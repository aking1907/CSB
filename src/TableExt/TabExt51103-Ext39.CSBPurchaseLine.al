tableextension 51103 "CSB Purchase Line" extends "Purchase Line" //39
{
    fields
    {
        field(50100; "CSB Item GTIN"; Code[14])
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

        field(50102; "CSB Shelf No."; Code[10])
        {
            Caption = 'CSB Shelf No.';
            FieldClass = FlowField;
            CalcFormula = lookup(Item."Shelf No." where("No." = field("No.")));
        }
        field(50107; "CSB Amount to Receive"; Decimal)
        {
            Caption = 'CSB Amount to Receive';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(50108; "CSB Allocation Amt. to Receive"; Decimal)
        {
            Caption = 'CSB Allocation Amt. to Receive';
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
        field(50111; "CSB Line Disc. to Receive"; Decimal)
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
        Rec."CSB Amount to Receive" := 0;
        Rec."CSB Amount to Invoice" := 0;
        Rec."CSB Line Disc. to Receive" := 0;
        Rec."CSB Line Disc. to Invoice" := 0;
        Rec."CSB Amount to Receive" := Rec."Qty. to Receive" * Rec."Unit Cost";
        Rec."CSB Amount to Invoice" := Rec."Qty. to Invoice" * Rec."Unit Cost";
        Rec."CSB Line Disc. to Receive" := Rec."Qty. to Receive" * Rec."Line Discount Amount";
        Rec."CSB Line Disc. to Invoice" := Rec."Qty. to Invoice" * Rec."Line Discount Amount";
    end;
}
