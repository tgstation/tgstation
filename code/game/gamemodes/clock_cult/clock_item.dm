/obj/item/clockwork
	name = "meme blaster"
	desc = "What the fuck is this? It looks kinda like a frog."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/clockwork_desc = "A fabled artifact from beyond the stars. Contains concentrated meme essence." //Shown to clockwork cultists instead of the normal description
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "rare_pepe"
	w_class = 2

/obj/item/clockwork/New()
	..()
	all_clockwork_objects += src

/obj/item/clockwork/Destroy()
	all_clockwork_objects -= src
	return ..()

/obj/item/clockwork/examine(mob/user)
	if((is_servant_of_ratvar(user) || isobserver(user)) && clockwork_desc)
		desc = clockwork_desc
	..()
	desc = initial(desc)

/obj/item/clockwork/daemon_shell
	name = "daemon shell"
	desc = "A vaguely arachnoid brass shell with a single empty socket in its body."
	clockwork_desc = "An unpowered daemon. It needs to be attached to a Tinkerer's Cache."
	icon_state = "daemon_shell"
	w_class = 3

/obj/item/clockwork/daemon_shell/New()
	..()
	clockwork_daemons++

/obj/item/clockwork/daemon_shell/Destroy()
	clockwork_daemons--
	return ..()

/obj/item/clockwork/tinkerers_daemon //Shouldn't ever appear on its own
	name = "tinkerer's daemon"
	desc = "An arachnoid shell with a single spinning cogwheel in its center."
	clockwork_desc = "A tinkerer's daemon, dutifully producing components."
	icon_state = "tinkerers_daemon"
	w_class = 3
	var/specific_component //The type of component that the daemon is set to produce in particular, if any
	var/obj/structure/destructible/clockwork/cache/cache //The cache the daemon is feeding
	var/production_time = 0 //Progress towards production of the next component in seconds
	var/production_cooldown = 200 //How many deciseconds it takes to produce a new component
	var/component_slowdown_mod = 2 //how many deciseconds are added to the cooldown when producing a component for each of that component type

/obj/item/clockwork/tinkerers_daemon/New()
	..()
	START_PROCESSING(SSobj, src)
	clockwork_daemons++

/obj/item/clockwork/tinkerers_daemon/Destroy()
	STOP_PROCESSING(SSobj, src)
	clockwork_daemons--
	return ..()

/obj/item/clockwork/tinkerers_daemon/process()
	if(!cache || !istype(loc, /obj/structure/destructible/clockwork/cache))
		visible_message("<span class='warning'>[src] shuts down!</span>")
		new/obj/item/clockwork/daemon_shell(get_turf(src))
		qdel(src)
		return 0
	var/servants = 0
	for(var/mob/living/L in living_mob_list)
		if(is_servant_of_ratvar(L))
			servants++
	if(servants * 0.2 < clockwork_daemons)
		return 0
	if(production_time <= world.time)
		var/component_to_generate = specific_component
		if(!component_to_generate)
			component_to_generate = get_weighted_component_id() //more likely to generate components that we have less of
		clockwork_component_cache[component_to_generate]++
		production_time = world.time + production_cooldown + (clockwork_component_cache[component_to_generate] * component_slowdown_mod) //Start it over
		cache.visible_message("<span class='warning'>[cache] hums as the tinkerer's daemon within it produces a component.</span>")

/obj/item/clockwork/tinkerers_daemon/attack_hand(mob/user)
	return 0
