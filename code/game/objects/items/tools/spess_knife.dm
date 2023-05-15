#define ICON_SUFFIX_KNIFE "_knife"
#define ICON_SUFFIX_SCREWDRIVER "_screwdriver"
#define ICON_SUFFIX_WIRECUTTER "_cutters"

/obj/item/spess_knife
	name = "spess knife"
	desc = "A well-known tool combining knife, screwdriver, cutters and many more."
	icon = 'icons/obj/tools.dmi'
	icon_state = "spess_knife"
	inhand_icon_state = "screwdriver" // TODO
	worn_icon_state = "screwdriver" // TODO
	belt_icon_state = "screwdriver" // TODO
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	resistance_flags = FIRE_PROOF
	tool_behaviour = null
	toolspeed = 2 // Two times worse than default tools
	/// The sound played on_attack_self
	var/switch_sound = 'sound/weapons/empty.ogg'

/obj/item/spess_knife/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/transforming, \
		force_on = force, \
		throwforce_on = throwforce, \
		hitsound_on = hitsound, \
		w_class_on = w_class, \
		clumsy_check = FALSE, \
		inhand_icon_change = FALSE, \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Toggles between crowbar and wirecutters and gives feedback to the user.
 */
/obj/item/spess_knife/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	//tool_behaviour = (active ? TOOL_WRENCH : TOOL_SCREWDRIVER)
	//balloon_alert(user, "attached [active ? "bolt bit" : "screw bit"]")
	playsound(user ? user : src, 'sound/weapons/empty.ogg', 50, TRUE)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/spess_knife/examine()
	. = ..()
	//. += " It's fitted with a [tool_behaviour == TOOL_SCREWDRIVER ? "screw" : "bolt"] bit."

/obj/item/lighter/update_icon_state()
	icon_state = initial(icon_state)

	if (tool_behaviour == TOOL_KNIFE)
		icon_state += ICON_SUFFIX_KNIFE
	else if (tool_behaviour == TOOL_SCREWDRIVER)
		icon_state += ICON_SUFFIX_SCREWDRIVER
	else if (tool_behaviour == TOOL_WIRECUTTER)
		icon_state += ICON_SUFFIX_WIRECUTTER

	return ..()

#undef ICON_SUFFIX_KNIFE
#undef ICON_SUFFIX_SCREWDRIVER
#undef ICON_SUFFIX_WIRECUTTER
