#define WHITE_TEAM "White"
#define RED_TEAM "Red"
#define BLUE_TEAM "Blue"
#define GREEN_TEAM "Green"
#define YELLOW_TEAM "Yellow"
#define FLAG_RETURN_TIME 200 // 20 seconds
#define INSTAGIB_RESPAWN 50 //5 seconds
#define DEFAULT_RESPAWN 150 //15 seconds

/obj/item/ctf
	name = "banner"
	icon = 'icons/obj/banner.dmi'
	icon_state = "banner"
	inhand_icon_state = "banner"
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	desc = "A banner with Nanotrasen's logo on it."
	slowdown = 2
	throw_speed = 0
	throw_range = 1
	force = 200
	armour_penetration = 1000
	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE
	item_flags = SLOWS_WHILE_IN_HAND
	var/team = WHITE_TEAM
	var/reset_cooldown = 0
	var/anyonecanpickup = TRUE
	var/obj/effect/ctf/flag_reset/reset
	var/reset_path = /obj/effect/ctf/flag_reset
	/// Which area we announce updates on the flag to. Should just generally be the area of the arena.
	var/game_area = /area/centcom/ctf

/obj/item/ctf/Destroy()
	QDEL_NULL(reset)
	return ..()

/obj/item/ctf/Initialize(mapload)
	. = ..()
	if(!reset)
		reset = new reset_path(get_turf(src))
		reset.flag = src
	RegisterSignal(src, COMSIG_PARENT_PREQDELETED, PROC_REF(reset_flag)) //just in case CTF has some map hazards (read: chasms).

/obj/item/ctf/process()
	if(is_ctf_target(loc)) //pickup code calls temporary drops to test things out, we need to make sure the flag doesn't reset from
		return PROCESS_KILL
	if(world.time > reset_cooldown)
		reset_flag()

/obj/item/ctf/proc/reset_flag(capture = FALSE)
	SIGNAL_HANDLER
	STOP_PROCESSING(SSobj, src)

	var/turf/our_turf = get_turf(src.reset)
	if(!our_turf)
		return TRUE
	forceMove(our_turf)
	for(var/mob/M in GLOB.player_list)
		var/area/mob_area = get_area(M)
		if(istype(mob_area, game_area))
			if(!capture)
				to_chat(M, span_userdanger("[src] has been returned to the base!"))
	return TRUE //so if called by a signal, it doesn't delete

//working with attack hand feels like taking my brain and putting it through an industrial pill press so i'm gonna be a bit liberal with the comments
/obj/item/ctf/attack_hand(mob/living/user, list/modifiers)
	//pre normal check item stuff, this is for our special flag checks
	if(!is_ctf_target(user) && !anyonecanpickup)
		to_chat(user, span_warning("Non-players shouldn't be moving the flag!"))
		return
	if(team in user.faction)
		to_chat(user, span_warning("You can't move your own flag!"))
		return
	if(loc == user)
		if(!user.dropItemToGround(src))
			return
	for(var/mob/M in GLOB.player_list)
		var/area/mob_area = get_area(M)
		if(istype(mob_area, game_area))
			to_chat(M, span_userdanger("\The [initial(src.name)] has been taken!"))
	STOP_PROCESSING(SSobj, src)
	anchored = FALSE // Hacky usage that bypasses set_anchored(), because normal checks need this to be FALSE to pass
	. = ..() //this is the actual normal item checks
	if(.) //only apply these flag passives
		anchored = TRUE // Avoid directly assigning to anchored and prefer to use set_anchored() on normal circumstances.
		return
	//passing means the user picked up the flag so we can now apply this
	user.set_anchored(TRUE)
	user.status_flags &= ~CANPUSH

/obj/item/ctf/dropped(mob/user)
	..()
	user.anchored = FALSE // Hacky usage that bypasses set_anchored()
	user.status_flags |= CANPUSH
	reset_cooldown = world.time + 20 SECONDS
	START_PROCESSING(SSobj, src)
	for(var/mob/M in GLOB.player_list)
		var/area/mob_area = get_area(M)
		if(istype(mob_area, game_area))
			to_chat(M, span_userdanger("\The [initial(name)] has been dropped!"))
	anchored = TRUE // Avoid directly assigning to anchored and prefer to use set_anchored() on normal circumstances.


/obj/item/ctf/red
	name = "red flag"
	icon_state = "banner-red"
	inhand_icon_state = "banner-red"
	desc = "A red banner used to play capture the flag."
	team = RED_TEAM
	reset_path = /obj/effect/ctf/flag_reset/red


/obj/item/ctf/blue
	name = "blue flag"
	icon_state = "banner-blue"
	inhand_icon_state = "banner-blue"
	desc = "A blue banner used to play capture the flag."
	team = BLUE_TEAM
	reset_path = /obj/effect/ctf/flag_reset/blue

/obj/item/ctf/green
	name = "green flag"
	icon_state = "banner-green"
	inhand_icon_state = "banner-green"
	desc = "A green banner used to play capture the flag."
	team = GREEN_TEAM
	reset_path = /obj/effect/ctf/flag_reset/green


/obj/item/ctf/yellow
	name = "yellow flag"
	icon_state = "banner-yellow"
	inhand_icon_state = "banner-yellow"
	desc = "A yellow banner used to play capture the flag."
	team = YELLOW_TEAM
	reset_path = /obj/effect/ctf/flag_reset/yellow

/obj/effect/ctf/flag_reset
	name = "banner landmark"
	icon = 'icons/obj/banner.dmi'
	icon_state = "banner"
	desc = "This is where a banner with Nanotrasen's logo on it would go."
	layer = LOW_ITEM_LAYER
	var/obj/item/ctf/flag

/obj/effect/ctf/flag_reset/Destroy()
	if(flag)
		flag.reset = null
		flag = null
	return ..()

/obj/effect/ctf/flag_reset/red
	name = "red flag landmark"
	icon_state = "banner-red"
	desc = "This is where a red banner used to play capture the flag \
		would go."

/obj/effect/ctf/flag_reset/blue
	name = "blue flag landmark"
	icon_state = "banner-blue"
	desc = "This is where a blue banner used to play capture the flag \
		would go."

/obj/effect/ctf/flag_reset/green
	name = "green flag landmark"
	icon_state = "banner"
	desc = "This is where a green banner used to play capture the flag \
		would go."

/obj/effect/ctf/flag_reset/yellow
	name = "yellow flag landmark"
	icon_state = "banner"
	desc = "This is where a yellow banner used to play capture the flag \
		would go."

#define CTF_LOADING_UNLOADED 0
#define CTF_LOADING_LOADING 1
#define CTF_LOADING_LOADED 2

/proc/toggle_id_ctf(user, activated_id, automated = FALSE, unload = FALSE)
	var/static/loading = CTF_LOADING_UNLOADED
	if(unload == TRUE)
		log_admin("[key_name_admin(user)] is attempting to unload CTF.")
		message_admins("[key_name_admin(user)] is attempting to unload CTF.")
		if(loading == CTF_LOADING_UNLOADED)
			to_chat(user, span_warning("CTF cannot be unloaded if it was not loaded in the first place"))
			return
		to_chat(user, span_warning("CTF is being unloaded"))
		for(var/obj/machinery/capture_the_flag/CTF as anything in GLOB.ctf_panel.ctf_machines)
			CTF.unload()
		log_admin("[key_name_admin(user)] has unloaded CTF.")
		message_admins("[key_name_admin(user)] has unloaded CTF.")
		loading = CTF_LOADING_UNLOADED
		return
	switch (loading)
		if (CTF_LOADING_UNLOADED)
			if (isnull(GLOB.ctf_spawner))
				to_chat(user, span_boldwarning("Couldn't find a CTF spawner. Call a maintainer!"))
				return

			to_chat(user, span_notice("Loading CTF..."))

			loading = CTF_LOADING_LOADING
			if(!GLOB.ctf_spawner.load_map(user))
				to_chat(user, span_warning("CTF loading was cancelled"))
				loading = CTF_LOADING_UNLOADED
				return
			loading = CTF_LOADING_LOADED
		if (CTF_LOADING_LOADING)
			to_chat(user, span_warning("CTF is loading!"))

			return

	var/ctf_enabled = FALSE
	var/area/A
	for(var/obj/machinery/capture_the_flag/CTF as anything in GLOB.ctf_panel.ctf_machines)
		if(activated_id != CTF.game_id)
			continue
		ctf_enabled = CTF.toggle_ctf()
		A = get_area(CTF)
	for(var/obj/machinery/power/emitter/E in A)
		E.active = ctf_enabled
	if(user)
		message_admins("[key_name_admin(user)] has [ctf_enabled ? "enabled" : "disabled"] CTF!")
	else if(automated)
		message_admins("CTF has finished a round and automatically restarted.")
		notify_ghosts("CTF has automatically restarted after a round finished in [A]!",'sound/effects/ghost2.ogg')
	else
		message_admins("The players have spoken! Voting has enabled CTF!")
	if(!automated)
		notify_ghosts("CTF has been [ctf_enabled? "enabled" : "disabled"] in [A]!",'sound/effects/ghost2.ogg')

#undef CTF_LOADING_UNLOADED
#undef CTF_LOADING_LOADING
#undef CTF_LOADING_LOADED

/obj/machinery/capture_the_flag
	name = "CTF Controller"
	desc = "Used for running friendly games of capture the flag."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"
	density = TRUE
	resistance_flags = INDESTRUCTIBLE
	var/game_id = CTF_GHOST_CTF_GAME_ID

	var/victory_rejoin_text = "<span class='userdanger'>Teams have been cleared. Click on the machines to vote to begin another round.</span>"
	var/team = WHITE_TEAM
	var/team_span = ""
	//Capture the Flag scoring
	var/points = 0
	var/points_to_win = 3
	var/respawn_cooldown = DEFAULT_RESPAWN
	//Capture Point/King of the Hill scoring
	var/control_points = 0
	var/control_points_to_win = 180
	var/list/team_members = list()
	///assoc list: mob = outfit datum (class)
	var/list/spawned_mobs = list()
	var/list/recently_dead_ckeys = list()
	var/ctf_enabled = FALSE
	///assoc list for classes. If there's only one, it'll just equip. Otherwise, it lets you pick which outfit!
	var/list/ctf_gear = list("Rifleman" = /datum/outfit/ctf, "Assaulter" = /datum/outfit/ctf/assault, "Marksman" = /datum/outfit/ctf/marksman)
	var/list/instagib_gear = list("Instagib" = /datum/outfit/ctf/instagib)
	var/list/default_gear
	var/ammo_type = /obj/effect/powerup/ammo/ctf
	// Fast paced gameplay, no real time for burn infections.
	var/player_traits = list(TRAIT_NEVER_WOUNDED)

	var/list/dead_barricades = list()

	var/static/arena_reset = FALSE
	var/game_area = /area/centcom/ctf

	/// This variable is needed because of ctf shitcode + we need to make sure we're deleting the current ctf landmark that spawned us in and not a new one.
	var/obj/effect/landmark/ctf/ctf_landmark

/obj/machinery/capture_the_flag/Initialize(mapload)
	. = ..()
	GLOB.ctf_panel.ctf_machines += src
	SSpoints_of_interest.make_point_of_interest(src)
	default_gear = ctf_gear
	ctf_landmark = GLOB.ctf_spawner

/obj/machinery/capture_the_flag/Destroy()
	ctf_landmark = null
	GLOB.ctf_panel.ctf_machines -= src
	return ..()

/obj/machinery/capture_the_flag/process(delta_time)
	for(var/i in spawned_mobs)
		if(!i)
			spawned_mobs -= i
			continue
		// Anyone in crit, automatically reap
		var/mob/living/living_participant = i
		if(HAS_TRAIT(living_participant, TRAIT_CRITICAL_CONDITION) || living_participant.stat == DEAD || !living_participant.client) // If they're critted, dead or no longer in their body, dust them
			ctf_dust_old(living_participant)
		else
			// The changes that you've been hit with no shield but not
			// instantly critted are low, but have some healing.
			living_participant.adjustBruteLoss(-2.5 * delta_time)
			living_participant.adjustFireLoss(-2.5 * delta_time)

/obj/machinery/capture_the_flag/red
	name = "Red CTF Controller"
	icon_state = "syndbeacon"
	team = RED_TEAM
	team_span = "redteamradio"
	ctf_gear = list("Rifleman" = /datum/outfit/ctf/red, "Assaulter" = /datum/outfit/ctf/assault/red, "Marksman" = /datum/outfit/ctf/marksman/red)
	instagib_gear = list("Instagib" = /datum/outfit/ctf/red/instagib)

/obj/machinery/capture_the_flag/blue
	name = "Blue CTF Controller"
	icon_state = "bluebeacon"
	team = BLUE_TEAM
	team_span = "blueteamradio"
	ctf_gear = list("Rifleman" = /datum/outfit/ctf/blue, "Assaulter" = /datum/outfit/ctf/assault/blue, "Marksman" = /datum/outfit/ctf/marksman/blue)
	instagib_gear = list("Instagib" = /datum/outfit/ctf/blue/instagib)

/obj/machinery/capture_the_flag/green
	name = "Green CTF Controller"
	icon_state = "greenbeacon"
	team = GREEN_TEAM
	team_span = "greenteamradio"
	ctf_gear = list("Rifleman" = /datum/outfit/ctf/green, "Assaulter" = /datum/outfit/ctf/assault/green, "Marksman" = /datum/outfit/ctf/marksman/green)
	instagib_gear = list("Instagib" = /datum/outfit/ctf/green/instagib)

/obj/machinery/capture_the_flag/yellow
	name = "Yellow CTF Controller"
	icon_state = "yellowbeacon"
	team = YELLOW_TEAM
	team_span = "yellowteamradio"
	ctf_gear = list("Rifleman" = /datum/outfit/ctf/yellow, "Assaulter" = /datum/outfit/ctf/assault/yellow, "Marksman" = /datum/outfit/ctf/marksman/yellow)
	instagib_gear = list("Instagib" = /datum/outfit/ctf/yellow/instagib)

//ATTACK GHOST IGNORING PARENT RETURN VALUE
/obj/machinery/capture_the_flag/attack_ghost(mob/user)
	if(ctf_enabled == FALSE)
		if(user.client && user.client.holder)
			var/response = tgui_alert(usr,"Enable this CTF game?", "CTF", list("Yes", "No"))
			if(response == "Yes")
				toggle_id_ctf(user, game_id)
			return


		if(!(GLOB.ghost_role_flags & GHOSTROLE_MINIGAME))
			to_chat(user, span_warning("CTF has been temporarily disabled by admins."))
			return
		for(var/obj/machinery/capture_the_flag/CTF as anything in GLOB.ctf_panel.ctf_machines)
			if(CTF.game_id != game_id && CTF.ctf_enabled)
				to_chat(user, span_warning("There is already an ongoing game in the [get_area(CTF)]!"))
				return
		get_ctf_voting_controller(game_id).vote(user)
		return

	if(!SSticker.HasRoundStarted())
		return
	if(user.ckey in team_members)
		if(user.ckey in recently_dead_ckeys)
			to_chat(user, span_warning("It must be more than [DisplayTimeText(respawn_cooldown)] from your last death to respawn!"))
			return
		var/client/new_team_member = user.client
		if(user.mind && user.mind.current)
			ctf_dust_old(user.mind.current)
		spawn_team_member(new_team_member)
		return

	for(var/obj/machinery/capture_the_flag/CTF as anything in GLOB.ctf_panel.ctf_machines)
		if(CTF.game_id != game_id || CTF == src || CTF.ctf_enabled == FALSE)
			continue
		if(user.ckey in CTF.team_members)
			to_chat(user, span_warning("No switching teams while the round is going!"))
			return
		if(CTF.team_members.len < src.team_members.len)
			to_chat(user, span_warning("[src.team] has more team members than [CTF.team]! Try joining [CTF.team] team to even things up."))
			return

	var/client/new_team_member = user.client
	team_members |= new_team_member.ckey
	to_chat(user, "<span class='userdanger'>You are now a member of [src.team]. Get the enemy flag and bring it back to your team's controller!</span>")
	spawn_team_member(new_team_member)


//does not add to recently dead, because it dusts and that triggers ctf_qdelled_player
/obj/machinery/capture_the_flag/proc/ctf_dust_old(mob/living/body)
	if(isliving(body) && (team in body.faction))
		var/turf/T = get_turf(body)
		if(ammo_type)
			new ammo_type(T)
		body.dust()

/obj/machinery/capture_the_flag/proc/ctf_qdelled_player(mob/living/body)
	SIGNAL_HANDLER

	recently_dead_ckeys += body.ckey
	spawned_mobs -= body
	addtimer(CALLBACK(src, PROC_REF(clear_cooldown), body.ckey), respawn_cooldown, TIMER_UNIQUE)

/obj/machinery/capture_the_flag/proc/clear_cooldown(ckey)
	recently_dead_ckeys -= ckey

/obj/machinery/capture_the_flag/proc/spawn_team_member(client/new_team_member)
	var/datum/outfit/chosen_class

	if(ctf_gear.len == 1) //no choices to make
		for(var/key in ctf_gear)
			chosen_class = ctf_gear[key]

	else //there's a choice to make, present a radial menu
		var/list/display_classes = list()

		for(var/key in ctf_gear)
			var/datum/outfit/ctf/class = ctf_gear[key]
			var/datum/radial_menu_choice/option = new
			option.image  = image(icon = initial(class.icon), icon_state = initial(class.icon_state))
			option.info = "<span class='boldnotice'>[initial(class.class_description)]</span>"
			display_classes[key] = option

		sort_list(display_classes)
		var/choice = show_radial_menu(new_team_member.mob, src, display_classes, radius = 38)
		if(!choice || !(GLOB.ghost_role_flags & GHOSTROLE_MINIGAME) || (new_team_member.ckey in recently_dead_ckeys) || !isobserver(new_team_member.mob) || src.ctf_enabled == FALSE || !(new_team_member.ckey in src.team_members))
			return //picked nothing, admin disabled it, cheating to respawn faster, cheating to respawn... while in game?,
				   //there isn't a game going on any more, you are no longer a member of this team (perhaps a new match already started?)
		chosen_class = ctf_gear[choice]

	var/turf/spawn_point = pick(get_adjacent_open_turfs(get_turf(src)))
	var/mob/living/carbon/human/M = new /mob/living/carbon/human(spawn_point)
	new_team_member.prefs.safe_transfer_prefs_to(M, is_antag = TRUE)
	if(M.dna.species.outfit_important_for_life)
		M.set_species(/datum/species/human)
	M.key = new_team_member.key
	M.faction += team
	M.equipOutfit(chosen_class)
	RegisterSignal(M, COMSIG_PARENT_QDELETING, PROC_REF(ctf_qdelled_player)) //just in case CTF has some map hazards (read: chasms). bit shorter than dust
	for(var/trait in player_traits)
		ADD_TRAIT(M, trait, CAPTURE_THE_FLAG_TRAIT)
	spawned_mobs[M] = chosen_class
	return M //used in medisim.dm

/obj/machinery/capture_the_flag/Topic(href, href_list)
	if(href_list["join"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			attack_ghost(ghost)

/obj/machinery/capture_the_flag/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ctf))
		var/obj/item/ctf/flag = I
		if(flag.team != src.team)
			points++
			flag.reset_flag(capture = TRUE)
			for(var/mob/ctf_player in GLOB.player_list)
				var/area/mob_area = get_area(ctf_player)
				if(istype(mob_area, game_area))
					to_chat(ctf_player, "<span class='userdanger [team_span]'>[user.real_name] has captured \the [flag], scoring a point for [team] team! They now have [points]/[points_to_win] points!</span>")
			if(points >= points_to_win)
				victory()

/obj/machinery/capture_the_flag/proc/victory()
	for(var/mob/_competitor in GLOB.mob_living_list)
		var/mob/living/competitor = _competitor
		var/area/mob_area = get_area(competitor)
		if(istype(mob_area, game_area))
			to_chat(competitor, "<span class='narsie [team_span]'>[team] team wins!</span>")
			to_chat(competitor, victory_rejoin_text)
			for(var/obj/item/ctf/W in competitor)
				competitor.dropItemToGround(W)
			competitor.dust()
	control_point_reset()
	for(var/obj/machinery/capture_the_flag/CTF as anything in GLOB.ctf_panel.ctf_machines)
		if(CTF.game_id != game_id)
			continue
		if(CTF.ctf_enabled == TRUE)
			machine_reset(CTF)

/obj/machinery/capture_the_flag/proc/toggle_ctf()
	if(!ctf_enabled)
		start_ctf()
		. = TRUE
	else
		stop_ctf()
		. = FALSE

/obj/machinery/capture_the_flag/proc/start_ctf()
	ctf_enabled = TRUE
	for(var/d in dead_barricades)
		var/obj/effect/ctf/dead_barricade/D = d
		D.respawn()

	dead_barricades.Cut()

	notify_ghosts("[name] has been activated!", source = src, action=NOTIFY_ORBIT, header = "CTF has been activated")

/obj/machinery/capture_the_flag/proc/machine_reset(obj/machinery/capture_the_flag/CTF)
	CTF.points = 0
	CTF.control_points = 0
	CTF.ctf_enabled = FALSE
	CTF.team_members = list()
	CTF.arena_reset = FALSE

/obj/machinery/capture_the_flag/proc/control_point_reset()
	for(var/obj/machinery/control_point/control in GLOB.machines)
		control.icon_state = "dominator"
		control.controlling = null

/obj/machinery/capture_the_flag/proc/unload()
	if(!ctf_landmark)
		return

	if(ctf_landmark == GLOB.ctf_spawner)
		stop_ctf()
		new /obj/effect/landmark/ctf(get_turf(GLOB.ctf_spawner))


/obj/machinery/capture_the_flag/proc/stop_ctf()
	var/area/A = get_area(src)
	for(var/_competitor in GLOB.mob_living_list)
		var/mob/living/competitor = _competitor
		if((get_area(A) == A) && (competitor.ckey in team_members))
			competitor.dust()
	team_members.Cut()
	spawned_mobs.Cut()
	recently_dead_ckeys.Cut()
	control_point_reset()
	machine_reset(src)

/obj/machinery/capture_the_flag/proc/instagib_mode()
	for(var/obj/machinery/capture_the_flag/CTF as anything in GLOB.ctf_panel.ctf_machines)
		if(CTF.game_id != game_id)
			continue
		CTF.ctf_gear = CTF.instagib_gear
		CTF.respawn_cooldown = INSTAGIB_RESPAWN

/obj/machinery/capture_the_flag/proc/normal_mode()
	for(var/obj/machinery/capture_the_flag/CTF as anything in GLOB.ctf_panel.ctf_machines)
		if(CTF.game_id != game_id)
			continue
		CTF.ctf_gear = CTF.default_gear
		CTF.respawn_cooldown = DEFAULT_RESPAWN

/obj/structure/trap/ctf
	name = "Spawn protection"
	desc = "Stay outta the enemy spawn!"
	icon_state = "trap"
	resistance_flags = INDESTRUCTIBLE
	var/team = WHITE_TEAM
	time_between_triggers = 1
	anchored = TRUE
	alpha = 255

/obj/structure/trap/ctf/examine(mob/user)
	return

/obj/structure/trap/ctf/trap_effect(mob/living/L)
	if(!is_ctf_target(L))
		return
	if(!(src.team in L.faction))
		to_chat(L, span_danger("<B>Stay out of the enemy spawn!</B>"))
		L.investigate_log("has died from entering the enemy spawn in CTF.", INVESTIGATE_DEATHS)
		L.death()

/obj/structure/trap/ctf/red
	team = RED_TEAM
	icon_state = "trap-fire"

/obj/structure/trap/ctf/blue
	team = BLUE_TEAM
	icon_state = "trap-frost"

/obj/structure/trap/ctf/green
	team = GREEN_TEAM
	icon_state = "trap-earth"

/obj/structure/trap/ctf/yellow
	team = YELLOW_TEAM
	icon_state = "trap-shock"

/obj/structure/barricade/security/ctf
	name = "barrier"
	desc = "A barrier. Provides cover in fire fights."
	deploy_time = 0
	deploy_message = 0

/obj/structure/barricade/security/ctf/make_debris()
	new /obj/effect/ctf/dead_barricade(get_turf(src))

/obj/structure/table/reinforced/ctf
	resistance_flags = INDESTRUCTIBLE
	flags_1 = NODECONSTRUCT_1

/obj/effect/ctf
	density = FALSE
	anchored = TRUE
	invisibility = INVISIBILITY_OBSERVER
	alpha = 100
	resistance_flags = INDESTRUCTIBLE

/obj/effect/ctf/dead_barricade
	name = "dead barrier"
	desc = "It provided cover in fire fights. And now it's gone."
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrier0"
	var/game_id = "centcom"

/obj/effect/ctf/dead_barricade/Initialize(mapload)
	. = ..()
	for(var/obj/machinery/capture_the_flag/CTF as anything in GLOB.ctf_panel.ctf_machines)
		if(CTF.game_id != game_id)
			continue
		CTF.dead_barricades += src

/obj/effect/ctf/dead_barricade/Destroy()
	for(var/obj/machinery/capture_the_flag/CTF as anything in GLOB.ctf_panel.ctf_machines)
		if(CTF.game_id != game_id)
			continue
		CTF.dead_barricades -= src
	return ..()

/obj/effect/ctf/dead_barricade/proc/respawn()
	if(!QDELETED(src))
		new /obj/structure/barricade/security/ctf(get_turf(src))
		qdel(src)

//Control Point

/obj/machinery/control_point
	name = "control point"
	desc = "You should capture this."
	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator"
	resistance_flags = INDESTRUCTIBLE
	var/obj/machinery/capture_the_flag/controlling
	var/team = "none"
	///This is how many points are gained a second while controlling this point
	var/point_rate = 1
	var/game_area = /area/centcom/ctf

/obj/machinery/control_point/process(delta_time)
	if(controlling)
		controlling.control_points += point_rate * delta_time
		if(controlling.control_points >= controlling.control_points_to_win)
			controlling.victory()

	var/scores

	for(var/obj/machinery/capture_the_flag/team as anything in GLOB.ctf_panel.ctf_machines)
		if (!team.ctf_enabled)
			continue
		scores += UNLINT("<span style='color: [team.team]'>[team.team] - [team.control_points]/[team.control_points_to_win]</span>\n")

	balloon_alert_to_viewers(scores)

/obj/machinery/control_point/attackby(mob/user, params)
	capture(user)

/obj/machinery/control_point/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	capture(user)

/obj/machinery/control_point/proc/capture(mob/user)
	if(do_after(user, 30, target = src))
		for(var/obj/machinery/capture_the_flag/team as anything in GLOB.ctf_panel.ctf_machines)
			if(team.ctf_enabled && (user.ckey in team.team_members))
				controlling = team
				icon_state = "dominator-[team.team]"
				for(var/mob/M in GLOB.player_list)
					var/area/mob_area = get_area(M)
					if(istype(mob_area, game_area))
						to_chat(M, "<span class='userdanger [team.team_span]'>[user.real_name] has captured \the [src], claiming it for [team.team]! Go take it back!</span>")
				break

/proc/is_ctf_target(atom/target)
	. = FALSE
	if(istype(target, /obj/structure/barricade/security/ctf))
		. = TRUE
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		for(var/obj/machinery/capture_the_flag/CTF as anything in GLOB.ctf_panel.ctf_machines)
			if(H in CTF.spawned_mobs)
				. = TRUE
				break

#undef WHITE_TEAM
#undef RED_TEAM
#undef BLUE_TEAM
#undef GREEN_TEAM
#undef YELLOW_TEAM
#undef FLAG_RETURN_TIME
#undef INSTAGIB_RESPAWN
#undef DEFAULT_RESPAWN
