/datum/role
	var/name	= "generic role"	//Common name to be seen in game in things like round end reports.
	var/id 		= null				//A string. Be absolutely sure this is unique for evey antagonist/group.
	var/list/associates =	list()	//Nonantagonists mobs tied to antagonists through various circumstances.
	var/threat	= 0					//Threat is an assessment of how "dangerous" an antagonist/group is to a station it is used in weighting.
										//In group antags the threat of the group and the threat of its members of its group both count.
	var/list/objectives	= list()	//In groups objectives are shared with all members, it's possible for someone to have both personal and group objectives.

	var/list/restricted_jobs = list()	//Role can't hold this job initially as this antagonist.Matters for initail antag status.
											//Often there's some ingame means to get around this (usually loyalty implant removal).
											//Never code an antag under the assumption that a certain job can't become that antag.
	var/antag_flag = null 				//Preferences flag such as BE_WIZARD that need to be turned on for players to be antag
	var/minimum_age = 0					//How many days must players have been playing before they can play this antagonist
	var/datum/mind/owner = null				//Should always be set in gain_role.
	var/datum/group/active_group		//A group to actively track beside-eqwrqwe
	var/datum/group/associated_group	//A path. If an antag functions exclusively in a group enviroment, this makes sure it exists.

/datum/role/proc/create_or_join_group(group_path,datum/mind/M) //Call if there should only ever be one of these groups (because they have a common goal)
	for(var/datum/group/G in ticker.mode.antagonist_factions)
		if(G.id == initial(associated_group.id))
			join_group(G,owner)
			return
	create_group(associated_group, list(owner))

/datum/role/proc/create_group(group_path, mind) //Call if there can be competing versions of the same group
	var/datum/group/New_group = new group_path
	if(mind)
		New_group.members += mind
	ticker.mode.antagonist_factions += New_group

/datum/role/proc/join_group(datum/group/G, mind)
	if(mind && !(mind in G.members))
		G.members += mind

/datum/role/proc/leave_group(datum/group/G, mind)
	if(mind && (mind in G.members))
		G.members -= mind
	//if(G.members.len == 0)
		//remove_group(G)

/datum/role/proc/gain_role(datum/mind/M) //Active group isn't put here because there's two ways of doing it
	if(!M)
		return 0
	owner = M
	for(var/datum/role/R in owner.antag_roles) //Already this antag!
		if(R.id == id)
			return 0
	owner.antag_roles += src
	if(associated_group && initial(associated_group.universal_group))
		create_or_join_group(associated_group,owner)
	equip()
	enpower()
	greet()

/datum/role/proc/lose_role(var/strip_equipment, var/strip_powers)
	if(active_group)
		leave_group(active_group, owner)
	if(strip_equipment)
		unequip()
	if(strip_powers)
		depower()
	dismiss()
	owner.antag_roles -= src
	ticker.mode.abandoned_role_datums += src

/datum/role/proc/trade_role(path)	//This proc assumes you know what you're doing, don't use it as a sanity check
	var/datum/role/R = new path
	R.gain_role()
	lose_role()
	return

/datum/role/proc/equip()			//physical items put on the body
	return

/datum/role/proc/enpower()			//special abilities given to the body or mind
	if(ishuman(owner.current))
		var/mob/living/carbon/human/H
		if(!H.dna)
			H.dna.remove_mutation(CLOWNMUT)

/datum/role/proc/unequip()			//stealing physical things on unantaging (usually undesirable: immersion breaking)
	return

/datum/role/proc/depower()			//removing special abilities on the body or mind
	return

/datum/role/proc/antag_life()		//called every life tick, don't put anything too intensive in here.
	return

/datum/role/proc/greet()
	owner.current << "<B><font size=3 color=red>You are a [name]!</font></B>"
	var/obj_count = 1
	for(var/datum/objective/objective in objectives)
		owner.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++
	return

/datum/role/proc/dismiss()
	owner.current << "<B><font size=3 color=red>You are no longer a [name]!</font></B>"
	return

/datum/role/proc/declare_completion()
	return

/proc/is_antag(datum/mind/M, id) //with id field looks for specific kind of antag, without it just checks for anything
	if(id)
		for(var/datum/role/R in M.antag_roles)
			if(R.id == id)
				return 1
	else
		if(M.antag_roles.len > 0)
			return 1
	return 0