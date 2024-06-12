/// Allows us to roll for and apply a wound without actually dealing damage. Used for aggregate wounding power with pellet clouds
/obj/item/bodypart/proc/painless_wound_roll(wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus, sharpness=NONE)
	SHOULD_CALL_PARENT(TRUE)

	if(!owner || wounding_dmg <= WOUND_MINIMUM_DAMAGE || wound_bonus == CANT_WOUND || (owner.status_flags & GODMODE))
		return

	var/mangled_state = get_mangled_state()
	var/easy_dismember = HAS_TRAIT(owner, TRAIT_EASYDISMEMBER) // if we have easydismember, we don't reduce damage when redirecting damage to different types (slashing weapons on mangled/skinless limbs attack at 100% instead of 50%)

	var/bio_status = get_bio_state_status()

	var/has_exterior = ((bio_status & ANATOMY_EXTERIOR))
	var/has_interior = ((bio_status & ANATOMY_INTERIOR))

	var/exterior_ready_to_dismember = (!has_exterior || ((mangled_state & BODYPART_MANGLED_EXTERIOR)))

	// if we're bone only, all cutting attacks go straight to the bone
	if(!has_exterior && has_interior)
		if(wounding_type == WOUND_SLASH)
			wounding_type = WOUND_BLUNT
			wounding_dmg *= (easy_dismember ? 1 : 0.6)
		else if(wounding_type == WOUND_PIERCE)
			wounding_type = WOUND_BLUNT
			wounding_dmg *= (easy_dismember ? 1 : 0.75)
	else
		// if we've already mangled the skin (critical slash or piercing wound), then the bone is exposed, and we can damage it with sharp weapons at a reduced rate
		// So a big sharp weapon is still all you need to destroy a limb
		if(has_interior && exterior_ready_to_dismember && !(mangled_state & BODYPART_MANGLED_INTERIOR) && sharpness)
			if(wounding_type == WOUND_SLASH && !easy_dismember)
				wounding_dmg *= 0.6 // edged weapons pass along 60% of their wounding damage to the bone since the power is spread out over a larger area
			if(wounding_type == WOUND_PIERCE && !easy_dismember)
				wounding_dmg *= 0.75 // piercing weapons pass along 75% of their wounding damage to the bone since it's more concentrated
			wounding_type = WOUND_BLUNT
		if ((dismemberable_by_wound() || dismemberable_by_total_damage()) && try_dismember(wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus))
			return
	return check_wounding(wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus)

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
/obj/item/bodypart/proc/check_wounding(woundtype, damage, wound_bonus, bare_wound_bonus, attack_direction, damage_source)
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/datum/wound)

	if(HAS_TRAIT(owner, TRAIT_NEVER_WOUNDED) || (owner.status_flags & GODMODE))
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

	if(HAS_TRAIT(owner, TRAIT_EASYBLEED) && ((woundtype == WOUND_PIERCE) || (woundtype == WOUND_SLASH)))
		damage *= 1.5

	var/base_roll = rand(1, round(damage ** WOUND_DAMAGE_EXPONENT))
	var/injury_roll = base_roll
	injury_roll += check_woundings_mods(woundtype, damage, wound_bonus, bare_wound_bonus)
	var/list/series_wounding_mods = check_series_wounding_mods()

	if(injury_roll > WOUND_DISMEMBER_OUTRIGHT_THRESH && prob(get_damage() / max_damage * 100) && can_dismember())
		var/datum/wound/loss/dismembering = new
		dismembering.apply_dismember(src, woundtype, outright = TRUE, attack_direction = attack_direction)
		return

	var/list/datum/wound/possible_wounds = list()
	for (var/datum/wound/type as anything in GLOB.all_wound_pregen_data)
		var/datum/wound_pregen_data/pregen_data = GLOB.all_wound_pregen_data[type]
		if (pregen_data.can_be_applied_to(src, list(woundtype), random_roll = TRUE))
			possible_wounds[type] = pregen_data.get_weight(src, woundtype, damage, attack_direction, damage_source)
	// quick re-check to see if bare_wound_bonus applies, for the benefit of log_wound(), see about getting the check from check_woundings_mods() somehow
	if(ishuman(owner))
		var/mob/living/carbon/human/human_wearer = owner
		var/list/clothing = human_wearer.get_clothing_on_part(src)
		for(var/obj/item/clothing/clothes_check as anything in clothing)
			// unlike normal armor checks, we tabluate these piece-by-piece manually so we can also pass on appropriate damage the clothing's limbs if necessary
			if(clothes_check.get_armor_rating(WOUND))
				bare_wound_bonus = 0
				break

	for (var/datum/wound/iterated_path as anything in possible_wounds)
		for (var/datum/wound/existing_wound as anything in wounds)
			if (iterated_path == existing_wound.type)
				possible_wounds -= iterated_path
				break // breaks out of the nested loop

		var/datum/wound_pregen_data/pregen_data = GLOB.all_wound_pregen_data[iterated_path]
		var/specific_injury_roll = (injury_roll + series_wounding_mods[pregen_data.wound_series])
		if (pregen_data.get_threshold_for(src, attack_direction, damage_source) > specific_injury_roll)
			possible_wounds -= iterated_path
			continue

		if (pregen_data.compete_for_wounding)
			for (var/datum/wound/other_path as anything in possible_wounds)
				if (other_path == iterated_path)
					continue
				if (initial(iterated_path.severity) == initial(other_path.severity) && pregen_data.overpower_wounds_of_even_severity)
					possible_wounds -= other_path
					continue
				else if (pregen_data.competition_mode == WOUND_COMPETITION_OVERPOWER_LESSERS)
					if (initial(iterated_path.severity) > initial(other_path.severity))
						possible_wounds -= other_path
						continue
				else if (pregen_data.competition_mode == WOUND_COMPETITION_OVERPOWER_GREATERS)
					if (initial(iterated_path.severity) < initial(other_path.severity))
						possible_wounds -= other_path
						continue

	while (TRUE)
		var/datum/wound/possible_wound = pick_weight(possible_wounds)
		if (isnull(possible_wound))
			break

		possible_wounds -= possible_wound
		var/datum/wound_pregen_data/possible_pregen_data = GLOB.all_wound_pregen_data[possible_wound]

		var/datum/wound/replaced_wound
		for(var/datum/wound/existing_wound as anything in wounds)
			var/datum/wound_pregen_data/existing_pregen_data = GLOB.all_wound_pregen_data[existing_wound.type]
			if(existing_pregen_data.wound_series == possible_pregen_data.wound_series)
				if(existing_wound.severity >= initial(possible_wound.severity))
					continue
				else
					replaced_wound = existing_wound
			// if we get through this whole loop without continuing, we found our winner

		var/datum/wound/new_wound = new possible_wound
		if(replaced_wound)
			new_wound = replaced_wound.replace_wound(new_wound, attack_direction = attack_direction)
		else
			new_wound.apply_wound(src, attack_direction = attack_direction, wound_source = damage_source)
		log_wound(owner, new_wound, damage, wound_bonus, bare_wound_bonus, base_roll) // dismembering wounds are logged in the apply_wound() for loss wounds since they delete themselves immediately, these will be immediately returned
		return new_wound

// try forcing a specific wound, but only if there isn't already a wound of that severity or greater for that type on this bodypart
/obj/item/bodypart/proc/force_wound_upwards(datum/wound/potential_wound, smited = FALSE, wound_source)
	SHOULD_NOT_OVERRIDE(TRUE)

	if (isnull(potential_wound))
		return

	var/datum/wound_pregen_data/pregen_data = GLOB.all_wound_pregen_data[potential_wound]
	for(var/datum/wound/existing_wound as anything in wounds)
		var/datum/wound_pregen_data/existing_pregen_data = existing_wound.get_pregen_data()
		if (existing_pregen_data.wound_series == pregen_data.wound_series)
			if(existing_wound.severity < initial(potential_wound.severity)) // we only try if the existing one is inferior to the one we're trying to force
				existing_wound.replace_wound(new potential_wound, smited)
			return

	var/datum/wound/new_wound = new potential_wound
	new_wound.apply_wound(src, smited = smited, wound_source = wound_source)
	return new_wound

/**
 *  A simple proc to force a type of wound onto this mob. If you just want to force a specific mainline (fractures, bleeding, etc.) wound, you only need to care about the first 3 args.
 *
 * Args:
 * * wounding_type: The wounding_type, e.g. WOUND_BLUNT, WOUND_SLASH to force onto the mob. Can be a list.
 * * obj/item/bodypart/limb: The limb we wil be applying the wound to. If null, a random bodypart will be picked.
 * * min_severity: The minimum severity that will be considered.
 * * max_severity: The maximum severity that will be considered.
 * * severity_pick_mode: The "pick mode" to be used. See get_corresponding_wound_type's documentation
 * * wound_source: The source of the wound to be applied. Nullable.
 *
 * For the rest of the args, refer to get_corresponding_wound_type().
 *
 * Returns:
 * A new wound instance if the application was successful, null otherwise.
*/
/mob/living/carbon/proc/cause_wound_of_type_and_severity(wounding_type, obj/item/bodypart/limb, min_severity, max_severity = min_severity, severity_pick_mode = WOUND_PICK_HIGHEST_SEVERITY, wound_source)
	if (isnull(limb))
		limb = pick(bodyparts)

	var/list/type_list = wounding_type
	if (!islist(type_list))
		type_list = list(type_list)

	var/datum/wound/corresponding_typepath = get_corresponding_wound_type(type_list, limb, min_severity, max_severity, severity_pick_mode)
	if (corresponding_typepath)
		return limb.force_wound_upwards(corresponding_typepath, wound_source = wound_source)

/// Limb is nullable, but picks a random one. Defers to limb.get_wound_threshold_of_wound_type, see it for documentation.
/mob/living/carbon/proc/get_wound_threshold_of_wound_type(wounding_type, severity, default, obj/item/bodypart/limb, wound_source)
	if (isnull(limb))
		limb = pick(bodyparts)

	if (!limb)
		return default

	return limb.get_wound_threshold_of_wound_type(wounding_type, severity, default, wound_source)

/**
 * A simple proc that gets the best wound to fit the criteria laid out, then returns its wound threshold.
 *
 * Args:
 * * wounding_type: The wounding_type, e.g. WOUND_BLUNT, WOUND_SLASH to force onto the mob. Can be a list of wounding_types.
 * * severity: The severity that will be considered.
 * * return_value_if_no_wound: If no wound is found, we will return this instead. (It is reccomended to use named args for this one, as its unclear what it is without)
 * * wound_source: The theoretical source of the wound. Nullable.
 *
 * Returns:
 * return_value_if_no_wound if no wound is found - if one IS found, the wound threshold for that wound.
 */
/obj/item/bodypart/proc/get_wound_threshold_of_wound_type(wounding_type, severity, return_value_if_no_wound, wound_source)
	var/list/type_list = wounding_type
	if (!islist(type_list))
		type_list = list(type_list)

	var/datum/wound/wound_path = get_corresponding_wound_type(type_list, src, severity, duplicates_allowed = TRUE, care_about_existing_wounds = FALSE)
	if (wound_path)
		var/datum/wound_pregen_data/pregen_data = GLOB.all_wound_pregen_data[wound_path]
		return pregen_data.get_threshold_for(src, damage_source = wound_source)

	return return_value_if_no_wound

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
		var/list/clothing = human_owner.get_clothing_on_part(src)
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

/// Should return an assoc list of (wound_series -> penalty). Will be used in determining series-specific penalties for wounding.
/obj/item/bodypart/proc/check_series_wounding_mods()
	RETURN_TYPE(/list)

	var/list/series_mods = list()

	for (var/datum/wound/iterated_wound as anything in wounds)
		var/datum/wound_pregen_data/pregen_data = GLOB.all_wound_pregen_data[iterated_wound.type]

		series_mods[pregen_data.wound_series] += iterated_wound.series_threshold_penalty

	return series_mods

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

	var/dam_mul = 1

	// we can (normally) only have one wound per type, but remember there's multiple types (smites like :B:loodless can generate multiple cuts on a limb)
	for(var/datum/wound/iter_wound as anything in wounds)
		dam_mul *= iter_wound.damage_multiplier_penalty

	if(!LAZYLEN(wounds) && current_gauze && !replaced) // no more wounds = no need for the gauze anymore
		owner.visible_message(span_notice("\The [current_gauze.name] on [owner]'s [name] falls away."), span_notice("The [current_gauze.name] on your [plaintext_zone] falls away."))
		QDEL_NULL(current_gauze)

	wound_damage_multiplier = dam_mul
	refresh_bleed_rate()
