/*
	New methods:
	pulse - sends a pulse into a wire for hacking purposes
	cut - cuts a wire and makes any necessary state changes
	mend - mends a wire and makes any necessary state changes
	canAIControl - 1 if the AI can control the airlock, 0 if not (then check canAIHack to see if it can hack in)
	canAIHack - 1 if the AI can hack into the airlock to recover control, 0 if not. Also returns 0 if the AI does not *need* to hack it.
	hasPower - 1 if the main or backup power are functioning, 0 if not.
	requiresIDs - 1 if the airlock is requiring IDs, 0 if not
	isAllPowerCut - 1 if the main and backup power both have cut wires.
	regainMainPower - handles the effect of main power coming back on.
	loseMainPower - handles the effect of main power going offline. Usually (if one isn't already running) spawn a thread to count down how long it will be offline - counting down won't happen if main power was completely cut along with backup power, though, the thread will just sleep.
	loseBackupPower - handles the effect of backup power going offline.
	regainBackupPower - handles the effect of main power coming back on.
	shock - has a chance of electrocuting its target.
*/

// Wires for the airlock are located in the datum folder, inside the wires datum folder.

#define AIRLOCK_CLOSED	1
#define AIRLOCK_CLOSING	2
#define AIRLOCK_OPEN	3
#define AIRLOCK_OPENING	4
#define AIRLOCK_DENY	5
#define AIRLOCK_EMAG	6

#define AIRLOCK_SECURITY_NONE			0 //Normal airlock				//Wires are not secured
#define AIRLOCK_SECURITY_METAL			1 //Medium security airlock		//There is a simple metal over wires (use welder)
#define AIRLOCK_SECURITY_PLASTEEL_I_S	2 								//Sliced inner plating (use crowbar), jumps to 0
#define AIRLOCK_SECURITY_PLASTEEL_I		3 								//Removed outer plating, second layer here (use welder)
#define AIRLOCK_SECURITY_PLASTEEL_O_S	4 								//Sliced outer plating (use crowbar)
#define AIRLOCK_SECURITY_PLASTEEL_O		5 								//There is first layer of plasteel (use welder)
#define AIRLOCK_SECURITY_PLASTEEL		6 //Max security airlock		//Fully secured wires (use wirecutters to remove grille, that is electrified)

#define AIRLOCK_INTEGRITY_N			 300 // Normal airlock integrity
#define AIRLOCK_INTEGRITY_MULTIPLIER 1.5 // How much reinforced doors health increases
#define AIRLOCK_DAMAGE_DEFLECTION_N  20  // Normal airlock damage deflection
#define AIRLOCK_DAMAGE_DEFLECTION_R  30  // Reinforced airlock damage deflection

#define NOT_ELECTRIFIED 0
#define ELECTRIFIED_PERMANENT -1



/obj/machinery/door/airlock
	name = "airlock"
	icon = 'icons/obj/doors/airlocks/station/public.dmi'
	icon_state = "closed"
	max_integrity = 300
	var/normal_integrity = AIRLOCK_INTEGRITY_N
	integrity_failure = 70
	damage_deflection = AIRLOCK_DAMAGE_DEFLECTION_N

	var/security_level = 0 //How much are wires secured
	var/aiControlDisabled = 0 //If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
	var/hackProof = FALSE // if true, this door can't be hacked by the AI
	var/secondsMainPowerLost = 0 //The number of seconds until power is restored.
	var/secondsBackupPowerLost = 0 //The number of seconds until power is restored.
	var/spawnPowerRestoreRunning = FALSE
	var/lights = TRUE // bolt lights show by default
	secondsElectrified = 0 //How many seconds remain until the door is no longer electrified. -1 if it is permanently electrified until someone fixes it.
	var/aiDisabledIdScanner = FALSE
	var/aiHacking = FALSE
	var/obj/machinery/door/airlock/closeOther = null
	var/closeOtherId = null
	var/lockdownbyai = FALSE
	assemblytype = /obj/structure/door_assembly/door_assembly_0
	var/justzap = FALSE
	normalspeed = 1
	var/obj/item/weapon/electronics/airlock/electronics = null
	var/hasShocked = FALSE //Prevents multiple shocks from happening
	autoclose = TRUE
	var/obj/item/device/doorCharge/charge = null //If applied, causes an explosion upon opening the door
	var/obj/item/weapon/note //Any papers pinned to the airlock
	var/detonated = 0
	var/doorOpen = 'sound/machines/airlock.ogg'
	var/doorClose = 'sound/machines/airlockclose.ogg'
	var/doorDeni = 'sound/machines/deniedbeep.ogg' // i'm thinkin' Deni's
	var/boltUp = 'sound/machines/boltsup.ogg'
	var/boltDown = 'sound/machines/boltsdown.ogg'
	var/noPower = 'sound/machines/doorclick.ogg'

	var/airlock_material = null //material of inner filling; if its an airlock with glass, this should be set to "glass"
	var/overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
	var/note_overlay_file = 'icons/obj/doors/airlocks/station/overlays.dmi' //Used for papers and photos pinned to the airlock

	var/cyclelinkeddir = 0
	var/obj/machinery/door/airlock/cyclelinkedairlock
	var/shuttledocked = 0
	var/delayed_close_requested = FALSE // TRUE means the door will automatically close the next time it's opened.

	explosion_block = 1
	hud_possible = list(DIAG_AIRLOCK_HUD)

	var/air_tight = FALSE	//TRUE means density will be set as soon as the door begins to close
	var/prying_so_hard = FALSE

	var/static/list/airlock_overlays = list()

/obj/machinery/door/airlock/Initialize()
	. = ..()
	wires = new /datum/wires/airlock(src)
	if (cyclelinkeddir)
		cyclelinkairlock()
	if(frequency)
		set_frequency(frequency)

	if(closeOtherId != null)
		addtimer(CALLBACK(.proc/update_other_id), 5)
	if(glass)
		airlock_material = "glass"
	if(security_level > AIRLOCK_SECURITY_METAL)
		obj_integrity = normal_integrity * AIRLOCK_INTEGRITY_MULTIPLIER
		max_integrity = normal_integrity * AIRLOCK_INTEGRITY_MULTIPLIER
	else
		obj_integrity = normal_integrity
		max_integrity = normal_integrity
	if(damage_deflection == AIRLOCK_DAMAGE_DEFLECTION_N && security_level > AIRLOCK_SECURITY_METAL)
		damage_deflection = AIRLOCK_DAMAGE_DEFLECTION_R
	prepare_huds()
	var/datum/atom_hud/data/diagnostic/diag_hud = GLOB.huds[DATA_HUD_DIAGNOSTIC]
	diag_hud.add_to_hud(src)
	diag_hud_set_electrified()


	update_icon()

/obj/machinery/door/airlock/proc/update_other_id()
	for(var/obj/machinery/door/airlock/A in GLOB.airlocks)
		if(A.closeOtherId == closeOtherId && A != src)
			closeOther = A
			break

/obj/machinery/door/airlock/proc/cyclelinkairlock()
	if (cyclelinkedairlock)
		cyclelinkedairlock.cyclelinkedairlock = null
		cyclelinkedairlock = null
	if (!cyclelinkeddir)
		return
	var/limit = world.view
	var/turf/T = get_turf(src)
	var/obj/machinery/door/airlock/FoundDoor
	do
		T = get_step(T, cyclelinkeddir)
		FoundDoor = locate() in T
		if (FoundDoor && FoundDoor.cyclelinkeddir != get_dir(FoundDoor, src))
			FoundDoor = null
		limit--
	while(!FoundDoor && limit)
	if (!FoundDoor)
		return
	FoundDoor.cyclelinkedairlock = src
	cyclelinkedairlock = FoundDoor

/obj/machinery/door/airlock/vv_edit_var(var_name)
	. = ..()
	switch (var_name)
		if ("cyclelinkeddir")
			cyclelinkairlock()


/obj/machinery/door/airlock/lock()
	bolt()

/obj/machinery/door/airlock/proc/bolt()
	if(locked)
		return
	locked = TRUE
	playsound(src,boltDown,30,0,3)
	update_icon()

/obj/machinery/door/airlock/unlock()
	unbolt()

/obj/machinery/door/airlock/proc/unbolt()
	if(!locked)
		return
	locked = FALSE
	playsound(src,boltUp,30,0,3)
	update_icon()

/obj/machinery/door/airlock/narsie_act()
	var/turf/T = get_turf(src)
	var/runed = prob(20)
	if(glass)
		if(runed)
			new/obj/machinery/door/airlock/cult/glass(T)
		else
			new/obj/machinery/door/airlock/cult/unruned/glass(T)
	else
		if(runed)
			new/obj/machinery/door/airlock/cult(T)
		else
			new/obj/machinery/door/airlock/cult/unruned(T)
	qdel(src)

/obj/machinery/door/airlock/ratvar_act() //Airlocks become pinion airlocks that only allow servants
	if(glass)
		new/obj/machinery/door/airlock/clockwork/brass(get_turf(src))
	else
		new/obj/machinery/door/airlock/clockwork(get_turf(src))
	qdel(src)

/obj/machinery/door/airlock/Destroy()
	QDEL_NULL(wires)
	if(charge)
		qdel(charge)
		charge = null
	QDEL_NULL(electronics)
	if (cyclelinkedairlock)
		if (cyclelinkedairlock.cyclelinkedairlock == src)
			cyclelinkedairlock.cyclelinkedairlock = null
		cyclelinkedairlock = null
	if(id_tag)
		for(var/obj/machinery/doorButtons/D in GLOB.machines)
			D.removeMe(src)
	qdel(note)
	return ..()

/obj/machinery/door/airlock/handle_atom_del(atom/A)
	if(A == note)
		note = null
		update_icon()

/obj/machinery/door/airlock/bumpopen(mob/living/user) //Airlocks now zap you when you 'bump' them open when they're electrified. --NeoFite
	if(!issilicon(usr))
		if(src.isElectrified())
			if(!src.justzap)
				if(src.shock(user, 100))
					src.justzap = TRUE
					spawn (10)
						justzap = FALSE
					return
			else /*if(src.justzap)*/
				return
		else if(user.hallucination > 50 && ishuman(user) && prob(10) && src.operating == FALSE)
			hallucinate_shock(user)
			return
	if (cyclelinkedairlock)
		if (!shuttledocked && !emergency && !cyclelinkedairlock.shuttledocked && !cyclelinkedairlock.emergency && allowed(user))
			if(cyclelinkedairlock.operating)
				cyclelinkedairlock.delayed_close_requested = TRUE
			else
				addtimer(CALLBACK(cyclelinkedairlock, .proc/close), 2)
	..()

/obj/machinery/door/airlock/proc/hallucinate_shock(mob/living/user)
	var/image/shock_image = image(user, user, dir = user.dir)
	var/image/electrocution_skeleton_anim = image('icons/mob/human.dmi', user, icon_state = "electrocuted_base", layer=ABOVE_MOB_LAYER)
	shock_image.color = rgb(0,0,0)
	shock_image.override = TRUE
	electrocution_skeleton_anim.appearance_flags = RESET_COLOR

	to_chat(user, "<span class='userdanger'>You feel a powerful shock course through your body!</span>")
	if(user.client)
		user.client.images |= shock_image
		user.client.images |= electrocution_skeleton_anim
	addtimer(CALLBACK(src, .proc/reset_hallucinate_shock_animation, user, shock_image, electrocution_skeleton_anim), 40)
	user.playsound_local(get_turf(src), "sparks", 100, 1)
	user.staminaloss += 50
	user.Stun(40)
	user.jitteriness += 1000
	user.do_jitter_animation(user.jitteriness)
	addtimer(CALLBACK(src, .proc/hallucinate_shock_drop, user), 20)

/obj/machinery/door/airlock/proc/reset_hallucinate_shock_animation(mob/living/user, shock_image, electrocution_skeleton_anim)
	if(user.client)
		user.client.images.Remove(shock_image)
		user.client.images.Remove(electrocution_skeleton_anim)

/obj/machinery/door/airlock/proc/hallucinate_shock_drop(mob/living/user)
	user.jitteriness = max(user.jitteriness - 990, 10) //Still jittery, but vastly less
	user.Knockdown(60)

/obj/machinery/door/airlock/proc/isElectrified()
	if(src.secondsElectrified != NOT_ELECTRIFIED)
		return TRUE
	return FALSE

/obj/machinery/door/airlock/proc/canAIControl(mob/user)
	return ((aiControlDisabled != 1) && (!isAllPowerCut()));

/obj/machinery/door/airlock/proc/canAIHack()
	return ((aiControlDisabled==1) && (!hackProof) && (!isAllPowerCut()));

/obj/machinery/door/airlock/hasPower()
	return ((!secondsMainPowerLost || !secondsBackupPowerLost) && !(stat & NOPOWER))

/obj/machinery/door/airlock/requiresID()
	return !(wires.is_cut(WIRE_IDSCAN) || aiDisabledIdScanner)

/obj/machinery/door/airlock/proc/isAllPowerCut()
	if((wires.is_cut(WIRE_POWER1) || wires.is_cut(WIRE_POWER2)) && (wires.is_cut(WIRE_BACKUP1) || wires.is_cut(WIRE_BACKUP2)))
		return TRUE

/obj/machinery/door/airlock/proc/regainMainPower()
	if(src.secondsMainPowerLost > 0)
		src.secondsMainPowerLost = 0

/obj/machinery/door/airlock/proc/loseMainPower()
	if(src.secondsMainPowerLost <= 0)
		src.secondsMainPowerLost = 60
		if(src.secondsBackupPowerLost < 10)
			src.secondsBackupPowerLost = 10
	if(!src.spawnPowerRestoreRunning)
		spawnPowerRestoreRunning = TRUE
		spawn(0)
			var/cont = 1
			while (cont)
				sleep(10)
				if(QDELETED(src))
					return
				cont = 0
				if(secondsMainPowerLost>0)
					if(!wires.is_cut(WIRE_POWER1) && !wires.is_cut(WIRE_POWER2))
						secondsMainPowerLost -= 1
						updateDialog()
					cont = 1

				if(secondsBackupPowerLost>0)
					if(!wires.is_cut(WIRE_BACKUP1) && !wires.is_cut(WIRE_BACKUP2))
						secondsBackupPowerLost -= 1
						updateDialog()
					cont = 1
			spawnPowerRestoreRunning = FALSE
			updateDialog()

/obj/machinery/door/airlock/proc/loseBackupPower()
	if(src.secondsBackupPowerLost < 60)
		src.secondsBackupPowerLost = 60

/obj/machinery/door/airlock/proc/regainBackupPower()
	if(src.secondsBackupPowerLost > 0)
		src.secondsBackupPowerLost = 0

// shock user with probability prb (if all connections & power are working)
// returns TRUE if shocked, FALSE otherwise
// The preceding comment was borrowed from the grille's shock script
/obj/machinery/door/airlock/proc/shock(mob/user, prb)
	if(!hasPower())		// unpowered, no shock
		return FALSE
	if(hasShocked > world.time)
		return FALSE	//Already shocked someone recently?
	if(!prob(prb))
		return FALSE //you lucked out, no shock for you
	do_sparks(5, TRUE, src)
	var/tmp/check_range = TRUE
	if(electrocute_mob(user, get_area(src), src, 1, check_range))
		hasShocked = world.time + 10
		return TRUE
	else
		return FALSE

/obj/machinery/door/airlock/update_icon(state=0, override=0)
	if(operating && !override)
		return
	switch(state)
		if(0)
			if(density)
				state = AIRLOCK_CLOSED
			else
				state = AIRLOCK_OPEN
			icon_state = ""
		if(AIRLOCK_OPEN, AIRLOCK_CLOSED)
			icon_state = ""
		if(AIRLOCK_DENY, AIRLOCK_OPENING, AIRLOCK_CLOSING, AIRLOCK_EMAG)
			icon_state = "nonexistenticonstate" //MADNESS
	set_airlock_overlays(state)

/obj/machinery/door/airlock/proc/set_airlock_overlays(state)
	var/mutable_appearance/frame_overlay
	var/mutable_appearance/filling_overlay
	var/mutable_appearance/lights_overlay
	var/mutable_appearance/panel_overlay
	var/mutable_appearance/weld_overlay
	var/mutable_appearance/damag_overlay
	var/mutable_appearance/sparks_overlay
	var/mutable_appearance/note_overlay
	var/notetype = note_type()

	switch(state)
		if(AIRLOCK_CLOSED)
			frame_overlay = get_airlock_overlay("closed", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closed_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)
			if(obj_integrity <integrity_failure)
				damag_overlay = get_airlock_overlay("sparks_broken", overlays_file)
			else if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_damaged", overlays_file)
			if(lights && hasPower())
				if(locked)
					lights_overlay = get_airlock_overlay("lights_bolts", overlays_file)
				else if(emergency)
					lights_overlay = get_airlock_overlay("lights_emergency", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay(notetype, note_overlay_file)

		if(AIRLOCK_DENY)
			if(!hasPower())
				return
			frame_overlay = get_airlock_overlay("closed", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closed_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(obj_integrity <integrity_failure)
				damag_overlay = get_airlock_overlay("sparks_broken", overlays_file)
			else if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_damaged", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)
			lights_overlay = get_airlock_overlay("lights_denied", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay(notetype, note_overlay_file)

		if(AIRLOCK_EMAG)
			frame_overlay = get_airlock_overlay("closed", icon)
			sparks_overlay = get_airlock_overlay("sparks", overlays_file)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closed_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(obj_integrity <integrity_failure)
				damag_overlay = get_airlock_overlay("sparks_broken", overlays_file)
			else if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_damaged", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay(notetype, note_overlay_file)

		if(AIRLOCK_CLOSING)
			frame_overlay = get_airlock_overlay("closing", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closing", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closing", icon)
			if(lights && hasPower())
				lights_overlay = get_airlock_overlay("lights_closing", overlays_file)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closing_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closing", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay("[notetype]_closing", note_overlay_file)

		if(AIRLOCK_OPEN)
			frame_overlay = get_airlock_overlay("open", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_open", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_open", icon)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_open_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_open", overlays_file)
			if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_open", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay("[notetype]_open", note_overlay_file)

		if(AIRLOCK_OPENING)
			frame_overlay = get_airlock_overlay("opening", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_opening", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_opening", icon)
			if(lights && hasPower())
				lights_overlay = get_airlock_overlay("lights_opening", overlays_file)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_opening_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_opening", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay("[notetype]_opening", note_overlay_file)

	cut_overlays()
	add_overlay(frame_overlay)
	add_overlay(filling_overlay)
	add_overlay(lights_overlay)
	add_overlay(panel_overlay)
	add_overlay(weld_overlay)
	add_overlay(sparks_overlay)
	add_overlay(damag_overlay)
	add_overlay(note_overlay)

/proc/get_airlock_overlay(icon_state, icon_file)
	var/obj/machinery/door/airlock/A
	pass(A)	//suppress unused warning
	var/list/airlock_overlays = A.airlock_overlays
	var/iconkey = "[icon_state][icon_file]"
	if((!(. = airlock_overlays[iconkey])))
		. = airlock_overlays[iconkey] = mutable_appearance(icon_file, icon_state)

/obj/machinery/door/airlock/do_animate(animation)
	switch(animation)
		if("opening")
			update_icon(AIRLOCK_OPENING)
		if("closing")
			update_icon(AIRLOCK_CLOSING)
		if("deny")
			if(!stat)
				update_icon(AIRLOCK_DENY)
				playsound(src,doorDeni,50,0,3)
				sleep(6)
				update_icon(AIRLOCK_CLOSED)

/obj/machinery/door/airlock/examine(mob/user)
	..()
	if(charge && !panel_open && in_range(user, src))
		to_chat(user, "<span class='warning'>The maintenance panel seems haphazardly fastened.</span>")
	if(charge && panel_open)
		to_chat(user, "<span class='warning'>Something is wired up to the airlock's electronics!</span>")
	if(note)
		if(!in_range(user, src))
			to_chat(user, "There's a [note.name] pinned to the front. You can't read it from here.")
		else
			to_chat(user, "There's a [note.name] pinned to the front...")
			note.examine(user)

	if(panel_open)
		switch(security_level)
			if(AIRLOCK_SECURITY_NONE)
				to_chat(user, "Wires are exposed!")
			if(AIRLOCK_SECURITY_METAL)
				to_chat(user, "Wires are hidden behind welded metal cover")
			if(AIRLOCK_SECURITY_PLASTEEL_I_S)
				to_chat(user, "There is some shredded plasteel inside")
			if(AIRLOCK_SECURITY_PLASTEEL_I)
				to_chat(user, "Wires are behind inner layer of plasteel")
			if(AIRLOCK_SECURITY_PLASTEEL_O_S)
				to_chat(user, "There is some shredded plasteel inside")
			if(AIRLOCK_SECURITY_PLASTEEL_O)
				to_chat(user, "There is welded plasteel cover hiding wires")
			if(AIRLOCK_SECURITY_PLASTEEL)
				to_chat(user, "There is protective grille over panel")
	else if(security_level)
		if(security_level == AIRLOCK_SECURITY_METAL)
			to_chat(user, "It looks a bit stronger")
		else
			to_chat(user, "It looks very robust")

/obj/machinery/door/airlock/attack_ai(mob/user)
	if(!src.canAIControl(user))
		if(src.canAIHack())
			src.hack(user)
			return
		else
			to_chat(user, "<span class='warning'>Airlock AI control has been blocked with a firewall. Unable to hack.</span>")
	if(emagged)
		to_chat(user, "<span class='warning'>Unable to interface: Airlock is unresponsive.</span>")
		return
	if(detonated)
		to_chat(user, "<span class='warning'>Unable to interface. Airlock control panel damaged.</span>")
		return

	//Separate interface for the AI.
	user.set_machine(src)
	var/t1 = text("<B>Airlock Control</B><br>\n")
	if(src.secondsMainPowerLost > 0)
		if(!wires.is_cut(WIRE_POWER1) && !wires.is_cut(WIRE_POWER2))
			t1 += text("Main power is offline for [] seconds.<br>\n", src.secondsMainPowerLost)
		else
			t1 += text("Main power is offline indefinitely.<br>\n")
	else
		t1 += text("Main power is online.")

	if(src.secondsBackupPowerLost > 0)
		if(!wires.is_cut(WIRE_BACKUP1) && !wires.is_cut(WIRE_BACKUP2))
			t1 += text("Backup power is offline for [] seconds.<br>\n", src.secondsBackupPowerLost)
		else
			t1 += text("Backup power is offline indefinitely.<br>\n")
	else if(src.secondsMainPowerLost > 0)
		t1 += text("Backup power is online.")
	else
		t1 += text("Backup power is offline, but will turn on if main power fails.")
	t1 += "<br>\n"

	if(wires.is_cut(WIRE_IDSCAN))
		t1 += text("IdScan wire is cut.<br>\n")
	else if(src.aiDisabledIdScanner)
		t1 += text("IdScan disabled. <A href='?src=\ref[];aiEnable=1'>Enable?</a><br>\n", src)
	else
		t1 += text("IdScan enabled. <A href='?src=\ref[];aiDisable=1'>Disable?</a><br>\n", src)

	if(src.emergency)
		t1 += text("Emergency Access Override is enabled. <A href='?src=\ref[];aiDisable=11'>Disable?</a><br>\n", src)
	else
		t1 += text("Emergency Access Override is disabled. <A href='?src=\ref[];aiEnable=11'>Enable?</a><br>\n", src)

	if(wires.is_cut(WIRE_POWER1))
		t1 += text("Main Power Input wire is cut.<br>\n")
	if(wires.is_cut(WIRE_POWER2))
		t1 += text("Main Power Output wire is cut.<br>\n")
	if(!secondsMainPowerLost)
		t1 += text("<A href='?src=\ref[];aiDisable=2'>Temporarily disrupt main power?</a>.<br>\n", src)
	if(!secondsBackupPowerLost)
		t1 += text("<A href='?src=\ref[];aiDisable=3'>Temporarily disrupt backup power?</a>.<br>\n", src)

	if(wires.is_cut(WIRE_BACKUP1))
		t1 += text("Backup Power Input wire is cut.<br>\n")
	if(wires.is_cut(WIRE_BACKUP2))
		t1 += text("Backup Power Output wire is cut.<br>\n")

	if(wires.is_cut(WIRE_BOLTS))
		t1 += text("Door bolt drop wire is cut.<br>\n")
	else if(!src.locked)
		t1 += text("Door bolts are up. <A href='?src=\ref[];aiDisable=4'>Drop them?</a><br>\n", src)
	else
		t1 += text("Door bolts are down.")
		if(src.hasPower())
			t1 += text(" <A href='?src=\ref[];aiEnable=4'>Raise?</a><br>\n", src)
		else
			t1 += text(" Cannot raise door bolts due to power failure.<br>\n")

	if(wires.is_cut(WIRE_LIGHT))
		t1 += text("Door bolt lights wire is cut.<br>\n")
	else if(!src.lights)
		t1 += text("Door bolt lights are off. <A href='?src=\ref[];aiEnable=10'>Enable?</a><br>\n", src)
	else
		t1 += text("Door bolt lights are on. <A href='?src=\ref[];aiDisable=10'>Disable?</a><br>\n", src)

	if(wires.is_cut(WIRE_SHOCK))
		t1 += text("Electrification wire is cut.<br>\n")
	if(secondsElectrified==ELECTRIFIED_PERMANENT)
		t1 += text("Door is electrified indefinitely. <A href='?src=\ref[];aiDisable=5'>Un-electrify it?</a><br>\n", src)
	else if(secondsElectrified>NOT_ELECTRIFIED)
		t1 += text("Door is electrified temporarily ([] seconds). <A href='?src=\ref[];aiDisable=5'>Un-electrify it?</a><br>\n", secondsElectrified, src)
	else
		t1 += text("Door is not electrified. <A href='?src=\ref[];aiEnable=5'>Electrify it for 30 seconds?</a> Or, <A href='?src=\ref[];aiEnable=6'>Electrify it indefinitely until someone cancels the electrification?</a><br>\n", src, src)

	if(wires.is_cut(WIRE_SAFETY))
		t1 += text("Door force sensors not responding.</a><br>\n")
	else if(src.safe)
		t1 += text("Door safeties operating normally.  <A href='?src=\ref[];aiDisable=8'>Override?</a><br>\n",src)
	else
		t1 += text("Danger.  Door safeties disabled.  <A href='?src=\ref[];aiEnable=8'>Restore?</a><br>\n",src)

	if(wires.is_cut(WIRE_TIMING))
		t1 += text("Door timing circuitry not responding.</a><br>\n")
	else if(src.normalspeed)
		t1 += text("Door timing circuitry operating normally.  <A href='?src=\ref[];aiDisable=9'>Override?</a><br>\n",src)
	else
		t1 += text("Warning.  Door timing circuitry operating abnormally.  <A href='?src=\ref[];aiEnable=9'>Restore?</a><br>\n",src)

	if(src.welded)
		t1 += text("Door appears to have been welded shut.<br>\n")
	else if(!src.locked)
		if(src.density)
			t1 += text("<A href='?src=\ref[];aiEnable=7'>Open door</a><br>\n", src)
		else
			t1 += text("<A href='?src=\ref[];aiDisable=7'>Close door</a><br>\n", src)

	t1 += text("<p><a href='?src=\ref[];close=1'>Close</a></p>\n", src)
	user << browse(t1, "window=airlock")
	onclose(user, "airlock")

//aiDisable - 1 idscan, 2 disrupt main power, 3 disrupt backup power, 4 drop door bolts, 5 un-electrify door, 7 close door, 11 lift access override
//aiEnable - 1 idscan, 4 raise door bolts, 5 electrify door for 30 seconds, 6 electrify door indefinitely, 7 open door, 11 enable access override


/obj/machinery/door/airlock/proc/hack(mob/user)
	set waitfor = 0
	if(!aiHacking)
		aiHacking = TRUE
		to_chat(user, "Airlock AI control has been blocked. Beginning fault-detection.")
		sleep(50)
		if(src.canAIControl(user))
			to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
			aiHacking = FALSE
			return
		else if(!src.canAIHack())
			to_chat(user, "Connection lost! Unable to hack airlock.")
			aiHacking = FALSE
			return
		to_chat(user, "Fault confirmed: airlock control wire disabled or cut.")
		sleep(20)
		to_chat(user, "Attempting to hack into airlock. This may take some time.")
		sleep(200)
		if(src.canAIControl(user))
			to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
			aiHacking = FALSE
			return
		else if(!src.canAIHack())
			to_chat(user, "Connection lost! Unable to hack airlock.")
			aiHacking = FALSE
			return
		to_chat(user, "Upload access confirmed. Loading control program into airlock software.")
		sleep(170)
		if(src.canAIControl(user))
			to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
			aiHacking = FALSE
			return
		else if(!src.canAIHack())
			to_chat(user, "Connection lost! Unable to hack airlock.")
			aiHacking = FALSE
			return
		to_chat(user, "Transfer complete. Forcing airlock to execute program.")
		sleep(50)
		//disable blocked control
		src.aiControlDisabled = 2
		to_chat(user, "Receiving control information from airlock.")
		sleep(10)
		//bring up airlock dialog
		aiHacking = FALSE
		if(user)
			src.attack_ai(user)

/obj/machinery/door/airlock/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/machinery/door/airlock/attack_hand(mob/user)
	if(!(issilicon(user) || IsAdminGhost(user)))
		if(src.isElectrified())
			if(src.shock(user, 100))
				return

	if(ishuman(user) && prob(40) && src.density)
		var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= 60 && Adjacent(user))
			playsound(src.loc, 'sound/effects/bang.ogg', 25, 1)
			if(!istype(H.head, /obj/item/clothing/head/helmet))
				H.visible_message("<span class='danger'>[user] headbutts the airlock.</span>", \
									"<span class='userdanger'>You headbutt the airlock!</span>")
				H.Knockdown(100)
				H.apply_damage(10, BRUTE, "head")
			else
				visible_message("<span class='danger'>[user] headbutts the airlock. Good thing [user.p_theyre()] wearing a helmet.</span>")
			return

	if(panel_open)
		if(security_level)
			to_chat(user, "<span class='warning'>Wires are protected!</span>")
			return
		wires.interact(user)
	else
		..()
	return


/obj/machinery/door/airlock/Topic(href, href_list, var/nowindow = 0)
	// If you add an if(..()) check you must first remove the var/nowindow parameter.
	// Otherwise it will runtime with this kind of error: null.Topic()
	if(!nowindow)
		..()
	if(usr.incapacitated() && !IsAdminGhost(usr))
		return
	add_fingerprint(usr)
	if(href_list["close"])
		usr << browse(null, "window=airlock")
		if(usr.machine==src)
			usr.unset_machine()
			return

	if((in_range(src, usr) && isturf(loc)) && panel_open)
		usr.set_machine(src)



	if((issilicon(usr) && src.canAIControl(usr)) || IsAdminGhost(usr))
		//AI
		//aiDisable - 1 idscan, 2 disrupt main power, 3 disrupt backup power, 4 drop door bolts, 5 un-electrify door, 7 close door, 8 door safties, 9 door speed, 11 emergency access
		//aiEnable - 1 idscan, 4 raise door bolts, 5 electrify door for 30 seconds, 6 electrify door indefinitely, 7 open door,  8 door safties, 9 door speed, 11 emergency access
		if(href_list["aiDisable"])
			var/code = text2num(href_list["aiDisable"])
			switch (code)
				if(1)
					//disable idscan
					if(wires.is_cut(WIRE_IDSCAN))
						to_chat(usr, "The IdScan wire has been cut - So, you can't disable it, but it is already disabled anyways.")
					else if(src.aiDisabledIdScanner)
						to_chat(usr, "You've already disabled the IdScan feature.")
					else
						aiDisabledIdScanner = TRUE
				if(2)
					//disrupt main power
					if(!secondsMainPowerLost)
						src.loseMainPower()
						update_icon()
					else
						to_chat(usr, "Main power is already offline.")
				if(3)
					//disrupt backup power
					if(!secondsBackupPowerLost)
						src.loseBackupPower()
						update_icon()
					else
						to_chat(usr, "Backup power is already offline.")
				if(4)
					//drop door bolts
					if(wires.is_cut(WIRE_BOLTS))
						to_chat(usr, "You can't drop the door bolts - The door bolt dropping wire has been cut.")
					else
						bolt()
				if(5)
					//un-electrify door
					if(wires.is_cut(WIRE_SHOCK))
						to_chat(usr, text("Can't un-electrify the airlock - The electrification wire is cut."))
					else if(isElectrified())
						set_electrified(0)

				if(8)
					// Safeties!  We don't need no stinking safeties!
					if(wires.is_cut(WIRE_SAFETY))
						to_chat(usr, text("Control to door sensors is disabled."))
					else if (src.safe)
						safe = FALSE
					else
						to_chat(usr, text("Firmware reports safeties already overriden."))

				if(9)
					// Door speed control
					if(wires.is_cut(WIRE_TIMING))
						to_chat(usr, text("Control to door timing circuitry has been severed."))
					else if (src.normalspeed)
						normalspeed = 0
					else
						to_chat(usr, text("Door timing circuitry already accelerated."))
				if(7)
					//close door
					if(src.welded)
						to_chat(usr, text("The airlock has been welded shut!"))
					else if(src.locked)
						to_chat(usr, text("The door bolts are down!"))
					else if(!src.density)
						close()
					else
						open()

				if(10)
					// Bolt lights
					if(wires.is_cut(WIRE_LIGHT))
						to_chat(usr, text("Control to door bolt lights has been severed.</a>"))
					else if (src.lights)
						lights = FALSE
						update_icon()
					else
						to_chat(usr, text("Door bolt lights are already disabled!"))

				if(11)
					// Emergency access
					if (src.emergency)
						emergency = FALSE
						update_icon()
					else
						to_chat(usr, text("Emergency access is already disabled!"))


		else if(href_list["aiEnable"])
			var/code = text2num(href_list["aiEnable"])
			switch (code)
				if(1)
					//enable idscan
					if(wires.is_cut(WIRE_IDSCAN))
						to_chat(usr, "You can't enable IdScan - The IdScan wire has been cut.")
					else if(src.aiDisabledIdScanner)
						aiDisabledIdScanner = FALSE
					else
						to_chat(usr, "The IdScan feature is not disabled.")
				if(4)
					//raise door bolts
					if(wires.is_cut(WIRE_BOLTS))
						to_chat(usr, text("The door bolt drop wire is cut - you can't raise the door bolts.<br>\n"))
					else if(!src.locked)
						to_chat(usr, text("The door bolts are already up.<br>\n"))
					else
						if(src.hasPower())
							unbolt()
						else
							to_chat(usr, text("Cannot raise door bolts due to power failure.<br>\n"))

				if(5)
					//electrify door for 30 seconds
					if(wires.is_cut(WIRE_SHOCK))
						to_chat(usr, text("The electrification wire has been cut.<br>\n"))
					else if(secondsElectrified==ELECTRIFIED_PERMANENT)
						to_chat(usr, text("The door is already indefinitely electrified. You'd have to un-electrify it before you can re-electrify it with a non-forever duration.<br>\n"))
					else if(isElectrified())
						to_chat(usr, text("The door is already electrified. You can't re-electrify it while it's already electrified.<br>\n"))
					else
						shockedby += "\[[time_stamp()]\][usr](ckey:[usr.ckey])"
						add_logs(usr, src, "electrified")
						set_electrified(30)
						spawn(10)
							while (secondsElectrified > 0)
								secondsElectrified--
								if(secondsElectrified <= 0)
									set_electrified(NOT_ELECTRIFIED)
								updateUsrDialog()
								sleep(10)
				if(6)
					//electrify door indefinitely
					if(wires.is_cut(WIRE_SHOCK))
						to_chat(usr, text("The electrification wire has been cut.<br>\n"))
					else if(secondsElectrified==ELECTRIFIED_PERMANENT)
						to_chat(usr, text("The door is already indefinitely electrified.<br>\n"))
					else if(isElectrified())
						to_chat(usr, text("The door is already electrified. You can't re-electrify it while it's already electrified.<br>\n"))
					else
						shockedby += text("\[[time_stamp()]\][usr](ckey:[usr.ckey])")
						add_logs(usr, src, "electrified")
						set_electrified(ELECTRIFIED_PERMANENT)

				if (8) // Not in order >.>
					// Safeties!  Maybe we do need some stinking safeties!
					if(wires.is_cut(WIRE_SAFETY))
						to_chat(usr, text("Control to door sensors is disabled."))
					else if (!src.safe)
						safe = TRUE
						src.updateUsrDialog()
					else
						to_chat(usr, text("Firmware reports safeties already in place."))

				if(9)
					// Door speed control
					if(wires.is_cut(WIRE_TIMING))
						to_chat(usr, text("Control to door timing circuitry has been severed."))
					else if (!src.normalspeed)
						normalspeed = 1
						src.updateUsrDialog()
					else
						to_chat(usr, text("Door timing circuitry currently operating normally."))

				if(7)
					//open door
					if(src.welded)
						to_chat(usr, text("The airlock has been welded shut!"))
					else if(src.locked)
						to_chat(usr, text("The door bolts are down!"))
					else if(src.density)
						open()
					else
						close()
				if(10)
					// Bolt lights
					if(wires.is_cut(WIRE_LIGHT))
						to_chat(usr, text("Control to door bolt lights has been severed.</a>"))
					else if (!src.lights)
						lights = TRUE
						update_icon()
						src.updateUsrDialog()
					else
						to_chat(usr, text("Door bolt lights are already enabled!"))
				if(11)
					// Emergency access
					if (!src.emergency)
						emergency = TRUE
						update_icon()
					else
						to_chat(usr, text("Emergency access is already enabled!"))

	add_fingerprint(usr)
	if(!nowindow)
		updateUsrDialog()

/obj/machinery/door/airlock/attackby(obj/item/C, mob/user, params)
	if(!issilicon(user) && !IsAdminGhost(user))
		if(src.isElectrified())
			if(src.shock(user, 75))
				return
	add_fingerprint(user)

	if(panel_open)
		switch(security_level)
			if(AIRLOCK_SECURITY_NONE)
				if(istype(C, /obj/item/stack/sheet/metal))
					var/obj/item/stack/sheet/metal/S = C
					if(S.amount < 2)
						to_chat(user, "<span class='warning'>You need at least 2 metal sheets to reinforce [src].</span>")
						return
					to_chat(user, "<span class='notice'>You start reinforcing [src]</span>")
					if(do_after(user, 20, 1, target = src))
						if(!panel_open || !S.use(2))
							return
						user.visible_message("<span class='notice'>[user] reinforce \the [src] with metal.</span>",
											"<span class='notice'>You reinforce \the [src] with metal.</span>")
						security_level = AIRLOCK_SECURITY_METAL
						update_icon()
					return
				else if(istype(C, /obj/item/stack/sheet/plasteel))
					var/obj/item/stack/sheet/plasteel/S = C
					if(S.amount < 2)
						to_chat(user, "<span class='warning'>You need at least 2 plasteel sheets to reinforce [src].</span>")
						return
					to_chat(user, "<span class='notice'>You start reinforcing [src].</span>")
					if(do_after(user, 20, 1, target = src))
						if(!panel_open || !S.use(2))
							return
						user.visible_message("<span class='notice'>[user] reinforce \the [src] with plasteel.</span>",
											"<span class='notice'>You reinforce \the [src] with plasteel.</span>")
						security_level = AIRLOCK_SECURITY_PLASTEEL
						modify_max_integrity(normal_integrity * AIRLOCK_INTEGRITY_MULTIPLIER)
						damage_deflection = AIRLOCK_DAMAGE_DEFLECTION_R
						update_icon()
					return
			if(AIRLOCK_SECURITY_METAL)
				if(istype(C, /obj/item/weapon/weldingtool))
					var/obj/item/weapon/weldingtool/WT = C
					if(!WT.remove_fuel(2, user))
						return
					to_chat(user, "<span class='notice'>You begin cutting the panel's shielding...</span>")
					playsound(loc, WT.usesound, 40, 1)
					if(do_after(user, 40*WT.toolspeed, 1, target = src))
						if(!panel_open || !WT.isOn())
							return
						playsound(loc, WT.usesound, 50, 1)
						user.visible_message("<span class='notice'>[user] cuts through \the [src]'s shielding.</span>",
										"<span class='notice'>You cut through \the [src]'s shielding.</span>",
										"<span class='italics'>You hear welding.</span>")
						security_level = AIRLOCK_SECURITY_NONE
						spawn_atom_to_turf(/obj/item/stack/sheet/metal, user.loc, 2)
						update_icon()
					return
			if(AIRLOCK_SECURITY_PLASTEEL_I_S)
				if(istype(C, /obj/item/weapon/crowbar))
					var/obj/item/weapon/crowbar/W = C
					to_chat(user, "<span class='notice'>You start removing the inner layer of shielding...</span>")
					playsound(src, W.usesound, 100, 1)
					if(do_after(user, 40*W.toolspeed, 1, target = src))
						if(!panel_open)
							return
						if(security_level != AIRLOCK_SECURITY_PLASTEEL_I_S)
							return
						user.visible_message("<span class='notice'>[user] remove \the [src]'s shielding.</span>",
											"<span class='notice'>You remove \the [src]'s inner shielding.</span>")
						security_level = AIRLOCK_SECURITY_NONE
						modify_max_integrity(normal_integrity)
						damage_deflection = AIRLOCK_DAMAGE_DEFLECTION_N
						spawn_atom_to_turf(/obj/item/stack/sheet/plasteel, user.loc, 1)
						update_icon()
					return
			if(AIRLOCK_SECURITY_PLASTEEL_I)
				if(istype(C, /obj/item/weapon/weldingtool))
					var/obj/item/weapon/weldingtool/WT = C
					if(!WT.remove_fuel(2, user))
						return
					to_chat(user, "<span class='notice'>You begin cutting the inner layer of shielding...</span>")
					playsound(loc, WT.usesound, 40, 1)
					if(do_after(user, 40*WT.toolspeed, 1, target = src))
						if(!panel_open || !WT.isOn())
							return
						playsound(loc, WT.usesound, 50, 1)
						user.visible_message("<span class='notice'>[user] cuts through \the [src]'s shielding.</span>",
										"<span class='notice'>You cut through \the [src]'s shielding.</span>",
										"<span class='italics'>You hear welding.</span>")
						security_level = AIRLOCK_SECURITY_PLASTEEL_I_S
					return
			if(AIRLOCK_SECURITY_PLASTEEL_O_S)
				if(istype(C, /obj/item/weapon/crowbar))
					var/obj/item/weapon/crowbar/W = C
					to_chat(user, "<span class='notice'>You start removing outer layer of shielding...</span>")
					playsound(src, W.usesound, 100, 1)
					if(do_after(user, 40*W.toolspeed, 1, target = src))
						if(!panel_open)
							return
						if(security_level != AIRLOCK_SECURITY_PLASTEEL_O_S)
							return
						user.visible_message("<span class='notice'>[user] remove \the [src]'s shielding.</span>",
											"<span class='notice'>You remove \the [src]'s shielding.</span>")
						security_level = AIRLOCK_SECURITY_PLASTEEL_I
						spawn_atom_to_turf(/obj/item/stack/sheet/plasteel, user.loc, 1)
					return
			if(AIRLOCK_SECURITY_PLASTEEL_O)
				if(istype(C, /obj/item/weapon/weldingtool))
					var/obj/item/weapon/weldingtool/WT = C
					if(!WT.remove_fuel(2, user))
						return
					to_chat(user, "<span class='notice'>You begin cutting the outer layer of shielding...</span>")
					playsound(loc, WT.usesound, 40, 1)
					if(do_after(user, 40*WT.toolspeed, 1, target = src))
						if(!panel_open || !WT.isOn())
							return
						playsound(loc, WT.usesound, 50, 1)
						user.visible_message("<span class='notice'>[user] cuts through \the [src]'s shielding.</span>",
										"<span class='notice'>You cut through \the [src]'s shielding.</span>",
										"<span class='italics'>You hear welding.</span>")
						security_level = AIRLOCK_SECURITY_PLASTEEL_O_S
					return
			if(AIRLOCK_SECURITY_PLASTEEL)
				if(istype(C, /obj/item/weapon/wirecutters))
					var/obj/item/weapon/wirecutters/W = C
					if(src.hasPower() && src.shock(user, 60)) // Protective grille of wiring is electrified
						return
					to_chat(user, "<span class='notice'>You start cutting through the outer grille.</span>")
					playsound(src, W.usesound, 100, 1)
					if(do_after(user, 10*W.toolspeed, 1, target = src))
						if(!panel_open)
							return
						user.visible_message("<span class='notice'>[user] cut through \the [src]'s outer grille.</span>",
											"<span class='notice'>You cut through \the [src]'s outer grille.</span>")
						security_level = AIRLOCK_SECURITY_PLASTEEL_O
					return
	if(istype(C, /obj/item/weapon/screwdriver))
		if(panel_open && detonated)
			to_chat(user, "<span class='warning'>[src] has no maintenance panel!</span>")
			return
		panel_open = !panel_open
		to_chat(user, "<span class='notice'>You [panel_open ? "open":"close"] the maintenance panel of the airlock.</span>")
		playsound(src.loc, C.usesound, 50, 1)
		src.update_icon()
	else if(istype(C, /obj/item/weapon/wirecutters) && note)
		user.visible_message("<span class='notice'>[user] cuts down [note] from [src].</span>", "<span class='notice'>You remove [note] from [src].</span>")
		playsound(src, 'sound/items/Wirecutter.ogg', 50, 1)
		note.forceMove(get_turf(user))
		note = null
		update_icon()
	else if(is_wire_tool(C))
		return attack_hand(user)
	else if(istype(C, /obj/item/weapon/pai_cable))
		var/obj/item/weapon/pai_cable/cable = C
		cable.plugin(src, user)
	else if(istype(C, /obj/item/weapon/airlock_painter))
		change_paintjob(C, user)
	else if(istype(C, /obj/item/device/doorCharge))
		if(!panel_open || security_level)
			to_chat(user, "<span class='warning'>The maintenance panel must be open to apply [C]!</span>")
			return
		if(emagged)
			return
		if(charge && !detonated)
			to_chat(user, "<span class='warning'>There's already a charge hooked up to this door!</span>")
			return
		if(detonated)
			to_chat(user, "<span class='warning'>The maintenance panel is destroyed!</span>")
			return
		to_chat(user, "<span class='warning'>You apply [C]. Next time someone opens the door, it will explode.</span>")
		user.drop_item()
		panel_open = FALSE
		update_icon()
		C.forceMove(src)
		charge = C
	else if(istype(C, /obj/item/weapon/paper) || istype(C, /obj/item/weapon/photo))
		if(note)
			to_chat(user, "<span class='warning'>There's already something pinned to this airlock! Use wirecutters to remove it.<spa>")
			return
		if(!user.transferItemToLoc(C, src))
			to_chat(user, "<span class='warning'>For some reason, you can't attach [C]!</span>")
			return
		user.visible_message("<span class='notice'>[user] pins [C] to [src].</span>", "<span class='notice'>You pin [C] to [src].</span>")
		note = C
		update_icon()
	else
		return ..()


/obj/machinery/door/airlock/try_to_weld(obj/item/weapon/weldingtool/W, mob/user)
	if(!operating && density)
		if(user.a_intent != INTENT_HELP)
			if(W.remove_fuel(0,user))
				user.visible_message("[user] is [welded ? "unwelding":"welding"] the airlock.", \
								"<span class='notice'>You begin [welded ? "unwelding":"welding"] the airlock...</span>", \
								"<span class='italics'>You hear welding.</span>")
				playsound(loc, W.usesound, 40, 1)
				if(do_after(user,40*W.toolspeed, 1, target = src, extra_checks = CALLBACK(src, .proc/weld_checks, W, user)))
					playsound(loc, 'sound/items/welder2.ogg', 50, 1)
					welded = !welded
					user.visible_message("[user.name] has [welded? "welded shut":"unwelded"] [src].", \
										"<span class='notice'>You [welded ? "weld the airlock shut":"unweld the airlock"].</span>")
					update_icon()
		else
			if(obj_integrity < max_integrity)
				if(W.remove_fuel(0,user))
					user.visible_message("[user] is welding the airlock.", \
									"<span class='notice'>You begin repairing the airlock...</span>", \
									"<span class='italics'>You hear welding.</span>")
					playsound(loc, W.usesound, 40, 1)
					if(do_after(user,40*W.toolspeed, 1, target = src, extra_checks = CALLBACK(src, .proc/weld_checks, W, user)))
						playsound(loc, 'sound/items/welder2.ogg', 50, 1)
						obj_integrity = max_integrity
						stat &= ~BROKEN
						user.visible_message("[user.name] has repaired [src].", \
											"<span class='notice'>You finish repairing the airlock.</span>")
						update_icon()
			else
				to_chat(user, "<span class='notice'>The airlock doesn't need repairing.</span>")

/obj/machinery/door/airlock/proc/weld_checks(obj/item/weapon/weldingtool/W, mob/user)
	return !operating && density && user && W && W.isOn() && user.loc

/obj/machinery/door/airlock/try_to_crowbar(obj/item/I, mob/living/user)
	var/beingcrowbarred = null
	if(istype(I, /obj/item/weapon/crowbar) )
		beingcrowbarred = 1
	else
		beingcrowbarred = 0
	if(panel_open && charge)
		to_chat(user, "<span class='notice'>You carefully start removing [charge] from [src]...</span>")
		playsound(get_turf(src), I.usesound, 50, 1)
		if(!do_after(user, 150*I.toolspeed, target = src))
			to_chat(user, "<span class='warning'>You slip and [charge] detonates!</span>")
			charge.ex_act(EXPLODE_DEVASTATE)
			user.Knockdown(60)
			return
		user.visible_message("<span class='notice'>[user] removes [charge] from [src].</span>", \
							 "<span class='notice'>You gently pry out [charge] from [src] and unhook its wires.</span>")
		charge.forceMove(get_turf(user))
		charge = null
		return
	if( beingcrowbarred && (density && welded && !operating && src.panel_open && (!hasPower()) && !src.locked) )
		playsound(src.loc, I.usesound, 100, 1)
		user.visible_message("[user] removes the electronics from the airlock assembly.", \
							 "<span class='notice'>You start to remove electronics from the airlock assembly...</span>")
		if(do_after(user,40*I.toolspeed, target = src))
			if(src.loc)
				deconstruct(TRUE, user)
				return
	else if(hasPower())
		to_chat(user, "<span class='warning'>The airlock's motors resist your efforts to force it!</span>")
	else if(locked)
		to_chat(user, "<span class='warning'>The airlock's bolts prevent it from being forced!</span>")
	else if( !welded && !operating)
		if(!beingcrowbarred) //being fireaxe'd
			var/obj/item/weapon/twohanded/fireaxe/F = I
			if(F.wielded)
				spawn(0)
					if(density)
						open(2)
					else
						close(2)
			else
				to_chat(user, "<span class='warning'>You need to be wielding the fire axe to do that!</span>")
		else
			spawn(0)
				if(density)
					open(2)
				else
					close(2)

	if(istype(I, /obj/item/weapon/crowbar/power))
		if(isElectrified())
			shock(user,100)//it's like sticking a forck in a power socket
			return

		if(!density)//already open
			return

		if(locked)
			to_chat(user, "<span class='warning'>The bolts are down, it won't budge!</span>")
			return

		if(welded)
			to_chat(user, "<span class='warning'>It's welded, it won't budge!</span>")
			return

		var/time_to_open = 5
		if(hasPower() && !prying_so_hard)
			time_to_open = 50
			playsound(src, 'sound/machines/airlock_alien_prying.ogg',100,1) //is it aliens or just the CE being a dick?
			prying_so_hard = TRUE
			var/result = do_after(user, time_to_open,target = src)
			prying_so_hard = FALSE
			if(result)
				open(2)
				if(density && !open(2))
					to_chat(user, "<span class='warning'>Despite your attempts, the [src] refuses to open.</span>")

/obj/machinery/door/airlock/plasma/attackby(obj/item/C, mob/user, params)
	if(C.is_hot() > 300)//If the temperature of the object is over 300, then ignite
		message_admins("Plasma airlock ignited by [ADMIN_LOOKUPFLW(user)] in [ADMIN_COORDJMP(src)]")
		log_game("Plasma wall ignited by [key_name(user)] in [COORD(src)]")
		ignite(C.is_hot())
	else
		return ..()

/obj/machinery/door/airlock/open(forced=0)
	if( operating || welded || locked )
		return FALSE
	if(!forced)
		if(!hasPower() || wires.is_cut(WIRE_OPEN))
			return FALSE
	if(charge && !detonated)
		panel_open = TRUE
		update_icon(AIRLOCK_OPENING)
		visible_message("<span class='warning'>[src]'s panel is blown off in a spray of deadly shrapnel!</span>")
		charge.loc = get_turf(src)
		charge.ex_act(EXPLODE_DEVASTATE)
		detonated = 1
		charge = null
		for(var/mob/living/carbon/human/H in orange(2,src))
			H.Unconscious(160)
			H.adjust_fire_stacks(20)
			H.IgniteMob() //Guaranteed knockout and ignition for nearby people
			H.apply_damage(40, BRUTE, "chest")
		return
	if(forced < 2)
		if(emagged)
			return FALSE
		use_power(50)
		playsound(src.loc, doorOpen, 30, 1)
		if(src.closeOther != null && istype(src.closeOther, /obj/machinery/door/airlock/) && !src.closeOther.density)
			src.closeOther.close()
	else
		playsound(src.loc, 'sound/machines/airlockforced.ogg', 30, 1)

	if(autoclose && normalspeed)
		addtimer(CALLBACK(src, .proc/autoclose), 150)
	else if(autoclose && !normalspeed)
		addtimer(CALLBACK(src, .proc/autoclose), 15)

	if(!density)
		return TRUE
	operating = TRUE
	update_icon(AIRLOCK_OPENING, 1)
	src.set_opacity(0)
	sleep(5)
	density = FALSE
	sleep(9)
	src.layer = OPEN_DOOR_LAYER
	update_icon(AIRLOCK_OPEN, 1)
	set_opacity(0)
	operating = FALSE
	air_update_turf(1)
	update_freelook_sight()
	if(delayed_close_requested)
		delayed_close_requested = FALSE
		addtimer(CALLBACK(src, .proc/close), 2)
	return TRUE


/obj/machinery/door/airlock/close(forced=0)
	if(operating || welded || locked)
		return
	if(!forced)
		if(!hasPower() || wires.is_cut(WIRE_BOLTS))
			return
	if(safe)
		for(var/atom/movable/M in get_turf(src))
			if(M.density && M != src) //something is blocking the door
				addtimer(CALLBACK(src, .proc/autoclose), 60)
				return

	if(forced < 2)
		if(emagged)
			return
		use_power(50)
		playsound(src.loc, doorClose, 30, 1)
	else
		playsound(src.loc, 'sound/machines/airlockforced.ogg', 30, 1)

	var/obj/structure/window/killthis = (locate(/obj/structure/window) in get_turf(src))
	if(killthis)
		killthis.ex_act(EXPLODE_HEAVY)//Smashin windows

	if(density)
		return TRUE
	operating = TRUE
	update_icon(AIRLOCK_CLOSING, 1)
	src.layer = CLOSED_DOOR_LAYER
	if(air_tight)
		density = TRUE
	sleep(5)
	density = TRUE
	if(!safe)
		crush()
	sleep(9)
	update_icon(AIRLOCK_CLOSED, 1)
	if(visible && !glass)
		set_opacity(1)
	operating = FALSE
	delayed_close_requested = FALSE
	air_update_turf(1)
	update_freelook_sight()
	if(safe)
		CheckForMobs()
	return TRUE

/obj/machinery/door/airlock/proc/prison_open()
	if(emagged)
		return
	locked = FALSE
	src.open()
	locked = TRUE
	return


/obj/machinery/door/airlock/proc/change_paintjob(obj/item/weapon/airlock_painter/W, mob/user)
	if(!W.can_use(user))
		return

	var/list/optionlist
	if(airlock_material == "glass")
		optionlist = list("Public", "Public2", "Engineering", "Atmospherics", "Security", "Command", "Medical", "Research", "Mining", "Maintenance")
	else
		optionlist = list("Public", "Engineering", "Atmospherics", "Security", "Command", "Medical", "Research", "Mining", "Maintenance", "External", "High Security")

	var/paintjob = input(user, "Please select a paintjob for this airlock.") in optionlist
	if((!in_range(src, usr) && src.loc != usr) || !W.use(user))
		return
	switch(paintjob)
		if("Public")
			icon = 'icons/obj/doors/airlocks/station/public.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_0
		if("Public2")
			icon = 'icons/obj/doors/airlocks/station2/glass.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station2/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_glass
		if("Engineering")
			icon = 'icons/obj/doors/airlocks/station/engineering.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_eng
		if("Atmospherics")
			icon = 'icons/obj/doors/airlocks/station/atmos.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_atmo
		if("Security")
			icon = 'icons/obj/doors/airlocks/station/security.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_sec
		if("Command")
			icon = 'icons/obj/doors/airlocks/station/command.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_com
		if("Medical")
			icon = 'icons/obj/doors/airlocks/station/medical.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_med
		if("Research")
			icon = 'icons/obj/doors/airlocks/station/research.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_research
		if("Mining")
			icon = 'icons/obj/doors/airlocks/station/mining.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_min
		if("Maintenance")
			icon = 'icons/obj/doors/airlocks/station/maintenance.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_mai
		if("External")
			icon = 'icons/obj/doors/airlocks/external/external.dmi'
			overlays_file = 'icons/obj/doors/airlocks/external/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_ext
		if("High Security")
			icon = 'icons/obj/doors/airlocks/highsec/highsec.dmi'
			overlays_file = 'icons/obj/doors/airlocks/highsec/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_highsecurity
	update_icon()

/obj/machinery/door/airlock/CanAStarPass(obj/item/weapon/card/id/ID)
//Airlock is passable if it is open (!density), bot has access, and is not bolted shut or powered off)
	return !density || (check_access(ID) && !locked && hasPower())

/obj/machinery/door/airlock/emag_act(mob/user)
	if(!operating && density && hasPower() && !emagged)
		operating = TRUE
		update_icon(AIRLOCK_EMAG, 1)
		sleep(6)
		if(QDELETED(src))
			return
		operating = FALSE
		if(!open())
			update_icon(AIRLOCK_CLOSED, 1)
		emagged = TRUE
		desc = "<span class='warning'>Its access panel is smoking slightly.</span>"
		lights = FALSE
		locked = TRUE
		loseMainPower()
		loseBackupPower()

/obj/machinery/door/airlock/attack_alien(mob/living/carbon/alien/humanoid/user)
	add_fingerprint(user)
	if(isElectrified())
		shock(user, 100) //Mmm, fried xeno!
		return
	if(!density) //Already open
		return
	if(locked || welded) //Extremely generic, as aliens only understand the basics of how airlocks work.
		to_chat(user, "<span class='warning'>[src] refuses to budge!</span>")
		return
	user.visible_message("<span class='warning'>[user] begins prying open [src].</span>",\
						"<span class='noticealien'>You begin digging your claws into [src] with all your might!</span>",\
						"<span class='warning'>You hear groaning metal...</span>")
	var/time_to_open = 5
	if(hasPower())
		time_to_open = 50 //Powered airlocks take longer to open, and are loud.
		playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, 1)


	if(do_after(user, time_to_open, target = src))
		if(density && !open(2)) //The airlock is still closed, but something prevented it opening. (Another player noticed and bolted/welded the airlock in time!)
			to_chat(user, "<span class='warning'>Despite your efforts, [src] managed to resist your attempts to open it!</span>")

/obj/machinery/door/airlock/hostile_lockdown(mob/origin)
	// Must be powered and have working AI wire.
	if(canAIControl(src) && !stat)
		locked = FALSE //For airlocks that were bolted open.
		safe = FALSE //DOOR CRUSH
		close()
		bolt() //Bolt it!
		set_electrified(ELECTRIFIED_PERMANENT)  //Shock it!
		if(origin)
			shockedby += "\[[time_stamp()]\][origin](ckey:[origin.ckey])"


/obj/machinery/door/airlock/disable_lockdown()
	// Must be powered and have working AI wire.
	if(canAIControl(src) && !stat)
		unbolt()
		set_electrified(NOT_ELECTRIFIED)
		open()
		safe = TRUE


/obj/machinery/door/airlock/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(flags & NODECONSTRUCT))
		stat |= BROKEN
		if(!panel_open)
			panel_open = TRUE
		wires.cut_all()
		update_icon()

/obj/machinery/door/airlock/proc/set_electrified(seconds)
	secondsElectrified = seconds
	diag_hud_set_electrified()

/obj/machinery/door/airlock/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(obj_integrity < (0.75 * max_integrity))
		update_icon()


/obj/machinery/door/airlock/deconstruct(disassembled = TRUE, mob/user)
	if(!(flags & NODECONSTRUCT))
		var/obj/structure/door_assembly/A
		if(assemblytype)
			A = new assemblytype(src.loc)
			A.heat_proof_finished = src.heat_proof //tracks whether there's rglass in
		else
			A = new /obj/structure/door_assembly/door_assembly_0(src.loc)
			//If you come across a null assemblytype, it will produce the default assembly instead of disintegrating.
		A.created_name = name

		if(!disassembled)
			if(A)
				A.obj_integrity = A.max_integrity * 0.5
		else if(emagged)
			if(user)
				to_chat(user, "<span class='warning'>You discard the damaged electronics.</span>")
		else
			if(user)
				to_chat(user, "<span class='notice'>You remove the airlock electronics.</span>")

			var/obj/item/weapon/electronics/airlock/ae
			if(!electronics)
				ae = new/obj/item/weapon/electronics/airlock( src.loc )
				gen_access()
				if(req_one_access.len)
					ae.one_access = 1
					ae.accesses = src.req_one_access
				else
					ae.accesses = src.req_access
			else
				ae = electronics
				electronics = null
				ae.loc = src.loc
	qdel(src)

/obj/machinery/door/airlock/rcd_vals(mob/user, obj/item/weapon/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 50, "cost" = 32)
	return FALSE

/obj/machinery/door/airlock/rcd_act(mob/user, obj/item/weapon/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_DECONSTRUCT)
			to_chat(user, "<span class='notice'>You deconstruct the airlock.</span>")
			qdel(src)
			return TRUE
	return FALSE

/obj/machinery/door/airlock/proc/note_type() //Returns a string representing the type of note pinned to this airlock
	if(!note)
		return
	else if(istype(note, /obj/item/weapon/paper))
		return "note"
	else if(istype(note, /obj/item/weapon/photo))
		return "photo"

#undef AIRLOCK_CLOSED
#undef AIRLOCK_CLOSING
#undef AIRLOCK_OPEN
#undef AIRLOCK_OPENING
#undef AIRLOCK_DENY
#undef AIRLOCK_EMAG

#undef AIRLOCK_SECURITY_NONE
#undef AIRLOCK_SECURITY_METAL
#undef AIRLOCK_SECURITY_PLASTEEL_I_S
#undef AIRLOCK_SECURITY_PLASTEEL_I
#undef AIRLOCK_SECURITY_PLASTEEL_O_S
#undef AIRLOCK_SECURITY_PLASTEEL_O
#undef AIRLOCK_SECURITY_PLASTEEL

#undef AIRLOCK_INTEGRITY_N
#undef AIRLOCK_INTEGRITY_MULTIPLIER
#undef AIRLOCK_DAMAGE_DEFLECTION_N
#undef AIRLOCK_DAMAGE_DEFLECTION_R

#undef NOT_ELECTRIFIED
#undef ELECTRIFIED_PERMANENT
