reportextension 51101 "CSB Customer Register" extends "Customer Register" //10046
{
    dataset
    {
        add("Cust. Ledger Entry")
        {
            column(CSBListOfAppliedDocNo; ListOfAppliedDocNo) { }
            column(CSBFCAmountLCY; FCAmountLCY) { }
            column(CSBTotalAmount; TotalAmount) { }
            column(CSBTotalFCAmount; TotalFCAmount) { }
            column(CSBTotalStatementAmount; TotalStatementAmount) { }
            column(CSBExternalDocumentNo; "External Document No.") { }
        }

        modify("Cust. Ledger Entry")
        {
            trigger OnAfterAfterGetRecord()
            begin
                CSBGetListOfAppliedDocNo();
            end;
        }

    }
    rendering
    {
        layout(CSBDefaultRDLCLayout)
        {
            Type = RDLC;
            Caption = 'CSB Customer Register';
            Summary = 'CSB Customer Register';
            LayoutFile = './src/ReportExt/RDLC/RepExt51101-Ext10046.CSBCustomerRegister.rdlc';
        }

        layout(CSBPaymentsRDLCLayout)
        {
            Type = RDLC;
            Caption = 'CSB Customer Register - Payments';
            Summary = 'CSB Customer Register - Payments';
            LayoutFile = './src/ReportExt/RDLC/RepExt51101-Ext10046.CSBCustomerRegisterPayments.rdlc';
        }
    }

    var
        ListOfAppliedDocNo: Text[250];
        FCAmountLCY: Decimal;
        RegisterNo: Integer;
        TotalAmount: Decimal;
        TotalAmountFirstTransaction: Decimal;
        TotalFCAmount: Decimal;
        TotalStatementAmount: Decimal;
        TotalRegisterAmount: Decimal;
        FixTotalAmount: Boolean;

    local procedure CSBGetListOfAppliedDocNo()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        DetailedCustLedgEntry2: Record "Detailed Cust. Ledg. Entry";
        TempSalesInvoiceHeader: Record "Sales Invoice Header" temporary;
        CustLedgerEntryNo: Integer;
    begin
        ListOfAppliedDocNo := '';
        FCAmountLCY := 0;

        if RegisterNo = 0 then
            RegisterNo := "G/L Register"."No."
        else
            if RegisterNo <> "G/L Register"."No." then begin
                RegisterNo := "G/L Register"."No.";
                if not FixTotalAmount then begin
                    FixTotalAmount := true;
                    TotalAmountFirstTransaction := TotalAmount;
                end;
                TotalRegisterAmount += TotalAmount - TotalFCAmount;
                TotalAmount := 0;
                TotalFCAmount := 0;
            end;

        CustLedgerEntryNo := "Cust. Ledger Entry"."Entry No.";

        DetailedCustLedgEntry.SetRange("Cust. Ledger Entry No.", CustLedgerEntryNo);
        DetailedCustLedgEntry.SetRange("Entry Type", DetailedCustLedgEntry."Entry Type"::Application);
        DetailedCustLedgEntry.SetRange(Unapplied, false);
        if DetailedCustLedgEntry.FindSet() then
            repeat
                if (DetailedCustLedgEntry."Applied Cust. Ledger Entry No." = CustLedgerEntryNo) then begin
                    DetailedCustLedgEntry2.SetRange("Applied Cust. Ledger Entry No.", CustLedgerEntryNo);
                    DetailedCustLedgEntry2.SetFilter("Cust. Ledger Entry No.", '<>%1', CustLedgerEntryNo);
                    if DetailedCustLedgEntry2.FindSet() then
                        repeat
                            if CustLedgerEntry.Get(DetailedCustLedgEntry2."Cust. Ledger Entry No.") then begin
                                TempSalesInvoiceHeader."No." := CustLedgerEntry."Document No.";
                                if TempSalesInvoiceHeader.Insert() then;
                            end;
                        until DetailedCustLedgEntry2.Next() = 0;
                end else begin
                    TempSalesInvoiceHeader."No." := DetailedCustLedgEntry."Document No.";
                    if TempSalesInvoiceHeader.Insert() then;
                end;
            until DetailedCustLedgEntry.Next() = 0;

        CustLedgerEntry.SetCurrentKey("Closed by Entry No.");
        CustLedgerEntry.SetRange("Closed by Entry No.", CustLedgerEntryNo);
        if CustLedgerEntry.FindSet() then
            repeat
                TempSalesInvoiceHeader."No." := CustLedgerEntry."Document No.";
                if TempSalesInvoiceHeader.Insert() then;
            until CustLedgerEntry.Next() = 0;

        if TempSalesInvoiceHeader.FindSet() then
            repeat
                ListOfAppliedDocNo += ',' + TempSalesInvoiceHeader."No.";
            until TempSalesInvoiceHeader.Next() = 0;

        if StrPos(TempSalesInvoiceHeader."No.", 'FC') = 1 then begin
            FCAmountLCY := "Cust. Ledger Entry"."Amount (LCY)";
            "Cust. Ledger Entry"."Amount (LCY)" := 0;
        end;

        TotalAmount += "Cust. Ledger Entry"."Amount (LCY)";
        TotalFCAmount += FCAmountLCY;

        if not FixTotalAmount then
            TotalStatementAmount := TotalAmount - TotalFCAmount
        else
            TotalStatementAmount := TotalAmountFirstTransaction - TotalFCAmount;

        ListOfAppliedDocNo := DelChr(ListOfAppliedDocNo, '<>', ',');
    end;

}
