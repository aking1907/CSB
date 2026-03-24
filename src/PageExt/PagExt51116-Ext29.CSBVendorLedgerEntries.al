pageextension 51116 "CSB Vendor Ledger Entries" extends "Vendor Ledger Entries" //29
{
    actions
    {
        addafter("Create Payment")
        {
            action(CSBCreatePayment)
            {
                Image = SetupPayment;
                ApplicationArea = All;
                Caption = 'CSB Create Payment';
                ToolTip = 'CSB Create Payment.';

                trigger OnAction()
                var
                    VendLedgerEntry: Record "Vendor Ledger Entry";
                    CSBCreatePaymentsReport: Report "CSB Create Payments";
                begin
                    CurrPage.SetSelectionFilter(VendLedgerEntry);
                    CSBCreatePaymentsReport.SetSourceRecord(VendLedgerEntry);
                    CSBCreatePaymentsReport.RunModal();
                end;
            }
        }
        addafter("Create Payment_Promoted")
        {
            actionref(CSBCreatePayment_Promoted; CSBCreatePayment) { }
        }
    }
}
