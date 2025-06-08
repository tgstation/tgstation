/datum/mutation/shock
	name = "Shock Touch"
	desc = "The affected can channel excess electricity through their hands without shocking themselves, allowing them to shock others. Mostly harmless! Mostly... "
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	text_gain_indication = span_notice("You feel power flow through your hands.")
	text_lose_indication = span_notice("The energy in your hands subsides.")
	power_path = /datum/action/cooldown/spell/touch/shock
	instability = POSITIVE_INSTABILITY_MODERATE // bad stun baton
	energy_coeff = 1
	power_coeff = 1

/datum/mutation/shock/setup()
	. = ..()
	var/datum/action/cooldown/spell/touch/shock/to_modify =.

	if(!istype(to_modify)) // null or invalid
		return

	if(GET_MUTATION_POWER(src) <= 1)
		to_modify.stagger = initial(to_modify.stagger)
		return

	to_modify.stagger = TRUE

/datum/action/cooldown/spell/touch/shock
	name = "Shock Touch"
	desc = "Channel electricity to your hand to shock people with. Mostly harmless! Mostly... "
	button_icon_state = "zap"
	sound = 'sound/items/weapons/zapbang.ogg'
	cooldown_time = 7 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	antimagic_flags = NONE

	///This var decides if the spell should stagger, dictated by presence of power chromosome
	var/stagger = FALSE

	hand_path = /obj/item/melee/touch_attack/shock
	draw_message = span_notice("You channel electricity into your hand.")
	drop_message = span_notice("You let the electricity from your hand dissipate.")

/datum/action/cooldown/spell/touch/shock/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	if(iscarbon(victim))
		var/mob/living/carbon/carbon_victim = victim
		if(carbon_victim.electrocute_act(5, caster, 1, SHOCK_NOGLOVES | SHOCK_NOSTUN))//doesn't stun. never let this stun

			var/obj/item/bodypart/affecting = carbon_victim.get_bodypart(carbon_victim.get_random_valid_zone(caster.zone_selected))
			var/armor_block = carbon_victim.run_armor_check(affecting, ENERGY)
			carbon_victim.apply_damage(20, STAMINA, def_zone = affecting, blocked = armor_block)

			carbon_victim.dropItemToGround(carbon_victim.get_active_held_item())
			carbon_victim.dropItemToGround(carbon_victim.get_inactive_held_item())
			carbon_victim.adjust_confusion(15 SECONDS)
			carbon_victim.visible_message(
				span_danger("[caster] electrocutes [victim]!"),
				span_userdanger("[caster] electrocutes you!"),
			)
			if(stagger)
				carbon_victim.adjust_staggered_up_to(STAGGERED_SLOWDOWN_LENGTH * 2, 10 SECONDS)
			return TRUE

	else if(isliving(victim))
		var/mob/living/living_victim = victim
		if(living_victim.electrocute_act(15, caster, 1, SHOCK_NOSTUN)) //We do damage here because non-carbon mobs typically ignore stamina damage.
			living_victim.visible_message(
				span_danger("[caster] electrocutes [victim]!"),
				span_userdanger("[caster] electrocutes you!"),
			)
			if(stagger)
				living_victim.adjust_staggered_up_to(STAGGERED_SLOWDOWN_LENGTH * 2, 10 SECONDS)
			return TRUE

	to_chat(caster, span_warning("The electricity doesn't seem to affect [victim]..."))
	return TRUE

/obj/item/melee/touch_attack/shock
	name = "\improper shock touch"
	desc = "This is kind of like when you rub your feet on a shag rug so you can zap your friends, only a lot less safe."
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "zapper"
	inhand_icon_state = "zapper"

/datum/mutation/lay_on_hands
	name = "Mending Touch"
	desc = "The affected can lay their hands on other people to transfer a small amount of their injuries to themselves."
	quality = POSITIVE
	locked = FALSE
	difficulty = 16
	text_gain_indication = span_notice("Your hand feels blessed!")
	text_lose_indication = span_notice("Your hand feels secular once more.")
	power_path = /datum/action/cooldown/spell/touch/lay_on_hands
	instability = POSITIVE_INSTABILITY_MAJOR
	energy_coeff = 1
	power_coeff = 1
	synchronizer_coeff = 1

/datum/mutation/lay_on_hands/setup()
	. = ..()
	var/datum/action/cooldown/spell/touch/lay_on_hands/to_modify =.

	if(!istype(to_modify)) // null or invalid
		return

	// Transfers more damage if strengthened. (1.5 with power chromosome)
	to_modify.power_coefficient = GET_MUTATION_POWER(src)
	// Halves transferred damage if synchronized. (0.5 with synchronizer chromosome)
	to_modify.synchronizer_coefficient = GET_MUTATION_SYNCHRONIZER(src)

/datum/action/cooldown/spell/touch/lay_on_hands
	name = "Mending Touch"
	desc = "You can now lay your hands on other people to transfer a small amount of their physical injuries to yourself. \
		For some reason, this power does not play nicely with the undead, or people with strange ideas about morality."
	button_icon = 'icons/mob/actions/actions_genetic.dmi'
	button_icon_state = "mending_touch"
	sound = 'sound/effects/magic/staff_healing.ogg'
	cooldown_time = 12 SECONDS
	school = SCHOOL_RESTORATION
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	antimagic_flags = NONE

	hand_path = /obj/item/melee/touch_attack/lay_on_hands
	draw_message = span_notice("You ready your hand to transfer injuries to yourself.")
	drop_message = span_notice("You lower your hand.")
	/// Multiplies the amount healed.
	var/heal_multiplier = 1
	/// Multiplies the incoming pain from healing. (Halved with synchronizer chromosome)
	var/pain_multiplier = 1
	/// Icon used for beaming effect
	var/beam_icon = "blood"
	/// The mutation's power coefficient.
	var/power_coefficient = 1
	/// The mutation's synchronizer coefficient.
	var/synchronizer_coefficient = 1

/datum/action/cooldown/spell/touch/lay_on_hands/create_hand(mob/living/carbon/cast_on)
	. = ..()
	if(!.)
		return .
	var/obj/item/bodypart/transfer_limb = cast_on.get_active_hand()
	if(IS_ROBOTIC_LIMB(transfer_limb))
		to_chat(cast_on, span_notice("You fail to channel your mending powers through your inorganic hand."))
		return FALSE

	return TRUE

/datum/action/cooldown/spell/touch/lay_on_hands/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/mendicant)

	var/mob/living/hurtguy = victim

	heal_multiplier = initial(heal_multiplier) * power_coefficient
	pain_multiplier = initial(pain_multiplier) * synchronizer_coefficient

	// Message to show on a successful heal if the healer has a special pacifism interaction with the mutation.
	var/peaceful_message = null

	var/success

	var/hurt_this_guy = determine_if_this_hurts_instead(mendicant, hurtguy)

	if (hurt_this_guy && (HAS_TRAIT(mendicant, TRAIT_PACIFISM) || !mendicant.combat_mode)) //Returns if we're a pacifist and we'd hurt them, or we're not in combat mode and we'll hurt them
		mendicant.balloon_alert(mendicant, "[hurtguy] would be hurt!")
		return FALSE

	if(hurt_this_guy)
		return by_gods_light_i_smite_you(mendicant, hurtguy, heal_multiplier)

	// Heal more, hurt a bit more.
	// If you crunch the numbers it sounds crazy good,
	// but I think that's a fair reward for combining the efforts of Genetics, Medbay, and Mining to reach a hidden mechanic.
	if(HAS_TRAIT_FROM(mendicant, TRAIT_HIPPOCRATIC_OATH, HIPPOCRATIC_OATH_TRAIT))
		heal_multiplier *= 2
		pain_multiplier *= 0.5
		peaceful_message = span_boldnotice("You can feel the magic of the Rod of Aesculapius aiding your efforts!")
		beam_icon = "sendbeam"
		var/obj/item/rod_of_asclepius/rod = locate() in mendicant.contents
		if(rod)
			rod.add_filter("cool_glow", 2, list("type" = "outline", "color" = COLOR_VERY_PALE_LIME_GREEN, "size" = 1.25))
			addtimer(CALLBACK(rod, TYPE_PROC_REF(/datum, remove_filter), "cool_glow"), 6 SECONDS)

	// If a normal pacifist, transfer more.
	else if(HAS_TRAIT(mendicant, TRAIT_PACIFISM))
		heal_multiplier *= 1.75
		peaceful_message = span_boldnotice("Your peaceful nature helps you guide all the pain to yourself.")

	if(iscarbon(hurtguy))
		success = do_complicated_heal(mendicant, hurtguy, heal_multiplier, pain_multiplier)
	else
		success = do_simple_heal(mendicant, hurtguy, heal_multiplier, pain_multiplier)

	// No healies in the end, cancel
	if(!success)
		return FALSE

	if(peaceful_message)
		to_chat(mendicant, peaceful_message)

	// Both types can be ignited (technically at least), so we can just do this here.
	if(hurtguy.fire_stacks > 0)
		mendicant.set_fire_stacks(hurtguy.fire_stacks * pain_multiplier, remove_wet_stacks = TRUE)
		if(hurtguy.on_fire)
			mendicant.ignite_mob()
			hurtguy.extinguish_mob()

	mendicant.Beam(hurtguy, icon_state = beam_icon, time = 0.5 SECONDS)
	beam_icon = initial(beam_icon)

	hurtguy.update_damage_overlays()
	mendicant.update_damage_overlays()

	hurtguy.visible_message(span_notice("[mendicant] lays hands on [hurtguy]!"))
	to_chat(hurtguy, span_boldnotice("[mendicant] lays hands on you, healing you!"))
	new /obj/effect/temp_visual/heal(get_turf(hurtguy), COLOR_VERY_PALE_LIME_GREEN)
	return success

/datum/action/cooldown/spell/touch/lay_on_hands/proc/do_simple_heal(mob/living/carbon/mendicant, mob/living/hurtguy, heal_multiplier, pain_multiplier)
	// Did the transfer work?
	. = FALSE

	// Damage to heal
	var/brute_to_heal = min(hurtguy.getBruteLoss(), 35 * heal_multiplier)
	// no double dipping
	var/burn_to_heal = min(hurtguy.getFireLoss(), (35 - brute_to_heal) * heal_multiplier)

	// Get at least organic limb to transfer the damage to
	var/list/mendicant_organic_limbs = list()
	for(var/obj/item/bodypart/possible_limb in mendicant.bodyparts)
		if(IS_ORGANIC_LIMB(possible_limb))
			mendicant_organic_limbs += possible_limb
	// None? Gtfo
	if(!length(mendicant_organic_limbs))
		mendicant.balloon_alert(mendicant, "no organic limbs!")
		return .

	// Try to use our active hand, otherwise pick at random
	var/obj/item/bodypart/mendicant_transfer_limb = mendicant.get_active_hand()
	if(!(mendicant_transfer_limb in mendicant_organic_limbs))
		mendicant_transfer_limb = pick(mendicant_organic_limbs)
		mendicant_transfer_limb.receive_damage(brute_to_heal * pain_multiplier, burn_to_heal * pain_multiplier, forced = TRUE, wound_bonus = CANT_WOUND)

	if(brute_to_heal)
		hurtguy.adjustBruteLoss(-brute_to_heal)
		. = TRUE

	if(burn_to_heal)
		hurtguy.adjustFireLoss(-burn_to_heal)
		. = TRUE

	if(!.)
		hurtguy.balloon_alert(mendicant, "unhurt!")

/datum/action/cooldown/spell/touch/lay_on_hands/proc/do_complicated_heal(mob/living/carbon/mendicant, mob/living/carbon/hurtguy, heal_multiplier, pain_multiplier)

	// Did the transfer work?
	. = FALSE
	// Get the hurtguy's limbs and the mendicant's limbs to attempt a 1-1 transfer.
	var/list/hurt_limbs = hurtguy.get_damaged_bodyparts(1, 1, BODYTYPE_ORGANIC) + hurtguy.get_wounded_bodyparts(BODYTYPE_ORGANIC)
	var/list/mendicant_organic_limbs = list()
	for(var/obj/item/bodypart/possible_limb in mendicant.bodyparts)
		if(IS_ORGANIC_LIMB(possible_limb))
			mendicant_organic_limbs += possible_limb

	// If we have no organic available limbs just give up.
	if(!length(mendicant_organic_limbs))
		mendicant.balloon_alert(mendicant, "no organic limbs!")
		return .
	if(!length(hurt_limbs))
		hurtguy.balloon_alert(mendicant, "no damaged organic limbs!")
		return .

	// Counter to make sure we don't take too much from separate limbs
	var/total_damage_healed = 0
	// Transfer damage from one limb to the mendicant's counterpart.
	for(var/obj/item/bodypart/affected_limb as anything in hurt_limbs)
		var/obj/item/bodypart/mendicant_transfer_limb = mendicant.get_bodypart(affected_limb.body_zone)
		// If the compared limb isn't organic, skip it and pick a random one.
		if(!(mendicant_transfer_limb in mendicant_organic_limbs))
			mendicant_transfer_limb = pick(mendicant_organic_limbs)

		// Transfer at most 35 damage, by default.
		var/brute_damage = min(affected_limb.brute_dam, 35 * heal_multiplier)
		// no double dipping
		var/burn_damage = min(affected_limb.burn_dam, (35 * heal_multiplier) - brute_damage)
		if((brute_damage || burn_damage) && total_damage_healed < (35 * heal_multiplier))
			total_damage_healed += brute_damage + burn_damage
			. = TRUE
			var/brute_taken = brute_damage * pain_multiplier
			var/burn_taken = burn_damage * pain_multiplier
			// Heal!
			affected_limb.heal_damage(brute_damage, burn_damage, required_bodytype = BODYTYPE_ORGANIC)
			// Hurt!
			mendicant_transfer_limb.receive_damage(brute_taken, burn_taken, forced = TRUE, wound_bonus = CANT_WOUND)

		// Force light wounds onto you.
		for(var/datum/wound/iter_wound as anything in affected_limb.wounds)
			switch(iter_wound.severity)
				if(WOUND_SEVERITY_SEVERE) // half and half
					if(prob(50 * heal_multiplier))
						continue
				if(WOUND_SEVERITY_CRITICAL)
					if(heal_multiplier < 1.5) // need buffs to transfer crit wounds
						continue
			. = TRUE
			iter_wound.remove_wound()
			iter_wound.apply_wound(mendicant_transfer_limb)

	if(HAS_TRAIT(mendicant, TRAIT_NOBLOOD))
		return .

	// 10% base
	var/max_blood_transfer = (BLOOD_VOLUME_NORMAL * 0.10) * heal_multiplier
	// Too little blood
	if(hurtguy.blood_volume < BLOOD_VOLUME_NORMAL)
		var/max_blood_to_hurtguy = min(mendicant.blood_volume, BLOOD_VOLUME_NORMAL - hurtguy.blood_volume)
		var/blood_to_hurtguy = min(max_blood_transfer, max_blood_to_hurtguy)
		if(!blood_to_hurtguy)
			return .

		// We ignore incompatibility here.
		if(!mendicant.transfer_blood_to(hurtguy, blood_to_hurtguy, forced = TRUE, ignore_incompatibility = TRUE))
			return

		to_chat(mendicant, span_notice("Your veins (and brain) feel a bit lighter."))
		. = TRUE
		// Because we do our own spin on it!
		if(hurtguy.get_blood_compatibility(mendicant) == FALSE)
			hurtguy.adjustToxLoss((blood_to_hurtguy * 0.1) * pain_multiplier) // 1 dmg per 10 blood
			to_chat(hurtguy, span_notice("Your veins feel thicker, but they itch a bit."))
		else
			to_chat(hurtguy, span_notice("Your veins feel thicker!"))
		return

	if(hurtguy.blood_volume < BLOOD_VOLUME_MAXIMUM)
		return

	// Too MUCH blood
	var/max_blood_to_mendicant = BLOOD_VOLUME_EXCESS - hurtguy.blood_volume
	var/blood_to_mendicant = min(max_blood_transfer, max_blood_to_mendicant)
	// mender always gonna have blood

	// We ignore incompatibility here.
	if(!hurtguy.transfer_blood_to(mendicant, hurtguy.blood_volume - BLOOD_VOLUME_EXCESS, forced = TRUE, ignore_incompatibility = TRUE))
		return

	to_chat(hurtguy, span_notice("Your veins don't feel quite so swollen anymore."))
	. = TRUE
	// Because we do our own spin on it!
	if(mendicant.get_blood_compatibility(hurtguy) == FALSE)
		mendicant.adjustToxLoss((blood_to_mendicant * 0.1) * pain_multiplier) // 1 dmg per 10 blood
		to_chat(mendicant, span_notice("Your veins swell and itch!"))
	else
		to_chat(mendicant, span_notice("Your veins swell!"))


/datum/action/cooldown/spell/touch/lay_on_hands/proc/determine_if_this_hurts_instead(mob/living/carbon/mendicant, mob/living/hurtguy)

	if(hurtguy.mob_biotypes & MOB_UNDEAD && mendicant.mob_biotypes & MOB_UNDEAD)
		return FALSE //always return false if we're both undead //undead solidarity

	if(hurtguy.mob_biotypes & MOB_UNDEAD && !HAS_TRAIT(mendicant, TRAIT_EVIL)) //Is the mob undead and we're not evil? If so, hurt.
		return TRUE

	if(HAS_TRAIT(hurtguy, TRAIT_EVIL) && !HAS_TRAIT(mendicant, TRAIT_EVIL)) //Is the guy evil and we're not evil? If so, hurt.
		return TRUE

	if(!(hurtguy.mob_biotypes & MOB_UNDEAD) && HAS_TRAIT(hurtguy, TRAIT_EMPATH) && HAS_TRAIT(mendicant, TRAIT_EVIL)) //Is the guy not undead, they're an empath and we're evil? If so, hurt.
		return TRUE

	return FALSE

///If our target was undead or evil, we blast them with a firey beam rather than healing them. For, you know, 'holy' reasons. When did genes become so morally uptight?

/datum/action/cooldown/spell/touch/lay_on_hands/proc/by_gods_light_i_smite_you(mob/living/carbon/smiter, mob/living/motherfucker_to_hurt, smite_multiplier)
	var/our_smite_multiplier = smite_multiplier
	var/evil_smite = HAS_TRAIT(smiter, TRAIT_EVIL) ? TRUE : FALSE
	var/divine_champion = smiter.mind?.holy_role >= HOLY_ROLE_PRIEST ? TRUE : FALSE
	var/smite_text_to_target = "lays hands on you"

	if(divine_champion || HAS_TRAIT(smiter, TRAIT_SPIRITUAL))

		// Defaults for possible deity. You know, just in case.
		var/possible_deity = evil_smite ? "Satan" : "God"

		var/mob/living/carbon/human/human_smiter = smiter

		// If we have a client, check their deity pref and use that instead of our chaps god if our smiter is a spiritualist
		var/client/smiter_client = smiter.client

		if(smiter_client && HAS_TRAIT(smiter, TRAIT_SPIRITUAL))
			possible_deity = smiter_client.prefs?.read_preference(/datum/preference/name/deity)
		else if (GLOB.deity)
			possible_deity = GLOB.deity

		if(ishuman(human_smiter))
			human_smiter.force_say()
			if(evil_smite)
				human_smiter.say("in [possible_deity]'s dark name, I COMMAND YOU TO PERISH!!!", forced = "compelled by the power of their deity")
			else
				human_smiter.say("By [possible_deity]'s might, I SMITE YOU!!!", forced = "compelled by the power of their deity")
		our_smite_multiplier *= divine_champion ? 5 : 1 //good luck surviving this if they're a chap

	if(evil_smite)
		motherfucker_to_hurt.visible_message(span_warning("[smiter] snaps [smiter.p_their()] fingers in front of [motherfucker_to_hurt]'s face, and [motherfucker_to_hurt]'s body twists violently from an unseen force!"))
		motherfucker_to_hurt.apply_damage(10 * our_smite_multiplier, BRUTE, spread_damage = TRUE, wound_bonus = 5 * our_smite_multiplier)
		motherfucker_to_hurt.adjust_staggered_up_to(STAGGERED_SLOWDOWN_LENGTH * our_smite_multiplier, 25 SECONDS)
		smiter.emote("snap")
		smite_text_to_target = "crushes you psychically with a snap of [smiter.p_their()] fingers"
	else
		motherfucker_to_hurt.visible_message(span_warning("[smiter] lays hands on [motherfucker_to_hurt], but it shears [motherfucker_to_hurt.p_them()] with a brilliant energy!"))
		motherfucker_to_hurt.apply_damage(10 * our_smite_multiplier, BURN, spread_damage = TRUE, wound_bonus = 5 * our_smite_multiplier)
		motherfucker_to_hurt.adjust_fire_stacks(3 * our_smite_multiplier)
		motherfucker_to_hurt.ignite_mob()

	motherfucker_to_hurt.update_damage_overlays()

	to_chat(motherfucker_to_hurt, span_bolddanger("[smiter] [smite_text_to_target], hurting you!"))
	motherfucker_to_hurt.emote("scream")
	new /obj/effect/temp_visual/explosion(get_turf(motherfucker_to_hurt), evil_smite ? LIGHT_COLOR_BLOOD_MAGIC : LIGHT_COLOR_HOLY_MAGIC)
	. = TRUE

/obj/item/melee/touch_attack/lay_on_hands
	name = "mending touch"
	desc = "Unlike in your favorite tabletop games, you sadly can't cast this on yourself, so you can't use that as a Scapegoat." // mayus is reference. if you get it you're cool
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "greyscale"
	color = COLOR_VERY_PALE_LIME_GREEN
	inhand_icon_state = "greyscale"
	item_flags = parent_type::item_flags & ~NEEDS_PERMIT
