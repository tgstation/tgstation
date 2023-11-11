//-------------------- FLOOR PLANE --------------------

///Contains just the floor
/atom/movable/screen/plane_master/floor
	name = "Floor"
	documentation = "The well, floor. This is mostly used as a sorting mechanism, but it also lets us create a \"border\" around the game world plane, so its drop shadow will actually work."
	plane = FLOOR_PLANE
	render_relay_planes = list(RENDER_PLANE_GAME, LIGHT_MASK_PLANE)

/atom/movable/screen/plane_master/transparent_floor
	name = "Transparent Floor"
	documentation = "Really just openspace, stuff that is a turf but has no color or alpha whatsoever.\
		<br>We use this to draw to just the light mask plane, cause if it's not there we get holes of blackness over openspace"
	plane = TRANSPARENT_FLOOR_PLANE
	render_relay_planes = list(LIGHT_MASK_PLANE)
	// Needs to be critical or it uh, it'll look white
	critical = PLANE_CRITICAL_DISPLAY|PLANE_CRITICAL_NO_RELAY

/atom/movable/screen/plane_master/floor/Initialize(mapload, datum/hud/hud_owner, datum/plane_master_group/home, offset)
	. = ..()
	add_relay_to(GET_NEW_PLANE(EMISSIVE_RENDER_PLATE, offset), relay_layer = EMISSIVE_FLOOR_LAYER, relay_color = GLOB.em_block_color)

//-------------------- WALL PLANE --------------------

/atom/movable/screen/plane_master/wall
	name = "Wall"
	documentation = "Holds all walls. We render this onto the game world. Separate so we can use this + space and floor planes as a guide for where byond blackness is NOT."
	plane = WALL_PLANE
	render_relay_planes = list(RENDER_PLANE_GAME_WORLD, LIGHT_MASK_PLANE)

/atom/movable/screen/plane_master/wall/Initialize(mapload, datum/hud/hud_owner, datum/plane_master_group/home, offset)
	. = ..()
	add_relay_to(GET_NEW_PLANE(EMISSIVE_RENDER_PLATE, offset), relay_layer = EMISSIVE_WALL_LAYER, relay_color = GLOB.em_block_color)

/atom/movable/screen/plane_master/wall_upper
	name = "Upper wall"
	documentation = "There are some walls that want to render above most things (mostly minerals since they shift over.\
		<br>We draw them to their own plane so we can hijack them for our emissive mask stuff"
	plane = WALL_PLANE_UPPER
	render_relay_planes = list(RENDER_PLANE_GAME_WORLD, LIGHT_MASK_PLANE)

/atom/movable/screen/plane_master/wall_upper/Initialize(mapload, datum/hud/hud_owner, datum/plane_master_group/home, offset)
	. = ..()
	add_relay_to(GET_NEW_PLANE(EMISSIVE_RENDER_PLATE, offset), relay_layer = EMISSIVE_WALL_LAYER, relay_color = GLOB.em_block_color)

//-------------------- AREA PLANE --------------------

/atom/movable/screen/plane_master/area
	name = "Area"
	documentation = "Holds the areas themselves, which ends up meaning it holds any overlays/effects we apply to areas. NOT snow or rad storms, those go on above lighting"
	plane = AREA_PLANE

//-------------------- GAME PLANES --------------------

/atom/movable/screen/plane_master/game
	name = "Lower game world"
	documentation = "Exists mostly because of FOV shit. Basically, if you've just got a normal not ABOVE fov thing, and you don't want it masked, stick it here yeah?"
	plane = GAME_PLANE
	render_relay_planes = list(RENDER_PLANE_GAME_WORLD)

/atom/movable/screen/plane_master/high_game
	name = "High Game"
	documentation = "Holds anything that wants to be displayed above the rest of the game plane, and doesn't want to be clickable. \
		<br>This includes atmos debug overlays, blind sound images, and mining scanners. \
		<br>Really only exists for its layering potential, we don't use this for any vfx"
	plane = HIGH_GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

//-------------------- FOV PLANES --------------------

/atom/movable/screen/plane_master/game_world_fov_hidden
	name = "lower game world fov hidden"
	documentation = "If you want something to be hidden by fov, stick it on this plane. We're masked by the fov blocker plane, so the items on us can actually well, disappear."
	plane = GAME_PLANE_FOV_HIDDEN
	render_relay_planes = list(RENDER_PLANE_GAME_WORLD)

/atom/movable/screen/plane_master/game_world_fov_hidden/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	add_filter("vision_cone", 1, alpha_mask_filter(render_source = OFFSET_RENDER_TARGET(FIELD_OF_VISION_BLOCKER_RENDER_TARGET, offset), flags = MASK_INVERSE))

/atom/movable/screen/plane_master/field_of_vision_blocker
	name = "Field of vision blocker"
	documentation = "This is one of those planes that's only used as a filter. It masks out things that want to be hidden by fov.\
		<br>Literally just contains FOV images, or masks."
	plane = FIELD_OF_VISION_BLOCKER_PLANE
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	render_target = FIELD_OF_VISION_BLOCKER_RENDER_TARGET
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_planes = list()
	// We do NOT allow offsetting, because there's no case where you would want to block only one layer, at least currently
	allows_offsetting = FALSE
	start_hidden = TRUE
	// We mark as multiz_scaled FALSE so transforms don't effect us, and we draw to the planes below us as if they were us.
	// This is safe because we will ALWAYS be on the top z layer, so it DON'T MATTER
	multiz_scaled = FALSE

/atom/movable/screen/plane_master/field_of_vision_blocker/Initialize(mapload, datum/hud/hud_owner, datum/plane_master_group/home, offset)
	. = ..()
	mirror_parent_hidden()

/atom/movable/screen/plane_master/game_world_above
	name = "Above game world"
	documentation = "We need a place that's unmasked by fov that also draws above the upper game world fov hidden plane. I told you fov was hacky man."
	plane = ABOVE_GAME_PLANE
	render_relay_planes = list(RENDER_PLANE_GAME_WORLD)

/atom/movable/screen/plane_master/game_world_upper
	name = "Upper game world"
	documentation = "Ok so fov is kinda fucky, because planes in byond serve both as effect groupings and as rendering orderers. Since that's true, we need a plane that we can stick stuff that draws above fov blocked stuff on."
	plane = GAME_PLANE_UPPER
	render_relay_planes = list(RENDER_PLANE_GAME_WORLD)

/atom/movable/screen/plane_master/game_world_upper_fov_hidden
	name = "Upper game world fov hidden"
	documentation = "Just as we need a place to draw things \"above\" the hidden fov plane, we also need to be able to hide stuff that draws over the upper game plane."
	plane = GAME_PLANE_UPPER_FOV_HIDDEN
	render_relay_planes = list(RENDER_PLANE_GAME_WORLD)

/atom/movable/screen/plane_master/game_world_upper_fov_hidden/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	// Dupe of the other hidden plane
	add_filter("vision_cone", 1, alpha_mask_filter(render_source = OFFSET_RENDER_TARGET(FIELD_OF_VISION_BLOCKER_RENDER_TARGET, offset), flags = MASK_INVERSE))
