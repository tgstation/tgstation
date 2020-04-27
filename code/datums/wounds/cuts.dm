
/*
	Cuts
*/

/datum/wound/brute/cut
	sound_effect = 'sound/weapons/slice.ogg'
	processes = TRUE
	wound_type = WOUND_TYPE_CUT

	/// How much blood we start losing when this wound is first applied
	var/initial_flow
	/// When we have less than this amount of flow, either from treatment or clotting, we demote to a lower cut or are healed
	var/minimum_flow
	/// How fast our blood flow will naturally decrease per tick, not only do larger cuts bleed more faster, they clot slower
	var/clot_rate

	/// Once the blood flow drops below minimum_flow, we demote it to this type of wound. If there's none, we're all better
	var/demotes_to

	treatable_by = list(/obj/item/stack/medical/suture, /obj/item/stack/medical/gauze, /obj/item/gun/energy/laser)
	treatable_tool = TOOL_CAUTERY
	/// How much staunching per type (cautery, suturing, bandaging) you can have before that type is no longer effective for this cut
	var/max_per_type
	/// The maximum flow we've had so far
	var/highest_flow
	/// How much flow we've already cauterized
	var/cauterized
	/// How much flow we've already sutured
	var/sutured

	var/obj/item/stack/current_bandage

/datum/wound/brute/cut/apply_wound(obj/item/bodypart/L, silent = FALSE, datum/wound/brute/cut/old_wound = NONE, special_arg = NONE)
	. = ..()
	blood_flow = initial_flow
	if(old_wound)
		blood_flow = old_wound.blood_flow

/datum/wound/brute/cut/remove_wound()
	QDEL_NULL(current_bandage)
	..()

/datum/wound/brute/cut/handle_process()
	if(current_bandage)
		if(clot_rate > 0)
			blood_flow -= clot_rate
		blood_flow -= current_bandage.absorption_rate
		current_bandage.absorption_capacity -= current_bandage.absorption_rate
		if(current_bandage.absorption_capacity < 0)
			victim.visible_message("<span class='danger'>Blood seeps through \the [current_bandage] on [victim]'s [limb.name].</span>", "<span class='warning'>Blood seeps through \the [current_bandage] on your [limb.name].</span>", vision_distance=COMBAT_MESSAGE_RANGE)
			QDEL_NULL(current_bandage)
	else
		blood_flow -= clot_rate

	if(blood_flow > highest_flow)
		highest_flow = blood_flow

	if(blood_flow < minimum_flow)
		if(demotes_to)
			replace_wound(demotes_to)
		else
			to_chat(victim, "<span class='green'>The cut on your [limb.name] has stopped bleeding!</span>")
			remove_wound()

/datum/wound/brute/cut/treat_self(obj/item/I, mob/user)
	if(istype(I, /obj/item/gun/energy/laser))
		self_las_cauterize(I, user)
	else if(I.tool_behaviour == TOOL_CAUTERY)
		self_tool_cauterize(I, user)
	else if(istype(I, /obj/item/stack/medical/gauze))
		bandage(I, user)
	else if(istype(I, /obj/item/stack/medical/suture))
		suture(I, user)

/datum/wound/brute/cut/treat(obj/item/I, mob/user)
	if(istype(I, /obj/item/gun/energy/laser))
		las_cauterize(I, user)
	else if(I.tool_behaviour == TOOL_CAUTERY)
		tool_cauterize(I, user)
	else if(istype(I, /obj/item/stack/medical/gauze))
		bandage(I, user)
	else if(istype(I, /obj/item/stack/medical/suture))
		suture(I, user)

/datum/wound/brute/cut/proc/self_las_cauterize(obj/item/gun/energy/laser/lasgun, mob/user)
	victim.visible_message("<span class='warning'>[user] begins aiming [lasgun] directly at [victim.p_their()] own [limb.name]...</span>", "<span class='userdanger'>You begin aiming [lasgun] directly at your [limb.name]...</span>")
	if(!do_after(user, base_treat_time * 1.5, target=victim))
		return
	var/damage = lasgun.chambered.BB.damage
	lasgun.chambered.BB.wound_bonus -= 30
	lasgun.chambered.BB.damage *= 1.5
	lasgun.process_fire(victim, victim, TRUE, null, limb.body_zone)
	victim.emote("scream")
	victim.visible_message("<span class='warning'>The cuts on [victim]'s [limb.name] scar over!</span>")
	blood_flow -= damage / 15
	cauterized += damage / 15

/datum/wound/brute/cut/proc/las_cauterize(obj/item/gun/energy/laser/lasgun, mob/user)
	victim.visible_message("<span class='warning'>[user] begins aiming [lasgun] directly at [victim]'s [limb.name]...</span>", "<span class='userdanger'>[user] begins aiming [lasgun] directly at your [limb.name]...</span>")
	if(!do_after(user, base_treat_time, extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	var/damage = lasgun.chambered.BB.damage
	lasgun.chambered.BB.wound_bonus -= 40
	lasgun.chambered.BB.damage *= 1.5
	lasgun.process_fire(victim, user, TRUE, null, limb.body_zone)
	victim.emote("scream")
	victim.visible_message("<span class='warning'>The cuts on [victim]'s [limb.name] scar over!</span>")
	blood_flow -= damage / 10
	cauterized += damage / 10


/datum/wound/brute/cut/proc/self_tool_cauterize(obj/item/I, mob/user)
	victim.visible_message("<span class='danger'>[user] begins cauterizing [victim.p_their()] own [limb.name] with [I]...</span>", "<span class='warning'>You begin cauterizing your [limb.name] with [I]...</span>")
	if(!do_after(victim, base_treat_time * 1.5, target=victim))
		return

	to_chat(victim, "<span class='green'>You cauterize some of the bleeding on your [limb.name].<b>It hurts!</b></span>")
	limb.receive_damage(burn = 3 + severity, wound_bonus = CANT_WOUND)
	if(prob(70))
		victim.emote("scream")
	blood_flow -= 0.4
	cauterized += 0.4

	if(blood_flow > minimum_flow)
		try_treating(I, user)
	else
		to_chat(victim,"<span class='green'>The cuts on your [limb.name] scar over!</span>")
		return

/datum/wound/brute/cut/proc/tool_cauterize(obj/item/I, mob/user)
	victim.visible_message("<span class='warning'>[user] begins cauterizing [victim]'s [limb.name] with [I]...</span>", "<span class='userdanger'>[user] begins cauterizing your [limb.name] with [I]...</span>")
	if(!do_after(user, base_treat_time, extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	user.visible_message("<span class='green'>[user] cauterizes some of the bleeding on [victim].</span>", "<span class='green'>You cauterize some of the bleeding on [victim].</span>")
	limb.receive_damage(burn = 2 + severity, wound_bonus = CANT_WOUND)
	if(prob(30))
		victim.emote("scream")
	blood_flow -= 0.5
	cauterized += 0.5

	if(blood_flow > minimum_flow)
		try_treating(I, user)
	else
		to_chat(user, "<span class='green'>You successfully lower the severity of [victim]'s cuts.</span>")


/datum/wound/brute/cut/proc/suture(obj/item/stack/medical/suture/I, mob/user)
	var/efficiency = 1
	if(user == victim)
		efficiency = 0.75
		victim.visible_message("<span class='notice'>[victim] begins stitching [victim.p_their()] [limb.name] with [I]...</span>", "<span class='notice'>You begin stitching your [limb.name] with [I]...</span>")
	else
		victim.visible_message("<span class='notice'>[user] begins stitching [victim]'s [limb.name] with [I]...</span>", "<span class='notice'>[user] begins stitching your [limb.name] with [I]...</span>")
	if(!do_after(user, base_treat_time, extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	user.visible_message("<span class='green'>[user] stitches up some of the bleeding on [victim].</span>", "<span class='green'>You stitch up some of the bleeding on [victim].</span>")
	//limb.receive_damage(brute = 2 + severity, wound_bonus = CANT_WOUND)
	blood_flow -= I.stop_bleeding * efficiency
	sutured += I.stop_bleeding * efficiency

	if(blood_flow > minimum_flow)
		try_treating(I, user)
	else
		to_chat(user, "<span class='green'>You successfully lower the severity of [victim]'s cuts.</span>")


/datum/wound/brute/cut/proc/bandage(obj/item/stack/I, mob/user)
	if(current_bandage)
		if(current_bandage.absorption_capacity > I.absorption_capacity)
			to_chat(user, "<span class='warning'>The [current_bandage] on [victim]'s [limb.name] is still in better condition than your [I.name]!</span>")
			return
		else
			victim.visible_message("<span class='warning'>[user] begins topping off the wrapping on [victim]'s [limb.name] with [I]...</span>", "<span class='warning'>[user] begins topping off the wrapping on your [limb.name] with [I]...</span>")
	else
		victim.visible_message("<span class='warning'>[user] begins wrapping [victim]'s [limb.name] with [I]...</span>", "<span class='warning'>[user] begins wrapping your [limb.name] with [I]...</span>")
	if(!do_after(user, base_treat_time, extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	user.visible_message("<span class='green'>[user] applies [I] to [victim]'s [limb.name].</span>", "<span class='green'>You bandage some of the bleeding on [victim].</span>")
	QDEL_NULL(current_bandage)
	current_bandage = new I.type(limb)
	current_bandage.amount = 1
	I.use(1)


/datum/wound/brute/cut/moderate
	name = "Rough Abrasion"
	desc = "Patient's skin has been badly scraped, generating moderate blood loss."
	treat_text = "Application of clean bandages or first-aid grade sutures, followed by food and rest."
	examine_desc = "has an open cut"
	occur_text = "is cut open, slowly leaking blood"
	severity = WOUND_SEVERITY_MODERATE
	initial_flow = 3
	minimum_flow = 1
	max_per_type = 4
	clot_rate = 0.15
	threshold_minimum = 20
	threshold_penalty = 10
	status_effect_type = /datum/status_effect/wound/cut/moderate

/datum/wound/brute/cut/severe
	name = "Open Laceration"
	desc = "Patient's skin is ripped clean open, allowing significant blood loss."
	treat_text = "Speedy application of first-aid grade sutures and clean bandages, followed by vitals monitoring to ensure recovery."
	examine_desc = "has a severe cut"
	occur_text = "is ripped open, veins spurting blood"
	severity = WOUND_SEVERITY_SEVERE
	initial_flow = 5
	minimum_flow = 3
	clot_rate = 0.05
	max_per_type = 5
	threshold_minimum = 50
	threshold_penalty = 25
	demotes_to = /datum/wound/brute/cut/moderate
	status_effect_type = /datum/status_effect/wound/cut/severe

/datum/wound/brute/cut/critical
	name = "Weeping Avulsion"
	desc = "Patient's skin is completely torn open, along with significant loss of tissue. Extreme blood loss will lead to quick death without intervention."
	treat_text = "Immediate surgical suturing and bandaging followed by supervised resanguination."
	examine_desc = "is spurting blood at an alarming rate"
	occur_text = "is torn open, spraying blood wildly"
	severity = WOUND_SEVERITY_CRITICAL
	initial_flow = 7
	minimum_flow = 6
	clot_rate = -0.1
	max_per_type = 6
	threshold_minimum = 80
	threshold_penalty = 40
	demotes_to = /datum/wound/brute/cut/severe
	status_effect_type = /datum/status_effect/wound/cut/critical
