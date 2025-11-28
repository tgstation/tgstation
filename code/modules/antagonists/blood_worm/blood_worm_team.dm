/datum/team/blood_worm
	name = "\improper Blood Worms"
	member_name = "blood worm"

	var/static/list/objective_types = list(
		//datum/objective/blood_worm/kill,
		/datum/objective/blood_worm/consume,
		/datum/objective/blood_worm/multiply,
		/datum/objective/blood_worm/conquer,
	)

/datum/team/blood_worm/New(starting_members)
	. = ..()

	for (var/objective_type in objective_types)
		objectives += new objective_type()

	for (var/datum/objective/objective as anything in objectives)
		objective.team = src

/datum/team/blood_worm/add_member(datum/mind/member)
	. = ..()
	register_member_mob(member.current)
	RegisterSignal(member, COMSIG_MIND_TRANSFERRED, PROC_REF(on_mind_transferred))

/datum/team/blood_worm/remove_member(datum/mind/member)
	UnregisterSignal(member, COMSIG_MIND_TRANSFERRED)
	unregister_member_mob(member.current)
	return ..()

/datum/team/blood_worm/proc/on_mind_transferred(datum/mind/member, mob/previous_body)
	SIGNAL_HANDLER
	unregister_member_mob(previous_body)
	register_member_mob(member.current)

/datum/team/blood_worm/proc/register_member_mob(mob/member_mob)
	if (!member_mob)
		return
	for (var/datum/objective/blood_worm/objective in objectives)
		objective.register_team_member_mob(member_mob)

/datum/team/blood_worm/proc/unregister_member_mob(mob/member_mob)
	if (!member_mob)
		return
	for (var/datum/objective/blood_worm/objective in objectives)
		objective.unregister_team_member_mob(member_mob)
