<<<<<<< HEAD
/obj/machinery/computer/operating
	name = "operating computer"
	desc = "Used to monitor the vitals of a patient during surgery."
	icon_screen = "crew"
	icon_keyboard = "med_key"
	circuit = /obj/item/weapon/circuitboard/computer/operating
	var/mob/living/carbon/human/patient = null
	var/obj/structure/table/optable/table = null


/obj/machinery/computer/operating/New()
	..()
	if(ticker)
		find_table()

/obj/machinery/computer/operating/initialize()
	find_table()

/obj/machinery/computer/operating/proc/find_table()
	for(var/dir in cardinal)
		table = locate(/obj/structure/table/optable, get_step(src, dir))
		if(table)
			table.computer = src
			break


/obj/machinery/computer/operating/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/operating/interact(mob/user)
	var/dat = ""
	if(table)
		dat += "<B>Patient information:</B><BR>"
		if(table.check_patient())
			patient = table.patient
			dat += get_patient_info()
		else
			patient = null
			dat += "<B>No patient detected</B>"
	else
		dat += "<B>Operating table not found.</B>"

	var/datum/browser/popup = new(user, "op", "Operating Computer", 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/operating/proc/get_patient_info()
	var/dat = {"
				<div class='statusLabel'>Patient:</div> [patient.stat ? "<span class='bad'>Non-Responsive</span>" : "<span class='good'>Stable</span>"]<BR>
				<div class='statusLabel'>Blood Type:</div> [patient.dna.blood_type]

				<BR>
				<div class='line'><div class='statusLabel'>Health:</div><div class='progressBar'><div style='width: [max(patient.health, 0)]%;' class='progressFill good'></div></div><div class='statusValue'>[patient.health]%</div></div>
				<div class='line'><div class='statusLabel'>\> Brute Damage:</div><div class='progressBar'><div style='width: [max(patient.getBruteLoss(), 0)]%;' class='progressFill bad'></div></div><div class='statusValue'>[patient.getBruteLoss()]%</div></div>
				<div class='line'><div class='statusLabel'>\> Resp. Damage:</div><div class='progressBar'><div style='width: [max(patient.getOxyLoss(), 0)]%;' class='progressFill bad'></div></div><div class='statusValue'>[patient.getOxyLoss()]%</div></div>
				<div class='line'><div class='statusLabel'>\> Toxin Content:</div><div class='progressBar'><div style='width: [max(patient.getToxLoss(), 0)]%;' class='progressFill bad'></div></div><div class='statusValue'>[patient.getToxLoss()]%</div></div>
				<div class='line'><div class='statusLabel'>\> Burn Severity:</div><div class='progressBar'><div style='width: [max(patient.getFireLoss(), 0)]%;' class='progressFill bad'></div></div><div class='statusValue'>[patient.getFireLoss()]%</div></div>

				"}
	if(patient.surgeries.len)
		dat += "<BR><BR><B>Initiated Procedures</B><div class='statusDisplay'>"
		for(var/datum/surgery/procedure in patient.surgeries)
			dat += "[capitalize(procedure.name)]<BR>"
			var/datum/surgery_step/surgery_step = procedure.get_surgery_step()
			dat += "Next step: [capitalize(surgery_step.name)]<BR>"
		dat += "</div>"
	return dat
=======
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/operating
	name = "Operating Computer"
	density = 1
	anchored = 1.0
	icon_state = "operating"
	circuit = "/obj/item/weapon/circuitboard/operating"
	var/mob/living/carbon/human/victim = null
	var/obj/machinery/optable/optable = null

	light_color = LIGHT_COLOR_BLUE

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

	var/dat = {"<HEAD><TITLE>Operating Computer</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>"}
	if(!isnull(src.optable) && (src.optable.check_victim()))
		src.victim = src.optable.victim
		dat += {"
<B>Patient Information:</B><BR>
<BR>
<B>Name:</B> [src.victim.real_name]<BR>
<B>Age:</B> [src.victim.age]<BR>
<B>Blood Type:</B> [src.victim.dna.b_type]<BR>
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
		return 1
	else
		usr.set_machine(src)
	return

/obj/machinery/computer/operating/process()
	if(..())
		src.updateDialog()
	update_icon()

/obj/machinery/computer/operating/update_icon()
	..()
	if(!(stat & (BROKEN | NOPOWER)))
		updatemodules()
		if(!isnull(src.optable) && (src.optable.check_victim()))
			src.victim = src.optable.victim
			if(victim.stat == DEAD)
				icon_state = "operating-dead"
			else
				icon_state = "operating-living"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
