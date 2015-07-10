///////////
// EARTH //
///////////

/////////
// AIR //
/////////

/obj/effect/proc_holder/spell/targeted/lightning/elemental
	name = "Storm Bolt"
	panel = "Abilities"
	invocation_type = null
	charge_max = 150
	clothes_req = 0

/obj/effect/proc_holder/spell/aoe_turf/repulse/elemental
	name = "Gale"
	panel = "Abilities"
	invocation_type = null
	charge_max = 200
	clothes_req = 0

/obj/effect/proc_holder/spell/targeted/airElementalBind
	name = "Cyclone"
	panel = "Abilities"
	invocation_type = null
	charge_max = 600
	clothes_req = 0

/obj/effect/proc_holder/spell/targeted/airElementalBind/cast(list/targets)
	for(var/mob/living/target in targets)
		if(target.stat)
			charge_counter = charge_max
			return
		new /obj/structure/cyclone(get_turf(target))

/obj/structure/cyclone
	name = "cyclone"
	desc = "A small localized tornado, Raging winds swirl around a central point. It is impossible to tell if something is inside."
	density = 1
	anchored = 1
	icon = 'icons/effects/effects.dmi'
	icon_state = "bhole3"

/obj/structure/cyclone/New()
	visible_message("<span class='warning'>A raging cyclone suddenly manifests!</span>")
	for(var/mob/living/M in get_turf(src))
		if(istype(M, /mob/living/simple_animal/revenant))
			continue
		M.visible_message("<span class='warning'>[M] is trapped in the cylone!</span>", \
						  "<span class='boldannounce'>A cocoon of raging winds appears around you, locking you in place!</span>")
		M.notransform = 1
		M.alpha = 0
	spawn(100)
		for(var/mob/living/M in get_turf(src))
			if(M.notransform)
				M.notransform = 0
				M.alpha = 255
		qdel(src)
