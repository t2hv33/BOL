--[[ Sida's Auto Carry Plugin: Orianna ]]--
--[[ Version 1.0 ]]--
function PassiveFarm(minion)
  return getDmg("P", minion, myHero)
end
 
AutoCarry.Plugins:RegisterBonusLastHitDamage(PassiveFarm)