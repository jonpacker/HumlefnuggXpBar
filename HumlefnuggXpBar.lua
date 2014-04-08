HFXB = {}

function HFXB.init(eventCode, addOnName)
  if addOnName ~= "HumlefnuggXpBar" then return end

  HFXB.gain()

  for i = 1, 20 do 
    local bubble = CreateControlFromVirtual("HFXBBubble", HFXBFrame, "HFXBBubble", i)
    bubble:SetSimpleAnchorParent((i - 1) * 75, 0)
  end
end

function HFXB.update()

end

function HFXB.gain()
  local xp = GetUnitXP("player")
  local levelXp = GetUnitXPMax("player")
  HFXBFramebar:SetDimensions(HFXBFrame:GetWidth() * (xp / levelXp), HFXBFrame:GetHeight())
end

EVENT_MANAGER:RegisterForEvent("HFXB", EVENT_ADD_ON_LOADED, HFXB.init)
EVENT_MANAGER:RegisterForEvent("HFXB", EVENT_EXPERIENCE_UPDATE, HFXB.gain)