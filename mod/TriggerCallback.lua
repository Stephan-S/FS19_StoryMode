TriggerCallback = {};

function TriggerCallback:new(trigger, partition, part)
    o = {}
    setmetatable(o, self)
    self.__index = self
    o.trigger = trigger;
    o.partition = partition;
    o.part = part;
    return o
end;

function TriggerCallback:onFieldDataUpdateFinished(fielddata)
    if fielddata ~= nil and self.trigger ~= nil then
        self.trigger:onFieldDataUpdateFinished(fielddata, self.partition, self.part);
    end;
end;    