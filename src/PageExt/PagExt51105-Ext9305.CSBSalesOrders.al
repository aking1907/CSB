pageextension 51105 "CSB Sales Orders" extends "Sales Order List" //9305
{
    layout
    {
        addlast(Control1)
        {
            field("CSB Status"; Rec."CSB Status")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the status of the order.';
            }
            field("CSB Created By"; Rec."CSB Created By")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies Created By of the order.';
            }
        }
    }
    actions
    {
        addafter("Create Inventor&y Put-away/Pick")
        {
            action(CSBCombibeOrders)
            {
                Image = NewSalesQuote;
                ApplicationArea = All;
                Caption = 'CSB Combine Orders';
                ToolTip = 'Create combined Sales Order.';

                trigger OnAction()
                begin
                    CSBCombineOrders();
                end;
            }
            action(CSBPostRetailSalesOrder)
            {
                Image = NewSalesQuote;
                ApplicationArea = All;
                Caption = 'CSB Create & Post Retail SO';
                ToolTip = 'Create & Post Retail Sales Order.';

                trigger OnAction()
                var
                    CSBPostRetailSalesOrderReport: Report "CSB Post Retail Sales Order";
                begin
                    CSBPostRetailSalesOrderReport.Runmodal();
                end;
            }
        }
        addafter("Create Inventor&y Put-away/Pick_Promoted")
        {
            actionref(CSBCombibeOrders_Promoted; CSBCombibeOrders) { }
            actionref(CSBPostRetailSalesOrder_Promoted; CSBPostRetailSalesOrder) { }
        }
    }

    local procedure CSBCombineOrders()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesHeaderTemp: Record "Sales Header" temporary;
        SalesLineTemp: Record "Sales Line" temporary;
        LineNo: Integer;
        DocumentNo: Code[20];
        MsgSOCreated: Label 'Sales Order %1 has been created.', Comment = '%1 Sales Order No.';
        MsgCombineSO: Label 'Do you want to combine Sales Orders?';
    begin
        if not Dialog.Confirm(MsgCombineSO, true) then exit;
        CurrPage.SetSelectionFilter(SalesHeader);
        if SalesHeader.FindSet() then
            repeat
                SalesHeader.TestField("Document Type", SalesHeader."Document Type"::Order);
                SalesHeaderTemp.Reset();
                SalesHeaderTemp.SetFilter("Sell-to Customer No.", '<>%1', SalesHeader."Sell-to Customer No.");
                if not SalesHeaderTemp.IsEmpty then
                    Error('The Combine Order function available for the same Sell-to Customer No. only!');

                SalesHeaderTemp.Reset();
                SalesHeaderTemp.SetFilter("Currency Code", '<>%1', SalesHeader."Currency Code");
                if not SalesHeaderTemp.IsEmpty then
                    Error('The Combine Order function available for the same Currency Code only!');

                SalesHeaderTemp.Reset();
                SalesHeaderTemp := SalesHeader;
                SalesHeaderTemp.Insert();

                SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                SalesLine.SetRange("Document No.", SalesHeader."No.");
                if SalesLine.FindSet() then
                    repeat
                        SalesLine.TestField("Quantity Shipped", 0);
                        SalesLine.TestField("Quantity Invoiced", 0);

                        SalesLineTemp := SalesLine;
                        SalesLineTemp.Insert();
                    until SalesLine.Next() = 0;
            until SalesHeader.Next() = 0;


        //Create Order
        SalesHeaderTemp.FindFirst();
        Clear(SalesHeader);
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader.Validate("Sell-to Customer No.", SalesHeaderTemp."Sell-to Customer No.");
        SalesHeader.Insert(true);
        DocumentNo := SalesHeader."No.";

        SalesLineTemp.Reset();
        if SalesLineTemp.FindSet() then
            repeat
                LineNo += 10000;
                Clear(SalesLine);
                SalesLine."Document Type" := SalesHeader."Document Type";
                SalesLine."Document No." := SalesHeader."No.";
                SalesLine."Line No." := LineNo;
                SalesLine.Validate(Type, SalesLineTemp.Type);
                SalesLine.Validate("No.", SalesLineTemp."No.");
                SalesLine.Validate("Variant Code", SalesLineTemp."Variant Code");
                SalesLine.Validate("Location Code", SalesLineTemp."Location Code");
                SalesLine.Validate("Unit of Measure Code", SalesLineTemp."Unit of Measure Code");
                SalesLine."CSB Item GTIN" := SalesLineTemp."CSB Item GTIN";
                SalesLine.Validate(Quantity, SalesLineTemp.Quantity);
                SalesLine.Validate("Unit Price", SalesLineTemp."Unit Price");
                SalesLine.Validate("Line Discount %", SalesLineTemp."Line Discount %");
                SalesLine.Insert(true);
            until SalesLineTemp.Next() = 0;

        //Delete source orders
        SalesHeaderTemp.Reset();
        if SalesHeaderTemp.FindSet() then
            repeat
                SalesLine.Reset();
                SalesLine.SetRange("Document Type", SalesHeaderTemp."Document Type");
                SalesLine.SetRange("Document No.", SalesHeaderTemp."No.");
                if not SalesLine.IsEmpty then
                    SalesLine.DeleteAll(true);

                SalesHeader.Reset();
                SalesHeader.SetRange("Document Type", SalesHeaderTemp."Document Type");
                SalesHeader.SetRange("No.", SalesHeaderTemp."No.");
                if SalesHeader.FindFirst() then
                    SalesHeader.Delete(true);
            until SalesHeaderTemp.Next() = 0;

        Message(MsgSOCreated, DocumentNo);
        CurrPage.Update(false);
    end;
}
