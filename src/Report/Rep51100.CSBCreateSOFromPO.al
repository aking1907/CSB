report 51100 "CSB Create SO From PO"
{
    Caption = 'CSB Create SO From PO';
    ProcessingOnly = true;

    dataset
    {
        dataitem(PurchaseHeader; "Purchase Header")
        {
            DataItemTableView = sorting("Document Type", "No.") where("Document Type" = const(Order));
            trigger OnAfterGetRecord()
            begin
                GlobalSalesOrderNo := CreateSOFromPO(PurchaseHeader);
                CurrReport.Break();
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    Caption = 'Params';
                    field(CustomerNo; GlobalCustomerNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Sell-to Customer No.';
                        ToolTip = 'Specifies Sell-to Customer No. of the product.';
                        TableRelation = Customer;
                    }
                }
            }
        }
    }

    trigger OnPostReport()
    begin
        Message(MsgSOCreated, GlobalSalesOrderNo);
    end;

    local procedure CreateSOFromPO(Rec: Record "Purchase Header"): Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PurchaseLine: Record "Purchase Line";
    begin
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader.Validate("Sell-to Customer No.", GlobalCustomerNo);
        SalesHeader.TestField("Sell-to Customer No.");
        SalesHeader."Your Reference" := Rec."No.";
        SalesHeader.Insert(true);

        SalesHeader.Validate("Location Code", Rec."Location Code");
        SalesHeader.Modify();

        Rec."Your Reference" := CopyStr(Rec."Your Reference" + ';' + SalesHeader."No.", 1, MaxStrLen(Rec."Your Reference"));
        Rec."Your Reference" := DelChr(Rec."Your Reference", '<>', ';');
        Rec.Modify();

        PurchaseLine.SetRange("Document Type", Rec."Document Type");
        PurchaseLine.SetRange("Document No.", Rec."No.");
        if PurchaseLine.FindSet() then
            repeat
                Clear(SalesLine);
                SalesLine."Document Type" := SalesHeader."Document Type";
                SalesLine."Document No." := SalesHeader."No.";
                SalesLine."Line No." := PurchaseLine."Line No.";
                SalesLine.Validate(Type, PurchaseLine.Type);
                SalesLine.Validate("No.", PurchaseLine."No.");
                SalesLine.Validate("Variant Code", PurchaseLine."Variant Code");
                SalesLine.Validate("Location Code", PurchaseLine."Location Code");
                SalesLine.Validate("Unit of Measure Code", PurchaseLine."Unit of Measure Code");
                SalesLine."CSB Item GTIN" := PurchaseLine."CSB Item GTIN";
                SalesLine.Validate(Quantity, PurchaseLine.Quantity);
                SalesLine.Insert(true);
            until PurchaseLine.Next() = 0;

        exit(SalesHeader."No.");
    end;

    var
        GlobalCustomerNo: Code[20];
        GlobalSalesOrderNo: Code[20];
        MsgSOCreated: Label 'Sales Order %1 has been created.', Comment = '%1 Sales Order No.';
}
