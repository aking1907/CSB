reportextension 51102 "CSB Picking List by Order" extends "Picking List by Order" //10153
{
    dataset
    {
        add("Sales Header")
        {
            column(CSB_Sales_Header_Cartons; "CSB Cartons") { }
            column(CSB_Sales_Header_Pallets; "CSB Pallets") { }
            column(CSB_Sales_Header_ScaledWeight; "CSB Scaled Weight") { }
            column(CSB_Sales_Header_GrossWeight; "CSB Total Gross Weight") { }
            column(CSB_Sales_Header_ShippingAgentCode; "Shipping Agent Code") { }
            column(CSB_Sales_Header_ShippingAgentName; GetShippingAgentName("Shipping Agent Code")) { }
            column(CSB_Sales_Header_ExternalDocument_No; "External Document No.") { }
            column(CSB_Sales_Header_PackageTrackingNo; "Package Tracking No.") { }
            column(CSB_Sales_Header_YourReference; "Your Reference") { }
        }
        add("Sales Line")
        {
            column(CSB_Sales_Line_ItemGTIN; "CSB Item GTIN") { }
            column(CSB_Sales_Line_ShelfNo_; "CSB Shelf No.") { }
            column(CSB_Sales_Line_QtytoShip; "Qty. to Ship") { }
        }
    }
    rendering
    {
        layout(CSBDefaultRDLCLayout)
        {
            Type = RDLC;
            Caption = 'CSB Picking List by Order';
            Summary = 'CSB Picking List by Order';
            LayoutFile = './src/ReportExt/RDLC/RepExt51102-Ext10153.CSBPickingListbyOrder.rdlc';
        }
    }

    local procedure GetShippingAgentName(ShippingAgentCode: Code[20]): Text[50]
    var
        ShippingAgent: Record "Shipping Agent";
    begin
        if not ShippingAgent.Get(ShippingAgentCode) then
            exit('');

        exit(CopyStr(ShippingAgent.Name, 1, 50));
    end;
}
