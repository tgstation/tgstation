

/datum/symptom/cough
	max_chance = 10
	stage = 2
	badness = EFFECT_DANGER_ANNOYING

/datum/symptom/cough/activate(mob/living/carbon/mob)
	mob.emote("cough")
	
	var/datum/gas_mixture/breath
	if (ishuman(mob))
		var/mob/living/carbon/human/H = mob
		breath = H.get_breath_from_internal(BREATH_VOLUME)
	if(!breath)//not wearing internals
		var/head_block = 0
		if (ishuman(mob))
			var/mob/living/carbon/human/H = mob
			if (H.head && (H.head.flags_cover & HEADCOVERSMOUTH))
				head_block = 1
		if(!head_block)
			if(!mob.wear_mask || !(mob.wear_mask.flags_cover & MASKCOVERSMOUTH))
				if(isturf(mob.loc))
					if(mob.check_airborne_sterility())
						return
					var/strength = 0
					for (var/datum/disease/advanced/V in mob.diseases)
						strength += V.infectionchance
					strength = round(strength / mob.diseases.len)
					var/i = 1
					while (strength > 0 && i < 10) //stronger viruses create more clouds at once, max limit of 10 clouds
						new /obj/effect/pathogen_cloud/core(get_turf(src), mob, virus_copylist(mob.diseases))
						strength -= 30
						i++

/datum/symptom/beard
	name = "Facial Hypertrichosis"
	desc = "Causes the infected to spontaneously grow a beard, regardless of gender. Only affects humans."
	stage = 2
	max_multiplier = 5
	badness = EFFECT_DANGER_FLAVOR


/datum/symptom/beard/activate(mob/living/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = mob
		if(ishuman(mob))
			var/beard_name = ""
			spawn(5 SECONDS)
				if(multiplier >= 1 && multiplier < 2)
					beard_name = "Beard (Jensen)"
				if(multiplier >= 2 && multiplier < 3)
					beard_name = "Beard (Full)"
				if(multiplier >= 3 && multiplier < 4)
					beard_name = "Beard (Very Long)"
				if(multiplier >= 4)
					beard_name = "Beard (Dwarf)"
				if(beard_name != "" && H.facial_hairstyle != beard_name)
					H.facial_hairstyle = beard_name
					to_chat(H, span_warning("Your chin itches."))
					H.update_body_parts()

/datum/symptom/drowsness
	name = "Automated Sleeping Syndrome"
	desc = "Makes the infected feel more drowsy."
	stage = 2
	badness = EFFECT_DANGER_HINDRANCE
	multiplier = 5
	max_multiplier = 10

/datum/symptom/drowsness/activate(mob/living/mob)
	mob.adjust_drowsiness_up_to(multiplier, 40 SECONDS)

/datum/symptom/cough//creates pathogenic clouds that may contain even non-airborne viruses.
	name = "Anima Syndrome"
	desc = "Causes the infected to cough rapidly, releasing pathogenic clouds."
	stage = 2
	badness = EFFECT_DANGER_ANNOYING
	max_chance = 10

/datum/symptom/cough/activate(var/mob/living/mob)
	mob.emote("cough")
	if(!ishuman(mob))
		return
	var/mob/living/carbon/human/H = mob
	var/datum/gas_mixture/breath
	breath = H.get_breath_from_internal(BREATH_VOLUME)
	if(!breath)//not wearing internals
		if(!H.wear_mask)
			if(isturf(mob.loc))
				var/list/blockers = list()
				blockers = list(H.wear_mask,H.glasses,H.head)
				for (var/item in blockers)
					var/obj/item/clothing/I = item
					if (!istype(I))
						continue
					if (I.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
						return
				if(mob.check_airborne_sterility())
					return
				var/strength = 0
				for (var/datum/disease/advanced/V  as anything in mob.diseases)
					strength += V.infectionchance
				strength = round(strength/mob.diseases.len)

				var/i = 1
				while (strength > 0 && i < 10) //stronger viruses create more clouds at once, max limit of 10 clouds
					new /obj/effect/pathogen_cloud/core(get_turf(src), mob, virus_copylist(mob.diseases))
					strength -= 30
					i++

/datum/symptom/hungry
	name = "Appetiser Effect"
	desc = "Starves the infected."
	stage = 2
	badness = EFFECT_DANGER_ANNOYING
	multiplier = 10
	max_multiplier = 20

/datum/symptom/hungry/activate(mob/living/mob)
	mob.nutrition = max(0, mob.nutrition - 20*multiplier)

/datum/symptom/fridge
	name = "Refridgerator Syndrome"
	desc = "Causes the infected to shiver at random."
	encyclopedia = "No matter whether the room is cold or hot. This has no effect on their body temperature."
	stage = 2
	max_multiplier = 4
	multiplier = 1
	badness = EFFECT_DANGER_FLAVOR

/datum/symptom/fridge/activate(mob/living/mob)
	to_chat(mob, span_warning("[pick("You feel cold.", "You shiver.")]"))
	mob.emote("shiver")
	set_body_temp(mob)

/datum/symptom/fridge/proc/set_body_temp(mob/living/M)
	if(multiplier >= 3) // when unsafe the shivers can cause cold damage
		M.add_body_temperature_change("chills", -6 * power * multiplier)
	else
		// Get the max amount of change allowed before going under cold damage limit, then cap the maximum allowed temperature change from safe chills to 5 over the cold damage limit
		var/change_limit = min(M.get_body_temp_cold_damage_limit() + 5 - M.get_body_temp_normal(apply_change=FALSE), 0)
		M.add_body_temperature_change("chills", max(-6 * power * multiplier, change_limit))

/datum/symptom/fridge/deactivate(mob/living/carbon/mob)
	if(mob)
		mob.remove_body_temperature_change("chills")
	
/datum/symptom/hair
	name = "Hair Loss"
	desc = "Causes rapid hairloss in the infected."
	stage = 2
	badness = EFFECT_DANGER_FLAVOR
	multiplier = 1
	max_multiplier = 5

/datum/symptom/hair/activate(mob/living/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		if(H.hairstyle != "Bald")
			if (H.hairstyle != "Balding Hair")
				to_chat(H, span_danger("Your hair starts to fall out in clumps..."))
				if (prob(multiplier*20))
					H.hairstyle = "Balding Hair"
					H.update_body_parts()
			else
				to_chat(H, span_danger("You have almost no hair left..."))
				if (prob(multiplier*20))
					H.hairstyle = "Bald"
					H.update_body_parts()

/datum/symptom/stimulant
	name = "Adrenaline Extra"
	desc = "Causes the infected to synthesize artificial adrenaline."
	stage = 2
	badness = EFFECT_DANGER_HELPFUL
	max_multiplier = 20

/datum/symptom/stimulant/activate(mob/living/mob)
	to_chat(mob, span_notice("You feel a rush of energy inside you!"))
	if(ismouse(mob))
		mob.Shake(3,3, 10 SECONDS)
		return
	if (mob.reagents.get_reagent_amount(/datum/reagent/adrenaline) < 10)
		if(prob(5 * multiplier) && multiplier >= 8)
			mob.reagents.add_reagent(/datum/reagent/adrenaline, 11) //you are gonna probably die
		else
			mob.reagents.add_reagent(/datum/reagent/adrenaline, 4)
	if (prob(30))
		mob.adjust_jitter_up_to(1 SECONDS, 30 SECONDS)

/datum/symptom/drunk
	name = "Vermouth Syndrome"
	desc = "Causes the infected to synthesize pure ethanol."
	stage = 2
	badness = EFFECT_DANGER_HARMFUL
	multiplier = 3
	max_multiplier = 7

/datum/symptom/drunk/activate(mob/living/mob)
	if(ismouse(mob))
		return
	to_chat(mob, span_notice("You feel like you had one hell of a party!"))
	if (mob.reagents.get_reagent_amount(/datum/reagent/consumable/ethanol/vermouth) < multiplier*5)
		mob.reagents.add_reagent(/datum/reagent/consumable/ethanol/vermouth, multiplier*5)


/datum/symptom/bloodynose
	name = "Intranasal Hemorrhage"
	desc = "Causes the infected's nasal pathways to hemorrhage, causing a nosebleed, potentially carrying the pathogen."
	stage = 2
	badness = EFFECT_DANGER_ANNOYING

/datum/symptom/bloodynose/activate(mob/living/mob)
	if (prob(30))
		if (ishuman(mob))
			var/mob/living/carbon/human/H = mob
			if (!(TRAIT_NOBLOOD in H.dna.species.inherent_traits))
				H.add_splatter_floor(get_turf(mob), 1)
		else
			var/obj/effect/decal/cleanable/blood/D= locate(/obj/effect/decal/cleanable/blood) in get_turf(mob)
			if(D==null)
				D = new /obj/effect/decal/cleanable/blood(get_turf(mob))
			D.diseases |= virus_copylist(mob.diseases)


/datum/symptom/lantern
	name = "Lantern Syndrome"
	desc = "Causes the infected to glow."
	stage = 2
	badness = EFFECT_DANGER_HELPFUL
	multiplier = 4
	max_multiplier = 10
	var/uncolored = 0
	var/flavortext = 0
	var/color = rgb(255, 255, 255)

/datum/symptom/lantern/activate(mob/living/mob)
	if(ismouse(mob))
		mob.set_light(multiplier, multiplier/3, l_color = color)
		return
	if(mob.reagents.has_reagent(/datum/reagent/space_cleaner))
		uncolored = 1	//Having spacecleaner in your system when the effect activates will permanently make the color white.
	if(mob.reagents.reagent_list.len == 0 || uncolored == TRUE)
		color = rgb(255, 255, 255)
	else
		color = mix_color_from_reagents(mob.reagents.reagent_list)
	if(!flavortext)
		to_chat(mob, span_notice("You are glowing!"))
		flavortext = 1
	mob.set_light(multiplier, multiplier, multiplier/3, l_color = color)

/datum/symptom/lantern/deactivate(mob/living/mob)
	mob.set_light(0, 0, 0, l_color = rgb(0,0,0))
	to_chat(mob, span_notice("You don't feel as bright."))
	flavortext = 0

/datum/symptom/vitreous
	name = "Vitreous resonance"
	desc = "Causes the infected to shake uncontrollably, at the same frequency that is required to break glass."
	stage = 2
	chance = 25
	max_chance = 75
	max_multiplier = 2
	badness = EFFECT_DANGER_ANNOYING

/datum/symptom/vitreous/activate(mob/living/carbon/human/H)
	H.Shake(3, 3, 3 SECONDS)
	if(ishuman(H))
		addtimer(CALLBACK(src, PROC_REF(shatter)), 0.5 SECONDS)

/datum/symptom/vitreous/proc/shatter()
	var/obj/item/reagent_containers/glass_to_shatter = H.get_active_held_item()
	var/obj/item/bodypart/check_arm = H.get_active_hand()
	if(!glass_to_shatter)
		return
	if (is_type_in_list(glass_to_shatter, list(/obj/item/reagent_containers/cup/glass)))
		to_chat(H, span_warning("Your [check_arm] resonates with the glass in \the [glass_to_shatter], shattering it to bits!"))
		glass_to_shatter.reagents.expose(H, TOUCH)
		new/obj/effect/decal/cleanable/generic(get_turf(H))
		playsound(H, 'sound/effects/glassbr1.ogg', 25, 1)
		spawn(1 SECONDS)
			if (H && check_arm)
				if (prob(50 * multiplier))
					to_chat(H, span_notice("Your [check_arm] deresonates, healing completely!"))
					check_arm.heal_damage(1000) // full heal
				else
					to_chat(H, span_warning("Your [check_arm] deresonates, sustaining burns!"))
					check_arm.take_damage(15 * multiplier, BRUTE)
		qdel(glass_to_shatter)
	else if (prob(1))
		to_chat(H, span_notice("Your [check_arm] aches for the cold, smooth feel of container-grade glass..."))

/datum/symptom/spiky_skin
	name = "Porokeratosis Acanthus"
	desc = "Causes the infected to generate keratin spines along their skin."
	stage = 2
	max_count = 1
	badness = EFFECT_DANGER_HINDRANCE
	var/skip = FALSE
	multiplier = 4
	max_multiplier = 8

/datum/symptom/spiky_skin/activate(mob/living/mob, multiplier)
	to_chat(mob, span_warning("Your skin feels a little prickly."))

/datum/symptom/spiky_skin/deactivate(mob/living/mob)
	if(!skip)
		to_chat(mob, span_notice("Your skin feels nice and smooth again!"))
	..()

/datum/symptom/spiky_skin/on_touch(mob/living/mob, mob/living/toucher, mob/living/touched, touch_type)
	if(!count || skip)
		return
	if(!istype(toucher) || !istype(touched))
		return
	var/obj/item/bodypart/E
	var/mob/living/carbon/human/H
	if(toucher == mob)	//we bumped into someone else
		if(ishuman(touched))
			H = touched
			E = H.get_bodypart(H.get_random_valid_zone())
	else	//someone else bumped into us
		if(ishuman(toucher))
			H = toucher
			E = H.get_bodypart(H.get_random_valid_zone())

	if(toucher == mob)
		if(E)
			to_chat(mob, span_warning("As you bump into \the [touched], your spines dig into \his [E]!"))
			E.take_damage(multiplier, BRUTE)
		else
			to_chat(mob, span_warning("As you bump into \the [touched], your spines dig into \him!"))
			var/mob/living/L = touched
			if(istype(L) && !istype(L, /mob/living/silicon))
				L.apply_damage(multiplier, BRUTE, E)
		var/mob/M = touched
		log_attack("[M] damaged [H] with keratin spikes")
	else
		if(E)
			to_chat(mob, span_warning("As \the [toucher] [touch_type == DISEASE_BUMP ? "bumps into" : "touches"] you, your spines dig into \his [E]!"))
			to_chat(toucher, span_danger("As you [touch_type == DISEASE_BUMP ? "bump into" : "touch"] \the [mob], \his spines dig into your [E]!"))
			E.take_damage(multiplier)
		else
			to_chat(mob, span_warning("As \the [toucher] [touch_type == DISEASE_BUMP ? "bumps into" : "touches"] you, your spines dig into \him!"))
			to_chat(toucher, span_danger("As you [touch_type == DISEASE_BUMP ? "bump into" : "touch"] \the [mob], \his spines dig into you!"))
			var/mob/living/L = toucher
			if(istype(L) && !istype(L, /mob/living/silicon))
				L.apply_damage(multiplier)
		var/mob/M = touched
		log_attack("[M] damaged [H] with keratin spikes")

/* TODO LATER

/datum/symptom/calorieburn
	name = "Caloric expenditure overefficiency"
	desc = "Causes the infected to burn calories at a higher rate."
	encyclopedia = "Higher Strength means accelerated metabolism."
	stage = 2
	multiplier = 1.5
	max_multiplier = 4
	max_count = 1
	badness = EFFECT_DANGER_HINDRANCE

/datum/symptom/calorieburn/activate(var/mob/living/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		H.calorie_burn_rate *= multiplier

/datum/symptom/calorieburn/deactivate(var/mob/living/mob)
	if (count)
		if(ishuman(mob))
			var/mob/living/carbon/human/H = mob
			H.calorie_burn_rate /= multiplier

/datum/symptom/calorieconserve
	name = "Caloric expenditure defficiency"
	desc = "Causes the infected to burn calories at a lower rate."
	encyclopedia = "Higher Strength means decelerated metabolism."
	stage = 2
	multiplier = 1.5
	max_multiplier = 4
	max_count = 1
	badness = EFFECT_DANGER_HINDRANCE

/datum/symptom/calorieconserve/activate(var/mob/living/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		H.calorie_burn_rate /= multiplier

/datum/symptom/calorieconserve/deactivate(var/mob/living/mob)
	if(count)
		if(ishuman(mob))
			var/mob/living/carbon/human/H = mob
			H.calorie_burn_rate *= multiplier
*/

/datum/symptom/famine
	name = "Faminous Potation"
	desc = "The infected emanates a field that kills off plantlife. Lethal to species descended from plants."
	stage = 2
	max_multiplier = 3
	badness = EFFECT_DANGER_HINDRANCE

/datum/symptom/famine/activate(var/mob/living/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		if(H.dna)
			if(ispodperson(H)) //Plantmen take a LOT of damage
				H.adjustCloneLoss(5 * multiplier)

	for(var/obj/machinery/hydroponics/H in range(3*multiplier,mob))
		switch(rand(1,3))
			if(1)
				H.adjust_waterlevel(-rand(1,10))
				H.adjust_plant_nutriments(-rand(1,5))
			if(2)
				H.adjust_toxic(rand(1,50))
			if(3)
				H.adjust_weedlevel(10)
				H.adjust_pestlevel(10)
				if(prob(5))
					H.plantdies()


	for(var/obj/item/food/grown/G in range(2*multiplier,mob))
		G.visible_message("<span class = 'warning'>\The [G] rots at an alarming rate!</span>")
		new /obj/item/food/badrecipe(get_turf(G))
		qdel(G)
		if(prob(30/multiplier))
			break
/datum/symptom/cyborg_vomit
	name = "Oleum Syndrome"
	desc = "Causes the infected to internally synthesize oil and other inorganic material."
	stage = 2
	badness = EFFECT_DANGER_ANNOYING

/datum/symptom/cyborg_vomit/activate(mob/living/mob)
	if(prob(90))		//90% chance for just oil
		mob.visible_message(span_danger("[mob.name] vomits up some oil!"))
		mob.adjustToxLoss(-3)
		var/obj/effect/decal/cleanable/oil/O = new /obj/effect/decal/cleanable/oil(get_turf(mob))
		playsound(O, 'sound/effects/splat.ogg', 50, 1)
		mob.Stun(0.5 SECONDS)
	else				//10% chance for a random bot!
		to_chat(mob, span_danger("You feel like something's about to burst out of you!"))
		sleep(100)
		var/list/possible_bots = list(
			/mob/living/simple_animal/bot/cleanbot,
			/mob/living/simple_animal/bot/medbot,
			/mob/living/simple_animal/bot/secbot,
			/mob/living/simple_animal/bot/floorbot,
			/mob/living/simple_animal/bot/buttbot
		)
		var/chosen_bot = pick(possible_bots)
		var/mob/living/simple_animal/bot/B = new chosen_bot(get_turf(mob))
		new /obj/effect/decal/cleanable/blood(get_turf(mob))
		mob.visible_message("<span class ='danger'>A [B.name] bursts out of [mob.name]'s mouth!</span>")
		playsound(B, 'sound/effects/splat.ogg', 50, 1)
		mob.emote("scream")
		mob.adjustBruteLoss(15)
		mob.Stun(1 SECONDS)


/datum/symptom/mommi_shrink
	name = "Dysplasia Syndrome"
	desc = "Rapidly restructures the body of the infected, causing them to shrink in size."
	badness = EFFECT_DANGER_FLAVOR
	stage = 2
	var/activated = 0

/datum/symptom/mommi_shrink/activate(var/mob/living/mob)
	if(activated)
		return
	to_chat(mob, "<span class = 'warning'>You feel small...</span>")
	mob.transform.Scale(0.5, 0.5)
	mob.update_transform()
	mob.pass_flags |= PASSTABLE

	activated = 1

/datum/symptom/mommi_shrink/deactivate(mob/living/mob)
	to_chat(mob, "<span class = 'warning'>You feel like an adult again.</span>")
	mob.transform.Scale(2, 2)
	mob.update_transform()
	mob.pass_flags &= ~PASSTABLE
	activated = 0

/datum/symptom/wendigo_vomit
	name = "Gastrointestinal Inflammation"
	desc = "Inflames the GI tract of the infected, causing relentless vomitting."
	stage = 2
	badness = EFFECT_DANGER_HINDRANCE
	chance = 6
	max_chance = 12

/datum/symptom/wendigo_vomit/activate(mob/living/mob)
	if(!ishuman(mob))
		return

	var/mob/living/carbon/human/H = mob
	if(prob(33))
		H.vomit(stun = FALSE)
	else
		H.vomit()

/datum/symptom/antitox
	name = "Antioxidantisation Syndrome"
	desc = "A very real syndrome beloved by Super-Food Fans and Essential Oil Enthusiasts; encourages the production of anti-toxin within the body."
	stage = 2
	badness = EFFECT_DANGER_HELPFUL

/datum/symptom/antitox/activate(mob/living/mob)
	to_chat(mob, "<span class = 'notice'>You feel your toxins being purged!</span>")
	mob.adjustToxLoss(-4)

/datum/symptom/cult_vomit
	name = "Hemoptysis"
	desc = "Causes the infected to cough up blood."
	stage = 2
	badness = EFFECT_DANGER_HINDRANCE
	var/active = 0

/datum/symptom/cult_vomit/activate(mob/living/carbon/M)
	if(!ishuman(M) || active)
		return
	if(istype(get_area(M), /area/station/service/chapel))
		return
	if(IS_CULTIST(M))
		return

	var/mob/living/carbon/human/mob = M
	active = 1
	to_chat(mob, span_warning("You feel a burning sensation in your throat."))
	sleep(10 SECONDS)
	to_chat(mob, span_danger("You feel an agonizing pain in your throat!"))
	sleep(10 SECONDS)
	mob.visible_message(span_danger("[mob] vomits up blood!"), span_danger("You vomit up blood!"))
	var/obj/effect/decal/cleanable/blood/S = new(loc = get_turf(mob))
	S.count = 1
	playsound(mob, 'sound/effects/splat.ogg', 50, 1)
	mob.Stun(5)
	mob.blood_volume -= 8
	active = 0

/datum/symptom/choking
	name = "Choking"
	desc = "The virus causes inflammation of the host's air conduits, leading to intermittent choking."
	max_multiplier = 10
	multiplier = 1
	badness = EFFECT_DANGER_HINDRANCE
	max_chance = 20
	stage = 2

/datum/symptom/choking/activate(mob/living/carbon/mob)
	mob.emote("gasp")
	if(prob(25))
		to_chat(mob, span_warning("[pick("You're having difficulty breathing.", "Your breathing becomes heavy.")]"))
	mob.adjustOxyLoss(rand(2, 3) * multiplier)
