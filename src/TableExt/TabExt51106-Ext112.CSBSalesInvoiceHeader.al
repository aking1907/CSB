tableextension 51106 "CSB Sales Invoice Header" extends "Sales Invoice Header" //112
{
    fields
    {
        field(50100; "CSB Delete After Posting"; Boolean)
        {
            Caption = 'CSB Delete After Posting';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(50102; "CSB Created By"; Code[50])
        {
            Caption = 'CSB Created By';
            FieldClass = FlowField;
            CalcFormula = lookup(User."User Name" where("User Security ID" = field(SystemCreatedBy)));
        }
        field(50103; "CSB Pallets"; Integer)
        {
            Caption = 'CSB Pallets';
            DataClassification = CustomerContent;
        }
        field(50104; "CSB Cartons"; Integer)
        {
            Caption = 'CSB Cartons';
            DataClassification = CustomerContent;
        }
        field(50105; "CSB Scaled Weight"; Integer)
        {
            Caption = 'CSB Scaled Weight';
            DataClassification = CustomerContent;
        }
        field(50106; "CSB Total Gross Weight"; Decimal)
        {
            Caption = 'CSB Total Gross Weight';
            DecimalPlaces = 0 : 2;
            FieldClass = FlowField;
            CalcFormula = sum("Sales Line"."Gross Weight" where("Document No." = field("No.")));
        }
        field(50116; "CSB Retail"; Boolean)
        {
            Caption = 'CSB Retail';
            DataClassification = CustomerContent;
        }
    }
}
