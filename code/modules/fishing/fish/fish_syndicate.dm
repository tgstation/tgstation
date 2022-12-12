/obj/item/fish/donkfish
	name = "donk co. company patent donkfish"
	desc = "A lab-grown donkfish. Its invention was an accident for the most part, as it was intended to be consumed in donk pockets. Unfortunately, it tastes horrible, so it has now become a pseudo-mascot."
	icon_state = "donkfish"
	random_case_rarity = FISH_RARITY_VERY_RARE
	required_fluid_type = AQUARIUM_FLUID_FRESHWATER
	stable_population = 4
	fillet_type = /obj/item/food/fishmeat/donkfish

/obj/item/fish/emulsijack
	name = "toxic emulsijack"
	desc = "Ah, the terrifying emulsijack. Created in a laboratory, this slimey, scaleless fish emits an invisible toxin that emulsifies other fish for it to feed on. Its only real use is for completely ruining a tank."
	icon_state = "emulsijack"
	random_case_rarity = FISH_RARITY_GOOD_LUCK_FINDING_THIS
	required_fluid_type = AQUARIUM_FLUID_ANADROMOUS
	stable_population = 3

/obj/item/fish/emulsijack/process(delta_time)
	var/emulsified = FALSE
	var/obj/structure/aquarium/aquarium = loc
	if(istype(aquarium))
		for(var/obj/item/fish/victim in aquarium)
			if(istype(victim, /obj/item/fish/emulsijack))
				continue //no team killing
			victim.adjust_health((victim.health - 3) * delta_time) //the victim may heal a bit but this will quickly kill
			emulsified = TRUE
	if(emulsified)
		adjust_health((health + 3) * delta_time)
		last_feeding = world.time //emulsijack feeds on the emulsion!
	..()

/obj/item/fish/deathrattle
	name = "deathrattle"
	desc = "Another sickening creation of secret syndicate laboratories. Explodes on death."
	icon_state = "deathrattle"
	random_case_rarity = FISH_RARITY_VERY_RARE
	required_fluid_type = AQUARIUM_FLUID_FRESHWATER
	stable_population = 3 //LOL
	fillet_type = /obj/item/food/fishmeat/donkfish

/obj/item/fish/deathrattle/set_status(new_status)
	. = ..()
	if(new_status == FISH_DEAD)
		log_bomber(null, null, src, "fish has died, triggering its explosion.", message_admins = TRUE)
		explosion(src, 1, 2, 4, 2) //minibomb sized, if you're curious
