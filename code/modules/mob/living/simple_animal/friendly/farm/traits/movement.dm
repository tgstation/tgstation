/datum/farm_animal_trait/vine_eating
	name = "Vine-Eating"
	description = "This animal will eat vines it encounters."
	manifest_probability = 55
	continue_probability = 75

/datum/farm_animal_trait/vine_eating/on_move(var/mob/living/simple_animal/farm/M)
	if(!M.stat)
		if(locate(/obj/effect/spacevine) in M.loc)
			var/obj/effect/spacevine/SV = locate(/obj/effect/spacevine) in M.loc
			SV.eat(M)
			M.hunger += 50

/datum/farm_animal_trait/vine_eating/on_life(var/mob/living/simple_animal/farm/M)
	if(M.stat == CONSCIOUS)
		if(locate(/obj/effect/spacevine) in M.loc)
			var/obj/effect/spacevine/SV = locate(/obj/effect/spacevine) in M.loc
			SV.eat(M)
			M.hunger += 50
		if(!M.pulledby)
			for(var/direction in shuffle(list(1,2,4,8,5,6,9,10)))
				var/step = get_step(M, direction)
				if(step)
					if(locate(/obj/effect/spacevine) in step)
						M.Move(step, get_dir(M, step))

/datum/farm_animal_trait/ridable
	name = "Ridable"
	description = "This animal will let you ride them."
	manifest_probability = 55
	continue_probability = 75
	opposite_trait = /datum/farm_animal_trait/flying

/datum/farm_animal_trait/ridable/on_apply(var/mob/living/simple_animal/farm/M)
	M.can_buckle = 1
	M.buckle_lying = 0
	return

/datum/farm_animal_trait/flying
	name = "Flying"
	description = "This animal can fly."
	manifest_probability = 55
	continue_probability = 75
	opposite_trait = /datum/farm_animal_trait/ridable
	var/is_flying = FALSE
	var/is_falling = FALSE
	var/image/shadow

/datum/farm_animal_trait/flying/on_apply(var/mob/living/simple_animal/farm/M)
	shadow = image('icons/effects/effects.dmi', "under_shadow")
	shadow.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	M.overlays += shadow
	animate(M, pixel_z = 15, time = 20)
	spawn(10)
	is_flying = TRUE
	M.pass_flags = PASSTABLE | PASSGRILLE | PASSMOB | PASSBLOB
	return

/datum/farm_animal_trait/flying/on_life(var/mob/living/simple_animal/farm/M)
	if(is_flying && !is_falling)
		animate(M, pixel_z = 10, time = 10)
		spawn(10)
		animate(M, pixel_z = 15, time = 10)
		spawn(10)
		animate(M, pixel_z = 10, time = 10)
		spawn(10)
		animate(M, pixel_z = 15, time = 10)
		spawn(10)
			return

/datum/farm_animal_trait/flying/on_death(var/mob/living/simple_animal/farm/M)
	is_flying = FALSE
	is_falling = TRUE
	animate(M, pixel_z = 0, time = 10)
	sleep(10)
	M.overlays -= shadow
	M.pass_flags = 0
	return

/datum/farm_animal_trait/slow
	name = "Slow"
	description = "This animal is slow."
	manifest_probability = 55
	continue_probability = 75
	opposite_trait = /datum/farm_animal_trait/fast

/datum/farm_animal_trait/slow/on_apply(var/mob/living/simple_animal/farm/M)
	M.speed = 2
	return

/datum/farm_animal_trait/fast
	name = "Fast"
	description = "This animal is fast."
	manifest_probability = 55
	continue_probability = 75
	opposite_trait = /datum/farm_animal_trait/slow

/datum/farm_animal_trait/fast/on_apply(var/mob/living/simple_animal/farm/M)
	M.speed = 0
	return
