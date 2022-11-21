/**
 * This datum is for use by shades who have a master but are not cultists.
 * Cult shades don't get it because they get the cult datum instead.
 * They are bound to follow the orders of their creator, probably a chaplain or miner.
 * Technically they're not 'antagonists' but they have antagonist-like properties.
 */
/datum/antagonist/shade_minion
	name = "\improper Loyal Shade"
	show_in_antagpanel = FALSE
	show_in_roundend = FALSE
	silent = TRUE
	ui_name = "AntagInfoShade"
	count_against_dynamic_roll_chance = FALSE
	/// Name of this shade's master.
	var/master_name = "nobody?"

/datum/antagonist/shade_minion/ui_static_data(mob/user)
	var/list/data = list()
	data["master_name"] = master_name
	return data

/// Apply a new master to the shade, will display the popup again also.
/datum/antagonist/shade_minion/proc/update_master(master_name)
	if (src.master_name == master_name)
		return

	src.master_name = master_name
	update_static_data(owner.current)
	INVOKE_ASYNC(src, PROC_REF(display_panel))

/// Shows the info panel, moved out into its own proc for signal handling reasons.
/datum/antagonist/shade_minion/proc/display_panel()
	var/datum/action/antag_info/info_button = info_button_ref?.resolve()
	info_button?.Trigger()
