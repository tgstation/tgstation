
/obj/effect/floating_blade
	name = "knife"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "knife"
	/// The color the knife glows around it.
	var/glow_color = "#f8f8ff"

/obj/effect/floating_blade/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/movetype_handler)
	ADD_TRAIT(src, TRAIT_MOVE_FLYING, INNATE_TRAIT)
	add_filter("knife", 2, list("type" = "outline", "color" = glow_color, "size" = 1))

/obj/effect/floating_blade/bonus
	name = "glorious knife"
	glow_color = "#fffbbf"

/obj/effect/floating_blade/bonus/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_enter,
	)

	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/floating_blade/bonus/proc/on_enter(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!isliving(arrived))
		return

	var/mob/living/arrived_mob = arrived
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(arrived_mob)
	if(heretic_datum?.heretic_path != PATH_BLADE)
		qdel(src)
		return

	grant_boon(arrived_mob)

/obj/effect/floating_blade/bonus/proc/grant_boon(mob/living/grant_to)
	qdel(src)
