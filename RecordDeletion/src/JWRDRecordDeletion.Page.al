page 90000 "JWRD Record Deletion"
{
    ApplicationArea = All;
    Caption = 'Record Deletion';
    // **************************************************************************************************************************
    // Updated By Jenworks - JTS 20230824
    // Created and Designed by Olof Simren 2014
    // Downloaded from olofsimren.com
    //
    // For illustration only, without warranty, free to use as you want.
    // **************************************************************************************************************************

    InsertAllowed = false;
    PageType = List;
    SourceTable = "JWRD Record Deletion Table";
    UsageCategory = Administration;

    layout
    {
        area(Content)

        {
            repeater(Group)
            {
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = ' ';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = ' ';
                }
                field("No. of Records"; Rec."No. of Records")
                {
                    ApplicationArea = All;
                    ToolTip = ' ';
                }
                field("No. of Table Relation Errors"; Rec."No. of Table Relation Errors")
                {
                    ApplicationArea = All;
                    ToolTip = ' ';
                }
                field(DeleteRecords; Rec."Delete Records")
                {
                    ApplicationArea = All;
                    ToolTip = ' ';
                }
            }
        }
    }


    actions
    {
        area(Promoted)
        {
            actionref("InsertUpdateTables"; "Insert/Update Tables") { }
            actionref("SuggestRecordsToDelete"; "Suggest Records to Delete") { }
            actionref("ClearRecordsToDelete"; "Clear Records to Delete") { }
            actionref("DeleteRecordsPromotedAction"; "Delete Records") { }
            actionref("CheckTableRelations"; "Check Table Relations") { }
            actionref("ViewRecords"; "View Records") { }


        }
        area(Processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Insert/Update Tables")
                {
                    ApplicationArea = All;
                    Caption = 'Insert/Update Tables';
                    Image = Refresh;
                    ToolTip = ' ';

                    trigger OnAction()
                    var
                        JWRDRecordDeletionMgt: Codeunit "JWRD Record Deletion Mgt.";
                    begin
                        JWRDRecordDeletionMgt.InsertUpdateTables();
                    end;
                }
                action("Update Record Count")
                {
                    ApplicationArea = All;
                    Caption = 'Update Record Count';
                    Image = Refresh;
                    ToolTip = ' ';

                    trigger OnAction()
                    var
                        JWRDRecordDeletionTable: Record "JWRD Record Deletion Table";
                        JWRDRecordDeletionMgt: Codeunit "JWRD Record Deletion Mgt.";
                    begin
                        CurrPage.SetSelectionFilter(JWRDRecordDeletionTable);
                        JWRDRecordDeletionMgt.SetRecordCount(JWRDRecordDeletionTable);
                    end;
                }
                action("Suggest Records to Delete")
                {
                    ApplicationArea = All;
                    Caption = 'Suggest Records to Delete';
                    Image = Suggest;
                    ToolTip = ' ';

                    trigger OnAction()
                    var
                        JWRDRecordDeletionMgt: Codeunit "JWRD Record Deletion Mgt.";
                    begin
                        JWRDRecordDeletionMgt.SuggestRecordsToDelete();
                    end;
                }
                action("Clear Records to Delete")
                {
                    ApplicationArea = All;
                    Caption = 'Clear Records to Delete';
                    Image = ClearLog;
                    ToolTip = ' ';

                    trigger OnAction()
                    var
                        JWRDRecordDeletionMgt: Codeunit "JWRD Record Deletion Mgt.";
                    begin
                        JWRDRecordDeletionMgt.ClearRecordsToDelete();
                    end;
                }
                action("Delete Records")
                {
                    ApplicationArea = All;
                    Caption = 'Delete Records';
                    Image = Delete;
                    ToolTip = ' ';

                    trigger OnAction()
                    var
                        JWRDRecordDeletionTable: Record "JWRD Record Deletion Table";
                        JWRDRecordDeletionMgt: Codeunit "JWRD Record Deletion Mgt.";
                    begin
                        CurrPage.SetSelectionFilter(JWRDRecordDeletionTable);
                        JWRDRecordDeletionMgt.DeleteRecords(JWRDRecordDeletionTable);
                    end;
                }
                action("Check Table Relations")
                {
                    ApplicationArea = All;
                    Caption = 'Check Table Relations';
                    Image = Relationship;
                    ToolTip = ' ';

                    trigger OnAction()
                    var
                        JWRDRecordDeletionTable: Record "JWRD Record Deletion Table";
                        JWRDRecordDeletionMgt: Codeunit "JWRD Record Deletion Mgt.";
                    begin
                        CurrPage.SetSelectionFilter(JWRDRecordDeletionTable);
                        JWRDRecordDeletionMgt.CheckTableRelations(JWRDRecordDeletionTable);
                    end;
                }
                action("View Records")
                {
                    ApplicationArea = All;
                    Caption = 'View Records';
                    Image = "Table";
                    ToolTip = ' ';

                    trigger OnAction()
                    var
                        JWRDRecordDeletionMgt: Codeunit "JWRD Record Deletion Mgt.";
                    begin
                        JWRDRecordDeletionMgt.ViewRecords(Rec);
                    end;
                }
            }
        }
    }
    views
    {
        view(HasRecords)
        {
            Caption = 'Has Records';
            Filters = where("No. of Records" = filter(> 0));
            OrderBy = descending("No. of Records");
        }
        view(TablesToProcess)
        {
            Caption = 'Tables to Process';
            Filters = where("Delete Records" = const(true), "No. of Records" = filter(> 0));
            OrderBy = descending("No. of Records");
        }
    }
}
