pageextension 51111 "CSB Posted Purchase Invoice" extends "Posted Purchase Invoice" //138
{
    layout
    {
        addbefore("Ship-to")
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
        }
    }
}
