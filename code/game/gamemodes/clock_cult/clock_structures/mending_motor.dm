//Mending Motor: A prism that consumes replicant alloy or power to repair nearby mechanical servants at a quick rate.
/obj/structure/destructible/clockwork/powered/mending_motor
	name = "mending motor"
	desc = "A dark onyx prism, held in midair by spiraling tendrils of stone."
	clockwork_desc = "A powerful prism that rapidly repairs nearby mechanical servants and clockwork structures."
	icon_state = "mending_motor_inactive"
	active_icon = "mending_motor"
	inactive_icon = "mending_motor_inactive"
	unanchored_icon = "mending_motor_unwrenched"
	construction_value = 20
	max_integrity = 125
	obj_integrity = 125
	break_message = "<span class='warning'>The prism falls to the ground with a heavy thud!</span>"
	debris = list(/obj/item/clockwork/alloy_shards/small = 3, \
	/obj/item/clockwork/alloy_shards/medium = 1, \
	/obj/item/clockwork/alloy_shards/large = 1, \
	/obj/item/clockwork/component/vanguard_cogwheel/onyx_prism = 1)
	var/heal_attempts = 4
	var/heal_cost = MIN_CLOCKCULT_POWER*2
	var/static/list/damage_heal_order = list(BRUTE, BURN, OXY)
	var/static/list/heal_finish_messages = list("There, all mended!", "Try not to get too damaged.", "No more dents and scratches for you!", "Champions never die.", "All patched up.", \
	"Ah, child, it's okay now.")
	var/static/list/heal_failure_messages = list("Pain is temporary.", "What you do for the Justiciar is eternal.", "Bear this for me.", "Be strong, child.", "Please, be careful!", \
	"If you die, you will be remembered.")
	var/static/list/mending_motor_typecache = typecacheof(list(
	/obj/structure/destructible/clockwork,
	/obj/machinery/door/airlock/clockwork,
	/obj/machinery/door/window/clockwork,
	/obj/structure/window/reinforced/clockwork,
	/obj/structure/table/reinforced/brass))

/obj/structure/destructible/clockwork/powered/mending_motor/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		to_chat(user, "<span class='inathneq_small'>It requires at least <b>[heal_cost]W</b> to attempt to repair clockwork mobs, structures, or converted silicons.</span>")

/obj/structure/destructible/clockwork/powered/mending_motor/forced_disable(bad_effects)
	if(active)
		if(bad_effects)
			try_use_power(heal_cost)
		visible_message("<span class='warning'>[src] emits an airy chuckling sound and falls dark!</span>")
		toggle()
		return TRUE

/obj/structure/destructible/clockwork/powered/mending_motor/attack_hand(mob/living/user)
	if(user.canUseTopic(src, !issilicon(user), NO_DEXTERY) && is_servant_of_ratvar(user))
		if(total_accessable_power() < MIN_CLOCKCULT_POWER)
			to_chat(user, "<span class='warning'>[src] needs more power to function!</span>")
			return 0
		toggle(0, user)

/obj/structure/destructible/clockwork/powered/mending_motor/process()
	var/efficiency = get_efficiency_mod()
	for(var/atom/movable/M in range(7, src))
		var/turf/T
		if(isclockmob(M) || istype(M, /mob/living/simple_animal/drone/cogscarab))
			T = get_turf(M)
			var/mob/living/simple_animal/S = M
			if(S.health == S.maxHealth || S.stat == DEAD)
				continue
			for(var/i in 1 to heal_attempts)
				if(S.health < S.maxHealth)
					if(try_use_power(heal_cost))
						S.adjustHealth(-(8 * efficiency))
						new /obj/effect/overlay/temp/heal(T, "#1E8CE1")
					else
						to_chat(S, "<span class='inathneq'>\"[text2ratvar(pick(heal_failure_messages))]\"</span>")
						break
				else
					to_chat(S, "<span class='inathneq'>\"[text2ratvar(pick(heal_finish_messages))]\"</span>")
					break
		else if(is_type_in_typecache(M, mending_motor_typecache))
			T = get_turf(M)
			var/obj/structure/destructible/clockwork/C = M
			if(C.obj_integrity == C.max_integrity || (istype(C) && !C.can_be_repaired))
				continue
			for(var/i in 1 to heal_attempts)
				if(C.obj_integrity < C.max_integrity)
					if(try_use_power(heal_cost))
						C.obj_integrity = min(C.obj_integrity + (8 * efficiency), C.max_integrity)
						if(C == src)
							efficiency = get_efficiency_mod()
						C.update_icon()
						new /obj/effect/overlay/temp/heal(T, "#1E8CE1")
					else
						break
				else
					break
		else if(issilicon(M))
			T = get_turf(M)
			var/mob/living/silicon/S = M
			if(S.health == S.maxHealth || S.stat == DEAD || !is_servant_of_ratvar(S))
				continue
			for(var/i in 1 to heal_attempts)
				if(S.health < S.maxHealth)
					if(try_use_power(heal_cost))
						S.heal_ordered_damage(8 * efficiency, damage_heal_order)
						new /obj/effect/overlay/temp/heal(T, "#1E8CE1")
					else
						to_chat(S, "<span class='inathneq'>\"[text2ratvar(pick(heal_failure_messages))]\"</span>")
						break
				else
					to_chat(S, "<span class='inathneq'>\"[text2ratvar(pick(heal_finish_messages))]\"</span>")
					break
	. = ..()
	if(. < heal_cost)
		forced_disable(FALSE)
