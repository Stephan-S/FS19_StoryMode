Trigger = {};
Trigger.vehicleCategories = {"PLOWS" , "FERTILIZERSPREADERS", "TRACTORS", "TRACTORSM", "SEEDERS", "HARVESTERS", "CUTTERS", "SPRAYERS", "POWERHARROWS", "WEEDERS"}

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
       -- fulfilled = self:checkStatisticReached()
    elseif self.triggerType == "playerInRange" then
        fulfilled = self:checkPlayerInRange()
    elseif self.triggerType == "fieldCheck" then
        self:checkFieldStatus();
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
    local statPair = statistic:split("-");
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
    local vehicleDesc = self.vehicleType;
    local vehicleDescSplitted = self.vehicleType:split("-");
    if vehicleDescSplitted ~= nil and vehicleDescSplitted[1] ~= nil and vehicleDescSplitted[2] ~= nil then
        --print("Found attr: " .. attrFields[1] .. " with value: " .. attrFields[2]);
        self.vehciclesToCount = {};
        self.vehciclesToCount[vehicleDescSplitted[1]] = tonumber(vehicleDescSplitted[2]);
    end;

    if self.vehciclesToCount ~= nil then
        for vehicleType,vehicleCount in pairs(self.vehciclesToCount) do
            return self:checkVehicleCount(vehicleType,vehicleCount);
        end;
    end;
end;

function Trigger:checkVehicleCount(vehicleType, vehicleCount)
    local currentVehiclesOfType = self:getVehcicleCount(vehicleType);

    return currentVehiclesOfType >= vehicleCount;
end;

function Trigger:getVehcicleCount(vehicleType)
    local count = 0;
    for _,ownedItem in pairs(g_currentMission.ownedItems) do
        if ownedItem.storeItem.categoryName ~= nil then
            if string.find(vehicleType, "TRACTORS") ~= nil then
                if string.find(ownedItem.storeItem.categoryName, "TRACTORS") ~= nil then
                    count = count + ownedItem.numItems;
                    --print("StoryMode - Trigger: found item of type: " .. vehicleType);
                end;                
            else
                if ownedItem.storeItem.categoryName == vehicleType then
                    count = count + ownedItem.numItems;
                    --print("StoryMode - Trigger: found item of type: " .. vehicleType);
                end;
            end;
        end;
    end;
    return count;
end;

function Trigger:checkPlayerInRange()
    local positionBounds = {};
    local playerPosField = self.playerPos:split("/");
    
    if playerPosField ~= nil and playerPosField[1] ~= nil and playerPosField[2] ~= nil and playerPosField[3] ~= nil then
        positionBounds["x"] = tonumber(playerPosField[1]);
        positionBounds["z"] = tonumber(playerPosField[2]);
        positionBounds["radius"] = tonumber(playerPosField[3]);

        local x,z = self:getPlayerPos();

        local dist = math.sqrt(math.pow(x-positionBounds["x"],2) + math.pow(z-positionBounds["z"],2) );
        
        return dist <= positionBounds["radius"];
    end;

    return false;
end;

function Trigger:getPlayerPos()
    --ToDo: test;
    local x = 0;
    local z = 0;
    for _,player in pairs(g_currentMission.players) do
        x = player.baseInformation.lastPositionX;
        print("x: " .. x);
        z = player.baseInformation.lastPositionZ;
        print("z: " .. z);
    end;

    return x,z;
end;

function Trigger:checkFieldStatus()    
    local fieldStatusString = self.fieldStatus;
    local fieldStatusStringSplitted = self.fieldStatus:split("-");
    if fieldStatusStringSplitted ~= nil and fieldStatusStringSplitted[1] ~= nil and fieldStatusStringSplitted[2] ~= nil then
        self.fieldToCheck = toNumber(fieldStatusStringSplitted[1]);
        self.fieldTargetStatus = fieldStatusStringSplitted[2]
        self.fieldTargetFruit = 0;
        if fieldStatusStringSplitted[3] ~= nil then
            self.fieldTargetFruit = toNumber(fieldStatusStringSplitted[3]);
        end;
        if fieldStatusStringSplitted[4] ~= nil then
            self.fieldTargetFruitGrowth = toNumber(fieldStatusStringSplitted[4]);
        end;

        Trigger:checkFieldForStatus(self.fieldToCheck, self.fieldTargetStatus, self.fieldTargetFruit, self.fieldTargetFruitGrowth);
    end;
end;

function Trigger:checkFieldForStatus(fieldToCheck, fieldTargetStatus, fieldTargetFruit, fieldTargetFruitGrowth)
    local field = g_fieldManager.fields[fieldToCheck];
    if field ~= nil then
        --ToDo: The offsets should be determined by the field angle i guess
        FSDensityMapUtil.getFieldStatus(field.posX, field.posZ, field.posX+5, field.posZ-5, field.posX+0.1, field.posZ-0.1, self:onFieldDataUpdateFinished, Trigger);
    else
        print("StoryMode - Trigger: passed field " .. fieldToCheck .. " is nil");
    end;
end;

function Trigger:onFieldDataUpdateFinished(fieldData)
    if self.fieldToCheck ~= nil then
        print("Trigger - got field data and fieldToCheck is not nil");
        if fieldData.farmlandId == g_fieldManager.fields[self.fieldToCheck].farmlandId then
            print("Trigger - got field data for correct field");
            if self.fieldTargetStatus == "sown" then
                if fieldData.fruitPixels[self.fieldTargetFruit] >= (0.9 * fieldData.fieldArea) then
                    print("Trigger - got field data for correct field with enough sown fruit");
                    if fieldData.fruit[self.fieldTargetFruit] >= self.fieldTargetFruitGrowth then
                        print("Trigger - got field data for correct field with enough sown fruit in the correct growth state");
                        self.alreadyFulfilled = true;
                    end;
                end;
            end;
        end;
    end;
end;