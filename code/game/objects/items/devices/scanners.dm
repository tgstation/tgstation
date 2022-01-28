
/*

CONTAINS:
T-RAY
HEALTH ANALYZER
GAS ANALYZER
SLIME SCANNER
GENE SCANNER

*/

// Describes the three modes of scanning available for health analyzers
#define SCANMODE_HEALTH 0
#define SCANMODE_WOUND 1
#define SCANMODE_COUNT 2 // Update this to be the number of scan modes if you add more
#define SCANNER_CONDENSED 0
#define SCANNER_VERBOSE 1

/obj/item/t_scanner
	name = "\improper T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	custom_price = PAYCHECK_ASSISTANT * 0.7
	icon = 'icons/obj/device.dmi'
	icon_state = "t-ray0"
	var/on = FALSE
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	custom_materials = list(/datum/material/iron=150)

/obj/item/t_scanner/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to emit terahertz-rays into [user.p_their()] brain with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return TOXLOSS

/obj/item/t_scanner/proc/toggle_on()
	on = !on
	icon_state = copytext_char(icon_state, 1, -1) + "[on]"
	if(on)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/t_scanner/attack_self(mob/user)
	toggle_on()

/obj/item/t_scanner/cyborg_unequip(mob/user)
	if(!on)
		return
	toggle_on()

/obj/item/t_scanner/process()
	if(!on)
		STOP_PROCESSING(SSobj, src)
		return null
	scan()

/obj/item/t_scanner/proc/scan()
	t_ray_scan(loc)

/proc/t_ray_scan(mob/viewer, flick_time = 8, distance = 3)
	if(!ismob(viewer) || !viewer.client)
		return
	var/list/t_ray_images = list()
	for(var/obj/O in orange(distance, viewer) )
		if(HAS_TRAIT(O, TRAIT_T_RAY_VISIBLE))
			var/image/I = new(loc = get_turf(O))
			var/mutable_appearance/MA = new(O)
			MA.alpha = 128
			MA.dir = O.dir
			I.appearance = MA
			t_ray_images += I
	if(t_ray_images.len)
		flick_overlay(t_ray_images, list(viewer.client), flick_time)

/obj/item/healthanalyzer
	name = "health analyzer"
	icon = 'icons/obj/device.dmi'
	icon_state = "health"
	inhand_icon_state = "healthanalyzer"
	worn_icon_state = "healthanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	desc = "A hand-held body scanner capable of distinguishing vital signs of the subject. Has a side button to scan for chemicals, and can be toggled to scan wounds."
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON | ITEM_HAS_CONTEXTUAL_SCREENTIPS
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=200)
	var/mode = SCANNER_VERBOSE
	var/scanmode = SCANMODE_HEALTH
	var/advanced = FALSE
	custom_price = PAYCHECK_HARD

/obj/item/healthanalyzer/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET, .proc/on_requesting_context_for_target)

/obj/item/healthanalyzer/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click [src] to toggle the limb damage readout.")

/obj/item/healthanalyzer/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to analyze [user.p_them()]self with [src]! The display shows that [user.p_theyre()] dead!"))
	return BRUTELOSS

/obj/item/healthanalyzer/attack_self(mob/user)
	scanmode = (scanmode + 1) % SCANMODE_COUNT
	switch(scanmode)
		if(SCANMODE_HEALTH)
			to_chat(user, span_notice("You switch the health analyzer to check physical health."))
		if(SCANMODE_WOUND)
			to_chat(user, span_notice("You switch the health analyzer to report extra info on wounds."))

/obj/item/healthanalyzer/attack(mob/living/M, mob/living/carbon/human/user)
	flick("[icon_state]-scan", src) //makes it so that it plays the scan animation upon scanning, including clumsy scanning

	// Clumsiness/brain damage check
	if ((HAS_TRAIT(user, TRAIT_CLUMSY) || HAS_TRAIT(user, TRAIT_DUMB)) && prob(50))
		user.visible_message(span_warning("[user] analyzes the floor's vitals!"), \
							span_notice("You stupidly try to analyze the floor's vitals!"))
		to_chat(user, "[span_info("Analyzing results for The floor:\n\tOverall status: <b>Healthy</b>")]\
				\n[span_info("Key: <font color='#00cccc'>Suffocation</font>/<font color='#00cc66'>Toxin</font>/<font color='#ffcc33'>Burn</font>/<font color='#ff3333'>Brute</font>")]\
				\n[span_info("\tDamage specifics: <font color='#66cccc'>0</font>-<font color='#00cc66'>0</font>-<font color='#ff9933'>0</font>-<font color='#ff3333'>0</font>")]\
				\n[span_info("Body temperature: ???")]")
		return

	if(ispodperson(M)&& !advanced)
		to_chat(user, "<span class='info'>[M]'s biological structure is too complex for the health analyzer.")
		return

	user.visible_message(span_notice("[user] analyzes [M]'s vitals."), \
						span_notice("You analyze [M]'s vitals."))

	switch (scanmode)
		if (SCANMODE_HEALTH)
			healthscan(user, M, mode, advanced)
		if (SCANMODE_WOUND)
			woundscan(user, M, src)

	add_fingerprint(user)

/obj/item/healthanalyzer/attack_secondary(mob/living/victim, mob/living/user, params)
	chemscan(user, victim)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/healthanalyzer/proc/on_requesting_context_for_target(
	datum/source,
	list/context,
	atom/target,
)
	SIGNAL_HANDLER

	if (!isliving(target))
		return

	switch (scanmode)
		if (SCANMODE_HEALTH)
			context[SCREENTIP_CONTEXT_LMB] = "Scan health"
		if (SCANMODE_WOUND)
			context[SCREENTIP_CONTEXT_LMB] = "Scan wounds"

	context[SCREENTIP_CONTEXT_RMB] = "Scan chemicals"

	return CONTEXTUAL_SCREENTIP_SET

// Used by the PDA medical scanner too
/proc/healthscan(mob/user, mob/living/target, mode = SCANNER_VERBOSE, advanced = FALSE)
	if(user.incapacitated())
		return

	if(user.is_blind())
		to_chat(user, span_warning("You realize that your scanner has no accessibility support for the blind!"))
		return

	// the final list of strings to render
	var/render_list = list()

	// Damage specifics
	var/oxy_loss = target.getOxyLoss()
	var/tox_loss = target.getToxLoss()
	var/fire_loss = target.getFireLoss()
	var/brute_loss = target.getBruteLoss()
	var/mob_status = (target.stat == DEAD ? span_alert("<b>Deceased</b>") : "<b>[round(target.health/target.maxHealth,0.01)*100]% healthy</b>")

	if(HAS_TRAIT(target, TRAIT_FAKEDEATH) && !advanced)
		mob_status = span_alert("<b>Deceased</b>")
		oxy_loss = max(rand(1, 40), oxy_loss, (300 - (tox_loss + fire_loss + brute_loss))) // Random oxygen loss

	render_list += "[span_info("Analyzing results for [target]:")]\n<span class='info ml-1'>Overall status: [mob_status]</span>\n"

	SEND_SIGNAL(target, COMSIG_LIVING_HEALTHSCAN, render_list, advanced, user, mode)

	if(ishuman(target))
		var/mob/living/carbon/human/humantarget = target
		if(humantarget.undergoing_cardiac_arrest() && humantarget.stat != DEAD)
			render_list += "<span class='alert ml-1'><b>Subject suffering from heart attack: Apply defibrillation or other electric shock immediately!</b></span>\n"
		if(humantarget.has_reagent(/datum/reagent/inverse/technetium))
			advanced = TRUE

	// Husk detection
	if(advanced && HAS_TRAIT_FROM(target, TRAIT_HUSK, BURN))
		render_list += "<span class='alert ml-1'>Subject has been husked by severe burns.</span>\n"
	else if (advanced && HAS_TRAIT_FROM(target, TRAIT_HUSK, CHANGELING_DRAIN))
		render_list += "<span class='alert ml-1'>Subject has been husked by dessication.</span>\n"
	else if(HAS_TRAIT(target, TRAIT_HUSK))
		render_list += "<span class='alert ml-1'>Subject has been husked.</span>\n"

	if(target.getStaminaLoss())
		if(advanced)
			render_list += "<span class='alert ml-1'>Fatigue level: [target.getStaminaLoss()]%.</span>\n"
		else
			render_list += "<span class='alert ml-1'>Subject appears to be suffering from fatigue.</span>\n"
	if (target.getCloneLoss())
		if(advanced)
			render_list += "<span class='alert ml-1'>Cellular damage level: [target.getCloneLoss()].</span>\n"
		else
			render_list += "<span class='alert ml-1'>Subject appears to have [target.getCloneLoss() > 30 ? "severe" : "minor"] cellular damage.</span>\n"
	if (!target.getorganslot(ORGAN_SLOT_BRAIN)) // kept exclusively for soul purposes
		render_list += "<span class='alert ml-1'>Subject lacks a brain.</span>\n"

	if(iscarbon(target))
		var/mob/living/carbon/carbontarget = target
		if(LAZYLEN(carbontarget.get_traumas()))
			var/list/trauma_text = list()
			for(var/datum/brain_trauma/trauma in carbontarget.get_traumas())
				var/trauma_desc = ""
				switch(trauma.resilience)
					if(TRAUMA_RESILIENCE_SURGERY)
						trauma_desc += "severe "
					if(TRAUMA_RESILIENCE_LOBOTOMY)
						trauma_desc += "deep-rooted "
					if(TRAUMA_RESILIENCE_WOUND)
						trauma_desc += "fracture-derived "
					if(TRAUMA_RESILIENCE_MAGIC, TRAUMA_RESILIENCE_ABSOLUTE)
						trauma_desc += "permanent "
				trauma_desc += trauma.scan_desc
				trauma_text += trauma_desc
			render_list += "<span class='alert ml-1'>Cerebral traumas detected: subject appears to be suffering from [english_list(trauma_text)].</span>\n"
		if(carbontarget.quirks.len)
			render_list += "<span class='info ml-1'>Subject Major Disabilities: [carbontarget.get_quirk_string(FALSE, CAT_QUIRK_MAJOR_DISABILITY)].</span>\n"
			if(advanced)
				render_list += "<span class='info ml-1'>Subject Minor Disabilities: [carbontarget.get_quirk_string(FALSE, CAT_QUIRK_MINOR_DISABILITY)].</span>\n"

	if (HAS_TRAIT(target, TRAIT_IRRADIATED))
		render_list += "<span class='alert ml-1'>Subject is irradiated. Supply toxin healing.</span>\n"

	if(advanced && target.hallucinating())
		render_list += "<span class='info ml-1'>Subject is hallucinating.</span>\n"

	//Eyes and ears
	if(advanced && iscarbon(target))
		var/mob/living/carbon/carbontarget = target

		// Ear status
		var/obj/item/organ/ears/ears = carbontarget.getorganslot(ORGAN_SLOT_EARS)
		if(istype(ears))
			if(HAS_TRAIT_FROM(carbontarget, TRAIT_DEAF, GENETIC_MUTATION))
				render_list = "<span class='alert ml-2'>Subject is genetically deaf.\n</span>"
			else if(HAS_TRAIT_FROM(carbontarget, TRAIT_DEAF, EAR_DAMAGE))
				render_list = "<span class='alert ml-2'>Subject is deaf from ear damage.\n</span>"
			else if(HAS_TRAIT(carbontarget, TRAIT_DEAF))
				render_list = "<span class='alert ml-2'>Subject is deaf.\n</span>"
			else
				if(ears.damage)
					render_list += "<span class='alert ml-2'>Subject has [ears.damage > ears.maxHealth ? "permanent ": "temporary "]hearing damage.\n</span>"
				if(ears.deaf)
					render_list += "<span class='alert ml-2'>Subject is [ears.damage > ears.maxHealth ? "permanently ": "temporarily "] deaf.\n</span>"

		// Eye status
		var/obj/item/organ/eyes/eyes = carbontarget.getorganslot(ORGAN_SLOT_EYES)
		if(istype(eyes))
			if(carbontarget.is_blind())
				render_list += "<span class='alert ml-2'>Subject is blind.\n</span>"
			else if(HAS_TRAIT(carbontarget, TRAIT_NEARSIGHT))
				render_list += "<span class='alert ml-2'>Subject is nearsighted.\n</span>"

	// Body part damage report
	if(iscarbon(target))
		var/mob/living/carbon/carbontarget = target
		var/list/damaged = carbontarget.get_damaged_bodyparts(1,1)
		if(length(damaged)>0 || oxy_loss>0 || tox_loss>0 || fire_loss>0)
			var/dmgreport = "<span class='info ml-1'>General status:</span>\
							<table class='ml-2'><tr><font face='Verdana'>\
							<td style='width:7em;'><font color='#ff0000'><b>Damage:</b></font></td>\
							<td style='width:5em;'><font color='#ff3333'><b>Brute</b></font></td>\
							<td style='width:4em;'><font color='#ff9933'><b>Burn</b></font></td>\
							<td style='width:4em;'><font color='#00cc66'><b>Toxin</b></font></td>\
							<td style='width:8em;'><font color='#00cccc'><b>Suffocation</b></font></td></tr>\
							<tr><td><font color='#ff3333'><b>Overall:</b></font></td>\
							<td><font color='#ff3333'><b>[CEILING(brute_loss,1)]</b></font></td>\
							<td><font color='#ff9933'><b>[CEILING(fire_loss,1)]</b></font></td>\
							<td><font color='#00cc66'><b>[CEILING(tox_loss,1)]</b></font></td>\
							<td><font color='#33ccff'><b>[CEILING(oxy_loss,1)]</b></font></td></tr>"

			if(mode == SCANNER_VERBOSE)
				for(var/obj/item/bodypart/limb as anything in damaged)
					dmgreport += "<tr><td><font color='#cc3333'>[capitalize(limb.name)]:</font></td>"
					dmgreport += "<td><font color='#cc3333'>[(limb.brute_dam > 0) ? "[CEILING(limb.brute_dam,1)]" : "0"]</font></td>"
					dmgreport += "<td><font color='#ff9933'>[(limb.burn_dam > 0) ? "[CEILING(limb.burn_dam,1)]" : "0"]</font></td></tr>"
			dmgreport += "</font></table>"
			render_list += dmgreport // tables do not need extra linebreak

	if(ishuman(target))
		var/mob/living/carbon/human/humantarget = target

		// Organ damage, missing organs
		if(humantarget.internal_organs && humantarget.internal_organs.len)
			var/render = FALSE
			var/toReport = "<span class='info ml-1'>Organs:</span>\
				<table class='ml-2'><tr>\
				<td style='width:6em;'><font color='#ff0000'><b>Organ:</b></font></td>\
				[advanced ? "<td style='width:3em;'><font color='#ff0000'><b>Dmg</b></font></td>" : ""]\
				<td style='width:12em;'><font color='#ff0000'><b>Status</b></font></td>"

			for(var/obj/item/organ/organ in humantarget.internal_organs)
				var/status = organ.get_status_text()
				if (status != "")
					render = TRUE
					toReport += "<tr><td><font color='#cc3333'>[organ.name]:</font></td>\
						[advanced ? "<td><font color='#ff3333'>[CEILING(organ.damage,1)]</font></td>" : ""]\
						<td>[status]</td></tr>"

			var/datum/species/the_dudes_species = humantarget.dna.species
			var/missing_organs = list()
			if(!humantarget.getorganslot(ORGAN_SLOT_BRAIN))
				missing_organs += "brain"
			if(!(NOBLOOD in the_dudes_species.species_traits) && !humantarget.getorganslot(ORGAN_SLOT_HEART))
				missing_organs += "heart"
			if(!(TRAIT_NOBREATH in the_dudes_species.species_traits) && !humantarget.getorganslot(ORGAN_SLOT_LUNGS))
				missing_organs += "lungs"
			if(!(TRAIT_NOMETABOLISM in the_dudes_species.species_traits) && !humantarget.getorganslot(ORGAN_SLOT_LIVER))
				missing_organs += "liver"
			if(!(NOSTOMACH in the_dudes_species.species_traits) && !humantarget.getorganslot(ORGAN_SLOT_STOMACH))
				missing_organs += "stomach"
			if(!humantarget.getorganslot(ORGAN_SLOT_EARS))
				missing_organs += "ears"
			if(!humantarget.getorganslot(ORGAN_SLOT_EYES))
				missing_organs += "eyes"

			if(length(missing_organs))
				render = TRUE
				for(var/organ in missing_organs)
					toReport += "<tr><td><font color='#cc3333'>[organ]:</font></td>\
						[advanced ? "<td><font color='#ff3333'>["-"]</font></td>" : ""]\
						<td><font color='#cc3333'>["Missing"]</font></td></tr>"

			if(render)
				render_list += toReport + "</table>" // tables do not need extra linebreak

		//Genetic stability
		if(advanced && humantarget.has_dna())
			render_list += "<span class='info ml-1'>Genetic Stability: [humantarget.dna.stability]%.</span>\n"

		// Species and body temperature
		var/datum/species/targetspecies = humantarget.dna.species
		var/mutant = humantarget.dna.check_mutation(HULK) \
			|| targetspecies.mutantlungs != initial(targetspecies.mutantlungs) \
			|| targetspecies.mutantbrain != initial(targetspecies.mutantbrain) \
			|| targetspecies.mutantheart != initial(targetspecies.mutantheart) \
			|| targetspecies.mutanteyes != initial(targetspecies.mutanteyes) \
			|| targetspecies.mutantears != initial(targetspecies.mutantears) \
			|| targetspecies.mutanthands != initial(targetspecies.mutanthands) \
			|| targetspecies.mutanttongue != initial(targetspecies.mutanttongue) \
			|| targetspecies.mutantliver != initial(targetspecies.mutantliver) \
			|| targetspecies.mutantstomach != initial(targetspecies.mutantstomach) \
			|| targetspecies.mutantappendix != initial(targetspecies.mutantappendix) \
			|| targetspecies.flying_species != initial(targetspecies.flying_species)

		render_list += "<span class='info ml-1'>Species: [targetspecies.name][mutant ? "-derived mutant" : ""]</span>\n"
		render_list += "<span class='info ml-1'>Core temperature: [round(humantarget.coretemperature-T0C,0.1)] &deg;C ([round(humantarget.coretemperature*1.8-459.67,0.1)] &deg;F)</span>\n"
	render_list += "<span class='info ml-1'>Body temperature: [round(target.bodytemperature-T0C,0.1)] &deg;C ([round(target.bodytemperature*1.8-459.67,0.1)] &deg;F)</span>\n"

	// Time of death
	if(target.tod && (target.stat == DEAD || ((HAS_TRAIT(target, TRAIT_FAKEDEATH)) && !advanced)))
		render_list += "<span class='info ml-1'>Time of Death: [target.tod]</span>\n"
		var/tdelta = round(world.time - target.timeofdeath)
		render_list += "<span class='alert ml-1'><b>Subject died [DisplayTimeText(tdelta)] ago.</b></span>\n"

	// Wounds
	if(iscarbon(target))
		var/mob/living/carbon/carbontarget = target
		var/list/wounded_parts = carbontarget.get_wounded_bodyparts()
		for(var/i in wounded_parts)
			var/obj/item/bodypart/wounded_part = i
			render_list += "<span class='alert ml-1'><b>Physical trauma[LAZYLEN(wounded_part.wounds) > 1 ? "s" : ""] detected in [wounded_part.name]</b>"
			for(var/k in wounded_part.wounds)
				var/datum/wound/W = k
				render_list += "<div class='ml-2'>[W.name] ([W.severity_text()])\nRecommended treatment: [W.treat_text]</div>" // less lines than in woundscan() so we don't overload people trying to get basic med info
			render_list += "</span>"

	//Diseases
	for(var/thing in target.diseases)
		var/datum/disease/D = thing
		if(!(D.visibility_flags & HIDDEN_SCANNER))
			render_list += "<span class='alert ml-1'><b>Warning: [D.form] detected</b>\n\
			<div class='ml-2'>Name: [D.name].\nType: [D.spread_text].\nStage: [D.stage]/[D.max_stages].\nPossible Cure: [D.cure_text]</div>\
			</span>" // divs do not need extra linebreak

	// Blood Level
	if(target.has_dna())
		var/mob/living/carbon/carbontarget = target
		var/blood_id = carbontarget.get_blood_id()
		if(blood_id)
			if(ishuman(carbontarget))
				var/mob/living/carbon/human/humantarget = carbontarget
				if(humantarget.is_bleeding())
					render_list += "<span class='alert ml-1'><b>Subject is bleeding!</b></span>\n"
			var/blood_percent = round((carbontarget.blood_volume / BLOOD_VOLUME_NORMAL)*100)
			var/blood_type = carbontarget.dna.blood_type
			if(blood_id != /datum/reagent/blood) // special blood substance
				var/datum/reagent/R = GLOB.chemical_reagents_list[blood_id]
				blood_type = R ? R.name : blood_id
			if(carbontarget.blood_volume <= BLOOD_VOLUME_SAFE && carbontarget.blood_volume > BLOOD_VOLUME_OKAY)
				render_list += "<span class='alert ml-1'>Blood level: LOW [blood_percent] %, [carbontarget.blood_volume] cl,</span> [span_info("type: [blood_type]")]\n"
			else if(carbontarget.blood_volume <= BLOOD_VOLUME_OKAY)
				render_list += "<span class='alert ml-1'>Blood level: <b>CRITICAL [blood_percent] %</b>, [carbontarget.blood_volume] cl,</span> [span_info("type: [blood_type]")]\n"
			else
				render_list += "<span class='info ml-1'>Blood level: [blood_percent] %, [carbontarget.blood_volume] cl, type: [blood_type]</span>\n"

	// Cybernetics
	if(iscarbon(target))
		var/mob/living/carbon/carbontarget = target
		var/cyberimp_detect
		for(var/obj/item/organ/cyberimp/CI in carbontarget.internal_organs)
			if(CI.status == ORGAN_ROBOTIC && !CI.syndicate_implant)
				cyberimp_detect += "[!cyberimp_detect ? "[CI.get_examine_string(user)]" : ", [CI.get_examine_string(user)]"]"
		if(cyberimp_detect)
			render_list += "<span class='notice ml-1'>Detected cybernetic modifications:</span>\n"
			render_list += "<span class='notice ml-2'>[cyberimp_detect]</span>\n"
	// we handled the last <br> so we don't need handholding
	to_chat(user, jointext(render_list, ""), trailing_newline = FALSE, type = MESSAGE_TYPE_INFO)

/proc/chemscan(mob/living/user, mob/living/target)
	if(user.incapacitated())
		return

	if(user.is_blind())
		to_chat(user, span_warning("You realize that your scanner has no accessibility support for the blind!"))
		return

	if(istype(target) && target.reagents)
		var/render_list = list()

		// Blood reagents
		if(target.reagents.reagent_list.len)
			render_list += "<span class='notice ml-1'>Subject contains the following reagents in their blood:</span>\n"
			for(var/r in target.reagents.reagent_list)
				var/datum/reagent/reagent = r
				if(reagent.chemical_flags & REAGENT_INVISIBLE) //Don't show hidden chems on scanners
					continue
				render_list += "<span class='notice ml-2'>[round(reagent.volume, 0.001)] units of [reagent.name][reagent.overdosed ? "</span> - [span_boldannounce("OVERDOSING")]" : ".</span>"]\n"
		else
			render_list += "<span class='notice ml-1'>Subject contains no reagents in their blood.</span>\n"

		// Stomach reagents
		var/obj/item/organ/stomach/belly = target.getorganslot(ORGAN_SLOT_STOMACH)
		if(belly)
			if(belly.reagents.reagent_list.len)
				render_list += "<span class='notice ml-1'>Subject contains the following reagents in their stomach:</span>\n"
				for(var/bile in belly.reagents.reagent_list)
					var/datum/reagent/bit = bile
					if(bit.chemical_flags & REAGENT_INVISIBLE) //Don't show hidden chems on scanners
						continue
					if(!belly.food_reagents[bit.type])
						render_list += "<span class='notice ml-2'>[round(bit.volume, 0.001)] units of [bit.name][bit.overdosed ? "</span> - [span_boldannounce("OVERDOSING")]" : ".</span>"]\n"
					else
						var/bit_vol = bit.volume - belly.food_reagents[bit.type]
						if(bit_vol > 0)
							render_list += "<span class='notice ml-2'>[round(bit_vol, 0.001)] units of [bit.name][bit.overdosed ? "</span> - [span_boldannounce("OVERDOSING")]" : ".</span>"]\n"
			else
				render_list += "<span class='notice ml-1'>Subject contains no reagents in their stomach.</span>\n"

		// Addictions
		if(LAZYLEN(target.mind?.active_addictions))
			render_list += "<span class='boldannounce ml-1'>Subject is addicted to the following types of drug:</span>\n"
			for(var/datum/addiction/addiction_type as anything in target.mind.active_addictions)
				render_list += "<span class='alert ml-2'>[initial(addiction_type.name)]</span>\n"

		// Special eigenstasium addiction
		if(target.has_status_effect(/datum/status_effect/eigenstasium))
			render_list += "<span class='notice ml-1'>Subject is temporally unstable. Stabilising agent is recommended to reduce disturbances.</span>\n"

		// Allergies
		for(var/datum/quirk/quirky as anything in target.quirks)
			if(istype(quirky, /datum/quirk/item_quirk/allergic))
				var/datum/quirk/item_quirk/allergic/allergies_quirk = quirky
				var/allergies = allergies_quirk.allergy_string
				render_list += "<span class='alert ml-1'>Subject is extremely allergic to the following chemicals:</span>\n"
				render_list += "<span class='alert ml-2'>[allergies]</span>\n"

		// we handled the last <br> so we don't need handholding
		to_chat(user, jointext(render_list, ""), trailing_newline = FALSE, type = MESSAGE_TYPE_INFO)

/obj/item/healthanalyzer/AltClick(mob/user)
	..()

	if(!user.canUseTopic(src, BE_CLOSE))
		return

	mode = !mode
	to_chat(user, mode == SCANNER_VERBOSE ? "The scanner now shows specific limb damage." : "The scanner no longer shows limb damage.")

/obj/item/healthanalyzer/advanced
	name = "advanced health analyzer"
	icon_state = "health_adv"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject with high accuracy."
	advanced = TRUE

/// Displays wounds with extended information on their status vs medscanners
/proc/woundscan(mob/user, mob/living/carbon/patient, obj/item/healthanalyzer/wound/scanner)
	if(!istype(patient) || user.incapacitated())
		return

	if(user.is_blind())
		to_chat(user, span_warning("You realize that your scanner has no accessibility support for the blind!"))
		return

	var/render_list = ""
	for(var/i in patient.get_wounded_bodyparts())
		var/obj/item/bodypart/wounded_part = i
		render_list += "<span class='alert ml-1'><b>Warning: Physical trauma[LAZYLEN(wounded_part.wounds) > 1? "s" : ""] detected in [wounded_part.name]</b>"
		for(var/k in wounded_part.wounds)
			var/datum/wound/W = k
			render_list += "<div class='ml-2'>[W.get_scanner_description()]</div>\n"
		render_list += "</span>"

	if(render_list == "")
		if(istype(scanner))
			// Only emit the cheerful scanner message if this scan came from a scanner
			playsound(scanner, 'sound/machines/ping.ogg', 50, FALSE)
			to_chat(user, span_notice("\The [scanner] makes a happy ping and briefly displays a smiley face with several exclamation points! It's really excited to report that [patient] has no wounds!"))
		else
			to_chat(user, "<span class='notice ml-1'>No wounds detected in subject.</span>")
	else
		to_chat(user, jointext(render_list, ""), type = MESSAGE_TYPE_INFO)

/obj/item/healthanalyzer/wound
	name = "first aid analyzer"
	icon_state = "adv_spectrometer"
	desc = "A prototype MeLo-Tech medical scanner used to diagnose injuries and recommend treatment for serious wounds, but offers no further insight into the patient's health. You hope the final version is less annoying to read!"
	var/next_encouragement
	var/greedy

/obj/item/healthanalyzer/wound/attack_self(mob/user)
	if(next_encouragement < world.time)
		playsound(src, 'sound/machines/ping.ogg', 50, FALSE)
		var/list/encouragements = list("briefly displays a happy face, gazing emptily at you", "briefly displays a spinning cartoon heart", "displays an encouraging message about eating healthy and exercising", \
				"reminds you that everyone is doing their best", "displays a message wishing you well", "displays a sincere thank-you for your interest in first-aid", "formally absolves you of all your sins")
		to_chat(user, span_notice("\The [src] makes a happy ping and [pick(encouragements)]!"))
		next_encouragement = world.time + 10 SECONDS
		greedy = FALSE
	else if(!greedy)
		to_chat(user, span_warning("\The [src] displays an eerily high-definition frowny face, chastizing you for asking it for too much encouragement."))
		greedy = TRUE
	else
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		if(isliving(user))
			var/mob/living/L = user
			to_chat(L, span_warning("\The [src] makes a disappointed buzz and pricks your finger for being greedy. Ow!"))
			L.adjustBruteLoss(4)
			L.dropItemToGround(src)

/obj/item/healthanalyzer/wound/attack(mob/living/carbon/patient, mob/living/carbon/human/user)
	add_fingerprint(user)
	user.visible_message(span_notice("[user] scans [patient] for serious injuries."), span_notice("You scan [patient] for serious injuries."))

	if(!istype(patient))
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
		to_chat(user, span_notice("\The [src] makes a sad buzz and briefly displays a frowny face, indicating it can't scan [patient]."))
		return

	woundscan(user, patient, src)

/obj/item/analyzer
	desc = "A hand-held environmental scanner which reports current gas levels. Alt-Click to use the built in barometer function."
	name = "gas analyzer"
	custom_price = PAYCHECK_ASSISTANT * 0.9
	icon = 'icons/obj/device.dmi'
	icon_state = "analyzer"
	inhand_icon_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	tool_behaviour = TOOL_ANALYZER
	custom_materials = list(/datum/material/iron=30, /datum/material/glass=20)
	grind_results = list(/datum/reagent/mercury = 5, /datum/reagent/iron = 5, /datum/reagent/silicon = 5)
	var/cooldown = FALSE
	var/cooldown_time = 250
	var/accuracy // 0 is the best accuracy.

/obj/item/analyzer/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click [src] to activate the barometer function.")

/obj/item/analyzer/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to analyze [user.p_them()]self with [src]! The display shows that [user.p_theyre()] dead!"))
	return BRUTELOSS

/obj/item/analyzer/attack_self(mob/user)
	add_fingerprint(user)

	if (user.stat || user.is_blind())
		return

	var/turf/location = user.loc
	if(!istype(location))
		return

	var/render_list = list()
	var/datum/gas_mixture/environment = location.return_air()
	var/pressure = environment.return_pressure()
	var/total_moles = environment.total_moles()

	render_list += "[span_info("<B>Results:</B>")]\
				\n<span class='[abs(pressure - ONE_ATMOSPHERE) < 10 ? "info" : "alert"]'>Pressure: [round(pressure, 0.01)] kPa</span>\n"
	if(total_moles)
		var/list/env_gases = environment.gases

		environment.assert_gases(arglist(GLOB.hardcoded_gases))
		var/o2_concentration = env_gases[/datum/gas/oxygen][MOLES]/total_moles
		var/n2_concentration = env_gases[/datum/gas/nitrogen][MOLES]/total_moles
		var/co2_concentration = env_gases[/datum/gas/carbon_dioxide][MOLES]/total_moles
		var/plasma_concentration = env_gases[/datum/gas/plasma][MOLES]/total_moles

		render_list += "<span class='[abs(n2_concentration - N2STANDARD) < 20 ? "info" : "alert"]'>Nitrogen: [round(n2_concentration*100, 0.01)] % ([round(env_gases[/datum/gas/nitrogen][MOLES], 0.01)] mol)</span>\
			\n<span class='[abs(o2_concentration - O2STANDARD) < 2 ? "info" : "alert"]'>Oxygen: [round(o2_concentration*100, 0.01)] % ([round(env_gases[/datum/gas/oxygen][MOLES], 0.01)] mol)</span>\
			\n<span class='[co2_concentration > 0.01 ? "alert" : "info"]'>CO2: [round(co2_concentration*100, 0.01)] % ([round(env_gases[/datum/gas/carbon_dioxide][MOLES], 0.01)] mol)</span>\
			\n<span class='[plasma_concentration > 0.005 ? "alert" : "info"]'>Plasma: [round(plasma_concentration*100, 0.01)] % ([round(env_gases[/datum/gas/plasma][MOLES], 0.01)] mol)</span>\n"

		environment.garbage_collect()

		for(var/id in env_gases)
			if(id in GLOB.hardcoded_gases)
				continue
			var/gas_concentration = env_gases[id][MOLES]/total_moles
			render_list += "[span_alert("[env_gases[id][GAS_META][META_GAS_NAME]]: [round(gas_concentration*100, 0.01)] % ([round(env_gases[id][MOLES], 0.01)] mol)")]\n"
		render_list += "[span_info("Temperature: [round(environment.temperature-T0C, 0.01)] &deg;C ([round(environment.temperature, 0.01)] K)")]\n"
	// we handled the last <br> so we don't need handholding
	to_chat(user, jointext(render_list, ""), trailing_newline = FALSE, type = MESSAGE_TYPE_INFO)

/obj/item/analyzer/AltClick(mob/user) //Barometer output for measuring when the next storm happens
	..()

	if(user.canUseTopic(src, BE_CLOSE))
		if(cooldown)
			to_chat(user, span_warning("[src]'s barometer function is preparing itself."))
			return

		var/turf/T = get_turf(user)
		if(!T)
			return

		playsound(src, 'sound/effects/pop.ogg', 100)
		var/area/user_area = T.loc
		var/datum/weather/ongoing_weather = null

		if(!user_area.outdoors)
			to_chat(user, span_warning("[src]'s barometer function won't work indoors!"))
			return

		for(var/V in SSweather.processing)
			var/datum/weather/W = V
			if(W.barometer_predictable && (T.z in W.impacted_z_levels) && W.area_type == user_area.type && !(W.stage == END_STAGE))
				ongoing_weather = W
				break

		if(ongoing_weather)
			if((ongoing_weather.stage == MAIN_STAGE) || (ongoing_weather.stage == WIND_DOWN_STAGE))
				to_chat(user, span_warning("[src]'s barometer function can't trace anything while the storm is [ongoing_weather.stage == MAIN_STAGE ? "already here!" : "winding down."]"))
				return

			to_chat(user, span_notice("The next [ongoing_weather] will hit in [butchertime(ongoing_weather.next_hit_time - world.time)]."))
			if(ongoing_weather.aesthetic)
				to_chat(user, span_warning("[src]'s barometer function says that the next storm will breeze on by."))
		else
			var/next_hit = SSweather.next_hit_by_zlevel["[T.z]"]
			var/fixed = next_hit ? timeleft(next_hit) : -1
			if(fixed < 0)
				to_chat(user, span_warning("[src]'s barometer function was unable to trace any weather patterns."))
			else
				to_chat(user, span_warning("[src]'s barometer function says a storm will land in approximately [butchertime(fixed)]."))
		cooldown = TRUE
		addtimer(CALLBACK(src,/obj/item/analyzer/proc/ping), cooldown_time)

/obj/item/analyzer/proc/ping()
	if(isliving(loc))
		var/mob/living/L = loc
		to_chat(L, span_notice("[src]'s barometer function is ready!"))
	playsound(src, 'sound/machines/click.ogg', 100)
	cooldown = FALSE

/obj/item/analyzer/proc/butchertime(amount)
	if(!amount)
		return
	if(accuracy)
		var/inaccurate = round(accuracy*(1/3))
		if(prob(50))
			amount -= inaccurate
		if(prob(50))
			amount += inaccurate
	return DisplayTimeText(max(1,amount))

/proc/atmosanalyzer_scan(mob/user, atom/target, silent=FALSE)
	var/mixture = target.return_analyzable_air()
	if(!mixture)
		return FALSE

	var/icon = target
	var/render_list = list()
	if(!silent && isliving(user))
		user.visible_message(span_notice("[user] uses the analyzer on [icon2html(icon, viewers(user))] [target]."), span_notice("You use the analyzer on [icon2html(icon, user)] [target]."))
	render_list += span_boldnotice("Results of analysis of [icon2html(icon, user)] [target].")

	var/list/airs = islist(mixture) ? mixture : list(mixture)
	for(var/g in airs)
		if(airs.len > 1) //not a unary gas mixture
			render_list += span_boldnotice("Node [airs.Find(g)]")
		var/datum/gas_mixture/air_contents = g

		var/total_moles = air_contents.total_moles()
		var/pressure = air_contents.return_pressure()
		var/volume = air_contents.return_volume() //could just do mixture.volume... but safety, I guess?
		var/temperature = air_contents.temperature
		var/cached_scan_results = air_contents.analyzer_results

		if(total_moles > 0)
			render_list += "[span_notice("Moles: [round(total_moles, 0.01)] mol")]\
							\n[span_notice("Volume: [volume] L")]\
							\n[span_notice("Pressure: [round(pressure,0.01)] kPa")]"

			var/list/cached_gases = air_contents.gases
			for(var/id in cached_gases)
				var/gas_concentration = cached_gases[id][MOLES]/total_moles
				render_list += span_notice("[cached_gases[id][GAS_META][META_GAS_NAME]]: [round(gas_concentration*100, 0.01)] % ([round(cached_gases[id][MOLES], 0.01)] mol)")
			render_list += span_notice("Temperature: [round(temperature - T0C,0.01)] &deg;C ([round(temperature, 0.01)] K)")
		else
			render_list += airs.len > 1 ? span_notice("This node is empty!") : span_notice("[target] is empty!")

		if(cached_scan_results && cached_scan_results["fusion"]) //notify the user if a fusion reaction was detected
			render_list += "[span_boldnotice("Large amounts of free neutrons detected in the air indicate that a fusion reaction took place.")]\
						\n[span_notice("Instability of the last fusion reaction: [round(cached_scan_results["fusion"], 0.01)].")]"
	// we let the join apply newlines so we do need handholding
	to_chat(user, jointext(render_list, "\n"), type = MESSAGE_TYPE_INFO)
	return TRUE

//slime scanner

/obj/item/slime_scanner
	name = "slime scanner"
	desc = "A device that analyzes a slime's internal composition and measures its stats."
	icon = 'icons/obj/device.dmi'
	icon_state = "adv_spectrometer"
	inhand_icon_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=30, /datum/material/glass=20)

/obj/item/slime_scanner/attack(mob/living/M, mob/living/user)
	if(user.stat || user.is_blind())
		return
	if (!isslime(M))
		to_chat(user, span_warning("This device can only scan slimes!"))
		return
	var/mob/living/simple_animal/slime/T = M
	slime_scan(T, user)

/proc/slime_scan(mob/living/simple_animal/slime/T, mob/living/user)
	var/to_render = "========================\
					\n<b>Slime scan results:</b>\
					\n[span_notice("[T.colour] [T.is_adult ? "adult" : "baby"] slime")]\
					\nNutrition: [T.nutrition]/[T.get_max_nutrition()]"
	if (T.nutrition < T.get_starve_nutrition())
		to_render += "\n[span_warning("Warning: slime is starving!")]"
	else if (T.nutrition < T.get_hunger_nutrition())
		to_render += "\n[span_warning("Warning: slime is hungry")]"
	to_render += "\nElectric change strength: [T.powerlevel]\nHealth: [round(T.health/T.maxHealth,0.01)*100]%"
	if (T.slime_mutation[4] == T.colour)
		to_render += "\nThis slime does not evolve any further."
	else
		if (T.slime_mutation[3] == T.slime_mutation[4])
			if (T.slime_mutation[2] == T.slime_mutation[1])
				to_render += "\nPossible mutation: [T.slime_mutation[3]]\
							  \nGenetic destability: [T.mutation_chance/2] % chance of mutation on splitting"
			else
				to_render += "\nPossible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]] (x2)\
							  \nGenetic destability: [T.mutation_chance] % chance of mutation on splitting"
		else
			to_render += "\nPossible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]], [T.slime_mutation[4]]\
						  \nGenetic destability: [T.mutation_chance] % chance of mutation on splitting"
	if (T.cores > 1)
		to_render += "\nMultiple cores detected"
	to_render += "\nGrowth progress: [T.amount_grown]/[SLIME_EVOLUTION_THRESHOLD]"
	if(T.effectmod)
		to_render += "\n[span_notice("Core mutation in progress: [T.effectmod]")]\
					  \n[span_notice("Progress in core mutation: [T.applied] / [SLIME_EXTRACT_CROSSING_REQUIRED]")]"
	to_chat(user, to_render + "\n========================")

/obj/item/sequence_scanner
	name = "genetic sequence scanner"
	icon = 'icons/obj/device.dmi'
	icon_state = "gene"
	inhand_icon_state = "healthanalyzer"
	worn_icon_state = "healthanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	desc = "A hand-held scanner for analyzing someones gene sequence on the fly. Hold near a DNA console to update the internal database."
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=200)
	var/list/discovered = list() //hit a dna console to update the scanners database
	var/list/buffer
	var/ready = TRUE
	var/cooldown = 200

/obj/item/sequence_scanner/attack(mob/living/M, mob/living/carbon/human/user)
	add_fingerprint(user)
	if (!HAS_TRAIT(M, TRAIT_GENELESS) && !HAS_TRAIT(M, TRAIT_BADDNA)) //no scanning if its a husk or DNA-less Species
		user.visible_message(span_notice("[user] analyzes [M]'s genetic sequence."), \
							span_notice("You analyze [M]'s genetic sequence."))
		gene_scan(M, user)

	else
		user.visible_message(span_notice("[user] fails to analyze [M]'s genetic sequence."), span_warning("[M] has no readable genetic sequence!"))

/obj/item/sequence_scanner/attack_self(mob/user)
	display_sequence(user)

/obj/item/sequence_scanner/attack_self_tk(mob/user)
	return

/obj/item/sequence_scanner/afterattack(obj/O, mob/user, proximity)
	. = ..()
	if(!istype(O) || !proximity)
		return

	if(istype(O, /obj/machinery/computer/scan_consolenew))
		var/obj/machinery/computer/scan_consolenew/C = O
		if(C.stored_research)
			to_chat(user, span_notice("[name] linked to central research database."))
			discovered = C.stored_research.discovered_mutations
		else
			to_chat(user,span_warning("No database to update from."))

/obj/item/sequence_scanner/proc/gene_scan(mob/living/carbon/C, mob/living/user)
	if(!iscarbon(C) || !C.has_dna())
		return
	buffer = C.dna.mutation_index
	to_chat(user, span_notice("Subject [C.name]'s DNA sequence has been saved to buffer."))
	if(LAZYLEN(buffer))
		for(var/A in buffer)
			to_chat(user, span_notice("[get_display_name(A)]"))


/obj/item/sequence_scanner/proc/display_sequence(mob/living/user)
	if(!LAZYLEN(buffer) || !ready)
		return
	var/list/options = list()
	for(var/A in buffer)
		options += get_display_name(A)

	var/answer = tgui_input_list(user, "Analyze Potential", "Sequence Analyzer", sort_list(options))
	if(isnull(answer))
		return
	if(ready && user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		var/sequence
		for(var/A in buffer) //this physically hurts but i dont know what anything else short of an assoc list
			if(get_display_name(A) == answer)
				sequence = buffer[A]
				break

		if(sequence)
			var/display
			for(var/i in 0 to length_char(sequence) / DNA_MUTATION_BLOCKS-1)
				if(i)
					display += "-"
				display += copytext_char(sequence, 1 + i*DNA_MUTATION_BLOCKS, DNA_MUTATION_BLOCKS*(1+i) + 1)

			to_chat(user, "[span_boldnotice("[display]")]<br>")

		ready = FALSE
		icon_state = "[icon_state]_recharging"
		addtimer(CALLBACK(src, .proc/recharge), cooldown, TIMER_UNIQUE)

/obj/item/sequence_scanner/proc/recharge()
	icon_state = initial(icon_state)
	ready = TRUE

/obj/item/sequence_scanner/proc/get_display_name(mutation)
	var/datum/mutation/human/HM = GET_INITIALIZED_MUTATION(mutation)
	if(!HM)
		return "ERROR"
	if(mutation in discovered)
		return  "[HM.name] ([HM.alias])"
	else
		return HM.alias

/obj/item/scanner_wand
	name = "kiosk scanner wand"
	icon = 'icons/obj/device.dmi'
	icon_state = "scanner_wand"
	inhand_icon_state = "healthanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	desc = "A wand for scanning someone else for a medical analysis. Insert into a kiosk is make the scanned patient the target of a health scan."
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	var/selected_target = null

/obj/item/scanner_wand/attack(mob/living/M, mob/living/carbon/human/user)
	flick("[icon_state]_active", src) //nice little visual flash when scanning someone else.

	if((HAS_TRAIT(user, TRAIT_CLUMSY) || HAS_TRAIT(user, TRAIT_DUMB)) && prob(25))
		user.visible_message(span_warning("[user] targets himself for scanning."), \
		to_chat(user, span_info("You try scanning [M], before realizing you're holding the scanner backwards. Whoops.")))
		selected_target = user
		return

	if(!ishuman(M))
		to_chat(user, span_info("You can only scan human-like, non-robotic beings."))
		selected_target = null
		return

	user.visible_message(span_notice("[user] targets [M] for scanning."), \
						span_notice("You target [M] vitals."))
	selected_target = M
	return

/obj/item/scanner_wand/attack_self(mob/user)
	to_chat(user, span_info("You clear the scanner's target."))
	selected_target = null

/obj/item/scanner_wand/proc/return_patient()
	var/returned_target = selected_target
	return returned_target

#undef SCANMODE_HEALTH
#undef SCANMODE_WOUND
#undef SCANMODE_COUNT
#undef SCANNER_CONDENSED
#undef SCANNER_VERBOSE
