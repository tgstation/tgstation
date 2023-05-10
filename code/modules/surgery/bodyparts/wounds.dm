/// Allows us to roll for and apply a wound without actually dealing damage. Used for aggregate wounding power with pellet clouds
/obj/item/bodypart/proc/painless_wound_roll(wounding_type, phantom_wounding_dmg, wound_bonus, bare_wound_bonus, sharpness=NONE)
	SHOULD_CALL_PARENT(TRUE)

	if(!owner || phantom_wounding_dmg <= WOUND_MINIMUM_DAMAGE || wound_bonus == CANT_WOUND)
		return

	var/mangled_state = get_mangled_state()
	var/easy_dismember = HAS_TRAIT(owner, TRAIT_EASYDISMEMBER) // if we have easydismember, we don't reduce damage when redirecting damage to different types (slashing weapons on mangled/skinless limbs attack at 100% instead of 50%)

	if(wounding_type == WOUND_BLUNT && sharpness)
		if(sharpness & SHARP_EDGED)
			wounding_type = WOUND_SLASH
		else if (sharpness & SHARP_POINTY)
			wounding_type = WOUND_PIERCE

	//Handling for bone only/flesh only(none right now)/flesh and bone targets
	switch(biological_state)
		// if we're bone only, all cutting attacks go straight to the bone
		if(BIO_BONE)
			if(wounding_type == WOUND_SLASH)
				wounding_type = WOUND_BLUNT
				phantom_wounding_dmg *= (easy_dismember ? 1 : 0.6)
			else if(wounding_type == WOUND_PIERCE)
				wounding_type = WOUND_BLUNT
				phantom_wounding_dmg *= (easy_dismember ? 1 : 0.75)
			if((mangled_state & BODYPART_MANGLED_BONE) && try_dismember(wounding_type, phantom_wounding_dmg, wound_bonus, bare_wound_bonus))
				return
		// note that there's no handling for BIO_FLESH since we don't have any that are that right now (slimepeople maybe someday)
		// standard humanoids
		if(BIO_FLESH_BONE)
			// if we've already mangled the skin (critical slash or piercing wound), then the bone is exposed, and we can damage it with sharp weapons at a reduced rate
			// So a big sharp weapon is still all you need to destroy a limb
			if((mangled_state & BODYPART_MANGLED_FLESH) && !(mangled_state & BODYPART_MANGLED_BONE) && sharpness)
				playsound(src, "sound/effects/wounds/crackandbleed.ogg", 100)
				if(wounding_type == WOUND_SLASH && !easy_dismember)
					phantom_wounding_dmg *= 0.6 // edged weapons pass along 60% of their wounding damage to the bone since the power is spread out over a larger area
				if(wounding_type == WOUND_PIERCE && !easy_dismember)
					phantom_wounding_dmg *= 0.75 // piercing weapons pass along 75% of their wounding damage to the bone since it's more concentrated
				wounding_type = WOUND_BLUNT
			else if((mangled_state & BODYPART_MANGLED_FLESH) && (mangled_state & BODYPART_MANGLED_BONE) && try_dismember(wounding_type, phantom_wounding_dmg, wound_bonus, bare_wound_bonus))
				return

	check_wounding(wounding_type, phantom_wounding_dmg, wound_bonus, bare_wound_bonus)

/**
 * check_wounding() is where we handle rolling for, selecting, and applying a wound if we meet the criteria
 *
 * We generate a "score" for how woundable the attack was based on the damage and other factors discussed in [/obj/item/bodypart/proc/check_woundings_mods], then go down the list from most severe to least severe wounds in that category.
 * We can promote a wound from a lesser to a higher severity this way, but we give up if we have a wound of the given type and fail to roll a higher severity, so no sidegrades/downgrades
 *
 * Arguments:
 * * woundtype- Either WOUND_BLUNT, WOUND_SLASH, WOUND_PIERCE, or WOUND_BURN based on the attack type.
 * * damage- How much damage is tied to this attack, since wounding potential scales with damage in an attack (see: WOUND_DAMAGE_EXPONENT)
 * * wound_bonus- The wound_bonus of an attack
 * * bare_wound_bonus- The bare_wound_bonus of an attack
 */
/obj/item/bodypart/proc/check_wounding(woundtype, damage, wound_bonus, bare_wound_bonus, attack_direction)
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/datum/wound)

	if(HAS_TRAIT(owner, TRAIT_NEVER_WOUNDED))
		return

	// note that these are fed into an exponent, so these are magnified
	if(HAS_TRAIT(owner, TRAIT_EASILY_WOUNDED))
		damage *= 1.5
	else
		damage = min(damage, WOUND_MAX_CONSIDERED_DAMAGE)

	if(HAS_TRAIT(owner,TRAIT_HARDLY_WOUNDED))
		damage *= 0.85

	if(HAS_TRAIT(owner, TRAIT_EASYDISMEMBER))
		damage *= 1.1

	var/base_roll = rand(1, round(damage ** WOUND_DAMAGE_EXPONENT))
	var/injury_roll = base_roll
	injury_roll += check_woundings_mods(woundtype, damage, wound_bonus, bare_wound_bonus)
	if(injury_roll > WOUND_DISMEMBER_OUTRIGHT_THRESH && prob(get_damage() / max_damage * 100))
		var/datum/wound/loss/dismembering = new
		dismembering.apply_dismember(src, woundtype, outright = TRUE, attack_direction = attack_direction)
		return

	var/list/wounds_checking = GLOB.global_wound_types[woundtype]
	// quick re-check to see if bare_wound_bonus applies, for the benefit of log_wound(), see about getting the check from check_woundings_mods() somehow
	if(ishuman(owner))
		var/mob/living/carbon/human/human_wearer = owner
		var/list/clothing = human_wearer.clothingonpart(src)
		for(var/obj/item/clothing/clothes_check as anything in clothing)
			// unlike normal armor checks, we tabluate these piece-by-piece manually so we can also pass on appropriate damage the clothing's limbs if necessary
			if(clothes_check.get_armor_rating(WOUND))
				bare_wound_bonus = 0
				break

	//cycle through the wounds of the relevant category from the most severe down
	for(var/datum/wound/possible_wound as anything in wounds_checking)
		var/datum/wound/replaced_wound
		for(var/datum/wound/existing_wound as anything in wounds)
			if(existing_wound.type in wounds_checking)
				if(existing_wound.severity >= initial(possible_wound.severity))
					return
				else
					replaced_wound = existing_wound

		if(initial(possible_wound.threshold_minimum) < injury_roll)
			var/datum/wound/new_wound
			if(replaced_wound)
				new_wound = replaced_wound.replace_wound(possible_wound, attack_direction = attack_direction)
			else
				new_wound = new possible_wound
				new_wound.apply_wound(src, attack_direction = attack_direction)
			log_wound(owner, new_wound, damage, wound_bonus, bare_wound_bonus, base_roll) // dismembering wounds are logged in the apply_wound() for loss wounds since they delete themselves immediately, these will be immediately returned
			return new_wound

// try forcing a specific wound, but only if there isn't already a wound of that severity or greater for that type on this bodypart
/obj/item/bodypart/proc/force_wound_upwards(specific_woundtype, smited = FALSE)
	SHOULD_NOT_OVERRIDE(TRUE)

	var/datum/wound/potential_wound = specific_woundtype
	for(var/datum/wound/existing_wound as anything in wounds)
		if(existing_wound.wound_type == initial(potential_wound.wound_type))
			if(existing_wound.severity < initial(potential_wound.severity)) // we only try if the existing one is inferior to the one we're trying to force
				existing_wound.replace_wound(potential_wound, smited)
			return

	var/datum/wound/new_wound = new potential_wound
	new_wound.apply_wound(src, smited = smited)

/**
 * check_wounding_mods() is where we handle the various modifiers of a wound roll
 *
 * A short list of things we consider: any armor a human target may be wearing, and if they have no wound armor on the limb, if we have a bare_wound_bonus to apply, plus the plain wound_bonus
 * We also flick through all of the wounds we currently have on this limb and add their threshold penalties, so that having lots of bad wounds makes you more liable to get hurt worse
 * Lastly, we add the inherent wound_resistance variable the bodypart has (heads and chests are slightly harder to wound), and a small bonus if the limb is already disabled
 *
 * Arguments:
 * * It's the same ones on [/obj/item/bodypart/proc/receive_damage]
 */
/obj/item/bodypart/proc/check_woundings_mods(wounding_type, damage, wound_bonus, bare_wound_bonus)
	SHOULD_CALL_PARENT(TRUE)

	var/armor_ablation = 0
	var/injury_mod = 0

	if(owner && ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		var/list/clothing = human_owner.clothingonpart(src)
		for(var/obj/item/clothing/clothes as anything in clothing)
			// unlike normal armor checks, we tabluate these piece-by-piece manually so we can also pass on appropriate damage the clothing's limbs if necessary
			armor_ablation += clothes.get_armor_rating(WOUND)
			if(wounding_type == WOUND_SLASH)
				clothes.take_damage_zone(body_zone, damage, BRUTE)
			else if(wounding_type == WOUND_BURN && damage >= 10) // lazy way to block freezing from shredding clothes without adding another var onto apply_damage()
				clothes.take_damage_zone(body_zone, damage, BURN)

		if(!armor_ablation)
			injury_mod += bare_wound_bonus

	injury_mod -= armor_ablation
	injury_mod += wound_bonus

	for(var/datum/wound/wound as anything in wounds)
		injury_mod += wound.threshold_penalty

	var/part_mod = -wound_resistance
	if(get_damage() >= max_damage)
		part_mod += disabled_wound_penalty

	injury_mod += part_mod

	return injury_mod

	/// Get whatever wound of the given type is currently attached to this limb, if any
/obj/item/bodypart/proc/get_wound_type(checking_type)
	RETURN_TYPE(checking_type)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(isnull(wounds))
		return

	for(var/wound in wounds)
		if(istype(wound, checking_type))
			return wound

/**
 * update_wounds() is called whenever a wound is gained or lost on this bodypart, as well as if there's a change of some kind on a bone wound possibly changing disabled status
 *
 * Covers tabulating the damage multipliers we have from wounds (burn specifically), as well as deleting our gauze wrapping if we don't have any wounds that can use bandaging
 *
 * Arguments:
 * * replaced- If true, this is being called from the remove_wound() of a wound that's being replaced, so the bandage that already existed is still relevant, but the new wound hasn't been added yet
 */
/obj/item/bodypart/proc/update_wounds(replaced = FALSE)
	SHOULD_CALL_PARENT(TRUE)

	var/dam_mul = 1 //initial(wound_damage_multiplier)

	// we can (normally) only have one wound per type, but remember there's multiple types (smites like :B:loodless can generate multiple cuts on a limb)
	for(var/datum/wound/iter_wound as anything in wounds)
		dam_mul *= iter_wound.damage_mulitplier_penalty

	if(!LAZYLEN(wounds) && current_gauze && !replaced) // no more wounds = no need for the gauze anymore
		owner.visible_message(span_notice("\The [current_gauze.name] on [owner]'s [name] falls away."), span_notice("The [current_gauze.name] on your [parse_zone(body_zone)] falls away."))
		QDEL_NULL(current_gauze)

	wound_damage_multiplier = dam_mul
	refresh_bleed_rate()
