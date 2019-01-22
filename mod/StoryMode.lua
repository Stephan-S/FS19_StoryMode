StoryMode = {};
StoryMode.Version = "1.0.0";
StoryMode.config_changed = false;
local myName = "FS19_StoryMode";

StoryMode.directory = g_currentModDirectory;
StoryMode.storyDirectory = g_currentModDirectory .. "story/";

source(Utils.getFilename("gui/smGui.lua", g_currentModDirectory))
source(Utils.getFilename("Trigger.lua", g_currentModDirectory))

StoryMode.currentStory = 1;
StoryMode.currentStoryPresented = false;
StoryMode.lastStory = 3;
StoryMode.waitTime = 2000;
StoryMode.waitTimeConstant = 10000;
StoryMode.storedFieldInfoVariables = false;

function StoryMode:prerequisitesPresent(specializations)
    return true;
end;

function StoryMode:delete()	
end;

function StoryMode:loadMap(name)		
	--print("StoryMode load map");
	
	--gui
    StoryMode.gui = {};
    StoryMode.gui["smSettingGui"] = smGui:new();
	g_gui:loadGui(StoryMode.directory .. "gui/smGui.xml", "smGui", StoryMode.gui.smSettingGui);	
		
	--load settings:	
	StoryMode.confDirectory = g_currentMission.missionInfo.savegameDirectory; --getUserProfileAppPath().. "modsSettings/FS19_StoryMode/"; 
	StoryMode:readStoryXML()	
	StoryMode:readConfig();

	-- Save Story when saving savegame
	FSBaseMission.saveSavegame = Utils.appendedFunction(FSBaseMission.saveSavegame, StoryMode.saveSavegame);

    -- Only needed for global action event 
    FSBaseMission.registerActionEvents = Utils.appendedFunction(FSBaseMission.registerActionEvents, StoryMode.registerActionEventsMenu);

	--FieldInfoDisplay.onFieldDataUpdateFinished = Utils.appendedFunction(FieldInfoDisplay.onFieldDataUpdateFinished, StoryMode.onFieldDataUpdateFinished);
	--FSDensityMapUtil.getFieldStatusAsync = Utils.appendedFunction(FSDensityMapUtil.getFieldStatusAsync, StoryMode.onGetFieldStatusAsync);
	--FSDensityMapUtil.getFieldStatusAsync = Utils.appendedFunction(FSDensityMapUtil.getFieldStatusAsync, StoryMode.onAsynCall);
end;

function StoryMode:deleteMap()	
end;

function StoryMode.saveSavegame()
	StoryMode:writeConfig();
end;

function StoryMode:load(xmlFile)	
end;

-- only needed for global action event
function StoryMode:registerActionEventsMenu()
    --print("StoryMode registerActionEventsMenu")
    local erg, eventName = InputBinding.registerActionEvent(g_inputBinding, 'StoryMode_Settings',self, StoryMode.onOpenSettings ,false ,true ,false ,true)
    if erg then
         g_inputBinding.events[eventName].displayIsVisible = false
    end
end

function StoryMode:onOpenSettings(actionName, keyStatus, arg4, arg5, arg6)
	--print("StoryMode - open settings");
	if StoryMode.gui.smSettingGui.isOpen then
		StoryMode.gui.smSettingGui:onClickBack()
	elseif g_gui.currentGui == nil then
		g_gui:showGui("smGui")
	end;
end;

function StoryMode:settingsFromGui()
end;

function StoryMode:settingsResetGui()
end;

function StoryMode:guiClosed()
end;

function StoryMode:onLeave()
end;

function StoryMode:onDelete()
end;

function StoryMode:newMouseEvent(superFunc,posX, posY, isDown, isUp, button)
end;

function StoryMode:mouseEvent(posX, posY, isDown, isUp, button)	
end; 

function StoryMode:keyEvent(unicode, sym, modifier, isDown) 	
end; 

function StoryMode:StoryMode_init()	
end;

function StoryMode:onFieldDataUpdateFinished(data)	
	if data ~= nil then
		--print("_____________DATAAAAAAAAAAAAAAAAAAAAAA_____________");
		--DebugUtil.printTableRecursively(data, "----", 0, 1);
	else
		
		--print("_____________DATAAAAAAAAAAAAAAAAAAAAAA____is NIIIL_________");
	end;
end;

function StoryMode:onGetFieldStatusAsync(a,b,c,d,e,f,g)
	if StoryMode.storedFieldInfoVariables == false then
		StoryMode.fieldInfoReturnFunction = f;
		StoryMode.fieldInfoPassedTable = g;
		StoryMode.storedFieldInfoVariables = true;
	end;
end;

function StoryMode:onAsynCall(a,b,c,d,e,f,g,h,i,j)	
	if a ~= nil then
		print("_____________a exists (number): " .. a);
	end;
	if b ~= nil then
		print("_____________b exists_: " .. b);
	end;
	if c ~= nil then
		print("_____________c exists_: " .. c);
	end;
	if d ~= nil then
		print("_____________d exists_: " .. d);
	end;
	if e ~= nil then
		print("_____________e exists_: " .. e);
	end;
	if f ~= nil then
		print("_____________f exists_: ");
	end;
	if g ~= nil then
		print("_____________g exists and is a table_____________");
	end;
	if h ~= nil then
		print("_____________h exists_____________");
		DebugUtil.printTableRecursively(h, "----", 0, 1);
	end;
end;

function StoryMode:update(dt)
	StoryMode.waitTime = StoryMode.waitTime- dt;
	if StoryMode.waitTime > 0 then
		return;
	end;
	
	StoryMode.waitTime = StoryMode.waitTimeConstant;
	print("StoryMode - update(dt)");
	for _,ownedItem in pairs(g_currentMission.landscapingController.farmlandManager.stateChangeListener) do
		if ownedItem.fields ~= nil then
			--print("posX: " .. ownedItem.fields[20].posX .. " posZ: " .. ownedItem.fields[20].posZ .. " posX+5: " .. (ownedItem.fields[20].posX+5) .. " posZ-5: " .. (ownedItem.fields[20].posZ-5) .. " posX+0.1: " .. (ownedItem.fields[20].posX+0.1));
			--FSDensityMapUtil:getFieldStatusAsync(ownedItem.fields[20].posX, ownedItem.fields[20].posZ, ownedItem.fields[20].posX+5,ownedItem.fields[20].posZ-5, ownedItem.fields[20].posX+0.1,  StoryMode.onFieldDataUpdateFinished, self);
			StoryMode.requestedFieldData = true
			FSDensityMapUtil.getFieldStatus(ownedItem.fields[20].posX, ownedItem.fields[20].posZ, ownedItem.fields[20].posX+5,ownedItem.fields[20].posZ-5, ownedItem.fields[20].posX+0.1, ownedItem.fields[20].posZ-0.1, StoryMode.onFieldDataUpdateFinished, StoryMode);
			--FSDensityMapUtil.getFieldStatusAsync(-43, 83, -37, 78, -42.9998, 83.00001,  StoryMode.onFieldDataUpdateFinished, StoryMode);
			--local res = FSDensityMapUtil.getFieldStatus(218.71260062059, -65.571403612696, 223.71260062059, -70.571403394139, 218.71260040203); -- StoryMode.fieldInfoReturnFunction, StoryMode.fieldInfoPassedTable);
			--local res = FSDensityMapUtil:getFieldStatus(218.71260062059, -65.571403612696, 223.71260062059, -70.571403394139, 218.71260040203, StoryMode);
			--if res ~= nil then
				--print("Got result: ");
				--DebugUtil.printTableRecursively(res, "__________________", 0, 1);
			--end;

			--local field = ownedItem.fields[20].setFieldStatusPartitions[1];
			for _,field in pairs(ownedItem.fields[20].getFieldStatusPartitions) do
				

				local retMax, totalMax = FSDensityMapUtil.getFruitArea(1, field.x0, field.z0, field.widthX, field.widthZ, field.heightX, field.heightZ, true, false);
				local retMin, totalMin = FSDensityMapUtil.getFruitArea(1, field.x0, field.z0, field.widthX, field.widthZ, field.heightX, field.heightZ, true, true);
				--local growthState = FieldUtil.getMaxGrowthState(1, ownedItem.fields[20]);
				
				local query = g_currentMission.fieldCropsQuery

				local requiredFruitType = 1;
				local useWindrowed = false;

				if requiredFruitType ~= FruitType.UNKNOWN then
					local ids = g_currentMission.fruits[requiredFruitType]
					if ids ~= nil and ids.id ~= 0 then
						if useWindrowed then
							return 0, 1
						end
						local desc = g_fruitTypeManager:getFruitTypeByIndex(requiredFruitType)
						--query:addRequiredCropType(ids.id, 2+1, 2+1, desc.startStateChannel, desc.numStateChannels, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels)
						
						local x,z, widthX,widthZ, heightX,heightZ = MathUtil.getXZWidthAndHeight(field.x0, field.z0, field.widthX, field.widthZ, field.heightX, field.heightZ)
						
						query:addRequiredCropType(ids.id, 3, 3, desc.startStateChannel, desc.numStateChannels, g_currentMission.terrainDetailTypeFirstChannel, g_currentMission.terrainDetailTypeNumChannels)
						local areaFound, totalArea = query:getParallelogram(x,z, widthX,widthZ, heightX,heightZ, true)
						--print("Field: " .. _ .. " areaFound (3): " .. areaFound .. " totalArea: " .. totalArea .. " x0: " .. field.x0 .. " z0: " .. field.z0 .. " widthX: " .. field.widthX .. " widthZ: " .. field.widthZ .. " heightX: " .. field.heightX .. " heightZ: " .. field.heightZ);
						
					end
				end				
				
				--local x,z, widthX,widthZ, heightX,heightZ = MathUtil.getXZWidthAndHeight(field.x0, field.z0, field.widthX, field.widthZ, field.heightX, field.heightZ)
				--local areaFound, totalArea = query:getParallelogram(x,z, widthX,widthZ, heightX,heightZ, true)
				--print("Field: " .. _ .. " areaFound: " .. areaFound .. " totalArea: " .. totalArea .. " x0: " .. field.x0 .. " z0: " .. field.z0 .. " widthX: " .. field.widthX .. " widthZ: " .. field.widthZ .. " heightX: " .. field.heightX .. " heightZ: " .. field.heightZ);
				
				--print("Conversion: " .. g_currentMission:getFruitPixelsToSqm());
				--getDensityRegionWorld(g_currentMission.fruitsList[1].id, field.x0, field.z0, field.widthX, field.widthZ, field.heightX, field.heightZ, 1, 4);
				--local id = g_currentMission.fruitsList[1].id
				--local desc = g_fruitTypeManager.indexToFruitType[1];

				--setDensityReturnValueShift(id, -1);
				--setDensityCompareParams(id, "between", desc.minHarvestingGrowthState+1, desc.maxHarvestingGrowthState+1);
				
				--local fruit = g_currentMission.fruits[1];
				--getDensityParallelogram
				--getDensityParallelogram
				--local sum  = getDensityParallelogram(g_currentMission.fruitsList[1].id, field.x0, field.z0, field.widthX, field.widthZ, field.heightX, field.heightZ, 1, 4);
				--local sum  = getDensityRegionWorld(g_currentMission.fruitsList[1].id, field.x0, field.z0, field.widthX, field.widthZ, field.heightX, field.heightZ, 1, 4);
				--print("Field: " .. _ .. " sum: " .. sum);

				--setDensityMaskParams(1, "between", 1,8)						
				--local sum = addDensityMaskedParallelogram(1, field.x0, field.z0, field.widthX, field.widthZ, field.heightX, field.heightZ,0, 4, 1, 0, 4, 1)
				--print("Field: " .. _ .. " sum: " .. sum);
				--function FieldUtil.getFruitArea(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, terrainDetailRequiredValueRanges, terrainDetailProhibitValueRanges, requiredFruitType, requiredMinGrowthState, requiredMaxGrowthState, prohibitedFruitType, prohibitedMinGrowthState, prohibitedMaxGrowthState, useWindrowed)
				
				--print("Field: " .. _ .. " GrwothState: " .. growthState);
				--print("Field: " .. _ .. " RetMax: " .. retMax .. " totalMax: " .. totalMax);
				--print("Field: " .. _ .. " RetMin: " .. retMin .. " totalMin: " .. totalMin);
			end;

			for _,player in pairs(g_currentMission.players) do
				x = player.baseInformation.lastPositionX;
				print("x: " .. x);
				z = player.baseInformation.lastPositionZ;
				print("z: " .. z);
			end;

		end;
	end;

	if StoryMode.currentStory < StoryMode.lastStory then
		if StoryMode.currentStoryPresented == false then
			StoryMode.gui.smSettingGui:setStoryTitleField(StoryMode.storyParts[StoryMode.currentStory].titleText);
			StoryMode.gui.smSettingGui:setStoryTextField(StoryMode.storyParts[StoryMode.currentStory].storyText);
			
			if g_gui.currentGui == nil then
				g_gui:showGui("smGui")
				StoryMode.currentStoryPresented = true;

				--DebugUtil.printTableRecursively(g_currentMission,"----",0,1)
				--print("____-----------------g_currentMission.inGameMenu.pageStatistics---------------------___-------------------______________!!!!!!!!!!!!!")
				--print("____-----------------g_currentMission.inGameMenu.pageStatistics---------------------___-------------------______________!!!!!!!!!!!!!")
				--print("____-----------------g_currentMission.inGameMenu.pageStatistics---------------------___-------------------______________!!!!!!!!!!!!!")
				--DebugUtil.printTableRecursively(g_currentMission.fruitsList,"----",0,2)

				
				--print("____-----------------g_currentMission.inGameMenu.baseIngameMap---------------------___-------------------______________!!!!!!!!!!!!!")
				--print("____-----------------g_currentMission.inGameMenu.baseIngameMap---------------------___-------------------______________!!!!!!!!!!!!!")
				--print("____-----------------g_currentMission.inGameMenu.baseIngameMap---------------------___-------------------______________!!!!!!!!!!!!!")
				--DebugUtil.printTableRecursively(g_currentMission.inGameMenu.baseIngameMap,"----",0,2)
				

				--print("____-----------------players---------------------___-------------------______________!!!!!!!!!!!!!")
				--print("____-----------------players---------------------___-------------------______________!!!!!!!!!!!!!")
				--print("____-----------------players---------------------___-------------------______________!!!!!!!!!!!!!")
				--DebugUtil.printTableRecursively(g_currentMission.players,"----",0,2)
				
				--print("____-----------------farmlandManager---------------------___-------------------______________!!!!!!!!!!!!!")
				--print("____-----------------farmlandManager---------------------___-------------------______________!!!!!!!!!!!!!")
				--print("____-----------------farmlandManager---------------------___-------------------______________!!!!!!!!!!!!!")
				--DebugUtil.printTableRecursively(g_currentMission.landscapingController.farmlandManager,"----",0,2)				
			end;
		else
			if g_gui.currentGui == nil then
				local fulfilledOptions = StoryMode:checkRequirements();
				for _,storyOption in pairs(StoryMode.storyParts[StoryMode.currentStory].options) do
					if (fulfilledOptions[storyOption] == true) then
						StoryMode:handleFulFilledStory(storyOption);
					end;
				end;
			end;
		end;
	end;
end;

function StoryMode:checkRequirements()
	local fulfilledOptions = {};
	for _,storyOption in pairs(StoryMode.storyParts[StoryMode.currentStory].options) do
		--print("Checking storyOption: ");
		local fulfilled = true;
		for _,trigger in pairs(storyOption.triggers) do
			--print("Checking trigger: " .. trigger.triggerType);
			local triggerCheck = trigger:checkFulfilled();
			fulfilled = fulfilled and triggerCheck;
		end;

		fulfilledOptions[storyOption] = fulfilled;			
	end;

	return fulfilledOptions;
end;

function StoryMode:handleFulFilledStory(storyOption)
	if storyOption.bonus ~= nil then
		if storyOption.bonus.money ~= nil then
			local owner = g_currentMission.player.farmId
			g_currentMission:addMoney(storyOption.bonus.money, owner, "addMoney");
		end;
	end;
	StoryMode.currentStory = storyOption.nextStory;
	StoryMode.currentStoryPresented = false;
end;

function StoryMode:draw()
	--print("StoryMode - draw");
end; 

function StoryMode:writeConfig()
	--print("StoryMode writeConfig ");

	-- skip on dedicated servers
	if g_dedicatedServerInfo ~= nil then
		return
	end

	--createFolder(getUserProfileAppPath().. "modsSettings/");
	--createFolder(StoryMode.confDirectory);

	local file = StoryMode.confDirectory.. "/" .. myName..".xml"
	local xml
	local groupNameTag
	local group
	xml = createXMLFile("FS19_StoryMode_XML", file, "FS19_StoryModeSettings");		

		if StoryMode ~= nil then  					
			setXMLInt(xml,	"FS19_StoryModeSettings.currentStory(0)#value", StoryMode.currentStory);
			setXMLBool(xml, "FS19_StoryModeSettings.currentStoryPresented(0)#value", StoryMode.currentStoryPresented);			
		end;
	
	saveXMLFile(xml)	
end

function StoryMode:readConfig()	
	--print("StoryMode - readConfig ")

	-- skip on dedicated servers
	if g_dedicatedServerInfo ~= nil then
		return
	end

	local file = StoryMode.confDirectory.. "/" .. myName..".xml"
	local xml
	if not fileExists(file) then
		StoryMode:writeConfig()
	else
		-- load existing XML file
		xml = loadXMLFile("FS19_StoryMode_XML", file, "FS19_StoryModeSettings");
		
		if StoryMode ~= nil then  
			StoryMode.currentStory = getXMLInt(xml,  "FS19_StoryModeSettings.currentStory(0)#value");
			StoryMode.currentStoryPresented = getXMLBool(xml,  "FS19_StoryModeSettings.currentStoryPresented(0)#value");
		end
	end;
end

function StoryMode:readStoryXML()	
	--print("StoryMode - readStoryXML ")

	-- skip on dedicated servers
	if g_dedicatedServerInfo ~= nil then
		return
	end

	local file = StoryMode.storyDirectory.. myName .. "_mainStory.xml"
	local xml
	if fileExists(file) then
		-- load existing XML file
		xml = loadXMLFile("FS19_StoryMode_mainStory_XML", file, "FS19_StoryModeStory");
		
		if StoryMode ~= nil then  
			StoryMode.lastStory = getXMLInt(xml, "FS19_StoryModeStory.storyPartsCount") + 1;
			StoryMode.storyParts = {};
			for i=1, StoryMode.lastStory-1, 1 do
				StoryMode.storyParts[i] = {};
				StoryMode.storyParts[i].titleText = getXMLString(xml, "FS19_StoryModeStory.storyParts.story_" .. i .. ".titleText");
				StoryMode.storyParts[i].storyText = getXMLString(xml, "FS19_StoryModeStory.storyParts.story_" .. i .. ".storyText");

				StoryMode.storyParts[i].options = {};
				local storyOptions = getXMLInt(xml,  "FS19_StoryModeStory.storyParts.story_" .. i .. ".storyOptions");
				
				for storyOption=1, storyOptions, 1 do
					StoryMode.storyParts[i].options[storyOption] = {};
					StoryMode.storyParts[i].options[storyOption].triggers = {};
					
					local triggerCount = getXMLInt(xml,  "FS19_StoryModeStory.storyParts.story_" .. i .. ".triggers_" .. storyOption .. ".triggerCount");
					for trigger=1, triggerCount, 1 do						
						local triggerType = getXMLString(xml,  "FS19_StoryModeStory.storyParts.story_" .. i .. ".triggers_" .. storyOption .. ".trigger_" .. trigger .. "(0)#triggerType");
						local triggerSticks = getXMLBool(xml,  "FS19_StoryModeStory.storyParts.story_" .. i .. ".triggers_" .. storyOption .. ".trigger_" .. trigger .. "(0)#triggerSticks");
						local triggerAttributes = getXMLString(xml,  "FS19_StoryModeStory.storyParts.story_" .. i .. ".triggers_" .. storyOption .. ".trigger_" .. trigger .. "(0)#triggerAttributes");
						local newTrigger = Trigger:new(triggerType, triggerSticks, triggerAttributes);
						StoryMode.storyParts[i].options[storyOption].triggers[trigger] = newTrigger;
					end;
					
					StoryMode.storyParts[i].options[storyOption].bonus = {};
					StoryMode.storyParts[i].options[storyOption].bonus.money = getXMLInt(xml, "FS19_StoryModeStory.storyParts.story_" .. i .. ".bonus_" .. storyOption .. ".money");
				
					StoryMode.storyParts[i].options[storyOption].nextStory = getXMLInt(xml,  "FS19_StoryModeStory.storyParts.story_" .. i .. ".nextStoryPart_" .. storyOption);
					
				end;
			end;
		end
	end;
end

local elementOverlayExists = function(element)
	return element.overlay ~= nil and element.overlay.overlay ~= nil and element.overlay.overlay ~= 0;
end;

function StoryMode:setImageOverlay(element, filePath)
	--print(('\t\tsetImageOverlay(): element=%q, filePath=%q'):format(tostring(element), tostring(filePath)));
	
	if elementOverlayExists(element) then
		delete(element.overlay.overlay);
	end;

	element.overlay.overlay = createImageOverlay(filePath);
	element.overlay.filePath = filePath;	
end;

function StoryMode.setModImages(element, xmlFile, key)
	element.modImgDir = StoryMode.directory .. (getXMLString(xmlFile, key .. "#MOD_imageDir") or "");
	local fileNames = getXMLString(xmlFile, key .. '#MOD_imageFilename');

	if fileNames ~= nil then
		StoryMode:setImageOverlay(element, element.modImgDir .. fileNames);		
	end;
end;

BitmapElement.loadFromXML = Utils.appendedFunction(BitmapElement.loadFromXML,    StoryMode.setModImages);

addModEventListener(StoryMode);
