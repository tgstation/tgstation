/datum/mutation/human/stealth
	name = "Cloak Of Darkness"
	quality = POSITIVE
	get_chance = 10
	lowest_value = 256 * 14
	text_gain_indication = "<span class='notice'>You begin to fade into the shadows.</span>"
	text_lose_indication = "<span class='notice'>You become fully visible.</span>"

/datum/mutation/human/stealth/on_life(mob/living/carbon/human/owner)
	var/turf/simulated/T = get_turf(owner)
	if(!istype(T))
		return
	if(T.lighting_lumcount <= 2)
		owner.alpha -= 25
	else
		owner.alpha = round(255 * 0.80)

/datum/mutation/human/stealth/on_losing(mob/living/carbon/human/owner)
	..()
	owner.alpha = 255

/datum/mutation/human/chameleon
	name = "Chameleon"
	quality = POSITIVE
	get_chance = 10
	lowest_value = 256 * 14
	text_gain_indication = "<span class='notice'>You feel one with your surroundings.</span>"
	text_lose_indication = "<span class='notice'>You feel oddly exposed.</span>"

/datum/mutation/human/chameleon/on_life(mob/living/carbon/human/owner)
	if((world.time - owner.last_movement) >= 30 && !owner.stat && owner.canmove && !owner.restrained())
		owner.alpha -= 25
	else
		owner.alpha = round(255 * 0.80)

/datum/mutation/human/chameleon/on_losing(mob/living/carbon/human/owner)
	..()
	owner.alpha = 255