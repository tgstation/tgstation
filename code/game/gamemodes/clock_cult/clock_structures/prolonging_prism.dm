//Prolonging Prism: A prism that consumes power to delay the shuttle
/obj/structure/destructible/clockwork/powered/prolonging_prism
	name = "prolonging prism"
	desc = "A dark onyx prism, held in midair by spiraling tendrils of stone."
	clockwork_desc = "A powerful prism that will delay the arrival of an emergency shuttle."
	icon_state = "prolonging_prism_inactive"
	active_icon = "prolonging_prism"
	inactive_icon = "prolonging_prism_inactive"
	unanchored_icon = "prolonging_prism_unwrenched"
	construction_value = 20
	max_integrity = 125
	obj_integrity = 125
	break_message = "<span class='warning'>The prism falls to the ground with a heavy thud!</span>"
	debris = list(/obj/item/clockwork/alloy_shards/small = 3, \
	/obj/item/clockwork/alloy_shards/medium = 1, \
	/obj/item/clockwork/alloy_shards/large = 1, \
	/obj/item/clockwork/component/vanguard_cogwheel/onyx_prism = 1)
	var/static/list/component_refund = list(VANGUARD_COGWHEEL = 1, GEIS_CAPACITOR = 1, REPLICANT_ALLOY = 1)

/obj/structure/destructible/clockwork/powered/prolonging_prism/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		if(GLOB.ratvar_awakens || SSshuttle.emergency.mode == SHUTTLE_DOCKED || SSshuttle.emergency.mode == SHUTTLE_IGNITING || SSshuttle.emergency.mode == SHUTTLE_STRANDED || SSshuttle.emergency.mode == SHUTTLE_ESCAPE)
			to_chat(user, "<span class='inathneq'>An emergency shuttle has arrived and this prism is no longer useful; attempt to activate it to gain a partial refund of components used.</span>")
		else
			var/efficiency = get_efficiency_mod()
			to_chat(user, "<span class='inathneq_small'>It requires at least <b>[get_delay_cost() * efficiency]W</b> to attempt to delay the arrival of an emergency shuttle by \
			<b>[get_delay_time() * 0.1 * efficiency]</b> second\s.</span>")

/obj/structure/destructible/clockwork/powered/prolonging_prism/forced_disable(bad_effects)
	if(active)
		if(bad_effects)
			try_use_power(MIN_CLOCKCULT_POWER*4)
		visible_message("<span class='warning'>[src] emits an airy chuckling sound and falls dark!</span>")
		toggle()
		return TRUE

/obj/structure/destructible/clockwork/powered/prolonging_prism/attack_hand(mob/living/user)
	if(user.canUseTopic(src, !issilicon(user), NO_DEXTERY) && is_servant_of_ratvar(user))
		if(GLOB.ratvar_awakens || SSshuttle.emergency.mode == SHUTTLE_DOCKED || SSshuttle.emergency.mode == SHUTTLE_IGNITING || SSshuttle.emergency.mode == SHUTTLE_STRANDED || SSshuttle.emergency.mode == SHUTTLE_ESCAPE)
			to_chat(user, "<span class='brass'>You break the prism apart, refunding some of the components used.</span>")
			for(var/i in component_refund)
				generate_cache_component(i, src)
			take_damage(max_integrity)
			return 0
		if(SSshuttle.emergency.mode != SHUTTLE_CALL)
			to_chat(user, "<span class='warning'>No emergency shuttles are attempting to arrive at the station!</span>")
			return 0
		var/efficiency = get_efficiency_mod()
		if(total_accessable_power() < get_delay_cost() * efficiency)
			to_chat(user, "<span class='warning'>[src] needs more power to function!</span>")
			return 0
		toggle(0, user)

/obj/structure/destructible/clockwork/powered/prolonging_prism/process()
	if(SSshuttle.emergency.mode != SHUTTLE_CALL)
		forced_disable(FALSE)
		return
	. = ..()
	var/efficiency = get_efficiency_mod()
	if(!try_use_power(get_delay_cost() * efficiency))
		forced_disable(FALSE)
		return
	SSshuttle.emergency.setTimer(SSshuttle.emergency.timeLeft(1) + (get_delay_time() * efficiency))
	var/placement_style = prob(50)
	for(var/t in SSshuttle.emergency.ripple_area(SSshuttle.getDock("emergency_home")))
		if(prob(50 * efficiency))
			var/turf/T = t
			if(placement_style)
				if(IsOdd(T.x + T.y))
					new/obj/effect/overlay/temp/ratvar/prolonging_prism/big(T)
				else
					new/obj/effect/overlay/temp/ratvar/prolonging_prism(T)
			else
				if(IsOdd(T.x + T.y))
					new/obj/effect/overlay/temp/ratvar/prolonging_prism(T)
				else
					new/obj/effect/overlay/temp/ratvar/prolonging_prism/big(T)
			CHECK_TICK //some of those shuttles are way too big
	var/security_num = seclevel2num(get_security_level())
	var/canceltime = SSshuttle.emergencyCallTime
	switch(security_num)
		if(SEC_LEVEL_GREEN)
			canceltime *= 2
		if(SEC_LEVEL_BLUE)
			canceltime *= 0.5
		else
			canceltime *= 0.25
	canceltime += world.time //add the world.time after so we don't double it
	if(SSshuttle.emergency.timeLeft(1) > canceltime) //if we go over the recall time, recall that shuttle
		SSshuttle.emergency.cancel(get_area(src))

/obj/structure/destructible/clockwork/powered/prolonging_prism/proc/get_delay_cost()
	var/security_num = seclevel2num(get_security_level())
	switch(security_num)
		if(SEC_LEVEL_GREEN)
			. = MIN_CLOCKCULT_POWER*2
		if(SEC_LEVEL_BLUE)
			. = MIN_CLOCKCULT_POWER*4
		if(SEC_LEVEL_RED)
			. = MIN_CLOCKCULT_POWER*6
		if(SEC_LEVEL_DELTA)
			. = MIN_CLOCKCULT_POWER*8
	if(SSshuttle.emergency.mode == SHUTTLE_CALL && SSshuttle.canRecall())
		. *= 2

/obj/structure/destructible/clockwork/powered/prolonging_prism/proc/get_delay_time()
	var/security_num = seclevel2num(get_security_level())
	switch(security_num)
		if(SEC_LEVEL_GREEN)
			return 30
		if(SEC_LEVEL_BLUE) //green and blue will delay and eventually recall
			return 25
		if(SEC_LEVEL_RED)
			return 15
		if(SEC_LEVEL_DELTA) //red and delta will eventually arrive
			return 10