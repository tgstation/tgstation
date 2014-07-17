/obj/mecha/working/ripley
	desc = "Autonomous Power Loader Unit. The workhorse of the exosuit world. Hardened to protect miners against the dangers of the asteroid."
	name = "\improper APLU \"Ripley\""
	icon_state = "ripley"
	step_in = 6
	max_temperature = 20000
	health = 200
	wreckage = /obj/structure/mecha_wreckage/ripley
	damage_absorption = list("brute"=0.4,"fire"=1.2,"bullet"=0.9,"laser"=1,"energy"=1,"bomb"=1)
	var/list/cargo = new
	var/cargo_capacity = 15
	var/mode_change_cooldown = 0 //Stops rapid swapping between movement modes to stop the movespeed toggle from being too useful in combat
	var/overdrive_step_in = 2 // How fast we go when we swap to movement mode
	var/regular_step_in = 6 // How fast we go when we're in work mode
	var/equipment_locked = 0 //Lock equipment if we've swapped movement modes, defaults to off
	var/datum/global_iterator/mecha_ripley_mining_scanner_ticker/scanner = null //Holder for scanning datum

/obj/mecha/working/ripley/New()
	scanner = new /datum/global_iterator/mecha_ripley_mining_scanner_ticker(null, 0)
	scanner.installed_to = src
	..()

/obj/mecha/working/ripley/click_action(atom/target,mob/user)
	if(equipment_locked)
		occupant_message("<span class='warning'>Equipment has been locked.</span>")
		return
	..()

/obj/mecha/working/ripley/ex_act(severity)
	if(!equipment_locked && severity > 1)
		return //So long as we've got the blast shields up, explosions are not really a threat, but it cant withstand max threshold explosions
	..()

/obj/mecha/working/ripley/moved_inside(var/mob/living/carbon/human/H as mob)
	var/T =..()
	if(T)
		scanner.start()
	return T

/obj/mecha/working/ripley/go_out()
	..()
	scanner.stop()

/obj/mecha/working/ripley/proc/MineralScanner()
	var/client/C = occupant.client
	var/list/L = list()
	var/turf/simulated/mineral/M
	for(M in range(7, src))
		if(M.scan_state)
			L += M
	for(M in L)
		var/turf/T = get_turf(M)
		var/image/I = image('icons/turf/walls.dmi', loc = T, icon_state = M.scan_state, layer = 18)
		C.images += I
		spawn(30)
			if(C)
				C.images -= I
	return 1

/datum/global_iterator/mecha_ripley_mining_scanner_ticker
	delay = 50
	var/obj/mecha/working/ripley/installed_to = null

/datum/global_iterator/mecha_ripley_mining_scanner_ticker/process()
	if(!installed_to.occupant.client)
		stop()
		return
	installed_to.MineralScanner()

/*
/obj/mecha/working/ripley/New()
	..()
	return
*/

/obj/mecha/working/ripley/firefighter
	desc = "Standart APLU chassis was refitted with additional thermal protection and cistern."
	name = "\improper APLU \"Firefighter\""
	icon_state = "firefighter"
	max_temperature = 65000
	health = 250
	lights_power = 8
	damage_absorption = list("fire"=0.5,"bullet"=0.8,"bomb"=0.5)
	wreckage = /obj/structure/mecha_wreckage/ripley/firefighter

/obj/mecha/working/ripley/deathripley
	desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA DIE"
	name = "\improper DEATH-RIPLEY"
	icon_state = "deathripley"
	step_in = 3
	opacity=0
	lights_power = 60
	wreckage = /obj/structure/mecha_wreckage/ripley/deathripley
	step_energy_drain = 0

/obj/mecha/working/ripley/deathripley/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/tool/safety_clamp
	ME.attach(src)
	return

/obj/mecha/working/ripley/mining
	desc = "An old, dusty mining ripley."
	name = "\improper APLU \"Miner\""

/obj/mecha/working/ripley/mining/New()
	..()
	//Attach drill
	if(prob(25)) //Possible diamond drill... Feeling lucky?
		var/obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill/D = new /obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill
		D.attach(src)
	else
		var/obj/item/mecha_parts/mecha_equipment/tool/drill/D = new /obj/item/mecha_parts/mecha_equipment/tool/drill
		D.attach(src)

	//Attach hydrolic clamp
	var/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp/HC = new /obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp
	HC.attach(src)
	for(var/obj/item/mecha_parts/mecha_tracking/B in src.contents)//Deletes the beacon so it can't be found easily
		qdel(B)

/obj/mecha/working/ripley/Exit(atom/movable/O)
	if(O in cargo)
		return 0
	return ..()

/obj/mecha/working/ripley/Topic(href, href_list)
	..()
	if(href_list["drop_from_cargo"])
		var/obj/O = locate(href_list["drop_from_cargo"])
		if(O && O in src.cargo)
			src.occupant_message("\blue You unload [O].")
			O.loc = get_turf(src)
			src.cargo -= O
			var/turf/T = get_turf(O)
			if(T)
				T.Entered(O)
			src.log_message("Unloaded [O]. Cargo compartment capacity: [cargo_capacity - src.cargo.len]")
	if(href_list["toggle_overdrive"])
		if(mode_change_cooldown)
			occupant_message("System is unable to swap movement modes in rapid succession. Processing.")
			return
		if(equipment_locked)
			damage_absorption = list("brute"=0.4,"fire"=1.2,"bullet"=0.9,"laser"=1,"energy"=1,"bomb"=1)
			occupant_message("Enabling equipment and blast shields, rerouting power from movement actuators")
			equipment_locked = 0
			step_in = regular_step_in
		else
			occupant_message("Disabling equipment and blast shields, rerouting power to movement actuators")
			damage_absorption = list("brute"=1,"fire"=1.2,"bullet"=1,"laser"=1.5,"energy"=1.5,"bomb"=1)
			equipment_locked = 1
			step_in = overdrive_step_in
		mode_change_cooldown = 1
		spawn(30)
			mode_change_cooldown = 0
	return

/obj/mecha/working/ripley/get_stats_part()
	var/output = ..()
	output += "<b><A href='?src=\ref[src];toggle_overdrive=1'>Toggle movement mode</A></b><br>"
	output += "<b>Cargo Compartment Contents:</b><div style=\"margin-left: 15px;\">"
	if(src.cargo.len)
		for(var/obj/O in src.cargo)
			output += "<a href='?src=\ref[src];drop_from_cargo=\ref[O]'>Unload</a> : [O]<br>"
	else
		output += "Nothing"
	output += "</div>"
	return output

/obj/mecha/working/ripley/Destroy()
	for(var/mob/M in src)
		if(M==src.occupant)
			continue
		M.loc = get_turf(src)
		M.loc.Entered(M)
		step_rand(M)
	for(var/atom/movable/A in src.cargo)
		A.loc = get_turf(src)
		var/turf/T = get_turf(A)
		if(T)
			T.Entered(A)
		step_rand(A)
	..()
	return



