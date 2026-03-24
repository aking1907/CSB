page 51102 "CSB Order Status List"
{
    ApplicationArea = All;
    Caption = 'Order Status List';
    PageType = List;
    SourceTable = "CSB Order Status";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Type; Rec."Type")
                {
                    ToolTip = 'Specifies the value of the Type field.';
                }
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Code field.';
                    ShowMandatory = true;
                }
            }
        }
    }
}
