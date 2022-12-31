/datum/species/beefman
	name = "Beefman"
	plural_form = "Beefmen"
	id = SPECIES_BEEFMAN
	examine_limb_id = SPECIES_BEEFMAN
	sexes = FALSE
	species_traits = list(
		NOEYESPRITES,
		NO_UNDERWEAR,
		DYNCOLORS,
		AGENDER,
	)
	mutant_bodyparts = list(
		"beef_color" = "#e73f4e",
		"beef_eyes" = BEEF_EYES_OLIVES,
		"beef_mouth" = BEEF_MOUTH_SMILE,
		"beef_trauma" = /datum/brain_trauma/mild/phobia/strangers,
	)
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_EASYDISMEMBER,
		TRAIT_GENELESS,
		TRAIT_LITERATE,
		TRAIT_RESISTCOLD,
		TRAIT_SLEEPIMMUNE,
	)
	offset_features = list(
		OFFSET_ID = list(0,2),
		OFFSET_GLOVES = list(0,-4),
		OFFSET_GLASSES = list(0,3),
		OFFSET_EARS = list(0,3),
		OFFSET_SHOES = list(0,0),
		OFFSET_S_STORE = list(0,2),
		OFFSET_FACEMASK = list(0,3),
		OFFSET_HEAD = list(0,3),
		OFFSET_FACE = list(0,3),
		OFFSET_BELT = list(0,3),
		OFFSET_SUIT = list(0,2),
		OFFSET_NECK = list(0,3),
	)

	cellular_damage_desc = "meat degradation"

	species_language_holder = /datum/language_holder/russian
	mutanttongue = /obj/item/organ/internal/tongue/beefman
	skinned_type = /obj/item/food/meatball
	meat = /obj/item/food/meat/slab
	toxic_food = DAIRY | PINEAPPLE
	disliked_food = VEGETABLES | FRUIT | CLOTH
	liked_food = RAW | MEAT | FRIED
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	payday_modifier = 0.75
	speedmod = -0.2
	armor = -20
	siemens_coeff = 0.7 // base electrocution coefficient
	bodytemp_normal = T20C

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/beef, \
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/beef, \
		BODY_ZONE_HEAD = /obj/item/bodypart/head/beef, \
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/beef, \
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/beef, \
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/beef, \
	)

	death_sound = 'sound/voice/beefman/beef_die.ogg'
	grab_sound = 'sound/voice/beefman/beef_grab.ogg'
	special_step_sounds = list(
		'sound/voice/beefman/footstep_splat1.ogg',
		'sound/voice/beefman/footstep_splat2.ogg',
		'sound/voice/beefman/footstep_splat3.ogg',
		'sound/voice/beefman/footstep_splat4.ogg',
	)

	///Dehydration caused by consuming Salt. Causes bleeding and affects how much they will bleed.
	var/dehydrated = 0
	///List of all limbs that can be removed and replaced at will.
	var/static/list/tearable_limbs = list(
		BODY_ZONE_PRECISE_MOUTH,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
	)

// Taken from Ethereal
/datum/species/beefman/on_species_gain(mob/living/carbon/human/user, datum/species/old_species, pref_load)
	. = ..()
	spec_updatehealth(user)
	var/obj/item/organ/internal/brain/has_brain = user.getorganslot(ORGAN_SLOT_BRAIN)
	if(has_brain)
		if(user.dna.features["beef_trauma"])
			user.gain_trauma(user.dna.features["beef_trauma"], TRAUMA_RESILIENCE_ABSOLUTE)
		user.gain_trauma(/datum/brain_trauma/special/bluespace_prophet/phobetor, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/species/beefman/randomize_features(mob/living/carbon/human/human_mob)
	human_mob.dna.features["beef_color"] = pick(GLOB.color_list_beefman[pick(GLOB.color_list_beefman)])
	fixed_mut_color = human_mob.dna.features["beef_color"]
	human_mob.dna.features["beef_eyes"] = pick(GLOB.eyes_beefman)
	human_mob.dna.features["beef_mouth"] = pick(GLOB.mouths_beefman)

/datum/species/beefman/on_species_loss(mob/living/carbon/human/user, datum/species/new_species, pref_load)
	user.cure_trauma_type(/datum/brain_trauma/special/bluespace_prophet/phobetor, TRAUMA_RESILIENCE_ABSOLUTE)
	user.cure_trauma_type(user.dna.features["beef_trauma"], TRAUMA_RESILIENCE_ABSOLUTE)
	return ..()

/datum/species/beefman/spec_life(mob/living/carbon/human/user)
	. = ..()
	///How much we should bleed out, taking Burn damage into account.
	var/sear_juices = user.getFireLoss_non_prosthetic() / 30

	// Bleed out those juices by warmth, minus burn damage. If we are salted - bleed more
	if(dehydrated > 0)
		user.adjust_beefman_bleeding(clamp((user.bodytemperature - 297.15) / 20 - sear_juices, 2, 10))
		dehydrated -= 0.5
	else
		user.adjust_beefman_bleeding(clamp((user.bodytemperature - 297.15) / 20 - sear_juices, 0, 5))

	// Replenish Blood Faster! (But only if you actually make blood)
	var/bleed_rate
	for(var/obj/item/bodypart/all_bodyparts as anything in user.bodyparts)
		bleed_rate += all_bodyparts.generic_bleedstacks

/datum/species/beefman/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/user, delta_time, times_fired)
	if(istype(chem, /datum/reagent/saltpetre) || istype(chem, /datum/reagent/consumable/salt))
		if(!dehydrated || DT_PROB(10, delta_time))
			to_chat(user, span_alert("Your beefy mouth tastes dry."))
		dehydrated++
	return ..()

/datum/species/beefman/spec_updatehealth(mob/living/carbon/human/beefman)
	. = ..()
	fixed_mut_color = beefman.dna.features["beef_color"]
	beefman.update_body()

/datum/species/beefman/get_features()
	var/list/features = ..()

	features += "feature_beef_color"
	features += "feature_beef_eyes"
	features += "feature_beef_mouth"
	features += "feature_beef_trauma"

	return features

/datum/species/beefman/random_name(gender, unique, lastname)
	if(unique)
		return random_unique_beefman_name()
	var/randname = beefman_name()
	return randname

/datum/species/beefman/get_species_description()
	return "Made entirely out of beef, Beefmen are completely delusional \
		through and through, with constant hallucinations and 'tears in reality'"

/datum/species/beefman/get_species_lore()
	return list(
		"On a very quiet day, the Russian-famous 'Fiddler' Diner was serving food to the crew, when they realized they ran out of burger ingredients. \
		After drawing straws, the Cook was sent to fetch some more meat from the Morgue, unaware of the events that will transpire. \
		'It's normal for the Kitchen to grab dead bodies, right? It's not like they need them... Right?' The Cook thought, \
		inattentively grabbing the first body they could find, trying to get this over with before it becomes a memory. \
		What the Cook hadn't noticed, the Morgue's tray was green, the body was filled with a soul, one that was begging not to be gibbed.",

		"The Cook one'd and two'd the body into the gibber and turned it on, the grinder struggling to keep up on its unupgraded parts. \
		Once the whole body entered the machine, it suddenly stopped working, and instead started spitting the meat back out, as if it was in reverse... \
		The Cook looked over to see what was going on, but the slab of meat looked back, with massive eyes.",

		"After a quick confiscation from the Russian Sol Government, most records of 'Beefmen' have gone dark, \
		with minor glimpses of 'Sleep Experiments' going around. \
		One thing is certain though, a rise of gibbers on-board Russian stations, which was followed by a rise in Beefmen. \
		No one knows what happened during this era, but when the program finally ended and they were allowed into society, \
		none of them were able to live 'normally'. Their complete inability to sleep, but their power in traversing the 'Phobetor Tear' \
		immediately started popping everywhere, and has been at the	forefront of galaxy-wide investigations of their anatomy and the experiments.",
	)

/datum/species/beefman/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		//Positive
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "person",
			SPECIES_PERK_NAME = "Beefy Limbs",
			SPECIES_PERK_DESC = "Beefmen are able to tear off and put limbs back on at will. They do this by targetting their limb and right clicking.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "running",
			SPECIES_PERK_NAME = "Runners",
			SPECIES_PERK_DESC = "Beefmen are 20% faster than other species by default, allowing them to outrun things that normal crewmembers cannot.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "temperature-low",
			SPECIES_PERK_NAME = "Cold Loving",
			SPECIES_PERK_DESC = "Beefmen are completely immune to the cold, even helping them prevent bleeding.",
		),
		//Neutral
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "link",
			SPECIES_PERK_NAME = "Phobetor Tears",
			SPECIES_PERK_DESC = "Beefmen can see and use Phobetor tears, small tears in reality that, \
				When used, teleports you to the other end of the tear. This cannot if someone is near the start and end.",
		),
		//Negative
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "shield-alt",
			SPECIES_PERK_NAME = "Boneless Meat",
			SPECIES_PERK_DESC = "Beefmen's meat is not well guarded, taking 20% more damage than normal crew.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "tint",
			SPECIES_PERK_NAME = "Juice Bleeding",
			SPECIES_PERK_DESC = "Beefmen will begin to bleed out when their temperature is above 24C, \
				Though scaling burn damage will prevent the bleeding.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "briefcase-medical",
			SPECIES_PERK_NAME = "Mentally unfit",
			SPECIES_PERK_DESC = "Beefmen suffer terribly from a permanent brain trauma. \
				that can't be repaired under normal circumstances.",
		),
	)

	return to_add

/**
 * BEEFMAN UNIQUE PROCS AND INTEGRATION
 */
/mob/living/carbon/human/proc/adjust_beefman_bleeding(amount)
	for(var/obj/item/bodypart/all_bodyparts as anything in bodyparts)
		all_bodyparts.setBleedStacks(amount)

///When interacting with another person, you will bleed over them.
/datum/species/beefman/proc/bleed_over_target(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user != target && user.is_bleeding())
		target.add_mob_blood(user)

/**
 * ATTACK PROCS
 */
/datum/species/beefman/help(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	bleed_over_target(user, target)
	return ..()

/datum/species/beefman/grab(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	bleed_over_target(user, target)
	return ..()

/datum/species/beefman/spec_unarmedattacked(mob/living/carbon/human/user, mob/living/carbon/human/target)
	bleed_over_target(user, target)
	return ..()

/datum/species/beefman/disarm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(user != target)
		return ..()
	var/target_zone = user.zone_selected
	var/obj/item/bodypart/affecting = user.get_bodypart(check_zone(user.zone_selected))
	if(!affecting || !(target_zone in tearable_limbs))
		return FALSE
	if(user.handcuffed)
		to_chat(user, span_alert("You can't get a good enough grip with your hands bound."))
		return FALSE
	if(!IS_ORGANIC_LIMB(affecting))
		to_chat(user, "That thing is on there good. It's not coming off with a gentle tug.")
		return FALSE

	if(target_zone == BODY_ZONE_PRECISE_MOUTH)
		var/obj/item/organ/internal/tongue/tongue = user.getorgan(/obj/item/organ/internal/tongue)
		if(!tongue)
			to_chat("You do not have a tongue!")
			return FALSE
		user.visible_message(
			span_notice("[user] grabs onto [p_their()] own tongue and pulls."),
			span_notice("You grab hold of your tongue and yank hard."))
		if(!do_mob(user, target, 1 SECONDS))
			return FALSE
		var/obj/item/food/meat/slab/meat = new()
		tongue.Remove(user, special = TRUE)
		user.put_in_hands(meat)
		playsound(get_turf(user), 'sound/voice/beefman/beef_hit.ogg', 40, 1)
		return TRUE
	user.visible_message(
		span_notice("[user] grabs onto [p_their()] own [affecting.name] and pulls."),
		span_notice("You grab hold of your [affecting.name] and yank hard."))
	if(!do_mob(user, target))
		return FALSE
	user.visible_message(
		span_notice("[user]'s [affecting.name] comes right off in their hand."),
		span_notice("Your [affecting.name] pops right off."))
	playsound(get_turf(user), 'sound/voice/beefman/beef_hit.ogg', 40, 1)
	// Destroy Limb, Drop Meat, Pick Up
	var/obj/item/food/meat/slab/dropped_meat = affecting.drop_limb()
	//This will return a meat vis drop_meat(), even if only Beefman limbs return anything. If this was another species' limb, it just comes off.
	if(dropped_meat)
		user.put_in_hands(dropped_meat)
	return TRUE

/datum/species/beefman/spec_attacked_by(obj/item/meat, mob/living/user, obj/item/bodypart/affecting, mob/living/carbon/human/beefboy)
	if(!istype(meat, /obj/item/food/meat/slab))
		return ..()
	var/target_zone = user.zone_selected
	if(!(target_zone in tearable_limbs))
		return FALSE
	if(target_zone == BODY_ZONE_PRECISE_MOUTH)
		var/obj/item/organ/internal/tongue/tongue = user.getorgan(/obj/item/organ/internal/tongue)
		if(tongue)
			to_chat("You already have a tongue!")
			return FALSE
		user.visible_message(
			span_notice("[user] begins mashing [meat] into [beefboy]'s mouth."),
			span_notice("You begin mashing [meat] into [beefboy]'s mouth."))
		if(!do_mob(user, beefboy, 2 SECONDS))
			return FALSE
		user.visible_message(
			span_notice("The [meat] sprouts and becomes [beefboy]'s new tongue!"),
			span_notice("The [meat] successfully fuses with your mouth!"))
		var/obj/item/organ/internal/tongue/beefman/new_tongue = new()
		new_tongue.Insert(user, special = TRUE)
		qdel(meat)
		playsound(get_turf(beefboy), 'sound/voice/beefman/beef_grab.ogg', 50, 1)
		return TRUE
	if(affecting)
		return FALSE
	user.visible_message(
		span_notice("[user] begins mashing [meat] into [beefboy]'s torso."),
		span_notice("You begin mashing [meat] into [beefboy]'s torso."))
	// Leave Melee Chain (so deleting the meat doesn't throw an error) <--- aka, deleting the meat that called this very proc.
	if(!do_mob(user, beefboy, 2 SECONDS))
		return FALSE
	// Attach the part!
	var/obj/item/bodypart/new_bodypart = beefboy.newBodyPart(target_zone, FALSE)
	beefboy.visible_message(
		span_notice("The meat sprouts digits and becomes [beefboy]'s new [new_bodypart.name]!"),
		span_notice("The meat sprouts digits and becomes your new [new_bodypart.name]!"))
	new_bodypart.try_attach_limb(beefboy)
	new_bodypart.update_limb(is_creating = TRUE)
	beefboy.update_body_parts()
	new_bodypart.give_meat(beefboy, meat)
	qdel(meat)
	playsound(get_turf(beefboy), 'sound/voice/beefman/beef_grab.ogg', 50, 1)
	return TRUE
