GLOBAL_LIST_EMPTY_TYPED(slime_pen_controllers, /obj/machinery/slime_pen_controller)

/obj/item/wallframe/slime_pen_controller
	name = "slime pen management frame"
	desc = "Used for building slime pen consoles."
	icon_state = "button"
	result_path = /obj/machinery/slime_pen_controller
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)
	pixel_shift = 24


/obj/machinery/slime_pen_controller
	name = "slime pen management console"
	desc = "It seems most of the features are locked down, the developers must have been pretty lazy. Can turn the ooze sucker on and off though. Can link a sucker to this using a multitool."

	icon = 'monkestation/code/modules/slimecore/icons/machinery.dmi'
	base_icon_state = "slime_panel"
	icon_state = "slime_panel"

	var/obj/machinery/plumbing/ooze_sucker/linked_sucker
	var/datum/corral_data/linked_data
	var/mapping_id

/obj/machinery/slime_pen_controller/Initialize(mapload)
	. = ..()
	GLOB.slime_pen_controllers += src
	register_context()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/slime_pen_controller/LateInitialize()
	. = ..()
	locate_machinery()

/obj/machinery/slime_pen_controller/Destroy()
	GLOB.slime_pen_controllers -= src
	return ..()

/obj/machinery/slime_pen_controller/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(linked_sucker)
		context[SCREENTIP_CONTEXT_RMB] = "Toggle Linked Scrubber"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/slime_pen_controller/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SlimePenController", "[src]")
		ui.open()

/obj/machinery/slime_pen_controller/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	if(!linked_data)
		data["slimes"] = list()
		data["corral_upgrades"] = list()
		data["buyable_upgrades"] = list()
		data["capacity"] = "0/0"

	else
		data["slimes"] = list()
		linked_data.update_slimes()
		data["capacity"] = "[length(linked_data.managed_slimes)]/[linked_data.max_capacity]"

		for(var/mob/living/basic/slime/slime as anything in linked_data.managed_slimes)
			var/list/slime_data = list()
			slime_data += list(
				"name" = slime.name,
				"health" = round((slime.health / slime.maxHealth) * 100),
				"slime_color" = capitalize(slime.current_color.name),
				"hunger_precent" = slime.hunger_precent,
				"mutation_chance" = slime.mutation_chance,
				"accessory" = slime.worn_accessory ? slime.worn_accessory.name : "None",
			)
			slime_data["possible_mutations"] = list()
			for(var/datum/slime_mutation_data/mutation_data as anything in slime.possible_color_mutations)
				var/list/mutation_info = list()
				var/mob_string
				for(var/mob/living/mob as anything in mutation_data.latch_needed)
					mob_string += "[mutation_data.latch_needed[mob]] units of genetic data from [mob::name]. \n"
				var/item_string
				for(var/obj/item/item as anything in mutation_data.needed_items)
					item_string += "[item:name]. \n"

				mutation_info += list(
					"color" = capitalize(mutation_data.output::name),
					"weight" = mutation_data.weight,
					"mutate_chance" = mutation_data.mutate_probability,
					"mobs_needed" = mob_string,
					"items_needed" = item_string,
				)
				slime_data["possible_mutations"] += list(mutation_info)

			slime_data["traits"] = list()
			for(var/datum/slime_trait/trait as anything in slime.slime_traits)
				var/list/trait_data = list()
				trait_data += list(
					"name" = trait.name,
					"desc" = trait.desc,
					"food" = (FOOD_CHANGE in trait.menu_buttons),
					"environment" = (ENVIRONMENT_CHANGE in trait.menu_buttons),
					"behaviour" = (BEHAVIOUR_CHANGE in trait.menu_buttons),
					"danger" = (DANGEROUS_CHANGE in trait.menu_buttons),
					"docile" = (DOCILE_CHANGE in trait.menu_buttons),
				)
				slime_data["traits"] += list(trait_data)

			data["slimes"] += list(slime_data)

		data["corral_upgrades"] = list()
		for(var/datum/corral_upgrade/upgrade as anything in linked_data.corral_upgrades)
			data["corral_upgrades"] += list(list(
				"name" = upgrade.name,
				"desc" = upgrade.desc,
			))

		data["buyable_upgrades"] = list()
		for(var/datum/corral_upgrade/listed as anything in subtypesof(/datum/corral_upgrade))
			var/list/upgrade_data = list()
			upgrade_data += list(
				"name" = listed.name,
				"desc" = listed.desc,
				"cost" = listed.cost,
				"owned" = (listed in linked_data.corral_upgrades),
				"path" = listed.type,
			)
			data["buyable_upgrades"] += list(upgrade_data)

	data["reagent_amount"] = 0
	data["reagent_data"] = list()
	if(linked_sucker)
		data["reagent_amount"] = linked_sucker.reagents.total_volume
		data["reagent_data"] = list()
		for(var/datum/reagent/reagent as anything in linked_sucker.reagents.reagent_list)
			data["reagent_data"] += list(list(
				"name" = reagent.name,
				"amount" = reagent.volume,
			))

	return data

/obj/machinery/slime_pen_controller/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("buy")
			for(var/datum/corral_upgrade/item as anything in subtypesof(/datum/corral_upgrade))
				if(text2path(params["path"]) == item)
					try_buy(item)
					return TRUE

/obj/machinery/slime_pen_controller/proc/try_buy(datum/corral_upgrade/item)
	if(!linked_data)
		return
	if(SSresearch.xenobio_points < item::cost)
		return

	var/datum/corral_upgrade/new_upgrade = new item
	SSresearch.xenobio_points -= new_upgrade.cost
	new_upgrade.on_add(linked_data)
	linked_data.corral_upgrades |= new_upgrade

/obj/machinery/slime_pen_controller/locate_machinery(multitool_connection)
	if(!mapping_id)
		return
	for(var/obj/machinery/plumbing/ooze_sucker/main in GLOB.machines)
		if(main.mapping_id != mapping_id)
			continue
		linked_sucker = main
		main.linked_controller = src
		return

/obj/machinery/slime_pen_controller/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!QDELETED(linked_sucker))
		linked_sucker.toggle_state()
		balloon_alert_to_viewers("[linked_sucker.turned_on ? "enabled" : "disabled"] ooze sucker")
		visible_message(span_notice("[user] fiddles with the [src], [linked_sucker.turned_on ? "enabling" : "disabling"] the pens ooze sucker."))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/slime_pen_controller/multitool_act(mob/living/user, obj/item/multitool/multitool)
	if(!multitool_check_buffer(user, multitool) || QDELETED(multitool.buffer))
		return
	var/obj/machinery/corral_corner/pad = multitool.buffer
	if(!istype(pad) || !pad.connected_data)
		return
	if(linked_data)
		UnregisterSignal(linked_data, COMSIG_QDELETING)
	linked_data = pad.connected_data
	RegisterSignal(linked_data, COMSIG_QDELETING, PROC_REF(clear_data))
	balloon_alert_to_viewers("linked pen")
	pad.balloon_alert_to_viewers("linked to controller")
	to_chat(user, span_notice("You link the [pad] to the [src]."))
	return TRUE

/obj/machinery/slime_pen_controller/proc/clear_data()
	UnregisterSignal(linked_data, COMSIG_QDELETING)
	linked_data = null
