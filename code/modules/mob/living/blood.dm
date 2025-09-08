#define BLOOD_DRIP_RATE_MOD 90 //Greater number means creating blood drips more often while bleeding
// Conversion between internal drunk power and common blood alcohol content
#define DRUNK_POWER_TO_BLOOD_ALCOHOL 0.003

/****************************************************
				BLOOD SYSTEM
****************************************************/

// Takes care blood loss and regeneration
/mob/living/carbon/human/handle_blood(seconds_per_tick, times_fired)
	// Under these circumstances blood handling is not necessary
	if(bodytemperature < BLOOD_STOP_TEMP || HAS_TRAIT(src, TRAIT_FAKEDEATH) || HAS_TRAIT(src, TRAIT_HUSK))
		return
	// Run the signal, still allowing mobs with noblood to "handle blood" in their own way
	var/sigreturn = SEND_SIGNAL(src, COMSIG_HUMAN_ON_HANDLE_BLOOD, seconds_per_tick, times_fired)
	if((sigreturn & HANDLE_BLOOD_HANDLED) || HAS_TRAIT(src, TRAIT_NOBLOOD))
		return

	//Blood regeneration if there is some space
	if(!(sigreturn & HANDLE_BLOOD_NO_NUTRITION_DRAIN))
		if(blood_volume < BLOOD_VOLUME_NORMAL && !HAS_TRAIT(src, TRAIT_NOHUNGER))
			var/nutrition_ratio = round(nutrition / NUTRITION_LEVEL_WELL_FED, 0.2)
			if(satiety > 80)
				nutrition_ratio *= 1.25
			adjust_nutrition(-nutrition_ratio * HUNGER_FACTOR * seconds_per_tick)
			blood_volume = min(blood_volume + (BLOOD_REGEN_FACTOR * physiology.blood_regen_mod * nutrition_ratio * seconds_per_tick), BLOOD_VOLUME_NORMAL)

	//Bloodloss from wounds
	var/temp_bleed = 0
	for(var/obj/item/bodypart/iter_part as anything in bodyparts)
		temp_bleed += iter_part.cached_bleed_rate * seconds_per_tick

		if(iter_part.generic_bleedstacks) // If you don't have any bleedstacks, don't try and heal them
			iter_part.adjustBleedStacks(-1, 0)

	if(temp_bleed)
		bleed(temp_bleed)
		bleed_warn(temp_bleed)

	//Effects of bloodloss
	if(sigreturn & HANDLE_BLOOD_NO_OXYLOSS)
		return

	// Some effects are halved mid-combat.
	var/determined_mod = has_status_effect(/datum/status_effect/determined) ? 0.5 : 0

	var/word = pick("dizzy","woozy","faint")
	switch(blood_volume)
		if(BLOOD_VOLUME_EXCESS to BLOOD_VOLUME_MAX_LETHAL)
			if(SPT_PROB(7.5, seconds_per_tick))
				to_chat(src, span_userdanger("Blood starts to tear your skin apart. You're going to burst!"))
				investigate_log("has been gibbed by having too much blood.", INVESTIGATE_DEATHS)
				inflate_gib()
		// Way too much blood!
		if(BLOOD_VOLUME_EXCESS to BLOOD_VOLUME_MAX_LETHAL)
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(src, span_warning("You feel your skin swelling."))
		// Too much blood
		if(BLOOD_VOLUME_MAXIMUM to BLOOD_VOLUME_EXCESS)
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(src, span_warning("You feel terribly bloated."))
		// Low blood but not a big deal in the immediate
		if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
			if(SPT_PROB(2.5, seconds_per_tick))
				set_eye_blur_if_lower(2 SECONDS * determined_mod)
				if(prob(50))
					to_chat(src, span_danger("You feel [word]. It's getting a bit hard to breathe."))
					losebreath += 0.5 * determined_mod * seconds_per_tick
				else if(getStaminaLoss() < 25 * determined_mod)
					to_chat(src, span_danger("You feel [word]. It's getting a bit hard to focus."))
					adjustStaminaLoss(10 * determined_mod * REM * seconds_per_tick)
		// Pretty low blood, getting dangerous!
		if(BLOOD_VOLUME_RISKY to BLOOD_VOLUME_OKAY)
			if(SPT_PROB(5, seconds_per_tick))
				set_eye_blur_if_lower(2 SECONDS * determined_mod)
				set_dizzy_if_lower(2 SECONDS * determined_mod)
				if(prob(50))
					to_chat(src, span_bolddanger("You feel very [word]. It's getting hard to breathe!"))
					losebreath += 1 * determined_mod * seconds_per_tick
				else if(getStaminaLoss() < 40 * determined_mod)
					to_chat(src, span_bolddanger("You feel very [word]. It's getting hard to stay awake!"))
					adjustStaminaLoss(15 * determined_mod * REM * seconds_per_tick)
		// Very low blood, danger!!
		if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_RISKY)
			if(SPT_PROB(5, seconds_per_tick))
				set_eye_blur_if_lower(4 SECONDS * determined_mod)
				set_dizzy_if_lower(4 SECONDS * determined_mod)
				if(prob(50))
					to_chat(src, span_userdanger("You feel extremely [word]! It's getting very hard to breathe!"))
					losebreath += 1.5 * determined_mod * seconds_per_tick
				else if(getStaminaLoss() < 80 * determined_mod)
					to_chat(src, span_userdanger("You feel extremely [word]! It's getting very hard to stay awake!"))
					adjustStaminaLoss(20 * determined_mod * REM * seconds_per_tick)
		// Critically low blood, death is near! Adrenaline won't help you here.
		if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
			if(SPT_PROB(7.5, seconds_per_tick))
				Unconscious(rand(1 SECONDS, 2 SECONDS))
				to_chat(src, span_userdanger("You black out for a moment!"))
		// Instantly die upon this threshold
		if(-INFINITY to BLOOD_VOLUME_SURVIVE)
			if(!HAS_TRAIT(src, TRAIT_NODEATH))
				investigate_log("has died of bloodloss.", INVESTIGATE_DEATHS)
				death()

	// Blood ratio! if you have 280 blood, this equals 0.5 as that's half of the current value, 560.
	var/effective_blood_ratio = blood_volume / BLOOD_VOLUME_NORMAL
	var/target_oxyloss = max((1 - effective_blood_ratio) * 100, 0)

	// If your ratio is less than one (you're missing any blood) and your oxyloss is under missing blood %, start getting oxy damage.
	// This damage accrues faster the less blood you have.
	// If the damage surpasses the KO threshold for oxyloss, then we'll always tick up so you die eventually
	if(target_oxyloss > 0 && (getOxyLoss() < target_oxyloss || (target_oxyloss >= OXYLOSS_PASSOUT_THRESHOLD && stat >= UNCONSCIOUS)))
		// At roughly half blood this equals to 3 oxyloss per tick. At 90% blood it's close to 0.5
		var/rounded_oxyloss = round(0.01 * (BLOOD_VOLUME_NORMAL - blood_volume), 0.25) * seconds_per_tick
		adjustOxyLoss(rounded_oxyloss, updating_health = TRUE)

/// Has each bodypart update its bleed/wound overlay icon states
/mob/living/carbon/proc/update_bodypart_bleed_overlays()
	for(var/obj/item/bodypart/iter_part as anything in bodyparts)
		iter_part.update_part_wound_overlay()

/// Makes a blood drop, leaking amt units of blood from the mob
/mob/living/proc/bleed(amt)
	if(HAS_TRAIT(src, TRAIT_GODMODE) || !can_bleed())
		return

	blood_volume = max(blood_volume - amt, 0)

	// Blood loss still happens in locker, floor stays clean
	if(isturf(loc) && prob(sqrt(amt) * BLOOD_DRIP_RATE_MOD))
		add_splatter_floor(loc, (amt <= 10))

/mob/living/carbon/human/bleed(amt)
	amt *= physiology.bleed_mod
	return ..()

/// A helper to see how much blood we're losing per tick
/mob/living/proc/get_bleed_rate()
	return 0

/mob/living/carbon/get_bleed_rate()
	if(HAS_TRAIT(src, TRAIT_GODMODE) || !can_bleed())
		return
	var/bleed_amt = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/iter_bodypart = X
		bleed_amt += iter_bodypart.cached_bleed_rate
	return bleed_amt

/mob/living/carbon/human/get_bleed_rate()
	return ..() * physiology.bleed_mod

/**
 * bleed_warn() is used to for carbons with an active client to occasionally receive messages warning them about their bleeding status (if applicable)
 *
 * Arguments:
 * * bleed_amt- When we run this from [/mob/living/carbon/human/proc/handle_blood] we already know how much blood we're losing this tick, so we can skip tallying it again with this
 * * forced-
 */
/mob/living/carbon/proc/bleed_warn(bleed_amt = 0, forced = FALSE)
	if(!blood_volume || !client)
		return
	if(!COOLDOWN_FINISHED(src, bleeding_message_cd) && !forced)
		return

	if(!bleed_amt) // if we weren't provided the amount of blood we lost this tick in the args
		bleed_amt = get_bleed_rate()

	var/bleeding_severity = ""
	var/next_cooldown = BLEEDING_MESSAGE_BASE_CD

	switch(bleed_amt)
		if(-INFINITY to 0)
			return
		if(0 to 1)
			bleeding_severity = "You feel light trickles of blood across your skin"
			next_cooldown *= 2.5
		if(1 to 3)
			bleeding_severity = "You feel a small stream of blood running across your body"
			next_cooldown *= 2
		if(3 to 5)
			bleeding_severity = "You skin feels clammy from the flow of blood leaving your body"
			next_cooldown *= 1.7
		if(5 to 7)
			bleeding_severity = "Your body grows more and more numb as blood streams out"
			next_cooldown *= 1.5
		if(7 to INFINITY)
			bleeding_severity = "Your heartbeat thrashes wildly trying to keep up with your bloodloss"

	var/rate_of_change = ", but it's getting better." // if there's no wounds actively getting bloodier or maintaining the same flow, we must be getting better!
	if(HAS_TRAIT(src, TRAIT_COAGULATING)) // if we have coagulant, we're getting better quick
		rate_of_change = ", but it's clotting up quickly!"
	else
		// flick through our wounds to see if there are any bleeding ones getting worse or holding flow (maybe move this to handle_blood and cache it so we don't need to cycle through the wounds so much)
		for(var/datum/wound/iter_wound as anything in all_wounds)
			if(!iter_wound.blood_flow)
				continue
			var/iter_wound_roc = iter_wound.get_bleed_rate_of_change()
			switch(iter_wound_roc)
				if(BLOOD_FLOW_INCREASING) // assume the worst, if one wound is getting bloodier, we focus on that
					rate_of_change = ", <b>and it's getting worse!</b>"
					break
				if(BLOOD_FLOW_STEADY) // our best case now is that our bleeding isn't getting worse
					rate_of_change = ", and it's holding steady."
				if(BLOOD_FLOW_DECREASING) // this only matters if none of the wounds fit the above two cases, included here for completeness
					continue

	to_chat(src, span_warning("[bleeding_severity][rate_of_change]"))
	COOLDOWN_START(src, bleeding_message_cd, next_cooldown)

/mob/living/carbon/human/bleed_warn(bleed_amt = 0, forced = FALSE)
	if(!HAS_TRAIT(src, TRAIT_NOBLOOD))
		return ..()

/mob/living/proc/restore_blood()
	blood_volume = initial(blood_volume)

/mob/living/carbon/restore_blood()
	blood_volume = BLOOD_VOLUME_NORMAL
	for(var/obj/item/bodypart/bodypart_to_restore as anything in bodyparts)
		bodypart_to_restore.setBleedStacks(0)

/****************************************************
				BLOOD TRANSFERS
****************************************************/

//Gets blood from mob to a container or other mob, preserving all data in it.
/mob/living/proc/transfer_blood_to(atom/movable/receiver, amount, forced, ignore_incompatibility)
	if(!blood_volume || !receiver.reagents)
		return FALSE

	if(blood_volume < BLOOD_VOLUME_BAD && !forced)
		return FALSE

	if(blood_volume < amount)
		amount = blood_volume

	var/datum/blood_type/blood_type = get_bloodtype()
	if (!blood_type)
		return FALSE

	var/blood_reagent = get_blood_reagent()

	blood_volume -= amount
	var/list/blood_data = get_blood_data()

	if (!isliving(receiver))
		receiver.reagents.add_reagent(blood_reagent, amount, blood_data, bodytemperature, creation_callback = CALLBACK(src, PROC_REF(on_blood_created), blood_type))
		return TRUE

	var/mob/living/target = receiver
	if (target.get_blood_reagent() != blood_reagent)
		target.reagents.add_reagent(blood_reagent, amount, blood_data, bodytemperature, creation_callback = CALLBACK(src, PROC_REF(on_blood_created), blood_type))
		return TRUE

	if(blood_data["viruses"])
		for(var/datum/disease/blood_disease as anything in blood_data["viruses"])
			if((blood_disease.spread_flags & DISEASE_SPREAD_SPECIAL) || (blood_disease.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS))
				continue
			target.ForceContractDisease(blood_disease)

	if(!ignore_incompatibility && !(blood_type.type_key() in target.get_bloodtype().compatible_types))
		target.reagents.add_reagent(/datum/reagent/toxin, amount * 0.5)
		return TRUE

	target.blood_volume = min(target.blood_volume + round(amount, 0.1), BLOOD_VOLUME_MAX_LETHAL)
	return TRUE

/// Callback that adds blood_reagent to any blood extracted from ourselves
/mob/living/proc/on_blood_created(datum/blood_type/blood_type, datum/reagent/new_blood)
	new_blood.AddElement(/datum/element/blood_reagent, src, blood_type)

/mob/living/proc/get_blood_data()
	SHOULD_CALL_PARENT(TRUE)
	RETURN_TYPE(/list)

	var/datum/blood_type/blood_type = get_bloodtype()
	if (!blood_type || !can_bleed())
		return

	var/blood_data = list()
	blood_data["blood_type"] = blood_type
	blood_data["blood_DNA"] = blood_type.dna_string

	if (reagents)
		var/list/temp_chem = list()
		for(var/datum/reagent/blood_reagent in reagents.reagent_list)
			temp_chem[blood_reagent.type] = blood_reagent.volume
		blood_data["trace_chem"] = list2params(temp_chem)

	if (blood_type.blood_flags & BLOOD_TRANSFER_VIRAL_DATA)
		// Viruses we possess
		blood_data["viruses"] = list()
		for(var/datum/disease/disease as anything in diseases)
			blood_data["viruses"] += disease.Copy()

		if(LAZYLEN(disease_resistances))
			blood_data["resistances"] = disease_resistances.Copy()

	// DNA, mind, facitons, etc don't get stored in stuff like oil
	if (!(blood_type.blood_flags & BLOOD_ADD_DNA))
		return blood_data

	if(mind)
		blood_data["mind"] = mind

	if(ckey)
		blood_data["ckey"] = ckey
	else if (persistent_client?.mob?.ckey)
		blood_data["ckey"] = persistent_client.mob.ckey

	blood_data["factions"] = faction
	return blood_data

/mob/living/carbon/get_blood_data()
	var/list/blood_data = ..()
	if (!blood_data)
		return

	var/datum/blood_type/blood_type = get_bloodtype()
	if (!(blood_type.blood_flags & BLOOD_ADD_DNA))
		return blood_data

	// If we haven't suicided but the ghost cannot reenter, i.e. we ghosted, don't set ourselves as cloneable
	var/mob/dead/observer/ghost = get_ghost(TRUE, TRUE)
	if(!HAS_TRAIT(src, TRAIT_SUICIDED) && (!ghost || ghost.can_reenter_corpse))
		blood_data["cloneable"] = TRUE

	if (!blood_data["mind"] && last_mind)
		blood_data["mind"] = last_mind

	if (!blood_data["ckey"] && last_mind)
		blood_data["ckey"] = ckey(last_mind.key)

	blood_data["gender"] = gender
	blood_data["real_name"] = real_name
	if (dna)
		blood_data["blood_DNA"] = dna.unique_enzymes
		blood_data["features"] = dna.features

	blood_data["quirks"] = list()
	for(var/datum/quirk/quirk as anything in quirks)
		blood_data["quirks"] += quirk.type

	return blood_data

/mob/living/proc/get_bloodtype()
	RETURN_TYPE(/datum/blood_type)
	if (!blood_volume)
		return

	if (!(mob_biotypes & MOB_ORGANIC))
		if (mob_biotypes & MOB_ROBOTIC)
			return get_blood_type(BLOOD_TYPE_OIL)
		return

	if (mob_biotypes & MOB_SLIME)
		return get_blood_type(BLOOD_TYPE_TOX)
	else if (mob_biotypes & MOB_PLANT)
		return get_blood_type(BLOOD_TYPE_H2O)
	else if (mob_biotypes & MOB_REPTILE)
		return get_blood_type(BLOOD_TYPE_LIZARD)
	else if (mob_biotypes & MOB_HUMANOID)
		// O+ as to avoid mobs bleeding all human bloodtypes under the sun, and its statistically the most common one
		return get_blood_type(BLOOD_TYPE_O_PLUS)

	return get_blood_type(BLOOD_TYPE_ANIMAL)

/// Returns the reagent type this mob has for blood
/mob/living/proc/get_blood_reagent()
	if (!can_bleed())
		return

	var/datum/blood_type/blood_type = get_bloodtype()
	return blood_type?.reagent_type

/// Check if a mob can bleed, and possibly if they're capable of leaving decals on turfs/mobs/items
/mob/living/proc/can_bleed(bleed_flag = NONE)
	if (HAS_TRAIT(src, TRAIT_HUSK) || HAS_TRAIT(src, TRAIT_NOBLOOD))
		return BLEED_NONE

	if (!bleed_flag)
		return BLEED_SPLATTER

	var/datum/blood_type/blood_type = get_bloodtype()
	if (!blood_type)
		return BLEED_NONE

	if (blood_type.blood_flags & bleed_flag)
		return BLEED_SPLATTER

	if (blood_type.blood_flags & BLOOD_ADD_DNA)
		return BLEED_ADD_DNA

	return BLEED_NONE

/// Returns the blood_type datum that corresponds to the string id key in GLOB.blood_types
/proc/get_blood_type(id)
	RETURN_TYPE(/datum/blood_type)
	return GLOB.blood_types[id]

/// Returns the hex color string, or a color matrix, of a given blood_type datum given an assoc list of blood_DNA e.g. ("Unknown Blood Type", "*X")
/proc/get_color_from_blood_list(list/blood_DNA)
	var/datum/blood_type/blood_type
	if(!length(blood_DNA))
		return get_blood_type(BLOOD_TYPE_O_PLUS).get_color()
	else if (length(blood_DNA) == 1) // Microop for when we don't need to do color mixing
		blood_type = blood_DNA[blood_DNA[length(blood_DNA)]]
		return blood_type.get_color()

	var/r_color = 0
	var/g_color = 0
	var/b_color = 0
	var/valid_colors = 0
	for (var/blood_key in blood_DNA)
		blood_type = blood_DNA[blood_key]
		if(!istype(blood_type))
			continue

		var/list/rgb_blood = rgb2num(blood_type.get_color())
		r_color += rgb_blood[1]
		g_color += rgb_blood[2]
		b_color += rgb_blood[3]
		valid_colors += 1

	if (valid_colors == 0)
		return get_blood_type(BLOOD_TYPE_O_PLUS).get_color()

	r_color /= valid_colors
	g_color /= valid_colors
	b_color /= valid_colors
	return rgb(r_color, g_color, b_color)

/// Checks if any of the passed blood types have certain blood flags
/proc/has_blood_flag(list/blood_DNA, blood_flags)
	if (isnull(blood_DNA))
		return FALSE

	if (!islist(blood_DNA))
		var/datum/blood_type/blood_type = blood_DNA
		blood_DNA = list(blood_type.dna_string = blood_type)

	var/matches = NONE
	for (var/blood_key in blood_DNA)
		var/datum/blood_type/blood_type = blood_DNA[blood_key]
		matches |= (blood_type.blood_flags & blood_flags)
	return matches

/**
 * Returns TRUE if src is compatible with donor's blood, otherwise FALSE.
 * * donor: Mob that is donating blood.
 */
/mob/living/proc/get_blood_compatibility(mob/living/donor)
	if (get_blood_reagent() != donor.get_blood_reagent())
		return FALSE

	var/datum/blood_type/patient_blood_data = get_bloodtype()
	var/datum/blood_type/donor_blood_data = donor.get_bloodtype()
	return (donor_blood_data?.type_key() in patient_blood_data?.compatible_types)

/// Create a small visual-only blood splatter
/mob/living/proc/create_splatter(splatter_dir = pick(GLOB.cardinals))
	// Check for husking and TRAIT_NOBLOOD
	if (!can_bleed()) // Even if we can't cover turfs, we still can add DNA to everything our blood hits
		return
	var/obj/effect/temp_visual/dir_setting/bloodsplatter/splatter = new(get_turf(src), splatter_dir, get_bloodtype()?.get_color())
	splatter.color = get_bloodtype()?.color

/*
 * Create a splatter or drip of this mob's blood type
 * Arguments:
 * * splatter_turf - If the splatter should be made on a different turf than the mob
 * * small_drip
 */
/mob/living/proc/add_splatter_floor(turf/splatter_turf, small_drip = FALSE)
	if (!splatter_turf)
		splatter_turf = get_turf(src)

	if (!splatter_turf)
		return

	// Check for husking and TRAIT_NOBLOOD
	switch (can_bleed(BLOOD_COVER_TURFS))
		if (BLEED_NONE)
			return
		if (BLEED_ADD_DNA)
			return splatter_turf.add_mob_blood(src)

	return get_bloodtype()?.make_blood_splatter(src, splatter_turf, small_drip)

/**
 * This proc is a helper for spraying blood for things like slashing/piercing wounds and dismemberment.
 *
 * The strength of the splatter in the second argument determines how much it can dirty and how far it can go
 *
 * Arguments:
 * * splatter_direction: Which direction the blood is flying
 * * splatter_strength: How many tiles it can go, and how many items it can pass over and dirty
 */
/mob/living/carbon/proc/spray_blood(splatter_direction, splatter_strength = 3)
	// Check if we can bleed and if our splatter can even go anywhere
	if(!isturf(loc) || can_bleed(BLOOD_COVER_TURFS) != BLEED_SPLATTER)
		return
	var/obj/effect/decal/cleanable/blood/hitsplatter/our_splatter = new(loc, get_static_viruses(), get_blood_dna_list(), splatter_strength)
	var/turf/targ = get_ranged_target_turf(src, splatter_direction, splatter_strength)
	our_splatter.fly_towards(targ, splatter_strength)

/mob/living/proc/make_blood_trail(turf/target_turf, turf/start, was_facing, movement_direction)
	if(!has_gravity() || !isturf(start))
		return

	var/base_bleed_rate = get_bleed_rate()
	var/base_brute = getBruteLoss()

	var/brute_ratio = round(base_brute / (maxHealth * 4), 0.1)
	var/bleeding_rate =  round(base_bleed_rate / 4, 0.1)
	// We only leave a trail if we're below a certain blood threshold
	// The more brute damage we have, or the more we're bleeding, the less blood we need to leave a trail
	if(blood_volume < max(BLOOD_VOLUME_NORMAL * (1 - max(bleeding_rate, brute_ratio)), 0))
		return

	var/blood_to_add = BLOOD_AMOUNT_PER_DECAL * 0.1
	if(body_position == LYING_DOWN)
		blood_to_add += bleed_drag_amount()
		blood_volume = max(blood_volume - blood_to_add, 0)
	else
		blood_to_add += base_bleed_rate

	// If we're very damaged or bleeding a lot, add even more blood to the trail
	if(base_brute >= 300 || base_bleed_rate >= 7)
		blood_to_add *= 2

	switch (can_bleed(BLOOD_COVER_TURFS))
		if (BLEED_NONE)
			return
		if (BLEED_ADD_DNA)
			return start.add_mob_blood(src)

	var/trail_dir = REVERSE_DIR(movement_direction)
	// The mob is performing a diagonal movement so we need to make a diagonal trail
	// This is not the same as a diagonal dir. Sorry.
	// This is insteas denoted by a negative direction (so we don't conflict with real dirs)
	if(movement_direction in GLOB.diagonals)
		trail_dir = -1 * movement_direction
		// Create a full trail on the tile we came from, and a start of a trail at the one we arrived to
		create_blood_trail_component(start, trail_dir, blood_to_add * 0.67, FALSE)
		create_blood_trail_component(target_turf, get_dir(start, target_turf), blood_to_add * 0.33, TRUE)
		return

	var/continuing_trail = FALSE
	// The mob is going a direction they were not previously facing
	// We now factor in their facing direction to make a trail that looks like they're turning
	// This is done by creating a diagonal dir
	if(trail_dir != was_facing && trail_dir != REVERSE_DIR(was_facing))
		// Look a step back to see if we should be constructing a diagonal dir
		// If there's no existing trail making a curve would look weird
		for(var/obj/effect/decal/cleanable/blood/trail_holder/past_trail in get_step(start, REVERSE_DIR(was_facing)))
			if(past_trail.get_trail_component(was_facing, check_reverse = TRUE, check_diagonals = TRUE, check_reverse_diagonals = TRUE))
				trail_dir |= was_facing
				continuing_trail = TRUE
				// In case we produced an invalid dir: go back on relevant axis
				if((trail_dir & (NORTH|SOUTH)) == (NORTH|SOUTH))
					trail_dir &= ~(was_facing & (NORTH|SOUTH))
				if((trail_dir & (EAST|WEST)) == (EAST|WEST))
					trail_dir &= ~(was_facing & (EAST|WEST))
				break

	if (continuing_trail || (trail_dir in GLOB.diagonals))
		create_blood_trail_component(start, trail_dir, blood_to_add * 0.67, FALSE)
		create_blood_trail_component(target_turf, get_dir(start, target_turf), blood_to_add * 0.33, TRUE)
		return

	// If we're still moving cardinally and didn't change our dir, there's a chance that there's a half-trail on our turf
	// in which case we want to continue it instead of doing a full trail
	// Only scenario in which we don't have one is if we just started the trail from our tile
	for(var/obj/effect/decal/cleanable/blood/trail_holder/trail_holder in start)
		var/obj/effect/decal/cleanable/blood/trail/trail = trail_holder.get_trail_component(trail_dir)
		if (trail?.half_piece) // We're moving straight, so just continue the path
			continuing_trail = TRUE
			break

	// If we've just started moving, put a half-trail on our previous turf instead of a full one
	create_blood_trail_component(start, trail_dir, blood_to_add * 0.67, !continuing_trail)
	create_blood_trail_component(target_turf, get_dir(start, target_turf), blood_to_add * 0.33, TRUE)
/*
 * Locate or create a trail holder, and add a dir to it
 * Arguments:
 * * trail_turf - Turf on which to look for/spawn a trail
 * * trail_dir - Direction in which the trail will be facing. Could be diagonal for a corner, or negative for a true diagonal trail
 * * blood_to_add - How much bloodiness we should add to the trail
 * * half_piece - Should we only create a beginning of a trail, and not a full tile trail? Does not support corners
 */
/mob/living/proc/create_blood_trail_component(turf/trail_turf, trail_dir, blood_to_add, half_piece)
	var/obj/effect/decal/cleanable/blood/trail_holder/trail
	var/check_reverse = TRUE
	// Do not check the reverse dir if we're a diagonal corner or a half piece
	if (trail_dir > 0 && !(trail_dir in GLOB.cardinals) || half_piece)
		check_reverse = FALSE
	// Pick any trail in the turf to add onto
	for(var/obj/effect/decal/cleanable/blood/trail_holder/any_trail in trail_turf)
		// If there exists a trail already, we will add onto the trial
		// UNLESS that trail has the same direction component and it is already dried
		//
		// If that is the case we will look for another trail (or create a new one)
		// (this will let fresh blood be laid over very dried blood)
		var/obj/effect/decal/cleanable/blood/trail/any_trail_component = any_trail.get_trail_component(trail_dir, check_reverse = check_reverse)
		if(isnull(any_trail_component) || !any_trail_component.dried)
			trail = any_trail
			break

	if(!isnull(trail))
		trail.adjust_bloodiness(blood_to_add)
		return trail.add_dir_to_trail(trail_dir, src, blood_to_add, half_piece)

	trail = new(trail_turf, get_static_viruses(), get_blood_dna_list())
	if(QDELETED(trail))
		return
	trail.bloodiness = blood_to_add
	return trail.add_dir_to_trail(trail_dir, src, blood_to_add, half_piece)

/mob/living/carbon/human/make_blood_trail(turf/target_turf, turf/start, direction)
	if(!is_bleeding())
		return
	return ..()

/// Returns how much blood we're losing from being dragged a tile, from [/mob/living/proc/make_blood_trail]
/mob/living/proc/bleed_drag_amount()
	var/brute_ratio = round(getBruteLoss() / maxHealth, 0.1)
	return max(1, brute_ratio * 2)

/mob/living/carbon/bleed_drag_amount()
	var/bleed_amount = 0
	for(var/i in all_wounds)
		var/datum/wound/iter_wound = i
		bleed_amount += iter_wound.drag_bleed_amount()
	return bleed_amount

/mob/living/proc/get_blood_alcohol_content()
	var/blood_alcohol_content = 0
	var/datum/status_effect/inebriated/inebriation = has_status_effect(/datum/status_effect/inebriated)
	if(!isnull(inebriation))
		blood_alcohol_content = round(inebriation.drunk_value * DRUNK_POWER_TO_BLOOD_ALCOHOL, 0.01)

	return blood_alcohol_content

#undef BLOOD_DRIP_RATE_MOD
#undef DRUNK_POWER_TO_BLOOD_ALCOHOL
