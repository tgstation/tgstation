/obj/effect/ebeam/containment
	name = "Containment Field"
	desc = "An energy field."
	mouse_opacity = 1
	anchored = 1
	density = 1
	layer = OBJ_LAYER-0.1

/obj/effect/ebeam/containment/attack_hand(mob/user)
	if(get_dist(src, user) > 1)
		return 0
	else
		throwback_shock(user)
		return 1


/obj/effect/ebeam/containment/blob_act(obj/effect/blob/B)
	return 0


/obj/effect/ebeam/containment/ex_act(severity, target)
	return 0

/obj/effect/ebeam/containment/Destroy()
	if(istype(owner.origin, /obj/machinery/field/generator))
		var/obj/machinery/field/generator/G = owner.origin
		if(G.fields.Find(owner))
			G.fields -= owner
	return ..()

/obj/effect/ebeam/containment/Crossed(mob/mover)
	if(isliving(mover))
		throwback_shock(mover)

/obj/effect/ebeam/containment/Crossed(obj/mover)
	if(istype(mover, /obj/machinery) || istype(mover, /obj/structure) || istype(mover, /obj/mecha))
		bump_field(mover)

/obj/proc/throwback_shock(mob/living/user)
	if(isliving(user))
		var/shock_damage = min(rand(30,40),rand(30,40))

		if(iscarbon(user))
			var/stun = min(shock_damage, 15)
			user.Stun(stun)
			user.Weaken(10)
			user.electrocute_act(shock_damage, src, 1)

		else if(issilicon(user))
			if(prob(20))
				user.Stun(2)
			user.take_overall_damage(0, shock_damage)
			user.visible_message("<span class='danger'>[user.name] was shocked by the [src.name]!</span>", \
			"<span class='userdanger'>Energy pulse detected, system damaged!</span>", \
			"<span class='italics'>You hear an electrical crack.</span>")

		user.updatehealth()
		bump_field(user)
	return

/obj/proc/bump_field(atom/movable/AM as mob|obj)
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, AM.loc)
	s.start()
	var/atom/target = get_edge_target_turf(AM, get_dir(src, get_step_away(AM, src)))
	AM.throw_at(target, 200, 4)

/obj/effect/ebeam/containment/CanPass(atom/movable/mover, turf/target, height=0)
	if(isliving(mover)) // Don't let mobs through
		throwback_shock(mover)
		return 0
	if(istype(mover, /obj/machinery) || istype(mover, /obj/structure) || istype(mover, /obj/mecha))
		bump_field(mover)
		return 0
	return ..()