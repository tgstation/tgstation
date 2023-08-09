/obj/item/retractor
	name = "retractor"
	desc = "Retracts stuff."
	icon = 'icons/obj/medical/surgery_tools.dmi'
	icon_state = "retractor"
	inhand_icon_state = "retractor"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*3, /datum/material/glass =SHEET_MATERIAL_AMOUNT * 1.5)
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	w_class = WEIGHT_CLASS_TINY
	tool_behaviour = TOOL_RETRACTOR
	toolspeed = 1

/obj/item/retractor/augment
	desc = "Micro-mechanical manipulator for retracting stuff."
	toolspeed = 0.5


/obj/item/hemostat
	name = "hemostat"
	desc = "You think you have seen this before."
	icon = 'icons/obj/medical/surgery_tools.dmi'
	icon_state = "hemostat"
	inhand_icon_state = "hemostat"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	custom_materials = list(/datum/material/iron =SHEET_MATERIAL_AMOUNT * 2.5, /datum/material/glass = SHEET_MATERIAL_AMOUNT*1.25)
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	w_class = WEIGHT_CLASS_TINY
	attack_verb_continuous = list("attacks", "pinches")
	attack_verb_simple = list("attack", "pinch")
	tool_behaviour = TOOL_HEMOSTAT
	toolspeed = 1

/obj/item/hemostat/augment
	desc = "Tiny servos power a pair of pincers to stop bleeding."
	toolspeed = 0.5


/obj/item/cautery
	name = "cautery"
	desc = "This stops bleeding."
	icon = 'icons/obj/medical/surgery_tools.dmi'
	icon_state = "cautery"
	inhand_icon_state = "cautery"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*1.25, /datum/material/glass = SMALL_MATERIAL_AMOUNT*7.5)
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	w_class = WEIGHT_CLASS_TINY
	attack_verb_continuous = list("burns")
	attack_verb_simple = list("burn")
	tool_behaviour = TOOL_CAUTERY
	toolspeed = 1

/obj/item/cautery/ignition_effect(atom/ignitable_atom, mob/user)
	. = span_notice("[user] touches the end of [src] to \the [ignitable_atom], igniting it with a puff of smoke.")

/obj/item/cautery/augment
	desc = "A heated element that cauterizes wounds."
	toolspeed = 0.5

/obj/item/cautery/advanced
	name = "searing tool"
	desc = "It projects a high power laser used for medical applications."
	icon = 'icons/obj/medical/surgery_tools.dmi'
	icon_state = "e_cautery"
	inhand_icon_state = "e_cautery"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*2, /datum/material/glass =SHEET_MATERIAL_AMOUNT, /datum/material/plasma =SHEET_MATERIAL_AMOUNT, /datum/material/uranium = SHEET_MATERIAL_AMOUNT*1.5, /datum/material/titanium = SHEET_MATERIAL_AMOUNT*1.5)
	hitsound = 'sound/items/welder.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	toolspeed = 0.7
	light_system = MOVABLE_LIGHT
	light_range = 1
	light_color = COLOR_SOFT_RED

/obj/item/cautery/advanced/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/transforming, \
		force_on = force, \
		throwforce_on = throwforce, \
		hitsound_on = hitsound, \
		w_class_on = w_class, \
		clumsy_check = FALSE, \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Toggles between drill and cautery and gives feedback to the user.
 */
/obj/item/cautery/advanced/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	tool_behaviour = (active ? TOOL_DRILL : TOOL_CAUTERY)
	balloon_alert(user, "lenses set to [active ? "drill" : "mend"]")
	playsound(user ? user : src, 'sound/weapons/tap.ogg', 50, TRUE)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/cautery/advanced/examine()
	. = ..()
	. += span_notice("It's set to [tool_behaviour == TOOL_CAUTERY ? "mending" : "drilling"] mode.")

/obj/item/surgicaldrill
	name = "surgical drill"
	desc = "You can drill using this item. You dig?"
	icon = 'icons/obj/medical/surgery_tools.dmi'
	icon_state = "drill"
	inhand_icon_state = "drill"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	hitsound = 'sound/weapons/circsawhit.ogg'
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*5, /datum/material/glass = SHEET_MATERIAL_AMOUNT*3)
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	force = 15
	demolition_mod = 0.5
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("drills")
	attack_verb_simple = list("drill")
	tool_behaviour = TOOL_DRILL
	toolspeed = 1
	sharpness = SHARP_POINTY
	wound_bonus = 10
	bare_wound_bonus = 10

/obj/item/surgicaldrill/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/eyestab)

/obj/item/surgicaldrill/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] rams [src] into [user.p_their()] chest! It looks like [user.p_theyre()] trying to commit suicide!"))
	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living/carbon, gib), null, null, TRUE, TRUE), 25)
	user.SpinAnimation(3, 10)
	playsound(user, 'sound/machines/juicer.ogg', 20, TRUE)
	return MANUAL_SUICIDE

/obj/item/surgicaldrill/augment
	desc = "Effectively a small power drill contained within your arm. May or may not pierce the heavens."
	hitsound = 'sound/weapons/circsawhit.ogg'
	w_class = WEIGHT_CLASS_SMALL
	toolspeed = 0.5

/obj/item/scalpel
	name = "scalpel"
	desc = "Cut, cut, and once more cut."
	icon = 'icons/obj/medical/surgery_tools.dmi'
	icon_state = "scalpel"
	inhand_icon_state = "scalpel"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	force = 10
	demolition_mod = 0.25
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*2, /datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT)
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP_EDGED
	tool_behaviour = TOOL_SCALPEL
	toolspeed = 1
	wound_bonus = 10
	bare_wound_bonus = 15

/obj/item/scalpel/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
	speed = 8 SECONDS * toolspeed, \
	effectiveness = 100, \
	bonus_modifier = 0, \
	)
	AddElement(/datum/element/eyestab)

/obj/item/scalpel/augment
	desc = "Ultra-sharp blade attached directly to your bone for extra-accuracy."
	toolspeed = 0.5

/obj/item/scalpel/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is slitting [user.p_their()] [pick("wrists", "throat", "stomach")] with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/circular_saw
	name = "circular saw"
	desc = "For heavy duty cutting."
	icon = 'icons/obj/medical/surgery_tools.dmi'
	icon_state = "saw"
	inhand_icon_state = "saw"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	hitsound = 'sound/weapons/circsawhit.ogg'
	mob_throw_hit_sound = 'sound/weapons/pierce.ogg'
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	force = 15
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 9
	throw_speed = 2
	throw_range = 5
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*5, /datum/material/glass = SHEET_MATERIAL_AMOUNT*3)
	attack_verb_continuous = list("attacks", "slashes", "saws", "cuts")
	attack_verb_simple = list("attack", "slash", "saw", "cut")
	sharpness = SHARP_EDGED
	tool_behaviour = TOOL_SAW
	toolspeed = 1
	wound_bonus = 15
	bare_wound_bonus = 10

/obj/item/circular_saw/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
	speed = 4 SECONDS * toolspeed, \
	effectiveness = 100, \
	bonus_modifier = 5, \
	butcher_sound = 'sound/weapons/circsawhit.ogg', \
	)
	//saws are very accurate and fast at butchering

/obj/item/circular_saw/augment
	desc = "A small but very fast spinning saw. It rips and tears until it is done."
	w_class = WEIGHT_CLASS_SMALL
	toolspeed = 0.5


/obj/item/surgical_drapes
	name = "surgical drapes"
	desc = "Nanotrasen brand surgical drapes provide optimal safety and infection control."
	icon = 'icons/obj/medical/surgery_tools.dmi'
	icon_state = "surgical_drapes"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	inhand_icon_state = "drapes"
	w_class = WEIGHT_CLASS_TINY
	attack_verb_continuous = list("slaps")
	attack_verb_simple = list("slap")

/obj/item/surgical_drapes/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/surgery_initiator)

/obj/item/surgical_processor //allows medical cyborgs to scan and initiate advanced surgeries
	name = "surgical processor"
	desc = "A device for scanning and initiating surgeries from a disk or operating computer."
	icon = 'icons/obj/device.dmi'
	icon_state = "surgical_processor"
	item_flags = NOBLUDGEON
	// List of surgeries downloaded into the device.
	var/list/loaded_surgeries = list()
	// If a surgery has been downloaded in. Will cause the display to have a noticeable effect - helps to realize you forgot to load anything in.
	var/downloaded = TRUE

/obj/item/surgical_processor/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/surgery_initiator)

/obj/item/surgical_processor/examine(mob/user)
	. = ..()
	. += span_notice("Equip the processor in one of your active modules to access downloaded advanced surgeries.")
	. += span_boldnotice("Advanced surgeries available:")
	//list of downloaded surgeries' names
	var/list/surgeries_names = list()
	for(var/datum/surgery/downloaded_surgery as anything in loaded_surgeries)
		if(initial(downloaded_surgery.replaced_by) in loaded_surgeries) //if a surgery has a better version replacing it, we don't include it in the list
			continue
		surgeries_names += "[initial(downloaded_surgery.name)]"
	. += span_notice("[english_list(surgeries_names)]")

/obj/item/surgical_processor/equipped(mob/user, slot, initial)
	. = ..()
	if(!(slot & ITEM_SLOT_HANDS))
		UnregisterSignal(user, COMSIG_SURGERY_STARTING)
		return
	RegisterSignal(user, COMSIG_SURGERY_STARTING, PROC_REF(check_surgery))

/obj/item/surgical_processor/dropped(mob/user, silent)
	. = ..()
	UnregisterSignal(user, COMSIG_SURGERY_STARTING)

/obj/item/surgical_processor/cyborg_unequip(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_SURGERY_STARTING)

/obj/item/surgical_processor/afterattack(atom/design_holder, mob/user, proximity)
	if(!proximity)
		return ..()
	if(!istype(design_holder, /obj/item/disk/surgery) && !istype(design_holder, /obj/machinery/computer/operating))
		return ..()
	balloon_alert(user, "copying designs...")
	playsound(src, 'sound/machines/terminal_processing.ogg', 25, TRUE)
	if(do_after(user, 1 SECONDS, target = design_holder))
		if(istype(design_holder, /obj/item/disk/surgery))
			var/obj/item/disk/surgery/surgery_disk = design_holder
			loaded_surgeries |= surgery_disk.surgeries
		else
			var/obj/machinery/computer/operating/surgery_computer = design_holder
			loaded_surgeries |= surgery_computer.advanced_surgeries
		playsound(src, 'sound/machines/terminal_success.ogg', 25, TRUE)
		downloaded = TRUE
		update_appearance(UPDATE_OVERLAYS)
	return TRUE

/obj/item/surgical_processor/update_overlays()
	. = ..()
	if(downloaded)
		. += mutable_appearance(src.icon, "+downloaded")

/obj/item/surgical_processor/proc/check_surgery(mob/user, datum/surgery/surgery, mob/patient)
	SIGNAL_HANDLER

	if(surgery.replaced_by in loaded_surgeries)
		return COMPONENT_CANCEL_SURGERY
	if(surgery.type in loaded_surgeries)
		return COMPONENT_FORCE_SURGERY

/obj/item/scalpel/advanced
	name = "laser scalpel"
	desc = "An advanced scalpel which uses laser technology to cut."
	icon_state = "e_scalpel"
	inhand_icon_state = "e_scalpel"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*3, /datum/material/glass =HALF_SHEET_MATERIAL_AMOUNT * 1.5, /datum/material/silver =SHEET_MATERIAL_AMOUNT, /datum/material/gold =HALF_SHEET_MATERIAL_AMOUNT * 1.5, /datum/material/diamond =SMALL_MATERIAL_AMOUNT * 2, /datum/material/titanium = SHEET_MATERIAL_AMOUNT*2)
	hitsound = 'sound/weapons/blade1.ogg'
	force = 16
	w_class = WEIGHT_CLASS_NORMAL
	toolspeed = 0.7
	light_system = MOVABLE_LIGHT
	light_range = 1
	light_color = LIGHT_COLOR_BLUE
	sharpness = SHARP_EDGED

/obj/item/scalpel/advanced/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/transforming, \
		force_on = force + 1, \
		throwforce_on = throwforce, \
		throw_speed_on = throw_speed, \
		sharpness_on = sharpness, \
		hitsound_on = hitsound, \
		w_class_on = w_class, \
		clumsy_check = FALSE, \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Toggles between saw and scalpel and updates the light / gives feedback to the user.
 */
/obj/item/scalpel/advanced/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	if(active)
		tool_behaviour = TOOL_SAW
		set_light_range(2)
	else
		tool_behaviour = TOOL_SCALPEL
		set_light_range(1)

	balloon_alert(user, "[active ? "enabled" : "disabled"] bone-cutting mode")
	playsound(user ? user : src, 'sound/machines/click.ogg', 50, TRUE)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/scalpel/advanced/examine()
	. = ..()
	. += span_notice("It's set to [tool_behaviour == TOOL_SCALPEL ? "scalpel" : "saw"] mode.")

/obj/item/retractor/advanced
	name = "mechanical pinches"
	desc = "An agglomerate of rods and gears."
	icon = 'icons/obj/medical/surgery_tools.dmi'
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*6, /datum/material/glass = SHEET_MATERIAL_AMOUNT*2, /datum/material/silver = SHEET_MATERIAL_AMOUNT*2, /datum/material/titanium =SHEET_MATERIAL_AMOUNT * 2.5)
	icon_state = "adv_retractor"
	inhand_icon_state = "adv_retractor"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	toolspeed = 0.7

/obj/item/retractor/advanced/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/transforming, \
		force_on = force, \
		throwforce_on = throwforce, \
		hitsound_on = hitsound, \
		w_class_on = w_class, \
		clumsy_check = FALSE, \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Toggles between retractor and hemostat and gives feedback to the user.
 */
/obj/item/retractor/advanced/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	tool_behaviour = (active ? TOOL_HEMOSTAT : TOOL_RETRACTOR)
	balloon_alert(user, "gears set to [active ? "clamp" : "retract"]")
	playsound(user ? user : src, 'sound/items/change_drill.ogg', 50, TRUE)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/retractor/advanced/examine()
	. = ..()
	. += span_notice("It resembles a [tool_behaviour == TOOL_RETRACTOR ? "retractor" : "hemostat"].")

/obj/item/shears
	name = "amputation shears"
	desc = "A type of heavy duty surgical shears used for achieving a clean separation between limb and patient. Keeping the patient still is imperative to be able to secure and align the shears."
	icon = 'icons/obj/medical/surgery_tools.dmi'
	icon_state = "shears"
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	toolspeed = 1
	force = 12
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 6
	throw_speed = 2
	throw_range = 5
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*4, /datum/material/titanium=SHEET_MATERIAL_AMOUNT*3)
	attack_verb_continuous = list("shears", "snips")
	attack_verb_simple = list("shear", "snip")
	sharpness = SHARP_EDGED
	custom_premium_price = PAYCHECK_CREW * 14

/obj/item/shears/attack(mob/living/amputee, mob/living/user)
	if(!iscarbon(amputee) || user.combat_mode)
		return ..()

	if(user.zone_selected == BODY_ZONE_CHEST)
		return ..()

	var/mob/living/carbon/patient = amputee

	if(HAS_TRAIT(patient, TRAIT_NODISMEMBER))
		to_chat(user, span_warning("The patient's limbs look too sturdy to amputate."))
		return

	var/candidate_name
	var/obj/item/organ/external/tail_snip_candidate
	var/obj/item/bodypart/limb_snip_candidate

	if(user.zone_selected == BODY_ZONE_PRECISE_GROIN)
		tail_snip_candidate = patient.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
		if(!tail_snip_candidate)
			to_chat(user, span_warning("[patient] does not have a tail."))
			return
		candidate_name = tail_snip_candidate.name

	else
		limb_snip_candidate = patient.get_bodypart(check_zone(user.zone_selected))
		if(!limb_snip_candidate)
			to_chat(user, span_warning("[patient] is already missing that limb, what more do you want?"))
			return
		candidate_name = limb_snip_candidate.name

	var/amputation_speed_mod = 1

	patient.visible_message(span_danger("[user] begins to secure [src] around [patient]'s [candidate_name]."), span_userdanger("[user] begins to secure [src] around your [candidate_name]!"))
	playsound(get_turf(patient), 'sound/items/ratchet.ogg', 20, TRUE)
	if(patient.stat >= UNCONSCIOUS || HAS_TRAIT(patient, TRAIT_INCAPACITATED)) //if you're incapacitated (due to paralysis, a stun, being in staminacrit, etc.), critted, unconscious, or dead, it's much easier to properly line up a snip
		amputation_speed_mod *= 0.5
	if(patient.stat != DEAD && patient.has_status_effect(/datum/status_effect/jitter)) //jittering will make it harder to secure the shears, even if you can't otherwise move
		amputation_speed_mod *= 1.5 //15*0.5*1.5=11.25, so staminacritting someone who's jittering (from, say, a stun baton) won't give you enough time to snip their head off, but staminacritting someone who isn't jittering will

	if(do_after(user,  toolspeed * 15 SECONDS * amputation_speed_mod, target = patient))
		playsound(get_turf(patient), 'sound/weapons/bladeslice.ogg', 250, TRUE)
		if(user.zone_selected == BODY_ZONE_PRECISE_GROIN) //OwO
			tail_snip_candidate.Remove(patient)
			tail_snip_candidate.forceMove(get_turf(patient))
		else
			limb_snip_candidate.dismember()
		user.visible_message(span_danger("[src] violently slams shut, amputating [patient]'s [candidate_name]."), span_notice("You amputate [patient]'s [candidate_name] with [src]."))

	if(HAS_MIND_TRAIT(user, TRAIT_MORBID)) //Freak
		user.add_mood_event("morbid_dismemberment", /datum/mood_event/morbid_dismemberment)

/obj/item/shears/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] is pinching [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	var/timer = 1 SECONDS
	for(var/obj/item/bodypart/thing in user.bodyparts)
		if(thing.body_part == CHEST)
			continue
		addtimer(CALLBACK(thing, TYPE_PROC_REF(/obj/item/bodypart/, dismember)), timer)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), user, 'sound/weapons/bladeslice.ogg', 70), timer)
		timer += 1 SECONDS
	sleep(timer)
	return BRUTELOSS

/obj/item/bonesetter
	name = "bonesetter"
	desc = "For setting things right."
	icon = 'icons/obj/medical/surgery_tools.dmi'
	icon_state = "bonesetter"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	custom_materials = list(/datum/material/iron =SHEET_MATERIAL_AMOUNT * 2.5,  /datum/material/glass = SHEET_MATERIAL_AMOUNT*1.25, /datum/material/silver = SHEET_MATERIAL_AMOUNT*1.25)
	flags_1 = CONDUCT_1
	item_flags = SURGICAL_TOOL
	w_class = WEIGHT_CLASS_SMALL
	attack_verb_continuous = list("corrects", "properly sets")
	attack_verb_simple = list("correct", "properly set")
	tool_behaviour = TOOL_BONESET
	toolspeed = 1

/obj/item/blood_filter
	name = "blood filter"
	desc = "For filtering the blood."
	icon = 'icons/obj/medical/surgery_tools.dmi'
	icon_state = "bloodfilter"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT, /datum/material/glass=HALF_SHEET_MATERIAL_AMOUNT * 1.5, /datum/material/silver=SMALL_MATERIAL_AMOUNT*5)
	item_flags = SURGICAL_TOOL
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("pumps", "siphons")
	attack_verb_simple = list("pump", "siphon")
	tool_behaviour = TOOL_BLOODFILTER
	toolspeed = 1
	/// Assoc list of chem ids to names, used for deciding which chems to filter when used for surgery
	var/list/whitelist = list()

/obj/item/blood_filter/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BloodFilter", name)
		ui.open()

/obj/item/blood_filter/ui_data(mob/user)
	var/list/data = list()
	var/list/chem_names = list()
	for(var/key in whitelist)
		chem_names += whitelist[key]
	data["whitelist"] = chem_names
	return data

/obj/item/blood_filter/ui_act(action, params)
	. = ..()
	if(.)
		return
	. = TRUE
	switch(action)
		if("add")
			var/selected_reagent = tgui_input_list(usr, "Select reagent to filter", "Whitelist reagent", GLOB.chemical_name_list)
			if(!selected_reagent)
				return TRUE

			var/chem_id = get_chem_id(selected_reagent)
			if(!chem_id)
				return TRUE

			if(!(chem_id in whitelist))
				whitelist[chem_id] = selected_reagent



		if("remove")
			var/chem_name = params["reagent"]
			var/chem_id = get_chem_id(chem_name)
			whitelist -= chem_id

/*
 * Cruel Surgery Tools
 *
 * This variety of tool has the CRUEL_IMPLEMENT flag.
 *
 * Bonuses if the surgery is being done by a morbid user and it is of their interest.
 *
 * Morbid users are interested in; autospies, revival surgery, plastic surgery, organ/feature manipulations, amputations
 *
 * Otherwise, normal tool.
 */

/obj/item/retractor/cruel
	name = "twisted retractor"
	desc = "Helps reveal secrets that would rather stay buried."
	icon_state = "cruelretractor"
	item_flags = SURGICAL_TOOL | CRUEL_IMPLEMENT

/obj/item/hemostat/cruel
	name = "cruel hemostat"
	desc = "Clamping bleeders, but not so good at fixing breathers."
	icon_state = "cruelhemostat"
	item_flags = SURGICAL_TOOL | CRUEL_IMPLEMENT

/obj/item/cautery/cruel
	name = "savage cautery"
	desc = "Chalk this one up as another successful vivisection."
	icon_state = "cruelcautery"
	item_flags = SURGICAL_TOOL | CRUEL_IMPLEMENT

/obj/item/scalpel/cruel
	name = "hungry scalpel"
	desc = "I remember every time I hold you. My born companion..."
	icon_state = "cruelscalpel"
	item_flags = SURGICAL_TOOL | CRUEL_IMPLEMENT

/obj/item/scalpel/cruel/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/bane, mob_biotypes = MOB_UNDEAD, damage_multiplier = 1) //Just in case one of the tennants get uppity
