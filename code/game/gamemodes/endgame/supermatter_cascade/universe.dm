
/datum/universal_state/supermatter_cascade
 	name = "Supermatter Cascade"
 	desc = "Unknown harmonance affecting universal substructure, converting nearby matter to supermatter."

 	decay_rate = 5 // 5% chance of a turf decaying on lighting update (there's no actual tick for turfs). Code that triggers this is lighting_overlays.dm, line #62.

/datum/universal_state/supermatter_cascade/OnShuttleCall(var/mob/user)
	if(user)
		if(user.hallucinating())
			var/msg = pick("your mother and father arguing","a smooth jazz tune","somebody speaking [pick("french","siik'tajr","gibberish")]","[pick("somebody","your parents","a gorilla","a man","a woman")] making [pick("chicken","cow","train","duck","cat","dog","strange","funny")] sounds")
			to_chat(user, "<span class='sinister'>All you hear on the frequency is [msg]. There will be no shuttle call today.</span>")
		else
			to_chat(user, "<span class='sinister'>All you hear on the frequency is static and panicked screaming. There will be no shuttle call today.</span>")
	return 0

/datum/universal_state/supermatter_cascade/OnTurfChange(var/turf/T)
	if(T.name == "space")
		T.overlays += "end01"
		T.underlays -= "end01"
	else
		T.overlays -= "end01"

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
			if(!istype(F,/turf/simulated/floor/plating))
				F.break_tile_to_plating()
		return

// Apply changes when entering state
/datum/universal_state/supermatter_cascade/OnEnter()
	set background = 1
	to_chat(world, "<span class='sinister' style='font-size:22pt'>You are blinded by a brilliant flash of energy.</span>")

	world << sound('sound/effects/cascade.ogg')

	for(var/mob/M in player_list)
		flick("e_flash", M.flash)

	if(emergency_shuttle.direction==2)
		captain_announce("The emergency shuttle has returned due to bluespace distortion.")

	emergency_shuttle.force_shutdown()

	suspend_alert = 1

	AreaSet()
	tcheck(80,1)
	MiscSet()
	tcheck(80,1)
	APCSet()
	tcheck(80,1)
	OverlayAndAmbientSet()
	tcheck(80,1)

	// Disable Nar-Sie.
	ticker.mode.eldergod=0

	ticker.StartThematic("endgame")

	PlayerSet()
	tcheck(80,1)
	if(!endgame_exits.len)
		message_admins("<span class='warning'><font size=7>SOMEBODY DIDNT PUT ENDGAME EXITS FOR THIS FUCKING MAP: [map.nameLong]</span></font>")
	else new /obj/machinery/singularity/narsie/large/exit(pick(endgame_exits))
	spawn(rand(30,60) SECONDS)
		var/txt = {"
There's been a galaxy-wide electromagnetic pulse.  All of our systems are heavily damaged and many personnel are dead or dying. We are seeing increasing indications of the universe itself beginning to unravel.

[station_name()], you are the only facility nearby a bluespace rift, which is near your research outpost.  You are hereby directed to enter the rift using all means necessary, quite possibly as the last humans alive.

You have five minutes before the universe collapses. Good l\[\[###!!!-

AUTOMATED ALERT: Link to [command_name()] lost.

The access requirements on the Asteroid Shuttles' consoles have now been revoked.
"}
		command_alert(txt,"SUPERMATTER CASCADE DETECTED")

		for(var/obj/machinery/computer/shuttle_control/C in machines)
			if(istype(C.shuttle,/datum/shuttle/mining) || istype(C.shuttle,/datum/shuttle/research))
				C.req_access = null

		sleep(5 MINUTES)
		ticker.declare_completion()
		ticker.station_explosion_cinematic(0,null) // TODO: Custom cinematic

		to_chat(world, "<B>Resetting in 30 seconds!</B>")

		feedback_set_details("end_error","Universe ended")

		if(blackbox)
			blackbox.save_all_data_to_sql()

		if (watchdog.waiting)
			to_chat(world, "<span class='notice'><B>Server will shut down for an automatic update in a few seconds.</B></span>")
			watchdog.signal_ready()
			return
		sleep(300)
		log_game("Rebooting due to universal collapse")
		CallHook("Reboot",list())
		world.Reboot()
		return

/datum/universal_state/supermatter_cascade/proc/AreaSet()
	for(var/area/ca in areas)
		var/area/A=get_area_master(ca)
		if(!istype(A,/area) || A.name=="Space" || istype(A,/area/beach))
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
		tcheck(80,1)

/datum/universal_state/supermatter_cascade/OverlayAndAmbientSet()
	for(var/turf/T in turfs)
		if(istype(T, /turf/space))
			T.overlays += "end01"
		else
			if(T.z != map.zCentcomm)
				T.underlays += "end01"
		tcheck(80,1)

	for(var/atom/movable/lighting_overlay/L in all_lighting_overlays)
		if(L.z != map.zCentcomm)
			L.update_lumcount(0.15, 0.5, 0)
		tcheck(80,1)

/datum/universal_state/supermatter_cascade/proc/MiscSet()
	for (var/obj/machinery/firealarm/alm in machines)
		if (!(alm.stat & BROKEN))
			alm.ex_act(2)
		tcheck(80,1)

/datum/universal_state/supermatter_cascade/proc/APCSet()
	for (var/obj/machinery/power/apc/APC in power_machines)
		if (!(APC.stat & BROKEN) && !APC.is_critical)
			APC.chargemode = 0
			if(APC.cell)
				APC.cell.charge = 0
			APC.emagged = 1
			APC.queue_icon_update()
		tcheck(80,1)

/datum/universal_state/supermatter_cascade/proc/PlayerSet()
	for(var/datum/mind/M in player_list)
		if(!istype(M.current,/mob/living))
			continue
		if(M.current.stat!=2)
			M.current.Weaken(10)
			flick("e_flash", M.current.flash)
		tcheck(80,1)

		var/failed_objectives=0
		for(var/datum/objective/O in M.objectives)
			O.blocked=O.type != /datum/objective/survive
			if(O.blocked)
				failed_objectives=1
			tcheck(80,1)

		if(!locate(/datum/objective/survive) in M.objectives)
			var/datum/objective/survive/live = new("Escape collapsing universe through the rift on the research output.")
			live.owner=M
			M.objectives += live

		if(failed_objectives)
			to_chat(M, "<span class='danger'><font size=3>You have permitted the universe to collapse and have therefore failed your objectives.</font></span>")

		// Delete all runes
		for(var/obj/effect/rune/R in rune_list)
			if(R)
				qdel(R)

		if(M in ticker.mode.revolutionaries)
			ticker.mode.revolutionaries -= M
			to_chat(M, "<span class='danger'><FONT size = 3>The massive pulse of energy clears your mind.  You are no longer a revolutionary.</FONT></span>")
			ticker.mode.update_rev_icons_removed(M)
			M.special_role = null

		if(M in ticker.mode.head_revolutionaries)
			ticker.mode.head_revolutionaries -= M
			to_chat(M.current, "<span class='danger'><FONT size = 3>The massive pulse of energy clears your mind.  You are no longer a head revolutionary.</FONT></span>")
			ticker.mode.update_rev_icons_removed(M)
			M.special_role = null

		if(M in ticker.mode.cult)
			ticker.mode.cult -= M
			ticker.mode.update_cult_icons_removed(M)
			M.special_role = null
			var/datum/game_mode/cult/cult = ticker.mode
			if (istype(cult))
				cult.memoize_cult_objectives(M)
			to_chat(M.current, "<span class='danger'><FONT size = 3>Nar-Sie loses interest in this plane. You are no longer a cultist.</FONT></span>")
			to_chat(M.current, "<span class='danger'>You find yourself unable to mouth the words of the forgotten...</span>")
			M.current.remove_language("Cult")
			M.memory = ""

		if(M in ticker.mode.wizards)
			ticker.mode.wizards -= M
			M.special_role = null
			M.current.spellremove(M.current, config.feature_object_spell_system? "object":"verb")
			to_chat(M.current, "<span class='danger'><FONT size = 3>Your powers ebb and you feel weak. You are no longer a wizard.</FONT></span>")
			ticker.mode.update_wizard_icons_removed(M)

		if(M in ticker.mode.changelings)
			ticker.mode.changelings -= M
			M.special_role = null
			M.current.remove_changeling_powers()
			M.current.verbs -= /datum/changeling/proc/EvolutionMenu
			if(M.changeling)
				del(M.changeling)
			to_chat(M.current, "<span class='danger'><FONT size = 3>You grow weak and lose your powers. You are no longer a changeling and are stuck in your current form.</FONT></span>")

		if(M in ticker.mode.vampires)
			ticker.mode.vampires -= M
			M.special_role = null
			M.current.remove_vampire_powers()
			if(M.vampire)
				del(M.vampire)
			to_chat(M.current, "<span class='danger'><FONT size = 3>You grow weak and lose your powers. You are no longer a vampire and are stuck in your current form.</FONT></span>")

		if(M in ticker.mode.syndicates)
			ticker.mode.syndicates -= M
			ticker.mode.update_synd_icons_removed(M)
			M.special_role = null
			//for (var/datum/objective/nuclear/O in objectives)
			//	objectives-=O
			to_chat(M.current, "<span class='danger'><FONT size = 3>Your masters are likely dead or dying. You are no longer a syndicate operative.</FONT></span>")

		if(M in ticker.mode.traitors)
			ticker.mode.traitors -= M
			M.special_role = null
			to_chat(M.current, "<span class='danger'><FONT size = 3>Your masters are likely dead or dying.  You are no longer a traitor.</FONT></span>")
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

			to_chat(A, "<span class='danger'><FONT size = 3>The massive blast of energy has fried the systems that were malfunctioning.  You are no longer malfunctioning.</FONT></span>")
		tcheck(80,1)
