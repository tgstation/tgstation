/obj/machinery/computer/cloning
	name = "cloning console"
	desc = "Used to clone people and manage DNA."
	icon_screen = "dna"
	icon_keyboard = "med_key"
	circuit = /obj/item/weapon/circuitboard/computer/cloning
	req_access = list(access_heads) //Only used for record deletion right now.

	var/list/network // The "network" of all cloning machines

	var/temp = "Inactive"
	var/scantemp_ckey
	var/scantemp = "Ready to Scan"
	var/menu = 1 //Which menu screen to display
	var/list/records
	var/datum/data/record/active_record = null
	var/obj/item/weapon/disk/data/diskette = null //Mostly so the geneticist can steal everything.
	var/loading = 0 // Nice loading text

/obj/machinery/computer/cloning/New()
	..()
	addtimer(src, "update_network", 5)
	records = list()

/obj/machinery/computer/cloning/Destroy()
	for(var/obj/machinery/cloning/M in network)
		M.computer = null
	network.Cut()
	. = ..()

/obj/machinery/computer/cloning/process()
	for(var/obj/machinery/cloning/scanner/scanner in network)
		if(scanner.autoscan && scanner.occupant)
			scan_mob(scanner.occupant)

	var/list/clonables = list()
	for(var/datum/cloning_record/R in records)
		if(R.can_clone())
			clonables += R

	for(var/obj/machinery/cloning/pod/pod in network)
		if(pod.ready_to_clone() && pod.autoclone)
			pod.growclone(popleft(cloneables))

/obj/machinery/computer/cloning/proc/update_network()
	network = list()

	var/list/new_nodes = list(src)
	var/list/scanned_nodes = list()

	while(new_nodes.len)
		var/obj/machinery/cloning/O = pop(new_nodes)
		scanned_nodes += O
		for(var/dir in list(NORTH, EAST, SOUTH, WEST))
			var/turf/T = get_step(src, dir)
			var/obj/machinery/cloning/M = locate(/obj/machinery/cloning, T)
			if(M in scanned_nodes || M in new_nodes)
				continue
			if(istype(M) && !M.computer)
				new_nodes += M
				M.computer = src

/obj/machinery/computer/cloning/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/disk/data)) //INSERT SOME DISKETTES
		if (!src.diskette)
			if(!user.drop_item())
				return
			W.forceMove(src)
			src.diskette = W
			user << "<span class='notice'>You insert [W].</span>"
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
			src.updateUsrDialog()
	else
		return ..()

/obj/machinery/computer/cloning/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "cloning_computer", name, 550, 550, master_ui, state)
		ui.open()

/obj/machinery/computer/cloning/ui_data()
	var/list/data = list()
	return data

/obj/machinery/computer/cloning/ui_act(action, params)
	if(..())
		return

/obj/machinery/computer/cloning/proc/scan_mob(mob/living/carbon/human/subject)
	if (!istype(subject))
		scantemp = "<font class='bad'>Unable to locate valid genetic data.</font>"
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return
	if (!subject.getorgan(/obj/item/organ/brain))
		scantemp = "<font class='bad'>No signs of intelligence detected.</font>"
		playsound(src, 'sound/machines/terminal_alert.ogg', 50, 0)
		return
	if (subject.suiciding == 1 || subject.hellbound)
		scantemp = "<font class='bad'>Subject's brain is not responding to scanning stimuli.</font>"
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return
	if ((subject.disabilities & NOCLONE) && (src.scanner.scan_level < 2))
		scantemp = "<font class='bad'>Subject no longer contains the fundamental materials required to create a living clone.</font>"
		playsound(src, 'sound/machines/terminal_alert.ogg', 50, 0)
		return
	if ((!subject.ckey) || (!subject.client))
		scantemp = "<font class='bad'>Mental interface failure.</font>"
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return
	if (find_record("ckey", subject.ckey, records))
		scantemp = "<font class='average'>Subject already in database.</font>"
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return

	var/datum/cloning_record/R = new()
	if(subject.dna.species)
		// We store the instance rather than the path, because some
		// species (abductors, slimepeople) store state in their
		// species datums
		R.fields["mrace"] = subject.dna.species
	else
		var/datum/species/rando_race = pick(config.roundstart_races)
		R.fields["mrace"] = rando_race.type
	R.fields["ckey"] = subject.ckey
	R.fields["name"] = subject.real_name
	R.fields["id"] = copytext(md5(subject.real_name), 2, 6)
	R.fields["UE"] = subject.dna.unique_enzymes
	R.fields["UI"] = subject.dna.uni_identity
	R.fields["SE"] = subject.dna.struc_enzymes
	R.fields["blood_type"] = subject.dna.blood_type
	R.fields["features"] = subject.dna.features
	R.fields["factions"] = subject.faction

	if(!isnull(subject.mind)) //Save that mind so traitors can continue traitoring after cloning.
		R.fields["mind"] = "\ref[subject.mind]"

	src.records += R
	scantemp = "Subject successfully scanned."
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
