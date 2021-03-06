Trigger = {};
--Trigger.vehicleCategories = {"PLOWS" , "FERTILIZERSPREADERS", "TRACTORS", "TRACTORSM", "SEEDERS", "HARVESTERS", "CUTTERS", "SPRAYERS", "POWERHARROWS", "WEEDERS"}
--Trigger.triggerTypes = {fieldOwned, propertyOwned, machinerOwned, tatToCheck, playerInRange, fieldStatus}
--Trigger.triggerTypeParams = {}
--Trigger.triggerTypeParams["fieldOwned"] = {farmLandID} --The farmLandID is not the fieldNumber as seen on the map, but the property Index  

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
        fulfilled = self:checkPlayerInRange()
    elseif self.triggerType == "fieldStatus" then
        fulfilled = self:checkFieldStatus();
    elseif self.triggerType == "timePassed" then
        fulfilled = self:checkTimePassed();
    elseif self.triggerType == "animalCount" then
        fulfilled = self:checkAnimalCount();
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
        self.statsToCheck[statPair[1]] = statPair[2];
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
    --print("Stat value: " .. currentValue .. " required: " .. value);

    return currentValue >= value;
end;

function Trigger:getStatisticValue(statistic)
    --ToDo!
    for _,farm in pairs(g_farmManager.farms) do
        if farm.players[1] ~= nil then
            --DebugUtil.printTableRecursively(farm.stats.statistics, "----", 0,1);
            return farm.stats.statistics[statistic].total;
		end;
	end;
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

        local objectId = nil;
        for _,player in pairs(g_currentMission.players) do
            objectId = player.rootNode;
        end;

        local node = createTransformGroup("MissionMarker");
        setTranslation(node, positionBounds["x"],0 , positionBounds["z"]);
					
        if self.hotspotcreated == nil then 
            local hotspot = MapHotspot:new("Mission", MapHotspot.CATEGORY_DEFAULT)
            hotspot:setText("Text", true);
            imageFilename = StoryMode.directory .. "img/" .. "mayorTom.dds";
            imageUVs = MapHotspot.UV["CIRCLE"]
            imageUVs = getNormalizedUVs(imageUVs)
            hotspot:setBorderedImage(imageFilename, imageUVs, StringUtil.getVectorNFromString("1,1,1,1"));
            hotspot:setLinkedNode(node)
            hotspot:setPersistent(true) 
            hotspot:setBlinking(true)
            g_currentMission:addMapHotspot(hotspot);

            StoryMode:addHotSpot(hotspot);
            self.hotspotcreated = true;
        end;

        local x,z = self:getPlayerPos();

        local dist = math.sqrt(math.pow(x-positionBounds["x"],2) + math.pow(z-positionBounds["z"],2) );
        
        return dist <= positionBounds["radius"];
    end;

    return false;
end;

function Trigger:getPlayerPos()
    local x = 0;
    local z = 0;

    local x,y,z = g_currentMission.player:getPositionData()
	if x == 0 and z == 0 then
        for _,vehicle in pairs(g_currentMission.vehicles) do
            if vehicle.spec_enterable ~= nil then
                if vehicle.spec_enterable.isControlled == true then
                    local x,y,z = getWorldTranslation(vehicle.rootNode);
                    --print("Vehicle pos: " .. x .. "/" .. z);
                end;
            end;
        end;
    end;

    return x,z;
end;

function Trigger:checkFieldStatus()    
    local fieldStatusString = self.fieldStatus;
    local fieldStatusStringSplitted = self.fieldStatus:split("-");
    --print("StoryMode - Trigger: checkFieldStatus called");
    if fieldStatusStringSplitted ~= nil and fieldStatusStringSplitted[1] ~= nil and fieldStatusStringSplitted[2] ~= nil then
        self.fieldToCheck = tonumber(fieldStatusStringSplitted[1]);
        self.fieldTargetStatus = fieldStatusStringSplitted[2]
        self.fieldTargetFruit = 0;
        if fieldStatusStringSplitted[3] ~= nil then
            self.fieldTargetFruit = tonumber(fieldStatusStringSplitted[3]);
        end;
        if fieldStatusStringSplitted[4] ~= nil then
            self.fieldTargetFruitGrowth = tonumber(fieldStatusStringSplitted[4]);
        end;
        if fieldStatusStringSplitted[5] ~= nil then
            self.fieldTargetFruitPercentage = tonumber(fieldStatusStringSplitted[5]);
        end;
        if fieldStatusStringSplitted[6] ~= nil then
            self.fieldTargetFruitPercentageSmaller = fieldStatusStringSplitted[6] == "<";
        end;

        return self:checkFieldForStatus();
    else        
        print("StoryMode - Trigger: checkFieldStatus wrong parameters in xml");
    end;
end;

function Trigger:checkFieldForStatus()
    local field = g_fieldManager.fields[self.fieldToCheck];
    if field ~= nil then
        local childrenNum = getNumOfChildren(field.fieldDimensions)
        
        self.fieldPartitionCount = getNumOfChildren(field.fieldDimensions)
        if self.fieldPartitions == nil then
            self.fieldPartitions = {};
            self.triggerCallbacks = {};

            for currentPartition = 1, self.fieldPartitionCount, 1 do        
                local childID = getChildAt(field.fieldDimensions, 0);
                local corner1ID = getChildAt(childID, 0);
                local corner2ID = getChildAt(childID, 1);
                
                x,y,z = getWorldTranslation(childID)
                corner1x,corner1y,corner1z = getWorldTranslation(corner1ID)
                corner2x,corner2y,corner2z = getWorldTranslation(corner2ID)

                self.fieldPartitions[currentPartition] = {};
                self.fieldPartitions[currentPartition][1] = {};
                self.fieldPartitions[currentPartition][2] = {};

                self.fieldPartitions[currentPartition][1].string = "blub";

                --print("self.fieldPartitions[" .. currentPartition .. "][1].string: " .. self.fieldPartitions[currentPartition][1].string);

                self.triggerCallbacks[currentPartition] = {};
                self.triggerCallbacks[currentPartition][1] = TriggerCallback:new(self, currentPartition, 1);
                self.triggerCallbacks[currentPartition][2] = TriggerCallback:new(self, currentPartition, 2);
            end;
        else
            
            local fieldArea = 0;
            local fruits = {};
            local fruitPixels = {};
            local weedFactor = 0;
            local cultivatorFactor = 0;
            local plowFactor = 0;

            for currentPartition = 1, self.fieldPartitionCount, 1 do
                for part=1,2 do
                    if self.fieldPartitions[currentPartition][part].fieldData ~= nil then
                        local data = self.fieldPartitions[currentPartition][part].fieldData;

                        weedFactor = (weedFactor * fieldArea + data.weedFactor * data.fieldArea) / (fieldArea + data.fieldArea)
                        cultivatorFactor = (cultivatorFactor * fieldArea + data.cultivatorFactor * data.fieldArea) / (fieldArea + data.fieldArea)
                        plowFactor = (plowFactor * fieldArea + data.plowFactor * data.fieldArea) / (fieldArea + data.fieldArea)

                        fieldArea = fieldArea + data.fieldArea
                        for _,growthState in pairs(data.fruits) do
                            if fruits[_] == nil then
                                fruits[_] = growthState;
                            else
                                fruits[_] = math.max(fruits[_], growthState);
                            end;
                        end;
                        for _,fruitAmount in pairs(data.fruitPixels) do
                            if fruitPixels[_] == nil then
                                fruitPixels[_] = fruitAmount;
                            else
                                fruitPixels[_] = fruitPixels[_] + fruitAmount;
                            end;
                        end;
                    end;
                end;
            end;

            --print("FieldArea: " .. fieldArea .. " fruitPixels[" .. self.fieldTargetFruit .. "]: " .. fruitPixels[self.fieldTargetFruit]);

            if self.fieldTargetStatus == "sown" then
                local target = 0.9 * fieldArea;
                if self.fieldTargetFruitPercentage ~= nil then
                    target = self.fieldTargetFruitPercentage * fieldArea;
                    --print("Target set to: " .. target .. " percentage = " .. self.fieldTargetFruitPercentage);
                end;
                --print("Target set to: " .. target);
                
                if fruitPixels[self.fieldTargetFruit] ~= nil then
                    
                    --print("fruitPixels[self.fieldTargetFruit] ~= nil: " .. fruitPixels[self.fieldTargetFruit] );
                    local areaAsDesired = false;
                    if self.fieldTargetFruitPercentageSmaller and fruitPixels[self.fieldTargetFruit] <= target then
                        areaAsDesired = true;
                    end;
                    if fruitPixels[self.fieldTargetFruit] >= target then
                        areaAsDesired = true;
                    end;
                    if areaAsDesired == true then
                        --print("areaAsDesired == true");
                        if fruits[self.fieldTargetFruit] >= self.fieldTargetFruitGrowth then
                            self.alreadyFulfilled = true;
                            --print("Trigger - fieldStatus - fulfilled");
                            return true;
                        end;
                    end;
                end;
            end;

            if self.fieldTargetStatus == "weed" then
                local target = 0.9;
                if self.fieldTargetFruitPercentage ~= nil then
                    target = self.fieldTargetFruitPercentage;
                    --print("Target set to: " .. target .. " percentage = " .. self.fieldTargetFruitPercentage);
                end;
                --print("Target set to: " .. target);

                local areaAsDesired = false;
                if self.fieldTargetFruitPercentageSmaller and weedFactor <= target then
                    areaAsDesired = true;
                end;
                if weedFactor >= target and not self.fieldTargetFruitPercentageSmaller then
                    areaAsDesired = true;
                end;

                if areaAsDesired then
                    self.alreadyFulfilled = true;
                    --print("Trigger - fieldStatus - fulfilled");
                    return true;
                end;
            end;
        end;

        for currentPartition = 1, self.fieldPartitionCount, 1 do            
            self.fieldPartitions[currentPartition][1].fieldData = nil;
            self.fieldPartitions[currentPartition][2].fieldData = nil;
            FSDensityMapUtil.getFieldStatusAsync(x, z, corner1x, corner1z, corner2x, corner2z, self.triggerCallbacks[currentPartition][1].onFieldDataUpdateFinished,  self.triggerCallbacks[currentPartition][1]);
            FSDensityMapUtil.getFieldStatusAsync(x, z, corner2x, z, corner2x, corner2z, self.triggerCallbacks[currentPartition][2].onFieldDataUpdateFinished,  self.triggerCallbacks[currentPartition][2]);
        end;

        --print("Child: ")
        --print("X: " .. x .. " Y: " .. y .. " Z: " .. z);
        --print("Corner 1: ");
        --print("X: " .. corner1x .. " Y: " .. corner1y .. " Z: " .. corner1z);
        --print("Corner 2: ");
        --print("X: " .. corner2x .. " Y: " .. corner2y .. " Z: " .. corner2z);
        --Trigger:getPlayerPos();    
        --local fieldWidth = corner2x - corner1x;
        --local fieldHeight = corner2z - z;    
        --print("Fieldwidth: " .. fieldWidth .. " height: " .. fieldHeight);
        --FSDensityMapUtil.getFieldStatusAsync(field.posX, field.posZ, field.posX+15, field.posZ-0.1, field.posX+0.1, field.posZ-15, self.onFieldDataUpdateFinished, self);
        --FSDensityMapUtil.getFieldStatusAsync(x, z, corner2x, z, corner2x, corner2z, self.onFieldDataUpdateFinished_2, self);
    else
        print("StoryMode - Trigger: passed field " .. self.fieldToCheck .. " is nil");
    end;
end;

function Trigger:onFieldDataUpdateFinished(fieldData, partition, part)
    --ToDo: Allow more field states, such aus plowed, cultivated and sprayed
    --print("Received information about partition: " .. partition .. " part: " .. part);
    --print("Trigger - got field data");
    if fieldData ~= nil then
        --print("fieldData is not nil");
        --DebugUtil.printTableRecursively(fieldData, "----", 0, 1);
    end;
    if self.fieldPartitions ~= nil then
        if self.fieldPartitions[partition][part] ~= nil then
            self.fieldPartitions[partition][part].fieldData = fieldData;
        else
            print("StoryMode - Trigger - self.fieldPartitions[currentPartition][part] is nil");
        end;
    else        
        print("StoryMode - Trigger - self.fieldPartitions is nil");
    end;
end;

function Trigger:checkTimePassed()
    local time = tonumber(self.timePassed);
    if StoryMode.timeSinceLastTrigger >= time then
        return true;
    else
        return false;        
    end;
end;

function Trigger:checkAnimalCount()
    local animalCountString = self.animalCount;
    local animalCountStringSplitted = animalCountString:split("-");

    if animalCountStringSplitted ~= nil and animalCountStringSplitted[1] ~= nil and animalCountStringSplitted[2] ~= nil then
        self.animalType = animalCountStringSplitted[1];
        self.animalTargetCount = tonumber(animalCountStringSplitted[2]);
        local animalCount = self:getAnimalCount(self.animalType);

        --print("Stat value: " .. animalCount .. " required: " .. self.animalTargetCount);

        return self.animalTargetCount <= animalCount
    end;

    return false;
end;

function Trigger:getAnimalCount(animalType)
    local animalCount = 0;
	for _,husbandry in pairs(g_currentMission.husbandries) do
		if husbandry.modulesByName["animals"] ~= nil then
			if husbandry.modulesByName["animals"].animalType == animalType then
				for _,animal in pairs(husbandry.modulesByName["animals"].animals) do
					animalCount = animalCount + 1;
				end;
			end;
		end;
    end;
    return animalCount;
end;
