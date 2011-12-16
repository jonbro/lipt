RoundedRect = class(RoundedButton, function(o, x, y, w, h)
	RoundedButton.init(o, x, y, w, h, nil)
	o.templateSprite = "rounded"
	o:setPosition(o.pos.x, o.pos.y)
end)
