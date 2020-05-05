


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
	var/flesh_damage = 5
	/// Our current counter for how much flesh regeneration we have stacked from regenerative mesh/synthflesh/whatever, decrements each tick and lowers flesh_damage
	var/flesh_healing = 0
	/// How much dead flesh there is to scrape off before we can really start treatment to regenerate flesh, only relevant for severe and critical burns since moderate is only 2nd degree
	var/mortification = 0

		// Infestation vars (only for severe and critical)
	/// How quickly infection breeds on this burn if we don't have disinfectant
	var/infestation_rate = 0
	/// Our current level of infection
	var/infestation = 0
	/// Our current level of sanitization/anti-infection, from disinfectants/alcohol/UV lights. While positive, totally pauses and slowly reverses infestation effects each tick
	var/sanitization = 0

	/// Once we reach infestation beyond WOUND_INFESTATION_SEPSIS, we get this many warnings before the limb is completely paralyzed (you'd have to ignore a really bad burn for a really long time for this to happen)
	var/strikes_to_lose_limb = 3

	/// The current bandage we have for this wound (maybe move bandages to the limb?)
	var/obj/item/stack/current_bandage

// TODO: flesh out (haha flesh), also clean up all of this to be more modular and less sprawly
/datum/wound/burn/handle_process()
	. = ..()
	if(victim.reagents)
		if(victim.reagents.has_reagent(/datum/reagent/medicine/spaceacillin))
			sanitization += 0.4
		if(victim.reagents.has_reagent(/datum/reagent/space_cleaner/sterilizine/))
			sanitization += 0.4


	if(current_bandage)
		current_bandage.absorption_capacity -= WOUND_BURN_SANITIZATION_RATE
		if(current_bandage.absorption_capacity <= 0)
			victim.visible_message("<span class='danger'>Pus soaks through \the [current_bandage] on [victim]'s [limb.name].</span>", "<span class='warning'>Pus soaks through \the [current_bandage] on your [limb.name].</span>", vision_distance=COMBAT_MESSAGE_RANGE)
			QDEL_NULL(current_bandage)
			treat_priority = TRUE // todo: check if burns need this really

	if(flesh_healing > 0)
		var/bandage_factor = (current_bandage ? current_bandage.splint_factor : 1)
		flesh_damage = max(0, flesh_damage - min(1, flesh_healing))
		flesh_healing = max(0, flesh_healing - bandage_factor) // good bandages multiply the length of flesh healing

	if((flesh_damage <= 0) && (infestation <= 0) && (mortification <= 0))
		to_chat(victim, "<span class='green'>The burns on your [limb.name] have cleared up!</span>")
		qdel(src)
		return

	if(sanitization > 0)
		var/bandage_factor = (current_bandage ? current_bandage.splint_factor : 1)
		infestation = max(0, infestation - WOUND_BURN_SANITIZATION_RATE)
		sanitization = max(0, sanitization - (WOUND_BURN_SANITIZATION_RATE * bandage_factor))
		return

	infestation += infestation_rate

	// TODO: actual math on this stuff
	switch(infestation)
		if(0 to WOUND_INFECTION_MODERATE)
			if(mortification <= 0 && current_bandage)
				flesh_healing += 0.1
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
			else if(prob(1))
				to_chat(victim, "<span class='warning'>You contemplate life without your [limb.name]...</span>")
				victim.adjustToxLoss(0.75)
			else if(prob(4))
				victim.adjustToxLoss(1)
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

	var/condition = ""
	if(current_bandage)
		var/bandage_condition
		switch(current_bandage.absorption_capacity)
			if(0 to 1.25)
				bandage_condition = "nearly ruined "
			if(1.25 to 2.75)
				bandage_condition = "badly worn "
			if(2.75 to 4)
				bandage_condition = "slightly bloodied "
			if(4 to INFINITY)
				bandage_condition = "clean "

		condition += " underneath a dressing of [bandage_condition] [current_bandage.name]"
	else
		switch(infestation)
			if(WOUND_INFECTION_MODERATE to WOUND_INFECTION_SEVERE)
				condition += ", <span class='deadsay'>with discolored spots along the nearby veins!</span>"
			if(WOUND_INFECTION_SEVERE to WOUND_INFECTION_CRITICAL)
				condition += ", <span class='deadsay'>with dark clouds spreading outwards under the skin!</span>"
			if(WOUND_INFECTION_CRITICAL to WOUND_INFECTION_SEPTIC)
				condition += ", <span class='deadsay'>with streaks of rotten infection pulsating outward!</span>"
			if(WOUND_INFECTION_SEPTIC to INFINITY)
				return "<span class='deadsay'><B>[victim.p_their(TRUE)] [limb.name] is a mess of char and rot, skin literally dripping off the bone with infection!</B></span>"
			else
				condition += "!"

	return "<B>[victim.p_their(TRUE)] [limb.name] [examine_desc][condition]</B>"

/datum/wound/burn/get_scanner_description(mob/user)
	. = ..()
	// how much life we have left in these bandages
	. += "<div class='ml-3'>"
	switch(infestation)
		if(WOUND_INFECTION_MODERATE to WOUND_INFECTION_SEVERE)
			. += "Infection Level: Moderate\n"
		if(WOUND_INFECTION_SEVERE to WOUND_INFECTION_CRITICAL)
			. += "Infection Level: Severe\n"
		if(WOUND_INFECTION_CRITICAL to WOUND_INFECTION_SEPTIC)
			. += "Infection Level: <span class='deadsay'>CRITICAL</span>\n"
		if(WOUND_INFECTION_SEPTIC to INFINITY)
			. += "Infection Level: <span class='deadsay'>LOSS IMMINENT</span>\n"

	if(flesh_damage > 0)
		. += "Flesh damage detected: Please apply ointment or regenerative mesh to allow recovery.\n"

	if(mortification > 0)
		. += "Mortification detected: Please excise dead skin via debriding surgery. If desperate, dead skin can be shaved off by applying an aggressive hold and interacting helpfully with a sharp object on the affected limb."
	. += "</div>"

/*
	new burn common procs
*/

// TODO:actually balance ointment + regen mesh + bandages
/datum/wound/burn/proc/ointment(obj/item/stack/medical/ointment/I, mob/user)
	user.visible_message("<span class='notice'>[user] begins applying [I] to [victim]'s [limb.name]...</span>", "<span class='notice'>You begin applying [I] to [user == victim ? "your" : "[victim]'s"] [limb.name]...</span>")
	if(!do_after(user, (user == victim ? I.self_delay : I.other_delay), extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	limb.heal_damage(I.heal_brute, I.heal_burn)
	user.visible_message("<span class='green'>[user] applies [I] to [victim].</span>", "<span class='green'>You apply [I] to [user == victim ? "your" : "[victim]'s"] [limb.name].</span>")
	I.use(1)
	sanitization += I.sanitization
	flesh_healing += I.flesh_regeneration

	if((infestation <= 0 || sanitization >= infestation) && (flesh_damage <= 0 || flesh_healing > flesh_damage))
		to_chat(user, "<span class='notice'>You've done all you can with [I], now you must wait for the flesh on [victim]'s [limb.name] to recover.</span>")
	else
		try_treating(I, user)

/datum/wound/burn/proc/bandage(obj/item/stack/medical/gauze/I, mob/user)
	if(current_bandage)
		if(current_bandage.absorption_capacity > I.absorption_capacity + 1)
			to_chat(user, "<span class='warning'>The [current_bandage] on [victim]'s [limb.name] is still in better condition than your [I.name]!</span>")
			return
		user.visible_message("<span class='warning'>[user] begins to redress the burns on [victim]'s [limb.name] with [I]...</span>", "<span class='warning'>You begin redressing the burns on [user == victim ? "your" : "[victim]'s"] [limb.name] with [I]...</span>")
	else
		user.visible_message("<span class='notice'>[user] begins to dress the burns on [victim]'s [limb.name] with [I]...</span>", "<span class='notice'>You begin dressing the burns on [user == victim ? "your" : "[victim]'s"] [limb.name] with [I]...</span>")

	if(!do_after(user, (user == victim ? I.self_delay : I.other_delay), target=victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	user.visible_message("<span class='green'>[user] applies [I] to [victim].</span>", "<span class='green'>You apply [I] to [user == victim ? "your" : "[victim]'s"] [limb.name].</span>")
	QDEL_NULL(current_bandage)
	current_bandage = new I.type(limb)
	current_bandage.amount = 1
	treat_priority = FALSE
	I.use(1)
	sanitization += I.sanitization
	//TODO: slowdown infestation?

/datum/wound/burn/proc/mesh(obj/item/stack/medical/mesh/I, mob/user)
	user.visible_message("<span class='notice'>[user] begins wrapping [victim]'s [limb.name] with [I]...</span>", "<span class='notice'>You begin wrapping [user == victim ? "your" : "[victim]'s"] [limb.name] with [I]...</span>")
	if(!do_after(user, (user == victim ? I.self_delay : I.other_delay), target=victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	limb.heal_damage(I.heal_brute, I.heal_burn)
	user.visible_message("<span class='green'>[user] applies [I] to [victim].</span>", "<span class='green'>You apply [I] to [user == victim ? "your" : "[victim]'s"] [limb.name].</span>")
	I.use(1)
	sanitization += I.sanitization
	flesh_healing += I.flesh_regeneration

	if(sanitization >= infestation && flesh_healing > flesh_damage)
		to_chat(user, "<span class='notice'>You've done all you can with [I], now you must wait for the flesh on [victim]'s [limb.name] to recover.</span>")
	else
		try_treating(I, user)

/datum/wound/burn/proc/uv(obj/item/flashlight/pen/paramedic/I, mob/user)
	if(I.uv_cooldown > world.time)
		to_chat(user, "<span class='notice'>[I] is still recharging!</span>")
		return
	if(infestation <= 0 || infestation < sanitization)
		to_chat(user, "<span class='notice'>There's no infection to treat on [victim]'s [limb.name]!</span>")
		return

	user.visible_message("<span class='notice'>[user] flashes the burns on [victim]'s [limb] with [I].</span>", "<span class='notice'>You flash the burns on [user == victim ? "your" : "[victim]'s"] [limb.name] with [I].</span>", vision_distance=COMBAT_MESSAGE_RANGE)
	sanitization += I.uv_power
	I.uv_cooldown = world.time + I.uv_cooldown_length

/datum/wound/burn/proc/shave(obj/item/I, mob/user)
	if(mortification <= 0)
		to_chat(user, "<span class='notice'>There's no dead skin to shave from [victim]'s [limb.name]!</span>")
		return

	user.visible_message("<span class='danger'>[user] begins crudely carving away dead flesh from [victim]'s [limb.name] with [I].</span>", "<span class='notice'>You begin crudely carving dead flesh from [victim]'s [limb.name] with [I]...</span>", ignored_mobs=victim, vision_distance=COMBAT_MESSAGE_RANGE)
	to_chat(victim, "<span class='danger'><b>[user] begins crudely carving away dead flesh from your [limb.name] with [I]!</b></span>") // und ZATS how I lost my medical license!
	if(!do_after(user, base_treat_time * I.toolspeed, target=victim, extra_checks = CALLBACK(src, .proc/still_exists))) // TODO: be mean and make this a chance to fail, maybe increased success if they're drunk or unconscious
		return

	user.visible_message("<span class='danger'>[user] carves away some of the dead flesh from [victim]'s [limb.name]!</span>", "<span class='notice'>You carve away some of the dead flesh from [victim]'s [limb.name]!</span>", ignored_mobs=victim, vision_distance=COMBAT_MESSAGE_RANGE)
	to_chat(victim, "<span class='danger'><b>[user] crudely carves away some of the dead flesh from your [limb.name]!</b></span>")
	limb.receive_damage(brute=I.force, wound_bonus=CANT_WOUND) // i'll be very nice and not wound for now!
	victim.bleed(I.force) // not TOO nice though
	mortification = max(0, mortification - (I.force * 0.05)) // 12 force scalpel removes .6 mortification
	if(prob(60))
		victim.emote("scream")

	if(mortification > 0)
		try_treating(I, user)
	else
		to_chat(user, "<span class='green'>You've hacked away enough dead flesh from [victim]'s [limb.name] to let it recover.</span>")
		to_chat(victim, "<span class='green'>[user] finishes hacking enough dead flesh from your [limb.name] to let it recover.</span>")

/datum/wound/burn/treat(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/medical/gauze))
		bandage(I, user)
	else if(istype(I, /obj/item/stack/medical/ointment))
		ointment(I, user)
	else if(istype(I, /obj/item/stack/medical/mesh))
		mesh(I, user)
	else if(istype(I, /obj/item/flashlight/pen/paramedic))
		uv(I, user)
	else if(I.sharpness)
		shave(I, user)

/datum/wound/burn/proc/regenerate_flesh(amount)
	flesh_healing += amount * 0.5 // 20u patch will heal 10 flesh standard

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
	flesh_damage = 5
	scarring_descriptions = list("small amoeba-shaped skinmarks", "a faded streak of depressed skin")

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
	treatable_by = list(/obj/item/flashlight/pen/paramedic, /obj/item/stack/medical/gauze, /obj/item/stack/medical/ointment, /obj/item/stack/medical/mesh)
	infestation_rate = 0.05 // appx 13 minutes to reach sepsis without any treatment
	flesh_damage = 12.5
	treatable_sharp = TRUE
	mortification = 4
	scarring_descriptions = list("a large, jagged patch of faded skin", "random spots of shiny, smooth skin", "spots of taut, leathery skin")

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
	treatable_by = list(/obj/item/flashlight/pen/paramedic, /obj/item/stack/medical/gauze, /obj/item/stack/medical/ointment, /obj/item/stack/medical/mesh)
	infestation_rate = 0.1 // appx 6.66 minutes to reach sepsis without any treatment
	flesh_damage = 20
	treatable_sharp = TRUE
	mortification = 6
	scarring_descriptions = list("massive, disfiguring keloid scars", "several long streaks of badly discolored and malformed skin", "unmistakeable splotches of dead tissue from serious burns")
