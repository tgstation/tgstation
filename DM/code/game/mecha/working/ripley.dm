/obj/mecha/working/ripley
	desc = "Autonomous Power Loader Unit MK-I. Designed primarily around heavy lifting, the Ripley can be outfitted with utility equipment to fill a number of roles."
	name = "\improper APLU MK-I \"Ripley\""
	icon_state = "ripley"
	silicon_icon_state = "ripley-empty"
	step_in = 1.5 //Move speed, lower is faster.
	/// How fast the mech is in low pressure
	var/fast_pressure_step_in = 1.5
	/// How fast the mech is in normal pressure
	var/slow_pressure_step_in = 2
	max_temperature = 20000
	max_integrity = 200
	lights_power = 7
	deflect_chance = 15
	armor = list("melee" = 40, "bullet" = 20, "laser" = 10, "energy" = 20, "bomb" = 40, "bio" = 0, "rad" = 20, "fire" = 100, "acid" = 100)
	max_equip = 6
	wreckage = /obj/structure/mecha_wreckage/ripley
	internals_req_access = list(ACCESS_MECH_ENGINE, ACCESS_MECH_SCIENCE, ACCESS_MECH_MINING)
	enclosed = FALSE //Normal ripley has an open cockpit design
	enter_delay = 10 //can enter in a quarter of the time of other mechs
	exit_delay = 10
	opacity = FALSE //Ripley has a window
	/// Amount of Goliath hides attached to the mech
	var/hides = 0
	/// List of all things in Ripley's Cargo Compartment
	var/list/cargo = new
	/// How much things Ripley can carry in their Cargo Compartment
	var/cargo_capacity = 15

/obj/mecha/working/ripley/Move()
	. = ..()
	update_pressure()

/obj/mecha/working/ripley/go_out()
	..()
	update_icon()

/obj/mecha/working/ripley/moved_inside(mob/living/carbon/human/H)
	..()
	update_icon()

/obj/mecha/working/ripley/check_for_internal_damage(list/possible_int_damage,ignore_threshold=null)
	if (!enclosed)
		possible_int_damage -= (MECHA_INT_TEMP_CONTROL + MECHA_INT_TANK_BREACH) //if we don't even have an air tank, these two doesn't make a ton of sense.
	. = ..()

/obj/mecha/working/ripley/Initialize()
	. = ..()
	AddComponent(/datum/component/armor_plate,3,/obj/item/stack/sheet/animalhide/goliath_hide,list("melee" = 10, "bullet" = 5, "laser" = 5))


/obj/mecha/working/ripley/Destroy()
	for(var/atom/movable/A in cargo)
		A.forceMove(drop_location())
		step_rand(A)
	cargo.Cut()
	return ..()

/obj/mecha/working/ripley/mkii
	desc = "Autonomous Power Loader Unit MK-II. This prototype Ripley is refitted with a pressurized cabin, trading its prior speed for atmospheric protection and armor."
	name = "\improper APLU MK-II \"Ripley\""
	icon_state = "ripleymkii"
	fast_pressure_step_in = 2 //step_in while in low pressure conditions
	slow_pressure_step_in = 4 //step_in while in normal pressure conditions
	step_in = 4
	max_temperature = 30000
	max_integrity = 250
	armor = list("melee" = 40, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 60, "bio" = 0, "rad" = 70, "fire" = 100, "acid" = 100)
	wreckage = /obj/structure/mecha_wreckage/ripley/mkii
	enclosed = TRUE
	enter_delay = 40
	silicon_icon_state = null
	opacity = TRUE


/obj/mecha/working/ripley/deathripley
	desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA DIE"
	name = "\improper DEATH-RIPLEY"
	icon_state = "deathripley"
	fast_pressure_step_in = 2 //step_in while in low pressure conditions
	slow_pressure_step_in = 3 //step_in while in normal pressure conditions
	step_in = 4
	lights_power = 7
	wreckage = /obj/structure/mecha_wreckage/ripley/deathripley
	step_energy_drain = 0
	enclosed = TRUE
	enter_delay = 40
	silicon_icon_state = null
	opacity = TRUE

/obj/mecha/working/ripley/deathripley/Initialize()
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill
	ME.attach(src)

/obj/mecha/working/ripley/deathripley/real
	desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA DIE. FOR REAL"

/obj/mecha/working/ripley/deathripley/real/Initialize()
	. = ..()
	for(var/obj/item/mecha_parts/mecha_equipment/E in equipment)
		E.detach()
		qdel(E)
	equipment.Cut()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill/real
	ME.attach(src)

/obj/mecha/working/ripley/mining
	desc = "An old, dusty mining Ripley."
	name = "\improper APLU \"Miner\""
	obj_integrity = 75 //Low starting health

/obj/mecha/working/ripley/mining/Initialize()
	. = ..()
	if(cell)
		cell.charge = FLOOR(cell.charge * 0.25, 1) //Starts at very low charge
	if(prob(70)) //Maybe add a drill
		if(prob(15)) //Possible diamond drill... Feeling lucky?
			var/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill/D = new
			D.attach(src)
		else
			var/obj/item/mecha_parts/mecha_equipment/drill/D = new
			D.attach(src)

	else //Add plasma cutter if no drill
		var/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma/P = new
		P.attach(src)

	//Add ore box to cargo
	cargo.Add(new /obj/structure/ore_box(src))

	//Attach hydraulic clamp
	var/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/HC = new
	HC.attach(src)
	for(var/obj/item/mecha_parts/mecha_tracking/B in trackers)//Deletes the beacon so it can't be found easily
		qdel(B)

	var/obj/item/mecha_parts/mecha_equipment/mining_scanner/scanner = new
	scanner.attach(src)

/obj/mecha/working/ripley/Exit(atom/movable/O)
	if(O in cargo)
		return 0
	return ..()

/obj/mecha/working/ripley/Topic(href, href_list)
	..()
	if(href_list["drop_from_cargo"])
		var/obj/O = locate(href_list["drop_from_cargo"]) in cargo
		if(O)
			occupant_message("<span class='notice'>You unload [O].</span>")
			O.forceMove(drop_location())
			cargo -= O
			log_message("Unloaded [O]. Cargo compartment capacity: [cargo_capacity - src.cargo.len]", LOG_MECHA)
	return


/obj/mecha/working/ripley/contents_explosion(severity, target)
	for(var/X in cargo)
		var/obj/O = X
		if(prob(30/severity))
			cargo -= O
			O.forceMove(drop_location())
	. = ..()

/obj/mecha/working/ripley/get_stats_part()
	var/output = ..()
	output += "<b>Cargo Compartment Contents:</b><div style=\"margin-left: 15px;\">"
	if(cargo.len)
		for(var/obj/O in cargo)
			output += "<a href='?src=[REF(src)];drop_from_cargo=[REF(O)]'>Unload</a> : [O]<br>"
	else
		output += "Nothing"
	output += "</div>"
	return output

/obj/mecha/working/ripley/relay_container_resist(mob/living/user, obj/O)
	to_chat(user, "<span class='notice'>You lean on the back of [O] and start pushing so it falls out of [src].</span>")
	if(do_after(user, 300, target = O))
		if(!user || user.stat != CONSCIOUS || user.loc != src || O.loc != src )
			return
		to_chat(user, "<span class='notice'>You successfully pushed [O] out of [src]!</span>")
		O.forceMove(drop_location())
		cargo -= O
	else
		if(user.loc == src) //so we don't get the message if we resisted multiple times and succeeded.
			to_chat(user, "<span class='warning'>You fail to push [O] out of [src]!</span>")
/**
  * Makes the mecha go faster and halves the mecha drill cooldown if in Lavaland pressure.
  *
  * Checks for Lavaland pressure, if that works out the mech's speed is equal to fast_pressure_step_in and the cooldown for the mecha drill is halved. If not it uses slow_pressure_step_in and drill cooldown is normal.
  */
/obj/mecha/working/ripley/proc/update_pressure()
	var/turf/T = get_turf(loc)

	if(lavaland_equipment_pressure_check(T))
		step_in = fast_pressure_step_in
		for(var/obj/item/mecha_parts/mecha_equipment/drill/drill in equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown) * 0.5

	else
		step_in = slow_pressure_step_in
		for(var/obj/item/mecha_parts/mecha_equipment/drill/drill in equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown)
