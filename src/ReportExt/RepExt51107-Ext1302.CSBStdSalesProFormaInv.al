reportextension 51107 "CSB Std. Sales - Pro Forma Inv" extends "Standard Sales - Pro Forma Inv" //1302
{
    dataset
    {
        add(Header)
        {
            column(CSBShipmentDate; Format("Shipment Date", 0, '<Month,2>/<Day,2>/<Year4>')) { }
            column(CSBShippingAgentCode; "Shipping Agent Code") { }
            column(CSBShippingAgentName; GetShippingAgentName("Shipping Agent Code")) { }
            column(CSBPackageTrackingNo; "Package Tracking No.") { }
            column(CSBPallets; "CSB Pallets") { }
            column(CSBScaledWeight; "CSB Scaled Weight") { }
            column(CSBCartons; "CSB Cartons") { }
            column(CSBTotalGrossWeight; "CSB Total Gross Weight") { }
            column(CSBSellToCustomerNo; "Sell-to Customer No.") { }
            column(CSBPaymentTermsDesc; GetPaymentTermsDesc("Payment Terms Code")) { }
            column(CSBShippingMethodDesc; GetShipmentMethodDesc("Shipment Method Code")) { }
            column(CSBTotalAmounttoShip; "CSB Total Amount to Ship") { }
            column(CSBTotalAmountIncludingVAT; "Amount Including VAT") { }
            column(CSBCustAddr1; CustAddr[1]) { }
            column(CSBCustAddr2; CustAddr[2]) { }
            column(CSBCustAddr3; CustAddr[3]) { }
            column(CSBCustAddr4; CustAddr[4]) { }
            column(CSBCustAddr5; CustAddr[5]) { }
            column(CSBCustAddr6; CustAddr[6]) { }
            column(CSBShipToAddr1; ShipToAddr[1]) { }
            column(CSBShipToAddr2; ShipToAddr[2]) { }
            column(CSBShipToAddr3; ShipToAddr[3]) { }
            column(CSBShipToAddr4; ShipToAddr[4]) { }
            column(CSBShipToAddr5; ShipToAddr[5]) { }
            column(CSBShipToAddr6; ShipToAddr[6]) { }
        }
        modify(Header)
        {
            trigger OnAfterAfterGetRecord()
            var
                FormatAddr: Codeunit "Format Address";
            begin
                TrimHeaderAddress();
                FormatAddr.SalesHeaderBillTo(CustAddr, Header);
                FormatAddr.SalesHeaderShipTo(ShipToAddr, CustAddr, Header);
            end;
        }
        add(Line)
        {
            column(CSBItemNo; "No.") { }
            column(CSBQuantityShipped; "Quantity Shipped") { }
            column(CSBQtytoShip; "Qty. to Ship") { }
            column(CSBItemReferenceNo; "Item Reference No.") { }
            column(CSBLineDiscount; "Line Discount %") { }
            column(CSBLineAmount; "Line Amount") { }
            column(CSBAmountIncludingVAT; "Amount Including VAT") { }
            column(CSBLineDiscountPrc; "Line Discount %") { }
            column(CSBLineDiscountAmount; "Line Discount Amount") { }
            column(CSBItemGTIN; "CSB Item GTIN") { }
            column(CSBLineGrossWeight; "CSB Line Gross Weight") { }
            column(CSBOrderQty; Quantity) { }
            column(CSBUoM; "Unit of Measure Code") { }
            column(CSBAmounttoShip; "CSB Amount to Ship") { }
            column(CSBUnitPrice; "Unit Price") { }
            column(CSBOriginalQuantity; "CSB Original Quantity") { }
        }
    }

    rendering
    {
        layout(CSBDefaultRDLCLayout)
        {
            Type = RDLC;
            Caption = 'CSB Pro Forma Invoice';
            Summary = 'CSB Pro Forma Invoice';
            LayoutFile = './src/ReportExt/RDLC/RepExt51107-Ext1302.CSBStdSalesProFormaInv.rdlc';
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

    local procedure GetPaymentTermsDesc(PaymentTermsCode: Code[20]): Text[50]
    var
        PaymentTerms: Record "Payment Terms";
    begin
        if not PaymentTerms.Get(PaymentTermsCode) then
            exit('');

        exit(CopyStr(PaymentTerms.Description, 1, 50));
    end;

    local procedure GetShipmentMethodDesc(ShipmentMethodCode: Code[20]): Text[50]
    var
        ShipmentMethod: Record "Shipment Method";
    begin
        if not ShipmentMethod.Get(ShipmentMethodCode) then
            exit('');

        exit(CopyStr(ShipmentMethod.Description, 1, 50));
    end;

    local procedure TrimHeaderAddress()
    begin
        Header."Bill-to Name" := Header."Bill-to Name".Trim();
        Header."Bill-to Name 2" := Header."Bill-to Name 2".Trim();
        Header."Bill-to Contact" := Header."Bill-to Contact".Trim();
        Header."Bill-to Address" := Header."Bill-to Address".Trim();
        Header."Bill-to Address 2" := Header."Bill-to Address 2".Trim();
        Header."Bill-to City" := Header."Bill-to City".Trim();
        Header."Bill-to County" := Header."Bill-to County".Trim();

        Header."Ship-to Name" := Header."Ship-to Name".Trim();
        Header."Ship-to Name 2" := Header."Ship-to Name 2".Trim();
        Header."Ship-to Contact" := Header."Ship-to Contact".Trim();
        Header."Ship-to Address" := Header."Ship-to Address".Trim();
        Header."Ship-to Address 2" := Header."Ship-to Address 2".Trim();
        Header."Ship-to City" := Header."Ship-to City".Trim();
        Header."Ship-to County" := Header."Ship-to County".Trim();
    end;

    var
        CustAddr: array[8] of Text[100];
        ShipToAddr: array[8] of Text[100];
}
