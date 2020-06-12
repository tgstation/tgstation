
/*
	Cuts
*/

/datum/wound/brute/cut
	sound_effect = 'sound/weapons/slice.ogg'
	processes = TRUE
	wound_type = WOUND_LIST_CUT
	treatable_by = list(/obj/item/stack/medical/suture, /obj/item/stack/medical/gauze)
	treatable_by_grabbed = list(/obj/item/gun/energy/laser)
	treatable_tool = TOOL_CAUTERY
	treat_priority = TRUE
	base_treat_time = 3 SECONDS

	/// How much blood we start losing when this wound is first applied
	var/initial_flow
	/// When we have less than this amount of flow, either from treatment or clotting, we demote to a lower cut or are healed of the wound
	var/minimum_flow
	/// How fast our blood flow will naturally decrease per tick, not only do larger cuts bleed more faster, they clot slower
	var/clot_rate

	/// Once the blood flow drops below minimum_flow, we demote it to this type of wound. If there's none, we're all better
	var/demotes_to

	/// How much staunching per type (cautery, suturing, bandaging) you can have before that type is no longer effective for this cut NOT IMPLEMENTED
	var/max_per_type
	/// The maximum flow we've had so far
	var/highest_flow
	/// How much flow we've already cauterized
	var/cauterized
	/// How much flow we've already sutured
	var/sutured

	/// The current bandage we have for this wound (maybe move bandages to the limb?)
	var/obj/item/stack/current_bandage
	/// A bad system I'm using to track the worst scar we earned (since we can demote, we want the biggest our wound has been, not what it was when it was cured (probably moderate))
	var/datum/scar/highest_scar

/datum/wound/brute/cut/wound_injury(datum/wound/brute/cut/old_wound = null)
	blood_flow = initial_flow
	if(old_wound)
		blood_flow = max(old_wound.blood_flow, initial_flow)
		if(old_wound.severity > severity && old_wound.highest_scar)
			highest_scar = old_wound.highest_scar
			old_wound.highest_scar = null
		if(old_wound.current_bandage)
			current_bandage = old_wound.current_bandage
			old_wound.current_bandage = null

	if(!highest_scar)
		highest_scar = new
		highest_scar.generate(limb, src, add_to_scars=FALSE)

/datum/wound/brute/cut/remove_wound(ignore_limb, replaced)
	if(!replaced && highest_scar)
		already_scarred = TRUE
		highest_scar.lazy_attach(limb)
	return ..()

/datum/wound/brute/cut/get_examine_description(mob/user)
	if(!current_bandage)
		return ..()

	var/bandage_condition = ""
	// how much life we have left in these bandages
	switch(current_bandage.absorption_capacity)
		if(0 to 1.25)
			bandage_condition = "nearly ruined "
		if(1.25 to 2.75)
			bandage_condition = "badly worn "
		if(2.75 to 4)
			bandage_condition = "slightly bloodied "
		if(4 to INFINITY)
			bandage_condition = "clean "
	return "<B>The cuts on [victim.p_their()] [limb.name] are wrapped with [bandage_condition] [current_bandage.name]!</B>"

/datum/wound/brute/cut/receive_damage(wounding_type, wounding_dmg, wound_bonus)
	if(victim.stat != DEAD && wounding_type == WOUND_SHARP) // can't stab dead bodies to make it bleed faster this way
		blood_flow += 0.05 * wounding_dmg

/datum/wound/brute/cut/handle_process()
	blood_flow = min(blood_flow, WOUND_CUT_MAX_BLOODFLOW)

	if(victim.reagents && victim.reagents.has_reagent(/datum/reagent/toxin/heparin))
		blood_flow += 0.5 // old herapin used to just add +2 bleed stacks per tick, this adds 0.5 bleed flow to all open cuts which is probably even stronger as long as you can cut them first
	else if(victim.reagents && victim.reagents.has_reagent(/datum/reagent/medicine/coagulant))
		blood_flow -= 0.25

	if(current_bandage)
		if(clot_rate > 0)
			blood_flow -= clot_rate
		blood_flow -= current_bandage.absorption_rate
		current_bandage.absorption_capacity -= current_bandage.absorption_rate
		if(current_bandage.absorption_capacity < 0)
			victim.visible_message("<span class='danger'>Blood soaks through \the [current_bandage] on [victim]'s [limb.name].</span>", "<span class='warning'>Blood soaks through \the [current_bandage] on your [limb.name].</span>", vision_distance=COMBAT_MESSAGE_RANGE)
			QDEL_NULL(current_bandage)
			treat_priority = TRUE
	else
		blood_flow -= clot_rate

	if(blood_flow > highest_flow)
		highest_flow = blood_flow

	if(blood_flow < minimum_flow)
		if(demotes_to)
			replace_wound(demotes_to)
		else
			to_chat(victim, "<span class='green'>The cut on your [limb.name] has stopped bleeding!</span>")
			qdel(src)

/* BEWARE, THE BELOW NONSENSE IS MADNESS. bones.dm looks more like what I have in mind and is sufficiently clean, don't pay attention to this messiness */

/datum/wound/brute/cut/check_grab_treatments(obj/item/I, mob/user)
	if(istype(I, /obj/item/gun/energy/laser))
		return TRUE

/datum/wound/brute/cut/treat(obj/item/I, mob/user)
	if(istype(I, /obj/item/gun/energy/laser))
		las_cauterize(I, user)
	else if(I.tool_behaviour == TOOL_CAUTERY || I.get_temperature() > 300)
		tool_cauterize(I, user)
	else if(istype(I, /obj/item/stack/medical/gauze))
		bandage(I, user)
	else if(istype(I, /obj/item/stack/medical/suture))
		suture(I, user)

/datum/wound/brute/cut/try_handling(mob/living/carbon/human/user)
	if(user.pulling != victim || user.zone_selected != limb.body_zone || user.a_intent == INTENT_GRAB)
		return FALSE

	if(!isfelinid(user))
		return FALSE

	lick_wounds(user)
	return TRUE

/// if a felinid is licking this cut to reduce bleeding
/datum/wound/brute/cut/proc/lick_wounds(mob/living/carbon/human/user)
	if(INTERACTING_WITH(user, victim))
		to_chat(user, "<span class='warning'>You're already interacting with [victim]!</span>")
		return

	user.visible_message("<span class='notice'>[user] begins licking the wounds on [victim]'s [limb.name].</span>", "<span class='notice'>You begin licking the wounds on [victim]'s [limb.name]...</span>", ignored_mobs=victim)
	to_chat(victim, "<span class='notice'>[user] begins to lick the wounds on your [limb.name].</span")
	if(!do_after(user, base_treat_time, target=victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	user.visible_message("<span class='notice'>[user] licks the wounds on [victim]'s [limb.name].</span>", "<span class='notice'>You lick some of the wounds on [victim]'s [limb.name]</span>", ignored_mobs=victim)
	to_chat(victim, "<span class='green'>[user] licks the wounds on your [limb.name]!</span")
	blood_flow -= 0.5

	if(blood_flow > minimum_flow)
		try_handling(user)
	else if(demotes_to)
		to_chat(user, "<span class='green'>You successfully lower the severity of [victim]'s cuts.</span>")

/datum/wound/brute/cut/on_xadone(power)
	. = ..()
	blood_flow -= 0.03 * power // i think it's like a minimum of 3 power, so .09 blood_flow reduction per tick is pretty good for 0 effort

/// If someone's putting a laser gun up to our cut to cauterize it
/datum/wound/brute/cut/proc/las_cauterize(obj/item/gun/energy/laser/lasgun, mob/user)
	var/self_penalty_mult = (user == victim ? 1.25 : 1)
	user.visible_message("<span class='warning'>[user] begins aiming [lasgun] directly at [victim]'s [limb.name]...</span>", "<span class='userdanger'>You begin aiming [lasgun] directly at [user == victim ? "your" : "[victim]'s"] [limb.name]...</span>")
	if(!do_after(user, base_treat_time  * self_penalty_mult, target=victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return
	var/damage = lasgun.chambered.BB.damage
	lasgun.chambered.BB.wound_bonus -= 30
	lasgun.chambered.BB.damage *= self_penalty_mult
	if(!lasgun.process_fire(victim, victim, TRUE, null, limb.body_zone))
		return
	victim.emote("scream")
	blood_flow -= damage / (5 * self_penalty_mult) // 20 / 5 = 4 bloodflow removed, p good
	cauterized += damage / (5 * self_penalty_mult)
	victim.visible_message("<span class='warning'>The cuts on [victim]'s [limb.name] scar over!</span>")

/// If someone is using either a cautery tool or something with heat to cauterize this cut
/datum/wound/brute/cut/proc/tool_cauterize(obj/item/I, mob/user)
	var/self_penalty_mult = (user == victim ? 1.5 : 1)
	user.visible_message("<span class='danger'>[user] begins cauterizing [victim]'s [limb.name] with [I]...</span>", "<span class='danger'>You begin cauterizing [user == victim ? "your" : "[victim]'s"] [limb.name] with [I]...</span>")
	var/time_mod = user.mind?.get_skill_modifier(/datum/skill/healing, SKILL_SPEED_MODIFIER) || 1
	if(!do_after(user, base_treat_time * time_mod * self_penalty_mult, target=victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	user.visible_message("<span class='green'>[user] cauterizes some of the bleeding on [victim].</span>", "<span class='green'>You cauterize some of the bleeding on [victim].</span>")
	limb.receive_damage(burn = 2 + severity, wound_bonus = CANT_WOUND)
	if(prob(30))
		victim.emote("scream")
	var/blood_cauterized = (0.6 / self_penalty_mult)
	blood_flow -= blood_cauterized
	cauterized += blood_cauterized

	if(blood_flow > minimum_flow)
		try_treating(I, user)
	else if(demotes_to)
		to_chat(user, "<span class='green'>You successfully lower the severity of [user == victim ? "your" : "[victim]'s"] cuts.</span>")

/// If someone is using a suture to close this cut
/datum/wound/brute/cut/proc/suture(obj/item/stack/medical/suture/I, mob/user)
	var/self_penalty_mult = (user == victim ? 1.4 : 1)
	user.visible_message("<span class='notice'>[user] begins stitching [victim]'s [limb.name] with [I]...</span>", "<span class='notice'>You begin stitching [user == victim ? "your" : "[victim]'s"] [limb.name] with [I]...</span>")
	var/time_mod = user.mind?.get_skill_modifier(/datum/skill/healing, SKILL_SPEED_MODIFIER) || 1
	if(!do_after(user, base_treat_time * time_mod * self_penalty_mult, target=victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return
	user.visible_message("<span class='green'>[user] stitches up some of the bleeding on [victim].</span>", "<span class='green'>You stitch up some of the bleeding on [user == victim ? "yourself" : "[victim]"].</span>")
	var/blood_sutured = I.stop_bleeding / self_penalty_mult
	blood_flow -= blood_sutured
	sutured += blood_sutured
	limb.heal_damage(I.heal_brute, I.heal_burn)

	if(blood_flow > minimum_flow)
		try_treating(I, user)
	else if(demotes_to)
		to_chat(user, "<span class='green'>You successfully lower the severity of [user == victim ? "your" : "[victim]'s"] cuts.</span>")

/// If someone is using gauze on this cut
/datum/wound/brute/cut/proc/bandage(obj/item/stack/I, mob/user)
	if(current_bandage)
		if(current_bandage.absorption_capacity > I.absorption_capacity + 1)
			to_chat(user, "<span class='warning'>The [current_bandage] on [victim]'s [limb.name] is still in better condition than your [I.name]!</span>")
			return
		else
			user.visible_message("<span class='warning'>[user] begins rewrapping the cuts on [victim]'s [limb.name] with [I]...</span>", "<span class='warning'>You begin rewrapping the cuts on [user == victim ? "your" : "[victim]'s"] [limb.name] with [I]...</span>")
	else
		user.visible_message("<span class='warning'>[user] begins wrapping the cuts on [victim]'s [limb.name] with [I]...</span>", "<span class='warning'>You begin wrapping the cuts on [user == victim ? "your" : "[victim]'s"] [limb.name] with [I]...</span>")
	var/time_mod = user.mind?.get_skill_modifier(/datum/skill/healing, SKILL_SPEED_MODIFIER) || 1
	if(!do_after(user, base_treat_time * time_mod, target=victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	user.visible_message("<span class='green'>[user] applies [I] to [victim]'s [limb.name].</span>", "<span class='green'>You bandage some of the bleeding on [user == victim ? "yourself" : "[victim]"].</span>")
	QDEL_NULL(current_bandage)
	current_bandage = new I.type(limb)
	current_bandage.amount = 1
	treat_priority = FALSE
	I.use(1)


/datum/wound/brute/cut/moderate
	name = "Rough Abrasion"
	desc = "Patient's skin has been badly scraped, generating moderate blood loss."
	treat_text = "Application of clean bandages or first-aid grade sutures, followed by food and rest."
	examine_desc = "has an open cut"
	occur_text = "is cut open, slowly leaking blood"
	sound_effect = 'sound/effects/blood1.ogg'
	severity = WOUND_SEVERITY_MODERATE
	initial_flow = 2
	minimum_flow = 0.5
	max_per_type = 3
	clot_rate = 0.15
	threshold_minimum = 20
	threshold_penalty = 10
	status_effect_type = /datum/status_effect/wound/cut/moderate
	scarring_descriptions = list("light, faded lines", "minor cut marks", "a small faded slit", "a series of small scars")

/datum/wound/brute/cut/severe
	name = "Open Laceration"
	desc = "Patient's skin is ripped clean open, allowing significant blood loss."
	treat_text = "Speedy application of first-aid grade sutures and clean bandages, followed by vitals monitoring to ensure recovery."
	examine_desc = "has a severe cut"
	occur_text = "is ripped open, veins spurting blood"
	sound_effect = 'sound/effects/blood2.ogg'
	severity = WOUND_SEVERITY_SEVERE
	initial_flow = 3.25
	minimum_flow = 2.75
	clot_rate = 0.07
	max_per_type = 4
	threshold_minimum = 50
	threshold_penalty = 25
	demotes_to = /datum/wound/brute/cut/moderate
	status_effect_type = /datum/status_effect/wound/cut/severe
	scarring_descriptions = list("a twisted line of faded gashes", "a gnarled sickle-shaped slice scar", "a long-faded puncture wound")

/datum/wound/brute/cut/critical
	name = "Weeping Avulsion"
	desc = "Patient's skin is completely torn open, along with significant loss of tissue. Extreme blood loss will lead to quick death without intervention."
	treat_text = "Immediate bandaging and either suturing or cauterization, followed by supervised resanguination."
	examine_desc = "is spurting blood at an alarming rate"
	occur_text = "is torn open, spraying blood wildly"
	sound_effect = 'sound/effects/blood3.ogg'
	severity = WOUND_SEVERITY_CRITICAL
	initial_flow = 4.25
	minimum_flow = 4
	clot_rate = -0.05 // critical cuts actively get worse instead of better
	max_per_type = 5
	threshold_minimum = 80
	threshold_penalty = 40
	demotes_to = /datum/wound/brute/cut/severe
	status_effect_type = /datum/status_effect/wound/cut/critical
	scarring_descriptions = list("a winding path of very badly healed scar tissue", "a series of peaks and valleys along a gruesome line of cut scar tissue", "a grotesque snake of indentations and stitching scars")

// TODO: see about moving dismemberment over to this, i'll have to add judging dismembering power/wound potential wrt item size i guess
/datum/wound/brute/cut/loss
	name = "Dismembered"
	desc = "oof ouch!!"
	occur_text = "is violently dismembered!"
	sound_effect = 'sound/effects/dismember.ogg'
	viable_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	severity = WOUND_SEVERITY_LOSS
	threshold_minimum = 180
	status_effect_type = null

/datum/wound/brute/cut/loss/apply_wound(obj/item/bodypart/L, silent, datum/wound/brute/cut/old_wound, smited = FALSE)
	if(!L.dismemberable)
		qdel(src)
		return

	L.dismember()
	qdel(src)
