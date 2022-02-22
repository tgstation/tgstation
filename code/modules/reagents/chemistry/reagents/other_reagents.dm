/datum/reagent/blood
	data = list("viruses"=null,"blood_DNA"=null,"blood_type"=null,"resistances"=null,"trace_chem"=null,"mind"=null,"ckey"=null,"gender"=null,"real_name"=null,"cloneable"=null,"factions"=null,"quirks"=null)
	name = "Blood"
	color = "#C80000" // rgb: 200, 0, 0
	metabolization_rate = 12.5 * REAGENTS_METABOLISM //fast rate so it disappears fast.
	taste_description = "iron"
	taste_mult = 1.3
	glass_icon_state = "glass_red"
	glass_name = "glass of tomato juice"
	glass_desc = "Are you sure this is tomato juice?"
	shot_glass_icon_state = "shotglassred"
	penetrates_skin = NONE
	ph = 7.4

	// FEED ME
/datum/reagent/blood/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray)
	. = ..()
	if(chems.has_reagent(type, 1))
		mytray.adjust_pestlevel(rand(2,3))

/datum/reagent/blood/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message=TRUE, touch_protection=0)
	. = ..()
	if(data && data["viruses"])
		for(var/thing in data["viruses"])
			var/datum/disease/strain = thing

			if((strain.spread_flags & DISEASE_SPREAD_SPECIAL) || (strain.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS))
				continue

			if((methods & (TOUCH|VAPOR)) && (strain.spread_flags & DISEASE_SPREAD_CONTACT_FLUIDS))
				exposed_mob.ContactContractDisease(strain)
			else //ingest, patch or inject
				exposed_mob.ForceContractDisease(strain)

	if(iscarbon(exposed_mob))
		var/mob/living/carbon/exposed_carbon = exposed_mob
		if(exposed_carbon.get_blood_id() == /datum/reagent/blood && ((methods & INJECT) || ((methods & INGEST) && exposed_carbon.dna && exposed_carbon.dna.species && (DRINKSBLOOD in exposed_carbon.dna.species.species_traits))))
			if(!data || !(data["blood_type"] in get_safe_blood(exposed_carbon.dna.blood_type)))
				exposed_carbon.reagents.add_reagent(/datum/reagent/toxin, reac_volume * 0.5)
			else
				exposed_carbon.blood_volume = min(exposed_carbon.blood_volume + round(reac_volume, 0.1), BLOOD_VOLUME_MAXIMUM)


/datum/reagent/blood/on_new(list/data)
	. = ..()
	if(istype(data))
		SetViruses(src, data)

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
		bloodsplatter = new(exposed_turf)
	if(data["blood_DNA"])
		bloodsplatter.add_blood_DNA(list(data["blood_DNA"] = data["blood_type"]))

/datum/reagent/blood/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray)
	. = ..()
	mytray.adjust_pestlevel(rand(2,3))

/datum/reagent/liquidgibs
	name = "Liquid Gibs"
	color = "#CC4633"
	description = "You don't even want to think about what's in here."
	taste_description = "gross iron"
	shot_glass_icon_state = "shotglassred"
	material = /datum/material/meat
	ph = 7.45
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

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
			infection.cure()
	LAZYOR(exposed_mob.disease_resistances, data)

/datum/reagent/vaccine/on_merge(list/data)
	if(istype(data))
		src.data |= data.Copy()

/datum/reagent/vaccine/fungal_tb

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
	glass_icon_state = "glass_clear"
	glass_name = "glass of water"
	glass_desc = "The father of all refreshments."
	shot_glass_icon_state = "shotglassclear"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_CLEANS

/*
 * Water reaction to turf
 */

/datum/reagent/water/expose_turf(turf/open/exposed_turf, reac_volume)
	. = ..()
	if(!istype(exposed_turf))
		return

	var/cool_temp = cooling_temperature
	if(reac_volume >= 5)
		exposed_turf.MakeSlippery(TURF_WET_WATER, 10 SECONDS, min(reac_volume*1.5 SECONDS, 60 SECONDS))

	for(var/mob/living/simple_animal/slime/exposed_slime in exposed_turf)
		exposed_slime.apply_water()

	var/obj/effect/hotspot/hotspot = (locate(/obj/effect/hotspot) in exposed_turf)
	if(hotspot && !isspaceturf(exposed_turf))
		if(exposed_turf.air)
			var/datum/gas_mixture/air = exposed_turf.air
			air.temperature = max(min(air.temperature-(cool_temp*1000), air.temperature/cool_temp),TCMB)
			air.react(src)
			qdel(hotspot)

/*
 * Water reaction to an object
 */

/datum/reagent/water/expose_obj(obj/exposed_obj, reac_volume)
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

/*
 * Water reaction to a mob
 */

/datum/reagent/water/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)//Splashing people with water can help put them out!
	. = ..()
	if(methods & TOUCH)
		exposed_mob.extinguish_mob() // extinguish removes all fire stacks
	if(methods & VAPOR)
		if(!isfelinid(exposed_mob))
			return
		exposed_mob.incapacitate(1) // startles the felinid, canceling any do_after
		SEND_SIGNAL(exposed_mob, COMSIG_ADD_MOOD_EVENT, "watersprayed", /datum/mood_event/watersprayed)


/datum/reagent/water/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	if(M.blood_volume)
		M.blood_volume += 0.1 * REM * delta_time // water is good for you!

///For weird backwards situations where water manages to get added to trays nutrients, as opposed to being snowflaked away like usual.
/datum/reagent/water/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray)
	if(chems.has_reagent(src.type, 1))
		mytray.adjust_waterlevel(round(chems.get_reagent_amount(src.type) * 1))
		//You don't belong in this world, monster!
		chems.remove_reagent(/datum/reagent/water, chems.get_reagent_amount(src.type))

/datum/reagent/water/holywater
	name = "Holy Water"
	description = "Water blessed by some deity."
	color = "#E0E8EF" // rgb: 224, 232, 239
	glass_icon_state = "glass_clear"
	glass_name = "glass of holy water"
	glass_desc = "A glass of holy water."
	self_consuming = TRUE //divine intervention won't be limited by the lack of a liver
	ph = 7.5 //God is alkaline
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_CLEANS

	// Holy water. Mostly the same as water, it also heals the plant a little with the power of the spirits. Also ALSO increases instability.
/datum/reagent/water/holywater/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray)
	if(chems.has_reagent(type, 1))
		mytray.adjust_waterlevel(round(chems.get_reagent_amount(type) * 1))
		mytray.adjust_plant_health(round(chems.get_reagent_amount(type) * 0.1))
		if(myseed)
			myseed.adjust_instability(round(chems.get_reagent_amount(type) * 0.15))

/datum/reagent/water/holywater/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_HOLY, type)

/datum/reagent/water/holywater/on_mob_add(mob/living/L, amount)
	. = ..()
	if(data)
		data["misc"] = 0

/datum/reagent/water/holywater/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_HOLY, type)
	..()

/datum/reagent/water/holywater/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	. = ..()
	if(IS_CULTIST(exposed_mob))
		to_chat(exposed_mob, span_userdanger("A vile holiness begins to spread its shining tendrils through your mind, purging the Geometer of Blood's influence!"))

/datum/reagent/water/holywater/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(M.blood_volume)
		M.blood_volume += 0.1 * REM * delta_time // water is good for you!
	if(!data)
		data = list("misc" = 0)

	data["misc"] += delta_time SECONDS * REM
	M.jitteriness = min(M.jitteriness + (2 * delta_time), 10)
	if(IS_CULTIST(M))
		for(var/datum/action/innate/cult/blood_magic/BM in M.actions)
			to_chat(M, span_cultlarge("Your blood rites falter as holy water scours your body!"))
			for(var/datum/action/innate/cult/blood_spell/BS in BM.spells)
				qdel(BS)
	if(data["misc"] >= (25 SECONDS)) // 10 units
		if(!M.stuttering)
			M.stuttering = 1
		M.stuttering = min(M.stuttering + (2 * delta_time), 10)
		M.Dizzy(5)
		if(IS_CULTIST(M) && DT_PROB(10, delta_time))
			M.say(pick("Av'te Nar'Sie","Pa'lid Mors","INO INO ORA ANA","SAT ANA!","Daim'niodeis Arc'iai Le'eones","R'ge Na'sie","Diabo us Vo'iscum","Eld' Mon Nobis"), forced = "holy water")
			if(prob(10))
				M.visible_message(span_danger("[M] starts having a seizure!"), span_userdanger("You have a seizure!"))
				M.Unconscious(12 SECONDS)
				to_chat(M, "<span class='cultlarge'>[pick("Your blood is your bond - you are nothing without it", "Do not forget your place", \
				"All that power, and you still fail?", "If you cannot scour this poison, I shall scour your meager life!")].</span>")
	if(data["misc"] >= (1 MINUTES)) // 24 units
		if(IS_CULTIST(M))
			M.mind.remove_antag_datum(/datum/antagonist/cult)
			M.Unconscious(100)
		M.jitteriness = 0
		M.stuttering = 0
		holder.remove_reagent(type, volume) // maybe this is a little too perfect and a max() cap on the statuses would be better??
		return
	holder.remove_reagent(type, 1 * REAGENTS_METABOLISM * delta_time) //fixed consumption to prevent balancing going out of whack

/datum/reagent/water/holywater/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(!istype(exposed_turf))
		return
	if(reac_volume>=10)
		for(var/obj/effect/rune/R in exposed_turf)
			qdel(R)
	exposed_turf.Bless()

/datum/reagent/water/hollowwater
	name = "Hollow Water"
	description = "An ubiquitous chemical substance that is composed of hydrogen and oxygen, but it looks kinda hollow."
	color = "#88878777"
	taste_description = "emptyiness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/hydrogen_peroxide
	name = "Hydrogen Peroxide"
	description = "An ubiquitous chemical substance that is composed of hydrogen and oxygen and oxygen." //intended intended
	color = "#AAAAAA77" // rgb: 170, 170, 170, 77 (alpha)
	taste_description = "burning water"
	var/cooling_temperature = 2
	glass_icon_state = "glass_clear"
	glass_name = "glass of oxygenated water"
	glass_desc = "The father of all refreshments. Surely it tastes great, right?"
	shot_glass_icon_state = "shotglassclear"
	ph = 6.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/*
 * Water reaction to turf
 */

/datum/reagent/hydrogen_peroxide/expose_turf(turf/open/exposed_turf, reac_volume)
	. = ..()
	if(!istype(exposed_turf))
		return
	if(reac_volume >= 5)
		exposed_turf.MakeSlippery(TURF_WET_WATER, 10 SECONDS, min(reac_volume*1.5 SECONDS, 60 SECONDS))
/*
 * Water reaction to a mob
 */

/datum/reagent/hydrogen_peroxide/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)//Splashing people with h2o2 can burn them !
	. = ..()
	if(methods & TOUCH)
		exposed_mob.adjustFireLoss(2, 0) // burns

/datum/reagent/fuel/unholywater //if you somehow managed to extract this from someone, dont splash it on yourself and have a smoke
	name = "Unholy Water"
	description = "Something that shouldn't exist on this plane of existence."
	taste_description = "suffering"
	metabolization_rate = 2.5 * REAGENTS_METABOLISM  //0.5u/second
	penetrates_skin = TOUCH|VAPOR
	ph = 6.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/fuel/unholywater/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(IS_CULTIST(M))
		M.adjust_drowsyness(-5* REM * delta_time)
		M.AdjustAllImmobility(-40 *REM* REM * delta_time)
		M.adjustStaminaLoss(-10 * REM * delta_time, 0)
		M.adjustToxLoss(-2 * REM * delta_time, 0)
		M.adjustOxyLoss(-2 * REM * delta_time, 0)
		M.adjustBruteLoss(-2 * REM * delta_time, 0)
		M.adjustFireLoss(-2 * REM * delta_time, 0)
		if(ishuman(M) && M.blood_volume < BLOOD_VOLUME_NORMAL)
			M.blood_volume += 3 * REM * delta_time
	else  // Will deal about 90 damage when 50 units are thrown
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3 * REM * delta_time, 150)
		M.adjustToxLoss(1 * REM * delta_time, 0)
		M.adjustFireLoss(1 * REM * delta_time, 0)
		M.adjustOxyLoss(1 * REM * delta_time, 0)
		M.adjustBruteLoss(1 * REM * delta_time, 0)
	..()

/datum/reagent/hellwater //if someone has this in their system they've really pissed off an eldrich god
	name = "Hell Water"
	description = "YOUR FLESH! IT BURNS!"
	taste_description = "burning"
	ph = 0.1
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/hellwater/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.set_fire_stacks(min(M.fire_stacks + (1.5 * delta_time), 5))
	M.IgniteMob() //Only problem with igniting people is currently the commonly available fire suits make you immune to being on fire
	M.adjustToxLoss(0.5*delta_time, 0)
	M.adjustFireLoss(0.5*delta_time, 0) //Hence the other damages... ain't I a bastard?
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2.5*delta_time, 150)
	holder.remove_reagent(type, 0.5*delta_time)

/datum/reagent/medicine/omnizine/godblood
	name = "Godblood"
	description = "Slowly heals all damage types. Has a rather high overdose threshold. Glows with mysterious power."
	overdose_threshold = 150
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

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
	fallback_icon_state = "spraytan_fallback"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/spraytan/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE)
	. = ..()
	if(ishuman(exposed_mob))
		if(methods & (PATCH|VAPOR))
			var/mob/living/carbon/human/exposed_human = exposed_mob
			if(exposed_human.dna.species.id == SPECIES_HUMAN)
				switch(exposed_human.skin_tone)
					if("african1")
						exposed_human.skin_tone = "african2"
					if("indian")
						exposed_human.skin_tone = "african1"
					if("arab")
						exposed_human.skin_tone = "indian"
					if("asian2")
						exposed_human.skin_tone = "arab"
					if("asian1")
						exposed_human.skin_tone = "asian2"
					if("mediterranean")
						exposed_human.skin_tone = "african1"
					if("latino")
						exposed_human.skin_tone = "mediterranean"
					if("caucasian3")
						exposed_human.skin_tone = "mediterranean"
					if("caucasian2")
						exposed_human.skin_tone = pick("caucasian3", "latino")
					if("caucasian1")
						exposed_human.skin_tone = "caucasian2"
					if ("albino")
						exposed_human.skin_tone = "caucasian1"

			if(MUTCOLORS in exposed_human.dna.species.species_traits) //take current alien color and darken it slightly
				var/newcolor = ""
				var/string = exposed_human.dna.features["mcolor"]
				var/len = length(string)
				var/char = ""
				var/ascii = 0
				for(var/i=1, i<=len, i += length(char))
					char = string[i]
					ascii = text2ascii(char)
					switch(ascii)
						if(48)
							newcolor += "0"
						if(49 to 57)
							newcolor += ascii2text(ascii-1) //numbers 1 to 9
						if(97)
							newcolor += "9"
						if(98 to 102)
							newcolor += ascii2text(ascii-1) //letters b to f lowercase
						if(65)
							newcolor += "9"
						if(66 to 70)
							newcolor += ascii2text(ascii+31) //letters B to F - translates to lowercase
						else
							break
				if(ReadHSV(newcolor)[3] >= ReadHSV("#7F7F7F")[3])
					exposed_human.dna.features["mcolor"] = newcolor
			exposed_human.regenerate_icons()

		if((methods & INGEST) && show_message)
			to_chat(exposed_mob, span_notice("That tasted horrible."))


/datum/reagent/spraytan/overdose_process(mob/living/M, delta_time, times_fired)
	metabolization_rate = 1 * REAGENTS_METABOLISM

	if(ishuman(M))
		var/mob/living/carbon/human/N = M
		if(!HAS_TRAIT(N, TRAIT_BALD))
			N.hairstyle = "Spiky"
		N.facial_hairstyle = "Shaved"
		N.facial_hair_color = "#000000"
		N.hair_color = "#000000"
		if(!(HAIR in N.dna.species.species_traits)) //No hair? No problem!
			N.dna.species.species_traits += HAIR
		if(N.dna.species.use_skintones)
			N.skin_tone = "orange"
		else if(MUTCOLORS in N.dna.species.species_traits) //Aliens with custom colors simply get turned orange
			N.dna.features["mcolor"] = "#ff8800"
		N.regenerate_icons()
		if(DT_PROB(3.5, delta_time))
			if(N.w_uniform)
				M.visible_message(pick("<b>[M]</b>'s collar pops up without warning.</span>", "<b>[M]</b> flexes [M.p_their()] arms."))
			else
				M.visible_message("<b>[M]</b> flexes [M.p_their()] arms.")
	if(DT_PROB(5, delta_time))
		M.say(pick("Shit was SO cash.", "You are everything bad in the world.", "What sports do you play, other than 'jack off to naked drawn Japanese people?'", "Don???t be a stranger. Just hit me with your best shot.", "My name is John and I hate every single one of you."), forced = /datum/reagent/spraytan)
	..()
	return

#define MUT_MSG_IMMEDIATE 1
#define MUT_MSG_EXTENDED 2
#define MUT_MSG_ABOUT2TURN 3

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
	var/cycles_to_turn = 20 //the current_cycle threshold / iterations needed before one can transform

/datum/reagent/mutationtoxin/on_mob_life(mob/living/carbon/human/H, delta_time, times_fired)
	. = TRUE
	if(!istype(H))
		return
	if(!(H.dna?.species) || !(H.mob_biotypes & MOB_ORGANIC))
		return

	if(DT_PROB(5, delta_time))
		var/list/pick_ur_fav = list()
		var/filter = NONE
		if(current_cycle <= (cycles_to_turn*0.3))
			filter = MUT_MSG_IMMEDIATE
		else if(current_cycle <= (cycles_to_turn*0.8))
			filter = MUT_MSG_EXTENDED
		else
			filter = MUT_MSG_ABOUT2TURN

		for(var/i in mutationtexts)
			if(mutationtexts[i] == filter)
				pick_ur_fav += i
		to_chat(H, span_warning("[pick(pick_ur_fav)]"))

	if(current_cycle >= cycles_to_turn)
		var/datum/species/species_type = race
		H.set_species(species_type)
		holder.del_reagent(type)
		to_chat(H, span_warning("You've become \a [lowertext(initial(species_type.name))]!"))
		return
	..()

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

/datum/reagent/mutationtoxin/jelly/on_mob_life(mob/living/carbon/human/H, delta_time, times_fired)
	if(isjellyperson(H))
		to_chat(H, span_warning("Your jelly shifts and morphs, turning you into another subspecies!"))
		var/species_type = pick(subtypesof(/datum/species/jelly))
		H.set_species(species_type)
		holder.del_reagent(type)
		return TRUE
	if(current_cycle >= cycles_to_turn) //overwrite since we want subtypes of jelly
		var/datum/species/species_type = pick(subtypesof(race))
		H.set_species(species_type)
		holder.del_reagent(type)
		to_chat(H, span_warning("You've become \a [initial(species_type.name)]!"))
		return TRUE
	return ..()

/datum/reagent/mutationtoxin/golem
	name = "Golem Mutation Toxin"
	description = "A crystal toxin."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/golem/random
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

/datum/reagent/mulligan
	name = "Mulligan Toxin"
	description = "This toxin will rapidly change the DNA of human beings. Commonly used by Syndicate spies and assassins in need of an emergency ID change."
	color = "#5EFF3B" //RGB: 94, 255, 59
	metabolization_rate = INFINITY
	taste_description = "slime"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/mulligan/on_mob_life(mob/living/carbon/human/H, delta_time, times_fired)
	..()
	if (!istype(H))
		return
	to_chat(H, span_warning("<b>You grit your teeth in pain as your body rapidly mutates!</b>"))
	H.visible_message("<b>[H]</b> suddenly transforms!")
	randomize_human(H)
	H.dna.update_dna_identity()

/datum/reagent/aslimetoxin
	name = "Advanced Mutation Toxin"
	description = "An advanced corruptive toxin produced by slimes."
	color = "#13BC5E" // rgb: 19, 188, 94
	taste_description = "slime"
	penetrates_skin = NONE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/aslimetoxin/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message=TRUE, touch_protection=0)
	. = ..()
	if(methods & ~TOUCH)
		exposed_mob.ForceContractDisease(new /datum/disease/transformation/slime(), FALSE, TRUE)

/datum/reagent/gluttonytoxin
	name = "Gluttony's Blessing"
	description = "An advanced corruptive toxin produced by something terrible."
	color = "#5EFF3B" //RGB: 94, 255, 59
	taste_description = "decay"
	penetrates_skin = NONE

/datum/reagent/gluttonytoxin/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message=TRUE, touch_protection=0)
	. = ..()
	if(reac_volume >= 1)//This prevents microdosing from infecting masses of people
		exposed_mob.ForceContractDisease(new /datum/disease/transformation/morph(), FALSE, TRUE)

/datum/reagent/serotrotium
	name = "Serotrotium"
	description = "A chemical compound that promotes concentrated production of the serotonin neurotransmitter in humans."
	color = "#202040" // rgb: 20, 20, 40
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	taste_description = "bitterness"
	ph = 10
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/serotrotium/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(ishuman(M))
		if(DT_PROB(3.5, delta_time))
			M.emote(pick("twitch","drool","moan","gasp"))
	..()

/datum/reagent/oxygen
	name = "Oxygen"
	description = "A colorless, odorless gas. Grows on trees but is still pretty valuable."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_mult = 0 // oderless and tasteless
	ph = 9.2//It's acutally a huge range and very dependant on the chemistry but ph is basically a made up var in it's implementation anyways
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED


/datum/reagent/oxygen/expose_turf(turf/open/exposed_turf, reac_volume)
	. = ..()
	if(istype(exposed_turf))
		var/temp = holder ? holder.chem_temp : T20C
		exposed_turf.atmos_spawn_air("o2=[reac_volume/20];TEMP=[temp]")
	return

/datum/reagent/copper
	name = "Copper"
	description = "A highly ductile metal. Things made out of copper aren't very durable, but it makes a decent material for electrical wiring."
	reagent_state = SOLID
	color = "#6E3B08" // rgb: 110, 59, 8
	taste_description = "metal"
	ph = 5.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/copper/expose_obj(obj/exposed_obj, reac_volume)
	. = ..()
	if(!istype(exposed_obj, /obj/item/stack/sheet/iron))
		return

	var/obj/item/stack/sheet/iron/M = exposed_obj
	reac_volume = min(reac_volume, M.amount)
	new/obj/item/stack/sheet/bronze(get_turf(M), reac_volume)
	M.use(reac_volume)

/datum/reagent/nitrogen
	name = "Nitrogen"
	description = "A colorless, odorless, tasteless gas. A simple asphyxiant that can silently displace vital oxygen."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_mult = 0
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/nitrogen/expose_turf(turf/open/exposed_turf, reac_volume)
	if(istype(exposed_turf))
		var/temp = holder ? holder.chem_temp : T20C
		exposed_turf.atmos_spawn_air("n2=[reac_volume/20];TEMP=[temp]")
	return ..()

/datum/reagent/hydrogen
	name = "Hydrogen"
	description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_mult = 0
	ph = 0.1//Now I'm stuck in a trap of my own design. Maybe I should make -ve phes? (not 0 so I don't get div/0 errors)
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/potassium
	name = "Potassium"
	description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
	reagent_state = SOLID
	color = "#A0A0A0" // rgb: 160, 160, 160
	taste_description = "sweetness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/mercury
	name = "Mercury"
	description = "A curious metal that's a liquid at room temperature. Neurodegenerative and very bad for the mind."
	color = "#484848" // rgb: 72, 72, 72A
	taste_mult = 0 // apparently tasteless.
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/mercury/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(!HAS_TRAIT(src, TRAIT_IMMOBILIZED) && !isspaceturf(M.loc))
		step(M, pick(GLOB.cardinals))
	if(DT_PROB(3.5, delta_time))
		M.emote(pick("twitch","drool","moan"))
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.5*delta_time)
	..()

/datum/reagent/sulfur
	name = "Sulfur"
	description = "A sickly yellow solid mostly known for its nasty smell. It's actually much more helpful than it looks in biochemisty."
	reagent_state = SOLID
	color = "#BF8C00" // rgb: 191, 140, 0
	taste_description = "rotten eggs"
	ph = 4.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/carbon
	name = "Carbon"
	description = "A crumbly black solid that, while unexciting on a physical level, forms the base of all known life. Kind of a big deal."
	reagent_state = SOLID
	color = "#1C1300" // rgb: 30, 20, 0
	taste_description = "sour chalk"
	ph = 5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/carbon/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(isspaceturf(exposed_turf))
		return

	var/obj/effect/decal/cleanable/dirt/dirt_decal = (locate() in exposed_turf.contents)
	if(!dirt_decal)
		dirt_decal = new(exposed_turf)

/datum/reagent/chlorine
	name = "Chlorine"
	description = "A pale yellow gas that's well known as an oxidizer. While it forms many harmless molecules in its elemental form it is far from harmless."
	reagent_state = GAS
	color = "#FFFB89" //pale yellow? let's make it light gray
	taste_description = "chlorine"
	ph = 7.4
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED


// You're an idiot for thinking that one of the most corrosive and deadly gasses would be beneficial
/datum/reagent/chlorine/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	if(chems.has_reagent(src.type, 1))
		mytray.adjust_plant_health(-round(chems.get_reagent_amount(src.type) * 1))
		mytray.adjust_toxic(round(chems.get_reagent_amount(src.type) * 1.5))
		mytray.adjust_waterlevel(-round(chems.get_reagent_amount(src.type) * 0.5))
		mytray.adjust_weedlevel(-rand(1,3))
		// White Phosphorous + water -> phosphoric acid. That's not a good thing really.


/datum/reagent/chlorine/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.take_bodypart_damage(0.5*REM*delta_time, 0, 0, 0)
	. = TRUE
	..()

/datum/reagent/fluorine
	name = "Fluorine"
	description = "A comically-reactive chemical element. The universe does not want this stuff to exist in this form in the slightest."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_description = "acid"
	ph = 2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

// You're an idiot for thinking that one of the most corrosive and deadly gasses would be beneficial
/datum/reagent/fluorine/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	if(chems.has_reagent(src.type, 1))
		mytray.adjust_plant_health(-round(chems.get_reagent_amount(src.type) * 2))
		mytray.adjust_toxic(round(chems.get_reagent_amount(src.type) * 2.5))
		mytray.adjust_waterlevel(-round(chems.get_reagent_amount(src.type) * 0.5))
		mytray.adjust_weedlevel(-rand(1,4))

/datum/reagent/fluorine/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.adjustToxLoss(0.5*REM*delta_time, 0)
	. = TRUE
	..()

/datum/reagent/sodium
	name = "Sodium"
	description = "A soft silver metal that can easily be cut with a knife. It's not salt just yet, so refrain from putting it on your chips."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128
	taste_description = "salty metal"
	ph = 11.6
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/phosphorus
	name = "Phosphorus"
	description = "A ruddy red powder that burns readily. Though it comes in many colors, the general theme is always the same."
	reagent_state = SOLID
	color = "#832828" // rgb: 131, 40, 40
	taste_description = "vinegar"
	ph = 6.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

// Phosphoric salts are beneficial though. And even if the plant suffers, in the long run the tray gets some nutrients. The benefit isn't worth that much.
/datum/reagent/phosphorus/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	if(chems.has_reagent(src.type, 1))
		mytray.adjust_plant_health(-round(chems.get_reagent_amount(src.type) * 0.75))
		mytray.adjust_waterlevel(-round(chems.get_reagent_amount(src.type) * 0.5))
		mytray.adjust_weedlevel(-rand(1,2))

/datum/reagent/lithium
	name = "Lithium"
	description = "A silver metal, its claim to fame is its remarkably low density. Using it is a bit too effective in calming oneself down."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128
	taste_description = "metal"
	ph = 11.3
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/lithium/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(!HAS_TRAIT(M, TRAIT_IMMOBILIZED) && !isspaceturf(M.loc) && isturf(M.loc))
		step(M, pick(GLOB.cardinals))
	if(DT_PROB(2.5, delta_time))
		M.emote(pick("twitch","drool","moan"))
	..()

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
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/space_cleaner/sterilizine/expose_mob(mob/living/carbon/exposed_carbon, methods=TOUCH, reac_volume)
	. = ..()
	if(!(methods & (TOUCH|VAPOR|PATCH)))
		return

	for(var/s in exposed_carbon.surgeries)
		var/datum/surgery/surgery = s
		surgery.speed_modifier = max(0.2, surgery.speed_modifier)

/datum/reagent/iron
	name = "Iron"
	description = "Pure iron is a metal."
	reagent_state = SOLID
	taste_description = "iron"
	material = /datum/material/iron
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	color = "#606060" //pure iron? let's make it violet of course
	ph = 6

/datum/reagent/iron/on_mob_life(mob/living/carbon/C, delta_time, times_fired)
	if(C.blood_volume < BLOOD_VOLUME_NORMAL)
		C.blood_volume += 0.25 * delta_time
	..()

/datum/reagent/gold
	name = "Gold"
	description = "Gold is a dense, soft, shiny metal and the most malleable and ductile metal known."
	reagent_state = SOLID
	color = "#F7C430" // rgb: 247, 196, 48
	taste_description = "expensive metal"
	material = /datum/material/gold
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/silver
	name = "Silver"
	description = "A soft, white, lustrous transition metal, it has the highest electrical conductivity of any element and the highest thermal conductivity of any metal."
	reagent_state = SOLID
	color = "#D0D0D0" // rgb: 208, 208, 208
	taste_description = "expensive yet reasonable metal"
	material = /datum/material/silver
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/uranium
	name ="Uranium"
	description = "A jade-green metallic chemical element in the actinide series, weakly radioactive."
	reagent_state = SOLID
	color = "#5E9964" //this used to be silver, but liquid uranium can still be green and it's more easily noticeable as uranium like this so why bother?
	taste_description = "the inside of a reactor"
	/// How much tox damage to deal per tick
	var/tox_damage = 0.5
	ph = 4
	material = /datum/material/uranium
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/uranium/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.adjustToxLoss(tox_damage * delta_time * REM)
	..()

/datum/reagent/uranium/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if((reac_volume < 3) || isspaceturf(exposed_turf))
		return

	var/obj/effect/decal/cleanable/greenglow/glow = locate() in exposed_turf.contents
	if(!glow)
		glow = new(exposed_turf)
	if(!QDELETED(glow))
		glow.reagents.add_reagent(type, reac_volume)

//Mutagenic chem side-effects.
/datum/reagent/uranium/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	mytray.mutation_roll(user)
	if(chems.has_reagent(src.type, 1))
		mytray.adjust_plant_health(-round(chems.get_reagent_amount(src.type) * 1))
		mytray.adjust_toxic(round(chems.get_reagent_amount(src.type) * 2))

/datum/reagent/uranium/radium
	name = "Radium"
	description = "Radium is an alkaline earth metal. It is extremely radioactive."
	reagent_state = SOLID
	color = "#00CC00" // ditto
	taste_description = "the colour blue and regret"
	tox_damage = 1*REM
	material = null
	ph = 10
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/uranium/radium/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	if(chems.has_reagent(src.type, 1))
		mytray.adjust_plant_health(-round(chems.get_reagent_amount(src.type) * 1))
		mytray.adjust_toxic(round(chems.get_reagent_amount(src.type) * 1))

/datum/reagent/bluespace
	name = "Bluespace Dust"
	description = "A dust composed of microscopic bluespace crystals, with minor space-warping properties."
	reagent_state = SOLID
	color = "#0000CC"
	taste_description = "fizzling blue"
	material = /datum/material/bluespace
	ph = 12
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/bluespace/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	. = ..()
	if(methods & (TOUCH|VAPOR))
		do_teleport(exposed_mob, get_turf(exposed_mob), (reac_volume / 5), asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE) //4 tiles per crystal

/datum/reagent/bluespace/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(current_cycle > 10 && DT_PROB(7.5, delta_time))
		to_chat(M, span_warning("You feel unstable..."))
		M.Jitter(2)
		current_cycle = 1
		addtimer(CALLBACK(M, /mob/living/proc/bluespace_shuffle), 30)
	..()

/mob/living/proc/bluespace_shuffle()
	do_teleport(src, get_turf(src), 5, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)

/datum/reagent/aluminium
	name = "Aluminium"
	description = "A silvery white and ductile member of the boron group of chemical elements."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168
	taste_description = "metal"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/silicon
	name = "Silicon"
	description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
	reagent_state = SOLID
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
	glass_icon_state = "dr_gibb_glass"
	glass_name = "glass of welder fuel"
	glass_desc = "Unless you're an industrial tool, this is probably not safe for consumption."
	penetrates_skin = NONE
	ph = 4
	burning_temperature = 1725 //more refined than oil
	burning_volume = 0.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/alcohol = 4)

/datum/reagent/fuel/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)//Splashing people with welding fuel to make them easy to ignite!
	. = ..()
	if(methods & (TOUCH|VAPOR))
		exposed_mob.adjust_fire_stacks(reac_volume / 10)

/datum/reagent/fuel/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.adjustToxLoss(0.5*delta_time, 0)
	..()
	return TRUE

/datum/reagent/space_cleaner
	name = "Space Cleaner"
	description = "A compound used to clean things. Now with 50% more sodium hypochlorite!"
	color = "#A5F0EE" // rgb: 165, 240, 238
	taste_description = "sourness"
	reagent_weight = 0.6 //so it sprays further
	penetrates_skin = NONE
	var/clean_types = CLEAN_WASH
	ph = 5.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_CLEANS

/datum/reagent/space_cleaner/expose_obj(obj/exposed_obj, reac_volume)
	. = ..()
	exposed_obj?.wash(clean_types)

/datum/reagent/space_cleaner/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(reac_volume < 1)
		return

	exposed_turf.wash(clean_types)
	for(var/am in exposed_turf)
		var/atom/movable/movable_content = am
		if(ismopable(movable_content)) // Mopables will be cleaned anyways by the turf wash
			continue
		movable_content.wash(clean_types)

	for(var/mob/living/simple_animal/slime/exposed_slime in exposed_turf)
		exposed_slime.adjustToxLoss(rand(5,10))

/datum/reagent/space_cleaner/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message=TRUE, touch_protection=0)
	. = ..()
	if(methods & (TOUCH|VAPOR))
		exposed_mob.wash(clean_types)

/datum/reagent/space_cleaner/ez_clean
	name = "EZ Clean"
	description = "A powerful, acidic cleaner sold by Waffle Co. Affects organic matter while leaving other objects unaffected."
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "acid"
	penetrates_skin = VAPOR
	ph = 2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/space_cleaner/ez_clean/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.adjustBruteLoss(1.665*delta_time)
	M.adjustFireLoss(1.665*delta_time)
	M.adjustToxLoss(1.665*delta_time)
	..()

/datum/reagent/space_cleaner/ez_clean/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	. = ..()
	if((methods & (TOUCH|VAPOR)) && !issilicon(exposed_mob))
		exposed_mob.adjustBruteLoss(1.5)
		exposed_mob.adjustFireLoss(1.5)

/datum/reagent/cryptobiolin
	name = "Cryptobiolin"
	description = "Cryptobiolin causes confusion and dizziness."
	color = "#ADB5DB" //i hate default violets and 'crypto' keeps making me think of cryo so it's light blue now
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "sourness"
	ph = 11.9
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/cryptobiolin/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.Dizzy(1)
	M.set_confusion(clamp(M.get_confusion(), 1, 20))
	..()

/datum/reagent/impedrezene
	name = "Impedrezene"
	description = "Impedrezene is a narcotic that impedes one's ability by slowing down the higher brain cell functions."
	color = "#E07DDD" // pink = happy = dumb
	taste_description = "numbness"
	ph = 9.1
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/opiods = 10)

/datum/reagent/impedrezene/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.jitteriness = max(M.jitteriness - (2.5*delta_time),0)
	if(DT_PROB(55, delta_time))
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2)
	if(DT_PROB(30, delta_time))
		M.adjust_drowsyness(3)
	if(DT_PROB(5, delta_time))
		M.emote("drool")
	..()

/datum/reagent/cyborg_mutation_nanomachines
	name = "Nanomachines"
	description = "Microscopic construction robots."
	color = "#535E66" // rgb: 83, 94, 102
	taste_description = "sludge"
	penetrates_skin = NONE

/datum/reagent/cyborg_mutation_nanomachines/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if((methods & (PATCH|INGEST|INJECT)) || ((methods & VAPOR) && prob(min(reac_volume,100)*(1 - touch_protection))))
		exposed_mob.ForceContractDisease(new /datum/disease/transformation/robot(), FALSE, TRUE)

/datum/reagent/xenomicrobes
	name = "Xenomicrobes"
	description = "Microbes with an entirely alien cellular structure."
	color = "#535E66" // rgb: 83, 94, 102
	taste_description = "sludge"
	penetrates_skin = NONE

/datum/reagent/xenomicrobes/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if((methods & (PATCH|INGEST|INJECT)) || ((methods & VAPOR) && prob(min(reac_volume,100)*(1 - touch_protection))))
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
	if((methods & (PATCH|INGEST|INJECT)) || ((methods & VAPOR) && prob(min(reac_volume,100)*(1 - touch_protection))))
		exposed_mob.ForceContractDisease(new /datum/disease/tuberculosis(), FALSE, TRUE)

/datum/reagent/snail
	name = "Agent-S"
	description = "Virological agent that infects the subject with Gastrolosis."
	color = "#003300" // rgb(0, 51, 0)
	taste_description = "goo"
	penetrates_skin = NONE
	ph = 11

/datum/reagent/snail/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if((methods & (PATCH|INGEST|INJECT)) || ((methods & VAPOR) && prob(min(reac_volume,100)*(1 - touch_protection))))
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
	reagent_state = SOLID
	color = "#664B63" // rgb: 102, 75, 99
	taste_description = "metal"
	ph = 11.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/smart_foaming_agent //Smart foaming agent. Functions similarly to metal foam, but conforms to walls.
	name = "Smart Foaming Agent"
	description = "An agent that yields metallic foam which conforms to area boundaries when mixed with light metal and a strong acid."
	reagent_state = SOLID
	color = "#664B63" // rgb: 102, 75, 99
	taste_description = "metal"
	ph = 11.8
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/ammonia
	name = "Ammonia"
	description = "A caustic substance commonly used in fertilizer or household cleaners."
	reagent_state = GAS
	color = "#404030" // rgb: 64, 64, 48
	taste_description = "mordant"
	ph = 11.6
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/ammonia/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	// Ammonia is bad ass.
	if(chems.has_reagent(src.type, 1))
		mytray.adjust_plant_health(round(chems.get_reagent_amount(src.type) * 0.12))
		if(myseed && prob(10))
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
/datum/reagent/diethylamine/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	if(chems.has_reagent(src.type, 1))
		mytray.adjust_plant_health(round(chems.get_reagent_amount(src.type) * 1))
		mytray.adjust_pestlevel(-rand(1,2))
		if(myseed)
			myseed.adjust_yield(round(chems.get_reagent_amount(src.type) * 1))
			myseed.adjust_instability(-round(chems.get_reagent_amount(src.type) * 1))

/datum/reagent/carbondioxide
	name = "Carbon Dioxide"
	reagent_state = GAS
	description = "A gas commonly produced by burning carbon fuels. You're constantly producing this in your lungs."
	color = "#B0B0B0" // rgb : 192, 192, 192
	taste_description = "something unknowable"
	ph = 6
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/carbondioxide/expose_turf(turf/open/exposed_turf, reac_volume)
	if(istype(exposed_turf))
		var/temp = holder ? holder.chem_temp : T20C
		exposed_turf.atmos_spawn_air("co2=[reac_volume/20];TEMP=[temp]")
	return ..()

/datum/reagent/nitrous_oxide
	name = "Nitrous Oxide"
	description = "A potent oxidizer used as fuel in rockets and as an anaesthetic during surgery."
	reagent_state = LIQUID
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	color = "#808080"
	taste_description = "sweetness"
	ph = 5.8
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/nitrous_oxide/expose_turf(turf/open/exposed_turf, reac_volume)
	. = ..()
	if(istype(exposed_turf))
		var/temp = holder ? holder.chem_temp : T20C
		exposed_turf.atmos_spawn_air("n2o=[reac_volume/20];TEMP=[temp]")

/datum/reagent/nitrous_oxide/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	. = ..()
	if(methods & VAPOR)
		exposed_mob.adjust_drowsyness(max(round(reac_volume, 1), 2))

/datum/reagent/nitrous_oxide/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.adjust_drowsyness(2 * REM * delta_time)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.blood_volume = max(H.blood_volume - (10 * REM * delta_time), 0)
	if(DT_PROB(10, delta_time))
		M.losebreath += 2
		M.set_confusion(min(M.get_confusion() + 2, 5))
	..()

/datum/reagent/nitrium_high_metabolization
	name = "Nitrosyl plasmide"
	description = "A highly reactive byproduct that stops you from sleeping, while dealing increasing toxin damage over time."
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM * 0.5 // Because nitrium/freon/hypernoblium are handled through gas breathing, metabolism must be lower for breathcode to keep up
	color = "E1A116"
	taste_description = "sourness"
	ph = 1.8
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE
	addiction_types = list(/datum/addiction/stimulants = 14)

/datum/reagent/nitrium_high_metabolization/on_mob_metabolize(mob/living/L)
	. = ..()
	ADD_TRAIT(L, TRAIT_STUNIMMUNE, type)
	ADD_TRAIT(L, TRAIT_SLEEPIMMUNE, type)

/datum/reagent/nitrium_high_metabolization/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_STUNIMMUNE, type)
	REMOVE_TRAIT(L, TRAIT_SLEEPIMMUNE, type)
	return ..()

/datum/reagent/nitrium_high_metabolization/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.adjustStaminaLoss(-2 * REM * delta_time, 0)
	M.adjustToxLoss(0.1 * current_cycle * REM * delta_time, 0) // 1 toxin damage per cycle at cycle 10
	return ..()

/datum/reagent/nitrium_low_metabolization
	name = "Nitrium"
	description = "A highly reactive gas that makes you feel faster."
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM * 0.5 // Because nitrium/freon/hypernoblium are handled through gas breathing, metabolism must be lower for breathcode to keep up
	color = "90560B"
	taste_description = "burning"
	ph = 2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/nitrium_low_metabolization/on_mob_metabolize(mob/living/L)
	. = ..()
	L.add_movespeed_modifier(/datum/movespeed_modifier/reagent/nitrium)

/datum/reagent/nitrium_low_metabolization/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/nitrium)
	return ..()

/datum/reagent/freon
	name = "Freon"
	description = "A powerful heat absorbent."
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM * 0.5 // Because nitrium/freon/hypernoblium are handled through gas breathing, metabolism must be lower for breathcode to keep up
	color = "90560B"
	taste_description = "burning"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/freon/on_mob_metabolize(mob/living/L)
	. = ..()
	L.add_movespeed_modifier(/datum/movespeed_modifier/reagent/freon)

/datum/reagent/freon/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/freon)
	return ..()

/datum/reagent/hypernoblium
	name = "Hyper-Noblium"
	description = "A suppressive gas that stops gas reactions on those who inhale it."
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM * 0.5 // Because nitrium/freon/hyper-nob are handled through gas breathing, metabolism must be lower for breathcode to keep up
	color = "90560B"
	taste_description = "searingly cold"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/hypernoblium/on_mob_metabolize(mob/living/L)
	. = ..()
	if(isplasmaman(L))
		ADD_TRAIT(L, TRAIT_NOFIRE, type)

/datum/reagent/hypernoblium/on_mob_end_metabolize(mob/living/L)
	if(isplasmaman(L))
		REMOVE_TRAIT(L, TRAIT_NOFIRE, type)
	return ..()

/datum/reagent/healium
	name = "Healium"
	description = "A powerful sleeping agent with healing properties"
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM * 0.5
	color = "90560B"
	taste_description = "rubbery"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/healium/on_mob_metabolize(mob/living/L)
	. = ..()
	L.PermaSleeping()

/datum/reagent/healium/on_mob_end_metabolize(mob/living/L)
	L.SetSleeping(10)
	return ..()

/datum/reagent/healium/on_mob_life(mob/living/L, delta_time, times_fired)
	. = ..()
	L.adjustFireLoss(-2 * REM * delta_time, FALSE)
	L.adjustToxLoss(-5 * REM * delta_time, FALSE)
	L.adjustBruteLoss(-2 * REM * delta_time, FALSE)

/datum/reagent/halon
	name = "Halon"
	description = "A fire suppression gas that removes oxygen and cools down the area"
	reagent_state = GAS
	metabolization_rate = REAGENTS_METABOLISM * 0.5
	color = "90560B"
	taste_description = "minty"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/halon/on_mob_metabolize(mob/living/L)
	. = ..()
	L.add_movespeed_modifier(/datum/movespeed_modifier/reagent/halon)
	ADD_TRAIT(L, TRAIT_RESISTHEAT, type)

/datum/reagent/halon/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/halon)
	REMOVE_TRAIT(L, TRAIT_RESISTHEAT, type)
	return ..()

/////////////////////////Colorful Powder////////////////////////////
//For colouring in /proc/mix_color_from_reagents

/datum/reagent/colorful_reagent/powder
	name = "Mundane Powder" //the name's a bit similar to the name of colorful reagent, but hey, they're practically the same chem anyway
	var/colorname = "none"
	description = "A powder that is used for coloring things."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 207, 54, 0
	taste_description = "the back of class"

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
	color = "#DA0000" // red
	random_color_list = list("#FC7474")
	ph = 0.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/orange
	name = "Orange Powder"
	colorname = "orange"
	color = "#FF9300" // orange
	random_color_list = list("#FF9300")
	ph = 2

/datum/reagent/colorful_reagent/powder/yellow
	name = "Yellow Powder"
	colorname = "yellow"
	color = "#FFF200" // yellow
	random_color_list = list("#FFF200")
	ph = 5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/green
	name = "Green Powder"
	colorname = "green"
	color = "#A8E61D" // green
	random_color_list = list("#A8E61D")
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/blue
	name = "Blue Powder"
	colorname = "blue"
	color = "#00B7EF" // blue
	random_color_list = list("#71CAE5")
	ph = 10
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/purple
	name = "Purple Powder"
	colorname = "purple"
	color = "#DA00FF" // purple
	random_color_list = list("#BD8FC4")
	ph = 13
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/invisible
	name = "Invisible Powder"
	colorname = "invisible"
	color = "#FFFFFF00" // white + no alpha
	random_color_list = list("#FFFFFF") //because using the powder color turns things invisible
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/black
	name = "Black Powder"
	colorname = "black"
	color = "#1C1C1C" // not quite black
	random_color_list = list("#8D8D8D") //more grey than black, not enough to hide your true colors
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/white
	name = "White Powder"
	colorname = "white"
	color = "#FFFFFF" // white
	random_color_list = list("#FFFFFF") //doesn't actually change appearance at all
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/* used by crayons, can't color living things but still used for stuff like food recipes */

/datum/reagent/colorful_reagent/powder/red/crayon
	name = "Red Crayon Powder"
	can_colour_mobs = FALSE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/orange/crayon
	name = "Orange Crayon Powder"
	can_colour_mobs = FALSE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/yellow/crayon
	name = "Yellow Crayon Powder"
	can_colour_mobs = FALSE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/green/crayon
	name = "Green Crayon Powder"
	can_colour_mobs = FALSE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/blue/crayon
	name = "Blue Crayon Powder"
	can_colour_mobs = FALSE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/purple/crayon
	name = "Purple Crayon Powder"
	can_colour_mobs = FALSE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

//datum/reagent/colorful_reagent/powder/invisible/crayon

/datum/reagent/colorful_reagent/powder/black/crayon
	name = "Black Crayon Powder"
	can_colour_mobs = FALSE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent/powder/white/crayon
	name = "White Crayon Powder"
	can_colour_mobs = FALSE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

//////////////////////////////////Hydroponics stuff///////////////////////////////

/datum/reagent/plantnutriment
	name = "Generic Nutriment"
	description = "Some kind of nutriment. You can't really tell what it is. You should probably report it, along with how you obtained it."
	color = "#000000" // RBG: 0, 0, 0
	var/tox_prob = 0
	taste_description = "plant food"
	ph = 3

/datum/reagent/plantnutriment/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(DT_PROB(tox_prob, delta_time))
		M.adjustToxLoss(1, 0)
		. = TRUE
	..()

/datum/reagent/plantnutriment/eznutriment
	name = "E-Z-Nutrient"
	description = "Contains electrolytes. It's what plants crave."
	color = "#376400" // RBG: 50, 100, 0
	tox_prob = 5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/plantnutriment/eznutriment/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray)
	. = ..()
	if(myseed && chems.has_reagent(src.type, 1))
		myseed.adjust_instability(0.2)
		myseed.adjust_potency(round(chems.get_reagent_amount(src.type) * 0.3))
		myseed.adjust_yield(round(chems.get_reagent_amount(src.type) * 0.1))

/datum/reagent/plantnutriment/left4zednutriment
	name = "Left 4 Zed"
	description = "Unstable nutriment that makes plants mutate more often than usual."
	color = "#1A1E4D" // RBG: 26, 30, 77
	tox_prob = 13
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/plantnutriment/left4zednutriment/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray)
	. = ..()
	if(myseed && chems.has_reagent(src.type, 1))
		mytray.adjust_plant_health(round(chems.get_reagent_amount(src.type) * 0.1))
		myseed.adjust_instability(round(chems.get_reagent_amount(src.type) * 0.2))

/datum/reagent/plantnutriment/robustharvestnutriment
	name = "Robust Harvest"
	description = "Very potent nutriment that slows plants from mutating."
	color = "#9D9D00" // RBG: 157, 157, 0
	tox_prob = 8
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/plantnutriment/robustharvestnutriment/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray)
	. = ..()
	if(myseed && chems.has_reagent(src.type, 1))
		myseed.adjust_instability(-0.25)
		myseed.adjust_potency(round(chems.get_reagent_amount(src.type) * 0.1))
		myseed.adjust_yield(round(chems.get_reagent_amount(src.type) * 0.2))

/datum/reagent/plantnutriment/endurogrow
	name = "Enduro Grow"
	description = "A specialized nutriment, which decreases product quantity and potency, but strengthens the plants endurance."
	color = "#a06fa7" // RBG: 160, 111, 167
	tox_prob = 8
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/plantnutriment/endurogrow/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray)
	. = ..()
	if(myseed && chems.has_reagent(src.type, 1))
		myseed.adjust_potency(-round(chems.get_reagent_amount(src.type) * 0.1))
		myseed.adjust_yield(-round(chems.get_reagent_amount(src.type) * 0.075))
		myseed.adjust_endurance(round(chems.get_reagent_amount(src.type) * 0.35))

/datum/reagent/plantnutriment/liquidearthquake
	name = "Liquid Earthquake"
	description = "A specialized nutriment, which increases the plant's production speed, as well as it's susceptibility to weeds."
	color = "#912e00" // RBG: 145, 46, 0
	tox_prob = 13
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/plantnutriment/liquidearthquake/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray)
	. = ..()
	if(myseed && chems.has_reagent(src.type, 1))
		myseed.adjust_weed_rate(round(chems.get_reagent_amount(src.type) * 0.1))
		myseed.adjust_weed_chance(round(chems.get_reagent_amount(src.type) * 0.3))
		myseed.adjust_production(-round(chems.get_reagent_amount(src.type) * 0.075))

// GOON OTHERS



/datum/reagent/fuel/oil
	name = "Oil"
	description = "Burns in a small smoky fire, can be used to get Ash."
	reagent_state = LIQUID
	color = "#2D2D2D"
	taste_description = "oil"
	burning_temperature = 1200//Oil is crude
	burning_volume = 0.05 //but has a lot of hydrocarbons
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = null

/datum/reagent/stable_plasma
	name = "Stable Plasma"
	description = "Non-flammable plasma locked into a liquid form that cannot ignite or become gaseous/solid."
	reagent_state = LIQUID
	color = "#2D2D2D"
	taste_description = "bitterness"
	taste_mult = 1.5
	ph = 1.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/stable_plasma/on_mob_life(mob/living/carbon/C, delta_time, times_fired)
	C.adjustPlasma(10 * REM * delta_time)
	..()

/datum/reagent/iodine
	name = "Iodine"
	description = "Commonly added to table salt as a nutrient. On its own it tastes far less pleasing."
	reagent_state = LIQUID
	color = "#BC8A00"
	taste_description = "metal"
	ph = 4.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/carpet
	name = "Carpet"
	description = "For those that need a more creative way to roll out a red carpet."
	reagent_state = LIQUID
	color = "#771100"
	taste_description = "carpet" // Your tounge feels furry.
	var/carpet_type = /turf/open/floor/carpet
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/carpet/expose_turf(turf/exposed_turf, reac_volume)
	if(isplatingturf(exposed_turf) || istype(exposed_turf, /turf/open/floor/iron))
		var/turf/open/floor/target_floor = exposed_turf
		target_floor.PlaceOnTop(carpet_type, flags = CHANGETURF_INHERIT_AIR)
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
	color = "#A8E61D"
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

/datum/reagent/carpet/royal/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	var/obj/item/organ/liver/liver = M.getorganslot(ORGAN_SLOT_LIVER)
	if(liver)
		// Heads of staff and the captain have a "royal metabolism"
		if(HAS_TRAIT(liver, TRAIT_ROYAL_METABOLISM))
			if(DT_PROB(5, delta_time))
				to_chat(M, "You feel like royalty.")
			if(DT_PROB(2.5, delta_time))
				M.say(pick("Peasants..","This carpet is worth more than your contracts!","I could fire you at any time..."), forced = "royal carpet")

		// The quartermaster, as a semi-head, has a "pretender royal" metabolism
		else if(HAS_TRAIT(liver, TRAIT_PRETENDER_ROYAL_METABOLISM))
			if(DT_PROB(8, delta_time))
				to_chat(M, "You feel like an impostor...")

/datum/reagent/carpet/royal/black
	name = "Royal Black Carpet"
	description = "For those that feel the need to show off their timewasting skills."
	color = "#000000"
	taste_description = "royalty"
	carpet_type = /turf/open/floor/carpet/royalblack
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/carpet/royal/blue
	name = "Royal Blue Carpet"
	description = "For those that feel the need to show off their timewasting skills.. in BLUE."
	color = "#5A64C8"
	taste_description = "blueyalty" //also intentional
	carpet_type = /turf/open/floor/carpet/royalblue
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/carpet/neon
	name = "Neon Carpet"
	description = "For those who like the 1980s, vegas, and debugging."
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
	reagent_state = LIQUID
	color = "#D35415"
	taste_description = "chemicals"
	ph = 7.8
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/pentaerythritol
	name = "Pentaerythritol"
	description = "Slow down, it ain't no spelling bee!"
	reagent_state = SOLID
	color = "#E66FFF"
	taste_description = "acid"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/acetaldehyde
	name = "Acetaldehyde"
	description = "Similar to plastic. Tastes like dead people."
	reagent_state = SOLID
	color = "#EEEEEF"
	taste_description = "dead people" //made from formaldehyde, ya get da joke ?
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/acetone_oxide
	name = "Acetone Oxide"
	description = "Enslaved oxygen"
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "acid"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED


/datum/reagent/acetone_oxide/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)//Splashing people kills people!
	. = ..()
	if(methods & TOUCH)
		exposed_mob.adjustFireLoss(2, FALSE) // burns,
		exposed_mob.adjust_fire_stacks((reac_volume / 10))



/datum/reagent/phenol
	name = "Phenol"
	description = "An aromatic ring of carbon with a hydroxyl group. A useful precursor to some medicines, but has no healing properties on its own."
	reagent_state = LIQUID
	color = "#E7EA91"
	taste_description = "acid"
	ph = 5.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/ash
	name = "Ash"
	description = "Supposedly phoenixes rise from these, but you've never seen it."
	reagent_state = LIQUID
	color = "#515151"
	taste_description = "ash"
	ph = 6.5
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

// Ash is also used IRL in gardening, as a fertilizer enhancer and weed killer
/datum/reagent/ash/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	if(chems.has_reagent(src.type, 1))
		mytray.adjust_plant_health(round(chems.get_reagent_amount(src.type) * 1))
		mytray.adjust_weedlevel(-1)

/datum/reagent/acetone
	name = "Acetone"
	description = "A slick, slightly carcinogenic liquid. Has a multitude of mundane uses in everyday life."
	reagent_state = LIQUID
	color = "#AF14B7"
	taste_description = "acid"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/colorful_reagent
	name = "Colorful Reagent"
	description = "Thoroughly sample the rainbow."
	reagent_state = LIQUID
	var/list/random_color_list = list("#00aedb","#a200ff","#f47835","#d41243","#d11141","#00b159","#00aedb","#f37735","#ffc425","#008744","#0057e7","#d62d20","#ffa700")
	color = "#C8A5DC"
	taste_description = "rainbows"
	var/can_colour_mobs = TRUE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	var/datum/callback/color_callback

/datum/reagent/colorful_reagent/New()
	color_callback = CALLBACK(src, .proc/UpdateColor)
	SSticker.OnRoundstart(color_callback)
	return ..()

/datum/reagent/colorful_reagent/Destroy()
	LAZYREMOVE(SSticker.round_end_events, color_callback) //Prevents harddels during roundstart
	color_callback = null //Fly free little callback
	return ..()

/datum/reagent/colorful_reagent/proc/UpdateColor()
	color_callback = null
	color = pick(random_color_list)

/datum/reagent/colorful_reagent/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(can_colour_mobs)
		M.add_atom_colour(pick(random_color_list), WASHABLE_COLOUR_PRIORITY)
	return ..()

/// Colors anything it touches a random color.
/datum/reagent/colorful_reagent/expose_atom(atom/exposed_atom, reac_volume)
	. = ..()
	if(!isliving(exposed_atom) || can_colour_mobs)
		exposed_atom.add_atom_colour(pick(random_color_list), WASHABLE_COLOUR_PRIORITY)

/datum/reagent/hair_dye
	name = "Quantum Hair Dye"
	description = "Has a high chance of making you look like a mad scientist."
	reagent_state = LIQUID
	var/list/potential_colors = list("#00aadd","#aa00ff","#ff7733","#dd1144","#dd1144","#00bb55","#00aadd","#ff7733","#ffcc22","#008844","#0055ee","#dd2222","#ffaa00") // fucking hair code
	color = "#C8A5DC"
	taste_description = "sourness"
	penetrates_skin = NONE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/hair_dye/New()
	SSticker.OnRoundstart(CALLBACK(src,.proc/UpdateColor))
	return ..()

/datum/reagent/hair_dye/proc/UpdateColor()
	color = pick(potential_colors)

/datum/reagent/hair_dye/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message=TRUE, touch_protection=FALSE)
	. = ..()
	if(!(methods & (TOUCH|VAPOR)) || !ishuman(exposed_mob))
		return

	var/mob/living/carbon/human/exposed_human = exposed_mob
	exposed_human.hair_color = pick(potential_colors)
	exposed_human.facial_hair_color = pick(potential_colors)
	exposed_human.update_hair()

/datum/reagent/barbers_aid
	name = "Barber's Aid"
	description = "A solution to hair loss across the world."
	reagent_state = LIQUID
	color = "#A86B45" //hair is brown
	taste_description = "sourness"
	penetrates_skin = NONE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/barbers_aid/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message=TRUE, touch_protection=FALSE)
	. = ..()
	if(!(methods & (TOUCH|VAPOR)) || !ishuman(exposed_mob) || HAS_TRAIT(exposed_mob, TRAIT_BALD))
		return

	var/mob/living/carbon/human/exposed_human = exposed_mob
	var/datum/sprite_accessory/hair/picked_hair = pick(GLOB.hairstyles_list)
	var/datum/sprite_accessory/facial_hair/picked_beard = pick(GLOB.facial_hairstyles_list)
	to_chat(exposed_human, span_notice("Hair starts sprouting from your scalp."))
	exposed_human.hairstyle = picked_hair
	exposed_human.facial_hairstyle = picked_beard
	exposed_human.update_hair()

/datum/reagent/concentrated_barbers_aid
	name = "Concentrated Barber's Aid"
	description = "A concentrated solution to hair loss across the world."
	reagent_state = LIQUID
	color = "#7A4E33" //hair is dark browmn
	taste_description = "sourness"
	penetrates_skin = NONE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/concentrated_barbers_aid/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message=TRUE, touch_protection=FALSE)
	. = ..()
	if(!(methods & (TOUCH|VAPOR)) || !ishuman(exposed_mob) || HAS_TRAIT(exposed_mob, TRAIT_BALD))
		return

	var/mob/living/carbon/human/exposed_human = exposed_mob
	to_chat(exposed_human, span_notice("Your hair starts growing at an incredible speed!"))
	exposed_human.hairstyle = "Very Long Hair"
	exposed_human.facial_hairstyle = "Beard (Very Long)"
	exposed_human.update_hair()

/datum/reagent/baldium
	name = "Baldium"
	description = "A major cause of hair loss across the world."
	reagent_state = LIQUID
	color = "#ecb2cf"
	taste_description = "bitterness"
	penetrates_skin = NONE
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/baldium/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message=TRUE, touch_protection=FALSE)
	. = ..()
	if(!(methods & (TOUCH|VAPOR)) || !ishuman(exposed_mob))
		return

	var/mob/living/carbon/human/exposed_human = exposed_mob
	to_chat(exposed_human, span_danger("Your hair is falling out in clumps!"))
	exposed_human.hairstyle = "Bald"
	exposed_human.facial_hairstyle = "Shaved"
	exposed_human.update_hair()

/datum/reagent/saltpetre
	name = "Saltpetre"
	description = "Volatile. Controversial. Third Thing."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	taste_description = "cool salt"
	ph = 11.2
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

// Saltpetre is used for gardening IRL, to simplify highly, it speeds up growth and strengthens plants
/datum/reagent/saltpetre/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	if(chems.has_reagent(src.type, 1))
		var/salt = chems.get_reagent_amount(src.type)
		mytray.adjust_plant_health(round(salt * 0.18))
		if(myseed)
			myseed.adjust_production(-round(salt/10)-prob(salt%10))
			myseed.adjust_potency(round(salt*1))

/datum/reagent/lye
	name = "Lye"
	description = "Also known as sodium hydroxide. As a profession making this is somewhat underwhelming."
	reagent_state = LIQUID
	color = "#FFFFD6" // very very light yellow
	taste_description = "acid"
	ph = 11.9
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/drying_agent
	name = "Drying Agent"
	description = "A desiccant. Can be used to dry things."
	reagent_state = LIQUID
	color = "#A70FFF"
	taste_description = "dryness"
	ph = 10.7
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/drying_agent/expose_turf(turf/open/exposed_turf, reac_volume)
	. = ..()
	if(!istype(exposed_turf))
		return
	exposed_turf.MakeDry(ALL, TRUE, reac_volume * 5 SECONDS) //50 deciseconds per unit

/datum/reagent/drying_agent/expose_obj(obj/exposed_obj, reac_volume)
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

/datum/reagent/royal_bee_jelly/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(DT_PROB(1, delta_time))
		M.say(pick("Bzzz...","BZZ BZZ","Bzzzzzzzzzzz..."), forced = "royal bee jelly")
	..()

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

/datum/reagent/romerol/expose_mob(mob/living/carbon/human/exposed_mob, methods=TOUCH, reac_volume)
	. = ..()
	// Silently add the zombie infection organ to be activated upon death
	if(!exposed_mob.getorganslot(ORGAN_SLOT_ZOMBIE))
		var/obj/item/organ/zombie_infection/nodamage/ZI = new()
		ZI.Insert(exposed_mob)

/datum/reagent/magillitis
	name = "Magillitis"
	description = "An experimental serum which causes rapid muscular growth in Hominidae. Side-affects may include hypertrichosis, violent outbursts, and an unending affinity for bananas."
	reagent_state = LIQUID
	color = "#00f041"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/magillitis/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	..()
	if((ishuman(M)) && current_cycle >= 10)
		M.gorillize()

/datum/reagent/growthserum
	name = "Growth Serum"
	description = "A commercial chemical designed to help older men in the bedroom."//not really it just makes you a giant
	color = "#ff0000"//strong red. rgb 255, 0, 0
	var/current_size = RESIZE_DEFAULT_SIZE
	taste_description = "bitterness" // apparently what viagra tastes like
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/growthserum/on_mob_life(mob/living/carbon/H, delta_time, times_fired)
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

	H.resize = newsize/current_size
	current_size = newsize
	H.update_transform()
	..()

/datum/reagent/growthserum/on_mob_end_metabolize(mob/living/M)
	M.resize = RESIZE_DEFAULT_SIZE/current_size
	current_size = RESIZE_DEFAULT_SIZE
	M.update_transform()
	..()

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
	color = "#FFFFFF" //pure white
	taste_description = "plastic"
	reagent_state = SOLID
	var/glitter_type = /obj/effect/decal/cleanable/glitter
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/glitter/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	if(!istype(exposed_turf))
		return
	new glitter_type(exposed_turf)

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

/datum/reagent/pax
	name = "Pax"
	description = "A colorless liquid that suppresses violence in its subjects."
	color = "#AAAAAA55"
	taste_description = "water"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	ph = 15
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/pax/on_mob_metabolize(mob/living/L)
	..()
	ADD_TRAIT(L, TRAIT_PACIFISM, type)

/datum/reagent/pax/on_mob_end_metabolize(mob/living/L)
	REMOVE_TRAIT(L, TRAIT_PACIFISM, type)
	..()

/datum/reagent/bz_metabolites
	name = "BZ Metabolites"
	description = "A harmless metabolite of BZ gas."
	color = "#FAFF00"
	taste_description = "acrid cinnamon"
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/bz_metabolites/on_mob_life(mob/living/carbon/target, delta_time, times_fired)
	if(target.mind)
		var/datum/antagonist/changeling/changeling = target.mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling)
			changeling.adjust_chemicals(-2 * REM * delta_time)
	return ..()

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

/datum/reagent/peaceborg/confuse/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(M.get_confusion() < 6)
		M.set_confusion(clamp(M.get_confusion() + (3 * REM * delta_time), 0, 5))
	if(M.dizziness < 6)
		M.dizziness = clamp(M.dizziness + (3 * REM * delta_time), 0, 5)
	if(DT_PROB(10, delta_time))
		to_chat(M, "You feel confused and disoriented.")
	..()

/datum/reagent/peaceborg/tire
	name = "Tiring Solution"
	description = "An extremely weak stamina-toxin that tires out the target. Completely harmless."
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "tiredness"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/peaceborg/tire/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	var/healthcomp = (100 - M.health) //DOES NOT ACCOUNT FOR ADMINBUS THINGS THAT MAKE YOU HAVE MORE THAN 200/210 HEALTH, OR SOMETHING OTHER THAN A HUMAN PROCESSING THIS.
	if(M.getStaminaLoss() < (45 - healthcomp)) //At 50 health you would have 200 - 150 health meaning 50 compensation. 60 - 50 = 10, so would only do 10-19 stamina.)
		M.adjustStaminaLoss(10 * REM * delta_time)
	if(DT_PROB(16, delta_time))
		to_chat(M, "You should sit down and take a rest...")
	..()

/datum/reagent/gondola_mutation_toxin
	name = "Tranquility"
	description = "A highly mutative liquid of unknown origin."
	color = "#9A6750" //RGB: 154, 103, 80
	taste_description = "inner peace"
	penetrates_skin = NONE

/datum/reagent/gondola_mutation_toxin/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if((methods & (PATCH|INGEST|INJECT)) || ((methods & VAPOR) && prob(min(reac_volume,100)*(1 - touch_protection))))
		exposed_mob.ForceContractDisease(new /datum/disease/transformation/gondola(), FALSE, TRUE)


/datum/reagent/spider_extract
	name = "Spider Extract"
	description = "A highly specialized extract coming from the Australicus sector, used to create broodmother spiders."
	color = "#ED2939"
	taste_description = "upside down"

/// Improvised reagent that induces vomiting. Created by dipping a dead mouse in welder fluid.
/datum/reagent/yuck
	name = "Organic Slurry"
	description = "A mixture of various colors of fluid. Induces vomiting."
	glass_name = "glass of ...yuck!"
	glass_desc = "It smells like a carcass, and doesn't look much better."
	color = "#545000"
	taste_description = "insides"
	taste_mult = 4
	metabolization_rate = 0.4 * REAGENTS_METABOLISM
	var/yuck_cycle = 0 //! The `current_cycle` when puking starts.

/datum/reagent/yuck/on_mob_add(mob/living/L)
	. = ..()
	if(HAS_TRAIT(L, TRAIT_NOHUNGER)) //they can't puke
		holder.del_reagent(type)

#define YUCK_PUKE_CYCLES 3 // every X cycle is a puke
#define YUCK_PUKES_TO_STUN 3 // hit this amount of pukes in a row to start stunning
/datum/reagent/yuck/on_mob_life(mob/living/carbon/C, delta_time, times_fired)
	if(!yuck_cycle)
		if(DT_PROB(4, delta_time))
			var/dread = pick("Something is moving in your stomach...", \
				"A wet growl echoes from your stomach...", \
				"For a moment you feel like your surroundings are moving, but it's your stomach...")
			to_chat(C, span_userdanger("[dread]"))
			yuck_cycle = current_cycle
	else
		var/yuck_cycles = current_cycle - yuck_cycle
		if(yuck_cycles % YUCK_PUKE_CYCLES == 0)
			if(yuck_cycles >= YUCK_PUKE_CYCLES * YUCK_PUKES_TO_STUN)
				holder.remove_reagent(type, 5)
			C.vomit(rand(14, 26), stun = yuck_cycles >= YUCK_PUKE_CYCLES * YUCK_PUKES_TO_STUN)
	if(holder)
		return ..()
#undef YUCK_PUKE_CYCLES
#undef YUCK_PUKES_TO_STUN

/datum/reagent/yuck/on_mob_end_metabolize(mob/living/L)
	yuck_cycle = 0 // reset vomiting
	return ..()

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
	color = "#FFFFFF" // rgb: 255, 255, 255
	taste_mult = 0 // oderless and tasteless
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/metalgen
	name = "Metalgen"
	data = list("material"=null)
	description = "A purple metal morphic liquid, said to impose it's metallic properties on whatever it touches."
	color = "#b000aa"
	taste_mult = 0 // oderless and tasteless
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE
	/// The material flags used to apply the transmuted materials
	var/applied_material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR
	/// The amount of materials to apply to the transmuted objects if they don't contain materials
	var/default_material_amount = 100

/datum/reagent/metalgen/expose_obj(obj/exposed_obj, volume)
	. = ..()
	metal_morph(exposed_obj)

/datum/reagent/metalgen/expose_turf(turf/exposed_turf, volume)
	. = ..()
	metal_morph(exposed_turf)

///turn an object into a special material
/datum/reagent/metalgen/proc/metal_morph(atom/A)
	var/metal_ref = data["material"]
	if(!metal_ref)
		return

	var/metal_amount = 0
	var/list/materials_to_transmute = A.get_material_composition(BREAKDOWN_INCLUDE_ALCHEMY)
	for(var/metal_key in materials_to_transmute) //list with what they're made of
		metal_amount += materials_to_transmute[metal_key]

	if(!metal_amount)
		metal_amount = default_material_amount //some stuff doesn't have materials at all. To still give them properties, we give them a material. Basically doesn't exist

	var/list/metal_dat = list((metal_ref) = metal_amount)
	A.material_flags = applied_material_flags
	A.set_custom_materials(metal_dat)
	ADD_TRAIT(A, TRAIT_MAT_TRANSMUTED, type)

/datum/reagent/gravitum
	name = "Gravitum"
	description = "A rare kind of null fluid, capable of temporalily removing all weight of whatever it touches." //i dont even
	color = "#050096" // rgb: 5, 0, 150
	taste_mult = 0 // oderless and tasteless
	metabolization_rate = 0.1 * REAGENTS_METABOLISM //20 times as long, so it's actually viable to use
	var/time_multiplier = 1 MINUTES //1 minute per unit of gravitum on objects. Seems overpowered, but the whole thing is very niche
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/gravitum/expose_obj(obj/exposed_obj, volume)
	. = ..()
	exposed_obj.AddElement(/datum/element/forced_gravity, 0)
	addtimer(CALLBACK(exposed_obj, .proc/_RemoveElement, list(/datum/element/forced_gravity, 0)), volume * time_multiplier)

/datum/reagent/gravitum/on_mob_add(mob/living/L)
	L.AddElement(/datum/element/forced_gravity, 0) //0 is the gravity, and in this case weightless
	return ..()

/datum/reagent/gravitum/on_mob_end_metabolize(mob/living/L)
	L.RemoveElement(/datum/element/forced_gravity, 0)

/datum/reagent/cellulose
	name = "Cellulose Fibers"
	description = "A crystaline polydextrose polymer, plants swear by this stuff."
	reagent_state = SOLID
	color = "#E6E6DA"
	taste_mult = 0
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

// "Second wind" reagent generated when someone suffers a wound. Epinephrine, adrenaline, and stimulants are all already taken so here we are
/datum/reagent/determination
	name = "Determination"
	description = "For when you need to push on a little more. Do NOT allow near plants."
	reagent_state = LIQUID
	color = "#D2FFFA"
	metabolization_rate = 0.75 * REAGENTS_METABOLISM // 5u (WOUND_DETERMINATION_CRITICAL) will last for ~34 seconds
	self_consuming = TRUE
	/// Whether we've had at least WOUND_DETERMINATION_SEVERE (2.5u) of determination at any given time. No damage slowdown immunity or indication we're having a second wind if it's just a single moderate wound
	var/significant = FALSE

/datum/reagent/determination/on_mob_end_metabolize(mob/living/carbon/M)
	if(significant)
		var/stam_crash = 0
		for(var/thing in M.all_wounds)
			var/datum/wound/W = thing
			stam_crash += (W.severity + 1) * 3 // spike of 3 stam damage per wound severity (moderate = 6, severe = 9, critical = 12) when the determination wears off if it was a combat rush
		M.adjustStaminaLoss(stam_crash)
	M.remove_status_effect(/datum/status_effect/determined)
	..()

/datum/reagent/determination/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(!significant && volume >= WOUND_DETERMINATION_SEVERE)
		significant = TRUE
		M.apply_status_effect(/datum/status_effect/determined) // in addition to the slight healing, limping cooldowns are divided by 4 during the combat high

	volume = min(volume, WOUND_DETERMINATION_MAX)

	for(var/thing in M.all_wounds)
		var/datum/wound/W = thing
		var/obj/item/bodypart/wounded_part = W.limb
		if(wounded_part)
			wounded_part.heal_damage(0.25 * REM * delta_time, 0.25 * REM * delta_time)
		M.adjustStaminaLoss(-0.25 * REM * delta_time) // the more wounds, the more stamina regen
	..()

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
	color = "#1f8016"
	metabolization_rate = 2.5 * REAGENTS_METABOLISM  //0.5u/second
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE

/datum/reagent/eldritch/on_mob_life(mob/living/carbon/drinker, delta_time, times_fired)
	if(IS_HERETIC(drinker))
		drinker.adjust_drowsyness(-5 * REM * delta_time)
		drinker.AdjustAllImmobility(-40 * REM * delta_time)
		drinker.adjustStaminaLoss(-10 * REM * delta_time, FALSE)
		drinker.adjustToxLoss(-2 * REM * delta_time, FALSE, forced = TRUE)
		drinker.adjustOxyLoss(-2 * REM * delta_time, FALSE)
		drinker.adjustBruteLoss(-2 * REM * delta_time, FALSE)
		drinker.adjustFireLoss(-2 * REM * delta_time, FALSE)
		if(drinker.blood_volume < BLOOD_VOLUME_NORMAL)
			drinker.blood_volume += 3 * REM * delta_time
	else
		drinker.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3 * REM * delta_time, 150)
		drinker.adjustToxLoss(2 * REM * delta_time, FALSE)
		drinker.adjustFireLoss(2 * REM * delta_time, FALSE)
		drinker.adjustOxyLoss(2 * REM * delta_time, FALSE)
		drinker.adjustBruteLoss(2 * REM * delta_time, FALSE)
	..()
	return TRUE

/datum/reagent/universal_indicator
	name = "Universal Indicator"
	description = "A solution that can be used to create pH paper booklets, or sprayed on things to colour them by their pH."
	taste_description = "a strong chemical taste"
	color = "#1f8016"

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
	reagent_state = SOLID
	color = "#993333"
	taste_mult = 1.3
	taste_description = "tiny legs scuttling down the back of your throat"
	metabolization_rate = 5 * REAGENTS_METABOLISM //1u per second
	glass_name = "glass of ants"
	glass_desc = "Bottoms up...?"
	ph = 4.6 // Ants contain Formic Acid
	/// How much damage the ants are going to be doing (rises with each tick the ants are in someone's body)
	var/ant_damage = 0
	/// Tells the debuff how many ants we are being covered with.
	var/amount_left = 0

/datum/reagent/ants/on_mob_life(mob/living/carbon/victim, delta_time)
	victim.adjustBruteLoss(max(0.1, round((ant_damage * 0.025),0.1))) //Scales with time. Roughly 32 brute with 100u.
	if(DT_PROB(5, delta_time))
		if(DT_PROB(5, delta_time)) //Super rare statement
			victim.say("AUGH NO NOT THE ANTS! NOT THE ANTS! AAAAUUGH THEY'RE IN MY EYES! MY EYES! AUUGH!!", forced = /datum/reagent/ants)
		else
			victim.say(pick("THEY'RE UNDER MY SKIN!!", "GET THEM OUT OF ME!!", "HOLY HELL THEY BURN!!", "MY GOD THEY'RE INSIDE ME!!", "GET THEM OUT!!"), forced = /datum/reagent/ants)
	if(DT_PROB(15, delta_time))
		victim.emote("scream")
	if(DT_PROB(2, delta_time)) // Stuns, but purges ants.
		victim.vomit(rand(5,10), FALSE, TRUE, 1, TRUE, FALSE, purge_ratio = 1)
	ant_damage++
	return ..()

/datum/reagent/ants/on_mob_end_metabolize(mob/living/living_anthill)
	ant_damage = 0
	to_chat(living_anthill, "<span class='notice'>You feel like the last of the ants are out of your system.</span>")
	return ..()

/datum/reagent/ants/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	. = ..()
	if(!iscarbon(exposed_mob) || (methods & (INGEST|INJECT)))
		return
	if(methods & (PATCH|TOUCH|VAPOR))
		amount_left = round(reac_volume,0.1)
		exposed_mob.apply_status_effect(/datum/status_effect/ants, amount_left)

/datum/reagent/ants/expose_obj(obj/exposed_obj, reac_volume)
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
	if(!istype(exposed_turf) || isspaceturf(exposed_turf)) // Is the turf valid
		return
	if((reac_volume <= 10)) // Makes sure people don't duplicate ants.
		return

	var/obj/effect/decal/cleanable/ants/pests = locate() in exposed_turf.contents
	if(!pests)
		pests = new(exposed_turf)
	var/spilled_ants = (round(reac_volume,1) - 5) // To account for ant decals giving 3-5 ants on initialize.
	pests.reagents.add_reagent(/datum/reagent/ants, spilled_ants)
	pests.update_ant_damage(spilled_ants)

//This is intended to a be a scarce reagent to gate certain drugs and toxins with. Do not put in a synthesizer. Renewable sources of this reagent should be inefficient.
/datum/reagent/lead
	name = "Lead"
	description = "A dull metalltic element with a low melting point."
	taste_description = "metal"
	reagent_state = SOLID
	color = "#80919d"
	metabolization_rate = 0.4 * REAGENTS_METABOLISM

/datum/reagent/lead/on_mob_life(mob/living/carbon/victim)
	. = ..()
	victim.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.5)

//The main feedstock for kronkaine production, also a shitty stamina healer.
/datum/reagent/kronkus_extract
	name = "Kronkus Extract"
	description = "A frothy extract made from fermented kronkus vine pulp.\nHighly bitter due to the presence of a variety of kronkamines."
	taste_description = "bitterness"
	color = "#228f63"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	addiction_types = list(/datum/addiction/stimulants = 5)

/datum/reagent/kronkus_extract/on_mob_life(mob/living/carbon/kronkus_enjoyer)
	. = ..()
	kronkus_enjoyer.adjustOrganLoss(ORGAN_SLOT_HEART, 0.1)
	kronkus_enjoyer.adjustStaminaLoss(-2, FALSE)

/datum/reagent/brimdust
	name = "Brimdust"
	description = "A brimdemon's dust. Consumption is not recommended, although plants like it."
	reagent_state = SOLID
	color = "#522546"
	taste_description = "burning"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/reagent/brimdust/on_mob_life(mob/living/carbon/carbon, delta_time, times_fired)
	. = ..()
	carbon.adjustFireLoss((ispodperson(carbon) ? -1 : 1) * delta_time)

/datum/reagent/brimdust/on_hydroponics_apply(obj/item/seeds/myseed, datum/reagents/chems, obj/machinery/hydroponics/mytray, mob/user)
	. = ..()
	if(chems.has_reagent(src.type, 1))
		mytray.adjust_weedlevel(-1)
		mytray.adjust_pestlevel(-1)
		mytray.adjust_plant_health(round(chems.get_reagent_amount(src.type) * 1))
		if(myseed)
			myseed.adjust_potency(round(chems.get_reagent_amount(src.type) * 0.5))
