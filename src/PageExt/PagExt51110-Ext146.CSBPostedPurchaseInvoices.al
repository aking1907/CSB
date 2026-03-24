pageextension 51110 "CSB Posted Purchase Invoices" extends "Posted Purchase Invoices" //146
{
    layout
    {
        addlast(Control1)
        {
            field("CSB Shipping Agent Code"; Rec."CSB Shipping Agent Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies CSB Shipping Agent Code of the product.';
            }
            field("CSB Package Tracking No."; Rec."CSB Package Tracking No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies CSB Package Tracking No. of the product.';
            }
            field("CSB Created By"; Rec."CSB Created By")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies Created By of the product.';
            }
        }
    }
}
