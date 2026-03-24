report 51104 "CSB Create Payments"
{
    Caption = 'CSB Create Payments';
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Params)
                {
                    ShowCaption = false;
                    field("Template Name"; JnlTemplateName)
                    {
                        ApplicationArea = All;
                        Caption = 'Template Name';
                        ShowMandatory = true;
                        TableRelation = "Gen. Journal Template".Name where(Type = const(Payments));
                        ToolTip = 'Specifies the name of the journal template.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            GenJnlTemplate: Record "Gen. Journal Template";
                            GeneralJournalTemplates: Page "General Journal Templates";
                        begin
                            GenJnlTemplate.FilterGroup(2);
                            GenJnlTemplate.SetRange(Type, GenJnlTemplate.Type::Payments);
                            GenJnlTemplate.FilterGroup(0);
                            GeneralJournalTemplates.SetTableView(GenJnlTemplate);
                            GeneralJournalTemplates.LookupMode := true;
                            if GeneralJournalTemplates.RunModal() = ACTION::LookupOK then begin
                                GeneralJournalTemplates.GetRecord(GenJnlTemplate);
                                JnlTemplateName := GenJnlTemplate.Name;
                            end;
                        end;
                    }
                    field("Batch Name"; JnlBatchName)
                    {
                        ApplicationArea = All;
                        Caption = 'Batch Name';
                        ShowMandatory = true;
                        TableRelation = "Gen. Journal Batch".Name where("Template Type" = const(Payments),
                                                                     Recurring = const(false));
                        ToolTip = 'Specifies the name of the journal batch.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            GenJournalBatch: Record "Gen. Journal Batch";
                            GeneralJournalBatches: Page "General Journal Batches";
                        begin
                            GenJournalBatch.FilterGroup(2);
                            GenJournalBatch.SetRange("Journal Template Name", JnlTemplateName);
                            GenJournalBatch.FilterGroup(0);

                            GeneralJournalBatches.SetTableView(GenJournalBatch);
                            GeneralJournalBatches.LookupMode := true;
                            if GeneralJournalBatches.RunModal() = ACTION::LookupOK then begin
                                GeneralJournalBatches.GetRecord(GenJournalBatch);
                                JnlBatchName := GenJournalBatch.Name;
                            end;
                        end;
                    }
                    field("Posting Date"; JnlPostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Posting Date';
                        ShowMandatory = true;
                        ToolTip = 'Specifies the entry''s posting date.';

                    }
                    field("Starting Document No."; JnlStartingDocumentNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Starting Document No.';
                        ShowMandatory = true;
                        ToolTip = 'Specifies a document number for the journal line.';
                    }
                    field("Bank Account"; JnlBankAccount)
                    {
                        ApplicationArea = All;
                        Caption = 'Bank Account';
                        TableRelation = "Bank Account";
                        ToolTip = 'Specifies the bank account to which a balancing entry for the journal line will be posted.';
                    }
                    field("Payment Type"; JnlBankPaymentType)
                    {
                        ApplicationArea = All;
                        Caption = 'Payment Type';
                        ToolTip = 'Specifies the code for the payment type to be used for the entry on the payment journal line.';
                    }
                }
            }
        }
    }

    trigger OnPostReport()
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlManagement: Codeunit GenJnlManagement;
    begin
        CreatePayments();

        GenJnlBatch.Reset();
        GenJnlBatch.SetRange("Journal Template Name", JnlTemplateName);
        GenJnlBatch.SetRange(Name, JnlBatchName);
        GenJnlBatch.FindFirst();

        GenJnlManagement.TemplateSelectionFromBatch(GenJnlBatch);
    end;

    trigger OnInitReport()
    begin
        JnlTemplateName := 'PAYMENT';
        JnlBatchName := 'CHECK';
        JnlPostingDate := WorkDate();
        JnlStartingDocumentNo := 'CSB00000';
        JnlBankAccount := 'CHASE PAYABLES';
        JnlBankPaymentType := JnlBankPaymentType::"Computer Check";
    end;

    procedure SetSourceRecord(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        if VendorLedgerEntry.FindSet() then
            repeat
                VendorLedgerEntry.TestField(Open, true);
                if (VendorLedgerEntry."Applies-to ID" <> '') or (VendorLedgerEntry."Applies-to Doc. No." <> '') then
                    Error(ErrCreatePayment, VendorLedgerEntry."Entry No.");

                TempVendorLedgerEntry := VendorLedgerEntry;
                TempVendorLedgerEntry.Insert();

                TempVendor."No." := VendorLedgerEntry."Vendor No.";
                if TempVendor.Insert() then;
            until VendorLedgerEntry.Next() = 0;
    end;

    local procedure CreatePayments()
    var
        GenJnlLine: Record "Gen. Journal Line";
        VendLedgerEntry: Record "Vendor Ledger Entry";
        RemitAddress: Record "Remit Address";
        TempVLE: Record "Vendor Ledger Entry" temporary;
        CSBPaymJnlVLEAppl: Page "CSB Paym. Jnl. VLE Appl.";
        LineNo: Integer;
    begin
        if JnlTemplateName = '' then Error(ErrInputParamIsMandatory, 'Template Name');
        if JnlBatchName = '' then Error(ErrInputParamIsMandatory, 'Batch Name');
        if JnlPostingDate = 0D then Error(ErrInputParamIsMandatory, 'Posting Date');
        if JnlStartingDocumentNo = '' then Error(ErrInputParamIsMandatory, 'Starting Document No.');

        GenJnlLine.SetRange("Journal Template Name", JnlTemplateName);
        GenJnlLine.SetRange("Journal Batch Name", JnlBatchName);
        if GenJnlLine.FindLast() then
            LineNo := GenJnlLine."Line No." + 10000;

        GenJnlLine.Reset();
        if TempVendor.FindSet() then
            repeat
                LineNo += 10000;
                JnlStartingDocumentNo := GetNextDocumentNo(JnlStartingDocumentNo);

                Clear(GenJnlLine);
                GenJnlLine.Validate("Journal Template Name", JnlTemplateName);
                GenJnlLine.Validate("Journal Batch Name", JnlBatchName);
                GenJnlLine."Line No." := LineNo;
                GenJnlLine.Validate("Posting Date", JnlPostingDate);
                GenJnlLine.Validate("Document Date", JnlPostingDate);
                GenJnlLine.Validate("Document Type", GenJnlLine."Document Type"::Payment);
                GenJnlLine.Validate("Document No.", JnlStartingDocumentNo);
                GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::Vendor);
                GenJnlLine.Validate("Account No.", TempVendor."No.");
                GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Bal. Account Type"::"Bank Account");
                GenJnlLine.Validate("Bal. Account No.", JnlBankAccount);
                GenJnlLine.Validate("Bank Payment Type", GenJnlLine."Bank Payment Type"::"Computer Check");
                GenJnlLine.Validate("Applies-to ID", JnlStartingDocumentNo);
                GenJnlLine.Validate("Transaction Type Code", GenJnlLine."Transaction Type Code"::BUS);
                RemitAddress.Reset();
                RemitAddress.SetRange("Vendor No.", TempVendor."No.");
                if RemitAddress.FindFirst() then
                    GenJnlLine.Validate("Remit-to Code", RemitAddress.Code);
                GenJnlLine.Insert(true);

                TempVendorLedgerEntry.SetRange("Vendor No.", TempVendor."No.");
                if TempVendorLedgerEntry.FindSet() then
                    repeat
                        VendLedgerEntry.Get(TempVendorLedgerEntry."Entry No.");
                        VendLedgerEntry."Applies-to Doc. Type" := VendLedgerEntry."Applies-to Doc. Type"::" ";
                        VendLedgerEntry."Applies-to ID" := JnlStartingDocumentNo;
                        VendLedgerEntry.CalcFields("Remaining Amount");
                        VendLedgerEntry."Amount to Apply" := VendLedgerEntry."Remaining Amount";
                        VendLedgerEntry."Remaining Pmt. Disc. Possible" := VendLedgerEntry."Original Pmt. Disc. Possible";
                        Codeunit.Run(Codeunit::"Vend. Entry-Edit", VendLedgerEntry);
                    until TempVendorLedgerEntry.Next() = 0;


                GenJnlLine.SetRange("Journal Template Name", JnlTemplateName);
                GenJnlLine.SetRange("Journal Batch Name", JnlBatchName);
                GenJnlLine.SetRange("Line No.", LineNo);

                Clear(CSBPaymJnlVLEAppl);
                CSBPaymJnlVLEAppl.SetParams(GenJnlLine);
                CSBPaymJnlVLEAppl.SetSourceRecord();
                CSBPaymJnlVLEAppl.CalcApplyToJnlLineAmt();
                CSBPaymJnlVLEAppl.GetSourceRecord(TempVLE);
                TempVLE.FindFirst();
                GenJnlLine.Validate(Amount, TempVLE."Closed by Amount");
                GenJnlLine.Modify();

            until TempVendor.Next() = 0;
    end;

    local procedure GetNextDocumentNo(DocumentNo: Text[20]): Text[20]
    var
        GenJnlLine: Record "Gen. Journal Line";
        I: Integer;
    begin
        if DocumentNo = 'CSB00000' then begin
            GenJnlLine.SetRange("Journal Template Name", JnlTemplateName);
            GenJnlLine.SetRange("Journal Batch Name", JnlBatchName);
            GenJnlLine.SetFilter("Document No.", 'CSB######');
            if GenJnlLine.FindLast() then
                DocumentNo := GenJnlLine."Document No.";
        end;

        for I := 0 to 100 do begin
            DocumentNo := IncStr(DocumentNo);
            GenJnlLine.SetRange("Journal Template Name", JnlTemplateName);
            GenJnlLine.SetRange("Journal Batch Name", JnlBatchName);
            GenJnlLine.SetRange("Document No.", DocumentNo);
            if not GenJnlLine.FindFirst() then
                exit(DocumentNo);
        end;
        exit(DocumentNo);
    end;

    procedure GetParams(GenJnlBatch: Record "Gen. Journal Batch")
    begin
        GenJnlBatch.Reset();
        GenJnlBatch.SetRange("Journal Template Name", JnlTemplateName);
        GenJnlBatch.SetRange(Name, JnlBatchName);
    end;

    var
        TempVendorLedgerEntry: Record "Vendor Ledger Entry" temporary;
        TempVendor: Record Vendor temporary;
        JnlTemplateName: Code[20];
        JnlBatchName: Code[20];
        JnlPostingDate: Date;
        JnlStartingDocumentNo: Text[20];
        JnlBankAccount: Code[20];
        JnlBankPaymentType: Enum "Bank Payment Type";
        ErrInputParamIsMandatory: Label 'Input  param %1 is mandatory!';
        ErrCreatePayment: Label 'A payment application process is in progress for the selected entry no. %1. Make sure you have not applied this entry in ongoing journals or payment reconciliation journals.', Comment = '%1 Entry No.';

}
