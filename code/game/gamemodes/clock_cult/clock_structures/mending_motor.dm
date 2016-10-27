//Mending Motor: A prism that consumes replicant alloy or power to repair nearby mechanical servants at a quick rate.
/obj/structure/destructible/clockwork/powered/mending_motor
	name = "mending motor"
	desc = "A dark onyx prism, held in midair by spiraling tendrils of stone."
	clockwork_desc = "A powerful prism that rapidly repairs nearby mechanical servants and clockwork structures."
	icon_state = "mending_motor_inactive"
	active_icon = "mending_motor"
	inactive_icon = "mending_motor_inactive"
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
	var/mob_cost = 200
	var/structure_cost = 250
	var/cyborg_cost = 300

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
		user << "<span class='inathneq_small'>It requires <b>[mob_cost]W</b> to heal clockwork mobs, <b>[structure_cost]W</b> for clockwork structures, and <b>[cyborg_cost]W</b> for cyborgs.</span>"

/obj/structure/destructible/clockwork/powered/mending_motor/process()
	if(..() < mob_cost)
		visible_message("<span class='warning'>[src] emits an airy chuckling sound and falls dark!</span>")
		toggle()
		return
	for(var/atom/movable/M in range(5, src))
		if(isclockmob(M) || istype(M, /mob/living/simple_animal/drone/cogscarab))
			var/mob/living/simple_animal/hostile/clockwork/W = M
			var/fatigued = FALSE
			if(istype(M, /mob/living/simple_animal/hostile/clockwork/marauder))
				var/mob/living/simple_animal/hostile/clockwork/marauder/E = M
				if(E.fatigue)
					fatigued = TRUE
			if((!fatigued && W.health == W.maxHealth) || W.stat)
				continue
			if(!try_use_power(mob_cost))
				break
			W.adjustHealth(-20)
		else if(istype(M, /obj/structure/destructible/clockwork))
			var/obj/structure/destructible/clockwork/C = M
			if(C.obj_integrity == C.max_integrity)
				continue
			if(!try_use_power(structure_cost))
				break
			C.obj_integrity = min(C.obj_integrity + 20, C.max_integrity)
		else if(issilicon(M))
			var/mob/living/silicon/S = M
			if(S.health == S.maxHealth || S.stat == DEAD || !is_servant_of_ratvar(S))
				continue
			if(!try_use_power(cyborg_cost))
				break
			S.adjustBruteLoss(-20)
			S.adjustFireLoss(-10)
	return 1

/obj/structure/destructible/clockwork/powered/mending_motor/attack_hand(mob/living/user)
	if(user.canUseTopic(src, BE_CLOSE))
		if(total_accessable_power() < mob_cost)
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
