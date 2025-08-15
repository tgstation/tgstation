// Sleeper, Medical Beam, and Syringe gun

/obj/item/mecha_parts/mecha_equipment/medical
	mech_flags = EXOSUIT_MODULE_MEDICAL

/obj/item/mecha_parts/mecha_equipment/medical/attach(obj/vehicle/sealed/mecha/new_mecha)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/detach(atom/moveto)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/process()
	if(!chassis)
		return PROCESS_KILL

/obj/item/mecha_parts/mecha_equipment/proc/get_reagent_data(list/datum/reagent/reagent_list)
	var/list/contained_reagents = list()
	if(length(reagent_list))
		for(var/datum/reagent/reagent as anything in reagent_list)
			contained_reagents += list(list("name" = reagent.name, "volume" = round(reagent.volume, 0.01))) // list in a list because Byond merges the first list...
	return contained_reagents

//---- Mecha sleeper, medical subtype has the chemical functionality
/obj/item/mecha_parts/mecha_equipment/sleeper
	name = "mounted sleeper"
	desc = "A mounted sleeper that stabilizes patients."
	icon_state = "mecha_sleeper_miner"
	energy_drain = 20
	range = MECHA_MELEE
	equip_cooldown = 20
	/// ref to the patient loaded in the sleeper
	var/mob/living/carbon/patient

/obj/item/mecha_parts/mecha_equipment/sleeper/Destroy()
	for(var/atom/movable/content as anything in src)
		content.forceMove(get_turf(src))
	return ..()

/obj/item/mecha_parts/mecha_equipment/sleeper/container_resist_act(mob/living/user)
	go_out()

/obj/item/mecha_parts/mecha_equipment/sleeper/action(mob/source, atom/atomtarget, list/modifiers)
	if(!action_checks(atomtarget))
		return
	if(!iscarbon(atomtarget))
		return
	var/mob/living/carbon/target = atomtarget
	if(!patient_insertion_check(target, source))
		return
	to_chat(source, "[icon2html(src, source)][span_notice("You start putting [target] into [src]...")]")
	chassis.visible_message(span_warning("[chassis] starts putting [target] into \the [src]."))
	if(!do_after(source, equip_cooldown, target, extra_checks=CALLBACK(src, PROC_REF(patient_insertion_check), target, source)))
		return
	if(!chassis || !(get_dir(chassis, target) & chassis.dir))
		return
	target.forceMove(src)
	patient = target
	START_PROCESSING(SSobj, src)
	to_chat(source, "[icon2html(src, source)][span_notice("[target] successfully loaded into [src]. Life support functions engaged.")]")
	chassis.visible_message(span_warning("[chassis] loads [target] into [src]."))
	log_message("[target] loaded. Life support functions engaged.", LOG_MECHA)
	return ..()

/obj/item/mecha_parts/mecha_equipment/sleeper/proc/patient_insertion_check(mob/living/carbon/target, mob/user)
	if(!isnull(target.buckled))
		to_chat(user, "[icon2html(src, user)][span_warning("[target] will not fit into the sleeper because [target.p_theyre()] buckled to [target.buckled]!")]")
		return FALSE
	if(target.has_buckled_mobs())
		to_chat(user, "[icon2html(src, user)][span_warning("[target] will not fit into the sleeper because of the creatures attached to it!")]")
		return FALSE
	if(patient)
		to_chat(user, "[icon2html(src, user)][span_warning("The sleeper is already occupied!")]")
		return FALSE
	return TRUE

/obj/item/mecha_parts/mecha_equipment/sleeper/proc/go_out()
	if(!patient)
		return
	patient.forceMove(get_turf(src))
	to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_notice("[patient] ejected. Life support functions disabled.")]")
	log_message("[patient] ejected. Life support functions disabled.", LOG_MECHA)
	STOP_PROCESSING(SSobj, src)
	patient = null

/obj/item/mecha_parts/mecha_equipment/sleeper/detach()
	if(patient)
		to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_warning("Unable to detach [src] - equipment occupied!")]")
		return
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/sleeper/get_snowflake_data()
	var/list/data = list("snowflake_id" = MECHA_SNOWFLAKE_ID_SLEEPER)
	if(isnull(patient))
		return data
	var/patient_state
	switch(patient.stat)
		if(CONSCIOUS)
			patient_state = "Conscious"
		if(UNCONSCIOUS)
			patient_state = "Unconscious"
		if(DEAD)
			patient_state = "*Dead*"
		if(SOFT_CRIT, HARD_CRIT)
			patient_state = "Critical"
		else
			patient_state = "Unknown"
	var/core_temp = ""
	if(ishuman(patient))
		var/mob/living/carbon/human/humi = patient
		core_temp = humi.bodytemperature-T0C
	data["patient"] = list(
		"patient_name" = patient.name,
		"patient_health" = patient.health/patient.maxHealth,
		"patient_state" = patient_state,
		"core_temp" = core_temp,
		"brute_loss" = patient.getBruteLoss(),
		"burn_loss" = patient.getFireLoss(),
		"toxin_loss" = patient.getToxLoss(),
		"oxygen_loss" = patient.getOxyLoss(),
	)
	data["contained_reagents"] = get_reagent_data(patient.reagents.reagent_list)
	data["has_brain_damage"] = patient.get_organ_loss(ORGAN_SLOT_BRAIN) != 0
	data["has_traumas"] = length(patient.get_traumas()) != 0

	return data

/obj/item/mecha_parts/mecha_equipment/sleeper/handle_ui_act(action, list/params)
	if(action == "eject")
		go_out()
		return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/sleeper/process(seconds_per_tick)
	if(!chassis.has_charge(energy_drain))
		log_message("Deactivated.", LOG_MECHA)
		to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_warning("[src] deactivated - no power.")]")
		STOP_PROCESSING(SSobj, src)
		return
	var/mob/living/carbon/ex_patient = patient
	if(!ex_patient)
		return
	if(ex_patient.loc != src)
		to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_notice("[patient] no longer detected. Life support functions diabled.")]")
		log_message("[patient] no longer detected - Life support functions disabled.", LOG_MECHA)
		STOP_PROCESSING(SSobj, src)
		patient = null
	ex_patient.adjustOxyLoss(-2 * seconds_per_tick)
	ex_patient.AdjustStun(-4 SECONDS * seconds_per_tick)
	ex_patient.AdjustKnockdown(-4 SECONDS * seconds_per_tick)
	ex_patient.AdjustParalyzed(-4 SECONDS * seconds_per_tick)
	ex_patient.AdjustImmobilized(-4 SECONDS * seconds_per_tick)
	ex_patient.AdjustUnconscious(-4 SECONDS * seconds_per_tick)
	if(ex_patient.reagents.get_reagent_amount(/datum/reagent/medicine/epinephrine) < 5 \
	&& ex_patient.reagents.get_reagent_amount(/datum/reagent/medicine/c2/penthrite) <= 0 \
	&& ex_patient.stat >= SOFT_CRIT)
		ex_patient.reagents.add_reagent(/datum/reagent/medicine/epinephrine, 5)
	if(ex_patient.reagents.get_reagent_amount(/datum/reagent/toxin/formaldehyde) <= 0 && ex_patient.stat == DEAD)
		ex_patient.reagents.add_reagent(/datum/reagent/toxin/formaldehyde, 3)
	chassis.use_energy(energy_drain)

//Medical subtype with the chems
/obj/item/mecha_parts/mecha_equipment/sleeper/medical
	name = "mounted sleeper"
	desc = "Equipment for medical exosuits. A mounted sleeper that stabilizes patients and can inject reagents from a equipped exosuit syringe gun."
	icon_state = "mecha_sleeper"
	mech_flags = EXOSUIT_MODULE_MEDICAL
	/// amount of chems to inject into patient from other hands syringe gun
	var/inject_amount = 10

/obj/item/mecha_parts/mecha_equipment/sleeper/medical/get_snowflake_data()
	var/list/data = ..()
	if(isnull(patient))
		return data
	var/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/shooter = locate(/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun) in chassis
	if(shooter)
		data["injectible_reagents"] = get_reagent_data(shooter.reagents.reagent_list)
	return data

/obj/item/mecha_parts/mecha_equipment/sleeper/medical/handle_ui_act(action, list/params)
	. = ..()
	if(.)
		return TRUE
	var/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/shooter = locate() in chassis
	if(shooter)
		for(var/datum/reagent/medication as anything in shooter.reagents.reagent_list)
			if(action == ("inject_reagent_" + medication.name))
				inject_reagent(medication, shooter)
				break // or maybe return TRUE? i'm not certain

/obj/item/mecha_parts/mecha_equipment/sleeper/medical/proc/inject_reagent(datum/reagent/reagent_to_inject, obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/SG)
	if(!reagent_to_inject || !patient || !SG || !(SG in chassis.flat_equipment))
		return
	var/to_inject = min(reagent_to_inject.volume, inject_amount)
	if(to_inject && patient.reagents.get_reagent_amount(reagent_to_inject.type) + to_inject <= inject_amount*2)
		to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_notice("Injecting [patient] with [to_inject] units of [reagent_to_inject.name].")]")
		log_message("Injecting [patient] with [to_inject] units of [reagent_to_inject.name].", LOG_MECHA)
		for(var/driver in chassis.return_drivers())
			log_combat(driver, patient, "injected", "[name] ([reagent_to_inject] - [to_inject] units)")
		SG.reagents.trans_to(patient, to_inject, target_id = reagent_to_inject.type)

///////////////////////////////// Syringe Gun ///////////////////////////////////////////////////////////////

#define FIRE_SYRINGE_MODE 0
#define ANALYZE_SYRINGE_MODE 1

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun
	name = "exosuit syringe gun"
	desc = "Equipment for medical exosuits. A chem synthesizer with syringe gun. Reagents inside are held in stasis, so no reactions will occur."
	icon_state = "mecha_syringegun"
	range = MECHA_MELEE|MECHA_RANGED
	equip_cooldown = 10
	energy_drain = 10
	///Lazylist of syringes that we've picked up
	var/list/syringes
	///List of all scanned reagents, starts with epinephrine and multiver
	var/list/datum/reagent/known_reagents
	///List of reagents we want to be creating this processing tick
	var/list/processed_reagents
	///Maximu amount of syringes we can hold
	var/max_syringes = 10
	///Maximum volume of reagents we can hold
	var/max_volume = 75
	///Reagent amount in units we produce per two seconds
	var/synth_speed = 2.5
	///Chooses what kind of action we should perform when clicking
	var/mode = FIRE_SYRINGE_MODE // fire syringe or analyze reagents.

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/Initialize(mapload)
	. = ..()
	create_reagents(max_volume, NO_REACT)
	known_reagents = list(/datum/reagent/medicine/epinephrine="Epinephrine",/datum/reagent/medicine/c2/multiver="Multiver")

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/detach()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/get_snowflake_data()
	var/list/analyzed_reagents = list() // we need to make this list because .tsk wont map over an indexed array
	for(var/i=1 to known_reagents.len)
		var/enabled = FALSE
		if(known_reagents[i] in processed_reagents)
			enabled = TRUE
		analyzed_reagents += list((list("name" = known_reagents[i].name, "enabled" = enabled)))
	var/list/data = list(
		"snowflake_id" = MECHA_SNOWFLAKE_ID_SYRINGE,
		"mode" = mode == FIRE_SYRINGE_MODE ? "Launch" : "Analyze",
		"mode_label" = "Action",
		"syringe" = LAZYLEN(syringes),
		"max_syringe" = max_syringes,
		"reagents" = reagents.total_volume,
		"total_reagents" = reagents.maximum_volume,
		"analyzed_reagents" = analyzed_reagents,
	)
	data["contained_reagents"] = get_reagent_data(reagents.reagent_list)
	return data

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/handle_ui_act(action, list/params)
	if(action == "change_mode")
		mode = !mode
		return TRUE
	else if(action == "purge_all")
		reagents.clear_reagents()
	else
		for(var/i=1 to known_reagents.len)
			var/reagent_id = known_reagents[i]
			if(action == ("purge_reagent_" + known_reagents[i].name))
				reagents.del_reagent(reagent_id)
			else if(action == ("toggle_reagent_" + known_reagents[i].name))
				synthesize(reagent_id)

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/synthesize(reagent)
	if(reagent in processed_reagents)
		LAZYREMOVE(processed_reagents, reagent)
		return
	var/message = "[known_reagents[reagent]]"
	LAZYADD(processed_reagents, reagent)
	if(!LAZYLEN(processed_reagents))
		return

	message += " added to production"
	START_PROCESSING(SSobj, src)
	to_chat(usr, message)
	to_chat(usr, "[icon2html(src, usr)][span_notice("Reagent processing started.")]")
	log_message("Reagent processing started.", LOG_MECHA)

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/action(mob/source, atom/target, list/modifiers)
	if(!action_checks(target))
		return
	if(istype(target, /obj/item/reagent_containers/syringe))
		return load_syringe(target)
	if(istype(target, /obj/item/storage))//Loads syringes from boxes
		for(var/obj/item/reagent_containers/syringe/S in target.contents)
			load_syringe(S, source)
		return
	if(mode == ANALYZE_SYRINGE_MODE)
		return analyze_reagents(target, source)
	//we're in syringe mode so lets do syringe stuff
	if(!LAZYLEN(syringes))
		to_chat(source, "[icon2html(src, source)]<span class='alert'>No syringes loaded.</span>")
		return
	if(reagents.total_volume <= 0)
		to_chat(source, "[icon2html(src, source)]<span class='alert'>No available reagents to load syringe with.</span>")
		return
	if(HAS_TRAIT(source, TRAIT_PACIFISM))
		to_chat(source, span_alert("The [src] might be lethally chambered! You don't want to risk harming anyone..."))
		return
	var/obj/item/ammo_casing/syringegun/chambered = new /obj/item/ammo_casing/syringegun(src)
	log_message("Fired [chambered] from [src] by [source], targeting [target].", LOG_MECHA)
	chambered.fire_casing(target, source, null, 0, 0, null, 0, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/load_syringe(obj/item/reagent_containers/syringe/S, mob/user)
	if(LAZYLEN(syringes) >= max_syringes)
		to_chat(user, "[icon2html(src, user)][span_warning("[src]'s syringe chamber is full!")]")
		return FALSE
	if(!chassis.Adjacent(S))
		to_chat(user, "[icon2html(src, user)][span_warning("Unable to load syringe!")]")
		return FALSE
	S.reagents.trans_to(src, S.reagents.total_volume, transferred_by = user)
	S.forceMove(src)
	LAZYADD(syringes,S)
	to_chat(user, "[icon2html(src, user)][span_notice("Syringe loaded.")]")
	return TRUE

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/analyze_reagents(atom/A, mob/user)
	if(get_dist(src,A) >= 4)
		to_chat(user, "[icon2html(src, user)][span_notice("The object is too far away!")]")
		return FALSE
	if(!A.reagents || ismob(A))
		to_chat(user, "[icon2html(src, user)][span_warning("No reagent info gained from [A].")]")
		return FALSE
	to_chat(user, "[icon2html(src, user)][span_notice("Analyzing reagents...")]")
	for(var/datum/reagent/R in A.reagents.reagent_list)
		if((R.chemical_flags & REAGENT_CAN_BE_SYNTHESIZED) && add_known_reagent(R.type,R.name))
			to_chat(user, "[icon2html(src, user)][span_notice("Reagent analyzed, identified as [R.name] and added to database.")]")
	to_chat(user, "[icon2html(src, user)][span_notice("Analysis complete.")]")
	return TRUE

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/add_known_reagent(r_id,r_name)
	if(r_id in known_reagents)
		return FALSE
	known_reagents += r_id
	known_reagents[r_id] = r_name
	return TRUE

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/process(seconds_per_tick)
	. = ..()
	if(.)
		return
	if(!LAZYLEN(processed_reagents) || reagents.total_volume >= reagents.maximum_volume || !chassis.has_charge(energy_drain))
		to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_alert("Reagent processing stopped.")]")
		log_message("Reagent processing stopped.", LOG_MECHA)
		return PROCESS_KILL
	var/amount = seconds_per_tick * synth_speed / LAZYLEN(processed_reagents)
	for(var/reagent in processed_reagents)
		reagents.add_reagent(reagent,amount)
		chassis.use_energy(energy_drain)

#undef FIRE_SYRINGE_MODE
#undef ANALYZE_SYRINGE_MODE

///////////////////////////////// Medical Beam ///////////////////////////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam
	name = "exosuit medical beamgun"
	desc = "Equipment for medical exosuits. Generates a focused beam of medical nanites."
	icon_state = "mecha_medigun"
	energy_drain = 10
	range = MECHA_MELEE|MECHA_RANGED
	equip_cooldown = 0
	///The medical gun doing the actual healing. yes its wierd but its better than copypasting the entire thing
	var/obj/item/gun/medbeam/mech/medigun
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT*7.5, /datum/material/glass = SHEET_MATERIAL_AMOUNT*4, /datum/material/plasma = SHEET_MATERIAL_AMOUNT*1.5, /datum/material/gold = SHEET_MATERIAL_AMOUNT*4, /datum/material/diamond =SHEET_MATERIAL_AMOUNT)

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/Initialize(mapload)
	. = ..()
	medigun = new(src)

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/Destroy()
	QDEL_NULL(medigun)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/process(deltatime)
	. = ..()
	if(. || !length(chassis.occupants))
		return
	if(chassis.weapons_safety)
		medigun.LoseTarget()
	medigun.process(SSOBJ_DT)

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/action(mob/source, atom/movable/target, list/modifiers)
	medigun.process_fire(target, loc)

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/detach()
	STOP_PROCESSING(SSobj, src)
	medigun.LoseTarget()
	return ..()
