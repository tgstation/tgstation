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
	SetLuminosity(2,1)

/obj/structure/destructible/clockwork/cache/Destroy()
	clockwork_caches--
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
		var/component_to_generate = get_weighted_component_id()
		PoolOrNew(get_component_animation_type(component_to_generate), get_turf(src))
		clockwork_component_cache[component_to_generate]++
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
			user.visible_message("<span class='notice'>[user] empties [S] into [src].</span>", "<span class='notice'>You offload your slab's components into [src].</span>")
		return 1
	else
		return ..()

/obj/structure/destructible/clockwork/cache/attack_hand(mob/user)
	if(!is_servant_of_ratvar(user))
		return 0
	if(!anchored)
		user << "<span class='warning'>[src] needs to be secured to remove Replicant Alloy from it!</span>"
		return 0
	if(!clockwork_component_cache[REPLICANT_ALLOY])
		user << "<span class='warning'>There is no Replicant Alloy in the global component cache!</span>"
		return 0
	clockwork_component_cache[REPLICANT_ALLOY]--
	var/obj/item/clockwork/component/replicant_alloy/A = new(get_turf(src))
	user.visible_message("<span class='notice'>[user] withdraws [A] from [src].</span>", "<span class='notice'>You withdraw [A] from [src].</span>")
	user.put_in_hands(A)
	return 1

/obj/structure/destructible/clockwork/cache/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		if(linkedwall)
			user << "<span class='brass'>It is linked and will generate a component every <b>[round((CACHE_PRODUCTION_TIME * 0.1) * get_efficiency_mod(TRUE), 0.1)]</b> seconds!</span>"
		user << "<b>Stored components:</b>"
		for(var/i in clockwork_component_cache)
			user << "<span class='[get_component_span(i)]_small'><i>[get_component_name(i)][i != REPLICANT_ALLOY ? "s":""]:</i> <b>[clockwork_component_cache[i]]</b></span>"
