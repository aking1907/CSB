report 51102 "CSB Posted Sal. Inv. Lines"
{
    ApplicationArea = All;
    Caption = 'CSB Posted Sal. Inv. Lines';
    UsageCategory = ReportsAndAnalysis;
    DefaultRenderingLayout = DefaultLayout;

    dataset
    {
        dataitem(Header; "Sales Invoice Header")
        {
            RequestFilterFields = "Posting Date", "Bill-to Customer No.";
            column(ShowDocumentLines; ShowDocumentLines) { }
            column(DocumentNo; "No.") { }
            column(CustomerNo; "Sell-to Customer No.") { }
            column(Name; "Bill-to Name") { }
            column(PostingDate; Format("Posting Date", 0, '<Month,2>/<Day,2>/<Year4>')) { }
            column(TotalCost; TotalCost) { DecimalPlaces = 2 : 2; }
            column(TotalAmount; "Amount Including VAT") { DecimalPlaces = 2 : 2; }
            column(GrossMargin; format(Round(GrossMargin, 0.01), 0, '<Sign><Integer><Decimals>')) { }
            column(Profit; format(Round(TotalProfit, 0.01), 0, '<Sign><Integer><Decimals>')) { }
            column(SalesTotal; SalesTotal) { DecimalPlaces = 2 : 2; }
            column(OtherCharges; OtherCharges) { DecimalPlaces = 2 : 2; }
            column(ReportTotalAmount; ReportTotalAmount) { DecimalPlaces = 2 : 2; }
            column(ReportTotalExtendedCost; ReportTotalExtendedCost) { DecimalPlaces = 2 : 2; }
            column(ReportTotalGrossMargin; ReportTotalGrossMargin) { DecimalPlaces = 2 : 2; }
            column(ReportTotalProfit; ReportTotalProfit) { DecimalPlaces = 2 : 2; }
            column(ReportTotalSales; ReportTotalSales) { DecimalPlaces = 2 : 2; }
            column(ReportTotalOtherCharges; ReportTotalOtherCharges) { DecimalPlaces = 2 : 2; }
            dataitem(Line; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = where(Quantity = filter('<>0'));
                DataItemLinkReference = Header;
                column(LineDocumentNo; "Document No.") { }
                column(LineItemNo; "No.") { }
                column(LineType; Type) { }
                column(LineQuantity; Quantity) { DecimalPlaces = 2 : 2; }
                column(LineAmount; Line."Amount Including VAT") { DecimalPlaces = 2 : 2; }
                column(LineCost; LineCost) { DecimalPlaces = 2 : 2; }
                column(LineMargin; Line."Line Amount" - LineCost) { DecimalPlaces = 2 : 2; }
                column(LineProfit; format(Round(LineProfit, 0.01), 0, '<Sign><Integer><Decimals>')) { }
                column(ShortcutDimension1Code; "Shortcut Dimension 1 Code") { }
                column(ShortcutDimension2Code; "Shortcut Dimension 2 Code") { }

                trigger OnAfterGetRecord()
                begin
                    LineCost := 0;
                    LineProfit := 0;

                    LineCost := CalcLineCostAmount(Line);

                    if Line."Line Amount" <> LineCost then
                        if Line."Line Amount" <> 0 then
                            LineProfit := (Line."Line Amount" - LineCost) / Line."Line Amount" * 100;
                end;
            }

            trigger OnAfterGetRecord()
            var
                SalInvLine: Record "Sales Invoice Line";
                SILLineCost: Decimal;
                TotalDiscounts: Decimal;
            begin
                TotalCost := 0;
                LineCost := 0;
                TotalProfit := 0;
                GrossMargin := 0;
                SalesTotal := 0;
                OtherCharges := 0;
                TotalDiscounts := 0;

                Header.CalcFields(Amount, "Amount Including VAT");

                ReportTotalAmount += Header."Amount Including VAT";

                SalInvLine.Reset();
                SalInvLine.SetRange("Document No.", Header."No.");
                SalInvLine.SetFilter(Quantity, '<>0');
                if SalInvLine.FindSet() then
                    repeat
                        SILLineCost := CalcLineCostAmount(SalInvLine);
                        TotalCost += SILLineCost;
                        TotalDiscounts += SalInvLine."Line Discount Amount";
                    until SalInvLine.Next() = 0;
                ReportTotalExtendedCost += TotalCost;

                SalInvLine.Reset();
                SalInvLine.SetRange("Document No.", Header."No.");
                SalInvLine.SetFilter(Quantity, '<>0');
                SalInvLine.SetRange(Type, SalInvLine.Type::Item);
                if SalInvLine.FindFirst() then begin
                    SalInvLine.CalcSums("Line Amount", "Line Discount Amount");
                    SalesTotal := SalInvLine."Line Amount";
                end;
                SalesTotal += TotalDiscounts;
                ReportTotalSales += SalesTotal;

                // SalInvLine.Reset();
                // SalInvLine.SetRange("Document No.", Header."No.");
                // SalInvLine.SetFilter(Quantity, '<>0');
                // SalInvLine.SetFilter(Type, '<>%1', SalInvLine.Type::Item);
                // if SalInvLine.FindFirst() then begin
                //     SalInvLine.CalcSums("Line Amount");
                //     OtherCharges := SalInvLine."Line Amount";
                // end;
                // OtherCharges += TotalDiscounts;
                OtherCharges := Header."Amount Including VAT" - SalesTotal;
                ReportTotalOtherCharges += OtherCharges;


                GrossMargin := SalesTotal - TotalCost;
                ReportTotalGrossMargin := ReportTotalSales - ReportTotalExtendedCost;

                if SalesTotal <> 0 then
                    TotalProfit := GrossMargin / SalesTotal * 100;

                ReportTotalProfit := 0;
                if ReportTotalSales <> 0 then
                    ReportTotalProfit := ReportTotalGrossMargin / ReportTotalSales * 100;
            end;

            trigger OnPreDataItem()
            begin
                case SortTypeOption of
                    SortTypeOption::"Customer No.":
                        Header.SetCurrentKey("Sell-to Customer No.");
                    SortTypeOption::"Class Code":
                        Header.SetCurrentKey("Shortcut Dimension 1 Code");
                end;


            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                    Caption = 'Params';
                    field(ShowDocumentLines; ShowDocumentLines)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies Show Document Lines on the report.';
                        Caption = 'Show Document Lines';
                    }
                    field(SortTypeOption; SortTypeOption)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the sort type on the report.';
                        Caption = 'Sort By';
                    }
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }

    rendering
    {
        layout(DefaultLayout)
        {
            Type = RDLC;
            LayoutFile = './src/Report/RDLC/Rep51102.CSBPostedSalInvLines.rdlc';
            Caption = 'Invoice Lines';
            Summary = 'CSB Posted Sal. Inv. Lines';
        }
    }

    local procedure CalcLineCostAmount(SalesInvLine: Record "Sales Invoice Line"): Decimal
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemCost: Decimal;
    begin
        SalesShipmentLine.SetCurrentKey("Order No.", "Order Line No.", "Posting Date");
        SalesShipmentLine.SetRange("Order No.", SalesInvLine."Order No.");
        SalesShipmentLine.SetRange("Order Line No.", SalesInvLine."Order Line No.");
        if SalesShipmentLine.FindSet() then
            repeat
                if SalesShipmentLine.Quantity <> 0 then begin
                    if ItemLedgerEntry.Get(SalesShipmentLine."Item Shpt. Entry No.") then begin
                        ItemLedgerEntry.CalcFields("Cost Amount (Actual)");
                        ItemCost := ItemLedgerEntry."Cost Amount (Actual)";
                    end;
                end;
            until SalesShipmentLine.Next() = 0;

        exit(Abs(ItemCost));
    end;

    var
        TotalCost: Decimal;
        GrossMargin: Decimal;
        TotalProfit: Decimal;
        LineCost: Decimal;
        LineProfit: Decimal;
        ShowDocumentLines: Boolean;
        ReportTotalAmount: Decimal;
        SortTypeOption: Option "Document No.","Class Code","Customer No.";
        SalesTotal: Decimal;
        OtherCharges: Decimal;
        ReportTotalExtendedCost: Decimal;
        ReportTotalGrossMargin: Decimal;
        ReportTotalProfit: Decimal;
        ReportTotalSales: Decimal;
        ReportTotalOtherCharges: Decimal;
}
