///handle_chemicals_in_body///

/mob/living/carbon/human/mutant/plant/handle_chemicals_in_body()
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(loc)) //else, there's considered to be no light
		var/turf/T = loc
		var/area/A = T.loc
		if(A)
			if(A.lighting_use_dynamic)	light_amount = min(10,T.lighting_lumcount) - 5 //hardcapped so it's not abused by having a ton of flashlights
			else						light_amount =  5
	nutrition += light_amount
	if(nutrition > 500)
		nutrition = 500
	if(light_amount > 2) //if there's enough light, heal
		heal_overall_damage(1,1)
		adjustToxLoss(-1)
		adjustOxyLoss(-1)

	if(nutrition < 200)
		take_overall_damage(2,0)

	..()

/mob/living/carbon/human/mutant/shadow/handle_chemicals_in_body()
	var/light_amount = 0
	if(isturf(loc))
		var/turf/T = loc
		var/area/A = T.loc
		if(A)
			if(A.lighting_use_dynamic)	light_amount = T.lighting_lumcount
			else						light_amount =  10
	if(light_amount > 2) //if there's enough light, start dying
		take_overall_damage(1,1)
	else if (light_amount < 2) //heal in the dark
		heal_overall_damage(1,1)

	..()

//handle_regular_hud_updates//

/mob/living/carbon/human/mutant/shadow/handle_regular_hud_updates()
	..()
	see_in_dark = 8

/mob/living/carbon/human/mutant/lizard/handle_regular_hud_updates()
	..()
	see_in_dark = 3
	see_invisible = SEE_INVISIBLE_LEVEL_ONE

/mob/living/carbon/human/mutant/slime/handle_regular_hud_updates()
	..()
	see_in_dark = 3
	see_invisible = SEE_INVISIBLE_LEVEL_ONE