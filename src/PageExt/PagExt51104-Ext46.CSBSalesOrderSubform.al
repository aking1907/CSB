pageextension 51104 "CSB Sales Order Subform" extends "Sales Order Subform" //46
{
    layout
    {
        addafter(Quantity)
        {
            field("CSB Original Quantity"; Rec."CSB Original Quantity")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies CSB Original Quantity of the product.';
            }
        }
        addafter("Item Reference No.")
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
            field("CSB Retail Price"; Rec."CSB Retail Price")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies CSB Retail Price of the product.';
            }
            field("CSB Salon Price"; Rec."CSB Salon Price")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies CSB Salon Price of the product.';
            }
            field("CSB Shelf No."; Rec."CSB Shelf No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies CSB Shelf No. of the product.';
            }
            field("CSB Total to Ship Excl. Tax"; Rec."CSB Total to Ship Excl. Tax")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies CSB Total to Ship Excl. Tax of the product.';
                Editable = false;
            }
            field("CSB Retail Unit Cost"; Rec."CSB Retail Unit Cost")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies CSB Retail Unit Cost of the product.';
                ShowMandatory = true;
            }

        }

        addbefore("Total Amount Excl. VAT")
        {
            field("CSB SH Total to Ship Excl. Tax"; GlobalSalesHeader."CSB Total to Ship Excl. Tax")
            {
                ApplicationArea = All;
                Caption = 'CSB Total Lines';
                ToolTip = 'Specifies CSB Total to Ship Excl. Tax of the product.';
                Editable = false;
                DecimalPlaces = 2 : 2;
            }
            field("CSB Total Amount to Ship"; GlobalSalesHeader."CSB Total Amount to Ship")
            {
                ApplicationArea = All;
                Caption = 'CSB Total Items Value';
                ToolTip = 'Specifies CSB Total Amount to Ship of the product.';
                Editable = false;
                DecimalPlaces = 2 : 2;
            }
            field("CSB Total Alloc. Amt. to Ship"; GlobalSalesHeader."CSB Total Alloc. Amt. to Ship")
            {
                ApplicationArea = All;
                Caption = 'CSB Total Acct Charges';
                ToolTip = 'Specifies CSB Total Alloc. Amt. to Ship of the product.';
                Editable = false;
                DecimalPlaces = 2 : 2;
            }
            field("CSB Total Alloc. Amt. to Inv."; GlobalSalesHeader."CSB Total Alloc. Amt. to Inv.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies CSB Total Alloc. Amt. to Inv. of the product.';
                Editable = false;
                DecimalPlaces = 2 : 2;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if GlobalSalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            GlobalSalesHeader.CalcFields("CSB Total to Ship Excl. Tax"
                                       , "CSB Total Amount to Ship"
                                       , "CSB Total Alloc. Amt. to Ship"
                                       , "CSB Total Disc. to Ship"
                                       , "CSB Total Amount to Invoice"
                                       , "CSB Total Alloc. Amt. to Inv."
                                       , "CSB Total Disc. to Invoice");
    end;

    var
        GlobalSalesHeader: Record "Sales Header";
}
