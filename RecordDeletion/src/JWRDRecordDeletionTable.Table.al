table 90000 "JWRD Record Deletion Table"
{
    // **************************************************************************************************************************
    // Updated By Jenworks - JTS 20230824
    // Created and Designed by Olof Simren 2014
    // Downloaded from olofsimren.com
    //
    // For illustration only, without warranty, free to use as you want.
    // **************************************************************************************************************************

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Editable = false;
        }
        field(2; "Table Name"; Text[250])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Name" where("Object Type" = const(Table),
                                                                       "Object ID" = field("Table ID")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(3; "No. of Records"; Integer)
        {
            Editable = false;
            //CalcFormula = Lookup("Table Information"."No. of Records" WHERE("Company Name" = FIELD(Company),
            //                                                                 "Table No." = FIELD("Table ID")));
            //FieldClass = FlowField;
        }
        field(4; "No. of Table Relation Errors"; Integer)
        {
            CalcFormula = count("JWRD Rec Del. Table Rel. Error" where("Table ID" = field("Table ID")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "Delete Records"; Boolean)
        {
        }
        field(6; Company; Text[30])
        {
        }
    }

    keys
    {
        key(Key1; "Table ID")
        {
            Clustered = true;
        }
        key(Key2; "No. of Records") { }
        key(Key3; "Delete Records") { }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        Company := CopyStr(CompanyName(), 1, MaxStrLen(Company));
    end;
}
