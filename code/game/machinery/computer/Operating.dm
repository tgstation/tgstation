//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/operating
	name = "Operating Computer"
	density = 1
	anchored = 1.0
	icon_state = "operating"
	circuit = "/obj/item/weapon/circuitboard/operating"
	var/mob/living/carbon/human/victim = null
	var/obj/machinery/optable/optable = null

	l_color = "#0000FF"

/obj/machinery/computer/operating/New()
	..()
	spawn(5)
		updatemodules()
		return
	return

/obj/machinery/computer/operating/proc/updatemodules()
	src.optable = findoptable()

/obj/machinery/computer/operating/proc/findoptable()
	var/obj/machinery/optable/optablef = null

	// Loop through every direction
	for(dir in list(NORTH,EAST,SOUTH,WEST))

		// Try to find a scanner in that direction
		optablef = locate(/obj/machinery/optable, get_step(src, dir))

		// If found, then we break, and return the scanner
		if (!isnull(optablef))
			break

	// If no scanner was found, it will return null
	return optablef

/obj/machinery/computer/operating/attack_ai(user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/computer/med_data/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/operating/attack_hand(mob/user as mob)
	if(..())
		return
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return

	updatemodules()

	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\computer\Operating.dm:41: var/dat = "<HEAD><TITLE>Operating Computer</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	var/dat = {"<HEAD><TITLE>Operating Computer</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>"}
	// END AUTOFIX
	if(!isnull(src.optable) && (src.optable.check_victim()))
		src.victim = src.optable.victim
		dat += {"
<B>Patient Information:</B><BR>
<BR>
<B>Name:</B> [src.victim.real_name]<BR>
<B>Age:</B> [src.victim.age]<BR>
<B>Blood Type:</B> [src.victim.b_type]<BR>
<BR>
<B>Health:</B> [src.victim.health]<BR>
<B>Brute Damage:</B> [src.victim.getBruteLoss()]<BR>
<B>Toxins Damage:</B> [src.victim.getToxLoss()]<BR>
<B>Fire Damage:</B> [src.victim.getFireLoss()]<BR>
<B>Suffocation Damage:</B> [src.victim.getOxyLoss()]<BR>
<B>Patient Status:</B> [src.victim.stat ? "Non-Responsive" : "Stable"]<BR>
<BR>
<A HREF='?src=\ref[user];mach_close=op'>Close</A>"}
	else
		src.victim = null
		dat += {"
<B>Patient Information:</B><BR>
<BR>
<B>No Patient Detected</B><BR>
<BR>
<A HREF='?src=\ref[user];mach_close=op'>Close</A>"}
	user << browse(dat, "window=op")
	user.set_machine(src)
	onclose(user, "op")


/obj/machinery/computer/operating/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)
	return


/obj/machinery/computer/operating/process()
	if(..())
		src.updateDialog()
