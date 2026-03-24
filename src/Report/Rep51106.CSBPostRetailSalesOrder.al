report 51106 "CSB Post Retail Sales Order"
{
    Caption = 'CSB Post Retail Sales Order';
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = None;

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Params)
                {
                    Caption = 'Parameters';
                    field(GlobalCustomerNo; GlobalCustomerNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Customer No.';
                        ToolTip = 'Specifies the value of the Global Customer No. field.';
                        Editable = false;
                        ShowMandatory = true;
                    }
                    field(GlobalPostingDate; GlobalPostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Posting Date';
                        ToolTip = 'Specifies the value of the Global Posting Date field.';
                        Editable = true;
                        ShowMandatory = true;
                    }
                    field(GlobalUnitPrice; GlobalUnitPrice)
                    {
                        ApplicationArea = All;
                        DecimalPlaces = 2 : 2;
                        Caption = 'Unit Price';
                        ToolTip = 'Specifies the value of the Global Unit Price field.';
                        Editable = true;
                        ShowMandatory = true;
                    }
                    field(GlobalUnitCost; GlobalUnitCost)
                    {
                        ApplicationArea = All;
                        DecimalPlaces = 2 : 2;
                        Caption = 'Unit Cost';
                        ToolTip = 'Specifies the value of the Global Unit Amount field.';
                        Editable = true;
                        ShowMandatory = true;
                    }
                    field(GlobalPostSO; GlobalPostSO)
                    {
                        ApplicationArea = All;
                        Caption = 'Post Sales Order';
                        ToolTip = 'Specifies the value of the Global Post SO field.';
                        Editable = true;
                        ShowMandatory = true;
                    }
                }
            }
        }
        trigger OnOpenPage()
        begin
            CSBGeneralSetup.Get();
            GlobalCustomerNo := CSBGeneralSetup."CSB Retail Customer No.";
            GlobalPostingDate := WorkDate;
            GlobalUnitPrice := 0;
            GlobalUnitCost := 0;
            GlobalPostSO := true;
        end;
    }

    trigger OnPostReport()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        CSBGeneralSetup.Get();

        SalesHeader.InitRecord();
        SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.Validate("Sell-to Customer No.", GlobalCustomerNo);
        SalesHeader.Insert(true);
        SalesHeader.Validate("CSB Retail", true);
        SalesHeader.Validate("CSB Delete After Posting", true);
        SalesHeader.Validate("Posting Date", GlobalPostingDate);
        SalesHeader.Modify(true);

        SalesLine.Init();
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.InitHeaderDefaults(SalesHeader);
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", CSBGeneralSetup."CSB Retail Item No.");
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Qty. to Ship", 1);
        SalesLine.Validate("Qty. to Invoice", 1);
        SalesLine.Validate("Unit Price", GlobalUnitPrice);
        SalesLine.Validate("CSB Retail Unit Cost", GlobalUnitCost);
        SalesLine.Insert(true);

        if GlobalPostSO then begin
            SalesHeader.Invoice := true;
            SalesHeader.Ship := true;
            SalesHeader.Modify();
            Codeunit.Run(Codeunit::"Sales-Post", SalesHeader);
        end;
    end;

    procedure PostUnitCostBeforePostingSalesDoc(var SalesHeader: Record "Sales Header")
    begin
        PostItemJournal(SalesHeader);
    end;

    procedure PostUnitCostAfterPostingSalesDoc(SalesInvHeaderNo: Code[20])
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader.Get(SalesInvHeaderNo);
        PostItemJournal(SalesInvoiceHeader);
    end;

    procedure PostItemJournal(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        ItemJournalLine: Record "Item Journal Line";
        SalesShipmentLine: Record "Sales Shipment Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemJournalBatch: Record "Item Journal Batch";
        Item: Record Item;
        NoSeries: Codeunit "No. Series";
        NextLineNo: Integer;
        DocumentNo: Code[20];
    begin
        if not SalesInvoiceHeader."CSB Retail" then exit;

        CSBGeneralSetup.Get();
        CSBGeneralSetup.TestField("CSB Retail Jnl. Template Name");
        CSBGeneralSetup.TestField("CSB Retail Jnl. Batch Name");
        CSBGeneralSetup.TestField("CSB Retail Item No.");

        Item.SetRange("No.", CSBGeneralSetup."CSB Retail Item No.");
        Item.SetRange("Location Filter", SalesInvoiceHeader."Location Code");
        Item.FindFirst();
        Item.CalcFields(Inventory);
        if Item.Inventory >= 0 then
            exit;

        ItemJournalBatch.Get(CSBGeneralSetup."CSB Retail Jnl. Template Name", CSBGeneralSetup."CSB Retail Jnl. Batch Name");
        ItemJournalBatch.TestField("No. Series");

        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
        SalesInvoiceLine.SetRange("No.", CSBGeneralSetup."CSB Retail Item No.");
        SalesInvoiceLine.FindFirst();
        if SalesInvoiceLine."CSB Retail Unit Cost" = 0 then
            exit;

        SalesInvoiceLine.TestField("Order No.");

        SalesShipmentLine.SetRange("Order No.", SalesInvoiceLine."Order No.");
        SalesShipmentLine.SetRange("Order Line No.", SalesInvoiceLine."Order Line No.");
        if not SalesShipmentLine.FindFirst() then
            Error(ErrNothingToPost);

        ItemLedgerEntry.Get(SalesShipmentLine."Item Shpt. Entry No.");
        ItemLedgerEntry.TestField(Open, true);

        ItemJournalLine.Reset();
        ItemJournalLine.SetRange("Journal Template Name", CSBGeneralSetup."CSB Retail Jnl. Template Name");
        ItemJournalLine.SetRange("Journal Batch Name", CSBGeneralSetup."CSB Retail Jnl. Batch Name");
        if ItemJournalLine.FindLast() then
            NextLineNo := ItemJournalLine."Line No." + 10000;

        DocumentNo := NoSeries.GetLastNoUsed(ItemJournalBatch."No. Series");
        DocumentNo := IncStr(DocumentNo);
        ItemJournalLine.Reset();
        ItemJournalLine.Init();
        ItemJournalLine.Validate("Journal Template Name", CSBGeneralSetup."CSB Retail Jnl. Template Name");
        ItemJournalLine.Validate("Journal Batch Name", CSBGeneralSetup."CSB Retail Jnl. Batch Name");
        ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::"Positive Adjmt.");
        ItemJournalLine.Validate("Line No.", NextLineNo);
        ItemJournalLine.Validate("Posting Date", ItemLedgerEntry."Posting Date");
        ItemJournalLine.Validate("Document No.", DocumentNo);
        ItemJournalLine.Validate("Item No.", SalesShipmentLine."No.");
        ItemJournalLine.Validate("Variant Code", SalesShipmentLine."Variant Code");
        ItemJournalLine.Validate("Location Code", SalesShipmentLine."Location Code");
        ItemJournalLine.Validate(Quantity, 1);
        ItemJournalLine.Validate("Unit of Measure Code", SalesShipmentLine."Unit of Measure Code");
        ItemJournalLine.Validate("Applies-from Entry", SalesShipmentLine."Item Shpt. Entry No.");
        ItemJournalLine.Validate("Unit Cost", SalesInvoiceLine."CSB Retail Unit Cost");
        ItemJournalLine.Validate("Unit Amount", SalesInvoiceLine."CSB Retail Unit Cost");
        ItemJournalLine.Insert(true);

        ItemJournalLine.SetRange("Journal Template Name", ItemJournalLine."Journal Template Name");
        ItemJournalLine.SetRange("Journal Batch Name", ItemJournalLine."Journal Batch Name");
        ItemJournalLine.SetRange("Line No.", ItemJournalLine."Line No.");

        Codeunit.Run(Codeunit::"Item Jnl.-Post", ItemJournalLine);
    end;

    local procedure PostItemJournal(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        ItemJournalLine: Record "Item Journal Line";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemJournalBatch: Record "Item Journal Batch";
        Item: Record Item;
        NoSeries: Codeunit "No. Series";
        NextLineNo: Integer;
        DocumentNo: Code[20];
    begin
        if not SalesHeader."CSB Retail" then exit;

        CSBGeneralSetup.Get();
        CSBGeneralSetup.TestField("CSB Retail Jnl. Template Name");
        CSBGeneralSetup.TestField("CSB Retail Jnl. Batch Name");
        CSBGeneralSetup.TestField("CSB Retail Item No.");

        Item.SetRange("No.", CSBGeneralSetup."CSB Retail Item No.");
        Item.SetRange("Location Filter", SalesHeader."Location Code");
        Item.FindFirst();
        Item.CalcFields(Inventory);
        if Item.Inventory < 0 then
            exit;

        ItemJournalBatch.Get(CSBGeneralSetup."CSB Retail Jnl. Template Name", CSBGeneralSetup."CSB Retail Jnl. Batch Name");
        ItemJournalBatch.TestField("No. Series");

        ItemJournalLine.Reset();
        ItemJournalLine.SetRange("Journal Template Name", CSBGeneralSetup."CSB Retail Jnl. Template Name");
        ItemJournalLine.SetRange("Journal Batch Name", CSBGeneralSetup."CSB Retail Jnl. Batch Name");
        if ItemJournalLine.FindLast() then
            NextLineNo := ItemJournalLine."Line No." + 10000;

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetRange("No.", CSBGeneralSetup."CSB Retail Item No.");
        SalesLine.FindFirst();

        DocumentNo := NoSeries.GetLastNoUsed(ItemJournalBatch."No. Series");
        DocumentNo := IncStr(DocumentNo);
        ItemJournalLine.Reset();
        ItemJournalLine.Init();
        ItemJournalLine.Validate("Journal Template Name", CSBGeneralSetup."CSB Retail Jnl. Template Name");
        ItemJournalLine.Validate("Journal Batch Name", CSBGeneralSetup."CSB Retail Jnl. Batch Name");
        ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::"Positive Adjmt.");
        ItemJournalLine.Validate("Line No.", NextLineNo);
        ItemJournalLine.Validate("Posting Date", SalesHeader."Posting Date");
        ItemJournalLine.Validate("Document No.", DocumentNo);
        ItemJournalLine.Validate("Item No.", CSBGeneralSetup."CSB Retail Item No.");
        ItemJournalLine.Validate("Location Code", SalesHeader."Location Code");
        ItemJournalLine.Validate(Quantity, 1);
        ItemJournalLine.Validate("Unit of Measure Code", SalesLine."Unit of Measure Code");
        ItemJournalLine.Validate("Unit Cost", SalesLine."CSB Retail Unit Cost");
        ItemJournalLine.Validate("Unit Amount", SalesLine."CSB Retail Unit Cost");
        ItemJournalLine.Insert(true);

        ItemJournalLine.SetRange("Journal Template Name", ItemJournalLine."Journal Template Name");
        ItemJournalLine.SetRange("Journal Batch Name", ItemJournalLine."Journal Batch Name");
        ItemJournalLine.SetRange("Line No.", ItemJournalLine."Line No.");

        Codeunit.Run(Codeunit::"Item Jnl.-Post", ItemJournalLine);

        ItemLedgerEntry.SetRange("Item No.", CSBGeneralSetup."CSB Retail Item No.");
        if ItemLedgerEntry.FindLast() then begin
            SalesLine.Validate("Appl.-to Item Entry", ItemLedgerEntry."Entry No.");
            SalesLine.Modify(true);
        end;
    end;

    var
        CSBGeneralSetup: Record "CSB General Setup";
        GlobalCustomerNo: Code[20];
        GlobalPostingDate: Date;
        GlobalUnitPrice: Decimal;
        GlobalUnitCost: Decimal;
        GlobalPostSO: Boolean;
        ErrNothingToPost: Label 'Nothing to post.';
}
