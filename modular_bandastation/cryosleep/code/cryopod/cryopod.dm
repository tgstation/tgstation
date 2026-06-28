GLOBAL_LIST_EMPTY(objectives)

/datum/objective/New()
	. = ..()
	GLOB.objectives += src

//Apparently objectives can be qdel'd. Learn a new thing every day
/datum/objective/Destroy()
	GLOB.objectives -= src
	return ..()

// Cryopods themselves.
/obj/machinery/cryopod
	name = "cryogenic freezer"
	desc = "Камера предназначенная для киборгов и гуманоидов, является безопасным местом, где персонал, страдающий от расстройства космического сна, может немного отдохнуть."
	icon = 'modular_bandastation/cryosleep/icons/cryogenics.dmi'
	icon_state = "cryopod-open"
	base_icon_state = "cryopod"
	use_power = FALSE
	density = TRUE
	anchored = TRUE
	state_open = TRUE
	interaction_flags_mouse_drop = NEED_DEXTERITY

	var/open_icon_state = "cryopod-open"
	/// Whether the cryopod respects the minimum time someone has to be disconnected before they can be put into cryo by another player
	var/respect_minimum_client_disconnect_time = TRUE
	/// Id of the occupant despawn timer.
	var/despawn_timer_id = null
	/// Time until despawn when a mob enters a cryopod. You cannot other people in pods unless they're catatonic.
	var/time_till_despawn = 30 SECONDS
	///Weakref to our controller
	var/datum/weakref/control_computer_weakref

/obj/machinery/cryopod/post_machine_initialize()
	. = ..()
	update_appearance(UPDATE_NAME|UPDATE_ICON_STATE)
	find_control_computer()

/obj/machinery/cryopod/Destroy()
	control_computer_weakref = null
	return ..()

/obj/machinery/cryopod/examine(mob/user)
	. = ..()
	if(occupant)
		. += span_notice("Внутри находится [occupant].")

/obj/machinery/cryopod/blob_act()
	return // It shouldn't be destroyed in any possible game way

/obj/machinery/cryopod/update_name(updates)
	if(isnull(occupant))
		name = src::name
		ru_names_rename(ru_names_toml(name, override_base = "[name]"))
	else
		name = "[src::name] ([occupant])"
		ru_names_rename(ru_names_toml(src::name, suffix = " ([occupant])", override_base = name))

	return ..()

/obj/machinery/cryopod/update_icon_state()
	icon_state = state_open ? open_icon_state : base_icon_state
	return ..()

/obj/machinery/cryopod/mouse_drop_receive(atom/dropped, mob/user, params)
	put_mob_inside(dropped, user)

/obj/machinery/cryopod/open_machine(drop = TRUE, density_to_set = FALSE)
	if(!QDELETED(occupant))
		var/mob/mob_occupant = occupant
		if(isnull(mob_occupant.client))
			delete_despawn_timer()
			UnregisterSignal(occupant, COMSIG_MOB_LOGIN)
		else
			UnregisterSignal(occupant, COMSIG_MOB_LOGOUT)

		UnregisterSignal(occupant, COMSIG_LIVING_DEATH)

	. = ..()

/obj/machinery/cryopod/relaymove(mob/user)
	container_resist_act(user)

/obj/machinery/cryopod/container_resist_act(mob/living/user)
	visible_message(
		span_notice("[capitalize(occupant.declent_ru(NOMINATIVE))] вылезает из [declent_ru(GENITIVE)]!"),
		span_notice("Вы вылезаете из [declent_ru(GENITIVE)]!")
	)

	open_machine(density_to_set = TRUE)

/obj/machinery/cryopod/close_machine(atom/movable/target, density_to_set)
	find_control_computer()

	if(!can_be_put_inside(target))
		return

	. = ..()
	to_chat(occupant, span_notice("<b>Вы чувствуете, как холодный воздух обволакивает вас. Чувства затухают и ваше тело немеет.</b>"))
	RegisterSignal(occupant, COMSIG_LIVING_DEATH, PROC_REF(on_occupant_death))

	var/mob/living/mob_occupant = occupant
	if(isnull(mob_occupant.client))
		handle_clientless_occupant()
	else
		RegisterSignal(mob_occupant, COMSIG_MOB_LOGOUT, PROC_REF(on_occupant_logout))

/// Checks if the target can be put inside cryopod
/obj/machinery/cryopod/proc/can_be_put_inside(mob/target)
	return isnull(validate_put_inside(target))

/obj/machinery/cryopod/proc/on_occupant_death(mob/living/dead_mob)
	SIGNAL_HANDLER

	open_machine(density_to_set = TRUE)

/obj/machinery/cryopod/proc/on_occupant_logout()
	SIGNAL_HANDLER

	UnregisterSignal(occupant, COMSIG_MOB_LOGOUT)
	handle_clientless_occupant()

/// Starts despawn timer for clientless occupant and makes cryopod listen for mob login
/obj/machinery/cryopod/proc/handle_clientless_occupant()
	RegisterSignal(occupant, COMSIG_MOB_LOGIN, PROC_REF(on_occupant_login))
	despawn_timer_id = addtimer(CALLBACK(src, PROC_REF(despawn_occupant)), time_till_despawn, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE|TIMER_DELETE_ME)

/obj/machinery/cryopod/proc/on_occupant_login()
	SIGNAL_HANDLER

	delete_despawn_timer()
	UnregisterSignal(occupant, COMSIG_MOB_LOGIN)
	RegisterSignal(occupant, COMSIG_MOB_LOGOUT, PROC_REF(on_occupant_logout))

/// Deletes the occupant despawn timer, if it exists
/obj/machinery/cryopod/proc/delete_despawn_timer()
	PRIVATE_PROC(TRUE)

	if(isnull(despawn_timer_id))
		return

	deltimer(despawn_timer_id)
	despawn_timer_id = null

/// Tries to find the control computer. Returns TRUE if it finds one or already has one, FALSE otherwise.
/obj/machinery/cryopod/proc/find_control_computer(force = FALSE)
	if(!force && !isnull(control_computer_weakref))
		return TRUE

	for(var/obj/machinery/computer/cryopod/cryo_console as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer/cryopod))
		if(QDELETED(cryo_console))
			continue

		if(get_area(cryo_console) != get_area(src))
			continue

		control_computer_weakref = WEAKREF(cryo_console)
		RegisterSignal(cryo_console, COMSIG_AREA_EXITED, PROC_REF(on_control_computer_area_exited))
		RegisterSignal(cryo_console, COMSIG_QDELETING, PROC_REF(on_control_computed_qdeleting))
		break

	if(isnull(control_computer_weakref))
		log_admin("Cryopod in [get_area(src)] could not find control computer!")
		message_admins("Cryopod in [get_area(src)] could not find control computer!")
		return FALSE

	return TRUE

/// Tries to find the control computer if linked computer was deleted
/obj/machinery/cryopod/proc/on_control_computed_qdeleting()
	SIGNAL_HANDLER

	control_computer_weakref = null
	find_control_computer()

/// Tries to find the control computer if somehow it left the area
/obj/machinery/cryopod/proc/on_control_computer_area_exited(obj/machinery/computer/cryopod/control_computer)
	SIGNAL_HANDLER

	UnregisterSignal(control_computer, COMSIG_AREA_EXITED)

	control_computer_weakref = null
	find_control_computer()

/obj/machinery/cryopod/proc/handle_objectives()
	if(!isliving(occupant))
		return

	var/mob/living/mob_occupant = occupant
	// Update any existing objectives involving this mob.
	for(var/datum/objective/objective as anything in GLOB.objectives)
		// We don't want revs to get objectives that aren't for heads of staff. Letting
		// them win or lose based on cryo is silly so we remove the objective.
		if(istype(objective,/datum/objective/mutiny) && objective.target == mob_occupant.mind)
			objective.team.objectives -= objective
			qdel(objective)
			for(var/datum/mind/mind in objective.team.members)
				to_chat(mind.current, "<BR>[span_userdanger("Ваша цель вне зоны досягаемости. Цель удалена!")]")
				mind.announce_objectives()
			return

		if(istype(objective.target) && objective.target == mob_occupant.mind)
			var/old_target = objective.target
			objective.target = null
			objective.find_target()
			if(!objective.target && objective.owner)
				to_chat(objective.owner.current, "<BR>[span_userdanger("Ваша цель вне зоны досягаемости. Цель удалена!")]")
				for(var/datum/antagonist/antag in objective.owner.antag_datums)
					antag.objectives -= objective
			if (!objective.team)
				objective.update_explanation_text()
				objective.owner.announce_objectives()
				to_chat(objective.owner.current, "<BR>[span_userdanger("Вы чувствуете, что ваша цель вне зоны досягаемости. Время плана [pick("Б","В","Г","Д","Ж","З")]. Цели обновлены!")]")
			else
				var/list/objectives_to_update
				for(var/datum/mind/objective_owner in objective.get_owners())
					to_chat(objective_owner.current, "<BR>[span_userdanger("Вы чувствуете, что ваша цель вне зоны досягаемости. Время плана [pick("Б","В","Г","Д","Ж","З")]. Цели обновлены!")]")
					for(var/datum/objective/update_target_objective in objective_owner.get_all_objectives())
						LAZYADD(objectives_to_update, update_target_objective)
				objectives_to_update += objective.team.objectives

				for(var/datum/objective/update_objective in objectives_to_update)
					if(update_objective.target != old_target || !istype(update_objective,objective.type))
						continue
					update_objective.target = objective.target
					update_objective.update_explanation_text()
					to_chat(objective.owner.current, "<BR>[span_userdanger("Вы чувствуете, что ваша цель вне зоны досягаемости. Время плана [pick("Б","В","Г","Д","Ж","З")]. Цели обновлены!")]")
					update_objective.owner.announce_objectives()

			qdel(objective)

/// This function can not be undone; do not call this unless you are sure.
/// Handles despawning the player.
/obj/machinery/cryopod/proc/despawn_occupant()
	var/mob/mob_occupant = occupant
	GLOB.joined_player_list -= mob_occupant.ckey || mob_occupant.mind?.key

	handle_occupant_items()
	handle_objectives()

	var/obj/machinery/computer/cryopod/control_computer = get_linked_control_computer()
	if(control_computer)
		control_computer.on_crewmember_frozen(mob_occupant)

	visible_message(
		span_notice("[capitalize(declent_ru(NOMINATIVE))] гудит и шипит, перемещая [mob_occupant.declent_ru(ACCUSATIVE)] в хранилище."),
		span_notice("[capitalize(declent_ru(NOMINATIVE))] гудит и шипит, перемещая вас в хранилище."),
		span_notice("Вы слышите как что-то гудит и шипит.")
	)

	mob_occupant.ghostize()

	erase_crew_manifest_record(mob_occupant)
	SSjob.free_job_position(mob_occupant.mind?.assigned_role.title)
	QDEL_NULL(mob_occupant)

	open_machine(density_to_set = TRUE)

/obj/machinery/cryopod/proc/get_linked_control_computer()
	return find_control_computer() ? control_computer_weakref.resolve() : null

/obj/machinery/cryopod/proc/erase_crew_manifest_record(mob/living/target)
	var/datum/record/crew/record_to_remove = find_record(target.real_name)
	if(QDELETED(record_to_remove))
		return

	qdel(record_to_remove)

/// Moves the occupant's items to the linked control computer or the drop location if there is no control computer
/// Items that can not be dropped will stay in the mob's contents
/obj/machinery/cryopod/proc/handle_occupant_items()
	var/obj/machinery/computer/cryopod/control_computer = get_linked_control_computer()
	var/mob/mob_occupant = occupant

	if(!mob_occupant || issilicon(mob_occupant))
		return

	var/atom/drop_location = drop_location()
	for(var/obj/item/item_to_store in mob_occupant)
		if(HAS_TRAIT(item_to_store, TRAIT_NODROP))
			continue

		if(!control_computer)
			mob_occupant.transferItemToLoc(item_to_store, drop_location, force = TRUE, silent = TRUE)
			continue

		if(istype(item_to_store, /obj/item/modular_computer))
			var/obj/item/modular_computer/computer = item_to_store
			for(var/datum/computer_file/program/messenger/message_app in computer.stored_files)
				message_app.invisible = TRUE

		control_computer.store_item(mob_occupant, item_to_store)

	if(control_computer)
		var/obj/item/disk/nuclear/disk = locate(/obj/item/disk/nuclear) in control_computer.get_all_contents()
		if(disk)
			var/list/possible_turfs = get_adjacent_open_turfs(control_computer)
			disk.forceMove(length(possible_turfs) ? pick(possible_turfs) : drop_location())

/// Handles putting mob inside the cryopod by user
/obj/machinery/cryopod/proc/put_mob_inside(mob/target, mob/user)
	PRIVATE_PROC(TRUE)

	if(!validate_put_inside_and_alert_user(target, user))
		return

	if(target == user)
		put_self_inside(target)
	else
		put_other_inside(target, user)

/// Checks if the target can be put inside cryopod and baloon alerts user if something is wrong
/obj/machinery/cryopod/proc/validate_put_inside_and_alert_user(mob/target, mob/user)
	var/error_message = validate_put_inside(target)
	if(!isnull(error_message))
		balloon_alert(user, error_message)
		return FALSE

	return TRUE

/// Handles putting other mob inside the cryopod by target
/obj/machinery/cryopod/proc/put_other_inside(mob/target, mob/user)
	PRIVATE_PROC(TRUE)

	if(target.client)
		balloon_alert(user, "у существа есть душа")
		message_admins("[key_name_admin(user)] tries to move [key_name_admin(target)] to the cryopod, while it still has a client connected")
		log_admin("[key_name(user)] tries to move [key_name(target)] to the cryopod, while it still has a client connected")
		return

	if(target.logout_time + CONFIG_GET(number/cryo_min_ssd_time) > world.time)
		balloon_alert(user, "слишком недавно в SSD")
		return

	if(target.buckled || target.has_buckled_mobs())
		to_chat(user, span_warning("Тело [target] к чему-то пристегнуто."))
		return

	var/answer = tgui_alert(
		user,
		"Вы уверены что хотите переместить [target] в криогенный стазис? Через [DisplayTimeText(time_till_despawn)] персонаж будет удален из игры и больше не сможет вернуться в этом раунде.",
		"Поместить [target] в криогенный стазис?",
		list("Да", "Нет")
	)
	if(answer != "Да")
		return

	if(target.mind?.assigned_role.req_admin_notify)
		answer = tgui_alert(
			user,
			"Вы ТОЧНО уверены что хотите переместить [target] в криогенный стазис? Он занимает важную для раунда профессию.",
			"Поместить [target] в криогенный стазис?",
			list("Да", "Нет")
		)
		if(answer != "Да")
			return

		message_admins("[key_name_admin(user)] tries to move [key_name_admin(target)] with important job [target.mind.assigned_role.title] to the cryopod")
		log_admin("[key_name(user)] tries to move [key_name(target)] with important job [target.mind.assigned_role.title] to the cryopod")

	var/list/target_special_roles = target.mind?.get_special_roles()
	if(length(target_special_roles))
		var/special_roles_text = english_list(target_special_roles)
		message_admins("[key_name_admin(user)] tries to move to the cryopod [key_name_admin(target)] with special roles: [special_roles_text]")
		log_admin("[key_name(user)] tries to move to the cryopod [key_name(target)] with special roles: [special_roles_text]")

	place_inside(target, user)

/// Handles putting mob inside the cryopod by target itself
/obj/machinery/cryopod/proc/put_self_inside(mob/target)
	PRIVATE_PROC(TRUE)

	if(target.buckled || target.has_buckled_mobs())
		to_chat(target, span_warning("Вы к чему-то пристегнуты."))
		return

	var/answer = tgui_alert(
		target,
		"Вы уверены что хотите погрузиться в криогенный стазис? Через [DisplayTimeText(time_till_despawn)] после выхода из игры или тела ваш персонаж будет удален и больше не сможет вернуться в этом раунде.",
		"Погрузиться криогенный стазис?",
		list("Да", "Нет")
	)
	if(answer != "Да")
		return

	if(target.mind?.assigned_role.req_admin_notify)
		answer = tgui_alert(
			target,
			"Вы ТОЧНО уверены что хотите погрузиться в криогенный стазис? Вы занимаете важную для раунда профессию.",
			"Погрузиться в криогенный стазис?",
			list("Да", "Нет")
		)
		if(answer != "Да")
			return

		message_admins("[key_name_admin(target)] tries to enter cryopod with important job [target.mind.assigned_role.title]")
		log_admin("[key_name(target)] tries to enter cryopod with important job [target.mind.assigned_role.title]")

	var/list/target_special_roles = target.mind?.get_special_roles()
	if(length(target_special_roles))
		answer = tgui_alert(
			target,
			"Вы ТОЧНО уверены что хотите погрузиться в криогенный стазис? Вы играете на специальной роли.",
			"Погрузиться криогенный стазис?",
			list("Да", "Нет")
		)

		if(answer != "Да")
			return

		var/special_roles_text = english_list(target_special_roles)
		message_admins("[key_name_admin(target)] tries to enter cryopod with special roles: [special_roles_text]")
		log_admin("[key_name(target)] tries to enter cryopod with special roles: [special_roles_text]")

	place_inside(target, target)

/// Just call close_machine for the target after 10 seconds do_after, without any checks, except in `do_after`
/obj/machinery/cryopod/proc/place_inside(mob/target, mob/user)
	PRIVATE_PROC(TRUE)

	if(!do_after(user, 5 SECONDS, target, extra_checks = CALLBACK(src, PROC_REF(validate_put_inside_and_alert_user), target, target)))
		return

	close_machine(target)

/// Validates if the target can be put inside.
/// Returns `null` if the target can be put inside, otherwise returns error message
/obj/machinery/cryopod/proc/validate_put_inside(mob/target)
	PRIVATE_PROC(TRUE)

	if(!ishuman(target) && !iscyborg(target))
		return "только люди и киборги"

	if(!QDELETED(occupant))
		return "внутри уже кто-то есть"

	if(!state_open)
		return "должен быть открыт"

	var/mob/living/living_target = target
	if(living_target.stat == DEAD)
		return "существо мертво"

	return null
