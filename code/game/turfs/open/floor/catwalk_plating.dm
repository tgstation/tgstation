/**
 * ## catwalk flooring
 *
 * They show what's underneath their catwalk flooring (pipes and the like)
 * you can screwdriver it to interact with the underneath stuff without destroying the tile...
 * unless you want to!
 */
/turf/open/floor/catwalk_floor	//the base type, meant to look like a maintenance panel
	icon = 'icons/turf/floors/catwalk_plating.dmi'
	icon_state = "maint_above"
	name = "catwalk floor"
	desc = "Flooring that shows its contents underneath. Engineers love it!"
	baseturfs = /turf/open/floor/plating
	floor_tile = /obj/item/stack/tile/catwalk_tile
	layer = CATWALK_LAYER
	plane = GAME_PLANE
	footstep = FOOTSTEP_CATWALK
	overfloor_placed = TRUE
	underfloor_accessibility = UNDERFLOOR_VISIBLE
	var/covered = TRUE
	var/catwalk_type = "maint"
	var/static/list/catwalk_underlays = list()

/turf/open/floor/catwalk_floor/Initialize(mapload)
	. = ..()
	if(!catwalk_underlays[catwalk_type])
		var/mutable_appearance/plating_underlay = mutable_appearance(icon, "[catwalk_type]_below", TURF_LAYER)
		catwalk_underlays[catwalk_type] = plating_underlay
	underlays += catwalk_underlays[catwalk_type]
	update_appearance()

/turf/open/floor/catwalk_floor/examine(mob/user)
	. = ..()

	if(covered)
		. += span_notice("You can <b>unscrew</b> it to reveal the contents beneath.")
	else
		. += span_notice("You can <b>screw</b> it to hide the contents beneath.")
		. += span_notice("There's a <b>small crack</b> on the edge of it.")

/turf/open/floor/catwalk_floor/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	covered = !covered
	if(!covered)
		underfloor_accessibility = UNDERFLOOR_INTERACTABLE
		layer = TURF_LAYER
		plane = FLOOR_PLANE
		icon_state = "[catwalk_type]_below"
	else
		underfloor_accessibility = UNDERFLOOR_VISIBLE
		layer = CATWALK_LAYER
		plane = GAME_PLANE
		icon_state = "[catwalk_type]_above"
	user.balloon_alert(user, "[!covered ? "cover removed" : "cover added"]")
	tool.play_tool_sound(src)
	update_appearance()

/turf/open/floor/catwalk_floor/crowbar_act(mob/user, obj/item/crowbar)
	if(covered)
		user.balloon_alert(user, "remove cover first!")
		return FALSE
	. = ..()

//Reskins! More fitting with most of our tiles, and appear as a radial on the base type
/turf/open/floor/catwalk_floor/iron
	name = "iron plated catwalk floor"
	icon_state = "iron_above"
	floor_tile = /obj/item/stack/tile/catwalk_tile/iron
	catwalk_type = "iron"


/turf/open/floor/catwalk_floor/iron_white
	name = "white plated catwalk floor"
	icon_state = "whiteiron_above"
	floor_tile = /obj/item/stack/tile/catwalk_tile/iron_white
	catwalk_type = "whiteiron"

/turf/open/floor/catwalk_floor/iron_dark
	name = "dark plated catwalk floor"
	icon_state = "darkiron_above"
	floor_tile = /obj/item/stack/tile/catwalk_tile/iron_dark
	catwalk_type = "darkiron"

/turf/open/floor/catwalk_floor/flat_white
	name = "white large plated catwalk floor"
	icon_state = "flatwhite_above"
	floor_tile = /obj/item/stack/tile/catwalk_tile/flat_white
	catwalk_type = "flatwhite"

/turf/open/floor/catwalk_floor/titanium
	name = "titanium plated catwalk floor"
	icon_state = "titanium_above"
	floor_tile = /obj/item/stack/tile/catwalk_tile/titanium
	catwalk_type = "titanium"

/turf/open/floor/catwalk_floor/iron_smooth //the original green type
	name = "smooth plated catwalk floor"
	icon_state = "smoothiron_above"
	floor_tile = /obj/item/stack/tile/catwalk_tile/iron_smooth
	catwalk_type = "smoothiron"
