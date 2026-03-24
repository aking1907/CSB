pageextension 51113 "CSB Posted Sales Invoice" extends "Posted Sales Invoice" //132
{
    layout
    {
        addafter("Dispute Status")
        {
            field("CSB Pallets"; Rec."CSB Pallets")
            {
                ApplicationArea = All;
            }
            field("CSB Cartons"; Rec."CSB Cartons")
            {
                ApplicationArea = All;
            }
            field("CSB Scaled Weight"; Rec."CSB Scaled Weight")
            {
                ApplicationArea = All;
            }
            field("CSB Total Gross Weight"; Rec."CSB Total Gross Weight")
            {
                ApplicationArea = All;
            }
        }
    }
}
