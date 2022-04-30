/// <summary>
/// Codeunit CTA_Functions_MGMT (ID 50101).
/// </summary>
codeunit 50101 "CTA_Functions_MGMT"
{
    trigger OnRun()
    begin

    end;

    /// <summary>
    /// OnLookupItemAttributeValue.
    /// </summary>
    /// <param name="pAttributeID">Integer.</param>
    /// <param name="pNoOfSelected">VAR Integer.</param>
    /// <param name="pLastValueIdSelected">Integer.</param>
    /// <param name="pSelectedAttributeValueIds">Text[250].</param>
    /// <param name="pItemNo">Code[20].</param>
    /// <returns>Return value of type Text[250].</returns>
    procedure OnLookupItemAttributeValue(pAttributeID: Integer; var pNoOfSelected: Integer; pLastValueIdSelected: Integer; var pSelectedAttributeValueIds: Text[250]; pItemNo: Code[20]): Text[250]
    var/// <param name="SelectedAttributeValueIds">Text[250].</param>

        ItemAttributeValue: Record "Item Attribute Value";
        PageItemAttributeValues: Page "Item Attribute Values";
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        CurrValue: Text[250];
    begin
        Clear(ItemAttributeValue);
        ItemAttributeValue.SetRange("Attribute ID", pAttributeID);
        ItemAttributeValue.SetRange(Blocked, false);

        Clear(PageItemAttributeValues);
        PageItemAttributeValues.SetTableView(ItemAttributeValue);
        PageItemAttributeValues.SetRecord(ItemAttributeValue);
        PageItemAttributeValues.LookupMode(true);
        if PageItemAttributeValues.RunModal = ACTION::LookupOK then begin
            PageItemAttributeValues.SetSelectionFilter(ItemAttributeValue);
            pNoOfSelected := ItemAttributeValue.Count;
            CurrValue := GetSelectedItemAttributeValues(ItemAttributeValue, pLastValueIdSelected, pSelectedAttributeValueIds, pNoOfSelected);


            ItemAttributeValueMapping.SetRange("Table ID", DATABASE::Item);
            ItemAttributeValueMapping.SetRange("No.", pItemNo);
            ItemAttributeValueMapping.SetRange("Item Attribute ID", pAttributeID);
            if ItemAttributeValueMapping.FindFirst then begin
                ItemAttributeValueMapping."Item Attribute Value ID" := pLastValueIdSelected;
                ItemAttributeValueMapping."Selected Attribute Value Ids" := pSelectedAttributeValueIds;
                ItemAttributeValueMapping.Modify();
            end;
            exit(CurrValue);
        end;
    end;

    local procedure GetSelectedItemAttributeValues(var pItemAttributeValue: Record "Item Attribute Value"; var LastValueIdSelected: Integer; var SelectedAttributeValueIds: Text; pNoOfSelected: Integer): Text[250]
    var
        i: Integer;
        AttributeValues: Text[250];
    begin
        Clear(AttributeValues);
        if pNoOfSelected = 1 then
            If pItemAttributeValue.FindFirst() then begin
                LastValueIdSelected := pItemAttributeValue.ID;
                SelectedAttributeValueIds := Format(LastValueIdSelected);
                AttributeValues := pItemAttributeValue.Value;
                Exit(AttributeValues);
            end;

        i := 0;
        if pItemAttributeValue.FindSet() then
            repeat
                i += 1;
                LastValueIdSelected := pItemAttributeValue.ID;
                SelectedAttributeValueIds += Format(pItemAttributeValue.ID) + '|';
                If i = pNoOfSelected then
                    AttributeValues := AttributeValues.TrimEnd(', ') + ' and ' + pItemAttributeValue.Value
                else
                    AttributeValues += pItemAttributeValue.Value + ', ';
            until pItemAttributeValue.Next() = 0;
        SelectedAttributeValueIds := SelectedAttributeValueIds.TrimEnd('|');
        Exit(AttributeValues);
    end;


    /// <summary>
    /// StoreItemAttValueID.
    /// </summary>
    /// <param name="pRelatedCode">Code[20].</param>
    /// <param name="pAttributeID">Integer.</param>
    /// <param name="pRec">Record "Item Attribute Value Selection".</param>
    /// <param name="pxRec">Record "Item Attribute Value Selection".</param>
    procedure StoreItemAttValueID(pRelatedCode: Code[20]; pAttributeID: Integer; pRec: Record "Item Attribute Value Selection"; pxRec: Record "Item Attribute Value Selection")
    var/// <param name="pxRec">Record "Item Attribute Value Selection".</param>

        ItemAttValue: Record "Item Attribute Value";
        ItemAttValueMap: Record "Item Attribute Value Mapping";
        ItemAttribute: Record "Item Attribute";
    begin


        ItemAttValueMap.SetRange("Table ID", DATABASE::Item);
        ItemAttValueMap.SetRange("No.", pRelatedCode);
        ItemAttValueMap.SetRange("Item Attribute ID", ItemAttValue."Attribute ID");
        if ItemAttValueMap.FindFirst then begin
            ItemAttValueMap."Item Attribute Value ID" := ItemAttValue.ID;
            ItemAttValueMap.Modify();
        end;

        ItemAttribute.Get(pAttributeID);
        if pRec.FindAttributeValueFromRecord(ItemAttValue, pxRec) then
            if not ItemAttValue.HasBeenUsed then
                ItemAttValue.Delete();
    end;
    /// <summary>
    /// ReAssignAttributeValueID.
    /// </summary>
    /// <param name="ItemAttValueMapping">Record "Item Attribute Value Mapping".</param>
    /// <param name="NewValueIDs">VAR Text[250].</param>
    /// <returns>Return value of type Integer.</returns>
    procedure ReAssignAttributeValueID(ItemAttValueMapping: Record "Item Attribute Value Mapping"; var NewValueIDs: Text[250]): Integer
    var
        ItemAttributeValue: Record "Item Attribute Value";
        NewItemAttributeValueId: Integer;
    begin
        ItemAttributeValue.Reset();
        ItemAttributeValue.SetRange("Attribute ID", ItemAttValueMapping."Item Attribute ID");
        ItemAttributeValue.SetFilter(ID, ItemAttValueMapping."Selected Attribute Value Ids");
        if ItemAttributeValue.FindSet() then
            repeat
                if ItemAttValueMapping."Item Attribute Value ID" <> ItemAttributeValue.ID then begin
                    NewItemAttributeValueId := ItemAttributeValue.ID;
                    NewValueIDs += Format(ItemAttributeValue.ID) + '|';
                end;
            until ItemAttributeValue.Next() = 0;
        NewValueIDs := NewValueIDs.TrimEnd('|');
        exit(NewItemAttributeValueId);
    end;


    /// <summary>
    /// GetAttribValues.
    /// </summary>
    /// <param name="ItemAttribValueMapping">VAR Record "Item Attribute Value Mapping".</param>
    /// <returns>Return value of type Text[250].</returns>
    procedure GetAttribValues(var ItemAttribValueMapping: Record "Item Attribute Value Mapping"): Text[250]
    var
        AttributeValues: Text[250];
        ItemAttribValue: Record "Item Attribute Value";
        RecordCount: Integer;
        i: Integer;
    begin
        Clear(AttributeValues);
        Clear(i);
        ItemAttribValue.Reset();
        ItemAttribValue.SetRange("Attribute ID", ItemAttribValueMapping."Item Attribute ID");
        ItemAttribValue.SetFilter(ID, ItemAttribValueMapping."Selected Attribute Value Ids");

        RecordCount := ItemAttribValue.Count;
        if RecordCount = 1 then
            If ItemAttribValue.FindFirst() then begin
                AttributeValues := ItemAttribValue.Value;
                Exit(AttributeValues);
            end;
        if ItemAttribValue.FindSet() then
            repeat
                i += 1;
                If i = RecordCount then
                    AttributeValues := AttributeValues.TrimEnd(', ') + ' and ' + ItemAttribValue.Value
                else
                    AttributeValues += ItemAttribValue.Value + ', ';
            until ItemAttribValue.Next() = 0;
        exit(AttributeValues);
    end;


    /// <summary>
    /// FindItemsByAttributes.
    /// </summary>
    /// <param name="FilterItemAttributesBuffer">VAR Record "Filter Item Attributes Buffer".</param>
    /// <param name="TempFilteredItem">Temporary VAR Record Item.</param>
    procedure FindItemsByAttributes(var FilterItemAttributesBuffer: Record "Filter Item Attributes Buffer"; var TempFilteredItem: Record Item temporary)
    var
        ItemAttribValueMapping: Record "Item Attribute Value Mapping";
        ItemAttribute: Record "Item Attribute";
        AttributeValueIDFilter: Text;
    begin
        if not FilterItemAttributesBuffer.FindSet then
            exit;

        ItemAttribValueMapping.SetRange("Table ID", DATABASE::Item);

        repeat
            ItemAttribute.SetRange(Name, FilterItemAttributesBuffer.Attribute);
            if ItemAttribute.FindFirst then begin
                ItemAttribValueMapping.SetRange("Item Attribute ID", ItemAttribute.ID);
                AttributeValueIDFilter := GetItemAttributeValueFilter(FilterItemAttributesBuffer, ItemAttribute);
                if AttributeValueIDFilter = '' then begin
                    TempFilteredItem.DeleteAll();
                    exit;
                end;

                GetFilteredItems(ItemAttribValueMapping, TempFilteredItem, AttributeValueIDFilter, ItemAttribute);
                if TempFilteredItem.IsEmpty() then
                    exit;
            end;
        until FilterItemAttributesBuffer.Next() = 0;
    end;

    local procedure GetFilteredItems(var ItemAttribValueMapping: Record "Item Attribute Value Mapping"; var TempFilteredItem: Record Item temporary; AttributeValueIDFilter: Text; var ItemAttribute: Record "Item Attribute")
    var
        Item: Record Item;
    begin
        if ItemAttribute.Type = ItemAttribute.Type::Option then
            ItemAttribValueMapping.SetFilter("Selected Attribute Value Ids", AttributeValueIDFilter)
        else
            ItemAttribValueMapping.SetFilter("Item Attribute Value ID", AttributeValueIDFilter);

        if ItemAttribValueMapping.IsEmpty() then begin
            TempFilteredItem.Reset();
            TempFilteredItem.DeleteAll();
            exit;
        end;

        if not TempFilteredItem.FindSet then begin
            if ItemAttribValueMapping.FindSet then
                repeat
                    Item.Get(ItemAttribValueMapping."No.");
                    TempFilteredItem.TransferFields(Item);
                    TempFilteredItem.Insert();
                until ItemAttribValueMapping.Next() = 0;
            exit;
        end;

        repeat
            ItemAttribValueMapping.SetRange("No.", TempFilteredItem."No.");
            if ItemAttribValueMapping.IsEmpty() then
                TempFilteredItem.Delete();
        until TempFilteredItem.Next() = 0;
        ItemAttribValueMapping.SetRange("No.");
    end;

    local procedure GetItemAttributeValueFilter(var FilterItemAttributesBuffer: Record "Filter Item Attributes Buffer"; var ItemAttribute: Record "Item Attribute") AttributeFilter: Text
    var
        ItemAttribValue: Record "Item Attribute Value";
    begin
        ItemAttribValue.SetRange("Attribute ID", ItemAttribute.ID);
        ItemAttribValue.SetValueFilter(ItemAttribute, FilterItemAttributesBuffer.Value);

        if not ItemAttribValue.FindSet then
            exit;

        repeat
            if ItemAttribute.Type = ItemAttribute.Type::Option then
                AttributeFilter += StrSubstNo('@*%1*|', ItemAttribValue.ID)
            else
                AttributeFilter += StrSubstNo('%1|', ItemAttribValue.ID);
        until ItemAttribValue.Next() = 0;

        exit(CopyStr(AttributeFilter, 1, StrLen(AttributeFilter) - 1));
    end;




}