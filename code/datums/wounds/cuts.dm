
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

	var/cauterized

	var/bandaged

	var/stitched

/datum/wound/brute/cut/apply_wound(obj/item/bodypart/L, silent = FALSE, datum/wound/brute/cut/old_wound = NONE, special_arg = NONE)
	. = ..()
	blood_flow = initial_flow
	if(old_wound)
		blood_flow = old_wound.blood_flow


/datum/wound/brute/cut/handle_process()
	blood_flow -= clot_rate
	if(blood_flow < minimum_flow)
		if(demotes_to)
			replace_wound(demotes_to)
		else
			remove_wound()

/datum/wound/brute/cut/treat_self(obj/item/I, mob/user)
	if(istype(I, /obj/item/gun/energy/laser))
		self_las_cauterize(I, user)
	else if(I.tool_behaviour == TOOL_CAUTERY)
		self_tool_cauterize(I, user)
	else if(istype(I, /obj/item/stack/medical/gauze))
		self_bandage(I, user)

/datum/wound/brute/cut/treat(obj/item/I, mob/user)
	if(istype(I, /obj/item/gun/energy/laser))
		las_cauterize(I, user)
	else if(I.tool_behaviour == TOOL_CAUTERY)
		tool_cauterize(I, user)
	else if(istype(I, /obj/item/stack/medical/gauze))
		bandage(I, user)

/datum/wound/brute/cut/proc/self_las_cauterize(obj/item/gun/energy/laser/lasgun, mob/user)
	victim.visible_message("<span class='warning'>[user] begins aiming [lasgun] directly at [victim.p_their()] own [limb.name]...</span>", "<span class='userdanger'>You begin aiming [lasgun] directly at your [limb.name]...</span>")
	if(do_after(user, base_treat_time * 1.5, target=victim))
		if(QDELETED(src) || !limb)
			return
		var/damage = lasgun.chambered.BB.damage
		lasgun.chambered.BB.wound_bonus -= 30
		lasgun.chambered.BB.damage *= 1.5
		lasgun.process_fire(victim, victim, TRUE, null, limb.body_zone)
		victim.emote("scream")
		victim.visible_message("<span class='warning'>The cuts on [victim]'s [limb.name] scar over!</span>")
		blood_flow -= damage / 15


/datum/wound/brute/cut/proc/las_cauterize(obj/item/gun/energy/laser/lasgun, mob/user)
	victim.visible_message("<span class='warning'>[user] begins aiming [lasgun] directly at [victim]'s [limb.name]...</span>", "<span class='userdanger'>[user] begins aiming [lasgun] directly at your [limb.name]...</span>")
	if(do_after(user, base_treat_time, target=victim))
		if(QDELETED(src) || !limb)
			return
		var/damage = lasgun.chambered.BB.damage
		lasgun.chambered.BB.wound_bonus -= 40
		lasgun.chambered.BB.damage *= 1.5
		lasgun.process_fire(victim, user, TRUE, null, limb.body_zone)
		victim.emote("scream")
		victim.visible_message("<span class='warning'>The cuts on [victim]'s [limb.name] scar over!</span>")
		blood_flow -= damage / 10



/datum/wound/brute/cut/proc/self_tool_cauterize(obj/item/I, mob/user)
	victim.visible_message("<span class='danger'>[user] begins cauterizing [victim.p_their()] own [limb.name] with [I]...</span>", "<span class='warning'>You begin cauterizing your [limb.name] with [I]...</span>")
	if(do_after(victim, base_treat_time * 1.5, target=victim))
		if(QDELETED(src) || !limb)
			return
		to_chat(victim, "<span class='green'>You cauterize some of the bleeding on your [limb.name].<b>It hurts!</b></span>")
		limb.receive_damage(burn = 3 + severity, wound_bonus = CANT_WOUND)
		if(prob(70))
			victim.emote("scream")
		blood_flow -= 0.4

		if(blood_flow > minimum_flow)
			try_treating(I, user)
		else
			to_chat(victim,"<span class='green'>The cuts on your [limb.name] scar over!</span>")
			return

/datum/wound/brute/cut/proc/tool_cauterize(obj/item/I, mob/user)
	victim.visible_message("<span class='warning'>[user] begins cauterizing [victim]'s [limb.name] with [I]...</span>", "<span class='userdanger'>[user] begins cauterizing your [limb.name] with [I]...</span>")
	if(do_after(user, base_treat_time, target=victim))
		if(QDELETED(src) || !limb)
			return
		user.visible_message("<span class='green'>[user] cauterizes some of the bleeding on [victim].</span>", "<span class='green'>You cauterize some of the bleeding on [victim].</span>")
		limb.receive_damage(burn = 2 + severity, wound_bonus = CANT_WOUND)
		if(prob(30))
			victim.emote("scream")
		blood_flow -= 0.5
		if(blood_flow > minimum_flow)
			try_treating(I, user)
		else
			to_chat(user, "<span class='green'>You successfully lower the severity of [victim]'s cuts.</span>")
			to_chat(victim,"<span class='green'>The cuts on [victim]'s [limb.name] scar over!</span>")


/datum/wound/brute/cut/proc/self_bandage(obj/item/I, mob/user)
	user.visible_message("<span class='warning'>[user] begins wrapping [victim]'s [limb.name] with [I]...</span>", "<span class='userdanger'>[user] begins wrapping your [limb.name] with [I]...</span>")
	if(do_after(user, base_treat_time * 1.5, target=victim))
		if(QDELETED(src) || !limb)
			return
		user.visible_message("<span class='green'>[user] bandages some of the.</span>", "<span class='green'>You bandage some of the bleeding on [victim].</span>")
		blood_flow -= 0.5
		if(blood_flow > minimum_flow)
			try_treating(I, user)
		else
			to_chat(user, "<span class='green'>You successfully lower the severity of [victim]'s cuts.</span>")
			to_chat(victim,"<span class='green'>The bleeding on your [limb.name] drops off!</span>")


/datum/wound/brute/cut/proc/bandage(obj/item/I, mob/user)
	victim.visible_message("<span class='warning'>[user] begins wrapping [victim]'s [limb.name] with [I]...</span>", "<span class='userdanger'>[user] begins wrapping your [limb.name] with [I]...</span>")
	if(do_after(user, base_treat_time, target=victim))
		if(QDELETED(src) || !limb)
			return
		user.visible_message("<span class='green'>[user] bandages some of the bleeding on [victim].</span>", "<span class='green'>You bandage some of the bleeding on [victim].</span>")
		blood_flow -= 0.5
		if(blood_flow > minimum_flow)
			try_treating(I, user)
		else
			to_chat(user, "<span class='green'>You successfully lower the severity of [victim]'s cuts.</span>")
			to_chat(victim,"<span class='green'>The bleeding on your [limb.name] drops off!</span>")




/datum/wound/brute/cut/moderate
	name = "rough abrasion"
	desc = "Patient's skin has been badly scraped, generating moderate blood loss."
	treat_text = "Application of clean bandages or first-aid grade sutures, followed by food and rest."
	examine_desc = "has an open cut"
	occur_text = "is cut open, slowly leaking blood"
	severity = WOUND_SEVERITY_MODERATE
	initial_flow = 3
	minimum_flow = 1
	clot_rate = 0.15
	threshold_minimum = 20
	threshold_penalty = 10
	status_effect_type = /datum/status_effect/wound/cut/moderate

/datum/wound/brute/cut/severe
	name = "open laceration"
	desc = "Patient's skin is ripped clean open, allowing significant blood loss."
	treat_text = "Speedy application of first-aid grade sutures and clean bandages, followed by vitals monitoring to ensure recovery."
	examine_desc = "has a severe cut"
	occur_text = "is ripped open, veins spurting blood"
	severity = WOUND_SEVERITY_SEVERE
	initial_flow = 6
	minimum_flow = 3
	clot_rate = 0.125
	threshold_minimum = 50
	threshold_penalty = 25
	demotes_to = /datum/wound/brute/cut/moderate
	status_effect_type = /datum/status_effect/wound/cut/severe

/datum/wound/brute/cut/critical
	name = "weeping avulsion"
	desc = "Patient's skin is completely torn open, along with significant loss of tissue. Extreme blood loss will lead to quick death without intervention."
	treat_text = "Immediate surgical suturing and bandaging followed by supervised resanguination."
	examine_desc = "is spurting blood at an alarming rate"
	occur_text = "is torn open, spraying blood wildly"
	severity = WOUND_SEVERITY_CRITICAL
	initial_flow = 9
	minimum_flow = 6
	clot_rate = 0.1
	threshold_minimum = 80
	threshold_penalty = 40
	demotes_to = /datum/wound/brute/cut/severe
	status_effect_type = /datum/status_effect/wound/cut/critical
