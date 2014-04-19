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
  HFXB.setupAnimationTimelines()
  HFXBFrametext:SetFont("EsoUI/Common/Fonts/univers55.otf|12|soft-shadow-thick")
  HFXBFramegainText:SetFont("EsoUI/Common/Fonts/univers55.otf|12|soft-shadow-thick")

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

function HFXB.setupAnimationTimelines()
  HFXB.setupGainTextAnimationTimeline()
  HFXB.setupGainAnimationTimeline()
end

function HFXB.setupGainTextAnimationTimeline()
  local timeline = ANIMATION_MANAGER:CreateTimeline()
  local anim = timeline:InsertAnimation(ANIMATION_ALPHA, HFXBFramegainText, 5000)
  anim:SetDuration(5000)
  anim:SetEasingFunction(ZO_BezierInEase)
  anim:SetAlphaValues(1, 0)
  HFXB.gainTextAnimation = timeline
end

function HFXB.setupGainAnimationTimeline()
  local timeline = ANIMATION_MANAGER:CreateTimeline()
  local anim = timeline:InsertAnimation(ANIMATION_ALPHA, HFXBFramegain, 5000)
  anim:SetDuration(5000)
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
  HFXB.gainTextAnimation:Stop()
  HFXBFramegainText:SetAlpha(0)
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

function HFXB.gain(current, max)
  local newXp = HFXB.getCurrentXp() / HFXB.getMaxXp()

  HFXBFramebar:SetDimensions(HFXBFrame:GetWidth() * newXp, HFXBFrame:GetHeight())
  HFXBFramebar:SetColor(unpack(HFXB.getBarColour()))
  HFXBFrametext:SetText(string.format("%d/%d (%d%%)", HFXB.getCurrentXp(), HFXB.getMaxXp(), newXp * 100))

  if newXp > HFXB.currentXp and HFXB.gainAnimation ~= nil then
    local xpDiff = newXp - HFXB.currentXp
    local gainWidth = HFXBFrame:GetWidth() * xpDiff
    local offset = HFXBFrame:GetWidth() * HFXB.currentXp
    if gainWidth < 1 then 
      gainWidth = 1
      offset = offset - 1
    end
    HFXBFramegain:SetDimensions(gainWidth, HFXBFrame:GetHeight())
    HFXBFramegain:SetSimpleAnchorParent(offset, 0)

    local format = xpDiff > 0.01 and "+%d (%d%%)" or "+%d (%.2f%%)"
    HFXBFramegainText:SetText(string.format(format, HFXB.getMaxXp() * xpDiff, xpDiff * 100))

    HFXBFramegain:SetAlpha(1)
    HFXBFramegainText:SetAlpha(1)
    HFXB.gainAnimation:Stop()
    HFXB.gainTextAnimation:Stop()
    HFXB.gainAnimation:PlayFromStart()
    HFXB.gainTextAnimation:PlayFromStart()
  end

  HFXB.currentXp = newXp
end

EVENT_MANAGER:RegisterForEvent("HFXB", EVENT_ADD_ON_LOADED, HFXB.init)
EVENT_MANAGER:RegisterForEvent("HFXB", EVENT_EXPERIENCE_UPDATE, HFXB.gain)
EVENT_MANAGER:RegisterForEvent("HFXB", EVENT_VETERAN_POINTS_UPDATE, HFXB.gain)