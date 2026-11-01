/// Ratwood's field medicine on medieval maps: a needle sews wounds stitch by stitch (rogueitems/needle.dm sew(), with the
/// Medicine skill), cloth and bandages bind a limb (natural/clothfibersthorn.dm bandage(), bodypart_wounds.dm
/// get_bleed_rate(), process_bandage()), and the bandage shows on the body (human/update_icons.dm). The stitches and the
/// bandage act on the bleeding as Ratwood counts it (combat/blood.dm rogue_bleed_rate()). A sewn cut or stab of TG stays as
/// its sewn tail (Ratwood sew_wound()), a dynamic wound sewn shut is gone (combat/wounds.dm).

/// The sheets of Ratwood's body damage, with the bandage of each limb ("<zone>_b", Ratwood icons/roguetown/mob/bodies/dam/).
#define ROGUE_BANDAGE_SHEET_MALE 'modular_redtard/icons/mob/dam_male.dmi'
#define ROGUE_BANDAGE_SHEET_FEMALE 'modular_redtard/icons/mob/dam_female.dmi'
/// The series of the sewn tails: a limb may carry any number of them.
#define ROGUE_WOUND_SERIES_SEWN "rogue_wound_series_sewn"
/// Ratwood's aqua vitae, which comes with its drinks (block 1, alcohol): the cloth soaks it once the reagent exists.
#define ROGUE_AQUA_VITAE_PATH "/datum/reagent/consumable/ethanol/aqua_vitae"

/datum/wound
	/// Ratwood sew_progress: how far the stitches have got.
	var/rogue_sew_progress = 0
	/// Blood per second the stitches already hold back (Ratwood lowers bleed_rate with every stitch).
	var/rogue_stitched = 0

/// How far the stitches must get to sew this wound (Ratwood sew_threshold); 0 when a needle cannot sew it.
/datum/wound/proc/rogue_sew_threshold()
	return 0

/datum/wound/slash/flesh/rogue_sew_threshold()
	return rogue_cut_sew_threshold()

/datum/wound/pierce/bleed/rogue_sew_threshold()
	return rogue_cut_sew_threshold()

/// A cut or a stab: a small one sews quickly, an opened artery takes long (Ratwood slash 25 and 50, artery 100).
/datum/wound/proc/rogue_cut_sew_threshold()
	if(severity >= WOUND_SEVERITY_CRITICAL)
		return ROGUE_SEW_THRESHOLD_ARTERY
	return severity >= WOUND_SEVERITY_SEVERE ? ROGUE_SEW_THRESHOLD_SEVERE : ROGUE_SEW_THRESHOLD_MODERATE

/// The wound is sewn shut (Ratwood sew_wound()): a cut or a stab of TG becomes its sewn tail, which still bleeds and hurts a
/// little until it has healed (sewn_bleed_rate, sewn_woundpain, sewn_whp), and leaves the cut's scar then.
/datum/wound/proc/rogue_sew_done()
	var/datum/wound/rogue/sewn/sewn = new
	sewn.rogue_sew_from(src)
	replace_wound(sewn)
	if(!QDELETED(sewn) && sewn.limb)
		sewn.rogue_set_bleed(sewn.rogue_fresh_bleed)

/// A stitch holds blood back (Ratwood: each stitch lowers bleed_rate by half the doctor's Medicine, hold a second's).
/datum/wound/proc/rogue_stitch(hold)
	rogue_stitched += hold

/// Blood per second this wound still loses, stitches counted.
/datum/wound/proc/rogue_bleeding_left()
	return blood_flow + rogue_bleed_delta()

/// Ratwood on_bodypart_gain(): a new wound that bleeds soaks through the bandage on its limb (bandage_expire()). TG's cuts and
/// stabs count only from critical up, an opened artery: a lesser one is a crit's wound made milder, or one stemmed.
/datum/wound/proc/rogue_soaks_bandage()
	return FALSE

/datum/wound/slash/flesh/rogue_soaks_bandage()
	return severity >= WOUND_SEVERITY_CRITICAL

/datum/wound/pierce/bleed/rogue_soaks_bandage()
	return severity >= WOUND_SEVERITY_CRITICAL

/datum/wound/rogue_stump/rogue_soaks_bandage()
	return TRUE

/// What the wound mends a Life tick of sleep, times the quality of the bed (Ratwood sleep_healing: 1 for most wounds).
/datum/wound/proc/rogue_sleep_healing()
	return rogue_value("wound_sleep_healing")

/// An opened artery mends slowly in sleep (Ratwood artery sleep_healing 0.5).
/datum/wound/slash/flesh/rogue_sleep_healing()
	return severity >= WOUND_SEVERITY_CRITICAL ? rogue_value("artery_sleep_healing") : ..()

/datum/wound/pierce/bleed/rogue_sleep_healing()
	return severity >= WOUND_SEVERITY_CRITICAL ? rogue_value("artery_sleep_healing") : ..()

/// A broken bone does not mend in sleep until it is set (Ratwood fracture sleep_healing 0); a dislocation does.
/datum/wound/blunt/bone/rogue_sleep_healing()
	return severity >= WOUND_SEVERITY_SEVERE ? rogue_value("fracture_sleep_healing") : ..()

/datum/wound/cranial_fissure/rogue_sleep_healing()
	return rogue_value("fracture_sleep_healing")

/// A stump is only seared shut (Ratwood dismemberment sleep_healing 0).
/datum/wound/rogue_stump/rogue_sleep_healing()
	return rogue_value("stump_sleep_healing")

/datum/wound/rogue_stump/rogue_sew_threshold()
	return sewn < stumps ? ROGUE_SEW_THRESHOLD_STUMP : 0

/// A sewn stump bleeds and hurts little (Ratwood sewn_bleed_rate 0.25, sewn_woundpain 20); searing still closes it.
/datum/wound/rogue_stump/rogue_sew_done()
	sewn++
	rogue_sew_progress = 0
	rogue_stitched = 0
	adjust_blood_flow(ROGUE_STUMP_SEWN_BLEED - ROGUE_STUMP_BLEED)

/// The sewn tail of a cut or a stab of TG (Ratwood sew_wound()): the wound stays, sewn, with the little bleeding and pain of
/// its sewn state and no more than its sewn health to mend (sewn_bleed_rate, sewn_woundpain, sewn_whp), and mends a little each
/// Life tick by itself (passive_healing 1), in sleep and under medicine (combat/wounds.dm). Healed, it leaves the scar the
/// cut would have left. It does not clot: Ratwood's sewn bleeding is at or below the floor it would clot to.
/datum/wound/rogue/sewn
	name = "sewn wound"
	desc = "A sewn wound, still tender, slowly knitting."
	treat_text = "Let it heal; rest and medicine speed it."
	treat_text_short = "Let it heal"
	examine_desc = "has a sewn wound"

/// Takes over from the wound being sewn: its name, size and scar, and the sewn state of its kind (Ratwood's slashes,
/// punctures and arteries).
/datum/wound/rogue/sewn/proc/rogue_sew_from(datum/wound/old)
	name = "sewn [LOWER_TEXT(old.name)]"
	severity = old.severity
	can_scar = old.can_scar
	scar_keyword = old.scar_keyword
	default_scar_file = old.default_scar_file
	var/stab = istype(old, /datum/wound/pierce)
	var/most
	if(old.severity >= WOUND_SEVERITY_CRITICAL)
		switch(old.rogue_artery)
			if(ROGUE_ARTERY_THROAT)
				most = rogue_value("sewn_throat_health")
				rogue_fresh_bleed = rogue_value("sewn_throat_bleed")
				rogue_woundpain = rogue_value("sewn_throat_pain")
			if(ROGUE_ARTERY_HEART)
				most = rogue_value("sewn_heart_health")
				rogue_fresh_bleed = rogue_value("sewn_heart_bleed")
				rogue_woundpain = rogue_value("sewn_heart_pain")
			else
				most = rogue_value("sewn_artery_health")
				rogue_fresh_bleed = rogue_value("sewn_artery_bleed")
				rogue_woundpain = rogue_value("sewn_artery_pain")
	else if(old.severity >= WOUND_SEVERITY_SEVERE)
		most = stab ? rogue_value("sewn_stab_severe_health") : rogue_value("sewn_cut_severe_health")
		rogue_fresh_bleed = stab ? rogue_value("sewn_stab_severe_bleed") : rogue_value("sewn_cut_severe_bleed")
		rogue_woundpain = rogue_value("sewn_cut_pain")
	else
		most = stab ? rogue_value("sewn_stab_moderate_health") : rogue_value("sewn_cut_moderate_health")
		rogue_fresh_bleed = stab ? rogue_value("sewn_stab_moderate_bleed") : rogue_value("sewn_cut_moderate_bleed")
		rogue_woundpain = rogue_value("sewn_cut_pain")
	var/left = isnull(old.rogue_health) ? old.rogue_health_max() : old.rogue_health
	rogue_health = left > 0 ? min(left, most) : most
	rogue_passive_healing = rogue_value("sewn_passive_healing")

/// Any number of sewn tails on a limb, beside the wounds of every series (the cut that is sewn is already gone).
/datum/wound_pregen_data/rogue_sewn
	abstract = FALSE
	wound_path_to_generate = /datum/wound/rogue/sewn
	can_be_randomly_generated = FALSE
	compete_for_wounding = FALSE
	duplicates_allowed = TRUE
	required_limb_biostate = BIO_FLESH
	required_wounding_type = WOUND_ALL
	wound_series = ROGUE_WOUND_SERIES_SEWN

/datum/wound_pregen_data/rogue_sewn/can_be_applied_to(obj/item/bodypart/limb, suggested_wounding_type = required_wounding_type, datum/wound/old_wound, random_roll = FALSE, duplicates_allowed = src.duplicates_allowed, care_about_existing_wounds = TRUE)
	return ..(limb, suggested_wounding_type, old_wound, random_roll, TRUE, FALSE)

/datum/wound
	/// Ratwood whp: what is left to mend before the wound closes (potions, soaked bandages); null until it is first mended.
	var/rogue_health

/// What mending this wound takes before it closes (Ratwood whp by its kind and size); 0 when mending does not close it.
/datum/wound/proc/rogue_health_max()
	return 0

/datum/wound/slash/flesh/rogue_health_max()
	return rogue_cut_health(ROGUE_WOUND_HEALTH_CUT_MODERATE, ROGUE_WOUND_HEALTH_CUT_SEVERE)

/datum/wound/pierce/bleed/rogue_health_max()
	return rogue_cut_health(ROGUE_WOUND_HEALTH_STAB_MODERATE, ROGUE_WOUND_HEALTH_STAB_SEVERE)

/// A cut or a stab by its size; a critical one is an opened artery (combat/blood.dm), the neck's and the heart's the longest.
/datum/wound/proc/rogue_cut_health(moderate, severe)
	if(severity >= WOUND_SEVERITY_CRITICAL)
		return (rogue_artery == ROGUE_ARTERY_THROAT || rogue_artery == ROGUE_ARTERY_HEART) ? ROGUE_WOUND_HEALTH_ARTERY_VITAL : ROGUE_WOUND_HEALTH_ARTERY
	return severity >= WOUND_SEVERITY_SEVERE ? severe : moderate

/datum/wound/blunt/bone/rogue_health_max()
	return limb?.body_zone == BODY_ZONE_HEAD && severity >= WOUND_SEVERITY_SEVERE ? ROGUE_WOUND_HEALTH_SKULL : ROGUE_WOUND_HEALTH_BONE

/datum/wound/cranial_fissure/rogue_health_max()
	return ROGUE_WOUND_HEALTH_SKULL

/datum/wound/burn/flesh/rogue_health_max()
	if(severity >= WOUND_SEVERITY_CRITICAL)
		return ROGUE_WOUND_HEALTH_BURN_CRITICAL
	return severity >= WOUND_SEVERITY_SEVERE ? ROGUE_WOUND_HEALTH_BURN_SEVERE : ROGUE_WOUND_HEALTH_BURN_MODERATE

/// Ratwood heal_wound(): mends the wound by the amount and eases its pain by half of it (combat/pain.dm); with nothing left to
/// mend it closes (a cut, a stab, a burn or a broken bone of TG is gone, and scars as TG's do). Returns what it took of the
/// amount.
/datum/wound/proc/rogue_heal_wound(amount)
	var/most = rogue_health_max()
	if(!most || amount <= 0)
		return 0
	if(isnull(rogue_health))
		rogue_health = most
	var/healed = min(rogue_health, amount)
	rogue_health -= healed
	rogue_ease_pain(amount)
	if(rogue_health <= 0)
		qdel(src)
	return healed

/// A stump mends by the searing it still needs (integrity): Ratwood's potions heal a stump's whp as the searing does, and its
/// pain eases with it (combat/pain.dm).
/datum/wound/rogue_stump/rogue_heal_wound(amount)
	if(amount <= 0 || integrity <= 0)
		return 0
	var/healed = min(integrity, amount)
	integrity -= healed
	if(victim)
		victim.rogue_pain_hud_dirty = TRUE
	if(integrity <= 0)
		to_chat(victim, span_green("My [stumps > 1 ? "stumps close" : "stump closes"]."))
		qdel(src)
	return healed

/// Ratwood heal_wounds(): mends the wounds one after another, each taking what it needs of the amount and passing the rest on.
/// TRUE when any of them mended.
/proc/rogue_mend_wounds(list/wounds, amount)
	. = FALSE
	for(var/datum/wound/wound as anything in wounds)
		if(amount <= 0)
			break
		var/healed = wound.rogue_heal_wound(amount)
		if(healed)
			amount -= healed
			. = TRUE

/mob/living/carbon/proc/rogue_heal_wounds(amount)
	return rogue_mend_wounds(all_wounds, amount)

/obj/item/bodypart/proc/rogue_heal_wounds(amount)
	return rogue_mend_wounds(wounds, amount)

/// The wounds of this limb a needle can sew.
/obj/item/bodypart/proc/rogue_sewable_wounds()
	. = list()
	for(var/datum/wound/wound as anything in wounds)
		if(wound.rogue_sew_threshold())
			. += wound

/// Ratwood's sew(): every two seconds a stitch, which holds back half the doctor's Medicine of blood (at least 1, per
/// Life tick) and gets the stitches (Medicine + 1) * 5 further; when they reach the wound's threshold it is sewn and the
/// needle spends a thread. The doctor learns a little with each stitch and more on finishing, by intelligence.
/obj/item/needle/proc/rogue_sew(mob/living/carbon/patient, mob/living/user)
	var/obj/item/bodypart/limb = patient.get_bodypart(check_zone(user.zone_selected))
	if(!limb)
		to_chat(user, span_warning("That limb is missing."))
		return
	var/list/sewable = limb.rogue_sewable_wounds()
	if(!length(sewable))
		to_chat(user, span_warning("There aren't any wounds to be sewn."))
		return
	var/datum/wound/target = sewable[1]
	if(length(sewable) > 1)
		var/list/choices = list()
		for(var/datum/wound/wound as anything in sewable)
			choices[avoid_assoc_duplicate_keys(capitalize(wound.name), choices)] = wound
		target = choices[tgui_input_list(user, "Which wound?", "[src]", choices)]
		if(!target)
			return
	var/rank = user.rogue_skill_rank(/datum/attribute/skill/misc/medicine)
	var/step = (rank + 1) * ROGUE_SEW_STEP_PER_RANK
	var/hold = max(rank * ROGUE_SEW_HOLD_PER_RANK, ROGUE_SEW_HOLD_MIN) / ROGUE_LIFE_TICK
	var/informed = FALSE
	while(!QDELETED(target) && target.limb == limb && !QDELETED(src) && user.is_holding(src))
		if(!infinite && stringamt < 1)
			to_chat(user, span_warning("The needle has no thread left!"))
			return
		var/threshold = target.rogue_sew_threshold()
		if(!threshold)
			return
		if(!do_after(user, ROGUE_SEW_STITCH_TIME, target = patient))
			return
		if(QDELETED(target) || target.limb != limb)
			return
		user.rogue_craft_experience(/datum/attribute/skill/misc/medicine, user.rogue_stat(ROGUE_STAT_INTELLIGENCE) * ROGUE_SEW_XP_STEP)
		playsound(patient, 'modular_redtard/rockhill/sound/foley/sewflesh.ogg', 100, TRUE, -2)
		target.rogue_sew_progress = min(target.rogue_sew_progress + step, threshold)
		target.rogue_stitch(hold)
		if(!informed && target.rogue_bleeding_left() <= 0)
			informed = TRUE
			patient.visible_message(span_green("One last drop of blood trickles from the [target.name] on [patient]'s [limb.plaintext_zone] before it closes."), span_green("The throbbing warmth coming out of the [target.name] soothes and stops. It no longer bleeds."))
		if(target.rogue_sew_progress < threshold)
			continue
		user.rogue_craft_experience(/datum/attribute/skill/misc/medicine, user.rogue_stat(ROGUE_STAT_INTELLIGENCE) * ROGUE_SEW_XP_FINISH * threshold / ROGUE_SEW_XP_NORMALIZER)
		if(!infinite)
			stringamt--
			update_appearance(UPDATE_OVERLAYS)
		if(patient == user)
			user.visible_message(span_notice("[user] sews \a [target.name] on [user.p_them()]self."), span_notice("I stitch \a [target.name] on my [limb.plaintext_zone]."))
		else
			user.visible_message(span_notice("[user] sews \a [target.name] on [patient]'s [limb.plaintext_zone]."), span_notice("I stitch \a [target.name] on [patient]'s [limb.plaintext_zone]."))
		log_combat(user, patient, "sewed", src)
		target.rogue_sew_done()
		return

/obj/item/natural/cloth
	/// Share of a limb's bleeding left under this cloth as a bandage (Ratwood bandage_effectiveness).
	var/rogue_bandage_effectiveness = 0.5
	/// Deciseconds bandaging with it takes, before the Medicine skill shortens it (Ratwood bandage_speed).
	var/rogue_bandage_time = 7 SECONDS
	/// Blood it soaks up before it is soaked through (Ratwood bandage_health).
	var/rogue_bandage_capacity = 150
	/// What it can still soak up; null until it is first used.
	var/rogue_bandage_left
	/// Soaked through with blood: as a bandage it no longer helps, until it is washed.
	var/rogue_soaked = FALSE
	/// Soaked in a potion or blessed water (rogue_soak_medicines): what it heals each Ratwood tick as a bandage (Ratwood
	/// medicine_quality), and what of it is left (medicine_amount), spent soak_spend a tick.
	var/rogue_medicine_quality = 0
	var/rogue_medicine_left = 0
	/// What it was soaked in, for its look.
	var/datum/reagent/rogue_medicine

/// Ratwood's bandage: faster to put on, and soaks up twice as much.
/obj/item/natural/cloth/bandage
	rogue_bandage_time = 4 SECONDS
	rogue_bandage_capacity = 300

/obj/item/natural/cloth/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!ishuman(interacting_with) || !rogue_combat_enabled())
		return ..()
	INVOKE_ASYNC(src, PROC_REF(rogue_bandage), interacting_with, user)
	return ITEM_INTERACT_SUCCESS

/// Ratwood's wash_act(): washed, the cloth soaks up as much as new, and the medicine is washed out.
/obj/item/natural/cloth/wash(clean_types)
	. = ..()
	rogue_soaked = FALSE
	rogue_bandage_left = rogue_bandage_capacity
	rogue_clear_medicine()

/// Ratwood's soakings (clothfibersthorn.dm attackby()), in its order: reagent type -> list(what a cloth soaked in it heals a
/// Ratwood tick under a bandage, how long it lasts, Ratwood's word for it). A health potion heals quickly, aqua vitae slowly but
/// long, blessed water slowly and only on a bandage. Aqua vitae is Ratwood's drink (ROGUE_AQUA_VITAE_PATH): its soaking turns on
/// by itself once the reagent exists. Made anew on each use, so the numbers follow the values the admins change.
/proc/rogue_soak_medicines()
	. = list(
		/datum/reagent/medicine/healthpot = list(rogue_value("soak_lyfeblood_quality"), rogue_value("soak_lyfeblood_amount"), "lyfeblood"),
		/datum/reagent/medicine/stronghealth = list(rogue_value("soak_strong_lyfeblood_quality"), rogue_value("soak_strong_lyfeblood_amount"), "strong lyfeblood"),
	)
	var/aqua_vitae = text2path(ROGUE_AQUA_VITAE_PATH)
	if(aqua_vitae)
		.[aqua_vitae] = list(rogue_value("soak_aqua_vitae_quality"), rogue_value("soak_aqua_vitae_amount"), "aqua vitae")
	.[/datum/reagent/water/blessed] = list(rogue_value("soak_blessed_water_quality"), rogue_value("soak_blessed_water_amount"), "blessed water")

/// A vessel used on the cloth soaks it in a medicine it holds soak_units of, if the cloth is not soaked yet.
/obj/item/natural/cloth/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!tool.reagents || !rogue_combat_enabled())
		return ..()
	var/datum/reagent/medicine
	for(var/datum/reagent/kind as anything in rogue_soak_medicines())
		if(tool.reagents.has_reagent(kind, ROGUE_SOAK_UNITS))
			medicine = kind
			break
	if(!medicine)
		return ..()
	if(rogue_medicine_left > 0)
		to_chat(user, span_warning("[src] is already soaked."))
		return ITEM_INTERACT_BLOCKING
	INVOKE_ASYNC(src, PROC_REF(rogue_soak_in), tool, medicine, user)
	return ITEM_INTERACT_SUCCESS

/obj/item/natural/cloth/proc/rogue_soak_in(obj/item/vessel, datum/reagent/medicine, mob/living/user)
	var/list/soakings = rogue_soak_medicines()
	var/list/data = soakings[medicine]
	to_chat(user, span_notice("Soaking [src] in [data[3]]..."))
	if(!do_after(user, ROGUE_SOAK_TIME, target = src) || rogue_medicine_left > 0 || !vessel.reagents?.has_reagent(medicine, ROGUE_SOAK_UNITS))
		return
	vessel.reagents.remove_reagent(medicine, ROGUE_SOAK_UNITS)
	rogue_medicine = medicine
	rogue_medicine_quality = data[1]
	rogue_medicine_left = data[2]
	update_appearance(UPDATE_OVERLAYS)

/// The medicine is spent or washed out.
/obj/item/natural/cloth/proc/rogue_clear_medicine()
	if(!rogue_medicine)
		return
	rogue_medicine = null
	rogue_medicine_quality = 0
	rogue_medicine_left = 0
	update_appearance(UPDATE_OVERLAYS)

/// Ratwood's process_bandage(): a clean bandage soaked in medicine mends the wounds it binds and heals the limb a little each
/// tick, until the medicine is spent.
/obj/item/natural/cloth/proc/rogue_medicine_tick(obj/item/bodypart/limb, ticks)
	if(!rogue_medicine_quality || rogue_soaked)
		return
	var/amount = rogue_medicine_quality * ticks
	limb.rogue_heal_wounds(amount)
	if(limb.brute_dam || limb.burn_dam)
		limb.heal_damage(amount, amount)
	rogue_medicine_left -= ROGUE_SOAK_SPEND * ticks
	if(rogue_medicine_left <= 0)
		rogue_clear_medicine()

/obj/item/natural/cloth/update_overlays()
	. = ..()
	if(rogue_medicine && icon_exists(icon, "[icon_state]_soaked"))
		var/mutable_appearance/soaked = mutable_appearance(icon, "[icon_state]_soaked")
		soaked.color = initial(rogue_medicine.color)
		. += soaked

/obj/item/natural/cloth/examine(mob/user)
	. = ..()
	if(!rogue_medicine)
		return
	var/list/soakings = rogue_soak_medicines()
	var/list/data = soakings[rogue_medicine]
	if(data)
		. += span_notice("It has been soaked in [data[3]].")

/// Ratwood's bandage(): on the limb aimed at, through what does not cover it thickly; the Medicine skill makes it 15% faster
/// a rank, and one who bandages oneself may walk meanwhile.
/obj/item/natural/cloth/proc/rogue_bandage(mob/living/carbon/human/patient, mob/living/user)
	var/obj/item/bodypart/limb = patient.get_bodypart(check_zone(user.zone_selected))
	if(!limb)
		return
	if(limb.rogue_bandage)
		to_chat(user, span_warning("There is already a bandage."))
		return
	if(!patient.try_inject(user, limb.body_zone, INJECT_TRY_SHOW_ERROR_MESSAGE))
		return
	var/time = rogue_bandage_time * max(1 - user.rogue_skill_rank(/datum/attribute/skill/misc/medicine) * ROGUE_BANDAGE_TIME_PER_RANK, 0)
	playsound(patient, 'modular_redtard/rockhill/sound/foley/bandage.ogg', 100, FALSE)
	if(!do_after(user, time, target = patient, timed_action_flags = patient == user ? IGNORE_USER_LOC_CHANGE : NONE))
		return
	if(QDELETED(limb) || limb.owner != patient || limb.rogue_bandage || !user.transferItemToLoc(src, limb))
		return
	limb.rogue_bandage = src
	patient.update_damage_overlays()
	playsound(patient, 'modular_redtard/rockhill/sound/foley/bandage.ogg', 100, FALSE)
	if(patient == user)
		user.visible_message(span_notice("[user] bandages [user.p_their()] [limb.plaintext_zone]."), span_notice("I bandage my [limb.plaintext_zone]."))
	else
		user.visible_message(span_notice("[user] bandages [patient]'s [limb.plaintext_zone]."), span_notice("I bandage [patient]'s [limb.plaintext_zone]."))

/// The cloth soaks up blood; when it can take no more, the blood soaks through.
/obj/item/natural/cloth/proc/rogue_soak(amount, obj/item/bodypart/limb)
	if(isnull(rogue_bandage_left))
		rogue_bandage_left = rogue_bandage_capacity
	rogue_bandage_left -= amount
	if(rogue_bandage_left <= 0)
		rogue_soak_through(limb)

/// Ratwood bandage_expire(): the blood soaks through the bandage, which helps no more until it is washed. A full bandage, or
/// a new wound that bleeds under it (the blood element, combat/blood.dm), does it.
/obj/item/natural/cloth/proc/rogue_soak_through(obj/item/bodypart/limb)
	if(rogue_soaked)
		return
	rogue_soaked = TRUE
	rogue_bandage_left = 0
	var/mob/living/carbon/owner = limb.owner
	if(!owner)
		return
	add_mob_blood(owner)
	if(owner.stat != DEAD)
		owner.visible_message(span_warning("Blood soaks through the bandage on [owner]'s [limb.plaintext_zone]."), span_warning("Blood soaks through the bandage on my [limb.plaintext_zone]."), vision_distance = 3)

/obj/item/bodypart
	/// The cloth binding this limb (Ratwood bodypart bandage).
	var/obj/item/natural/cloth/rogue_bandage

/// Ratwood's bandage on the body (human/update_icons.dm): "<zone>_b" of its sheet of body damage in the colour of the cloth,
/// with the bandage of the breast on a woman's chest, drawn where TG draws its gauze (over the limb, under the clothes). Limbs
/// without TG's damage overlays (a goblin's) and parts without a bandage sprite (the head, Ratwood has none) show none.
/obj/item/bodypart/get_bodypart_damage_state()
	. = ..()
	if(!rogue_bandage || !dmg_overlay_type)
		return
	var/mob/living/carbon/human/person = owner
	var/female = istype(person) && person.physique == FEMALE
	var/sheet = female ? ROGUE_BANDAGE_SHEET_FEMALE : ROGUE_BANDAGE_SHEET_MALE
	var/list/states = list("[body_zone]_b")
	if(female && body_zone == BODY_ZONE_CHEST)
		states += "boob_b"
	for(var/state in states)
		if(!icon_exists(sheet, state))
			continue
		var/mutable_appearance/bandage = mutable_appearance(sheet, state, layer = -GAUZE_LAYER)
		bandage.color = rogue_bandage.color
		if(!.)
			. = list()
		. += bandage

/// Ratwood's get_bleed_rate() under a bandage: the bleeding soaks into a clean bandage, which holds back its share, and
/// what little is left (no more than 1 a Life tick) stops. A soaked bandage helps no more.
/obj/item/bodypart/proc/rogue_bandaged_rate(rate, ticks)
	if(rogue_bandage.rogue_soaked)
		return rate
	if(ticks)
		rogue_bandage.rogue_soak(rate * ROGUE_LIFE_TICK * ticks, src)
	rate *= rogue_bandage.rogue_bandage_effectiveness
	return rate * ROGUE_LIFE_TICK <= ROGUE_BANDAGE_STOP ? 0 : rate

/// A bandage or a leech that leaves the limb (taken off, fallen off) is no longer on it; the bandage no longer shows.
/obj/item/bodypart/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == rogue_bandage)
		rogue_bandage = null
		owner?.update_damage_overlays()
	if(LAZYFIND(rogue_leeches, gone))
		LAZYREMOVE(rogue_leeches, gone)
		var/obj/item/natural/worms/leech/leech = gone
		leech.rogue_limb = null

/// Bandaged limbs and leeches on them, as Ratwood's examine shows them, with a link to take each off.
/mob/living/carbon/human/examine(mob/user)
	. = ..()
	if(!rogue_combat_enabled())
		return
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		var/obj/item/natural/cloth/cloth = limb.rogue_bandage
		if(cloth)
			. += span_notice("[p_Their()] [limb.plaintext_zone] is bandaged with [cloth.rogue_soaked ? "a blood-soaked [cloth.name]" : "\a [cloth]"]. <a href='byond://?src=[REF(src)];rogue_unbandage=[REF(limb)]'>Remove</a>")
		for(var/obj/item/natural/worms/leech/leech as anything in limb.rogue_leeches)
			. += span_notice("\A [leech] is latched onto [p_their()] [limb.plaintext_zone]. <a href='byond://?src=[REF(src)];rogue_unleech=[REF(leech)]'>Remove</a>")

/mob/living/carbon/human/Topic(href, href_list)
	if(href_list["rogue_unbandage"])
		var/obj/item/bodypart/limb = locate(href_list["rogue_unbandage"]) in bodyparts
		if(limb?.rogue_bandage && isliving(usr))
			INVOKE_ASYNC(src, PROC_REF(rogue_unbandage), usr, limb)
		return
	if(href_list["rogue_unleech"])
		var/obj/item/natural/worms/leech/leech = locate(href_list["rogue_unleech"])
		if(istype(leech) && leech.rogue_limb?.owner == src && isliving(usr))
			INVOKE_ASYNC(leech, TYPE_PROC_REF(/obj/item/natural/worms/leech, rogue_rip_off), usr)
		return
	return ..()

/// Ratwood's unbandaging (human_topic.dm): five seconds, 15% faster a rank of Medicine; the cloth comes into the hand.
/mob/living/carbon/human/proc/rogue_unbandage(mob/living/user, obj/item/bodypart/limb)
	var/obj/item/natural/cloth/cloth = limb.rogue_bandage
	if(!IsReachableBy(user))
		to_chat(user, span_warning("I need to be closer to remove that!"))
		return
	if(user == src)
		user.visible_message(span_warning("[user] starts unbandaging [user.p_their()] [limb.plaintext_zone]."), span_warning("I start unbandaging my [limb.plaintext_zone]..."))
	else
		user.visible_message(span_warning("[user] starts unbandaging [src]'s [limb.plaintext_zone]."), span_warning("I start unbandaging [src]'s [limb.plaintext_zone]..."))
	if(!do_after(user, ROGUE_UNBANDAGE_TIME * max(1 - user.rogue_skill_rank(/datum/attribute/skill/misc/medicine) * ROGUE_BANDAGE_TIME_PER_RANK, 0), target = src))
		return
	if(QDELETED(cloth) || QDELETED(limb) || limb.rogue_bandage != cloth)
		return
	cloth.forceMove(drop_location())
	user.put_in_hands(cloth)

#undef ROGUE_BANDAGE_SHEET_MALE
#undef ROGUE_BANDAGE_SHEET_FEMALE
#undef ROGUE_WOUND_SERIES_SEWN
#undef ROGUE_AQUA_VITAE_PATH
