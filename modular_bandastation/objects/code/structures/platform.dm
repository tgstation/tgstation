// MARK: Platform
/obj/structure/railing/platform
	name = "platform"
	desc = "Металлическая платформа."
	icon = 'modular_bandastation/objects/icons/obj/structures/platform.dmi'
	icon_state = "metal"
	layer = BELOW_OBJ_LAYER
	plane = GAME_PLANE
	flags_1 = ON_BORDER_1
	obj_flags = CAN_BE_HIT | IGNORE_DENSITY
	pass_flags_self = LETPASSTHROW | PASSSTRUCTURE
	density = TRUE
	anchored = TRUE
	armor_type = /datum/armor/platform
	max_integrity = 200
	item_deconstruct = /obj/item/stack/sheet/iron
	var/material_amount = 4

/datum/armor/platform
	melee = 10
	bullet = 10
	laser = 10
	energy = 50
	bomb = 20
	fire = 100
	acid = 30

/obj/structure/railing/platform/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_change_layer))
	adjust_dir_layer(dir)

// Dismantle
/obj/structure/railing/platform/screwdriver_act(mob/user, obj/item/I)
	if(resistance_flags & INDESTRUCTIBLE)
		to_chat(user, span_warning("Вы пытаетесь разобрать [declent_ru(ACCUSATIVE)], но она слишком прочная!"))
		I.play_tool_sound(src, 100)
		return TRUE
	to_chat(user, span_warning("Вы разбираете [declent_ru(ACCUSATIVE)]."))
	I.play_tool_sound(src, 100)
	deconstruct()
	return TRUE

// Overrides. We deconstruct it with a screwdriver
/obj/structure/railing/platform/wirecutter_act(mob/living/user, obj/item/I)
	return

/obj/structure/railing/platform/atom_deconstruct(disassembled)
	var/obj/sheet = new item_deconstruct(drop_location(), material_amount)
	transfer_fingerprints_to(sheet)

/obj/structure/railing/platform/proc/on_change_layer(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	adjust_dir_layer(new_dir)

/obj/structure/railing/platform/proc/adjust_dir_layer(direction)
	layer = (direction & SOUTH) ? ABOVE_MOB_LAYER : initial(layer)

// MARK: Reinforced platform
/obj/structure/railing/platform/reinforced
	name = "reinforced platform"
	desc = "Прочная платформа из пластали, с повышенной устойчивостью к опасным средам."
	icon_state = "plasteel"
	item_deconstruct = /obj/item/stack/sheet/plasteel
	armor_type = /datum/armor/platform_reinforced
	max_integrity = 300

/datum/armor/platform_reinforced
	melee = 20
	bullet = 30
	laser = 30
	energy = 100
	bomb = 75
	fire = 100
	acid = 100

// MARK: Platform corners
/obj/structure/railing/platform/corner
	icon_state = "metalcorner"
	density = FALSE
	climbable = FALSE
	material_amount = 2

/obj/structure/railing/platform/reinforced/corner
	icon_state = "plasteelcorner"
	density = FALSE
	climbable = FALSE
	material_amount = 2
