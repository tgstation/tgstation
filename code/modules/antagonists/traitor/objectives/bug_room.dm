/datum/traitor_objective_category/bug_room
	name = "Bug Room"
	objectives = list(
		/datum/traitor_objective/bug_room = 1,
		/datum/traitor_objective/bug_room/risky = 1,
		/datum/traitor_objective/bug_room/super_risky = 1,
	)

/datum/traitor_objective/bug_room
	name = "Bug the %DEPARTMENT HEAD%'s office"
	description = "Use the button below to materialize the bug within your hand, \
		where you'll then be able to place it down in the %DEPARTMENT HEAD%'s office. \
		If it gets destroyed before you are able to plant it, this objective will fail. \
		Remember, planting the bug may leave behind fibers and fingerprints - \
		be sure to clean it off with soap (or similar) to be safe!"

	progression_reward = list(2 MINUTES, 8 MINUTES)
	telecrystal_reward = list(0, 1)

	progression_minimum = 0 MINUTES
	progression_maximum = 30 MINUTES

	var/list/applicable_heads = list(
		JOB_RESEARCH_DIRECTOR = /area/station/command/heads_quarters/rd,
		JOB_CHIEF_MEDICAL_OFFICER = /area/station/command/heads_quarters/cmo,
		JOB_CHIEF_ENGINEER = /area/station/command/heads_quarters/ce,
		JOB_HEAD_OF_PERSONNEL = /area/station/command/heads_quarters/hop,
		JOB_CAPTAIN = /area/station/command/heads_quarters/captain, // For head roles so that they can still get this objective.
		JOB_QUARTERMASTER = /area/station/command/heads_quarters/qm,
	)
	var/datum/job/target_office
	var/requires_head_as_supervisor = TRUE

	var/obj/item/traitor_bug/bug

/datum/traitor_objective/bug_room/risky
	progression_minimum = 10 MINUTES
	progression_maximum = 40 MINUTES
	applicable_heads = list(
		JOB_CAPTAIN = /area/station/command/heads_quarters/captain,
	)
	progression_reward = list(5 MINUTES, 10 MINUTES)
	telecrystal_reward = list(1, 2)
	requires_head_as_supervisor = FALSE

/datum/traitor_objective/bug_room/super_risky
	progression_minimum = 20 MINUTES
	progression_maximum = 60 MINUTES
	applicable_heads = list(
		JOB_HEAD_OF_SECURITY = /area/station/command/heads_quarters/hos,
	)
	progression_reward = list(10 MINUTES, 15 MINUTES)
	telecrystal_reward = list(2, 3)
	requires_head_as_supervisor = FALSE

/datum/traitor_objective/bug_room/super_risky/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	if(!handler.get_completion_count(/datum/traitor_objective/bug_room/risky))
		// Locked if they don't have any of the risky bug room objective completed
		return FALSE
	return ..()

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
			bug.target_area_type = applicable_heads[target_office.title]
			AddComponent(/datum/component/traitor_objective_register, bug, \
				succeed_signals = list(COMSIG_TRAITOR_BUG_PLANTED_GROUND), \
				fail_signals = list(COMSIG_PARENT_QDELETING), \
				penalty = TRUE)

/datum/traitor_objective/bug_room/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	var/datum/job/role = generating_for.assigned_role
	var/list/possible_heads
	if(requires_head_as_supervisor)
		possible_heads = applicable_heads & role.department_head
	else
		possible_heads = applicable_heads
	for(var/datum/traitor_objective/bug_room/room as anything in possible_duplicates)
		possible_heads -= room.target_office.title
	if(!length(possible_heads))
		return FALSE
	var/target_head = pick(possible_heads)

	target_office = SSjob.name_occupations[target_head]
	replace_in_name("%DEPARTMENT HEAD%", target_head)
	return TRUE

/datum/traitor_objective/bug_room/ungenerate_objective()
	bug = null

/obj/item/traitor_bug
	name = "suspicious device"
	desc = "It looks dangerous."
	item_flags = EXAMINE_SKIP

	icon = 'icons/obj/weapons/items_and_weapons.dmi'
	icon_state = "bug"

	/// The area at which this bug can be planted at. Has to be a type.
	var/area/target_area_type
	/// The object on which this bug can be planted on. Has to be a type.
	var/obj/target_object_type
	/// The object this bug is currently planted on.
	var/obj/planted_on
	/// The time it takes to place this bug.
	var/deploy_time = 10 SECONDS

/obj/item/traitor_bug/examine(mob/user)
	. = ..()
	if(planted_on)
		return

	if(user.mind?.has_antag_datum(/datum/antagonist/traitor))
		if(target_area_type)
			. += span_notice("This device must be placed by <b>using it in hand</b> inside the <b>[initial(target_area_type.name)]</b>.")
		else if(target_object_type)
			. += span_notice("This device must be placed by <b>clicking on the [initial(target_object_type.name)]</b> with it.")
		. += span_notice("Remember, you may leave behind fingerprints or fibers on the device. Use <b>soap</b> or similar to scrub it clean to be safe!")

/obj/item/traitor_bug/interact(mob/user)
	. = ..()
	if(!target_area_type)
		return
	var/turf/location = drop_location()
	if(!location)
		return
	var/area/current_area = get_area(location)
	if(!istype(current_area, target_area_type))
		balloon_alert(user, "you can't deploy this here!")
		return
	if(!do_after(user, deploy_time, src))
		return
	var/obj/structure/traitor_bug/new_bug = new(location)
	transfer_fingerprints_to(new_bug)
	transfer_fibers_to(new_bug)
	SEND_SIGNAL(src, COMSIG_TRAITOR_BUG_PLANTED_GROUND, location)
	qdel(src)

/obj/item/traitor_bug/afterattack(atom/movable/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!target_object_type)
		return
	if(!user.Adjacent(target))
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	var/result = SEND_SIGNAL(src, COMSIG_TRAITOR_BUG_PRE_PLANTED_OBJECT, target)
	if(!(result & COMPONENT_FORCE_PLACEMENT))
		if(result & COMPONENT_FORCE_FAIL_PLACEMENT || !istype(target, target_object_type))
			balloon_alert(user, "you can't attach this onto here!")
			return
	if(!do_after(user, deploy_time, src))
		return
	if(planted_on)
		return
	forceMove(target)
	target.vis_contents += src
	vis_flags |= VIS_INHERIT_PLANE
	planted_on = target
	RegisterSignal(planted_on, COMSIG_PARENT_QDELETING, PROC_REF(handle_planted_on_deletion))
	SEND_SIGNAL(src, COMSIG_TRAITOR_BUG_PLANTED_OBJECT, target)

/obj/item/traitor_bug/proc/handle_planted_on_deletion()
	planted_on = null

/obj/item/traitor_bug/Destroy()
	if(planted_on)
		vis_flags &= ~VIS_INHERIT_PLANE
		planted_on.vis_contents -= src
	return ..()

/obj/item/traitor_bug/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(planted_on)
		vis_flags &= ~VIS_INHERIT_PLANE
		planted_on.vis_contents -= src
		anchored = FALSE
		UnregisterSignal(planted_on, COMSIG_PARENT_QDELETING)
		planted_on = null

/obj/item/traitor_bug/attackby_storage_insert(datum/storage, atom/storage_holder, mob/user)
	return !istype(storage_holder, target_object_type)

/obj/structure/traitor_bug
	name = "suspicious device"
	desc = "It looks dangerous. Best you leave this alone."

	anchored = TRUE

	icon = 'icons/obj/weapons/items_and_weapons.dmi'
	icon_state = "bug-animated"

/obj/structure/traitor_bug/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(fade_out), 10 SECONDS), 3 MINUTES)

/obj/structure/traitor_bug/proc/fade_out(seconds)
	animate(src, alpha = 30, time = seconds)

/obj/structure/traitor_bug/deconstruct(disassembled)
	explosion(src, light_impact_range = 2, flame_range = 5, explosion_cause = src) // Pretty god damn dangerous
	return ..()
