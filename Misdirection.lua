-- VARIABLES
MDB_Conf = {};
local Tank = ""

-- Control Frame
local MDB = CreateFrame("Button",nil, UIParent, "SecureActionButtonTemplate");
MDB:SetSize(36,36);
MDB:SetPoint("CENTER",100,-200);


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

-- MDB:Hide();

-- Register Loot Events
MDB:RegisterEvent("ADDON_LOADED");
MDB:RegisterEvent("GROUP_ROSTER_UPDATE");
MDB:RegisterEvent("PLAYER_REGEN_ENABLED");


local function checkParty()
    memberCount = GetNumGroupMembers();
    Tank = "";
    for groupindex = 1,memberCount do
        if (GetPartyMember(groupindex)) then
            memberCount = memberCount + 1
            if(UnitGroupRolesAssigned(Unit) == "TANK") then
                Tank = "party" .. groupindex;
                --break
            end
        end
    end
    if(Tank == "") then 
        Tank = "pet"
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
    end

    if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_REGEN_ENABLED" then
        checkParty();
    end
end)

