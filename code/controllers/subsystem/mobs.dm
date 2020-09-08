SUBSYSTEM_DEF(mobs)
	name = "Mobs"
	priority = FIRE_PRIORITY_MOBS
	flags = SS_KEEP_TIMING | SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/currentrun = list()
	var/static/list/clients_by_zlevel[][]
	var/static/list/dead_players_by_zlevel[][] = list(list()) // Needs to support zlevel 1 here, MaxZChanged only happens when z2 is created and new_players can login before that.
	var/cubemonkeys = 0
	var/static/list/cheeserats
	var/next_slow_check = 0

/datum/controller/subsystem/mobs/stat_entry(msg)
	msg = "P:[length(GLOB.mob_living_list)]"
	return ..()

/datum/controller/subsystem/mobs/proc/MaxZChanged()
	if (!islist(clients_by_zlevel))
		clients_by_zlevel = new /list(world.maxz,0)
		dead_players_by_zlevel = new /list(world.maxz,0)
	while (clients_by_zlevel.len < world.maxz)
		clients_by_zlevel.len++
		clients_by_zlevel[clients_by_zlevel.len] = list()
		dead_players_by_zlevel.len++
		dead_players_by_zlevel[dead_players_by_zlevel.len] = list()

/datum/controller/subsystem/mobs/fire(resumed = FALSE)
	if(!resumed)
		currentrun = GLOB.mob_living_list.Copy()

	///Cache for speed as lists are references
	var/list/currentprocrun = currentrun
	var/times_fired = src.times_fired
	while(currentprocrun.len)
		var/mob/living/L = currentprocrun[currentprocrun.len]
		currentprocrun.len--
		if(!L.life_process())
			GLOB.mob_living_list.Remove(L)//we died

		if(iscarbon(L))//carbon breathing
			var/mob/living/carbon/C = L	//do it here because it happens slower than life to make atmos not die
			if(times_fired >= C.next_breathe_check || C.failed_last_breath)
				C.handle_breathing()
				C.next_breathe_check = times_fired + 4
				if(!C.failed_last_breath)//if this changes we're going to check next breathe anyway so no need to check organs
					var/obj/item/organ/lungs/lung = C.getorganslot(ORGAN_SLOT_LUNGS)
					var/obj/item/organ/lungs/heart = C:getorganslot(ORGAN_SLOT_HEART)
					if(lung?.damage > lung.high_threshold)
						C.next_breathe_check--
					if(heart?.damage > heart.high_threshold)
						C.next_breathe_check--


		if(L.client && (currentrun <= next_slow_check))//only check for the zlevel every 5 runs
			next_slow_check = currentrun + 5

			message_admins("cliechek")

			var/turf/T = get_turf(L)
			if(!T)
				L.move_to_error_room()
				var/msg = "[ADMIN_LOOKUPFLW(L)] was found to have no .loc with an attached client, if the cause is unknown it would be wise to ask how this was accomplished."
				message_admins(msg)
				send2tgs_adminless_only("Mob", msg, R_ADMIN)
				log_game("[key_name(L)] was found to have no .loc with an attached client.")

				// This is a temporary error tracker to make sure we've caught everything
			else if(L.registered_z != T.z)
#ifdef TESTING
				message_admins("[ADMIN_LOOKUPFLW(L)] has somehow ended up in Z-level [T.z] despite being registered in Z-level [registered_z]. If you could ask them how that happened and notify coderbus, it would be appreciated.")
#endif
				log_game("Z-TRACKING: [L] has somehow ended up in Z-level [T.z] despite being registered in Z-level [L.registered_z].")
				L.update_z(T.z)
			else if(L.registered_z)
				log_game("Z-TRACKING: [L] of type [L.type] has a Z-registration despite not having a client.")
				L.update_z(null)


		if(MC_TICK_CHECK)
			return
