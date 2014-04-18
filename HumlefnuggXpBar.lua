HFXB = {}
HFXB.defaults = {
  width = 1500,
}

HFXB.xpColour = { 0.31, 0.05, 0.51, 1 };
HFXB.vpColour = { 0.48, 0.69, 0.55, 1 };
HFXB.currentXp = 0;

local LAM = LibStub:GetLibrary("LibAddonMenu-1.0")

function HFXB.init(eventCode, addOnName)
  if addOnName ~= "HumlefnuggXpBar" then return end

  HFXB.vars = ZO_SavedVars:New("HFXBSettings", 2, nil, HFXB.defaults)
  HFXB.setupGainAnimationTimeline()
  HFXBFrametext:SetFont("EsoUI/Common/Fonts/univers57.otf|14|soft-shadow-thick")

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

function HFXB.setupGainAnimationTimeline()
  local timeline = ANIMATION_MANAGER:CreateTimeline()
  local anim = timeline:InsertAnimation(ANIMATION_ALPHA, HFXBFramegain, 0)
  anim:SetDuration(10000)
  anim:SetEasingFunction(ZO_BezierInEase)
  anim:SetAlphaValues(1, 0)
  HFXB.gainAnimation = timeline
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

function HFXB.showStatText()
  HFXBFrametext:SetHidden(false)
end

function HFXB.hideStatText()
  HFXBFrametext:SetHidden(true)
end

function HFXB.getCurrentXp()
  return IsUnitVeteran('player') and GetUnitVeteranPoints('player') or GetUnitXP('player')
end

function HFXB.getMaxXp()
  return IsUnitVeteran('player') and GetUnitVeteranPointsMax('player') or GetUnitXPMax('player')
end

function HFXB.getBarColour()
  return IsUnitVeteran('player') and HFXB.vpColour or HFXB.xpColour
end

function HFXB.displayGainAnimation(from, to)

end

function HFXB.gain(current, max)
  local newXp = HFXB.getCurrentXp() / HFXB.getMaxXp()

  HFXBFramebar:SetDimensions(HFXBFrame:GetWidth() * newXp, HFXBFrame:GetHeight())
  HFXBFramebar:SetColor(unpack(HFXB.getBarColour()))
  HFXBFrametext:SetText(string.format("%d/%d (%d%%)", HFXB.getCurrentXp(), HFXB.getMaxXp(), newXp * 100))

  if newXp > HFXB.currentXp then
    local gainWidth = HFXBFrame:GetWidth() * (newXp - HFXB.currentXp)
    local offset = HFXBFrame:GetWidth() * HFXB.currentXp
    if gainWidth < 1 then 
      gainWidth = 1
      offset = offset - 1
    end
    HFXBFramegain:SetDimensions(gainWidth, HFXBFrame:GetHeight())
    HFXBFramegain:SetSimpleAnchorParent(offset, 0)
    if HFXB.gainAnimation ~= nil then
      HFXB.gainAnimation:Stop()
      HFXB.gainAnimation:PlayFromStart()
    end
  end

  HFXB.currentXp = newXp
end

EVENT_MANAGER:RegisterForEvent("HFXB", EVENT_ADD_ON_LOADED, HFXB.init)
EVENT_MANAGER:RegisterForEvent("HFXB", EVENT_EXPERIENCE_UPDATE, HFXB.gain)
EVENT_MANAGER:RegisterForEvent("HFXB", EVENT_VETERAN_POINTS_UPDATE, HFXB.gain)