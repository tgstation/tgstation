// Sleeper, Medical Beam, and Syringe gun

/obj/item/mecha_parts/mecha_equipment/medical
	mech_flags = EXOSUIT_MODULE_MEDICAL

/obj/item/mecha_parts/mecha_equipment/medical/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/mecha_parts/mecha_equipment/medical/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/can_attach(obj/vehicle/sealed/mecha/M)
	. = ..()
	if(!ismedicalmecha(M))
		return FALSE


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
	salvageable = FALSE
	var/mob/living/carbon/patient = null
	var/inject_amount = 10

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/Destroy()
	for(var/atom/movable/AM in src)
		AM.forceMove(get_turf(src))
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/Exit(atom/movable/O)//prevents them from leaving without being forcemoved I guess
	return FALSE

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/action(mob/source, atom/atomtarget, params)
	if(!action_checks(atomtarget))
		return
	if(!iscarbon(atomtarget))
		return
	var/mob/living/carbon/target = atomtarget
	if(!patient_insertion_check(target))
		return
	to_chat(source, "[icon2html(src, source)]<span class='notice'>You start putting [target] into [src]...</span>")
	chassis.visible_message("<span class='warning'>[chassis] starts putting [target] into \the [src].</span>")
	if(!do_after(source, equip_cooldown, target=target))
		return
	if(!chassis || src != chassis.selected || !(get_dir(chassis, target)&chassis.dir))
		return
	if(!patient_insertion_check(target, source))
		return
	target.forceMove(src)
	patient = target
	START_PROCESSING(SSobj, src)
	update_equip_info()
	to_chat(source, "[icon2html(src, source)]<span class='notice'>[target] successfully loaded into [src]. Life support functions engaged.</span>")
	chassis.visible_message("<span class='warning'>[chassis] loads [target] into [src].</span>")
	log_message("[target] loaded. Life support functions engaged.", LOG_MECHA)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/patient_insertion_check(mob/living/carbon/target, mob/user)
	if(target.buckled)
		to_chat(user, "[icon2html(src, user)]<span class='warning'>[target] will not fit into the sleeper because [target.p_theyre()] buckled to [target.buckled]!</span>")
		return FALSE
	if(target.has_buckled_mobs())
		to_chat(user, "[icon2html(src, user)]<span class='warning'>[target] will not fit into the sleeper because of the creatures attached to it!</span>")
		return FALSE
	if(patient)
		to_chat(user, "[icon2html(src, user)]<span class='warning'>The sleeper is already occupied!</span>")
		return FALSE
	return TRUE

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/go_out()
	if(!patient)
		return
	patient.forceMove(get_turf(src))
	to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)]<span class='notice'>[patient] ejected. Life support functions disabled.</span>")
	log_message("[patient] ejected. Life support functions disabled.", LOG_MECHA)
	STOP_PROCESSING(SSobj, src)
	patient = null
	update_equip_info()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/detach()
	if(patient)
		to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)]<span class='warning'>Unable to detach [src] - equipment occupied!</span>")
		return
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/get_equip_info()
	var/output = ..()
	if(output)
		var/temp = ""
		if(patient)
			temp = "<br />\[Occupant: [patient] ([patient.stat > 1 ? "*DECEASED*" : "Health: [patient.health]%"])\]<br /><a href='?src=[REF(src)];view_stats=1'>View stats</a>|<a href='?src=[REF(src)];eject=1'>Eject</a>"
		return "[output] [temp]"

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/Topic(href,href_list)
	. = ..()
	if(.)
		return
	if(!(usr in chassis.occupants))
		return
	if(href_list["eject"])
		go_out()
	if(href_list["view_stats"])
		usr << browse(get_patient_stats(),"window=msleeper")
		onclose(usr, "msleeper")
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
				<span class='danger'>[patient.getCloneLoss() ? "Subject appears to have cellular damage." : ""]</span><br />
				<span class='danger'>[patient.getOrganLoss(ORGAN_SLOT_BRAIN) ? "Significant brain damage detected." : ""]</span><br />
				<span class='danger'>[length(patient.get_traumas()) ? "Brain Traumas detected." : ""]</span><br />
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
	if(!R || !patient || !SG || !(SG in chassis.equipment))
		return
	var/to_inject = min(R.volume, inject_amount)
	if(to_inject && patient.reagents.get_reagent_amount(R.type) + to_inject <= inject_amount*2)
		to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)]<span class='notice'>Injecting [patient] with [to_inject] units of [R.name].</span>")
		log_message("Injecting [patient] with [to_inject] units of [R.name].", LOG_MECHA)
		log_combat(chassis.occupants, patient, "injected", "[name] ([R] - [to_inject] units)")
		SG.reagents.trans_id_to(patient,R.type,to_inject)
		update_equip_info()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/update_equip_info()
	. = ..()
	if(. && patient)
		send_byjax(chassis.occupants,"msleeper.browser","lossinfo",get_patient_dam())
		send_byjax(chassis.occupants,"msleeper.browser","reagents",get_patient_reagents())
		send_byjax(chassis.occupants,"msleeper.browser","injectwith",get_available_reagents())

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/container_resist_act(mob/living/user)
	go_out()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/process(delta_time)
	. = ..()
	if(.)
		return
	if(!chassis.has_charge(energy_drain))
		log_message("Deactivated.", LOG_MECHA)
		to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)]<span class='warning'>[src] deactivated - no power.</span>")
		STOP_PROCESSING(SSobj, src)
		return
	var/mob/living/carbon/M = patient
	if(!M)
		return
	if(M.health > 0)
		M.adjustOxyLoss(-0.5 * delta_time)
	M.AdjustStun(-40 * delta_time)
	M.AdjustKnockdown(-40 * delta_time)
	M.AdjustParalyzed(-40 * delta_time)
	M.AdjustImmobilized(-40 * delta_time)
	M.AdjustUnconscious(-40 * delta_time)
	if(M.reagents.get_reagent_amount(/datum/reagent/medicine/epinephrine) < 5)
		M.reagents.add_reagent(/datum/reagent/medicine/epinephrine, 5)
	chassis.use_power(energy_drain)
	update_equip_info()




///////////////////////////////// Syringe Gun ///////////////////////////////////////////////////////////////

#define FIRE_SYRINGE_MODE		0
#define ANALYZE_SYRINGE_MODE	1

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun
	name = "exosuit syringe gun"
	desc = "Equipment for medical exosuits. A chem synthesizer with syringe gun. Reagents inside are held in stasis, so no reactions will occur."
	icon = 'icons/obj/guns/projectile.dmi'
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

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/Initialize()
	. = ..()
	create_reagents(max_volume, NO_REACT)
	known_reagents = list(/datum/reagent/medicine/epinephrine="Epinephrine",/datum/reagent/medicine/c2/multiver="Multiver")

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/create_reagents(max_vol, flags)
	. = ..()
	RegisterSignal(reagents, list(COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_REM_REAGENT), .proc/on_reagent_change)
	RegisterSignal(reagents, COMSIG_PARENT_QDELETING, .proc/on_reagents_del)

/// Handles detaching signal hooks incase someone is crazy enough to make this edible.
/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/on_reagents_del(datum/reagents/reagents)
	SIGNAL_HANDLER
	UnregisterSignal(reagents, list(COMSIG_REAGENTS_NEW_REAGENT, COMSIG_REAGENTS_ADD_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_REM_REAGENT, COMSIG_PARENT_QDELETING))
	return NONE

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/detach()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/can_attach(obj/vehicle/sealed/mecha/medical/M)
	. = ..()
	if(!istype(M))
		return FALSE

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/get_equip_info()
	var/output = ..()// no . = here to avoid obfuscation
	if(output)
		return "[output] \[<a href=\"?src=[REF(src)];toggle_mode=1\">[mode? "Analyze" : "Launch"]</a>\]<br />\[Syringes: [LAZYLEN(syringes)]/[max_syringes] | Reagents: [reagents.total_volume]/[reagents.maximum_volume]\]<br /><a href='?src=[REF(src)];show_reagents=1'>Reagents list</a>"

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/action(mob/source, atom/target, params)
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
		to_chat(source, "[icon2html(src, source)]<span class=\"alert\">No syringes loaded.</span>")
		return
	if(reagents.total_volume<=0)
		to_chat(source, "[icon2html(src, source)]<span class=\"alert\">No available reagents to load syringe with.</span>")
		return
	if(HAS_TRAIT(source, TRAIT_PACIFISM))
		to_chat(source, "<span class=\"alert\">The [src] might be lethally chambered! You don't want to risk harming anyone...</span>")
		return
	var/obj/item/ammo_casing/syringegun/chambered = new /obj/item/ammo_casing/syringegun(src)
	log_message("Fired [chambered] from [src] by [source], targeting [target].", LOG_MECHA)
	chambered.fire_casing(target, source, null, 0, 0, null, 0, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/Topic(href,href_list)
	..()
	if (href_list["toggle_mode"])
		mode = !mode
		update_equip_info()
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
			to_chat(usr, "[icon2html(src, usr)]<span class='notice'>Reagent processing started.</span>")
			log_message("Reagent processing started.", LOG_MECHA)
		return
	if (href_list["show_reagents"])
		if(!(usr in chassis.occupants))
			return
		usr << browse(get_reagents_page(),"window=msyringegun")
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
		to_chat(user, "[icon2html(src, user)]<span class='warning'>[src]'s syringe chamber is full!</span>")
		return FALSE
	if(get_dist(src,S) >= 2)
		to_chat(user, "[icon2html(src, user)]<span class='warning'>The syringe is too far away!</span>")
		return FALSE
	for(var/obj/structure/D in S.loc)//Basic level check for structures in the way (Like grilles and windows)
		if(!(D.CanPass(S,src.loc)))
			to_chat(user, "[icon2html(src, user)]<span class='warning'>Unable to load syringe!</span>")
			return FALSE
	for(var/obj/machinery/door/D in S.loc)//Checks for doors
		if(!(D.CanPass(S,src.loc)))
			to_chat(user, "[icon2html(src, user)]<span class='warning'>Unable to load syringe!</span>")
			return FALSE
	S.reagents.trans_to(src, S.reagents.total_volume, transfered_by = user)
	S.forceMove(src)
	LAZYADD(syringes,S)
	to_chat(user, "[icon2html(src, user)]<span class='notice'>Syringe loaded.</span>")
	update_equip_info()
	return TRUE

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/analyze_reagents(atom/A, mob/user)
	if(get_dist(src,A) >= 4)
		to_chat(user, "[icon2html(src, user)]<span class='notice'>The object is too far away!</span>")
		return FALSE
	if(!A.reagents || ismob(A))
		to_chat(user, "[icon2html(src, user)]<span class='warning'>No reagent info gained from [A].</span>")
		return FALSE
	to_chat(user, "[icon2html(src, user)]<span class='notice'>Analyzing reagents...</span>")
	for(var/datum/reagent/R in A.reagents.reagent_list)
		if((R.chemical_flags & REAGENT_CAN_BE_SYNTHESIZED) && add_known_reagent(R.type,R.name))
			to_chat(user, "[icon2html(src, user)]<span class='notice'>Reagent analyzed, identified as [R.name] and added to database.</span>")
			send_byjax(chassis.occupants,"msyringegun.browser","reagents_form",get_reagents_form())
	to_chat(user, "[icon2html(src, user)]<span class='notice'>Analysis complete.</span>")
	return TRUE

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/add_known_reagent(r_id,r_name)
	if(r_id in known_reagents)
		return FALSE
	known_reagents += r_id
	known_reagents[r_id] = r_name
	return TRUE

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/update_equip_info()
	. = ..()
	if(.)
		send_byjax(chassis.occupants,"msyringegun.browser","reagents",get_current_reagents())
		send_byjax(chassis.occupants,"msyringegun.browser","reagents_form",get_reagents_form())

/// Updates the equipment info list when the reagents change. Eats signal args.
/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/on_reagent_change(datum/reagents/holder, ...)
	SIGNAL_HANDLER
	update_equip_info()
	return NONE


/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/process(delta_time)
	. = ..()
	if(.)
		return
	if(!LAZYLEN(processed_reagents) || reagents.total_volume >= reagents.maximum_volume || !chassis.has_charge(energy_drain))
		to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)]<span class='alert'>Reagent processing stopped.</span>")
		log_message("Reagent processing stopped.", LOG_MECHA)
		return PROCESS_KILL
	var/amount = delta_time * synth_speed / LAZYLEN(processed_reagents)
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
	custom_materials = list(/datum/material/iron = 15000, /datum/material/glass = 8000, /datum/material/plasma = 3000, /datum/material/gold = 8000, /datum/material/diamond = 2000)
	material_flags = MATERIAL_NO_EFFECTS

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/Initialize()
	. = ..()
	medigun = new(src)


/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/Destroy()
	QDEL_NULL(medigun)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/process(deltatime)
	. = ..()
	if(.)
		return
	medigun.process(SSOBJ_DT)

/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/action(mob/source, atom/movable/target, params)
	medigun.process_fire(target, loc)


/obj/item/mecha_parts/mecha_equipment/medical/mechmedbeam/detach()
	STOP_PROCESSING(SSobj, src)
	medigun.LoseTarget()
	return ..()
