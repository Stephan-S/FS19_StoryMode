StoryMode = {};
StoryMode.Version = "1.0.0";
StoryMode.config_changed = false;
local myName = "FS19_StoryMode";

StoryMode.directory = g_currentModDirectory;
StoryMode.modStoryDirectory = g_currentModDirectory .. "story/";
StoryMode.customStoryDirectory = getUserProfileAppPath().. "StoryModeStories/"; 

source(Utils.getFilename("gui/smGui.lua", g_currentModDirectory))
source(Utils.getFilename("Trigger.lua", g_currentModDirectory))
source(Utils.getFilename("TriggerCallback.lua", g_currentModDirectory))

StoryMode.currentStory = 1;
StoryMode.currentStoryPresented = false;
StoryMode.lastStory = 3;
StoryMode.waitTime = 2000;
StoryMode.waitTimeConstant = 10000;
StoryMode.storedFieldInfoVariables = false;
StoryMode.timeSinceLastTrigger = 0;

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
	StoryMode.confDirectory = g_currentMission.missionInfo.savegameDirectory;
	StoryMode:readStoryXML()	
	StoryMode:readConfig();

	-- Save Story when saving savegame
	FSBaseMission.saveSavegame = Utils.appendedFunction(FSBaseMission.saveSavegame, StoryMode.saveSavegame);

    -- Only needed for global action event 
    FSBaseMission.registerActionEvents = Utils.appendedFunction(FSBaseMission.registerActionEvents, StoryMode.registerActionEventsMenu);
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

function StoryMode:printUnknownMethodParameters(a,b,c,d,e,f,g,h,i,j)	
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
	StoryMode.timeSinceLastTrigger = StoryMode.timeSinceLastTrigger + (dt/1000.0); 
	if StoryMode.waitTime > 0 then
		return;
	end;
	
	StoryMode.waitTime = StoryMode.waitTimeConstant;
	--print("StoryMode - update(dt) " .. StoryMode.currentStory .. "/" .. StoryMode.lastStory);
	
	--DebugUtil.printTableRecursively(g_currentMission.objectsToClassName, "-----", 0, 1);
	--print("Map title: " ..  g_currentMission.missionInfo.map.title);

	

	if StoryMode.currentStory < StoryMode.lastStory then
		if StoryMode.currentStoryPresented == false then
			StoryMode.gui.smSettingGui:setStoryTitleField(StoryMode.storyParts[StoryMode.currentStory].titleText);
			StoryMode.gui.smSettingGui:setStoryTextField(StoryMode.storyParts[StoryMode.currentStory].storyText);
			
			if g_gui.currentGui == nil then
				g_gui:showGui("smGui")
				StoryMode.currentStoryPresented = true;						
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
			--if triggerCheck then
				--print ("Trigger " .. trigger.triggerType .. " fulfilled")
			--else				
				--print ("Trigger " .. trigger.triggerType .. " not fulfilled")
			--end;
			fulfilled = fulfilled and triggerCheck;
		end;

		fulfilledOptions[storyOption] = fulfilled;			
	end;

	return fulfilledOptions;
end;

function StoryMode:handleFulFilledStory(storyOption)
	print("StoryMode - handling fulfilled Story");
	if storyOption.bonus ~= nil then
		if storyOption.bonus.money ~= nil then
			local owner = g_currentMission.player.farmId
			g_currentMission:addMoney(storyOption.bonus.money, owner, "addMoney");
		end;
	end;
	StoryMode.currentStory = storyOption.nextStory;
	StoryMode.currentStoryPresented = false;
	StoryMode.timeSinceLastTrigger = 0;
	StoryMode:setImageOverlay(StoryMode.guiImageElement, StoryMode.storyParts[StoryMode.currentStory].image);
	
	if StoryMode.HotSpots ~= nil then
		for _,hotspot in pairs(StoryMode.HotSpots) do
			g_currentMission.removeMapHotspot(hotspot);
		end;
		StoryMode.HotSpots = nil;
	end;
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

	
	if StoryMode.confDirectory == nil then		
		StoryMode.confDirectory = g_currentMission.missionInfo.savegameDirectory;
	end;

	if StoryMode.confDirectory ~= nil then
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
	end;
end

function StoryMode:readConfig()	
	--print("StoryMode - readConfig ")

	-- skip on dedicated servers
	if g_dedicatedServerInfo ~= nil then
		return
	end
	if StoryMode.confDirectory ~= nil then
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
				
				StoryMode:setImageOverlay(StoryMode.guiImageElement, StoryMode.storyParts[StoryMode.currentStory].image);
				StoryMode.gui.smSettingGui:setStoryTitleField(StoryMode.storyParts[StoryMode.currentStory].titleText);
				StoryMode.gui.smSettingGui:setStoryTextField(StoryMode.storyParts[StoryMode.currentStory].storyText);				
			end

		end;
	end;
end

function StoryMode:readStoryXML()	
	--print("StoryMode - readStoryXML ")

	-- skip on dedicated servers
	if g_dedicatedServerInfo ~= nil then
		return
	end

	createFolder(StoryMode.customStoryDirectory);

	local mapName =  g_currentMission.missionInfo.map.title;

	local customFile = StoryMode.customStoryDirectory .. mapName .. "_Story.xml";
	print("Customfile: " .. customFile);
	local modFile = StoryMode.modStoryDirectory.. myName .. "_" .. mapName .. "_mainStory.xml"
	local file = modFile;

	if fileExists(customFile) then
		file = customFile;
		print("Customfile exists");
	end;

	--local file = StoryMode.modStoryDirectory.. myName .. "_mainStory.xml"
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

				local includedInMod =  getXMLBool(xml, "FS19_StoryModeStory.storyParts.story_" .. i .. ".storyImage(0)#includedInMod");
				local includedInAppFolder =  getXMLBool(xml, "FS19_StoryModeStory.storyParts.story_" .. i .. ".storyImage(0)#includedInAppFolder");
				local imagePath = getXMLString(xml, "FS19_StoryModeStory.storyParts.story_" .. i .. ".storyImage(0)#name_or_path");

				if includedInMod then
					StoryMode.storyParts[i].image = StoryMode.directory .. imagePath;
				elseif includedInAppFolder then
					StoryMode.storyParts[i].image = getUserProfileAppPath() .. imagePath;
				else
					StoryMode.storyParts[i].image = StoryMode.directory .. "img/Tom.dds";
				end;

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

function StoryMode:addHotSpot(hotspot) 
	if StoryMode.HotSpots == nil then
		StoryMode.HotSpots = {};
	end;

	StoryMode.HotSpots[tablelength(StoryMode.HotSpots)+1] = hotspot;
end

function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
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
	
	StoryMode.guiImageElement = element;
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
