var/datum/subsystem/puppetmaster/SSpuppetmaster

/datum/subsystem/puppetmaster
	name = "Puppetmaster"
	priority = 0

	var/list/puppets = list()
	var/antags = 0

/datum/subsystem/puppetmaster/New()
	NEW_SS_GLOBAL(SSpuppetmaster)

/datum/subsystem/puppetmaster/Initialize()
	. = ..()

/datum/subsystem/puppetmaster/stat_entry()
	..("Puppets:[puppets.len]|Antags:[antags]")

// Register and Deregister are called by the on_gain() and on_loss() procs
// of the datum, so you don't have to call them yourself
/datum/subsystem/puppetmaster/proc/register(datum/mind/user, datum/antag/role)
	var/key = role.type
	if(!puppets[key])
		var/datum/puppet/new_puppet
		var/new_puppet
		if(role.type == /datum/antag/traitor)
			new_puppet = new /datum/puppet/traitor()
		puppets[key] = new_puppet

	var/datum/puppet/P = puppets[key]
	P.members |= user

/datum/subsystem/puppetmaster/proc/deregister(datum/mind/user,datum/antag/role)
	var/key = role.type
	var/datum/puppet/P = puppets[key]
	if(istype(P))
		P.members -= user

/datum/subsystem/puppetmaster/fire()
	antags = 0
	for(var/i in puppets)
		var/datum/puppet/P = puppets[i]
		antags += P.members.len
		P.tick()

/datum/subsystem/puppetmaster/proc/declare()
	for(var/i in puppets)
		var/datum/antag/D = i
		var/datum/puppet/P = puppets[i]
		world << D.name
		P.declare_completion()

/datum/puppet
	var/list/members = list()
	var/datum_type

/datum/puppet/proc/tick()
	return

/datum/puppet/proc/declare_completion()
	for(var/i in members)
		var/datum/mind/M = i
		var/datum/antag/D = M.special_roles[datum_type]
		world << "[M.name] ([M.key])"
		var/count = 1
		for(var/j in D.objectives)
			var/datum/objective/objective = j
			if(objective.check_completion())
				world << "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
			else
				world << "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
			count++

/datum/puppet/traitor
	var/exchange_red
	var/exchange_blue
	datum_type = /datum/antag/traitor

/datum/puppet/traitor/tick()
	var/list/needs_objectives = list()

	for(var/i in members)
		var/datum/mind/M = i
		var/datum/antag/traitor/D = M.special_roles[datum_type]
		if(!D || !istype(D))
			members.Remove(M)

		if(!D.objectives.len)
			needs_objectives |= M
		else
			D.tick(M)

	give_objectives(shuffle(needs_objectives))

/datum/puppet/traitor/proc/give_objectives(list/needs_objectives)
	var/do_exchange = FALSE
	if(needs_objectives.len >= 8)
		do_exchange = TRUE

	for(var/i in needs_objectives)
		var/datum/mind/M = i
		var/datum/antag/traitor/D = M.special_roles[datum_type]
		if(issilicon(M.current))
			D.make_silicon_objectives(M)
		else
			var/exchanging = FALSE
			if(do_exchange)
				if(!exchange_red)
					exchange_red = M
					exchanging = TRUE
				else if(!exchange_blue)
					exchange_blue = M
					exchanging = TRUE
				else
					do_exchange = FALSE

			D.make_objectives(M, exchanging=exchanging)
