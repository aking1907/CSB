pageextension 51117 "CSB Posted Purchase Receipts" extends "Posted Purchase Receipts" //145
{
    layout
    {
        addlast(Control1)
        {
            field("CSB Cost Amount (Expected)"; Rec."CSB Cost Amount (Expected)")
            {
                ApplicationArea = All;
                Caption = 'CSB Cost Amount (Expected)';
                Editable = false;
            }
            field("CSB Vendor Invoice No."; Rec."CSB Vendor Invoice No.")
            {
                ApplicationArea = All;
                Caption = 'CSB Vendor Invoice No.';
                ToolTip = 'CSB Vendor Invoice No.';
                Editable = false;
            }
        }
    }
}
