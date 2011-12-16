-- lua file to generate a header containing a few sprites for use in the loading screen

-- these are the defaults that I use in blud
--[[
static animation_t walkAnimation = {
		// setup the defaults for the animation
		ani.index			= 0;
		ani.frame			= 0;
		ani.total_frames	= 1;
		ani.w				= 1;
		ani.h				= 1;
		ani.frame_duration	= 75;
		ani.next_tick		= 0;
		ani.loops			= -1;
		ani.final_index		= -1;
		ani.frame_skip		= 1;
		
		ani.tex_y = 0;					// how much offset from the top left of the sheet the texture is (no longer using the index for lookups)
		ani.tex_x = 0;					// doing it this way so that we can have differently sized textures
		ani.tex_w = 0;					// how big the texture is (on the sheet)
		ani.tex_h = 0;
		
		ani.sprite_x = 0;					// how far offset the display of the sprite should be from the requested display position (how much alpha got trimmed when packing the sprite)
		ani.sprite_y = 0;
		ani.spritesource_w = 0;			// the size of the sprite before the alpha trimming took place
		ani.spritesource_h = 0;			// used for doing rotations around the center of the sprite (maybe, used for nothing for now)			
	}
--]]
for i, v in ipairs(list.frames) do
sprite_text = [[
static animation_t walkAnimation = {
	0,
	0,
	1,
	]] .. v.spriteSourceSize.width/spriteSize .. [[,
	]] .. v.spriteSourceSize.height/spriteSize .. [[,
	
	]] .. v.textureRect.y .. [[,
	]] .. v.textureRect.x .. [[,
	]] .. v.textureRect.width .. [[,
	]] .. v.textureRect.height .. [[,
	
	]] .. v.spriteColorRect.x .. [[,
	]] .. v.spriteColorRect.y .. [[,
	]] .. v.spriteSourceSize.width .. [[,
	]] .. v.spriteSourceSize.height .. [[,

	75,
	0,	
	-1,
	-1,
	1
};
]]
end