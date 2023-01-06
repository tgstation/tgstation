/obj/item/screwdriver
	name = "screwdriver"
	desc = "You can be totally screwy with this."
	icon = 'icons/obj/tools.dmi'
	icon_state = "screwdriver_map"
	inhand_icon_state = "screwdriver"
	worn_icon_state = "screwdriver"
	belt_icon_state = "screwdriver"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	flags_1 = CONDUCT_1 | IS_PLAYER_COLORABLE_1
	slot_flags = ITEM_SLOT_BELT
	force = 5
	demolition_mod = 0.5
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	custom_materials = list(/datum/material/iron=75)
	attack_verb_continuous = list("stabs")
	attack_verb_simple = list("stab")
	hitsound = 'sound/weapons/bladeslice.ogg'
	usesound = list('sound/items/screwdriver.ogg', 'sound/items/screwdriver2.ogg')
	tool_behaviour = TOOL_SCREWDRIVER
	toolspeed = 1
	armor_type = /datum/armor/item_screwdriver
	drop_sound = 'sound/items/handling/screwdriver_drop.ogg'
	pickup_sound = 'sound/items/handling/screwdriver_pickup.ogg'
	sharpness = SHARP_POINTY
	greyscale_config = /datum/greyscale_config/screwdriver
	greyscale_config_inhand_left = /datum/greyscale_config/screwdriver_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/screwdriver_inhand_right
	greyscale_config_belt = /datum/greyscale_config/screwdriver_belt
	/// If the item should be assigned a random color
	var/random_color = TRUE
	/// List of possible random colors
	var/static/list/screwdriver_colors = list(
		COLOR_TOOL_BLUE,
		COLOR_TOOL_RED,
		COLOR_TOOL_PINK,
		COLOR_TOOL_BROWN,
		COLOR_TOOL_GREEN,
		COLOR_TOOL_CYAN,
		COLOR_TOOL_YELLOW,
	)

/datum/armor/item_screwdriver
	fire = 50
	acid = 30

/obj/item/screwdriver/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is stabbing [src] into [user.p_their()] [pick("temple", "heart")]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/screwdriver/Initialize(mapload)
	if(random_color)
		set_greyscale(colors = list(pick(screwdriver_colors)))
	. = ..()
	AddElement(/datum/element/eyestab)
	AddElement(/datum/element/falling_hazard, damage = force, wound_bonus = wound_bonus, hardhat_safety = TRUE, crushes = FALSE, impact_sound = hitsound)

/obj/item/screwdriver/abductor
	name = "alien screwdriver"
	desc = "An ultrasonic screwdriver."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "screwdriver_a"
	inhand_icon_state = "screwdriver_nuke"
	custom_materials = list(/datum/material/iron=5000, /datum/material/silver=2500, /datum/material/plasma = 1000, /datum/material/titanium = 2000, /datum/material/diamond = 2000)
	usesound = 'sound/items/pshoom.ogg'
	toolspeed = 0.1
	random_color = FALSE
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null

/obj/item/screwdriver/abductor/get_belt_overlay()
	return mutable_appearance('icons/obj/clothing/belt_overlays.dmi', "screwdriver_alien")

/obj/item/screwdriver/power
	name = "hand drill"
	desc = "A simple powered hand drill."
	icon_state = "drill"
	belt_icon_state = null
	inhand_icon_state = "drill"
	worn_icon_state = "drill"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	custom_materials = list(/datum/material/iron=3500, /datum/material/silver=1500, /datum/material/titanium=2500) //what research value?
	force = 8 //might or might not be too high, subject to change
	throwforce = 8
	throw_speed = 2
	throw_range = 3//it's heavier than a screw driver/wrench, so it does more damage, but can't be thrown as far
	attack_verb_continuous = list("drills", "screws", "jabs", "whacks")
	attack_verb_simple = list("drill", "screw", "jab", "whack")
	hitsound = 'sound/items/drill_hit.ogg'
	usesound = 'sound/items/drill_use.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	toolspeed = 0.7
	random_color = FALSE
	greyscale_config = null
	greyscale_config_belt = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null

/obj/item/screwdriver/power/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/transforming, \
		force_on = force, \
		throwforce_on = throwforce, \
		hitsound_on = hitsound, \
		w_class_on = w_class, \
		clumsy_check = FALSE)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Toggles between crowbar and wirecutters and gives feedback to the user.
 */
/obj/item/screwdriver/power/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	tool_behaviour = (active ? TOOL_WRENCH : TOOL_SCREWDRIVER)
	balloon_alert(user, "attached [active ? "bolt bit" : "screw bit"]")
	playsound(user ? user : src, 'sound/items/change_drill.ogg', 50, TRUE)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/screwdriver/power/examine()
	. = ..()
	. += " It's fitted with a [tool_behaviour == TOOL_SCREWDRIVER ? "screw" : "bolt"] bit."

/obj/item/screwdriver/power/suicide_act(mob/living/user)
	if(tool_behaviour == TOOL_SCREWDRIVER)
		user.visible_message(span_suicide("[user] is putting [src] to [user.p_their()] temple. It looks like [user.p_theyre()] trying to commit suicide!"))
	else
		user.visible_message(span_suicide("[user] is pressing [src] against [user.p_their()] head! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(loc, 'sound/items/drill_use.ogg', 50, TRUE, -1)
	return BRUTELOSS

/obj/item/screwdriver/cyborg
	name = "automated screwdriver"
	desc = "A powerful automated screwdriver, designed to be both precise and quick."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "screwdriver_cyborg"
	hitsound = 'sound/items/drill_hit.ogg'
	usesound = 'sound/items/drill_use.ogg'
	toolspeed = 0.5
	random_color = FALSE

/obj/item/screwdriver/red
	random_color = FALSE

/obj/item/screwdriver/red/Initialize(mapload)
	. = ..()
	set_greyscale(colors=list(screwdriver_colors["red"]))
