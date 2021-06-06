local internal = _G["LibGuildStore_Internal"]

-- A simple utility function to return which set of settings are active,
-- based on the allSettingsAccount option setting.
function MasterMerchant:ActiveSettings()
  return MasterMerchant.systemSavedVariables
end

-- alias for previous function
function MasterMerchant.makeIndexFromLink(itemLink)
  return internal.GetOrCreateIndexFromLink(itemLink)
end

function MasterMerchant:TimeCheck()
  --[[
  this does nothing because LibPrice has no idea what MM
  is doing. Don't mess with it or I'll make it local.
  ]]--
end

function MasterMerchant:itemPriceTip(itemLink, chatText, clickable)

  local tipStats = MasterMerchant:itemStats(itemLink, false)
  if tipStats.avgPrice then

    local tipFormat
    if tipStats['numDays'] < 2 then
      tipFormat = GetString(MM_TIP_FORMAT_SINGLE)
    else
      tipFormat = GetString(MM_TIP_FORMAT_MULTI)
    end

    local avePriceString = self.LocalizedNumber(tipStats['avgPrice'])
    tipFormat            = string.gsub(tipFormat, '.2f', 's')
    tipFormat            = string.gsub(tipFormat, 'M.M.', 'MM')
    -- chatText
    if not chatText then tipFormat = tipFormat .. '|t16:16:EsoUI/Art/currency/currency_gold.dds|t' end
    local salesString = zo_strformat(GetString(SK_PRICETIP_SALES), tipStats['numSales'])
    if tipStats['numSales'] ~= tipStats['numItems'] then
      salesString = salesString .. zo_strformat(GetString(MM_PRICETIP_ITEMS), tipStats['numItems'])
    end
    return string.format(tipFormat, salesString, tipStats['numDays'],
      avePriceString), tipStats['avgPrice'], tipStats['graphInfo']
    --return string.format(tipFormat, zo_strformat(GetString(SK_PRICETIP_SALES), tipStats['numSales']), tipStats['numDays'], tipStats['avgPrice']), tipStats['avgPrice'], tipStats['graphInfo']
  else
    return nil, tipStats['numDays'], nil
  end
end

function MasterMerchant:itemStats(itemLink, clickable)
  local itemID    = GetItemLinkItemId(itemLink)
  local itemIndex = internal.GetOrCreateIndexFromLink(itemLink)
  return MasterMerchant:toolTipStats(itemID, itemIndex, true, true)
end
