
//cael - some changes here. the analysis pad is entirely new

/obj/machinery/anomaly/artifact_analyser
	name = "Artifact Analyser"
	desc = "Studies the structure of artifacts to discover their uses."
	icon = 'virology.dmi'
	icon_state = "analyser"
	anchored = 1
	density = 1
	var/scan_progress = 0
	var/scan_num = 0
	var/obj/scanned_obj
	var/obj/machinery/scanner/owned_scanner = null

/obj/machinery/anomaly/artifact_analyser/New()
	..()

	//connect to a nearby scanner pad
	owned_scanner = locate(/obj/machinery/scanner) in get_step(src, dir)
	if(!owned_scanner)
		owned_scanner = locate(/obj/machinery/scanner) in orange(1, src)

/obj/machinery/anomaly/artifact_analyser/attack_hand(var/mob/user as mob)
	if(stat & (NOPOWER|BROKEN) || get_dist(src, user) > 1)
		user.unset_machine(src)
		return

	var/dat = "<B>Anomalous material analyser</B><BR>"
	dat += "<HR>"
	if(!owned_scanner)
		owned_scanner = locate() in orange(1, src)

	if(!owned_scanner)
		dat += "<b><font color=red>Unable to locate analysis pad.</font></b><br>"
	else if(scan_progress)
		dat += "<b>Please wait. Analysis in progress.</b><br>"
	else
		dat += "Place an item to be scanned on the pad to begin."

	dat += "<hr>"
	dat += "<a href='?src=\ref[src]'>Refresh</a> <a href='?src=\ref[src];close=1'>Close</a>"
	user << browse(dat, "window=artanalyser;size=450x500")
	user.set_machine(src)
	onclose(user, "artanalyser")
