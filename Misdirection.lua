-- VARIABLES
MDB_Conf = {};
local Tank = "pet"
local TankName = ""
local CooldownActive = false

-- Control Frame
local MDB = CreateFrame("Button",nil, UIParent, "SecureActionButtonTemplate,ActionButtonTemplate");
MDB:SetSize(36,36);
MDB:SetPoint("CENTER",100,-200);

-- Cooldown Frame
local CDF = CreateFrame("Cooldown", "MyCdFrame", MDB,  "CooldownFrameTemplate")
CDF:SetAllPoints(MDB)
CDF:SetSwipeColor(1, 1, 1)

MDB.texture = MDB:CreateTexture(nil, "BACKGROUND")

--MDB:SetAttribute("type1", "macro") -- left click causes macro
--MDB:SetAttribute("macrotext1", "/cast Misdirection") -- text for macro on left click
--MDB:SetAttribute("unit", "pet") -- text for macro on left click
--frame:SetAttribute("unit", "player")
MDB:RegisterForClicks("LeftButtonUp")

MDB:SetAttribute("type", "spell")
MDB:SetAttribute("spell", "Misdirection")
MDB:SetAttribute("unit", "pet")


MDB.texture:SetTexture("Interface\\Icons\\Ability_Hunter_Misdirection")
MDB.texture:SetAllPoints(true)


MDB:SetMovable(true)
MDB:EnableMouse(true)
MDB:SetScript("OnMouseDown", function(self, button)
    inLockdown = InCombatLockdown()
    if inLockdown == false then
        if button == "RightButton" and not self.isMoving then
            self:StartMoving();
            self.isMoving = true;
            
        end
    end
end)
MDB:SetScript("OnMouseUp", function(self, button)
 
    if button == "RightButton" and self.isMoving then
        self:StopMovingOrSizing();
        self.isMoving = false;
        point, relativeTo, relativePoint, xOfs, yOfs = MDB:GetPoint();
        MDB_Conf.location.x = xOfs;
        MDB_Conf.location.y = yOfs;
        --DEFAULT_CHAT_FRAME:AddMessage("Location X=" . MDB_Conf.location.x . " Y=" . MDB_Conf.location.y);

    end
end)
MDB:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(MDB, "ANCHOR_RIGHT")
    GameTooltip:SetText(TankName)
    GameTooltip:Show() 
end)
MDB:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)


-- MDB:Hide();

-- Register Loot Events
MDB:RegisterEvent("ADDON_LOADED");
MDB:RegisterEvent("GROUP_ROSTER_UPDATE");
MDB:RegisterEvent("PLAYER_REGEN_ENABLED");
MDB:RegisterEvent("UNIT_AURA");
MDB:RegisterEvent("SPELL_UPDATE_COOLDOWN");
MDB:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");

local function checkParty()
    memberCount = GetNumGroupMembers();
    Tank = "";
    for groupindex = 1,memberCount do
        if(UnitGroupRolesAssigned(memberCount) == "TANK") then
            if IsInRaid() then
                Tank = "raid" .. groupindex;
                local name, realm = UnitName("raid" .. groupindex)
                if name ~= TankName then 
                    DEFAULT_CHAT_FRAME:AddMessage("|cffff0000Misdirection|r New Tank: " .. TankName);
                end
                TankName = name
            else
                Tank = "party" .. groupindex;
                local name, realm = UnitName("party" .. groupindex)
                if name ~= TankName then 
                    DEFAULT_CHAT_FRAME:AddMessage("|cffff0000Misdirection|r New Tank: " .. TankName);
                end
                TankName = name
            end
            
            --break
        end
        memberCount = memberCount + 1
    end
    if(Tank == "") then 
        Tank = "pet"
        local name, realm = UnitName("pet")
        if name ~= TankName then 
            DEFAULT_CHAT_FRAME:AddMessage("|cffff0000Misdirection|r New Tank: " .. name);
        end

        TankName = name
    end
    MDB:SetAttribute("unit", Tank) -- Set target
end

MDB:SetScript("OnEvent", function(self,event,arg1)

    if event == "ADDON_LOADED" and arg1 == "Misdirection" then

        -- Load Settings
        if MDB_Conf.location == nil then 
            MDB_Conf.location = {};
            MDB_Conf.location.x = 100;
            MDB_Conf.location.y = -200;
        end
        MDB:SetPoint("CENTER",MDB_Conf.location.x,MDB_Conf.location.y);
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000Misdirection|r Locked and Loaded!");
        checkParty();
    end

    if event == "UNIT_AURA" or event == "SPELL_UPDATE_COOLDOWN" or event == "ACTIONBAR_UPDATE_COOLDOWN" then

        local mdFound = false
        for i=1,40 do
            local name, icon, _, _, _, etime = UnitBuff("player",i)
            if name == "Misdirection" then
               mdFound = true
               break
            end
        end

        local start, duration, enabled, modRate = GetSpellCooldown("Misdirection")
        local cdLeft = start + duration - GetTime()
        
        if start == 0 or cdLeft == 30 then
            CooldownActive = false
        end

        if mdFound == false then
            if cdLeft > 0 then
                if CooldownActive == false then
                    CooldownActive = true
                    CDF:SetCooldown(GetTime(), cdLeft)
                end
            end
        end

    end

    if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_REGEN_ENABLED" then
        checkParty();
    end
end)

