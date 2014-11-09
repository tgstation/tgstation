
/datum/universal_state/supermatter_cascade
 	name = "Supermatter Cascade"
 	desc = "Unknown harmonance affecting universal substructure, converting nearby matter to supermatter."

 	decay_rate = 5 // 5% chance of a turf decaying on lighting update/airflow (there's no actual tick for turfs)

/datum/universal_state/supermatter_cascade/OnShuttleCall(var/mob/user)
	if(user)
		user << "<span class='sinister'>All you hear on the frequency is static and panicked screaming. There will be no shuttle call today.</span>"
	return 0

/datum/universal_state/supermatter_cascade/OnTurfChange(var/turf/T)
	var/turf/space/spess = T
	if(istype(spess))
		spess.overlays += "end01"

/datum/universal_state/supermatter_cascade/DecayTurf(var/turf/T)
	if(istype(T,/turf/simulated/wall))
		var/turf/simulated/wall/W=T
		W.melt()
		return
	if(istype(T,/turf/simulated/floor))
		var/turf/simulated/floor/F=T
		// Burnt?
		if(!F.burnt)
			F.burn_tile()
		else
			F.ReplaceWithLattice()
		return

// Apply changes when entering state
/datum/universal_state/supermatter_cascade/OnEnter()
	world << "___________________________________________________________________"
	world << "<span class='sinister' style='font-size:3'>You are blinded by a brilliant flash of energy.</span>"

	if(emergency_shuttle.direction==2)
		captain_announce("The emergency shuttle has returned due to bluespace distortion.")

	emergency_shuttle.force_shutdown()

	for(var/area/ca in world)
		var/area/A=get_area_master(ca)
		if(!istype(A,/area) || A.name=="Space")
			continue

		// No cheating~
		A.jammed=2

		// Reset all alarms.
		A.fire     = null
		A.atmos    = 1
		A.atmosalm = 0
		A.poweralm = 1
		A.party    = null
		A.radalert = 0

		// Slap random alerts on shit
		if(prob(25))
			switch(rand(1,4))
				if(1)
					A.fire=1
				if(2)
					A.atmosalm=1
				if(3)
					A.radalert=1
				if(4)
					A.party=1

		A.updateicon()

	for(var/turf/space/spess in world)
		spess.overlays += "end01"

	for (var/obj/machinery/firealarm/alm in world)
		if (!(alm.stat & BROKEN))
			alm.ex_act(2)

	for (var/obj/machinery/power/apc/APC in world)
		if (!(APC.stat & BROKEN) && !istype(APC.areaMaster,/area/turret_protected/ai))
			if(APC.cell)
				APC.cell.charge = 0
			APC.emagged = 1
			APC.queue_icon_update()
			APC.update()

	ticker.StartThematic("endgame")
	for(var/datum/mind/M in player_list)
		if(!istype(M.current,/mob/living))
			continue
		if(M.current.stat!=2)
			M.current.Weaken(10)
			flick("e_flash", M.current.flash)

		var/failed_objectives=0
		for(var/datum/objective/O in M.objectives)
			O.blocked=O.type != /datum/objective/survive
			if(O.blocked)
				failed_objectives=1
		if(!locate(/datum/objective/survive) in M.objectives)
			var/datum/objective/survive/live = new("Escape collapsing universe through the rift.")
			live.owner=M
			M.objectives += live
		if(failed_objectives)
			M << "\red<b><font size=3>You have permitted the universe to collapse and have therefore failed your objectives.</font></b>"

		if(M in ticker.mode.revolutionaries)
			ticker.mode.revolutionaries -= M
			M << "\red <FONT size = 3><B>The massive pulse of energy clears your mind.  You are no longer a revolutionary.</B></FONT>"
			ticker.mode.update_rev_icons_removed(M)
			M.special_role = null

		if(M in ticker.mode.head_revolutionaries)
			ticker.mode.head_revolutionaries -= M
			M.current << "\red <FONT size = 3><B>The massive pulse of energy clears your mind.  You are no longer a head revolutionary.</B></FONT>"
			ticker.mode.update_rev_icons_removed(M)
			M.special_role = null

		if(M in ticker.mode.cult)
			ticker.mode.cult -= M
			ticker.mode.update_cult_icons_removed(M)
			M.special_role = null
			var/datum/game_mode/cult/cult = ticker.mode
			if (istype(cult))
				cult.memoize_cult_objectives(M)
			M.current << "\red <FONT size = 3><B>Nar-Sie loses interest in this plane. You are no longer a cultist.</B></FONT>"
			M.memory = ""

		if(M in ticker.mode.wizards)
			ticker.mode.wizards -= M
			M.special_role = null
			M.current.spellremove(M.current, config.feature_object_spell_system? "object":"verb")
			M.current << "\red <FONT size = 3><B>Your powers ebb and you feel weak. You are no longer a wizard.</B></FONT>"
			ticker.mode.update_wizard_icons_removed(M)

		if(M in ticker.mode.changelings)
			ticker.mode.changelings -= M
			M.special_role = null
			M.current.remove_changeling_powers()
			M.current.verbs -= /datum/changeling/proc/EvolutionMenu
			if(M.changeling)
				del(M.changeling)
			M.current << "<FONT color='red' size = 3><B>You grow weak and lose your powers. You are no longer a changeling and are stuck in your current form.</B></FONT>"

		if(M in ticker.mode.vampires)
			ticker.mode.vampires -= M
			M.special_role = null
			M.current.remove_vampire_powers()
			if(M.vampire)
				del(M.vampire)
			M.current << "<FONT color='red' size = 3><B>You grow weak and lose your powers. You are no longer a vampire and are stuck in your current form.</B></FONT>"

		if(M in ticker.mode.syndicates)
			ticker.mode.syndicates -= M
			ticker.mode.update_synd_icons_removed(M)
			M.special_role = null
			//for (var/datum/objective/nuclear/O in objectives)
			//	objectives-=O
			M.current << "\red <FONT size = 3><B>Your masters are likely dead or dying. You are no longer a syndicate operative.</B></FONT>"

		if(M in ticker.mode.traitors)
			ticker.mode.traitors -= M
			M.special_role = null
			M.current << "\red <FONT size = 3><B>Your masters are likely dead or dying.  You are no longer a traitor.</B></FONT>"
			if(isAI(M.current))
				var/mob/living/silicon/ai/A = M.current
				A.set_zeroth_law("")
				A.show_laws()

		if(M in ticker.mode.malf_ai)
			ticker.mode.malf_ai -= M
			M.special_role = null
			var/mob/living/silicon/ai/A = M.current

			A.verbs.Remove(/mob/living/silicon/ai/proc/choose_modules,
			/datum/game_mode/malfunction/proc/takeover,
			/datum/game_mode/malfunction/proc/ai_win)

			A.malf_picker.remove_verbs(A)

			A.laws = new base_law_type
			del(A.malf_picker)
			A.show_laws()
			A.icon_state = "ai"

			A << "\red <FONT size = 3><B>The massive blast of energy has fried the systems that were malfunctioning.  You are no longer malfunctioning.</B></FONT>"
	world << "___________________________________________________________________"
	new /obj/machinery/singularity/narsie/large/exit(pick(endgame_exits))
	spawn(rand(30,60) SECONDS)
		var/txt = {"
There's been a galaxy-wide electromagnetic pulse.  All of our systems are heavily damaged and many personnel are dead or dying. We are seeing increasing indications of the universe itself beginning to unravel.

[station_name()], you are the only facility nearby a bluespace rift, which is near your research outpost.  You are hereby directed to enter the rift using all means necessary, quite possibly as the last humans alive.

You have five minutes before the universe collapses. Good l\[\[###!!!-

AUTOMATED ALERT: Link to [command_name()] lost."}
		command_alert(txt,"SUPERMATTER CASCADE DETECTED")
		sleep(5 MINUTES)
		ticker.declare_completion()
		ticker.station_explosion_cinematic(0,null) // TODO: Custom cinematic

		world << "<B>Resetting in 30 seconds!</B>"

		feedback_set_details("end_error","Universe ended")

		if(blackbox)
			blackbox.save_all_data_to_sql()

		if (watchdog.waiting)
			world << "\blue <B>Server will shut down for an automatic update in a few seconds.</B>"
			watchdog.signal_ready()
			return
		sleep(300)
		log_game("Rebooting due to universal collapse")
		CallHook("Reboot",list())
		world.Reboot()
		return