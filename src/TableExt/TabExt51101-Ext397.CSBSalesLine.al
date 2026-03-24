tableextension 51101 "CSB Sales Line" extends "Sales Line" //397
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
        field(50103; "CSB Item GTIN"; Code[14])
        {
            Caption = 'CSB Item GTIN';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if Rec.Type <> Rec.Type::Item then exit;
                if Rec."CSB Item GTIN" = '' then exit;

                if Item.Get(Rec."No.") then
                    if Item.GTIN = Rec."CSB Item GTIN" then
                        exit;

                Item.SetRange(GTIN, Rec."CSB Item GTIN");
                Item.FindFirst();
                Rec.Validate("No.", Item."No.");
            end;
        }
        field(50104; "CSB Original Quantity"; Decimal)
        {
            Caption = 'CSB Original Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(50105; "CSB Total to Ship Excl. Tax"; Decimal)
        {
            Caption = 'CSB Total to Ship Excl. Tax';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(50106; "CSB Line Gross Weight"; Decimal)
        {
            Caption = 'CSB Line Gross Weight';
            DataClassification = CustomerContent;
        }
        field(50107; "CSB Amount to Ship"; Decimal)
        {
            Caption = 'CSB Amount to Ship';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(50108; "CSB Allocation Amt. to Ship"; Decimal)
        {
            Caption = 'CSB Allocation Amt. to Ship';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(50109; "CSB Amount to Invoice"; Decimal)
        {
            Caption = 'CSB Amount to Invoice';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(50110; "CSB Allocation Amt. to Invoice"; Decimal)
        {
            Caption = 'CSB Allocation Amt. to Invoice';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(50111; "CSB Line Disc. to Ship"; Decimal)
        {
            Caption = 'CSB Total Line Disc. to Receive';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(50112; "CSB Line Disc. to Invoice"; Decimal)
        {
            Caption = 'CSB Total Line Disc. to Invoice';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(50113; "CSB Retail Unit Cost"; Decimal)
        {
            Caption = 'CSB Retail Unit Cost';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                SalesHeader: Record "Sales Header";
            begin
                SalesHeader.Get(Rec."Document Type", Rec."Document No.");
                SalesHeader.TestField("CSB Retail", true);
            end;
        }
    }

    procedure SetItemGTIN()
    var
        Item: Record Item;
    begin
        Rec."CSB Item GTIN" := '';
        if Rec.Type = Rec.Type::Item then
            if Item.Get(Rec."No.") then
                Rec."CSB Item GTIN" := Item.GTIN;
    end;

    procedure RecalculateLineTotals()
    begin
        Rec."CSB Amount to Ship" := 0;
        Rec."CSB Amount to Invoice" := 0;
        Rec."CSB Allocation Amt. to Ship" := 0;
        Rec."CSB Allocation Amt. to Invoice" := 0;
        Rec."CSB Line Disc. to Ship" := 0;
        Rec."CSB Line Disc. to Invoice" := 0;

        if Rec.Type = Rec.Type::Item then begin
            Rec."CSB Amount to Ship" := Rec."Qty. to Ship" * Rec."Unit Price";
            Rec."CSB Amount to Invoice" := Rec."Qty. to Invoice" * Rec."Unit Price";
            Rec."CSB Line Disc. to Ship" := Rec."Qty. to Ship" * Rec."Line Discount Amount";
            Rec."CSB Line Disc. to Invoice" := Rec."Qty. to Invoice" * Rec."Line Discount Amount";
        end;

        if Rec.Type = Rec.Type::"Allocation Account" then begin
            Rec."CSB Allocation Amt. to Ship" := Rec."Qty. to Ship" * Rec."Unit Price";
            Rec."CSB Allocation Amt. to Invoice" := Rec."Qty. to Invoice" * Rec."Unit Price";
        end;
    end;
}