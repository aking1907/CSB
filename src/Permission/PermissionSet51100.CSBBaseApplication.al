permissionset 51100 "CSB Base Application"
{
    Assignable = true;
    Permissions = tabledata "CSB General Setup" = RIMD,
        table "CSB General Setup" = X,
        codeunit "CSB Event Subscriber" = X,
        page "CSB General Setup" = X,
        tabledata "CSB Order Status" = RIMD,
        table "CSB Order Status" = X,
        report "CSB Create Payments" = X,
        report "CSB Create PO From SO" = X,
        report "CSB Create SO From PO" = X,
        report "CSB Export Paym. Jnl. VLE Appl" = X,
        report "CSB Posted Sal. Inv. Lines" = X,
        report "CSB Sales Invoice" = X,
        codeunit "CSB Modify System Records" = X,
        page "CSB Order Status List" = X,
        page "CSB Paym. Jnl. VLE Appl." = X;
}