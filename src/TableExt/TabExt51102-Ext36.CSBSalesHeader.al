tableextension 51102 "CSB Sales Header" extends "Sales Header" //36
{
    fields
    {
        field(50100; "CSB Delete After Posting"; Boolean)
        {
            Caption = 'CSB Delete After Posting';
            DataClassification = CustomerContent;
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
            CalcFormula = sum("Sales Line"."CSB Line Gross Weight" where("Document No." = field("No."), "Document Type" = field("Document Type")));
        }
        field(50107; "CSB Total to Ship Excl. Tax"; Decimal)
        {
            Caption = 'CSB Total to Ship Excl. Tax';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Line"."CSB Total to Ship Excl. Tax" where("Document No." = field("No."), "Document Type" = field("Document Type")));
        }
        field(50108; "CSB Status"; Code[10])
        {
            Caption = 'CSB Status';
            DataClassification = CustomerContent;
            TableRelation = "CSB Order Status".Code where(Type = const(Sales));
        }
        field(50109; "CSB Total Amount to Ship"; Decimal)
        {
            Caption = 'CSB Total Amount to Ship';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Line"."CSB Amount to Ship" where("Document No." = field("No."), "Document Type" = field("Document Type")));
        }
        field(50110; "CSB Total Alloc. Amt. to Ship"; Decimal)
        {
            Caption = 'CSB Total Alloc. Amt. to Ship';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Line"."CSB Allocation Amt. to Ship" where("Document No." = field("No."), "Document Type" = field("Document Type")));
        }
        field(50111; "CSB Total Amount to Invoice"; Decimal)
        {
            Caption = 'CSB Total Amount to Invoice';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Line"."CSB Amount to Invoice" where("Document No." = field("No."), "Document Type" = field("Document Type")));
        }
        field(50112; "CSB Total Alloc. Amt. to Inv."; Decimal)
        {
            Caption = 'CSB Total Alloc. Amt. to Invoice';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Line"."CSB Allocation Amt. to Invoice" where("Document No." = field("No."), "Document Type" = field("Document Type")));
        }
        field(50113; "CSB Total Line Disc. Amount"; Decimal)
        {
            Caption = 'CSB Total Line Disc. Amount';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Line"."Line Discount Amount" where("Document No." = field("No."), "Document Type" = field("Document Type")));
        }
        field(50114; "CSB Total Disc. to Ship"; Decimal)
        {
            Caption = 'CSB Total Dssc. to Ship';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Line"."CSB Line Disc. to Ship" where("Document No." = field("No."), "Document Type" = field("Document Type")));
        }
        field(50115; "CSB Total Disc. to Invoice"; Decimal)
        {
            Caption = 'CSB Total Disc. to Invoice';
            FieldClass = FlowField;
            CalcFormula = sum("Sales Line"."CSB Line Disc. to Invoice" where("Document No." = field("No."), "Document Type" = field("Document Type")));
        }
        field(50116; "CSB Retail"; Boolean)
        {
            Caption = 'CSB Retail';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Salesline: Record "Sales Line";
            begin
                Salesline.SetRange("Document No.", Rec."No.");
                Salesline.SetRange("Document Type", Rec."Document Type");
                if Salesline.FindSet() then
                    Salesline.ModifyAll("CSB Retail Unit Cost", 0, false);
            end;
        }
    }
}