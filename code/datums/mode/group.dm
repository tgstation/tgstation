//You should never manually add a role antag datum to a group, it should be done in the role antag datum itself under
//create_group() for roundstart members and conversion() for later additions.

/datum/group
	var/name	= "generic group"	//Common name to be seen in game in things like round end reports.
	var/id 		= null				//A string. Be absolutely sure this is unique for evey antagonist/group.
	var/list/associates =	list()	//Nonantagonists mobs tied to antagonists through various circumstances.
	var/threat	= 0					//Threat is an assessment of how "dangerous" an antagonist/group is to a station it is used in weighting.
										//In group antags the threat of the group and the threat of its members of its group both count.
	var/list/objectives	= list()	//In groups objectives are shared with all members, it's possible for someone to have both personal and group objectives.
	var/list/members =	list()			//List of datums of antagonist members. A memberless group is effectively "dead".
	var/universal_group = 0				//If a group is universal, any new relevent antags automatically join it instead of making new groups

/datum/group/proc/populate_group()
	return