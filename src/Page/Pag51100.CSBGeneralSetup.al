page 51100 "CSB General Setup"
{
    ApplicationArea = All;
    Caption = 'CSB General Setup';
    PageType = Card;
    SourceTable = "CSB General Setup";
    UsageCategory = Documents;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(Posting)
            {
                Caption = 'Posting';
                field("Primary Key"; Rec."Primary Key") { Visible = false; Editable = false; }
                field("Overwrite SO Posting Date"; Rec."Overwrite Sales Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Overwrite Sales Posting Date field.';
                }
                field("CSB Delete SO After Posting"; Rec."CSB Delete After Posting")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the CSB Delete SO After Posting field.';
                }
            }
            group(Reporting)
            {
                Caption = 'Reporting';
                field("Freight G/L Account"; Rec."Freight G/L Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Freight G/L Account field.';
                }
            }
            group(Retail)
            {
                Caption = 'Retail';
                field("CSB Retail Jnl. Template Name"; Rec."CSB Retail Jnl. Template Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the CSB Retail Jnl. Template Name field.';
                }
                field("CSB Retail Jnl. Batch Name"; Rec."CSB Retail Jnl. Batch Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the CSB Retail Jnl. Batch Name field.';
                }
                field("CSB Retail Customer No."; Rec."CSB Retail Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the CSB Retail Customer No. field.';
                }
                field("CSB Retail Item No."; Rec."CSB Retail Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the CSB Retail Item No. field.';
                }
            }
        }
    }


    trigger OnOpenPage()
    begin
        if not Rec.IsEmpty then exit;

        Rec.Insert();
    end;
}
