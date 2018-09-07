//Helper proc to get an Eminence mob if it exists
/proc/get_eminence()
	return locate(/mob/camera/eminence) in servants_and_ghosts()

//The Eminence is a unique mob that functions like the leader of the cult. It's incorporeal but can interact with the world in several ways.
/mob/camera/eminence
	name = "\the Emininence"
	real_name = "\the Eminence"
	desc = "The leader-elect of the servants of Ratvar."
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "eminence"
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	move_on_shuttle = TRUE
	see_in_dark = 8
	invisibility = INVISIBILITY_OBSERVER
	layer = FLY_LAYER
	faction = list("ratvar")
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	var/turf/last_failed_turf
	var/static/superheated_walls = 0
	var/lastWarning = 0

/mob/camera/eminence/CanPass(atom/movable/mover, turf/target)
	return TRUE

/mob/camera/eminence/Move(NewLoc, direct)
	var/OldLoc = loc
	if(NewLoc && !istype(NewLoc, /turf/open/indestructible/reebe_void))
		var/turf/T = get_turf(NewLoc)
		if(!GLOB.ratvar_awakens)
			if(locate(/obj/effect/blessing, T))
				if(last_failed_turf != T)
					T.visible_message("<span class='warning'>[T] suddenly emits a ringing sound!</span>", null, null, null, src)
					playsound(T, 'sound/machines/clockcult/ark_damage.ogg', 75, FALSE)
					last_failed_turf = T
				if((world.time - lastWarning) >= 30)
					lastWarning = world.time
					to_chat(src, "<span class='warning'>This turf is consecrated and can't be crossed!</span>")
				return
			if(istype(get_area(T), /area/chapel))
				if((world.time - lastWarning) >= 30)
					lastWarning = world.time
					to_chat(src, "<span class='warning'>The Chapel is hallowed ground under a heretical deity, and can't be accessed!</span>")
				return
		else
			for(var/turf/TT in range(5, src))
				if(prob(166 - (get_dist(src, TT) * 33)))
					TT.ratvar_act() //Causes moving to leave a swath of proselytized area behind the Eminence
		forceMove(T)
		Moved(OldLoc, direct)

/mob/camera/eminence/Process_Spacemove(movement_dir = 0)
	return TRUE

/mob/camera/eminence/Login()
	..()
	add_servant_of_ratvar(src, TRUE)
	var/datum/antagonist/clockcult/C = mind.has_antag_datum(/datum/antagonist/clockcult,TRUE)
	if(C && C.clock_team)
		if(C.clock_team.eminence && C.clock_team.eminence != src)
			remove_servant_of_ratvar(src,TRUE)
			qdel(src)
			return
		else
			C.clock_team.eminence = src
	to_chat(src, "<span class='bold large_brass'>You have been selected as the Eminence!</span>")
	to_chat(src, "<span class='brass'>As the Eminence, you lead the servants. Anything you say will be heard by the entire cult.</span>")
	to_chat(src, "<span class='brass'>Though you can move through walls, you're also incorporeal, and largely can't interact with the world except for a few ways.</span>")
	to_chat(src, "<span class='brass'>Additionally, unless the herald's beacon is activated, you can't understand any speech while away from Reebe.</span>")
	eminence_help()
	for(var/V in actions)
		var/datum/action/A = V
		A.Remove(src) //So we get rid of duplicate actions; this also removes Hierophant network, since our say() goes across it anyway
	var/datum/action/innate/eminence/E
	for(var/V in subtypesof(/datum/action/innate/eminence))
		E = new V
		E.Grant(src)

/mob/camera/eminence/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if(client.handle_spam_prevention(message,MUTE_IC))
			return
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!message)
		return
	src.log_talk(message, LOG_SAY, tag="clockwork eminence")
	if(GLOB.ratvar_awakens)
		visible_message("<span class='brass'><b>You feel light slam into your mind and form words:</b> \"[capitalize(message)]\"</span>")
		playsound(src, 'sound/machines/clockcult/ark_scream.ogg', 50, FALSE)
	message = "<span class='big brass'><b>The [GLOB.ratvar_awakens ? "Radiance" : "Eminence"]:</b> \"[message]\"</span>"
	for(var/mob/M in servants_and_ghosts())
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [message]")
		else
			to_chat(M, message)

/mob/camera/eminence/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode)
	. = ..()
	if(is_reebe(z) || is_servant_of_ratvar(speaker) || GLOB.ratvar_approaches || GLOB.ratvar_awakens) //Away from Reebe, the Eminence can't hear anything
		to_chat(src, message)
		return
	to_chat(src, "<i>[speaker] says something, but you can't understand any of it...</i>")

/mob/camera/eminence/ClickOn(atom/A, params)
	var/list/modifiers = params2list(params)
	if(modifiers["shift"])
		A.examine(src)
		return
	if(modifiers["alt"] && istype(A, /turf/closed/wall/clockwork))
		superheat_wall(A)
		return
	if(modifiers["middle"] || modifiers["ctrl"])
		issue_command(A)
		return
	if(GLOB.ark_of_the_clockwork_justiciar == A)
		var/obj/structure/destructible/clockwork/massive/celestial_gateway/G = GLOB.ark_of_the_clockwork_justiciar
		if(G.recalling)
			return
		if(!G.recalls_remaining)
			to_chat(src, "<span class='warning'>The Ark can no longer recall!</span>")
			return
		if(alert(src, "Initiate mass recall?", "Mass Recall", "Yes", "No") != "Yes" || QDELETED(src) || QDELETED(G) || !G.obj_integrity)
			return
		G.initiate_mass_recall() //wHOOPS LOOKS LIKE A HULK GOT THROUGH
	else if(istype(A, /obj/structure/destructible/clockwork/trap/trigger))
		var/obj/structure/destructible/clockwork/trap/trigger/T = A
		T.visible_message("<span class='danger'>[T] clunks as it's activated remotely.</span>")
		to_chat(src, "<span class='brass'>You activate [T].</span>")
		T.activate()

/mob/camera/eminence/ratvar_act()
	name = "\improper Radiance"
	real_name = "\improper Radiance"
	desc = "The light, forgotten."
	transform = matrix() * 2
	invisibility = SEE_INVISIBLE_MINIMUM

/mob/camera/eminence/proc/issue_command(atom/movable/A)
	var/list/commands
	var/atom/movable/command_location
	if(A == src)
		commands = list("Defend the Ark!", "Advance!", "Retreat!", "Generate Power", "Build Defenses (Bottom-Up)", "Build Defenses (Top-Down)")
	else
		command_location = A
		commands = list("Rally Here", "Regroup Here", "Avoid This Area", "Reinforce This Area")
		if(istype(A, /obj/structure/destructible/clockwork/powered))
			var/obj/structure/destructible/clockwork/powered/P = A
			if(!can_access_clockwork_power(P))
				commands += "Power This Structure"
			if(P.obj_integrity < P.max_integrity)
				commands += "Repair This Structure"
	var/roma_invicta = input(src, "Choose a command to issue to your cult!", "Issue Commands") as null|anything in commands
	if(!roma_invicta)
		return
	var/command_text = ""
	var/marker_icon
	switch(roma_invicta)
		if("Rally Here")
			command_text = "The Eminence orders an offensive rally at [command_location] to the GETDIR!"
			marker_icon = "eminence_rally"
		if("Regroup Here")
			command_text = "The Eminence orders a regroup to [command_location] to the GETDIR!"
			marker_icon = "eminence_rally"
		if("Avoid This Area")
			command_text = "The Eminence has designated the area to your GETDIR as dangerous and to be avoided!"
			marker_icon = "eminence_avoid"
		if("Reinforce This Area")
			command_text = "The Eminence orders the defense and fortification of the area to your GETDIR!"
			marker_icon = "eminence_reinforce"
		if("Power This Structure")
			command_text = "[command_location] to your GETDIR has no power! Turn it on and make sure there's a sigil of transmission nearby!"
			marker_icon = "eminence_unlimited_power"
		if("Repair This Structure")
			command_text = "The Eminence orders that [command_location] to your GETDIR should be repaired ASAP!"
			marker_icon = "eminence_repair"
		if("Defend the Ark!")
			command_text = "The Eminence orders immediate defense of the Ark!"
		if("Advance!")
			command_text = "The Eminence commands you push forward!"
		if("Retreat!")
			command_text = "The Eminence has sounded the retreat! Fall back!"
		if("Generate Power")
			command_text = "The Eminence orders more power! Build power generations on the station!"
		if("Build Defenses (Bottom-Up)")
			command_text = "The Eminence orders that defenses should be built starting from the bottom of Reebe!"
		if("Build Defenses (Top-Down)")
			command_text = "The Eminence orders that defenses should be built starting from the top of Reebe!"
	if(marker_icon)
		new/obj/effect/temp_visual/ratvar/command_point(get_turf(A), marker_icon)
		for(var/mob/M in servants_and_ghosts())
			to_chat(M, "<span class='large_brass'>[replacetext(command_text, "GETDIR", dir2text(get_dir(M, command_location)))]</span>")
			M.playsound_local(M, 'sound/machines/clockcult/eminence_command.ogg', 75, FALSE, pressure_affected = FALSE)
	else
		hierophant_message("<span class='bold large_brass'>[command_text]</span>")
		for(var/mob/M in servants_and_ghosts())
			M.playsound_local(M, 'sound/machines/clockcult/eminence_command.ogg', 75, FALSE, pressure_affected = FALSE)

/mob/camera/eminence/proc/superheat_wall(turf/closed/wall/clockwork/wall)
	if(!istype(wall))
		return
	if(superheated_walls >= SUPERHEATED_CLOCKWORK_WALL_LIMIT && !wall.heated)
		to_chat(src, "<span class='warning'>You're exerting all of your power superheating this many walls already! Cool some down first!</span>")
		return
	wall.turn_up_the_heat()
	if(wall.heated)
		superheated_walls++
		to_chat(src, "<span class='neovgre_small'>You superheat [wall]. <b>Superheated walls:</b> [superheated_walls]/[SUPERHEATED_CLOCKWORK_WALL_LIMIT]")
	else
		superheated_walls--
		to_chat(src, "<span class='neovgre_small'>You cool [wall]. <b>Superheated walls:</b> [superheated_walls]/[SUPERHEATED_CLOCKWORK_WALL_LIMIT]")

/mob/camera/eminence/proc/eminence_help()
	to_chat(src, "<span class='bold alloy'>You can make use of certain shortcuts to perform different actions:</span>")
	to_chat(src, "<span class='alloy'><b>Alt-Click a clockwork wall</b> to superheat or cool it down. \
	Superheated walls can't be destroyed by hulks or mechs and are much slower to deconstruct, and are marked by a bright red glow. \
	This lasts indefinitely, but only [SUPERHEATED_CLOCKWORK_WALL_LIMIT] clockwork walls can be superheated at once.</span>")
	to_chat(src, "<span class='alloy'><b>Interact with the Ark</b> to initiate an emergency recall that teleports all servants directly to its location after a short delay. \
	This can only be used a single time, or twice if the herald's beacon was activated,</span>")
	to_chat(src, "<span class='alloy'><b>Middle or Ctrl-Click anywhere</b> to allow you to issue a variety of contextual commands to your cult. Different objects allow for different \
	commands. <i>Doing this on yourself will provide commands that tell the entire cult a goal.</i></span>")


//Eminence actions below this point
/datum/action/innate/eminence
	name = "Eminence Action"
	desc = "You shouldn't see this. File a bug report!"
	icon_icon = 'icons/mob/actions/actions_clockcult.dmi'
	background_icon_state = "bg_clock"
	buttontooltipstyle = "clockcult"

/datum/action/innate/eminence/IsAvailable()
	if(!iseminence(owner))
		qdel(src)
		return
	return ..()

//Lists available powers
/datum/action/innate/eminence/power_list
	name = "Eminence Powers"
	desc = "Forgot what you can do? This refreshes you on your powers as Eminence."
	button_icon_state = "eminence_rally"

/datum/action/innate/eminence/power_list/Activate()
	var/mob/camera/eminence/E = owner
	E.eminence_help()

//Returns to the Ark
/datum/action/innate/eminence/ark_jump
	name = "Return to Ark"
	desc = "Warps you to the Ark."
	button_icon_state = "Abscond"

/datum/action/innate/eminence/ark_jump/Activate()
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/G = GLOB.ark_of_the_clockwork_justiciar
	if(G)
		owner.forceMove(get_turf(G))
		owner.playsound_local(owner, 'sound/magic/magic_missile.ogg', 50, TRUE)
		flash_color(owner, flash_color = "#AF0AAF", flash_time = 25)
	else
		to_chat(owner, "<span class='warning'>There is no Ark!</span>")

//Warps to the Station
/datum/action/innate/eminence/station_jump
	name = "Warp to Station"
	desc = "Warps to Space Station 13. You cannot hear anything while there!</span>"
	button_icon_state = "warp_down"

/datum/action/innate/eminence/station_jump/Activate()
	if(is_reebe(owner.z))
		owner.forceMove(get_turf(pick(GLOB.generic_event_spawns)))
		owner.playsound_local(owner, 'sound/magic/magic_missile.ogg', 50, TRUE)
		flash_color(owner, flash_color = "#AF0AAF", flash_time = 25)
	else
		to_chat(owner, "<span class='warning'>You're already on the station!</span>")

//A quick-use button for recalling the servants to the Ark
/datum/action/innate/eminence/mass_recall
	name = "Mass Recall"
	desc = "Initiates a mass recall, warping all servants to the Ark after a short delay. This can only be used once."
	button_icon_state = "Spatial Gateway"

/datum/action/innate/eminence/mass_recall/IsAvailable()
	. = ..()
	if(.)
		var/obj/structure/destructible/clockwork/massive/celestial_gateway/G = GLOB.ark_of_the_clockwork_justiciar
		if(G)
			return G.recalls_remaining && !G.recalling
		return FALSE

/datum/action/innate/eminence/mass_recall/Activate()
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/G = GLOB.ark_of_the_clockwork_justiciar
	if(G && !G.recalling && G.recalls_remaining)
		if(alert(owner, "Initiate mass recall?", "Mass Recall", "Yes", "No") != "Yes" || QDELETED(owner) || QDELETED(G) || !G.obj_integrity)
			return
		G.initiate_mass_recall()
