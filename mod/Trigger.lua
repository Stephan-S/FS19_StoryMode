Trigger = {};

function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
 end

function Trigger:new(triggerType, triggerSticks, triggerAttributes)
    o = {}
    setmetatable(o, self)
    self.__index = self
    o.triggerType = triggerType;
    o.triggerAttributes = triggerAttributes;
    o.alreadyFulfilled = false;
    o.triggerSticks = triggerSticks;
    if o.triggerAttributes ~= nil then
        o:parseAttributes();
    end;
    return o
end;

function Trigger:parseAttributes()
    for _,attrPair in pairs(self.triggerAttributes:split(";")) do
        --print("pair: " .. attrPair);
        local attrFields = attrPair:split(":");
        if attrFields ~= nil and attrFields[1] ~= nil and attrFields[2] ~= nil then
            --print("Found attr: " .. attrFields[1] .. " with value: " .. attrFields[2]);
            self[attrFields[1]] = attrFields[2];
        end;
    end;
end;

function Trigger:checkFulfilled()    
    --print("Check checkFulfilled: ");
    if self.alreadyFulfilled and self.triggerSticks then
        return true;
    end;

    local fulfilled = false;
    if self.triggerType == "fieldOwned" then
        fulfilled =  self:checkFieldOwned()
    elseif self.triggerType == "propertyOwned" then
        fulfilled = self:checkPropertyOwned()
    elseif self.triggerType == "machineryOwned" then
        fulfilled = self:checkMachineryOwned()
    elseif self.triggerType == "statToCheck" then
        fulfilled = self:checkStatisticReached()
    elseif self.triggerType == "playerInRange" then
        fulfilled = self:checkStatisticReached()
    end;

    self.alreadyFulfilled = fulfilled;

    return fulfilled;
end;

function Trigger:checkFieldOwned()
    if self.farmLandID ~= nil then
        --print("Farmland check: " .. tonumber(self.farmLandID) .. " : " .. tostring(g_currentMission.landscapingController.farmlandManager.farmlands[tonumber(self.farmLandID)].isOwned))
        return g_currentMission.landscapingController.farmlandManager.farmlands[tonumber(self.farmLandID)].isOwned;
    end;

    return false;
end;

function Trigger:checkPropertyOwned()
    local propertyName = self.propertyName;
    local propFound = false;
    for _,className in pairs( g_currentMission.objectsToClassName ) do
        if className == propertyName then
            propFound = true;
        end;
    end

    --print("Check property: " .. self.propertyName .. " : " .. tostring(propFound));
    return propFound;
end;

function Trigger:checkStatisticReached()
    local statistic = self.statToCheck;
    local statPair = self.statToCkeck:split("-");
    if statPair ~= nil and statPair[1] ~= nil and statPair[2] ~= nil then
        --print("Found attr: " .. attrFields[1] .. " with value: " .. attrFields[2]);
        self.statsToCheck = {};
        self.statsoCheck[statPair[1]] = statPair[2];
    end;

    if self.statsToCheck ~= nil then
        for _,stat in pairs(self.statsToCheck) do
            return self:checkStatReached(_,stat);
        end;
    end;
end;

function Trigger:checkStatReached(statistic, value)
    value = tonumber(value);
    currentValue = self:getStatisticValue(statistic);

    return currentValue >= value;
end;

function Trigger:getStatisticValue(statistic)
    --ToDo!
end;

function Trigger:checkMachineryOwned()
    local vehicleDesc = self.statToCheck;
    local vehicleDescSplitted = self.statToCkeck:split("-");
    if vehicleDescSplitted ~= nil and vehicleDescSplitted[1] ~= nil and vehicleDescSplitted[2] ~= nil then
        --print("Found attr: " .. attrFields[1] .. " with value: " .. attrFields[2]);
        self.vehciclesToCount = {};
        self.vehciclesToCount[vehicleDescSplitted[1]] = vehicleDescSplitted[2];
    end;

    if self.vehciclesToCount ~= nil then
        for vehicleType,vehicleCount in pairs(self.vehciclesToCount) do
            return self:checkVehicleCount(vehicleType,vehicleCount);
        end;
    end;
end;

function Trigger:checkVehicleCount(vehicleType, vehicleCount)
    local currentVehiclesOfType = self:getVehcicleCount(vehicleType);

    return currentVehiclesOfType > vehicleCount;
end;

function Trigger:getVehcicleCount(vehicleType)
    --ToDo;
end;

function Trigger:checkPlayerInRange()
    local positionBounds = {};
    local playerPosField = self.playerPos:split("-");
    
    if playerPosField ~= nil and playerPosField[1] ~= nil and playerPosField[2] ~= nil and playerPosField[3] ~= nil then
        positionBounds["x"] = tonumber(playerPosField[1]);
        positionBounds["z"] = tonumber(playerPosField[2]);
        positionBounds["radius"] = tonumber(playerPosField[3]);

        local x,z = self:getPlayerPos();
        x = 1;
        z = 1;

        local dist = math.sqrt(math.pow(x-positionBounds.x,2) + math.pow(z-positionBounds.z,2) );
        
        return dist <= positionBounds.radius;
    end;

    return false;
end;

function Trigger:getPlayerPos()
    --ToDo;
    return {1,1};
end;


