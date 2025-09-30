#define CALLOUT_TIME (5 SECONDS)
#define CALLOUT_COOLDOWN 3 SECONDS

/// Component that allows its owner/owner's wearer to use callouts system - their pointing is replaced with a fancy radial which allows them to summon glowing markers
/datum/component/callouts
	/// If parent is clothing, slot on which this component activates
	var/item_slot
	/// If we are currently active
	var/active = TRUE
	/// Current user of this component
	var/mob/cur_user
	/// Whenever the user should shout the voiceline
	var/voiceline = FALSE
	/// If voiceline is true, what prefix the user should use
	var/radio_prefix = null
	/// List of all callout options
	var/static/list/callout_options = typecacheof(subtypesof(/datum/callout_option))
	/// Text displayed when parent is examined
	var/examine_text = null
	/// Cooldown for callouts
	COOLDOWN_DECLARE(callout_cooldown)

/datum/component/callouts/Initialize(item_slot = null, voiceline = FALSE, radio_prefix = null, examine_text = null)
	if (!isitem(parent) && !ismob(parent))
		return COMPONENT_INCOMPATIBLE
	src.item_slot = item_slot
	src.voiceline = voiceline
	src.radio_prefix = radio_prefix
	src.examine_text = examine_text

	if (ismob(parent))
		cur_user = parent
		return

	var/atom/atom_parent = parent

	if (!ismob(atom_parent.loc))
		return

	var/mob/user = atom_parent.loc
	if (!isnull(item_slot) && user.get_item_by_slot(item_slot) != parent)
		return

	RegisterSignal(atom_parent.loc, COMSIG_MOB_CLICKON, PROC_REF(on_click))
	cur_user = atom_parent.loc

/datum/component/callouts/Destroy(force)
	cur_user = null
	. = ..()

/datum/component/callouts/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_CLICKON, PROC_REF(on_click))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examines))
	RegisterSignal(parent, COMSIG_CLICK_CTRL, PROC_REF(on_ctrl_click))

/datum/component/callouts/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOB_CLICKON, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED, COMSIG_ATOM_EXAMINE, COMSIG_CLICK_CTRL))

/datum/component/callouts/proc/on_ctrl_click(datum/source, mob/living/user)
	SIGNAL_HANDLER

	if (!isitem(parent))
		return

	if (user.incapacitated)
		return

	var/obj/item/item_parent = parent
	active = !active
	item_parent.balloon_alert(user, active ? "callouts enabled" : "callouts disabled")

/datum/component/callouts/proc/on_equipped(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if (item_slot & slot)
		RegisterSignal(equipper, COMSIG_MOB_CLICKON, PROC_REF(on_click))
		cur_user = equipper
	else if (cur_user == equipper)
		UnregisterSignal(cur_user, COMSIG_MOB_CLICKON, PROC_REF(on_click))
		cur_user = null

/datum/component/callouts/proc/on_dropped(datum/source, mob/user)
	SIGNAL_HANDLER

	if (cur_user == user)
		UnregisterSignal(cur_user, COMSIG_MOB_CLICKON, PROC_REF(on_click))
		cur_user = null

/datum/component/callouts/proc/on_examines(mob/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if (!isnull(examine_text))
		examine_list += examine_text

/datum/component/callouts/proc/on_click(mob/user, atom/clicked_atom, list/modifiers)
	SIGNAL_HANDLER

	if (!LAZYACCESS(modifiers, SHIFT_CLICK) || !LAZYACCESS(modifiers, MIDDLE_CLICK))
		return

	if (user.incapacitated)
		return

	if (!active)
		return

	if (!COOLDOWN_FINISHED(src, callout_cooldown))
		clicked_atom.balloon_alert(user, "callout is on cooldown!")
		return COMSIG_MOB_CANCEL_CLICKON

	INVOKE_ASYNC(src, PROC_REF(callout_picker), user, clicked_atom)
	return COMSIG_MOB_CANCEL_CLICKON

/datum/component/callouts/proc/callout_picker(mob/user, atom/clicked_atom)
	var/list/callout_items = list()
	for(var/datum/callout_option/callout_option as anything in callout_options)
		callout_items[callout_option] = image(icon = 'icons/hud/radial.dmi', icon_state = callout_option::icon_state)

	var/datum/callout_option/selection = show_radial_menu(user, get_turf(clicked_atom), callout_items, button_animation_flags = NONE, click_on_hover = TRUE, user_space = TRUE)
	if (!selection)
		return

	COOLDOWN_START(src, callout_cooldown, CALLOUT_COOLDOWN)
	new /obj/effect/temp_visual/callout(get_turf(user), user, selection, clicked_atom)
	SEND_SIGNAL(user, COMSIG_MOB_CREATED_CALLOUT, selection, clicked_atom)
	if (voiceline)
		user.say((!isnull(radio_prefix) ? radio_prefix : "") + selection::voiceline, forced = src)

/obj/effect/temp_visual/callout
	name = "callout"
	icon = 'icons/effects/callouts.dmi'
	icon_state = "point"
	plane = ABOVE_LIGHTING_PLANE
	duration = CALLOUT_TIME

/obj/effect/temp_visual/callout/Initialize(mapload, mob/creator, datum/callout_option/callout, atom/target)
	. = ..()
	if (isnull(creator))
		return
	icon_state = callout::icon_state
	color = colorize_string(creator.get_voice(), 2, 0.9)
	update_appearance()
	var/turf/target_loc = get_turf(target)
	animate(src, pixel_x = (target_loc.x - loc.x) * ICON_SIZE_X + target.pixel_x, pixel_y = (target_loc.y - loc.y) * ICON_SIZE_Y + target.pixel_y, time = 0.2 SECONDS, easing = SINE_EASING|EASE_OUT)

/datum/callout_option
	var/name = "ERROR"
	var/icon_state = "point"
	var/voiceline = "Something has gone wrong!"

/datum/callout_option/point
	name = "Point"
	icon_state = "point"
	voiceline = "Here!"

/datum/callout_option/danger
	name = "Danger"
	icon_state = "danger"
	voiceline = "Danger there!"

/datum/callout_option/guard
	name = "Guard"
	icon_state = "guard"
	voiceline = "Hold this position!"

/datum/callout_option/attack
	name = "Attack"
	icon_state = "attack"
	voiceline = "Attack there!"

/datum/callout_option/mine
	name = "Mine"
	icon_state = "mine"
	voiceline = "Dig here!"

/datum/callout_option/move
	name = "Move"
	icon_state = "move"
	voiceline = "Reposition there!"

#undef CALLOUT_TIME
#undef CALLOUT_COOLDOWN
