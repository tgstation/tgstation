/obj/machinery/computer/operating/New()
	..()
	for(var/obj/machinery/optable/O in world)
		if(src.id == O.id)
			src.table = O

/obj/machinery/computer/operating/attack_ai(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)

/obj/machinery/computer/operating/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)


/obj/machinery/computer/operating/proc/interact(mob/user)
	if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
		if (!istype(user, /mob/living/silicon))
			user.machine = null
			user << browse(null, "window=op")
			return

	user.machine = src
	var/dat = "<HEAD><TITLE>Operating Computer</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>\n"
	dat += "<A HREF='?src=\ref[user];mach_close=op'>Close</A><br><br>" //| <A HREF='?src=\ref[user];update=1'>Update</A>"
	if(src.table && (src.table.check_victim()))
		src.victim = src.table.victim
		dat += {"
<B>Patient Information:</B><BR>
<BR>
<B>Name:</B> [src.victim.real_name]<BR>
<B>Age:</B> [src.victim.age]<BR>
<B>Blood Type:</B> [src.victim.b_type]<BR>
<BR>
<B>Health:</B> [src.victim.health]<BR>
<B>Brute Damage:</B> [src.victim.bruteloss]<BR>
<B>Toxins Damage:</B> [src.victim.toxloss]<BR>
<B>Fire Damage:</B> [src.victim.fireloss]<BR>
<B>Suffocation Damage:</B> [src.victim.oxyloss]<BR>
<B>Patient Status:</B> [src.victim.stat ? "Non-responsive" : "Stable"]<BR>
"}
	else
		src.victim = null
		dat += {"
<B>Patient Information:</B><BR>
<BR>
<B>No Patient Detected</B>
"}
	user << browse(dat, "window=op")
	onclose(user, "op")

/obj/machinery/computer/operating/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src
//		if (href_list["update"])
//			src.interact(usr)
	return

/obj/machinery/computer/operating/process()
	if(!(stat & (NOPOWER|BROKEN)) )
		use_power(500)

	src.updateDialog()