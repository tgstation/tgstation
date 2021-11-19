/datum/mood_event/drunk
	mood_change = 3
	description = "<span class='nicegreen'>Everything just feels better after a drink or two.</span>\n"

/datum/mood_event/quality_nice
	description = "<span class='nicegreen'>That drink wasn't bad at all.</span>\n"
	mood_change = 2
	timeout = 7 MINUTES

/datum/mood_event/quality_good
	description = "<span class='nicegreen'>That drink was pretty good.</span>\n"
	mood_change = 4
	timeout = 7 MINUTES

/datum/mood_event/quality_verygood
	description = "<span class='nicegreen'>That drink was great!</span>\n"
	mood_change = 6
	timeout = 7 MINUTES

/datum/mood_event/quality_fantastic
	description = "<span class='nicegreen'>That drink was amazing!</span>\n"
	mood_change = 8
	timeout = 7 MINUTES

/datum/mood_event/amazingtaste
	description = "<span class='nicegreen'>Amazing taste!</span>\n"
	mood_change = 50
	timeout = 10 MINUTES
	
/datum/reagent/consumable/pilk
	name = "Pilk"
	description = "A horrid bubbling combination of milk and cola. You are a fucking alchemist and no-one can tell you otherwise."
	color = "#BEAE7E" // rgb: 190, 174, 126
	quality = -4 //this is godawful, though i dont think negative quality actually does anything
	nutriment_factor = 2 * REAGENTS_METABOLISM //somehow more filling than pure nutriment
	taste_description = "bubbles, milk, whatever the hell pepis is and a want to die" //pepis is canon now, its the rival brand to Space Cola. Renember to rename this to explicitly say pepis if it gets added in.
	glass_icon_state = "pilk" //the sprite has what is intended to be foam on top as pilk makes that in real life
	glass_name = "glass of pilk"
	glass_desc = "A horrid bubbling combination of milk and cola. You are a fucking alchemist and no-one can tell you otherwise."
	glass_price = DRINK_PRICE_MEDIUM
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/pilk/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(!isfelinid(M)) //felinids love pilk
		if(isskeleton(M))
			M.adjustBruteLoss(1, 0) //ITS POISON
		else
			M.adjust_disgust(4 * REM * delta_time)
	else
		SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "full_on_pilk", /datum/mood_event/full_on_pilk, name)
	..()

/datum/reagent/consumable/ethanol/peg_nog
	name = "Peg Nog"
	description = "Its time to get PEGGED!"
	color = "#C1C17B" // rgb: 193, 193, 123
	quality = -6 //its somehow worse
	nutriment_factor = 3 * REAGENTS_METABOLISM //more filling
	boozepwr = 20
	taste_description = "getting pegged" //oh no
	glass_icon_state = "peg_nog"
	glass_name = "glass of peg nog"
	glass_desc = "Its time to get PEGGED!"
	glass_price = DRINK_PRICE_MEDIUM
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/peg_nog/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(!isfelinid(M)) //felinids love peg nog too!
		if(isskeleton(M))
			M.adjustBruteLoss(2, 0) //when drinking this you wish for bone hurting juice
		else
			M.adjust_disgust(7 * REM * delta_time)
	else
		SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "pegged", /datum/mood_event/pegged, name)
	..()
