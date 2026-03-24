pageextension 51118 "CSB Posted Purchase Receipt" extends "Posted Purchase Receipt" //136
{
    layout
    {
        addafter("Vendor Shipment No.")
        {

            field("CSB Vendor Invoice No."; Rec."CSB Vendor Invoice No.")
            {
                ApplicationArea = All;
                Caption = 'CSB Vendor Invoice No.';
                ToolTip = 'CSB Vendor Invoice No.';
                Editable = false;
            }
        }
    }
    actions
    {
        addafter("&Navigate")
        {
            action(CSBUpdateDocument)
            {
                ApplicationArea = All;
                Caption = 'CSB Update Document';
                ToolTip = 'CSB Update Document';
                Image = Document;

                trigger OnAction()
                var
                    CSBPurchRcptHeaderModifyPage: Page "CSB Purch. Rcpt. Header Modify";
                begin
                    CSBPurchRcptHeaderModifyPage.SetSourceRecord(Rec);
                    CSBPurchRcptHeaderModifyPage.LookupMode(true);
                    if CSBPurchRcptHeaderModifyPage.RunModal() <> Action::LookupOK then
                        exit;

                    CSBPurchRcptHeaderModifyPage.UpdateValues();
                    CurrPage.Update(false);
                end;
            }
        }

        addafter("&Navigate_Promoted")
        {
            actionref(CSBUpdateDocument_Promoted; CSBUpdateDocument) { }
        }
    }
}
