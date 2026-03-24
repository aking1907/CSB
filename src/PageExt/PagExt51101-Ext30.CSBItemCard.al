pageextension 51101 "CSB Item Card" extends "Item Card" //30
{
    layout
    {
        addafter("Costing Method")
        {
            field("CSB List Price"; Rec."CSB Retail Price")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the CSB Retail Price of the Item.';
            }
            field("CSB Salon Price"; Rec."CSB Salon Price")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the CSB Salon Price of the Item.';
            }
        }
    }
}