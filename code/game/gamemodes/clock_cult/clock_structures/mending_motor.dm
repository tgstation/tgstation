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
	break_message = "<span class='warning'>The prism collapses with a heavy thud!</span>"
	debris = list(/obj/item/clockwork/alloy_shards/small = 5, \
	/obj/item/clockwork/alloy_shards/medium = 1, \
	/obj/item/clockwork/alloy_shards/large = 1, \
	/obj/item/clockwork/component/vanguard_cogwheel = 1)
	var/stored_alloy = 0
	var/max_alloy = REPLICANT_ALLOY_POWER * 10
	var/heal_attempts = 4
	var/list/heal_finish_messages = list("There, all mended!", "Try not to get too damaged.", "No more dents and scratches for you!", "Champions never die.", "All patched up.", \
	"Ah, child, it's okay now.")
	var/list/heal_failure_messages = list("Pain is temporary.", "What you do for the Justiciar is eternal.", "Bear this for me.", "Be strong, child.", "Please, be careful!", \
	"If you die, you will be remembered.")
	var/static/list/mending_motor_typecache = typecacheof(list(
	/obj/structure/destructible/clockwork,
	/obj/machinery/door/airlock/clockwork,
	/obj/machinery/door/window/clockwork,
	/obj/structure/window/reinforced/clockwork,
	/obj/structure/table/reinforced/brass))

/obj/structure/destructible/clockwork/powered/mending_motor/prefilled
	stored_alloy = REPLICANT_ALLOY_POWER //starts with 1 replicant alloy's worth of power

/obj/structure/destructible/clockwork/powered/mending_motor/total_accessable_power()
	. = ..()
	if(. != INFINITY)
		. += accessable_alloy_power()

/obj/structure/destructible/clockwork/powered/mending_motor/proc/accessable_alloy_power()
	return stored_alloy

/obj/structure/destructible/clockwork/powered/mending_motor/use_power(amount)
	var/alloypower = accessable_alloy_power()
	while(alloypower >= MIN_CLOCKCULT_POWER && amount >= MIN_CLOCKCULT_POWER)
		stored_alloy -= MIN_CLOCKCULT_POWER
		alloypower -= MIN_CLOCKCULT_POWER
		amount -= MIN_CLOCKCULT_POWER
	return ..()

/obj/structure/destructible/clockwork/powered/mending_motor/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "<span class='alloy'>It contains <b>[stored_alloy*CLOCKCULT_POWER_TO_ALLOY_MULTIPLIER]/[max_alloy*CLOCKCULT_POWER_TO_ALLOY_MULTIPLIER]</b> units of liquified alloy, \
		which is equivalent to <b>[stored_alloy]W/[max_alloy]W</b> of power.</span>"
		user << "<span class='inathneq_small'>It requires at least <b>[MIN_CLOCKCULT_POWER]W</b> to attempt to repair clockwork mobs, structures, or converted silicons.</span>"

/obj/structure/destructible/clockwork/powered/mending_motor/process()
	var/efficiency = get_efficiency_mod()
	for(var/atom/movable/M in range(7, src))
		var/turf/T
		if(isclockmob(M) || istype(M, /mob/living/simple_animal/drone/cogscarab))
			T = get_turf(M)
			var/mob/living/simple_animal/hostile/clockwork/marauder/E = M
			var/is_marauder = istype(E)
			if(E.health == E.maxHealth || E.stat == DEAD || (is_marauder && !E.fatigue))
				continue
			for(var/i in 1 to heal_attempts)
				if(E.health < E.maxHealth || (is_marauder && E.fatigue))
					if(try_use_power(MIN_CLOCKCULT_POWER))
						E.adjustHealth(-(8 * efficiency))
						PoolOrNew(/obj/effect/overlay/temp/heal, list(T, "#1E8CE1"))
					else
						E << "<span class='inathneq'>\"[text2ratvar(pick(heal_failure_messages))]\"</span>"
						break
				else
					E << "<span class='inathneq'>\"[text2ratvar(pick(heal_finish_messages))]\"</span>"
					break
		else if(is_type_in_typecache(M, mending_motor_typecache))
			T = get_turf(M)
			var/obj/structure/C = M
			if(C.obj_integrity == C.max_integrity)
				continue
			for(var/i in 1 to heal_attempts)
				if(C.obj_integrity < C.max_integrity)
					if(try_use_power(MIN_CLOCKCULT_POWER))
						C.obj_integrity = min(C.obj_integrity + (8 * efficiency), C.max_integrity)
						if(C == src)
							efficiency = get_efficiency_mod()
						C.update_icon()
						PoolOrNew(/obj/effect/overlay/temp/heal, list(T, "#1E8CE1"))
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
					if(try_use_power(MIN_CLOCKCULT_POWER))
						S.adjustBruteLoss(-(5 * efficiency))
						S.adjustFireLoss(-(3 * efficiency))
						PoolOrNew(/obj/effect/overlay/temp/heal, list(T, "#1E8CE1"))
					else
						S << "<span class='inathneq'>\"[text2ratvar(pick(heal_failure_messages))]\"</span>"
						break
				else
					S << "<span class='inathneq'>\"[text2ratvar(pick(heal_finish_messages))]\"</span>"
					break
	. = ..()
	if(. < MIN_CLOCKCULT_POWER)
		visible_message("<span class='warning'>[src] emits an airy chuckling sound and falls dark!</span>")
		toggle()
		return

/obj/structure/destructible/clockwork/powered/mending_motor/attack_hand(mob/living/user)
	if(user.canUseTopic(src, !issilicon(user)) && is_servant_of_ratvar(user))
		if(total_accessable_power() < MIN_CLOCKCULT_POWER)
			user << "<span class='warning'>[src] needs more power or replicant alloy to function!</span>"
			return 0
		toggle(0, user)

/obj/structure/destructible/clockwork/powered/mending_motor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clockwork/component/replicant_alloy) && is_servant_of_ratvar(user))
		if(stored_alloy + REPLICANT_ALLOY_POWER > max_alloy)
			user << "<span class='warning'>[src] is too full to accept any more alloy!</span>"
			return 0
		playsound(user, 'sound/machines/click.ogg', 50, 1)
		clockwork_say(user, text2ratvar("Transmute into fuel."), TRUE)
		user << "<span class='brass'>You force [I] to liquify and pour it into [src]'s compartments. \
		It now contains <b>[stored_alloy*CLOCKCULT_POWER_TO_ALLOY_MULTIPLIER]/[max_alloy*CLOCKCULT_POWER_TO_ALLOY_MULTIPLIER]</b> units of liquified alloy.</span>"
		stored_alloy = stored_alloy + REPLICANT_ALLOY_POWER
		user.drop_item()
		qdel(I)
		return 1
	else
		return ..()
