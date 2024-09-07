// Researcher, Scanner, Recoverer, and Digger

/obj/machinery/xenoarch
	icon = 'modular_doppler/xenoarch/icons/xenoarch_machines.dmi'
	density = TRUE
	layer = BELOW_OBJ_LAYER
	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	pass_flags = PASSTABLE
	/// the item that holds everything
	var/obj/item/storage_unit
	///how long between each process
	var/process_speed = 10 SECONDS
	COOLDOWN_DECLARE(process_delay)

/obj/machinery/xenoarch/Initialize(mapload)
	. = ..()
	storage_unit = new /obj/item(src)

/obj/machinery/xenoarch/Destroy()
	QDEL_NULL(storage_unit)
	return ..()

/obj/machinery/xenoarch/RefreshParts()
	. = ..()
	var/efficiency = -2 //to allow t1 parts to not change the base speed
	for(var/datum/stock_part/stockpart in component_parts)
		efficiency += stockpart.tier

	process_speed = initial(process_speed) - (efficiency)

/obj/machinery/xenoarch/process()
	if(machine_stat & (NOPOWER|BROKEN) || !anchored)
		COOLDOWN_RESET(src, process_delay) //if you are broken or no power (or not anchored), you aren't allowed to progress!
		return

	if(!COOLDOWN_FINISHED(src, process_delay))
		return

	COOLDOWN_START(src, process_delay, process_speed)
	xenoarch_process()

/obj/machinery/xenoarch/proc/xenoarch_process()
	return

/obj/machinery/xenoarch/wrench_act(mob/living/user, obj/item/tool)
	. = ..()

	if(default_unfasten_wrench(user, tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/xenoarch/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()

	toggle_panel_open()
	to_chat(user, span_notice("You [panel_open ? "open":"close"] the maintenance panel of [src]."))
	tool.play_tool_sound(src)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/xenoarch/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()

	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/xenoarch/researcher
	name = "xenoarch researcher"
	desc = "A machine that is used to condense strange rocks, useless relics, and broken objects into bigger artifacts."
	icon_state = "researcher"
	circuit = /obj/item/circuitboard/machine/xenoarch_machine/xenoarch_researcher
	/// the amount of research that is currently done
	var/current_research = 0
	/// the max amount of value we can have
	var/max_research = 300
	/// the value of each accepted item
	var/list/accepted_types = list(
		/obj/item/xenoarch/strange_rock = 1,
		/obj/item/xenoarch/useless_relic = 5,
		/obj/item/xenoarch/useless_relic/magnified = 10,
		/obj/item/xenoarch/broken_item = 10,
	)

/obj/machinery/xenoarch/researcher/examine(mob/user)
	. = ..()

	. += span_notice("<br>[current_research]/[max_research] research available.")
	. += span_notice("L-Click to insert items or take out all the strange rocks. R-Click to use research points.")

/obj/machinery/xenoarch/researcher/attackby(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/storage/bag/xenoarch))
		for(var/obj/strange_rocks in weapon.contents)
			strange_rocks.forceMove(storage_unit)

		balloon_alert(user, "rocks inserted!")
		return

	if(is_type_in_list(weapon, accepted_types))
		weapon.forceMove(storage_unit)
		balloon_alert(user, "item inserted!")
		return

	return ..()

/obj/machinery/xenoarch/researcher/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	var/choice = tgui_input_list(user, "Remove the rocks from [src]?", "Rock Removal", list("Yes", "No"))
	if(choice != "Yes")
		return
	var/turf/src_turf = get_turf(src)
	for(var/obj/item/removed_item in storage_unit.contents)
		removed_item.forceMove(src_turf)

	balloon_alert(user, "items removed!")

/obj/machinery/xenoarch/researcher/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	var/turf/src_turf = get_turf(src)
	var/choice = tgui_input_list(user, "Choose which reward you would like!", "Reward Choice", list("Lavaland Chest (150)", "Anomalous Crystal (150)", "Bepis Tech (100)"))
	if(!choice)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	switch(choice)
		if("Lavaland Chest (150)")
			if(current_research < 150)
				balloon_alert(user, "insufficient research!")
				return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

			current_research -= 150
			new /obj/structure/closet/crate/necropolis/tendril(src_turf)

		if("Anomalous Crystal (150)")
			if(current_research < 150)
				balloon_alert(user, "insufficient research!")
				return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

			current_research -= 150
			var/list/choices = subtypesof(/obj/machinery/anomalous_crystal) - /obj/machinery/anomalous_crystal/theme_warp
			var/random_crystal = pick(choices)
			new random_crystal(src_turf)

		if("Bepis Tech (100)")
			if(current_research < 100)
				balloon_alert(user, "insufficient research!")
				return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

			current_research -= 100
			new /obj/item/disk/design_disk/bepis/remove_tech(src_turf)

	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/xenoarch/researcher/xenoarch_process()
	if(length(storage_unit.contents) <= 0)
		return

	if(current_research >= max_research)
		return

	var/obj/item/first_item = storage_unit.contents[1]
	var/reward_attempt = accepted_types[first_item.type]
	current_research = min(current_research + reward_attempt, 300)
	qdel(first_item)

/obj/machinery/xenoarch/scanner
	name = "xenoarch scanner"
	desc = "A machine that is used to scan strange rocks, making it easier to extract the item inside."
	icon_state = "scanner"
	circuit = /obj/item/circuitboard/machine/xenoarch_machine/xenoarch_scanner

/obj/machinery/xenoarch/scanner/attackby(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/storage/bag/xenoarch))
		for(var/obj/item/xenoarch/strange_rock/chosen_rocks in weapon.contents)
			chosen_rocks.get_scanned()

		balloon_alert(user, "scan complete!")
		return

	if(istype(weapon, /obj/item/xenoarch/strange_rock))
		var/obj/item/xenoarch/strange_rock/chosen_rock
		if(chosen_rock.get_scanned())
			balloon_alert(user, "scan complete!")
			return

		to_chat(user, span_warning("[chosen_rock] was unable to be scanned, perhaps it was already scanned?"))
		return

	return ..()

/obj/machinery/xenoarch/recoverer
	name = "xenoarch recoverer"
	desc = "A machine that will recover the damaged, destroyed objects found within the strange rocks."
	icon_state = "recoverer"
	circuit = /obj/item/circuitboard/machine/xenoarch_machine/xenoarch_recoverer

/obj/machinery/xenoarch/recoverer/examine(mob/user)
	. = ..()
	. += span_notice("<br>L-Click to remove all items inside [src].")

/obj/machinery/xenoarch/recoverer/attackby(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/xenoarch/broken_item))
		weapon.forceMove(storage_unit)
		balloon_alert(user, "item inserted!")
		return

	return ..()

/obj/machinery/xenoarch/recoverer/attack_hand(mob/living/user, list/modifiers)
	var/choice = tgui_input_list(user, "Remove the broken items from [src]?", "Item Removal", list("Yes", "No"))
	if(choice != "Yes")
		return

	var/turf/src_turf = get_turf(src)
	for(var/obj/item/removed_item in storage_unit.contents)
		removed_item.forceMove(src_turf)

	balloon_alert(user, "items removed!")

/obj/machinery/xenoarch/recoverer/xenoarch_process()
	var/turf/src_turf = get_turf(src)
	if(length(storage_unit.contents) <= 0)
		return

	var/obj/item/content_obj = storage_unit.contents[1]
	if(!istype(content_obj, /obj/item/xenoarch/broken_item))
		qdel(content_obj)
		return

	if(istype(content_obj, /obj/item/xenoarch/broken_item/tech))
		var/spawn_item = pick_weight(GLOB.tech_reward)
		recover_item(spawn_item, content_obj)
		return

	if(istype(content_obj, /obj/item/xenoarch/broken_item/weapon))
		var/spawn_item = pick_weight(GLOB.weapon_reward)
		recover_item(spawn_item, content_obj)
		return

	if(istype(content_obj, /obj/item/xenoarch/broken_item/illegal))
		var/spawn_item = pick_weight(GLOB.illegal_reward)
		recover_item(spawn_item, content_obj)
		return

	if(istype(content_obj, /obj/item/xenoarch/broken_item/alien))
		var/spawn_item = pick_weight(GLOB.alien_reward)
		recover_item(spawn_item, content_obj)
		return

	if(istype(content_obj, /obj/item/xenoarch/broken_item/plant))
		var/spawn_item = pick_weight(GLOB.plant_reward)
		recover_item(spawn_item, content_obj)
		return

	if(istype(content_obj, /obj/item/xenoarch/broken_item/clothing))
		var/spawn_item = pick_weight(GLOB.clothing_reward)
		recover_item(spawn_item, content_obj)
		return

	if(istype(content_obj, /obj/item/xenoarch/broken_item/animal))
		var/spawn_item
		for(var/looptime in 1 to rand(1,4))
			spawn_item = pick_weight(GLOB.animal_reward)
			new spawn_item(src_turf)

		recover_item(spawn_item, content_obj)
		return

/obj/machinery/xenoarch/recoverer/proc/recover_item(obj/insert_obj, obj/delete_obj)
	var/src_turf = get_turf(src)
	new insert_obj(src_turf)
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	qdel(delete_obj)

/obj/machinery/xenoarch/digger
	name = "xenoarch digger"
	desc = "A machine that is used to slowly uncover items within strange rocks."
	icon_state = "digger"
	circuit = /obj/item/circuitboard/machine/xenoarch_machine/xenoarch_digger

/obj/machinery/xenoarch/digger/examine(mob/user)
	. = ..()
	. += span_notice("<br>L-Click to remove all items inside [src].")

/obj/machinery/xenoarch/digger/attackby(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/storage/bag/xenoarch))
		for(var/obj/strange_rocks in weapon.contents)
			strange_rocks.forceMove(storage_unit)

		balloon_alert(user, "rocks inserted!")
		return

	if(istype(weapon, /obj/item/xenoarch/strange_rock))
		weapon.forceMove(src)
		balloon_alert(user, "rock inserted!")
		return

/obj/machinery/xenoarch/digger/attack_hand(mob/living/user, list/modifiers)
	var/choice = tgui_input_list(user, "Remove the rocks from [src]?", "Rock Removal", list("Yes", "No"))
	if(choice != "Yes")
		return

	var/turf/src_turf = get_turf(src)
	for(var/obj/item/removed_item in storage_unit.contents)
		removed_item.forceMove(src_turf)

	balloon_alert(user, "items removed!")

/obj/machinery/xenoarch/digger/xenoarch_process()
	var/turf/src_turf = get_turf(src)
	if(length(storage_unit.contents) <= 0)
		return

	var/obj/item/xenoarch/strange_rock/first_item = storage_unit.contents[1]
	new first_item.hidden_item(src_turf)
	qdel(first_item)
