StoryMode = {};
StoryMode.Version = "1.0.0";
StoryMode.config_changed = false;
local myName = "FS19_StoryMode";

StoryMode.directory = g_currentModDirectory;
StoryMode.storyDirectory = g_currentModDirectory .. "story/";

source(Utils.getFilename("gui/smGui.lua", g_currentModDirectory))

StoryMode.currentStory = 1;
StoryMode.currentStoryPresented = false;
StoryMode.lastStory = 3;

--StoryMode.storyParts = {};
--StoryMode.storyParts[1] = {};
--StoryMode.storyParts[1].titleText = "Introductions";
--StoryMode.storyParts[1].storyText = "Hello there buddy. My name is Thomas Witherfield and I am the mayor of Felsbrunn! I heard you are interested in starting a farm here. Here is the deal: I offer you a starter loan and in exchange you are going to follow my plans. See, i have a vision in my mind of how we can make Felsbrunn so much more attractive to tourists and turn the fields around here into a beautiful scenery of growing plants of all variety and animals living in free range. Do you accept?";
--StoryMode.storyParts[1].requirements = {};
--StoryMode.storyParts[1].bonus = {};
--StoryMode.storyParts[1].bonus.money = 500000;

--StoryMode.storyParts[2] = {};
--StoryMode.storyParts[2].titleText = "Buy your first patch of land";
--StoryMode.storyParts[2].storyText = "Hello there buddy. I am glad you accepted my proposal. So let's get started, we have so much work ahead of us. Felsbrunn will become the greatest town. I am so glad I finally found someone willing to put in all the work. Let us start of by buying a patch of land to build you a farmhouse on. I would suggest field number 20, it has a lot of space for buildings and is not to expensive.";
--StoryMode.storyParts[2].requirements = {};
--StoryMode.storyParts[2].requirements.fields = {};
--StoryMode.storyParts[2].requirements.fields[1] = {};
--StoryMode.storyParts[2].requirements.fields[1].number = 18;
--StoryMode.storyParts[2].requirements.fields[1].farmLandID = 29;
--StoryMode.storyParts[2].requirements.fields[1].owned = true;
--StoryMode.storyParts[2].requirements.fields[1].crop = 0; --0 = any, otherwise, id of crop
--StoryMode.storyParts[2].requirements.property = {"FarmhousePlaceable"};
--StoryMode.storyParts[2].bonus = {};
--StoryMode.storyParts[2].bonus.money = 200000;


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
    print("StoryMode registerActionEventsMenu")
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
				if StoryMode:checkRequirements() == true then
					print("StoryMode - Requirements for " .. StoryMode.currentStory .. " fulfilled");

					StoryMode:handleBonus();

					StoryMode.currentStory = StoryMode.currentStory + 1;
					StoryMode.currentStoryPresented = false;
				end;
			end;
		end;
	end;
end;

function StoryMode:checkRequirements()
	if StoryMode.storyParts[StoryMode.currentStory].requirements == nil then
		return true;
	else
		local fulfilled = true;
		
		if StoryMode.storyParts[StoryMode.currentStory].requirements.fields ~= nil then
			fulfilled = fulfilled and StoryMode:checkRequirementFields();
		end;
		
		if StoryMode.storyParts[StoryMode.currentStory].requirements.property ~= nil then
			fulfilled = fulfilled and StoryMode:checkRequirementProperty();
		end;

		return fulfilled;
	end;

	return false;
end;

function StoryMode:checkRequirementProperty()
	if StoryMode.storyParts[StoryMode.currentStory].requirements.property == nil then
		return true;
	else
		local fulfilled = true;
		
		for _,propertyName in pairs( StoryMode.storyParts[StoryMode.currentStory].requirements.property ) do
			local propFound = false;
			for _,className in pairs( g_currentMission.objectsToClassName ) do
				--print("StoryMode - comparing " .. propertyName .. " with " .. className) ;
				if className == propertyName then
					propFound = true;
				end;
			end

			if propFound == false then
				fulfilled = false;
			end;
		end 

		return fulfilled;
	end;

	return false;
end;

function StoryMode:checkRequirementFields()
	if StoryMode.storyParts[StoryMode.currentStory].requirements.fields == nil then
		return true;
	else
		local fulfilled = true;
		
		for _,fieldDesc in pairs( StoryMode.storyParts[StoryMode.currentStory].requirements.fields ) do
			if fieldDesc.owned == true then
				fulfilled = fulfilled and g_currentMission.landscapingController.farmlandManager.farmlands[fieldDesc.farmLandID].isOwned;
			end;
		end 

		return fulfilled;
	end;

	return false;
end;

function StoryMode:handleBonus()
	if StoryMode.storyParts[StoryMode.currentStory].bonus ~= nil then
		if StoryMode.storyParts[StoryMode.currentStory].bonus.money ~= nil then
			local owner = g_currentMission.player.farmId
			g_currentMission:addMoney(StoryMode.storyParts[StoryMode.currentStory].bonus.money, owner, "addMoney");
		end;
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

				StoryMode.storyParts[i].requirements = {};
				
				StoryMode.storyParts[i].requirements.fields = {};
				local fieldRequirements = getXMLInt(xml, "FS19_StoryModeStory.storyParts.story_" .. i .. ".requirements.fieldRequirements");
				for r=1, fieldRequirements, 1 do
					StoryMode.storyParts[i].requirements.fields[r] = {};
					StoryMode.storyParts[i].requirements.fields[r].number = getXMLInt(xml, "FS19_StoryModeStory.storyParts.story_" .. i .. ".requirements.fields.field_" .. r .. "(0)#number");
					StoryMode.storyParts[i].requirements.fields[r].farmLandID = getXMLInt(xml, "FS19_StoryModeStory.storyParts.story_" .. i .. ".requirements.fields.field_" .. r .. "(0)#farmLandID");
					StoryMode.storyParts[i].requirements.fields[r].owned = getXMLBool(xml, "FS19_StoryModeStory.storyParts.story_" .. i .. ".requirements.fields.field_" .. r .. "(0)#owned");
					StoryMode.storyParts[i].requirements.fields[r].crop = getXMLInt(xml, "FS19_StoryModeStory.storyParts.story_" .. i .. ".requirements.fields.field_" .. r .. "(0)#crop");
				end;

				StoryMode.storyParts[i].requirements.property = {};
				local propertyRequirements = getXMLInt(xml, "FS19_StoryModeStory.storyParts.story_" .. i .. ".requirements.propertyRequirements");
				for p=1, propertyRequirements, 1 do
					StoryMode.storyParts[i].requirements.property[p] = getXMLString(xml, "FS19_StoryModeStory.storyParts.story_" .. i .. ".requirements.property.property_" .. p);
				end;

				StoryMode.storyParts[i].bonus = {};
				StoryMode.storyParts[i].bonus.money = getXMLInt(xml, "FS19_StoryModeStory.storyParts.story_" .. i .. ".bonus.money");
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
