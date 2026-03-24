page 51101 "CSB Paym. Jnl. VLE Appl."
{
    ApplicationArea = All;
    Caption = 'Paym. Jnl. VLE Appl.';
    PageType = List;
    SourceTable = "Vendor Ledger Entry";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(JnlDocumentType; GlobalGenJnlLine."Document Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Jnl. Document Type';
                    ToolTip = 'Specifies the Jnl. Document Type.';
                    DrillDown = false;
                    Lookup = false;
                }
                field(JnlDocumentNo; GlobalGenJnlLine."Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Jnl. Document No.';
                    ToolTip = 'Specifies the Jnl. Document No.';
                }
                field(JnlAmount; GlobalGenJnlLine.Amount)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Jnl. Amount';
                    ToolTip = 'Specifies the Jnl. Amount';
                }
                field("Apply-to Jnl. Line Amt."; Rec."Closed by Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Apply-to Jnl. Line Amt.';
                    ToolTip = 'Specifies the Jnl. Amount';
                }
                field(AppliesToID; Rec."Applies-to ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of entries that will be applied to when you choose the Apply Entries action.';
                    Editable = false;
                    Visible = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the vendor entry''s posting date.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the document type that the vendor entry belongs to.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the vendor entry''s document number.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the number of the vendor account that the entry is linked to.';
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the name of the vendor account that the entry is linked to.';
                    Visible = False;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies a description of the vendor entry.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the currency code for the amount on the line.';
                    Editable = false;
                    Visible = false;
                }
                field("Original Amount"; Rec."Original Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the amount of the original entry.';
                    Visible = false;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the amount of the entry.';
                    Visible = false;
                }
                field("Debit Amount"; Rec."Debit Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total of the ledger entries that represent debits.';
                    Editable = false;
                    Visible = false;
                }
                field("Credit Amount"; Rec."Credit Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total of the ledger entries that represent credits.';
                    Editable = false;
                    Visible = false;
                }
                field("Remaining Amount"; Rec."Remaining Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the amount that remains to be applied to before the entry is totally applied to.';
                }
                field("Amount to Apply"; Rec."Amount to Apply")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount to apply.';
                }

                field("Due Date"; Rec."Due Date")
                {
                    Editable = false;
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    ToolTip = 'Specifies the due date on the entry.';
                }
                field("Pmt. Discount Date"; Rec."Pmt. Discount Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date on which the amount in the entry must be paid for a payment discount to be granted.';
                    StyleExpr = DiscountStyle;

                    trigger OnValidate()
                    begin
                        SetDiscountStyle();
                    end;
                }
                field("Pmt. Disc. Tolerance Date"; Rec."Pmt. Disc. Tolerance Date")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the latest date the amount in the entry must be paid in order for payment discount tolerance to be granted.';
                }
                field("Payment Reference"; Rec."Payment Reference")
                {
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the payment of the purchase invoice.';
                }
                field("Original Pmt. Disc. Possible"; Rec."Original Pmt. Disc. Possible")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the discount that you can obtain if the entry is applied to before the payment discount date.';
                    Editable = false;
                }
                field("Remaining Pmt. Disc. Possible"; Rec."Remaining Pmt. Disc. Possible")
                {
                    StyleExpr = DiscountStyle;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the remaining payment discount which can be received if the payment is made before the payment discount date.';
                }

                field("Max. Payment Tolerance"; Rec."Max. Payment Tolerance")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the maximum tolerated amount the entry can differ from the amount on the invoice or credit memo.';
                }
                field(Open; Rec.Open)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies whether the amount on the entry has been fully paid or there is still a remaining amount that must be applied to.';
                }
                field(Positive; Rec.Positive)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies if the entry to be applied is positive.';
                }
                field("Remit-to Code"; Rec."Remit-to Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the address for the remit-to code.';
                    Visible = false;
                    TableRelation = "Remit Address".Code where("Vendor No." = field("Vendor No."));
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the global dimension that is linked to the record or entry for analysis purposes. Two global dimensions, typically for the company''s most important activities, are available on all cards, documents, reports, and lists.';
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    Editable = false;
                    Visible = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the global dimension that is linked to the record or entry for analysis purposes. Two global dimensions, typically for the company''s most important activities, are available on all cards, documents, reports, and lists.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RefreshValues)
            {
                Image = Refresh;
                ApplicationArea = All;
                Caption = 'Refresh Values';
                ToolTip = 'Refresh Values';

                trigger OnAction()
                begin
                    CalcApplyToJnlLineAmt();
                end;
            }

            action(ExportToExcel)
            {
                Image = ExportToExcel;
                ApplicationArea = All;
                Caption = 'Export to Excel';
                ToolTip = 'Export to Excel';

                trigger OnAction()
                var
                    ReportExportPaymJnlVLEAppl: Report "CSB Export Paym. Jnl. VLE Appl";
                begin
                    CalcApplyToJnlLineAmt();
                    ReportExportPaymJnlVLEAppl.SetSourceRecord(Rec, GlobalGenJnlLine, JnlTemplName, JnlBatchName);
                    ReportExportPaymJnlVLEAppl.Run();
                end;
            }
        }
        area(Promoted)
        {
            actionref(RefreshValues_Promoted; RefreshValues) { }
            actionref(ExportToExcel_Promoted; ExportToExcel) { }
        }
    }
    trigger OnOpenPage()
    begin
        SetSourceRecord();
        CalcApplyToJnlLineAmt();
    end;

    trigger OnAfterGetRecord()
    begin
        StyleTxt := Rec.SetStyle();
        GlobalGenJnlLine.Get(JnlTemplName, JnlBatchName, Rec."Transaction No.");
        SetDiscountStyle();
    end;

    trigger OnClosePage()
    begin
        CalcApplyToJnlLineAmt();
    end;

    procedure SetParams(var GenJnlLine: Record "Gen. Journal Line")
    begin
        GlobalGenJnlLine.Copy(GenJnlLine);
        JnlTemplName := GenJnlLine."Journal Template Name";
        JnlBatchName := GenJnlLine."Journal Batch Name";
    end;

    procedure SetSourceRecord()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        Skip: Boolean;
    begin
        if GlobalGenJnlLine.FindSet() then
            repeat
                VendorLedgerEntry.Reset();
                VendorLedgerEntry.SetCurrentKey("Vendor No.", "Applies-to ID", Open, Positive, "Due Date");
                VendorLedgerEntry.SetRange("Vendor No.", GlobalGenJnlLine."Account No.");
                VendorLedgerEntry.SetRange("Applies-to ID", GlobalGenJnlLine."Applies-to ID");
                VendorLedgerEntry.SetRange(Open, true);
                if VendorLedgerEntry.FindSet() then
                    repeat
                        Skip := false;
                        if GlobalGenJnlLine."Applies-to Doc. Type" <> GlobalGenJnlLine."Applies-to Doc. Type"::" " then
                            if GlobalGenJnlLine."Applies-to Doc. Type" <> VendorLedgerEntry."Applies-to Doc. Type" then
                                Skip := true;

                        if not Skip then begin
                            Rec := VendorLedgerEntry;
                            Rec."Transaction No." := GlobalGenJnlLine."Line No.";
                            Rec."Closed at Date" := GlobalGenJnlLine."Posting Date";
                            Rec.Insert();
                        end;
                    until VendorLedgerEntry.Next() = 0;
            until GlobalGenJnlLine.Next() = 0;

        Rec.SetCurrentKey("Transaction No.");
        if Rec.FindFirst() then;
    end;

    procedure GetSourceRecord(var TempVendLedgerEntry: Record "Vendor Ledger Entry" temporary)
    begin
        if not TempVendLedgerEntry.IsTemporary then Error('');
        TempVendLedgerEntry.Reset();
        if not TempVendLedgerEntry.IsEmpty then
            TempVendLedgerEntry.DeleteAll();

        Rec.Reset();
        if Rec.FindSet() then
            repeat
                TempVendLedgerEntry := Rec;
                TempVendLedgerEntry.Insert();
            until Rec.Next() = 0;
    end;

    procedure CalcApplyToJnlLineAmt()
    var
        TempVendLedgerEntry: Record "Vendor Ledger Entry" temporary;
        VendLedgerEntryForSearch: Record "Vendor Ledger Entry";
        TempDocumentList: Record "Item" temporary;
        CurrEntryNo: Integer;
        DiscountAmount: Decimal;
        AmtToApply: Decimal;
    begin
        CurrEntryNo := Rec."Entry No.";
        if Rec.FindSet() then
            repeat
                TempVendLedgerEntry := Rec;
                TempVendLedgerEntry.Insert();

                TempDocumentList."No." := Rec."Applies-to ID";
                if TempDocumentList.Insert() then;
            until Rec.Next() = 0;

        if Rec.Get(CurrEntryNo) then;
        VendLedgerEntryForSearch.Copy(Rec);

        if TempDocumentList.FindSet() then
            repeat
                AmtToApply := 0;
                DiscountAmount := 0;

                GlobalGenJnlLine.Get(JnlTemplName, JnlBatchName, Rec."Transaction No.");

                TempVendLedgerEntry.Reset();
                TempVendLedgerEntry.SetRange("Applies-to ID", TempDocumentList."No.");
                TempVendLedgerEntry.FindFirst();
                TempVendLedgerEntry.CalcSums("Amount to Apply");
                AmtToApply := TempVendLedgerEntry."Amount to Apply";

                TempVendLedgerEntry.SetFilter("Pmt. Discount Date", '>=%1', TempVendLedgerEntry."Closed at Date");
                if TempVendLedgerEntry.FindFirst() then begin
                    TempVendLedgerEntry.CalcSums("Remaining Pmt. Disc. Possible");
                    DiscountAmount := TempVendLedgerEntry."Remaining Pmt. Disc. Possible";
                end;

                Rec.Reset();
                Rec.SetRange("Applies-to ID", TempDocumentList."No.");
                if Rec.FindSet() then
                    Rec.ModifyAll("Closed by Amount", DiscountAmount - AmtToApply);

            until TempDocumentList.Next() = 0;

        Rec.Reset();
        Rec.CopyFilters(VendLedgerEntryForSearch);
        Rec.SetCurrentKey("Transaction No.");
        if Rec.FindFirst() then;
        if Rec.Get(CurrEntryNo) then;
    end;

    local procedure SetDiscountStyle()
    begin
        DiscountStyle := 'None';
        if Rec."Remaining Pmt. Disc. Possible" <> 0 then
            if WorkDate() > Rec."Pmt. Discount Date" then
                DiscountStyle := 'StrongAccent';
    end;

    var
        VendLedgEntry: Record "Vendor Ledger Entry";
        CurrExchRate: Record "Currency Exchange Rate";
        CalcType: Enum "Vendor Apply Calculation Type";
        ApplnType: Enum "Vendor Apply-to Type";
        GlobalGenJnlLine: Record "Gen. Journal Line";
        JnlTemplName: Code[20];
        JnlBatchName: Code[20];
        ApplnDate: Date;
        ApplnCurrencyCode: Code[10];
        StyleTxt: Text;
        DiscountStyle: Text;
        ValidExchRate: Boolean;
}
