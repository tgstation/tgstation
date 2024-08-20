/datum/symptom/beard
	name = "Facial Hypertrichosis"
	desc = "Causes the infected to spontaneously grow a beard, regardless of gender. Only affects humans."
	stage = 2
	max_multiplier = 5
	badness = EFFECT_DANGER_FLAVOR


/datum/symptom/beard/activate(mob/living/mob)
	if(istype(mob, /mob/living/carbon/human))
		var/mob/living/carbon/human/victim = mob
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
				if(beard_name != "" && victim.facial_hairstyle != beard_name)
					victim.facial_hairstyle = beard_name
					to_chat(victim, span_warning("Your chin itches."))
					victim.update_body_parts()

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

/datum/symptom/cough/activate(mob/living/mob)
	mob.emote("cough")
	if(!ishuman(mob))
		return
	var/mob/living/carbon/human/victim = mob
	var/datum/gas_mixture/breath
	breath = victim.get_breath_from_internal(BREATH_VOLUME)
	if(!breath)//not wearing internals
		if(!victim.wear_mask)
			if(isturf(mob.loc))
				var/list/blockers = list()
				blockers = list(victim.wear_mask,victim.glasses,victim.head)
				for (var/item in blockers)
					var/obj/item/clothing/clothes = item
					if (!istype(clothes))
						continue
					if (clothes.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
						return
				if(mob.check_airborne_sterility())
					return
				var/strength = 0
				for (var/datum/disease/advanced/virus  as anything in mob.diseases)
					strength += virus.infectionchance
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

/datum/symptom/fridge/proc/set_body_temp(mob/living/mob)
	if(multiplier >= 3) // when unsafe the shivers can cause cold damage
		mob.add_body_temperature_change("chills", -6 * power * multiplier)
	else
		// Get the max amount of change allowed before going under cold damage limit, then cap the maximum allowed temperature change from safe chills to 5 over the cold damage limit
		var/change_limit = min(mob.get_body_temp_cold_damage_limit() + 5 - mob.get_body_temp_normal(apply_change=FALSE), 0)
		mob.add_body_temperature_change("chills", max(-6 * power * multiplier, change_limit))

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
		var/mob/living/carbon/human/victim = mob
		if(victim.hairstyle != "Bald")
			if (victim.hairstyle != "Balding Hair")
				to_chat(victim, span_danger("Your hair starts to fall out in clumps..."))
				if (prob(multiplier*20))
					victim.hairstyle = "Balding Hair"
					victim.update_body_parts()
			else
				to_chat(victim, span_danger("You have almost no hair left..."))
				if (prob(multiplier*20))
					victim.hairstyle = "Bald"
					victim.update_body_parts()

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
			var/mob/living/carbon/human/victim = mob
			if (!(TRAIT_NOBLOOD in victim.dna.species.inherent_traits))
				victim.add_splatter_floor(get_turf(mob), 1)
		else
			var/obj/effect/decal/cleanable/blood/blood= locate(/obj/effect/decal/cleanable/blood) in get_turf(mob)
			if(blood==null)
				blood = new /obj/effect/decal/cleanable/blood(get_turf(mob))
			blood.diseases |= virus_copylist(mob.diseases)


//commented out until i can figure out how to make this work without shoving static lights on moving objects
/datum/symptom/lantern
	name = "Lantern Syndrome"
	desc = "Causes the infected to glow."
	stage = 2
	badness = EFFECT_DANGER_HELPFUL
	multiplier = 4
	max_multiplier = 10
	chance = 10
	max_chance = 15
	var/uncolored = 0
	var/flavortext = 0
	var/color = rgb(255, 255, 255)
	var/obj/effect/dummy/lighting_obj/moblight

/datum/symptom/lantern/activate(mob/living/mob)
	if(!moblight)
		moblight = new(mob)
	if(ismouse(mob))
		moblight.set_light_range(multiplier)
		moblight.set_light_power(multiplier / 3)
		moblight.set_light_color(color)
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
	moblight.set_light_range(multiplier)
	moblight.set_light_power(multiplier / 3)
	moblight.set_light_color(color)

/datum/symptom/lantern/deactivate(mob/living/mob)
	QDEL_NULL(moblight)
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

/datum/symptom/vitreous/activate(mob/living/carbon/human/victim)
	victim.Shake(3, 3, 3 SECONDS)
	if(ishuman(victim))
		addtimer(CALLBACK(src, PROC_REF(shatter), victim), 0.5 SECONDS)

/datum/symptom/vitreous/proc/shatter(mob/living/carbon/human/victim)
	var/obj/item/reagent_containers/glass_to_shatter = victim.get_active_held_item()
	var/obj/item/bodypart/check_arm = victim.get_active_hand()
	if(!glass_to_shatter)
		return
	if (is_type_in_list(glass_to_shatter, list(/obj/item/reagent_containers/cup/glass)))
		to_chat(victim, span_warning("Your [check_arm] resonates with the glass in \the [glass_to_shatter], shattering it to bits!"))
		glass_to_shatter.reagents.expose(victim, TOUCH)
		new/obj/effect/decal/cleanable/generic(get_turf(victim))
		playsound(victim, 'sound/effects/glassbr1.ogg', 25, 1)
		spawn(1 SECONDS)
			if (victim && check_arm)
				if (prob(50 * multiplier))
					to_chat(victim, span_notice("Your [check_arm] deresonates, healing completely!"))
					check_arm.heal_damage(1000) // full heal
				else
					to_chat(victim, span_warning("Your [check_arm] deresonates, sustaining burns!"))
					check_arm.take_damage(15 * multiplier, BRUTE)
		qdel(glass_to_shatter)
	else if (prob(1))
		to_chat(victim, span_notice("Your [check_arm] aches for the cold, smooth feel of container-grade glass..."))

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
	var/obj/item/bodypart/bodypartTarget
	var/mob/living/carbon/human/target
	if(toucher == mob)	//we bumped into someone else
		if(ishuman(touched))
			target = touched
			bodypartTarget = target.get_bodypart(target.get_random_valid_zone())
	else	//someone else bumped into us
		if(ishuman(toucher))
			target = toucher
			bodypartTarget = target.get_bodypart(target.get_random_valid_zone())

	if(toucher == mob)
		if(bodypartTarget)
			to_chat(mob, span_warning("As you bump into \the [touched], your spines dig into \his [bodypartTarget]!"))
			bodypartTarget.take_damage(multiplier, BRUTE)
		else
			to_chat(mob, span_warning("As you bump into \the [touched], your spines dig into \him!"))
			var/mob/living/impaled = touched
			if(istype(impaled) && !istype(impaled, /mob/living/silicon))
				impaled.apply_damage(multiplier, BRUTE, bodypartTarget)
	else
		if(bodypartTarget)
			to_chat(mob, span_warning("As \the [toucher] [touch_type == DISEASE_BUMP ? "bumps into" : "touches"] you, your spines dig into \his [bodypartTarget]!"))
			to_chat(toucher, span_danger("As you [touch_type == DISEASE_BUMP ? "bump into" : "touch"] \the [mob], \his spines dig into your [bodypartTarget]!"))
			bodypartTarget.take_damage(multiplier)
		else
			to_chat(mob, span_warning("As \the [toucher] [touch_type == DISEASE_BUMP ? "bumps into" : "touches"] you, your spines dig into \him!"))
			to_chat(toucher, span_danger("As you [touch_type == DISEASE_BUMP ? "bump into" : "touch"] \the [mob], \his spines dig into you!"))
			var/mob/living/victim = toucher
			if(istype(victim) && !istype(victim, /mob/living/silicon))
				victim.apply_damage(multiplier)
	var/mob/attacker = touched
	log_attack("[attacker] damaged [target] with keratin spikes")

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
		var/mob/living/carbon/human/victim = mob
		victim.calorie_burn_rate *= multiplier

/datum/symptom/calorieburn/deactivate(var/mob/living/mob)
	if (count)
		if(ishuman(mob))
			var/mob/living/carbon/human/victim = mob
			victim.calorie_burn_rate /= multiplier

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
		var/mob/living/carbon/human/victim = mob
		victim.calorie_burn_rate /= multiplier

/datum/symptom/calorieconserve/deactivate(var/mob/living/mob)
	if(count)
		if(ishuman(mob))
			var/mob/living/carbon/human/victim = mob
			victim.calorie_burn_rate *= multiplier
*/

/datum/symptom/famine
	name = "Faminous Potation"
	desc = "The infected emanates a field that kills off plantlife. Lethal to species descended from plants."
	stage = 2
	max_multiplier = 3
	badness = EFFECT_DANGER_HINDRANCE

/datum/symptom/famine/activate(mob/living/mob)
	if(ishuman(mob))
		var/mob/living/carbon/human/victim = mob
		if(ispodperson(victim))
			victim.adjustCloneLoss(5 * multiplier) //Plantmen take a LOT of damag

	for(var/obj/item/food/grown/crop in range(2 * multiplier,mob))
		crop.visible_message(span_warning("\The [crop] rots at an alarming rate!"))
		new /obj/item/food/badrecipe(get_turf(crop))
		qdel(crop)
		if(prob(30 / multiplier))
			break

/datum/symptom/cyborg_vomit
	name = "Oleum Syndrome"
	desc = "Causes the infected to internally synthesize oil and other inorganic material."
	stage = 2
	badness = EFFECT_DANGER_ANNOYING

/datum/symptom/cyborg_vomit/activate(mob/living/mob)
	if(HAS_TRAIT(mob, TRAIT_NOHUNGER) || !mob.has_mouth())
		return
	if(prob(90))		//90% chance for just oil
		mob.visible_message(span_danger("[mob.name] vomits up some oil!"))
		mob.adjustToxLoss(-3)
		var/obj/effect/decal/cleanable/oil/oil = new /obj/effect/decal/cleanable/oil(get_turf(mob))
		playsound(oil, 'sound/effects/splat.ogg', 50, 1)
		mob.Stun(0.5 SECONDS)
	else				//10% chance for a random bot!
		to_chat(mob, span_danger("You feel like something's about to burst out of you!"))
		sleep(100)
		var/list/possible_bots = list(
			/mob/living/simple_animal/bot/cleanbot,
			/mob/living/basic/bot/medbot,
			/mob/living/simple_animal/bot/secbot,
			/mob/living/simple_animal/bot/floorbot,
			/mob/living/simple_animal/bot/buttbot
		)
		var/chosen_bot = pick(possible_bots)
		var/mob/living/simple_animal/bot/newbot = new chosen_bot(get_turf(mob))
		new /obj/effect/decal/cleanable/blood(get_turf(mob))
		mob.visible_message("<span class ='danger'>A [newbot.name] bursts out of [mob.name]'s mouth!</span>")
		playsound(newbot, 'sound/effects/splat.ogg', 50, 1)
		mob.emote("scream")
		mob.adjustBruteLoss(15)
		mob.Stun(1 SECONDS)


/datum/symptom/mommi_shrink
	name = "Dysplasia Syndrome"
	desc = "Rapidly restructures the body of the infected, causing them to shrink in size."
	badness = EFFECT_DANGER_FLAVOR
	stage = 2
	var/activated = 0

/datum/symptom/mommi_shrink/activate(mob/living/mob)
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

	var/mob/living/carbon/human/victim = mob
	victim.vomit(stun = FALSE)

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

/datum/symptom/cult_vomit/activate(mob/living/carbon/mob)
	if(!ishuman(mob) || active)
		return
	if(istype(get_area(mob), /area/station/service/chapel))
		return
	if(IS_CULTIST(mob))
		return

	var/mob/living/carbon/human/victim = mob
	active = 1
	to_chat(victim, span_warning("You feel a burning sensation in your throat."))
	sleep(10 SECONDS)
	to_chat(victim, span_danger("You feel an agonizing pain in your throat!"))
	sleep(10 SECONDS)
	victim.vomit(10, TRUE)
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

/datum/symptom/disfiguration
	name = "Disfiguration"
	desc = "The virus liquefies facial muscles, disfiguring the host."
	max_count = 1

/datum/symptom/disfiguration/activate(mob/living/carbon/mob)
	ADD_TRAIT(mob, TRAIT_DISFIGURED, type)
	mob.visible_message(span_warning("[mob]'s face appears to cave in!"), span_notice("You feel your face crumple and cave in!"))

/datum/symptom/disfiguration/deactivate(mob/living/carbon/mob)
	REMOVE_TRAIT(mob, TRAIT_DISFIGURED, type)

/datum/symptom/blindness
	name = "Hyphema"
	desc = "Sufferers exhibit dangerously low levels of frames per second in the eyes, leading to damage and eventually blindness."
	max_multiplier = 4
	stage = 2
	badness = EFFECT_DANGER_HARMFUL

/datum/symptom/blindness/activate(mob/living/carbon/mob)
	if(!iscarbon(mob))
		return

	var/obj/item/organ/internal/eyes/eyes = mob.get_organ_slot(ORGAN_SLOT_EYES)
	if(!eyes)
		return // can't do much

	switch(round(multiplier))
		if(1, 2)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(mob, span_warning("Your eyes itch."))

		if(3, 4)
			to_chat(mob, span_boldwarning("Your eyes burn!"))
			mob.set_eye_blur_if_lower(10 SECONDS)
			eyes.apply_organ_damage(1)

		else
			mob.set_eye_blur_if_lower(20 SECONDS)
			eyes.apply_organ_damage(5)

			// Applies nearsighted at minimum
			if(!mob.is_nearsighted_from(EYE_DAMAGE) && eyes.damage <= eyes.low_threshold)
				eyes.set_organ_damage(eyes.low_threshold)

			if(prob(eyes.damage - eyes.low_threshold + 1))
				if(!mob.is_blind_from(EYE_DAMAGE))
					to_chat(mob, span_userdanger("You go blind!"))
					eyes.apply_organ_damage(eyes.maxHealth)
			else
				to_chat(mob, span_userdanger("Your eyes burn horrifically!"))
