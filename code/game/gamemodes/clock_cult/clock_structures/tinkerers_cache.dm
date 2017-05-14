//Tinkerer's cache: Stores components for later use.
/obj/structure/destructible/clockwork/cache
	name = "tinkerer's cache"
	desc = "A large brass spire with a flaming hole in its center."
	clockwork_desc = "A brass container capable of storing a large amount of components.\n\
	Shares components with all other caches and will gradually generate components if near a Clockwork Wall."
	icon_state = "tinkerers_cache"
	unanchored_icon = "tinkerers_cache_unwrenched"
	construction_value = 10
	break_message = "<span class='warning'>The cache's fire winks out before it falls in on itself!</span>"
	max_integrity = 80
	obj_integrity = 80
	light_color = "#C2852F"
	var/wall_generation_cooldown
	var/turf/closed/wall/clockwork/linkedwall //if we've got a linked wall and are producing
	var/static/linked_caches = 0 //how many caches are linked to walls; affects how fast components are produced

/obj/structure/destructible/clockwork/cache/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	GLOB.clockwork_caches++
	update_slab_info()
	set_light(2, 0.7)

/obj/structure/destructible/clockwork/cache/Destroy()
	GLOB.clockwork_caches--
	update_slab_info()
	STOP_PROCESSING(SSobj, src)
	if(linkedwall)
		linked_caches--
		linkedwall.linkedcache = null
		linkedwall = null
	return ..()

/obj/structure/destructible/clockwork/cache/process()
	if(!anchored)
		if(linkedwall)
			linked_caches--
			linkedwall.linkedcache = null
			linkedwall = null
		return
	for(var/turf/closed/wall/clockwork/C in range(4, src))
		if(!C.linkedcache && !linkedwall)
			linked_caches++
			C.linkedcache = src
			linkedwall = C
			wall_generation_cooldown = world.time + get_production_time()
			visible_message("<span class='warning'>[src] starts to whirr in the presence of [C]...</span>")
			break
	if(linkedwall && wall_generation_cooldown <= world.time)
		wall_generation_cooldown = world.time + get_production_time()
		var/component_id = generate_cache_component(null, src)
		playsound(linkedwall, 'sound/magic/clockwork/fellowship_armory.ogg', rand(15, 20), 1, -3, 1, 1)
		visible_message("<span class='[get_component_span(component_id)]'>Something</span><span class='warning'> cl[pick("ank", "ink", "unk", "ang")]s around inside of [src]...</span>")

/obj/structure/destructible/clockwork/cache/attackby(obj/item/I, mob/living/user, params)
	if(!is_servant_of_ratvar(user))
		return ..()
	if(istype(I, /obj/item/clockwork/component))
		var/obj/item/clockwork/component/C = I
		if(!anchored)
			to_chat(user, "<span class='warning'>[src] needs to be secured to place [C] into it!</span>")
		else
			GLOB.clockwork_component_cache[C.component_id]++
			update_slab_info()
			to_chat(user, "<span class='notice'>You add [C] to [src].</span>")
			user.drop_item()
			qdel(C)
		return 1
	else if(istype(I, /obj/item/clockwork/slab))
		var/obj/item/clockwork/slab/S = I
		if(!anchored)
			to_chat(user, "<span class='warning'>[src] needs to be secured to offload your slab's components into it!</span>")
		else
			for(var/i in S.stored_components)
				GLOB.clockwork_component_cache[i] += S.stored_components[i]
				S.stored_components[i] = 0
			update_slab_info()
			user.visible_message("<span class='notice'>[user] empties [S] into [src].</span>", "<span class='notice'>You offload your slab's components into [src].</span>")
		return 1
	else
		return ..()

/obj/structure/destructible/clockwork/cache/update_anchored(mob/user, do_damage)
	..()
	if(anchored)
		set_light(2, 0.7)
	else
		set_light(0)

/obj/structure/destructible/clockwork/cache/attack_hand(mob/living/user)
	..()
	if(is_servant_of_ratvar(user))
		if(linkedwall)
			if(wall_generation_cooldown > world.time)
				var/temp_time = (wall_generation_cooldown - world.time) * 0.1
				to_chat(user, "<span class='alloy'>[src] will produce a component in <b>[temp_time]</b> second[temp_time == 1 ? "":"s"].</span>")
			else
				to_chat(user, "<span class='brass'>[src] is about to produce a component!</span>")
		else if(anchored)
			to_chat(user, "<span class='alloy'>[src] is unlinked! Construct a Clockwork Wall nearby to generate components!</span>")
		else
			to_chat(user, "<span class='alloy'>[src] needs to be secured to generate components!</span>")

/obj/structure/destructible/clockwork/cache/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		if(linkedwall)
			to_chat(user, "<span class='brass'>It is linked to a Clockwork Wall and will generate a component every <b>[round(get_production_time() * 0.1, 0.1)]</b> seconds!</span>")
		else
			to_chat(user, "<span class='alloy'>It is unlinked! Construct a Clockwork Wall nearby to generate components!</span>")
		to_chat(user, "<b>Stored components:</b>")
		for(var/i in GLOB.clockwork_component_cache)
			to_chat(user, "<span class='[get_component_span(i)]_small'><i>[get_component_name(i)][i != REPLICANT_ALLOY ? "s":""]:</i> <b>[GLOB.clockwork_component_cache[i]]</b></span>")

/obj/structure/destructible/clockwork/cache/proc/get_production_time()
	return (CACHE_PRODUCTION_TIME + (ACTIVE_CACHE_SLOWDOWN * linked_caches)) * get_efficiency_mod(TRUE)
