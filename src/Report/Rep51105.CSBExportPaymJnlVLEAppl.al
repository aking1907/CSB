report 51105 "CSB Export Paym. Jnl. VLE Appl"
{
    ApplicationArea = All;
    Caption = 'Export Paym. Jnl. VLE Appl';
    DefaultLayout = Excel;
    ExcelLayout = './src/Report/Excel/Rep51105.CSBExportPaymJnlVLEAppl.xlsx';

    dataset
    {
        dataitem(VLE; "Vendor Ledger Entry")
        {
            UseTemporary = true;
            DataItemTableView = sorting("Transaction No.") order(ascending);
            column(JnlDocumentType; "Message to Recipient") { }
            column(JnlDocumentNo; "Payment Reference") { }
            column(JnlAmount; "Max. Payment Tolerance") { }
            column(ApplyToJnlLineAmt; "Closed by Amount") { }
            column(DocumentType; "Document Type") { }
            column(DocumentNo; "Document No.") { }
            column(ExternalDocumentNo; "External Document No.") { }
            column(VendorNo; "Vendor No.") { }
            column(Description; Description) { }
            column(RemainingAmount; "Remaining Amount") { }
            column(AmountToApply; "Amount to Apply") { }
            column(DueDate; "Due Date") { }
            column(PmtDiscountDate; "Pmt. Discount Date") { }
            column(OriginalPmtDiscPossible; "Original Pmt. Disc. Possible") { }
            column(RemainingPmtDiscPossible; "Remaining Pmt. Disc. Possible") { }
            column(MaxPaymentTolerance; "Max. Payment Tolerance") { }


        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(Processing)
            {
            }
        }
    }

    procedure SetSourceRecord(var TempVendorLedgerEntry: Record "Vendor Ledger Entry" temporary;
                              var GenJnlLine: Record "Gen. Journal Line";
                                  JnlTemplName: Code[20]; JnlBatchName: Code[20])
    begin
        if not TempVendorLedgerEntry.IsTemporary then Error('');

        if TempVendorLedgerEntry.FindSet() then
            repeat
                VLE := TempVendorLedgerEntry;

                VLE."Message to Recipient" := '';
                VLE."Payment Reference" := '';
                VLE."Max. Payment Tolerance" := 0;

                if GenJnlLine.Get(JnlTemplName, JnlBatchName, VLE."Transaction No.") then begin
                    VLE."Message to Recipient" := Format(GenJnlLine."Document Type");
                    VLE."Payment Reference" := GenJnlLine."Document No.";
                    VLE."Max. Payment Tolerance" := GenJnlLine.Amount;
                end;

                VLE.Insert();
            until TempVendorLedgerEntry.Next = 0;
    end;

    var
        GlobalGenJnlLine: Record "Gen. Journal Line";
}
