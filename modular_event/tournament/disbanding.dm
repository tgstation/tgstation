/// Landmark to determine where team members are disbanded to
/obj/effect/landmark/disband_location
	name = "disband location"
	icon_state = "x3"

	var/arena_id = ARENA_DEFAULT_ID
	var/team_id = ARENA_RED_TEAM

	var/obj/machinery/computer/tournament_controller/tournament_controller

/obj/effect/landmark/disband_location/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/landmark/disband_location/LateInitialize()
	. = ..()

	tournament_controller = GLOB.tournament_controllers[arena_id]
	if (isnull(tournament_controller))
		stack_trace("Disband location had an invalid arena_id: \"[arena_id]\"")
		qdel(src)
		return

	tournament_controller.disband_locations[team_id] = src

/obj/effect/landmark/disband_location/Destroy()
	if (!isnull(tournament_controller))
		tournament_controller.disband_locations -= team_id

	return ..()

/obj/machinery/computer/tournament_controller/proc/disband_teams(mob/user)
	for (var/team_id in old_mobs)
		var/obj/disband_location = disband_locations[team_id]

		for (var/client/client as anything in old_mobs[team_id])
			var/mob/living/old_mob = old_mobs[team_id][client]
			if (isnull(old_mob))
				continue

			if (old_mob.stat <= CONSCIOUS)
				old_mob.fully_heal(admin_revive = TRUE)

			old_mob.forceMove(disband_location.loc)
			old_mob.key = client?.key

	QDEL_LIST(contestants)
	old_mobs.Cut()

	message_admins("[key_name_admin(user)] disbanded [arena_id] arena teams.")
	log_admin("[key_name_admin(user)] disbanded [arena_id] arena teams.")
