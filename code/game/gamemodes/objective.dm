GLOBAL_LIST(admin_objective_list) //Prefilled admin assignable objective list

/datum/objective
	var/datum/mind/owner //The primary owner of the objective. !!SOMEWHAT DEPRECATED!! Prefer using 'team' for new code.
	var/datum/team/team //An alternative to 'owner': a team. Use this when writing new code.
	var/name = "generic objective" //Name for admin prompts
	var/explanation_text = "Nothing" //What that person is supposed to do.
	///if this objective doesn't print failure or success in the roundend report
	var/no_failure = FALSE
	///name used in printing this objective (Objective #1)
	var/objective_name = "Objective"
	var/team_explanation_text //For when there are multiple owners.
	var/datum/mind/target = null //If they are focused on a particular person.
	var/target_amount = 0 //If they are focused on a particular number. Steal objectives have their own counter.
	var/completed = FALSE //currently only used for custom objectives.
	var/martyr_compatible = FALSE //If the objective is compatible with martyr objective, i.e. if you can still do it while dead.
	///can this be granted by admins?
	var/admin_grantable = FALSE

/datum/objective/New(text)
	if(text)
		explanation_text = text

//Apparently objectives can be qdel'd. Learn a new thing every day
/datum/objective/Destroy()
	return ..()

/datum/objective/proc/get_owners() // Combine owner and team into a single list.
	. = (team?.members) ? team.members.Copy() : list()
	if(owner)
		. += owner

/datum/objective/proc/admin_edit(mob/admin)
	return

//Shared by few objective types
/datum/objective/proc/admin_simple_target_pick(mob/admin)
	var/list/possible_targets = list()
	var/def_value
	for(var/datum/mind/possible_target in SSticker.minds)
		if ((possible_target != src) && ishuman(possible_target.current))
			possible_targets += possible_target.current

	possible_targets = list("Free objective", "Random") + sort_names(possible_targets)


	if(target?.current)
		def_value = target.current

	var/mob/new_target = input(admin,"Select target:", "Objective target", def_value) as null|anything in possible_targets
	if (!new_target)
		return

	if (new_target == "Free objective")
		target = null
	else if (new_target == "Random")
		find_target()
	else
		target = new_target.mind

	update_explanation_text()

/**
 * Checks if the passed mind is considered "escaped".
 *
 * Escaped mobs are used to check certain antag objectives / results.
 *
 * Escaped includes minds with alive, non-exiled mobs generally.
 *
 * Returns TRUE if they're a free person, or FALSE if they failed
 */
/proc/considered_escaped(datum/mind/escapee)
	if(!considered_alive(escapee))
		return FALSE
	if(considered_exiled(escapee))
		return FALSE
	// "Into the sunset" force escaping for forced escape success
	if(escapee.force_escaped)
		return TRUE
	// Station destroying events (blob, cult, nukies)? Just let them win, even if there was no hope of escape
	if(SSticker.force_ending || GLOB.station_was_nuked)
		return TRUE
	// Escape hasn't happened yet
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return FALSE
	var/area/current_area = get_area(escapee.current)
	// In custody (shuttle brig) does not count as escaping
	if(!current_area || istype(current_area, /area/shuttle/escape/brig))
		return FALSE
	var/turf/current_turf = get_turf(escapee.current)
	if(!current_turf)
		return FALSE
	// Finally, if we made it to centcom (or the syndie base - got hijacked), we're home free
	return current_turf.onCentCom() || current_turf.onSyndieBase()

/datum/objective/proc/check_completion()
	return completed

/// Provides a string describing what a good job you did or did not do
/datum/objective/proc/get_roundend_success_suffix()
	if(no_failure)
		return "" // Just print the objective with no success/fail evaluation, as it has no mechanical backing
	return check_completion() ? span_greentext("Success!") : span_redtext("Fail.")

/datum/objective/proc/is_unique_objective(possible_target, dupe_search_range)
	if(!islist(dupe_search_range))
		stack_trace("Non-list passed as duplicate objective search range")
		dupe_search_range = list(dupe_search_range)

	for(var/A in dupe_search_range)
		var/list/objectives_to_compare
		if(istype(A,/datum/mind))
			var/datum/mind/M = A
			objectives_to_compare = M.get_all_objectives()
		else if(istype(A,/datum/antagonist))
			var/datum/antagonist/G = A
			objectives_to_compare = G.objectives
		else if(istype(A,/datum/team))
			var/datum/team/T = A
			objectives_to_compare = T.objectives
		for(var/datum/objective/O in objectives_to_compare)
			if(istype(O, type) && O.get_target() == possible_target)
				return FALSE
	return TRUE

/datum/objective/proc/get_target()
	return target

/datum/objective/proc/is_valid_target(datum/mind/possible_target)
	if(!ishuman(possible_target.current))
		return FALSE

	if(possible_target.current.stat == DEAD)
		return FALSE

	var/target_area = get_area(possible_target.current)
	if(!HAS_TRAIT(SSstation, STATION_TRAIT_LATE_ARRIVALS) && istype(target_area, /area/shuttle/arrival))
		return FALSE

	return TRUE

//dupe_search_range is a list of antag datums / minds / teams
/datum/objective/proc/find_target(dupe_search_range, list/blacklist)
	var/list/datum/mind/owners = get_owners()
	if(!dupe_search_range)
		dupe_search_range = get_owners()
	var/list/possible_targets = list()
	var/try_target_late_joiners = FALSE
	for(var/I in owners)
		var/datum/mind/O = I
		if(O.late_joiner)
			try_target_late_joiners = TRUE
	for(var/datum/mind/possible_target in get_crewmember_minds())
		if(possible_target in owners)
			continue
		if(!is_unique_objective(possible_target,dupe_search_range))
			continue
		if(possible_target in blacklist)
			continue
		if(!is_valid_target(possible_target))
			continue
		possible_targets += possible_target
	if(try_target_late_joiners)
		var/list/all_possible_targets = possible_targets.Copy()
		for(var/I in all_possible_targets)
			var/datum/mind/PT = I
			if(!PT.late_joiner)
				possible_targets -= PT
		if(!possible_targets.len)
			possible_targets = all_possible_targets
	if(possible_targets.len > 0)
		target = pick(possible_targets)
	update_explanation_text()
	return target

/datum/objective/proc/update_explanation_text()
	if(team_explanation_text && LAZYLEN(get_owners()) > 1)
		explanation_text = team_explanation_text

/datum/objective/proc/give_special_equipment(special_equipment)
	var/datum/mind/receiver = pick(get_owners())
	if(!ishuman(receiver?.current))
		return
	var/mob/living/carbon/human/receiver_current = receiver.current
	for(var/obj/equipment_path as anything in special_equipment)
		var/obj/equipment_object = new equipment_path
		if(receiver_current.equip_to_storage(equipment_object, ITEM_SLOT_BACK, indirect_action = TRUE))
			continue
		LAZYINITLIST(receiver.failed_special_equipment)
		receiver.failed_special_equipment += equipment_path
		receiver.try_give_equipment_fallback()

/datum/action/special_equipment_fallback
	name = "Request Objective-specific Equipment"
	desc = "Call down a supply pod containing the equipment required for specific objectives."
	button_icon = 'icons/obj/devices/tracker.dmi'
	button_icon_state = "beacon"

/datum/action/special_equipment_fallback/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return FALSE

	var/datum/mind/our_mind = target
	if(!istype(our_mind))
		CRASH("[type] - [src] has an incorrect target!")
	if(our_mind.current != owner)
		CRASH("[type] - [src] was owned by a mob which was not the current of the target mind!")

	if(LAZYLEN(our_mind.failed_special_equipment))
		podspawn(list(
			"target" = get_turf(owner),
			"style" = /datum/pod_style/syndicate,
			"spawn" = our_mind.failed_special_equipment,
		))
		our_mind.failed_special_equipment = null
	qdel(src)
	return TRUE

/datum/objective/assassinate
	name = "assassinate"
	martyr_compatible = TRUE
	admin_grantable = TRUE
	var/target_role_type = FALSE


/datum/objective/assassinate/check_completion()
	return completed || (!considered_alive(target) || considered_afk(target) || considered_exiled(target))

/datum/objective/assassinate/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Assassinate [target.name], the [!target_role_type ? target.assigned_role.title : english_list(target.get_special_roles())]."
	else
		explanation_text = "Free objective."

/datum/objective/assassinate/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

#define DISCONNECT_GRACE_TIME (2 MINUTES)
#define DISCONNECT_GRACE_WARNING_TIME (1 MINUTES)

/datum/objective/mutiny
	name = "mutiny"
	martyr_compatible = 1
	var/target_role_type = FALSE
	/// Not primarily used as a cooldown but a timer to give a little bit more of a chance for the player to reconnect.
	COOLDOWN_DECLARE(disconnect_timer)
	/// Whether admins have been warned about the potentially AFK player
	var/warned_admins = FALSE

/datum/objective/mutiny/proc/warn_admins()
	message_admins("[ADMIN_LOOKUPFLW(target.current)] has gone AFK with a mutiny objective that involves them. They only have [COOLDOWN_TIMELEFT(src, disconnect_timer) / 10] seconds remaining before they are treated as if they were dead.")

/datum/objective/mutiny/check_completion()
	if(!target || !considered_alive(target) || considered_exiled(target))
		return TRUE

	if(considered_afk(target))
		if(!COOLDOWN_STARTED(src, disconnect_timer))
			COOLDOWN_START(src, disconnect_timer, DISCONNECT_GRACE_TIME)
			warn_admins()
		else if(COOLDOWN_FINISHED(src, disconnect_timer))
			return TRUE
		else if(COOLDOWN_TIMELEFT(src, disconnect_timer) <= DISCONNECT_GRACE_WARNING_TIME && !warned_admins)
			warned_admins = TRUE
			warn_admins()
	else
		COOLDOWN_RESET(src, disconnect_timer)
		warned_admins = FALSE

	var/turf/T = get_turf(target.current)
	return !T || !is_station_level(T.z)

#undef DISCONNECT_GRACE_TIME
#undef DISCONNECT_GRACE_WARNING_TIME



/datum/objective/mutiny/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Assassinate or exile [target.name], the [!target_role_type ? target.assigned_role.title : english_list(target.get_special_roles())]."
	else
		explanation_text = "Free objective."

/datum/objective/maroon
	name = "maroon"
	martyr_compatible = TRUE
	admin_grantable = TRUE
	var/target_role_type = FALSE


/datum/objective/maroon/check_completion()
	if (!target)
		return TRUE
	if (!considered_alive(target))
		return TRUE
	if (!target.current.onCentCom() && !target.current.onSyndieBase())
		return TRUE
	return FALSE

/datum/objective/maroon/update_explanation_text()
	if(target?.current)
		explanation_text = "Prevent [target.name], the [!target_role_type ? target.assigned_role.title : english_list(target.get_special_roles())], from escaping alive."
	else
		explanation_text = "Free objective."

/datum/objective/maroon/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

/datum/objective/debrain
	name = "debrain"
	admin_grantable = TRUE
	var/target_role_type = FALSE


/datum/objective/debrain/check_completion()
	if(!target)//If it's a free objective.
		return TRUE
	if(!target.current || !isbrain(target.current))
		return FALSE
	var/atom/A = target.current
	var/list/datum/mind/owners = get_owners()

	while(A.loc) // Check to see if the brainmob is on our person
		A = A.loc
		for(var/datum/mind/M in owners)
			if(M.current && M.current.stat != DEAD && A == M.current)
				return TRUE
	return FALSE

/datum/objective/debrain/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Steal the brain of [target.name], the [!target_role_type ? target.assigned_role.title : english_list(target.get_special_roles())]."
	else
		explanation_text = "Free objective."

/datum/objective/debrain/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

/datum/objective/protect//The opposite of killing a dude.
	name = "protect"
	martyr_compatible = TRUE
	admin_grantable = TRUE
	var/target_role_type = FALSE
	var/human_check = TRUE

/datum/objective/protect/check_completion()
	var/obj/item/organ/brain/brain_target
	if(isnull(target))
		return FALSE
	if(human_check)
		brain_target = target.current?.get_organ_slot(ORGAN_SLOT_BRAIN)
	//Protect will always succeed when someone suicides
	return !target || (target.current && HAS_TRAIT(target.current, TRAIT_SUICIDED)) || considered_alive(target, enforce_human = human_check) || (brain_target && HAS_TRAIT(brain_target, TRAIT_SUICIDED))

/datum/objective/protect/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Protect [target.name], the [!target_role_type ? target.assigned_role.title : english_list(target.get_special_roles())]."
	else
		explanation_text = "Free objective."

/datum/objective/protect/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

/datum/objective/protect/nonhuman
	name = "protect nonhuman"
	human_check = FALSE
	admin_grantable = FALSE

/datum/objective/jailbreak
	name = "jailbreak"
	martyr_compatible = TRUE //why not?
	admin_grantable = TRUE
	var/target_role_type


/datum/objective/jailbreak/check_completion()
	return completed || (considered_escaped(target))

/datum/objective/jailbreak/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Ensure that [target.name], the [!target_role_type ? target.assigned_role.title : english_list(target.get_special_roles())] escapes alive and out of custody."
	else
		explanation_text = "Free objective."

/datum/objective/jailbreak/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

/datum/objective/jailbreak/detain
	name = "detain"

/datum/objective/jailbreak/detain/check_completion()
	return completed || (!considered_escaped(target) && (considered_alive(target) && target.current.onCentCom()))

/datum/objective/jailbreak/detain/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Ensure that [target.name], the [!target_role_type ? target.assigned_role.title : english_list(target.get_special_roles())] is delivered to Nanotrasen alive and in custody."
	else
		explanation_text = "Free objective."

/datum/objective/hijack
	name = "hijack"
	explanation_text = "Hijack the emergency shuttle by hacking its navigational protocols through the control console (alt click emergency shuttle console)."
	team_explanation_text = "Hijack the emergency shuttle by hacking its navigational protocols through the control console (alt click emergency shuttle console). Leave no team member behind."
	martyr_compatible = FALSE //Technically you won't get both anyway.
	/// Overrides the hijack speed of any antagonist datum it is on ONLY, no other datums are impacted.
	admin_grantable = TRUE
	var/hijack_speed_override = 1

/datum/objective/hijack/check_completion() // Requires all owners to escape.
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return FALSE
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/M in owners)
		if(!considered_alive(M) || !SSshuttle.emergency.shuttle_areas[get_area(M.current)])
			return FALSE
	return SSshuttle.emergency.is_hijacked()

/datum/objective/elimination
	name = "elimination"
	explanation_text = "Slaughter all loyalist crew aboard the shuttle. You, and any likeminded individuals, must be the only remaining people on the shuttle."
	team_explanation_text = "Slaughter all loyalist crew aboard the shuttle. You, and any likeminded individuals, must be the only remaining people on the shuttle. Leave no team member behind."
	martyr_compatible = FALSE

/datum/objective/elimination/check_completion()
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return FALSE
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/M in owners)
		if(!considered_alive(M, enforce_human = FALSE) || !SSshuttle.emergency.shuttle_areas[get_area(M.current)])
			return FALSE
	return SSshuttle.emergency.elimination_hijack()

/datum/objective/elimination/highlander
	name="highlander elimination"
	explanation_text = "Escape on the shuttle alone. Ensure that nobody else makes it out."

/datum/objective/elimination/highlander/check_completion()
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return FALSE
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/M in owners)
		if(!considered_alive(M, enforce_human = FALSE) || !SSshuttle.emergency.shuttle_areas[get_area(M.current)])
			return FALSE
	return SSshuttle.emergency.elimination_hijack(filter_by_human = FALSE, solo_hijack = TRUE)

/datum/objective/block
	name = "no organics on shuttle"
	explanation_text = "Do not allow any organic lifeforms with sapience to escape on the shuttle alive."
	martyr_compatible = 1

/datum/objective/block/check_completion()
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return TRUE
	for(var/mob/living/player in GLOB.player_list)
		if(player.mind && player.stat != DEAD && (player.mob_biotypes & MOB_ORGANIC))
			if(get_area(player) in SSshuttle.emergency.shuttle_areas)
				return FALSE
	return TRUE

/datum/objective/purge
	name = "no mutants on shuttle"
	explanation_text = "Ensure no nonhuman humanoid species with sapience are present aboard the escape shuttle."
	martyr_compatible = TRUE

/datum/objective/purge/check_completion()
	if(SSshuttle.emergency.mode != SHUTTLE_ENDGAME)
		return TRUE
	for(var/mob/living/player in GLOB.player_list)
		if((get_area(player) in SSshuttle.emergency.shuttle_areas) && player.mind && player.stat != DEAD && ishuman(player))
			var/mob/living/carbon/human/H = player
			if(H.dna.species.id != SPECIES_HUMAN)
				return FALSE
	return TRUE

/datum/objective/robot_army
	name = "robot army"
	explanation_text = "Have at least eight active cyborgs synced to you."
	martyr_compatible = FALSE

/datum/objective/robot_army/check_completion()
	var/counter = 0
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/M in owners)
		if(!M.current || !isAI(M.current))
			continue
		var/mob/living/silicon/ai/A = M.current
		for(var/mob/living/silicon/robot/R in A.connected_robots)
			if(R.stat != DEAD)
				counter++
	return counter >= 8

/datum/objective/escape
	name = "escape"
	explanation_text = "Escape on the shuttle or an escape pod alive and without being in custody."
	team_explanation_text = "Have all members of your team escape on a shuttle or pod alive, without being in custody."
	admin_grantable = TRUE

/datum/objective/escape/check_completion()
	// Require all owners escape safely.
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/M in owners)
		if(!considered_escaped(M))
			return FALSE
	return TRUE

/datum/objective/escape/escape_with_identity
	name = "escape with identity"
	var/target_real_name // Has to be stored because the target's real_name can change over the course of the round
	var/target_missing_id

/datum/objective/escape/escape_with_identity/find_target(dupe_search_range, list/blacklist)
	target = ..()
	update_explanation_text()

/datum/objective/escape/escape_with_identity/is_valid_target(datum/mind/possible_target)
	if(HAS_TRAIT(possible_target.current, TRAIT_NO_DNA_COPY))
		return FALSE
	return ..()

/datum/objective/escape/escape_with_identity/update_explanation_text()
	if(target?.current)
		target_real_name = target.current.real_name
		explanation_text = "Escape on the shuttle or an escape pod with the identity of [target_real_name], the [target.assigned_role.title]"
		var/mob/living/carbon/human/H
		if(ishuman(target.current))
			H = target.current
		if(H && H.get_id_name() != target_real_name)
			target_missing_id = 1
		else
			explanation_text += " while wearing their identification card"
		explanation_text += "." //Proper punctuation is important!

	else
		explanation_text = "Escape on the shuttle or an escape pod alive and without being in custody."

/datum/objective/escape/escape_with_identity/check_completion()
	var/list/datum/mind/owners = get_owners()
	if(!target || !target_real_name)
		return ..()
	for(var/datum/mind/M in owners)
		if(!ishuman(M.current) || !considered_escaped(M))
			continue
		var/mob/living/carbon/human/H = M.current
		if(H.dna.real_name == target_real_name && (H.get_id_name() == target_real_name || target_missing_id))
			return TRUE
	return FALSE

/datum/objective/escape/escape_with_identity/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

/datum/objective/survive
	name = "survive"
	explanation_text = "Stay alive until the end."
	admin_grantable = TRUE

/datum/objective/survive/check_completion()
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/M in owners)
		if(!considered_alive(M))
			return FALSE
	return TRUE

/datum/objective/survive/malf //Like survive, but for Malf AIs
	name = "survive AI"
	explanation_text = "Prevent your own deactivation."
	admin_grantable = FALSE

/datum/objective/survive/malf/check_completion()
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/mindobj in owners)
		if(!iscyborg(mindobj) && !considered_alive(mindobj, FALSE)) //Shells (and normal borgs for that matter) are considered alive for Malf
			return FALSE
		return TRUE

/datum/objective/exile
	name = "exile"
	explanation_text = "Stay alive off station. Do not go to CentCom."

/datum/objective/exile/check_completion()
	var/list/owners = get_owners()
	for(var/datum/mind/mind as anything in owners)
		if(!considered_alive(mind))
			return FALSE
		if(SSmapping.level_has_any_trait(mind.current.z, list(ZTRAIT_STATION, ZTRAIT_CENTCOM))) //went to centcom or ended round on station
			return FALSE
	return TRUE

/datum/objective/martyr
	name = "martyr"
	explanation_text = "Die a glorious death."
	admin_grantable = TRUE

/datum/objective/martyr/check_completion()
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/M in owners)
		if(considered_alive(M))
			return FALSE
		if(M.current && HAS_TRAIT(M.current, TRAIT_SUICIDED)) //killing yourself ISN'T glorious.
			return FALSE
	return TRUE

/datum/objective/nuclear
	name = "nuclear"
	explanation_text = "Destroy the station with a nuclear device."
	martyr_compatible = TRUE
	admin_grantable = TRUE

/datum/objective/nuclear/check_completion()
	if(GLOB.station_was_nuked)
		return TRUE
	return FALSE

GLOBAL_LIST_EMPTY(possible_items)
/datum/objective/steal
	name = "steal"
	martyr_compatible = FALSE
	admin_grantable = TRUE
	var/datum/objective_item/targetinfo = null //Save the chosen item datum so we can access it later.
	var/obj/item/steal_target = null //Needed for custom objectives (they're just items, not datums).

/datum/objective/steal/get_target()
	return steal_target

/datum/objective/steal/find_target(dupe_search_range, list/blacklist)
	var/list/datum/mind/owners = get_owners()
	if(!dupe_search_range)
		dupe_search_range = get_owners()
	var/approved_targets = list()
	for(var/datum/objective_item/possible_item in GLOB.possible_items)
		if(!possible_item.valid_objective_for(owners, require_owner = FALSE))
			continue
		if(possible_item.objective_type != OBJECTIVE_ITEM_TYPE_NORMAL)
			continue
		if(!is_unique_objective(possible_item.targetitem,dupe_search_range))
			continue
		approved_targets += possible_item
	if (length(approved_targets))
		return set_target(pick(approved_targets))
	return set_target(null)

/datum/objective/steal/proc/set_target(datum/objective_item/item)
	if(item)
		targetinfo = item
		steal_target = targetinfo.targetitem
		explanation_text = "Steal [targetinfo.name]"
		give_special_equipment(targetinfo.special_equipment)
		return steal_target
	else
		explanation_text = "Free objective."
		return

/datum/objective/steal/admin_edit(mob/admin)
	var/list/possible_items_all = GLOB.possible_items
	var/new_target = input(admin,"Select target:", "Objective target", steal_target) as null|anything in sort_names(possible_items_all)+"custom"
	if (!new_target)
		return

	if (new_target == "custom") //Can set custom items.
		var/custom_path = input(admin,"Search for target item type:","Type") as null|text
		if (!custom_path)
			return
		var/obj/item/custom_target = pick_closest_path(custom_path, make_types_fancy(subtypesof(/obj/item)))
		var/custom_name = initial(custom_target.name)
		custom_name = stripped_input(admin,"Enter target name:", "Objective target", custom_name)
		if (!custom_name)
			return
		steal_target = custom_target
		explanation_text = "Steal [custom_name]."

	else
		set_target(new_target)

/datum/objective/steal/check_completion()
	var/list/datum/mind/owners = get_owners()
	if(!steal_target)
		return TRUE
	for(var/datum/mind/M in owners)
		if(!isliving(M.current))
			continue

		var/list/all_items = M.current.get_all_contents() //this should get things in cheesewheels, books, etc.

		for(var/obj/I in all_items) //Check for items
			if(HAS_TRAIT(I, TRAIT_ITEM_OBJECTIVE_BLOCKED))
				continue

			if(istype(I, steal_target))
				if(!targetinfo) //If there's no targetinfo, then that means it was a custom objective. At this point, we know you have the item, so return 1.
					return TRUE
				else if(targetinfo.check_special_completion(I))//Returns true by default. Items with special checks will return true if the conditions are fulfilled.
					return TRUE

			if(targetinfo && (I.type in targetinfo.altitems)) //Ok, so you don't have the item. Do you have an alternative, at least?
				if(targetinfo.check_special_completion(I))//Yeah, we do! Don't return 0 if we don't though - then you could fail if you had 1 item that didn't pass and got checked first!
					return TRUE
	return FALSE

/datum/objective/capture
	name = "capture"
	admin_grantable = TRUE

/datum/objective/capture/proc/gen_amount_goal()
	target_amount = rand(5,10)
	update_explanation_text()
	return target_amount

/datum/objective/capture/update_explanation_text()
	. = ..()
	explanation_text = "Capture [target_amount] lifeform\s with an energy net. Live, rare specimens are worth more."

/datum/objective/capture/check_completion()//Basically runs through all the mobs in the area to determine how much they are worth.
	var/captured_amount = 0
	var/area/centcom/central_command_areas/holding/A = GLOB.areas_by_type[/area/centcom/central_command_areas/holding]
	for(var/mob/living/carbon/human/M in A)//Humans.
		if(ismonkey(M))
			captured_amount+=0.1
			continue
		if(M.stat == DEAD)//Dead folks are worth less.
			captured_amount+=0.5
			continue
		captured_amount+=1
	for(var/mob/living/carbon/alien/larva/M in A)//Larva are important for research.
		if(M.stat == DEAD)
			captured_amount+=0.5
			continue
		captured_amount+=1
	for(var/mob/living/carbon/alien/adult/M in A)//Aliens are worth twice as much as humans.
		if(isalienqueen(M))//Queens are worth three times as much as humans.
			if(M.stat == DEAD)
				captured_amount+=1.5
			else
				captured_amount+=3
			continue
		if(M.stat == DEAD)
			captured_amount+=1
			continue
		captured_amount+=2
	return captured_amount >= target_amount

/datum/objective/capture/admin_edit(mob/admin)
	var/count = input(admin,"How many mobs to capture ?","capture",target_amount) as num|null
	if(count)
		target_amount = count
	update_explanation_text()

/datum/objective/protect_object
	name = "protect object"
	var/obj/protect_target

/datum/objective/protect_object/proc/set_target(obj/O)
	protect_target = O
	RegisterSignal(protect_target, COMSIG_QDELETING, PROC_REF(on_objective_qdel))
	update_explanation_text()

/datum/objective/protect_object/update_explanation_text()
	. = ..()
	if(protect_target)
		explanation_text = "Protect \the [protect_target] at all costs."
	else
		explanation_text = "Free objective."

/datum/objective/protect_object/check_completion()
	return !isnull(protect_target)

/datum/objective/protect_object/proc/on_objective_qdel()
	SIGNAL_HANDLER
	protect_target = null

//Changeling Objectives

/datum/objective/absorb
	name = "absorb"
	admin_grantable = TRUE

/datum/objective/absorb/proc/gen_amount_goal(lowbound = 4, highbound = 6)
	target_amount = rand (lowbound,highbound)
	var/n_p = 1 //autowin
	var/list/datum/mind/owners = get_owners()
	if (SSticker.current_state == GAME_STATE_SETTING_UP)
		for(var/i in GLOB.new_player_list)
			var/mob/dead/new_player/P = i
			if(P.ready == PLAYER_READY_TO_PLAY && !(P.mind in owners))
				n_p ++
	else if (SSticker.IsRoundInProgress())
		for(var/mob/living/carbon/human/P in GLOB.player_list)
			if(!(IS_CHANGELING(P)) && !(P.mind in owners))
				n_p ++
	target_amount = min(target_amount, n_p)

	update_explanation_text()
	return target_amount

/datum/objective/absorb/update_explanation_text()
	. = ..()
	explanation_text = "Extract [target_amount] compatible genome\s."

/datum/objective/absorb/admin_edit(mob/admin)
	var/count = input(admin,"How many people to absorb?","absorb",target_amount) as num|null
	if(count)
		target_amount = count
	update_explanation_text()

/datum/objective/absorb/check_completion()
	var/list/datum/mind/owners = get_owners()
	var/absorbed_count = 0
	for(var/datum/mind/M in owners)
		if(!M)
			continue
		var/datum/antagonist/changeling/changeling = M.has_antag_datum(/datum/antagonist/changeling)
		if(!changeling || !changeling.stored_profiles)
			continue
		absorbed_count += changeling.absorbed_count
	return absorbed_count >= target_amount

/datum/objective/absorb_most
	name = "absorb most"
	explanation_text = "Extract more compatible genomes than any other Changeling."

/datum/objective/absorb_most/check_completion()
	var/list/datum/mind/owners = get_owners()
	var/absorbed_count = 0
	for(var/datum/mind/M in owners)
		if(!M)
			continue
		var/datum/antagonist/changeling/changeling = M.has_antag_datum(/datum/antagonist/changeling)
		if(!changeling || !changeling.stored_profiles)
			continue
		absorbed_count += changeling.absorbed_count

	for(var/datum/antagonist/changeling/changeling2 in GLOB.antagonists)
		if(!changeling2.owner || changeling2.owner == owner || !changeling2.stored_profiles || changeling2.absorbed_count < absorbed_count)
			continue
		return FALSE
	return TRUE

/datum/objective/absorb_changeling
	name = "absorb changeling"
	explanation_text = "Absorb another Changeling."

/datum/objective/absorb_changeling/check_completion()
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/ling_mind as anything in owners)
		var/datum/antagonist/changeling/changeling = ling_mind.has_antag_datum(/datum/antagonist/changeling)
		if(!changeling)
			continue

		var/total_genetic_points = changeling.genetic_points
		for(var/power_path in changeling.purchased_powers)
			var/datum/action/changeling/power = changeling.purchased_powers[power_path]
			total_genetic_points += power.dna_cost

		if(total_genetic_points > initial(changeling.genetic_points))
			return TRUE
	return completed

//End Changeling Objectives

/datum/objective/destroy
	name = "destroy AI"
	martyr_compatible = TRUE

/datum/objective/destroy/find_target(dupe_search_range, list/blacklist)
	var/list/possible_targets = active_ais(TRUE)
	possible_targets -= blacklist
	var/mob/living/silicon/ai/target_ai = pick(possible_targets)
	target = target_ai.mind
	update_explanation_text()
	return target

/datum/objective/destroy/check_completion()
	if(target?.current)
		return target.current.stat == DEAD || target.current.z > 6 || !target.current.ckey //Borgs/brains/AIs count as dead for traitor objectives.
	return TRUE

/datum/objective/destroy/update_explanation_text()
	..()
	if(target?.current)
		explanation_text = "Destroy [target.name], the experimental AI."
	else
		explanation_text = "Free objective."

/datum/objective/destroy/admin_edit(mob/admin)
	var/list/possible_targets = active_ais(1)
	if(possible_targets.len)
		var/mob/new_target = input(admin,"Select target:", "Objective target") as null|anything in sort_names(possible_targets)
		target = new_target.mind
	else
		to_chat(admin, span_boldwarning("No active AIs with minds."))
	update_explanation_text()

/datum/objective/steal_n_of_type
	name = "steal five of"
	explanation_text = "Steal some items!"
	//what types we want to steal
	var/list/wanted_items = list()
	//how many we want to steal
	var/amount = 5

/datum/objective/steal_n_of_type/New()
	..()
	wanted_items = typecacheof(wanted_items)

/datum/objective/steal_n_of_type/check_completion()
	var/list/datum/mind/owners = get_owners()
	var/stolen_count = 0
	for(var/datum/mind/M in owners)
		if(!isliving(M.current))
			continue
		var/list/all_items = M.current.get_all_contents() //this should get things in cheesewheels, books, etc.
		for(var/obj/current_item in all_items) //Check for wanted items
			if(is_type_in_typecache(current_item, wanted_items))
				if(check_if_valid_item(current_item))
					stolen_count++
	return stolen_count >= amount

/datum/objective/steal_n_of_type/proc/check_if_valid_item(obj/item/current_item)
	return TRUE

/datum/objective/steal_n_of_type/summon_guns
	name = "steal guns"
	explanation_text = "Steal at least five guns!"
	wanted_items = list(/obj/item/gun)
	amount = 5

/datum/objective/steal_n_of_type/summon_guns/check_if_valid_item(obj/item/current_item)
	var/obj/item/gun/gun = current_item
	return !(gun.gun_flags & NOT_A_REAL_GUN)

/datum/objective/steal_n_of_type/summon_magic
	name = "steal magic"
	explanation_text = "Steal at least five magical artefacts!"
	wanted_items = list()
	amount = 5

/datum/objective/steal_n_of_type/summon_magic/New()
	wanted_items = GLOB.summoned_magic_objectives
	..()

/datum/objective/steal_n_of_type/summon_magic/check_completion()
	var/list/datum/mind/owners = get_owners()
	var/stolen_count = 0
	for(var/datum/mind/M in owners)
		if(!isliving(M.current))
			continue
		var/list/all_items = M.current.get_all_contents() //this should get things in cheesewheels, books, etc.
		for(var/obj/thing in all_items) //Check for wanted items
			if(istype(thing, /obj/item/book/granter/action/spell))
				var/obj/item/book/granter/action/spell/spellbook = thing
				if(spellbook.uses > 0) //if the book still has powers...
					stolen_count++ //it counts. nice.
			else if(is_type_in_typecache(thing, wanted_items))
				stolen_count++
	return stolen_count >= amount

/datum/objective/steal_n_of_type/organs
	name = "steal organs"
	explanation_text = "Steal at least 5 organic organs! They must be kept healthy."
	wanted_items = list(/obj/item/organ)
	amount = 5 //i want this to be higher, but the organs must be fresh at roundend

/datum/objective/steal_n_of_type/organs/check_completion()
	var/list/datum/mind/owners = get_owners()
	var/stolen_count = 0
	for(var/datum/mind/mind in owners)
		if(!isliving(mind.current))
			continue
		var/list/all_items = mind.current.get_all_contents() //this should get things in cheesewheels, books, etc.
		for(var/obj/item/stolen in all_items) //Check for wanted items
			var/found = FALSE
			for(var/wanted_type in wanted_items)
				if(istype(stolen, wanted_type))
					found = TRUE
					break
			if(!found)
				continue
			//this is an objective item
			var/obj/item/organ/wanted = stolen
			if(!(wanted.organ_flags & ORGAN_FAILING) && !IS_ROBOTIC_ORGAN(wanted))
				stolen_count++
	return stolen_count >= amount

//Created by admin tools
/datum/objective/custom
	name = "custom"
	admin_grantable = TRUE
	no_failure = TRUE

/datum/objective/custom/admin_edit(mob/admin)
	var/expl = stripped_input(admin, "Custom objective:", "Objective", explanation_text)
	if(expl)
		explanation_text = expl

//Ideally this would be all of them but laziness and unusual subtypes
/proc/generate_admin_objective_list()
	GLOB.admin_objective_list = list()

	var/list/allowed_types = sort_list(subtypesof(/datum/objective), GLOBAL_PROC_REF(cmp_typepaths_asc))

	for(var/datum/objective/goal as anything in allowed_types)
		if(!initial(goal.admin_grantable))
			continue
		GLOB.admin_objective_list[initial(goal.name)] = goal

/datum/objective/contract
	var/payout = 0
	var/payout_bonus = 0
	var/area/dropoff = null

/datum/objective/contract/is_valid_target(datum/mind/possible_target)
	if(HAS_TRAIT(possible_target, TRAIT_HAS_BEEN_KIDNAPPED))
		return FALSE
	return ..()

// Generate a random valid area on the station that the dropoff will happen.
/datum/objective/contract/proc/generate_dropoff()
	var/found = FALSE
	while (!found)
		var/area/dropoff_area = pick(GLOB.areas)
		if(dropoff_area && (dropoff_area.type in GLOB.the_station_areas) && !dropoff_area.outdoors)
			dropoff = dropoff_area
			found = TRUE

// Check if both the contractor and contract target are at the dropoff point.
/datum/objective/contract/proc/dropoff_check(mob/user, mob/target)
	var/area/user_area = get_area(user)
	var/area/target_area = get_area(target)

	return (istype(user_area, dropoff) && istype(target_area, dropoff))
