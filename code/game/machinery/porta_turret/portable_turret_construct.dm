#define PTURRET_UNSECURED  0
#define PTURRET_BOLTED  1
#define PTURRET_START_INTERNAL_ARMOUR  2
#define PTURRET_INTERNAL_ARMOUR_ON  3
#define PTURRET_GUN_EQUIPPED  4
#define PTURRET_SENSORS_ON  5
#define PTURRET_CLOSED  6
#define PTURRET_START_EXTERNAL_ARMOUR  7
#define PTURRET_EXTERNAL_ARMOUR_ON  8

/obj/machinery/porta_turret_construct
	name = "turret frame"
	icon = 'icons/obj/weapons/turrets.dmi'
	icon_state = "turret_frame"
	desc = "An unfinished covered turret frame."
	anchored = FALSE
	density = TRUE
	obj_flags = UNIQUE_RENAME | RENAME_NO_DESC
	use_power = NO_POWER_USE
	var/build_step = PTURRET_UNSECURED //the current step in the building process
	var/finish_name = "turret" //the name applied to the product turret
	var/obj/item/gun/installed_gun = null

/obj/machinery/porta_turret_construct/examine(mob/user)
	. = ..()
	switch(build_step)
		if(PTURRET_UNSECURED)
			. += span_notice("The external bolts are <b>unwrenched</b>, and the frame could be <i>pried</i> apart.")
		if(PTURRET_BOLTED)
			. += span_notice("The frame requires <b>metal</b> for its internal armor, the external bolts are <i>wrenched</i> in place.")
		if(PTURRET_START_INTERNAL_ARMOUR)
			. += span_notice("The turret's armor needs to be <b>bolted</b> in place, the armor looked like it could be <i>welded</i> out.")
		if(PTURRET_INTERNAL_ARMOUR_ON)
			. += span_notice("The turret requires an <b>energy based gun</b> to function, the armor is secured by <i>bolts</i>.")
		if(PTURRET_GUN_EQUIPPED)
			. += span_notice("The turret requires an <b>proximity sensor</b> to function. The energy gun could <i>be removed</i>.")
		if(PTURRET_SENSORS_ON)
			. += span_notice("The turret's access hatch is <b>unscrewed</b>. The proximity sensor could <i>be removed</i>.")
		if(PTURRET_CLOSED)
			. += span_notice("The turret requires <b>metal</b> for its external armor, the access hatch could be <i>unscrewed</i>.")
		if(PTURRET_START_EXTERNAL_ARMOUR)
			. += span_notice("The turret's armor needs to be <b>welded</b> in place, the armor looks like it could be <i>pried</i> off.")

/obj/machinery/porta_turret_construct/attackby(obj/item/used, mob/user, list/modifiers, list/attack_modifiers)
	//this is a bit unwieldy but self-explanatory
	switch(build_step)
		if(PTURRET_UNSECURED) //first step
			if(used.tool_behaviour == TOOL_WRENCH && !anchored)
				used.play_tool_sound(src, 100)
				to_chat(user, span_notice("You secure the external bolts."))
				set_anchored(TRUE)
				build_step = PTURRET_BOLTED
				return

			else if(used.tool_behaviour == TOOL_CROWBAR && !anchored)
				used.play_tool_sound(src, 75)
				to_chat(user, span_notice("You dismantle the turret construction."))
				new /obj/item/stack/sheet/iron(loc, 5)
				qdel(src)
				return

		if(PTURRET_BOLTED)
			if(istype(used, /obj/item/stack/sheet/iron))
				var/obj/item/stack/sheet/iron/sheet = used
				if(sheet.use(2))
					to_chat(user, span_notice("You add some metal armor to the interior frame."))
					build_step = PTURRET_START_INTERNAL_ARMOUR
					icon_state = "turret_frame2"
				else
					to_chat(user, span_warning("You need two sheets of iron to continue construction!"))
				return

			else if(used.tool_behaviour == TOOL_WRENCH)
				used.play_tool_sound(src, 75)
				to_chat(user, span_notice("You unfasten the external bolts."))
				set_anchored(FALSE)
				build_step = PTURRET_UNSECURED
				return


		if(PTURRET_START_INTERNAL_ARMOUR)
			if(used.tool_behaviour == TOOL_WRENCH)
				used.play_tool_sound(src, 100)
				to_chat(user, span_notice("You bolt the metal armor into place."))
				build_step = PTURRET_INTERNAL_ARMOUR_ON
				return

			else if(used.tool_behaviour == TOOL_WELDER)
				if(!used.tool_start_check(user, amount = 5)) //uses up 5 fuel
					return

				to_chat(user, span_notice("You start to remove the turret's interior metal armor..."))

				if(used.use_tool(src, user, 20, volume = 50, amount = 5)) //uses up 5 fuel
					build_step = PTURRET_BOLTED
					to_chat(user, span_notice("You remove the turret's interior metal armor."))
					new /obj/item/stack/sheet/iron(drop_location(), 2)
					return


		if(PTURRET_INTERNAL_ARMOUR_ON)
			if(istype(used, /obj/item/gun/energy)) //the gun installation part
				var/obj/item/gun/energy/egun = used
				if(egun.gun_flags & TURRET_INCOMPATIBLE)
					to_chat(user, span_notice("You don't think it would be right to add [used] to the turret"))
					return
				if(!user.transferItemToLoc(egun, src))
					return
				installed_gun = egun
				to_chat(user, span_notice("You add [used] to the turret."))
				build_step = PTURRET_GUN_EQUIPPED
				return
			else if(used.tool_behaviour == TOOL_WRENCH)
				used.play_tool_sound(src, 100)
				to_chat(user, span_notice("You remove the turret's metal armor bolts."))
				build_step = PTURRET_START_INTERNAL_ARMOUR
				return

		if(PTURRET_GUN_EQUIPPED)
			if(isprox(used))
				build_step = PTURRET_SENSORS_ON
				if(!user.temporarilyRemoveItemFromInventory(used))
					return
				to_chat(user, span_notice("You add the proximity sensor to the turret."))
				qdel(used)
				return


		if(PTURRET_SENSORS_ON)
			if(used.tool_behaviour == TOOL_SCREWDRIVER)
				used.play_tool_sound(src, 100)
				build_step = PTURRET_CLOSED
				to_chat(user, span_notice("You close the internal access hatch."))
				return


		if(PTURRET_CLOSED)
			if(istype(used, /obj/item/stack/sheet/iron))
				var/obj/item/stack/sheet/iron/sheet = used
				if(sheet.use(2))
					to_chat(user, span_notice("You add some metal armor to the exterior frame."))
					build_step = PTURRET_START_EXTERNAL_ARMOUR
				else
					to_chat(user, span_warning("You need two sheets of iron to continue construction!"))
				return

			else if(used.tool_behaviour == TOOL_SCREWDRIVER)
				used.play_tool_sound(src, 100)
				build_step = PTURRET_SENSORS_ON
				to_chat(user, span_notice("You open the internal access hatch."))
				return

		if(PTURRET_START_EXTERNAL_ARMOUR)
			if(used.tool_behaviour == TOOL_WELDER)
				if(!used.tool_start_check(user, amount = 5))
					return

				to_chat(user, span_notice("You begin to weld the turret's armor down..."))
				if(used.use_tool(src, user, 30, volume = 50, amount = 5))
					build_step = PTURRET_EXTERNAL_ARMOUR_ON
					to_chat(user, span_notice("You weld the turret's armor down."))

					//The final step: create a full turret

					var/obj/machinery/porta_turret/turret
					//fuck lasertag turrets
					if(istype(installed_gun, /obj/item/gun/energy/laser/bluetag) || istype(installed_gun, /obj/item/gun/energy/laser/redtag))
						turret = new/obj/machinery/porta_turret/lasertag(loc)
					else
						turret = new/obj/machinery/porta_turret(loc)
					turret.name = finish_name
					turret.installation = installed_gun.type
					turret.setup(installed_gun)
					turret.locked = FALSE
					qdel(src)
					return

			else if(used.tool_behaviour == TOOL_CROWBAR)
				used.play_tool_sound(src, 75)
				to_chat(user, span_notice("You pry off the turret's exterior armor."))
				new /obj/item/stack/sheet/iron(loc, 2)
				build_step = PTURRET_CLOSED
				return

	if(used.get_writing_implement_details()?["interaction_mode"] == MODE_WRITING) //you can rename turrets like bots!
		var/choice = tgui_input_text(user, "Enter a new turret name", "Turret Classification", finish_name, max_length = MAX_NAME_LEN)
		if(!choice)
			return
		if(!user.can_perform_action(src))
			return

		finish_name = choice
		return
	return ..()

/obj/machinery/porta_turret_construct/nameformat(input, user)
	finish_name = input
	return input

/obj/machinery/porta_turret_construct/rename_reset()
	finish_name = initial(finish_name)

/obj/machinery/porta_turret_construct/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	switch(build_step)
		if(PTURRET_GUN_EQUIPPED)
			build_step = PTURRET_INTERNAL_ARMOUR_ON

			installed_gun.forceMove(loc)
			to_chat(user, span_notice("You remove [installed_gun] from the turret frame."))
			installed_gun = null

		if(PTURRET_SENSORS_ON)
			to_chat(user, span_notice("You remove the prox sensor from the turret frame."))
			new /obj/item/assembly/prox_sensor(loc)
			build_step = PTURRET_GUN_EQUIPPED

/obj/machinery/porta_turret_construct/attack_ai()
	return

#undef PTURRET_BOLTED
#undef PTURRET_CLOSED
#undef PTURRET_EXTERNAL_ARMOUR_ON
#undef PTURRET_GUN_EQUIPPED
#undef PTURRET_INTERNAL_ARMOUR_ON
#undef PTURRET_SENSORS_ON
#undef PTURRET_START_EXTERNAL_ARMOUR
#undef PTURRET_START_INTERNAL_ARMOUR
#undef PTURRET_UNSECURED
