/**
 * ## catwalk flooring
 *
 * They show what's underneath their catwalk flooring (pipes and the like)
 * you can screwdriver it to interact with the underneath stuff without destroying the tile...
 * unless you want to!
 */
/turf/open/floor/plating/catwalk_floor
	icon = 'icons/turf/floors/catwalk_plating.dmi'
	icon_state = "catwalk_below"
	name = "catwalk floor"
	desc = "Flooring that shows its contents underneath. Engineers love it!"
	baseturfs = /turf/open/floor/plating
	floor_tile = /obj/item/stack/tile/catwalk_tile
	footstep = FOOTSTEP_CATWALK
	barefootstep = FOOTSTEP_CATWALK
	clawfootstep = FOOTSTEP_CATWALK
	heavyfootstep = FOOTSTEP_CATWALK
	var/covered = TRUE

/turf/open/floor/plating/catwalk_floor/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/turf/open/floor/plating/catwalk_floor/update_overlays()
	. = ..()
	var/static/image/catwalk_overlay
	if(isnull(catwalk_overlay))
		catwalk_overlay = new()
		catwalk_overlay.icon = icon
		catwalk_overlay.icon_state = "catwalk_above"
		catwalk_overlay.plane = GAME_PLANE
		catwalk_overlay.layer = CATWALK_LAYER
		catwalk_overlay = catwalk_overlay.appearance
	if(covered)
		. += catwalk_overlay

/turf/open/floor/plating/catwalk_floor/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	covered = !covered
	user.balloon_alert(user, "[!covered ? "cover removed" : "cover added"]")
	update_icon(UPDATE_OVERLAYS)

/turf/open/floor/plating/catwalk_floor/pry_tile(obj/item/crowbar, mob/user, silent)
	if(covered)
		user.balloon_alert(user, "remove cover first!")
		return FALSE
	. = ..()
