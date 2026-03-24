reportextension 51100 "CSB Standard Purchase - Order" extends "Standard Purchase - Order" //1322
{

    // WORDLayout = './src/ReportExt/Word/Rep1322-Ext51100.CSBStandardPurchaseOrder.docx';

    dataset
    {
        modify("Purchase Header")
        {
            trigger OnAfterAfterGetRecord()
            begin
                AddPhoneToShipToAddr();
            end;
        }
        modify("Purchase Line")
        {
            trigger OnAfterAfterGetRecord()

            begin
                Clear(Item);
                if "Purchase Line".Type <> "Purchase Line".Type::Item then exit;
                if Item.Get("Purchase Line"."No.") then;
            end;
        }
        add("Purchase Line")
        {
            column(CSBItemGTIN; Item.GTIN) { }
        }
    }
    rendering
    {
        layout(CSBWordLayout)
        {
            Type = Word;
            Caption = 'CSB Standard Purchase Order';
            Summary = 'CSB Standard Purchase Order';
            LayoutFile = './src/ReportExt/Word/Rep1322-Ext51100.CSBStandardPurchaseOrder.docx';
        }
    }

    local procedure AddPhoneToShipToAddr()
    var
        Location: Record Location;
        i: Integer;
        skip: Boolean;
    begin
        if not Location.Get("Purchase Header"."Location Code") then
            exit;

        for i := 1 to 8 do begin
            if not skip and (ShipToAddr[i] = '') then begin
                ShipToAddr[i] := Location."Phone No.";
                skip := true;
            end;
        end;
    end;

    var
        Item: Record Item;
}
