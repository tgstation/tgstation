

/obj/structure/alien/resin/flower_bud_enemy //inheriting basic attack/damage stuff from alien structures
	name = "flower bud"
	desc = "a large pulsating plant..."
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "flower_bud"
	layer = MOB_LAYER + 0.9
	opacity = 0
	canSmoothWith = list()
	smooth = SMOOTH_FALSE
	var/growth_time = 1200


/obj/structure/alien/resin/flower_bud_enemy/New()
	..()
	var/list/anchors = list()
	anchors += locate(x-2,y+2,z)
	anchors += locate(x+2,y+2,z)
	anchors += locate(x-2,y-2,z)
	anchors += locate(x+2,y-2,z)

	for(var/turf/T in anchors)
		var/datum/beam/B = Beam(T,"vine",'icons/effects/spacevines.dmi',INFINITY, 5,/obj/effect/ebeam/vine)
		B.sleep_time = 10 //these shouldn't move, so let's slow down updates to 1 second (any slower and the deletion of the vines would be too slow)

	spawn(growth_time)
		visible_message("<span class='danger'>the plant has borne fruit!</span>")
		new /mob/living/simple_animal/hostile/venus_human_trap (get_turf(src))
		qdel(src)


/obj/effect/ebeam/vine
	name = "thick vine"
	mouse_opacity = 1
	desc = "a thick vine, painful to the touch"


/obj/effect/ebeam/vine/Crossed(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/L = AM
		if(!("vines" in L.faction))
			L.adjustBruteLoss(5)
			L << "<span class='alert'>You cut yourself on the thorny vines.</span>"



/mob/living/simple_animal/hostile/venus_human_trap
	name = "venus human trap"
	desc = "now you know how the fly feels"
	icon_state = "venus_human_trap"
	layer = MOB_LAYER + 0.9
	health = 50
	maxHealth = 50
	ranged = 1
	harm_intent_damage = 5
	melee_damage_lower = 25
	melee_damage_upper = 25
	a_intent = "harm"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	faction = list("hostile","vines","plants")
	var/list/grasping = list()
	var/max_grasps = 4
	var/grasp_chance = 20
	var/grasp_pull_chance = 85
	var/grasp_range = 4
	del_on_death = 1

/mob/living/simple_animal/hostile/venus_human_trap/handle_automated_action()
	if(..())
		for(var/mob/living/L in grasping)
			if(L.stat == DEAD)
				var/datum/beam/B = grasping[L]
				if(B)
					B.End()
				grasping -= L

			//Can attack+pull multiple times per cycle
			if(L.Adjacent(src))
				L.attack_animal(src)
			else
				if(prob(grasp_pull_chance))
					dir = get_dir(src,L) //staaaare
					step(L,get_dir(L,src)) //reel them in
					L.Weaken(3) //you can't get away now~

		if(grasping.len < max_grasps)
			for(var/mob/living/L in range(grasp_range,src))
				if(L == src || faction_check(L))
					continue
				if(!(L in grasping) && L != target && prob(grasp_chance))
					L << "<span class='userdanger'>\the [src] has you entangled!</span>"
					grasping[L] = Beam(L,"vine",'icons/effects/spacevines.dmi',INFINITY, 5,/obj/effect/ebeam/vine)

					break //only take 1 new victim per cycle


/mob/living/simple_animal/hostile/venus_human_trap/OpenFire(atom/the_target)
	var/dist = get_dist(src,the_target)
	Beam(the_target,"vine",'icons/effects/spacevines.dmi',dist*2, dist+2,/obj/effect/ebeam/vine)
	the_target.attack_animal(src)


/mob/living/simple_animal/hostile/venus_human_trap/CanAttack(atom/the_target)
	. = ..()
	if(.)
		if(the_target in grasping)
			return 0
