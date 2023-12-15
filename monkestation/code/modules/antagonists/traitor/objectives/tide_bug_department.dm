/datum/traitor_objective_category/tide_bug_department
	name = "Tide Bug Department"
	objectives = list(/datum/traitor_objective/tide_bug_department = 1,
					/datum/traitor_objective/tide_bug_department/high_risk_department = 1)

/datum/traitor_objective/tide_bug_department
	name = "Disrupt the operations of %DEPARTMENT% by placing a T1de virus bug in %AREA%."
	description = "Use the button below to materialize the T1de virus bug within your hand, where you'll then be able to place it in %AREA%. \
				   One minute after the bug is placed it will randomly open, bolt, and or electrify all airlocks in the department, \
				   if the bug is destroyed before this, the objective will fail."
	progression_minimum = 10 MINUTES
	progression_reward = list(5 MINUTES, 10 MINUTES)
	telecrystal_reward = list(2, 3)

	///What departments can we pick from mapped to their base area type
	var/list/valid_departments = list(/datum/job_department/cargo = /area/station/cargo,
									/datum/job_department/medical = /area/station/medical,
									/datum/job_department/science = /area/station/science,
									/datum/job_department/engineering = /area/station/engineering) //service is too low security for them to be worth anything(sorry clown)
	///The department chosen for this objective to target
	var/datum/job_department/targeted_department
	///The area chosen for this objective to target
	var/area/targeted_area
	///Have we sent them the bug yet
	var/bug_sent = FALSE
	///The areas affected by this bug
	var/list/affected_areas

/datum/traitor_objective/tide_bug_department/high_risk_department
	progression_minimum = 30 MINUTES
	progression_reward = list(15 MINUTES, 20 MINUTES)
	telecrystal_reward = list(3, 4)
	valid_departments = list(/datum/job_department/command = /area/station/command,
							/datum/job_department/security = /area/station/security)

/datum/traitor_objective/tide_bug_department/can_generate_objective(datum/mind/generating_for, list/possible_duplicates)
	if(length(possible_duplicates))
		return FALSE
	return TRUE

/datum/traitor_objective/tide_bug_department/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	var/datum/job/role = generating_for.assigned_role
	for(var/datum/traitor_objective/tide_bug_department/objective as anything in possible_duplicates)
		valid_departments -= objective.targeted_department
	for(var/datum/job_department/department as anything in role.departments_list) //breaking into your own department should not be an objective
		valid_departments -= department

	if(!length(valid_departments))
		return FALSE

	targeted_department = SSjob.joinable_departments_by_type[pick(valid_departments)]

	var/list/valid_areas = typecacheof(valid_departments[targeted_department.type])
	var/list/blacklisted_areas = typecacheof(TRAITOR_OBJECTIVE_BLACKLISTED_AREAS + /area/station/security/checkpoint) //sec checkpoint is fine for weakpoints but not tide bugs
	affected_areas = GLOB.the_station_areas.Copy()
	for(var/area/possible_area as anything in affected_areas)
		if(is_type_in_typecache(possible_area, blacklisted_areas) || !is_type_in_typecache(possible_area, valid_areas) || initial(possible_area.outdoors))
			affected_areas -= possible_area

	if(!length(affected_areas))
		return FALSE

	targeted_area = pick(affected_areas)

	replace_in_name("%DEPARTMENT%", targeted_department.department_name)
	replace_in_name("%AREA%", initial(targeted_area.name))
	return TRUE

/datum/traitor_objective/tide_bug_department/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!bug_sent)
		buttons += add_ui_button("", "Pressing this will materialize a T1de virus bug in your hand.", "globe", "bug")
	return buttons

/datum/traitor_objective/tide_bug_department/ui_perform_action(mob/user, action)
	. = ..()
	if(action == "bug")
		if(bug_sent)
			return
		bug_sent = TRUE
		var/obj/item/traitor_bug/bug = new(user.drop_location(), src)
		user.put_in_hands(bug)
		bug.balloon_alert(user, "The Tide virus bug materializes in your hand.")
		AddComponent(/datum/component/traitor_objective_register, bug, \
				succeed_signals = list(COMSIG_TRAITOR_BUG_ACTIVATED), \
				fail_signals = list(COMSIG_QDELETING), \
				penalty = telecrystal_penalty)
		bug.objective_weakref = WEAKREF(src)

/obj/item/traitor_bug
	///Weakref to our objective
	var/datum/weakref/objective_weakref

/obj/item/traitor_bug/interact(mob/user)
	. = ..()
	var/datum/traitor_objective/tide_bug_department/resolved_objective = objective_weakref?.resolve()
	if(!resolved_objective?.targeted_area)
		return

	var/turf/location = drop_location()
	if(!location)
		return

	var/area/current_area = get_area(location)
	if(!istype(current_area, resolved_objective.targeted_area))
		balloon_alert(user, "you can't deploy this here!")
		return

	if(!do_after(user, deploy_time, src))
		return

	var/obj/structure/traitor_bug/new_bug = new(location)
	new_bug.bug_item_ref = src
	transfer_fingerprints_to(new_bug)
	transfer_fibers_to(new_bug)
	moveToNullspace() //this used to be handled by the objective completing as soon as this was planted, but due to needing to check for things after that its just easier to do it this way

/obj/structure/traitor_bug
	name = "suspicious device"
	desc = "It looks dangerous. Best you leave this alone."

	anchored = TRUE

	icon = 'icons/obj/device_syndie.dmi'
	icon_state = "bug-animated"
	/// Ref to our bug item
	var/obj/item/traitor_bug/bug_item_ref

/obj/structure/traitor_bug/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(tide_department)), 60 SECONDS)

/obj/structure/traitor_bug/deconstruct(disassembled)
	QDEL_NULL(bug_item_ref)
	return ..()

/obj/structure/traitor_bug/proc/tide_department()
	if(!bug_item_ref)
		return

	SEND_SIGNAL(bug_item_ref, COMSIG_TRAITOR_BUG_ACTIVATED)

	var/datum/traitor_objective/tide_bug_department/resolved_objective = bug_item_ref.objective_weakref?.resolve()
	if(!resolved_objective?.affected_areas)
		return

	SEND_GLOBAL_SIGNAL(COMSIG_GLOBAL_GREY_TIDE_TRAITOR, resolved_objective.affected_areas, TRUE)

#define TIME_TO_UNBOLT 3 MINUTES
/obj/machinery/door/airlock/proc/traitor_bug_tide()
	if(obj_flags & EMAGGED)
		return

	unbolt()
	open()

//its random if it gets bolted or electrifried or not
	if(prob(70))
		bolt()

	if(prob(30))
		set_electrified(MACHINE_ELECTRIFIED_PERMANENT)

	addtimer(CALLBACK(src, PROC_REF(unbolt)), TIME_TO_UNBOLT) //unbolt the airlocks in 3 minutes

#undef TIME_TO_UNBOLT
