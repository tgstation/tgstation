/obj/machinery/colony_recycler
	name = "materials recycler"
	desc = "A large crushing machine used to recycle small items inefficiently. Items are inserted by hand, rather than by belt. \
		Mind your fingers."
	icon = 'modular_doppler/colony_fabricator/icons/portable_machines.dmi'
	icon_state = "recycler"
	anchored = FALSE
	density = TRUE
	circuit = null
	/// The percentage of materials returned
	var/amount_produced = 80
	/// The sound made when an item is eaten
//	var/item_recycle_sound = 'modular_doppler/reagent_forging/sound/forge.ogg'
	/// The recycler's internal materials storage, for when items recycled don't produce enough to make a full sheet of that material
	var/datum/component/material_container/materials
	/// The list of all the materials we can recycle
	var/static/list/allowed_materials = list(
		/datum/material/iron,
		/datum/material/glass,
		/datum/material/silver,
		/datum/material/plasma,
		/datum/material/gold,
		/datum/material/diamond,
		/datum/material/plastic,
		/datum/material/uranium,
		/datum/material/bananium,
		/datum/material/titanium,
		/datum/material/bluespace,
	)
	/// The item we turn into when repacked
	var/repacked_type = /obj/item/flatpacked_machine/recycler

/obj/machinery/colony_recycler/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/repackable, repacked_type, 5 SECONDS)
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)
	materials = AddComponent( \
		/datum/component/material_container, \
		allowed_materials, \
		INFINITY, \
		MATCONTAINER_EXAMINE, \
		container_signals = list(COMSIG_MATCONTAINER_ITEM_CONSUMED = TYPE_PROC_REF(/obj/machinery/colony_recycler, has_eaten_materials)), \
	)

/obj/machinery/colony_recycler/Destroy()
	materials = null
	return ..()

/obj/machinery/colony_recycler/examine(mob/user)
	. = ..()
	. += span_notice("Reclaiming <b>[amount_produced]%</b> of materials salvaged.")
	. += span_notice("Can be <b>secured</b> with a <b>wrench</b> using <b>Right-Click</b>.")

/obj/machinery/colony_recycler/wrench_act_secondary(mob/living/user, obj/item/tool)
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/// Proc called when the recycler eats new materials, checks if we should spit out new material sheets
/obj/machinery/colony_recycler/proc/has_eaten_materials(container, obj/item/item_inserted, last_inserted_id, mats_consumed, amount_inserted, atom/context)
	SIGNAL_HANDLER

	flick("recycler_grind", src)
//	playsound(src, item_recycle_sound, 50, TRUE)
	use_energy(min(active_power_usage * 0.25, amount_inserted / 100))

	if(amount_inserted)
		materials.retrieve_all(drop_location())

// "parts kit" for buying these from cargo

/obj/item/flatpacked_machine/recycler
	name = "recycler parts kit"
	icon = 'modular_doppler/colony_fabricator/icons/parts_kits.dmi'
	icon_state = "recycler"
	type_to_deploy = /obj/machinery/colony_recycler
	deploy_time = 2 SECONDS
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/titanium = HALF_SHEET_MATERIAL_AMOUNT, // Titan for the crushing element
	)
