#define MECH_JAIL_TIME 10

/obj/item/mecha_parts/mecha_equipment/tool/jail
	name = "Mounted Jail Cell"
	desc = "Mounted Jail Cell, capable of holding up to two prisoners for a limited time. (Can be attached to Gygax)"
	icon_state = "mecha_jail"
	origin_tech = "biotech=2;combat=4"
	energy_drain = 20
	range = MELEE
	reliability = 1000
	equip_cooldown = 50 //very long time to actually load someone up
	var/list/cells = list("cell1" = list("mob" = null, "timer" = 0), "cell2" = list("mob" = null, "timer" = 0))
	var/datum/global_iterator/pr_mech_jail
	salvageable = 0

/obj/item/mecha_parts/mecha_equipment/tool/jail/can_attach(obj/mecha/combat/gygax/G)
	if(..())
		if(istype(G))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/tool/jail/New()
	. = ..()
	pr_mech_jail = new /datum/global_iterator/mech_jail(list(src),0)
	pr_mech_jail.set_delay(equip_cooldown)
	return

/obj/item/mecha_parts/mecha_equipment/tool/jail/allow_drop()
	return 0

/obj/item/mecha_parts/mecha_equipment/tool/jail/destroy()
	for(var/atom/movable/AM in src)
		AM.forceMove(get_turf(src))
	for(var/list/cell in cells) //safety nets
		var/celldetails = cells[cell]
		if(celldetails["mob"])
			var/mob/living/carbon/occupant = celldetails["mob"]
			occupant.loc = get_turf(src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/tool/jail/Exit(atom/movable/O)
	return 0

//is there an open cell for a mob?
//returns the cell that's got a space
/obj/item/mecha_parts/mecha_equipment/tool/jail/proc/CellFree()
	for(var/cell in cells)
		var/list/celldetails = cells[cell]
		if(!celldetails["mob"])
			return celldetails
	return

//are all our cells empty?
/obj/item/mecha_parts/mecha_equipment/tool/jail/proc/AllFree()
	var/allfree = 1
	for(var/cell in cells)
		var/list/celldetails = cells[cell]
		if(celldetails["mob"])
			allfree = 0
			break
	return allfree

/obj/item/mecha_parts/mecha_equipment/tool/jail/action(var/mob/living/carbon/target)
	if(!action_checks(target))
		return
	if(!istype(target))
		return
	if(target.buckled)
		occupant_message("[target] will not fit into the jail cell because they are buckled to [target.buckled].")
		return
	if(!CellFree())
		occupant_message("The jail cells are already occupied")
		return
	if(!(target.handcuffed || target.legcuffed))
		occupant_message("[target] must be restrained before they can be properly placed in the holding cell.")
		return
	for(var/mob/living/carbon/slime/M in range(1,target))
		if(M.Victim == target)
			occupant_message("[target] will not fit into the jail cell because they have a slime latched onto their head.")
			return
	occupant_message("You start putting [target] into [src].")
	chassis.visible_message("[chassis] starts putting [target] into the [src].")
	var/C = chassis.loc
	var/T = target.loc
	if(do_after_cooldown(target))
		if(chassis.loc!=C || target.loc!=T)
			return
		if(!CellFree())
			occupant_message("<font color=\"red\"><B>The jail cells are already occupied!</B></font>")
			return
		target.forceMove(src)
		var/list/chosencell = CellFree()
		chosencell["mob"] = target
		chosencell["timer"] = MECH_JAIL_TIME
		if(!CellFree())
			set_ready_state(0)
		target.reset_view(src)
		/*
		if(target.client)
		target.client.perspective = EYE_PERSPECTIVE
		target.client.eye = chassis
		*/
		if(CellFree()) //because the process can't have been already going if both cells were empty
			pr_mech_jail.start()
		occupant_message("<font color='blue'>[target] successfully loaded into [src].")
		chassis.visible_message("[chassis] loads [target] into [src].")
		log_message("[target] loaded.")
		return 1
	return

/obj/item/mecha_parts/mecha_equipment/tool/jail/proc/go_out(var/list/L)
	var/mob/living/ejected = L["mob"]
	if(!ejected)
		return
	ejected.forceMove(get_turf(src))
	occupant_message("[ejected] ejected.")
	log_message("[ejected] ejected.")
	L["timer"] = 0
	ejected.reset_view()
	/*
	if(occupant.client)
	occupant.client.eye = occupant.client.mob
	occupant.client.perspective = MOB_PERSPECTIVE
	*/
	L["mob"] = null
	ejected = null
	if(AllFree())
		pr_mech_jail.stop()
		set_ready_state(1)
	return 1

/obj/item/mecha_parts/mecha_equipment/tool/jail/detach()
	if(!AllFree())
		occupant_message("Unable to detach [src] - equipment occupied.")
		return
	pr_mech_jail.stop()
	return ..()

/obj/item/mecha_parts/mecha_equipment/tool/jail/get_equip_info()
	var/output = ..()
	if(output)
		var/temp = ""
		for(var/cell in cells)
			var/list/celldetails = cells[cell]
			var/mob/living/carbon/occupant = celldetails["mob"]
			var/timer = celldetails["timer"]
			temp += "<br />\[Occupant: [occupant ? "[occupant] (Health: [occupant.health]%)" : "none"]\]<br />|Time left: [timer * 3]|<a href='?src=\ref[src];eject[cell]=1'>Eject</a>"
		return "[output] [temp]"
	return

/obj/item/mecha_parts/mecha_equipment/tool/jail/Topic(href,href_list)
	..()
	var/datum/topic_input/filter = new /datum/topic_input(href,href_list)
	for(var/cell in cells)
		if(filter.get("eject[cell]"))
			go_out(cells[cell])
	return

/datum/global_iterator/mech_jail/process(var/obj/item/mecha_parts/mecha_equipment/tool/jail/J)
	//log_admin("Timer 1: [J.ctimer1], Timer 2: [J.ctimer2]")
	if(!J.chassis)
		J.set_ready_state(1)
		return stop()
	if(!J.chassis.has_charge(J.energy_drain))
		J.set_ready_state(1)
		J.log_message("Deactivated.")
		J.occupant_message("[src] deactivated - no power.")
		for(var/cell in J.cells)
			J.go_out(J.cells[cell])
		return stop()
	if(J.AllFree())
		return stop()
	for(var/cell in J.cells)
		var/list/thiscell = J.cells[cell]
		if (thiscell["mob"])
			thiscell["timer"]--
			if (thiscell["timer"] <= 0)
				J.go_out(thiscell)
			else if(thiscell["timer"] == 1)
				J.occupant_message("<span class='warning'>[thiscell["mob"]] will be ejected in 3 seconds!</span>")
	J.chassis.use_power(J.energy_drain)
	J.update_equip_info()
	return