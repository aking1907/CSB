pageextension 51114 "CSB G/L Registers" extends "G/L Registers" //116
{
    layout
    {
        addafter("Journal Batch Name")
        {
            field("CSB Total Batch Amount"; Rec."CSB Total Batch Amount")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        addafter("Delete Empty Registers")
        {
            action(CSBRecalcBatchAmount)
            {
                Image = CalculateBalanceAccount;
                ApplicationArea = All;
                Caption = 'CSB Recalc. Batch Amount';
                ToolTip = 'CSB Recalc. Batch Amount.';

                trigger OnAction()
                var
                    GLEntry: Record "G/L Entry";
                    CSBModifySystemRecordsCU: Codeunit "CSB Modify System Records";
                begin
                    GLEntry.SetRange("Entry No.", Rec."From Entry No.", Rec."To Entry No.");
                    GLEntry.SetFilter(Amount, '>0');
                    if not GLEntry.FindFirst() then
                        exit;

                    GLEntry.CalcSums(Amount);
                    Rec."CSB Total Batch Amount" := GLEntry.Amount;
                    CSBModifySystemRecordsCU.ModifyGLRegister(Rec);
                end;
            }
        }
    }
}
