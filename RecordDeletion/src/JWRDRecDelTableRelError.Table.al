table 90001 "JWRD Rec Del. Table Rel. Error"
{
    // **************************************************************************************************************************
    // Updated By Jenworks - JTS 20230824
    // Created and Designed by Olof Simren 2014
    // Downloaded from olofsimren.com
    //
    // For illustration only, without warranty, free to use as you want.
    // **************************************************************************************************************************

    DrillDownPageId = "JWRD Rec Del. Table Rel. Error";
    LookupPageId = "JWRD Rec Del. Table Rel. Error";

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Editable = false;
        }
        field(2; "Entry No."; Integer)
        {
            Editable = false;
        }
        field(3; "Field No."; Integer)
        {
            Editable = false;
        }
        field(4; "Field Name"; Text[30])
        {
            CalcFormula = lookup(Field.FieldName where(TableNo = field("Table ID"),
                                                        "No." = field("Field No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; Error; Text[250])
        {
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Table ID", "Entry No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}
