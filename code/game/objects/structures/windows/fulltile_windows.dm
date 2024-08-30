/obj/structure/window/fulltile
	icon = 'icons/obj/smooth_structures/windows/normal_window.dmi'
	icon_state = "0-lower"
	pixel_y = WINDOW_OFF_FRAME_Y_OFFSET
	max_integrity = 50
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_OBJ
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE
	glass_amount = 2
	rcd_spritesheet_override = "full tile window"

/obj/structure/window/fulltile/unanchored
	anchored = FALSE

/obj/structure/window/plasma/fulltile
	icon = 'icons/obj/smooth_structures/windows/plasma_window.dmi'
	icon_state = "0-lower"
	pixel_y = WINDOW_OFF_FRAME_Y_OFFSET
	max_integrity = 300
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE
	glass_amount = 2

/obj/structure/window/plasma/fulltile/unanchored
	anchored = FALSE

/obj/structure/window/reinforced/plasma/fulltile
	icon = 'icons/obj/smooth_structures/windows/plasma_reinforced_window.dmi'
	icon_state = "0-lower"
	pixel_y = WINDOW_OFF_FRAME_Y_OFFSET
	state = RWINDOW_SECURE
	max_integrity = 1000
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE
	glass_amount = 2

/obj/structure/window/reinforced/plasma/fulltile/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/reinforced/fulltile
	icon = 'icons/obj/smooth_structures/windows/reinforced_window.dmi'
	icon_state = "0-lower"
	pixel_y = WINDOW_OFF_FRAME_Y_OFFSET
	max_integrity = 150
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	state = RWINDOW_SECURE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE
	glass_amount = 2
	rcd_spritesheet_override = "reinforced full tile window"

/obj/structure/window/reinforced/fulltile/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/reinforced/fulltile/damaged
	var/integrity_min_factor = 0.2
	var/integrity_max_factor = 0.8

/obj/structure/window/reinforced/fulltile/damaged/Initialize(mapload)
	. = ..()
	atom_integrity = rand(max_integrity * integrity_min_factor, max_integrity * integrity_max_factor)

/obj/structure/window/reinforced/tinted/fulltile
	icon = 'icons/obj/smooth_structures/windows/tinted_window.dmi'
	icon_state = "0-lower"
	pixel_y = WINDOW_OFF_FRAME_Y_OFFSET
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE
	glass_amount = 2

/obj/structure/window/reinforced/fulltile/ice
	icon = 'icons/obj/smooth_structures/windows/frosted_window.dmi'
	max_integrity = 150
	glass_amount = 2

//there is a sub shuttle window in survival_pod.dm for mining pods
/obj/structure/window/reinforced/shuttle//this is called reinforced because it is reinforced w/titanium
	name = "shuttle window"
	desc = "A reinforced, air-locked pod window."
	icon = 'icons/obj/smooth_structures/windows/titanium_window.dmi'
	icon_state = "0-lower"
	pixel_y = WINDOW_OFF_FRAME_Y_OFFSET
	max_integrity = 150
	wtype = "shuttle"
	reinf = TRUE
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	reinf = TRUE
	heat_resistance = 1600
	armor_type = /datum/armor/reinforced_shuttle
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE
	explosion_block = 3
	glass_type = /obj/item/stack/sheet/titaniumglass
	glass_amount = 2
	receive_ricochet_chance_mod = 1.2

/datum/armor/reinforced_shuttle
	melee = 90
	bomb = 50
	fire = 80
	acid = 100

/obj/structure/window/reinforced/shuttle/narsie_act()
	add_atom_colour("#3C3434", FIXED_COLOUR_PRIORITY)

/obj/structure/window/reinforced/shuttle/tinted
	opacity = TRUE

/obj/structure/window/reinforced/shuttle/unanchored
	anchored = FALSE

/obj/structure/window/reinforced/shuttle/indestructible
	name = "hardened shuttle window"
	obj_flags = CAN_BE_HIT | BLOCKS_CONSTRUCTION
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/window/reinforced/shuttle/indestructible/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	return FALSE

/obj/structure/window/reinforced/plasma/plastitanium
	name = "plastitanium window"
	desc = "A durable looking window made of an alloy of of plasma and titanium."
	icon = 'icons/obj/smooth_structures/windows/plastitanium_window.dmi'
	icon_state = "0-lower"
	pixel_y = WINDOW_OFF_FRAME_Y_OFFSET
	max_integrity = 1200
	wtype = "shuttle"
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	heat_resistance = 1600
	armor_type = /datum/armor/plasma_plastitanium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE_PLASTITANIUM
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE_PLASTITANIUM
	explosion_block = 3
	damage_deflection = 21 //The same as reinforced plasma windows.3
	glass_type = /obj/item/stack/sheet/plastitaniumglass
	glass_amount = 2
	rad_insulation = RAD_HEAVY_INSULATION

/datum/armor/plasma_plastitanium
	melee = 95
	bomb = 50
	fire = 80
	acid = 100

/obj/structure/window/reinforced/plasma/plastitanium/unanchored
	anchored = FALSE
	state = WINDOW_OUT_OF_FRAME

/obj/structure/window/paperframe
	name = "paper frame"
	desc = "A fragile separator made of thin wood and paper."
	icon = 'icons/obj/smooth_structures/windows/paper_window.dmi'
	icon_state = null
	opacity = TRUE
	max_integrity = 15
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_PAPERFRAME
	canSmoothWith = SMOOTH_GROUP_PAPERFRAME
	glass_amount = 2
	glass_type = /obj/item/stack/sheet/paperframes
	heat_resistance = 233
	decon_speed = 10
	can_atmos_pass = ATMOS_PASS_YES
	resistance_flags = FLAMMABLE
	armor_type = /datum/armor/none
	knock_sound = "pageturn"
	bash_sound = 'sound/weapons/slashmiss.ogg'
	break_sound = 'sound/items/poster_ripped.ogg'
	hit_sound = 'sound/weapons/slashmiss.ogg'

/obj/structure/window/paperframe/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/structure/window/paperframe/examine(mob/user)
	. = ..()
	if(atom_integrity < max_integrity)
		. += span_info("It looks a bit damaged, you may be able to fix it with some <b>paper</b>.")

/obj/structure/window/paperframe/spawn_debris(location)
	. = list(new /obj/item/stack/sheet/mineral/wood(location))
	for (var/i in 1 to rand(1,4))
		. += new /obj/item/paper/natural(location)

/obj/structure/window/paperframe/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(user.combat_mode)
		take_damage(4, BRUTE, MELEE, 0)
		if(!QDELETED(src))
			update_appearance()

/obj/structure/window/paperframe/update_appearance(updates)
	. = ..()
	set_opacity(atom_integrity >= max_integrity)

/obj/structure/window/paperframe/update_icon(updates=ALL)
	if(atom_integrity >= max_integrity)
		icon = 'icons/obj/smooth_structures/windows/paper_window.dmi'
	else
		icon = 'icons/obj/smooth_structures/windows/paper_window_torn.dmi'
	. = ..()
	if((updates & UPDATE_SMOOTHING) && (smoothing_flags & USES_SMOOTHING))
		QUEUE_SMOOTH(src)

/obj/structure/window/paperframe/attackby(obj/item/W, mob/living/user)
	if(W.get_temperature())
		fire_act(W.get_temperature())
		return
	if(user.combat_mode)
		return ..()
	if(istype(W, /obj/item/paper) && atom_integrity < max_integrity)
		user.visible_message(span_notice("[user] starts to patch the holes in \the [src]."))
		if(do_after(user, 20, target = src))
			atom_integrity = min(atom_integrity+4,max_integrity)
			qdel(W)
			user.visible_message(span_notice("[user] patches some of the holes in \the [src]."))
			if(atom_integrity == max_integrity)
				update_appearance()
			return
	..()
	update_appearance()


/obj/structure/window/bronze
	name = "brass window"
	desc = "A paper-thin pane of translucent yet reinforced brass. Nevermind, this is just weak bronze!"
	icon = 'icons/obj/smooth_structures/structure_variations.dmi'
	icon_state = "clockwork_window-single"
	glass_type = /obj/item/stack/sheet/bronze

MAPPING_DIRECTIONAL_HELPERS_EMPTY(/obj/structure/window/bronze/spawner)

/obj/structure/window/bronze/unanchored
	anchored = FALSE

/obj/structure/window/bronze/fulltile
	icon = 'icons/obj/smooth_structures/clockwork_window.dmi'
	pixel_y = WINDOW_OFF_FRAME_Y_OFFSET
	icon_state = "clockwork_window-0"
	base_icon_state = "clockwork_window"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE_BRONZE + SMOOTH_GROUP_WINDOW_FULLTILE
	canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE_BRONZE
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	max_integrity = 50
	glass_amount = 2

/obj/structure/window/bronze/fulltile/unanchored
	anchored = FALSE

