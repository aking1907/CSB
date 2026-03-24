page 51103 "CSB Purch. Rcpt. Header Modify"
{
    ApplicationArea = All;
    Caption = 'CSB Purch. Rcpt. Header Modify';
    PageType = Card;
    SourceTable = "Purch. Rcpt. Header";
    SourceTableTemporary = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("No."; Rec."No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the number of a general ledger account, item, additional cost, or fixed asset, depending on what you selected in the Type field.';
                }
                field("Order No."; Rec."Order No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the line number of the order that created the entry.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    Editable = false;
                    ToolTip = 'Specifies the posting date of the record.';
                }
                field("CSB Vendor Invoice No."; Rec."CSB Vendor Invoice No.")
                {
                    ToolTip = 'CSB Vendor Invoice No.';
                }
            }
        }
    }

    procedure SetSourceRecord(var PurchRcptHeader: Record "Purch. Rcpt. Header")
    begin
        Rec := PurchRcptHeader;
        Rec.Insert();
    end;

    procedure GetSourceRecord(var PurchRcptHeader: Record "Purch. Rcpt. Header")
    begin
        PurchRcptHeader := Rec;
    end;

    procedure UpdateValues()
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        CSBModifySystemRecordsCU: Codeunit "CSB Modify System Records";
    begin
        PurchRcptHeader.Get(Rec."No.");
        PurchRcptHeader."CSB Vendor Invoice No." := Rec."CSB Vendor Invoice No.";

        CSBModifySystemRecordsCU.ModifyPurchRcptHeader(PurchRcptHeader);
    end;

}
