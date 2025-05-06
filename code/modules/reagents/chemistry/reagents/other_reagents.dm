/datum/reagent/blood
	data = list("viruses"=null,"blood_DNA"=null,"blood_type"=null,"resistances"=null,"trace_chem"=null,"mind"=null,"ckey"=null,"gender"=null,"real_name"=null,"cloneable"=null,"factions"=null,"quirks"=null)
	name = "Blood"
	color = "#C80000" // rgb: 200, 0, 0
	metabolization_rate = 12.5 * REAGENTS_METABOLISM //fast rate so it disappears fast.
	taste_description = "iron"
	taste_mult = 1.3
	penetrates_skin = NONE
	ph = 7.4
	default_container = /obj/item/reagent_containers/blood

/datum/glass_style/shot_glass/blood
	required_drink_type = /datum/reagent/blood
	icon_state = "shotglassred"

/datum/glass_style/drinking_glass/blood
	required_drink_type = /datum/reagent/blood
	name = "glass of tomato juice"
	desc = "Are you sure this is tomato juice?"

	// FEED ME
/datum/reagent/blood/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_pestlevel(rand(2, 3))

/datum/reagent/blood/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message=TRUE, touch_protection=0)
	. = ..()
	if(data && data["viruses"])
		for(var/thing in data["viruses"])
			var/datum/disease/strain = thing

			if((strain.spread_flags & DISEASE_SPREAD_SPECIAL) || (strain.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS))
				continue

			if(methods & INGEST)
				if(!strain.has_required_infectious_organ(exposed_mob, ORGAN_SLOT_STOMACH))
					continue

				exposed_mob.ForceContractDisease(strain)
			else if(methods & (INJECT|PATCH))
				if(!strain.has_required_infectious_organ(exposed_mob, ORGAN_SLOT_HEART))
					continue

				exposed_mob.ForceContractDisease(strain)
			else if((methods & (VAPOR|INHALE)) && (strain.spread_flags & DISEASE_SPREAD_CONTACT_FLUIDS))
				if(!strain.has_required_infectious_organ(exposed_mob, ORGAN_SLOT_LUNGS))
					continue

				exposed_mob.ContactContractDisease(strain)
			else if((methods & TOUCH) && (strain.spread_flags & DISEASE_SPREAD_CONTACT_FLUIDS))
				exposed_mob.ContactContractDisease(strain)

	if(data && data["resistances"])
		if(methods & (INGEST|INJECT|INHALE)) //have to inject, inhale or ingest it. no curefoam/cheap curesprays
			for(var/stuff in exposed_mob.diseases)
				var/datum/disease/infection = stuff
				if(infection.GetDiseaseID() in data["resistances"])
					if(!infection.bypasses_immunity)
						infection.cure(add_resistance = FALSE)

	if(iscarbon(exposed_mob))
		var/mob/living/carbon/exposed_carbon = exposed_mob
		var/datum/blood_type/carbon_blood_type = exposed_carbon.dna.blood_type
		if(carbon_blood_type.reagent_type == type && ((methods & INJECT) || ((methods & INGEST) && HAS_TRAIT(exposed_carbon, TRAIT_DRINKS_BLOOD))))
			var/datum/blood_type/recipient_blood_type = exposed_carbon.dna.blood_type
			var/datum/blood_type/donor_blood_type = data["blood_type"]
			if(!(donor_blood_type.type_key() in recipient_blood_type.compatible_types))
				exposed_carbon.reagents.add_reagent(/datum/reagent/toxin, reac_volume * 0.5)
			else
				exposed_carbon.blood_volume = min(exposed_carbon.blood_volume + round(reac_volume, 0.1), BLOOD_VOLUME_MAXIMUM)

			exposed_carbon.reagents.remove_reagent(type, reac_volume) // Because we don't want blood to just lie around in the patient's blood, makes no sense.

		// covers them and their worn equipment in blood
		if((methods & (TOUCH|VAPOR)) && reac_volume > 3)
			if(data["blood_DNA"] && data["blood_type"])
				exposed_carbon.add_blood_DNA(list(data["blood_DNA"] = data["blood_type"]))
			else
				exposed_carbon.add_blood_DNA(list("Non-human DNA" = random_human_blood_type()))

/datum/reagent/blood/on_new(list/data)
	. = ..()
	if(!istype(data))
		return
	SetViruses(src, data)
	var/datum/blood_type/blood_type = data["blood_type"]
	if(!blood_type)
		return
	var/blood_color = blood_type.get_color()
	if(blood_color != BLOOD_COLOR_RED) // If the blood is default red, just use the darker red color for the reagent.
		color = blood_color

/datum/reagent/blood/on_merge(list/mix_data)
	if(data && mix_data)
		if(data["blood_DNA"] != mix_data["blood_DNA"])
			data["cloneable"] = 0 //On mix, consider the genetic sampling unviable for pod cloning if the DNA sample doesn't match.
		if(data["viruses"] || mix_data["viruses"])

			var/list/mix1 = data["viruses"]
			var/list/mix2 = mix_data["viruses"]

			// Stop issues with the list changing during mixing.
			var/list/to_mix = list()

			for(var/datum/disease/advance/AD in mix1)
				to_mix += AD
			for(var/datum/disease/advance/AD in mix2)
				to_mix += AD

			var/datum/disease/advance/AD = Advance_Mix(to_mix)
			if(AD)
				var/list/preserve = list(AD)
				for(var/D in data["viruses"])
					if(!istype(D, /datum/disease/advance))
						preserve += D
				data["viruses"] = preserve
	return 1

/datum/reagent/blood/proc/get_diseases()
	. = list()
	if(data && data["viruses"])
		for(var/thing in data["viruses"])
			var/datum/disease/D = thing
			. += D

/datum/reagent/blood/expose_turf(turf/exposed_turf, reac_volume)//splash the blood all over the place
	. = ..()
	if(!istype(exposed_turf))
		return
	if(reac_volume < 3)
		return

	var/obj/effect/decal/cleanable/blood/bloodsplatter = locate() in exposed_turf //find some blood here
	if(!bloodsplatter)
		bloodsplatter = new(exposed_turf, data["viruses"])
	if(LAZYLEN(data["viruses"]))
		var/list/viruses_to_add = list()
		for(var/datum/disease/virus in data["viruses"])
			if(virus.spread_flags & DISEASE_SPREAD_CONTACT_FLUIDS)
				viruses_to_add += virus
		if(LAZYLEN(viruses_to_add))
			bloodsplatter.AddComponent(/datum/component/infective, viruses_to_add)
	if(data["blood_DNA"])
		bloodsplatter.add_blood_DNA(list(data["blood_DNA"] = data["blood_type"]))

/datum/reagent/blood/expose_obj(obj/exposed_obj, reac_volume, methods=TOUCH, show_message=TRUE)
	. = ..()
	if(!istype(exposed_obj))
		return
	if(reac_volume < 3)
		return

	if(!(methods & (VAPOR|TOUCH)))
		return

	if(LAZYLEN(data["viruses"]))
		var/list/viruses_to_add = list()
		for(var/datum/disease/virus in data["viruses"])
			if(virus.spread_flags & DISEASE_SPREAD_CONTACT_FLUIDS)
				viruses_to_add += virus
		if(length(viruses_to_add))
			exposed_obj.AddComponent(/datum/component/infective, viruses_to_add)
	if(data["blood_DNA"] && data["blood_type"])
		exposed_obj.add_blood_DNA(list(data["blood_DNA"] = data["blood_type"]))
	else
		exposed_obj.add_blood_DNA(list("Non-human DNA" = random_human_blood_type()))

/datum/reagent/blood/get_taste_description(mob/living/taster)
	if(isnull(taster))
		return ..()
	if(!HAS_TRAIT(taster, TRAIT_DETECTIVES_TASTE))
		return ..()
	var/blood_type = data?["blood_type"]
	if(!blood_type)
		return ..()
	return list("[blood_type] type blood" = 1)

/datum/reagent/consumable/liquidgibs
	name = "Liquid Gibs"
	color = "#CC4633"
	description = "You don't even want to think about what's in here."
	taste_description = "gross iron"
	nutriment_factor = 2
	material = /datum/material/meat
	ph = 7.45
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/shot_glass/liquidgibs
	required_drink_type = /datum/reagent/consumable/liquidgibs
	icon_state = "shotglassred"

/datum/reagent/bone_dust
	name = "Bone Dust"
	color = "#dbcdcb"
	description = "Ground up bones, gross!"
	taste_description = "the most disgusting grain in existence"

/datum/reagent/vaccine
	//data must contain virus type
	name = "Vaccine"
	color = "#C81040" // rgb: 200, 16, 64
	taste_description = "slime"
	penetrates_skin = NONE

/datum/reagent/vaccine/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message=TRUE, touch_protection=0)
	. = ..()
	if(!islist(data) || !(methods & (INGEST|INJECT)))
		return

	for(var/thing in exposed_mob.diseases)
		var/datum/disease/infection = thing
		if(infection.GetDiseaseID() in data)
			infection.cure(add_resistance = TRUE)
	LAZYOR(exposed_mob.disease_resistances, data)

/datum/reagent/vaccine/on_merge(list/data)
	if(istype(data))
		src.data |= data.Copy()

/datum/reagent/vaccine/fungal_tb
	name = "Vaccine (Fungal Tuberculosis)"

/datum/reagent/vaccine/fungal_tb/New(data)
	. = ..()
	var/list/cached_data
	if(!data)
		cached_data = list()
	else
		cached_data = data
	cached_data |= "[/datum/disease/tuberculosis]"
	src.data = cached_data

/datum/reagent/water
	name = "Water"
	description = "An ubiquitous chemical substance that is composed of hydrogen and oxygen."
	color = "#AAAAAA77" // rgb: 170, 170, 170, 77 (alpha)
	taste_description = "water"
	var/cooling_temperature = 2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_CLEANS
	default_container = /obj/item/reagent_containers/cup/glass/waterbottle

/datum/glass_style/shot_glass/water
	required_drink_type = /datum/reagent/water
	icon_state = "shotglassclear"

/datum/glass_style/drinking_glass/water
	required_drink_type = /datum/reagent/water
	name = "glass of water"
	desc = "The father of all refreshments."
	icon_state = "glass_clear"

/*
 * Water reaction to turf
 */

/datum/reagent/water/expose_turf(turf/open/exposed_turf, reac_volume)
	. = ..()

	if(!istype(exposed_turf))
		return

	for(var/mob/living/basic/slime/exposed_slime in exposed_turf)
		exposed_slime.apply_water()

	var/cool_temp = cooling_temperature

	var/obj/effect/hotspot/hotspot = (locate(/obj/effect/hotspot) in exposed_turf)
	if(hotspot && !isspaceturf(exposed_turf))
		if(exposed_turf.air)
			var/datum/gas_mixture/air = exposed_turf.air
			air.temperature = max(min(air.temperature-(cool_temp*1000), air.temperature/cool_temp),TCMB)
			air.react(src)
			qdel(hotspot)

	if(isgroundlessturf(exposed_turf) || isnoslipturf(exposed_turf))
		return

	if(reac_volume >= 5)
		exposed_turf.MakeSlippery(TURF_WET_WATER, 10 SECONDS, min(reac_volume*1.5 SECONDS, 60 SECONDS))

/*
 * Water reaction to an object
 */

/datum/reagent/water/expose_obj(obj/exposed_obj, reac_volume, methods=TOUCH, show_message=TRUE)
	. = ..()
	exposed_obj.extinguish()
	exposed_obj.wash(CLEAN_TYPE_ACID)
	// Monkey cube
	if(istype(exposed_obj, /obj/item/food/monkeycube))
		var/obj/item/food/monkeycube/cube = exposed_obj
		cube.Expand()

	// Dehydrated carp
	else if(istype(exposed_obj, /obj/item/toy/plush/carpplushie/dehy_carp))
		var/obj/item/toy/plush/carpplushie/dehy_carp/dehy = exposed_obj
		dehy.Swell() // Makes a carp

	else if(istype(exposed_obj, /obj/item/stack/sheet/hairlesshide))
		var/obj/item/stack/sheet/hairlesshide/HH = exposed_obj
		new /obj/item/stack/sheet/wethide(get_turf(HH), HH.amount)
		qdel(HH)


/// How many wet stacks you get per units of water when it's applied by touch.
#define WATER_TO_WET_STACKS_FACTOR_TOUCH 0.5
/// How many wet stacks you get per unit of water when it's applied by vapor. Much less effective than by touch, of course.
#define WATER_TO_WET_STACKS_FACTOR_VAPOR 0.1


/**
 * Water reaction to a mob
 */
/datum/reagent/water/expose_mob(mob/living/exposed_mob, methods = TOUCH, reac_volume)//Splashing people with water can help put them out!
	. = ..()
	if(methods & TOUCH)
		exposed_mob.extinguish_mob() // extinguish removes all fire stacks
		exposed_mob.adjust_wet_stacks(reac_volume * WATER_TO_WET_STACKS_FACTOR_TOUCH) // Water makes you wet, at a 50% water-to-wet-stacks ratio. Which, in turn, gives you some mild protection from being set on fire!

	if(methods & VAPOR)
		exposed_mob.adjust_wet_stacks(reac_volume * WATER_TO_WET_STACKS_FACTOR_VAPOR) // Spraying someone with water with the hope to put them out is just simply too funny to me not to add it.

		if(!HAS_TRAIT(exposed_mob, TRAIT_WATER_HATER) || HAS_TRAIT(exposed_mob, TRAIT_WATER_ADAPTATION))
			return

		exposed_mob.incapacitate(1) // startles the felinid, canceling any do_after
		exposed_mob.add_mood_event("watersprayed", /datum/mood_event/watersprayed)

	if(methods & (TOUCH|VAPOR)) // wakey wakey eggs and bakey
		exposed_mob.adjust_dizzy(-2 SECONDS)
		exposed_mob.adjust_confusion(-2 SECONDS)
		exposed_mob.adjust_drowsiness(-4 SECONDS)
		exposed_mob.adjust_jitter(-4 SECONDS)
		exposed_mob.AdjustSleeping(-15 SECONDS)
		exposed_mob.AdjustUnconscious(-8 SECONDS)
		var/drunkness_restored = HAS_TRAIT(exposed_mob, TRAIT_WATER_ADAPTATION) ? -0.5 : -0.25
		exposed_mob.adjust_drunk_effect(drunkness_restored)

	if((methods & INGEST) && HAS_TRAIT(exposed_mob, TRAIT_WATER_ADAPTATION) && reac_volume >= 4)
		exposed_mob.adjust_wet_stacks(0.15 * reac_volume)

#undef WATER_TO_WET_STACKS_FACTOR_TOUCH
#undef WATER_TO_WET_STACKS_FACTOR_VAPOR


/datum/reagent/water/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/water_adaptation = HAS_TRAIT(affected_mob, TRAIT_WATER_ADAPTATION)
	if(affected_mob.blood_volume)
		var/blood_restored = water_adaptation ? 0.3 : 0.1
		affected_mob.blood_volume += blood_restored * REM * seconds_per_tick // water is good for you!
	var/drunkness_restored = water_adaptation ? -0.5 : -0.25
	affected_mob.adjust_drunk_effect(drunkness_restored * REM * seconds_per_tick) // and even sobers you up slowly!!
	if(water_adaptation)
		var/need_mob_update = FALSE
		need_mob_update = affected_mob.adjustToxLoss(-0.25 * REM * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype)
		need_mob_update += affected_mob.adjustFireLoss(-0.25 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
		need_mob_update += affected_mob.adjustBruteLoss(-0.25 * REM * seconds_per_tick, updating_health = FALSE, required_bodytype = affected_bodytype)
		return need_mob_update ? UPDATE_MOB_HEALTH : .

// For weird backwards situations where water manages to get added to trays nutrients, as opposed to being snowflaked away like usual.
/datum/reagent/water/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_waterlevel(round(volume))
	//You don't belong in this world, monster!
	mytray.reagents.remove_reagent(type, volume)

/datum/reagent/water/salt
	name = "Saltwater"
	description = "Water, but salty. Smells like... the station infirmary?"
	color = "#aaaaaa9d" // rgb: 170, 170, 170, 77 (alpha)
	taste_description = "the sea"
	cooling_temperature = 3
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_CLEANS
	default_container = /obj/item/reagent_containers/cup/glass/waterbottle

/datum/glass_style/shot_glass/water/salt
	required_drink_type = /datum/reagent/water/salt
	icon_state = "shotglassclear"

/datum/glass_style/drinking_glass/water/salt
	required_drink_type = /datum/reagent/water/salt
	name = "glass of saltwater"
	desc = "If you have a sore throat, gargle some saltwater and watch the pain go away. Can be used as a very improvised topical medicine against wounds."
	icon_state = "glass_clear"

/datum/reagent/water/salt/expose_mob(mob/living/exposed_mob, methods, reac_volume)
	. = ..()
	if(!iscarbon(exposed_mob))
		return
	var/mob/living/carbon/carbies = exposed_mob
	if(!(methods & (PATCH|TOUCH|VAPOR)))
		return
	for(var/datum/wound/iter_wound as anything in carbies.all_wounds)
		iter_wound.on_saltwater(reac_volume, carbies)

// Mixed salt with water! All the help of salt with none of the irritation. Plus increased volume.
/datum/wound/proc/on_saltwater(reac_volume, mob/living/carbon/carbies)
	return

/datum/wound/pierce/bleed/on_saltwater(reac_volume, mob/living/carbon/carbies)
	adjust_blood_flow(-0.06 * reac_volume, initial_flow * 0.6)
	to_chat(carbies, span_notice("The salt water splashes over [LOWER_TEXT(src)], soaking up the blood."))

/datum/wound/slash/flesh/on_saltwater(reac_volume, mob/living/carbon/carbies)
	adjust_blood_flow(-0.1 * reac_volume, initial_flow * 0.5)
	to_chat(carbies, span_notice("The salt water splashes over [LOWER_TEXT(src)], soaking up the blood."))

/datum/wound/burn/flesh/on_saltwater(reac_volume)
	// Similar but better stats from normal salt.
	sanitization += VALUE_PER(0.6, 30) * reac_volume
	infestation -= max(VALUE_PER(0.5, 30) * reac_volume, 0)
	infestation_rate += VALUE_PER(0.07, 30) * reac_volume
	to_chat(victim, span_notice("The salt water splashes over [LOWER_TEXT(src)], soaking up the... miscellaneous fluids. It feels somewhat better afterwards."))
	return

/datum/reagent/water/holywater
	name = "Holy Water"
	description = "Water blessed by some deity."
	color = "#E0E8EF" // rgb: 224, 232, 239
	self_consuming = TRUE //divine intervention won't be limited by the lack of a liver
	ph = 7.5 //God is alkaline
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_CLEANS|REAGENT_UNAFFECTED_BY_METABOLISM // Operates at fixed metabolism for balancing memes.
	default_container = /obj/item/reagent_containers/cup/glass/bottle/holywater
	metabolized_traits = list(TRAIT_HOLY)

/datum/glass_style/drinking_glass/holywater
	required_drink_type = /datum/reagent/water/holywater
	name = "glass of holy water"
	desc = "A glass of holy water."
	icon_state = "glass_clear"

/datum/reagent/water/holywater/on_new(list/data)
	// Tracks the total amount of deciseconds that the reagent has been metab'd for, for the purpose of deconversion
	if(isnull(data))
		data = list("deciseconds_metabolized" = 0)
	else if(isnull(data["deciseconds_metabolized"]))
		data["deciseconds_metabolized"] = 0

	return ..()

// Holy water. Unlike water, which is nuked, stays in and heals the plant a little with the power of the spirits. Also ALSO increases instability.
/datum/reagent/water/holywater/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_waterlevel(round(volume))
	mytray.adjust_plant_health(round(volume * 0.1))
	mytray.myseed?.adjust_instability(round(volume * 0.15))

/datum/reagent/water/holywater/on_mob_add(mob/living/affected_mob, amount)
	. = ..()
	if(IS_CULTIST(affected_mob))
		to_chat(affected_mob, span_userdanger("A vile holiness begins to spread its shining tendrils through your mind, purging the Geometer of Blood's influence!"))

/datum/reagent/water/holywater/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()

	data["deciseconds_metabolized"] += (seconds_per_tick * 1 SECONDS * REM)

	affected_mob.adjust_jitter_up_to(4 SECONDS * REM * seconds_per_tick, 20 SECONDS)
	var/need_mob_update = FALSE

	if(IS_CULTIST(affected_mob))
		for(var/datum/action/innate/cult/blood_magic/BM in affected_mob.actions)
			var/removed_any = FALSE
			for(var/datum/action/innate/cult/blood_spell/BS in BM.spells)
				removed_any = TRUE
				qdel(BS)
			if(removed_any)
				to_chat(affected_mob, span_cult_large("Your blood rites falter as holy water scours your body!"))

	if(data["deciseconds_metabolized"] >= (25 SECONDS)) // 10 units
		affected_mob.adjust_stutter_up_to(4 SECONDS * REM * seconds_per_tick, 20 SECONDS)
		affected_mob.set_dizzy_if_lower(10 SECONDS)
		if(IS_CULTIST(affected_mob) && SPT_PROB(10, seconds_per_tick))
			affected_mob.say(pick("Av'te Nar'Sie","Pa'lid Mors","INO INO ORA ANA","SAT ANA!","Daim'niodeis Arc'iai Le'eones","R'ge Na'sie","Diabo us Vo'iscum","Eld' Mon Nobis"), forced = "holy water")
			if(prob(10))
				affected_mob.visible_message(span_danger("[affected_mob] starts having a seizure!"), span_userdanger("You have a seizure!"))
				affected_mob.Unconscious(12 SECONDS)
				to_chat(affected_mob, span_cult_large("[pick("Your blood is your bond - you are nothing without it", "Do not forget your place", \
					"All that power, and you still fail?", "If you cannot scour this poison, I shall scour your meager life!")]."))
		else if(HAS_TRAIT(affected_mob, TRAIT_EVIL) && SPT_PROB(25, seconds_per_tick)) //Congratulations, your committment to evil has now made holy water a deadly poison to you!
			if(!IS_CULTIST(affected_mob) || affected_mob.mind?.holy_role != HOLY_ROLE_PRIEST)
				affected_mob.painful_scream() // DOPPLER EDIT: check for painkilling before screaming
				need_mob_update += affected_mob.adjustFireLoss(3 * REM * seconds_per_tick, updating_health = FALSE)

	if(data["deciseconds_metabolized"] >= (1 MINUTES)) // 24 units
		if(IS_CULTIST(affected_mob))
			affected_mob.mind.remove_antag_datum(/datum/antagonist/cult)
			affected_mob.Unconscious(10 SECONDS)
		else if(HAS_TRAIT(affected_mob, TRAIT_EVIL)) //At this much holy water, you're probably going to fucking melt. good luck
			if(!IS_CULTIST(affected_mob) || affected_mob.mind?.holy_role != HOLY_ROLE_PRIEST)
				need_mob_update += affected_mob.adjustFireLoss(10 * REM * seconds_per_tick, updating_health = FALSE)
		affected_mob.remove_status_effect(/datum/status_effect/jitter)
		affected_mob.remove_status_effect(/datum/status_effect/speech/stutter)
		holder?.remove_reagent(type, volume) // maybe this is a little too perfect and a max() cap on the statuses would be better??
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/water/holywater/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(!istype(exposed_turf))
		return
	if(reac_volume >= 10)
		for(var/obj/effect/rune/R in exposed_turf)
			qdel(R)
	exposed_turf.Bless()

/datum/reagent/water/hollowwater
	name = "Hollow Water"
	description = "An ubiquitous chemical substance that is composed of hydrogen and oxygen, but it looks kinda hollow."
	color = "#88878777"
	taste_description = "emptyiness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/hydrogen_peroxide
	name = "Hydrogen Peroxide"
	description = "An ubiquitous chemical substance that is composed of hydrogen and oxygen and oxygen." //intended intended
	color = "#AAAAAA77" // rgb: 170, 170, 170, 77 (alpha)
	taste_description = "burning water"
	var/cooling_temperature = 2
	ph = 6.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/shot_glass/hydrogen_peroxide
	required_drink_type = /datum/reagent/hydrogen_peroxide
	icon_state = "shotglassclear"

/datum/glass_style/drinking_glass/hydrogen_peroxide
	required_drink_type = /datum/reagent/hydrogen_peroxide
	name = "glass of oxygenated water"
	desc = "The father of all refreshments. Surely it tastes great, right?"
	icon_state = "glass_clear"

/*
 * Water reaction to turf
 */

/datum/reagent/hydrogen_peroxide/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if (reac_volume < 1.5)
		return
	if (!isplatingturf(exposed_turf) && exposed_turf.type != /turf/closed/wall)
		return
	if (!HAS_TRAIT(exposed_turf, TRAIT_RUSTY))
		exposed_turf.AddElement(/datum/element/rust)
/*
 * Water reaction to a mob
 */

/datum/reagent/hydrogen_peroxide/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, touch_protection = 0) //Exposing people to h2o2 can burn them !
	. = ..()
	if(!(methods & (VAPOR|TOUCH)))
		return

	var/damage_to_inflict = 2 * max(1 - touch_protection, 0)

	if(damage_to_inflict)
		exposed_mob.adjustFireLoss(damage_to_inflict)

/datum/reagent/fuel/unholywater //if you somehow managed to extract this from someone, dont splash it on yourself and have a smoke
	name = "Unholy Water"
	description = "Something that shouldn't exist on this plane of existence."
	taste_description = "suffering"
	self_consuming = TRUE //unholy intervention won't be limited by the lack of a liver
	metabolization_rate = 2.5 * REAGENTS_METABOLISM  //0.5u/second
	penetrates_skin = TOUCH|VAPOR
	ph = 6.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/fuel/unholywater/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	if(IS_CULTIST(affected_mob))
		ADD_TRAIT(affected_mob, TRAIT_COAGULATING, type)

/datum/reagent/fuel/unholywater/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()

	var/need_mob_update = FALSE
	if(IS_CULTIST(affected_mob))
		affected_mob.adjust_drowsiness(-10 SECONDS * REM * seconds_per_tick)
		affected_mob.AdjustAllImmobility(-40 * REM * seconds_per_tick)
		need_mob_update += affected_mob.adjustStaminaLoss(-10 * REM * seconds_per_tick, updating_stamina = FALSE)
		need_mob_update += affected_mob.adjustToxLoss(-2 * REM * seconds_per_tick, updating_health = FALSE)
		need_mob_update += affected_mob.adjustOxyLoss(-2 * REM * seconds_per_tick, updating_health = FALSE)
		need_mob_update += affected_mob.adjustBruteLoss(-2 * REM * seconds_per_tick, updating_health = FALSE)
		need_mob_update += affected_mob.adjustFireLoss(-2 * REM * seconds_per_tick, updating_health = FALSE)
		need_mob_update = TRUE
		if(ishuman(affected_mob) && affected_mob.blood_volume < BLOOD_VOLUME_NORMAL)
			affected_mob.blood_volume += 3 * REM * seconds_per_tick

			var/datum/wound/bloodiest_wound

			for(var/datum/wound/iter_wound as anything in affected_mob.all_wounds)
				if(iter_wound.blood_flow && iter_wound.blood_flow > bloodiest_wound?.blood_flow)
					bloodiest_wound = iter_wound

			if(bloodiest_wound)
				bloodiest_wound.adjust_blood_flow(-2 * REM * seconds_per_tick)

	else  // Will deal about 90 damage when 50 units are thrown
		need_mob_update += affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3 * REM * seconds_per_tick, 150)
		need_mob_update += affected_mob.adjustToxLoss(1 * REM * seconds_per_tick, updating_health = FALSE)
		need_mob_update += affected_mob.adjustFireLoss(1 * REM * seconds_per_tick, updating_health = FALSE)
		need_mob_update += affected_mob.adjustOxyLoss(1 * REM * seconds_per_tick, updating_health = FALSE)
		need_mob_update += affected_mob.adjustBruteLoss(1 * REM * seconds_per_tick, updating_health = FALSE)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/fuel/unholywater/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	REMOVE_TRAIT(affected_mob, TRAIT_COAGULATING, type) //We don't cult check here because potentially our imbiber may no longer be a cultist for whatever reason! It doesn't purge holy water, after all!

/datum/reagent/hellwater //if someone has this in their system they've really pissed off an eldrich god
	name = "Hell Water"
	description = "YOUR FLESH! IT BURNS!"
	taste_description = "burning"
	ph = 0.1
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/hellwater/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.set_fire_stacks(min(affected_mob.fire_stacks + (1.5 * seconds_per_tick), 5))
	affected_mob.ignite_mob() //Only problem with igniting people is currently the commonly available fire suits make you immune to being on fire
	var/need_mob_update
	need_mob_update = affected_mob.adjustToxLoss(0.5*seconds_per_tick, updating_health = FALSE)
	need_mob_update += affected_mob.adjustFireLoss(0.5*seconds_per_tick, updating_health = FALSE) //Hence the other damages... ain't I a bastard?
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2.5*seconds_per_tick, 150)
	if(holder)
		holder.remove_reagent(type, 0.5 * seconds_per_tick)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/medicine/omnizine/godblood
	name = "Godblood"
	description = "Slowly heals all damage types. Has a rather high overdose threshold. Glows with mysterious power."
	overdose_threshold = 150
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

///Used for clownery
/datum/reagent/lube
	name = "Space Lube"
	description = "Lubricant is a substance introduced between two moving surfaces to reduce the friction and wear between them. giggity."
	color = "#009CA8" // rgb: 0, 156, 168
	taste_description = "cherry" // by popular demand
	var/lube_kind = TURF_WET_LUBE ///What kind of slipperiness gets added to turfs
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/lube/expose_turf(turf/open/exposed_turf, reac_volume)
	. = ..()
	if(!istype(exposed_turf))
		return
	if(reac_volume >= 1)
		exposed_turf.MakeSlippery(lube_kind, 15 SECONDS, min(reac_volume * 2 SECONDS, 120))

/datum/reagent/lube/used_on_fish(obj/item/fish/fish)
	ADD_TRAIT(fish, TRAIT_FISH_FED_LUBE, type) //required for the lubefish mutation
	addtimer(TRAIT_CALLBACK_REMOVE(fish, TRAIT_FISH_FED_LUBE, type), fish.feeding_frequency, TIMER_UNIQUE|TIMER_OVERRIDE)
	return TRUE

///Stronger kind of lube. Applies TURF_WET_SUPERLUBE.
/datum/reagent/lube/superlube
	name = "Super Duper Lube"
	description = "This \[REDACTED\] has been outlawed after the incident on \[DATA EXPUNGED\]."
	lube_kind = TURF_WET_SUPERLUBE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/spraytan
	name = "Spray Tan"
	description = "A substance applied to the skin to darken the skin."
	color = "#FFC080" // rgb: 255, 196, 128  Bright orange
	metabolization_rate = 10 * REAGENTS_METABOLISM // very fast, so it can be applied rapidly.  But this changes on an overdose
	overdose_threshold = 11 //Slightly more than one un-nozzled spraybottle.
	taste_description = "sour oranges"
	ph = 5
	fallback_icon = 'icons/obj/drinks/drink_effects.dmi'
	fallback_icon_state = "spraytan_fallback"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	glass_price = DRINK_PRICE_HIGH

/datum/reagent/spraytan/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if(ishuman(exposed_mob))
		if(methods & (PATCH|VAPOR) && touch_protection >= 1)
			var/mob/living/carbon/human/exposed_human = exposed_mob
			if(HAS_TRAIT(exposed_human, TRAIT_USES_SKINTONES))
				switch(exposed_human.skin_tone)
					if("african1")
						exposed_human.skin_tone = "african2"
					if("indian")
						exposed_human.skin_tone = "mixed2"
					if("arab")
						exposed_human.skin_tone = "indian"
					if("asian2")
						exposed_human.skin_tone = "arab"
					if("asian1")
						exposed_human.skin_tone = "asian2"
					if("mediterranean")
						exposed_human.skin_tone = "mixed1"
					if("latino")
						exposed_human.skin_tone = "mediterranean"
					if("caucasian3")
						exposed_human.skin_tone = "mediterranean"
					if("caucasian2")
						exposed_human.skin_tone = pick("caucasian3", "latino")
					if("caucasian1")
						exposed_human.skin_tone = "caucasian2"
					if("albino")
						exposed_human.skin_tone = "caucasian1"
					if("mixed1")
						exposed_human.skin_tone = "mixed2"
					if("mixed2")
						exposed_human.skin_tone = "mixed3"
					if("mixed3")
						exposed_human.skin_tone = "african1"
					if("mixed4")
						exposed_human.skin_tone = "mixed3"
			//take current alien color and darken it slightly
			else if(HAS_TRAIT(exposed_human, TRAIT_MUTANT_COLORS) && !HAS_TRAIT(exposed_human, TRAIT_FIXED_MUTANT_COLORS))
				var/list/existing_color = rgb2num(exposed_human.dna.features["mcolor"])
				var/list/darkened_color = list()
				// Reduces each part of the color by 16
				for(var/channel in existing_color)
					darkened_color += max(channel - 17, 0)

				var/new_color = rgb(darkened_color[1], darkened_color[2], darkened_color[3])
				var/list/new_hsv = rgb2hsv(new_color)
				// Can't get too dark now
				if(new_hsv[3] >= 50)
					exposed_human.dna.features["mcolor"] = new_color
			exposed_human.update_body(is_creating = TRUE)

		if((methods & INGEST) && show_message)
			to_chat(exposed_mob, span_notice("That tasted horrible."))

/datum/reagent/spraytan/overdose_process(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	metabolization_rate = 1 * REAGENTS_METABOLISM

	if(ishuman(affected_mob))
		var/mob/living/carbon/human/affected_human = affected_mob
		var/obj/item/bodypart/head/head = affected_human.get_bodypart(BODY_ZONE_HEAD)
		if(head)
			head.head_flags |= HEAD_HAIR //No hair? No problem!
		if(!HAS_TRAIT(affected_human, TRAIT_SHAVED))
			affected_human.set_facial_hairstyle("Shaved", update = FALSE)
		affected_human.set_facial_haircolor(COLOR_BLACK, update = FALSE)
		if(!HAS_TRAIT(affected_human, TRAIT_BALD))
			affected_human.set_hairstyle("Spiky", update = FALSE)
		affected_human.set_haircolor(COLOR_BLACK, update = FALSE)
		if(HAS_TRAIT(affected_human, TRAIT_USES_SKINTONES))
			affected_human.skin_tone = "orange"
		else if(HAS_TRAIT(affected_human, TRAIT_MUTANT_COLORS) && !HAS_TRAIT(affected_human, TRAIT_FIXED_MUTANT_COLORS)) //Aliens with custom colors simply get turned orange
			affected_human.dna.features["mcolor"] = "#ff8800"
		affected_human.update_body(is_creating = TRUE)
		if(SPT_PROB(3.5, seconds_per_tick))
			if(affected_human.w_uniform)
				affected_mob.visible_message(pick("<b>[affected_mob]</b>'s collar pops up without warning.</span>", "<b>[affected_mob]</b> flexes [affected_mob.p_their()] arms."))
			else
				affected_mob.visible_message("<b>[affected_mob]</b> flexes [affected_mob.p_their()] arms.")
	if(SPT_PROB(5, seconds_per_tick))
		affected_mob.say(pick("Shit was SO cash.", "You are everything bad in the world.", "What sports do you play, other than 'jack off to naked drawn Japanese people?'", "Don???t be a stranger. Just hit me with your best shot.", "My name is John and I hate every single one of you."), forced = /datum/reagent/spraytan)

#define MUT_MSG_IMMEDIATE 1
#define MUT_MSG_EXTENDED 2
#define MUT_MSG_ABOUT2TURN 3

/// the current_cycle threshold / iterations needed before one can transform
#define CYCLES_TO_TURN 20
/// the cycle at which 'immediate' mutation text begins displaying
#define CYCLES_MSG_IMMEDIATE 6
/// the cycle at which 'extended' mutation text begins displaying
#define CYCLES_MSG_EXTENDED 16

/datum/reagent/mutationtoxin
	name = "Stable Mutation Toxin"
	description = "A humanizing toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	metabolization_rate = 0.5 * REAGENTS_METABOLISM //metabolizes to prevent micro-dosage
	taste_description = "slime"
	var/race = /datum/species/human
	var/list/mutationtexts = list( "You don't feel very well." = MUT_MSG_IMMEDIATE,
									"Your skin feels a bit abnormal." = MUT_MSG_IMMEDIATE,
									"Your limbs begin to take on a different shape." = MUT_MSG_EXTENDED,
									"Your appendages begin morphing." = MUT_MSG_EXTENDED,
									"You feel as though you're about to change at any moment!" = MUT_MSG_ABOUT2TURN)

/datum/reagent/mutationtoxin/on_mob_life(mob/living/carbon/human/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(!istype(affected_mob))
		return
	if(!(affected_mob.dna?.species) || !(affected_mob.mob_biotypes & affected_biotype))
		return

	if(SPT_PROB(5, seconds_per_tick))
		var/list/pick_ur_fav = list()
		var/filter = NONE
		if(current_cycle <= CYCLES_MSG_IMMEDIATE)
			filter = MUT_MSG_IMMEDIATE
		else if(current_cycle <= CYCLES_MSG_EXTENDED)
			filter = MUT_MSG_EXTENDED
		else
			filter = MUT_MSG_ABOUT2TURN

		for(var/i in mutationtexts)
			if(mutationtexts[i] == filter)
				pick_ur_fav += i
		to_chat(affected_mob, span_warning("[pick(pick_ur_fav)]"))

	if(current_cycle >= CYCLES_TO_TURN)
		var/datum/species/species_type = race
		affected_mob.set_species(species_type)
		holder.del_reagent(type)
		to_chat(affected_mob, span_warning("You've become \a [LOWER_TEXT(initial(species_type.name))]!"))
		return

/datum/reagent/mutationtoxin/classic //The one from plasma on green slimes
	name = "Mutation Toxin"
	description = "A corruptive toxin."
	color = "#13BC5E" // rgb: 19, 188, 94
	race = /datum/species/jelly/slime
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/mutationtoxin/felinid
	name = "Felinid Mutation Toxin"
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/human/felinid
	taste_description = "something nyat good"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/mutationtoxin/lizard
	name = "Lizard Mutation Toxin"
	description = "A lizarding toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/lizard
	taste_description = "dragon's breath but not as cool"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/mutationtoxin/fly
	name = "Fly Mutation Toxin"
	description = "An insectifying toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/fly
	taste_description = "trash"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/mutationtoxin/moth
	name = "Moth Mutation Toxin"
	description = "A glowing toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/moth
	taste_description = "clothing"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/mutationtoxin/pod
	name = "Podperson Mutation Toxin"
	description = "A vegetalizing toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/pod
	taste_description = "flowers"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/mutationtoxin/jelly
	name = "Imperfect Mutation Toxin"
	description = "A jellyfying toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/jelly
	taste_description = "grandma's gelatin"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/mutationtoxin/jelly/on_mob_life(mob/living/carbon/human/affected_mob, seconds_per_tick, times_fired)
	if(isjellyperson(affected_mob))
		to_chat(affected_mob, span_warning("Your jelly shifts and morphs, turning you into another subspecies!"))
		var/species_type = pick(subtypesof(/datum/species/jelly))
		affected_mob.set_species(species_type)
		holder.del_reagent(type)
		return UPDATE_MOB_HEALTH
	if(current_cycle >= CYCLES_TO_TURN) //overwrite since we want subtypes of jelly
		var/datum/species/species_type = pick(subtypesof(race))
		affected_mob.set_species(species_type)
		holder.del_reagent(type)
		to_chat(affected_mob, span_warning("You've become \a [initial(species_type.name)]!"))
		return UPDATE_MOB_HEALTH
	return ..()

/datum/reagent/mutationtoxin/golem
	name = "Golem Mutation Toxin"
	description = "A crystal toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/golem
	taste_description = "rocks"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/mutationtoxin/abductor
	name = "Abductor Mutation Toxin"
	description = "An alien toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/abductor
	taste_description = "something out of this world... no, universe!"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/mutationtoxin/android
	name = "Android Mutation Toxin"
	description = "A robotic toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/android
	taste_description = "circuitry and steel"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

//BLACKLISTED RACES
/datum/reagent/mutationtoxin/skeleton
	name = "Skeleton Mutation Toxin"
	description = "A scary toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/skeleton
	taste_description = "milk... and lots of it"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/mutationtoxin/zombie
	name = "Zombie Mutation Toxin"
	description = "An undead toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/zombie //Not the infectious kind. The days of xenobio zombie outbreaks are long past.
	taste_description = "brai...nothing in particular"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/mutationtoxin/ash
	name = "Ash Mutation Toxin"
	description = "An ashen toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/lizard/ashwalker
	taste_description = "savagery"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

//DANGEROUS RACES
/datum/reagent/mutationtoxin/shadow
	name = "Shadow Mutation Toxin"
	description = "A dark toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/shadow
	taste_description = "the night"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/mutationtoxin/plasma
	name = "Plasma Mutation Toxin"
	description = "A plasma-based toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/plasmaman
	taste_description = "plasma"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

#undef MUT_MSG_IMMEDIATE
#undef MUT_MSG_EXTENDED
#undef MUT_MSG_ABOUT2TURN

#undef CYCLES_TO_TURN
#undef CYCLES_MSG_IMMEDIATE
#undef CYCLES_MSG_EXTENDED

/datum/reagent/mulligan
	name = "Mulligan Toxin"
	description = "This toxin will rapidly change the DNA of humanoid beings. Commonly used by Syndicate spies and assassins in need of an emergency ID change."
	color = "#5EFF3B" //RGB: 94, 255, 59
	metabolization_rate = INFINITY
	taste_description = "slime"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/mulligan/on_mob_life(mob/living/carbon/human/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if (!istype(affected_mob))
		return
	to_chat(affected_mob, span_warning("<b>You grit your teeth in pain as your body rapidly mutates!</b>"))
	affected_mob.visible_message("<b>[affected_mob]</b> suddenly transforms!")
	randomize_human_normie(affected_mob)

/datum/reagent/aslimetoxin
	name = "Advanced Mutation Toxin"
	description = "An advanced corruptive toxin produced by slimes."
	color = "#13BC5E" // rgb: 19, 188, 94
	taste_description = "slime"
	penetrates_skin = NONE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/aslimetoxin/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message=TRUE, touch_protection=0)
	. = ..()
	if((methods & (PATCH|INGEST|INJECT|INHALE)) || ((methods & (VAPOR|TOUCH)) && prob(min(reac_volume,100)*(1 - touch_protection))))
		exposed_mob.ForceContractDisease(new /datum/disease/transformation/slime(), FALSE, TRUE)

/datum/reagent/gluttonytoxin
	name = "Gluttony's Blessing"
	description = "An advanced corruptive toxin produced by something terrible."
	color = "#5EFF3B" //RGB: 94, 255, 59
	taste_description = "decay"
	penetrates_skin = NONE

/datum/reagent/gluttonytoxin/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message=TRUE, touch_protection=0)
	. = ..()
	if(reac_volume <= 1)//This prevents microdosing from infecting masses of people
		return

	if((methods & (PATCH|INGEST|INJECT|INHALE)) || ((methods & (VAPOR|TOUCH)) && prob(min(reac_volume,100)*(1 - touch_protection))))
		exposed_mob.ForceContractDisease(new /datum/disease/transformation/morph(), FALSE, TRUE)

/datum/reagent/serotrotium
	name = "Serotrotium"
	description = "A chemical compound that promotes concentrated production of the serotonin neurotransmitter in humans."
	color = "#202040" // rgb: 20, 20, 40
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	taste_description = "bitterness"
	ph = 10
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/serotrotium/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(3.5, seconds_per_tick))
		affected_mob.emote(pick("twitch","drool","moan","gasp"))

/datum/reagent/oxygen
	name = "Oxygen"
	description = "A colorless, odorless gas. Grows on trees but is still pretty valuable."
	color = COLOR_GRAY
	taste_mult = 0 // oderless and tasteless
	ph = 9.2//It's acutally a huge range and very dependant on the chemistry but ph is basically a made up var in its implementation anyways
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED


/datum/reagent/oxygen/expose_turf(turf/open/exposed_turf, reac_volume)
	. = ..()
	if(istype(exposed_turf))
		exposed_turf.atmos_spawn_air("[GAS_O2]=[reac_volume/20];[TURF_TEMPERATURE(holder ? holder.chem_temp : T20C)]")
	return

/datum/reagent/copper
	name = "Copper"
	description = "A highly ductile metal. Things made out of copper aren't very durable, but it makes a decent material for electrical wiring."
	color = "#6E3B08" // rgb: 110, 59, 8
	taste_description = "metal"
	ph = 5.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/copper/expose_obj(obj/exposed_obj, reac_volume, methods=TOUCH, show_message=TRUE)
	. = ..()
	if(!istype(exposed_obj, /obj/item/stack/sheet/iron))
		return

	var/obj/item/stack/sheet/iron/metal = exposed_obj
	reac_volume = min(reac_volume, metal.amount)
	new/obj/item/stack/sheet/bronze(get_turf(metal), reac_volume)
	metal.use(reac_volume)

/datum/reagent/nitrogen
	name = "Nitrogen"
	description = "A colorless, odorless, tasteless gas. A simple asphyxiant that can silently displace vital oxygen."
	color = COLOR_GRAY
	taste_mult = 0
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/nitrogen/expose_turf(turf/open/exposed_turf, reac_volume)
	if(istype(exposed_turf))
		exposed_turf.atmos_spawn_air("[GAS_N2]=[reac_volume/20];[TURF_TEMPERATURE(holder ? holder.chem_temp : T20C)]")
	return ..()

/datum/reagent/hydrogen
	name = "Hydrogen"
	description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
	color = COLOR_GRAY
	taste_mult = 0
	ph = 0.1//Now I'm stuck in a trap of my own design. Maybe I should make -ve phes? (not 0 so I don't get div/0 errors)
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/potassium
	name = "Potassium"
	description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
	color = "#A0A0A0" // rgb: 160, 160, 160
	taste_description = "sweetness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/mercury
	name = "Mercury"
	description = "A curious metal that's a liquid at room temperature. Neurodegenerative and very bad for the mind."
	color = COLOR_WEBSAFE_DARK_GRAY // rgb: 72, 72, 72A
	taste_mult = 0 // apparently tasteless.
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/mercury/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(!HAS_TRAIT(src, TRAIT_IMMOBILIZED) && isturf(affected_mob.loc) && !isgroundlessturf(affected_mob.loc))
		step(affected_mob, pick(GLOB.cardinals))
	if(SPT_PROB(3.5, seconds_per_tick))
		affected_mob.emote(pick("twitch","drool","moan"))
	if(affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.5*seconds_per_tick))
		return UPDATE_MOB_HEALTH

/datum/reagent/sulfur
	name = "Sulfur"
	description = "A sickly yellow solid mostly known for its nasty smell. It's actually much more helpful than it looks in biochemistry."
	color = "#BF8C00" // rgb: 191, 140, 0
	taste_description = "rotten eggs"
	ph = 4.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/carbon
	name = "Carbon"
	description = "A crumbly black solid that, while unexciting on a physical level, forms the base of all known life. Kind of a big deal."
	color = "#1C1300" // rgb: 30, 20, 0
	taste_description = "sour chalk"
	ph = 5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/carbon/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(isspaceturf(exposed_turf))
		return

	exposed_turf.spawn_unique_cleanable(/obj/effect/decal/cleanable/dirt)

/datum/reagent/chlorine
	name = "Chlorine"
	description = "A pale yellow gas that's well known as an oxidizer. While it forms many harmless molecules in its elemental form it is far from harmless."
	color = "#FFFB89" //pale yellow? let's make it light gray
	taste_description = "chlorine"
	ph = 7.4
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED


// You're an idiot for thinking that one of the most corrosive and deadly gasses would be beneficial
/datum/reagent/chlorine/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_plant_health(-round(volume))
	mytray.adjust_toxic(round(volume * 1.5))
	mytray.adjust_waterlevel(-round(volume * 0.5))
	mytray.adjust_weedlevel(-rand(1, 3))
	// White Phosphorous + water -> phosphoric acid. That's not a good thing really.


/datum/reagent/chlorine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.take_bodypart_damage(0.5*REM*seconds_per_tick, 0))
		return UPDATE_MOB_HEALTH

/datum/reagent/fluorine
	name = "Fluorine"
	description = "A comically-reactive chemical element. The universe does not want this stuff to exist in this form in the slightest."
	color = COLOR_GRAY
	taste_description = "acid"
	ph = 2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

// You're an idiot for thinking that one of the most corrosive and deadly gasses would be beneficial
/datum/reagent/fluorine/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_plant_health(-round(volume * 2))
	mytray.adjust_toxic(round(volume * 2.5))
	mytray.adjust_waterlevel(-round(volume * 0.5))
	mytray.adjust_weedlevel(-rand(1, 4))

/datum/reagent/fluorine/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.adjustToxLoss(0.5*REM*seconds_per_tick, updating_health = FALSE))
		return UPDATE_MOB_HEALTH

/datum/reagent/sodium
	name = "Sodium"
	description = "A soft silver metal that can easily be cut with a knife. It's not salt just yet, so refrain from putting it on your chips."
	color = COLOR_GRAY
	taste_description = "salty metal"
	ph = 11.6
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/phosphorus
	name = "Phosphorus"
	description = "A ruddy red powder that burns readily. Though it comes in many colors, the general theme is always the same."
	color = "#832828" // rgb: 131, 40, 40
	taste_description = "vinegar"
	ph = 6.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

// Phosphoric salts are beneficial though. And even if the plant suffers, in the long run the tray gets some nutrients. The benefit isn't worth that much.
/datum/reagent/phosphorus/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_plant_health(-round(volume * 0.75))
	mytray.adjust_waterlevel(-round(volume * 0.5))
	mytray.adjust_weedlevel(-rand(1, 2))

/datum/reagent/lithium
	name = "Lithium"
	description = "A silver metal, its claim to fame is its remarkably low density. Using it is a bit too effective in calming oneself down."
	color = COLOR_GRAY
	taste_description = "metal"
	ph = 11.3
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/lithium/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(!HAS_TRAIT(affected_mob, TRAIT_IMMOBILIZED) && isturf(affected_mob.loc) && !isgroundlessturf(affected_mob.loc))
		step(affected_mob, pick(GLOB.cardinals))
	if(SPT_PROB(2.5, seconds_per_tick))
		affected_mob.emote(pick("twitch","drool","moan"))

/datum/reagent/glycerol
	name = "Glycerol"
	description = "Glycerol is a simple polyol compound. Glycerol is sweet-tasting and of low toxicity."
	color = "#D3B913"
	taste_description = "sweetness"
	ph = 9
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/space_cleaner/sterilizine
	name = "Sterilizine"
	description = "Sterilizes wounds in preparation for surgery."
	color = "#D0EFEE" // space cleaner but lighter
	taste_description = "bitterness"
	ph = 10.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_AFFECTS_WOUNDS

/datum/reagent/space_cleaner/sterilizine/expose_mob(mob/living/carbon/exposed_carbon, methods=TOUCH, reac_volume)
	. = ..()
	if(!(methods & (TOUCH|VAPOR|PATCH)))
		return

	for(var/datum/surgery/surgery as anything in exposed_carbon.surgeries)
		surgery.speed_modifier = max(0.2, surgery.speed_modifier)

/datum/reagent/space_cleaner/sterilizine/on_burn_wound_processing(datum/wound/burn/flesh/burn_wound)
	burn_wound.sanitization += 0.9

/datum/reagent/iron
	name = "Iron"
	description = "Pure iron is a metal."
	taste_description = "iron"
	material = /datum/material/iron
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	color = "#606060" //pure iron? let's make it violet of course
	ph = 6

/datum/reagent/gold
	name = "Gold"
	description = "Gold is a dense, soft, shiny metal and the most malleable and ductile metal known."
	color = "#F7C430" // rgb: 247, 196, 48
	taste_description = "expensive metal"
	material = /datum/material/gold
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/silver
	name = "Silver"
	description = "A soft, white, lustrous transition metal, it has the highest electrical conductivity of any element and the highest thermal conductivity of any metal."
	color = "#D0D0D0" // rgb: 208, 208, 208
	taste_description = "expensive yet reasonable metal"
	material = /datum/material/silver
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/uranium
	name = "Uranium"
	description = "A jade-green metallic chemical element in the actinide series, weakly radioactive."
	color = "#5E9964" //this used to be silver, but liquid uranium can still be green and it's more easily noticeable as uranium like this so why bother?
	taste_description = "the inside of a reactor"
	ph = 4
	material = /datum/material/uranium
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/effect/decal/cleanable/greenglow
	/// How much tox damage to deal per tick
	var/tox_damage = 0.5
	/// How radioactive is this reagent
	var/rad_power = 1

/datum/reagent/uranium/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(!HAS_TRAIT(affected_mob, TRAIT_IRRADIATED) && SSradiation.can_irradiate_basic(affected_mob))
		var/chance = min(volume / (20 - rad_power * 5), rad_power)
		if(SPT_PROB(chance, seconds_per_tick)) // ignore rad protection calculations bc it's inside of us
			affected_mob.AddComponent(/datum/component/irradiated)
	if(affected_mob.adjustToxLoss(tox_damage * seconds_per_tick * REM, updating_health = FALSE))
		return UPDATE_MOB_HEALTH

/datum/reagent/uranium/expose_obj(obj/exposed_obj, reac_volume, methods=TOUCH, show_message=TRUE)
	. = ..()

	if(!SSradiation.can_irradiate_basic(exposed_obj))
		return

	radiation_pulse(
		source = exposed_obj,
		max_range = 0,
		threshold = RAD_VERY_LIGHT_INSULATION,
		chance = (min(reac_volume * rad_power, CALCULATE_RAD_MAX_CHANCE(rad_power))),
	)

/datum/reagent/uranium/expose_mob(mob/living/exposed_mob, methods, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()

	if(!SSradiation.can_irradiate_basic(exposed_mob))
		return

	if(ishuman(exposed_mob) && SSradiation.wearing_rad_protected_clothing(exposed_mob))
		return

	if(!(methods & (TOUCH|VAPOR)))
		return

	var/exposure_probability = min(100 - (touch_protection * 100), 0, 100)
	if(exposure_probability && !prob(exposure_probability))
		return


	radiation_pulse(
		source = exposed_mob,
		max_range = 0,
		threshold = RAD_VERY_LIGHT_INSULATION,
		chance = (min(reac_volume * rad_power, CALCULATE_RAD_MAX_CHANCE(rad_power))),
	)

/datum/reagent/uranium/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if((reac_volume < 3) || isspaceturf(exposed_turf))
		return

	var/obj/effect/decal/cleanable/greenglow/glow = exposed_turf.spawn_unique_cleanable(/obj/effect/decal/cleanable/greenglow)
	if(!QDELETED(glow))
		glow.reagents.add_reagent(type, reac_volume)

//Mutagenic chem side-effects.
/datum/reagent/uranium/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.mutation_roll(user)
	mytray.adjust_plant_health(-round(volume))
	mytray.adjust_toxic(round(volume / tox_damage)) // more damage = more

/datum/reagent/uranium/radium
	name = "Radium"
	description = "Radium is an alkaline earth metal. It is extremely radioactive."
	color = "#00CC00" // ditto
	taste_description = "the colour blue and regret"
	tox_damage = 1
	material = null
	ph = 10
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	rad_power = 2

/datum/reagent/bluespace
	name = "Bluespace Dust"
	description = "A dust composed of microscopic bluespace crystals, with minor space-warping properties."
	color = "#0000CC"
	taste_description = "fizzling blue"
	material = /datum/material/bluespace
	ph = 12
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/bluespace/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if(!(methods & (VAPOR|TOUCH)))
		return

	do_teleport(exposed_mob, get_turf(exposed_mob), (reac_volume / 5), asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE) //4 tiles per crystal

/datum/reagent/bluespace/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(current_cycle > 10 && SPT_PROB(7.5, seconds_per_tick))
		to_chat(affected_mob, span_warning("You feel unstable..."))
		affected_mob.set_jitter_if_lower(2 SECONDS)
		current_cycle = 1
		addtimer(CALLBACK(affected_mob, TYPE_PROC_REF(/mob/living, bluespace_shuffle)), 3 SECONDS)

/mob/living/proc/bluespace_shuffle()
	do_teleport(src, get_turf(src), 5, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)

/datum/reagent/aluminium
	name = "Aluminium"
	description = "A silvery white and ductile member of the boron group of chemical elements."
	color = "#A8A8A8" // rgb: 168, 168, 168
	taste_description = "metal"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/silicon
	name = "Silicon"
	description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
	color = "#A8A8A8" // rgb: 168, 168, 168
	taste_mult = 0
	material = /datum/material/glass
	ph = 10
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/fuel
	name = "Welding Fuel"
	description = "Required for welders. Flammable."
	color = "#660000" // rgb: 102, 0, 0
	taste_description = "gross metal"
	penetrates_skin = NONE
	ph = 4
	burning_temperature = 1725 //more refined than oil
	burning_volume = 0.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/alcohol = 4)

/datum/glass_style/drinking_glass/fuel
	required_drink_type = /datum/reagent/fuel
	name = "glass of welder fuel"
	desc = "Unless you're an industrial tool, this is probably not safe for consumption."
	icon_state = "dr_gibb_glass"

/datum/reagent/fuel/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)//Splashing people with welding fuel to make them easy to ignite!
	. = ..()
	if(!(methods & (VAPOR|TOUCH)))
		return

	exposed_mob.adjust_fire_stacks(reac_volume / 10)

/datum/reagent/fuel/on_mob_life(mob/living/carbon/victim, seconds_per_tick, times_fired)
	. = ..()
	var/obj/item/organ/liver/liver = victim.get_organ_slot(ORGAN_SLOT_LIVER)
	if(liver && HAS_TRAIT(liver, TRAIT_HUMAN_AI_METABOLISM))
		return
	if(victim.adjustToxLoss(0.5 * seconds_per_tick, updating_health = FALSE, required_biotype = affected_biotype))
		return UPDATE_MOB_HEALTH

/datum/reagent/fuel/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()

	if(!istype(exposed_turf) || isspaceturf(exposed_turf))
		return

	if((reac_volume < 5))
		return

	var/obj/effect/decal/cleanable/fuel_pool/pool = exposed_turf.spawn_unique_cleanable(/obj/effect/decal/cleanable/fuel_pool)
	if(pool)
		pool.burn_amount = max(min(round(reac_volume / 5), 10), 1)

/datum/reagent/space_cleaner
	name = "Space Cleaner"
	description = "A compound used to clean things. Now with 50% more sodium hypochlorite! Can be used to clean wounds, but it's not really meant for that."
	color = "#A5F0EE" // rgb: 165, 240, 238
	taste_description = "sourness"
	reagent_weight = 0.6 //so it sprays further
	penetrates_skin = VAPOR
	var/clean_types = CLEAN_WASH
	ph = 5.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_CLEANS|REAGENT_AFFECTS_WOUNDS

/datum/reagent/space_cleaner/expose_obj(obj/exposed_obj, reac_volume, methods=TOUCH, show_message=TRUE)
	. = ..()
	exposed_obj?.wash(clean_types)

/datum/reagent/space_cleaner/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(reac_volume < 1)
		return

	exposed_turf.wash(clean_types, TRUE)

	for(var/mob/living/basic/slime/exposed_slime in exposed_turf)
		exposed_slime.adjustToxLoss(rand(5,10))

/datum/reagent/space_cleaner/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message=TRUE, touch_protection=0)
	. = ..()
	if(!(methods & (VAPOR|TOUCH)))
		return

	exposed_mob.wash(clean_types)

/datum/reagent/space_cleaner/on_burn_wound_processing(datum/wound/burn/flesh/burn_wound)
	burn_wound.sanitization += 0.3
	if(prob(5))
		to_chat(burn_wound.victim, span_notice("Your [burn_wound] stings and burns from [src] covering it! It <i>does</i> look pretty clean though."))
		burn_wound.victim.apply_damage(0.5, TOX)
		burn_wound.victim.apply_damage(0.5, BURN, burn_wound.limb, wound_bonus = CANT_WOUND)

/datum/reagent/space_cleaner/ez_clean
	name = "EZ Clean"
	description = "A powerful, acidic cleaner sold by Waffle Corp. Affects organic matter while leaving other objects unaffected."
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "acid"
	penetrates_skin = VAPOR
	ph = 2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/space_cleaner/ez_clean/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = affected_mob.adjustBruteLoss(1.665*seconds_per_tick, updating_health = FALSE)
	need_mob_update += affected_mob.adjustFireLoss(1.665*seconds_per_tick, updating_health = FALSE)
	need_mob_update += affected_mob.adjustToxLoss(1.665*seconds_per_tick, updating_health = FALSE)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/space_cleaner/ez_clean/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if(!(methods & (TOUCH|VAPOR)) || issilicon(exposed_mob))
		return

	var/damage_to_inflict = 1.5 * max(1 - touch_protection, 0)

	if(damage_to_inflict)
		exposed_mob.adjustBruteLoss(damage_to_inflict)
		exposed_mob.adjustFireLoss(damage_to_inflict)

/datum/reagent/cryptobiolin
	name = "Cryptobiolin"
	description = "Cryptobiolin causes confusion and dizziness."
	color = "#ADB5DB" //i hate default violets and 'crypto' keeps making me think of cryo so it's light blue now
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "sourness"
	ph = 11.9
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/cryptobiolin/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.set_dizzy_if_lower(2 SECONDS)

	// Cryptobiolin adjusts the mob's confusion down to 20 seconds if it's higher,
	// or up to 1 second if it's lower, but will do nothing if it's in between
	var/confusion_left = affected_mob.get_timed_status_effect_duration(/datum/status_effect/confusion)
	if(confusion_left < 1 SECONDS)
		affected_mob.set_confusion(1 SECONDS)

	else if(confusion_left > 20 SECONDS)
		affected_mob.set_confusion(20 SECONDS)

/datum/reagent/impedrezene
	name = "Impedrezene"
	description = "Impedrezene is a narcotic that impedes one's ability by slowing down the higher brain cell functions."
	color = "#E07DDD" // pink = happy = dumb
	taste_description = "numbness"
	ph = 9.1
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/opioids = 10)

/datum/reagent/impedrezene/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_jitter(-5 SECONDS * seconds_per_tick)
	if(SPT_PROB(55, seconds_per_tick))
		affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2)
		. = TRUE
	if(SPT_PROB(30, seconds_per_tick))
		affected_mob.adjust_drowsiness(6 SECONDS)
	if(SPT_PROB(5, seconds_per_tick))
		affected_mob.emote("drool")

/datum/reagent/cyborg_mutation_nanomachines
	name = "Nanomachines"
	description = "Microscopic construction robots. Nanomachines son!"
	color = "#535E66" // rgb: 83, 94, 102
	taste_description = "sludge"
	penetrates_skin = NONE

/datum/reagent/cyborg_mutation_nanomachines/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	var/obj/item/organ/liver/liver = exposed_mob.get_organ_slot(ORGAN_SLOT_LIVER)
	if(liver && HAS_TRAIT(liver, TRAIT_HUMAN_AI_METABOLISM))
		return
	if((methods & (PATCH|INGEST|INJECT|INHALE)) || ((methods & (VAPOR|TOUCH)) && prob(min(reac_volume,100)*(1 - touch_protection))))
		exposed_mob.ForceContractDisease(new /datum/disease/transformation/robot(), FALSE, TRUE)

/datum/reagent/xenomicrobes
	name = "Xenomicrobes"
	description = "Microbes with an entirely alien cellular structure."
	color = "#535E66" // rgb: 83, 94, 102
	taste_description = "sludge"
	penetrates_skin = NONE

/datum/reagent/xenomicrobes/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if((methods & (PATCH|INGEST|INJECT|INHALE)) || ((methods & (VAPOR|TOUCH)) && prob(min(reac_volume,100)*(1 - touch_protection))))
		exposed_mob.ForceContractDisease(new /datum/disease/transformation/xeno(), FALSE, TRUE)

/datum/reagent/fungalspores
	name = "Tubercle Bacillus Cosmosis Microbes"
	description = "Active fungal spores."
	color = "#92D17D" // rgb: 146, 209, 125
	taste_description = "slime"
	penetrates_skin = NONE
	ph = 11

/datum/reagent/fungalspores/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if((methods & (PATCH|INGEST|INJECT|INHALE)) || ((methods & (VAPOR|TOUCH)) && prob(min(reac_volume,100)*(1 - touch_protection))))
		exposed_mob.ForceContractDisease(new /datum/disease/tuberculosis(), FALSE, TRUE)

/datum/reagent/snail
	name = "Agent-S"
	description = "Virological agent that infects the subject with Gastrolosis."
	color = COLOR_VERY_DARK_LIME_GREEN // rgb(0, 51, 0)
	taste_description = "goo"
	penetrates_skin = NONE
	ph = 11

/datum/reagent/snail/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if((methods & (PATCH|INGEST|INJECT|INHALE)) || ((methods & (VAPOR|TOUCH)) && prob(min(reac_volume,100)*(1 - touch_protection))))
		exposed_mob.ForceContractDisease(new /datum/disease/gastrolosis(), FALSE, TRUE)

/datum/reagent/fluorosurfactant//foam precursor
	name = "Fluorosurfactant"
	description = "A perfluoronated sulfonic acid that forms a foam when mixed with water."
	color = "#9E6B38" // rgb: 158, 107, 56
	taste_description = "metal"
	ph = 11
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/foaming_agent// Metal foaming agent. This is lithium hydride. Add other recipes (e.g. LiH + H2O -> LiOH + H2) eventually.
	name = "Foaming Agent"
	description = "An agent that yields metallic foam when mixed with light metal and a strong acid."
	color = "#664B63" // rgb: 102, 75, 99
	taste_description = "metal"
	ph = 11.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/smart_foaming_agent //Smart foaming agent. Functions similarly to metal foam, but conforms to walls.
	name = "Smart Foaming Agent"
	description = "An agent that yields metallic foam which conforms to area boundaries when mixed with light metal and a strong acid."
	color = "#664B63" // rgb: 102, 75, 99
	taste_description = "metal"
	ph = 11.8
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/ammonia
	name = "Ammonia"
	description = "A caustic substance commonly used in fertilizer or household cleaners."
	color = "#404030" // rgb: 64, 64, 48
	taste_description = "mordant"
	ph = 11.6
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/ammonia/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	// Ammonia is bad ass.
	mytray.adjust_plant_health(round(volume * 0.12))

	var/obj/item/seeds/myseed = mytray.myseed
	if(!isnull(myseed) && prob(10))
		myseed.adjust_yield(1)
		myseed.adjust_instability(1)

/datum/reagent/diethylamine
	name = "Diethylamine"
	description = "A secondary amine, mildly corrosive."
	color = "#604030" // rgb: 96, 64, 48
	taste_description = "iron"
	ph = 12
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

// This is more bad ass, and pests get hurt by the corrosive nature of it, not the plant. The new trade off is it culls stability.
/datum/reagent/diethylamine/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_plant_health(round(volume))
	mytray.adjust_pestlevel(-rand(1,2))
	var/obj/item/seeds/myseed = mytray.myseed
	if(!isnull(myseed))
		myseed.adjust_yield(round(volume))
		myseed.adjust_instability(-round(volume))

/datum/reagent/carbondioxide
	name = "Carbon Dioxide"
	description = "A gas commonly produced by burning carbon fuels. You're constantly producing this in your lungs."
	color = "#B0B0B0" // rgb : 192, 192, 192
	taste_description = "something unknowable"
	ph = 6
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/carbondioxide/expose_turf(turf/open/exposed_turf, reac_volume)
	if(istype(exposed_turf))
		exposed_turf.atmos_spawn_air("[GAS_CO2]=[reac_volume/20];[TURF_TEMPERATURE(holder ? holder.chem_temp : T20C)]")
	return ..()

/datum/reagent/nitrous_oxide
	name = "Nitrous Oxide"
	description = "A potent oxidizer used as fuel in rockets and as an anaesthetic during surgery. As it is an anticoagulant, nitrous oxide is best \
		used alongside sanguirite to allow blood clotting to continue."
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	color = COLOR_GRAY
	taste_description = "sweetness"
	ph = 5.8
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/nitrous_oxide/expose_turf(turf/open/exposed_turf, reac_volume)
	. = ..()
	if(istype(exposed_turf))
		exposed_turf.atmos_spawn_air("[GAS_N2O]=[reac_volume/20];[TURF_TEMPERATURE(holder ? holder.chem_temp : T20C)]")

/datum/reagent/nitrous_oxide/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if(methods & (VAPOR|INHALE))
		// apply 2 seconds of drowsiness per unit applied, with a min duration of 4 seconds
		var/drowsiness_to_apply = max(round(reac_volume, 1) * 2 SECONDS * (1 - touch_protection), 4 SECONDS)
		exposed_mob.adjust_drowsiness(drowsiness_to_apply)
	if(methods & INHALE)
		exposed_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.25 * reac_volume, required_organ_flag = affected_organ_flags)
		exposed_mob.adjust_hallucinations(10 SECONDS * reac_volume)

/datum/reagent/nitrous_oxide/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	if(!HAS_TRAIT(affected_mob, TRAIT_COAGULATING)) //IF the mob does not have a coagulant in them, we add the blood mess trait to make the bleed quicker
		ADD_TRAIT(affected_mob, TRAIT_BLOODY_MESS, type)

/datum/reagent/nitrous_oxide/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	REMOVE_TRAIT(affected_mob, TRAIT_BLOODY_MESS, type)

/datum/reagent/nitrous_oxide/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_drowsiness(4 SECONDS * REM * seconds_per_tick)

	if(!HAS_TRAIT(affected_mob, TRAIT_BLOODY_MESS) && !HAS_TRAIT(affected_mob, TRAIT_COAGULATING)) //So long as they do not have a coagulant, if they did not have the bloody mess trait, they do now
		ADD_TRAIT(affected_mob, TRAIT_BLOODY_MESS, type)

	else if(HAS_TRAIT(affected_mob, TRAIT_COAGULATING)) //if we find they now have a coagulant, we remove the trait
		REMOVE_TRAIT(affected_mob, TRAIT_BLOODY_MESS, type)

	if(SPT_PROB(10, seconds_per_tick))
		affected_mob.losebreath += 2
		affected_mob.adjust_confusion_up_to(2 SECONDS, 5 SECONDS)

/////////////////////////Colorful Powder////////////////////////////
//For colouring in /proc/mix_color_from_reagents

/datum/reagent/colorful_reagent/powder
	name = "Mundane Powder" //the name's a bit similar to the name of colorful reagent, but hey, they're practically the same chem anyway
	description = "A powder that is used for coloring things."
	color = COLOR_WHITE
	taste_description = "the back of class"
	can_color_organs = TRUE
	var/colorname = "none"

/datum/reagent/colorful_reagent/powder/New()
	if(colorname == "none")
		description = "A rather mundane-looking powder. It doesn't look like it'd color much of anything..."
	else if(colorname == "invisible")
		description = "An invisible powder. Unfortunately, since it's invisible, it doesn't look like it'd color much of anything..."
	else
		description = "\An [colorname] powder, used for coloring things [colorname]."
	return ..()

/datum/reagent/colorful_reagent/powder/red
	name = "Red Powder"
	colorname = "red"
	color = COLOR_CRAYON_RED
	random_color_list = list("#FC7474")
	ph = 0.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/orange
	name = "Orange Powder"
	colorname = "orange"
	color = COLOR_CRAYON_ORANGE
	random_color_list = list(COLOR_CRAYON_ORANGE)
	ph = 2

/datum/reagent/colorful_reagent/powder/yellow
	name = "Yellow Powder"
	colorname = "yellow"
	color = COLOR_CRAYON_YELLOW
	random_color_list = list(COLOR_CRAYON_YELLOW)
	ph = 5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/green
	name = "Green Powder"
	colorname = "green"
	color = COLOR_CRAYON_GREEN
	random_color_list = list(COLOR_CRAYON_GREEN)
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/blue
	name = "Blue Powder"
	colorname = "blue"
	color = COLOR_CRAYON_BLUE
	random_color_list = list("#71CAE5")
	ph = 10
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/purple
	name = "Purple Powder"
	colorname = "purple"
	color = COLOR_CRAYON_PURPLE
	random_color_list = list("#BD8FC4")
	ph = 13
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/invisible
	name = "Invisible Powder"
	colorname = "invisible"
	color = "#FFFFFF00" // white + no alpha
	random_color_list = list(COLOR_WHITE) //because using the powder color turns things invisible
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/black
	name = "Black Powder"
	colorname = "black"
	color = COLOR_CRAYON_BLACK
	random_color_list = list("#8D8D8D") //more grey than black, not enough to hide your true colors
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/white
	name = "White Powder"
	colorname = "white"
	color = COLOR_WHITE
	random_color_list = list(COLOR_WHITE)
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/* used by crayons, can't color living things but still used for stuff like food recipes */

/datum/reagent/colorful_reagent/powder/red/crayon
	name = "Red Crayon Powder"
	can_color_mobs = FALSE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/orange/crayon
	name = "Orange Crayon Powder"
	can_color_mobs = FALSE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/yellow/crayon
	name = "Yellow Crayon Powder"
	can_color_mobs = FALSE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/green/crayon
	name = "Green Crayon Powder"
	can_color_mobs = FALSE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/blue/crayon
	name = "Blue Crayon Powder"
	can_color_mobs = FALSE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/purple/crayon
	name = "Purple Crayon Powder"
	can_color_mobs = FALSE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

//datum/reagent/colorful_reagent/powder/invisible/crayon

/datum/reagent/colorful_reagent/powder/black/crayon
	name = "Black Crayon Powder"
	can_color_mobs = FALSE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/white/crayon
	name = "White Crayon Powder"
	can_color_mobs = FALSE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

//////////////////////////////////Hydroponics stuff///////////////////////////////

/datum/reagent/plantnutriment
	name = "Generic Nutriment"
	description = "Some kind of nutriment. You can't really tell what it is. You should probably report it, along with how you obtained it."
	color = COLOR_BLACK // RBG: 0, 0, 0
	var/tox_prob = 0
	taste_description = "plant food"
	ph = 3

/datum/reagent/plantnutriment/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(tox_prob, seconds_per_tick))
		if(affected_mob.adjustToxLoss(1, updating_health = FALSE, required_biotype = affected_biotype))
			return UPDATE_MOB_HEALTH

/datum/reagent/plantnutriment/eznutriment
	name = "E-Z Nutrient"
	description = "Contains electrolytes. It's what plants crave."
	color = "#376400" // RBG: 50, 100, 0
	tox_prob = 5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/plantnutriment/eznutriment/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	var/obj/item/seeds/myseed = mytray.myseed
	if(!isnull(myseed))
		myseed.adjust_instability(0.2)
		myseed.adjust_potency(round(volume * 0.3))
		myseed.adjust_yield(round(volume * 0.1))

/datum/reagent/plantnutriment/left4zednutriment
	name = "Left 4 Zed"
	description = "Unstable nutriment that makes plants mutate more often than usual."
	color = "#1A1E4D" // RBG: 26, 30, 77
	tox_prob = 13
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/plantnutriment/left4zednutriment/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)

	mytray.adjust_plant_health(round(volume * 0.1))
	mytray.myseed?.adjust_instability(round(volume * 0.2))

/datum/reagent/plantnutriment/robustharvestnutriment
	name = "Robust Harvest"
	description = "Very potent nutriment that slows plants from mutating."
	color = "#9D9D00" // RBG: 157, 157, 0
	tox_prob = 8
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/plantnutriment/robustharvestnutriment/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	var/obj/item/seeds/myseed = mytray.myseed
	if(!isnull(myseed))
		myseed.adjust_instability(-0.25)
		myseed.adjust_potency(round(volume * 0.1))
		myseed.adjust_yield(round(volume * 0.2))

/datum/reagent/plantnutriment/endurogrow
	name = "Enduro Grow"
	description = "A specialized nutriment, which decreases product quantity and potency, but strengthens the plants endurance."
	color = "#a06fa7" // RBG: 160, 111, 167
	tox_prob = 8
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/plantnutriment/endurogrow/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	var/obj/item/seeds/myseed = mytray.myseed
	if(!isnull(myseed))
		myseed.adjust_potency(-round(volume * 0.1))
		myseed.adjust_yield(-round(volume * 0.075))
		myseed.adjust_endurance(round(volume * 0.35))

/datum/reagent/plantnutriment/liquidearthquake
	name = "Liquid Earthquake"
	description = "A specialized nutriment, which increases the plant's production speed, as well as it's susceptibility to weeds."
	color = "#912e00" // RBG: 145, 46, 0
	tox_prob = 13
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/plantnutriment/liquidearthquake/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)

	var/obj/item/seeds/myseed = mytray.myseed
	if(!isnull(myseed))
		myseed.adjust_weed_rate(round(volume * 0.1))
		myseed.adjust_weed_chance(round(volume * 0.3))
		myseed.adjust_production(-round(volume * 0.075))

// GOON OTHERS



/datum/reagent/fuel/oil
	name = "Oil"
	description = "Burns in a small smoky fire, can be used to get Ash."
	color = "#2D2D2D"
	taste_description = "oil"
	burning_temperature = 1200//Oil is crude
	burning_volume = 0.05 //but has a lot of hydrocarbons
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = null
	default_container = /obj/effect/decal/cleanable/oil

/datum/reagent/stable_plasma
	name = "Stable Plasma"
	description = "Non-flammable plasma locked into a liquid form that cannot ignite or become gaseous/solid."
	color = "#2D2D2D"
	taste_description = "bitterness"
	taste_mult = 1.5
	ph = 1.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/stable_plasma/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjustPlasma(10 * REM * seconds_per_tick)

/datum/reagent/iodine
	name = "Iodine"
	description = "Commonly added to table salt as a nutrient. On its own it tastes far less pleasing."
	color = "#BC8A00"
	taste_description = "metal"
	ph = 4.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/carpet
	name = "Carpet"
	description = "For those that need a more creative way to roll out a red carpet."
	color = "#771100"
	taste_description = "carpet" // Your tounge feels furry.
	var/carpet_type = /turf/open/floor/carpet
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/carpet/expose_turf(turf/exposed_turf, reac_volume)
	if(isopenturf(exposed_turf) && exposed_turf.turf_flags & IS_SOLID && !istype(exposed_turf, /turf/open/floor/carpet))
		exposed_turf.place_on_top(carpet_type, flags = CHANGETURF_INHERIT_AIR)
	..()

/datum/reagent/carpet/black
	name = "Black Carpet"
	description = "The carpet also comes in... BLAPCK" //yes, the typo is intentional
	color = "#1E1E1E"
	taste_description = "licorice"
	carpet_type = /turf/open/floor/carpet/black
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/carpet/blue
	name = "Blue Carpet"
	description = "For those that really need to chill out for a while."
	color = "#0000DC"
	taste_description = "frozen carpet"
	carpet_type = /turf/open/floor/carpet/blue
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/carpet/cyan
	name = "Cyan Carpet"
	description = "For those that need a throwback to the years of using poison as a construction material. Smells like asbestos."
	color = "#00B4FF"
	taste_description = "asbestos"
	carpet_type = /turf/open/floor/carpet/cyan
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/carpet/green
	name = "Green Carpet"
	description = "For those that need the perfect flourish for green eggs and ham."
	color = COLOR_CRAYON_GREEN
	taste_description = "Green" //the caps is intentional
	carpet_type = /turf/open/floor/carpet/green
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/carpet/orange
	name = "Orange Carpet"
	description = "For those that prefer a healthy carpet to go along with their healthy diet."
	color = "#E78108"
	taste_description = "orange juice"
	carpet_type = /turf/open/floor/carpet/orange
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/carpet/purple
	name = "Purple Carpet"
	description = "For those that need to waste copious amounts of healing jelly in order to look fancy."
	color = "#91D865"
	taste_description = "jelly"
	carpet_type = /turf/open/floor/carpet/purple
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/carpet/red
	name = "Red Carpet"
	description = "For those that need an even redder carpet."
	color = "#731008"
	taste_description = "blood and gibs"
	carpet_type = /turf/open/floor/carpet/red
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/carpet/royal
	name = "Royal Carpet?"
	description = "For those that break the game and need to make an issue report."

/datum/reagent/carpet/royal/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/obj/item/organ/liver/liver = affected_mob.get_organ_slot(ORGAN_SLOT_LIVER)
	if(liver)
		// Heads of staff and the captain have a "royal metabolism"
		if(HAS_TRAIT(liver, TRAIT_ROYAL_METABOLISM))
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, "You feel like royalty.")
			if(SPT_PROB(2.5, seconds_per_tick))
				affected_mob.say(pick("Peasants..","This carpet is worth more than your contracts!","I could fire you at any time..."), forced = "royal carpet")

		// The quartermaster, as a semi-head, has a "pretender royal" metabolism
		else if(HAS_TRAIT(liver, TRAIT_PRETENDER_ROYAL_METABOLISM))
			if(SPT_PROB(8, seconds_per_tick))
				to_chat(affected_mob, "You feel like an impostor...")

/datum/reagent/carpet/royal/black
	name = "Royal Black Carpet"
	description = "For those that feel the need to show off their time-wasting skills."
	color = COLOR_BLACK
	taste_description = "royalty"
	carpet_type = /turf/open/floor/carpet/royalblack
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/carpet/royal/blue
	name = "Royal Blue Carpet"
	description = "For those that feel the need to show off their time-wasting skills... in BLUE."
	color = "#5A64C8"
	taste_description = "blueyalty" //also intentional
	carpet_type = /turf/open/floor/carpet/royalblue
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/carpet/neon
	name = "Neon Carpet"
	description = "For those who like the 1980s, Vegas, and debugging."
	color = COLOR_ALMOST_BLACK
	taste_description = "neon"
	ph = 6
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	carpet_type = /turf/open/floor/carpet/neon

/datum/reagent/carpet/neon/simple_white
	name = "Simple White Neon Carpet"
	description = "For those who like fluorescent lighting."
	color = LIGHT_COLOR_HALOGEN
	taste_description = "sodium vapor"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	carpet_type = /turf/open/floor/carpet/neon/simple/white

/datum/reagent/carpet/neon/simple_red
	name = "Simple Red Neon Carpet"
	description = "For those who like a bit of uncertainty."
	color = COLOR_RED
	taste_description = "neon hallucinations"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	carpet_type = /turf/open/floor/carpet/neon/simple/red

/datum/reagent/carpet/neon/simple_orange
	name = "Simple Orange Neon Carpet"
	description = "For those who like some sharp edges."
	color = COLOR_ORANGE
	taste_description = "neon spines"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	carpet_type = /turf/open/floor/carpet/neon/simple/orange

/datum/reagent/carpet/neon/simple_yellow
	name = "Simple Yellow Neon Carpet"
	description = "For those who need a little stability in their lives."
	color = COLOR_YELLOW
	taste_description = "stabilized neon"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	carpet_type = /turf/open/floor/carpet/neon/simple/yellow

/datum/reagent/carpet/neon/simple_lime
	name = "Simple Lime Neon Carpet"
	description = "For those who need a little bitterness."
	color = COLOR_LIME
	taste_description = "neon citrus"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	carpet_type = /turf/open/floor/carpet/neon/simple/lime

/datum/reagent/carpet/neon/simple_green
	name = "Simple Green Neon Carpet"
	description = "For those who need a little bit of change in their lives."
	color = COLOR_GREEN
	taste_description = "radium"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	carpet_type = /turf/open/floor/carpet/neon/simple/green

/datum/reagent/carpet/neon/simple_teal
	name = "Simple Teal Neon Carpet"
	description = "For those who need a smoke."
	color = COLOR_TEAL
	taste_description = "neon tobacco"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	carpet_type = /turf/open/floor/carpet/neon/simple/teal

/datum/reagent/carpet/neon/simple_cyan
	name = "Simple Cyan Neon Carpet"
	description = "For those who need to take a breath."
	color = COLOR_DARK_CYAN
	taste_description = "neon air"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	carpet_type = /turf/open/floor/carpet/neon/simple/cyan

/datum/reagent/carpet/neon/simple_blue
	name = "Simple Blue Neon Carpet"
	description = "For those who need to feel joy again."
	color = COLOR_NAVY
	taste_description = "neon blue"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	carpet_type = /turf/open/floor/carpet/neon/simple/blue

/datum/reagent/carpet/neon/simple_purple
	name = "Simple Purple Neon Carpet"
	description = "For those that need a little bit of exploration."
	color = COLOR_PURPLE
	taste_description = "neon hell"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	carpet_type = /turf/open/floor/carpet/neon/simple/purple

/datum/reagent/carpet/neon/simple_violet
	name = "Simple Violet Neon Carpet"
	description = "For those who want to temp fate."
	color = COLOR_VIOLET
	taste_description = "neon hell"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	carpet_type = /turf/open/floor/carpet/neon/simple/violet

/datum/reagent/carpet/neon/simple_pink
	name = "Simple Pink Neon Carpet"
	description = "For those just want to stop thinking so much."
	color = COLOR_PINK
	taste_description = "neon pink"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	carpet_type = /turf/open/floor/carpet/neon/simple/pink

/datum/reagent/carpet/neon/simple_black
	name = "Simple Black Neon Carpet"
	description = "For those who need to catch their breath."
	color = COLOR_BLACK
	taste_description = "neon ash"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	carpet_type = /turf/open/floor/carpet/neon/simple/black

/datum/reagent/bromine
	name = "Bromine"
	description = "A brownish liquid that's highly reactive. Useful for stopping free radicals, but not intended for human consumption."
	color = "#D35415"
	taste_description = "chemicals"
	ph = 7.8
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/pentaerythritol
	name = "Pentaerythritol"
	description = "Slow down, it ain't no spelling bee!"
	color = "#E66FFF"
	taste_description = "acid"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/acetaldehyde
	name = "Acetaldehyde"
	description = "Similar to plastic. Tastes like dead people."
	color = "#EEEEEF"
	taste_description = "dead people" //made from formaldehyde, ya get da joke ?
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/acetone_oxide
	name = "Acetone Oxide"
	description = "Enslaved oxygen"
	color = "#966199cb"
	taste_description = "acid"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/acetone_oxide/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)//Splashing people kills people!
	. = ..()
	if(!(methods & TOUCH))
		return

	var/damage_to_inflict = 2 * max(1 - touch_protection, 0)

	if(damage_to_inflict)
		exposed_mob.adjustFireLoss(damage_to_inflict)

	exposed_mob.adjust_fire_stacks((reac_volume / 10))

/datum/reagent/phenol
	name = "Phenol"
	description = "An aromatic ring of carbon with a hydroxyl group. A useful precursor to some medicines, but has no healing properties on its own."
	color = "#E7EA91"
	taste_description = "acid"
	ph = 5.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/ash
	name = "Ash"
	description = "Supposedly phoenixes rise from these, but you've never seen it."
	color = "#515151"
	taste_description = "ash"
	ph = 6.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/effect/decal/cleanable/ash

// Ash is also used IRL in gardening, as a fertilizer enhancer and weed killer
/datum/reagent/ash/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_plant_health(round(volume))
	mytray.adjust_weedlevel(-1)

/datum/reagent/acetone
	name = "Acetone"
	description = "A slick, slightly carcinogenic liquid. Has a multitude of mundane uses in everyday life."
	color = "#AF14B7"
	taste_description = "acid"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent
	name = "Colorful Reagent"
	description = "Thoroughly sample the rainbow."
	var/list/random_color_list = list("#00aedb","#a200ff","#f47835","#d41243","#d11141","#00b159","#00aedb","#f37735","#ffc425","#008744","#0057e7","#d62d20","#ffa700")
	color = COLOR_GRAY
	taste_description = "rainbows"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	/// Whenever this reagent can color mob limbs and organs upon exposure
	var/can_color_mobs = TRUE
	/// Whenever this reagent can color mob equipment when they're exposed to it externally
	var/can_color_clothing = TRUE
	/// Whenever this reagent can color mob organs when taken internally
	var/can_color_organs = FALSE // False by default as this would cause chaotic flickering of victim's eyes
	var/datum/callback/color_callback

/datum/reagent/colorful_reagent/New()
	color_callback = CALLBACK(src, PROC_REF(UpdateColor))
	SSticker.OnRoundstart(color_callback)
	return ..()

/datum/reagent/colorful_reagent/Destroy()
	LAZYREMOVE(SSticker.round_end_events, color_callback) //Prevents harddels during roundstart
	color_callback = null //Fly free little callback
	return ..()

/datum/reagent/colorful_reagent/proc/UpdateColor()
	color_callback = null
	color = pick(random_color_list)

/datum/reagent/colorful_reagent/expose_mob(mob/living/exposed_mob, methods, reac_volume, show_message, touch_protection)
	. = ..()
	var/picked_color = pick(random_color_list)
	var/color_filter = color_transition_filter(picked_color, SATURATION_OVERRIDE)
	if (can_color_clothing && (methods & (TOUCH|VAPOR|INHALE)))
		var/include_flags = INCLUDE_HELD|INCLUDE_ACCESSORIES
		if (methods & (VAPOR|INHALE) || touch_protection >= 1)
			include_flags |= INCLUDE_POCKETS
		// Not as anyting because this can produce nulls with the flags we passed
		for (var/obj/item/to_color in exposed_mob.get_equipped_items(include_flags))
			to_color.add_atom_colour(color_filter, WASHABLE_COLOUR_PRIORITY)

	if (ishuman(exposed_mob))
		var/mob/living/carbon/human/exposed_human = exposed_mob
		exposed_human.set_facial_haircolor(picked_color, update = FALSE)
		exposed_human.set_haircolor(picked_color)

	if (!can_color_mobs)
		return

	if (!iscarbon(exposed_mob))
		exposed_mob.add_atom_colour(color_filter, WASHABLE_COLOUR_PRIORITY)
		return

	var/mob/living/carbon/exposed_carbon = exposed_mob

	for (var/obj/item/organ/organ as anything in exposed_carbon.organs)
		organ.add_atom_colour(color_filter, WASHABLE_COLOUR_PRIORITY)

	for (var/obj/item/bodypart/part as anything in exposed_carbon.bodyparts)
		part.add_atom_colour(color_filter, WASHABLE_COLOUR_PRIORITY)

/datum/reagent/colorful_reagent/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()

	if (!iscarbon(affected_mob))
		if (can_color_mobs)
			affected_mob.add_atom_colour(color_transition_filter(pick(random_color_list), SATURATION_OVERRIDE), WASHABLE_COLOUR_PRIORITY)
		return

	if(!can_color_organs)
		return

	var/mob/living/carbon/carbon_mob = affected_mob
	var/color_priority = WASHABLE_COLOUR_PRIORITY
	if (current_cycle >= 30) // Seeps deep into your tissues
		color_priority = FIXED_COLOUR_PRIORITY

	for (var/obj/item/organ/organ as anything in carbon_mob.organs)
		organ.add_atom_colour(color_transition_filter(pick(random_color_list), SATURATION_OVERRIDE), color_priority)

/// Colors anything it touches a random color.
/datum/reagent/colorful_reagent/expose_atom(atom/exposed_atom, reac_volume)
	. = ..()
	if(!isliving(exposed_atom))
		exposed_atom.add_atom_colour(color_transition_filter(pick(random_color_list), SATURATION_OVERRIDE), WASHABLE_COLOUR_PRIORITY)

/datum/reagent/hair_dye
	name = "Quantum Hair Dye"
	description = "Has a high chance of making you look like a mad scientist."
	var/list/potential_colors = list("#00aadd","#aa00ff","#ff7733","#dd1144","#dd1144","#00bb55","#00aadd","#ff7733","#ffcc22","#008844","#0055ee","#dd2222","#ffaa00") // fucking hair code
	color = COLOR_GRAY
	taste_description = "sourness"
	penetrates_skin = NONE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/hair_dye/New()
	SSticker.OnRoundstart(CALLBACK(src, PROC_REF(UpdateColor)))
	return ..()

/datum/reagent/hair_dye/proc/UpdateColor()
	color = pick(potential_colors)

/datum/reagent/hair_dye/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message=TRUE, touch_protection = 0)
	. = ..()
	if(!(methods & (TOUCH|VAPOR|INHALE)) || !ishuman(exposed_mob))
		return

	var/exposure_probability = min(100 - (touch_protection * 100), 0, 100)
	if(exposure_probability && !prob(exposure_probability))
		return

	var/mob/living/carbon/human/exposed_human = exposed_mob
	exposed_human.set_facial_haircolor(pick(potential_colors), update = FALSE)
	exposed_human.set_haircolor(pick(potential_colors)) //this will call update_body_parts()

/datum/reagent/barbers_aid
	name = "Barber's Aid"
	description = "A solution to hair loss across the world."
	color = "#A86B45" //hair is brown
	taste_description = "sourness"
	penetrates_skin = NONE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/barbers_aid/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message=TRUE, touch_protection = 0)
	. = ..()
	if(!(methods & (TOUCH|VAPOR)) || !ishuman(exposed_mob) || (HAS_TRAIT(exposed_mob, TRAIT_BALD) && HAS_TRAIT(exposed_mob, TRAIT_SHAVED)))
		return

	var/exposure_probability = min(100 - (touch_protection * 100), 0, 100)
	if(exposure_probability && !prob(exposure_probability))
		return

	var/mob/living/carbon/human/exposed_human = exposed_mob
	if(!HAS_TRAIT(exposed_human, TRAIT_SHAVED))
		var/datum/sprite_accessory/facial_hair/picked_beard = pick(SSaccessories.facial_hairstyles_list)
		exposed_human.set_facial_hairstyle(picked_beard, update = FALSE)
	if(!HAS_TRAIT(exposed_human, TRAIT_BALD))
		var/datum/sprite_accessory/hair/picked_hair = pick(SSaccessories.hairstyles_list)
		exposed_human.set_hairstyle(picked_hair, update = TRUE)
	to_chat(exposed_human, span_notice("Hair starts sprouting from your [HAS_TRAIT(exposed_human, TRAIT_BALD) ? "face" : "scalp"]."))

/datum/reagent/concentrated_barbers_aid
	name = "Concentrated Barber's Aid"
	description = "A concentrated solution to hair loss across the world."
	color = "#7A4E33" //hair is dark browmn
	taste_description = "sourness"
	penetrates_skin = NONE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/concentrated_barbers_aid/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message=TRUE, touch_protection = 0)
	. = ..()
	if(!(methods & (TOUCH|VAPOR)) || !ishuman(exposed_mob) || (HAS_TRAIT(exposed_mob, TRAIT_BALD) && HAS_TRAIT(exposed_mob, TRAIT_SHAVED)))
		return

	var/exposure_probability = min(100 - (touch_protection * 100), 0, 100)
	if(exposure_probability && !prob(exposure_probability))
		return

	var/mob/living/carbon/human/exposed_human = exposed_mob
	if(!HAS_TRAIT(exposed_human, TRAIT_SHAVED))
		exposed_human.set_facial_hairstyle("Beard (Very Long)", update = FALSE)
	if(!HAS_TRAIT(exposed_human, TRAIT_BALD))
		exposed_human.set_hairstyle("Very Long Hair", update = TRUE)
	to_chat(exposed_human, span_notice("Your[HAS_TRAIT(exposed_human, TRAIT_BALD) ? " facial" : ""] hair starts growing at an incredible speed!"))

/datum/reagent/concentrated_barbers_aid/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(current_cycle > 21 / creation_purity)
		if(!ishuman(affected_mob))
			return
		var/mob/living/carbon/human/human_mob = affected_mob
		if(creation_purity == 1 && human_mob.has_quirk(/datum/quirk/item_quirk/bald))
			human_mob.remove_quirk(/datum/quirk/item_quirk/bald)
		var/obj/item/bodypart/head/head = human_mob.get_bodypart(BODY_ZONE_HEAD)
		if(!head || (head.head_flags & HEAD_HAIR))
			return
		head.head_flags |= HEAD_HAIR
		if(HAS_TRAIT(affected_mob, TRAIT_BALD))
			to_chat(affected_mob, span_warning("You feel your scalp mutate, but you are still hopelessly bald."))
		else
			to_chat(affected_mob, span_notice("Your scalp mutates, a full head of hair sprouting from it."))
			human_mob.update_body_parts()

/datum/reagent/baldium
	name = "Baldium"
	description = "A major cause of hair loss across the world."
	color = "#ecb2cf"
	taste_description = "bitterness"
	penetrates_skin = NONE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/baldium/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message=TRUE, touch_protection = 0)
	. = ..()
	if(!(methods & (TOUCH|VAPOR)) || !ishuman(exposed_mob))
		return

	var/exposure_probability = min(100 - (touch_protection * 100), 0, 100)
	if(exposure_probability && !prob(exposure_probability))
		return

	var/mob/living/carbon/human/exposed_human = exposed_mob
	to_chat(exposed_human, span_danger("Your hair is falling out in clumps!"))
	exposed_human.set_facial_hairstyle("Shaved", update = FALSE)
	exposed_human.set_hairstyle("Bald", update = TRUE)

/datum/reagent/saltpetre
	name = "Saltpetre"
	description = "Volatile. Controversial. Third Thing."
	color = "#60A584" // rgb: 96, 165, 132
	taste_description = "cool salt"
	ph = 11.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

// Saltpetre is used for gardening IRL, to simplify highly, it speeds up growth and strengthens plants
/datum/reagent/saltpetre/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_plant_health(round(volume * 0.18))
	mytray.myseed?.adjust_production(-round(volume / 10)-prob(volume % 10))
	mytray.myseed?.adjust_potency(round(volume))

/datum/reagent/lye
	name = "Lye"
	description = "Also known as sodium hydroxide. As a profession making this is somewhat underwhelming."
	color = "#FFFFD6" // very very light yellow
	taste_description = "acid"
	ph = 11.9
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/drying_agent
	name = "Drying Agent"
	description = "A desiccant. Can be used to dry things."
	color = "#A70FFF"
	taste_description = "dryness"
	ph = 10.7
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/drying_agent/expose_turf(turf/open/exposed_turf, reac_volume)
	. = ..()
	if(!istype(exposed_turf))
		return
	// We want one spray of this stuff (5u) to take out a wet floor. Feels better that way
	exposed_turf.MakeDry(ALL, TRUE, reac_volume * 10 SECONDS)

/datum/reagent/drying_agent/expose_obj(obj/exposed_obj, reac_volume, methods=TOUCH, show_message=TRUE)
	. = ..()
	if(exposed_obj.type != /obj/item/clothing/shoes/galoshes)
		return
	var/t_loc = get_turf(exposed_obj)
	qdel(exposed_obj)
	new /obj/item/clothing/shoes/galoshes/dry(t_loc)

// Virology virus food chems.

/datum/reagent/toxin/mutagen/mutagenvirusfood
	name = "Mutagenic Agar"
	color = "#A3C00F" // rgb: 163,192,15
	taste_description = "sourness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/toxin/mutagen/mutagenvirusfood/sugar
	name = "Sucrose Agar"
	color = "#41B0C0" // rgb: 65,176,192
	taste_description = "sweetness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/medicine/synaptizine/synaptizinevirusfood
	name = "Virus Rations"
	color = "#D18AA5" // rgb: 209,138,165
	taste_description = "bitterness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/toxin/plasma/plasmavirusfood
	name = "Virus Plasma"
	color = "#A270A8" // rgb: 166,157,169
	taste_description = "bitterness"
	taste_mult = 1.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/toxin/plasma/plasmavirusfood/weak
	name = "Weakened Virus Plasma"
	color = "#A28CA5" // rgb: 206,195,198
	taste_description = "bitterness"
	taste_mult = 1.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/uranium/uraniumvirusfood
	name = "Decaying Uranium Gel"
	color = "#67ADBA" // rgb: 103,173,186
	taste_description = "the inside of a reactor"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/uranium/uraniumvirusfood/unstable
	name = "Unstable Uranium Gel"
	color = "#2FF2CB" // rgb: 47,242,203
	taste_description = "the inside of a reactor"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/uranium/uraniumvirusfood/stable
	name = "Stable Uranium Gel"
	color = "#04506C" // rgb: 4,80,108
	taste_description = "the inside of a reactor"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

// Bee chemicals

/datum/reagent/royal_bee_jelly
	name = "Royal Bee Jelly"
	description = "Royal Bee Jelly, if injected into a Queen Space Bee said bee will split into two bees."
	color = "#00ff80"
	taste_description = "strange honey"
	ph = 3
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/royal_bee_jelly/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(SPT_PROB(1, seconds_per_tick))
		affected_mob.say(pick("Bzzz...","BZZ BZZ","Bzzzzzzzzzzz..."), forced = "royal bee jelly")

//Misc reagents

/datum/reagent/romerol
	name = "Romerol"
	// the REAL zombie powder
	description = "Romerol is a highly experimental bioterror agent \
		which causes dormant nodules to be etched into the grey matter of \
		the subject. These nodules only become active upon death of the \
		host, upon which, the secondary structures activate and take control \
		of the host body."
	color = "#123524" // RGB (18, 53, 36)
	metabolization_rate = INFINITY
	taste_description = "brains"
	ph = 0.5

/datum/reagent/romerol/expose_mob(mob/living/carbon/human/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	// Silently add the zombie infection organ to be activated upon death
	if(exposed_mob.get_organ_slot(ORGAN_SLOT_ZOMBIE))
		return

	if((methods & (PATCH|INGEST|INJECT|INHALE)) || ((methods & (VAPOR|TOUCH)) && prob(min(reac_volume,100)*(1 - touch_protection))))
		var/obj/item/organ/zombie_infection/nodamage/zombie_infection = new()
		zombie_infection.Insert(exposed_mob)

/datum/reagent/magillitis
	name = "Magillitis"
	description = "An experimental serum which causes rapid muscular growth in Hominidae. Side effects may include hypertrichosis, violent outbursts, and an unending affinity for bananas."
	color = "#00f041"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/magillitis/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if((ishuman(affected_mob)) && current_cycle > 10)
		var/mob/living/basic/gorilla/new_gorilla = affected_mob.gorillize()
		new_gorilla.AddComponent(/datum/component/regenerator, regeneration_delay = 12 SECONDS, brute_per_second = 1.5, outline_colour = COLOR_PALE_GREEN)

/datum/reagent/growthserum
	name = "Growth Serum"
	description = "A commercial chemical designed to help older men in the bedroom."//not really it just makes you a giant
	color = "#ff0000"//strong red. rgb 255, 0, 0
	var/current_size = RESIZE_DEFAULT_SIZE
	taste_description = "bitterness" // apparently what viagra tastes like
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/growthserum/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/newsize = current_size
	switch(volume)
		if(0 to 19)
			newsize = 1.25*RESIZE_DEFAULT_SIZE
		if(20 to 49)
			newsize = 1.5*RESIZE_DEFAULT_SIZE
		if(50 to 99)
			newsize = 2*RESIZE_DEFAULT_SIZE
		if(100 to 199)
			newsize = 2.5*RESIZE_DEFAULT_SIZE
		if(200 to INFINITY)
			newsize = 3.5*RESIZE_DEFAULT_SIZE

	affected_mob.update_transform(newsize/current_size)
	current_size = newsize

/datum/reagent/growthserum/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.update_transform(RESIZE_DEFAULT_SIZE/current_size)
	current_size = RESIZE_DEFAULT_SIZE

/datum/reagent/growthserum/used_on_fish(obj/item/fish/fish)
	ADD_TRAIT(fish, TRAIT_FISH_QUICK_GROWTH, type)
	addtimer(TRAIT_CALLBACK_REMOVE(fish, TRAIT_FISH_QUICK_GROWTH, type), fish.feeding_frequency * 0.8, TIMER_UNIQUE|TIMER_OVERRIDE)
	return TRUE

/datum/reagent/plastic_polymers
	name = "Plastic Polymers"
	description = "the petroleum based components of plastic."
	color = "#f7eded"
	taste_description = "plastic"
	ph = 6
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/glitter
	name = "Generic Glitter"
	description = "if you can see this description, contact a coder."
	color = COLOR_WHITE //pure white
	taste_description = "plastic"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	var/glitter_type = /obj/effect/decal/cleanable/glitter

/datum/reagent/glitter/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(!istype(exposed_turf))
		return
	exposed_turf.spawn_unique_cleanable(glitter_type)

/datum/reagent/glitter/pink
	name = "Pink Glitter"
	description = "pink sparkles that get everywhere"
	color = "#ff8080" //A light pink color
	glitter_type = /obj/effect/decal/cleanable/glitter/pink
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/glitter/white
	name = "White Glitter"
	description = "white sparkles that get everywhere"
	glitter_type = /obj/effect/decal/cleanable/glitter/white
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/glitter/blue
	name = "Blue Glitter"
	description = "blue sparkles that get everywhere"
	color = "#4040FF" //A blueish color
	glitter_type = /obj/effect/decal/cleanable/glitter/blue
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/glitter/confetti
	name = "Confetti"
	description = "Tiny plastic flakes that are impossible to sweep up."
	color = "#7dd87b"
	glitter_type = /obj/effect/decal/cleanable/confetti
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/pax
	name = "Pax"
	description = "A colorless liquid that suppresses violence in its subjects."
	color = "#AAAAAA55"
	taste_description = "water"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	ph = 15
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	metabolized_traits = list(TRAIT_PACIFISM)

/datum/reagent/bz_metabolites
	name = "BZ Metabolites"
	description = "A harmless metabolite of BZ gas."
	color = "#FAFF00"
	taste_description = "acrid cinnamon"
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE
	metabolized_traits = list(TRAIT_CHANGELING_HIVEMIND_MUTE)

/datum/reagent/bz_metabolites/on_mob_life(mob/living/carbon/target, seconds_per_tick, times_fired)
	. = ..()
	target.adjust_hallucinations(5 SECONDS * REM * seconds_per_tick)
	var/datum/antagonist/changeling/changeling = IS_CHANGELING(target)
	changeling?.adjust_chemicals(-2 * REM * seconds_per_tick)

/datum/reagent/pax/peaceborg
	name = "Synthpax"
	description = "A colorless liquid that suppresses violence in its subjects. Cheaper to synthesize than normal Pax, but wears off faster."
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/peaceborg/confuse
	name = "Dizzying Solution"
	description = "Makes the target off balance and dizzy"
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "dizziness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/peaceborg/confuse/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	affected_mob.adjust_confusion_up_to(3 SECONDS * REM * seconds_per_tick, 5 SECONDS)
	affected_mob.adjust_dizzy_up_to(6 SECONDS * REM * seconds_per_tick, 12 SECONDS)

	if(SPT_PROB(10, seconds_per_tick))
		to_chat(affected_mob, "You feel confused and disoriented.")

/datum/reagent/peaceborg/tire
	name = "Tiring Solution"
	description = "An extremely weak stamina-toxin that tires out the target. Completely harmless."
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "tiredness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/peaceborg/tire/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/healthcomp = (100 - affected_mob.health) //DOES NOT ACCOUNT FOR ADMINBUS THINGS THAT MAKE YOU HAVE MORE THAN 200/210 HEALTH, OR SOMETHING OTHER THAN A HUMAN PROCESSING THIS.
	. = FALSE
	if(affected_mob.getStaminaLoss() < (45 - healthcomp)) //At 50 health you would have 200 - 150 health meaning 50 compensation. 60 - 50 = 10, so would only do 10-19 stamina.)
		if(affected_mob.adjustStaminaLoss(10 * REM * seconds_per_tick, updating_stamina = FALSE))
			. = UPDATE_MOB_HEALTH
	if(SPT_PROB(16, seconds_per_tick))
		to_chat(affected_mob, "You should sit down and take a rest...")

/datum/reagent/gondola_mutation_toxin
	name = "Tranquility"
	description = "A highly mutative liquid of unknown origin."
	color = "#9A6750" //RGB: 154, 103, 80
	taste_description = "inner peace"
	penetrates_skin = NONE
	var/datum/disease/transformation/gondola_disease = /datum/disease/transformation/gondola

/datum/reagent/gondola_mutation_toxin/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if((methods & (PATCH|INGEST|INJECT|INHALE)) || ((methods & (VAPOR|TOUCH)) && prob(min(reac_volume,100)*(1 - touch_protection))))
		exposed_mob.ForceContractDisease(new gondola_disease, FALSE, TRUE)

/datum/reagent/spider_extract
	name = "Spider Extract"
	description = "A highly specialized extract coming from the Australicus sector, used to create broodmother spiders."
	color = "#ED2939"
	taste_description = "upside down"

/// Improvised reagent that induces vomiting. Created by dipping a dead mouse in welder fluid.
/datum/reagent/yuck
	name = "Organic Slurry"
	description = "A mixture of various colors of fluid. Induces vomiting."
	color = "#545000"
	taste_description = "insides"
	taste_mult = 4
	metabolization_rate = 0.4 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	var/yuck_cycle = 0 //! The `current_cycle` when puking starts.

/datum/glass_style/drinking_glass/yuck
	required_drink_type = /datum/reagent/yuck
	name = "glass of ...yuck!"
	desc = "It smells like a carcass, and doesn't look much better."

/datum/reagent/yuck/on_mob_add(mob/living/affected_mob)
	if(HAS_TRAIT(affected_mob, TRAIT_NOHUNGER)) //they can't puke
		holder.del_reagent(type)
	return ..()

#define YUCK_PUKE_CYCLES 3 // every X cycle is a puke
#define YUCK_PUKES_TO_STUN 3 // hit this amount of pukes in a row to start stunning
/datum/reagent/yuck/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(!yuck_cycle)
		if(SPT_PROB(4, seconds_per_tick))
			var/dread = pick("Something is moving in your stomach...", \
				"A wet growl echoes from your stomach...", \
				"For a moment you feel like your surroundings are moving, but it's your stomach...")
			to_chat(affected_mob, span_userdanger("[dread]"))
			yuck_cycle = current_cycle
	else
		var/yuck_cycles = current_cycle - yuck_cycle
		if(yuck_cycles % YUCK_PUKE_CYCLES == 0)
			if(yuck_cycles >= YUCK_PUKE_CYCLES * YUCK_PUKES_TO_STUN)
				if(holder)
					holder.remove_reagent(type, 5)
			var/passable_flags = (MOB_VOMIT_MESSAGE | MOB_VOMIT_HARM)
			if(yuck_cycles >= (YUCK_PUKE_CYCLES * YUCK_PUKES_TO_STUN))
				passable_flags |= MOB_VOMIT_STUN
			affected_mob.vomit(vomit_flags = passable_flags, lost_nutrition = rand(14, 26))

#undef YUCK_PUKE_CYCLES
#undef YUCK_PUKES_TO_STUN

/datum/reagent/yuck/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	yuck_cycle = 0 // reset vomiting

/datum/reagent/yuck/on_transfer(atom/A, methods=TOUCH, trans_volume)
	if((methods & INGEST) || !iscarbon(A))
		return ..()

	A.reagents.remove_reagent(type, trans_volume)
	A.reagents.add_reagent(/datum/reagent/fuel, trans_volume * 0.75)
	A.reagents.add_reagent(/datum/reagent/water, trans_volume * 0.25)

	return ..()

//monkey powder heehoo
/datum/reagent/monkey_powder
	name = "Monkey Powder"
	description = "Just add water!"
	color = "#9C5A19"
	taste_description = "bananas"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/plasma_oxide
	name = "Hyper-Plasmium Oxide"
	description = "Compound created deep in the cores of demon-class planets. Commonly found through deep geysers."
	color = "#470750" // rgb: 255, 255, 255
	taste_description = "hell"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/exotic_stabilizer
	name = "Exotic Stabilizer"
	description = "Advanced compound created by mixing stabilizing agent and hyper-plasmium oxide."
	color = "#180000" // rgb: 255, 255, 255
	taste_description = "blood"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/wittel
	name = "Wittel"
	description = "An extremely rare metallic-white substance only found on demon-class planets."
	color = COLOR_WHITE // rgb: 255, 255, 255
	taste_mult = 0 // oderless and tasteless
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/metalgen
	name = "Metalgen"
	data = list("material"=null)
	description = "A purple metal morphic liquid, said to impose its metallic properties on whatever it touches."
	color = "#b000aa"
	taste_mult = 0 // oderless and tasteless
	chemical_flags = REAGENT_NO_RANDOM_RECIPE
	/// The material flags used to apply the transmuted materials
	var/applied_material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	/// The amount of materials to apply to the transmuted objects if they don't contain materials
	var/default_material_amount = 100

/datum/reagent/metalgen/expose_obj(obj/exposed_obj, reac_volume, methods=TOUCH, show_message=TRUE)
	. = ..()
	metal_morph(exposed_obj)

/datum/reagent/metalgen/expose_turf(turf/exposed_turf, volume)
	. = ..()
	metal_morph(exposed_turf)

///turn an object into a special material
/datum/reagent/metalgen/proc/metal_morph(atom/target)
	var/metal_ref = data["material"]
	if(!metal_ref)
		return

	if(is_type_in_typecache(target, GLOB.blacklisted_metalgen_types)) //some stuff can lead to exploits if transmuted
		return

	var/metal_amount = 0
	var/list/materials_to_transmute = target.get_material_composition()
	for(var/metal_key in materials_to_transmute) //list with what they're made of
		metal_amount += materials_to_transmute[metal_key]

	if(!metal_amount)
		metal_amount = default_material_amount //some stuff doesn't have materials at all. To still give them properties, we give them a material. Basically doesn't exist

	var/list/metal_dat = list((metal_ref) = metal_amount)
	target.material_flags = applied_material_flags
	target.set_custom_materials(metal_dat)

/datum/reagent/gravitum
	name = "Gravitum"
	description = "A rare kind of null fluid, capable of temporarily removing all weight of whatever it touches." //i dont even
	color = "#050096" // rgb: 5, 0, 150
	taste_mult = 0 // oderless and tasteless
	metabolization_rate = 0.1 * REAGENTS_METABOLISM //20 times as long, so it's actually viable to use
	var/time_multiplier = 1 MINUTES //1 minute per unit of gravitum on objects. Seems overpowered, but the whole thing is very niche
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	self_consuming = TRUE //this works on objects, so it should work on skeletons and robots too

/datum/reagent/gravitum/expose_obj(obj/exposed_obj, reac_volume, methods=TOUCH, show_message=TRUE)
	. = ..()
	exposed_obj.AddElement(/datum/element/forced_gravity, 0)
	addtimer(CALLBACK(exposed_obj, PROC_REF(_RemoveElement), list(/datum/element/forced_gravity, 0)), volume * time_multiplier, TIMER_UNIQUE|TIMER_OVERRIDE)

/datum/reagent/gravitum/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.AddElement(/datum/element/forced_gravity, 0) //0 is the gravity, and in this case weightless

/datum/reagent/gravitum/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.RemoveElement(/datum/element/forced_gravity, 0)

/datum/reagent/cellulose
	name = "Cellulose Fibers"
	description = "A crystalline polydextrose polymer, plants swear by this stuff."
	color = "#E6E6DA"
	taste_mult = 0
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

// "Second wind" reagent generated when someone suffers a wound. Epinephrine, adrenaline, and stimulants are all already taken so here we are
/datum/reagent/determination
	name = "Determination"
	description = "For when you need to push on a little more. Do NOT allow near plants."
	color = "#D2FFFA"
	metabolization_rate = 0.75 * REAGENTS_METABOLISM // 5u (WOUND_DETERMINATION_CRITICAL) will last for ~34 seconds
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	self_consuming = TRUE
	metabolized_traits = list(TRAIT_ANALGESIA)
	/// Whether we've had at least WOUND_DETERMINATION_SEVERE (2.5u) of determination at any given time. No damage slowdown immunity or indication we're having a second wind if it's just a single moderate wound
	var/significant = FALSE

/datum/reagent/determination/on_mob_end_metabolize(mob/living/carbon/affected_mob)
	. = ..()
	if(significant)
		var/stam_crash = 0
		for(var/thing in affected_mob.all_wounds)
			var/datum/wound/W = thing
			stam_crash += (W.severity + 1) * 3 // spike of 3 stam damage per wound severity (moderate = 6, severe = 9, critical = 12) when the determination wears off if it was a combat rush
		affected_mob.adjustStaminaLoss(stam_crash)
	affected_mob.remove_status_effect(/datum/status_effect/determined)

/datum/reagent/determination/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(!significant && volume >= WOUND_DETERMINATION_SEVERE)
		significant = TRUE
		affected_mob.apply_status_effect(/datum/status_effect/determined) // in addition to the slight healing, limping cooldowns are divided by 4 during the combat high

	volume = min(volume, WOUND_DETERMINATION_MAX)

	for(var/thing in affected_mob.all_wounds)
		var/datum/wound/W = thing
		var/obj/item/bodypart/wounded_part = W.limb
		if(wounded_part)
			wounded_part.heal_damage(0.25 * REM * seconds_per_tick, 0.25 * REM * seconds_per_tick)
		if(affected_mob.adjustStaminaLoss(-1 * REM * seconds_per_tick, updating_stamina = FALSE)) // the more wounds, the more stamina regen
			return UPDATE_MOB_HEALTH

// unholy water, but for heretics.
// why couldn't they have both just used the same reagent?
// who knows.
// maybe nar'sie is considered to be too "mainstream" of a god to worship in the heretic community.
/datum/reagent/eldritch
	name = "Eldritch Essence"
	description = "A strange liquid that defies the laws of physics. \
		It re-energizes and heals those who can see beyond this fragile reality, \
		but is incredibly harmful to the closed-minded. It metabolizes very quickly."
	taste_description = "Ag'hsj'saje'sh"
	self_consuming = TRUE //eldritch intervention won't be limited by the lack of a liver
	color = "#1f8016"
	metabolization_rate = 2.5 * REAGENTS_METABOLISM  //0.5u/second
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/eldritch/on_mob_life(mob/living/carbon/drinker, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update = FALSE
	if(IS_HERETIC_OR_MONSTER(drinker))
		drinker.adjust_drowsiness(-10 * REM * seconds_per_tick)
		drinker.AdjustAllImmobility(-40 * REM * seconds_per_tick)
		need_mob_update += drinker.adjustStaminaLoss(-10 * REM * seconds_per_tick, updating_stamina = FALSE)
		need_mob_update += drinker.adjustToxLoss(-2 * REM * seconds_per_tick, updating_health = FALSE, forced = TRUE)
		need_mob_update += drinker.adjustOxyLoss(-2 * REM * seconds_per_tick, updating_health = FALSE)
		need_mob_update += drinker.adjustBruteLoss(-2 * REM * seconds_per_tick, updating_health = FALSE)
		need_mob_update += drinker.adjustFireLoss(-2 * REM * seconds_per_tick, updating_health = FALSE)
		if(drinker.blood_volume < BLOOD_VOLUME_NORMAL)
			drinker.blood_volume += 3 * REM * seconds_per_tick
	else
		need_mob_update = drinker.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3 * REM * seconds_per_tick, 150)
		need_mob_update += drinker.adjustToxLoss(2 * REM * seconds_per_tick, updating_health = FALSE)
		need_mob_update += drinker.adjustFireLoss(2 * REM * seconds_per_tick, updating_health = FALSE)
		need_mob_update += drinker.adjustOxyLoss(2 * REM * seconds_per_tick, updating_health = FALSE)
		need_mob_update += drinker.adjustBruteLoss(2 * REM * seconds_per_tick, updating_health = FALSE)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/eldritch/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if ((reac_volume >= 1.5 || isplatingturf(exposed_turf)) && !HAS_TRAIT(exposed_turf, TRAIT_RUSTY))
		exposed_turf.rust_turf()

/datum/reagent/universal_indicator
	name = "Universal Indicator"
	description = "A solution that can be used to create pH paper booklets, or sprayed on things to colour them by their pH."
	taste_description = "a strong chemical taste"
	color = "#1f8016"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

//Colours things by their pH
/datum/reagent/universal_indicator/expose_atom(atom/exposed_atom, reac_volume)
	. = ..()
	if(exposed_atom.reagents)
		var/color
		CONVERT_PH_TO_COLOR(exposed_atom.reagents.ph, color)
		exposed_atom.add_atom_colour(color, WASHABLE_COLOUR_PRIORITY)

// [Original ants concept by Keelin on Goon]
/datum/reagent/ants
	name = "Ants"
	description = "A genetic crossbreed between ants and termites, their bites land at a 3 on the Schmidt Pain Scale."
	color = "#993333"
	taste_mult = 1.3
	taste_description = "tiny legs scuttling down the back of your throat"
	metabolization_rate = 5 * REAGENTS_METABOLISM //1u per second
	ph = 4.6 // Ants contain Formic Acid
	/// Number of ticks the ants have been in the person's body
	var/ant_ticks = 0
	/// Amount of damage done per tick the ants have been in the person's system
	var/ant_damage = 0.025
	/// Tells the debuff how many ants we are being covered with.
	var/amount_left = 0
	/// Decal to spawn when spilled
	var/ants_decal = /obj/effect/decal/cleanable/ants
	/// Status effect applied by splashing ants
	var/status_effect = /datum/status_effect/ants
	/// List of possible common statements to scream when eating ants
	var/static/list/ant_screams = list(
		"THEY'RE UNDER MY SKIN!!",
		"GET THEM OUT OF ME!!",
		"HOLY HELL THEY BURN!!",
		"MY GOD THEY'RE INSIDE ME!!",
		"GET THEM OUT!!",
	)

/datum/glass_style/drinking_glass/ants
	required_drink_type = /datum/reagent/ants
	name = "glass of ants"
	desc = "Bottoms up...?"

/datum/reagent/ants/on_mob_life(mob/living/carbon/victim, seconds_per_tick)
	. = ..()
	victim.adjustBruteLoss(max(0.1, round((ant_ticks * ant_damage),0.1))) //Scales with time. Roughly 32 brute with 100u.
	ant_ticks++
	if(ant_ticks < 5) // Makes ant food a little more appetizing, since you won't be screaming as much.
		return
	if(SPT_PROB(5, seconds_per_tick))
		if(SPT_PROB(5, seconds_per_tick)) //Super rare statement
			victim.say("AUGH NO NOT THE ANTS! NOT THE ANTS! AAAAUUGH THEY'RE IN MY EYES! MY EYES! AUUGH!!", forced = type)
		else
			victim.say(pick(ant_screams), forced = type)
	if(SPT_PROB(15, seconds_per_tick))
		victim.painful_scream() // DOPPLER EDIT: check for painkilling before screaming
	if(SPT_PROB(2, seconds_per_tick)) // Stuns, but purges ants.
		victim.vomit(VOMIT_CATEGORY_DEFAULT, lost_nutrition = rand(5,10), purge_ratio = 1)

/datum/reagent/ants/on_mob_end_metabolize(mob/living/living_anthill)
	. = ..()
	ant_ticks = 0
	to_chat(living_anthill, span_notice("You feel like the last of \the [src] are out of your system."))

/datum/reagent/ants/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if(!iscarbon(exposed_mob))
		return
	if(methods & INGEST)
		exposed_mob.check_allergic_reaction(BUGS, chance = reac_volume * 10, histamine_add = min(10, reac_volume))
	if(!(methods & (PATCH|TOUCH|VAPOR)))
		return

	amount_left = round(reac_volume,0.1) * (1 - touch_protection)
	if(amount_left)
		exposed_mob.apply_status_effect(status_effect, amount_left)

/datum/reagent/ants/expose_obj(obj/exposed_obj, reac_volume, methods=TOUCH, show_message=TRUE)
	. = ..()
	var/turf/open/my_turf = exposed_obj.loc // No dumping ants on an object in a storage slot
	if(!istype(my_turf)) //Are we actually in an open turf?
		return
	var/static/list/accepted_types = typecacheof(list(/obj/machinery/atmospherics, /obj/structure/cable, /obj/structure/disposalpipe))
	if(!accepted_types[exposed_obj.type]) // Bypasses pipes, vents, and cables to let people create ant mounds on top easily.
		return
	expose_turf(my_turf, reac_volume)

/datum/reagent/ants/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(!istype(exposed_turf)) // Is the turf valid
		return
	if((reac_volume <= 10)) // Makes sure people don't duplicate ants.
		return

	var/obj/effect/decal/cleanable/ants/pests = exposed_turf.spawn_unique_cleanable(ants_decal)
	if(!pests)
		return

	var/spilled_ants = (round(reac_volume,1) - 5) // To account for ant decals giving 3-5 ants on initialize.
	pests.reagents.add_reagent(type, spilled_ants)
	pests.update_ant_damage()

/datum/reagent/ants/fire
	name = "Fire ants"
	description = "A rare mutation of space ants, born from the heat of a plasma fire. Their bites land a 3.7 on the Schmidt Pain Scale."
	color = "#b51f1f"
	taste_description = "tiny flaming legs scuttling down the back of your throat"
	ant_damage = 0.05 // Roughly 64 brute with 100u
	ants_decal = /obj/effect/decal/cleanable/ants/fire
	status_effect = /datum/status_effect/ants/fire

/datum/glass_style/drinking_glass/fire_ants
	required_drink_type = /datum/reagent/ants/fire
	name = "glass of fire ants"
	desc = "This is a terrible idea."

//This is intended to a be a scarce reagent to gate certain drugs and toxins with. Do not put in a synthesizer. Renewable sources of this reagent should be inefficient.
/datum/reagent/lead
	name = "Lead"
	description = "A dull metallic element with a low melting point."
	taste_description = "metal"
	color = "#80919d"
	metabolization_rate = 0.4 * REAGENTS_METABOLISM

/datum/reagent/lead/on_mob_life(mob/living/carbon/victim)
	. = ..()
	if(victim.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.5))
		return UPDATE_MOB_HEALTH

//The main feedstock for kronkaine production, also a shitty stamina healer.
/datum/reagent/kronkus_extract
	name = "Kronkus Extract"
	description = "A frothy extract made from fermented kronkus vine pulp.\nHighly bitter due to the presence of a variety of kronkamines."
	taste_description = "bitterness"
	color = "#228f63"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/stimulants = 5)

/datum/reagent/kronkus_extract/on_mob_life(mob/living/carbon/kronkus_enjoyer, seconds_per_tick)
	. = ..()
	var/need_mob_update
	need_mob_update = kronkus_enjoyer.adjustOrganLoss(ORGAN_SLOT_HEART, 0.2 * REM * seconds_per_tick, required_organ_flag = affected_organ_flags)
	need_mob_update += kronkus_enjoyer.adjustStaminaLoss(-6, updating_stamina = FALSE)
	if(need_mob_update)
		return UPDATE_MOB_HEALTH

/datum/reagent/brimdust
	name = "Brimdust"
	description = "A brimdemon's dust. Consumption is not recommended, although plants like it."
	color = "#522546"
	taste_description = "burning"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/brimdust/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.adjustFireLoss((ispodperson(affected_mob) ? -1 : 1 * seconds_per_tick), updating_health = FALSE))
		return UPDATE_MOB_HEALTH

/datum/reagent/brimdust/on_hydroponics_apply(obj/machinery/hydroponics/mytray, mob/user)
	mytray.adjust_weedlevel(-1)
	mytray.adjust_pestlevel(-1)
	mytray.adjust_plant_health(round(volume))
	mytray.myseed?.adjust_potency(round(volume * 0.5))

// I made this food....with love.
// Reagent added to food by chef's with a chef's kiss. Makes people happy.
/datum/reagent/love
	name = "Love"
	description = "This food's been made... with love."
	color = "#ff7edd"
	taste_description = "love"
	taste_mult = 10
	overdose_threshold = 50 // too much love is a bad thing

/datum/reagent/love/expose_mob(mob/living/exposed_mob, methods, reac_volume, show_message, touch_protection)
	. = ..()
	// A syringe is not grandma's cooking
	if(methods & ~INGEST)
		exposed_mob.reagents.del_reagent(type)

/datum/reagent/love/on_mob_metabolize(mob/living/metabolizer)
	. = ..()
	metabolizer.add_mood_event(name, /datum/mood_event/love_reagent)

/datum/reagent/love/on_mob_delete(mob/living/affected_mob)
	. = ..()
	// When we exit the system we'll leave the moodlet based on the amount we had
	var/duration_of_moodlet = current_cycle * 20 SECONDS
	affected_mob.clear_mood_event(name)
	affected_mob.add_mood_event(name, /datum/mood_event/love_reagent, duration_of_moodlet)

/datum/reagent/love/overdose_process(mob/living/metabolizer, seconds_per_tick, times_fired)
	. = ..()
	var/mob/living/carbon/carbon_metabolizer = metabolizer
	if(!istype(carbon_metabolizer) || !carbon_metabolizer.can_heartattack() || carbon_metabolizer.undergoing_cardiac_arrest())
		metabolizer.reagents.del_reagent(type)
		return

	if(SPT_PROB(10, seconds_per_tick))
		carbon_metabolizer.set_heartattack(TRUE)

/datum/reagent/hauntium
	name = "Hauntium"
	color = "#3B3B3BA3"
	description = "An eerie liquid created by purifying the presence of ghosts. If it happens to get in your body, it starts hurting your soul." //soul as in mood and heart
	taste_description = "evil spirits"
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	material = /datum/material/hauntium
	ph = 10
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

//gives 20 seconds of haunting effect for every unit of it that touches an object
/datum/reagent/hauntium/expose_obj(obj/exposed_obj, reac_volume, methods=TOUCH, show_message=TRUE)
	. = ..()
	if(!isitem(exposed_obj))
		return
	if(HAS_TRAIT_FROM(exposed_obj, TRAIT_HAUNTED, HAUNTIUM_REAGENT_TRAIT))
		return
	exposed_obj.make_haunted(HAUNTIUM_REAGENT_TRAIT, "#f8f8ff")
	addtimer(CALLBACK(exposed_obj, TYPE_PROC_REF(/atom/movable/, remove_haunted), HAUNTIUM_REAGENT_TRAIT), reac_volume * 20 SECONDS)

/datum/reagent/hauntium/on_mob_metabolize(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	to_chat(affected_mob, span_userdanger("You feel an evil presence inside you!"))
	if(affected_mob.mob_biotypes & MOB_UNDEAD || HAS_MIND_TRAIT(affected_mob, TRAIT_MORBID))
		affected_mob.add_mood_event("morbid_hauntium", /datum/mood_event/morbid_hauntium, name) //8 minutes of slight mood buff if undead or morbid
	else
		affected_mob.add_mood_event("hauntium_spirits", /datum/mood_event/hauntium_spirits, name) //8 minutes of mood debuff

/datum/reagent/hauntium/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(affected_mob.mob_biotypes & MOB_UNDEAD || HAS_MIND_TRAIT(affected_mob, TRAIT_MORBID)) //if morbid or undead,acts like an addiction-less drug
		affected_mob.remove_status_effect(/datum/status_effect/jitter)
		affected_mob.AdjustStun(-5 SECONDS * REM * seconds_per_tick)
		affected_mob.AdjustKnockdown(-5 SECONDS * REM * seconds_per_tick)
		affected_mob.AdjustUnconscious(-5 SECONDS * REM * seconds_per_tick)
		affected_mob.AdjustParalyzed(-5 SECONDS * REM * seconds_per_tick)
		affected_mob.AdjustImmobilized(-5 SECONDS * REM * seconds_per_tick)
	else
		if(affected_mob.adjustOrganLoss(ORGAN_SLOT_HEART, REM * seconds_per_tick)) //1 heart damage per tick
			. = UPDATE_MOB_HEALTH
		if(SPT_PROB(10, seconds_per_tick))
			affected_mob.emote(pick("twitch","choke","shiver","gag"))

// The same as gold just with a slower metabolism rate, to make using the Hand of Midas easier.
/datum/reagent/gold/cursed
	name = "Cursed Gold"
	metabolization_rate = 0.2 * REAGENTS_METABOLISM

/datum/reagent/luminescent_fluid
	name = "Green Luminiscent Fluid"
	description = "A colored fluid that produces light as a result of a chemical reaction with oxygen." // Reacts with oxygen in hydrogen peroxide IRL
	taste_description = "buttery acid" // Best way I can describe glowstick fluid's taste
	color = LIGHT_COLOR_GREEN
	metabolization_rate = 0.3 * REAGENTS_METABOLISM
	ph = 3
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	overdose_threshold = 50 // GLOW GLOW GLOW
	metabolized_traits = list(TRAIT_MINOR_NIGHT_VISION)
	self_consuming = TRUE
	/// Fake flashlight we're using to make owner's eyes glow
	var/obj/item/flashlight/eyelight/glow/glowing
	/// Previous overlay_ignore_lighting of owner's eyes
	var/prev_ignore_lighting
	/// Have we added a flashlight already and it got destroyed by something?
	var/added_light = FALSE

/datum/reagent/luminescent_fluid/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	if (volume > 20) // Even if you don't have eyes, your eyeholes still glow :)
		glowing = new(affected_mob)
		glowing.set_light_color(color)
		glowing.set_light_on(TRUE)
		added_light = TRUE

	if (!ishuman(affected_mob))
		return

	var/mob/living/carbon/human/affected_human = affected_mob
	affected_human.add_eye_color(color, EYE_COLOR_LUMINESCENT_PRIORITY)
	RegisterSignal(affected_human, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(on_organ_added))
	RegisterSignal(affected_human, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_organ_removed))
	var/obj/item/organ/eyes/eyes = affected_human.get_organ_slot(ORGAN_SLOT_EYES)
	if (eyes && !IS_ROBOTIC_ORGAN(eyes))
		prev_ignore_lighting = eyes.overlay_ignore_lighting
		eyes.overlay_ignore_lighting = TRUE

/datum/reagent/luminescent_fluid/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	QDEL_NULL(glowing)
	if (!ishuman(affected_mob))
		return

	var/mob/living/carbon/human/affected_human = affected_mob
	affected_human.remove_eye_color(EYE_COLOR_LUMINESCENT_PRIORITY)
	var/obj/item/organ/eyes/eyes = affected_human.get_organ_slot(ORGAN_SLOT_EYES)
	if (eyes && !IS_ROBOTIC_ORGAN(eyes) && !overdosed)
		eyes.overlay_ignore_lighting = prev_ignore_lighting

/datum/reagent/luminescent_fluid/on_mob_life(mob/living/affected_mob, seconds_per_tick, times_fired)
	. = ..()

	if (isnull(glowing) && !added_light && volume > 20)
		glowing = new(affected_mob)
		glowing.set_light_color(color)
		glowing.set_light_on(TRUE)
		added_light = TRUE

	if (SPT_PROB(8, seconds_per_tick))
		if(affected_mob.adjustToxLoss(1, updating_health = FALSE))
			return UPDATE_MOB_HEALTH

/datum/reagent/luminescent_fluid/proc/on_organ_added(mob/living/source, obj/item/organ/eyes/new_eyes)
	SIGNAL_HANDLER

	if (istype(new_eyes) && !IS_ROBOTIC_ORGAN(new_eyes))
		prev_ignore_lighting = new_eyes.overlay_ignore_lighting
		new_eyes.overlay_ignore_lighting = TRUE

/datum/reagent/luminescent_fluid/proc/on_organ_removed(mob/living/source, obj/item/organ/eyes/old_eyes)
	SIGNAL_HANDLER

	if (istype(old_eyes) && !IS_ROBOTIC_ORGAN(old_eyes) && !overdosed)
		old_eyes.overlay_ignore_lighting = prev_ignore_lighting

/datum/reagent/luminescent_fluid/overdose_start(mob/living/affected_mob)
	. = ..()
	if (!ishuman(affected_mob))
		return
	var/mob/living/carbon/human/affected_human = affected_mob
	var/obj/item/organ/eyes/eyes = affected_human.get_organ_slot(ORGAN_SLOT_EYES)
	if (eyes && !IS_ROBOTIC_ORGAN(eyes))
		eyes.eye_color_left = color
		eyes.eye_color_right = color
		affected_human.update_body()

/datum/reagent/luminescent_fluid/red
	name = "Red Luminiscent Fluid"
	color = COLOR_SOFT_RED
	// The glow *is* unnatural, so...
	metabolized_traits = list(TRAIT_MINOR_NIGHT_VISION, TRAIT_UNNATURAL_RED_GLOWY_EYES)

/datum/reagent/luminescent_fluid/red/overdose_start(mob/living/affected_mob)
	. = ..()
	if (!ishuman(affected_mob))
		return
	ADD_TRAIT(affected_mob, TRAIT_UNNATURAL_RED_GLOWY_EYES, OVERDOSE_TRAIT)

/datum/reagent/luminescent_fluid/blue
	name = "Blue Luminiscent Fluid"
	color = LIGHT_COLOR_BLUE

/datum/reagent/luminescent_fluid/cyan
	name = "Cyan Luminiscent Fluid"
	color = LIGHT_COLOR_CYAN

/datum/reagent/luminescent_fluid/yellow
	name = "Yellow Luminiscent Fluid"
	color = LIGHT_COLOR_DIM_YELLOW

/datum/reagent/luminescent_fluid/orange
	name = "Orange Luminiscent Fluid"
	color = LIGHT_COLOR_ORANGE

/datum/reagent/luminescent_fluid/pink
	name = "Pink Luminiscent Fluid"
	color = LIGHT_COLOR_PINK
