//Tinkerer's Daemon: A machine that rapidly produces components at a power cost.
/obj/structure/destructible/clockwork/powered/tinkerers_daemon
	name = "tinkerer's daemon"
	desc = "A strange machine with three small brass obelisks attached to it."
	clockwork_desc = "An efficient machine that can rapidly produce components at a small power cost. It will only function if outnumbered by servants at a rate to 5:1."
	icon_state = "tinkerers_daemon"
	active_icon = "tinkerers_daemon"
	inactive_icon = "tinkerers_daemon"
	unanchored_icon = "tinkerers_daemon_unwrenched"
	max_integrity = 100
	obj_integrity = 100
	construction_value = 20
	break_message = "<span class='warning'>The daemon shatters into millions of pieces, leaving only a disc of metal!</span>"
	debris = list(/obj/item/clockwork/alloy_shards/medium = 1, \
	/obj/item/clockwork/alloy_shards/small = 6, \
	/obj/item/clockwork/component/replicant_alloy/replication_plate = 1)
	var/static/mutable_appearance/daemon_glow = mutable_appearance('icons/obj/clockwork_objects.dmi', "tinkerglow")
	var/static/mutable_appearance/component_glow = mutable_appearance('icons/obj/clockwork_objects.dmi', "t_random_component")
	var/component_id_to_produce
	var/production_time = 0 //last time we produced a component
	var/production_cooldown = 60

/obj/structure/destructible/clockwork/powered/tinkerers_daemon/Initialize()
	. = ..()
	GLOB.clockwork_daemons++

/obj/structure/destructible/clockwork/powered/tinkerers_daemon/Destroy()
	GLOB.clockwork_daemons--
	return ..()

/obj/structure/destructible/clockwork/powered/tinkerers_daemon/ratvar_act()
	..()
	if(GLOB.nezbere_invoked)
		production_time = 0
		production_cooldown = initial(production_cooldown) * 0.5
		if(!active)
			toggle(0)
	else
		production_cooldown = initial(production_cooldown)

/obj/structure/destructible/clockwork/powered/tinkerers_daemon/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		if(active)
			if(component_id_to_produce)
				to_chat(user, "<span class='[get_component_span(component_id_to_produce)]_small'>It is currently producing [get_component_name(component_id_to_produce)][component_id_to_produce != REPLICANT_ALLOY ? "s":""].</span>")
			else
				to_chat(user, "<span class='brass'>It is currently producing random components.</span>")
		to_chat(user, "<span class='nezbere_small'>It will produce a component every <b>[round((production_cooldown*0.1) * get_efficiency_mod(TRUE), 0.1)]</b> seconds and requires at least the following power for each component type:</span>")
		for(var/i in GLOB.clockwork_component_cache)
			to_chat(user, "<span class='[get_component_span(i)]_small'><i>[get_component_name(i)]:</i> <b>[get_component_cost(i)]W</b> <i>([GLOB.clockwork_component_cache[i]] exist[GLOB.clockwork_component_cache[i] == 1 ? "s" : ""])</i></span>")

/obj/structure/destructible/clockwork/powered/tinkerers_daemon/forced_disable(bad_effects)
	if(active)
		if(bad_effects)
			try_use_power(MIN_CLOCKCULT_POWER*4)
			visible_message("<span class='warning'>[src] shuts down with a horrible grinding noise!</span>")
			playsound(src, 'sound/magic/clockwork/anima_fragment_attack.ogg', 50, 1)
		else
			visible_message("<span class='warning'>[src] shuts down!</span>")
		toggle()
		return TRUE

/obj/structure/destructible/clockwork/powered/tinkerers_daemon/attack_hand(mob/living/user)
	if(!is_servant_of_ratvar(user))
		to_chat(user, "<span class='warning'>You place your hand on the daemon, but nothing happens.</span>")
		return
	if(active)
		toggle(0, user)
	else
		if(!anchored)
			to_chat(user, "<span class='warning'>[src] needs to be secured to the floor before it can be activated!</span>")
			return FALSE
		var/servants = 0
		for(var/mob/living/L in GLOB.living_mob_list)
			if(is_servant_of_ratvar(L))
				servants++
		if(servants * 0.2 < GLOB.clockwork_daemons)
			to_chat(user, "<span class='nezbere'>\"There are too few servants for this daemon to work.\"</span>")
			return
		if(!GLOB.clockwork_caches)
			to_chat(user, "<span class='nezbere'>\"You require a cache for this daemon to operate. Get to it.\"</span>")
			return
		var/min_power_usable = 0
		for(var/i in GLOB.clockwork_component_cache)
			if(!min_power_usable)
				min_power_usable = get_component_cost(i)
			else
				min_power_usable = min(min_power_usable, get_component_cost(i))
		if(total_accessable_power() < min_power_usable)
			to_chat(user, "<span class='nezbere'>\"You need more power to activate this daemon, friend.\"</span>")
			return
		var/choice = alert(user,"Activate Daemon...",,"Specific Component","Random Component","Cancel")
		switch(choice)
			if("Specific Component")
				var/list/components = list()
				for(var/i in GLOB.clockwork_component_cache)
					components["[get_component_name(i)] ([get_component_cost(i)]W)"] = i
				var/input_component = input(user, "Choose a component type.", name) as null|anything in components
				component_id_to_produce = components[input_component]
				servants = 0
				for(var/mob/living/L in GLOB.living_mob_list)
					if(is_servant_of_ratvar(L))
						servants++
				if(!is_servant_of_ratvar(user) || !user.canUseTopic(src, !issilicon(user), NO_DEXTERY) || active || !GLOB.clockwork_caches || servants * 0.2 < GLOB.clockwork_daemons)
					return
				if(!component_id_to_produce)
					to_chat(user, "<span class='warning'>You decide not to select a component and activate the daemon.</span>")
					return
				if(total_accessable_power() < get_component_cost(component_id_to_produce))
					to_chat(user, "<span class='warning'>There is too little power to produce this type of component!</span>")
					return
				toggle(0, user)
			if("Random Component")
				component_id_to_produce = null
				toggle(0, user)

/obj/structure/destructible/clockwork/powered/tinkerers_daemon/toggle(fast_process, mob/living/user)
	. = ..()
	if(active)
		var/component_color = get_component_color(component_id_to_produce)
		daemon_glow.color = component_color
		add_overlay(daemon_glow)
		component_glow.icon_state = "t_[component_id_to_produce ? component_id_to_produce :"random_component"]"
		component_glow.color = component_color
		add_overlay(component_glow)
		production_time = world.time + production_cooldown //don't immediately produce when turned on after being off
		set_light(2, 0.9, get_component_color_bright(component_id_to_produce))
	else
		cut_overlays()
		set_light(0)

/obj/structure/destructible/clockwork/powered/tinkerers_daemon/proc/get_component_cost(id)
	return max(MIN_CLOCKCULT_POWER*2, (MIN_CLOCKCULT_POWER*2) * (1 + round(GLOB.clockwork_component_cache[id] * 0.2)))

/obj/structure/destructible/clockwork/powered/tinkerers_daemon/process()
	var/servants = 0
	for(var/mob/living/L in GLOB.living_mob_list)
		if(is_servant_of_ratvar(L))
			servants++
	. = ..()
	var/min_power_usable = 0
	if(!component_id_to_produce)
		for(var/i in GLOB.clockwork_component_cache)
			if(!min_power_usable)
				min_power_usable = get_component_cost(i)
			else
				min_power_usable = min(min_power_usable, get_component_cost(i))
	else
		min_power_usable = get_component_cost(component_id_to_produce)
	if(!GLOB.clockwork_caches || servants * 0.2 < GLOB.clockwork_daemons || . < min_power_usable) //if we don't have enough to produce the lowest or what we chose to produce, cancel out
		forced_disable(FALSE)
		return
	if(production_time <= world.time)
		var/component_to_generate = component_id_to_produce
		if(!component_to_generate)
			component_to_generate = get_weighted_component_id() //more likely to generate components that we have less of
		if(!try_use_power(get_component_cost(component_to_generate)))
			component_to_generate = null
			if(!component_id_to_produce)
				for(var/i in GLOB.clockwork_component_cache)
					if(try_use_power(get_component_cost(i))) //if we fail but are producing random, try and get a different component to produce
						component_to_generate = i
						break
		if(component_to_generate)
			generate_cache_component(component_to_generate, src)
			production_time = world.time + (production_cooldown * get_efficiency_mod(TRUE)) //go on cooldown
			visible_message("<span class='warning'>[src] hums as it produces a </span><span class='[get_component_span(component_to_generate)]'>component</span><span class='warning'>.</span>")
		else
			forced_disable(FALSE) //we shouldn't actually ever get here, as we should cancel out way before this
