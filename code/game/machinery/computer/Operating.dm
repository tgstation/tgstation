/obj/machinery/computer/operating
	name = "operating computer"
	desc = "Used to monitor the vitals of a patient during surgery."
	icon_screen = "crew"
	icon_keyboard = "med_key"
	circuit = /obj/item/weapon/circuitboard/computer/operating
	var/mob/living/carbon/human/patient = null
	var/obj/structure/table/optable/table = null

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/operating/Initialize()
	..()
	find_table()

/obj/machinery/computer/operating/proc/find_table()
	for(var/dir in GLOB.cardinal)
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
