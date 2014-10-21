#define MECH_JAIL_TIME 30

/obj/item/mecha_parts/mecha_equipment/tool/jail
	name = "Mounted Jail Cell"
	desc = "Mounted Jail Cell, capable of holding up to two prisoners for a limited time. (Can be attached to Gygax)"
	icon_state = "mecha_jail"
	origin_tech = "biotech=2;combat=4"
	energy_drain = 20
	range = MELEE
	construction_cost = list("iron"=7500,"glass"=10000)
	reliability = 1000
	equip_cooldown = 50 //very long time to actually load someone up
	var/mob/living/carbon/cell1 = null
	var/mob/living/carbon/cell2 = null
	var/ctimer1 = 0
	var/ctimer2 = 0
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
	if(cell1) //safety nets
		cell1.loc = get_turf(src)
	if(cell2)
		cell2.loc = get_turf(src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/tool/jail/Exit(atom/movable/O)
	return 0

/obj/item/mecha_parts/mecha_equipment/tool/jail/action(var/mob/living/carbon/target)
	if(!action_checks(target))
		return
	if(!istype(target))
		return
	if(target.buckled)
		occupant_message("[target] will not fit into the jail cell because they are buckled to [target.buckled].")
		return
	if(cell1 && cell2)
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
		if(cell1 && cell2)
			occupant_message("<font color=\"red\"><B>The jail cells are already occupied!</B></font>")
			return
		target.forceMove(src)
		if(!cell1)
			cell1 = target
			ctimer1 = MECH_JAIL_TIME
		else if (!cell2)
			cell2 = target
			ctimer2 = MECH_JAIL_TIME
			set_ready_state(0)
		target.reset_view(src)
		/*
		if(target.client)
		target.client.perspective = EYE_PERSPECTIVE
		target.client.eye = chassis
		*/
		pr_mech_jail.start()
		occupant_message("<font color='blue'>[target] successfully loaded into [src].")
		chassis.visible_message("[chassis] loads [target] into [src].")
		log_message("[target] loaded.")
		return 1
	return

/obj/item/mecha_parts/mecha_equipment/tool/jail/proc/go_out(var/mob/living/carbon/ejected, ejectedtimer)
	if(!ejected)
		return
	ejected.forceMove(get_turf(src))
	occupant_message("[ejected] ejected.")
	log_message("[ejected] ejected.")
	ejectedtimer = 0
	ejected.reset_view()
	/*
	if(occupant.client)
	occupant.client.eye = occupant.client.mob
	occupant.client.perspective = MOB_PERSPECTIVE
	*/
	if(cell1 == ejected) //I really don't know why these are necessary. Just accept that they are
		cell1 = null
	if(cell2 == ejected)
		cell2 = null
	ejected = null
	if(!cell1 && !cell2)
		pr_mech_jail.stop()
		set_ready_state(1)
	return 1

/obj/item/mecha_parts/mecha_equipment/tool/jail/detach()
	if(cell1 || cell2)
		occupant_message("Unable to detach [src] - equipment occupied.")
		return
	pr_mech_jail.stop()
	return ..()

/obj/item/mecha_parts/mecha_equipment/tool/jail/get_equip_info()
	var/output = ..()
	if(output)
		var/temp = ""
		if(cell1)
			temp = "<br />\[Occupant: [cell1] (Health: [cell1.health]%)\]<br />|Time left: [ctimer1]|<a href='?src=\ref[src];ejectcell1=1'>Eject</a>"
		if(cell2)
			temp = temp + "<br />\[Occupant: [cell2] (Health: [cell2.health]%)\]<br />|Time left: [ctimer2]|<a href='?src=\ref[src];ejectcell2=1'>Eject</a>"
		return "[output] [temp]"
	return

/obj/item/mecha_parts/mecha_equipment/tool/jail/Topic(href,href_list)
	..()
	var/datum/topic_input/filter = new /datum/topic_input(href,href_list)
	if(filter.get("ejectcell1"))
		go_out(cell1, ctimer1)
	if(filter.get("ejectcell2"))
		go_out(cell2, ctimer2)
	return

/datum/global_iterator/mech_jail/process(var/obj/item/mecha_parts/mecha_equipment/tool/jail/J)
	log_admin("Timer 1: [J.ctimer1], Timer 2: [J.ctimer2]")
	if(!J.chassis)
		J.set_ready_state(1)
		return stop()
	if(!J.chassis.has_charge(J.energy_drain))
		J.set_ready_state(1)
		J.log_message("Deactivated.")
		J.occupant_message("[src] deactivated - no power.")
		J.go_out(J.cell1, J.ctimer1)
		J.go_out(J.cell2, J.ctimer2)
		return stop()
	if(!J.cell1 && !J.cell2)
		return
	if (J.cell1)
		J.ctimer1--
		if (J.ctimer1 <= 0)
			J.go_out(J.cell1, J.ctimer1)
		if(J.ctimer1 == 5)
			J.occupant_message("<span class='warning'>Occupant [J.cell1] ejected in 5 seconds!</span>")
	if (J.cell2)
		J.ctimer2--
		if (J.ctimer2 <= 0)
			J.go_out(J.cell2, J.ctimer2)
		if(J.ctimer1 == 5)
			J.occupant_message("<span class='warning'>Occupant [J.cell2] ejected in 5 seconds!</span>")
	//log_admin("Current cells of [M] and [N]")
	J.chassis.use_power(J.energy_drain)
	J.update_equip_info()
	return