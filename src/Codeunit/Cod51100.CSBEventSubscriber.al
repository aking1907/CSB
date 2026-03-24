codeunit 51100 "CSB Event Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post (Yes/No)", OnBeforeOnRun, '', false, false)]
    local procedure CodeunitSalesPostYesNo_OnBeforeOnRun(var SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        CSBGeneraalSetup: Record "CSB General Setup";
        PostingDateLbl: Label 'The document Posting Date is not equal to today''s date. Do you want to overwrite it and continue posting?';
    begin
        CSBGeneraalSetup.Get();
        if CSBGeneraalSetup."Overwrite Sales Posting Date" then begin
            if SalesHeader."Posting Date" <> Today() then begin
                if GuiAllowed then
                    if not Confirm(PostingDateLbl, true) then
                        Error('');

                SalesHeader.Validate("Posting Date", Today());
                SalesHeader.Validate("Document Date", Today());
                SalesHeader.Modify(true);
            end;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforePostSalesDoc, '', false, false)]
    local procedure CodeunitSalesPost_OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean; var IsHandled: Boolean; var CalledBy: Integer)
    var
        SalesLine: Record "Sales Line";
        CSBPostRetailSalesOrderReport: Report "CSB Post Retail Sales Order";
    begin
        if SalesHeader.IsTemporary then exit;
        if CommitIsSuppressed or PreviewMode then exit;

        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then exit;

        CSBPostRetailSalesOrderReport.PostUnitCostBeforePostingSalesDoc(SalesHeader);

        if not SalesHeader."CSB Delete After Posting" then exit;

        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FindSet() then
            repeat
                if (SalesLine."Qty. to Ship" + SalesLine."Quantity Shipped") < SalesLine.Quantity then begin
                    if SalesHeader.Status = SalesHeader.Status::Released then begin
                        SalesHeader.Status := SalesHeader.Status::Open;
                        SalesHeader.Modify();

                        SalesLine.Validate(Quantity, SalesLine."Qty. to Ship" + SalesLine."Quantity Shipped");
                        SalesLine.Modify();

                        SalesHeader.Status := SalesHeader.Status::Released;
                        SalesHeader.Modify();
                    end else begin
                        SalesLine.Validate(Quantity, SalesLine."Qty. to Ship" + SalesLine."Quantity Shipped");
                        SalesLine.Modify();
                    end;
                end else
                    if (SalesLine."Qty. to Invoice" + SalesLine."Quantity Invoiced") <> (SalesLine."Qty. to Ship" + SalesLine."Quantity Shipped") then begin
                        if SalesHeader.Status = SalesHeader.Status::Released then begin
                            SalesHeader.Status := SalesHeader.Status::Open;
                            SalesHeader.Modify();

                            SalesLine.Validate("Qty. to Invoice", SalesLine."Qty. to Ship" + SalesLine."Quantity Shipped" - SalesLine."Quantity Invoiced");
                            SalesLine.Modify();

                            SalesHeader.Status := SalesHeader.Status::Released;
                            SalesHeader.Modify();
                        end else begin
                            SalesLine.Validate("Qty. to Invoice", SalesLine."Qty. to Ship" + SalesLine."Quantity Shipped" - SalesLine."Quantity Invoiced");
                            SalesLine.Modify();
                        end;
                    end;
            until SalesLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterPostSalesDoc, '', false, false)]
    local procedure CodeunitSalesPost_OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean; PreviewMode: Boolean)
    var
        CSBPostRetailSalesOrderReport: Report "CSB Post Retail Sales Order";
    begin
        if SalesHeader.IsTemporary then exit;
        if CommitIsSuppressed or PreviewMode then exit;

        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then exit;

        CSBPostRetailSalesOrderReport.PostUnitCostAfterPostingSalesDoc(SalesInvHdrNo);
    end;

    //Update Posted Sales Invoice
    [EventSubscriber(ObjectType::Page, Page::"Posted Sales Inv. - Update", OnAfterRecordChanged, '', false, false)]
    local procedure SalesInvHeaderEdit_OnAfterRecordChanged(var SalesInvoiceHeader: Record "Sales Invoice Header"; xSalesInvoiceHeader: Record "Sales Invoice Header"; var IsChanged: Boolean)
    begin
        IsChanged := IsChanged or (SalesInvoiceHeader."Shipping Agent Code" <> xSalesInvoiceHeader."Shipping Agent Code") or
          (SalesInvoiceHeader."Package Tracking No." <> xSalesInvoiceHeader."Package Tracking No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Inv. Header - Edit", OnOnRunOnBeforeTestFieldNo, '', false, false)]
    local procedure SalesInvHeaderEdit_OnOnRunOnBeforeTestFieldNo(var SalesInvoiceHeader: Record "Sales Invoice Header"; SalesInvoiceHeaderRec: Record "Sales Invoice Header")
    begin
        SalesInvoiceHeader."Shipping Agent Code" := SalesInvoiceHeaderRec."Shipping Agent Code";
        SalesInvoiceHeader."Package Tracking No." := SalesInvoiceHeaderRec."Package Tracking No.";
    end;

    //Update Posted Purchase Invoice
    [EventSubscriber(ObjectType::Page, Page::"Posted Purch. Invoice - Update", OnAfterRecordChanged, '', false, false)]
    local procedure PurchaseInvHeaderEdit_OnAfterRecordChanged(var PurchInvHeader: Record "Purch. Inv. Header"; xPurchInvHeader: Record "Purch. Inv. Header"; var IsChanged: Boolean; xPurchInvHeaderGlobal: Record "Purch. Inv. Header")
    begin
        IsChanged := IsChanged or (PurchInvHeader."CSB Shipping Agent Code" <> xPurchInvHeaderGlobal."CSB Shipping Agent Code") or
          (PurchInvHeader."CSB Package Tracking No." <> xPurchInvHeaderGlobal."CSB Package Tracking No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Inv. Header - Edit", OnBeforePurchInvHeaderModify, '', false, false)]
    local procedure PurchInvHeaderEdit_OnBeforePurchInvHeaderModify(var PurchInvHeader: Record "Purch. Inv. Header"; PurchInvHeaderRec: Record "Purch. Inv. Header")
    begin
        PurchInvHeader."CSB Shipping Agent Code" := PurchInvHeaderRec."CSB Shipping Agent Code";
        PurchInvHeader."CSB Package Tracking No." := PurchInvHeaderRec."CSB Package Tracking No.";
    end;

    //Purchase Line
    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnAfterValidateEvent, "No.", false, false)]
    local procedure PurchaseLine_OnAfterValidateNo(var Rec: Record "Purchase Line"; xRec: Record "Purchase Line")
    begin
        Rec.SetItemGTIN();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeInsertEvent, '', false, false)]
    local procedure PurchaseLine_OnBeforeInsertEvent(var Rec: Record "Purchase Line")
    var
        GLEntry: Record "G/L Entry";
    begin
        if Rec.IsTemporary then exit;

        Rec.RecalculateLineTotals();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeModifyEvent, '', false, false)]
    local procedure PurchaseLine_OnBeforeModify(var Rec: Record "Purchase Line")
    var
        GLEntry: Record "G/L Entry";
    begin
        if Rec.IsTemporary then exit;

        Rec.RecalculateLineTotals();
    end;

    //Sales Header
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeInsertEvent, '', false, false)]
    local procedure SalesHeader_OnBeforeInsertEvent(var Rec: Record "Sales Header")
    var
        CSBGeneraalSetup: Record "CSB General Setup";
    begin
        if Rec.IsTemporary then exit;
        CSBGeneraalSetup.Get();

        if Rec."Document Type" = Rec."Document Type"::Order then begin
            Rec."CSB Delete After Posting" := CSBGeneraalSetup."CSB Delete After Posting";

            Rec."CSB Retail" := false;
            if CSBGeneraalSetup."CSB Retail Customer No." <> '' then
                if Rec."Sell-to Customer No." = CSBGeneraalSetup."CSB Retail Customer No." then
                    Rec."CSB Retail" := true;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeModifyEvent, '', false, false)]
    local procedure SalesHeader_OnBeforeModifyEvent(var Rec: Record "Sales Header"; var xRec: Record "Sales Header")
    var
        CSBGeneraalSetup: Record "CSB General Setup";
    begin
        if Rec.IsTemporary then exit;
        CSBGeneraalSetup.Get();

        if Rec."Document Type" = Rec."Document Type"::Order then begin
            if CSBGeneraalSetup."CSB Retail Customer No." <> '' then
                if Rec."Sell-to Customer No." <> xRec."Sell-to Customer No." then
                    if Rec."Sell-to Customer No." = CSBGeneraalSetup."CSB Retail Customer No." then
                        Rec."CSB Retail" := true;
        end;
    end;

    //Sales Line
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterValidateEvent, "No.", false, false)]
    local procedure SalesLine_OnAfterValidateNo(var Rec: Record "Sales Line"; xRec: Record "Sales Line")
    begin
        Rec.SetItemGTIN();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeInsertEvent, '', false, false)]
    local procedure SalesLine_OnBeforeInsertEvent(var Rec: Record "Sales Line")
    var
        GLEntry: Record "G/L Entry";
    begin
        if Rec.IsTemporary then exit;

        Rec."CSB Total to Ship Excl. Tax" := 0;
        if (Rec.Quantity <> 0) and (Rec."Qty. to Ship" + Rec."Quantity Shipped" <> 0) then
            Rec."CSB Total to Ship Excl. Tax" := Rec."Line Amount" * (Rec."Qty. to Ship" + Rec."Quantity Shipped") / Rec.Quantity;

        Rec."CSB Line Gross Weight" := Rec."Gross Weight" * Rec."Qty. to Ship";

        if Rec."CSB Original Quantity" = 0 then
            Rec."CSB Original Quantity" := Rec.Quantity;

        Rec.RecalculateLineTotals();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeModifyEvent, '', false, false)]
    local procedure SalesLine_OnBeforeModify(var Rec: Record "Sales Line"; var xRec: Record "Sales Line")
    var
        GLEntry: Record "G/L Entry";
    begin
        if Rec.IsTemporary then exit;

        Rec."CSB Total to Ship Excl. Tax" := 0;
        if (Rec.Quantity <> 0) and (Rec."Qty. to Ship" + Rec."Quantity Shipped" <> 0) then
            Rec."CSB Total to Ship Excl. Tax" := Rec."Line Amount" * (Rec."Qty. to Ship" + Rec."Quantity Shipped") / Rec.Quantity;

        Rec."CSB Line Gross Weight" := Rec."Gross Weight" * Rec."Qty. to Ship";

        if Rec.Quantity <> xRec.Quantity then
            if Rec."CSB Original Quantity" = 0 then
                Rec."CSB Original Quantity" := Rec.Quantity;

        Rec.RecalculateLineTotals();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnValidateLineDiscountPercentOnBeforeUpdateAmounts, '', false, false)]
    local procedure SalesLine_OnValidateLineDiscountPercentOnBeforeUpdateAmounts(var SalesLine: Record "Sales Line"; CurrFieldNo: Integer)
    var
        Currency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        if SalesLine."Currency Code" = '' then begin
            if not Currency.Get(GeneralLedgerSetup."LCY Code") then
                Currency."Amount Rounding Precision" := 0.01;
        end else
            Currency.Get(SalesLine."Currency Code");

        SalesLine."Line Discount Amount" := Round(SalesLine."Unit Price", Currency."Amount Rounding Precision")
                        * SalesLine."Line Discount %" / 100;

        SalesLine."Line Discount Amount" :=
        Round(Round(SalesLine."Unit Price", Currency."Amount Rounding Precision")
                * SalesLine."Line Discount %" / 100, Currency."Amount Rounding Precision", '=') * SalesLine.Quantity;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterUpdateLineDiscPct, '', false, false)]
    local procedure SalesLine_OnAfterUpdateLineDiscPct(var SalesLine: Record "Sales Line")
    var
        Currency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        if SalesLine."Currency Code" = '' then begin
            if not Currency.Get(GeneralLedgerSetup."LCY Code") then
                Currency."Amount Rounding Precision" := 0.01;
        end else
            Currency.Get(SalesLine."Currency Code");

        SalesLine."Line Discount %" := SalesLine."Line Discount Amount" / SalesLine.Quantity * 100 / Round(SalesLine."Unit Price", Currency."Amount Rounding Precision");

        SalesLine."Line Discount Amount" :=
             Round(Round(SalesLine."Unit Price", Currency."Amount Rounding Precision")
                     * SalesLine."Line Discount %" / 100, Currency."Amount Rounding Precision", '=') * SalesLine.Quantity;
    end;

    //G/L Register
    [EventSubscriber(ObjectType::Table, Database::"G/L Register", OnBeforeInsertEvent, '', false, false)]
    local procedure GLRegister_OnBeforeInsert(var Rec: Record "G/L Register")
    var
        GLEntry: Record "G/L Entry";
    begin
        if Rec.IsTemporary then exit;

        GLEntry.SetRange("Entry No.", Rec."From Entry No.", Rec."To Entry No.");
        GLEntry.SetFilter(Amount, '>0');
        if not GLEntry.FindFirst() then
            exit;

        GLEntry.CalcSums(Amount);
        Rec."CSB Total Batch Amount" := GLEntry.Amount;
    end;

    [EventSubscriber(ObjectType::Table, Database::"G/L Register", OnBeforeModifyEvent, '', false, false)]
    local procedure GLRegister_OnBeforeModify(var Rec: Record "G/L Register")
    var
        GLEntry: Record "G/L Entry";
    begin
        if Rec.IsTemporary then exit;

        GLEntry.SetRange("Entry No.", Rec."From Entry No.", Rec."To Entry No.");
        GLEntry.SetFilter(Amount, '>0');
        if not GLEntry.FindFirst() then
            exit;

        GLEntry.CalcSums(Amount);
        Rec."CSB Total Batch Amount" := GLEntry.Amount;
    end;

    //Purch.-Post
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnBeforePurchRcptHeaderInsert, '', false, false)]
    local procedure PurchPost_OnBeforePurchRcptHeaderInsert(var PurchRcptHeader: Record "Purch. Rcpt. Header"; var PurchaseHeader: Record "Purchase Header"; CommitIsSupressed: Boolean; WarehouseReceiptHeader: Record "Warehouse Receipt Header"; WhseReceive: Boolean; WarehouseShipmentHeader: Record "Warehouse Shipment Header"; WhseShip: Boolean)

    begin
        PurchRcptHeader."CSB Vendor Invoice No." := PurchaseHeader."Vendor Invoice No.";
    end;

    //Item Jnl.-Post
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post", OnBeforeCode, '', false, false)]
    local procedure ItemJnlPost_OnBeforeCode(var ItemJournalLine: Record "Item Journal Line"; var HideDialog: Boolean; var SuppressCommit: Boolean; var IsHandled: Boolean)
    var
        CSBGeneralSetup: Record "CSB General Setup";
    begin
        if CSBGeneralSetup.Get() then
            if ItemJournalLine."Item No." = CSBGeneralSetup."CSB Retail Item No." then
                HideDialog := true;
    end;

}