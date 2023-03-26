/obj/structure/closet/secure_closet
	name = "secure locker"
	desc = "It's a card-locked storage unit."
	locked = TRUE
	icon_state = "secure"
	max_integrity = 250
	armor_type = /datum/armor/closet_secure_closet
	secure = TRUE
	damage_deflection = 20
	material_drop = /obj/item/stack/sheet/plasteel
	material_drop_amount = 2

/datum/armor/closet_secure_closet
	melee = 30
	bullet = 50
	laser = 50
	energy = 100
	fire = 80
	acid = 80

/obj/structure/closet/secure_closet/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_GREY_TIDE, PROC_REF(grey_tide))

/obj/structure/closet/secure_closet/proc/grey_tide(datum/source, list/grey_tide_areas)
	SIGNAL_HANDLER

	if(!is_station_level(z))
		return

	for(var/area_type in grey_tide_areas)
		if(!istype(get_area(src), area_type))
			continue
		locked = FALSE
		update_appearance(UPDATE_ICON)

/obj/structure/closet/secure_closet/customizable

/obj/structure/closet/secure_closet/customizable/examine(mob/user)
	. = ..()
	. += span_notice("Use an airlock painter to change its texture.")

/obj/structure/closet/secure_closet/customizable/tool_interact(obj/item/W, mob/living/user)
	if(istype(W, /obj/item/airlock_painter))
		var/static/choices = list(
			"Bar" = "cabinet",
			"Cargo" = "qm",
			"Engineering" = "ce",
			"Hydroponics" = "hydro",
			"Medical" = "med",
			"Personal" = "personal closet",
			"Science" = "rd",
			"Security" = "cap",
			"Mining" = "mining",
			"Virology" = "bio_viro",
		)
		var/choice = tgui_input_list(user, "Set Closet Paintjob", "Paintjob", choices)
		if(isnull(choice))
			return TRUE

		var/obj/item/airlock_painter/painter = W
		if(!painter.use_paint(user))
			return TRUE
		icon_state = choices[choice]

		update_appearance()
		return TRUE

	return ..()
