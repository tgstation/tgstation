/obj/vehicle/sealed/mecha/marauder
	desc = "Heavy-duty, combat exosuit, developed after the Durand model. Rarely found among civilian populations. Its bleeding edge armour ensures maximum usability and protection at the cost of some modularity."
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
	accesses = list(ACCESS_CENT_SPECOPS)
	wreckage = /obj/structure/mecha_wreckage/marauder
	mecha_flags = CAN_STRAFE | IS_ENCLOSED | HAS_LIGHTS | MMI_COMPATIBLE | AI_COMPATIBLE
	mech_type = EXOSUIT_MODULE_MARAUDER
	force = 45
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 5,
		MECHA_POWER = 1,
		MECHA_ARMOR = 1,
	)
	bumpsmash = TRUE

	/// Reusable smoke generator system
	var/datum/effect_system/fluid_spread/smoke/smoke_system
	/// Remaining smoke charges
	var/smoke_charges = 5
	/// Cooldown between using smoke
	var/smoke_cooldown = 10 SECONDS
	/// Bool for zoom on/off
	var/zoom_mode = FALSE

/datum/armor/mecha_marauder
	melee = 70
	bullet = 60
	laser = 60
	energy = 30
	bomb = 50
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/marauder/Initialize(mapload, built_manually)
	. = ..()
	smoke_system = new(src, 3, holder = src)

/obj/vehicle/sealed/mecha/marauder/Destroy()
	QDEL_NULL(smoke_system)
	return ..()

/obj/vehicle/sealed/mecha/marauder/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_smoke)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_zoom)

/obj/vehicle/sealed/mecha/marauder/loaded
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/energy/pulse,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/radio, /obj/item/mecha_parts/mecha_equipment/air_tank/full, /obj/item/mecha_parts/mecha_equipment/thrusters/ion),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(/obj/item/mecha_parts/mecha_equipment/armor/antiemp_armor_booster/clandestine),
	)

/obj/vehicle/sealed/mecha/marauder/loaded/populate_parts()
	cell = new /obj/item/stock_parts/power_store/cell/bluespace(src)
	scanmod = new /obj/item/stock_parts/scanning_module/triphasic(src)
	capacitor = new /obj/item/stock_parts/capacitor/quadratic(src)
	servo = new /obj/item/stock_parts/servo/femto(src)
	update_part_values()

/obj/vehicle/sealed/mecha/marauder/remove_occupant(mob/driver)
	. = ..()
	zoom_mode = FALSE

/obj/vehicle/sealed/mecha/marauder/can_move(direction)
	. = ..()
	if(!. || !zoom_mode)
		return

	if(TIMER_COOLDOWN_FINISHED(src, COOLDOWN_MECHA_MESSAGE))
		to_chat(occupants, "[icon2html(src, occupants)][span_warning("Unable to move while in zoom mode!")]")
		TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MESSAGE, 2 SECONDS)
	return FALSE

/datum/action/vehicle/sealed/mecha/mech_smoke
	name = "Smoke"
	button_icon_state = "mech_smoke"

/datum/action/vehicle/sealed/mecha/mech_smoke/IsAvailable(feedback)
	. = ..()
	if (!.)
		return

	var/obj/vehicle/sealed/mecha/marauder/maradeur = chassis
	if(!TIMER_COOLDOWN_FINISHED(maradeur, COOLDOWN_MECHA_SMOKE))
		if (feedback)
			owner.balloon_alert(owner, "smoke charges on cooldown!")
		return FALSE

	if (!maradeur.smoke_charges)
		if (feedback)
			owner.balloon_alert(owner, "out of smoke charges!")
		return FALSE

/datum/action/vehicle/sealed/mecha/mech_smoke/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	if(!chassis || !(owner in chassis.occupants))
		return
	var/obj/vehicle/sealed/mecha/marauder/maradeur = chassis
	if(TIMER_COOLDOWN_FINISHED(maradeur, COOLDOWN_MECHA_SMOKE) && maradeur.smoke_charges)
		maradeur.smoke_system.start()
		maradeur.smoke_charges--
		TIMER_COOLDOWN_START(maradeur, COOLDOWN_MECHA_SMOKE, maradeur.smoke_cooldown)

/datum/action/vehicle/sealed/mecha/mech_zoom
	name = "Zoom"
	button_icon_state = "mech_zoom_off"

/datum/action/vehicle/sealed/mecha/mech_zoom/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return
	if(!owner.client || !chassis || !(owner in chassis.occupants))
		return
	var/obj/vehicle/sealed/mecha/marauder/maradeur = chassis
	maradeur.zoom_mode = !maradeur.zoom_mode
	button_icon_state = "mech_zoom_[maradeur.zoom_mode ? "on" : "off"]"
	maradeur.log_message("Toggled zoom mode.", LOG_MECHA)
	to_chat(owner, "[icon2html(maradeur, owner)]<font color='[maradeur.zoom_mode ? "blue" : "red"]'>Zoom mode [maradeur.zoom_mode ? "en" : "dis"]abled.</font>")
	if(maradeur.zoom_mode)
		owner.client.view_size.setTo(4.5)
		SEND_SOUND(owner, sound('sound/vehicles/mecha/imag_enh.ogg', volume=50))
	else
		owner.client.view_size.resetToDefault()
	build_all_button_icons()

/obj/vehicle/sealed/mecha/marauder/seraph
	desc = "Heavy-duty, command-type exosuit. This is a custom model, utilized only by high-ranking military personnel."
	name = "\improper Seraph"
	icon_state = "seraph"
	base_icon_state = "seraph"
	accesses = list(ACCESS_CENT_SPECOPS)
	movedelay = 3
	max_integrity = 550
	armor_type = /datum/armor/mecha_seraph
	wreckage = /obj/structure/mecha_wreckage/seraph
	force = 55
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 5,
		MECHA_POWER = 1,
		MECHA_ARMOR = 1,
	)
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/energy/pulse,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/radio, /obj/item/mecha_parts/mecha_equipment/air_tank/full, /obj/item/mecha_parts/mecha_equipment/thrusters/ion),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(/obj/item/mecha_parts/mecha_equipment/armor/antiemp_armor_booster/clandestine),
	)

/datum/armor/mecha_seraph
	melee = 80
	bullet = 65
	laser = 65
	energy = 50
	bomb = 50
	fire = 100
	acid = 100


/obj/vehicle/sealed/mecha/marauder/mauler
	desc = "Heavy-duty, combat exosuit, developed off of the existing Marauder model, its hardened exterior prevents the use of add-on armor packages."
	name = "\improper Mauler"
	ui_theme = "syndicate"
	icon_state = "mauler"
	base_icon_state = "mauler"
	armor_type = /datum/armor/mecha_mauler
	accesses = list(ACCESS_SYNDICATE)
	wreckage = /obj/structure/mecha_wreckage/mauler
	mecha_flags = ID_LOCK_ON | CAN_STRAFE | IS_ENCLOSED | HAS_LIGHTS | MMI_COMPATIBLE | AI_COMPATIBLE
	max_equip_by_category = list(
		MECHA_L_ARM = 1,
		MECHA_R_ARM = 1,
		MECHA_UTILITY = 4,
		MECHA_POWER = 1,
		MECHA_ARMOR = 1,
	)
	equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = null,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/radio, /obj/item/mecha_parts/mecha_equipment/air_tank/full, /obj/item/mecha_parts/mecha_equipment/thrusters/ion),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	destruction_sleep_duration = 20

/datum/armor/mecha_mauler
	melee = 80
	bullet = 60
	laser = 50
	energy = 30
	bomb = 50
	fire = 100
	acid = 100

/obj/vehicle/sealed/mecha/marauder/mauler/Initialize(mapload)
	. = ..()
	add_minimap_blip(src, MINIMAP_SYNDICATE_MECH_BLIP, "syndiemech")

/obj/vehicle/sealed/mecha/marauder/mauler/loaded
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/radio, /obj/item/mecha_parts/mecha_equipment/air_tank/full, /obj/item/mecha_parts/mecha_equipment/thrusters/ion),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(/obj/item/mecha_parts/mecha_equipment/armor/antiemp_armor_booster/clandestine),
	)

/obj/vehicle/sealed/mecha/marauder/mauler/loaded/Initialize(mapload)
	. = ..()
	max_ammo()

/obj/vehicle/sealed/mecha/marauder/mauler/loaded/populate_parts()
	cell = new /obj/item/stock_parts/power_store/cell/bluespace(src)
	scanmod = new /obj/item/stock_parts/scanning_module/triphasic(src)
	capacitor = new /obj/item/stock_parts/capacitor/quadratic(src)
	servo = new /obj/item/stock_parts/servo/femto(src)
	update_part_values()
