/// <summary>
/// PageExtension CTA_ItemAttributeValueListext (ID 50100) extends Record Item Attribute Value List.
/// </summary>
pageextension 50100 "CTA_ItemAttribValueListext" extends "Item Attribute Value List"
{
    layout
    {
        addafter(Value)
        {
            field(CTA_Value; Rec.Value)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Value';
                ToolTip = 'Specifies the value of the item attribute.';

                trigger OnLookup(var Text: Text): Boolean
                var

                    LastValueIdSelected: Integer;
                begin
                    Clear(NoOfSelected);
                    Clear(CurrAttributeValueIds);
                    Clear(LastValueIdSelected);
                    if Rec."Attribute Type" = Rec."Attribute Type"::Option then begin
                        Rec.Value := CTAFunctions.OnLookupItemAttributeValue(Rec."Attribute ID", NoOfSelected, LastValueIdSelected, CurrAttributeValueIds, RelatedRecordCode);

                    end;
                end;

                trigger OnValidate()
                var
                    ItemAttValue: Record "Item Attribute Value";

                    ItemAttValueMap: Record "Item Attribute Value Mapping";
                    ItemAttribute: Record "Item Attribute";
                begin
                    if ItemAttribute.Type = ItemAttribute.Type::Option then
                        exit;
                    if not Rec.FindAttributeValue(ItemAttributeValue) then
                        Rec.InsertItemAttributeValue(ItemAttValue, Rec);

                    CTAFunctions.StoreItemAttValueID(RelatedRecordCode, Rec."Attribute ID", Rec, xRec);
                end;
            }
        }
        modify(Value)
        {
            Visible = false;
        }
    }
    var

        ItemAttributeValue: Record "Item Attribute Value";
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        NoOfSelected: Integer;
        CurrAttributeValueIds: Text[250];
        CTAFunctions: Codeunit CTA_Functions_MGMT;


}
