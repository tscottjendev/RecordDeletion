codeunit 90000 "JWRD Record Deletion Mgt."
{
    var
        CheckingTableRelationsTxt: Label 'Checking Relations Between Records!\Table: #1#######', Comment = '#1 is the table id';
        CheckTableRelationsQst: Label 'Check Table Relations?';
        DeleteRecordsQst: Label 'Delete Records?';
        DeletingRecordsTxt: Label 'Deleting Records!\Table: #1#######', Comment = '#1 is the table id';
        DoesNotExistErr: Label '%1 => %2 = ''%3'' does not exist in the ''%4'' table', Comment = '%1 is the table name, %2 is the field name, %3 is the field value, %4 is the relation table name';

    procedure CheckTableRelations(var JWRDRecordDeletionTable: Record "JWRD Record Deletion Table")
    var

        RelationField: Record Field;
        SourceField: Record Field;
        JWRDRecDelTableRelError: Record "JWRD Rec Del. Table Rel. Error";
        TableKey: Record "Key";
        RelationRecordRef: RecordRef;
        SourceRecordRef: RecordRef;
        RelationFieldRef: FieldRef;
        SourceFieldRef: FieldRef;
        SkipCheck: Boolean;
        ProgressDialog: Dialog;
        EntryNo: Integer;
    begin
        if not Confirm(CheckTableRelationsQst, false) then
            exit;

        JWRDRecDelTableRelError.DeleteAll();
        ProgressDialog.Open(CheckingTableRelationsTxt);
        if JWRDRecordDeletionTable.IsEmpty() then
            exit;

        JWRDRecordDeletionTable.FindSet();
        repeat
            ProgressDialog.Update(1, Format(JWRDRecordDeletionTable."Table ID"));
            SourceRecordRef.Open(JWRDRecordDeletionTable."Table ID");
            if not SourceRecordRef.IsEmpty() then begin
                SourceRecordRef.FindSet();
                repeat
                    SourceField.SetRange(TableNo, JWRDRecordDeletionTable."Table ID");
                    SourceField.SetRange(Class, SourceField.Class::Normal);
                    SourceField.SetFilter(RelationTableNo, '<>0');
                    if not SourceField.IsEmpty() then begin
                        SourceField.FindSet();
                        repeat
                            SourceFieldRef := SourceRecordRef.Field(SourceField."No.");
                            if (Format(SourceFieldRef.Value) <> '') and (Format(SourceFieldRef.Value) <> '0') then begin
                                RelationRecordRef.Open(SourceField.RelationTableNo);
                                SkipCheck := false;
                                if SourceField.RelationFieldNo <> 0 then
                                    RelationFieldRef := RelationRecordRef.Field(SourceField.RelationFieldNo)
                                else begin
                                    TableKey.Get(SourceField.RelationTableNo, 1);  // PK
                                    RelationField.SetRange(TableNo, SourceField.RelationTableNo);
                                    RelationField.SetFilter(FieldName, CopyStr(TableKey.Key, 1, 30));
                                    if RelationField.FindFirst() then // No Match if Dual PK
                                        RelationFieldRef := RelationRecordRef.Field(RelationField."No.")
                                    else
                                        SkipCheck := true;
                                end;
                                if (SourceFieldRef.Type = RelationFieldRef.Type) and (SourceFieldRef.Length = RelationFieldRef.Length) and (not SkipCheck) then begin
                                    RelationFieldRef.SetRange(SourceFieldRef.Value);
                                    if not RelationRecordRef.FindFirst() then begin
                                        JWRDRecDelTableRelError.SetRange("Table ID", SourceRecordRef.Number);
                                        if JWRDRecDelTableRelError.FindLast() then
                                            EntryNo := JWRDRecDelTableRelError."Entry No." + 1
                                        else
                                            EntryNo := 1;
                                        JWRDRecDelTableRelError.Init();
                                        JWRDRecDelTableRelError."Table ID" := SourceRecordRef.Number;
                                        JWRDRecDelTableRelError."Entry No." := EntryNo;
                                        JWRDRecDelTableRelError."Field No." := SourceFieldRef.Number;
                                        JWRDRecDelTableRelError.Error := CopyStr(StrSubstNo(DoesNotExistErr, Format(SourceRecordRef.GetPosition()), Format(RelationFieldRef.Name), Format(SourceFieldRef.Value), Format(RelationRecordRef.Name)), 1, 250);
                                        JWRDRecDelTableRelError.Insert();
                                    end;
                                end;
                                RelationRecordRef.Close();
                            end;
                        until SourceField.Next() = 0;
                    end;
                until SourceRecordRef.Next() = 0;
            end;
            SourceRecordRef.Close();
        until JWRDRecordDeletionTable.Next() = 0;
        ProgressDialog.Close();
    end;

    procedure ClearRecordsToDelete()
    var
        JWRDRecordDeletionTable: Record "JWRD Record Deletion Table";
    begin
        JWRDRecordDeletionTable.ModifyAll("Delete Records", false);
    end;

    procedure DeleteRecords(var JWRDRecordDeletionTable: Record "JWRD Record Deletion Table")
    var
        JWRDRecDelTableRelError: Record "JWRD Rec Del. Table Rel. Error";
        RecordRef: RecordRef;
        ProgressDialog: Dialog;
    begin
        if not Confirm(DeleteRecordsQst, false) then
            exit;

        ProgressDialog.Open(DeletingRecordsTxt);
        if JWRDRecordDeletionTable.FindSet(true) then
            repeat
                if JWRDRecordDeletionTable."Delete Records" then begin
                    ProgressDialog.Update(1, Format(JWRDRecordDeletionTable."Table ID"));
                    RecordRef.Open(JWRDRecordDeletionTable."Table ID");
                    RecordRef.DeleteAll();
                    RecordRef.Close();
                    JWRDRecDelTableRelError.SetRange("Table ID", JWRDRecordDeletionTable."Table ID");
                    JWRDRecDelTableRelError.DeleteAll();
                end;
            until JWRDRecordDeletionTable.Next() = 0;
        JWRDRecordDeletionTable.ModifyAll("No. of Records", 0);
        ProgressDialog.Close();
    end;

    procedure InsertUpdateTables()
    var
        AllObj: Record AllObj;
        JWRDRecordDeletionTable: Record "JWRD Record Deletion Table";
        TableMetadata: Record "Table Metadata";
    begin
        AllObj.SetRange(AllObj."Object Type", AllObj."Object Type"::Table);
        AllObj.SetRange(AllObj."Object ID", 1, 1999999999);
        if AllObj.FindSet() then
            repeat
                if TableMetadata.Get(AllObj."Object ID") then
                    if TableMetadata.TableType = TableMetadata.TableType::Normal then begin
                        JWRDRecordDeletionTable.Init();
                        JWRDRecordDeletionTable."Table ID" := AllObj."Object ID";
                        JWRDRecordDeletionTable.Company := CopyStr(CompanyName(), 1, MaxStrLen(JWRDRecordDeletionTable.Company));
                        if JWRDRecordDeletionTable.Insert() then;
                    end
            until AllObj.Next() = 0;
        JWRDRecordDeletionTable.Reset();
        SetRecordCount(JWRDRecordDeletionTable);
    end;

    procedure SetRecordCount(var JWRDRecordDeletionTable: Record "JWRD Record Deletion Table")
    begin
        if JWRDRecordDeletionTable.FindSet(true) then
            repeat
                JWRDRecordDeletionTable."No. of Records" := GetRecordCount(JWRDRecordDeletionTable."Table ID");
                JWRDRecordDeletionTable.Modify();
            until JWRDRecordDeletionTable.Next() = 0;
    end;

    procedure SetSuggestedTable(TableID: Integer)
    var
        JWRDRecordDeletionTable: Record "JWRD Record Deletion Table";
    begin
        if JWRDRecordDeletionTable.Get(TableID) then begin
            JWRDRecordDeletionTable."Delete Records" := true;
            JWRDRecordDeletionTable.Modify();
        end;
    end;

    procedure SuggestRecordsToDelete()
    begin
        SetSuggestedTable(Database::"Action Message Entry");
        SetSuggestedTable(Database::"Analysis View Budget Entry");
        SetSuggestedTable(Database::"Analysis View Entry");
        SetSuggestedTable(Database::"Analysis View");
        SetSuggestedTable(Database::"Approval Comment Line");
        SetSuggestedTable(Database::"Approval Entry");
        SetSuggestedTable(Database::"Assemble-to-Order Link");
        SetSuggestedTable(Database::"Assembly Comment Line");
        SetSuggestedTable(Database::"Assembly Header");
        SetSuggestedTable(Database::"Assembly Line");
        SetSuggestedTable(Database::"Avg. Cost Adjmt. Entry Point");
        SetSuggestedTable(Database::"Bank Acc. Reconciliation Line");
        SetSuggestedTable(Database::"Bank Acc. Reconciliation");
        SetSuggestedTable(Database::"Bank Account Ledger Entry");
        SetSuggestedTable(Database::"Bank Account Ledger Entry");
        SetSuggestedTable(Database::"Bank Account Statement Line");
        SetSuggestedTable(Database::"Bank Account Statement");
        SetSuggestedTable(Database::"Bank Stmt Multiple Match Line");
        SetSuggestedTable(Database::"Campaign Entry");
        SetSuggestedTable(Database::"Capacity Ledger Entry");
        SetSuggestedTable(Database::"Cash Flow Manual Revenue");
        SetSuggestedTable(Database::"Cash Flow Manual Expense");
        SetSuggestedTable(Database::"Cash Flow Forecast Entry");
        SetSuggestedTable(Database::"Cash Flow Worksheet Line");
        SetSuggestedTable(Database::"Certificate of Supply");
        SetSuggestedTable(Database::"Change Log Entry");
        SetSuggestedTable(Database::"Check Ledger Entry");
        SetSuggestedTable(Database::"Comment Line");
        SetSuggestedTable(Database::"Contract Change Log");
        SetSuggestedTable(Database::"Contract Gain/Loss Entry");
        SetSuggestedTable(Database::"Contract/Service Discount");
        SetSuggestedTable(Database::"Cost Budget Entry");
        SetSuggestedTable(Database::"Cost Budget Register");
        SetSuggestedTable(Database::"Cost Entry");
        SetSuggestedTable(Database::"Cost Journal Line");
        SetSuggestedTable(Database::"Cost Register");
        SetSuggestedTable(Database::"Credit Trans Re-export History");
        SetSuggestedTable(Database::"Credit Transfer Entry");
        SetSuggestedTable(Database::"Credit Transfer Register");
        SetSuggestedTable(Database::"Cust. Ledger Entry");
        SetSuggestedTable(Database::"Date Compr. Register");
        SetSuggestedTable(Database::"Detailed Cust. Ledg. Entry");
        SetSuggestedTable(Database::"Detailed Vendor Ledg. Entry");
        SetSuggestedTable(Database::"Dimension Set Entry");
        SetSuggestedTable(Database::"Dimension Set Tree Node");
        SetSuggestedTable(Database::"Direct Debit Collection Entry");
        SetSuggestedTable(Database::"Direct Debit Collection");
        SetSuggestedTable(Database::"Document Entry");
        SetSuggestedTable(Database::"Email Item");
        SetSuggestedTable(Database::"Employee Absence");
        SetSuggestedTable(Database::"Error Buffer");
        SetSuggestedTable(Database::"Exch. Rate Adjmt. Reg.");
        SetSuggestedTable(Database::"FA G/L Posting Buffer");
        SetSuggestedTable(Database::"FA Ledger Entry");
        SetSuggestedTable(Database::"FA Register");
        SetSuggestedTable(Database::"Filed Contract Line");
        SetSuggestedTable(Database::"Filed Service Contract Header");
        SetSuggestedTable(Database::"Fin. Charge Comment Line");
        SetSuggestedTable(Database::"Finance Charge Memo Header");
        SetSuggestedTable(Database::"Finance Charge Memo Line");
        SetSuggestedTable(Database::"G/L - Item Ledger Relation");
        SetSuggestedTable(Database::"G/L Budget Entry");
        SetSuggestedTable(Database::"G/L Budget Name");
        SetSuggestedTable(Database::"G/L Entry - VAT Entry Link");
        SetSuggestedTable(Database::"G/L Entry");
        SetSuggestedTable(Database::"G/L Register");
        SetSuggestedTable(Database::"Gen. Jnl. Allocation");
        SetSuggestedTable(Database::"Gen. Journal Line");
        SetSuggestedTable(Database::"Handled IC Inbox Jnl. Line");
        SetSuggestedTable(Database::"Handled IC Inbox Purch. Header");
        SetSuggestedTable(Database::"Handled IC Inbox Purch. Line");
        SetSuggestedTable(Database::"Handled IC Inbox Sales Header");
        SetSuggestedTable(Database::"Handled IC Inbox Sales Line");
        SetSuggestedTable(Database::"Handled IC Inbox Trans.");
        SetSuggestedTable(Database::"Handled IC Outbox Jnl. Line");
        SetSuggestedTable(Database::"Handled IC Outbox Purch. Hdr");
        SetSuggestedTable(Database::"Handled IC Outbox Purch. Line");
        SetSuggestedTable(Database::"Handled IC Outbox Sales Header");
        SetSuggestedTable(Database::"Handled IC Outbox Sales Line");
        SetSuggestedTable(Database::"Handled IC Outbox Trans.");
        SetSuggestedTable(Database::"IC Comment Line");
        SetSuggestedTable(Database::"IC Document Dimension");
        SetSuggestedTable(Database::"IC Inbox Jnl. Line");
        SetSuggestedTable(Database::"IC Inbox Purchase Header");
        SetSuggestedTable(Database::"IC Inbox Purchase Line");
        SetSuggestedTable(Database::"IC Inbox Sales Header");
        SetSuggestedTable(Database::"IC Inbox Sales Line");
        SetSuggestedTable(Database::"IC Inbox Transaction");
        SetSuggestedTable(Database::"IC Inbox/Outbox Jnl. Line Dim.");
        SetSuggestedTable(Database::"IC Outbox Jnl. Line");
        SetSuggestedTable(Database::"IC Outbox Purchase Header");
        SetSuggestedTable(Database::"IC Outbox Purchase Line");
        SetSuggestedTable(Database::"IC Outbox Sales Header");
        SetSuggestedTable(Database::"IC Outbox Sales Line");
        SetSuggestedTable(Database::"IC Outbox Transaction");
        SetSuggestedTable(Database::"Incoming Document");
        SetSuggestedTable(Database::"Ins. Coverage Ledger Entry");
        SetSuggestedTable(Database::"Insurance Register");
        SetSuggestedTable(Database::"Inter. Log Entry Comment Line");
        SetSuggestedTable(Database::"Interaction Log Entry");
        SetSuggestedTable(Database::"Internal Movement Header");
        SetSuggestedTable(Database::"Internal Movement Line");
        SetSuggestedTable(Database::"Inventory Adjmt. Entry (Order)");
        SetSuggestedTable(Database::"Inventory Period Entry");
        SetSuggestedTable(Database::"Inventory Report Entry");
        SetSuggestedTable(Database::"Issued Fin. Charge Memo Header");
        SetSuggestedTable(Database::"Issued Fin. Charge Memo Line");
        SetSuggestedTable(Database::"Issued Reminder Header");
        SetSuggestedTable(Database::"Issued Reminder Line");
        SetSuggestedTable(Database::"Item Analysis View Budg. Entry");
        SetSuggestedTable(Database::"Item Analysis View Entry");
        SetSuggestedTable(Database::"Item Analysis View");
        SetSuggestedTable(Database::"Item Application Entry History");
        SetSuggestedTable(Database::"Item Application Entry");
        SetSuggestedTable(Database::"Item Budget Entry");
        SetSuggestedTable(Database::"Item Charge Assignment (Purch)");
        SetSuggestedTable(Database::"Item Charge Assignment (Sales)");
        SetSuggestedTable(Database::"Item Entry Relation");
        SetSuggestedTable(Database::"Item Journal Line");
        SetSuggestedTable(Database::"Item Ledger Entry");
        SetSuggestedTable(Database::"Item Register");
        SetSuggestedTable(Database::"Item Tracking Comment");
        SetSuggestedTable(Database::"Job Entry No.");
        SetSuggestedTable(Database::"Job Journal Line");
        SetSuggestedTable(Database::"Job Ledger Entry");
        SetSuggestedTable(Database::"Job Planning Line Invoice");
        SetSuggestedTable(Database::"Job Planning Line");
        SetSuggestedTable(Database::"Job Queue Log Entry");
        SetSuggestedTable(Database::"Job Register");
        SetSuggestedTable(Database::"Job Task Dimension");
        SetSuggestedTable(Database::"Job Task");
        SetSuggestedTable(Database::"Job Usage Link");
        SetSuggestedTable(Database::"Job WIP Entry");
        SetSuggestedTable(Database::"Job WIP G/L Entry");
        SetSuggestedTable(Database::"Job WIP Total");
        SetSuggestedTable(Database::"Job WIP Warning");
        SetSuggestedTable(Database::"Loaner Entry");
        SetSuggestedTable(Database::"Lot No. Information");
        SetSuggestedTable(Database::"Maintenance Ledger Entry");
        SetSuggestedTable(Database::"Maintenance Registration");
        SetSuggestedTable(Database::"Opportunity Entry");
        SetSuggestedTable(Database::"Order Promising Line");
        SetSuggestedTable(Database::"Order Tracking Entry");
        SetSuggestedTable(Database::"Payable Vendor Ledger Entry");
        SetSuggestedTable(Database::"Payment Application Proposal");
        SetSuggestedTable(Database::"Payment Export Data");
        SetSuggestedTable(Database::"Payment Jnl. Export Error Text");
        SetSuggestedTable(Database::"Payment Matching Details");
        SetSuggestedTable(Database::"Phys. Inventory Ledger Entry");
        SetSuggestedTable(Database::"Planning Assignment");
        SetSuggestedTable(Database::"Planning Component");
        SetSuggestedTable(Database::"Planning Error Log");
        SetSuggestedTable(Database::"Planning Routing Line");
        SetSuggestedTable(Database::"Post Value Entry to G/L");
        SetSuggestedTable(Database::"Posted Approval Comment Line");
        SetSuggestedTable(Database::"Posted Approval Entry");
        SetSuggestedTable(Database::"Posted Assemble-to-Order Link");
        SetSuggestedTable(Database::"Posted Assembly Header");
        SetSuggestedTable(Database::"Posted Assembly Line");
        SetSuggestedTable(Database::"Posted Invt. Pick Header");
        SetSuggestedTable(Database::"Posted Invt. Pick Line");
        SetSuggestedTable(Database::"Posted Invt. Put-away Header");
        SetSuggestedTable(Database::"Posted Invt. Put-away Line");
        SetSuggestedTable(Database::"Posted Payment Recon. Hdr");
        SetSuggestedTable(Database::"Posted Payment Recon. Line");
        SetSuggestedTable(Database::"Posted Whse. Receipt Header");
        SetSuggestedTable(Database::"Posted Whse. Receipt Line");
        SetSuggestedTable(Database::"Posted Whse. Shipment Header");
        SetSuggestedTable(Database::"Posted Whse. Shipment Line");
        SetSuggestedTable(Database::"Prod. Order Capacity Need");
        SetSuggestedTable(Database::"Prod. Order Comment Line");
        SetSuggestedTable(Database::"Prod. Order Comp. Cmt Line");
        SetSuggestedTable(Database::"Prod. Order Component");
        SetSuggestedTable(Database::"Prod. Order Line");
        SetSuggestedTable(Database::"Prod. Order Routing Line");
        SetSuggestedTable(Database::"Prod. Order Routing Personnel");
        SetSuggestedTable(Database::"Prod. Order Routing Tool");
        SetSuggestedTable(Database::"Prod. Order Rtng Comment Line");
        SetSuggestedTable(Database::"Prod. Order Rtng Qlty Meas.");
        SetSuggestedTable(Database::"Production Forecast Entry");
        SetSuggestedTable(Database::"Production Order");
        SetSuggestedTable(Database::"Purch. Comment Line Archive");
        SetSuggestedTable(Database::"Purch. Comment Line");
        SetSuggestedTable(Database::"Purch. Cr. Memo Hdr.");
        SetSuggestedTable(Database::"Purch. Cr. Memo Line");
        SetSuggestedTable(Database::"Purch. Inv. Header");
        SetSuggestedTable(Database::"Purch. Inv. Line");
        SetSuggestedTable(Database::"Purch. Rcpt. Header");
        SetSuggestedTable(Database::"Purch. Rcpt. Line");
        SetSuggestedTable(Database::"Purchase Header Archive");
        SetSuggestedTable(Database::"Purchase Header");
        SetSuggestedTable(Database::"Purchase Line Archive");
        SetSuggestedTable(Database::"Purchase Line");
        SetSuggestedTable(Database::"Registered Invt. Movement Hdr.");
        SetSuggestedTable(Database::"Registered Invt. Movement Line");
        SetSuggestedTable(Database::"Registered Whse. Activity Hdr.");
        SetSuggestedTable(Database::"Registered Whse. Activity Line");
        SetSuggestedTable(Database::"Reminder Comment Line");
        SetSuggestedTable(Database::"Reminder Header");
        SetSuggestedTable(Database::"Reminder Line");
        SetSuggestedTable(Database::"Reminder/Fin. Charge Entry");
        SetSuggestedTable(Database::"Requisition Line");
        SetSuggestedTable(Database::"Res. Capacity Entry");
        SetSuggestedTable(Database::"Res. Journal Line");
        SetSuggestedTable(Database::"Res. Ledger Entry");
        SetSuggestedTable(Database::"Reservation Entry");
        SetSuggestedTable(Database::"Resource Register");
        SetSuggestedTable(Database::"Return Receipt Header");
        SetSuggestedTable(Database::"Return Receipt Line");
        SetSuggestedTable(Database::"Return Shipment Header");
        SetSuggestedTable(Database::"Return Shipment Line");
        SetSuggestedTable(Database::"Returns-Related Document");
        SetSuggestedTable(Database::"Reversal Entry");
        SetSuggestedTable(Database::"Rounding Residual Buffer");
        SetSuggestedTable(Database::"Sales Comment Line Archive");
        SetSuggestedTable(Database::"Sales Comment Line");
        SetSuggestedTable(Database::"Sales Cr.Memo Header");
        SetSuggestedTable(Database::"Sales Cr.Memo Line");
        SetSuggestedTable(Database::"Sales Header Archive");
        SetSuggestedTable(Database::"Sales Header");
        SetSuggestedTable(Database::"Sales Invoice Header");
        SetSuggestedTable(Database::"Sales Invoice Line");
        SetSuggestedTable(Database::"Sales Line Archive");
        SetSuggestedTable(Database::"Sales Line");
        SetSuggestedTable(Database::"Sales Planning Line");
        SetSuggestedTable(Database::"Sales Shipment Header");
        SetSuggestedTable(Database::"Sales Shipment Line");
        SetSuggestedTable(Database::"Segment Criteria Line");
        SetSuggestedTable(Database::"Segment Header");
        SetSuggestedTable(Database::"Segment History");
        SetSuggestedTable(Database::"Segment Interaction Language");
        SetSuggestedTable(Database::"Segment Line");
        SetSuggestedTable(Database::"Serial No. Information");
        SetSuggestedTable(Database::"Service Comment Line");
        SetSuggestedTable(Database::"Service Contract Header");
        SetSuggestedTable(Database::"Service Contract Line");
        SetSuggestedTable(Database::"Service Cr.Memo Header");
        SetSuggestedTable(Database::"Service Cr.Memo Line");
        SetSuggestedTable(Database::"Service Document Log");
        SetSuggestedTable(Database::"Service Document Register");
        SetSuggestedTable(Database::"Service Header");
        SetSuggestedTable(Database::"Service Invoice Header");
        SetSuggestedTable(Database::"Service Invoice Line");
        SetSuggestedTable(Database::"Service Item Component");
        SetSuggestedTable(Database::"Service Item Line");
        SetSuggestedTable(Database::"Service Item Log");
        SetSuggestedTable(Database::"Service Item");
        SetSuggestedTable(Database::"Service Ledger Entry");
        SetSuggestedTable(Database::"Service Line Price Adjmt.");
        SetSuggestedTable(Database::"Service Line");
        SetSuggestedTable(Database::"Service Order Allocation");
        SetSuggestedTable(Database::"Service Register");
        SetSuggestedTable(Database::"Service Shipment Header");
        SetSuggestedTable(Database::"Service Shipment Item Line");
        SetSuggestedTable(Database::"Service Shipment Line");
        SetSuggestedTable(Database::"Time Sheet Cmt. Line Archive");
        SetSuggestedTable(Database::"Time Sheet Comment Line");
        SetSuggestedTable(Database::"Time Sheet Detail Archive");
        SetSuggestedTable(Database::"Time Sheet Detail");
        SetSuggestedTable(Database::"Time Sheet Header Archive");
        SetSuggestedTable(Database::"Time Sheet Header");
        SetSuggestedTable(Database::"Time Sheet Line Archive");
        SetSuggestedTable(Database::"Time Sheet Line");
        SetSuggestedTable(Database::"Time Sheet Posting Entry");
        SetSuggestedTable(Database::"To-do");
        SetSuggestedTable(Database::"Tracking Specification");
        SetSuggestedTable(Database::"Transfer Header");
        SetSuggestedTable(Database::"Transfer Line");
        SetSuggestedTable(Database::"Transfer Receipt Header");
        SetSuggestedTable(Database::"Transfer Receipt Line");
        SetSuggestedTable(Database::"Transfer Shipment Header");
        SetSuggestedTable(Database::"Transfer Shipment Line");
        SetSuggestedTable(Database::"Unplanned Demand");
        SetSuggestedTable(Database::"Untracked Planning Element");
        SetSuggestedTable(Database::"Value Entry Relation");
        SetSuggestedTable(Database::"Value Entry");
        SetSuggestedTable(Database::"VAT Entry");
        SetSuggestedTable(Database::"VAT Rate Change Log Entry");
        SetSuggestedTable(Database::"VAT Report Header");
        SetSuggestedTable(Database::"VAT Report Line");
        SetSuggestedTable(Database::"VAT Report Line Relation");
        SetSuggestedTable(Database::"VAT Report Error Log");
        SetSuggestedTable(Database::"Vendor Ledger Entry");
        SetSuggestedTable(Database::"Warehouse Activity Header");
        SetSuggestedTable(Database::"Warehouse Activity Line");
        SetSuggestedTable(Database::"Warehouse Entry");
        SetSuggestedTable(Database::"Warehouse Journal Line");
        SetSuggestedTable(Database::"Warehouse Receipt Header");
        SetSuggestedTable(Database::"Warehouse Receipt Line");
        SetSuggestedTable(Database::"Warehouse Register");
        SetSuggestedTable(Database::"Warehouse Request");
        SetSuggestedTable(Database::"Warehouse Shipment Header");
        SetSuggestedTable(Database::"Warehouse Shipment Line");
        SetSuggestedTable(Database::"Warranty Ledger Entry");
        SetSuggestedTable(Database::"Whse. Internal Pick Header");
        SetSuggestedTable(Database::"Whse. Internal Pick Line");
        SetSuggestedTable(Database::"Whse. Internal Put-away Header");
        SetSuggestedTable(Database::"Whse. Internal Put-away Line");
        SetSuggestedTable(Database::"Whse. Item Entry Relation");
        SetSuggestedTable(Database::"Whse. Item Tracking Line");
        SetSuggestedTable(Database::"Whse. Pick Request");
        SetSuggestedTable(Database::"Whse. Put-away Request");
        SetSuggestedTable(Database::"Whse. Worksheet Line");
        SetSuggestedTable(Database::Attachment);
        SetSuggestedTable(Database::Attendee);
        SetSuggestedTable(Database::Job);
        SetSuggestedTable(Database::Opportunity);

        OnAfterSuggestRecordsToDelete();
    end;

    procedure ViewRecords(JWRDRecordDeletionTable: Record "JWRD Record Deletion Table")
    begin
        Hyperlink(GetUrl(ClientType::Current, CompanyName, ObjectType::Table, JWRDRecordDeletionTable."Table ID"));
    end;

    local procedure GetRecordCount(TableID: Integer): Integer
    var
        RecordRef: RecordRef;

    begin
        RecordRef.Open(TableID);
        RecordRef.LockTable();
        exit(RecordRef.Count);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterSuggestRecordsToDelete();
    begin
    end;
}
