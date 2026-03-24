pageextension 51109 "CSB Posted Sales Invoices" extends "Posted Sales Invoices" //143
{
    layout
    {
        addafter("Location Code")
        {
            field("CSB Package Tracking No."; Rec."Package Tracking No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Package Tracking No.';
            }
        }
        addlast(Control1)
        {
            field("CSB Created By"; Rec."CSB Created By")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies Created By of the product.';
            }
        }
    }
}