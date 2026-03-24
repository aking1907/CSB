report 51101 "CSB Create PO From SO"
{
    Caption = 'CSB Create PO From SO';
    ProcessingOnly = true;

    dataset
    {
        dataitem(SalesHeader; "Sales Header")
        {
            DataItemTableView = sorting("Document Type", "No.") where("Document Type" = const(Order));
            trigger OnAfterGetRecord()
            begin
                GlobalPurchaseOrderNo := CreatePOFromSO(SalesHeader);
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
                    field(VendotNo; GlobalVendorNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Buy-from Vendor No.';
                        ToolTip = 'Specifies Buy-from Vendor No. of the product.';
                        TableRelation = Vendor;
                    }
                }
            }
        }
    }

    trigger OnPostReport()
    begin
        Message(MsgPOCreated, GlobalPurchaseOrderNo);
    end;

    local procedure CreatePOFromSO(Rec: Record "Sales Header"): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        SalesLine: Record "Sales Line";
    begin
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Order;
        PurchaseHeader.Validate("Buy-from Vendor No.", GlobalVendorNo);
        PurchaseHeader.TestField("Buy-from Vendor No.");
        PurchaseHeader."Your Reference" := Rec."No.";
        PurchaseHeader.Insert(true);

        PurchaseHeader.Validate("Location Code", Rec."Location Code");
        PurchaseHeader.Modify();

        Rec."Your Reference" := CopyStr(Rec."Your Reference" + ';' + PurchaseHeader."No.", 1, MaxStrLen(Rec."Your Reference"));
        Rec."Your Reference" := DelChr(Rec."Your Reference", '<>', ';');
        Rec.Modify();

        SalesLine.SetRange("Document Type", Rec."Document Type");
        SalesLine.SetRange("Document No.", Rec."No.");
        if SalesLine.FindSet() then
            repeat
                Clear(PurchaseLine);
                PurchaseLine."Document Type" := PurchaseHeader."Document Type";
                PurchaseLine."Document No." := PurchaseHeader."No.";
                PurchaseLine."Line No." := SalesLine."Line No.";
                PurchaseLine.Validate(Type, SalesLine.Type);
                PurchaseLine.Validate("No.", SalesLine."No.");
                PurchaseLine.Validate("Variant Code", SalesLine."Variant Code");
                PurchaseLine.Validate("Location Code", SalesLine."Location Code");
                PurchaseLine.Validate("Unit of Measure Code", SalesLine."Unit of Measure Code");
                PurchaseLine."CSB Item GTIN" := SalesLine."CSB Item GTIN";
                PurchaseLine.Validate(Quantity, SalesLine.Quantity);
                PurchaseLine.Validate("Direct Unit Cost", SalesLine."Unit Cost");
                PurchaseLine.Insert(true);
            until SalesLine.Next() = 0;

        exit(PurchaseHeader."No.");
    end;

    var
        GlobalVendorNo: Code[20];
        GlobalPurchaseOrderNo: Code[20];
        MsgPOCreated: Label 'Purchase Order %1 has been created.', Comment = '%1 Purchase Order No.';
}