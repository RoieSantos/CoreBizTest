/// <summary>
/// Unknown CTA_StdSalesInvoice (ID 50100) extends Record Standard Sales - Invoice.
/// </summary>
reportextension 50100 "CTA_StdSalesInvoiceext" extends "Standard Sales - Invoice"
{
    RDLCLayout = 'src/reportextension/layout/CTA_StandardSalesInvoice.rdlc';
    WordLayout = 'src/reportextension/layout/CTA_StandardSalesInvoice.docx';
    dataset
    {
        add(Line)
        {
            column(AttributeValues; "Attribute Values")
            {
                IncludeCaption = true;
            }
        }
    }
}
