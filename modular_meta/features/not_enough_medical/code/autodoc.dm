GLOBAL_LIST_INIT(autodoc_supported_surgery_steps, typecacheof(list(
	/datum/surgery_step/incise,
	/datum/surgery_step/clamp_bleeders,
	/datum/surgery_step/close,
	/datum/surgery_step/saw,
	/datum/surgery_step/sever_limb,
	/datum/surgery_step/heal,
	/datum/surgery_step/extract_implant,
	/datum/surgery_step/remove_fat,
	/datum/surgery_step/drill,
	/datum/surgery_step/retract_skin,
	/datum/surgery_step/fix_eyes,
	/datum/surgery_step/pacify,
	/datum/surgery_step/incise_heart,
	/datum/surgery_step/debride,
	/datum/surgery/brain_surgery, // Не вылечит дегенерата вроде тебя
	/datum/surgery_step/repair_bone_hairline,
	/datum/surgery/ear_surgery,
	/datum/surgery_step/gastrectomy,
	/datum/surgery_step/hepatectomy,
	/datum/surgery/repair_puncture,
	/datum/surgery_step/mechanic_open,
	/datum/surgery_step/mechanic_unwrench,
	/datum/surgery_step/prepare_electronics,
	/datum/surgery_step/mechanic_wrench,
	/datum/surgery_step/open_hatch,
	/datum/surgery_step/mechanic_close
)))

/proc/list_avg(list/L)
	. = 0
	for(var/num in L)
		. += num
	. /= length(L)
	LAZYCLEARLIST(L)

/obj/machinery/autodoc // Автодок - излечивает аутизм игроков сс220
	name = "autodoc"
	desc = "An automatic surgical complex specialized in restorative and modernizing operations."
	circuit = /obj/item/circuitboard/machine/autodoc
	icon = 'modular_meta/features/not_enough_medical/icons/64x64_autodoc.dmi'
	icon_state = "autodoc_base"
	density = FALSE
	anchored = TRUE
	layer = ABOVE_WINDOW_LAYER
	pixel_x = -16
	var/speed_mult = 1
	var/list/valid_surgeries = list()
	var/datum/surgery/target_surgery
	var/datum/surgery/active_surgery
	var/datum/surgery_step/active_step
	var/target_zone = "chest"
	var/in_use = FALSE
	var/caesar = FALSE
	var/message_cooldown = 0
	var/mutable_appearance/top_overlay

/obj/machinery/autodoc/examine(mob/user)
	. = ..()
	if(occupant)
		. += "<hr><span class='notice'>Inside is <b>[occupant]</b>.</span>"
		. += "<hr><span class='notice'><b>RMB</b> for quick extraction..</span>"
	. += "<hr><span class='notice'><b>Ctrl-Click</b>, to open internal storage.</span>"

/obj/machinery/autodoc/CanPass(atom/movable/mover, border_dir)
	if(border_dir == NORTH)
		return FALSE
	return ..()

/obj/machinery/autodoc/Initialize(mapload)
	. = ..()
	top_overlay = mutable_appearance(icon, "autodoc_top", ABOVE_MOB_LAYER)
	occupant_typecache = GLOB.typecache_living
	update_icon()
	for(var/datum/surgery/S in GLOB.surgeries_list)
		var/valid = TRUE
		if((ispath(S.replaced_by) && S.replaced_by != S.type) || !LAZYLEN(S.steps)) // the autodoc only uses the BEST versions of a surgery
			valid = FALSE
		else
			for(var/step in S.steps)
				if(!is_type_in_typecache(step, GLOB.autodoc_supported_surgery_steps))
					valid = FALSE
					break
		if(valid)
			valid_surgeries += S

/obj/machinery/autodoc/RefreshParts()
	. = ..()
	var/list/P = list()
	var/avg = 1
	for(var/obj/item/stock_parts/servo/M in component_parts)
		P += M.get_part_rating()
	avg = round(list_avg(P), 1)
	switch(avg)
		if(2)
			speed_mult = 0.75
		if(3)
			speed_mult = 0.5
		if(4)
			speed_mult = 0.25
		else
			speed_mult = 0.1

	//Энергопотребление (10к -> 7.5к -> 5к -> 2.5к -> 1к)
	var/Pwr = -1
	for(var/obj/item/stock_parts/capacitor/cap in component_parts)
		Pwr += cap.rating
	active_power_usage = initial(active_power_usage) - (initial(active_power_usage)*(Pwr))/4
	if(active_power_usage <= 1000)
		active_power_usage = 1000

/obj/machinery/autodoc/attack_hand_secondary(mob/user, modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	playsound(src, 'sound/machines/terminal/terminal_error.ogg', 50, FALSE)
	active_surgery.complete()
	active_surgery = null
	active_step = null
	in_use = FALSE
	if(!state_open)
		open_machine()
	update_icon()
	// START_PROCESSING(SSfastprocess, src)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/autodoc/ui_act(action, list/params)
	if(..())
		return
	switch(action)
		if("target")
			if(!in_use && (params["part"] in list(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)))
				target_zone = params["part"]
		if("surgery")
			if(!in_use)
				var/path = text2path(params["path"])
				for(var/datum/surgery/S in valid_surgeries)
					if((S.type == path) && S.possible_locs.Find(target_zone))
						target_surgery = S
						return
		if("start")
			INVOKE_ASYNC(src, PROC_REF(surgery_time), usr)

/obj/machinery/autodoc/Destroy()
	if(active_surgery)
		active_surgery.complete()
	open_machine()
	return ..()

/obj/machinery/autodoc/proc/mcdonalds(mob/living/carbon/victim)
	for(var/obj/item/bodypart/BP in victim.bodyparts)
		if(BP.body_part != HEAD && BP.body_part != CHEST && BP.can_dismember())
			playsound(src, pick(
		'sound/effects/changeling_absorb/changeling_absorb1.ogg',
		'sound/effects/changeling_absorb/changeling_absorb2.ogg',
		'sound/effects/changeling_absorb/changeling_absorb3.ogg',
		'sound/effects/changeling_absorb/changeling_absorb4.ogg',
		'sound/effects/changeling_absorb/changeling_absorb5.ogg',
		'sound/effects/changeling_absorb/changeling_absorb6.ogg',
		'sound/effects/changeling_absorb/changeling_absorb7.ogg',
		), 50, TRUE)
			BP.dismember()
			BP.forceMove(get_turf(src))
			BP.throw_at(get_edge_target_turf(src, pick(GLOB.alldirs)), INFINITY, 5, spin = TRUE)
			sleep(10)
	var/list/organs = list()
	for(var/obj/item/organ/OR in victim.organs)
		if(!istype(OR, /obj/item/organ/brain) && !istype(OR, /obj/item/organ/heart))
			organs += OR
	if(LAZYLEN(organs))
		var/obj/item/organ/O = pick(organs)
		O.Remove(victim)
		O.forceMove(get_turf(src))
		victim.emote("agony")
		O.throw_at(get_edge_target_turf(src, pick(GLOB.alldirs)), INFINITY, 5, spin = TRUE)
	// this is just a big ol' middle finger to the victim
	victim.adjust_slurring(30 SECONDS) // Превращение в кодера ыы220 лол
	victim.adjust_dizzy(30 SECONDS) // Превращение в кодера ыы220 лол
	victim.adjust_jitter(30 SECONDS) // Превращение в кодера ыы220 лол
	// victim.setOrganLoss(ORGAN_SLOT_BRAIN, max(135, victim.getOrganLoss(ORGAN_SLOT_BRAIN))) // Я надеюсь я ничего не сломаю этим
	say("SHAURMA IS COOKED! Switching to standard operating mode.")
	caesar = FALSE
	playsound(src, 'sound/items/weapons/circsawhit.ogg', 50, TRUE)

/obj/machinery/autodoc/proc/surgery_time(mob/living/doer)
	var/mob/living/carbon/patient
	if(in_use)
		say("Wait until the operation is complete.")
		playsound(src, 'sound/machines/terminal/terminal_error.ogg', 50, FALSE)
		return
	if(!target_surgery || !target_zone)
		say("Incorrect configuration.")
		playsound(src, 'sound/machines/terminal/terminal_error.ogg', 50, FALSE)
		if(!state_open)
			open_machine()
		return
	if(state_open)
		close_machine()
	update_icon()
	for(var/mob/living/carbon/C in src)
		patient = C
		break
	if(!patient)
		say("No patient found inside.")
		playsound(src, 'sound/machines/terminal/terminal_error.ogg', 50, FALSE)
		if(!state_open)
			open_machine()
		return
	var/obj/item/bodypart/affecting = patient.get_bodypart(check_zone(target_zone))
	if(affecting)
	// Я уверен на все 100 процентов что из-за выпиливания всех кусков кода чёто да отрыгнёт в процессе
		//if(!target_surgery.requires_bodypart)
		//	playsound(src, 'sound/machines/terminal/terminal_error.ogg', 50, FALSE)
		//	if(!state_open)
		//		open_machine()
		//	return
		if(target_surgery.requires_bodypart_type && IS_ORGANIC_LIMB(affecting) != target_surgery.requires_bodypart_type)
			say("It is impossible to perform surgery on this part of the body.")
			playsound(src, 'sound/machines/terminal/terminal_error.ogg', 50, FALSE)
			if(!state_open)
				open_machine()
			return
		//if(target_surgery.requires_real_bodypart && affecting.is_pseudopart)
		//	playsound(src, 'sound/machines/terminal/terminal_error.ogg', 50, FALSE)
		//	if(!state_open)
		//		open_machine()
		//	return
	//else if(patient && target_surgery.requires_bodypart) //mob with no limb in surgery zone when we need a limb
	//	playsound(src, 'sound/machines/terminal/terminal_error.ogg', 50, FALSE)
	//	if(!state_open)
	//		open_machine()
	//	return
	log_combat(doer, patient, "began [target_surgery] surgery", src)
	for(var/surgery_type in target_surgery.steps)
		var/datum/surgery_step/SS = new surgery_type
		if(!SS.autodoc_check(target_zone, src, FALSE, patient))
			qdel(SS)
			playsound(src, 'sound/machines/terminal/terminal_error.ogg', 50, FALSE)
			if(!state_open)
				open_machine()
			return
		qdel(SS)
	in_use = TRUE
	update_icon()
	active_surgery = new target_surgery.type(patient, target_zone, affecting)
	while(active_surgery.status <= active_surgery.steps.len)
		if(caesar)
			say("LET'S CREATE SHAURMA!")
			mcdonalds(patient)
			break
		var/datum/surgery_step/next_step = active_surgery.get_surgery_next_step()
		if(!next_step)
			break
		active_step = next_step
		active_surgery.step_in_progress = TRUE
		active_surgery.status++
		if(next_step.repeatable || next_step.ad_repeatable)
			while(next_step.autodoc_check(target_zone, src, TRUE, patient))
				sleep((next_step.time * speed_mult) / 2)
				playsound(src, 'sound/items/weapons/circsawhit.ogg', 50, TRUE)
				sleep((next_step.time * speed_mult) / 2)
				playsound(src, 'sound/items/weapons/circsawhit.ogg', 50, TRUE)
				next_step.autodoc_success(patient, target_zone, active_surgery, src)
		else
			sleep((next_step.time * speed_mult) / 2)
			playsound(src, 'sound/items/weapons/circsawhit.ogg', 50, TRUE)
			sleep((next_step.time * speed_mult) / 2)
			playsound(src, 'sound/items/weapons/circsawhit.ogg', 50, TRUE)
			next_step.autodoc_success(patient, target_zone, active_surgery, src)
		active_surgery.step_in_progress = FALSE
	active_surgery.complete()
	active_surgery = null
	active_step = null
	in_use = FALSE
	if(!state_open)
		open_machine()
	update_icon()
	use_energy(active_power_usage)

/obj/machinery/autodoc/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Autodoc", name)
		ui.open()

/obj/machinery/autodoc/ui_data(mob/user)
	. = list()
	if(in_use)
		.["mode"] = 2
		.["s_name"] = target_surgery.name
		.["steps"] = list()
		for(var/s in target_surgery.steps)
			var/datum/surgery_step/S = s
			.["steps"] += list(list(
				"name" = initial(S.name),
				"current" = active_step ? (active_step.type == s) : FALSE
			))
	else
		.["mode"] = 1
		.["target"] = target_zone
		.["surgeries"] = list()
		for(var/datum/surgery/S in valid_surgeries)
			if(S.possible_locs.Find(target_zone))
				.["surgeries"] += list(list(
					"name" = S.name,
					"selected" = (S == target_surgery),
					"path" = "[S.type]",
				))
/obj/machinery/autodoc/mouse_drop_dragged(atom/target, mob/user)
	if(!QDELETED(occupant) && istype(occupant))
		return
	// Господи да сьебись ты нахуй а хотя стоп похуй
	//if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK) || !Adjacent(target) || !user.Adjacent(target) || !iscarbon(target))
	//	return
	if(close_machine(target))
		log_combat(user, target, "inserted", null, "into [src].")
	add_fingerprint(user)
/obj/machinery/autodoc/emag_act(mob/user)
	if(caesar)
		to_chat(user, span_notice("<b>[src]</b> already hacked!"))
		return
	log_combat(user, src, "emagged")
	to_chat(user, span_notice("Turn on the shaurma mode in <b>[src]</b>."))
	add_fingerprint(user)
	caesar = TRUE

/obj/machinery/autodoc/update_icon()
	. = ..()
	cut_overlays()
	add_overlay(top_overlay)
	if(!(machine_stat & (NOPOWER|BROKEN)))
		if(in_use)
			add_overlay("auto_doc_lights_working")
		else
			add_overlay("auto_doc_lights_on")
	if(occupant)
		add_overlay("autodoc_door_closed")
	else
		add_overlay("autodoc_door_open")

/obj/machinery/autodoc/proc/toggle_open(mob/user)
	if(panel_open)
		to_chat(user, span_notice("The panel is open and does not allow the doors to close."))
		return
	if(state_open)
		close_machine(null, user)
		return
	else if(in_use)
		to_chat(user, span_notice("Can't open the door. It looks like you need to wait for the operation to complete."))
		return
	open_machine()

/obj/machinery/autodoc/open_machine()
	if(state_open)
		return FALSE
	..(FALSE)
	if(occupant)
		occupant.forceMove(get_turf(src))
	update_icon()
	return TRUE

/obj/machinery/autodoc/relaymove(mob/user as mob)
	if(user.stat || in_use)
		if(message_cooldown <= world.time)
			message_cooldown = world.time + 50
			to_chat(user, span_warning("Door <b>[src]</b> does not open!"))
		return
	open_machine()


/obj/item/circuitboard/machine/autodoc
	name = "Autodoc"
	greyscale_colors = CIRCUIT_COLOR_MEDICAL
	build_path = /obj/machinery/autodoc
	req_components = list(
							/obj/item/stock_parts/capacitor = 5,
							/obj/item/stock_parts/scanning_module = 5,
							/obj/item/stock_parts/servo = 5,
							/obj/item/stock_parts/micro_laser = 5,
							/obj/item/scalpel/advanced = 1,
							/obj/item/retractor/advanced = 1,
							/obj/item/surgicaldrill = 1,
							/obj/item/bonesetter = 1,
							/obj/item/blood_filter = 1,
							/obj/item/stack/sheet/glass = 15)

/datum/design/board/autodoc
	name = "Autodoc"
	desc = "An automatic surgical complex specialized in restorative and modernizing operations."
	id = "autodoc"
	build_path = /obj/item/circuitboard/machine/autodoc
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/surgery_step/incise/autodoc_success(mob/living/carbon/target, target_zone, datum/surgery/surgery, obj/machinery/autodoc/autodoc)
	if ishuman(target)
		var/mob/living/carbon/human/human_target = target
		if (!HAS_TRAIT(human_target, TRAIT_NOBLOOD))
			var/obj/item/bodypart/target_bodypart = target.get_bodypart(target_zone)
			if(target_bodypart)
				target_bodypart.adjustBleedStacks(10)
	return TRUE

/datum/surgery_step/clamp_bleeders/autodoc_success(mob/living/carbon/target, target_zone, datum/surgery/surgery, obj/machinery/autodoc/autodoc)
	if(locate(/datum/surgery_step/saw) in surgery.steps)
		target.heal_bodypart_damage(20, 0, target_zone = target_zone)
	if (ishuman(target))
		var/mob/living/carbon/human/human_target = target
		var/obj/item/bodypart/target_bodypart = human_target.get_bodypart(target_zone)
		if(target_bodypart)
			target_bodypart.adjustBleedStacks(-3)
	return TRUE

/datum/surgery_step/close/autodoc_success(mob/living/carbon/target, target_zone, datum/surgery/surgery, obj/machinery/autodoc/autodoc)
	if(locate(/datum/surgery_step/saw) in surgery.steps)
		target.heal_bodypart_damage(45, 0, target_zone = target_zone)
	if (ishuman(target))
		var/mob/living/carbon/human/human_target = target
		var/obj/item/bodypart/target_bodypart = human_target.get_bodypart(target_zone)
		if(target_bodypart)
			target_bodypart.adjustBleedStacks(-3)
	return TRUE

/datum/surgery_step/saw/autodoc_success(mob/living/carbon/target, target_zone, datum/surgery/surgery, obj/machinery/autodoc/autodoc)
	target.apply_damage(50, BRUTE, "[target_zone]")
	return TRUE

/datum/surgery_step/sever_limb/autodoc_success(mob/living/carbon/target, target_zone, datum/surgery/surgery, obj/machinery/autodoc/autodoc)
	if(surgery.operated_bodypart)
		var/obj/item/bodypart/target_limb = surgery.operated_bodypart
		target_limb.drop_limb()
		target_limb.forceMove(get_turf(autodoc))
		autodoc.visible_message(span_notice("<b>[autodoc]</b> выплёвывает <b>[target_limb]</b>!"))
	return TRUE

/datum/surgery_step/heal/autodoc_success(mob/living/carbon/target, target_zone, datum/surgery/surgery, obj/machinery/autodoc/autodoc)
	target.heal_bodypart_damage(brutehealing,burnhealing)
	return TRUE

/datum/surgery_step/extract_implant/autodoc_success(mob/living/carbon/target, target_zone, datum/surgery/surgery, obj/machinery/autodoc/autodoc)

	if(implant)
		display_pain(target, "You can feel your [implant.name] pulled out of you!")
		implant.removed(target)

		if (QDELETED(implant))
			return ..()

		var/obj/item/implantcase/case
		for(var/obj/item/implantcase/implant_case in target.held_items)
			case = implant_case
			break
		if(!case)
			case = locate(/obj/item/implantcase) in get_turf(target)
		if(case && !case.imp)
			case.imp = implant
			implant.forceMove(case)
			case.update_appearance()
		else
			qdel(implant)

	else
		return FALSE // Я хз чё будет нахуй
	return TRUE

/datum/surgery_step/remove_fat/autodoc_success(mob/living/carbon/target, target_zone, datum/surgery/surgery, obj/machinery/autodoc/autodoc)
	target.overeatduration = 0 //patient is unfatted
	var/removednutriment = target.nutrition
	target.set_nutrition(NUTRITION_LEVEL_WELL_FED)
	removednutriment -= NUTRITION_LEVEL_WELL_FED //whatever was removed goes into the meat
	var/mob/living/carbon/human/human = target
	var/typeofmeat = /obj/item/food/meat/slab/human

	if(target.flags_1 & HOLOGRAM_1)
		typeofmeat = null
	else if(human.dna && human.dna.species)
		typeofmeat = human.dna.species.meat

	if(typeofmeat)
		var/obj/item/food/meat/slab/human/newmeat = new typeofmeat
		newmeat.name = "fatty meat"
		newmeat.desc = "Extremely fatty tissue taken from a patient."
		newmeat.subjectname = human.real_name
		newmeat.subjectjob = human.job
		newmeat.reagents.add_reagent (/datum/reagent/consumable/nutriment, (removednutriment / 15)) //To balance with nutriment_factor of nutriment
		newmeat.forceMove(target.loc)
	return TRUE

/datum/surgery_step/fix_eyes/autodoc_success(mob/living/carbon/target, target_zone, datum/surgery/surgery, obj/machinery/autodoc/autodoc)
	var/obj/item/organ/eyes/target_eyes = target.get_organ_slot(ORGAN_SLOT_EYES)
	target.remove_status_effect(/datum/status_effect/temporary_blindness)
	target.set_eye_blur_if_lower(70 SECONDS) //this will fix itself slowly.
	target_eyes.set_organ_damage(0) // heals nearsightedness and blindness from eye damage
	return TRUE

/datum/surgery_step/heal/autodoc_check(target_zone, obj/machinery/autodoc/autodoc, silent, mob/living/carbon/target)
	if(target && !(brutehealing && target.getBruteLoss()) && !(burnhealing && target.getFireLoss()))
		return FALSE
	return TRUE

/datum/surgery_step/pacify/autodoc_success(mob/living/carbon/target, target_zone, datum/surgery/surgery, obj/machinery/autodoc/autodoc)
	display_pain(target, "Your head pounds... the concept of violence flashes in your head, and nearly makes you hurl!")
	target.gain_trauma(/datum/brain_trauma/severe/pacifism, TRAUMA_RESILIENCE_LOBOTOMY)
	return TRUE

/datum/surgery_step/incise_heart/autodoc_success(mob/living/carbon/target, target_zone, datum/surgery/surgery, obj/machinery/autodoc/autodoc)
	if(ishuman(target))
		var/mob/living/carbon/human/target_human = target
		if (!HAS_TRAIT(target_human, TRAIT_NOBLOOD))
			var/obj/item/bodypart/target_bodypart = target_human.get_bodypart(target_zone)
			target_bodypart.adjustBleedStacks(10)
			target_human.adjustBruteLoss(10)
	return TRUE

/datum/surgery_step/debride/autodoc_success(mob/living/carbon/target, target_zone, datum/surgery/surgery, obj/machinery/autodoc/autodoc)
	var/datum/wound/burn/flesh/burn_wound = surgery.operated_wound
	if(burn_wound)
		log_combat(autodoc, target, "excised infected flesh in", addition="COMBAT MODE: Unknown")
		burn_wound.infestation -= infestation_removed
		burn_wound.sanitization += sanitization_added
		if(burn_wound.infestation <= 0)
			repeatable = FALSE
	else
		return FALSE
	return TRUE

/datum/surgery_step/fix_brain/autodoc_success(mob/living/carbon/target, target_zone, datum/surgery/surgery, obj/machinery/autodoc/autodoc)
	display_pain(target, "The pain in your head receeds, thinking becomes a bit easier!")
	if(target.mind?.has_antag_datum(/datum/antagonist/brainwashed))
		target.mind.remove_antag_datum(/datum/antagonist/brainwashed)
	target.setOrganLoss(ORGAN_SLOT_BRAIN, target.get_organ_loss(ORGAN_SLOT_BRAIN) - 50) //we set damage in this case in order to clear the "failing" flag
	target.cure_all_traumas(TRAUMA_RESILIENCE_SURGERY)
	if(target.get_organ_loss(ORGAN_SLOT_BRAIN) > 0)
		return FALSE
	return TRUE

/datum/surgery_step/repair_bone_hairline/autodoc_success(mob/living/carbon/target, target_zone, datum/surgery/surgery, obj/machinery/autodoc/autodoc)
	if(surgery.operated_wound)
		log_combat(autodoc, target, "repaired a hairline fracture in", addition="COMBAT_MODE: Unknown")
		qdel(surgery.operated_wound)
	else
		return FALSE
	return TRUE

/datum/surgery_step/fix_ears/autodoc_success(mob/living/carbon/target, target_zone, datum/surgery/surgery, obj/machinery/autodoc/autodoc)
	var/obj/item/organ/ears/target_ears = target.get_organ_slot(ORGAN_SLOT_EARS)
	display_pain(target, "Your head swims, but it seems like you can feel your hearing coming back!")
	target_ears.deaf = (20) //deafness works off ticks, so this should work out to about 30-40s
	target_ears.set_organ_damage(0)
	return TRUE

/datum/surgery_step/gastrectomy/autodoc_success(mob/living/carbon/target, target_zone, datum/surgery/surgery, obj/machinery/autodoc/autodoc)
	var/mob/living/carbon/human/target_human = target
	var/obj/item/organ/stomach/target_stomach = target.get_organ_slot(ORGAN_SLOT_STOMACH)
	target_human.setOrganLoss(ORGAN_SLOT_STOMACH, 20) // Stomachs have a threshold for being able to even digest food, so I might tweak this number
	if(target_stomach)
		target_stomach.operated = TRUE
		if(target_stomach.organ_flags & ORGAN_EMP) //If our organ is failing due to an EMP, fix that
			target_stomach.organ_flags &= ~ORGAN_EMP
	display_pain(target, "The pain in your gut ebbs and fades somewhat.")
	return TRUE

/datum/surgery_step/hepatectomy/autodoc_success(mob/living/carbon/target, target_zone, datum/surgery/surgery, obj/machinery/autodoc/autodoc)
	var/mob/living/carbon/human/human_target = target
	var/obj/item/organ/liver/target_liver = target.get_organ_slot(ORGAN_SLOT_LIVER)
	human_target.setOrganLoss(ORGAN_SLOT_LIVER, 10) //not bad, not great
	if(target_liver)
		target_liver.operated = TRUE
		if(target_liver.organ_flags & ORGAN_EMP) //If our organ is failing due to an EMP, fix that
			target_liver.organ_flags &= ~ORGAN_EMP
	display_pain(target, "The pain receeds slightly.")
	return TRUE

/datum/surgery_step/seal_veins/autodoc_success(mob/living/carbon/target, target_zone, datum/surgery/surgery, obj/machinery/autodoc/autodoc)
	var/datum/wound/pierce/bleed/pierce_wound = surgery.operated_wound
	if(!pierce_wound)
		autodoc.say("[target] has no puncture wound there!")
		return FALSE
	log_combat(autodoc, target, "realigned blood vessels in", addition="COMBAT MODE: Unknown")
	pierce_wound.adjust_blood_flow(-0.25)
	return TRUE

// bioware операции были временно убраны
///datum/surgery_step/reshape_ligaments/autodoc_success(mob/living/carbon/target, target_zone, datum/surgery/surgery, obj/machinery/autodoc/autodoc)
//	new /datum/bioware/hooked_ligaments(target)
//	return TRUE

/datum/surgery_step/proc/autodoc_success(mob/living/carbon/target, target_zone, datum/surgery/surgery, obj/machinery/autodoc/autodoc)
	return TRUE

/datum/surgery_step
	var/ad_repeatable = FALSE

/datum/surgery_step/proc/autodoc_check(target_zone, obj/machinery/autodoc/autodoc, silent = TRUE, mob/living/carbon/target)
	return TRUE
