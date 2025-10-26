
/*
	Burn wounds
*/

// TODO: well, a lot really, but specifically I want to add potential fusing of clothing/equipment on the affected area, and limb infections, though those may go in body part code
/datum/wound/burn
	name = "Burn Wound"
	undiagnosed_name = "Burns"
	a_or_from = "from"
	sound_effect = 'sound/effects/wounds/sizzle1.ogg'

/datum/wound/burn/flesh
	name = "Burn (Flesh) Wound"
	a_or_from = "from"
	processes = TRUE
	threshold_penalty = 15

	default_scar_file = FLESH_SCAR_FILE

	treatable_by = list(/obj/item/stack/medical/ointment, /obj/item/stack/medical/mesh) // sterilizer and alcohol will require reagent treatments, coming soon

	// Flesh damage vars
	/// How much damage to our flesh we currently have. Once both this and infestation reach 0, the wound is considered healed
	var/flesh_damage = 5
	/// Our current counter for how much flesh regeneration we have stacked from regenerative mesh/synthflesh/whatever, decrements each tick and lowers flesh_damage
	var/flesh_healing = 0

	// Infestation vars (only for severe and critical)
	/// How quickly infection breeds on this burn if we don't have disinfectant
	var/infestation_rate = 0
	/// Our current level of infection
	var/infestation = 0
	/// Our current level of sanitization/anti-infection, from disinfectants/alcohol/UV lights. While positive, totally pauses and slowly reverses infestation effects each tick
	var/sanitization = 0

	/// Once we reach infestation beyond WOUND_INFESTATION_SEPSIS, we get this many warnings before the limb is completely paralyzed (you'd have to ignore a really bad burn for a really long time for this to happen)
	var/strikes_to_lose_limb = 3

/datum/wound/burn/flesh/handle_process(seconds_per_tick, times_fired)

	if (!victim || HAS_TRAIT(victim, TRAIT_STASIS))
		return

	. = ..()
	if(strikes_to_lose_limb <= 0) // we've already hit sepsis, nothing more to do
		victim.adjustToxLoss(0.25 * seconds_per_tick)
		if(SPT_PROB(0.5, seconds_per_tick))
			victim.visible_message(span_danger("The infection on the remnants of [victim]'s [limb.plaintext_zone] shift and bubble nauseatingly!"), span_warning("You can feel the infection on the remnants of your [limb.plaintext_zone] coursing through your veins!"), vision_distance = COMBAT_MESSAGE_RANGE)
		return

	for(var/datum/reagent/reagent as anything in victim.reagents.reagent_list)
		if(reagent.chemical_flags & REAGENT_AFFECTS_WOUNDS)
			reagent.on_burn_wound_processing(src)

	if(HAS_TRAIT(victim, TRAIT_VIRUS_RESISTANCE))
		sanitization += 0.9
	if(HAS_TRAIT(victim, TRAIT_IMMUNODEFICIENCY))
		infestation += 0.05
		sanitization = max(sanitization - 0.15, 0)
		if(infestation_rate <= 0.15 && prob(50))
			infestation_rate += 0.001
	if(limb.current_gauze)
		limb.seep_gauze(WOUND_BURN_SANITIZATION_RATE * seconds_per_tick)

	if(flesh_healing > 0) // good bandages multiply the length of flesh healing
		var/bandage_factor = limb.current_gauze?.burn_cleanliness_bonus || 1
		flesh_damage = max(flesh_damage - (0.5 * seconds_per_tick), 0)
		flesh_healing = max(flesh_healing - (0.5 * bandage_factor * seconds_per_tick), 0) // good bandages multiply the length of flesh healing

	// if we have little/no infection, the limb doesn't have much burn damage, and our nutrition is good, heal some flesh
	if(infestation <= WOUND_INFECTION_MODERATE && (limb.burn_dam < 5) && (victim.nutrition >= NUTRITION_LEVEL_FED))
		flesh_healing += 0.2

	// here's the check to see if we're cleared up
	if((flesh_damage <= 0) && (infestation <= WOUND_INFECTION_MODERATE))
		to_chat(victim, span_green("The burns on your [limb.plaintext_zone] have cleared up!"))
		qdel(src)
		return

	// sanitization is checked after the clearing check but before the actual ill-effects, because we freeze the effects of infection while we have sanitization
	if(sanitization > 0)
		var/bandage_factor = limb.current_gauze?.burn_cleanliness_bonus || 1
		infestation = max(infestation - (WOUND_BURN_SANITIZATION_RATE * seconds_per_tick), 0)
		sanitization = max(sanitization - (WOUND_BURN_SANITIZATION_RATE * bandage_factor * seconds_per_tick), 0)
		return

	infestation += infestation_rate * seconds_per_tick
	switch(infestation)
		if(0 to WOUND_INFECTION_MODERATE)
			return

		if(WOUND_INFECTION_MODERATE to WOUND_INFECTION_SEVERE)
			if(SPT_PROB(15, seconds_per_tick))
				victim.adjustToxLoss(0.2)
				if(prob(6))
					to_chat(victim, span_warning("The blisters on your [limb.plaintext_zone] ooze a strange pus..."))

		if(WOUND_INFECTION_SEVERE to WOUND_INFECTION_CRITICAL)
			if(!disabling)
				if(SPT_PROB(1, seconds_per_tick))
					to_chat(victim, span_warning("<b>Your [limb.plaintext_zone] completely locks up, as you struggle for control against the infection!</b>"))
					set_disabling(TRUE)
					return
			else if(SPT_PROB(4, seconds_per_tick))
				to_chat(victim, span_notice("You regain sensation in your [limb.plaintext_zone], but it's still in terrible shape!"))
				set_disabling(FALSE)
				return

			if(SPT_PROB(10, seconds_per_tick))
				victim.adjustToxLoss(0.5)

		if(WOUND_INFECTION_CRITICAL to WOUND_INFECTION_SEPTIC)
			if(!disabling)
				if(SPT_PROB(1.5, seconds_per_tick))
					to_chat(victim, span_warning("<b>You suddenly lose all sensation of the festering infection in your [limb.plaintext_zone]!</b>"))
					set_disabling(TRUE)
					return
			else if(SPT_PROB(1.5, seconds_per_tick))
				to_chat(victim, span_notice("You can barely feel your [limb.plaintext_zone] again, and you have to strain to retain motor control!"))
				set_disabling(FALSE)
				return

			if(SPT_PROB(2.48, seconds_per_tick))
				if(prob(20))
					to_chat(victim, span_warning("You contemplate life without your [limb.plaintext_zone]..."))
					victim.adjustToxLoss(0.75)
				else
					victim.adjustToxLoss(1)

		if(WOUND_INFECTION_SEPTIC to INFINITY)
			if(SPT_PROB(0.5 * infestation, seconds_per_tick))
				strikes_to_lose_limb--
				switch(strikes_to_lose_limb)
					if(2 to INFINITY)
						to_chat(victim, span_deadsay("<b>The infection in your [limb.plaintext_zone] is literally dripping off, you feel horrible!</b>"))
					if(1)
						to_chat(victim, span_deadsay("<b>Infection has just about completely claimed your [limb.plaintext_zone]!</b>"))
					if(0)
						to_chat(victim, span_deadsay("<b>The last of the nerve endings in your [limb.plaintext_zone] wither away, as the infection completely paralyzes your joint connector.</b>"))
						threshold_penalty *= 2 // piss easy to destroy
						set_disabling(TRUE)

/datum/wound/burn/flesh/set_disabling(new_value)
	. = ..()
	if(new_value && strikes_to_lose_limb <= 0)
		treat_text_short = "Amputate or augment limb immediately, or place the patient into cryogenics."
	else
		treat_text_short = initial(treat_text_short)

/datum/wound/burn/flesh/get_wound_description(mob/user)
	if(strikes_to_lose_limb <= 0)
		return span_deadsay("<B>[victim.p_Their()] [limb.plaintext_zone] has locked up completely and is non-functional.</B>")

	var/list/condition = list("[victim.p_Their()] [limb.plaintext_zone] [examine_desc]")
	if(limb.current_gauze)
		var/bandage_condition
		switch(limb.current_gauze.absorption_capacity)
			if(0 to 1.25)
				bandage_condition = "nearly ruined"
			if(1.25 to 2.75)
				bandage_condition = "badly worn"
			if(2.75 to 4)
				bandage_condition = "slightly stained"
			if(4 to INFINITY)
				bandage_condition = "clean"

		condition += " underneath a dressing of [bandage_condition] [limb.current_gauze.name]."
	else
		switch(infestation)
			if(WOUND_INFECTION_MODERATE to WOUND_INFECTION_SEVERE)
				condition += ", [span_deadsay("with early signs of infection.")]"
			if(WOUND_INFECTION_SEVERE to WOUND_INFECTION_CRITICAL)
				condition += ", [span_deadsay("with growing clouds of infection.")]"
			if(WOUND_INFECTION_CRITICAL to WOUND_INFECTION_SEPTIC)
				condition += ", [span_deadsay("with streaks of rotten infection!")]"
			if(WOUND_INFECTION_SEPTIC to INFINITY)
				return span_deadsay("<B>[victim.p_Their()] [limb.plaintext_zone] is a mess of charred skin and infected rot!</B>")
			else
				condition += "!"

	return "<B>[condition.Join()]</B>"

/datum/wound/burn/flesh/severity_text(simple = FALSE)
	. = ..()
	. += " Burn / "
	switch(infestation)
		if(-INFINITY to WOUND_INFECTION_MODERATE)
			. += "No"
		if(WOUND_INFECTION_MODERATE to WOUND_INFECTION_SEVERE)
			. += "Moderate"
		if(WOUND_INFECTION_SEVERE to WOUND_INFECTION_CRITICAL)
			. += "<b>Severe</b>"
		if(WOUND_INFECTION_CRITICAL to WOUND_INFECTION_SEPTIC)
			. += "<b>Critical</b>"
		if(WOUND_INFECTION_SEPTIC to INFINITY)
			. += "<b>Total</b>"
	. += " Infection"

/datum/wound/burn/flesh/get_scanner_description(mob/user)
	if(strikes_to_lose_limb <= 0) // Unclear if it can go below 0, best to not take the chance
		var/oopsie = "Type: [name]<br>Severity: [severity_text()]"
		oopsie += "<div class='ml-3'>Infection Level: [span_deadsay("The body part has suffered complete sepsis and must be removed. Amputate or augment limb immediately, or place the patient in a cryotube.")]</div>"
		return oopsie

	. = ..()
	. += "<div class='ml-3'>"

	if(infestation <= sanitization && flesh_damage <= flesh_healing)
		. += "No further treatment required: Burns will heal shortly."
	else
		switch(infestation)
			if(WOUND_INFECTION_MODERATE to WOUND_INFECTION_SEVERE)
				. += "Infection Level: Moderate\n"
			if(WOUND_INFECTION_SEVERE to WOUND_INFECTION_CRITICAL)
				. += "Infection Level: Severe\n"
			if(WOUND_INFECTION_CRITICAL to WOUND_INFECTION_SEPTIC)
				. += "Infection Level: [span_deadsay("CRITICAL")]\n"
			if(WOUND_INFECTION_SEPTIC to INFINITY)
				. += "Infection Level: [span_deadsay("LOSS IMMINENT")]\n"
		if(infestation > sanitization)
			. += "\tSurgical debridement, antibiotics/sterilizers, or regenerative mesh will rid infection. Paramedic UV penlights are also effective.\n"

		if(flesh_damage > 0)
			. += "Flesh damage detected: Application of ointment, regenerative mesh, Synthflesh, or ingestion of \"Miner's Salve\" will repair damaged flesh. Good nutrition, rest, and keeping the wound clean can also slowly repair flesh.\n"
	. += "</div>"

/*
	new burn common procs
*/

/// Checks if the wound is in a state that ointment or flesh will help
/datum/wound/burn/flesh/proc/can_be_ointmented_or_meshed()
	if(infestation > 0 && sanitization < infestation)
		return TRUE
	if(flesh_damage > 0 && flesh_healing <= flesh_damage)
		return TRUE
	return FALSE

/// Paramedic UV penlights
/datum/wound/burn/flesh/proc/uv(obj/item/flashlight/pen/paramedic/I, mob/user)
	if(!COOLDOWN_FINISHED(I, uv_cooldown))
		to_chat(user, span_notice("[I] is still recharging!"))
		return TRUE
	if(infestation <= 0 || infestation < sanitization)
		to_chat(user, span_notice("There's no infection to treat on [victim]'s [limb.plaintext_zone]!"))
		return TRUE

	user.visible_message(span_notice("[user] flashes the burns on [victim]'s [limb] with [I]."), span_notice("You flash the burns on [user == victim ? "your" : "[victim]'s"] [limb.plaintext_zone] with [I]."), vision_distance=COMBAT_MESSAGE_RANGE)
	sanitization += I.uv_power
	COOLDOWN_START(I, uv_cooldown, I.uv_cooldown_length)
	return TRUE

/datum/wound/burn/flesh/treat(obj/item/I, mob/user)
	if(istype(I, /obj/item/flashlight/pen/paramedic))
		return uv(I, user)

// people complained about burns not healing on stasis beds, so in addition to checking if it's cured, they also get the special ability to very slowly heal on stasis beds if they have the healing effects stored
/datum/wound/burn/flesh/on_stasis(seconds_per_tick, times_fired)
	. = ..()
	if(strikes_to_lose_limb <= 0) // we've already hit sepsis, nothing more to do
		if(SPT_PROB(0.5, seconds_per_tick))
			victim.visible_message(span_danger("The infection on the remnants of [victim]'s [limb.plaintext_zone] shift and bubble nauseatingly!"), span_warning("You can feel the infection on the remnants of your [limb.plaintext_zone] coursing through your veins!"), vision_distance = COMBAT_MESSAGE_RANGE)
		return
	if(flesh_healing > 0)
		flesh_damage = max(flesh_damage - (0.1 * seconds_per_tick), 0)
	if((flesh_damage <= 0) && (infestation <= 1))
		to_chat(victim, span_green("The burns on your [limb.plaintext_zone] have cleared up!"))
		qdel(src)
		return
	if(sanitization > 0)
		infestation = max(infestation - (0.1 * WOUND_BURN_SANITIZATION_RATE * seconds_per_tick), 0)

/datum/wound/burn/flesh/on_synthflesh(reac_volume)
	flesh_healing += reac_volume * 0.5 // 20u patch will heal 10 flesh standard

/datum/wound_pregen_data/flesh_burn
	abstract = TRUE

	required_wounding_type = WOUND_BURN
	required_limb_biostate = BIO_FLESH

	wound_series = WOUND_SERIES_FLESH_BURN_BASIC

/datum/wound/burn/get_limb_examine_description()
	return span_warning("The flesh on this limb appears badly cooked.")

// we don't even care about first degree burns, straight to second
/datum/wound/burn/flesh/moderate
	name = "Second Degree Burns"
	desc = "Patient is suffering considerable burns with mild skin penetration, weakening limb integrity and increased burning sensations."
	treat_text = "Apply topical ointment or regenerative mesh to the wound."
	treat_text_short = "Apply healing aid such as regenerative mesh."
	examine_desc = "is badly burned and breaking out in blisters"
	occur_text = "breaks out with violent red burns"
	severity = WOUND_SEVERITY_MODERATE
	damage_multiplier_penalty = 1.1
	series_threshold_penalty = 30 // burns cause significant decrease in limb integrity compared to other wounds
	status_effect_type = /datum/status_effect/wound/burn/flesh/moderate
	flesh_damage = 5
	scar_keyword = "burnmoderate"

	simple_desc = "Patient's skin is burned, weakening the limb and multiplying perceived damage!"
	simple_treat_text = "Ointment will speed up recovery, as will regenerative mesh. Risk of infection is negligible."
	homemade_treat_text = "Healthy tea will speed up recovery. Salt, or preferably a salt-water mixture, will sanitize the wound, but the former will cause skin irritation, increasing the risk of infection."

/datum/wound_pregen_data/flesh_burn/second_degree
	abstract = FALSE

	wound_path_to_generate = /datum/wound/burn/flesh/moderate

	threshold_minimum = 40

/datum/wound/burn/flesh/severe
	name = "Third Degree Burns"
	desc = "Patient is suffering extreme burns with full skin penetration, creating serious risk of infection and greatly reduced limb integrity."
	treat_text = "Swiftly apply healing aids such as Synthflesh or regenerative mesh to the wound. \
		Disinfect the wound and surgically debride any infected skin, and wrap in clean gauze / use ointment to prevent further infection. \
		If the limb has locked up, it must be amputated, augmented or treated with cryogenics."
	treat_text_short = "Apply healing aid such as regenerative mesh, Synthflesh, or cryogenics and disinfect / debride. \
		Clean gauze or ointment will slow infection rate."
	examine_desc = "appears seriously charred, with aggressive red splotches"
	occur_text = "chars rapidly, exposing ruined tissue and spreading angry red burns"
	severity = WOUND_SEVERITY_SEVERE
	damage_multiplier_penalty = 1.2
	series_threshold_penalty = 40
	status_effect_type = /datum/status_effect/wound/burn/flesh/severe
	treatable_by = list(/obj/item/flashlight/pen/paramedic, /obj/item/stack/medical/ointment, /obj/item/stack/medical/mesh)
	infestation_rate = 0.07 // appx 9 minutes to reach sepsis without any treatment
	flesh_damage = 12.5
	scar_keyword = "burnsevere"

	simple_desc = "Patient's skin is badly burned, significantly weakening the limb and compounding further damage!!"
	simple_treat_text = "<b>Bandages will speed up recovery</b>, as will <b>ointment or regenerative mesh</b>. <b>Spaceacilin, sterilizine, and 'Miner's Salve'</b> will help with infection."
	homemade_treat_text = "<b>Healthy tea</b> will speed up recovery. <b>Salt</b>, or preferably a <b>salt-water</b> mixture, will sanitize the wound, but the former especially will cause skin irritation and dehydration, speeding up infection. <b>Space Cleaner</b> can be used as disinfectant in a pinch."

/datum/wound_pregen_data/flesh_burn/third_degree
	abstract = FALSE

	wound_path_to_generate = /datum/wound/burn/flesh/severe

	threshold_minimum = 80

/datum/wound/burn/flesh/critical
	name = "Catastrophic Burns"
	desc = "Patient is suffering near complete loss of tissue and significantly charred muscle and bone, creating life-threatening risk of infection and negligible limb integrity."
	treat_text = "Immediately apply healing aids such as Synthflesh or regenerative mesh to the wound. \
		Disinfect the wound and surgically debride any infected skin, and wrap in clean gauze / use ointment to prevent further infection. \
		If the limb has locked up, it must be amputated, augmented or treated with cryogenics."
	treat_text_short = "Apply healing aid such as regenerative mesh, Synthflesh, or cryogenics and disinfect / debride. \
		Clean gauze or ointment will slow infection rate."
	examine_desc = "is a ruined mess of blanched bone, melted fat, and charred tissue"
	occur_text = "vaporizes as flesh, bone, and fat melt together in a horrifying mess"
	severity = WOUND_SEVERITY_CRITICAL
	damage_multiplier_penalty = 1.3
	sound_effect = 'sound/effects/wounds/sizzle2.ogg'
	threshold_penalty = 25
	status_effect_type = /datum/status_effect/wound/burn/flesh/critical
	treatable_by = list(/obj/item/flashlight/pen/paramedic, /obj/item/stack/medical/ointment, /obj/item/stack/medical/mesh)
	infestation_rate = 0.075 // appx 4.33 minutes to reach sepsis without any treatment
	flesh_damage = 20
	scar_keyword = "burncritical"

	simple_desc = "Patient's skin is destroyed and tissue charred, leaving the limb with almost <b>no integrity<b> and a drastic chance of <b>infection<b>!!!"
	simple_treat_text = "Immediately <b>bandage</b> the wound and treat it with <b>ointment or regenerative mesh</b>. <b>Spaceacilin, sterilizine, or 'Miner's Salve'</b> will stave off infection. Seek professional care <b>immediately</b>, before sepsis sets in and the wound becomes untreatable."
	homemade_treat_text = "<b>Healthy tea</b> will help with recovery. A <b>salt-water mixture</b>, topically applied, might help stave off infection in the short term, but pure table salt is NOT recommended. <b>Space Cleaner</b> can be used as disinfectant in a pinch."

/datum/wound_pregen_data/flesh_burn/fourth_degree
	abstract = FALSE

	wound_path_to_generate = /datum/wound/burn/flesh/critical

	threshold_minimum = 140

///special severe wound caused by sparring interference or other god related punishments.
/datum/wound/burn/flesh/severe/brand
	name = "Holy Brand"
	desc = "Patient is suffering extreme burns from a strange brand marking, creating serious risk of infection and greatly reduced limb integrity."
	examine_desc = "appears to have holy symbols painfully branded into their flesh, leaving severe burns."
	occur_text = "chars rapidly into a strange pattern of holy symbols, burned into the flesh."

	simple_desc = "Patient's skin has had strange markings burned onto it, significantly weakening the limb and compounding further damage!!"

/datum/wound_pregen_data/flesh_burn/third_degree/holy
	abstract = FALSE
	can_be_randomly_generated = FALSE

	wound_path_to_generate = /datum/wound/burn/flesh/severe/brand
/// special severe wound caused by the cursed slot machine.

/datum/wound/burn/flesh/severe/cursed_brand
	name = "Ancient Brand"
	desc = "Patient is suffering extreme burns with oddly ornate brand markings, creating serious risk of infection and greatly reduced limb integrity."
	examine_desc = "appears to have ornate symbols painfully branded into their flesh, leaving severe burns"
	occur_text = "chars rapidly into a pattern that can only be described as an agglomeration of several financial symbols, burned into the flesh"

/datum/wound/burn/flesh/severe/cursed_brand/get_limb_examine_description()
	return span_warning("The flesh on this limb has several ornate symbols burned into it, with pitting throughout.")

/datum/wound_pregen_data/flesh_burn/third_degree/cursed_brand
	abstract = FALSE
	can_be_randomly_generated = FALSE

	wound_path_to_generate = /datum/wound/burn/flesh/severe/cursed_brand
