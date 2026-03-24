tableextension 51109 "CSB Purch. Rcpt. Header" extends "Purch. Rcpt. Header" //120
{
    fields
    {
        field(51100; "CSB Vendor Invoice No."; Code[35])
        {
            DataClassification = CustomerContent;
            Caption = 'CSB Vendor Invoice No.';
        }
        field(51101; "CSB Cost Amount (Expected)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("Value Entry"."Cost Amount (Expected)" where("Document Type" = const("Purchase Receipt")
                                                                         , "Document No." = field("No.")));
            Caption = 'CSB Cost Amount (Expected)';
            Editable = false;
            FieldClass = FlowField;
        }
    }
}
