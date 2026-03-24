pageextension 51100 "CSB Item List" extends "Item List" //31
{
    layout
    {
        addafter(Blocked)
        {
            field("CSB Purchasing Blocked"; Rec."Purchasing Blocked")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies the value of the Purchasing Blocked field.';
            }
            field("CSB Sales Blocked"; Rec."Sales Blocked")
            {
                ApplicationArea = all;
                ToolTip = 'Specifies the value of the Sales Blocked field.';
            }
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
        modify(GTIN)
        {
            Visible = true;
        }
        modify(Blocked)
        {
            Visible = true;
        }
    }
}