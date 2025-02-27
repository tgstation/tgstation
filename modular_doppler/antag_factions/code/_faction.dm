/datum/antag_faction
	/// The name of the faction.
	var/name
	/// A brief overview of the faction.
	var/description
	/// The type of antagonist this faction affects.
	var/list/antagonist_types = list()
	/// Do we award any bonus TC for traitor/spy-type antags?
	var/bonus_tc = 0
	/// A special uplink category for our stuff, if applicable.
	var/datum/uplink_category/faction_category
	/// A HTML-formatted line (span, etc) given to antagonists that choose the faction.
	var/entry_line

/// The default 'we don't have an org' organization.
/datum/antag_faction/none
	name = "None"
	description = "You aren't affiliated with any particular antagonistic organization."
