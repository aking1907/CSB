pageextension 51108 "CSB Purchase Order" extends "Purchase Order" //50
{
    layout
    {
        addafter(Status)
        {
            field("CSB Status"; Rec."CSB Status")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the status of the order.';
            }
        }
        addafter("Remit-to Code")
        {
            field("CSB Shipping Agent Code"; Rec."CSB Shipping Agent Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies CSB Shipping Agent Code of the product.';
            }
            field("CSB Package Tracking No."; Rec."CSB Package Tracking No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies CSB Package Tracking No. of the product.';
            }
        }
    }

    actions
    {
        addafter(PostPrepaymentCreditMemo)
        {
            action(CSBCreateSOFromPO)
            {
                Image = Sales;
                ApplicationArea = All;
                Caption = 'CSB Create Sales Order';
                ToolTip = 'Create a Sales Order from a Purchase Order.';

                trigger OnAction()
                var
                    PurchaseHeader: Record "Purchase Header";
                begin
                    PurchaseHeader.SetRange("No.", Rec."No.");
                    PurchaseHeader.SetRange("Document Type", Rec."Document Type");

                    Report.Run(Report::"CSB Create SO From PO", true, true, PurchaseHeader);
                end;
            }
            action(CSBOpenSalesOrder)
            {
                Image = Order;
                ApplicationArea = All;
                Caption = 'CSB Open Sales Order';
                ToolTip = 'CSB Open Sales Order';

                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                begin
                    SalesHeader.Get(SalesHeader."Document Type"::Order, Rec."Your Reference");
                    Page.RunModal(Page::"Sales Order", SalesHeader);
                end;
            }
        }
        addafter(PostedPrepaymentCrMemos_Promoted)
        {
            actionref(CSBCreateSOFromPO_Promoted; CSBCreateSOFromPO) { }
            actionref(CSBOpenSalesOrder_Promoted; CSBOpenSalesOrder) { }
        }
    }
}
