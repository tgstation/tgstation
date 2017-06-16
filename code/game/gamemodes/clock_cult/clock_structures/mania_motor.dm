//Mania Motor: A pair of antenna that, while active, cause a variety of negative mental effects in nearby human mobs.
/obj/structure/destructible/clockwork/powered/mania_motor
	name = "mania motor"
	desc = "A pair of antenna with what appear to be sockets around the base. It reminds you of an antlion."
	clockwork_desc = "A transmitter that allows Sevtug to whisper into the minds of nearby non-servants, causing a variety of negative mental effects, up to and including conversion."
	icon_state = "mania_motor_inactive"
	active_icon = "mania_motor"
	inactive_icon = "mania_motor_inactive"
	unanchored_icon = "mania_motor_unwrenched"
	construction_value = 20
	break_message = "<span class='warning'>The antenna break off, leaving a pile of shards!</span>"
	max_integrity = 100
	obj_integrity = 100
	light_color = "#AF0AAF"
	debris = list(/obj/item/clockwork/alloy_shards/large = 2, \
	/obj/item/clockwork/alloy_shards/small = 2, \
	/obj/item/clockwork/component/geis_capacitor/antennae = 1)
	var/mania_cost = 150

/obj/structure/destructible/clockwork/powered/mania_motor/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		to_chat(user, "<span class='sevtug_small'>It requires <b>[mania_cost]W</b> to run.</span>")

/obj/structure/destructible/clockwork/powered/mania_motor/forced_disable(bad_effects)
	if(active)
		if(bad_effects)
			try_use_power(MIN_CLOCKCULT_POWER*4)
		visible_message("<span class='warning'>[src] hums loudly, then the sockets at its base fall dark!</span>")
		playsound(src, 'sound/effects/screech.ogg', 40, 1)
		toggle()
		return TRUE

/obj/structure/destructible/clockwork/powered/mania_motor/attack_hand(mob/living/user)
	if(user.canUseTopic(src, !issilicon(user), NO_DEXTERY) && is_servant_of_ratvar(user))
		if(!total_accessable_power() >= mania_cost)
			to_chat(user, "<span class='warning'>[src] needs more power to function!</span>")
			return 0
		toggle(0, user)

/obj/structure/destructible/clockwork/powered/mania_motor/toggle(fast_process, mob/living/user)
	. = ..()
	if(active)
		set_light(2, 0.9)
	else
		set_light(0)

/obj/structure/destructible/clockwork/powered/mania_motor/process()
	if(!try_use_power(mania_cost))
		forced_disable(FALSE)
		return
	var/efficiency = get_efficiency_mod()
	for(var/mob/living/carbon/human/H in viewers(7, src))
		if(is_servant_of_ratvar(H))
			continue
		var/list/effects = H.has_status_effect_list(STATUS_EFFECT_MANIAMOTOR)
		var/datum/status_effect/maniamotor/M
		for(var/datum/status_effect/maniamotor/MM in effects)
			if(MM.motor == src)
				M = MM
				break
		if(!M)
			M = H.apply_status_effect(STATUS_EFFECT_MANIAMOTOR)
			M.motor = src
		M.severity = Clamp(M.severity + ((11 - get_dist(src, H)) * efficiency * efficiency), 0, MAX_MANIA_SEVERITY)
