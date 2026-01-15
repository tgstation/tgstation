/datum/team/blood_worm
	name = "\improper Blood Worms"
	member_name = "blood worm"

	var/blood_consumed_total = 0
	var/times_reproduced_total = 0

	var/static/list/objective_types = list(
		/datum/objective/blood_worm/kill,
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

	RegisterSignal(member_mob, COMSIG_BLOOD_WORM_CONSUMED_BLOOD, PROC_REF(on_blood_worm_consumed_blood))
	RegisterSignal(member_mob, COMSIG_BLOOD_WORM_REPRODUCED, PROC_REF(on_blood_worm_reproduced))

/datum/team/blood_worm/proc/unregister_member_mob(mob/member_mob)
	if (!member_mob)
		return

	UnregisterSignal(member_mob, list(COMSIG_BLOOD_WORM_CONSUMED_BLOOD, COMSIG_BLOOD_WORM_REPRODUCED))

/datum/team/blood_worm/proc/on_blood_worm_consumed_blood(mob/living/basic/blood_worm/worm, normal_blood_amount, synth_blood_amount, total_blood_amount)
	SIGNAL_HANDLER
	blood_consumed_total += normal_blood_amount

/datum/team/blood_worm/proc/on_blood_worm_reproduced(mob/living/basic/blood_worm/worm)
	SIGNAL_HANDLER
	times_reproduced_total++

/datum/team/blood_worm/roundend_report()
	var/list/report = list()

	report += span_header("\The [name]:")
	report += printplayerlist(members)

	if (length(objectives))
		report += span_header("Their collective goals:")
		report += print_objective_list()

	report += ""

	report += did_we_win() ? span_greentext("The [name] were successful!") : span_redtext("The [name] have failed!")

	return "<div class='panel redborder'>[report.Join("<br>")]</div>"

/datum/team/blood_worm/proc/print_objective_list()
	. = list()
	for (var/i in 1 to length(objectives))
		var/datum/objective/objective = objectives[i]
		. += "<B>Objective #[i]</B>: [objective.explanation_text] [objective.get_roundend_success_suffix()]"

/datum/team/blood_worm/proc/did_we_win()
	for (var/datum/objective/objective as anything in objectives)
		if (!objective.check_completion())
			return FALSE
	return TRUE
