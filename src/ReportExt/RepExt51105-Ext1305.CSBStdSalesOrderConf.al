reportextension 51105 "CSB Std. Sales - Order Conf." extends "Standard Sales - Order Conf." //1305
{
    dataset
    {
        add(Header)
        {
            column(CSBRequestedDeliveryDate; Format("Requested Delivery Date", 0, '<Month,2>/<Day,2>/<Year4>')) { }
            column(CSBTotalGrossWeight; "CSB Total Gross Weight") { }
        }
        add(Line)
        {
            column(CSBItemGTIN; "CSB Item GTIN") { }
            column(CSBLineGrossWeight; "CSB Line Gross Weight") { }
        }
    }

    rendering
    {
        layout(CSBDefaultRDLCLayout)
        {
            Type = RDLC;
            Caption = 'CSB Order Confirmation';
            Summary = 'CSB Order Confirmation';
            LayoutFile = './src/ReportExt/RDLC/RepExt51105-Ext1305.CSBStdSalesOrderConf.rdlc';
        }
    }
}
