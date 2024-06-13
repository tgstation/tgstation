/mob/living/basic/chicken/void
	icon_suffix = "void"

	breed_name = "Void"
	egg_type = /obj/item/food/egg/void
	mutation_list = list()
	liked_foods = list(/obj/item/food/grown/eggplant = 5)

	book_desc = "Born from the suffering of White Chickens, they produce eggs that shrink you in size for a short duration. Research has shown this causes increased physical damage during the duration."

/obj/item/food/egg/void
	name = "Void Egg"
	icon_state = "void"

	layer_hen_type = /mob/living/basic/chicken/void

/obj/item/food/egg/void/consumed_egg(datum/source, mob/living/eater, mob/living/feeder)
	eater.apply_status_effect(/datum/status_effect/ranching/void_egg)

/datum/status_effect/ranching/void_egg
	id="void_ranching"
	duration = 10 SECONDS
	var/has_passdoor = 0
	var/has_passgrille = 0
	var/has_passglass = 0
	var/has_passmob = 0

/datum/status_effect/ranching/void_egg/on_apply()
	if(ishuman(owner))
		var/mob/living/carbon/human/user = owner
		for(var/flag in owner.pass_flags)
			if(flag == PASSDOORS)
				has_passdoor = 1
			if(flag == PASSGRILLE)
				has_passgrille = 1
			if(flag == PASSGLASS)
				has_passglass = 1
			if(flag == PASSMOB)
				has_passmob = 1

		if(!has_passmob)
			owner.pass_flags |= PASSMOB
		if(!has_passdoor)
			owner.pass_flags |= PASSDOORS
		if(!has_passgrille)
			owner.pass_flags |= PASSGRILLE
		if(!has_passglass)
			owner.pass_flags |= PASSGLASS

		user.physiology.brute_mod *= 2
		user.physiology.burn_mod *= 2
		user.transform = user.transform.Scale(0.5, 0.5)
	return ..()

/datum/status_effect/ranching/void_egg/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/user = owner
		if(!has_passmob)
			owner.pass_flags -= PASSMOB
		if(!has_passdoor)
			owner.pass_flags -= PASSDOORS
		if(!has_passgrille)
			owner.pass_flags -= PASSGRILLE
		if(!has_passglass)
			owner.pass_flags -= PASSGLASS

		user.physiology.brute_mod *= 0.5
		user.physiology.burn_mod *= 0.5
		user.transform = user.transform.Scale(2, 2)
