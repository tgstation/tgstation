/**
 * ## catwalk flooring
 *
 * They show what's underneath their catwalk flooring (pipes and the like)
 * you can crowbar it to interact with the underneath stuff without destroying the tile...
 * unless you want to!
 */
/turf/open/floor/catwalk_flooring
	icon = 'icons/turf/floors/catwalk_flooring.dmi'
	icon_state = "catwalk_below"
	name = "catwalk flooring"
	desc = "Flooring that shows its contents underneath. Engineers love it!"
	shoefootstep = FOOTSTEP_CATWALK
	barefootstep = FOOTSTEP_CATWALK
	mediumxenofootstep = FOOTSTEP_CATWALK
	var/base_state = "flooring" //Post mapping
	var/covered = TRUE

/turf/open/floor/catwalk_flooring/Initialize()
	. = ..()
	update_overlays()

/turf/open/floor/catwalk_flooring/update_overlays()
	. = ..()
	var/static/catwalk_overlay
	if(isnull(catwalk_overlay))
		catwalk_overlay = iconstate2appearance(icon, "catwalk_above")
	if(covered)
		add_overlay(catwalk_overlay)

/turf/open/floor/catwalk_flooring/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	cover = !cover
	user.balloon_alert(user, "[!cover ? "cover removed" : "cover added"]")
	update_turf_overlay()

/turf/open/floor/catwalk_flooring/pry_tile(obj/item/crowbar, mob/user, silent)
	if(cover)
		user.balloon_alert(user, "remove cover first!")
		return FALSE
	. = ..()
