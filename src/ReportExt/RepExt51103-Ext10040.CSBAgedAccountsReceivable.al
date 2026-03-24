reportextension 51103 "CSB Aged Accounts Receivable" extends "Aged Accounts Receivable NA" //10040
{
    dataset
    {
        add(Totals)
        {
            column(CSB_Cust__Ledger_Entry_SalespersonCode; "Cust. Ledger Entry"."Salesperson Code") { }
        }
    }
    rendering
    {
        layout(CSBDefaultRDLCLayout)
        {
            Type = RDLC;
            Caption = 'CSB Aged Accounts Receivable';
            Summary = 'CSB Aged Accounts Receivable';
            LayoutFile = './src/ReportExt/RDLC/RepExt51103-Ext10040.CSBAgedAccountsReceivable.rdlc';
        }
    }
}