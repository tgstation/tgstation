/datum/traitor_objective/bug_room
	name = "Bug the \[DEPARTMENT HEAD]'s office"
	description = "Use the button below to materialize the bug within your hand, where you'll then be able to place it down in the \[DEPARTMENT HEAD]'s office. If it gets destroyed before you are able to plant it, this objective will fail."

	progression_reward = list(2 MINUTES, 8 MINUTES)
	telecrystal_reward = list(0, 1)

	var/list/applicable_heads = list(
		"Research Director" = /area/command/heads_quarters/rd,
		"Chief Medical Officer" = /area/command/heads_quarters/cmo,
		"Chief Engineer" = /area/command/heads_quarters/ce,
		"Head of Personnel" = /area/command/heads_quarters/hop,
	)
	var/datum/job/target_office
	var/requires_head_as_supervisor = TRUE

	var/obj/item/traitor_bug/bug

/datum/traitor_objective/bug_room/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!bug)
		buttons += add_ui_button("", "Pressing this will materialize a bug in your hand, which you can place at the target office", "wifi", "summon_gear")
	return buttons

/datum/traitor_objective/bug_room/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("summon_gear")
			if(bug)
				return
			bug = new(user.drop_location())
			user.put_in_hands(bug)
			bug.balloon_alert(user, "the bug materializes in your hand")
			bug.target_area = applicable_heads[target_office.title]
			AddComponent(/datum/component/traitor_objective_register, bug, \
				succeed_signals = COMSIG_TRAITOR_BUG_PLANTED, \
				fail_signals = COMSIG_PARENT_QDELETING)

/datum/traitor_objective/bug_room/generate_objective(datum/mind/generating_for)
	var/datum/job/role = generating_for.assigned_role
	var/list/possible_heads
	if(requires_head_as_supervisor)
		possible_heads = applicable_heads & role.department_head
	else
		possible_heads = applicable_heads
	if(!length(possible_heads))
		return FALSE
	var/target_head = pick(possible_heads)

	target_office = SSjob.name_occupations[target_head]
	name = replacetext(name, "\[DEPARTMENT HEAD]", target_head)
	description = replacetext(description, "\[DEPARTMENT HEAD]", target_head)
	return TRUE

/datum/traitor_objective/bug_room/is_duplicate(datum/traitor_objective/bug_room/objective_to_compare)
	if(objective_to_compare.target_office == target_office)
		return TRUE
	return FALSE

/obj/item/traitor_bug
	name = "suspicious device"
	desc = "It looks dangerous"

	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "bug"

	var/area/target_area
	var/deploy_time = 10 SECONDS

/obj/item/traitor_bug/interact(mob/user)
	. = ..()
	var/turf/location = drop_location()
	if(!location)
		return
	var/area/current_area = get_area(location)
	if(!istype(current_area, target_area))
		balloon_alert(user, "you can't deploy this here!")
		return
	if(!do_after(user, deploy_time, src))
		return
	new /obj/structure/traitor_bug(location)
	SEND_SIGNAL(src, COMSIG_TRAITOR_BUG_PLANTED, location)
	qdel(src)

/obj/structure/traitor_bug
	name = "suspicious device"
	desc = "It looks dangerous"

	anchored = TRUE

	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "bug-animated"

/obj/structure/traitor_bug/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, .proc/fade_out, 10 SECONDS), 3 MINUTES)

/obj/structure/traitor_bug/proc/fade_out(seconds)
	animate(src, alpha = 30, time = seconds)

/obj/structure/traitor_bug/deconstruct(disassembled)
	explosion(src, 0, 0, 3, 5, explosion_cause = src) // Pretty god damn dangerous
	return ..()

/datum/traitor_objective/bug_room/risky
	progression_minimum = 10 MINUTES
	applicable_heads = list(
		"Captain" = /area/command/heads_quarters/captain,
	)
	progression_reward = list(5 MINUTES, 10 MINUTES)
	telecrystal_reward = list(1, 2)
	requires_head_as_supervisor = FALSE

/datum/traitor_objective/bug_room/super_risky
	progression_minimum = 20 MINUTES
	applicable_heads = list(
		"Head of Security" = /area/command/heads_quarters/hos,
	)
	progression_reward = list(10 MINUTES, 15 MINUTES)
	telecrystal_reward = list(2, 3)
	requires_head_as_supervisor = FALSE

/datum/traitor_objective/bug_room/super_risky/generate_objective(datum/mind/generating_for)
	if(!handler.get_completion_count(/datum/traitor_objective/bug_room/risky))
		// Locked if they don't have any of the risky bug room objective completed
		return FALSE
	return ..()
