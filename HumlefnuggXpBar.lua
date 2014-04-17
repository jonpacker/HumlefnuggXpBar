HFXB = {}
HFXB.defaults = {
  width = 1500,
}

local LAM = LibStub:GetLibrary("LibAddonMenu-1.0")

function HFXB.init(eventCode, addOnName)
  if addOnName ~= "HumlefnuggXpBar" then return end

  HFXB.vars = ZO_SavedVars:New("HFXBSettings", 2, nil, HFXB.defaults)

  -- config menu
  panel = LAM:CreateControlPanel("HFXBConfig", "Humlefnugg XP")
  LAM:AddSlider(panel, "HFXB.width", "Width", "Width of the bar", 400, 2000, 1,
      function() return HFXB.vars.width end,
      function(val) HFXB.vars.width = val; HFXB.updateSettings() end)

  for i = 1, 20 do 
    local bubble = CreateControlFromVirtual("HFXBBubble", HFXBFrame, "HFXBBubble", i)
  end

  HFXB.updateSettings()
  HFXB.gain()
end

function HFXB.updateSettings()
  if HFXB.vars.offsetX ~= nil and HFXB.vars.offsetY ~= nil then
    HFXBFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, HFXB.vars.offsetX, HFXB.vars.offsetY)
  end

  HFXBFrame:SetWidth(HFXB.vars.width)

  for i = 1, 20 do
    local bubble = _G["HFXBBubble"..i]
    bubble:SetWidth(HFXB.vars.width / 20)
    bubble:SetSimpleAnchorParent((i - 1) * (HFXB.vars.width / 20), 0)
  end
end

function HFXB.saveFramePosition()
  HFXB.vars.offsetX = HFXBFrame:GetLeft()
  HFXB.vars.offsetY = HFXBFrame:GetTop()
end

function HFXB.getCurrentXp()
  return IsUnitVeteran('player') and GetUnitVeteranPoints('player') or GetUnitXP('player')
end

function HFXB.getMaxXp()
  return IsUnitVeteran('player') and GetUnitVeteranPointsMax('player') or GetUnitXPMax('player')
end

function HFXB.gain(current, max)
  HFXBFramebar:SetDimensions(HFXBFrame:GetWidth() * (HFXB.getCurrentXp() / HFXB.getMaxXp()), HFXBFrame:GetHeight())
end

EVENT_MANAGER:RegisterForEvent("HFXB", EVENT_ADD_ON_LOADED, HFXB.init)
EVENT_MANAGER:RegisterForEvent("HFXB", EVENT_EXPERIENCE_UPDATE, HFXB.gain)
EVENT_MANAGER:RegisterForEvent("HFXB", EVENT_VETERAN_POINTS_UPDATE, HFXB.gain)