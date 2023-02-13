/obj/vehicle/sealed/mecha/marauder
	desc = "Heavy-duty, combat exosuit, developed after the Durand model. Rarely found among civilian populations."
	name = "\improper Marauder"
	icon_state = "marauder"
	base_icon_state = "marauder"
	movedelay = 5
	max_integrity = 500
	armor_type = /datum/armor/mecha_marauder
	max_temperature = 60000
	destruction_sleep_duration = 40
	exit_delay = 40
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	operation_req_access = list(ACCESS_CENT_SPECOPS)
	internals_req_access = list(ACCESS_CENT_SPECOPS)
	wreckage = /obj/structure/mecha_wreckage/marauder
	mecha_flags = CANSTRAFE | IS_ENCLOSED | HAS_LIGHTS | MMI_COMPATIBLE
	mech_type = EXOSUIT_MODULE_MARAUDER
	force = 45
	max_equip_by_category = list(
		MECHA_UTILITY = 3,
		MECHA_POWER = 2,
		MECHA_ARMOR = 3,
	)
	bumpsmash = TRUE

/datum/armor/mecha_marauder
	melee = 50
	bullet = 55
	laser = 40
	energy = 30
	bomb = 30
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/marauder/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_smoke)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_zoom)

/obj/vehicle/sealed/mecha/marauder/loaded
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/energy/pulse,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/thrusters/ion),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(/obj/item/mecha_parts/mecha_equipment/armor/antiproj_armor_booster),
	)

/obj/vehicle/sealed/mecha/marauder/add_cell(obj/item/stock_parts/cell/C=null)
	if(C)
		C.forceMove(src)
		cell = C
		return
	cell = new /obj/item/stock_parts/cell/bluespace(src)

/datum/action/vehicle/sealed/mecha/mech_smoke
	name = "Smoke"
	button_icon_state = "mech_smoke"

/datum/action/vehicle/sealed/mecha/mech_smoke/Trigger(trigger_flags)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_SMOKE) && chassis.smoke_charges>0)
		chassis.smoke_system.start()
		chassis.smoke_charges--
		TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_SMOKE, chassis.smoke_cooldown)

/datum/action/vehicle/sealed/mecha/mech_zoom
	name = "Zoom"
	button_icon_state = "mech_zoom_off"

/datum/action/vehicle/sealed/mecha/mech_zoom/Trigger(trigger_flags)
	if(!owner?.client || !chassis || !(owner in chassis.occupants))
		return
	chassis.zoom_mode = !chassis.zoom_mode
	button_icon_state = "mech_zoom_[chassis.zoom_mode ? "on" : "off"]"
	chassis.log_message("Toggled zoom mode.", LOG_MECHA)
	to_chat(owner, "[icon2html(chassis, owner)]<font color='[chassis.zoom_mode?"blue":"red"]'>Zoom mode [chassis.zoom_mode?"en":"dis"]abled.</font>")
	if(chassis.zoom_mode)
		owner.client.view_size.setTo(4.5)
		SEND_SOUND(owner, sound('sound/mecha/imag_enh.ogg', volume=50))
	else
		owner.client.view_size.resetToDefault()
	build_all_button_icons()

/obj/vehicle/sealed/mecha/marauder/seraph
	desc = "Heavy-duty, command-type exosuit. This is a custom model, utilized only by high-ranking military personnel."
	name = "\improper Seraph"
	icon_state = "seraph"
	base_icon_state = "seraph"
	operation_req_access = list(ACCESS_CENT_SPECOPS)
	internals_req_access = list(ACCESS_CENT_SPECOPS)
	movedelay = 3
	max_integrity = 550
	wreckage = /obj/structure/mecha_wreckage/seraph
	force = 55
	max_equip_by_category = list(
		MECHA_UTILITY = 3,
		MECHA_POWER = 2,
		MECHA_ARMOR = 3,
	)
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/energy/pulse,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/thrusters/ion),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(/obj/item/mecha_parts/mecha_equipment/armor/antiproj_armor_booster),
	)

/obj/vehicle/sealed/mecha/marauder/mauler
	desc = "Heavy-duty, combat exosuit, developed off of the existing Marauder model."
	name = "\improper Mauler"
	icon_state = "mauler"
	base_icon_state = "mauler"
	operation_req_access = list(ACCESS_SYNDICATE)
	internals_req_access = list(ACCESS_SYNDICATE)
	wreckage = /obj/structure/mecha_wreckage/mauler
	max_equip_by_category = list(
		MECHA_UTILITY = 3,
		MECHA_POWER = 2,
		MECHA_ARMOR = 4,
	)
	equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/thrusters/ion),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	destruction_sleep_duration = 20

/obj/vehicle/sealed/mecha/marauder/mauler/loaded
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/thrusters/ion),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(/obj/item/mecha_parts/mecha_equipment/armor/antiproj_armor_booster),
	)
