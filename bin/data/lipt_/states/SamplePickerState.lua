ListCell = class(CameraButton, function(o, x, y, w, h, name)
	local borders = 4
	local rightCol = 100
	if not retina then borders = borders/2; rightCol = rightCol/2 end
	Button.init(o, x, y, w, h)
	
	o.bkg = Object(x, y, w, h)
	o.bkg.tint = {r=224,g=222,b=215}
	o.bkg.sprite = sprites["white.png"]
	o.bkg.layer = 0

	o.topBg = Object(x, y, w, borders)
	o.topBg.tint = {r=210,g=205,b=196}
	o.topBg.sprite = o.bkg.sprite

	o.bottomBg = Object(x, y+h-borders, w, borders)
	o.bottomBg.tint = {r=167,g=160,b=142}
	o.bottomBg.sprite = o.bkg.sprite

	o.name = StringObject(x+rightCol, y+borders*3, name)
	o.name:setColor(155, 148, 142)
	o.name:setLayer(1)
end)

function ListCell:draw()
	self.bkg:drawStretched()
	self.topBg:drawStretched()
	self.bottomBg:drawStretched()
	self.name:draw()
end

-- lists the directories and samples in a directory
-- should be able to load new directories, and when samples are clicked, should load those

SamplePickerState = class(Group, function(o, instrument, directoryStack)
	-- build directory name from the stack

	o.dirName = table.concat(directoryStack, "/")

	Group.init(o)
	
	o.topBar = o:add(Object(0,0, bludG.camera.w, 40))
	o.topBar.sprite = sprites["white.png"]
	o.topBar.drawType = "stretched"
	o.topBar.layer = 2
	o.topBar.scrollFactor = Vec2(0,0)

	o.currentDir = o:add(StringObject(0,0,"/"..o.dirName))
	o.currentDir:setColor(0,0,0)
	-- move to the center of the topBar
	o.currentDir:setScrollFactor(o.topBar.scrollFactor)
	o.currentDir:setPosition(bludG.camera.w/2-o.currentDir.w/2, o.currentDir.pos.y)
	o.currentDir:setLayer(3)

	o.backButton = o:add(RoundedButton(0,0, 80, 80, "BCK"))
	o.backButton.scrollFactor = Vec2(0,0)
	o.backButton:setLayer(2)
	o.backButton.onPress = function()
		mainState = PlayState()
	end
	o:loadDirList(instrument, directoryStack)
end)

function SamplePickerState:loadDirList(instrument, directoryStack)
	-- filesystem
	self.fs = fs
	-- build the buttons
	local fHeight = 144
	local startPos = 80
	if not retina then fHeight = fHeight/2 end
	self.fileList = self:add(Group())

	-- if we are not at the top level then add a back one 
	if #directoryStack > 0 then
		local fbutton = self.fileList:add(ListCell(0, startPos, bludG.camera.w, fHeight, ".. (back)"))
		fbutton.name:setColor(0,0,0)        	
		startPos = startPos + fHeight
    	function fbutton:onPress()
    		-- replace the current view on the stack, move up one folder
    		table.remove(directoryStack)
    		-- reset the camera
    		bludG.camera.scroll.x, bludG.camera.scroll.y = 0, 0
    		mainState.edit = mainState:replaceState(mainState.edit, SamplePickerState(instrument, directoryStack))
    	end
	end
	local filesTable = fs:enumerate(tostring(self.dirName))
    for i,v in ipairs(filesTable) do
    	local file = tostring(self.dirName).."/"..v
		local fbutton = self.fileList:add(ListCell(0, startPos, bludG.camera.w, fHeight, v))
		startPos = startPos + fHeight
		if not fs:isDirectory(file) then
        	function fbutton:onPress()
        		previewSample = SampleData()
				fs:loadSample(file, previewSample)
   				player:preview(previewSample);
        	end
        	-- add a load button
        	local loadButton = self.fileList:add(RoundedButton(bludG.camera.w-80, startPos-fHeight, 60, 60, "LD"))
        	loadButton:setLayer(2)

        	function loadButton:onPress()
        		-- load the sample in the instrument and jump back to the instrument screen
        		-- TODO: get the jumping back to the instrument
   				instrument:setSample(file)
        		-- reset the camera
        		bludG.camera.scroll.x, bludG.camera.scroll.y = 0, 0
   				mainState = PlayState()
        	end
        elseif fs:isDirectory(file) then
			fbutton.name:setColor(0,0,0)        	
        	function fbutton:onPress()
        		-- replace the current view on the stack, with a new view for this new folder
        		table.insert(directoryStack, v)
        		-- reset the camera
        		bludG.camera.scroll.x, bludG.camera.scroll.y = 0, 0
        		mainState.edit = mainState:replaceState(mainState.edit, SamplePickerState(instrument, directoryStack))
        	end
        end
    end
    self.scrollArea = self:add(DragArea(0,0, bludG.camera.w,bludG.camera.h))
	self.scrollArea.onStart = function(da,x, y, id)
		da.starty = y
	end

	self.scrollArea.onMove = function(da,x,y,id)
		diff_y = da.lastPos[id].y-y
		bludG.camera.scroll.y = bludG.camera.scroll.y+diff_y
		if math.abs(y-da.starty) > 20 then
			-- clear all the touches so far
			for i,v in pairs(self.fileList.members) do
				v:clearTouches();
			end
		end
	end
	self.scrollArea.scrollFactor = Vec2(0,0)
	if #self.fileList.members > 0 then
	else
		-- self.loading:setText("No friends found.")
	end
end