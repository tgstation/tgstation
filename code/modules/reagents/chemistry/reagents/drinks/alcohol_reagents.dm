#define ALCOHOL_THRESHOLD_MODIFIER 1 //Greater numbers mean that less alcohol has greater intoxication potential
#define ALCOHOL_EXPONENT 1.6 //The exponent applied to boozepwr to make higher volume alcohol at least a little bit damaging to the liver

/datum/reagent/consumable/ethanol
	name = "Ethanol"
	description = "A well-known alcohol with a variety of applications."
	color = "#404030" // rgb: 64, 64, 48
	nutriment_factor = 0
	taste_description = "alcohol"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	ph = 7.33
	burning_temperature = 2193//ethanol burns at 1970C (at it's peak)
	burning_volume = 0.1
	default_container = /obj/item/reagent_containers/cup/glass/bottle/beer
	fallback_icon = 'icons/obj/drinks/bottles.dmi'
	fallback_icon_state = "beer"
	/**
	 * Boozepwr Chart
	 *
	 * Higher numbers equal higher hardness, higher hardness equals more intense alcohol poisoning
	 *
	 * Note that all higher effects of alcohol poisoning will inherit effects for smaller amounts
	 * (i.e. light poisoning inherts from slight poisoning)
	 * In addition, severe effects won't always trigger unless the drink is poisonously strong
	 * All effects don't start immediately, but rather get worse over time; the rate is affected by the imbiber's alcohol tolerance
	 * (see [/datum/status_effect/inebriated])
	 *
	 * * 0: Non-alcoholic
	 * * 1-10: Barely classifiable as alcohol - occassional slurring
	 * * 11-20: Slight alcohol content - slurring
	 * * 21-30: Below average - imbiber begins to look slightly drunk
	 * * 31-40: Just below average - no unique effects
	 * * 41-50: Average - mild disorientation, imbiber begins to look drunk
	 * * 51-60: Just above average - disorientation, vomiting, imbiber begins to look heavily drunk
	 * * 61-70: Above average - small chance of blurry vision, imbiber begins to look smashed
	 * * 71-80: High alcohol content - blurry vision, imbiber completely shitfaced
	 * * 81-90: Extremely high alcohol content - heavy toxin damage, passing out
	 * * 91-100: Dangerously toxic - swift death
	 */
	var/boozepwr = 65

/datum/reagent/consumable/ethanol/New(list/data)
	if(LAZYLEN(data))
		if(data["quality"])
			quality = data["quality"]
			name = "Natural " + name
		if(data["boozepwr"])
			boozepwr = data["boozepwr"]
	addiction_types = list(/datum/addiction/alcohol = 0.05 * boozepwr)
	return ..()

/datum/reagent/consumable/ethanol/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	if(drinker.get_drunk_amount() < volume * boozepwr * ALCOHOL_THRESHOLD_MODIFIER || boozepwr < 0)
		var/booze_power = boozepwr
		if(HAS_TRAIT(drinker, TRAIT_ALCOHOL_TOLERANCE)) //we're an accomplished drinker
			booze_power *= 0.7
		if(HAS_TRAIT(drinker, TRAIT_LIGHT_DRINKER))
			booze_power *= 2
		// Volume, power, and server alcohol rate effect how quickly one gets drunk
		drinker.adjust_drunk_effect(sqrt(volume) * booze_power * ALCOHOL_RATE * REM * seconds_per_tick)
		if(boozepwr > 0)
			var/obj/item/organ/internal/liver/liver = drinker.get_organ_slot(ORGAN_SLOT_LIVER)
			var/heavy_drinker_multiplier = (HAS_TRAIT(drinker, TRAIT_HEAVY_DRINKER) ? 0.5 : 1)
			if (istype(liver))
				liver.apply_organ_damage(((max(sqrt(volume) * (boozepwr ** ALCOHOL_EXPONENT) * liver.alcohol_tolerance * heavy_drinker_multiplier * seconds_per_tick, 0))/150))
	return ..()

/datum/reagent/consumable/ethanol/expose_obj(obj/exposed_obj, reac_volume)
	if(istype(exposed_obj, /obj/item/paper))
		var/obj/item/paper/paperaffected = exposed_obj
		paperaffected.clear_paper()
		to_chat(usr, span_notice("[paperaffected]'s ink washes away."))
	if(istype(exposed_obj, /obj/item/book))
		if(reac_volume >= 5)
			var/obj/item/book/affectedbook = exposed_obj
			affectedbook.book_data.set_content("")
			exposed_obj.visible_message(span_notice("[exposed_obj]'s writing is washed away by [name]!"))
		else
			exposed_obj.visible_message(span_warning("[exposed_obj]'s ink is smeared by [name], but doesn't wash away!"))
	return ..()

/datum/reagent/consumable/ethanol/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)//Splashing people with ethanol isn't quite as good as fuel.
	. = ..()
	if(!(methods & (TOUCH|VAPOR|PATCH)))
		return

	exposed_mob.adjust_fire_stacks(reac_volume / 15)

	if(!iscarbon(exposed_mob))
		return

	var/mob/living/carbon/exposed_carbon = exposed_mob
	var/power_multiplier = boozepwr / 65 // Weak alcohol has less sterilizing power

	for(var/datum/surgery/surgery as anything in exposed_carbon.surgeries)
		surgery.speed_modifier = max(0.1 * power_multiplier, surgery.speed_modifier)

/datum/reagent/consumable/ethanol/beer
	name = "Beer"
	description = "An alcoholic beverage brewed since ancient times on Old Earth. Still popular today."
	color = "#664300" // rgb: 102, 67, 0
	nutriment_factor = 1 * REAGENTS_METABOLISM
	boozepwr = 25
	taste_description = "mild carbonated malt"
	ph = 4
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_STOCK

// Beer is a chemical composition of alcohol and various other things. It's a garbage nutrient but hey, it's still one. Also alcohol is bad, mmmkay?
/datum/reagent/consumable/ethanol/beer/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_plant_health(-round(volume * 0.05))
	mytray.adjust_waterlevel(round(volume * 0.7))

/datum/reagent/consumable/ethanol/beer/light
	name = "Light Beer"
	description = "An alcoholic beverage brewed since ancient times on Old Earth. This variety has reduced calorie and alcohol content."
	boozepwr = 5 //Space Europeans hate it
	taste_description = "dish water"
	ph = 5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/beer/maltliquor
	name = "Malt Liquor"
	description = "An alcoholic beverage brewed since ancient times on Old Earth. This variety is stronger than usual, super cheap, and super terrible."
	boozepwr = 35
	taste_description = "sweet corn beer and the hood life"
	ph = 4.8
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/beer/green
	name = "Green Beer"
	description = "An alcoholic beverage brewed since ancient times on Old Earth. This variety is dyed a festive green."
	color = COLOR_CRAYON_GREEN
	taste_description = "green piss water"
	ph = 6
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/beer/green/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	if(drinker.color != color)
		drinker.add_atom_colour(color, TEMPORARY_COLOUR_PRIORITY)
	return ..()

/datum/reagent/consumable/ethanol/beer/green/on_mob_end_metabolize(mob/living/drinker)
	drinker.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, color)

/datum/reagent/consumable/ethanol/kahlua
	name = "Kahlua"
	description = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936!"
	color = "#8e8368" // rgb: 142,131,104
	boozepwr = 45
	ph = 6
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/kahlua/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	drinker.set_dizzy_if_lower(10 SECONDS * REM * seconds_per_tick)
	drinker.adjust_drowsiness(-6 SECONDS * REM * seconds_per_tick)
	drinker.AdjustSleeping(-40 * REM * seconds_per_tick)
	if(!HAS_TRAIT(drinker, TRAIT_ALCOHOL_TOLERANCE))
		drinker.set_jitter_if_lower(10 SECONDS)
	..()
	. = TRUE

/datum/reagent/consumable/ethanol/whiskey
	name = "Whiskey"
	description = "A superb and well-aged single-malt whiskey. Damn."
	color = "#b4a287" // rgb: 180,162,135
	boozepwr = 75
	taste_description = "molasses"
	ph = 4.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_STOCK

/datum/reagent/consumable/ethanol/whiskey/kong
	name = "Kong"
	description = "Makes You Go Ape!&#174;"
	color = "#332100" // rgb: 51, 33, 0
	taste_description = "the grip of a giant ape"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/whiskey/candycorn
	name = "Candy Corn Liquor"
	description = "Like they drank in 2D speakeasies."
	color = "#ccb800" // rgb: 204, 184, 0
	taste_description = "pancake syrup"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/whiskey/candycorn/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	if(SPT_PROB(5, seconds_per_tick))
		drinker.adjust_hallucinations(4 SECONDS * REM * seconds_per_tick)
	..()

/datum/reagent/consumable/ethanol/thirteenloko
	name = "Thirteen Loko"
	description = "A potent mixture of caffeine and alcohol."
	color = "#102000" // rgb: 16, 32, 0
	nutriment_factor = 1 * REAGENTS_METABOLISM
	boozepwr = 80
	quality = DRINK_GOOD
	overdose_threshold = 60
	taste_description = "jitters and death"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/thirteenloko/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	drinker.adjust_drowsiness(-14 SECONDS * REM * seconds_per_tick)
	drinker.AdjustSleeping(-40 * REM * seconds_per_tick)
	drinker.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, drinker.get_body_temp_normal())
	if(!HAS_TRAIT(drinker, TRAIT_ALCOHOL_TOLERANCE))
		drinker.set_jitter_if_lower(10 SECONDS)
	..()
	return TRUE

/datum/reagent/consumable/ethanol/thirteenloko/overdose_start(mob/living/drinker)
	to_chat(drinker, span_userdanger("Your entire body violently jitters as you start to feel queasy. You really shouldn't have drank all of that [name]!"))
	drinker.set_jitter_if_lower(40 SECONDS)
	drinker.Stun(1.5 SECONDS)

/datum/reagent/consumable/ethanol/thirteenloko/overdose_process(mob/living/drinker, seconds_per_tick, times_fired)
	if(SPT_PROB(3.5, seconds_per_tick) && iscarbon(drinker))
		var/obj/item/held_item = drinker.get_active_held_item()
		if(held_item)
			drinker.dropItemToGround(held_item)
			to_chat(drinker, span_notice("Your hands jitter and you drop what you were holding!"))
			drinker.set_jitter_if_lower(20 SECONDS)

	if(SPT_PROB(3.5, seconds_per_tick))
		to_chat(drinker, span_notice("[pick("You have a really bad headache.", "Your eyes hurt.", "You find it hard to stay still.", "You feel your heart practically beating out of your chest.")]"))

	if(SPT_PROB(2.5, seconds_per_tick) && iscarbon(drinker))
		var/obj/item/organ/internal/eyes/eyes = drinker.get_organ_slot(ORGAN_SLOT_EYES)
		if(eyes && IS_ORGANIC_ORGAN(eyes)) // doesn't affect robotic eyes
			if(drinker.is_blind())
				eyes.Remove(drinker)
				eyes.forceMove(get_turf(drinker))
				to_chat(drinker, span_userdanger("You double over in pain as you feel your eyeballs liquify in your head!"))
				drinker.emote("scream")
				drinker.adjustBruteLoss(15, required_bodytype = affected_bodytype)
			else
				to_chat(drinker, span_userdanger("You scream in terror as you go blind!"))
				eyes.apply_organ_damage(eyes.maxHealth)
				drinker.emote("scream")

	if(SPT_PROB(1.5, seconds_per_tick) && iscarbon(drinker))
		drinker.visible_message(span_danger("[drinker] starts having a seizure!"), span_userdanger("You have a seizure!"))
		drinker.Unconscious(10 SECONDS)
		drinker.set_jitter_if_lower(700 SECONDS)

	if(SPT_PROB(0.5, seconds_per_tick) && iscarbon(drinker))
		var/datum/disease/heart_attack = new /datum/disease/heart_failure
		drinker.ForceContractDisease(heart_attack)
		to_chat(drinker, span_userdanger("You're pretty sure you just felt your heart stop for a second there.."))
		drinker.playsound_local(drinker, 'sound/effects/singlebeat.ogg', 100, 0)

/datum/reagent/consumable/ethanol/vodka
	name = "Vodka"
	description = "Number one drink AND fueling choice for Russians worldwide."
	color = "#0064C8" // rgb: 0, 100, 200
	boozepwr = 65
	taste_description = "grain alcohol"
	ph = 8.1
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_CLEANS //Very high proof
	default_container = /obj/item/reagent_containers/cup/glass/bottle/vodka

/datum/reagent/consumable/ethanol/bilk
	name = "Bilk"
	description = "This appears to be beer mixed with milk. Disgusting."
	color = "#895C4C" // rgb: 137, 92, 76
	nutriment_factor = 2 * REAGENTS_METABOLISM
	boozepwr = 15
	taste_description = "desperation and lactate"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/bilk/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	if(drinker.getBruteLoss() && SPT_PROB(5, seconds_per_tick))
		drinker.heal_bodypart_damage(brute = 1)
		. = TRUE
	return ..() || .

/datum/reagent/consumable/ethanol/threemileisland
	name = "Three Mile Island Iced Tea"
	description = "Made for a woman, strong enough for a man."
	color = "#666340" // rgb: 102, 99, 64
	boozepwr = 10
	quality = DRINK_FANTASTIC
	taste_description = "dryness"
	ph = 3.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/threemileisland/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	drinker.set_drugginess(100 SECONDS * REM * seconds_per_tick)
	return ..()

/datum/reagent/consumable/ethanol/gin
	name = "Gin"
	description = "It's gin. In space. I say, good sir."
	color = "#d8e8f0" // rgb: 216,232,240
	boozepwr = 45
	taste_description = "an alcoholic christmas tree"
	ph = 6.9
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_STOCK

/datum/reagent/consumable/ethanol/rum
	name = "Rum"
	description = "Yohoho and all that."
	color = "#c9c07e" // rgb: 201,192,126
	boozepwr = 60
	taste_description = "spiked butterscotch"
	ph = 6.5
	default_container = /obj/item/reagent_containers/cup/glass/bottle/rum

/datum/reagent/consumable/ethanol/tequila
	name = "Tequila"
	description = "A strong and mildly flavoured, Mexican produced spirit. Feeling thirsty, hombre?"
	color = "#FFFF91" // rgb: 255, 255, 145
	boozepwr = 70
	taste_description = "paint stripper"
	ph = 4
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_STOCK

/datum/reagent/consumable/ethanol/vermouth
	name = "Vermouth"
	description = "You suddenly feel a craving for a martini..."
	color = "#91FF91" // rgb: 145, 255, 145
	boozepwr = 45
	taste_description = "dry alcohol"
	ph = 3.25
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/wine
	name = "Wine"
	description = "A premium alcoholic beverage made from distilled grape juice."
	color = "#7E4043" // rgb: 126, 64, 67
	boozepwr = 35
	taste_description = "bitter sweetness"
	ph = 3.45
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_STOCK
	default_container = /obj/item/reagent_containers/cup/glass/bottle/wine

/datum/reagent/consumable/ethanol/wine/on_merge(data)
	. = ..()
	if(src.data && data && data["vintage"] != src.data["vintage"])
		src.data["vintage"] = "mixed wine"

/datum/reagent/consumable/ethanol/wine/get_taste_description(mob/living/taster)
	if(HAS_TRAIT(taster,TRAIT_WINE_TASTER))
		if(data && data["vintage"])
			return list("[data["vintage"]]" = 1)
		else
			return list("synthetic wine"=1)
	return ..()

/datum/reagent/consumable/ethanol/lizardwine
	name = "Lizard Wine"
	description = "An alcoholic beverage from Space China, made by infusing lizard tails in ethanol."
	color = "#7E4043" // rgb: 126, 64, 67
	boozepwr = 45
	quality = DRINK_FANTASTIC
	taste_description = "scaley sweetness"
	ph = 3
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_STOCK

/datum/reagent/consumable/ethanol/grappa
	name = "Grappa"
	description = "A fine Italian brandy, for when regular wine just isn't alcoholic enough for you."
	color = "#F8EBF1"
	boozepwr = 60
	taste_description = "classy bitter sweetness"
	ph = 3.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_STOCK

/datum/reagent/consumable/ethanol/amaretto
	name = "Amaretto"
	description = "A gentle drink that carries a sweet aroma."
	color = "#E17600"
	boozepwr = 25
	taste_description = "fruity and nutty sweetness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_STOCK

/datum/reagent/consumable/ethanol/cognac
	name = "Cognac"
	description = "A sweet and strongly alcoholic drink, made after numerous distillations and years of maturing. Classy as fornication."
	color = "#AB3C05" // rgb: 171, 60, 5
	boozepwr = 75
	taste_description = "angry and irish"
	ph = 3.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_STOCK

/datum/reagent/consumable/ethanol/absinthe
	name = "Absinthe"
	description = "A powerful alcoholic drink. Rumored to cause hallucinations but does not."
	color = rgb(10, 206, 0)
	boozepwr = 80 //Very strong even by default
	taste_description = "death and licorice"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/absinthe/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	if(SPT_PROB(5, seconds_per_tick) && !HAS_TRAIT(drinker, TRAIT_ALCOHOL_TOLERANCE))
		drinker.adjust_hallucinations(8 SECONDS)
	..()

/datum/reagent/consumable/ethanol/hooch
	name = "Hooch"
	description = "Either someone's failure at cocktail making or attempt in alcohol production. In any case, do you really want to drink that?"
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 100
	taste_description = "pure resignation"
	addiction_types = list(/datum/addiction/alcohol = 5, /datum/addiction/maintenance_drugs = 2)
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/ale
	name = "Ale"
	description = "A dark alcoholic beverage made with malted barley and yeast."
	color = "#976063" // rgb: 151,96,99
	boozepwr = 65
	taste_description = "hearty barley ale"
	ph = 4.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_STOCK

/datum/reagent/consumable/ethanol/goldschlager
	name = "Goldschlager"
	description = "100 proof cinnamon schnapps, made for alcoholic teen girls on spring break."
	color = "#FFFF91" // rgb: 255, 255, 145
	boozepwr = 25
	quality = DRINK_NICE
	taste_description = "burning cinnamon"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

	// This drink is really popular with a certain demographic.
	var/teenage_girl_quality = DRINK_VERYGOOD

/datum/reagent/consumable/ethanol/goldschlager/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	// Reset quality each time, since the bottle can be shared
	quality = initial(quality)

	if(ishuman(exposed_mob))
		var/mob/living/carbon/human/human = exposed_mob
		// tgstation13 does not endorse underage drinking. laws may vary by your jurisdiction.
		if(human.age >= 13 && human.age <= 19 && human.gender == FEMALE)
			quality = teenage_girl_quality

	return ..()

/datum/reagent/consumable/ethanol/goldschlager/on_transfer(atom/atom, methods = TOUCH, trans_volume)
	if(!(methods & INGEST))
		return ..()

	var/convert_amount = trans_volume * min(GOLDSCHLAGER_GOLD_RATIO, 1)
	atom.reagents.remove_reagent(/datum/reagent/consumable/ethanol/goldschlager, convert_amount)
	atom.reagents.add_reagent(/datum/reagent/gold, convert_amount)
	return ..()

/datum/reagent/consumable/ethanol/patron
	name = "Patron"
	description = "Tequila with silver in it, a favorite of alcoholic women in the club scene."
	color = "#585840" // rgb: 88, 88, 64
	boozepwr = 60
	quality = DRINK_VERYGOOD
	taste_description = "metallic and expensive"
	ph = 4.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_HIGH

/datum/reagent/consumable/ethanol/gintonic
	name = "Gin and Tonic"
	description = "An all time classic, mild cocktail."
	color = "#cae7ec" // rgb: 202,231,236
	boozepwr = 25
	quality = DRINK_NICE
	taste_description = "mild and tart"
	ph = 3
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_EASY

/datum/reagent/consumable/ethanol/rum_coke
	name = "Rum and Coke"
	description = "Rum, mixed with cola."
	taste_description = "cola"
	boozepwr = 40
	quality = DRINK_NICE
	color = "#3E1B00"
	ph = 4
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/cuba_libre
	name = "Cuba Libre"
	description = "Viva la Revolucion! Viva Cuba Libre!"
	color = "#3E1B00" // rgb: 62, 27, 0
	boozepwr = 50
	quality = DRINK_GOOD
	taste_description = "a refreshing marriage of citrus and rum"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/cuba_libre/on_mob_life(mob/living/carbon/cubano, seconds_per_tick, times_fired)
	if(cubano.mind && cubano.mind.has_antag_datum(/datum/antagonist/rev)) //Cuba Libre, the traditional drink of revolutions! Heals revolutionaries.
		cubano.adjustBruteLoss(-1 * REM * seconds_per_tick, FALSE, required_bodytype = affected_bodytype)
		cubano.adjustFireLoss(-1 * REM * seconds_per_tick, FALSE, required_bodytype = affected_bodytype)
		cubano.adjustToxLoss(-1 * REM * seconds_per_tick, FALSE, required_biotype = affected_biotype)
		cubano.adjustOxyLoss(-5 * REM * seconds_per_tick, FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
		. = TRUE
	return ..() || .

/datum/reagent/consumable/ethanol/whiskey_cola
	name = "Whiskey Cola"
	description = "Whiskey, mixed with cola. Surprisingly refreshing."
	color = "#3E1B00" // rgb: 62, 27, 0
	boozepwr = 70
	quality = DRINK_NICE
	taste_description = "cola"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/martini
	name = "Classic Martini"
	description = "Vermouth with Gin. Not quite how 007 enjoyed it, but still delicious."
	color = "#cddbac" // rgb: 205,219,172
	boozepwr = 60
	quality = DRINK_NICE
	taste_description = "dry class"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_EASY

/datum/reagent/consumable/ethanol/vodkamartini
	name = "Vodka Martini"
	description = "Vodka with Gin. Not quite how 007 enjoyed it, but still delicious."
	color = "#cddcad" // rgb: 205,220,173
	boozepwr = 65
	quality = DRINK_NICE
	taste_description = "shaken, not stirred"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED


/datum/reagent/consumable/ethanol/white_russian
	name = "White Russian"
	description = "That's just, like, your opinion, man..."
	color = "#A68340" // rgb: 166, 131, 64
	boozepwr = 50
	quality = DRINK_GOOD
	taste_description = "bitter cream"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/screwdrivercocktail
	name = "Screwdriver"
	description = "Vodka, mixed with plain ol' orange juice. The result is surprisingly delicious."
	color = "#A68310" // rgb: 166, 131, 16
	boozepwr = 55
	quality = DRINK_NICE
	taste_description = "oranges"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/screwdrivercocktail/on_transfer(atom/atom, methods = TOUCH, trans_volume)
	if(!(methods & INGEST))
		return ..()

	if(src == atom.reagents.get_master_reagent() && istype(atom, /obj/item/reagent_containers/cup/glass/drinkingglass))
		var/obj/item/reagent_containers/cup/glass/drinkingglass/drink = atom
		drink.tool_behaviour = TOOL_SCREWDRIVER
		var/list/reagent_change_signals = list(
			COMSIG_REAGENTS_ADD_REAGENT,
			COMSIG_REAGENTS_NEW_REAGENT,
			COMSIG_REAGENTS_REM_REAGENT,
			COMSIG_REAGENTS_DEL_REAGENT,
			COMSIG_REAGENTS_CLEAR_REAGENTS,
			COMSIG_REAGENTS_REACTED,
		)
		RegisterSignals(drink.reagents, reagent_change_signals, PROC_REF(on_reagent_change))

	return ..()

/datum/reagent/consumable/ethanol/screwdrivercocktail/proc/on_reagent_change(datum/reagents/reagents)
	SIGNAL_HANDLER
	if(src != reagents.get_master_reagent())
		var/obj/item/reagent_containers/cup/glass/drinkingglass/drink = reagents.my_atom
		drink.tool_behaviour = initial(drink.tool_behaviour)
		UnregisterSignal(reagents, list(
			COMSIG_REAGENTS_ADD_REAGENT,
			COMSIG_REAGENTS_NEW_REAGENT,
			COMSIG_REAGENTS_REM_REAGENT,
			COMSIG_REAGENTS_DEL_REAGENT,
			COMSIG_REAGENTS_CLEAR_REAGENTS,
			COMSIG_REAGENTS_REACTED,
		))

/datum/reagent/consumable/ethanol/screwdrivercocktail/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	var/obj/item/organ/internal/liver/liver = drinker.get_organ_slot(ORGAN_SLOT_LIVER)
	if(HAS_TRAIT(liver, TRAIT_ENGINEER_METABOLISM))
		ADD_TRAIT(drinker, TRAIT_HALT_RADIATION_EFFECTS, "[type]")
		if (HAS_TRAIT(drinker, TRAIT_IRRADIATED))
			drinker.adjustToxLoss(-2 * REM * seconds_per_tick, required_biotype = affected_biotype)

	return ..()

/datum/reagent/consumable/ethanol/screwdrivercocktail/on_mob_end_metabolize(mob/living/drinker)
	REMOVE_TRAIT(drinker, TRAIT_HALT_RADIATION_EFFECTS, "[type]")
	return ..()

/datum/reagent/consumable/ethanol/booger
	name = "Booger"
	description = "Ewww..."
	color = "#8CFF8C" // rgb: 140, 255, 140
	boozepwr = 45
	taste_description = "sweet 'n creamy"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/bloody_mary
	name = "Bloody Mary"
	description = "A strange yet pleasurable mixture made of vodka, tomato and lime juice. Or at least you THINK the red stuff is tomato juice."
	color = "#bf707c" // rgb: 191,112,124
	boozepwr = 55
	quality = DRINK_GOOD
	taste_description = "tomatoes with a hint of lime and liquid murder"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/bloody_mary/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	if(drinker.blood_volume < BLOOD_VOLUME_NORMAL)
		drinker.blood_volume = min(drinker.blood_volume + (3 * REM * seconds_per_tick), BLOOD_VOLUME_NORMAL) //Bloody Mary quickly restores blood loss.
	..()

/datum/reagent/consumable/ethanol/brave_bull
	name = "Brave Bull"
	description = "It's just as effective as Dutch-Courage!"
	color = "#a79f98" // rgb: 167,159,152
	boozepwr = 60
	quality = DRINK_NICE
	taste_description = "alcoholic bravery"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_EASY
	var/tough_text

/datum/reagent/consumable/ethanol/brave_bull/on_mob_metabolize(mob/living/drinker)
	tough_text = pick("brawny", "tenacious", "tough", "hardy", "sturdy") //Tuff stuff
	to_chat(drinker, span_notice("You feel [tough_text]!"))
	drinker.maxHealth += 10 //Brave Bull makes you sturdier, and thus capable of withstanding a tiny bit more punishment.
	drinker.health += 10
	ADD_TRAIT(drinker, TRAIT_FEARLESS, type)

/datum/reagent/consumable/ethanol/brave_bull/on_mob_end_metabolize(mob/living/drinker)
	to_chat(drinker, span_notice("You no longer feel [tough_text]."))
	drinker.maxHealth -= 10
	drinker.health = min(drinker.health - 10, drinker.maxHealth) //This can indeed crit you if you're alive solely based on alchol ingestion
	REMOVE_TRAIT(drinker, TRAIT_FEARLESS, type)

/datum/reagent/consumable/ethanol/tequila_sunrise
	name = "Tequila Sunrise"
	description = "Tequila, Grenadine, and Orange Juice."
	color = "#FFE48C" // rgb: 255, 228, 140
	boozepwr = 45
	quality = DRINK_GOOD
	taste_description = "oranges with a hint of pomegranate"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_MEDIUM
	var/obj/effect/light_holder

/datum/reagent/consumable/ethanol/tequila_sunrise/on_mob_metabolize(mob/living/drinker)
	to_chat(drinker, span_notice("You feel gentle warmth spread through your body!"))
	light_holder = new(drinker)
	light_holder.set_light(3, 0.7, "#FFCC00") //Tequila Sunrise makes you radiate dim light, like a sunrise!

/datum/reagent/consumable/ethanol/tequila_sunrise/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	if(QDELETED(light_holder))
		holder.del_reagent(type) //If we lost our light object somehow, remove the reagent
	else if(light_holder.loc != drinker)
		light_holder.forceMove(drinker)
	return ..()

/datum/reagent/consumable/ethanol/tequila_sunrise/on_mob_end_metabolize(mob/living/drinker)
	to_chat(drinker, span_notice("The warmth in your body fades."))
	QDEL_NULL(light_holder)

/datum/reagent/consumable/ethanol/toxins_special
	name = "Toxins Special"
	description = "This thing is ON FIRE! CALL THE DAMN SHUTTLE!"
	color = "#8880a8" // rgb: 136,128,168
	boozepwr = 25
	quality = DRINK_VERYGOOD
	taste_description = "spicy toxins"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/toxins_special/on_mob_life(mob/living/drinker, seconds_per_tick, times_fired)
	drinker.adjust_bodytemperature(15 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, 0, drinker.get_body_temp_normal() + 20) //310.15 is the normal bodytemp.
	return ..()

/datum/reagent/consumable/ethanol/beepsky_smash
	name = "Beepsky Smash"
	description = "Drink this and prepare for the LAW."
	color = "#808000" // rgb: 128,128,0
	boozepwr = 60 //THE FIST OF THE LAW IS STRONG AND HARD
	quality = DRINK_GOOD
	metabolization_rate = 1.25 * REAGENTS_METABOLISM
	taste_description = "JUSTICE"
	overdose_threshold = 40
	ph = 2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	var/datum/brain_trauma/special/beepsky/beepsky_hallucination

/datum/reagent/consumable/ethanol/beepsky_smash/on_mob_metabolize(mob/living/carbon/drinker)
	if(HAS_TRAIT(drinker, TRAIT_ALCOHOL_TOLERANCE))
		metabolization_rate = 0.8
	// if you don't have a liver, or your liver isn't an officer's liver
	var/obj/item/organ/internal/liver/liver = drinker.get_organ_slot(ORGAN_SLOT_LIVER)
	if(!liver || !HAS_TRAIT(liver, TRAIT_LAW_ENFORCEMENT_METABOLISM))
		beepsky_hallucination = new()
		drinker.gain_trauma(beepsky_hallucination, TRAUMA_RESILIENCE_ABSOLUTE)
	..()

/datum/reagent/consumable/ethanol/beepsky_smash/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	drinker.set_jitter_if_lower(4 SECONDS)
	var/obj/item/organ/internal/liver/liver = drinker.get_organ_slot(ORGAN_SLOT_LIVER)
	// if you have a liver and that liver is an officer's liver
	if(liver && HAS_TRAIT(liver, TRAIT_LAW_ENFORCEMENT_METABOLISM))
		. = TRUE
		drinker.adjustStaminaLoss(-10 * REM * seconds_per_tick, required_biotype = affected_biotype)
		if(SPT_PROB(10, seconds_per_tick))
			drinker.cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/nearby_fake_item), name)
		if(SPT_PROB(5, seconds_per_tick))
			drinker.cause_hallucination(/datum/hallucination/stray_bullet, name)

	..()

/datum/reagent/consumable/ethanol/beepsky_smash/on_mob_end_metabolize(mob/living/carbon/drinker)
	if(beepsky_hallucination)
		QDEL_NULL(beepsky_hallucination)
	return ..()

/datum/reagent/consumable/ethanol/beepsky_smash/overdose_start(mob/living/carbon/drinker)
	var/obj/item/organ/internal/liver/liver = drinker.get_organ_slot(ORGAN_SLOT_LIVER)
	// if you don't have a liver, or your liver isn't an officer's liver
	if(!liver || !HAS_TRAIT(liver, TRAIT_LAW_ENFORCEMENT_METABOLISM))
		drinker.gain_trauma(/datum/brain_trauma/mild/phobia/security, TRAUMA_RESILIENCE_BASIC)

/datum/reagent/consumable/ethanol/irish_cream
	name = "Irish Cream"
	description = "Whiskey-imbued cream, what else would you expect from the Irish?"
	color = "#e3d0b2" // rgb: 227,208,178
	boozepwr = 50
	quality = DRINK_NICE
	taste_description = "creamy alcohol"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/manly_dorf
	name = "The Manly Dorf"
	description = "Beer and Ale, brought together in a delicious mix. Intended for true men only."
	color = "#815336" // rgb: 129,83,54
	boozepwr = 100 //For the manly only
	quality = DRINK_NICE
	taste_description = "hair on your chest and your chin"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	var/dorf_mode = FALSE

/datum/reagent/consumable/ethanol/manly_dorf/on_mob_metabolize(mob/living/drinker)
	if(ishuman(drinker))
		var/mob/living/carbon/human/potential_dwarf = drinker
		if(HAS_TRAIT(potential_dwarf, TRAIT_DWARF))
			to_chat(potential_dwarf, span_notice("Now THAT is MANLY!"))
			boozepwr = 50 // will still smash but not as much.
			dorf_mode = TRUE

/datum/reagent/consumable/ethanol/manly_dorf/on_mob_life(mob/living/carbon/dwarf, seconds_per_tick, times_fired)
	if(dorf_mode)
		dwarf.adjustBruteLoss(-2 * REM * seconds_per_tick, required_bodytype = affected_bodytype)
		dwarf.adjustFireLoss(-2 * REM * seconds_per_tick, required_bodytype = affected_bodytype)
	return ..()

/datum/reagent/consumable/ethanol/longislandicedtea
	name = "Long Island Iced Tea"
	description = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
	color = "#ff6633" // rgb: 255,102,51
	boozepwr = 35
	quality = DRINK_VERYGOOD
	taste_description = "a mixture of cola and alcohol"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/moonshine
	name = "Moonshine"
	description = "You've really hit rock bottom now... your liver packed its bags and left last night."
	color = "#AAAAAA77" // rgb: 170, 170, 170, 77 (alpha) (like water)
	boozepwr = 95
	taste_description = "bitterness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/b52
	name = "B-52"
	description = "Coffee, Irish Cream, and cognac. You will get bombed."
	color = "#8f1733" // rgb: 143,23,51
	boozepwr = 85
	quality = DRINK_GOOD
	taste_description = "angry and irish"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_EASY

/datum/reagent/consumable/ethanol/b52/on_mob_metabolize(mob/living/drinker)
	playsound(drinker, 'sound/effects/explosion_distant.ogg', 100, FALSE)

/datum/reagent/consumable/ethanol/irishcoffee
	name = "Irish Coffee"
	description = "Coffee, and alcohol. More fun than a Mimosa to drink in the morning."
	color = "#874010" // rgb: 135,64,16
	boozepwr = 35
	quality = DRINK_NICE
	taste_description = "giving up on the day"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/margarita
	name = "Margarita"
	description = "On the rocks with salt on the rim. Arriba~!"
	color = "#8CFF8C" // rgb: 140, 255, 140
	boozepwr = 35
	quality = DRINK_NICE
	taste_description = "dry and salty"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_MEDIUM

/datum/reagent/consumable/ethanol/black_russian
	name = "Black Russian"
	description = "For the lactose-intolerant. Still as classy as a White Russian."
	color = "#360000" // rgb: 54, 0, 0
	boozepwr = 70
	quality = DRINK_NICE
	taste_description = "bitterness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/manhattan
	name = "Manhattan"
	description = "The Detective's undercover drink of choice. He never could stomach gin..."
	color = "#ff3300" // rgb: 255,51,0
	boozepwr = 30
	quality = DRINK_NICE
	taste_description = "mild dryness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_EASY

/datum/reagent/consumable/ethanol/manhattan_proj
	name = "Manhattan Project"
	description = "A scientist's drink of choice, for pondering ways to blow up the station."
	color = COLOR_MOSTLY_PURE_RED
	boozepwr = 45
	quality = DRINK_VERYGOOD
	taste_description = "death, the destroyer of worlds"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/manhattan_proj/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	drinker.set_drugginess(1 MINUTES * REM * seconds_per_tick)
	return ..()

/datum/reagent/consumable/ethanol/whiskeysoda
	name = "Whiskey Soda"
	description = "For the more refined griffon."
	color = "#ffcc33" // rgb: 255,204,51
	boozepwr = 70
	quality = DRINK_NICE
	taste_description = "soda"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/antifreeze
	name = "Anti-freeze"
	description = "The ultimate refreshment. Not what it sounds like."
	color = "#30f0f8" // rgb: 48,240,248
	boozepwr = 35
	quality = DRINK_NICE
	taste_description = "Jack Frost's piss"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/antifreeze/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	drinker.adjust_bodytemperature(20 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, 0, drinker.get_body_temp_normal() + 20) //310.15 is the normal bodytemp.
	return ..()

/datum/reagent/consumable/ethanol/barefoot
	name = "Barefoot"
	description = "Barefoot and pregnant."
	color = "#fc5acc" // rgb: 252,90,204
	boozepwr = 45
	quality = DRINK_VERYGOOD
	taste_description = "creamy berries"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/barefoot/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	if(ishuman(drinker)) //Barefoot causes the imbiber to quickly regenerate brute trauma if they're not wearing shoes.
		var/mob/living/carbon/human/unshoed = drinker
		if(!unshoed.shoes)
			unshoed.adjustBruteLoss(-3 * REM * seconds_per_tick, FALSE, required_bodytype = affected_bodytype)
			. = TRUE
	return ..() || .

/datum/reagent/consumable/ethanol/snowwhite
	name = "Snow White"
	description = "A cold refreshment."
	color = "#FFFFFF" // rgb: 255, 255, 255
	boozepwr = 35
	quality = DRINK_NICE
	taste_description = "refreshing cold"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/demonsblood
	name = "Demon's Blood"
	description = "AHHHH!!!!"
	color = "#820000" // rgb: 130, 0, 0
	boozepwr = 75
	quality = DRINK_VERYGOOD
	taste_description = "sweet tasting iron"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/demonsblood/on_mob_metabolize(mob/living/metabolizer)
	. = ..()
	RegisterSignal(metabolizer, COMSIG_LIVING_BLOOD_CRAWL_PRE_CONSUMED, PROC_REF(pre_bloodcrawl_consumed))

/datum/reagent/consumable/ethanol/demonsblood/on_mob_end_metabolize(mob/living/metabolizer)
	. = ..()
	UnregisterSignal(metabolizer, COMSIG_LIVING_BLOOD_CRAWL_PRE_CONSUMED)

/// Prevents the imbiber from being dragged into a pool of blood by a slaughter demon.
/datum/reagent/consumable/ethanol/demonsblood/proc/pre_bloodcrawl_consumed(
	mob/living/source,
	datum/action/cooldown/spell/jaunt/bloodcrawl/crawl,
	mob/living/jaunter,
	obj/effect/decal/cleanable/blood,
)

	SIGNAL_HANDLER

	var/turf/jaunt_turf = get_turf(jaunter)
	jaunt_turf.visible_message(
		span_warning("Something prevents [source] from entering [blood]!"),
		blind_message = span_notice("You hear a splash and a thud.")
	)
	to_chat(jaunter, span_warning("A strange force is blocking [source] from entering!"))

	return COMPONENT_STOP_CONSUMPTION

/datum/reagent/consumable/ethanol/devilskiss
	name = "Devil's Kiss"
	description = "Creepy time!"
	color = "#A68310" // rgb: 166, 131, 16
	boozepwr = 70
	quality = DRINK_VERYGOOD
	taste_description = "bitter iron"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/devilskiss/on_mob_metabolize(mob/living/metabolizer)
	. = ..()
	RegisterSignal(metabolizer, COMSIG_LIVING_BLOOD_CRAWL_CONSUMED, PROC_REF(on_bloodcrawl_consumed))

/datum/reagent/consumable/ethanol/devilskiss/on_mob_end_metabolize(mob/living/metabolizer)
	. = ..()
	UnregisterSignal(metabolizer, COMSIG_LIVING_BLOOD_CRAWL_CONSUMED)

/// If eaten by a slaughter demon, the demon will regret it.
/datum/reagent/consumable/ethanol/devilskiss/proc/on_bloodcrawl_consumed(
	mob/living/source,
	datum/action/cooldown/spell/jaunt/bloodcrawl/crawl,
	mob/living/jaunter,
)

	SIGNAL_HANDLER

	. = COMPONENT_STOP_CONSUMPTION

	to_chat(jaunter, span_boldwarning("AAH! THEIR FLESH! IT BURNS!"))
	jaunter.apply_damage(25, BRUTE, wound_bonus = CANT_WOUND)

	for(var/obj/effect/decal/cleanable/nearby_blood in range(1, get_turf(source)))
		if(!nearby_blood.can_bloodcrawl_in())
			continue
		source.forceMove(get_turf(nearby_blood))
		source.visible_message(span_warning("[nearby_blood] violently expels [source]!"))
		crawl.exit_blood_effect(source)
		return

	// Fuck it, just eject them, thanks to some split second cleaning
	source.forceMove(get_turf(source))
	source.visible_message(span_warning("[source] appears from nowhere, covered in blood!"))
	crawl.exit_blood_effect(source)

/datum/reagent/consumable/ethanol/vodkatonic
	name = "Vodka and Tonic"
	description = "For when a gin and tonic isn't Russian enough."
	color = "#0064C8" // rgb: 0, 100, 200
	boozepwr = 70
	quality = DRINK_NICE
	taste_description = "tart bitterness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/ginfizz
	name = "Gin Fizz"
	description = "Refreshingly lemony, deliciously dry."
	color = "#ffffcc" // rgb: 255,255,204
	boozepwr = 45
	quality = DRINK_GOOD
	taste_description = "dry, tart lemons"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/bahama_mama
	name = "Bahama Mama"
	description = "A tropical cocktail with a complex blend of flavors."
	color = "#FF7F3B" // rgb: 255, 127, 59
	boozepwr = 35
	quality = DRINK_GOOD
	taste_description = "pineapple, coconut, and a hint of coffee"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/singulo
	name = "Singulo"
	description = "A blue-space beverage!"
	color = "#2E6671" // rgb: 46, 102, 113
	boozepwr = 35
	quality = DRINK_VERYGOOD
	taste_description = "concentrated matter"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	var/static/list/ray_filter = list(type = "rays", size = 40, density = 15, color = SUPERMATTER_SINGULARITY_RAYS_COLOUR, factor = 15)

/datum/reagent/consumable/ethanol/singulo/on_mob_metabolize(mob/living/drinker)
	ADD_TRAIT(drinker, TRAIT_MADNESS_IMMUNE, type)

/datum/reagent/consumable/ethanol/singulo/on_mob_end_metabolize(mob/living/drinker)
	REMOVE_TRAIT(drinker, TRAIT_MADNESS_IMMUNE, type)
	drinker.remove_filter("singulo_rays")

/datum/reagent/consumable/ethanol/singulo/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	if(SPT_PROB(2.5, seconds_per_tick))
		// 20u = 1x1, 45u = 2x2, 80u = 3x3
		var/volume_to_radius = FLOOR(sqrt(volume/5), 1) - 1
		var/suck_range = clamp(volume_to_radius, 0, 3)

		if(!suck_range)
			return ..()

		var/turf/gravity_well_turf = get_turf(drinker)
		goonchem_vortex(gravity_well_turf, 0, suck_range)
		playsound(get_turf(drinker), 'sound/effects/supermatter.ogg', 150, TRUE)
		drinker.add_filter("singulo_rays", 1, ray_filter)
		animate(drinker.get_filter("singulo_rays"), offset = 10, time = 1.5 SECONDS, loop = -1)
		addtimer(CALLBACK(drinker, TYPE_PROC_REF(/datum, remove_filter), "singulo_rays"), 1.5 SECONDS)
		drinker.emote("burp")
	return ..()

/datum/reagent/consumable/ethanol/sbiten
	name = "Sbiten"
	description = "A spicy Vodka! Might be a little hot for the little guys!"
	color = "#d8d5ae" // rgb: 216,213,174
	boozepwr = 70
	quality = DRINK_GOOD
	taste_description = "hot and spice"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/sbiten/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	drinker.adjust_bodytemperature(50 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, 0, BODYTEMP_HEAT_DAMAGE_LIMIT) //310.15 is the normal bodytemp.
	return ..()

/datum/reagent/consumable/ethanol/red_mead
	name = "Red Mead"
	description = "The true Viking drink! Even though it has a strange red color."
	color = "#C73C00" // rgb: 199, 60, 0
	boozepwr = 31 //Red drinks are stronger
	quality = DRINK_GOOD
	taste_description = "sweet and salty alcohol"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/mead
	name = "Mead"
	description = "A Viking drink, though a cheap one."
	color = "#e0c058" // rgb: 224,192,88
	nutriment_factor = 1 * REAGENTS_METABOLISM
	boozepwr = 30
	quality = DRINK_NICE
	taste_description = "sweet, sweet alcohol"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/iced_beer
	name = "Iced Beer"
	description = "A beer which is so cold the air around it freezes."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 15
	taste_description = "refreshingly cold"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/iced_beer/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	drinker.adjust_bodytemperature(-20 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, T0C) //310.15 is the normal bodytemp.
	return ..()

/datum/reagent/consumable/ethanol/grog
	name = "Grog"
	description = "Watered-down rum, Nanotrasen approves!"
	color = "#e0e058" // rgb: 224,224,88
	boozepwr = 1 //Basically nothing
	taste_description = "a poor excuse for alcohol"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/aloe
	name = "Aloe"
	description = "So very, very, very good."
	color = "#f8f800" // rgb: 248,248,0
	boozepwr = 35
	quality = DRINK_VERYGOOD
	taste_description = "sweet 'n creamy"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	//somewhat annoying mix
	glass_price = DRINK_PRICE_MEDIUM

/datum/reagent/consumable/ethanol/andalusia
	name = "Andalusia"
	description = "A nice, strangely named drink."
	color = "#c8f860" // rgb: 200,248,96
	boozepwr = 40
	quality = DRINK_GOOD
	taste_description = "lemons"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/alliescocktail
	name = "Allies Cocktail"
	description = "A drink made from your allies. Not as sweet as those made from your enemies."
	color = "#60f8f8" // rgb: 96,248,248
	boozepwr = 45
	quality = DRINK_NICE
	taste_description = "bitter yet free"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_EASY

/datum/reagent/consumable/ethanol/acid_spit
	name = "Acid Spit"
	description = "A drink for the daring, can be deadly if incorrectly prepared!"
	color = "#365000" // rgb: 54, 80, 0
	boozepwr = 70
	quality = DRINK_VERYGOOD
	taste_description = "stomach acid"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/amasec
	name = "Amasec"
	description = "Official drink of the Nanotrasen Gun-Club!"
	color = "#e0e058" // rgb: 224,224,88
	boozepwr = 35
	quality = DRINK_GOOD
	taste_description = "dark and metallic"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/changelingsting
	name = "Changeling Sting"
	description = "You take a tiny sip and feel a burning sensation..."
	color = "#2E6671" // rgb: 46, 102, 113
	boozepwr = 50
	quality = DRINK_GOOD
	taste_description = "your brain coming out your nose"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/changelingsting/on_mob_life(mob/living/carbon/target, seconds_per_tick, times_fired)
	var/datum/antagonist/changeling/changeling = target.mind?.has_antag_datum(/datum/antagonist/changeling)
	changeling?.adjust_chemicals(metabolization_rate * REM * seconds_per_tick)
	return ..()

/datum/reagent/consumable/ethanol/irishcarbomb
	name = "Irish Car Bomb"
	description = "Mmm, tastes like the free Irish state."
	color = "#2E6671" // rgb: 46, 102, 113
	boozepwr = 25
	quality = DRINK_GOOD
	taste_description = "the spirit of Ireland"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/syndicatebomb
	name = "Syndicate Bomb"
	description = "Tastes like terrorism!"
	color = "#2E6671" // rgb: 46, 102, 113
	boozepwr = 90
	quality = DRINK_GOOD
	taste_description = "purified antagonism"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/syndicatebomb/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	if(SPT_PROB(2.5, seconds_per_tick))
		playsound(get_turf(drinker), 'sound/effects/explosionfar.ogg', 100, TRUE)
	return ..()

/datum/reagent/consumable/ethanol/hiveminderaser
	name = "Hivemind Eraser"
	description = "A vessel of pure flavor."
	color = "#FF80FC" // rgb: 255, 128, 252
	boozepwr = 40
	quality = DRINK_GOOD
	taste_description = "psychic links"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/erikasurprise
	name = "Erika Surprise"
	description = "The surprise is, it's green!"
	color = "#2E6671" // rgb: 46, 102, 113
	boozepwr = 35
	quality = DRINK_VERYGOOD
	taste_description = "tartness and bananas"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/driestmartini
	name = "Driest Martini"
	description = "Only for the experienced. You think you see sand floating in the glass."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#2E6671" // rgb: 46, 102, 113
	boozepwr = 65
	quality = DRINK_GOOD
	taste_description = "a beach"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/bananahonk
	name = "Banana Honk"
	description = "A drink from Clown Heaven."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#FFFF91" // rgb: 255, 255, 140
	boozepwr = 60
	quality = DRINK_GOOD
	taste_description = "a bad joke"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/bananahonk/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	var/obj/item/organ/internal/liver/liver = drinker.get_organ_slot(ORGAN_SLOT_LIVER)
	if((liver && HAS_TRAIT(liver, TRAIT_COMEDY_METABOLISM)) || ismonkey(drinker))
		drinker.heal_bodypart_damage(1 * REM * seconds_per_tick, 1 * REM * seconds_per_tick)
		. = TRUE
	return ..() || .

/datum/reagent/consumable/ethanol/silencer
	name = "Silencer"
	description = "A drink from Mime Heaven."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#a8a8a8" // rgb: 168,168,168
	boozepwr = 59 //Proof that clowns are better than mimes right here
	quality = DRINK_GOOD
	taste_description = "a pencil eraser"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/silencer/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	if(ishuman(drinker) && HAS_MIND_TRAIT(drinker, TRAIT_MIMING))
		drinker.set_silence_if_lower(MIMEDRINK_SILENCE_DURATION)
		drinker.heal_bodypart_damage(1 * REM * seconds_per_tick, 1 * REM * seconds_per_tick)
		. = TRUE
	return ..() || .

/datum/reagent/consumable/ethanol/drunkenblumpkin
	name = "Drunken Blumpkin"
	description = "A weird mix of whiskey and blumpkin juice."
	color = "#1EA0FF" // rgb: 30,160,255
	boozepwr = 50
	quality = DRINK_VERYGOOD
	taste_description = "molasses and a mouthful of pool water"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/whiskey_sour //Requested since we had whiskey cola and soda but not sour.
	name = "Whiskey Sour"
	description = "Lemon juice/whiskey/sugar mixture. Moderate alcohol content."
	color = rgb(255, 201, 49)
	boozepwr = 35
	quality = DRINK_GOOD
	taste_description = "sour lemons"

/datum/reagent/consumable/ethanol/hcider
	name = "Hard Cider"
	description = "Apple juice, for adults."
	color = "#CD6839"
	nutriment_factor = 1 * REAGENTS_METABOLISM
	boozepwr = 25
	taste_description = "the season that <i>falls</i> between summer and winter"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_STOCK

/datum/reagent/consumable/ethanol/fetching_fizz //A reference to one of my favorite games of all time. Pulls nearby ores to the imbiber!
	name = "Fetching Fizz"
	description = "Whiskey sour/iron/uranium mixture resulting in a highly magnetic slurry. Mild alcohol content." //Requires no alcohol to make but has alcohol anyway because ~magic~
	color = rgb(255, 91, 15)
	boozepwr = 10
	quality = DRINK_VERYGOOD
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	taste_description = "charged metal" // the same as teslium, honk honk.
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/fetching_fizz/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	for(var/obj/item/stack/ore/O in orange(3, drinker))
		step_towards(O, get_turf(drinker))
	return ..()

//Another reference. Heals those in critical condition extremely quickly.
/datum/reagent/consumable/ethanol/hearty_punch
	name = "Hearty Punch"
	description = "Brave bull/syndicate bomb/absinthe mixture resulting in an energizing beverage. Mild alcohol content."
	color = rgb(140, 0, 0)
	boozepwr = 90
	quality = DRINK_VERYGOOD
	metabolization_rate = 0.4 * REAGENTS_METABOLISM
	taste_description = "bravado in the face of disaster"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/hearty_punch/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	if(drinker.health <= 0)
		drinker.adjustBruteLoss(-3 * REM * seconds_per_tick, FALSE, required_bodytype = affected_bodytype)
		drinker.adjustFireLoss(-3 * REM * seconds_per_tick, FALSE, required_bodytype = affected_bodytype)
		drinker.adjustCloneLoss(-5 * REM * seconds_per_tick, 0)
		drinker.adjustOxyLoss(-4 * REM * seconds_per_tick, FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
		drinker.adjustToxLoss(-3 * REM * seconds_per_tick, FALSE, required_biotype = affected_biotype)
		. = TRUE
	return ..() || .

/datum/reagent/consumable/ethanol/bacchus_blessing //An EXTREMELY powerful drink. Smashed in seconds, dead in minutes.
	name = "Bacchus' Blessing"
	description = "Unidentifiable mixture. Unmeasurably high alcohol content."
	color = rgb(51, 19, 3) //Sickly brown
	boozepwr = 300 //I warned you
	taste_description = "a wall of bricks"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/atomicbomb
	name = "Atomic Bomb"
	description = "Nuclear proliferation never tasted so good."
	color = "#666300" // rgb: 102, 99, 0
	boozepwr = 0 //custom drunk effect
	quality = DRINK_FANTASTIC
	taste_description = "da bomb"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_HIGH

/datum/reagent/consumable/ethanol/atomicbomb/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	drinker.set_drugginess(100 SECONDS * REM * seconds_per_tick)
	if(!HAS_TRAIT(drinker, TRAIT_ALCOHOL_TOLERANCE))
		drinker.adjust_confusion(2 SECONDS * REM * seconds_per_tick)
	drinker.set_dizzy_if_lower(20 SECONDS * REM * seconds_per_tick)
	drinker.adjust_slurring(6 SECONDS * REM * seconds_per_tick)
	switch(current_cycle)
		if(51 to 200)
			drinker.Sleeping(100 * REM * seconds_per_tick)
			. = TRUE
		if(201 to INFINITY)
			drinker.AdjustSleeping(40 * REM * seconds_per_tick)
			drinker.adjustToxLoss(2 * REM * seconds_per_tick, FALSE, required_biotype = affected_biotype)
			. = TRUE
	..()

/datum/reagent/consumable/ethanol/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	description = "Whoah, this stuff looks volatile!"
	color = "#9cc8b4" // rgb: 156,200,180
	boozepwr = 0 //custom drunk effect
	quality = DRINK_GOOD
	taste_description = "your brains smashed out by a lemon wrapped around a gold brick"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/gargle_blaster/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	drinker.adjust_dizzy(3 SECONDS * REM * seconds_per_tick)
	switch(current_cycle)
		if(15 to 45)
			drinker.adjust_slurring(3 SECONDS * REM * seconds_per_tick)

		if(45 to 55)
			if(SPT_PROB(30, seconds_per_tick))
				drinker.adjust_confusion(3 SECONDS * REM * seconds_per_tick)
		if(55 to 200)
			drinker.set_drugginess(110 SECONDS * REM * seconds_per_tick)
		if(200 to INFINITY)
			drinker.adjustToxLoss(2 * REM * seconds_per_tick, FALSE, required_biotype = affected_biotype)
			. = TRUE
	..()

/datum/reagent/consumable/ethanol/neurotoxin
	name = "Neurotoxin"
	description = "A strong neurotoxin that puts the subject into a death-like state."
	color = "#2E2E61" // rgb: 46, 46, 97
	boozepwr = 50
	quality = DRINK_VERYGOOD
	taste_description = "a numbing sensation"
	metabolization_rate = 1 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/neurotoxin/proc/pick_paralyzed_limb()
	return (pick(TRAIT_PARALYSIS_L_ARM,TRAIT_PARALYSIS_R_ARM,TRAIT_PARALYSIS_R_LEG,TRAIT_PARALYSIS_L_LEG))

/datum/reagent/consumable/ethanol/neurotoxin/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	drinker.set_drugginess(100 SECONDS * REM * seconds_per_tick)
	drinker.adjust_dizzy(4 SECONDS * REM * seconds_per_tick)
	drinker.adjustOrganLoss(ORGAN_SLOT_BRAIN, 1 * REM * seconds_per_tick, 150, required_organ_flag = affected_organ_flags)
	if(SPT_PROB(10, seconds_per_tick))
		drinker.adjustStaminaLoss(10, required_biotype = affected_biotype)
		drinker.drop_all_held_items()
		to_chat(drinker, span_notice("You cant feel your hands!"))
	if(current_cycle > 5)
		if(SPT_PROB(10, seconds_per_tick))
			var/paralyzed_limb = pick_paralyzed_limb()
			ADD_TRAIT(drinker, paralyzed_limb, type)
			drinker.adjustStaminaLoss(10, required_biotype = affected_biotype)
		if(current_cycle > 30)
			drinker.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags)
			if(current_cycle > 50 && SPT_PROB(7.5, seconds_per_tick))
				if(!drinker.undergoing_cardiac_arrest() && drinker.can_heartattack())
					drinker.set_heartattack(TRUE)
					if(drinker.stat == CONSCIOUS)
						drinker.visible_message(span_userdanger("[drinker] clutches at [drinker.p_their()] chest as if [drinker.p_their()] heart stopped!"))
	. = TRUE
	..()

/datum/reagent/consumable/ethanol/neurotoxin/on_mob_end_metabolize(mob/living/carbon/drinker)
	REMOVE_TRAIT(drinker, TRAIT_PARALYSIS_L_ARM, type)
	REMOVE_TRAIT(drinker, TRAIT_PARALYSIS_R_ARM, type)
	REMOVE_TRAIT(drinker, TRAIT_PARALYSIS_R_LEG, type)
	REMOVE_TRAIT(drinker, TRAIT_PARALYSIS_L_LEG, type)
	drinker.adjustStaminaLoss(10, required_biotype = affected_biotype)
	..()

/datum/reagent/consumable/ethanol/hippies_delight
	name = "Hippie's Delight"
	description = "You just don't get it maaaan."
	color = "#b16e8b" // rgb: 177,110,139
	nutriment_factor = 0
	boozepwr = 0 //custom drunk effect
	quality = DRINK_FANTASTIC
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	taste_description = "giving peace a chance"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/hippies_delight/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	drinker.set_slurring_if_lower(1 SECONDS * REM * seconds_per_tick)

	switch(current_cycle)
		if(1 to 5)
			drinker.set_dizzy_if_lower(20 SECONDS * REM * seconds_per_tick)
			drinker.set_drugginess(1 MINUTES * REM * seconds_per_tick)
			if(SPT_PROB(5, seconds_per_tick))
				drinker.emote(pick("twitch","giggle"))
		if(5 to 10)
			drinker.set_jitter_if_lower(40 SECONDS * REM * seconds_per_tick)
			drinker.set_dizzy_if_lower(40 SECONDS * REM * seconds_per_tick)
			drinker.set_drugginess(1.5 MINUTES * REM * seconds_per_tick)
			if(SPT_PROB(10, seconds_per_tick))
				drinker.emote(pick("twitch","giggle"))
		if (10 to 200)
			drinker.set_jitter_if_lower(80 SECONDS * REM * seconds_per_tick)
			drinker.set_dizzy_if_lower(80 SECONDS * REM * seconds_per_tick)
			drinker.set_drugginess(2 MINUTES * REM * seconds_per_tick)
			if(SPT_PROB(16, seconds_per_tick))
				drinker.emote(pick("twitch","giggle"))
		if(200 to INFINITY)
			drinker.set_jitter_if_lower(120 SECONDS * REM * seconds_per_tick)
			drinker.set_dizzy_if_lower(120 SECONDS * REM * seconds_per_tick)
			drinker.set_drugginess(2.5 MINUTES * REM * seconds_per_tick)
			if(SPT_PROB(23, seconds_per_tick))
				drinker.emote(pick("twitch","giggle"))
			if(SPT_PROB(16, seconds_per_tick))
				drinker.adjustToxLoss(2, FALSE, required_biotype = affected_biotype)
				. = TRUE
	..()

/datum/reagent/consumable/ethanol/eggnog
	name = "Eggnog"
	description = "For enjoying the most wonderful time of the year."
	color = "#fcfdc6" // rgb: 252, 253, 198
	nutriment_factor = 2 * REAGENTS_METABOLISM
	boozepwr = 1
	quality = DRINK_VERYGOOD
	taste_description = "custard and alcohol"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/dreadnog
	name = "Dreadnog"
	description = "For suffering during a period of joy."
	color = "#abb862" // rgb: 252, 253, 198
	nutriment_factor = 3 * REAGENTS_METABOLISM
	boozepwr = 1
	quality = DRINK_REVOLTING
	taste_description = "custard and alcohol"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/narsour
	name = "Nar'Sour"
	description = "Side effects include self-mutilation and hoarding plasteel."
	color = RUNE_COLOR_DARKRED
	boozepwr = 10
	quality = DRINK_FANTASTIC
	taste_description = "bloody"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/narsour/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	drinker.adjust_timed_status_effect(6 SECONDS * REM * seconds_per_tick, /datum/status_effect/speech/slurring/cult, max_duration = 6 SECONDS)
	drinker.adjust_stutter_up_to(6 SECONDS * REM * seconds_per_tick, 6 SECONDS)
	return ..()

/datum/reagent/consumable/ethanol/triple_sec
	name = "Triple Sec"
	description = "A sweet and vibrant orange liqueur."
	color = "#ffcc66"
	boozepwr = 30
	taste_description = "a warm flowery orange taste which recalls the ocean air and summer wind of the caribbean"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/creme_de_menthe
	name = "Creme de Menthe"
	description = "A minty liqueur excellent for refreshing, cool drinks."
	color = "#00cc00"
	boozepwr = 20
	taste_description = "a minty, cool, and invigorating splash of cold streamwater"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/creme_de_cacao
	name = "Creme de Cacao"
	description = "A chocolatey liqueur excellent for adding dessert notes to beverages and bribing sororities."
	color = "#996633"
	boozepwr = 20
	taste_description = "a slick and aromatic hint of chocolates swirling in a bite of alcohol"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/creme_de_coconut
	name = "Creme de Coconut"
	description = "A coconut liqueur for smooth, creamy, tropical drinks."
	color = "#F7F0D0"
	boozepwr = 20
	taste_description = "a sweet milky flavor with notes of toasted sugar"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/quadruple_sec
	name = "Quadruple Sec"
	description = "Kicks just as hard as licking the power cell on a baton, but tastier."
	color = "#cc0000"
	boozepwr = 35
	quality = DRINK_GOOD
	taste_description = "an invigorating bitter freshness which suffuses your being; no enemy of the station will go unrobusted this day"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/quadruple_sec/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	//Securidrink in line with the Screwdriver for engineers or Nothing for mimes
	var/obj/item/organ/internal/liver/liver = drinker.get_organ_slot(ORGAN_SLOT_LIVER)
	if(liver && HAS_TRAIT(liver, TRAIT_LAW_ENFORCEMENT_METABOLISM))
		drinker.heal_bodypart_damage(1 * REM * seconds_per_tick, 1 * REM * seconds_per_tick)
		. = TRUE
	return ..()

/datum/reagent/consumable/ethanol/quintuple_sec
	name = "Quintuple Sec"
	description = "Law, Order, Alcohol, and Police Brutality distilled into one single elixir of JUSTICE."
	color = "#ff3300"
	boozepwr = 55
	quality = DRINK_FANTASTIC
	taste_description = "THE LAW"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/quintuple_sec/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	//Securidrink in line with the Screwdriver for engineers or Nothing for mimes but STRONG..
	var/obj/item/organ/internal/liver/liver = drinker.get_organ_slot(ORGAN_SLOT_LIVER)
	if(liver && HAS_TRAIT(liver, TRAIT_LAW_ENFORCEMENT_METABOLISM))
		drinker.heal_bodypart_damage(2 * REM * seconds_per_tick, 2 * REM *  seconds_per_tick)
		drinker.adjustStaminaLoss(-2 * REM * seconds_per_tick, required_biotype = affected_biotype)
		. = TRUE
	return ..()

/datum/reagent/consumable/ethanol/grasshopper
	name = "Grasshopper"
	description = "A fresh and sweet dessert shooter. Difficult to look manly while drinking this."
	color = "#00ff00"
	boozepwr = 25
	quality = DRINK_GOOD
	taste_description = "chocolate and mint dancing around your mouth"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/stinger
	name = "Stinger"
	description = "A snappy way to end the day."
	color = "#ccff99"
	boozepwr = 25
	quality = DRINK_NICE
	taste_description = "a slap on the face in the best possible way"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/bastion_bourbon
	name = "Bastion Bourbon"
	description = "Soothing hot herbal brew with restorative properties. Hints of citrus and berry flavors."
	color = "#00FFFF"
	boozepwr = 30
	quality = DRINK_FANTASTIC
	taste_description = "hot herbal brew with a hint of fruit"
	metabolization_rate = 2 * REAGENTS_METABOLISM //0.4u per second
	ph = 4
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_HIGH

/datum/reagent/consumable/ethanol/bastion_bourbon/on_mob_metabolize(mob/living/drinker)
	var/heal_points = 10
	if(drinker.health <= 0)
		heal_points = 20 //heal more if we're in softcrit
	for(var/counter in 1 to min(volume, heal_points)) //only heals 1 point of damage per unit on add, for balance reasons
		drinker.adjustBruteLoss(-1, required_bodytype = affected_bodytype)
		drinker.adjustFireLoss(-1, required_bodytype = affected_bodytype)
		drinker.adjustToxLoss(-1, required_biotype = affected_biotype)
		drinker.adjustOxyLoss(-1, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
		drinker.adjustStaminaLoss(-1, required_biotype = affected_biotype)
	drinker.visible_message(span_warning("[drinker] shivers with renewed vigor!"), span_notice("One taste of [lowertext(name)] fills you with energy!"))
	if(!drinker.stat && heal_points == 20) //brought us out of softcrit
		drinker.visible_message(span_danger("[drinker] lurches to [drinker.p_their()] feet!"), span_boldnotice("Up and at 'em, kid."))

/datum/reagent/consumable/ethanol/bastion_bourbon/on_mob_life(mob/living/drinker, seconds_per_tick, times_fired)
	if(drinker.health > 0)
		drinker.adjustBruteLoss(-1 * REM * seconds_per_tick, required_bodytype = affected_bodytype)
		drinker.adjustFireLoss(-1 * REM * seconds_per_tick, required_bodytype = affected_bodytype)
		drinker.adjustToxLoss(-0.5 * REM * seconds_per_tick, required_biotype = affected_biotype)
		drinker.adjustOxyLoss(-3 * REM * seconds_per_tick, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
		drinker.adjustStaminaLoss(-5 * REM * seconds_per_tick, required_biotype = affected_biotype)
		. = TRUE
	..()

/datum/reagent/consumable/ethanol/squirt_cider
	name = "Squirt Cider"
	description = "Fermented squirt extract with a nose of stale bread and ocean water. Whatever a squirt is."
	color = "#FF0000"
	boozepwr = 40
	taste_description = "stale bread with a staler aftertaste"
	nutriment_factor = 2 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/squirt_cider/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	drinker.satiety += 5 * REM * seconds_per_tick //for context, vitamins give 15 satiety per second
	..()
	. = TRUE

/datum/reagent/consumable/ethanol/fringe_weaver
	name = "Fringe Weaver"
	description = "Bubbly, classy, and undoubtedly strong - a Glitch City classic."
	color = "#FFEAC4"
	boozepwr = 90 //classy hooch, essentially, but lower pwr to make up for slightly easier access
	quality = DRINK_GOOD
	taste_description = "ethylic alcohol with a hint of sugar"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/sugar_rush
	name = "Sugar Rush"
	description = "Sweet, light, and fruity - as girly as it gets."
	color = "#FF226C"
	boozepwr = 10
	quality = DRINK_GOOD
	taste_description = "your arteries clogging with sugar"
	nutriment_factor = 2 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/sugar_rush/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	drinker.satiety -= 10 * REM * seconds_per_tick //junky as hell! a whole glass will keep you from being able to eat junk food
	..()
	. = TRUE

/datum/reagent/consumable/ethanol/crevice_spike
	name = "Crevice Spike"
	description = "Sour, bitter, and smashingly sobering."
	color = "#5BD231"
	boozepwr = -10 //sobers you up - ideally, one would drink to get hit with brute damage now to avoid alcohol problems later
	quality = DRINK_VERYGOOD
	taste_description = "a bitter SPIKE with a sour aftertaste"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/crevice_spike/on_mob_metabolize(mob/living/drinker) //damage only applies when drink first enters system and won't again until drink metabolizes out
	drinker.adjustBruteLoss(3 * min(5,volume), required_bodytype = affected_bodytype) //minimum 3 brute damage on ingestion to limit non-drink means of injury - a full 5 unit gulp of the drink trucks you for the full 15

/datum/reagent/consumable/ethanol/sake
	name = "Sake"
	description = "A sweet rice wine of questionable legality and extreme potency."
	color = "#DDDDDD"
	boozepwr = 70
	taste_description = "sweet rice wine"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_STOCK

/datum/reagent/consumable/ethanol/peppermint_patty
	name = "Peppermint Patty"
	description = "This lightly alcoholic drink combines the benefits of menthol and cocoa."
	color = "#45ca7a"
	taste_description = "mint and chocolate"
	boozepwr = 25
	quality = DRINK_GOOD
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/peppermint_patty/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	drinker.apply_status_effect(/datum/status_effect/throat_soothed)
	drinker.adjust_bodytemperature(5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, 0, drinker.get_body_temp_normal())
	..()

/datum/reagent/consumable/ethanol/alexander
	name = "Alexander"
	description = "Named after a Greek hero, this mix is said to embolden a user's shield as if they were in a phalanx."
	color = "#F5E9D3"
	boozepwr = 50
	quality = DRINK_GOOD
	taste_description = "bitter, creamy cacao"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	var/obj/item/shield/mighty_shield

/datum/reagent/consumable/ethanol/alexander/on_mob_metabolize(mob/living/drinker)
	if(ishuman(drinker))
		var/mob/living/carbon/human/the_human = drinker
		for(var/obj/item/shield/the_shield in the_human.contents)
			mighty_shield = the_shield
			mighty_shield.block_chance += 10
			to_chat(the_human, span_notice("[the_shield] appears polished, although you don't recall polishing it."))
			return TRUE

/datum/reagent/consumable/ethanol/alexander/on_mob_life(mob/living/drinker, seconds_per_tick, times_fired)
	..()
	if(mighty_shield && !(mighty_shield in drinker.contents)) //If you had a shield and lose it, you lose the reagent as well. Otherwise this is just a normal drink.
		holder.remove_reagent(type, volume)

/datum/reagent/consumable/ethanol/alexander/on_mob_end_metabolize(mob/living/drinker)
	if(mighty_shield)
		mighty_shield.block_chance -= 10
		to_chat(drinker,span_notice("You notice [mighty_shield] looks worn again. Weird."))
	..()

/datum/reagent/consumable/ethanol/amaretto_alexander
	name = "Amaretto Alexander"
	description = "A weaker version of the Alexander, what it lacks in strength it makes up for in flavor."
	color = "#DBD5AE"
	boozepwr = 35
	quality = DRINK_VERYGOOD
	taste_description = "sweet, creamy cacao"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/sidecar
	name = "Sidecar"
	description = "The one ride you'll gladly give up the wheel for."
	color = "#FFC55B"
	boozepwr = 45
	quality = DRINK_GOOD
	taste_description = "delicious freedom"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_MEDIUM

/datum/reagent/consumable/ethanol/between_the_sheets
	name = "Between the Sheets"
	description = "A provocatively named classic. Funny enough, doctors recommend drinking it before taking a nap while underneath bedsheets."
	color = "#F4C35A"
	boozepwr = 55
	quality = DRINK_GOOD
	taste_description = "seduction"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_MEDIUM

/datum/reagent/consumable/ethanol/between_the_sheets/on_mob_life(mob/living/drinker, seconds_per_tick, times_fired)
	..()
	var/is_between_the_sheets = FALSE
	for(var/obj/item/bedsheet/bedsheet in range(drinker.loc, 0))
		if(bedsheet.loc != drinker.loc) // bedsheets in your backpack/neck don't count
			continue
		is_between_the_sheets = TRUE
		break

	if(!drinker.IsSleeping() || !is_between_the_sheets)
		return

	if(drinker.getBruteLoss() && drinker.getFireLoss()) //If you are damaged by both types, slightly increased healing but it only heals one. The more the merrier wink wink.
		if(prob(50))
			drinker.adjustBruteLoss(-0.25 * REM * seconds_per_tick, required_bodytype = affected_bodytype)
		else
			drinker.adjustFireLoss(-0.25 * REM * seconds_per_tick, required_bodytype = affected_bodytype)
	else if(drinker.getBruteLoss()) //If you have only one, it still heals but not as well.
		drinker.adjustBruteLoss(-0.2 * REM * seconds_per_tick, required_bodytype = affected_bodytype)
	else if(drinker.getFireLoss())
		drinker.adjustFireLoss(-0.2 * REM * seconds_per_tick, required_bodytype = affected_bodytype)

/datum/reagent/consumable/ethanol/kamikaze
	name = "Kamikaze"
	description = "Divinely windy."
	color = "#EEF191"
	boozepwr = 60
	quality = DRINK_GOOD
	taste_description = "divine windiness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/mojito
	name = "Mojito"
	description = "A drink that looks as refreshing as it tastes."
	color = "#DFFAD9"
	boozepwr = 30
	quality = DRINK_GOOD
	taste_description = "refreshing mint"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_MEDIUM

/datum/reagent/consumable/ethanol/moscow_mule
	name = "Moscow Mule"
	description = "A chilly drink that reminds you of the Derelict."
	color = "#EEF1AA"
	boozepwr = 30
	quality = DRINK_GOOD
	taste_description = "refreshing spiciness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/fernet
	name = "Fernet"
	description = "An incredibly bitter herbal liqueur used as a digestif."
	color = "#1B2E24" // rgb: 27, 46, 36
	boozepwr = 80
	taste_description = "utter bitterness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/fernet/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	if(drinker.nutrition <= NUTRITION_LEVEL_STARVING)
		drinker.adjustToxLoss(1 * REM * seconds_per_tick, FALSE, required_biotype = affected_biotype)
	drinker.adjust_nutrition(-5 * REM * seconds_per_tick)
	drinker.overeatduration = 0
	return ..()

/datum/reagent/consumable/ethanol/fernet_cola
	name = "Fernet Cola"
	description = "A very popular and bittersweet digestif, ideal after a heavy meal. Best served on a sawed-off cola bottle as per tradition."
	color = "#390600" // rgb: 57, 6,
	boozepwr = 25
	quality = DRINK_NICE
	taste_description = "sweet relief"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/fernet_cola/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	if(drinker.nutrition <= NUTRITION_LEVEL_STARVING)
		drinker.adjustToxLoss(0.5 * REM * seconds_per_tick, FALSE, required_biotype = affected_biotype)
	drinker.adjust_nutrition(-3 * REM * seconds_per_tick)
	drinker.overeatduration = 0
	return ..()

/datum/reagent/consumable/ethanol/fanciulli
	name = "Fanciulli"
	description = "What if the Manhattan cocktail ACTUALLY used a bitter herb liquour? Helps you sober up." //also causes a bit of stamina damage to symbolize the afterdrink lazyness
	color = "#CA933F" // rgb: 202, 147, 63
	boozepwr = -10
	quality = DRINK_NICE
	taste_description = "a sweet sobering mix"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_HIGH

/datum/reagent/consumable/ethanol/fanciulli/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	drinker.adjust_nutrition(-5 * REM * seconds_per_tick)
	drinker.overeatduration = 0
	return ..()

/datum/reagent/consumable/ethanol/fanciulli/on_mob_metabolize(mob/living/drinker)
	if(drinker.health > 0)
		drinker.adjustStaminaLoss(20, required_biotype = affected_biotype)
		. = TRUE
	..()

/datum/reagent/consumable/ethanol/branca_menta
	name = "Branca Menta"
	description = "A refreshing mixture of bitter Fernet with mint creme liquour."
	color = "#4B5746" // rgb: 75, 87, 70
	boozepwr = 35
	quality = DRINK_GOOD
	taste_description = "a bitter freshness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_MEDIUM

/datum/reagent/consumable/ethanol/branca_menta/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	drinker.adjust_bodytemperature(-20 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, T0C)
	return ..()

/datum/reagent/consumable/ethanol/branca_menta/on_mob_metabolize(mob/living/drinker)
	if(drinker.health > 0)
		drinker.adjustStaminaLoss(35, required_biotype = affected_biotype)
		. = TRUE
	..()

/datum/reagent/consumable/ethanol/blank_paper
	name = "Blank Paper"
	description = "A bubbling glass of blank paper. Just looking at it makes you feel fresh."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#DCDCDC" // rgb: 220, 220, 220
	boozepwr = 20
	quality = DRINK_GOOD
	taste_description = "bubbling possibility"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/blank_paper/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	if(ishuman(drinker) && HAS_MIND_TRAIT(drinker, TRAIT_MIMING))
		drinker.set_silence_if_lower(MIMEDRINK_SILENCE_DURATION)
		drinker.heal_bodypart_damage(1 * REM * seconds_per_tick, 1 * REM * seconds_per_tick)
		. = TRUE
	return ..()

/datum/reagent/consumable/ethanol/fruit_wine
	name = "Fruit Wine"
	description = "A wine made from grown plants."
	color = "#FFFFFF"
	boozepwr = 35
	quality = DRINK_GOOD
	taste_description = "bad coding"
	var/list/names = list("null fruit" = 1) //Names of the fruits used. Associative list where name is key, value is the percentage of that fruit.
	var/list/tastes = list("bad coding" = 1) //List of tastes. See above.
	ph = 4

/datum/reagent/consumable/ethanol/fruit_wine/on_new(list/data)
	if(!data)
		return

	src.data = data
	names = data["names"]
	tastes = data["tastes"]
	boozepwr = data["boozepwr"]
	color = data["color"]
	generate_data_info(data)

/datum/reagent/consumable/ethanol/fruit_wine/on_merge(list/data, amount)
	..()
	var/diff = (amount/volume)
	if(diff < 1)
		color = BlendRGB(color, data["color"], diff/2) //The percentage difference over two, so that they take average if equal.
	else
		color = BlendRGB(color, data["color"], (1/diff)/2) //Adjust so it's always blending properly.
	var/oldvolume = volume-amount

	var/list/cachednames = data["names"]
	for(var/name in names | cachednames)
		names[name] = ((names[name] * oldvolume) + (cachednames[name] * amount)) / volume

	var/list/cachedtastes = data["tastes"]
	for(var/taste in tastes | cachedtastes)
		tastes[taste] = ((tastes[taste] * oldvolume) + (cachedtastes[taste] * amount)) / volume

	boozepwr *= oldvolume
	var/newzepwr = data["boozepwr"] * amount
	boozepwr += newzepwr
	boozepwr /= volume //Blending boozepwr to volume.
	generate_data_info(data)

/datum/reagent/consumable/ethanol/fruit_wine/proc/generate_data_info(list/data)
	// BYOND's compiler fails to catch non-consts in a ranged switch case, and it causes incorrect behavior. So this needs to explicitly be a constant.
	var/const/minimum_percent = 0.15 //Percentages measured between 0 and 1.
	var/list/primary_tastes = list()
	var/list/secondary_tastes = list()
	for(var/taste in tastes)
		switch(tastes[taste])
			if(minimum_percent*2 to INFINITY)
				primary_tastes += taste
			if(minimum_percent to minimum_percent*2)
				secondary_tastes += taste

	var/minimum_name_percent = 0.35
	name = ""
	var/list/names_in_order = sortTim(names, GLOBAL_PROC_REF(cmp_numeric_dsc), TRUE)
	var/named = FALSE
	for(var/fruit_name in names)
		if(names[fruit_name] >= minimum_name_percent)
			name += "[fruit_name] "
			named = TRUE
	if(named)
		name += "Wine"
	else
		name = "Mixed [names_in_order[1]] Wine"

	var/alcohol_description
	switch(boozepwr)
		if(120 to INFINITY)
			alcohol_description = "suicidally strong"
		if(90 to 120)
			alcohol_description = "rather strong"
		if(70 to 90)
			alcohol_description = "strong"
		if(40 to 70)
			alcohol_description = "rich"
		if(20 to 40)
			alcohol_description = "mild"
		if(0 to 20)
			alcohol_description = "sweet"
		else
			alcohol_description = "watery" //How the hell did you get negative boozepwr?

	var/list/fruits = list()
	if(names_in_order.len <= 3)
		fruits = names_in_order
	else
		for(var/i in 1 to 3)
			fruits += names_in_order[i]
		fruits += "other plants"
	var/fruit_list = english_list(fruits)
	description = "A [alcohol_description] wine brewed from [fruit_list]."

	var/flavor = ""
	if(!primary_tastes.len)
		primary_tastes = list("[alcohol_description] alcohol")
	flavor += english_list(primary_tastes)
	if(secondary_tastes.len)
		flavor += ", with a hint of "
		flavor += english_list(secondary_tastes)
	taste_description = flavor

/datum/reagent/consumable/ethanol/champagne //How the hell did we not have champagne already!?
	name = "Champagne"
	description = "A sparkling wine known for its ability to strike fast and hard."
	color = "#ffffc1"
	boozepwr = 40
	taste_description = "auspicious occasions and bad decisions"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_EASY

/datum/reagent/consumable/ethanol/wizz_fizz
	name = "Wizz Fizz"
	description = "A magical potion, fizzy and wild! However the taste, you will find, is quite mild."
	color = "#4235d0" //Just pretend that the triple-sec was blue curacao.
	boozepwr = 50
	quality = DRINK_GOOD
	taste_description = "friendship! It is magic, after all"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/wizz_fizz/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	//A healing drink similar to Quadruple Sec, Ling Stings, and Screwdrivers for the Wizznerds; the check is consistent with the changeling sting
	if(drinker?.mind?.has_antag_datum(/datum/antagonist/wizard))
		drinker.heal_bodypart_damage(1 * REM * seconds_per_tick, 1 * REM * seconds_per_tick)
		drinker.adjustOxyLoss(-1 * REM * seconds_per_tick, FALSE, required_biotype = affected_biotype, required_respiration_type = affected_respiration_type)
		drinker.adjustToxLoss(-1 * REM * seconds_per_tick, FALSE, required_biotype = affected_biotype)
		drinker.adjustStaminaLoss(-1  * REM * seconds_per_tick, required_biotype = affected_biotype)
	return ..()

/datum/reagent/consumable/ethanol/bug_spray
	name = "Bug Spray"
	description = "A harsh, acrid, bitter drink, for those who need something to brace themselves."
	color = "#33ff33"
	boozepwr = 50
	quality = DRINK_GOOD
	taste_description = "the pain of ten thousand slain mosquitos"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/bug_spray/on_new(data)
	. = ..()
	AddElement(/datum/element/bugkiller_reagent)

/datum/reagent/consumable/ethanol/bug_spray/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	// Does some damage to bug biotypes
	var/did_damage = drinker.adjustToxLoss(1 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = MOB_BUG)
	// Random chance of causing a screm if we did some damage
	if(did_damage && SPT_PROB(2, seconds_per_tick))
		drinker.emote("scream")

	return ..() || did_damage

/datum/reagent/consumable/ethanol/applejack
	name = "Applejack"
	description = "The perfect beverage for when you feel the need to horse around."
	color = "#ff6633"
	boozepwr = 20
	taste_description = "an honest day's work at the orchard"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/jack_rose
	name = "Jack Rose"
	description = "A light cocktail perfect for sipping with a slice of pie."
	color = "#ff6633"
	boozepwr = 15
	quality = DRINK_NICE
	taste_description = "a sweet and sour slice of apple"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/turbo
	name = "Turbo"
	description = "A turbulent cocktail associated with outlaw hoverbike racing. Not for the faint of heart."
	color = "#e94c3a"
	boozepwr = 85
	quality = DRINK_VERYGOOD
	taste_description = "the outlaw spirit"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/turbo/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	if(SPT_PROB(2, seconds_per_tick))
		to_chat(drinker, span_notice("[pick("You feel disregard for the rule of law.", "You feel pumped!", "Your head is pounding.", "Your thoughts are racing..")]"))
	drinker.adjustStaminaLoss(-0.25 * drinker.get_drunk_amount() * REM * seconds_per_tick, required_biotype = affected_biotype)
	return ..()

/datum/reagent/consumable/ethanol/old_timer
	name = "Old Timer"
	description = "An archaic potation enjoyed by old coots of all ages."
	color = "#996835"
	boozepwr = 35
	quality = DRINK_NICE
	taste_description = "simpler times"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/old_timer/on_mob_life(mob/living/carbon/human/metabolizer, seconds_per_tick, times_fired)
	if(SPT_PROB(10, seconds_per_tick) && istype(metabolizer))
		metabolizer.age += 1
		if(metabolizer.age > 70)
			metabolizer.set_facial_haircolor("#cccccc", update = FALSE)
			metabolizer.set_haircolor("#cccccc", update = TRUE)
			if(metabolizer.age > 100)
				metabolizer.become_nearsighted(type)
				if(metabolizer.gender == MALE)
					metabolizer.set_facial_hairstyle("Beard (Very Long)", update = TRUE)

				if(metabolizer.age > 969) //Best not let people get older than this or i might incur G-ds wrath
					metabolizer.visible_message(span_notice("[metabolizer] becomes older than any man should be.. and crumbles into dust!"))
					metabolizer.dust(just_ash = FALSE, drop_items = TRUE, force = FALSE)

	return ..()

/datum/reagent/consumable/ethanol/rubberneck
	name = "Rubberneck"
	description = "A quality rubberneck should not contain any gross natural ingredients."
	color = "#ffe65b"
	boozepwr = 60
	quality = DRINK_GOOD
	taste_description = "artifical fruityness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/rubberneck/on_mob_metabolize(mob/living/drinker)
	. = ..()
	ADD_TRAIT(drinker, TRAIT_SHOCKIMMUNE, type)

/datum/reagent/consumable/ethanol/rubberneck/on_mob_end_metabolize(mob/living/drinker)
	REMOVE_TRAIT(drinker, TRAIT_SHOCKIMMUNE, type)
	return ..()

/datum/reagent/consumable/ethanol/duplex
	name = "Duplex"
	description = "An inseparable combination of two fruity drinks."
	color = "#50e5cf"
	boozepwr = 25
	quality = DRINK_NICE
	taste_description = "green apples and blue raspberries"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/trappist
	name = "Trappist Beer"
	description = "A strong dark ale brewed by space-monks."
	color = "#390c00"
	boozepwr = 40
	quality = DRINK_VERYGOOD
	taste_description = "dried plums and malt"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/trappist/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	if(drinker.mind?.holy_role)
		drinker.adjustFireLoss(-2.5 * REM * seconds_per_tick, FALSE, required_bodytype = affected_bodytype)
		drinker.adjust_jitter(-2 SECONDS * REM * seconds_per_tick)
		drinker.adjust_stutter(-2 SECONDS * REM * seconds_per_tick)
	return ..()

/datum/reagent/consumable/ethanol/blazaam
	name = "Blazaam"
	description = "A strange drink that few people seem to remember existing. Doubles as a Berenstain remover."
	boozepwr = 70
	quality = DRINK_FANTASTIC
	taste_description = "alternate realities"
	var/stored_teleports = 0

/datum/reagent/consumable/ethanol/blazaam/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	if(drinker.get_drunk_amount() > 40)
		if(stored_teleports)
			do_teleport(drinker, get_turf(drinker), rand(1,3), channel = TELEPORT_CHANNEL_WORMHOLE)
			stored_teleports--

		if(SPT_PROB(5, seconds_per_tick))
			stored_teleports += rand(2, 6)
			if(prob(70))
				drinker.vomit(vomit_type = VOMIT_PURPLE)
	return ..()

/datum/reagent/consumable/ethanol/planet_cracker
	name = "Planet Cracker"
	description = "This jubilant drink celebrates humanity's triumph over the alien menace. May be offensive to non-human crewmembers."
	boozepwr = 50
	quality = DRINK_FANTASTIC
	taste_description = "triumph with a hint of bitterness"

/datum/reagent/consumable/ethanol/mauna_loa
	name = "Mauna Loa"
	description = "Extremely hot; not for the faint of heart!"
	boozepwr = 40
	color = "#fe8308" // 254, 131, 8
	quality = DRINK_FANTASTIC
	taste_description = "fiery, with an aftertaste of burnt flesh"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/mauna_loa/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	// Heats the user up while the reagent is in the body. Occasionally makes you burst into flames.
	drinker.adjust_bodytemperature(25 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick)
	if (SPT_PROB(2.5, seconds_per_tick))
		drinker.adjust_fire_stacks(1)
		drinker.ignite_mob()
	..()

/datum/reagent/consumable/ethanol/painkiller
	name = "Painkiller"
	description = "Dulls your pain. Your emotional pain, that is."
	boozepwr = 20
	color = "#EAD677"
	quality = DRINK_NICE
	taste_description = "sugary tartness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/pina_colada
	name = "Pina Colada"
	description = "A fresh pineapple drink with coconut rum. Yum."
	boozepwr = 40
	color = "#FFF1B2"
	quality = DRINK_FANTASTIC
	taste_description = "pineapple, coconut, and a hint of the ocean"

/datum/reagent/consumable/ethanol/pina_olivada
	name = "Piña Olivada"
	description = "An oddly designed concoction of olive oil and pineapple juice."
	boozepwr = 20 // the oil coats your gastrointestinal tract, meaning you can't absorb as much alcohol. horrifying
	color = "#493c00"
	quality = DRINK_NICE
	taste_description = "a horrible emulsion of pineapple and olive oil"

/datum/reagent/consumable/ethanol/pina_olivada/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	if(SPT_PROB(8, seconds_per_tick))
		drinker.manual_emote(pick("coughs up some oil", "swallows the lump in [drinker.p_their()] throat", "gags", "chokes up a bit"))
	if(SPT_PROB(3, seconds_per_tick))
		var/static/list/messages = list(
			"A horrible aftertaste coats your mouth.",
			"You feel like you're going to choke on the oil in your throat.",
			"You start to feel some heartburn coming on.",
			"You want to throw up, but you know that nothing can come out due to the clog in your esophagus.",
			"Your throat feels horrible.",
		)
		to_chat(drinker, span_notice(pick(messages)))
	return ..()

/datum/reagent/consumable/ethanol/pruno // pruno mix is in drink_reagents
	name = "Pruno"
	color = "#E78108"
	description = "Fermented prison wine made from fruit, sugar, and despair. Security loves to confiscate this, which is the only kind thing Security has ever done."
	boozepwr = 85
	taste_description = "your tastebuds being individually shanked"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/pruno/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	drinker.adjust_disgust(5 * REM * seconds_per_tick)
	..()

/datum/reagent/consumable/ethanol/ginger_amaretto
	name = "Ginger Amaretto"
	description = "A delightfully simple cocktail that pleases the senses."
	boozepwr = 30
	color = "#EFB42A"
	quality = DRINK_GOOD
	taste_description = "sweetness followed by a soft sourness and warmth"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/godfather
	name = "Godfather"
	description = "A rough cocktail with illegal connections."
	boozepwr = 50
	color = "#E68F00"
	quality = DRINK_GOOD
	taste_description = "a delightful softened punch"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_MEDIUM

/datum/reagent/consumable/ethanol/godmother
	name = "Godmother"
	description = "A twist on a classic, liked more by mature women."
	boozepwr = 50
	color = "#E68F00"
	quality = DRINK_GOOD
	taste_description = "sweetness and a zesty twist"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/kortara
	name = "Kortara"
	description = "A sweet, milky nut-based drink enjoyed on Tizira. Frequently mixed with fruit juices and cocoa for extra refreshment."
	boozepwr = 25
	color = "#EEC39A"
	quality = DRINK_GOOD
	taste_description = "sweet nectar"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/kortara/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	if(drinker.getBruteLoss() && SPT_PROB(10, seconds_per_tick))
		drinker.heal_bodypart_damage(1,0)
		. = TRUE

/datum/reagent/consumable/ethanol/sea_breeze
	name = "Sea Breeze"
	description = "Light and refreshing with a mint and cocoa hit- like mint choc chip ice cream you can drink!"
	boozepwr = 15
	color = "#CFFFE5"
	quality = DRINK_VERYGOOD
	taste_description = "mint choc chip"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/sea_breeze/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	drinker.apply_status_effect(/datum/status_effect/throat_soothed)
	..()

/datum/reagent/consumable/ethanol/white_tiziran
	name = "White Tiziran"
	description = "A mix of vodka and kortara. The Lizard imbibes."
	boozepwr = 65
	color = "#A68340"
	quality = DRINK_GOOD
	taste_description = "strikes and gutters"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/drunken_espatier
	name = "Drunken Espatier"
	description = "Look, if you had to get into a shootout in the cold vacuum of space, you'd want to be drunk too."
	boozepwr = 65
	color = "#A68340"
	quality = DRINK_GOOD
	taste_description = "sorrow"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/drunken_espatier/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	drinker.add_mood_event("numb", /datum/mood_event/narcotic_medium, name) //comfortably numb
	..()

/datum/reagent/consumable/ethanol/drunken_espatier/on_mob_metabolize(mob/living/drinker)
	. = ..()
	drinker.apply_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)

/datum/reagent/consumable/ethanol/drunken_espatier/on_mob_end_metabolize(mob/living/drinker)
	. = ..()
	drinker.remove_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)

/datum/reagent/consumable/ethanol/protein_blend
	name = "Protein Blend"
	description = "A vile blend of protein, pure grain alcohol, korta flour, and blood. Useful for bulking up, if you can keep it down."
	boozepwr = 65
	color = "#FF5B69"
	quality = DRINK_NICE
	taste_description = "regret"
	nutriment_factor = 3 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/protein_blend/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	drinker.adjust_nutrition(2 * REM * seconds_per_tick)
	if(!islizard(drinker))
		drinker.adjust_disgust(5 * REM * seconds_per_tick)
	else
		drinker.adjust_disgust(2 * REM * seconds_per_tick)
	..()

/datum/reagent/consumable/ethanol/mushi_kombucha
	name = "Mushi Kombucha"
	description = "A popular summer beverage on Tizira, made from sweetened mushroom tea."
	boozepwr = 10
	color = "#C46400"
	quality = DRINK_VERYGOOD
	taste_description = "sweet 'shrooms"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/triumphal_arch
	name = "Triumphal Arch"
	description = "A drink celebrating the Lizard Empire and its military victories. It's popular at bars on Unification Day."
	boozepwr = 60
	color = "#FFD700"
	quality = DRINK_FANTASTIC
	taste_description = "victory"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/triumphal_arch/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	if(islizard(drinker))
		drinker.add_mood_event("triumph", /datum/mood_event/memories_of_home, name)
	..()

/datum/reagent/consumable/ethanol/the_juice
	name = "The Juice"
	description = "Woah man, this like, feels familiar to you dude."
	color = "#4c14be"
	boozepwr = 50
	quality = DRINK_GOOD
	taste_description = "like, the future, man"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	var/datum/brain_trauma/special/bluespace_prophet/prophet_trauma

/datum/reagent/consumable/ethanol/the_juice/on_mob_metabolize(mob/living/carbon/drinker)
	. = ..()
	prophet_trauma = new()
	drinker.gain_trauma(prophet_trauma, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/reagent/consumable/ethanol/the_juice/on_mob_end_metabolize(mob/living/carbon/drinker)
	if(prophet_trauma)
		QDEL_NULL(prophet_trauma)
	return ..()

//a jacked up absinthe that causes hallucinations to the game master controller basically, used in smuggling objectives
/datum/reagent/consumable/ethanol/ritual_wine
	name = "Ritual Wine"
	description = "The dangerous, potent, alcoholic component of ritual wine."
	color = rgb(35, 231, 25)
	boozepwr = 90 //enjoy near death intoxication
	taste_mult = 6
	taste_description = "concentrated herbs"

/datum/reagent/consumable/ethanol/ritual_wine/on_mob_metabolize(mob/living/psychonaut)
	. = ..()
	if(!psychonaut.hud_used)
		return
	var/atom/movable/plane_master_controller/game_plane_master_controller = psychonaut.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.add_filter("ritual_wine", 1, list("type" = "wave", "size" = 1, "x" = 5, "y" = 0, "flags" = WAVE_SIDEWAYS))

/datum/reagent/consumable/ethanol/ritual_wine/on_mob_end_metabolize(mob/living/psychonaut)
	. = ..()
	if(!psychonaut.hud_used)
		return
	var/atom/movable/plane_master_controller/game_plane_master_controller = psychonaut.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.remove_filter("ritual_wine")

//Moth Drinks
/datum/reagent/consumable/ethanol/curacao
	name = "Curaçao"
	description = "Made with laraha oranges, for an aromatic finish."
	boozepwr = 30
	color = "#1a5fa1"
	quality = DRINK_NICE
	taste_description = "blue orange"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/navy_rum //IN THE NAVY
	name = "Navy Rum"
	description = "Rum as the finest sailors drink."
	boozepwr = 90 //the finest sailors are often drunk
	color = "#d8e8f0"
	quality = DRINK_NICE
	taste_description = "a life on the waves"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/bitters //why do they call them bitters, anyway? they're more spicy than anything else
	name = "Andromeda Bitters"
	description = "A bartender's best friend, often used to lend a delicate spiciness to any drink. Produced in New Trinidad, now and forever."
	boozepwr = 70
	color = "#1c0000"
	quality = DRINK_NICE
	taste_description = "spiced alcohol"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/admiralty //navy rum, vermouth, fernet
	name = "Admiralty"
	description = "A refined, bitter drink made with navy rum, vermouth and fernet."
	boozepwr = 100
	color = "#1F0001"
	quality = DRINK_VERYGOOD
	taste_description = "haughty arrogance"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/long_haul //Rum, Curacao, Sugar, dash of bitters, lengthened with soda water
	name = "Long Haul"
	description = "A favourite amongst freighter pilots, unscrupulous smugglers, and nerf herders."
	boozepwr = 35
	color = "#003153"
	quality = DRINK_VERYGOOD
	taste_description = "companionship"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/long_john_silver //navy rum, bitters, lemonade
	name = "Long John Silver"
	description = "A long drink of navy rum, bitters, and lemonade. Particularly popular aboard the Mothic Fleet as it's light on ration credits and heavy on flavour."
	boozepwr = 50
	color = "#c4b35c"
	quality = DRINK_VERYGOOD
	taste_description = "rum and spices"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/tropical_storm //dark rum, pineapple juice, triple citrus, curacao
	name = "Tropical Storm"
	description = "A taste of the Caribbean in one glass."
	boozepwr = 40
	color = "#00bfa3"
	quality = DRINK_VERYGOOD
	taste_description = "the tropics"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/dark_and_stormy //rum and ginger beer- simple and classic
	name = "Dark and Stormy"
	description = "A classic drink arriving to thunderous applause." //thank you, thank you, I'll be here forever
	boozepwr = 50
	color = "#8c5046"
	quality = DRINK_GOOD
	taste_description = "ginger and rum"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/salt_and_swell //navy rum, tochtause syrup, egg whites, dash of saline-glucose solution
	name = "Salt and Swell"
	description = "A bracing sour with an interesting salty taste."
	boozepwr = 60
	color = "#b4abd0"
	quality = DRINK_FANTASTIC
	taste_description = "salt and spice"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/tiltaellen //yoghurt, salt, vinegar
	name = "Tiltällen"
	description = "A lightly fermented yoghurt drink with salt and a light dash of vinegar. Has a distinct sour cheesy flavour."
	boozepwr = 10
	color = "#F4EFE2"
	quality = DRINK_NICE
	taste_description = "sour cheesy yoghurt"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/tich_toch
	name = "Tich Toch"
	description = "A mix of Tiltällen, Töchtaüse Syrup, and vodka. It's not exactly to everyones' tastes."
	boozepwr = 75
	color = "#b4abd0"
	quality = DRINK_VERYGOOD
	taste_description = "spicy sour cheesy yoghurt"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/helianthus
	name = "Helianthus"
	description = "A dark yet radiant mixture of absinthe and hallucinogens. The choice of all true artists."
	boozepwr = 75
	color = "#fba914"
	quality = DRINK_VERYGOOD
	taste_description = "golden memories"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	var/hal_amt = 4
	var/hal_cap = 24

/datum/reagent/consumable/ethanol/helianthus/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	if(SPT_PROB(5, seconds_per_tick))
		drinker.adjust_hallucinations_up_to(4 SECONDS * REM * seconds_per_tick, 48 SECONDS)

	..()

/datum/reagent/consumable/ethanol/plumwine
	name = "Plum wine"
	description = "Plums turned into wine."
	color = "#8a0421"
	nutriment_factor = 1 * REAGENTS_METABOLISM
	boozepwr = 20
	taste_description = "a poet's love and undoing"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_STOCK

/datum/reagent/consumable/ethanol/the_hat
	name = "The Hat"
	description = "A fancy drink, usually served in a man's hat."
	color = "#b90a5c"
	boozepwr = 80
	quality = DRINK_NICE
	taste_description = "something perfumy"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_STOCK

/datum/reagent/consumable/ethanol/gin_garden
	name = "Gin Garden"
	description = "Excellent cooling alcoholic drink with not so ordinary taste."
	boozepwr = 20
	color = "#6cd87a"
	quality = DRINK_VERYGOOD
	taste_description = "light gin with sweet ginger and cucumber"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/gin_garden/on_mob_life(mob/living/carbon/doll, seconds_per_tick, times_fired)
	doll.adjust_bodytemperature(-5 * REM * TEMPERATURE_DAMAGE_COEFFICIENT * seconds_per_tick, doll.get_body_temp_normal())
	..()

/datum/reagent/consumable/ethanol/wine_voltaic
	name = "Voltaic Yellow Wine"
	description = "Electrically charged wine. Recharges ethereals, but also nontoxic."
	boozepwr = 30
	color = "#FFAA00"
	taste_description = "static with a hint of sweetness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/wine_voltaic/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume) //can't be on life because of the way blood works.
	. = ..()
	if(!(methods & (INGEST|INJECT|PATCH)) || !iscarbon(exposed_mob))
		return

	var/mob/living/carbon/exposed_carbon = exposed_mob
	var/obj/item/organ/internal/stomach/ethereal/stomach = exposed_carbon.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(istype(stomach))
		stomach.adjust_charge(reac_volume * 3)

/datum/reagent/consumable/ethanol/telepole
	name = "Telepole"
	description = "A grounding rod in the form of a drink.  Recharges ethereals, and gives temporary shock resistance."
	boozepwr = 50
	color = "#b300ff"
	quality = DRINK_NICE
	taste_description = "the howling storm"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/telepole/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	ADD_TRAIT(affected_mob, TRAIT_SHOCKIMMUNE, type)

/datum/reagent/consumable/ethanol/telepole/on_mob_end_metabolize(mob/living/affected_mob)
	REMOVE_TRAIT(affected_mob, TRAIT_SHOCKIMMUNE, type)
	return ..()

/datum/reagent/consumable/ethanol/telepole/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume) //can't be on life because of the way blood works.
	. = ..()
	if(!(methods & (INGEST|INJECT|PATCH)) || !iscarbon(exposed_mob))
		return

	var/mob/living/carbon/exposed_carbon = exposed_mob
	var/obj/item/organ/internal/stomach/ethereal/stomach = exposed_carbon.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(istype(stomach))
		stomach.adjust_charge(reac_volume * 2)

/datum/reagent/consumable/ethanol/pod_tesla
	name = "Pod Tesla"
	description = "Ride the lightning!  Recharges ethereals, suppresses phobias, and gives strong temporary shock resistance."
	boozepwr = 80
	color = "#00fbff"
	quality = DRINK_FANTASTIC
	taste_description = "victory, with a hint of insanity"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/pod_tesla/on_mob_metabolize(mob/living/affected_mob)
	..()
	affected_mob.add_traits(list(TRAIT_SHOCKIMMUNE,TRAIT_TESLA_SHOCKIMMUNE,TRAIT_FEARLESS), type)


/datum/reagent/consumable/ethanol/pod_tesla/on_mob_end_metabolize(mob/living/affected_mob)
	affected_mob.remove_traits(list(TRAIT_SHOCKIMMUNE,TRAIT_TESLA_SHOCKIMMUNE,TRAIT_FEARLESS), type)

/datum/reagent/consumable/ethanol/pod_tesla/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume) //can't be on life because of the way blood works.
	. = ..()
	if(!(methods & (INGEST|INJECT|PATCH)) || !iscarbon(exposed_mob))
		return

	var/mob/living/carbon/exposed_carbon = exposed_mob
	var/obj/item/organ/internal/stomach/ethereal/stomach = exposed_carbon.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(istype(stomach))
		stomach.adjust_charge(reac_volume * 5)

// Welcome to the Blue Room Bar and Grill, home to Mars' finest cocktails
/datum/reagent/consumable/ethanol/rice_beer
	name = "Rice Beer"
	description = "A light, rice-based lagered beer popular on Mars. Considered a hate crime against Bavarians under the Reinheitsgebot Act of 1516."
	boozepwr = 20
	color = "#664300"
	quality = DRINK_NICE
	taste_description = "mild carbonated malt"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/shochu
	name = "Shochu"
	description = "Also known as soju or baijiu, this drink is made from fermented rice, much like sake, but at a generally higher proof making it more similar to a true spirit."
	boozepwr = 20
	color = "#DDDDDD"
	quality = DRINK_NICE
	taste_description = "stiff rice wine"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/yuyake
	name = "Yūyake"
	description = "A sweet melon liqueur from Japan. Considered a relic of the 1980s by most, it has some niche use in cocktail making, in part due to its bright red colour."
	boozepwr = 20
	color = "#F54040"
	quality = DRINK_NICE
	taste_description = "sweet melon"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/coconut_rum
	name = "Coconut Rum"
	description = "The distilled essence of the beach. Tastes like bleach-blonde hair and suncream."
	boozepwr = 20
	color = "#F54040"
	quality = DRINK_NICE
	taste_description = "coconut rum"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

// Mixed Martian Drinks
/datum/reagent/consumable/ethanol/yuyakita
	name = "Yūyakita"
	description = "A hell unleashed upon the world by an unnamed patron."
	boozepwr = 20
	color = "#F54040"
	quality = DRINK_NICE
	taste_description = "death"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/saibasan
	name = "Saibāsan"
	description = "A drink glorifying Cybersun's enduring business."
	boozepwr = 20
	color = "#F54040"
	quality = DRINK_NICE
	taste_description = "betrayal"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/banzai_ti
	name = "Banzai-Tī"
	description = "A variation on the Long Island Iced Tea, made with yuyake for an alternative flavour that's hard to place."
	boozepwr = 20
	color = "#F54040"
	quality = DRINK_NICE
	taste_description = "an asian twist on the liquor cabinet"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/sanraizusoda
	name = "Sanraizusōda"
	description = "It's a melon cream soda, except with alcohol- what's not to love? Well... possibly the hangovers."
	boozepwr = 20
	color = "#F54040"
	quality = DRINK_NICE
	taste_description = "creamy melon soda"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/kumicho
	name = "Kumichō"
	description = "A new take on a classic cocktail, the Kumicho takes the Godfather formula and adds shochu for an Asian twist."
	boozepwr = 20
	color = "#F54040"
	quality = DRINK_NICE
	taste_description = "rice and rye"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/red_planet
	name = "Red Planet"
	description = "Made in celebration of the Martian Concession, the Red Planet is based on the classic El Presidente, and is as patriotic as it is bright crimson."
	boozepwr = 20
	color = "#F54040"
	quality = DRINK_NICE
	taste_description = "the spirit of freedom"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/amaterasu
	name = "Amaterasu"
	description = "Named for Amaterasu, the Shinto Goddess of the Sun, this cocktail embodies radiance- or something like that, anyway."
	boozepwr = 20
	color = "#F54040"
	quality = DRINK_NICE
	taste_description = "sweet nectar of the gods"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/nekomimosa
	name = "Nekomimosa"
	description = "An overly sweet cocktail, made with melon liqueur, melon juice, and champagne (which contains no melon, unfortunately)."
	boozepwr = 20
	color = "#FF0C8D"
	quality = DRINK_NICE
	taste_description = "MELON"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/sentai_quencha //melon soda, triple citrus, shochu, blue curacao
	name = "Sentai Quencha"
	description = "Based on the galaxy-famous \"Kyūkyoku no Ninja Pawā Sentai\", the Sentai Quencha is a favourite at anime conventions and weeb bars."
	boozepwr = 20
	color = "#F54040"
	quality = DRINK_NICE
	taste_description = "ultimate ninja power"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/bosozoku
	name = "Bōsōzoku"
	description = "A simple summer drink from Mars, made from a 1:1 mix of rice beer and lemonade."
	boozepwr = 20
	color = "#F54040"
	quality = DRINK_NICE
	taste_description = "bittersweet lemon"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/ersatzche
	name = "Ersatzche"
	description = "Sweet, bitter, spicy- that's a great combination."
	boozepwr = 20
	color = "#F54040"
	quality = DRINK_NICE
	taste_description = "spicy pineapple beer"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/red_city_am
	name = "Red City AM"
	description = "A breakfast drink from New Osaka, for when you really need to get drunk at 9:30 in the morning in more socially acceptable manner than drinking bagwine on the bullet train. Not that you should drink this on the bullet train either."
	boozepwr = 20
	color = "#F54040"
	quality = DRINK_NICE
	taste_description = "breakfast in a glass"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/kings_ransom
	name = "King's Ransom"
	description = "A stiff, bitter drink with an odd name and odder recipe."
	boozepwr = 20
	color = "#F54040"
	quality = DRINK_NICE
	taste_description = "bitter raspberry"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/four_bit
	name = "Four Bit"
	description = "A drink to power your typing hands."
	boozepwr = 20
	color = "#F54040"
	quality = DRINK_NICE
	taste_description = "cyberspace"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/white_hawaiian //coconut milk, coconut rum, coffee liqueur
	name = "White Hawaiian"
	description = "A take on the classic White Russian, subbing out the classics for some tropical flavours."
	boozepwr = 20
	color = "#F54040"
	quality = DRINK_NICE
	taste_description = "COCONUT"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/maui_sunrise //coconut rum, pineapple juice, yuyake, triple citrus, lemon-lime soda
	name = "Maui Sunrise"
	description = "Behind this drink's red facade lurks a sharp, complex flavour."
	boozepwr = 20
	color = "#F54040"
	quality = DRINK_NICE
	taste_description = "sunrise over the pacific"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/imperial_mai_tai //navy rum, rum, lime, triple sec, korta nectar
	name = "Imperial Mai Tai"
	description = "For when orgeat is in short supply, do as the spacers do- make do and mend."
	boozepwr = 20
	color = "#F54040"
	quality = DRINK_NICE
	taste_description = "spicy nutty rum"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/konococo_rumtini //todo: add espresso | coffee, coffee liqueur, coconut rum, sugar
	name = "Konococo Rumtini"
	description = "Coconut rum, coffee liqueur, and espresso- an odd combination, to be sure, but a welcomed one."
	boozepwr = 20
	color = "#F54040"
	quality = DRINK_NICE
	taste_description = "coconut coffee"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/consumable/ethanol/blue_hawaiian //pineapple juice, lemon juice, coconut rum, blue curacao
	name = "Blue Hawaiian"
	description = "Sweet, sharp and coconutty."
	boozepwr = 20
	color = "#F54040"
	quality = DRINK_NICE
	taste_description = "the aloha state"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

#undef ALCOHOL_EXPONENT
#undef ALCOHOL_THRESHOLD_MODIFIER
