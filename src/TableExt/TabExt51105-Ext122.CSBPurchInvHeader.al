tableextension 51105 "CSB Purch. Inv. Header" extends "Purch. Inv. Header" //122
{
    fields
    {
        field(50100; "CSB Shipping Agent Code"; Code[10])
        {
            AccessByPermission = TableData "Shipping Agent Services" = R;
            Caption = 'CSB Shipping Agent Code';
            TableRelation = "Shipping Agent";
        }
        field(50101; "CSB Package Tracking No."; Text[30])
        {
            Caption = 'CSB Package Tracking No.';
        }
        field(50102; "CSB Created By"; Code[50])
        {
            Caption = 'CSB Created By';
            FieldClass = FlowField;
            CalcFormula = lookup(User."User Name" where("User Security ID" = field(SystemCreatedBy)));
        }
    }
}
