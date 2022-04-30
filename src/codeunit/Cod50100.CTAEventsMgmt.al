/// <summary>
/// Codeunit CTA_Events_MGMT (ID 50100).
/// </summary>
codeunit 50100 "CTA_Events_MGMT"
{
    var
        CTAFunctions: Codeunit CTA_Functions_MGMT;




    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesInvLineInsert', '', false, false)]
    local procedure OnBeforeSalesInvLineInsert_CduSalesPost(var SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header"; SalesLine: Record "Sales Line"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; PostingSalesLine: Record "Sales Line")
    var
        ItemAttributeValueMap: Record "Item Attribute Value Mapping";
        ItemAttributeValue: Record "Item Attribute Value";
        AttributeValues: Text;
    begin
        if SalesLine.Type <> SalesLine.Type::Item then
            exit;
        ItemAttributeValueMap.SetRange("Table ID", DATABASE::Item);
        ItemAttributeValueMap.SetRange("No.", SalesLine."No.");
        if ItemAttributeValueMap.FindSet then
            repeat
                ItemAttributeValue.Get(ItemAttributeValueMap."Item Attribute ID", ItemAttributeValueMap."Item Attribute Value ID");
                ItemAttributeValue.CalcFields("Attribute Name");
                if ItemAttributeValueMap."Selected Attribute Value Ids" = '' then
                    AttributeValues += ItemAttributeValue."Attribute Name" + ' - ' + ItemAttributeValue.Value + '; '
                Else
                    AttributeValues += ItemAttributeValue."Attribute Name" + ' - ' + CTAFunctions.GetAttribValues(ItemAttributeValueMap) + '; ';
            until ItemAttributeValueMap.Next() = 0;
        SalesInvLine."Attribute Values" := AttributeValues.TrimEnd('; ');
    end;


    [EventSubscriber(ObjectType::Table, Database::"Item Attribute Value", 'OnLoadItemAttributesFactBoxDataOnBeforeInsert', '', false, false)]
    local procedure OnLoadItemAttributesFactBoxDataOnBeforeInsert_TableItemAttributeValue(var ItemAttributeValueMapping: Record "Item Attribute Value Mapping"; var ItemAttributeValue: Record "Item Attribute Value")
    begin
        if ItemAttributeValueMapping."Selected Attribute Value Ids" <> '' then
            ItemAttributeValue.Value := CTAFunctions.GetAttribValues(ItemAttributeValueMapping);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item Attribute Values", 'OnDeleteRecordEvent', '', false, false)]
    local procedure OnDeleteRecordEvent_PageItemAttributeValues_ModifyAttributeValueId(var Rec: Record "Item Attribute Value"; var AllowDelete: Boolean)
    var
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        NewValueIDs: Text[250];
    begin
        if (Rec.ID = 0) AND (NOT AllowDelete) then
            exit;

        Clear(NewValueIDs);
        ItemAttributeValueMapping.SetRange("Item Attribute ID", Rec."Attribute ID");
        ItemAttributeValueMapping.SetRange("Item Attribute Value ID", Rec.ID);
        IF ItemAttributeValueMapping.FindFirst() THEN
            if Format(Rec.ID) <> ItemAttributeValueMapping."Selected Attribute Value Ids" then begin
                ItemAttributeValueMapping."Item Attribute Value ID" := CTAFunctions.ReAssignAttributeValueID(ItemAttributeValueMapping, NewValueIDs);
                ItemAttributeValueMapping."Selected Attribute Value Ids" := NewValueIDs;
                if ItemAttributeValueMapping."Item Attribute Value ID" <> 0 then
                    ItemAttributeValueMapping.Modify();
            end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Item Attribute Value List", 'OnLoadAttributesOnBeforeTempItemAttributeValueInsert', '', false, false)]
    local procedure OnLoadAttributesOnBeforeTempItemAttributeValueInsert_PageItemAttValueList(var TempItemAttributeValue: Record "Item Attribute Value"; ItemAttributeValueMapping: Record "Item Attribute Value Mapping"; RelatedRecordCode: Code[20])
    begin
        if ItemAttributeValueMapping."Selected Attribute Value Ids" <> '' then
            TempItemAttributeValue.Value := CTAFunctions.GetAttribValues(ItemAttributeValueMapping);
    end;


}
