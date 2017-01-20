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
	var/wall_generation_cooldown
	var/turf/closed/wall/clockwork/linkedwall //if we've got a linked wall and are producing

/obj/structure/destructible/clockwork/cache/New()
	..()
	START_PROCESSING(SSobj, src)
	clockwork_caches++
	update_slab_info()
	SetLuminosity(2,1)

/obj/structure/destructible/clockwork/cache/Destroy()
	clockwork_caches--
	update_slab_info()
	STOP_PROCESSING(SSobj, src)
	if(linkedwall)
		linkedwall.linkedcache = null
		linkedwall = null
	return ..()

/obj/structure/destructible/clockwork/cache/process()
	if(!anchored)
		if(linkedwall)
			linkedwall.linkedcache = null
			linkedwall = null
		return
	for(var/turf/closed/wall/clockwork/C in range(4, src))
		if(!C.linkedcache && !linkedwall)
			C.linkedcache = src
			linkedwall = C
			wall_generation_cooldown = world.time + (CACHE_PRODUCTION_TIME * get_efficiency_mod(TRUE))
			visible_message("<span class='warning'>[src] starts to whirr in the presence of [C]...</span>")
			break
	if(linkedwall && wall_generation_cooldown <= world.time)
		wall_generation_cooldown = world.time + (CACHE_PRODUCTION_TIME * get_efficiency_mod(TRUE))
		generate_cache_component(null, src)
		playsound(linkedwall, 'sound/magic/clockwork/fellowship_armory.ogg', rand(15, 20), 1, -3, 1, 1)
		visible_message("<span class='warning'>Something cl[pick("ank", "ink", "unk", "ang")]s around inside of [src]...</span>")

/obj/structure/destructible/clockwork/cache/attackby(obj/item/I, mob/living/user, params)
	if(!is_servant_of_ratvar(user))
		return ..()
	if(istype(I, /obj/item/clockwork/component))
		var/obj/item/clockwork/component/C = I
		if(!anchored)
			user << "<span class='warning'>[src] needs to be secured to place [C] into it!</span>"
		else
			clockwork_component_cache[C.component_id]++
			update_slab_info()
			user << "<span class='notice'>You add [C] to [src].</span>"
			user.drop_item()
			qdel(C)
		return 1
	else if(istype(I, /obj/item/clockwork/slab))
		var/obj/item/clockwork/slab/S = I
		if(!anchored)
			user << "<span class='warning'>[src] needs to be secured to offload your slab's components into it!</span>"
		else
			for(var/i in S.stored_components)
				clockwork_component_cache[i] += S.stored_components[i]
				S.stored_components[i] = 0
			update_slab_info()
			user.visible_message("<span class='notice'>[user] empties [S] into [src].</span>", "<span class='notice'>You offload your slab's components into [src].</span>")
		return 1
	else
		return ..()

/obj/structure/destructible/clockwork/cache/attack_hand(mob/living/user)
	..()
	if(is_servant_of_ratvar(user))
		if(linkedwall)
			if(wall_generation_cooldown > world.time)
				user << "<span class='alloy'>[src] will produce a component in <b>[(world.time - wall_generation_cooldown) * 0.1]</b> seconds.</span>"
			else
				user << "<span class='brass'>[src] is about to produce a component!</span>"
		else if(anchored)
			user << "<span class='alloy'>[src] is unlinked! Construct a Clockwork Wall nearby to generate components!</span>"
		else
			user << "<span class='alloy'>[src] needs to be secured to generate components!</span>"

/obj/structure/destructible/clockwork/cache/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		if(linkedwall)
			user << "<span class='brass'>It is linked to a Clockwork Wall and will generate a component every <b>[round((CACHE_PRODUCTION_TIME * 0.1) * get_efficiency_mod(TRUE), 0.1)]</b> seconds!</span>"
		else
			user << "<span class='alloy'>It is unlinked! Construct a Clockwork Wall nearby to generate components!</span>"
		user << "<b>Stored components:</b>"
		for(var/i in clockwork_component_cache)
			user << "<span class='[get_component_span(i)]_small'><i>[get_component_name(i)][i != REPLICANT_ALLOY ? "s":""]:</i> <b>[clockwork_component_cache[i]]</b></span>"
