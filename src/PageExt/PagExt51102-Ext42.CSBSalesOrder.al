pageextension 51102 "CSB Sales Order" extends "Sales Order" //42
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
            field("CSB Delete After Posting"; Rec."CSB Delete After Posting")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if the order should be deleted after posting.';
            }
            field("CSB Retail"; Rec."CSB Retail")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies if the order is for retail.';
                Visible = false;
            }
            field("CSB Pallets"; Rec."CSB Pallets")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the number of pallets.';
            }
            field("CSB Cartons"; Rec."CSB Cartons")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the number of cartons.';
            }
            field("CSB Scaled Weight"; Rec."CSB Scaled Weight")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the scaled weight.';
            }
            field("CSB Total Gross Weight"; Rec."CSB Total Gross Weight")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the total gross weight.';
            }
        }
    }

    actions
    {
        addafter("S&hipments")
        {
            action(CSBCreatePOFromSO)
            {
                Image = Sales;
                ApplicationArea = All;
                Caption = 'CSB Create Purch. Order';
                ToolTip = 'Create a Purchase Order from a Sales Order.';

                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                begin
                    SalesHeader.SetRange("No.", Rec."No.");
                    SalesHeader.SetRange("Document Type", Rec."Document Type");

                    Report.Run(Report::"CSB Create PO From SO", true, true, SalesHeader);
                end;
            }
            action(CSBOpenPurchOrder)
            {
                Image = Order;
                ApplicationArea = All;
                Caption = 'CSB Open Purch. Order';
                ToolTip = 'CSB Open Purch. Order';

                trigger OnAction()
                var
                    PurchaseHeader: Record "Purchase Header";
                begin
                    PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, Rec."Your Reference");
                    Page.RunModal(Page::"Purchase Order", PurchaseHeader);
                    CurrPage.Update(false);
                end;
            }
            action(CSBRefreshValues)
            {
                Image = RefreshLines;
                ApplicationArea = All;
                Caption = 'CSB Refresh Values';
                ToolTip = 'CSB Refresh Values';

                trigger OnAction()
                var
                    SalesLine: Record "Sales Line";
                begin
                    SalesLine.SetRange("Document Type", Rec."Document Type");
                    SalesLine.SetRange("Document No.", Rec."No.");
                    if SalesLine.FindSet() then
                        repeat
                            SalesLine.Modify();
                        until SalesLine.Next() = 0;
                end;
            }
            action(CSBEmailProFormaInvoice)
            {
                Image = Email;
                ApplicationArea = All;
                Caption = 'CSB Email Pro Forma Invoice';
                ToolTip = 'CSB Email Pro Forma Invoice';

                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                    ReportSelections: Record "Report Selections";
                    ReportUsage: Enum "Report Selection Usage";
                begin
                    SalesHeader.SetRange("No.", Rec."No.");
                    SalesHeader.SetRange("Document Type", Rec."Document Type");
                    SalesHeader.FindFirst();

                    ReportUsage := ReportUsage::"Pro Forma S. Invoice";
                    ReportSelections.SendEmailToCust(ReportUsage.AsInteger()
                                                   , SalesHeader
                                                   , SalesHeader."No."
                                                   , SalesHeader.GetDocTypeTxt()
                                                   , true
                                                   , SalesHeader.GetBillToNo())

                end;
            }
        }
        addafter("S&hipments_Promoted")
        {
            actionref(CSBCreatePOFromSO_Promoted; CSBCreatePOFromSO) { }
            actionref(CSBOpenPurchOrder_Promoted; CSBOpenPurchOrder) { }
            actionref(CSBRefreshValues_Promoted; CSBRefreshValues) { }
        }
        addafter(ProformaInvoice_Promoted)
        {
            actionref(CSBEmailProFormaInvoice_Promoted; CSBEmailProFormaInvoice) { }
        }
    }
}