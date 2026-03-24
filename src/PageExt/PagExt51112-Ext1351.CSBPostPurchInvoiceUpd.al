pageextension 51112 "CSB Post. Purch. Invoice - Upd" extends "Posted Purch. Invoice - Update" //1351
{
    layout
    {
        addbefore("Ship-to Code")
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
