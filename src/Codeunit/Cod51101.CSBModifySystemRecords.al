codeunit 51101 "CSB Modify System Records"
{
    Permissions = TableData "G/L Register" = rm
                , TableData "Purch. Rcpt. Header" = rm;

    procedure ModifyGLRegister(var GLRegister: Record "G/L Register")
    begin
        GLRegister.Modify();
    end;

    procedure ModifyPurchRcptHeader(var PurchRcptHeader: Record "Purch. Rcpt. Header")
    begin
        PurchRcptHeader.Modify();
    end;
}
