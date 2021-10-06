/*
 * Old toggle suit behavior (from suit/toggle), now in component form.
 * Allows an item to toggle between two icon_states ([icon_state], and [icon_state]_t) on alt click.
 */
/datum/component/toggle_suit
	/// Whether the weapon is toggled open or not
	var/toggled = FALSE
	/// The base icon state we do operations on.
	var/base_icon_state
	/// The noun of what was "toggled" displayed to the user. EX: "Toggled the item's [buttons]"
	var/toggle_noun

/datum/component/toggle_suit/Initialize(toggle_noun = "buttons")
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/item_parent = parent

	src.toggle_noun = toggle_noun
	src.base_icon_state = item_parent.base_icon_state || item_parent.icon_state

/datum/component/toggle_suit/RegisterWithParent()
	RegisterSignal(parent, COMSIG_CLICK_ALT, .proc/on_alt_click)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)

/datum/component/toggle_suit/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_CLICK_ALT, COMSIG_PARENT_EXAMINE))

/*
 * Signal proc for COMSIG_CLICK_ALT.
 * If the user is living, adjecent or holding the parent,
 * and has arms / is not incapacitated, call do_suit_toggle.
 *
 * source - the item being clicked on
 * user - the mob doing the click
 */
/datum/component/toggle_suit/proc/on_alt_click(obj/item/source, mob/user)
	SIGNAL_HANDLER

	if(!isliving(user))
		return

	var/mob/living/living_user = user

	if(!living_user.Adjacent(source) && source.loc != living_user)
		return

	if(living_user.incapacitated())
		to_chat(user, span_warning("You can't adjust [source] right now."))
		return

	if(living_user.usable_hands <= 0)
		to_chat(user, span_warning("You can't adjust [source] without hands."))
		return

	do_suit_toggle(source, living_user)

/*
 * Signal proc for COMSIG_PARENT_EXAMINE.
 * Lets the user know they can toggle the parent open or closed.
 *
 * source - the item being examined (parent)
 * user - the mob examining it
 * examine_list - the list of things within the examine output
 */
/datum/component/toggle_suit/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("Alt-click on [source] to toggle the [toggle_noun].")

/*
 * Actually do the toggle of the icon.
 * Swaps the icon from [icon_state] to [icon_state]_t.
 *
 * source - the item being toggled
 * user - the mob doing the toggling
 */
/datum/component/toggle_suit/proc/do_suit_toggle(obj/item/source, mob/living/user)
	to_chat(user, span_notice("You toggle [source]'s [toggle_noun]."))

	toggled = !toggled
	if(toggled)
		source.icon_state = "[base_icon_state]_t"
	else
		source.icon_state = base_icon_state
	source.update_slot_icon()
