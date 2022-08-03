//CONTAINS: Detective's Scanner

// TODO: Split everything into easy to manage procs.

/obj/item/detective_scanner
	name = "forensic scanner"
	desc = "Used to remotely scan objects and biomass for DNA and fingerprints. Can print a report of the findings."
	icon = 'icons/obj/device.dmi'
	icon_state = "forensicnew"
	w_class = WEIGHT_CLASS_SMALL
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	var/scanning = FALSE
	var/list/log = list()
	var/range = 8
	var/view_check = TRUE
	var/forensicPrintCount = 0
	actions_types = list(/datum/action/item_action/display_detective_scan_results)

/datum/action/item_action/display_detective_scan_results
	name = "Display Forensic Scanner Results"

/datum/action/item_action/display_detective_scan_results/Trigger(trigger_flags)
	var/obj/item/detective_scanner/scanner = target
	if(istype(scanner))
		scanner.displayDetectiveScanResults(usr)

/obj/item/detective_scanner/attack_self(mob/user)
	if(log.len && !scanning)
		scanning = TRUE
		to_chat(user, span_notice("Printing report, please wait..."))
		addtimer(CALLBACK(src, .proc/PrintReport), 100)
	else
		to_chat(user, span_notice("The scanner has no logs or is in use."))

/obj/item/detective_scanner/proc/PrintReport()
	// Create our paper
	var/obj/item/paper/report_paper = new(get_turf(src))

	//This could be a global count like sec and med record printouts. See GLOB.data_core.medicalPrintCount AKA datacore.dm
	var/frNum = ++forensicPrintCount

	report_paper.name = text("FR-[] 'Forensic Record'", frNum)
	var/report_text = text("<center><B>Forensic Record - (FR-[])</B></center><HR><BR>", frNum)
	report_text += jointext(log, "<BR>")
	report_text += "<HR><B>Notes:</B><BR>"

	report_paper.add_raw_text(report_text)
	report_paper.update_appearance()

	if(ismob(loc))
		var/mob/M = loc
		M.put_in_hands(report_paper)
		to_chat(M, span_notice("Report printed. Log cleared."))

	// Clear the logs
	log = list()
	scanning = FALSE

/obj/item/detective_scanner/pre_attack_secondary(atom/A, mob/user, params)
	scan(A, user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/detective_scanner/afterattack(atom/A, mob/user, params)
	. = ..()
	scan(A, user)
	return FALSE

/obj/item/detective_scanner/proc/scan(atom/A, mob/user)
	set waitfor = FALSE
	if(!scanning)
		// Can remotely scan objects and mobs.
		if((get_dist(A, user) > range) || (!(A in view(range, user)) && view_check) || (loc != user))
			return

		scanning = TRUE

		user.visible_message(span_notice("\The [user] points the [src.name] at \the [A] and performs a forensic scan."))
		to_chat(user, span_notice("You scan \the [A]. The scanner is now analysing the results..."))


		// GATHER INFORMATION

		//Make our lists
		var/list/fingerprints = list()
		var/list/blood = GET_ATOM_BLOOD_DNA(A)
		var/list/fibers = GET_ATOM_FIBRES(A)
		var/list/reagents = list()

		var/target_name = A.name

		// Start gathering

		if(ishuman(A))

			var/mob/living/carbon/human/H = A
			if(!H.gloves)
				fingerprints += md5(H.dna.unique_identity)

		else if(!ismob(A))

			fingerprints = GET_ATOM_FINGERPRINTS(A)

			// Only get reagents from non-mobs.
			if(A.reagents && A.reagents.reagent_list.len)

				for(var/datum/reagent/R in A.reagents.reagent_list)
					reagents[R.name] = R.volume

					// Get blood data from the blood reagent.
					if(istype(R, /datum/reagent/blood))

						if(R.data["blood_DNA"] && R.data["blood_type"])
							var/blood_DNA = R.data["blood_DNA"]
							var/blood_type = R.data["blood_type"]
							LAZYINITLIST(blood)
							blood[blood_DNA] = blood_type

		// We gathered everything. Create a fork and slowly display the results to the holder of the scanner.

		var/found_something = FALSE
		add_log("<B>[station_time_timestamp()][get_timestamp()] - [target_name]</B>", 0)

		// Fingerprints
		if(length(fingerprints))
			sleep(30)
			add_log(span_info("<B>Prints:</B>"))
			for(var/finger in fingerprints)
				add_log("[finger]")
			found_something = TRUE

		// Blood
		if (length(blood))
			sleep(30)
			add_log(span_info("<B>Blood:</B>"))
			found_something = TRUE
			for(var/B in blood)
				add_log("Type: <font color='red'>[blood[B]]</font> DNA (UE): <font color='red'>[B]</font>")

		//Fibers
		if(length(fibers))
			sleep(30)
			add_log(span_info("<B>Fibers:</B>"))
			for(var/fiber in fibers)
				add_log("[fiber]")
			found_something = TRUE

		//Reagents
		if(length(reagents))
			sleep(30)
			add_log(span_info("<B>Reagents:</B>"))
			for(var/R in reagents)
				add_log("Reagent: <font color='red'>[R]</font> Volume: <font color='red'>[reagents[R]]</font>")
			found_something = TRUE

		// Get a new user
		var/mob/holder = null
		if(ismob(src.loc))
			holder = src.loc

		if(!found_something)
			add_log("<I># No forensic traces found #</I>", 0) // Don't display this to the holder user
			if(holder)
				to_chat(holder, span_warning("Unable to locate any fingerprints, materials, fibers, or blood on \the [target_name]!"))
		else
			if(holder)
				to_chat(holder, span_notice("You finish scanning \the [target_name]."))

		add_log("---------------------------------------------------------", 0)
		scanning = FALSE
		return

/obj/item/detective_scanner/proc/add_log(msg, broadcast = 1)
	if(scanning)
		if(broadcast && ismob(loc))
			var/mob/M = loc
			to_chat(M, msg)
		log += "&nbsp;&nbsp;[msg]"
	else
		CRASH("[src] [REF(src)] is adding a log when it was never put in scanning mode!")

/proc/get_timestamp()
	return time2text(world.time + 432000, ":ss")

/obj/item/detective_scanner/AltClick(mob/living/user)
	// Best way for checking if a player can use while not incapacitated, etc
	if(!user.canUseTopic(src, be_close=TRUE))
		return
	if(!LAZYLEN(log))
		to_chat(user, span_notice("Cannot clear logs, the scanner has no logs."))
		return
	if(scanning)
		to_chat(user, span_notice("Cannot clear logs, the scanner is in use."))
		return
	to_chat(user, span_notice("The scanner logs are cleared."))
	log = list()

/obj/item/detective_scanner/examine(mob/user)
	. = ..()
	if(LAZYLEN(log) && !scanning)
		. += span_notice("Alt-click to clear scanner logs.")

/obj/item/detective_scanner/proc/displayDetectiveScanResults(mob/living/user)
	// No need for can-use checks since the action button should do proper checks
	if(!LAZYLEN(log))
		to_chat(user, span_notice("Cannot display logs, the scanner has no logs."))
		return
	if(scanning)
		to_chat(user, span_notice("Cannot display logs, the scanner is in use."))
		return
	to_chat(user, span_notice("<B>Scanner Report</B>"))
	for(var/iterLog in log)
		to_chat(user, iterLog)
