table 51101 "CSB Order Status"
{
    Caption = 'Order Status';
    DataClassification = CustomerContent;
    LookupPageId = "CSB Order Status List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Type; Enum "CSB Order Status Type")
        {
            Caption = 'Type';
        }
    }
    keys
    {
        key(PK; "Type", "Code")
        {
            Clustered = true;
        }
    }
}
