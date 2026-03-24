reportextension 51104 "CSB Check (Stub/Check/Stub)" extends "Check (Stub/Check/Stub)" //10411
{
    dataset
    {
        add(GenJnlLine)
        {
            column(CSB_GJL_AccountNo; "Account No.") { }
        }
        add(PrintSettledLoop)
        {
            column(CSB_GJL_DocumentNo; CSBStubDocumentNo[PrintSettledLoop.Number + 1000000001]) { }

        }
        modify(PrintSettledLoop)
        {
            trigger OnAfterAfterGetRecord()
            var
                CSBGenJnlLine: Record "Gen. Journal Line";
                VendLedgEntry: Record "Vendor Ledger Entry";
                TempVendLedgEntry: Record "Vendor Ledger Entry" temporary;
            begin
                CSBStubLineNo := 0;
                clear(CSBStubDocumentNo);
                if (GenJnlLine."Account Type" = GenJnlLine."Account Type"::Vendor) and (GenJnlLine."Account No." <> '') and (GenJnlLine."Bal. Account No." <> '') then begin

                    if GenJnlLine."Applies-to ID" = '' then begin
                        CSBStubLineNo += 1;
                        CSBStubDocumentNo[CSBStubLineNo] := GenJnlLine."Applies-to Doc. No.";
                    end else begin
                        VendLedgEntry.Reset();
                        VendLedgEntry.SetCurrentKey("Vendor No.", Open, Positive);
                        VendLedgEntry.SetRange("Vendor No.", GenJnlLine."Account No.");
                        VendLedgEntry.SetRange(Open, true);
                        VendLedgEntry.SetRange("Applies-to ID", GenJnlLine."Applies-to ID");
                        if VendLedgEntry.FindSet() then
                            repeat
                                TempVendLedgEntry := VendLedgEntry;
                                TempVendLedgEntry.Insert();
                            until VendLedgEntry.Next() = 0;

                        if TempVendLedgEntry.FindSet() then
                            repeat
                                CSBStubLineNo += 1;
                                CSBStubDocumentNo[CSBStubLineNo] := TempVendLedgEntry."Document No.";
                                CSBStubExtDocumentNo[CSBStubLineNo] := TempVendLedgEntry."External Document No.";
                            until TempVendLedgEntry.Next() = 0;
                    end;
                end;
            end;
        }
        add(PrintCheck)
        {
            column(CSBStubDocumentNo_1; CSBStubDocumentNo[1]) { }
            column(CSBStubDocumentNo_2; CSBStubDocumentNo[2]) { }
            column(CSBStubDocumentNo_3; CSBStubDocumentNo[3]) { }
            column(CSBStubDocumentNo_4; CSBStubDocumentNo[4]) { }
            column(CSBStubDocumentNo_5; CSBStubDocumentNo[5]) { }
            column(CSBStubDocumentNo_6; CSBStubDocumentNo[6]) { }
            column(CSBStubDocumentNo_7; CSBStubDocumentNo[7]) { }
            column(CSBStubDocumentNo_8; CSBStubDocumentNo[8]) { }
            column(CSBStubDocumentNo_9; CSBStubDocumentNo[9]) { }
            column(CSBStubDocumentNo_10; CSBStubDocumentNo[10]) { }
            column(CSBStubExtDocumentNo_1; CSBStubExtDocumentNo[1]) { }
            column(CSBStubExtDocumentNo_2; CSBStubExtDocumentNo[2]) { }
            column(CSBStubExtDocumentNo_3; CSBStubExtDocumentNo[3]) { }
            column(CSBStubExtDocumentNo_4; CSBStubExtDocumentNo[4]) { }
            column(CSBStubExtDocumentNo_5; CSBStubExtDocumentNo[5]) { }
            column(CSBStubExtDocumentNo_6; CSBStubExtDocumentNo[6]) { }
            column(CSBStubExtDocumentNo_7; CSBStubExtDocumentNo[7]) { }
            column(CSBStubExtDocumentNo_8; CSBStubExtDocumentNo[8]) { }
            column(CSBStubExtDocumentNo_9; CSBStubExtDocumentNo[9]) { }
            column(CSBStubExtDocumentNo_10; CSBStubExtDocumentNo[10]) { }
        }
        modify(GenJnlLine)
        {
            trigger OnAfterAfterGetRecord()
            begin
                Clear(CSBStubDocumentNo);
                Clear(CSBStubExtDocumentNo);
            end;
        }

    }
    rendering
    {
        layout(CSBDefaultRDLCLayout)
        {
            Type = RDLC;
            Caption = 'CSB Check (Stub/Check/Stub)';
            Summary = 'CSB Check (Stub/Check/Stub)';
            LayoutFile = './src/ReportExt/RDLC/RepExt51104-Ext10411.CSBCheckStubCheckStub.rdlc';
        }
    }



    var
        CSBStubDocumentNo: array[50] of Text[35];
        CSBStubExtDocumentNo: array[50] of Text[35];
        CSBStubLineNo: Integer;

}
