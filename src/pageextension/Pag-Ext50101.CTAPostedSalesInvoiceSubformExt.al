/// <summary>
/// PageExtension CTE_PostedSalesInvSubformext (ID 50101) extends Record Posted Sales Invoice Subform.
/// </summary>
pageextension 50101 "CTE_PostedSalesInvSubformext" extends "Posted Sales Invoice Subform"
{
    layout
    {
        addafter(Description)
        {
            field(AttributeValues; Rec."Attribute Values")
            {
                ToolTip = 'Attribute Values';
                ApplicationArea = All;
            }
        }
    }
}
