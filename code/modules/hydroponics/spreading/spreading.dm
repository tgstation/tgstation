#define DEFAULT_SEED "glowshroom"
#define CREEPER_GROWTH_DISTANCE 4

/obj/effect/plantsegment
	name = "space vines"
	desc = "An extremely expansionistic species of vine."
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "Light1"
	anchored = 1
	opacity = 0
	density = 0
	layer = 5
	pass_flags = PASSTABLE | PASSGRILLE
	//mouse_opacity = 2

	var/health = 10
	var/max_health = 100
	var/list/turf/simulated/floor/neighbors = list()
	var/turf/epicenter
	var/datum/seed/seed
	var/sampled = 0
	var/spread_chance
	var/spread_distance
	var/mature_time
	var/tmp/last_tick = 0
	var/tmp/last_special = 0
	var/harvest = 0
	var/age = 0
	var/limited_growth = 0
	var/plant_damage_noun = "Thorns"
	var/tmp/on_resist_key //For resisting out of vines.

/obj/effect/plantsegment/creeper
	limited_growth = 1
/obj/effect/plantsegment/single
	spread_chance = 0

/obj/effect/plantsegment/Destroy()
	if(plant_controller)
		plant_controller.remove_plant(src)
	for(var/obj/effect/plantsegment/neighbor in range(1,src)) //i ded, tell my neighbors to wake up so they can take up my space
		plant_controller.add_plant(neighbor)
	..()

/obj/effect/plantsegment/New(var/newloc, var/datum/seed/newseed, var/turf/newepicenter, var/start_fully_mature = 0)
	..()

	if(!newepicenter)
		epicenter = get_turf(src)
	else
		epicenter = newepicenter

	if(!plant_controller)
		sleep(250) // ugly hack, should mean roundstart plants are fine.
	if(!plant_controller)
		error("<span class='danger'>Plant controller does not exist and [src] requires it. Aborting.</span>")
		qdel(src)
		return

	if(!istype(newseed))
		newseed = plant_controller.seeds[DEFAULT_SEED]
	seed = newseed
	if(!seed)
		qdel(src)
		return

	name = "[seed.seed_name] vines"
	max_health = round(seed.endurance/2)
	if(seed.spread == 1)
		limited_growth = 1
	mature_time = Ceiling(seed.maturation/2)
	spread_chance = round(40 + triangular_seq(seed.potency*2, 30)) // Diminishing returns formula, see maths.dm
	spread_distance = limited_growth ? (CREEPER_GROWTH_DISTANCE) : round(spread_chance*0.2)
	update_icon()

	if(start_fully_mature)
		health = max_health
		mature_time = 0

	spawn(1) // Plants will sometimes be spawned in the turf adjacent to the one they need to end up in, for the sake of correct dir/etc being set.
		plant_controller.add_plant(src)
		// Some plants eat through plating.
		if(seed.chems && !isnull(seed.chems["pacid"]))
			var/turf/T = get_turf(src)
			T.ex_act(prob(80) ? 3 : 2)

/obj/effect/plantsegment/examine(mob/user)
	..()
	if(!seed) return
	var/traits = ""
	if(seed.carnivorous == 2) traits += "<span class='alert'>It's quivering viciously.</span> "
	if(seed.stinging) traits += "<span class='alert'>It's covered in tiny stingers.</span> "
	if(seed.thorny) traits += "<span class='alert'>It's covered in sharp thorns.</span> "
	if(seed.ligneous) traits += "It's a tough and hard vine that can't be easily cut. "
	if(seed.hematophage) traits += "It's roots are blood red... "
	if(src.harvest) traits += "It has some [seed.seed_name]s ready to grab."
	if(traits) to_chat(user, traits)

/obj/effect/plantsegment/update_icon()
	var/arbitrary_measurement_of_how_lush_I_am_right_now // a post-mortem dedication to Comic
	if(harvest)
		arbitrary_measurement_of_how_lush_I_am_right_now = 4
	else if (age > mature_time)
		var/arbitrary_wait = 2*mature_time
		if(age >= arbitrary_wait)
			arbitrary_measurement_of_how_lush_I_am_right_now = 3
		else
			arbitrary_measurement_of_how_lush_I_am_right_now = 2
	else
		arbitrary_measurement_of_how_lush_I_am_right_now = 1

	var/at_fringe = get_dist(src,epicenter)
	if(at_fringe >= round(spread_distance*0.9))
		arbitrary_measurement_of_how_lush_I_am_right_now--
	if(at_fringe >= round(spread_distance*0.7))
		arbitrary_measurement_of_how_lush_I_am_right_now--
	if(health < max_health)
		arbitrary_measurement_of_how_lush_I_am_right_now -= round(-(health - max_health)/(max_health/3))

	arbitrary_measurement_of_how_lush_I_am_right_now = max(1, arbitrary_measurement_of_how_lush_I_am_right_now)

	switch(arbitrary_measurement_of_how_lush_I_am_right_now)
		if(1)
			icon_state = "Light[rand(1,3)]"
			src.opacity = 0
		if(2)
			icon_state = "Med[rand(1,3)]"
			src.opacity = 0
		if(3)
			icon_state = "Hvy[rand(1,3)]"
			if(!limited_growth) src.opacity = 1
		if(4)
			icon_state = "Hvst[rand(1,3)]"
			if(!limited_growth) src.opacity = 1

	// Apply colour and light from seed datum.
	if(seed.biolum && seed.biolum_colour && is_mature())
		set_light(1+round(seed.potency/20), l_color = seed.biolum_colour)
		return
	else
		set_light(0)

/obj/effect/plantsegment/attackby(var/obj/item/weapon/W, var/mob/user)
	if(user.a_intent == I_HELP && is_type_in_list(W, list(/obj/item/weapon/wirecutters, /obj/item/weapon/scalpel)))
		if(sampled)
			to_chat(user, "<span class='warning'>\The [src] has already been sampled recently.</span>")
			return
		if(!is_mature())
			to_chat(user, "<span class='warning'>\The [src] is not mature enough to yield a sample yet.</span>")
			return
		if(!seed)
			to_chat(user, "<span class='warning'>There is nothing to take a sample from.</span>")
			return
		if(sampled)
			to_chat(user, "<span class='danger'>You cannot take another sample from \the [src].</span>")
			return
		if(prob(70))
			sampled = 1
		seed.spawn_seed_packet(get_turf(user))
		health -= (rand(3,5)*5)
		sampled = 1
		plant_controller.add_plant(src)
	else if (istype(W, /obj/item/weapon/storage/bag/plants))
		attack_hand(user)
		var/obj/item/weapon/storage/bag/plants/S = W
		for (var/obj/item/weapon/reagent_containers/food/snacks/grown/G in locate(user.x,user.y,user.z))
			if(!S.can_be_inserted(G))
				return
			S.handle_item_insertion(G, 1)
	else
		..()
		take_damage(W)
		user.delayNextAttack(10)

/obj/effect/plantsegment/proc/take_damage(var/obj/item/weapon/W)
	if(!W.force) return 0
	var/dmg = W.force
	if(W.is_hot() || (W.is_sharp() && !seed.ligneous))
		dmg = dmg*4
	health -= dmg
	check_health()
	update_icon()

/obj/effect/plantsegment/ex_act(severity)
	switch(severity)
		if(1.0)
			die_off()
		if(2.0)
			if (prob(50))
				die_off()
		if(3.0)
			if (prob(5))
				die_off()
		else
			do_nothing()

/obj/effect/plantsegment/proc/do_nothing()
	return "done"

// Hotspots kill vines.
/obj/effect/plantsegment/fire_act(null, temp, volume)
	die_off()

/obj/effect/plantsegment/proc/check_health()
	if(health <= 0)
		die_off()

/obj/effect/plantsegment/proc/is_mature()
	return (health >= (max_health/2) && age > mature_time)

#undef CREEPER_GROWTH_DISTANCE
