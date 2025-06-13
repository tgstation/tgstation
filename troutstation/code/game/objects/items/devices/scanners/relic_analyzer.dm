/// A list of relic nodes scanned per techweb
GLOBAL_LIST_EMPTY(relic_nodes_scanned)

/obj/item/relicanalyzer
	name = "relic analyzer"
	icon = 'troutstation/icons/obj/devices/scanner.dmi'
	icon_state = "relic"
	desc = "A hand-held scanner that analyzes relic potentials, aiding research efforts."
	obj_flags = CONDUCTS_ELECTRICITY
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT *2)
	interaction_flags_click = NEED_LITERACY|NEED_LIGHT|ALLOW_RESTING
	custom_price = PAYCHECK_COMMAND
	var/last_scan_text
	var/scanner_busy = FALSE
	/// Weakref to the last relic scanned
	var/datum/weakref/last_scanned
	/// Connect to global techweb
	var/datum/techweb/linked_techweb
	var/relic_node_scan_reward = 50


/obj/item/relicanalyzer/Initialize(mapload)
	. = ..()
	register_item_context()

	return INITIALIZE_HINT_LATELOAD

/obj/item/relicanalyzer/LateInitialize(mapload)
	if(!CONFIG_GET(flag/no_default_techweb_link) && !linked_techweb)
		CONNECT_TO_RND_SERVER_ROUNDSTART(linked_techweb, src)

/obj/item/relicanalyzer/proc/get_examine_text()
	var/text
	var/obj/item/relic/R = last_scanned?.resolve()
	if (!R || !R.current_node)
		text += "\nThe analyzer isn't linked to any relic yet."
		return text
	text += "[R] is currently in an activation state ID of [R.current_node.node_id]."
	var/list/scanned_relic_nodes = GLOB.relic_nodes_scanned[linked_techweb][R]
	if (scanned_relic_nodes.Find(R.current_node.node_id))
		text += "\n<font color= '#bb0000'>This state has already been logged.</font>"
	else
		text += "\n<font color='#7b6fff'>Examine with this scanner to log this relic's state!</font>"
	text += "\n[R.current_node.desc]"
	text += "\nPotential fruitful stimuli to the relic includes:"
	for (var/datum/relic_trans/i as anything in R.current_node.relic_transes)
		text += "\n- [i.desc]"
	return text

/obj/item/relicanalyzer/examine(mob/user)
	. = ..()
	var/readability_check = user.can_read(src) && !user.is_blind()
	if (readability_check)
		. += get_examine_text()
	return

/obj/item/relicanalyzer/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /obj/item/relic))
		return NONE

	var/obj/item/relic/R = interacting_with

	. = ITEM_INTERACT_SUCCESS

	add_fingerprint(user)

	// Clumsiness/brain damage check
	if ((HAS_TRAIT(user, TRAIT_CLUMSY) || HAS_TRAIT(user, TRAIT_DUMB)) && prob(50))
		var/turf/scan_turf = get_turf(user)
		user.visible_message(
			span_warning("[user] analyzes [scan_turf]'s states!"),
			span_notice("You stupidly try to analyze [scan_turf]'s states!"),
		)

		var/floor_text = "This floor is made of floor."

		if(user.can_read(src) && !user.is_blind())
			to_chat(user, custom_boxed_message("blue_box", floor_text))
		last_scan_text = floor_text
		return

	user.visible_message(span_notice("[user] analyzes [R]"))
	balloon_alert(user, "analyzing [R]")
	playsound(user.loc, pick('sound/items/healthanalyzer.ogg', 'sound/effects/industrial_scan/industrial_scan1.ogg', 'sound/effects/industrial_scan/industrial_scan2.ogg', 'sound/effects/industrial_scan/industrial_scan3.ogg'), 50)

	if (!R.activated)
		visible_message(span_notice("[user] scans the [R], revealing its true nature!"))
		playsound(src, 'sound/effects/supermatter.ogg', 50, 3, -1)
		R.reveal()

	var/readability_check = user.can_read(src) && !user.is_blind()

	last_scanned = WEAKREF(R)

	/// Add research to the techweb
	var/list/scanned_relics = GLOB.relic_nodes_scanned[linked_techweb]
	if (isnull(scanned_relics))
		scanned_relics = list()
		GLOB.relic_nodes_scanned[linked_techweb] = scanned_relics

	if (R)
		var/list/scanned_relic_nodes = scanned_relics[R]
		if (isnull(scanned_relic_nodes))
			scanned_relic_nodes = list()
			scanned_relics[R] = scanned_relic_nodes
		if (R.current_node && !scanned_relic_nodes.Find(R.current_node.node_id))
			scanned_relic_nodes.Add(R.current_node.node_id)
			linked_techweb.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = relic_node_scan_reward))
			to_chat(user, span_notice("The analyzer sends [relic_node_scan_reward] research points to the research server!"))
			playsound(src, 'sound/machines/beep/beep.ogg', 50, 3, -1)

	last_scan_text = get_examine_text()
	if (readability_check)
		to_chat(user, custom_boxed_message("blue_box", jointext(last_scan_text, "\n")), trailing_newline = FALSE, type = MESSAGE_TYPE_INFO)
	else
		to_chat(user, span_notice("You can't seem to read this device."))


/datum/design/relic_analyzer
	name = "Relic Analyzer"
	desc = "A device to analyze relic activation states and add their contributions to research."
	id = "relic_analyzer"
	build_type = PROTOLATHE | AWAY_LATHE | AUTOLATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT, /datum/material/glass = SMALL_MATERIAL_AMOUNT)
	build_path = /obj/item/relicanalyzer
	category = list(RND_CATEGORY_INITIAL,
					RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SCIENCE)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE
