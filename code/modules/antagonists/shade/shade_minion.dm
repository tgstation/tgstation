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
	master_name = team.master.current?.real_name

/**
 * A team containing just the shade and master, so you can know who your master is.
 */
/datum/team/shade_pact
	show_roundend_report = FALSE
	/// The master of the pact
	var/datum/mind/master

/**
 * Create a new team consisting of a "pact master" and a subservient shade.
 * The first player passed in should be the one everyone else needs to obey.
 */
/datum/team/shade_pact/New(starting_members)
	. = ..()
	if(islist(starting_members))
		master = starting_members[0]
		return
	master = starting_members
