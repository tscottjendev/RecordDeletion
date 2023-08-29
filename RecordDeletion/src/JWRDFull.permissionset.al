permissionset 90000 "JWRD Full"
{
    Assignable = true;
    Permissions =
        table "JWRD Rec Del. Table Rel. Error" = X,
        tabledata "JWRD Rec Del. Table Rel. Error" = RIMD,
        table "JWRD Record Deletion Table" = X,
        tabledata "JWRD Record Deletion Table" = RIMD,
        codeunit "JWRD Record Deletion Mgt." = X,
        page "JWRD Rec Del. Table Rel. Error" = X,
        page "JWRD Record Deletion" = X;
}