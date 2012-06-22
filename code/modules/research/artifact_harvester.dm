
/obj/machinery/artifact_harvester
	name = "Anomaly Power Collector"
	icon = 'virology.dmi'
	icon_state = "incubator"	//incubator_on
	anchored = 1
	density = 1
	var/harvesting = 0
	var/obj/item/weapon/anobattery/inserted_battery
	var/obj/machinery/artifact/cur_artifact
	var/obj/machinery/analyser_pad/owned_pad = null

/obj/machinery/artifact_harvester/New()
	..()
	spawn(10)
		owned_pad = locate() in orange(1, src)

/obj/machinery/artifact_harvester/attackby(var/obj/I as obj, var/mob/user as mob)
	if(istype(I,/obj/item/weapon/anobattery))
		if(!inserted_battery)
			user << "You insert the battery."
			user.drop_item()
			I.loc = src
			src.inserted_battery = I
			return
	else
		return..()

/obj/machinery/artifact_harvester/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/artifact_harvester/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/artifact_harvester/attack_hand(var/mob/user as mob)
	interact(user)

/obj/machinery/artifact_harvester/process()

	if(harvesting)
		inserted_battery.stored_charge += 10
		if(inserted_battery.stored_charge >= inserted_battery.capacity)
			inserted_battery.stored_charge = inserted_battery.capacity
			harvesting = 0
			cur_artifact.anchored = 0
			src.visible_message("<b>[name]</b> states, \"Battery is full.\"")
			icon_state = "incubator"
	return

/obj/machinery/artifact_harvester/proc/interact(var/mob/user as mob)
	user.machine = src
	var/dat = "<B>Artifact Power Harvester</B><BR>"
	dat += "<HR><BR>"
	//
	if(owned_pad)
		if(harvesting)
			dat += "Please wait. Harvesting in progress ([(inserted_battery.stored_charge/inserted_battery.capacity)*100]%).<br>"
			dat += "<A href='?src=\ref[src];stopharvest=1'>Halt early</A><BR>"
		else
			if(inserted_battery)
				dat += "<b>[inserted_battery.name]</b> inserted, charge level: [inserted_battery.stored_charge]/[inserted_battery.capacity] ([(inserted_battery.stored_charge/inserted_battery.capacity)*100]%)<BR>"
				dat += "<b>Energy signature ID:</b>[inserted_battery.battery_effect.artifact_id]<BR>"
				dat += "<A href='?src=\ref[src];ejectbattery=1'>Eject battery</a><BR>"
				dat += "<A href='?src=\ref[src];drainbattery=1'>Drain battery of all charge</a><BR>"
				dat += "<A href='?src=\ref[src];harvest=1'>Begin harvesting</a><BR>"

			else
				dat += "No battery inserted.<BR>"
	else
		dat += "<B><font color=red>Unable to locate analysis pad.</font><BR></b>"
	//
	dat += "<HR>"
	dat += "<A href='?src=\ref[src];refresh=1'>Refresh</A> <A href='?src=\ref[src];close=1'>Close<BR>"
	user << browse(dat, "window=artharvester;size=450x500")
	onclose(user, "artharvester")

/obj/machinery/artifact_harvester/Topic(href, href_list)

	if (href_list["harvest"])
		//locate artifact on analysis pad
		cur_artifact = null
		var/articount = 0
		var/obj/machinery/artifact/analysed
		for(var/obj/machinery/artifact/A in get_turf(owned_pad))
			analysed = A
			articount++

		if(articount > 1)
			var/message = "<b>[src]</b> states, \"Cannot harvest. Too many artifacts on pad.\""
			src.visible_message(message, message)
		else if(!articount)
			var/message = "<b>[src]</b> states, \"Cannot harvest. No artifact found.\""
			src.visible_message(message, message)
		else
			cur_artifact = analysed
			//check to see if the battery is compatible
			if(inserted_battery)
				if(inserted_battery.battery_effect.artifact_id == cur_artifact.my_effect.artifact_id || inserted_battery.stored_charge == 0)
					harvesting = 1
					cur_artifact.anchored = 1
					icon_state = "incubator_on"
					var/message = "<b>[src]</b> states, \"Beginning artifact energy harvesting.\""
					src.visible_message(message, message)
					//
					inserted_battery.battery_effect = cur_artifact.my_effect
				else
					var/message = "<b>[src]</b> states, \"Cannot harvest. Incompatible energy signatures detected.\""
					src.visible_message(message, message)
			else if(cur_artifact)
				var/message = "<b>[src]</b> states, \"Cannot harvest. No battery inserted.\""
				src.visible_message(message, message)

	if (href_list["stopharvest"])
		if(harvesting)
			harvesting = 0
			cur_artifact.anchored = 0
			src.visible_message("<b>[name]</b> states, \"Harvesting interrupted.\"")
			icon_state = "incubator"


	if (href_list["ejectbattery"])
		src.inserted_battery.loc = src.loc
		src.inserted_battery = null

	if (href_list["drainbattery"])
		src.inserted_battery.battery_effect.artifact_id = ""
		src.inserted_battery.stored_charge = 0
		var/message = "<b>[src]</b> states, \"Battery drained of all charge.\""
		src.visible_message(message, message)

	if(href_list["close"])
		usr << browse(null, "window=artharvester")
		usr.machine = null

	src.updateDialog()
	return
