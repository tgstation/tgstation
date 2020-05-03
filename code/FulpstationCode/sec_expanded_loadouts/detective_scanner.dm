#define HEALTH_SCANNER_RANGE 1


/obj/item/detective_scanner/proc/bio_scan(mob/user, mob/living/M)

	var/health_scan = healthscan(user, M, TRUE, TRUE, TRUE)
	scanning = TRUE
	add_log(health_scan, FALSE)
	scanning = FALSE

/obj/item/detective_scanner/proc/chemscan(mob/user, atom/A)
	if(istype(A))
		if(A.reagents)
			scanning = TRUE
			var/list/reagent_report = list()
			add_log("<B>[station_time_timestamp()][get_timestamp()] - [A]: Chemical Analysis:</B>", FALSE)
			if(A.reagents.reagent_list.len)
				reagent_report += "<span class='notice'>Subject contains the following reagents:<br></span>"
				for(var/datum/reagent/R in A.reagents.reagent_list)
					reagent_report += "<span class='notice'>[round(R.volume, 0.001)] units of [R.name][R.overdosed == 1 && istype(A, /mob/living) ? "</span> - <span class='boldannounce'>OVERDOSING</span>" : ".</span>"]<br>"
			else
				reagent_report += "<span class='notice'>Subject contains no reagents.<br></span>"
			if(istype(A, /mob/living))
				var/mob/living/M = A
				if(M.reagents.addiction_list.len)
					reagent_report +="<span class='boldannounce'>Subject is addicted to the following reagents:<br></span>"
					for(var/datum/reagent/R in M.reagents.addiction_list)
						reagent_report += "<span class='alert'>[R.name]</span><br>"
				else
					reagent_report += "<span class='notice'>Subject is not addicted to any reagents.<br></span>"
			add_log(reagent_report.Join())
			scanning = FALSE

/obj/item/detective_scanner/proc/attack_mode(atom/A, mob/user, afterattack)
	if(!mode)
		scan(A, user)
		return

	if(get_dist(A, user) > HEALTH_SCANNER_RANGE)
		return

	if(!user)
		return

	chemscan(user, A)

	if(!istype(A, /mob/living))
		return

	bio_scan(user, A)



/obj/item/detective_scanner/proc/self_mode(mob/user)
	mode = !mode
	to_chat(usr, "You change [src] to [mode ? "biochem" : "forensic"] mode.")
	update_icon()


/obj/item/detective_scanner/verb/toggle_mode()
	set name = "Print Forensic Scanner Report"
	set category = "Object"
	set src in view(1)

	if(!isliving(usr))
		to_chat(usr, "<span class='warning'>You can't do that!</span>")
		return

	if(usr.incapacitated())
		return

	var/time_differential = world.time - print_time_stamp
	if(time_differential < print_cooldown)
		to_chat(usr, "<span class='warning'>[src] isn't yet ready to print! It will be ready in [(print_cooldown - time_differential) * 0.1] more seconds.</span>")
		return

	if(log.len && !scanning)
		scanning = 1
		to_chat(usr, "<span class='notice'>[src] prints out its report...</span>")
		print_time_stamp = world.time
		PrintReport()
	else
		to_chat(usr, "<span class='notice'>The scanner has no logs or is in use.</span>")


/obj/item/detective_scanner/verb/clear_logs()
	set name = "Clear Forensic Scanner Logs"
	set category = "Object"
	set src in view(1)

	if(!isliving(usr))
		to_chat(usr, "<span class='warning'>You can't do that!</span>")
		return

	if(usr.incapacitated())
		return

	var/obj/item/card/id/I = usr.get_idcard(TRUE)

	if(!I || !check_access(I))
		to_chat(usr, "<span class='warning'>Inadequate security clearance. Access denied.</span>")
		playsound(loc, SEC_RADIO_SCAN_SOUND_DENY, get_clamped_volume(), TRUE, -1)
		return

	to_chat(usr, "<span class='warning'>You purge the scanner's logs.</span>")
	log = list()
	playsound(loc, SEC_BODY_CAM_SOUND, get_clamped_volume(), TRUE, -1)



/obj/item/detective_scanner/update_icon()
	icon_state = "forensicnew-[mode]"
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/detective_scanner/attackby(obj/item/W, mob/user, params)
	if(!istype(W, /obj/item/disk/forensic))
		return
	var/obj/item/disk/forensic/F = W

	var/obj/item/card/id/I = user.get_idcard(TRUE)

	if(!I || !check_access(I))
		to_chat(usr, "<span class='warning'>Inadequate security clearance. Access denied.</span>")
		playsound(loc, SEC_RADIO_SCAN_SOUND_DENY, get_clamped_volume(), TRUE, -1)
		return

	if(!F.write_mode) //Copy the log to the disk if we're set to read mode.
		F.disk_log = log
		playsound(loc, SEC_BODY_CAM_SOUND, get_clamped_volume(), TRUE, -1)
		to_chat(usr, "<span class='notice'>You copied the scanner's log to the disk.</span>")

	else if(LAZYLEN(F.disk_log)) //So we don't accidentally overwrite the scanner logs with nothing
		log = F.disk_log
		playsound(loc, SEC_BODY_CAM_SOUND, get_clamped_volume(), TRUE, -1)
		to_chat(usr, "<span class='notice'>You overwrote the scanner's log with the disk's contents.</span>")

//Classic floppy back ups!
/obj/item/disk/forensic
	name = "forensic data disk"
	icon_state = "datadisk0" //Gosh I hope syndies don't mistake them for the nuke disk.
	desc = "Charmingly antiquated yet undeniably effective. Used to read and write data to and from the forensic scanner for record storage. Can be labeled with a pen."
	var/list/disk_log = list()
	var/write_mode = FALSE //This determines whether we read or write data from/to the forensic scanner
	obj_flags = UNIQUE_RENAME //Allows us to name and identify the disk.


/obj/item/disk/forensic/attack_self(mob/user)
	if(!write_mode)
		to_chat(usr, "<span class='notice'>You set [src] to write mode. It will now overwrite the forensic scanner's logs with its contents.</span>")
		write_mode = TRUE

	else
		to_chat(usr, "<span class='notice'>You set [src] to read mode. It will now copy data from the forensic scanner's logs.</span>")
		write_mode = FALSE

	playsound(loc, 'sound/machines/click.ogg', get_clamped_volume(), TRUE, -1)