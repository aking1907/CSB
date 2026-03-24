tableextension 51104 "CSB Purchase Header" extends "Purchase Header" //38
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
        field(50108; "CSB Status"; Code[10])
        {
            Caption = 'CSB Status';
            DataClassification = CustomerContent;
            TableRelation = "CSB Order Status".Code where(Type = const(Purchase));
        }
        field(50109; "CSB Total Amount to Receive"; Decimal)
        {
            Caption = 'CSB Total Amount to Receive';
            DecimalPlaces = 2 : 2;
            FieldClass = FlowField;
            CalcFormula = sum("Purchase Line"."CSB Amount to Receive" where("Document No." = field("No."), "Document Type" = field("Document Type")));
        }
        field(50111; "CSB Total Amount to Invoice"; Decimal)
        {
            Caption = 'CSB Total Amount to Invoice';
            DecimalPlaces = 2 : 2;
            FieldClass = FlowField;
            CalcFormula = sum("Purchase Line"."CSB Amount to Invoice" where("Document No." = field("No."), "Document Type" = field("Document Type")));
        }
        field(50113; "CSB Total Line Disc. Amount"; Decimal)
        {
            Caption = 'CSB Total Line Disc. Amount';
            DecimalPlaces = 2 : 2;
            FieldClass = FlowField;
            CalcFormula = sum("Purchase Line"."Line Discount Amount" where("Document No." = field("No."), "Document Type" = field("Document Type")));
        }
        field(50114; "CSB Total Disc. to Receive"; Decimal)
        {
            Caption = 'CSB Total Dssc. to Receive';
            DecimalPlaces = 2 : 2;
            FieldClass = FlowField;
            CalcFormula = sum("Purchase Line"."CSB Line Disc. to Receive" where("Document No." = field("No."), "Document Type" = field("Document Type")));
        }
        field(50115; "CSB Total Disc. to Invoice"; Decimal)
        {
            Caption = 'CSB Total Disc. to Invoice';
            DecimalPlaces = 2 : 2;
            FieldClass = FlowField;
            CalcFormula = sum("Purchase Line"."CSB Line Disc. to Invoice" where("Document No." = field("No."), "Document Type" = field("Document Type")));
        }
    }

}
