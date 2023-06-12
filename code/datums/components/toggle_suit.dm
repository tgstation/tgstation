/*
 * Simple component for allowing a user to change an atom's appearance on alt-click.
 * When toggled, changes the atom's icon_state between [base_icon_state] and [base_icon_state]_t.
 */
/datum/component/toggle_icon
	/// Whether the icon is toggled
	var/toggled = FALSE
	/// The base icon state we do operations on.
	var/base_icon_state
	/// The noun of what was "toggled" displayed to the user. EX: "Toggled the item's [buttons]"
	var/toggle_noun

/datum/component/toggle_icon/Initialize(toggle_noun = "buttons")
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	var/atom/atom_parent = parent

	src.toggle_noun = toggle_noun
	src.base_icon_state = atom_parent.base_icon_state || atom_parent.icon_state

/datum/component/toggle_icon/RegisterWithParent()
	RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(on_alt_click))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/toggle_icon/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_CLICK_ALT, COMSIG_PARENT_EXAMINE))

/*
 * Signal proc for COMSIG_CLICK_ALT.
 * If the user is living, adjacent to the source,
 * and has arms / is not incapacitated, call do_icon_toggle.
 *
 * source - the atom being clicked on
 * user - the mob doing the click
 */
/datum/component/toggle_icon/proc/on_alt_click(atom/source, mob/user)
	SIGNAL_HANDLER

	if(!isliving(user))
		return

	var/mob/living/living_user = user

	if(!living_user.Adjacent(source))
		return

	if(living_user.incapacitated())
		source.balloon_alert(user, "you're incapacitated!")
		return

	if(living_user.usable_hands <= 0)
		source.balloon_alert(user, "you don't have hands!")
		return

	do_icon_toggle(source, living_user)

/*
 * Signal proc for COMSIG_PARENT_EXAMINE.
 * Lets the user know they can toggle the parent open or closed.
 *
 * source - the atom being examined (parent)
 * user - the mob examining it
 * examine_list - the list of things within the examine output
 */
/datum/component/toggle_icon/proc/on_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("Alt-click on [source] to toggle the [toggle_noun].")

/*
 * Actually do the toggle of the icon.
 * Swaps the icon from [base_icon_state] to [base_icon_state]_t.
 *
 * source - the atom being toggled
 * user - the mob doing the toggling
 */
/datum/component/toggle_icon/proc/do_icon_toggle(atom/source, mob/living/user)
	source.balloon_alert(user, "toggled [toggle_noun]")

	toggled = !toggled
	if(toggled)
		source.icon_state = "[base_icon_state]_t"
	else
		source.icon_state = base_icon_state

	if(isitem(source))
		var/obj/item/item_source = source
		item_source.update_slot_icon()
