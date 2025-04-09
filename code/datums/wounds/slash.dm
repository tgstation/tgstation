
/*
	Slashing wounds
*/

/datum/wound/slash
	name = "Slashing (Cut) Wound"
	sound_effect = 'sound/items/weapons/slice.ogg'

/datum/wound_pregen_data/flesh_slash
	abstract = TRUE

	required_wounding_types = list(WOUND_SLASH)
	required_limb_biostate = BIO_FLESH

	wound_series = WOUND_SERIES_FLESH_SLASH_BLEED

/datum/wound/slash/flesh
	name = "Slashing (Cut) Flesh Wound"
	processes = TRUE
	treatable_by = list(/obj/item/stack/medical/suture)
	treatable_by_grabbed = list(/obj/item/gun/energy/laser)
	treatable_tools = list(TOOL_CAUTERY)
	base_treat_time = 3 SECONDS
	wound_flags = (ACCEPTS_GAUZE|CAN_BE_GRASPED)

	default_scar_file = FLESH_SCAR_FILE

	/// How much blood we start losing when this wound is first applied
	var/initial_flow
	/// When we have less than this amount of flow, either from treatment or clotting, we demote to a lower cut or are healed of the wound
	var/minimum_flow
	/// How much our blood_flow will naturally decrease per second, not only do larger cuts bleed more blood faster, they clot slower (higher number = clot quicker, negative = opening up)
	var/clot_rate

	/// Once the blood flow drops below minimum_flow, we demote it to this type of wound. If there's none, we're all better
	var/demotes_to

	/// A bad system I'm using to track the worst scar we earned (since we can demote, we want the biggest our wound has been, not what it was when it was cured (probably moderate))
	var/datum/scar/highest_scar

/datum/wound/slash/flesh/Destroy()
	highest_scar = null

	return ..()

/datum/wound/slash/flesh/wound_injury(datum/wound/slash/flesh/old_wound = null, attack_direction = null)
	if(old_wound)
		set_blood_flow(max(old_wound.blood_flow, initial_flow))
		if(old_wound.severity > severity && old_wound.highest_scar)
			set_highest_scar(old_wound.highest_scar)
			old_wound.clear_highest_scar()
	else
		set_blood_flow(initial_flow)
		if(limb.can_bleed() && attack_direction && victim.blood_volume > BLOOD_VOLUME_OKAY)
			victim.spray_blood(attack_direction, severity)

	if(!highest_scar)
		var/datum/scar/new_scar = new
		set_highest_scar(new_scar)
		new_scar.generate(limb, src, add_to_scars=FALSE)

	return ..()

/datum/wound/slash/flesh/proc/set_highest_scar(datum/scar/new_scar)
	if(highest_scar)
		UnregisterSignal(highest_scar, COMSIG_QDELETING)
	if(new_scar)
		RegisterSignal(new_scar, COMSIG_QDELETING, PROC_REF(clear_highest_scar))
	highest_scar = new_scar

/datum/wound/slash/flesh/proc/clear_highest_scar(datum/source)
	SIGNAL_HANDLER
	set_highest_scar(null)

/datum/wound/slash/flesh/remove_wound(ignore_limb, replaced)
	if(!replaced && highest_scar)
		already_scarred = TRUE
		highest_scar.lazy_attach(limb)
	return ..()

/datum/wound/slash/flesh/get_wound_description(mob/user)
	if(!limb.current_gauze)
		return ..()

	var/list/msg = list("The cuts on [victim.p_their()] [limb.plaintext_zone] are wrapped with ")
	// how much life we have left in these bandages
	switch(limb.current_gauze.absorption_capacity)
		if(0 to 1.25)
			msg += "nearly ruined"
		if(1.25 to 2.75)
			msg += "badly worn"
		if(2.75 to 4)
			msg += "slightly bloodied"
		if(4 to INFINITY)
			msg += "clean"
	msg += " [limb.current_gauze.name]!"

	return "<B>[msg.Join()]</B>"

/datum/wound/slash/flesh/receive_damage(wounding_type, wounding_dmg, wound_bonus)
	if (!victim) // if we are dismembered, we can still take damage, its fine to check here
		return

	if(victim.stat != DEAD && wound_bonus != CANT_WOUND && wounding_type == WOUND_SLASH) // can't stab dead bodies to make it bleed faster this way
		adjust_blood_flow(WOUND_SLASH_DAMAGE_FLOW_COEFF * wounding_dmg)

	return ..()

/datum/wound/slash/flesh/drag_bleed_amount()
	// say we have 3 severe cuts with 3 blood flow each, pretty reasonable
	// compare with being at 100 brute damage before, where you bled (brute/100 * 2), = 2 blood per tile
	var/bleed_amt = min(blood_flow * 0.1, 1) // 3 * 3 * 0.1 = 0.9 blood total, less than before! the share here is .3 blood of course.

	if(limb.current_gauze) // gauze stops all bleeding from dragging on this limb, but wears the gauze out quicker
		limb.seep_gauze(bleed_amt * 0.33)
		return

	return bleed_amt

/datum/wound/slash/flesh/get_bleed_rate_of_change()
	//basically if a species doesn't bleed, the wound is stagnant and will not heal on its own (nor get worse)
	if(!limb.can_bleed())
		return BLOOD_FLOW_STEADY
	if(HAS_TRAIT(victim, TRAIT_BLOODY_MESS))
		return BLOOD_FLOW_INCREASING
	if(limb.current_gauze || clot_rate > 0)
		return BLOOD_FLOW_DECREASING
	if(clot_rate < 0)
		return BLOOD_FLOW_INCREASING

/datum/wound/slash/flesh/handle_process(seconds_per_tick, times_fired)
	if (!victim || HAS_TRAIT(victim, TRAIT_STASIS))
		return

	// in case the victim has the NOBLOOD trait, the wound will simply not clot on its own
	if(limb.can_bleed())
		if(clot_rate > 0)
			adjust_blood_flow(-clot_rate * seconds_per_tick)
			if(QDELETED(src))
				return

		if(HAS_TRAIT(victim, TRAIT_BLOODY_MESS))
			adjust_blood_flow(0.25) // old heparin used to just add +2 bleed stacks per tick, this adds 0.5 bleed flow to all open cuts which is probably even stronger as long as you can cut them first

	if(limb.current_gauze)
		var/gauze_power = limb.current_gauze.absorption_rate
		limb.seep_gauze(gauze_power * seconds_per_tick)
		adjust_blood_flow(-gauze_power * seconds_per_tick)

/* BEWARE, THE BELOW NONSENSE IS MADNESS. bones.dm looks more like what I have in mind and is sufficiently clean, don't pay attention to this messiness */

/datum/wound/slash/flesh/check_grab_treatments(obj/item/I, mob/user)
	if(istype(I, /obj/item/gun/energy/laser))
		return TRUE
	if(I.get_temperature()) // if we're using something hot but not a cautery, we need to be aggro grabbing them first, so we don't try treating someone we're eswording
		return TRUE

/datum/wound/slash/flesh/treat(obj/item/I, mob/user)
	if(istype(I, /obj/item/gun/energy/laser))
		return las_cauterize(I, user)
	else if(I.tool_behaviour == TOOL_CAUTERY || I.get_temperature())
		return tool_cauterize(I, user)

/datum/wound/slash/flesh/try_handling(mob/living/user)
	if(user.pulling != victim || !HAS_TRAIT(user, TRAIT_WOUND_LICKER) || !victim.try_inject(user, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE))
		return FALSE
	if(!isnull(user.hud_used?.zone_select) && user.zone_selected != limb.body_zone)
		return FALSE

	if(DOING_INTERACTION_WITH_TARGET(user, victim))
		to_chat(user, span_warning("You're already interacting with [victim]!"))
		return
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		if(carbon_user.is_mouth_covered())
			to_chat(user, span_warning("Your mouth is covered, you can't lick [victim]'s wounds!"))
			return
		if(!carbon_user.get_organ_slot(ORGAN_SLOT_TONGUE))
			to_chat(user, span_warning("You can't lick wounds without a tongue!")) // f in chat
			return

	lick_wounds(user)
	return TRUE

/// if a felinid is licking this cut to reduce bleeding
/datum/wound/slash/flesh/proc/lick_wounds(mob/living/carbon/human/user)
	// transmission is one way patient -> felinid since google said cat saliva is antiseptic or whatever, and also because felinids are already risking getting beaten for this even without people suspecting they're spreading a deathvirus
	for(var/datum/disease/iter_disease as anything in victim.diseases)
		if(iter_disease.spread_flags & (DISEASE_SPREAD_SPECIAL | DISEASE_SPREAD_NON_CONTAGIOUS))
			continue
		user.ForceContractDisease(iter_disease)

	user.visible_message(span_notice("[user] begins licking the wounds on [victim]'s [limb.plaintext_zone]."), span_notice("You begin licking the wounds on [victim]'s [limb.plaintext_zone]..."), ignored_mobs=victim)
	to_chat(victim, span_notice("[user] begins to lick the wounds on your [limb.plaintext_zone]."))
	if(!do_after(user, base_treat_time, target = victim, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return

	user.visible_message(span_notice("[user] licks the wounds on [victim]'s [limb.plaintext_zone]."), span_notice("You lick some of the wounds on [victim]'s [limb.plaintext_zone]"), ignored_mobs=victim)
	to_chat(victim, span_green("[user] licks the wounds on your [limb.plaintext_zone]!"))
	var/mob/victim_stored = victim
	adjust_blood_flow(-0.5)

	if(blood_flow > minimum_flow)
		try_handling(user)
	else if(demotes_to)
		to_chat(user, span_green("You successfully lower the severity of [user == victim_stored ? "your" : "[victim_stored]'s"] cuts."))

/datum/wound/slash/flesh/adjust_blood_flow(adjust_by, minimum)
	. = ..()
	if(blood_flow > WOUND_MAX_BLOODFLOW)
		blood_flow = WOUND_MAX_BLOODFLOW
	if(blood_flow < minimum_flow && !QDELETED(src))
		if(demotes_to)
			replace_wound(new demotes_to)
		else
			to_chat(victim, span_green("The cut on your [limb.plaintext_zone] has [!limb.can_bleed() ? "healed up" : "stopped bleeding"]!"))
			qdel(src)

/datum/wound/slash/flesh/on_xadone(power)
	. = ..()
	adjust_blood_flow(-0.03 * power) // i think it's like a minimum of 3 power, so .09 blood_flow reduction per tick is pretty good for 0 effort

/datum/wound/slash/flesh/on_synthflesh(reac_volume)
	. = ..()
	adjust_blood_flow(-0.075 * reac_volume) // 20u * 0.075 = -1.5 blood flow, pretty good for how little effort it is

/// If someone's putting a laser gun up to our cut to cauterize it
/datum/wound/slash/flesh/proc/las_cauterize(obj/item/gun/energy/laser/lasgun, mob/user)
	var/self_penalty_mult = (user == victim ? 1.25 : 1)
	user.visible_message(span_warning("[user] begins aiming [lasgun] directly at [victim]'s [limb.plaintext_zone]..."), span_userdanger("You begin aiming [lasgun] directly at [user == victim ? "your" : "[victim]'s"] [limb.plaintext_zone]..."))
	if(!do_after(user, base_treat_time  * self_penalty_mult, target = victim, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return
	var/damage = lasgun.chambered.loaded_projectile.damage
	lasgun.chambered.loaded_projectile.wound_bonus -= 30
	lasgun.chambered.loaded_projectile.damage *= self_penalty_mult
	if(!lasgun.process_fire(victim, victim, TRUE, null, limb.body_zone))
		return
	victim.painful_scream() // DOPPLER EDIT: check for painkilling before screaming
	adjust_blood_flow(-1 * (damage / (5 * self_penalty_mult))) // 20 / 5 = 4 bloodflow removed, p good
	victim.visible_message(span_warning("The cuts on [victim]'s [limb.plaintext_zone] scar over!"))
	return TRUE

/// If someone is using either a cautery tool or something with heat to cauterize this cut
/datum/wound/slash/flesh/proc/tool_cauterize(obj/item/I, mob/user)
	var/improv_penalty_mult = (I.tool_behaviour == TOOL_CAUTERY ? 1 : 1.25) // 25% longer and less effective if you don't use a real cautery
	var/self_penalty_mult = (user == victim ? 1.5 : 1) // 50% longer and less effective if you do it to yourself

	var/treatment_delay = base_treat_time * self_penalty_mult * improv_penalty_mult

	if(HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		treatment_delay *= 0.5
		user.visible_message(span_danger("[user] begins expertly cauterizing [victim]'s [limb.plaintext_zone] with [I]..."), span_warning("You begin cauterizing [user == victim ? "your" : "[victim]'s"] [limb.plaintext_zone] with [I], keeping the holo-image indications in mind..."))
	else
		user.visible_message(span_danger("[user] begins cauterizing [victim]'s [limb.plaintext_zone] with [I]..."), span_warning("You begin cauterizing [user == victim ? "your" : "[victim]'s"] [limb.plaintext_zone] with [I]..."))

	playsound(user, 'sound/items/handling/surgery/cautery1.ogg', 75, TRUE)

	if(!do_after(user, treatment_delay, target = victim, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return

	playsound(user, 'sound/items/handling/surgery/cautery2.ogg', 75, TRUE)

	var/bleeding_wording = (!limb.can_bleed() ? "cuts" : "bleeding")
	user.visible_message(span_green("[user] cauterizes some of the [bleeding_wording] on [victim]."), span_green("You cauterize some of the [bleeding_wording] on [victim]."))
	victim.apply_damage(2 + severity, BURN, limb, wound_bonus = CANT_WOUND)
	if(prob(30))
		victim.painful_scream() // DOPPLER EDIT: check for painkilling before screaming
	var/blood_cauterized = (0.6 / (self_penalty_mult * improv_penalty_mult))
	var/mob/victim_stored = victim
	adjust_blood_flow(-blood_cauterized)

	if(blood_flow > minimum_flow)
		return try_treating(I, user)
	else if(demotes_to)
		to_chat(user, span_green("You successfully lower the severity of [user == victim_stored ? "your" : "[victim_stored]'s"] cuts."))
		return TRUE
	return FALSE

/datum/wound/slash/get_limb_examine_description()
	return span_warning("The flesh on this limb appears badly lacerated.")

/datum/wound/slash/flesh/moderate
	name = "Rough Abrasion"
	desc = "Patient's skin has been badly scraped, generating moderate blood loss."
	treat_text = "Apply bandaging or suturing to the wound. \
		Follow up with food and a rest period."
	treat_text_short = "Apply bandaging or suturing."
	examine_desc = "has an open cut"
	occur_text = "is cut open, slowly leaking blood"
	sound_effect = 'sound/effects/wounds/blood1.ogg'
	severity = WOUND_SEVERITY_MODERATE
	initial_flow = 2
	minimum_flow = 0.5
	clot_rate = 0.05
	threshold_penalty = 10
	status_effect_type = /datum/status_effect/wound/slash/flesh/moderate
	scar_keyword = "slashmoderate"

	simple_treat_text = "<b>Bandaging</b> the wound will reduce blood loss, help the wound close by itself quicker, and speed up the blood recovery period. The wound itself can be slowly <b>sutured</b> shut."
	homemade_treat_text = "<b>Tea</b> stimulates the body's natural healing systems, slightly fastening clotting. The wound itself can be rinsed off on a sink or shower as well. Other remedies are unnecessary."

/datum/wound/slash/flesh/moderate/update_descriptions()
	if(!limb.can_bleed())
		occur_text = "is cut open"

/datum/wound_pregen_data/flesh_slash/abrasion
	abstract = FALSE

	wound_path_to_generate = /datum/wound/slash/flesh/moderate

	threshold_minimum = 20

/datum/wound/slash/flesh/severe
	name = "Open Laceration"
	desc = "Patient's skin is ripped clean open, allowing significant blood loss."
	treat_text = "Swiftly apply bandaging or suturing to the wound, \
		or make use of blood clotting agents or cauterization. \
		Follow up with iron supplements or saline-glucose and a rest period."
	treat_text_short = "Apply bandaging, suturing, clotting agents, or cauterization."
	examine_desc = "has a severe cut"
	occur_text = "is ripped open, veins spurting blood"
	sound_effect = 'sound/effects/wounds/blood2.ogg'
	severity = WOUND_SEVERITY_SEVERE
	initial_flow = 3.25
	minimum_flow = 2.75
	clot_rate = 0.03
	threshold_penalty = 25
	demotes_to = /datum/wound/slash/flesh/moderate
	status_effect_type = /datum/status_effect/wound/slash/flesh/severe
	scar_keyword = "slashsevere"

	simple_treat_text = "<b>Bandaging</b> the wound is essential, and will reduce blood loss. Afterwards, the wound can be <b>sutured</b> shut, preferably while the patient is resting and/or grasping their wound."
	homemade_treat_text = "Bed sheets can be ripped up to make <b>makeshift gauze</b>. <b>Flour, table salt, or salt mixed with water</b> can be applied directly to stem the flow, though unmixed salt will irritate the skin and worsen natural healing. Resting and grabbing your wound will also reduce bleeding."

/datum/wound_pregen_data/flesh_slash/laceration
	abstract = FALSE

	wound_path_to_generate = /datum/wound/slash/flesh/severe

	threshold_minimum = 50

/datum/wound/slash/flesh/severe/update_descriptions()
	if(!limb.can_bleed())
		occur_text = "is ripped open"

/datum/wound/slash/flesh/critical
	name = "Weeping Avulsion"
	desc = "Patient's skin is completely torn open, along with significant loss of tissue. Extreme blood loss will lead to quick death without intervention."
	treat_text = "Immediately apply bandaging or suturing to the wound, \
		or make use of blood clotting agents or cauterization. \
		Follow up supervised resanguination."
	treat_text_short = "Apply bandaging, suturing, clotting agents, or cauterization."
	examine_desc = "is carved down to the bone, spraying blood wildly"
	occur_text = "is torn open, spraying blood wildly"
	sound_effect = 'sound/effects/wounds/blood3.ogg'
	severity = WOUND_SEVERITY_CRITICAL
	initial_flow = 4
	minimum_flow = 3.85
	clot_rate = -0.015 // critical cuts actively get worse instead of better
	threshold_penalty = 40
	demotes_to = /datum/wound/slash/flesh/severe
	status_effect_type = /datum/status_effect/wound/slash/flesh/critical
	scar_keyword = "slashcritical"
	wound_flags = (ACCEPTS_GAUZE | MANGLES_EXTERIOR | CAN_BE_GRASPED)
	simple_treat_text = "<b>Bandaging</b> the wound is of utmost importance, as is seeking direct medical attention - <b>Death</b> will ensue if treatment is delayed whatsoever, with lack of <b>oxygen</b> killing the patient, thus <b>Food, Iron, and saline solution</b> is always recommended after treatment. This wound will not naturally seal itself."
	homemade_treat_text = "Bed sheets can be ripped up to make <b>makeshift gauze</b>. <b>Flour, salt, and saltwater</b> topically applied will help. Dropping to the ground and grabbing your wound will reduce blood flow."

/datum/wound/slash/flesh/critical/update_descriptions()
	if (!limb.can_bleed())
		occur_text = "is torn open"

/datum/wound_pregen_data/flesh_slash/avulsion
	abstract = FALSE

	wound_path_to_generate = /datum/wound/slash/flesh/critical
	threshold_minimum = 80

/datum/wound/slash/flesh/moderate/many_cuts
	name = "Numerous Small Slashes"
	desc = "Patient's skin has numerous small slashes and cuts, generating moderate blood loss."
	examine_desc = "has a ton of small cuts"
	occur_text = "is cut numerous times, leaving many small slashes."

/datum/wound_pregen_data/flesh_slash/abrasion/cuts
	abstract = FALSE
	can_be_randomly_generated = FALSE

	wound_path_to_generate = /datum/wound/slash/flesh/moderate/many_cuts

// Subtype for cleave (heretic spell)
/datum/wound/slash/flesh/critical/cleave
	name = "Burning Avulsion"
	examine_desc = "is ruptured, spraying blood wildly"
	clot_rate = 0.01

/datum/wound/slash/flesh/critical/cleave/update_descriptions()
	if(!limb.can_bleed())
		occur_text = "is ruptured"

/datum/wound_pregen_data/flesh_slash/avulsion/clear
	abstract = FALSE
	can_be_randomly_generated = FALSE

	wound_path_to_generate = /datum/wound/slash/flesh/critical/cleave
