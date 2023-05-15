// Sleeper, Medical Beam, and Syringe gun

/obj/item/mecha_parts/mecha_equipment/medical
	mech_flags = EXOSUIT_MODULE_MEDICAL

/obj/item/mecha_parts/mecha_equipment/medical/attach(obj/vehicle/sealed/mecha/M)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/mecha_parts/mecha_equipment/medical/process()
	if(!chassis)
		return PROCESS_KILL

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/detach()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper
	name = "mounted sleeper"
	desc = "Equipment for medical exosuits. A mounted sleeper that stabilizes patients and can inject reagents in the exosuit's reserves."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	energy_drain = 20
	range = MECHA_MELEE
	equip_cooldown = 20
	///ref to the patient loaded in the sleeper
	var/mob/living/carbon/patient
	/// amount of chems to inject into patient from other hands syringe gun
	var/inject_amount = 10

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/Destroy()
	for(var/atom/movable/content as anything in src)
		content.forceMove(get_turf(src))
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/get_snowflake_data()
	var/list/data = list("snowflake_id" = MECHA_SNOWFLAKE_ID_SLEEPER)
	if(!patient)
		return data
	data["patient"] = list(
		"patientname" = patient.name,
		"is_dead" = patient.stat == DEAD,
		"patient_health" = patient.health/patient.maxHealth,
	)
	return data

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("eject")
			go_out()
			return TRUE
		if("view_stats")
			usr << browse(get_patient_stats(),"window=msleeper")
			onclose(usr, "msleeper")
			return FALSE

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/action(mob/source, atom/atomtarget, list/modifiers)
	if(!action_checks(atomtarget))
		return
	if(!iscarbon(atomtarget))
		return
	var/mob/living/carbon/target = atomtarget
	if(!patient_insertion_check(target))
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

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/patient_insertion_check(mob/living/carbon/target, mob/user)
	if(target.buckled)
		to_chat(user, "[icon2html(src, user)][span_warning("[target] will not fit into the sleeper because [target.p_theyre()] buckled to [target.buckled]!")]")
		return FALSE
	if(target.has_buckled_mobs())
		to_chat(user, "[icon2html(src, user)][span_warning("[target] will not fit into the sleeper because of the creatures attached to it!")]")
		return FALSE
	if(patient)
		to_chat(user, "[icon2html(src, user)][span_warning("The sleeper is already occupied!")]")
		return FALSE
	return TRUE

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/go_out()
	if(!patient)
		return
	patient.forceMove(get_turf(src))
	to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_notice("[patient] ejected. Life support functions disabled.")]")
	log_message("[patient] ejected. Life support functions disabled.", LOG_MECHA)
	STOP_PROCESSING(SSobj, src)
	patient = null

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/detach()
	if(patient)
		to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_warning("Unable to detach [src] - equipment occupied!")]")
		return
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/Topic(href,href_list)
	. = ..()
	if(.)
		return
	if(!(usr in chassis.occupants))
		return
	if(href_list["inject"])
		var/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/SG = locate() in chassis
		var/datum/reagent/R = locate(href_list["inject"]) in SG.reagents.reagent_list
		if(istype(R))
			inject_reagent(R, SG)

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/get_patient_stats()
	if(!patient)
		return
	return {"<html>
				<head>
				<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
				<title>[patient] statistics</title>
				<script language='javascript' type='text/javascript'>
				[js_byjax]
				</script>
				<style>
				h3 {margin-bottom:2px;font-size:14px;}
				#lossinfo, #reagents, #injectwith {padding-left:15px;}
				</style>
				</head>
				<body>
				<h3>Health statistics</h3>
				<div id="lossinfo">
				[get_patient_dam()]
				</div>
				<h3>Reagents in bloodstream</h3>
				<div id="reagents">
				[get_patient_reagents()]
				</div>
				<div id="injectwith">
				[get_available_reagents()]
				</div>
				</body>
				</html>"}

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/get_patient_dam()
	var/t1
	switch(patient.stat)
		if(0)
			t1 = "Conscious"
		if(1)
			t1 = "Unconscious"
		if(2)
			t1 = "*dead*"
		else
			t1 = "Unknown"
	var/core_temp = ""
	if(ishuman(patient))
		var/mob/living/carbon/human/humi = patient
		core_temp = {"<font color="[humi.coretemperature > 300 ? "#3d5bc3" : "#c51e1e"]"><b>Body Temperature:</b> [humi.bodytemperature-T0C]&deg;C ([humi.bodytemperature*1.8-459.67]&deg;F)</font><br />"}
	return {"<font color="[patient.health > 50 ? "#3d5bc3" : "#c51e1e"]"><b>Health:</b> [patient.stat > 1 ? "[t1]" : "[patient.health]% ([t1])"]</font><br />
				[core_temp]
				<font color="[patient.bodytemperature > 300 ? "#3d5bc3" : "#c51e1e"]"><b>Body Temperature:</b> [patient.bodytemperature-T0C]&deg;C ([patient.bodytemperature*1.8-459.67]&deg;F)</font><br />
				<font color="[patient.getBruteLoss() < 60 ? "#3d5bc3" : "#c51e1e"]"><b>Brute Damage:</b> [patient.getBruteLoss()]%</font><br />
				<font color="[patient.getOxyLoss() < 60 ? "#3d5bc3" : "#c51e1e"]"><b>Respiratory Damage:</b> [patient.getOxyLoss()]%</font><br />
				<font color="[patient.getToxLoss() < 60 ? "#3d5bc3" : "#c51e1e"]"><b>Toxin Content:</b> [patient.getToxLoss()]%</font><br />
				<font color="[patient.getFireLoss() < 60 ? "#3d5bc3" : "#c51e1e"]"><b>Burn Severity:</b> [patient.getFireLoss()]%</font><br />
				[span_danger("[patient.getCloneLoss() ? "Subject appears to have cellular damage." : ""]")]<br />
				[span_danger("[patient.get_organ_loss(ORGAN_SLOT_BRAIN) ? "Significant brain damage detected." : ""]")]<br />
				[span_danger("[length(patient.get_traumas()) ? "Brain Traumas detected." : ""]")]<br />
				"}

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/get_patient_reagents()
	if(patient.reagents)
		for(var/datum/reagent/R in patient.reagents.reagent_list)
			if(R.volume > 0)
				. += "[R]: [round(R.volume,0.01)]<br />"
	return . || "None"

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/get_available_reagents()
	var/output
	var/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/SG = locate(/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun) in chassis
	if(SG && SG.reagents && islist(SG.reagents.reagent_list))
		for(var/datum/reagent/R in SG.reagents.reagent_list)
			if(R.volume > 0)
				output += "<a href=\"?src=[REF(src)];inject=[REF(R)]\">Inject [R.name]</a><br />"
	return output


/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/inject_reagent(datum/reagent/R,obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/SG)
	if(!R || !patient || !SG || !(SG in chassis.flat_equipment))
		return
	var/to_inject = min(R.volume, inject_amount)
	if(to_inject && patient.reagents.get_reagent_amount(R.type) + to_inject <= inject_amount*2)
		to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_notice("Injecting [patient] with [to_inject] units of [R.name].")]")
		log_message("Injecting [patient] with [to_inject] units of [R.name].", LOG_MECHA)
		for(var/driver in chassis.return_drivers())
			log_combat(driver, patient, "injected", "[name] ([R] - [to_inject] units)")
		SG.reagents.trans_id_to(patient,R.type,to_inject)

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/container_resist_act(mob/living/user)
	go_out()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/process(seconds_per_tick)
	. = ..()
	if(.)
		return
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
	if(ex_patient.health > 0)
		ex_patient.adjustOxyLoss(-0.5 * seconds_per_tick)
	ex_patient.AdjustStun(-40 * seconds_per_tick)
	ex_patient.AdjustKnockdown(-40 * seconds_per_tick)
	ex_patient.AdjustParalyzed(-40 * seconds_per_tick)
	ex_patient.AdjustImmobilized(-40 * seconds_per_tick)
	ex_patient.AdjustUnconscious(-40 * seconds_per_tick)
	if(ex_patient.reagents.get_reagent_amount(/datum/reagent/medicine/epinephrine) < 5)
		ex_patient.reagents.add_reagent(/datum/reagent/medicine/epinephrine, 5)
	chassis.use_power(energy_drain)


///////////////////////////////// Syringe Gun ///////////////////////////////////////////////////////////////

#define FIRE_SYRINGE_MODE 0
#define ANALYZE_SYRINGE_MODE 1

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun
	name = "exosuit syringe gun"
	desc = "Equipment for medical exosuits. A chem synthesizer with syringe gun. Reagents inside are held in stasis, so no reactions will occur."
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	icon_state = "syringegun"
	range = MECHA_MELEE|MECHA_RANGED
	equip_cooldown = 10
	energy_drain = 10
	///Lazylist of syringes that we've picked up
	var/list/syringes
	///List of all scanned reagents, starts with epinephrine and multiver
	var/list/known_reagents
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

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/create_reagents(max_vol, flags)
	. = ..()
	RegisterSignals(reagents, list(COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_REM_REAGENT), PROC_REF(on_reagent_change))
	RegisterSignal(reagents, COMSIG_PARENT_QDELETING, PROC_REF(on_reagents_del))

/// Handles detaching signal hooks incase someone is crazy enough to make this edible.
/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/on_reagents_del(datum/reagents/reagents)
	SIGNAL_HANDLER
	UnregisterSignal(reagents, list(COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_REM_REAGENT, COMSIG_PARENT_QDELETING))
	return NONE

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/detach()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/get_snowflake_data()
	return list(
		"snowflake_id" = MECHA_SNOWFLAKE_ID_SYRINGE,
		"mode" = mode == FIRE_SYRINGE_MODE ? "Launch" : "Analyze",
		"syringe" = LAZYLEN(syringes),
		"max_syringe" = max_syringes,
		"reagents" = reagents.total_volume,
		"total_reagents" = reagents.maximum_volume,
	)

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(action == "change_mode")
		mode = !mode
		return TRUE
	else if(action == "show_reagents")
		usr << browse(get_reagents_page(),"window=msyringegun")
		return FALSE

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

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/Topic(href,href_list)
	..()
	if (href_list["toggle_mode"])
		mode = !mode
		return
	if (href_list["select_reagents"])
		LAZYCLEARLIST(processed_reagents)
		var/processingreagentamount = 0
		var/message
		for(var/i=1 to known_reagents.len)
			if(processingreagentamount >= synth_speed)
				break
			var/reagent = text2path(href_list["reagent_[i]"])
			if(reagent && (reagent in known_reagents))
				message = "[processingreagentamount ? ", " : null][known_reagents[reagent]]"
				LAZYADD(processed_reagents, reagent)
				processingreagentamount++
		if(LAZYLEN(processed_reagents))
			message += " added to production"
			START_PROCESSING(SSobj, src)
			to_chat(usr, message)
			to_chat(usr, "[icon2html(src, usr)][span_notice("Reagent processing started.")]")
			log_message("Reagent processing started.", LOG_MECHA)
		return
	if (href_list["purge_reagent"])
		var/reagent = href_list["purge_reagent"]
		if(!reagent)
			return
		reagents.del_reagent(reagent)
		return
	if (href_list["purge_all"])
		reagents.clear_reagents()

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/get_reagents_page()
	var/output = {"<html>
						<head>
						<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
						<title>Reagent Synthesizer</title>
						<script language='javascript' type='text/javascript'>
						[js_byjax]
						</script>
						<style>
						h3 {margin-bottom:2px;font-size:14px;}
						#reagents, #reagents_form {}
						form {width: 90%; margin:10px auto; border:1px dotted #999; padding:6px;}
						#submit {margin-top:5px;}
						</style>
						</head>
						<body>
						<h3>Current reagents:</h3>
						<div id="reagents">
						[get_current_reagents()]
						</div>
						<h3>Reagents production:</h3>
						<div id="reagents_form">
						[get_reagents_form()]
						</div>
						</body>
						</html>
						"}
	return output

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/get_reagents_form()
	var/r_list = get_reagents_list()
	var/inputs
	if(r_list)
		inputs += "<input type=\"hidden\" name=\"src\" value=\"[REF(src)]\">"
		inputs += "<input type=\"hidden\" name=\"select_reagents\" value=\"1\">"
		inputs += "<input id=\"submit\" type=\"submit\" value=\"Apply settings\">"
	var/output = {"<form action="byond://" method="get">
						[r_list || "No known reagents"]
						[inputs]
						</form>
						[r_list? "<span style=\"font-size:80%;\">Only the first [synth_speed] selected reagent\s will be added to production</span>" : null]
						"}
	return output

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/get_reagents_list()
	var/output
	for(var/i=1 to known_reagents.len)
		var/reagent_id = known_reagents[i]
		output += {"<input type="checkbox" value="[reagent_id]" name="reagent_[i]" [(reagent_id in processed_reagents)? "checked=\"1\"" : null]> [known_reagents[reagent_id]]<br />"}
	return output

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/get_current_reagents()
	var/output
	for(var/datum/reagent/R in reagents.reagent_list)
		if(R.volume > 0)
			output += "[R]: [round(R.volume,0.001)] - <a href=\"?src=[REF(src)];purge_reagent=[R]\">Purge Reagent</a><br />"
	if(output)
		output += "Total: [round(reagents.total_volume,0.001)]/[reagents.maximum_volume] - <a href=\"?src=[REF(src)];purge_all=1\">Purge All</a>"
	return output || "None"

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/load_syringe(obj/item/reagent_containers/syringe/S, mob/user)
	if(LAZYLEN(syringes) >= max_syringes)
		to_chat(user, "[icon2html(src, user)][span_warning("[src]'s syringe chamber is full!")]")
		return FALSE
	if(!chassis.Adjacent(S))
		to_chat(user, "[icon2html(src, user)][span_warning("Unable to load syringe!")]")
		return FALSE
	S.reagents.trans_to(src, S.reagents.total_volume, transfered_by = user)
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
			send_byjax(chassis.occupants,"msyringegun.browser","reagents_form",get_reagents_form())
	to_chat(user, "[icon2html(src, user)][span_notice("Analysis complete.")]")
	return TRUE

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/add_known_reagent(r_id,r_name)
	if(r_id in known_reagents)
		return FALSE
	known_reagents += r_id
	known_reagents[r_id] = r_name
	return TRUE

/// Updates the equipment info list when the reagents change. Eats signal args.
/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/on_reagent_change(datum/reagents/holder, ...)
	SIGNAL_HANDLER
	send_byjax(chassis.occupants,"msyringegun.browser","reagents",get_current_reagents())
	send_byjax(chassis.occupants,"msyringegun.browser","reagents_form",get_reagents_form())
	return NONE


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
		chassis.use_power(energy_drain)

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
	if(.)
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
