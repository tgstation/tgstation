/datum/species/plasmaman
	name = "\improper Plasmaman"
	plural_form = "Plasmamen"
	id = SPECIES_PLASMAMAN
	say_mod = "rattles"
	sexes = 0
	meat = /obj/item/stack/sheet/mineral/plasma
	species_traits = list(NOBLOOD,NOTRANSSTING, HAS_BONE)
	// plasmemes get hard to wound since they only need a severe bone wound to dismember, but unlike skellies, they can't pop their bones back into place
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_RESISTCOLD,
		TRAIT_RADIMMUNE,
		TRAIT_GENELESS,
		TRAIT_NOHUNGER,
		TRAIT_HARDLY_WOUNDED,
	)

	inherent_biotypes = MOB_HUMANOID|MOB_MINERAL
	mutantlungs = /obj/item/organ/lungs/plasmaman
	mutanttongue = /obj/item/organ/tongue/bone/plasmaman
	mutantliver = /obj/item/organ/liver/plasmaman
	mutantstomach = /obj/item/organ/stomach/bone/plasmaman
	burnmod = 1.5
	heatmod = 1.5
	brutemod = 1.5
	payday_modifier = 0.75
	breathid = "plas"
	damage_overlay_type = ""//let's not show bloody wounds or burns over bones.
	disliked_food = FRUIT | CLOTH
	liked_food = VEGETABLES
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC
	species_cookie = /obj/item/reagent_containers/food/condiment/milk
	outfit_important_for_life = /datum/outfit/plasmaman
	species_language_holder = /datum/language_holder/skeleton

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/l_arm/plasmaman,
		BODY_ZONE_R_ARM = /obj/item/bodypart/r_arm/plasmaman,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/plasmaman,
		BODY_ZONE_L_LEG = /obj/item/bodypart/l_leg/plasmaman,
		BODY_ZONE_R_LEG = /obj/item/bodypart/r_leg/plasmaman,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/plasmaman,
	)

	// Body temperature for Plasmen is much lower human as they can handle colder environments
	bodytemp_normal = (BODYTEMP_NORMAL - 40)
	// The minimum amount they stabilize per tick is reduced making hot areas harder to deal with
	bodytemp_autorecovery_min = 2
	// They are hurt at hot temps faster as it is harder to hold their form
	bodytemp_heat_damage_limit = (BODYTEMP_HEAT_DAMAGE_LIMIT - 20) // about 40C
	// This effects how fast body temp stabilizes, also if cold resit is lost on the mob
	bodytemp_cold_damage_limit = (BODYTEMP_COLD_DAMAGE_LIMIT - 50) // about -50c

	ass_image = 'icons/ass/assplasma.png'

	/// If the bones themselves are burning clothes won't help you much
	var/internal_fire = FALSE

/datum/species/plasmaman/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	C.set_safe_hunger_level()

/datum/species/plasmaman/spec_life(mob/living/carbon/human/H, delta_time, times_fired)
	var/atmos_sealed = TRUE
	if(!HAS_TRAIT(H, TRAIT_NOFIRE))
		atmos_sealed = FALSE
	else if(!isclothing(H.wear_suit) || !(H.wear_suit.clothing_flags & STOPSPRESSUREDAMAGE))
		atmos_sealed = FALSE
	else if(!HAS_TRAIT(H, TRAIT_NOSELFIGNITION_HEAD_ONLY) && (!isclothing(H.head) || !(H.head.clothing_flags & STOPSPRESSUREDAMAGE)))
		atmos_sealed = FALSE

	var/flammable_limb = FALSE
	for(var/obj/item/bodypart/found_bodypart as anything in H.bodyparts)//If any plasma based limb is found the plasmaman will attempt to autoignite
		if(IS_ORGANIC_LIMB(found_bodypart) && (found_bodypart.limb_id == SPECIES_PLASMAMAN || HAS_TRAIT(found_bodypart, TRAIT_PLASMABURNT))) //Allows for "donated" limbs and augmented limbs to prevent autoignition
			flammable_limb = TRUE
			break

	if(!flammable_limb && !H.on_fire) //Allows their suit to attempt to autoextinguish if augged and on fire
		return

	var/can_burn = FALSE
	if(!isclothing(H.w_uniform) || !(H.w_uniform.clothing_flags & PLASMAMAN_PREVENT_IGNITION))
		can_burn = TRUE
	else if(!isclothing(H.gloves))
		can_burn = TRUE
	else if(!HAS_TRAIT(H, TRAIT_NOSELFIGNITION_HEAD_ONLY) && (!isclothing(H.head) || !(H.head.clothing_flags & PLASMAMAN_PREVENT_IGNITION)))
		can_burn = TRUE

	if(!atmos_sealed && can_burn)
		var/datum/gas_mixture/environment = H.loc.return_air()
		if(environment?.total_moles())
			if(environment.gases[/datum/gas/hypernoblium] && (environment.gases[/datum/gas/hypernoblium][MOLES]) >= 5)
				if(H.on_fire && H.fire_stacks > 0)
					H.adjust_fire_stacks(-10 * delta_time)
			else if(!HAS_TRAIT(H, TRAIT_NOFIRE))
				if(environment.gases[/datum/gas/oxygen] && (environment.gases[/datum/gas/oxygen][MOLES]) >= 1) //Same threshhold that extinguishes fire
					H.adjust_fire_stacks(0.25 * delta_time)
					if(!H.on_fire && H.fire_stacks > 0)
						H.visible_message(span_danger("[H]'s body reacts with the atmosphere and bursts into flames!"),span_userdanger("Your body reacts with the atmosphere and bursts into flame!"))
					H.ignite_mob()
					internal_fire = TRUE

	else if(H.fire_stacks)
		var/obj/item/clothing/under/plasmaman/P = H.w_uniform
		if(istype(P))
			P.Extinguish(H)
			internal_fire = FALSE
	else
		internal_fire = FALSE

	H.update_fire()

/datum/species/plasmaman/handle_fire(mob/living/carbon/human/H, delta_time, times_fired, no_protection = FALSE)
	if(internal_fire)
		no_protection = TRUE
	. = ..()

/datum/species/plasmaman/pre_equip_species_outfit(datum/job/job, mob/living/carbon/human/equipping, visuals_only = FALSE)
	if(job.plasmaman_outfit)
		equipping.equipOutfit(job.plasmaman_outfit, visuals_only)
	equipping.internal = equipping.get_item_for_held_index(2)
	equipping.update_internals_hud_icon(1)


/datum/species/plasmaman/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_plasmaman_name()

	var/randname = plasmaman_name()

	if(lastname)
		randname += " [lastname]"

	return randname

/datum/species/plasmaman/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H, delta_time, times_fired)
	. = ..()
	if(istype(chem, /datum/reagent/toxin/plasma))
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate * delta_time)
		for(var/i in H.all_wounds)
			var/datum/wound/iter_wound = i
			iter_wound.on_xadone(4 * REAGENTS_EFFECT_MULTIPLIER * delta_time) // plasmamen use plasma to reform their bones or whatever
		return TRUE
	if(istype(chem, /datum/reagent/toxin/bonehurtingjuice))
		H.adjustStaminaLoss(7.5 * REAGENTS_EFFECT_MULTIPLIER * delta_time, 0)
		H.adjustBruteLoss(0.5 * REAGENTS_EFFECT_MULTIPLIER * delta_time, 0)
		if(DT_PROB(10, delta_time))
			switch(rand(1, 3))
				if(1)
					H.say(pick("oof.", "ouch.", "my bones.", "oof ouch.", "oof ouch my bones."), forced = /datum/reagent/toxin/bonehurtingjuice)
				if(2)
					H.manual_emote(pick("oofs silently.", "looks like [H.p_their()] bones hurt.", "grimaces, as though [H.p_their()] bones hurt."))
				if(3)
					to_chat(H, span_warning("Your bones hurt!"))
		if(chem.overdosed)
			if(DT_PROB(2, delta_time) && iscarbon(H)) //big oof
				var/selected_part = pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG) //God help you if the same limb gets picked twice quickly.
				var/obj/item/bodypart/bp = H.get_bodypart(selected_part) //We're so sorry skeletons, you're so misunderstood
				if(bp)
					playsound(H, get_sfx(SFX_DESECRATION), 50, TRUE, -1) //You just want to socialize
					H.visible_message(span_warning("[H] rattles loudly and flails around!!"), span_danger("Your bones hurt so much that your missing muscles spasm!!"))
					H.say("OOF!!", forced=/datum/reagent/toxin/bonehurtingjuice)
					bp.receive_damage(200, 0, 0) //But I don't think we should
				else
					to_chat(H, span_warning("Your missing arm aches from wherever you left it."))
					H.emote("sigh")
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate * delta_time)
		return TRUE

/datum/species/plasmaman/get_species_description()
	return "Found on the Icemoon of Freyja, plasmamen consist of colonial \
		fungal organisms which together form a sentient being. In human space, \
		they're usually attached to skeletons to afford a human touch."

/datum/species/plasmaman/get_species_lore()
	return list(
		"A confusing species, plasmamen are truly \"a fungus among us\". \
		What appears to be a singular being is actually a colony of millions of organisms \
		surrounding a found (or provided) skeletal structure.",

		"Originally discovered by NT when a researcher \
		fell into an open tank of liquid plasma, the previously unnoticed fungal colony overtook the body creating \
		the first \"true\" plasmaman. The process has since been streamlined via generous donations of convict corpses and plasmamen \
		have been deployed en masse throughout NT to bolster the workforce.",

		"New to the galactic stage, plasmamen are a blank slate. \
		Their appearance, generally regarded as \"ghoulish\", inspires a lot of apprehension in their crewmates. \
		It might be the whole \"flammable purple skeleton\" thing.",

		"The colonids that make up plasmamen require the plasma-rich atmosphere they evolved in. \
		Their psuedo-nervous system runs with externalized electrical impulses that immediately ignite their plasma-based bodies when oxygen is present.",
	)

/datum/species/plasmaman/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "user-shield",
			SPECIES_PERK_NAME = "Protected",
			SPECIES_PERK_DESC = "Plasmamen are immune to radiation, poisons, and most diseases.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bone",
			SPECIES_PERK_NAME = "Wound Resistance",
			SPECIES_PERK_DESC = "Plasmamen have higher tolerance for damage that would wound others.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "Plasma Healing",
			SPECIES_PERK_DESC = "Plasmamen can heal wounds by consuming plasma.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "hard-hat",
			SPECIES_PERK_NAME = "Protective Helmet",
			SPECIES_PERK_DESC = "Plasmamen's helmets provide them shielding from the flashes of welding, as well as an inbuilt flashlight.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fire",
			SPECIES_PERK_NAME = "Living Torch",
			SPECIES_PERK_DESC = "Plasmamen instantly ignite when their body makes contact with oxygen.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "wind",
			SPECIES_PERK_NAME = "Plasma Breathing",
			SPECIES_PERK_DESC = "Plasmamen must breathe plasma to survive. You receive a tank when you arrive.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "briefcase-medical",
			SPECIES_PERK_NAME = "Complex Biology",
			SPECIES_PERK_DESC = "Plasmamen take specialized medical knowledge to be \
				treated. Do not expect speedy revival, if you are lucky enough to get \
				one at all.",
		),
	)

	return to_add
