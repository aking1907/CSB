report 51103 "CSB Sales Invoice"
{
    ApplicationArea = All;
    Caption = 'CSB Sales Invoice';
    UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = DefaultLayout;

    dataset
    {
        dataitem(Header; "Sales Invoice Header")
        {
            RequestFilterFields = "No.";

            column(No; "No.") { }
            column(BilltoCustomerNo; "Bill-to Customer No.") { }
            column(QuoteNo; "Quote No.") { }
            column(CustAddr1; CustAddr[1]) { }
            column(CustAddr2; CustAddr[2]) { }
            column(CustAddr3; CustAddr[3]) { }
            column(CustAddr4; CustAddr[4]) { }
            column(CustAddr5; CustAddr[5]) { }
            column(CustAddr6; CustAddr[6]) { }
            column(ShipToAddr1; ShipToAddr[1]) { }
            column(ShipToAddr2; ShipToAddr[2]) { }
            column(ShipToAddr3; ShipToAddr[3]) { }
            column(ShipToAddr4; ShipToAddr[4]) { }
            column(ShipToAddr5; ShipToAddr[5]) { }
            column(ShipToAddr6; ShipToAddr[6]) { }
            column(PostingDate; Format("Posting Date", 0, '<Month,2>/<Day,2>/<Year4>')) { }
            column(OrderDate; Format("Order Date", 0, '<Month,2>/<Day,2>/<Year4>')) { }
            column(ShippingAgentCode; "Shipping Agent Code") { }
            column(ShippingAgentName; ShippingAgentName) { }
            column(ShipmentMethodCode; "Shipment Method Code") { }
            column(ShipmentMethodDesc; ShipmentMethodDesc) { }
            column(PaymentTermsCode; GetPaymentTermsDesc("Payment Terms Code")) { }
            column(ShipmentDate; Format("Shipment Date", 0, '<Month,2>/<Day,2>/<Year4>')) { }
            column(SalespersonCode; GetSalespersonName("Salesperson Code")) { }
            column(ExternalDocumentNo; "External Document No.") { }
            column(ShowShippingAddr; ShowShippingAddr) { }
            column(HomePage; GetHomePage("Sell-to Customer No.")) { }
            column(CompanyName; CompanyInformation.Name) { }
            column(CompanyAddress; CompanyInformation.Address) { }
            column(CompanyAddress2; CompanyInformation.City + ' ' + CompanyInformation.County + ', ' + CompanyInformation."Post Code") { }
            column(CompanyPhone; 'Phone: ' + CompanyInformation."Phone No.") { }
            column(CompanyFax; 'Fax: ' + CompanyInformation."Fax No.") { }
            column(CompanyLogo; CompanyInformation.Picture) { }
            column(OrderNo; "Order No.") { }
            column(TotalPieces; TotalPieces) { }
            column(TotalPrice; TotalPrice) { }
            column(CSBCartons; "CSB Cartons") { }
            column(CSBPallets; "CSB Pallets") { }
            column(CSBScaledWeight; "CSB Scaled Weight") { }
            column(CSBTotalGrossWeight; "CSB Total Gross Weight") { }
            column(PackageTrackingNo; "Package Tracking No.") { }
            column(TotalExtAmtOfTypeItem; TotalExtAmtOfTypeItem) { DecimalPlaces = 2 : 2; }
            column(TotalDiscountPrc; TotalDiscountPrc) { DecimalPlaces = 2 : 2; }
            column(TotalDiscountAmount; TotalDiscountAmount) { DecimalPlaces = 2 : 2; }
            column(TotalLineDiscountAmount; TotalLineDiscountAmount) { DecimalPlaces = 2 : 2; }
            column(TotalFreight; TotalFreight) { DecimalPlaces = 2 : 2; }
            column(TotalMiscChargesDiscounts; TotalMiscChargesDiscounts) { DecimalPlaces = 2 : 2; }
            column(InvoiceDiscountAmount; "Invoice Discount Amount") { }
            column(AmountIncludingTax; "Amount Including VAT") { }


            dataitem(Line; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemLinkReference = Header;
                UseTemporary = true;

                column(ItemNo; "No.") { }
                column(Description; Description) { }
                column(ItemReferenceNo; "Item Reference No.") { }
                column(Quantity; Quantity) { }
                column(UnitOfMeasure; "Unit of Measure") { }
                column(UnitCost; "Unit Cost") { }
                column(UnitPrice; "Unit Price") { }
                column(Amount; LineAmountWODisc) { }
                column(ItemGTIN; ItemGTIN) { }
                column(CSBRetailPrice; "CSB Retail Price") { }
                column(CSBOriginalQuantity; "CSB Original Quantity") { }
                column(AmountIncludingVAT; "Amount Including VAT") { }
                column(LineDiscountPrc; "Line Discount %") { }
                column(LineDiscountAmount; "Line Discount Amount") { }
                column(LineNo; "Line No.") { }
                column(LineAmount; "Line Amount") { }
                column(Type; Type) { }

                trigger OnAfterGetRecord()
                var
                    Item: Record Item;
                begin
                    ItemGTIN := '';
                    LineAmountWODisc := Line.Quantity * Line."Unit Price";

                    if Line.Type = Line.Type::Item then
                        if Item.Get(Line."No.") then
                            if Item.GTIN <> '' then
                                ItemGTIN := 'GTIN: ' + Item.GTIN;
                end;
            }

            trigger OnAfterGetRecord()
            var
                Customer: Record Customer;
                SalesInvoiceLine: Record "Sales Invoice Line";
                ShipmentMethod: Record "Shipment Method";
                ShippingAgent: Record "Shipping Agent";
                FormatAddr: Codeunit "Format Address";
                CSBGeneralSetup: Record "CSB General Setup";
                i: Integer;
                j: Integer;
                Skip: Boolean;
            begin
                ShippingAgentName := '';
                ShipmentMethodDesc := '';
                TotalExtAmtOfTypeItem := 0;

                TrimHeaderAddress();
                FormatAddr.SalesInvBillTo(CustAddr, Header);
                Skip := false;
                if Customer.Get(Header."Bill-to Customer No.") then
                    for i := 1 to 8 do begin
                        if not Skip and (CustAddr[i] = '') then begin
                            CustAddr[i] := 'Phone: ' + Customer."Phone No.";
                            Skip := true;
                        end;
                    end;

                FormatAddr.SalesInvShipTo(ShipToAddr, CustAddr, Header);
                Skip := false;
                if Customer.Get(Header."Bill-to Customer No.") then
                    for i := 1 to 8 do begin
                        if not Skip and (ShipToAddr[i] = '') then begin
                            ShipToAddr[i] := 'Phone: ' + Customer."Phone No.";
                            Skip := true;
                        end;
                    end;

                i := 0;
                TotalPieces := 0;
                TotalPrice := 0;

                for j := 1 to 6 do begin
                    case j of
                        1:
                            SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
                        2:
                            SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::"G/L Account");
                        3:
                            SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::"Charge (Item)");
                        4:
                            SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Resource);
                        5:
                            SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::"Fixed Asset");
                        6:
                            SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::"Allocation Account");
                    end;

                    SalesInvoiceLine.SetCurrentKey(Description, "No.");
                    SalesInvoiceLine.SetRange("Document No.", Header."No.");
                    if not GlobalShowZeroQtyLines then
                        SalesInvoiceLine.SetFilter(Quantity, '<>0');
                    if SalesInvoiceLine.FindSet() then
                        repeat
                            TotalPieces += SalesInvoiceLine.Quantity;
                            TotalPrice += SalesInvoiceLine.Amount;

                            i += 1;
                            Line := SalesInvoiceLine;
                            Line."Line No." := i;
                            Line.Insert();

                        until SalesInvoiceLine.Next() = 0;
                end;

                if ShipmentMethod.Get(Header."Shipment Method Code") then
                    ShipmentMethodDesc := ShipmentMethod.Description;

                if ShippingAgent.Get(Header."Shipping Agent Code") then
                    ShippingAgentName := ShippingAgent.Name;

                SalesInvoiceLine.Reset();
                SalesInvoiceLine.SetRange("Document No.", Header."No.");
                SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);

                SalesInvoiceLine.CalcSums("Line Discount Amount", Amount, "Line Amount");
                TotalDiscountAmount := SalesInvoiceLine."Line Discount Amount" + Header."Invoice Discount Value";
                TotalLineDiscountAmount := SalesInvoiceLine."Line Discount Amount";
                TotalExtAmtOfTypeItem := GetTotalItemAmountWODiscount(Header);

                TotalDiscountPrc := 0;
                if TotalExtAmtOfTypeItem <> 0 then
                    TotalDiscountPrc := Round(TotalDiscountAmount / TotalExtAmtOfTypeItem * 100, 0.01, '=');

                CSBGeneralSetup.Get();
                SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::"G/L Account");
                if CSBGeneralSetup."Freight G/L Account" <> '' then
                    SalesInvoiceLine.SetRange("No.", CSBGeneralSetup."Freight G/L Account");
                SalesInvoiceLine.CalcSums(Amount);
                TotalFreight := SalesInvoiceLine.Amount;

                if CSBGeneralSetup."Freight G/L Account" <> '' then
                    SalesInvoiceLine.SetFilter("No.", '<>%1', CSBGeneralSetup."Freight G/L Account");
                SalesInvoiceLine.CalcSums(Amount);
                TotalMiscChargesDiscounts := SalesInvoiceLine.Amount;

            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                field(ShowZeroQtyLines; GlobalShowZeroQtyLines)
                {
                    ApplicationArea = All;
                    Caption = 'Show Zero Qty. Lines';
                    ToolTip = 'Specifies the Show Zero Qty. Lines field.';
                }
            }
        }
    }
    rendering
    {
        layout(DefaultLayout)
        {
            Type = RDLC;
            LayoutFile = './src/Report/RDLC/Rep51103.CSBSalesInvoice.rdlc';
            Caption = 'CSB Sales Invoice';
            Summary = 'CSB Sales Invoice';
        }
        // layout(SIWithOriginalQtyLayout)
        // {
        //     Type = RDLC;
        //     LayoutFile = './src/Report/RDLC/Rep51103.CSBSalesInvoiceWithOriginalQty.rdlc';
        //     Caption = 'CSB Sales Invoice With Original Qty.';
        //     Summary = 'CSB Sales Invoice With Original Qty.';
        // }
        // layout(SIWithUPC)
        // {
        //     Type = RDLC;
        //     LayoutFile = './src/Report/RDLC/Rep51103.CSBSalesInvoiceUPC.rdlc';
        //     Caption = 'CSB Sales Invoice With UPC';
        //     Summary = 'CSB Sales Invoice With UPC';
        // }
    }

    trigger OnInitReport()
    begin

        GlobalShowZeroQtyLines := true;
    end;

    trigger OnPreReport()
    begin
        NumberOfCopies := 1;
        CompanyInformation.SetAutoCalcFields(Picture);
        CompanyInformation.Get();
    end;

    local procedure GetSalespersonName(SalespersonCode: Code[20]): Text[50]
    var
        Salesperson: Record "Salesperson/Purchaser";
    begin
        if not Salesperson.Get(SalespersonCode) then
            exit('');

        exit(Salesperson.Name);
    end;

    local procedure GetPaymentTermsDesc(PaymentTermsCode: Code[20]): Text[50]
    var
        PaymentTerms: Record "Payment Terms";
    begin
        if not PaymentTerms.Get(PaymentTermsCode) then
            exit('');

        exit(CopyStr(PaymentTerms.Description, 1, 50));
    end;

    local procedure GetHomePage(CustomerCode: Code[20]): Text[80]
    var
        Customer: Record Customer;
    begin
        if not Customer.Get(CustomerCode) then
            exit('');

        exit(Customer."Home Page");
    end;

    local procedure GetTotalItemAmountWODiscount(var SalesInvHeader: Record "Sales Invoice Header"): Decimal
    var
        SalInvLine: Record "Sales Invoice Line";
        TotalAmount: Decimal;
    begin
        SalInvLine.SetRange("Document No.", SalesInvHeader."No.");
        SalInvLine.SetRange(Type, SalInvLine.Type::Item);
        if SalInvLine.FindSet() then
            repeat
                TotalAmount += SalInvLine.Quantity * SalInvLine."Unit Price";
            until SalInvLine.Next() = 0;

        exit(TotalAmount);
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
        CompanyInformation: Record "Company Information";
        CustAddr: array[8] of Text[100];
        ShipToAddr: array[8] of Text[100];
        ShowShippingAddr: Boolean;
        TotalPieces: Decimal;
        TotalPrice: Decimal;
        NumberOfCopies: Integer;
        ItemGTIN: code[20];
        ShipmentMethodDesc: Text[100];
        ShippingAgentName: Text[50];
        GlobalShowZeroQtyLines: Boolean;
        TotalExtAmtOfTypeItem: Decimal;
        TotalDiscountPrc: Decimal;
        TotalDiscountAmount: Decimal;
        TotalLineDiscountAmount: Decimal;
        TotalFreight: Decimal;
        TotalMiscChargesDiscounts: Decimal;
        LineAmountWODisc: Decimal;
}
