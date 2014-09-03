
/obj/machinery/artifact_harvester
	name = "Exotic Particle Harvester"
	icon = 'icons/obj/virology.dmi'
	icon_state = "incubator"	//incubator_on
	anchored = 1
	density = 1
	idle_power_usage = 50
	active_power_usage = 750
	use_power = 1
	var/harvesting = 0
	var/obj/item/weapon/anobattery/inserted_battery
	var/obj/machinery/artifact/cur_artifact
	var/obj/machinery/artifact_scanpad/owned_scanner = null

/obj/machinery/artifact_harvester/New()
	..()
	//connect to a nearby scanner pad
	owned_scanner = locate(/obj/machinery/artifact_scanpad) in get_step(src, dir)
	if(!owned_scanner)
		owned_scanner = locate(/obj/machinery/artifact_scanpad) in orange(1, src)

/obj/machinery/artifact_harvester/attackby(var/obj/I as obj, var/mob/user as mob)
	if(istype(I,/obj/item/weapon/anobattery))
		if(!inserted_battery)
			user << "\blue You insert [I] into [src]."
			user.drop_item()
			I.loc = src
			src.inserted_battery = I
			updateDialog()
		else
			user << "\red There is already a battery in [src]."
	else
		return..()

/obj/machinery/artifact_harvester/attack_hand(var/mob/user as mob)
	src.add_fingerprint(user)
	interact(user)

/obj/machinery/artifact_harvester/interact(var/mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	user.set_machine(src)
	var/dat = "<B>Artifact Power Harvester</B><BR>"
	dat += "<HR><BR>"
	//
	if(owned_scanner)
		if(harvesting)
			if(harvesting > 0)
				dat += "Please wait. Harvesting in progress ([(inserted_battery.stored_charge/inserted_battery.capacity)*100]%).<br>"
			else
				dat += "Please wait. Energy dump in progress ([(inserted_battery.stored_charge/inserted_battery.capacity)*100]%).<br>"
			dat += "<A href='?src=\ref[src];stopharvest=1'>Halt early</A><BR>"
		else
			if(inserted_battery)
				dat += "<b>[inserted_battery.name]</b> inserted, charge level: [inserted_battery.stored_charge]/[inserted_battery.capacity] ([(inserted_battery.stored_charge/inserted_battery.capacity)*100]%)<BR>"
				dat += "<b>Energy signature ID:</b>[inserted_battery.battery_effect.artifact_id == "" ? "???" : "[inserted_battery.battery_effect.artifact_id]"]<BR>"
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

/obj/machinery/artifact_harvester/process()
	if(stat & (NOPOWER|BROKEN))
		return

	if(harvesting > 0)
		//gain a bit of charge
		inserted_battery.stored_charge += 0.5

		//check if we've finished
		if(inserted_battery.stored_charge >= inserted_battery.capacity)
			use_power = 1
			harvesting = 0
			cur_artifact.anchored = 0
			cur_artifact.being_used = 0
			src.visible_message("<b>[name]</b> states, \"Battery is full.\"")
			icon_state = "incubator"

	else if(harvesting < 0)
		//dump some charge
		inserted_battery.stored_charge -= 2

		//do the effect
		if(inserted_battery.battery_effect)
			inserted_battery.battery_effect.process()

			//if the effect works by touch, activate it on anyone viewing the console
			if(inserted_battery.battery_effect.effect == 0)
				var/list/nearby = viewers(1, src)
				for(var/mob/M in nearby)
					if(M.machine == src)
						inserted_battery.battery_effect.DoEffectTouch(M)

		//if there's no charge left, finish
		if(inserted_battery.stored_charge <= 0)
			use_power = 1
			inserted_battery.stored_charge = 0
			harvesting = 0
			if(inserted_battery.battery_effect && inserted_battery.battery_effect.activated)
				inserted_battery.battery_effect.ToggleActivate()
			src.visible_message("<b>[name]</b> states, \"Battery dump completed.\"")
			icon_state = "incubator"

/obj/machinery/artifact_harvester/Topic(href, href_list)

	if (href_list["harvest"])
		//locate artifact on analysis pad
		cur_artifact = null
		var/articount = 0
		var/obj/machinery/artifact/analysed
		for(var/obj/machinery/artifact/A in get_turf(owned_scanner))
			analysed = A
			articount++

		var/mundane = 0
		for(var/obj/O in get_turf(owned_scanner))
			if(O.invisibility)
				continue
			if(!istype(O, /obj/machinery/artifact) && !istype(O, /obj/machinery/artifact_scanpad))
				mundane++
				break
		for(var/mob/O in get_turf(owned_scanner))
			if(O.invisibility)
				continue
			mundane++
			break
		if(!analysed)
			var/message = "<b>[src]</b> states, \"Cannot harvest, unable to analyse.\""
			src.visible_message(message)
			return
		if(analysed.being_used)
			var/message = "<b>[src]</b> states, \"Cannot harvest. Too much interference.\""
			src.visible_message(message)
		else if(articount == 1 && !mundane)
			cur_artifact = analysed
			//there should already be a battery inserted, but this is just in case
			if(inserted_battery)
				//see if we can clear out an old effect
				//delete it when the ids match to account for duplicate ids having different effects
				if(inserted_battery.battery_effect && inserted_battery.stored_charge <= 0)
					del(inserted_battery.battery_effect)

				//only charge up
				var/matching_id = 0
				if(inserted_battery.battery_effect)
					matching_id = (inserted_battery.battery_effect.artifact_id == cur_artifact.my_effect.artifact_id)
				var/matching_effecttype = 0
				if(inserted_battery.battery_effect)
					matching_effecttype = (inserted_battery.battery_effect.type == cur_artifact.my_effect.type)
				if(!inserted_battery.battery_effect || (matching_id && matching_effecttype))
					harvesting = 1
					use_power = 2
					cur_artifact.anchored = 1
					cur_artifact.being_used = 1
					icon_state = "incubator_on"
					var/message = "<b>[src]</b> states, \"Beginning artifact energy harvesting.\""
					src.visible_message(message)

					//duplicate the artifact's effect datum
					if(!inserted_battery.battery_effect)
						var/effecttype = cur_artifact.my_effect.type
						var/datum/artifact_effect/E = new effecttype(inserted_battery)

						//duplicate it's unique settings
						for(var/varname in list("chargelevelmax","artifact_id","effect","effectrange","trigger"))
							E.vars[varname] = cur_artifact.my_effect.vars[varname]

						//copy the new datum into the battery
						inserted_battery.battery_effect = E
						inserted_battery.stored_charge = 0
				else
					var/message = "<b>[src]</b> states, \"Cannot harvest. Incompatible energy signatures detected.\""
					src.visible_message(message)
			else if(cur_artifact)
				var/message = "<b>[src]</b> states, \"Cannot harvest. No battery inserted.\""
				src.visible_message(message)
		else if(articount > 1 || mundane)
			var/message = "<b>[src]</b> states, \"Cannot harvest. Error isolating energy signature.\""
			src.visible_message(message)
		else if(!articount)
			var/message = "<b>[src]</b> states, \"Cannot harvest. No noteworthy energy signature isolated.\""
			src.visible_message(message)

	if (href_list["stopharvest"])
		if(harvesting)
			if(harvesting < 0 && inserted_battery.battery_effect && inserted_battery.battery_effect.activated)
				inserted_battery.battery_effect.ToggleActivate()
			harvesting = 0
			cur_artifact.anchored = 0
			cur_artifact.being_used = 0
			src.visible_message("<b>[name]</b> states, \"Activity interrupted.\"")
			icon_state = "incubator"

	if (href_list["ejectbattery"])
		src.inserted_battery.loc = src.loc
		src.inserted_battery = null

	if (href_list["drainbattery"])
		if(inserted_battery)
			if(inserted_battery.battery_effect && inserted_battery.stored_charge > 0)
				if(alert("This action will dump all charge, safety gear is recommended before proceeding","Warning","Continue","Cancel"))
					if(!inserted_battery.battery_effect.activated)
						inserted_battery.battery_effect.ToggleActivate(0)
					harvesting = -1
					use_power = 2
					icon_state = "incubator_on"
					var/message = "<b>[src]</b> states, \"Warning, battery charge dump commencing.\""
					src.visible_message(message)
			else
				var/message = "<b>[src]</b> states, \"Cannot dump energy. Battery is drained of charge already.\""
				src.visible_message(message)
		else
			var/message = "<b>[src]</b> states, \"Cannot dump energy. No battery inserted.\""
			src.visible_message(message)

	if(href_list["close"])
		usr << browse(null, "window=artharvester")
		usr.unset_machine(src)

	updateDialog()
