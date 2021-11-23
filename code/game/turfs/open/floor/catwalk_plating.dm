/**
 * ## catwalk flooring
 *
 * They show what's underneath their catwalk flooring (pipes and the like)
 * you can screwdriver it to interact with the underneath stuff without destroying the tile...
 * unless you want to!
 */
/turf/open/floor/catwalk_floor	//the base type, meant to look like a maintinence panel
	icon = 'icons/turf/floors/catwalk_plating.dmi'
	icon_state = "maint_below"
	name = "catwalk floor"
	desc = "Flooring that shows its contents underneath. Engineers love it!"
	baseturfs = /turf/open/floor/plating
	floor_tile = /obj/item/stack/tile/catwalk_tile
	footstep = FOOTSTEP_CATWALK
	overfloor_placed = TRUE
	underfloor_accessibility = UNDERFLOOR_VISIBLE
	var/covered = TRUE
	var/above_state = "maint_above"	//Icon-state for the overlay


/turf/open/floor/catwalk_floor/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/turf/open/floor/catwalk_floor/update_overlays()
	. = ..()
	var/image/catwalk_overlay	///Per-tile instead of static, so we can have multiple different types of catwalk
	if(isnull(catwalk_overlay))
		catwalk_overlay = new()
		catwalk_overlay.icon = icon
		catwalk_overlay.icon_state = "[above_state]"
		catwalk_overlay.plane = GAME_PLANE
		catwalk_overlay.layer = CATWALK_LAYER
		catwalk_overlay = catwalk_overlay.appearance
	if(covered)
		. += catwalk_overlay

/turf/open/floor/catwalk_floor/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	covered = !covered
	if(!covered)
		underfloor_accessibility = UNDERFLOOR_INTERACTABLE
	else
		underfloor_accessibility = UNDERFLOOR_VISIBLE
	user.balloon_alert(user, "[!covered ? "cover removed" : "cover added"]")
	update_icon(UPDATE_OVERLAYS)

/turf/open/floor/catwalk_floor/crowbar_act(mob/user, obj/item/crowbar)
	if(covered)
		user.balloon_alert(user, "remove cover first!")
		return FALSE
	. = ..()


//Reskins! More fitting with most of our tiles, and appear as a radial on the base type
/turf/open/floor/catwalk_floor/iron
	name = "iron plated catwalk floor"
	icon_state = "iron_below"
	above_state = "iron_above"
	floor_tile = /obj/item/stack/tile/catwalk_tile/iron

/turf/open/floor/catwalk_floor/iron_white
	name = "white plated catwalk floor"
	icon_state = "whiteiron_below"
	above_state = "whiteiron_above"
	floor_tile = /obj/item/stack/tile/catwalk_tile/iron_white

/turf/open/floor/catwalk_floor/iron_dark
	name = "dark plated catwalk floor"
	icon_state = "darkiron_below"
	above_state = "darkiron_above"
	floor_tile = /obj/item/stack/tile/catwalk_tile/iron_dark

/turf/open/floor/catwalk_floor/flat_white
	name = "white large plated catwalk floor"
	icon_state = "flatwhite_below"
	above_state = "flatwhite_above"
	floor_tile = /obj/item/stack/tile/catwalk_tile/flat_white

/turf/open/floor/catwalk_floor/titanium
	name = "titanium plated catwalk floor"
	icon_state = "titanium_below"
	above_state = "titanium_above"
	floor_tile = /obj/item/stack/tile/catwalk_tile/titanium

/turf/open/floor/catwalk_floor/iron_smooth //the original green type
	name = "smooth plated catwalk floor"
	icon_state = "smoothiron_below"
	above_state = "smoothiron_above"
	floor_tile = /obj/item/stack/tile/catwalk_tile/iron_smooth
