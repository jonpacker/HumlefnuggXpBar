HFXB = {}

function HFXB.init(eventCode, addOnName)
  local xp = GetUnitXP("player")
  local levelXp = GetUnitXPMax("player")
  HFXBFramebar:SetDimensions(HFXBFrame:GetWidth() * (xp / levelXp), HFXBFrame:GetHeight())
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