reportextension 51106 "CSB Pick Instruction" extends "Pick Instruction" //214
{
    dataset
    {
        add("Sales Header")
        {
            column(CSBShippingAgentCode; "Shipping Agent Code") { }
            column(CSBShippingAgentName; GetShippingAgentName("Shipping Agent Code")) { }
        }
        add("Sales Line")
        {
            column(CSBQtytoShip; "Qty. to Ship") { }
        }
    }

    rendering
    {
        layout(CSBDefaultRDLCLayout)
        {
            Type = RDLC;
            Caption = 'CSB Pick Instruction';
            Summary = 'CSB Pick Instruction';
            LayoutFile = './src/ReportExt/RDLC/RepExt51106-Ext214.CSBPickInstruction.rdlc';
        }
    }

    local procedure GetShippingAgentName(ShippingAgentCode: Code[20]): Text[50]
    var
        ShippingAgent: Record "Shipping Agent";
    begin
        if not ShippingAgent.Get(ShippingAgentCode) then
            exit('');

        exit(CopyStr(ShippingAgent.Name, 1, 50));
    end;
}