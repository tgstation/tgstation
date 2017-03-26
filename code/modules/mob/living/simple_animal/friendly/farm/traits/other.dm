/datum/farm_animal_trait/talkative
	name = "Talkative"
	description = "This animal will attempt to talk more often and mimic what others say."
	manifest_probability = 55
	continue_probability = 75

/datum/farm_animal_trait/talkative/on_apply(var/mob/living/simple_animal/farm/M)
	M.speak_chance = 15
	return

/datum/farm_animal_trait/talkative/on_hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans)
	if(speaker != owner.owner && prob(40)) //Dont imitate ourselves
		if(owner.owner.speak.len >= 40)
			owner.owner.speak -= pick(owner.owner.speak)
		owner.owner.speak |= html_decode(raw_message)

/datum/farm_animal_trait/bioluminescent
	name = "Bioluminescent"
	description = "This animal is bioluminescent, and glows."
	manifest_probability = 55
	continue_probability = 75

/datum/farm_animal_trait/bioluminescent/on_apply(var/mob/living/simple_animal/farm/M)
	M.SetLuminosity(4)
	return

/datum/farm_animal_trait/spooky
	name = "Spooky"
	description = "This animal is transparent and spooky."
	manifest_probability = 55
	continue_probability = 75

/datum/farm_animal_trait/spooky/on_apply(var/mob/living/simple_animal/farm/M)
	animate(M, alpha = 127, time = 30)
	return

/datum/farm_animal_trait/spooky/on_death(var/mob/living/simple_animal/farm/M)
	M.visible_message("[M] fades away...")
	animate(M, alpha = 0, time = 30)
	spawn(30)
	qdel(M)
	return

/datum/farm_animal_trait/chromatic_skin
	name = "Chromatic Skin"
	description = "This animal has chromatic skin, and will appear to be a rainbow of colors."
	manifest_probability = 55
	continue_probability = 75
	var/rainbow = FALSE
	var/cycling = FALSE

/datum/farm_animal_trait/chromatic_skin/on_apply(var/mob/living/simple_animal/farm/M)
	rainbow = TRUE
	return

/datum/farm_animal_trait/chromatic_skin/on_life(var/mob/living/simple_animal/farm/M)
	if(!cycling)
		cycling = TRUE
		animate(M, color = "#0000FF", time = 30)
		sleep(30)
		animate(M, color = "#00FF00", time = 30)
		sleep(30)
		animate(M, color = "#FF0000", time = 30)
		sleep(30)
		cycling = FALSE
	return

/datum/farm_animal_trait/chromatic_skin/on_death(var/mob/living/simple_animal/farm/M)
	rainbow = FALSE
	M.color = null
	return

/datum/farm_animal_trait/incendiary_mitochondria
	name = "Incendiary Mitochondria"
	description = "This animal is permanently on fire and will not suffer burn damage."
	manifest_probability = 55
	continue_probability = 75
	var/rainbow = FALSE

/datum/farm_animal_trait/incendiary_mitochondria/on_apply(var/mob/living/simple_animal/farm/M)
	var/image/fireOverlay = image(getOnFireIcon(new/icon(M.icon,M.icon_state)), loc = src)
	M.overlays += fireOverlay
	return

/datum/farm_animal_trait/incendiary_mitochondria/on_life(var/mob/living/simple_animal/farm/M)
	M.adjustFireLoss(-(M.getFireLoss()))
	return

/datum/farm_animal_trait/incendiary_mitochondria/on_death(var/mob/living/simple_animal/farm/M)
	M.visible_message("[M] burns into dust.")
	M.spawn_dust()
	qdel(M)
	return

/datum/farm_animal_trait/incendiary_mitochondria/on_attack_mob(var/mob/living/simple_animal/farm/M, var/mob/living/L)
	L.adjustFireLoss(M.dna.strength)
	return

/datum/farm_animal_trait/strong
	name = "Strong"
	description = "This animal is strong."
	manifest_probability = 25
	continue_probability = 50

/datum/farm_animal_trait/strong/on_apply(var/mob/living/simple_animal/farm/M)
	M.dna.strength = 20
	M.melee_damage_upper = 20
	M.melee_damage_lower = 20
	return

