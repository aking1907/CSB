tableextension 51108 "CSB Sales Invoice Line" extends "Sales Invoice Line" //113
{
    fields
    {
        field(50100; "CSB Retail Price"; Decimal)
        {
            Caption = 'CSB Retail Price';
            DecimalPlaces = 2 : 5;
            FieldClass = FlowField;
            CalcFormula = lookup(Item."CSB Retail Price" where("No." = field("No.")));
        }
        field(50101; "CSB Salon Price"; Decimal)
        {
            Caption = 'CSB Salon Price';
            DecimalPlaces = 2 : 5;
            FieldClass = FlowField;
            CalcFormula = lookup(Item."CSB Salon Price" where("No." = field("No.")));
        }
        field(50102; "CSB Shelf No."; Code[10])
        {
            Caption = 'CSB Shelf No.';
            FieldClass = FlowField;
            CalcFormula = lookup(Item."Shelf No." where("No." = field("No.")));
        }
        field(50104; "CSB Original Quantity"; Decimal)
        {
            Caption = 'CSB Original Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(50113; "CSB Retail Unit Cost"; Decimal)
        {
            Caption = 'CSB Retail Unit Cost';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
        }
    }
}
