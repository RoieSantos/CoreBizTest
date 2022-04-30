/// <summary>
/// PageExtension CTE_ItemListext (ID 50102) extends Record Item List.
/// </summary>
pageextension 50102 CTE_ItemListext extends "Item List"
{
    actions
    {
        modify(FilterByAttributes)
        {
            Visible = false;
        }
        addafter(FilterByAttributes)
        {
            action(FilterByAttributes1)
            {

                ApplicationArea = All;
                Caption = 'Filter by Attributes';
                ToolTip = 'Filter by Attributes';
                Image = Filter;
                Promoted = true;
                PromotedCategory = Category10;
                PromotedOnly = true;
                AccessByPermission = TableData "Item Attribute" = R;
                trigger OnAction()
                var
                    FilterPageID: Integer;
                    ParameterCount: Integer;
                    ItemAttributeMGMT: Codeunit "Item Attribute Management";
                    TypeHelper: Codeunit "Type Helper";
                    CloseAction: Action;
                    FilterText: Text;

                begin
                    FilterPageID := PAGE::"Filter Items by Attribute";
                    if ClientTypeManagement.GetCurrentClientType = CLIENTTYPE::Phone then
                        FilterPageID := PAGE::"Filter Items by Att. Phone";

                    CloseAction := PAGE.RunModal(FilterPageID, TempFilterItemAttributesBuffer);
                    if (ClientTypeManagement.GetCurrentClientType <> CLIENTTYPE::Phone) and (CloseAction <> ACTION::LookupOK) then
                        exit;

                    if TempFilterItemAttributesBuffer.IsEmpty() then begin
                        ClearAttributesFilter;
                        exit;
                    end;
                    TempItemFilteredFromAttrib.Reset();
                    TempItemFilteredFromAttrib.DeleteAll();
                    CTAFunctions.FindItemsByAttributes(TempFilterItemAttributesBuffer, TempItemFilteredFromAttrib);
                    FilterText := ItemAttributeMGMT.GetItemNoFilterText(TempItemFilteredFromAttrib, ParameterCount);

                    if ParameterCount < TypeHelper.GetMaxNumberOfParametersInSQLQuery - 100 then begin
                        Rec.FilterGroup(0);
                        Rec.MarkedOnly(false);
                        Rec.SetFilter("No.", FilterText);
                    end else begin
                        RunOnTempRec := true;
                        Rec.ClearMarks;
                        Rec.Reset;
                    end;
                end;
            }
        }
    }


    local procedure ClearAttributesFilter()
    begin
        Rec.ClearMarks;
        Rec.MarkedOnly(false);
        TempFilterItemAttributesBuffer.Reset();
        TempFilterItemAttributesBuffer.DeleteAll();
        Rec.FilterGroup(0);
        Rec.SetRange("No.");
    end;



    var
        ClientTypeManagement: Codeunit "Client Type Management";
        TempFilterItemAttributesBuffer: Record "Filter Item Attributes Buffer" temporary;
        TempItemFilteredFromAttrib: Record Item temporary;
        CTAFunctions: Codeunit CTA_Functions_MGMT;
}
