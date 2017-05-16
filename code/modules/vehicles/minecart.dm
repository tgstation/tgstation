/obj/vehicle/minecart
	name = "minecart"
	desc = "A metal box on wheels, usually for hauling rock chunks and various debris out of mines."
	icon_state = "miningcaropen"
	icon = 'icons/obj/crates.dmi'
	var/static/mutable_appearance/atvcover

/obj/vehicle/minecart/buckle_mob(mob/living/buckled_mob, force = 0, check_loc = 1)
	. = ..()
	riding_datum = new/datum/riding/minecart

/obj/vehicle/minecart/Initialize()
	. = ..()
	atvcover = atvcover || mutable_appearance(icon, "atvcover", ABOVE_MOB_LAYER)

/obj/vehicle/minecart/post_buckle_mob(mob/living/M)
	if(has_buckled_mobs())
		add_overlay(atvcover)
	else
		cut_overlay(atvcover)

/obj/vehicle/minecart/relaymove(mob/user, direction)
	var/turf/t = get_step(src, direction)
	var/obj/structure/minecart_rail/N = locate() in t
	if(N)
		..()
	else
		user << "You need a minecart rail to move!"
		return 0