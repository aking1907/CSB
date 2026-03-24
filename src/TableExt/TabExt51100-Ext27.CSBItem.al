tableextension 51100 "CSB Item" extends Item //27
{
    fields
    {
        field(50100; "CSB Retail Price"; Decimal)
        {
            Caption = 'CSB Retail Price';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(50101; "CSB Salon Price"; Decimal)
        {
            Caption = 'CSB Salon Price';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
    }
}
