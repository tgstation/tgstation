


// TODO: well, a lot really, but specifically I want to add potential fusing of clothing/equipment on the affected area, and limb infections, though those may go in body part code
/datum/wound/burn
	a_or_from = "from"
	damtype = BURN
	wound_type = WOUND_TYPE_BURN
	processes = TRUE
	sound_effect = 'sound/effects/sizzle1.ogg'

	treatable_by = list(/obj/item/stack/medical/gauze, /obj/item/stack/medical/ointment) // sterilizer and alcohol will require reagent treatments, coming soon

		// Flesh damage vars
	/// How much damage to our flesh we currently have. Once both this and mortification reach 0, the wound is considered healed
	var/flesh_damage
	/// Our current counter for how much flesh regeneration we have stacked from regenerative mesh/synthflesh/whatever, decrements each tick and lowers flesh_damage
	var/flesh_healing = 0
	/// How much dead flesh there is to scrape off before we can really start treatment to regenerate flesh, only relevant for severe and critical burns since moderate is only 2nd degree
	var/mortification

		// Infestation vars
	/// How quickly infection breeds on this burn if we don't have disinfectant
	var/infestation_rate = 0.1
	/// Our current level of infection
	var/infestation = 0
	/// Our current level of sanitization/anti-infection, from disinfectants/alcohol/UV lights. While positive, totally pauses and slowly reverses infestation effects each tick
	var/sanitization = 0

	/// Once we reach infestation beyond WOUND_INFESTATION_SEPSIS, we get this many warnings before the limb is completely paralyzed (you'd have to ignore a really bad burn for a really long time for this to happen)
	var/strikes_to_lose_limb = 3

// TODO: flesh out (haha flesh), also clean up all of this to be more modular and less sprawly
/datum/wound/burn/handle_process()
	. = ..()
	if(flesh_healing > 0)
		flesh_damage--
		flesh_healing--

	if(flesh_damage <= 0 && infestation <= 0)
		to_chat(victim, "<span class='green'>The burns on your [limb.name] have cleared up!</span>")
		remove_wound()
		return

	if(sanitization > 0)
		infestation = max(0, infestation - sanitization)
		sanitization = max(0, sanitization - 0.2) // 0.2 is a magic number, flesh this out
		return

	infestation += infestation_rate

	// TODO: actual math on this stuff
	switch(infestation)
		if(0 to WOUND_INFECTION_MODERATE)

		if(WOUND_INFECTION_MODERATE to WOUND_INFECTION_SEVERE)
			if(prob(30))
				victim.adjustToxLoss(0.2)
				if(prob(6))
					to_chat(victim, "<span class='warning'>The blisters on your [limb.name] ooze a strange pus...</span>")
		if(WOUND_INFECTION_SEVERE to WOUND_INFECTION_CRITICAL)
			if(!disabling && prob(2))
				to_chat(victim, "<span class='warning'><b>Your [limb.name] completely locks up, as you struggle for control against the infection!</b></span>")
				disabling = TRUE
			else if(disabling && prob(8))
				to_chat(victim, "<span class='notice'>You regain sensation in your [limb.name], but it's still in terrible shape!</span>")
				disabling = FALSE
			else if(prob(20))
				victim.adjustToxLoss(0.5)
		if(WOUND_INFECTION_CRITICAL to WOUND_INFECTION_SEPTIC)
			if(!disabling && prob(3))
				to_chat(victim, "<span class='warning'><b>You suddenly lose all sensation of the festering infection in your [limb.name]!</b></span>")
				disabling = TRUE
			else if(disabling && prob(3))
				to_chat(victim, "<span class='notice'>You can barely feel your [limb.name] again, and you have to strain to retain motor control!</span>")
				disabling = FALSE
			else if(prob(5))
				to_chat(victim, "<span class='danger'>You contemplate life without your [limb.name]...</span>")
				victim.adjustToxLoss(0.75)
		if(WOUND_INFECTION_SEPTIC to INFINITY)
			if(prob(infestation))
				switch(strikes_to_lose_limb)
					if(3 to INFINITY)
						to_chat(victim, "<span class='deadsay'>The skin on your [limb.name] is literally dripping off, you feel awful!</span>")
					if(2)
						to_chat(victim, "<span class='deadsay'><b>The infection in your [limb.name] is literally dripping off, you feel horrible!</b></span>")
					if(1)
						to_chat(victim, "<span class='deadsay'><b>Infection has just about completely claimed your [limb.name]!</b></span>")
					if(0)
						to_chat(victim, "<span class='deadsay'><b>The last of the nerve endings in your [limb.name] wither away, as the infection completely paralyzes your joint connector.</b></span>")
						var/datum/brain_trauma/severe/paralysis/sepsis = new (limb.body_zone)
						victim.gain_trauma(sepsis)
						processes = FALSE
				strikes_to_lose_limb--

/datum/wound/burn/get_examine_description(mob/user)
	if(strikes_to_lose_limb <= 0)
		return "<span class='deadsay'><B>[victim.p_their(TRUE)] [limb.name] is completely dead and unrecognizable as organic.</B></span>"

	var/infection_condition = ""
	// how much life we have left in these bandages
	switch(infestation)
		if(WOUND_INFECTION_MODERATE to WOUND_INFECTION_SEVERE)
			infection_condition = ", <span class='deadsay'>with discolored spots along the nearby veins!</span>"
		if(WOUND_INFECTION_SEVERE to WOUND_INFECTION_CRITICAL)
			infection_condition = ", <span class='deadsay'>with dark clouds spreading outwards under the skin!</span>"
		if(WOUND_INFECTION_CRITICAL to WOUND_INFECTION_SEPTIC)
			infection_condition = ", <span class='deadsay'>with spots of rotten infection forming and unforming!</span>"
		if(WOUND_INFECTION_SEPTIC to INFINITY)
			return "<span class='deadsay'><B>[victim.p_their(TRUE)] [limb.name] is a mess of char and flesh, skin literally dripping off the bone with infection!</B></span>"
		else
			infection_condition = "!"

	return "<B>[victim.p_their(TRUE)] [limb.name] [examine_desc][infection_condition]</B>"

/*
	new burn common procs
*/

// TODO:actually balance ointment + regen mesh + bandages
/datum/wound/burn/proc/ointment(obj/item/stack/medical/ointment/I, mob/user)
	victim.visible_message("<span class='green'>[user] begins applying [I] to [victim]'s [limb.name]...</span>", "<span class='green'>[user] begins applying [I] to your [limb.name]...</span>")
	if(!do_after(user, base_treat_time, extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	user.visible_message("<span class='green'>[user] applies [I] to [victim].</span>", "<span class='green'>You apply [I] to [victim]'s [limb.name].</span>")
	I.use(1)
	limb.heal_damage(burn = 3) // just a lil
	sanitization += 4 // make vars for this later

/datum/wound/burn/proc/bandage(obj/item/stack/medical/gauze/I, mob/user)
	user.visible_message("<span class='green'>[user] begins wrapping [victim]'s [limb.name] with [I]...</span>", "<span class='green'>You begin wrapping [user == victim ? "your" : "[victim]'s"] [limb.name] with [I]...</span>")
	if(!do_after(user, base_treat_time * (user == victim ? 1.5 : 1), target=victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	user.visible_message("<span class='green'>[user] applies [I] to [victim].</span>", "<span class='green'>You apply [I] to [user == victim ? "your" : "[victim]'s"] [limb.name].</span>")
	I.use(1)
	sanitization += 5 // make vars for this later

/datum/wound/burn/treat_self(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/medical/gauze))
		bandage(I, user)
		return
	if(istype(I, /obj/item/stack/medical/ointment))
		ointment(I, user)
		return

/datum/wound/burn/treat(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/medical/gauze))
		bandage(I, user)
		return
	if(istype(I, /obj/item/stack/medical/ointment))
		ointment(I, user)
		return

/datum/wound/burn/proc/regenerate_flesh(amount)
	flesh_healing += amount

// we don't even care about first degree burns, straight to second
/datum/wound/burn/moderate
	name = "Second Degree Burns"
	desc = "Patient is suffering considerable burns with mild skin penetration, weakening limb integrity and increased burning sensations."
	treat_text = "Recommended application of disinfectant and salve to affected limb, followed by bandaging."
	examine_desc = "is badly burned and breaking out in blisters"
	occur_text = "breaks out with violent red burns"
	severity = WOUND_SEVERITY_MODERATE
	damage_mulitplier_penalty = 1.25
	threshold_minimum = 40
	threshold_penalty = 30 // burns cause significant decrease in limb integrity compared to other wounds
	status_effect_type = /datum/status_effect/wound/burn/moderate

	infestation_rate = 0.1
	flesh_damage = 15

/datum/wound/burn/severe
	name = "Third Degree Burns"
	desc = "Patient is suffering extreme burns with full skin penetration, creating serious risk of infection and greatly reduced limb integrity."
	treat_text = "Recommended immediate disinfection and excision of ruined skin, followed by bandaging."
	examine_desc = "appears seriously charred, with aggressive red splotches"
	occur_text = "chars rapidly, exposing ruined tissue and spreading angry red burns"
	severity = WOUND_SEVERITY_SEVERE
	damage_mulitplier_penalty = 1.5
	threshold_minimum = 80
	threshold_penalty = 40
	status_effect_type = /datum/status_effect/wound/burn/severe

	infestation_rate = 0.25
	flesh_damage = 30
	mortification = 4

/datum/wound/burn/critical
	name = "Catastrophic Burns"
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

	infestation_rate = 1.5
	flesh_damage = 60
	mortification = 6
