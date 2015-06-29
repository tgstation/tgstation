/datum/mutation/human/stealth
	name = "Cloak Of Darkness"
	quality = POSITIVE
	get_chance = 33
	lowest_value = 256 * 14
	text_gain_indication = "<span class='notice'>You begin to fade into the shadows.</span>"
	text_lose_indication = "<span class='notice'>You become fully visible.</span>"


/datum/mutation/human/stealth/on_life(mob/living/carbon/human/owner)
	var/turf/simulated/T = get_turf(owner)
	if(!istype(T))
		return
	if((T.get_lumcount() * 10) <= 2)
		owner.alpha -= 25
	else
		owner.alpha = round(255 * 0.80)

/datum/mutation/human/stealth/on_losing(mob/living/carbon/human/owner)
	..()
	owner.alpha = 255

/datum/mutation/human/chameleon
	name = "Chameleon"
	quality = POSITIVE
	get_chance = 33
	lowest_value = 256 * 14
	text_gain_indication = "<span class='notice'>You feel one with your surroundings.</span>"
	text_lose_indication = "<span class='notice'>You feel oddly exposed.</span>"
	var/last_location

/datum/mutation/human/chameleon/on_life(mob/living/carbon/human/owner)
	owner.alpha = max(0, owner.alpha - 25)

/datum/mutation/human/chameleon/on_move(mob/living/carbon/human/owner)
	owner.alpha = 204  //famous 255 * 0.8, yes its magic number, no i wont make it a define

/datum/mutation/human/chameleon/on_losing(mob/living/carbon/human/owner)
	..()
	owner.alpha = 255