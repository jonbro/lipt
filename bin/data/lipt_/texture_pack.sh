TexturePacker --trim --format corona --data cute_list-hd.lua --algorithm MaxRects --extrude 1 --width 512 --height 512 --maxrects-heuristics best --verbose --sheet assets/cute@2x.png ungrouped_sprites/*;
TexturePacker --trim --format corona --data cute_list.lua --algorithm MaxRects --width 256 --height 256 --extrude 1 --maxrects-heuristics best --verbose --scale 0.5 --padding 0 --reduce-border-artifacts --sheet assets/cute.png ungrouped_sprites/*;

# sed -i"" "/module/d" cute_list.lua;
# sed -i"" "/module/d" cute_list-hd.lua;

# TexturePacker --auto-sd --trim --format corona --data serenade_list-hd.lua --width 1024 --height 1024 --algorithm MaxRects --padding 1 --sheet assets/serenade@2x.png ../../../ungrouped_sprites_serenade/*;
# sed -i"" "/module/d" serenade_list.lua;
# sed -i"" "/module/d" serenade_list-hd.lua;