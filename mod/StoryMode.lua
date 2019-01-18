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

function StoryMode:update(dt)
	StoryMode.waitTime - dt;
	if StoryMode.waitTime > 0 then
		return;
	end;
	
	StoryMode.waitTime = StoryMode.waitTimeConstant;
	--print("StoryMode - update(dt)");

	if StoryMode.currentStory < StoryMode.lastStory then
		if StoryMode.currentStoryPresented == false then
			StoryMode.gui.smSettingGui:setStoryTitleField(StoryMode.storyParts[StoryMode.currentStory].titleText);
			StoryMode.gui.smSettingGui:setStoryTextField(StoryMode.storyParts[StoryMode.currentStory].storyText);
			
			if g_gui.currentGui == nil then
				g_gui:showGui("smGui")
				StoryMode.currentStoryPresented = true;

				--DebugUtil.printTableRecursively(g_currentMission,"----",0,1)
				--print("____-----------------Owned Items---------------------___-------------------______________!!!!!!!!!!!!!")
				--print("____-----------------Owned Items---------------------___-------------------______________!!!!!!!!!!!!!")
				--print("____-----------------Owned Items---------------------___-------------------______________!!!!!!!!!!!!!")
				--DebugUtil.printTableRecursively(g_currentMission.ownedItems,"----",0,2)

				
				--print("____-----------------objectsToClassName---------------------___-------------------______________!!!!!!!!!!!!!")
				--print("____-----------------objectsToClassName---------------------___-------------------______________!!!!!!!!!!!!!")
				--print("____-----------------objectsToClassName---------------------___-------------------______________!!!!!!!!!!!!!")
				--DebugUtil.printTableRecursively(g_currentMission.objectsToClassName,"----",0,2)

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
