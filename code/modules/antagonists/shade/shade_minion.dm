/**
 * This datum is for use by shades who have a master but are not cultists.
 * Cult shades don't get it because they get the cult datum instead.
 * They are bound to follow the orders of their creator, probably a chaplain or miner.
 * Technically they're not 'antagonists' but they have antagonist-like properties.
 */
/datum/antagonist/shade_minion
	name = "\improper Shade"
	show_in_antagpanel = FALSE
	show_in_roundend = FALSE
	ui_name = "AntagInfoShade"
	/// Name of this shade's master.
	var/master_name = "nobody?"

/datum/antagonist/shade_minion/ui_static_data(mob/user)
	var/list/data = list()
	data["master_name"] = master_name
	return data

/**
 * Gets your master's name, they should be the only other member of the team
 */
/datum/antagonist/shade_minion/create_team(datum/team/shade_pact/team)
	if (!istype(team))
		return
	for (var/datum/mind/member as anything in team.members)
		if (member == owner)
			continue
		var/mob/master = member.current
		if (!master)
			CRASH("Master was not added to shade's team.")
		master_name = master.real_name

/**
 * A team containing just the shade and master, so you can know who your master is.
 */
/datum/team/shade_pact
	show_roundend_report = FALSE
