table 51103 "CSB General Setup"
{
    Caption = 'CSB General Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Overwrite Sales Posting Date"; Boolean)
        {
            Caption = 'Overwrite Sales Posting Date';
            DataClassification = CustomerContent;
        }
        field(3; "Freight G/L Account"; Code[20])
        {
            Caption = 'Freight G/L Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(4; "CSB Delete After Posting"; Boolean)
        {
            Caption = 'CSB Delete SO After Posting';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(5; "CSB Retail Jnl. Template Name"; Code[20])
        {
            Caption = 'CSB Retail Jnl. Template Name';
            DataClassification = CustomerContent;
            TableRelation = "Item Journal Template";

            trigger OnValidate()
            begin
                Rec."CSB Retail Jnl. Batch Name" := '';
            end;
        }
        field(6; "CSB Retail Jnl. Batch Name"; Code[20])
        {
            Caption = 'CSB Retail Jnl. Batch Name';
            DataClassification = CustomerContent;
            TableRelation = "Item Journal Batch".Name where("Journal Template Name" = field("CSB Retail Jnl. Template Name"));
        }
        field(7; "CSB Retail Item No."; Code[20])
        {
            Caption = 'CSB Retail Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(8; "CSB Retail Customer No."; Code[20])
        {
            Caption = 'CSB Retail Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }

    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

}
