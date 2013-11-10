/obj/machinery/computer/operating
	name = "operating computer"
	icon_state = "operating"
	density = 1
	anchored = 1.0
	circuit = /obj/item/weapon/circuitboard/operating
	var/mob/living/carbon/human/patient = null
	var/obj/structure/optable/table = null


/obj/machinery/computer/operating/New()
	..()
	for(var/dir in cardinal)
		table = locate(/obj/structure/optable, get_step(src, dir))
		if(table)
			table.computer = src
			break


/obj/machinery/computer/operating/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/computer/operating/interact(mob/user)
	if(get_dist(src, user) > 1 || stat & (BROKEN|NOPOWER))
		if(!istype(user, /mob/living/silicon))
			user.unset_machine()
			user << browse(null, "window=op")
			return

	user.set_machine(src)
	var/dat = "<HEAD><TITLE>Operating Computer</TITLE><META HTTP-EQUIV='Refresh' CONTENT='10'></HEAD><BODY>"
	if(table)
		dat += "<B>Patient information:</B><BR>"
		if(table.check_patient())
			patient = table.patient
			dat += {"<B>Patient Status:</B> [patient.stat ? "Non-Responsive" : "Stable"]<BR>
					<B>Blood Type:</B> [patient.blood_type]<BR>
					<BR>
					<B>Health:</B> [round(patient.health)]<BR>
					<B>Brute Damage:</B> [round(patient.getBruteLoss())]<BR>
					<B>Toxins Damage:</B> [round(patient.getToxLoss())]<BR>
					<B>Fire Damage:</B> [round(patient.getFireLoss())]<BR>
					<B>Suffocation Damage:</B> [round(patient.getOxyLoss())]<BR>
					"}
			if(patient.surgeries.len)
				dat += "<BR><B>Initiated Procedures:</B><BR>"
				for(var/datum/surgery/procedure in patient.surgeries)
					dat += "[procedure.name]<BR>"
		else
			patient = null
			dat += "<B>No patient detected</B>"
	else
		dat += "<B>Operating table not found.</B>"
	dat += "</BODY>"

	user << browse(dat, "window=op")
	onclose(user, "op")