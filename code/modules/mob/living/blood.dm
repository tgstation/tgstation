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
		var/iter_bleed_rate = iter_part.get_modified_bleed_rate()
		temp_bleed += iter_bleed_rate * seconds_per_tick

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

//Makes a blood drop, leaking amt units of blood from the mob
/mob/living/carbon/proc/bleed(amt)
	if(!blood_volume || HAS_TRAIT(src, TRAIT_GODMODE))
		return
	blood_volume = max(blood_volume - amt, 0)

	//Blood loss still happens in locker, floor stays clean
	if(isturf(loc) && prob(sqrt(amt)*BLOOD_DRIP_RATE_MOD))
		add_splatter_floor(loc, (amt <= 10))

/mob/living/carbon/human/bleed(amt)
	amt *= physiology.bleed_mod
	if(!HAS_TRAIT(src, TRAIT_NOBLOOD))
		..()

/// A helper to see how much blood we're losing per tick
/mob/living/carbon/proc/get_bleed_rate()
	if(!blood_volume)
		return
	var/bleed_amt = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/iter_bodypart = X
		bleed_amt += iter_bodypart.get_modified_bleed_rate()
	return bleed_amt

/mob/living/carbon/human/get_bleed_rate()
	if(HAS_TRAIT(src, TRAIT_NOBLOOD))
		return
	. = ..()
	. *= physiology.bleed_mod

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

	blood_volume -= amount
	var/list/blood_data = get_blood_data()

	if (!isliving(receiver))
		receiver.reagents.add_reagent(blood_type.reagent_type, amount, blood_data, bodytemperature, creation_callback = CALLBACK(src, PROC_REF(on_blood_created), blood_type))
		return TRUE

	var/mob/living/target = receiver
	var/datum/blood_type/receiver_blood_type = target.get_bloodtype()
	if (!receiver_blood_type?.reagent_type == blood_type.reagent_type)
		target.reagents.add_reagent(blood_type.reagent_type, amount, blood_data, bodytemperature, creation_callback = CALLBACK(src, PROC_REF(on_blood_created), blood_type))
		return TRUE

	if(blood_data["viruses"])
		for(var/datum/disease/blood_disease as anything in blood_data["viruses"])
			if((blood_disease.spread_flags & DISEASE_SPREAD_SPECIAL) || (blood_disease.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS))
				continue
			target.ForceContractDisease(blood_disease)

	if(!ignore_incompatibility && !(blood_type.type_key() in receiver_blood_type.compatible_types))
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
	if (!blood_type)
		return

	var/blood_data = list()
	blood_data["blood_type"] = blood_type
	blood_data["blood_DNA"] = blood_type.dna_string

	if (reagents)
		var/list/temp_chem = list()
		for(var/datum/reagent/blood_reagent in reagents.reagent_list)
			temp_chem[blood_reagent.type] = blood_reagent.volume
		blood_data["trace_chem"] = list2params(temp_chem)

	if (blood_type.expose_flags & BLOOD_TRANSFER_VIRAL_DATA)
		// Viruses we possess
		blood_data["viruses"] = list()
		for(var/datum/disease/disease as anything in diseases)
			blood_data["viruses"] += disease.Copy()

		if(LAZYLEN(disease_resistances))
			blood_data["resistances"] = disease_resistances.Copy()

	// DNA, mind, facitons, etc don't get stored in stuff like oil
	if (!(blood_type.expose_flags & BLOOD_ADD_DNA))
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
	if (!(blood_type.expose_flags & BLOOD_ADD_DNA))
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

/mob/living/proc/get_blood_reagent()
	var/datum/blood_type/blood_type = get_bloodtype()
	return blood_type?.reagent_type

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
/mob/living/carbon/get_blood_reagent()
	if (HAS_TRAIT(src, TRAIT_HUSK) || HAS_TRAIT(src, TRAIT_NOBLOOD))
		return

	var/datum/blood_type/blood_type = get_bloodtype()
	return blood_type?.reagent_type

/// Returns the blood_type datum that corresponds to the string id key in GLOB.blood_types
/proc/get_blood_type(id)
	RETURN_TYPE(/datum/blood_type)
	return GLOB.blood_types[id]

/// Returns the hex color string of a given blood_type datum given an assoc list of blood_DNA e.g. ("Unknown Blood Type", "*X")
/proc/get_blood_dna_color(list/blood_DNA)
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

		var/list/hopefully_not_a_list = blood_type.get_color()
		var/list/rgb_blood = null
		if (islist(hopefully_not_a_list))
			var/per_row = 3
			if (length(hopefully_not_a_list) >= 16)
				per_row = 4
			rgb_blood = list(hopefully_not_a_list[1], hopefully_not_a_list[per_row + 2], hopefully_not_a_list[per_row * 2 + 3])
		else
			rgb_blood = rgb2num(blood_type.get_color())

		r_color += rgb_blood[1]
		g_color += rgb_blood[2]
		b_color += rgb_blood[3]
		valid_colors += 1

	if (valid_colors == 0)
		return get_blood_type(BLOOD_TYPE_O_PLUS).get_color()

	r_color /= valid_colors
	g_color /= valid_colors
	b_color /= valid_colors

	// Our colors are too vibrant, so we're forced to use matrixes
	if (r_color > 255 || g_color > 255 || b_color > 255)
		return list(
			r_color, 0, 0,
			0, g_color, 0,
			0, 0, b_color,
		)

	return rgb(r_color, g_color, b_color)

/**
 * Returns TRUE if src is compatible with donor's blood, otherwise FALSE.
 * * donor: Mob that is donating blood.
 */
/mob/living/proc/get_blood_compatibility(mob/living/donor)
	var/datum/blood_type/patient_blood_data = get_bloodtype()
	var/datum/blood_type/donor_blood_data = donor.get_bloodtype()
	return (donor_blood_data?.type_key() in patient_blood_data?.compatible_types)

//to add a splatter of blood or other mob liquid.
/mob/living/proc/add_splatter_floor(turf/splatter_turf, small_drip, skip_reagents_check = FALSE)
	if(!skip_reagents_check && !(get_blood_reagent() in list(/datum/reagent/blood, /datum/reagent/toxin/acid)))
		return

	if(!splatter_turf)
		splatter_turf = get_turf(src)

	if(isclosedturf(splatter_turf) || (isgroundlessturf(splatter_turf) && !GET_TURF_BELOW(splatter_turf)))
		return

	var/list/temp_blood_DNA
	if(small_drip)
		// Only a certain number of drips (or one large splatter) can be on a given turf.
		var/obj/effect/decal/cleanable/blood/drip/drop = locate() in splatter_turf
		if(drop)
			if(drop.drips < 5)
				drop.drips++
				drop.add_overlay(pick(drop.random_icon_states))
				drop.add_mob_blood(src)
				return
			else
				temp_blood_DNA = GET_ATOM_BLOOD_DNA(drop) //we transfer the dna from the drip to the splatter
				qdel(drop)//the drip is replaced by a bigger splatter
		else
			drop = new(splatter_turf, get_static_viruses())
			drop.add_mob_blood(src)
			return

	// Find a blood decal or create a new one.
	var/obj/effect/decal/cleanable/blood/blood_spew = locate() in splatter_turf
	if(!blood_spew)
		blood_spew = new /obj/effect/decal/cleanable/blood/splatter(splatter_turf, get_static_viruses()) // TODO SMARTKAR
	if(QDELETED(blood_spew)) //Give it up
		return
	blood_spew.bloodiness = min((blood_spew.bloodiness + BLOOD_AMOUNT_PER_DECAL), BLOOD_POOL_MAX)
	blood_spew.add_mob_blood(src) //give blood info to the blood decal.
	if(temp_blood_DNA)
		blood_spew.add_blood_DNA(temp_blood_DNA, no_visuals = small_drip)

/mob/living/carbon/human/add_splatter_floor(turf/splatter_turf, small_drip, skip_reagents_check = TRUE)
	if(!HAS_TRAIT(src, TRAIT_NOBLOOD) && !get_bloodtype()?.no_bleed_overlays)
		. = ..()

/mob/living/carbon/alien/add_splatter_floor(turf/splatter_turf, small_drip, skip_reagents_check)
	if(!splatter_turf)
		splatter_turf = get_turf(src)
	var/obj/effect/decal/cleanable/blood/xeno/xeno_blood_splatter = locate() in splatter_turf.contents
	if(!xeno_blood_splatter)
		xeno_blood_splatter = new(splatter_turf)
	xeno_blood_splatter.add_blood_DNA(list("Alien DNA" = get_blood_type(BLOOD_TYPE_XENO)))

/mob/living/silicon/robot/add_splatter_floor(turf/splatter_turf, small_drip, skip_reagents_check)
	if(!splatter_turf)
		splatter_turf = get_turf(src)
	var/obj/effect/decal/cleanable/blood/oil/oil_splatter = locate() in splatter_turf.contents
	if(!oil_splatter)
		oil_splatter = new(splatter_turf)

/mob/living/proc/get_blood_alcohol_content()
	var/blood_alcohol_content = 0
	var/datum/status_effect/inebriated/inebriation = has_status_effect(/datum/status_effect/inebriated)
	if(!isnull(inebriation))
		blood_alcohol_content = round(inebriation.drunk_value * DRUNK_POWER_TO_BLOOD_ALCOHOL, 0.01)

	return blood_alcohol_content


/mob/living/proc/makeTrail(turf/target_turf, turf/start, direction)
	if(!has_gravity() || !isturf(start) || !blood_volume)
		return

	var/trail_type // = getTrail()
	/*

/mob/living/proc/getTrail()
	if(getBruteLoss() < 300)
		return pick("ltrails_1", "ltrails_2")
	else
		return pick("trails_1", "trails_2")
		*/
	var/trail_blood_type // = get_trail_blood()
	if(!trail_type || !trail_blood_type)
		return

	var/brute_ratio = round(getBruteLoss() / maxHealth, 0.1)
	if(blood_volume < max(BLOOD_VOLUME_NORMAL * (1 - brute_ratio * 0.25), 0))//don't leave trail if blood volume below a threshold
		return

	var/bleed_amount = bleedDragAmount()
	blood_volume = max(blood_volume - bleed_amount, 0) //that depends on our brute damage.
	var/newdir = get_dir(target_turf, start)
	if(newdir != direction)
		newdir = newdir | direction
		if(newdir == (NORTH|SOUTH))
			newdir = NORTH
		else if(newdir == (EAST|WEST))
			newdir = EAST

	if((newdir in GLOB.cardinals) && (prob(50)))
		newdir = REVERSE_DIR(get_dir(target_turf, start))

	var/found_trail = FALSE
	for(var/obj/effect/decal/cleanable/blood/trail_holder/trail in start)
		if (BLOOD_STATE_HUMAN != trail_blood_type)
			continue

		// Don't make double trails, even if they're of a different type
		if(newdir in trail.existing_dirs)
			found_trail = TRUE
			break

		trail.existing_dirs += newdir
		trail.add_overlay(image('icons/effects/blood.dmi', trail_type, dir = newdir))
		trail.add_mob_blood(src)
		trail.bloodiness = min(trail.bloodiness + bleed_amount, BLOOD_POOL_MAX)
		found_trail = TRUE
		break

	if (found_trail)
		return

	var/obj/effect/decal/cleanable/blood/trail_holder/trail = new(start, get_static_viruses())
	trail.existing_dirs += newdir
	trail.add_overlay(image('icons/effects/blood.dmi', trail_type, dir = newdir))
	trail.add_mob_blood(src)
	trail.bloodiness = min(bleed_amount, BLOOD_POOL_MAX)

/mob/living/carbon/human/makeTrail(turf/T)
	if(HAS_TRAIT(src, TRAIT_NOBLOOD) || !is_bleeding() || dna.blood_type.no_bleed_overlays)
		return
	..()

///Returns how much blood we're losing from being dragged a tile, from [/mob/living/proc/makeTrail]
/mob/living/proc/bleedDragAmount()
	var/brute_ratio = round(getBruteLoss() / maxHealth, 0.1)
	return max(1, brute_ratio * 2)

/mob/living/carbon/bleedDragAmount()
	var/bleed_amount = 0
	for(var/i in all_wounds)
		var/datum/wound/iter_wound = i
		bleed_amount += iter_wound.drag_bleed_amount()
	return bleed_amount

#undef BLOOD_DRIP_RATE_MOD
#undef DRUNK_POWER_TO_BLOOD_ALCOHOL
