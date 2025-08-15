/obj/structure/sign/gym
	name = "\improper Gym Encouragement Sign"
	sign_change_name = "gym_left"
	desc = "A sign of a hulking green man encouraging you to 'Unleash Your Inner Hulk'."
	icon_state = "gym-left"

/obj/structure/sign/gym/right
	icon_state = "gym-right"

/obj/structure/sign/gym/mirrored
	icon_state = "gymmirror-left"

/obj/structure/sign/gym/mirrored/right
	icon_state = "gymmirror-right"

/obj/structure/sign/xenobio_guide
	name = "\improper Slime genealogy sign"
	sign_change_name = "Xenobiology guide"
	desc = "A sign depicting how the slime colors change with mutations, and the grey slime in the root."
	icon_state = "xenobio-guide"
	is_editable = TRUE

/obj/structure/sign/chalkboard_menu
	name = "\improper Chalkboard coffee menu"
	icon_state = "chalkboard_menu"
	icon = 'icons/obj/machines/barsigns.dmi'
	desc = "85cr for a iced lactose-free caramel frappe?! Who buys that?!"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/xenobio_guide, 32)

// Tram-mounted statistics plate
/obj/structure/sign/tram_plate
	/// The tram we have info about
	var/specific_transport_id = TRAMSTATION_LINE_1
	/// Weakref to the tram we have info about
	var/datum/weakref/transport_ref
	/// Serial number of the tram
	var/tram_serial
	name = "tram information plate"
	sign_change_name = "Information - Tram Statistics"
	icon_state = "tram_plate"
	max_integrity = 150
	armor_type = /datum/armor/tram_structure
	is_editable = FALSE

/obj/structure/sign/tram_plate/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/sign/tram_plate/LateInitialize()
	link_tram()
	set_tram_serial()

/obj/structure/sign/tram_plate/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "View details"
		return CONTEXTUAL_SCREENTIP_SET

/obj/structure/sign/tram_plate/proc/link_tram()
	for(var/datum/transport_controller/linear/tram/tram as anything in SStransport.transports_by_type[TRANSPORT_TYPE_TRAM])
		if(tram.specific_transport_id == specific_transport_id)
			transport_ref = WEAKREF(tram)
			break

/obj/structure/sign/tram_plate/proc/set_tram_serial()
	var/datum/transport_controller/linear/tram/tram = transport_ref?.resolve()
	if(isnull(tram) || isnull(tram.tram_registration))
		return

	tram_serial = tram.tram_registration.serial_number
	desc = "A plate showing details from the manufacturer about this Nakamura Engineering SkyyTram Mk VI, serial number [tram_serial].<br><br>We are not responsible for any injuries or fatalities caused by usage of the tram. \
	Using the tram carries inherent risks, and we cannot guarantee the safety of all passengers. By using the tram, you assume, acknowledge, and accept all the risks and responsibilities. <br><br>\
	Please be aware that riding the tram can cause a variety of injuries, including but not limited to: slips, trips, and falls; collisions with other passengers or objects; strains, sprains, and other musculoskeletal injuries; \
	cuts, bruises, and lacerations; and more severe injuries such as head trauma, spinal cord injuries, and even death. These injuries can be caused by a variety of factors, including the movements of the tram, the behaviour \
	of other passengers, and unforeseen circumstances such as foul play or mechanical issues.<br><br>\
	By entering the tram, guideway, or crossings you agree Nanotrasen is not liable for any injuries, damages, or losses that may occur. If you do not agree to these terms, please do not use the tram.<br>"

/obj/structure/sign/tram_plate/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TramPlaque")
		ui.autoupdate = FALSE
		ui.open()

/obj/structure/sign/tram_plate/ui_static_data(mob/user)
	var/datum/transport_controller/linear/tram/tram = transport_ref?.resolve()
	var/list/data = list()
	var/list/current_tram = list()
	var/list/previous_trams = list()

	current_tram += list(list(
		"serialNumber" = tram.tram_registration.serial_number,
		"mfgDate" = tram.tram_registration.mfg_date,
		"distanceTravelled" = tram.tram_registration.distance_travelled,
		"tramCollisions" = tram.tram_registration.collisions,
	))

	for(var/datum/tram_mfg_info/previous_tram as anything in tram.tram_history)
		previous_trams += list(list(
		"serialNumber" = previous_tram.serial_number,
		"mfgDate" = previous_tram.mfg_date,
		"distanceTravelled" = previous_tram.distance_travelled,
		"tramCollisions" = previous_tram.collisions,
	))

	data["currentTram"] = current_tram
	data["previousTrams"] = previous_trams
	return data

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/tram_plate, 32)
