pageextension 51107 "CSB Posted Sales Inv. - Update" extends "Posted Sales Inv. - Update" //1355
{
    layout
    {
        addafter("Electronic Document")
        {
            group(CSBShippingBilling)
            {
                Caption = 'Shipping and Billing';
                field("CSB Shipping Agent"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    Caption = 'Agent';
                    ToolTip = 'Specifies the the Shipping Agent Code field value.';
                }
                field("CSB Package Tracking No."; Rec."Package Tracking No.")
                {
                    ApplicationArea = All;
                    Caption = 'Package Tracking No.';
                    ToolTip = 'Specifies the the Package Tracking No. field value.';
                }
            }
        }
    }
}
