


// TODO: well, a lot really, but specifically I want to add potential fusing of clothing/equipment on the affected area, and limb infections, though those may go in body part code
/datum/wound/burn
	damtype = BURN
	wound_type = WOUND_TYPE_BURN
	processes = TRUE
	sound_effect = 'sound/effects/sizzle1.ogg'

	treatable_by = list(/obj/item/stack/medical/gauze, /obj/item/stack/medical/ointment) // sterilizer and alcohol will require reagent treatments, coming soon

	/// How quickly infection breeds on this burn
	var/infection_rate = 0.1
	/// How much infection can we breed on this burn
	var/max_infestation = 3
	/// Our current level of infection
	var/infestation = 0
	/// Our current level of sanitization (anti-infection)
	var/sanitization = 0

// TODO: flesh out (haha flesh)
/datum/wound/burn/handle_process()
	. = ..()
	if(sanitization > 0)
		infestation = max(0, infestation - sanitization)
		sanitization = max(0, sanitization - 0.2)
		return

	if(infestation < max_infestation)
		infestation = min(max_infestation, infestation + infection_rate)

	switch(infestation / max_infestation)
		if(0.3 to 0.5)
			if(prob(20))
				victim.adjustToxLoss(infestation * 0.1)
				if(prob(10))
					to_chat(victim, "<span class='warning'>The blisters on your [limb.name] ooze a strange pus...</span>")
		if(0.5 to 0.7)
			if(prob(30))
				victim.adjustToxLoss(infestation * 0.2)
				if(prob(6))
					to_chat(victim, "<span class='warning'>Your [limb.name] feels like it's crawling...</span>")
		if(0.7 to 1)
			if(prob(30))
				victim.adjustToxLoss(infestation * 0.3)
				if(prob(15))
					to_chat(victim, "<span class='warning'>Your [limb.name] festers, turning more discolored by the second...</span>")



/datum/wound/burn/proc/bandage(obj/item/stack/medical/gauze/I, mob/user)
	victim.visible_message("<span class='green'>[user] begins wrapping [victim]'s [limb.name] with [I]...</span>", "<span class='green'>[user] begins wrapping your [limb.name] with [I]...</span>")
	if(do_after(user, base_treat_time, target=victim))
		if(QDELETED(src) || !limb)
			return
		user.visible_message("<span class='green'>[user] applies [I] to [victim].</span>", "<span class='green'>You apply [I] to [victim]'s [limb.name].</span>")
		I.use(1)
		limb.heal_damage(burn = 3) // just a lil

		sanitization += 4 // make vars for this later

/datum/wound/burn/proc/self_bandage(obj/item/stack/medical/gauze/I, mob/user)
	victim.visible_message("<span class='green'>[victim] begins wrapping [victim.p_their()] [limb.name] with [I]...</span>", "<span class='green'>You begin wrapping your [limb.name] with [I]...</span>")
	if(do_after(victim, base_treat_time))
		if(QDELETED(src) || !limb)
			return
		victim.visible_message("<span class='green'>[victim] sloppily applies [I] to [victim.p_their()] [limb].</span>", "<span class='green'>You sloppily apply [I] to your [limb.name].</span>")
		I.use(1)
		// no heal for self bandage, less sanitization too

		sanitization += 2 // make vars for this later

/datum/wound/burn/treat_self(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/medical/gauze))
		self_bandage(I, user)
		return
	if(istype(I, /obj/item/stack/medical/ointment))
		//self_ointment(I, user)
		return

/datum/wound/burn/treat(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/medical/gauze))
		bandage(I, user)
		return
	if(istype(I, /obj/item/stack/medical/ointment))
		//ointment(I, user)
		return

// we don't even care about first degree burns, straight to second
/datum/wound/burn/moderate
	name = "second degree burns"
	desc = "Patient is suffering considerable burns with mild skin penetration, creating a risk of infection and increased burning sensations."
	treat_text = "Recommended application of disinfectant and salve to affected limb, followed by bandaging."
	examine_desc = "is badly burned and breaking out in blisters"
	occur_text = "breaks out with violent red burns"
	severity = WOUND_SEVERITY_MODERATE
	damage_mulitplier_penalty = 1.25
	threshold_minimum = 40
	threshold_penalty = 30 // burns cause significant decrease in limb integrity compared to other wounds
	status_effect_type = /datum/status_effect/wound/burn/moderate



/datum/wound/burn/severe
	name = "third degree burns"
	desc = "Patient is suffering extreme burns with full skin penetration, creating serious risk of infection and greatly reduced limb integrity."
	treat_text = "Recommended immediate disinfection and excision of ruined skin, followed by bandaging."
	examine_desc = "appears seriously charred, with aggressive red splotches"
	occur_text = "chars rapidly, exposing ruined tissue and spreading angry red burns"
	severity = WOUND_SEVERITY_SEVERE
	damage_mulitplier_penalty = 1.5
	threshold_minimum = 80
	threshold_penalty = 40
	status_effect_type = /datum/status_effect/wound/burn/severe

/datum/wound/burn/critical
	name = "catastrophic burns"
	desc = "Patient is suffering near complete loss of tissue and significantly charred muscle and bone, creating life-threatening risk of infection and negligible limb integrity."
	treat_text = "Immediate surgical debriding of ruined skin, followed by potent tissue regeneration formula and bandaging."
	examine_desc = "is a ruined mess of blanched bone, melted fat, and charred tissue"
	occur_text = "vaporizes as flesh, bone, and fat melt together in a horrifying mess"
	severity = WOUND_SEVERITY_CRITICAL
	damage_mulitplier_penalty = 2
	sound_effect = 'sound/effects/sizzle2.ogg'
	threshold_minimum = 140
	threshold_penalty = 80
	status_effect_type = /datum/status_effect/wound/burn/critical

	max_infestation = 9
	/// If we have max infestation and we fail this many checks, we lose our whole damn limb assuming it's, y'know, a limb
	var/strikes_to_lose_limb = 3
	/// How many checks we've failed
	var/strikes

/datum/wound/burn/critical/handle_process()
	. = ..()

//	if(infestation >= max_infestation)
