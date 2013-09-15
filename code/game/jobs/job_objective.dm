/datum/mind/var/list/job_objectives=list()

#define FINDJOBTASK_DEFAULT_NEW 1 // Make a new task of this type if one can't be found.
/datum/mind/proc/findJobTask(var/typepath,var/options)
	var/datum/job_objective/task = locate(typepath) in src.job_objectives
	if(!istype(task,typepath))
		if(options & FINDJOBTASK_DEFAULT_NEW)
			task = new typepath()
			src.job_objectives += task
			return task
		else
			return null

/datum/job_objective
	var/datum/mind/owner = null			//Who owns the objective.
	var/completed = 0					//currently only used for custom objectives.
	var/per_unit = 0
	var/units_completed = 0
	var/units_needing_compensation = 0 // Shit not yet paid for
	var/units_requested = INFINITY
	var/completion_payment = 0			// Credits paid to owner when completed

/datum/job_objective/New(var/datum/mind/new_owner)
	owner=new_owner
	owner.job_objectives += src

/datum/job_objective/Del()

/datum/job_objective/proc/get_description()
	return "Placeholder objective."

/datum/job_objective/proc/unit_completed(var/count=1)
	units_completed += count
	units_needing_compensation += count

/datum/job_objective/proc/is_completed()
	if(!completed)
		completed = check_for_completion()
	return completed

/datum/job_objective/proc/check_for_completion()
	return 0

/datum/game_mode/proc/declare_job_completion()
	var/text = "<FONT size = 2><B>Job Completion:</B></FONT>"
	for(var/datum/mind/employee in player_list)
		if(!employee.job_objectives.len)//If the employee had no objectives, don't need to process this.
			return
		var/tasks_completed=0

		//text += "<b>[L.name]</b> ([ckey(D.mind.key)]), the [L.job]:\n"
		text += "<br>[employee.key] was [employee.name] ("
		if(employee.current)
			if(employee.current.stat == DEAD)
				text += "died"
			else
				text += "survived"
			if(employee.current.real_name != employee.name)
				text += " as [employee.current.real_name]"
		else
			text += "body destroyed"
		text += ")"

		var/count = 1
		for(var/datum/job_objective/objective in employee.job_objectives)
			if(objective.is_completed(1))
				text += "<br><B>Task #[count]</B>: [objective.get_description()] <font color='green'><B>Completed!</B></font>"
				feedback_add_details("employee_objective","[objective.type]|SUCCESS")
				tasks_completed++
			else
				text += "<br><B>Task #[count]</B>: [objective.get_description()] <font color='red'>Fail.</font>"
				feedback_add_details("employee_objective","[objective.type]|FAIL")
			count++

		if(tasks_completed>=1)
			text += "<br><font color='green'><B>The [employee.assigned_role] did their fucking job!</B></font>"
			feedback_add_details("employee_success","SUCCESS")
		else
			text += "<br><font color='red'><B>The [employee.assigned_role] was a worthless sack of shit!</B></font>"
			feedback_add_details("employee_success","FAIL")

	world << text
	return 1