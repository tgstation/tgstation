//Peaches
/obj/item/seeds/peach
	name = "pack of peach seeds"
	desc = "Contains seeds that grow into a lovely peach tree."
	icon_state = "seed-peach"
	species = "peach"
	plantname = "Peach Tree"
	product = /obj/item/food/grown/peach
	lifespan = 20
	endurance = 25
	yield = 5
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "peach-grow"
	icon_dead = "peach-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/peach/impeach)
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.1, /datum/reagent/water = 0.08)

/obj/item/food/grown/peach
	seed = /obj/item/seeds/peach
	name = "peach"
	desc = "Way better than canned peaches."
	icon_state = "peach"
	foodtypes = FRUIT
	juice_results = list(/datum/reagent/consumable/peachjuice = 0)
	tastes = list ("peaches" = 1)
	wine_power = 35

//impeachs
/obj/item/seeds/peach/impeach
	name = "pack of impeach seeds"
	desc = "A pack of impeach seeds."
	icon_state = "seed-impeach"
	species = "peach"
	plantname = "Impeach Tree"
	product = /obj/item/food/grown/peach/impeach
	icon_harvest = "impeach-harvest"
	mutatelist = list()
	rarity = 5

/obj/item/food/grown/peach/impeach
	seed = /obj/item/seeds/peach/impeach
	name = "impeach"
	desc = "A quick way to impeach your pets, friends or even your whole family!"
	icon_state = "impeach"
	var/activated = FALSE

/**
* Creates and spawns a giant peach locker.
*/
/obj/item/food/grown/peach/impeach/proc/create_plocker(user)
	var /obj/structure/closet/secure_closet/plocker/P = new /obj/structure/closet/secure_closet/plocker(get_turf(src.loc))
	P.visible_message("<span class='notice'>[src] suddenly turns into a giant peach!</span>")
	P.obj_integrity = round(P.max_integrity + (seed.potency / 4))
	P.damage_deflection = round(seed.endurance / 15)
	P.breakout_time += round(seed.endurance / 2)
	P.lifespan += round(seed.lifespan * 6)
	P.owner = user
	playsound(loc, 'sound/misc/moist_impact.ogg', 200, TRUE)
	return P

/**
* Used when the impeach isnt thrown in time, or is dropped.
*/
/obj/item/food/grown/peach/impeach/proc/dry_activate(user)
	if(QDELETED(src))
		return
	var /obj/structure/closet/secure_closet/plocker/P = create_plocker(user)
	for(var/mob/M in get_turf(P))
		if(P.insert(M))
			log_combat(user, M, "trapped", /obj/item/food/grown/peach/impeach)
	qdel(src)

/**
* Activates the timer for the impeach
*/
/obj/item/food/grown/peach/impeach/attack_self(mob/user)
	icon_state = "impeach_active"
	activated = TRUE
	addtimer(CALLBACK(src, .proc/dry_activate, user), 3 SECONDS)
	playsound(loc, 'sound/misc/twisting.ogg', 60, TRUE)

/**
* When coming in contact with a mob while active it will put them into a locker
*/
/obj/item/food/grown/peach/impeach/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(QDELETED(src) || activated == FALSE)
		return
	var /obj/structure/closet/secure_closet/plocker/P = create_plocker(throwingdatum.thrower)
	if(P.insert(hit_atom)) //when the impeach hits a mob
		log_combat(throwingdatum.thrower, hit_atom, "trapped", /obj/item/food/grown/peach/impeach)
	else //when the impeach hits anything that isnt a mob
		for(var/mob/M in get_turf(P))
			if(P.insert(M))
				log_combat(throwingdatum.thrower, M, "trapped", /obj/item/food/grown/peach/impeach)
	qdel(src)
