pageextension 51103 "CSB Purchase Order Subform" extends "Purchase Order Subform" //54
{
    layout
    {
        addafter("No.")
        {
            field("CSB Item GTIN"; Rec."CSB Item GTIN")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies Item GTIN of the product.';

                trigger OnAssistEdit()
                var
                    Item: Record Item;
                    ItemListPage: Page "Item List";
                begin
                    Item.SetRange(GTIN, Rec."CSB Item GTIN");
                    if Item.FindFirst() then
                        ItemListPage.SetRecord(Item);

                    ItemListPage.LookupMode(true);
                    if ItemListPage.RunModal() <> Action::LookupOK then
                        exit;

                    ItemListPage.GetRecord(Item);
                    Rec.Validate("No.", Item."No.");
                end;
            }
            field("CSB Shelf No."; Rec."CSB Shelf No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies CSB Shelf No. of the product.';
            }
        }
        addafter("Line Amount")
        {
            field("CSB Amount to Invoice"; Rec."CSB Amount to Invoice")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies CSB Amount to Invoice of the product.';
                DecimalPlaces = 2 : 2;
            }
            field("CSB Amount to Receive"; Rec."CSB Amount to Receive")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies CSB Amount to Receive of the product.';
                DecimalPlaces = 2 : 2;
            }
        }
        addbefore("Total Amount Excl. VAT")
        {
            field("CSB Total Amount to Receive"; GlobalPurchaseHeader."CSB Total Amount to Receive")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies CSB Total Amount to Receive of the product.';
                Editable = false;
                DecimalPlaces = 2 : 2;
            }
            field("CSB Total Disc. to Receive"; GlobalPurchaseHeader."CSB Total Disc. to Receive")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies CSB Total Disc. to Receive of the product.';
                Editable = false;
                DecimalPlaces = 2 : 2;
            }
            field("CSB Total Amount to Invoice"; GlobalPurchaseHeader."CSB Total Amount to Invoice")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies CSB Total Amount to Invoice of the product.';
                Editable = false;
                DecimalPlaces = 2 : 2;
            }
            field("CSB Total Disc. to Invoice"; GlobalPurchaseHeader."CSB Total Disc. to Invoice")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies CSB Total Disc. to Invoice of the product.';
                Editable = false;
                DecimalPlaces = 2 : 2;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        if GlobalPurchaseHeader.Get(Rec."Document Type", Rec."Document No.") then
            GlobalPurchaseHeader.CalcFields(
                                                  "CSB Total Amount to Receive"
                                                , "CSB Total Disc. to Receive"
                                                , "CSB Total Amount to Invoice"
                                                , "CSB Total Disc. to Invoice");
    end;

    var
        GlobalPurchaseHeader: Record "Purchase Header";
}
