//Common

/obj/machinery/abductor
	var/team = 0

/obj/machinery/abductor/proc/IsAgent(mob/living/carbon/human/H)
	if(H.dna.species.id == "abductor")
		var/datum/species/abductor/S = H.dna.species
		return S.agent
	return 0

/obj/machinery/abductor/proc/IsScientist(mob/living/carbon/human/H)
	if(H.dna.species.id == "abductor")
		var/datum/species/abductor/S = H.dna.species
		return S.scientist
	return 0

//Console

/obj/machinery/abductor/console
	name = "Abductor console"
	desc = "Ship command center."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "console"
	density = 1
	anchored = 1
	var/obj/item/device/abductor/gizmo/gizmo
	var/obj/item/clothing/suit/armor/abductor/vest/vest
	var/obj/machinery/abductor/experiment/experiment
	var/obj/machinery/abductor/pad/pad
	var/obj/machinery/computer/camera_advanced/abductor/camera
	var/list/datum/icon_snapshot/disguises = list()

/obj/machinery/abductor/console/attack_hand(mob/user)
	if(..())
		return
	if(!isabductor(user))
		user << "<span class='warning'>You start mashing alien buttons at random!</span>"
		if(do_after(user,100, target = src))
			TeleporterSend()
		return
	user.set_machine(src)
	var/dat = ""
	dat += "<H3> Abductsoft 3000 </H3>"

	if(experiment != null)
		var/points = experiment.points
		dat += "Collected Samples : [points] <br>"
		dat += "<b>Transfer data in exchange for supplies:</b><br>"
		dat += "<a href='?src=\ref[src];dispense=baton'>Advanced Baton</A><br>"
		dat += "<a href='?src=\ref[src];dispense=helmet'>Agent Helmet</A><br>"
		dat += "<a href='?src=\ref[src];dispense=vest'>Agent Vest</A><br>"
		dat += "<a href='?src=\ref[src];dispense=silencer'>Radio Silencer</A><br>"
		dat += "<a href='?src=\ref[src];dispense=tool'>Science Tool</A><br>"
	else
		dat += "<span class='bad'>NO EXPERIMENT MACHINE DETECTED</span> <br>"

	if(pad!=null)
		dat += "<span class='bad'>Emergency Teleporter System.</span>"
		dat += "<span class='bad'>Consider using primary observation console first.</span>"
		dat += "<a href='?src=\ref[src];teleporter_send=1'>Activate Teleporter</A><br>"
		if(gizmo!=null && gizmo.marked!=null)
			dat += "<a href='?src=\ref[src];teleporter_retrieve=1'>Retrieve Mark</A><br>"
		else
			dat += "<span class='linkOff'>Retrieve Mark</span><br>"
	else
		dat += "<span class='bad'>NO TELEPAD DETECTED</span></br>"

	if(vest!=null)
		dat += "<h4> Agent Vest Mode </h4><br>"
		var/mode = vest.mode
		if(mode == VEST_STEALTH)
			dat += "<a href='?src=\ref[src];flip_vest=1'>Combat</A>"
			dat += "<span class='linkOff'>Stealth</span>"
		else
			dat += "<span class='linkOff'>Combat</span>"
			dat += "<a href='?src=\ref[src];flip_vest=1'>Stealth</A>"

		dat+="<br>"
		dat += "<a href='?src=\ref[src];select_disguise=1'>Select Agent Vest Disguise</a><br>"
		dat += "<a href='?src=\ref[src];toggle_vest=1'>[vest.flags & NODROP ? "Unlock" : "Lock"] Vest</a><br>"
	else
		dat += "<span class='bad'>NO AGENT VEST DETECTED</span>"
	var/datum/browser/popup = new(user, "computer", "Abductor Console", 400, 500)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/abductor/console/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)
	if(href_list["teleporter_send"])
		TeleporterSend()
	else if(href_list["teleporter_retrieve"])
		TeleporterRetrieve()
	else if(href_list["flip_vest"])
		FlipVest()
	else if(href_list["toggle_vest"])
		toggle_vest()
	else if(href_list["select_disguise"])
		SelectDisguise()
	else if(href_list["dispense"])
		switch(href_list["dispense"])
			if("baton")
				Dispense(/obj/item/weapon/abductor_baton,cost=2)
			if("helmet")
				Dispense(/obj/item/clothing/head/helmet/abductor)
			if("silencer")
				Dispense(/obj/item/device/abductor/silencer)
			if("tool")
				Dispense(/obj/item/device/abductor/gizmo)
			if("vest")
				Dispense(/obj/item/clothing/suit/armor/abductor/vest)
	src.updateUsrDialog()


/obj/machinery/abductor/console/proc/TeleporterRetrieve()
	if(gizmo!=null && pad!=null && gizmo.marked)
		pad.Retrieve(gizmo.marked)

/obj/machinery/abductor/console/proc/TeleporterSend()
	if(pad!=null)
		pad.Send()

/obj/machinery/abductor/console/proc/FlipVest()
	if(vest!=null)
		vest.flip_mode()

/obj/machinery/abductor/console/proc/SelectDisguise(remote=0)
	var/list/entries = list()
	var/tempname
	var/datum/icon_snapshot/temp
	for(var/i = 1; i <= disguises.len; i++)
		temp = disguises[i]
		tempname = temp.name
		entries["[tempname]"] = disguises[i]
	var/entry_name = input( "Choose Disguise", "Disguise") in entries
	var/datum/icon_snapshot/chosen = entries[entry_name]
	if(chosen && (remote || in_range(usr,src)))
		vest.SetDisguise(chosen)

/obj/machinery/abductor/console/proc/SetDroppoint(turf/open/location,user)
	if(!istype(location))
		user << "<span class='warning'>That place is not safe for the specimen.</span>"
		return

	if(pad)
		pad.teleport_target = location
		user << "<span class='notice'>Location marked as test subject release point.</span>"


/obj/machinery/abductor/console/proc/Initialize()

	for(var/obj/machinery/abductor/pad/p in machines)
		if(p.team == team)
			pad = p
			break

	for(var/obj/machinery/abductor/experiment/e in machines)
		if(e.team == team)
			experiment = e
			e.console = src

	for(var/obj/machinery/computer/camera_advanced/abductor/c in machines)
		if(c.team == team)
			camera = c
			c.console = src

/obj/machinery/abductor/console/proc/AddSnapshot(mob/living/carbon/human/target)
	var/datum/icon_snapshot/entry = new
	entry.name = target.name
	entry.icon = target.icon
	entry.icon_state = target.icon_state
	entry.overlays = target.get_overlays_copy(list(L_HAND_LAYER,R_HAND_LAYER))
	for(var/i=1,i<=disguises.len,i++)
		var/datum/icon_snapshot/temp = disguises[i]
		if(temp.name == entry.name)
			disguises[i] = entry
			return
	disguises.Add(entry)

/obj/machinery/abductor/console/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/device/abductor/gizmo))
		var/obj/item/device/abductor/gizmo/G = O
		user << "<span class='notice'>You link the tool to the console.</span>"
		gizmo = G
		G.console = src
	else if(istype(O, /obj/item/clothing/suit/armor/abductor/vest))
		var/obj/item/clothing/suit/armor/abductor/vest/V = O
		user << "<span class='notice'>You link the vest to the console.</span>"
		if(istype(vest))
			if(vest.flags & NODROP)
				toggle_vest()
		vest = V
	else
		return ..()

/obj/machinery/abductor/console/proc/Dispense(item,cost=1)
	if(experiment && experiment.points >= cost)
		experiment.points-=cost
		say("Incoming supply!")
		if(pad)
			flick("alien-pad", pad)
			new item(pad.loc)
		else
			new item(src.loc)
	else
		say("Insufficent data!")

/obj/machinery/abductor/console/proc/toggle_vest()
	vest.flags ^= NODROP
	var/mob/M = vest.loc
	if(istype(M))
		M << "<span class='notice'>[src] is now \
			[vest.flags & NODROP ? "locked" : "unlocked"].</span>"
