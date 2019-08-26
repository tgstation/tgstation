/datum/reagent/australium
	name = "Australium"
	color = "#F2BE11"
	description = "Pure distilled essence of Australia. Can cause subjects to suddenly appear down-under."
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "australia"

/datum/reagent/australium/on_mob_life(mob/living/carbon/M)
	if(prob(10))
		M.say(pick("Cunt!", "Fuck off cunt!", "Tell him he's dreaming!", "Have a go, ya mug!", "Put a sock in it!", "She'll be right!", "I know a pretender when I see one!", "Wrap ya laughing gear 'round that!", "Throw another shrimp on the barbie!"), forced = /datum/reagent/australium)
	..()

/datum/reagent/australium/on_mob_add(mob/living/L)
	. = ..()
	var/matrix/M = matrix()
	M.Turn(180)
	L.transform = M

/datum/reagent/australium/on_mob_delete(mob/living/L)
	. = ..()
	L.transform = matrix()
