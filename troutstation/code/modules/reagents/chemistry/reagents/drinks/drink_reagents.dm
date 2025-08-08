/datum/reagent/consumable/lime_spider
	name = "Lime Spider"
	description = "Oddly popular on Io, this float is a twist on the typical: instead of ice cream in a cola, it is in a lime soda. The name is derived from the foam produced, being reminiscent of a spider's web."
	color = "#95d68a"
	quality = DRINK_GOOD
	nutriment_factor = 3
	taste_description = "creamy lime"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/lime_spider/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/lime_spider)


/datum/reagent/medicine/gaywater
    name = "Gay Water"
    description = "An ubiquitous chemical substance that is composed of hydrogen and oxygen. But gay."
    color = "#ff99fcfF"
    taste_description = "gay"
    var/cooling_temperature = 2
    chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_CLEANS
    default_container = /obj/item/reagent_containers/cup/glass/waterbottle

/datum/reagent/medicine/gaywater/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(5, seconds_per_tick))
		playsound(get_turf(drinker), 'troutstation/sound/misc/gay.ogg', 100, TRUE) // plays ytpmv elf Gay sound
		to_chat(drinker, span_notice("You're gay."))

/datum/glass_style/drinking_glass/gaywater
    required_drink_type = /datum/reagent/medicine/gaywater
    name = "glass of gay water"
    desc = "The queerest of all refreshments."

/datum/reagent/medicine/gaywater/overdose_start(mob/living/carbon/affected_mob)
	var/mob/living/carbon/human/affected_human = affected_mob
	to_chat(affected_human, span_userdanger("You feel incredibly gay... gay people..."))
	playsound(get_turf(affected_human), 'troutstation/sound/misc/gay.ogg', 100, TRUE)

	if(HAS_TRAIT(affected_human, TRAIT_USES_SKINTONES))
		affected_human.skin_tone = "pink" // pink skin for humans
	else if(HAS_TRAIT(affected_human, TRAIT_MUTANT_COLORS) && !HAS_TRAIT(affected_human, TRAIT_FIXED_MUTANT_COLORS)) //Code stolen from green beer overdose
		affected_human.dna.features[FEATURE_MUTANT_COLOR] = "#ff99fc"
	affected_human.update_body(is_creating = TRUE)

/datum/reagent/medicine/gaywater/overdose_process(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(20, seconds_per_tick))
		playsound(affected_mob, 'troutstation/sound/misc/gay.ogg', 100, FALSE) // Only audible to the mob
	if(prob(5))
		affected_mob.say(pick("bable", "beble", "bible", "boble", "booble", "babie", "bebie", "bibie", "bobie", "bubie", "boobie"))
		sleep(100)
