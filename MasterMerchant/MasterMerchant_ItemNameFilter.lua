local internal       = _G["LibGuildStore_Internal"]
local filter_items_data = _G["LibGuildStore_FilteredItemsData"]
local LMP                               = LibMediaProvider

IFScrollList           = ZO_SortFilterList:Subclass()
IFScrollList.defaults  = { }
-- Sort keys for the scroll lists
IFScrollList.SORT_KEYS = {
  ['name'] = { isNumeric = false, tiebreaker = "name" },
}
ITEM_DATA = 1

function IFScrollList:BuildMasterList()
  self.masterList = {}
  for name, link in pairs(filter_items_data) do
    table.insert(self.masterList, { itemName = name, itemLink = link })
  end
  local listControl = self:GetListControl()
  ZO_ScrollList_Clear(listControl)
  local scrollDataList = ZO_ScrollList_GetDataList(listControl)
  for i, itemData in ipairs(self.masterList) do
      table.insert(scrollDataList, ZO_ScrollList_CreateDataEntry(ITEM_DATA, itemData))
  end
end

function IFScrollList:SortScrollList()
  if self.currentSortKey == 'name' then
    MasterMerchant:SortByName(self.currentSortOrder, self)
  else
    internal:dm("Warn", "Shit Hit the fan IFScrollList:SortScrollList")
    internal:dm("Warn", self.currentSortKey)
  end
end

function IFScrollList:SetupNameFiltersRow(control, data)
  control.icon         = GetControl(control, GetString(MM_ITEM_ICON_COLUMN))
  control.itemName     = GetControl(control, GetString(MM_ITEMNAME_COLUMN))

  local fontString = LMP:Fetch('font', MasterMerchant.systemSavedVariables.windowFont) .. '|%d'
  control.itemName:SetFont(string.format(fontString, 15))

  local itemName = data.itemName
  local itemLink = internal:GetStringByIndex(internal.GS_CHECK_ITEMLINK, data.itemLink)
  local itemIcon = GetItemLinkInfo(itemLink)

  -- Draw itemIcon
  control.icon:SetHidden(false)
  control.icon:SetTexture(itemIcon)

  -- Draw itemName
  control.itemName:SetHidden(false)
  control.itemName:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
  control.itemName:SetFont(string.format(fontString, 15))
  control.itemName:SetText(zo_strformat('<<t:1>>', itemLink))
end

function IFScrollList:InitializeDataType(controlName)
  self.masterList = {}
  if controlName == 'MasterMerchantFilterByNameWindow' then
    ZO_ScrollList_AddDataType(self.list, 1, 'MasterMerchantFilterByNameDataRow', 36,
      function(control, data) self:SetupNameFiltersRow(control, data) end)
  else
    internal:dm("Warn", "Shit Hit the fan IFScrollList:InitializeDataType")
    internal:dm("Warn", controlName)
  end
  self:RefreshData()
end

function IFScrollList:New(control)
  local skList = ZO_SortFilterList.New(self, control)
  skList:InitializeDataType(control:GetName())
  if control:GetName() == 'MasterMerchantFilterByNameWindow' then
    skList.sortHeaderGroup:SelectHeaderByKey('name')
    ZO_SortHeader_OnMouseExit(MasterMerchantFilterByNameWindowHeadersItemName)
  else
    internal:dm("Warn", "Shit Hit the fan IFScrollList:New")
    internal:dm("Warn", control:GetName())
  end

  ZO_PostHook(skList, 'RefreshData', function()
    local texCon = skList.list.scrollbar:GetThumbTextureControl()
    if texCon:GetHeight() < 10 then skList.list.scrollbar:SetThumbTextureHeight(10) end
  end)

  return skList
end

function MasterMerchant:AddToFilterTable(itemLink)
  local itemName = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink))
  local linkHash   = internal:AddSalesTableData("itemLink", itemLink)

  if not filter_items_data[itemName] then
    filter_items_data[itemName] = linkHash
    GS17DataSavedVariables[internal.nameFilterNamespace][itemName] = linkHash
  end
  MasterMerchant.nameFilterScrollList:RefreshData()
end
