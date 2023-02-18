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
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	/// if the scanner is currently busy processing
	var/scanner_busy = FALSE
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
		scanner.display_detective_scan_results(usr)

/obj/item/detective_scanner/attack_self(mob/user)
	if(!LAZYLEN(log))
		balloon_alert(user, "no logs!")
		return
	if(scanner_busy)
		balloon_alert(user, "scanner busy!")
		return
	scanner_busy = TRUE
	balloon_alert(user, "printing report...")
	addtimer(CALLBACK(src, PROC_REF(safe_print_report)), 10 SECONDS)

/**
 * safe_print_report - a wrapper proc for print_report
 *
 * Calls print_report(), and should a runtime occur within we can still reset the 'busy' state
 */
/obj/item/detective_scanner/proc/safe_print_report()
	print_report()
	scanner_busy = FALSE

/obj/item/detective_scanner/proc/print_report()
	// Create our paper
	var/obj/item/paper/report_paper = new(get_turf(src))

	//This could be a global count like sec and med record printouts. See GLOB.manifest.generalPrintCount AKA datacore.dm
	var/frNum = ++forensicPrintCount

	report_paper.name = text("FR-[] 'Forensic Record'", frNum)
	var/report_text = text("<center><B>Forensic Record - (FR-[])</B></center><HR><BR>", frNum)
	report_text += jointext(log, "<BR>")
	report_text += "<HR><B>Notes:</B><BR>"

	report_paper.add_raw_text(report_text)
	report_paper.update_appearance()

	if(ismob(loc))
		var/mob/printer = loc
		printer.put_in_hands(report_paper)
		balloon_alert(printer, "logs cleared")

	// Clear the logs
	log = list()

/obj/item/detective_scanner/pre_attack_secondary(atom/A, mob/user, params)
	safe_scan(user, atom_to_scan = A)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/detective_scanner/afterattack(atom/A, mob/user, params)
	. = ..()
	safe_scan(user, atom_to_scan = A)
	return . | AFTERATTACK_PROCESSED_ITEM

/**
 * safe_scan - a wrapper proc for scan()
 *
 * calls scan(), and should a runtime occur within we can still reset the 'busy' state
 */
/obj/item/detective_scanner/proc/safe_scan(mob/user, atom/atom_to_scan)
	set waitfor = FALSE
	if(scanner_busy)
		return
	if(!scan(user, atom_to_scan)) // this should only return FALSE if a runtime occurs during the scan proc, so ideally never
		balloon_alert(user, "scanner error!") // but in case it does, we 'error' instead of just bricking the scanner
	scanner_busy = FALSE

/**
 * scan - scans an atom for forensic data and outputs it to the mob holding the scanner
 *
 * This should always return TRUE barring a runtime
 */
/obj/item/detective_scanner/proc/scan(mob/user, atom/scanned_atom)
	// Can remotely scan objects and mobs.
	if((get_dist(scanned_atom, user) > range) || (!(scanned_atom in view(range, user)) && view_check) || (loc != user))
		return TRUE

	scanner_busy = TRUE


	user.visible_message(
		span_notice("\The [user] points the [src.name] at \the [scanned_atom] and performs a forensic scan."),
		ignored_mobs = user
	)
	to_chat(user, span_notice("You scan \the [scanned_atom]. The scanner is now analysing the results..."))


	// GATHER INFORMATION

	//Make our assoc list array
	// The keys are the headers used for it, and the value is a list of each line printed
	var/list/det_data = list()
	var/list/blood = GET_ATOM_BLOOD_DNA(scanned_atom)
	det_data[DETSCAN_CATEGORY_FIBER] = GET_ATOM_FIBRES(scanned_atom)

	var/target_name = scanned_atom.name

	// Start gathering

	if(ishuman(scanned_atom))

		var/mob/living/carbon/human/scanned_human = scanned_atom
		if(!scanned_human.gloves)
			LAZYADD(det_data[DETSCAN_CATEGORY_FINGERS], md5(scanned_human.dna?.unique_identity))

	else if(!ismob(scanned_atom))

		det_data[DETSCAN_CATEGORY_FINGERS] = GET_ATOM_FINGERPRINTS(scanned_atom)

		// Only get reagents from non-mobs.
		for(var/datum/reagent/present_reagent as anything in scanned_atom.reagents?.reagent_list)
			LAZYADD(det_data[DETSCAN_CATEGORY_DRINK], \
				"Reagent: <font color='red'>[present_reagent.name]</font> Volume: <font color='red'>[present_reagent.volume]</font>")

			// Get blood data from the blood reagent.
			if(!istype(present_reagent, /datum/reagent/blood))
				continue

			var/blood_DNA = present_reagent.data["blood_DNA"]
			var/blood_type = present_reagent.data["blood_type"]
			if(!blood_DNA || !blood_type)
				continue

			LAZYSET(blood, blood_DNA, blood_type)

	if(istype(scanned_atom, /obj/item/card/id))
		var/obj/item/card/id/user_id = scanned_atom
		for(var/region in DETSCAN_ACCESS_ORDER())
			var/access_in_region = SSid_access.accesses_by_region[region] & user_id.GetAccess()
			if(!length(access_in_region))
				continue
			LAZYADD(det_data[DETSCAN_CATEGORY_ACCESS], "[region]:")
			var/list/access_names = list()
			for(var/access_num in access_in_region)
				access_names += SSid_access.get_access_desc(access_num)
			LAZYADD(det_data[DETSCAN_CATEGORY_ACCESS], english_list(access_names))


	for(var/bloodtype in blood)
		LAZYADD(det_data[DETSCAN_CATEGORY_BLOOD], \
		"Type: <font color='red'>[blood[bloodtype]]</font> DNA (UE): <font color='red'>[bloodtype]</font>")

	// sends it off to be modified by the items
	SEND_SIGNAL(scanned_atom, COMSIG_DETECTIVE_SCANNED, user, det_data)

	// We gathered everything. Create a fork and slowly display the results to the holder of the scanner.

	var/found_something = FALSE
	add_log("<B>[station_time_timestamp()][get_timestamp()] - [target_name]</B>", 0)

	for(var/category in DETSCAN_DEFAULT_ORDER())
		if(!LAZYLEN(det_data[category]))
			continue  // no data found, move to next category
		sleep(3 SECONDS)
		add_log(span_info("<B>[category]:</B>"))
		for(var/line in det_data[category])
			add_log(line)
		found_something = TRUE

	// Make sure the original user is still holding the scanner before sending them the results
	var/mob/holder = null
	if(src.loc == user)
		holder = user
	else if(ismob(src.loc))
		holder = src.loc

	if(!found_something)
		add_log("<I># No forensic traces found #</I>", 0) // Don't display this to the holder user
		if(holder)
			to_chat(holder, span_warning("Unable to locate any fingerprints, materials, fibers, or blood on \the [target_name]!"))
	else
		if(holder)
			to_chat(holder, span_notice("You finish scanning \the [target_name]."))

	add_log("---------------------------------------------------------", 0)
	return TRUE

/obj/item/detective_scanner/proc/add_log(msg, broadcast = 1)
	if(scanner_busy)
		if(broadcast && ismob(loc))
			var/mob/logger = loc
			to_chat(logger, msg)
		log += "&nbsp;&nbsp;[msg]"
	else
		CRASH("[src] [REF(src)] is adding a log when it was never put in scanning mode!")

/proc/get_timestamp()
	return time2text(world.time + 432000, ":ss")

/obj/item/detective_scanner/AltClick(mob/living/user)
	// Best way for checking if a player can use while not incapacitated, etc
	if(!user.can_perform_action(src))
		return
	if(!LAZYLEN(log))
		balloon_alert(user, "no logs!")
		return
	if(scanner_busy)
		balloon_alert(user, "scanner busy!")
		return
	balloon_alert(user, "deleting logs...")
	if(do_after(user, 3 SECONDS, target = src))
		balloon_alert(user, "logs cleared")
		log = list()

/obj/item/detective_scanner/examine(mob/user)
	. = ..()
	if(LAZYLEN(log) && !scanner_busy)
		. += span_notice("Alt-click to clear scanner logs.")

/obj/item/detective_scanner/proc/display_detective_scan_results(mob/living/user)
	// No need for can-use checks since the action button should do proper checks
	if(!LAZYLEN(log))
		balloon_alert(user, "no logs!")
		return
	if(scanner_busy)
		balloon_alert(user, "scanner busy!")
		return
	to_chat(user, span_notice("<B>Scanner Report</B>"))
	for(var/iterLog in log)
		to_chat(user, iterLog)
