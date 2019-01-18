--
-- StoryMode GUI
-- V1.0.0.0
--
-- @author Stephan Schlosser
-- @date 11/01/2019

smGui = {};

local smGui_mt = Class(smGui, ScreenElement);

function smGui:new(target, custom_mt)
    local self = ScreenElement:new(target, smGui_mt);
    self.returnScreenName = "";
    return self;	
end;

function smGui:onOpen()
    smGui:superClass().onOpen(self);
	FocusManager:setFocus(self.backButton);
end;

function smGui:onClose()
    smGui:superClass().onClose(self);
end;

function smGui:onClickBack()
    smGui:superClass().onClickBack(self);
	StoryMode:guiClosed();
end;

function smGui:onClickOk()
    smGui:superClass().onClickOk(self);
	StoryMode:settingsFromGui();
    self:onClickBack();
end;

function smGui:onIngameMenuHelpTextChanged(element)
end;

function smGui:onCreatesmGuiHeader(element)    
    smGui.header = element;
	element.text = g_i18n:getText('gui_sm_Setting');
end;

function smGui:onClickResetButton()
    StoryMode:settingsResetGui();
end;

function smGui:onCreatesmStoryTextField(element)    
    smGui.storyTextField = element;
end;

function smGui:setStoryTextField(storyText)    
    smGui.storyTextField.text = storyText;
end;

function smGui:setStoryTitleField(storyTitle)    
    smGui.header.text = storyTitle;
end;