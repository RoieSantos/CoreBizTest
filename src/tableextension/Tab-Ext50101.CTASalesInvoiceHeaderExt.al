/// <summary>
/// TableExtension CTE_SalesInvoiceHeaderext (ID 50101) extends Record Sales Invoice Line.
/// </summary>
tableextension 50101 "CTE_SalesInvoiceHeaderext" extends "Sales Invoice Line"
{
    fields
    {
        field(50100; "Attribute Values"; Text[1024])
        {
            Caption = 'Attribute Values';
            DataClassification = CustomerContent;
        }
    }
}
