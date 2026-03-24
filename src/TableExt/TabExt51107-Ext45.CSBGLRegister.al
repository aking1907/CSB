tableextension 51107 "CSB G/L Register" extends "G/L Register" //45
{
    fields
    {
        field(51100; "CSB Total Batch Amount"; Decimal)
        {
            Caption = 'CSB Total Batch Amount';
            DataClassification = CustomerContent;
        }
    }
}
