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
	var/icon_off = "off"
	var/icon_on = "on"
	var/icon_recharging = "recharge"
	var/icon_creating = "make"

	var/list/using_materials
	var/starting_amount = 0
	var/iron_cost = HALF_SHEET_MATERIAL_AMOUNT
	var/glass_cost = HALF_SHEET_MATERIAL_AMOUNT
	var/power_used = 1000

	var/mode = DRONE_READY
	var/timer
	var/cooldownTime = 1800 //3 minutes
	var/production_time = 30
	//The item the dispenser will create
	var/dispense_type = /obj/effect/mob_spawn/ghost_role/drone

	// The maximum number of "idle" drone shells it will make before
	// ceasing production. Set to 0 for infinite.
	var/maximum_idle = 3

	var/work_sound = 'sound/items/rped.ogg'
	var/create_sound = 'sound/items/deconstruct.ogg'
	var/recharge_sound = 'sound/machines/ping.ogg'

	var/begin_create_message = "whirs to life!"
	var/end_create_message = "dispenses a drone shell."
	var/recharge_message = "pings."
	var/recharging_text = "It is whirring and clicking. It seems to be recharging."

	var/break_message = "lets out a tinny alarm before falling dark."
	var/break_sound = 'sound/machines/warning-buzzer.ogg'

	var/datum/component/material_container/materials

/obj/machinery/drone_dispenser/Initialize(mapload)
	. = ..()
	materials = AddComponent( \
		/datum/component/material_container, \
		list(/datum/material/iron, /datum/material/glass), \
		SHEET_MATERIAL_AMOUNT * MAX_STACK_SIZE * 2, \
		MATCONTAINER_EXAMINE|BREAKDOWN_FLAGS_DRONE_DISPENSER, \
		allowed_items=/obj/item/stack \
	)
	materials.insert_amount_mat(starting_amount)
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
	dispense_type = /obj/effect/mob_spawn/ghost_role/drone/syndrone
	//If we're gonna be a jackass, go the full mile - 10 second recharge timer
	cooldownTime = 100
	end_create_message = "dispenses a suspicious drone shell."
	starting_amount = SHEET_MATERIAL_AMOUNT * 12.5

/obj/machinery/drone_dispenser/syndrone/badass //Please forgive me
	name = "badass syndrone shell dispenser"
	desc = "A suspicious machine that will create Syndicate exterminator drones when supplied with iron and glass. Disgusting. This one seems ominous."
	dispense_type = /obj/effect/mob_spawn/ghost_role/drone/syndrone/badass
	end_create_message = "dispenses an ominous suspicious drone shell."

// I don't need your forgiveness, this is awesome.
/obj/machinery/drone_dispenser/snowflake
	name = "snowflake drone shell dispenser"
	desc = "A hefty machine that, when supplied with iron and glass, will periodically create a snowflake drone shell. Does not need to be manually operated."
	dispense_type = /obj/effect/mob_spawn/ghost_role/drone/snowflake
	end_create_message = "dispenses a snowflake drone shell."
	// Those holoprojectors aren't cheap
	iron_cost = SHEET_MATERIAL_AMOUNT
	glass_cost = SHEET_MATERIAL_AMOUNT
	power_used = 2000
	starting_amount = SHEET_MATERIAL_AMOUNT * 5

// If the derelict gets lonely, make more friends.
/obj/machinery/drone_dispenser/derelict
	name = "derelict drone shell dispenser"
	desc = "A rusty machine that, when supplied with iron and glass, will periodically create a derelict drone shell. Does not need to be manually operated."
	dispense_type = /obj/effect/mob_spawn/ghost_role/drone/derelict
	end_create_message = "dispenses a derelict drone shell."
	iron_cost = SHEET_MATERIAL_AMOUNT * 5
	glass_cost = SHEET_MATERIAL_AMOUNT * 2.5
	starting_amount = 0
	cooldownTime = 600

/obj/machinery/drone_dispenser/classic
	name = "classic drone shell dispenser"
	desc = "A hefty machine that, when supplied with iron and glass, will periodically create a classic drone shell. Does not need to be manually operated."
	dispense_type = /obj/effect/mob_spawn/ghost_role/drone/classic
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
	power_used = 0
	cooldownTime = 10 //Only 1 second - hivebots are extremely weak
	dispense_type = /mob/living/simple_animal/hostile/hivebot
	begin_create_message = "closes and begins fabricating something within."
	end_create_message = "slams open, revealing a hivebot!"
	recharge_sound = null
	recharge_message = null

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
	..()
	if((machine_stat & (NOPOWER|BROKEN)) || !anchored)
		return

	if(!materials.has_materials(using_materials))
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
			if(power_used)
				use_power(power_used)

			var/atom/A = new dispense_type(loc)
			A.flags_1 |= (flags_1 & ADMIN_SPAWNED_1)

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
	for(var/a in loc)
		if(istype(a, dispense_type))
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

/obj/machinery/drone_dispenser/attackby(obj/item/I, mob/living/user)
	if(I.tool_behaviour == TOOL_CROWBAR)
		materials.retrieve_all()
		I.play_tool_sound(src)
		to_chat(user, span_notice("You retrieve the materials from [src]."))

	else if(I.tool_behaviour == TOOL_WELDER)
		if(!(machine_stat & BROKEN))
			to_chat(user, span_warning("[src] doesn't need repairs."))
			return

		if(!I.tool_start_check(user, amount=1))
			return

		user.visible_message(
			span_notice("[user] begins patching up [src] with [I]."),
			span_notice("You begin restoring the damage to [src]..."))

		if(!I.use_tool(src, user, 40, volume=50))
			return

		user.visible_message(
			span_notice("[user] fixes [src]!"),
			span_notice("You restore [src] to operation."))

		set_machine_stat(machine_stat & ~BROKEN)
		atom_integrity = max_integrity
		update_appearance()
	else
		return ..()

/obj/machinery/drone_dispenser/atom_break(damage_flag)
	. = ..()
	if(!.)
		return
	if(break_message)
		audible_message(span_warning("[src] [break_message]"))
	if(break_sound)
		playsound(src, break_sound, 50, TRUE)

/obj/machinery/drone_dispenser/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron(loc, 5)
	qdel(src)

#undef DRONE_PRODUCTION
#undef DRONE_RECHARGING
#undef DRONE_READY
