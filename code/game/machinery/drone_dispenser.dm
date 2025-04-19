#define DRONE_PRODUCTION "production"
#define DRONE_RECHARGING "recharging"
#define DRONE_READY "ready"

/obj/machinery/drone_dispenser //Most customizable machine 2015
	name = "drone shell dispenser"
	desc = "A hefty machine that, when supplied with iron and glass, will periodically create a drone shell. Does not need to be manually operated."

	icon = 'icons/obj/machines/drone_dispenser.dmi'
	icon_state = "on"
	density = TRUE

	max_integrity = 250
	integrity_failure = 0.33

	// These allow for different icons when creating custom dispensers
	/// Icon string to use when the drone dispenser is not processing.
	var/icon_off = "off"
	/// Icon string to use when the drone dispenser is processing.
	var/icon_on = "on"
	/// Icon string to use when the drone dispenser is on cooldown.
	var/icon_recharging = "recharge"
	/// Icon string to use when the drone dispenser is making a new shell.
	var/icon_creating = "make"

	/// The quantity of materials used when generating a new drone shell.
	var/list/using_materials
	/// Quantity of materials to automatically insert when the drone dispenser is spawned.
	var/starting_amount = 0
	var/iron_cost = HALF_SHEET_MATERIAL_AMOUNT
	var/glass_cost = HALF_SHEET_MATERIAL_AMOUNT
	/// Energy to draw when processing a new drone shell fresh.
	var/energy_used = 1 KILO JOULES

	/// What operation the drone shell dispenser is currently in, checked in process() to determine behavior
	var/mode = DRONE_READY
	/// Reference to world.time to use for calculation of cooldowns and production of a new drone dispenser.
	var/timer
	/// How long should the drone dispenser be on cooldown after operating
	var/cooldownTime = 3 MINUTES
	/// How long does it the drone dispenser take to generate a new drone shell?
	var/production_time = 3 SECONDS
	//The item the dispenser will create
	var/list/dispense_type = list(/obj/effect/mob_spawn/ghost_role/drone)

	/// The maximum number of "idle" drone shells it will make before ceasing production. Set to 0 for infinite.
	var/maximum_idle = 3

	/// Sound that the drone dispnser plays when it's ready to start making more drones.
	var/work_sound = 'sound/items/tools/rped.ogg'
	/// Sound that the drone dispnser plays when it's created a new drone.
	var/create_sound = 'sound/items/deconstruct.ogg'
	/// Sound that the drone dispnser plays when it's recharged it's cooldown.
	var/recharge_sound = 'sound/machines/ping.ogg'

	/// String that's displayed for when the drone dispenser start working.
	var/begin_create_message = "whirs to life!"
	/// String that's displayed for when the drone dispenser stops working.
	var/end_create_message = "dispenses a drone shell."
	/// String that's displayed for when the drone dispenser finished it's cooldown.
	var/recharge_message = "pings."
	/// String that's displayed for when the drone dispenser is still on cooldown.
	var/recharging_text = "It is whirring and clicking. It seems to be recharging."
	/// String that's displayed for when the drone dispenser is broken.
	var/break_message = "lets out a tinny alarm before falling dark."
	/// Sound that the drone dispnser plays when it's broken.
	var/break_sound = 'sound/machines/warning-buzzer.ogg'
	/// Reference to the object's internal storage for materials.
	var/datum/component/material_container/materials

/obj/machinery/drone_dispenser/Initialize(mapload)
	. = ..()
	materials = AddComponent( \
		/datum/component/material_container, \
		list(/datum/material/iron, /datum/material/glass), \
		SHEET_MATERIAL_AMOUNT * MAX_STACK_SIZE * 2, \
		MATCONTAINER_EXAMINE, \
		allowed_items = /obj/item/stack \
	)
	materials.insert_amount_mat(starting_amount, /datum/material/iron)
	materials.insert_amount_mat(starting_amount, /datum/material/glass)
	materials.precise_insertion = TRUE
	using_materials = list(/datum/material/iron = iron_cost, /datum/material/glass = glass_cost)
	REGISTER_REQUIRED_MAP_ITEM(1, 1)

/obj/machinery/drone_dispenser/Destroy()
	materials = null
	return ..()

/obj/machinery/drone_dispenser/preloaded
	starting_amount = SHEET_MATERIAL_AMOUNT * 2.5

/obj/machinery/drone_dispenser/syndrone //Please forgive me
	name = "syndrone shell dispenser"
	desc = "A suspicious machine that will create Syndicate exterminator drones when supplied with iron and glass. Disgusting."
	dispense_type = list(/obj/effect/mob_spawn/ghost_role/drone/syndrone)
	//If we're gonna be a jackass, go the full mile - 10 second recharge timer
	cooldownTime = 100
	end_create_message = "dispenses a suspicious drone shell."
	starting_amount = SHEET_MATERIAL_AMOUNT * 12.5

/obj/machinery/drone_dispenser/syndrone/badass //Please forgive me
	name = "badass syndrone shell dispenser"
	desc = "A suspicious machine that will create Syndicate exterminator drones when supplied with iron and glass. Disgusting. This one seems ominous."
	dispense_type = list(/obj/effect/mob_spawn/ghost_role/drone/syndrone/badass)
	end_create_message = "dispenses an ominous suspicious drone shell."

// I don't need your forgiveness, this is awesome.
/obj/machinery/drone_dispenser/snowflake
	name = "snowflake drone shell dispenser"
	desc = "A hefty machine that, when supplied with iron and glass, will periodically create a snowflake drone shell. Does not need to be manually operated."
	dispense_type = list(/obj/effect/mob_spawn/ghost_role/drone/snowflake)
	end_create_message = "dispenses a snowflake drone shell."
	// Those holoprojectors aren't cheap
	iron_cost = SHEET_MATERIAL_AMOUNT
	glass_cost = SHEET_MATERIAL_AMOUNT
	energy_used = 2 KILO JOULES
	starting_amount = SHEET_MATERIAL_AMOUNT * 5

// If the derelict gets lonely, make more friends.
/obj/machinery/drone_dispenser/derelict
	name = "derelict drone shell dispenser"
	desc = "A rusty machine that, when supplied with iron and glass, will periodically create a derelict drone shell. Does not need to be manually operated."
	dispense_type = list(/obj/effect/mob_spawn/ghost_role/drone/derelict)
	end_create_message = "dispenses a derelict drone shell."
	iron_cost = SHEET_MATERIAL_AMOUNT * 5
	glass_cost = SHEET_MATERIAL_AMOUNT * 2.5
	starting_amount = 0
	cooldownTime = 600

/obj/machinery/drone_dispenser/classic
	name = "classic drone shell dispenser"
	desc = "A hefty machine that, when supplied with iron and glass, will periodically create a classic drone shell. Does not need to be manually operated."
	dispense_type = list(/obj/effect/mob_spawn/ghost_role/drone/classic)
	end_create_message = "dispenses a classic drone shell."

// An example of a custom drone dispenser.
// This one requires no materials and creates basic hivebots
/obj/machinery/drone_dispenser/hivebot
	name = "hivebot fabricator"
	desc = "A large, bulky machine that whirs with activity, steam hissing from vents in its sides."
	icon = 'icons/obj/machines/hivebot_fabricator.dmi'
	icon_state = "hivebot_fab"
	icon_off = "hivebot_fab"
	icon_on = "hivebot_fab"
	icon_recharging = "hivebot_fab"
	icon_creating = "hivebot_fab_on"
	iron_cost = 0
	glass_cost = 0
	energy_used = 0
	cooldownTime = 10 //Only 1 second - hivebots are extremely weak
	dispense_type = list(/mob/living/basic/hivebot)
	begin_create_message = "closes and begins fabricating something within."
	end_create_message = "slams open, revealing a hivebot!"
	recharge_sound = null
	recharge_message = null

// A dispenser that produces binoculars, for the MediSim shuttle.
/obj/machinery/drone_dispenser/binoculars
	name = "binoculars fabricator"
	desc = "A hefty machine that periodically creates a pair of binoculars. Really, Nanotrasen? We're getting this lazy?"
	dispense_type = list(/obj/item/binoculars)
	starting_amount = SHEET_MATERIAL_AMOUNT * 2.5 //Redudant
	maximum_idle = 1
	cooldownTime = 5 SECONDS
	iron_cost = 0
	glass_cost = 0
	energy_used = 0
	end_create_message = "dispenses a pair of binoculars."

/obj/machinery/drone_dispenser/examine(mob/user)
	. = ..()
	var/material_requirement_string = "It needs "
	if (iron_cost > 0)
		material_requirement_string += "[iron_cost / SHEET_MATERIAL_AMOUNT] iron sheets "
		if (glass_cost > 0)
			material_requirement_string += "and "
	if (glass_cost > 0)
		material_requirement_string += "[glass_cost / SHEET_MATERIAL_AMOUNT] glass sheets "
	if (iron_cost > 0 || glass_cost > 0)
		material_requirement_string += "to produce one drone shell."
		. += span_notice(material_requirement_string)
	if((mode == DRONE_RECHARGING) && !machine_stat && recharging_text)
		. += span_warning("[recharging_text]")

/obj/machinery/drone_dispenser/process()
	if((machine_stat & (NOPOWER|BROKEN)) || !anchored)
		return

	if((glass_cost != 0 || iron_cost != 0) && !materials.has_materials(using_materials))
		return // We require more minerals

	// We are currently in the middle of something
	if(timer > world.time)
		return

	switch(mode)
		if(DRONE_READY)
			// If we have X drone shells already on our turf
			if(maximum_idle && (count_shells() >= maximum_idle))
				return // then do nothing; check again next tick
			if(begin_create_message)
				visible_message(span_notice("[src] [begin_create_message]"))
			if(work_sound)
				playsound(src, work_sound, 50, TRUE)
			mode = DRONE_PRODUCTION
			timer = world.time + production_time
			update_appearance()

		if(DRONE_PRODUCTION)
			materials.use_materials(using_materials)
			if(energy_used)
				use_energy(energy_used)

			for(var/spawnable_item as anything in dispense_type)
				var/atom/spawned_atom = new spawnable_item(loc)
				spawned_atom.flags_1 |= (flags_1 & ADMIN_SPAWNED_1)

			if(create_sound)
				playsound(src, create_sound, 50, TRUE)
			if(end_create_message)
				visible_message(span_notice("[src] [end_create_message]"))

			mode = DRONE_RECHARGING
			timer = world.time + cooldownTime
			update_appearance()

		if(DRONE_RECHARGING)
			if(recharge_sound)
				playsound(src, recharge_sound, 50, TRUE)
			if(recharge_message)
				visible_message(span_notice("[src] [recharge_message]"))

			mode = DRONE_READY
			update_appearance()

/obj/machinery/drone_dispenser/proc/count_shells()
	. = 0
	for(var/actual_shell in loc)
		for(var/potential_item as anything in dispense_type)
			if(istype(actual_shell, potential_item))
				.++

/obj/machinery/drone_dispenser/update_icon_state()
	if(machine_stat & (BROKEN|NOPOWER))
		icon_state = icon_off
		return ..()
	if(mode == DRONE_RECHARGING)
		icon_state = icon_recharging
		return ..()
	if(mode == DRONE_PRODUCTION)
		icon_state = icon_creating
		return ..()
	icon_state = icon_on
	return ..()

/obj/machinery/drone_dispenser/crowbar_act(mob/living/user, obj/item/tool)
	materials.retrieve_all()
	tool.play_tool_sound(src)
	to_chat(user, span_notice("You retrieve the materials from [src]."))
	return ITEM_INTERACT_SUCCESS

/obj/machinery/drone_dispenser/welder_act(mob/living/user, obj/item/tool)
	if(!(machine_stat & BROKEN))
		to_chat(user, span_warning("[src] doesn't need repairs."))
		return ITEM_INTERACT_BLOCKING

	if(!tool.tool_start_check(user, amount=1))
		return ITEM_INTERACT_BLOCKING

	user.visible_message(
		span_notice("[user] begins patching up [src] with [tool]."),
		span_notice("You begin restoring the damage to [src]..."))

	if(!tool.use_tool(src, user, 40, volume=50))
		return ITEM_INTERACT_BLOCKING

	user.visible_message(
		span_notice("[user] fixes [src]!"),
		span_notice("You restore [src] to operation."))

	set_machine_stat(machine_stat & ~BROKEN)
	atom_integrity = max_integrity
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/drone_dispenser/atom_break(damage_flag)
	. = ..()
	if(!.)
		return
	if(break_message)
		audible_message(span_warning("[src] [break_message]"))
	if(break_sound)
		playsound(src, break_sound, 50, TRUE)

#undef DRONE_PRODUCTION
#undef DRONE_RECHARGING
#undef DRONE_READY
