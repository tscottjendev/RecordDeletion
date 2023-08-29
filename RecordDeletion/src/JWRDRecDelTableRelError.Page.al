page 90001 "JWRD Rec Del. Table Rel. Error"
{
    // **************************************************************************************************************************
    // Updated By Jenworks - JTS 20230824
    // Created and Designed by Olof Simren 2014
    // Downloaded from olofsimren.com
    //
    // For illustration only, without warranty, free to use as you want.
    // **************************************************************************************************************************

    Editable = false;
    PageType = List;
    SourceTable = "JWRD Rec Del. Table Rel. Error";
    UsageCategory = None;

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
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = ' ';
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = ' ';
                }
                field(Error; Rec.Error)
                {
                    ApplicationArea = All;
                    ToolTip = ' ';
                }
            }
        }
    }

    actions
    {
    }
}
