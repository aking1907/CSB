pageextension 51115 "CSB Payment Journal" extends "Payment Journal" //256
{
    layout
    {
        addlast(Control1)
        {
            field("CSB Payment Discount %"; Rec."Payment Discount %") { ApplicationArea = All; }
            field("CSB Pmt. Discount Date"; Rec."Pmt. Discount Date") { ApplicationArea = All; }
            field("CSB Orig. Pmt. Disc. Possible"; Rec."Orig. Pmt. Disc. Possible") { ApplicationArea = All; }
        }
    }
    actions
    {
        addafter(ApplyEntries)
        {
            action(CSBDiscountMgt)
            {
                Caption = 'CSB Discount Mgt.';
                Image = Apply;
                ApplicationArea = All;

                trigger OnAction()
                var
                    VendLedgerEntry: Record "Vendor Ledger Entry";
                    TempVendLedgerEntry: Record "Vendor Ledger Entry" temporary;
                    GenJnlLine: Record "Gen. Journal Line";
                    CSBPaymJnlVLEAppl: Page "CSB Paym. Jnl. VLE Appl.";
                    CUVendEntryEdit: Codeunit "Vend. Entry-Edit";
                begin
                    if Rec.IsEmpty then exit;
                    CSBPaymJnlVLEAppl.SetParams(Rec);
                    CSBPaymJnlVLEAppl.LookupMode(true);
                    if CSBPaymJnlVLEAppl.RunModal() <> Action::LookupOK then
                        exit;

                    //Unapply entries
                    GenJnlLine.Copy(Rec);
                    GenJnlLine.SetRange("Account Type", GenJnlLine."Account Type"::Vendor);
                    GenJnlLine.SetFilter("Applies-to ID", '<>%1', '');
                    if GenJnlLine.FindSet() then
                        repeat
                            VendLedgerEntry.Reset();
                            VendLedgerEntry.SetCurrentKey("Vendor No.", "Applies-to ID", Open, Positive, "Due Date");
                            VendLedgerEntry.SetRange("Vendor No.", GenJnlLine."Account No.");
                            VendLedgerEntry.SetRange("Applies-to Doc. Type", GenJnlLine."Applies-to Doc. Type");
                            VendLedgerEntry.SetRange("Applies-to ID", GenJnlLine."Applies-to ID");
                            if VendLedgerEntry.FindSet() then
                                repeat
                                    VendLedgerEntry."Applies-to Doc. Type" := VendLedgerEntry."Applies-to Doc. Type"::" ";
                                    VendLedgerEntry."Applies-to ID" := '';
                                    Codeunit.Run(Codeunit::"Vend. Entry-Edit", VendLedgerEntry);
                                until VendLedgerEntry.Next() = 0;
                        until GenJnlLine.Next() = 0;

                    //Set page source record
                    CSBPaymJnlVLEAppl.GetSourceRecord(TempVendLedgerEntry);

                    //Modify Amount
                    TempVendLedgerEntry.Reset();
                    if GenJnlLine.FindSet() then
                        repeat
                            TempVendLedgerEntry.SetRange("Transaction No.", GenJnlLine."Line No.");

                            GenJnlLine.Validate(Amount, 0);
                            if TempVendLedgerEntry.FindFirst() then
                                GenJnlLine.Validate(Amount, TempVendLedgerEntry."Closed by Amount");

                            GenJnlLine.Modify();
                        until GenJnlLine.Next() = 0;

                    //Apply Entreis
                    VendLedgerEntry.Reset();
                    TempVendLedgerEntry.Reset();
                    if TempVendLedgerEntry.FindSet() then
                        repeat
                            VendLedgerEntry.Get(TempVendLedgerEntry."Entry No.");
                            VendLedgerEntry."Amount to Apply" := TempVendLedgerEntry."Amount to Apply";
                            VendLedgerEntry."Pmt. Discount Date" := TempVendLedgerEntry."Pmt. Discount Date";
                            VendLedgerEntry."Pmt. Disc. Tolerance Date" := TempVendLedgerEntry."Pmt. Disc. Tolerance Date";
                            VendLedgerEntry."Payment Reference" := TempVendLedgerEntry."Payment Reference";
                            VendLedgerEntry."Remaining Pmt. Disc. Possible" := TempVendLedgerEntry."Remaining Pmt. Disc. Possible";
                            VendLedgerEntry."Max. Payment Tolerance" := TempVendLedgerEntry."Max. Payment Tolerance";
                            VendLedgerEntry."Remit-to Code" := TempVendLedgerEntry."Remit-to Code";
                            VendLedgerEntry."Applies-to ID" := TempVendLedgerEntry."Applies-to ID";
                            VendLedgerEntry."Applies-to Doc. Type" := TempVendLedgerEntry."Applies-to Doc. Type";
                            Codeunit.Run(Codeunit::"Vend. Entry-Edit", VendLedgerEntry);
                        until TempVendLedgerEntry.Next() = 0;

                    CurrPage.Update(false);
                end;
            }


        }
        addafter(ApplyEntries_Promoted)
        {
            actionref(CSBDiscountMgt_Promoted; CSBDiscountMgt) { }
        }
    }
}
