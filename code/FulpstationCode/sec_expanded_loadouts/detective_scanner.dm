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

	if(log.len && !scanning)
		scanning = 1
		to_chat(usr, "<span class='notice'>Printing report, please wait...</span>")
		addtimer(CALLBACK(src, .proc/PrintReport), 30)
	else
		to_chat(usr, "<span class='notice'>The scanner has no logs or is in use.</span>")


/obj/item/detective_scanner/update_icon()
	icon_state = "forensicnew-[mode]"
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()