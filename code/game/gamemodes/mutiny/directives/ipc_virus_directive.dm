datum/directive/ipc_virus
	special_orders = list(
		"Terminate employment of all IPC personnel.",
		"Extract the Positronic Brains from IPC units.",
		"Mount the Positronic Brains into Cyborgs.")

	var/list/roboticist_roles = list(
		"Research Director",
		"Roboticist"
	)

	var/list/brains_to_enslave = list()
	var/list/cyborgs_to_make = list()
	var/list/ids_to_terminate = list()

	proc/get_ipcs()
		var/list/machines[0]
		for(var/mob/M in player_list)
			if (M.is_ready() && M.get_species() == "Machine")
				machines.Add(M)
		return machines

	proc/get_roboticists()
		var/list/roboticists[0]
		for(var/mob/M in player_list)
			if (M.is_ready() && roboticist_roles.Find(M.mind.assigned_role))
				roboticists.Add(M)
		return roboticists

datum/directive/ipc_virus/initialize()
	for(var/mob/living/carbon/human/H in get_ipcs())
		brains_to_enslave.Add(H.mind)
		cyborgs_to_make.Add(H.mind)
		ids_to_terminate.Add(H.wear_id)

datum/directive/ipc_virus/get_description()
	return {"
		<p>
			IPC units have been found to be infected with a violent and undesired virus in Virgus Ferrorus system.
			Risk to [station_name()] IPC units has not been assessed. Further information is classified.
		</p>
	"}

datum/directive/ipc_virus/meets_prerequisites()
	var/list/ipcs = get_ipcs()
	var/list/roboticists = get_roboticists()
	return ipcs.len > 2 && roboticists.len > 1

datum/directive/ipc_virus/directives_complete()
	return brains_to_enslave.len == 0 && cyborgs_to_make.len == 0 && ids_to_terminate.len == 0

datum/directive/ipc_virus/get_remaining_orders()
	var/text = ""
	for(var/brain in brains_to_enslave)
		text += "<li>Debrain [brain]</li>"

	for(var/brain in cyborgs_to_make)
		text += "<li>Enslave [brain] as a Cyborg</li>"

	for(var/id in ids_to_terminate)
		text += "<li>Terminate [id]</li>"

	return text

/hook/debrain/proc/debrain_directive(var/obj/item/organ/brain/B)
	var/datum/directive/ipc_virus/D = get_directive("ipc_virus")
	if (!D) return 1

	if(B && B.brainmob && B.brainmob.mind && D.brains_to_enslave.Find(B.brainmob.mind))
		D.brains_to_enslave.Remove(B.brainmob.mind)

	return 1

/hook/borgify/proc/borgify_directive(mob/living/silicon/robot/cyborg)
	var/datum/directive/ipc_virus/D = get_directive("ipc_virus")
	if (!D) return 1

	if(D.cyborgs_to_make.Find(cyborg.mind))
		D.cyborgs_to_make.Remove(cyborg.mind)

	// In case something glitchy happened and the victim got
	// borged without us tracking the brain removal, go ahead
	// and update that list too.
	if(D.brains_to_enslave.Find(cyborg.mind))
		D.brains_to_enslave.Remove(cyborg.mind)

	return 1

/hook/terminate_employee/proc/ipc_termination(obj/item/weapon/card/id)
	var/datum/directive/ipc_virus/D = get_directive("ipc_virus")
	if (!D) return 1

	if(D.ids_to_terminate && D.ids_to_terminate.Find(id))
		D.ids_to_terminate.Remove(id)

	return 1
