/obj/mecha/working/ripley
	desc = "Autonomous Power Loader Unit. This newer model is refitted with powerful armour against the dangers of the EVA mining process."
	name = "\improper APLU \"Ripley\""
	icon_state = "ripley"
	step_in = 5
	max_temperature = 20000
	health = 200
	lights_power = 7
	deflect_chance = 15
	damage_absorption = list("brute"=0.6,"fire"=1,"bullet"=0.8,"laser"=0.9,"energy"=1,"bomb"=0.6)
	max_equip = 6
	wreckage = /obj/structure/mecha_wreckage/ripley
	var/list/cargo = new
	var/cargo_capacity = 15

/*
/obj/mecha/working/ripley/New()
	..()
	return
*/

/obj/mecha/working/ripley/Move()
	. = ..()
	if(. && (locate(/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp) in equipment))
		var/obj/structure/ore_box/ore_box = locate(/obj/structure/ore_box) in cargo
		if(ore_box)
			for(var/obj/item/weapon/ore/ore in get_turf(src))
				ore.Move(ore_box)
	update_pressure()

/obj/mecha/working/ripley/Destroy()
	while(src.damage_absorption.["brute"] < 0.6)
		new /obj/item/asteroid/goliath_hide(src.loc)
		src.damage_absorption.["brute"] = src.damage_absorption.["brute"] + 0.1 //If a goliath-plated ripley gets killed, all the plates drop
	for(var/atom/movable/A in src.cargo)
		A.loc = loc
		step_rand(A)
	cargo.Cut()
	..()

/obj/mecha/working/ripley/go_out()
	..()
	if (src.damage_absorption["brute"] < 0.6 && src.damage_absorption["brute"] > 0.3)
		src.overlays = null
		src.overlays += image("icon" = "mecha.dmi", "icon_state" = "ripley-g-open")
	else if (src.damage_absorption.["brute"] == 0.3)
		src.overlays = null
		src.overlays += image("icon" = "mecha.dmi", "icon_state" = "ripley-g-full-open")

/obj/mecha/working/ripley/moved_inside(mob/living/carbon/human/H)
	..()
	if (src.damage_absorption["brute"] < 0.6 && src.damage_absorption["brute"] > 0.3)
		src.overlays = null
		src.overlays += image("icon" = "mecha.dmi", "icon_state" = "ripley-g")
	else if (src.damage_absorption["brute"] == 0.3)
		src.overlays = null
		src.overlays += image("icon" = "mecha.dmi", "icon_state" = "ripley-g-full")

/obj/mecha/working/ripley/mmi_moved_inside(obj/item/device/mmi/mmi_as_oc,mob/user)
	..()
	if (src.damage_absorption["brute"] < 0.6 && src.damage_absorption["brute"] > 0.3)
		src.overlays = null
		src.overlays += image("icon" = "mecha.dmi", "icon_state" = "ripley-g")
	else if (src.damage_absorption["brute"] == 0.3)
		src.overlays = null
		src.overlays += image("icon" = "mecha.dmi", "icon_state" = "ripley-g-full")

/obj/mecha/working/ripley/firefighter
	desc = "Autonomous Power Loader Unit. This model is refitted with additional thermal protection."
	name = "\improper APLU \"Firefighter\""
	icon_state = "firefighter"
	max_temperature = 65000
	health = 250
	lights_power = 7
	damage_absorption = list("brute"=0.6,"fire"=0.5,"bullet"=0.7,"laser"=0.7,"energy"=1,"bomb"=0.4)
	max_equip = 5 // More armor, less tools
	wreckage = /obj/structure/mecha_wreckage/ripley/firefighter

/obj/mecha/working/ripley/deathripley
	desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA DIE"
	name = "\improper DEATH-RIPLEY"
	icon_state = "deathripley"
	step_in = 3
	opacity=0
	lights_power = 7
	wreckage = /obj/structure/mecha_wreckage/ripley/deathripley
	step_energy_drain = 0

/obj/mecha/working/ripley/deathripley/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/tool/safety_clamp
	ME.attach(src)
	return

/obj/mecha/working/ripley/mining
	desc = "An old, dusty mining Ripley."
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

	//Add possible plasma cutter
	if(prob(25))
		var/obj/item/mecha_parts/mecha_equipment/M = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma
		M.attach(src)

	//Add ore box to cargo
	cargo.Add(new /obj/structure/ore_box(src))

	//Attach hydraulic clamp
	var/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp/HC = new /obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp
	HC.attach(src)
	for(var/obj/item/mecha_parts/mecha_tracking/B in src.contents)//Deletes the beacon so it can't be found easily
		qdel(B)

	var/obj/item/mecha_parts/mecha_equipment/tool/mining_scanner/scanner = new /obj/item/mecha_parts/mecha_equipment/tool/mining_scanner
	scanner.attach(src)

/obj/mecha/working/ripley/Exit(atom/movable/O)
	if(O in cargo)
		return 0
	return ..()

/obj/mecha/working/ripley/Topic(href, href_list)
	..()
	if(href_list["drop_from_cargo"])
		var/obj/O = locate(href_list["drop_from_cargo"])
		if(O && O in src.cargo)
			src.occupant_message("<span class='notice'>You unload [O].</span>")
			O.loc = loc
			src.cargo -= O
			src.log_message("Unloaded [O]. Cargo compartment capacity: [cargo_capacity - src.cargo.len]")
	return



/obj/mecha/working/ripley/get_stats_part()
	var/output = ..()
	output += "<b>Cargo Compartment Contents:</b><div style=\"margin-left: 15px;\">"
	if(src.cargo.len)
		for(var/obj/O in src.cargo)
			output += "<a href='?src=\ref[src];drop_from_cargo=\ref[O]'>Unload</a> : [O]<br>"
	else
		output += "Nothing"
	output += "</div>"
	return output

/obj/mecha/working/ripley/proc/update_pressure()
	var/turf/T = get_turf(loc)
	var/datum/gas_mixture/environment = T.return_air()
	var/pressure = environment.return_pressure()

	if(pressure < 20)
		step_in = 3
		for(var/obj/item/mecha_parts/mecha_equipment/tool/drill/drill in equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown)/2
	else
		step_in = 5
		for(var/obj/item/mecha_parts/mecha_equipment/tool/drill/drill in equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown)
