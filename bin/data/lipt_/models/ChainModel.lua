numPositions = 16
LChainModel = class(function(o, chainData)
	o.chainData = chainData
	o.steps = {}
	-- setup the steps in the chain
	for i=0,numPositions-1 do
		o.steps[i] = {hasPhrase=false,phrase=0}
	end

end)

function LChainModel:set(step, value)
	self.chainData:set(step, value)
	self.steps[step] = {hasPhrase=true,phrase=value}
end

function LChainModel:saveTo(data)
	data.steps = self.steps
	return data
end
function LChainModel:loadFrom(data)
	for i,v in pairs(data.steps) do
		if v.hasPhrase then
			self:set(i, v.phrase)
		end
	end	
end