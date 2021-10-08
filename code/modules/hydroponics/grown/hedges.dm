/obj/item/seeds/shrub
	name = "pack of shrub seeds"
	desc = "These seeds grow into hedge shrubs."
	icon_state = "seed-shrub"
	species = "shrub"
	plantname = "Shrubbery"
	product = /obj/item/grown/shrub
	lifespan = 40
	endurance = 30
	maturation = 4
	production = 6
	yield = 2
	instability = 10
	growthstages = 3
	reagents_add = list()

/obj/item/grown/shrub
	seed = /obj/item/seeds/shrub
	name = "shrub"
	desc = "A shrubbery, it looks nice and it was only a few credits too. Plant it on the ground to grow a hedge, shrubbing skills not required."
	icon_state = "shrub"

/obj/item/grown/shrub/attack_self(mob/user)
	var/turf/player_turf = get_turf(user)
	if(player_turf?.is_blocked_turf(TRUE))
		return FALSE
	user.visible_message(span_danger("[user] begins to plant \the [src]..."))
	if(do_after(user, 8 SECONDS, target = user.drop_location(), progress = TRUE))
		new /obj/structure/hedge/opaque(user.drop_location())
		to_chat(user, span_notice("You plant \the [src]."))
		qdel(src)

///the structure placed by the shrubs
/obj/structure/hedge
	name = "hedge"
	desc = "A large bushy hedge."
	icon = 'icons/obj/smooth_structures/hedge.dmi'
	icon_state = "hedge-0"
	base_icon_state = "hedge"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_HEDGE_FLUFF)
	canSmoothWith = list(SMOOTH_GROUP_HEDGE_FLUFF)
	density = TRUE
	anchored = TRUE
	opacity = FALSE
	max_integrity = 80

/obj/structure/hedge/attacked_by(obj/item/I, mob/living/user)
	if(opacity && HAS_TRAIT(user, TRAIT_BONSAI) && I.get_sharpness())
		to_chat(user,span_notice("You start trimming \the [src]."))
		if(do_after(user, 3 SECONDS,target=src))
			to_chat(user,span_notice("You finish trimming \the [src]."))
			opacity = FALSE
	else
		return ..()
/**
 * useful for mazes and such
 */
/obj/structure/hedge/opaque
	opacity = TRUE
