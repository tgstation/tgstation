/datum/round_event_control/pirates
	name = "Space Pirates"
	typepath = /datum/round_event/pirates
	weight = 8
	max_occurrences = 1
	min_players = 10
	earliest_start = 30 MINUTES
	gamemode_blacklist = list("nuclear")

/datum/round_event_control/pirates/preRunEvent()
	if (!SSmapping.empty_space)
		return EVENT_CANT_RUN

	return ..()

/datum/round_event/pirates
	startWhen = 60 //2 minutes to answer
	var/datum/comm_message/threat
	var/payoff = 0
	var/paid_off = FALSE
	var/ship_name = "Space Privateers Association"
	var/shuttle_spawned = FALSE

/datum/round_event/pirates/setup()
	ship_name = pick(strings(PIRATE_NAMES_FILE, "ship_names"))

/datum/round_event/pirates/announce(fake)
	priority_announce("Incoming subspace communication. Secure channel opened at all communication consoles.", "Incoming Message", 'sound/ai/commandreport.ogg')
	if(fake)
		return
	threat = new
	payoff = round(SSshuttle.points * 0.80)
	threat.title = "Business proposition"
	threat.content = "This is [ship_name]. Pay up [payoff] credits or you'll walk the plank."
	threat.possible_answers = list("We'll pay.","No way.")
	threat.answer_callback = CALLBACK(src,.proc/answered)
	SScommunications.send_message(threat,unique = TRUE)

/datum/round_event/pirates/proc/answered()
	if(threat && threat.answered == 1)
		if(SSshuttle.points >= payoff)
			SSshuttle.points -= payoff
			priority_announce("Thanks for the credits, landlubbers.",sender_override = ship_name)
			paid_off = TRUE
			return
		else
			priority_announce("Trying to cheat us? You'll regret this!",sender_override = ship_name)
	if(!shuttle_spawned)
		spawn_shuttle()



/datum/round_event/pirates/start()
	if(!paid_off && !shuttle_spawned)
		spawn_shuttle()

/datum/round_event/pirates/proc/spawn_shuttle()
	shuttle_spawned = TRUE

	var/list/candidates = pollGhostCandidates("Do you wish to be considered for pirate crew?", ROLE_TRAITOR)
	shuffle_inplace(candidates)

	var/datum/map_template/shuttle/pirate/default/ship = new
	var/x = rand(TRANSITIONEDGE,world.maxx - TRANSITIONEDGE - ship.width)
	var/y = rand(TRANSITIONEDGE,world.maxy - TRANSITIONEDGE - ship.height)
	var/z = SSmapping.empty_space.z_value
	var/turf/T = locate(x,y,z)
	if(!T)
		CRASH("Pirate event found no turf to load in")

	if(!ship.load(T))
		CRASH("Loading pirate ship failed!")
	for(var/turf/A in ship.get_affected_turfs(T))
		for(var/obj/effect/mob_spawn/human/pirate/spawner in A)
			if(candidates.len > 0)
				var/mob/M = candidates[1]
				spawner.create(M.ckey)
				candidates -= M
			else
				notify_ghosts("Space pirates are waking up!", source = spawner, action=NOTIFY_ATTACK, flashwindow = FALSE)

	priority_announce("Unidentified armed ship detected near the station.")

//Shuttle equipment

/obj/machinery/shuttle_scrambler
	name = "Data Siphon"
	desc = "This heap of machinery steals credits and data from unprotected systems and locks down cargo shuttles."
	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator"
	density = TRUE
	var/active = FALSE
	var/obj/item/gps/gps
	var/credits_stored = 0
	var/siphon_per_tick = 5

/obj/machinery/shuttle_scrambler/Initialize(mapload)
	. = ..()
	gps = new/obj/item/gps/internal/pirate(src)
	gps.tracking = FALSE
	update_icon()

/obj/machinery/shuttle_scrambler/process()
	if(active)
		if(is_station_level(z))
			var/siphoned = min(SSshuttle.points,siphon_per_tick)
			SSshuttle.points -= siphoned
			credits_stored += siphoned
			interrupt_research()
		else
			return
	else
		STOP_PROCESSING(SSobj,src)

/obj/machinery/shuttle_scrambler/proc/toggle_on(mob/user)
	SSshuttle.registerTradeBlockade(src)
	gps.tracking = TRUE
	active = TRUE
	to_chat(user,"<span class='notice'>You toggle [src] [active ? "on":"off"].</span>")
	to_chat(user,"<span class='warning'>The scrambling signal can be now tracked by GPS.</span>")
	START_PROCESSING(SSobj,src)

/obj/machinery/shuttle_scrambler/interact(mob/user)
	if(!active)
		if(alert(user, "Turning the scrambler on will make the shuttle trackable by GPS. Are you sure you want to do it?", "Scrambler", "Yes", "Cancel") == "Cancel")
			return
		if(active || !user.canUseTopic(src))
			return
		toggle_on(user)
		update_icon()
		send_notification()
	else
		dump_loot(user)

//interrupt_research
/obj/machinery/shuttle_scrambler/proc/interrupt_research()
	for(var/obj/machinery/rnd/server/S in GLOB.machines)
		if(S.stat & (NOPOWER|BROKEN))
			continue
		S.emp_act(1)
		new /obj/effect/temp_visual/emp(get_turf(S))

/obj/machinery/shuttle_scrambler/proc/dump_loot(mob/user)
	if(credits_stored < 200)
		to_chat(user,"<span class='notice'>Not enough credits to retrieve.</span>")
		return
	while(credits_stored >= 200)
		new /obj/item/stack/spacecash/c200(drop_location())
		credits_stored -= 200
	to_chat(user,"<span class='notice'>You retrieve the siphoned credits!</span>")


/obj/machinery/shuttle_scrambler/proc/send_notification()
	priority_announce("Data theft signal detected, source registered on local gps units.")

/obj/machinery/shuttle_scrambler/proc/toggle_off(mob/user)
	SSshuttle.clearTradeBlockade(src)
	gps.tracking = FALSE
	active = FALSE
	STOP_PROCESSING(SSobj,src)

/obj/machinery/shuttle_scrambler/update_icon()
	if(active)
		icon_state = "dominator-blue"
	else
		icon_state = "dominator"

/obj/machinery/shuttle_scrambler/Destroy()
	toggle_off()
	QDEL_NULL(gps)
	return ..()

/obj/item/gps/internal/pirate
	gpstag = "Nautical Signal"
	desc = "You can hear shanties over the static."

/obj/machinery/computer/shuttle/pirate
	name = "pirate shuttle console"
	shuttleId = "pirateship"
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	light_color = LIGHT_COLOR_RED
	possible_destinations = "pirateship_away;pirateship_home;pirateship_custom"

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/pirate
	name = "pirate shuttle navigation computer"
	desc = "Used to designate a precise transit location for the pirate shuttle."
	shuttleId = "pirateship"
	lock_override = CAMERA_LOCK_STATION
	shuttlePortId = "pirateship_custom"
	shuttlePortName = "custom location"
	x_offset = 9
	y_offset = 0
	see_hidden = FALSE

/obj/docking_port/mobile/pirate
	name = "pirate shuttle"
	id = "pirateship"
	var/engines_cooling = FALSE
	var/engine_cooldown = 3 MINUTES

/obj/docking_port/mobile/pirate/getStatusText()
	. = ..()
	if(engines_cooling)
		return "[.] - Engines cooling."

/obj/docking_port/mobile/pirate/initiate_docking(obj/docking_port/stationary/new_dock, movement_direction, force=FALSE)
	. = ..()
	if(. == DOCKING_SUCCESS && !is_reserved_level(new_dock.z))
		engines_cooling = TRUE
		addtimer(CALLBACK(src,.proc/reset_cooldown),engine_cooldown,TIMER_UNIQUE)

/obj/docking_port/mobile/pirate/proc/reset_cooldown()
	engines_cooling = FALSE

/obj/docking_port/mobile/pirate/canMove()
	if(engines_cooling)
		return FALSE
	return ..()

/obj/machinery/suit_storage_unit/pirate
	suit_type = /obj/item/clothing/suit/space
	helmet_type = /obj/item/clothing/head/helmet/space
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/internals/oxygen


/obj/machinery/loot_locator
	name = "Booty Locator"
	desc = "This sophisticated machine scans the nearby space for items of value."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "tdoppler"
	density = TRUE
	var/cooldown = 300
	var/next_use = 0

/obj/machinery/loot_locator/interact(mob/user)
	if(world.time <= next_use)
		to_chat(user,"<span class='warning'>[src] is recharging.</span>")
		return
	next_use = world.time + cooldown
	var/atom/movable/AM = find_random_loot()
	if(!AM)
		say("No valuables located. Try again later.")
	else
		say("Located: [AM.name] at [get_area_name(AM)]")

/obj/machinery/loot_locator/proc/find_random_loot()
	if(!GLOB.exports_list.len)
		setupExports()
	var/list/possible_loot = list()
	for(var/datum/export/pirate/E in GLOB.exports_list)
		possible_loot += E
	var/datum/export/pirate/P
	var/atom/movable/AM
	while(!AM && possible_loot.len)
		P = pick_n_take(possible_loot)
		AM = P.find_loot()
	return AM

//Pad & Pad Terminal
/obj/machinery/piratepad
	name = "cargo hold pad"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "lpad-idle-o"
	var/idle_state = "lpad-idle-o"
	var/warmup_state = "lpad-idle"
	var/sending_state = "lpad-beam"
	var/cargo_hold_id

/obj/machinery/piratepad/multitool_act(mob/living/user, obj/item/multitool/I)
	if (istype(I))
		to_chat(user, "<span class='notice'>You register [src] in [I]s buffer.</span>")
		I.buffer = src
		return TRUE

/obj/machinery/computer/piratepad_control
	name = "cargo hold control terminal"
	var/status_report = "Idle"
	var/obj/machinery/piratepad/pad
	var/warmup_time = 100
	var/sending = FALSE
	var/points = 0
	var/datum/export_report/total_report
	var/sending_timer
	var/cargo_hold_id

/obj/machinery/computer/piratepad_control/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/piratepad_control/multitool_act(mob/living/user, obj/item/multitool/I)
	if (istype(I) && istype(I.buffer,/obj/machinery/piratepad))
		to_chat(user, "<span class='notice'>You link [src] with [I.buffer] in [I] buffer.</span>")
		pad = I.buffer
		updateDialog()
		return TRUE

/obj/machinery/computer/piratepad_control/LateInitialize()
	. = ..()
	if(cargo_hold_id)
		for(var/obj/machinery/piratepad/P in GLOB.machines)
			if(P.cargo_hold_id == cargo_hold_id)
				pad = P
				return
	else
		pad = locate() in range(4,src)

/obj/machinery/computer/piratepad_control/ui_interact(mob/user)
	. = ..()
	var/list/t = list()
	t += "<div class='statusDisplay'>Cargo Hold Control<br>"
	t += "Current cargo value : [points]"
	t += "</div>"
	if(!pad)
		t += "<div class='statusDisplay'>No pad located.</div><BR>"
	else
		t += "<br>[status_report]<br>"
		if(!sending)
			t += "<a href='?src=[REF(src)];recalc=1;'>Recalculate Value</a><a href='?src=[REF(src)];send=1'>Send</a>"
		else
			t += "<a href='?src=[REF(src)];stop=1'>Stop sending</a>"

	var/datum/browser/popup = new(user, "piratepad", name, 300, 500)
	popup.set_content(t.Join())
	popup.open()

/obj/machinery/computer/piratepad_control/proc/recalc()
	if(sending)
		return
	status_report = "Predicted value:<br>"
	var/datum/export_report/ex = new
	for(var/atom/movable/AM in get_turf(pad))
		if(AM == pad)
			continue
		export_item_and_contents(AM, EXPORT_PIRATE | EXPORT_CARGO | EXPORT_CONTRABAND | EXPORT_EMAG, apply_elastic = FALSE, dry_run = TRUE, external_report = ex)
		
	for(var/datum/export/E in ex.total_amount)
		status_report += E.total_printout(ex,notes = FALSE) + "<br>"

/obj/machinery/computer/piratepad_control/proc/send()
	if(!sending)
		return

	var/datum/export_report/ex = new
	
	for(var/atom/movable/AM in get_turf(pad))
		if(AM == pad)
			continue
		export_item_and_contents(AM, EXPORT_PIRATE | EXPORT_CARGO | EXPORT_CONTRABAND | EXPORT_EMAG, apply_elastic = FALSE, delete_unsold = FALSE, external_report = ex)
	
	status_report = "Sold:<br>"
	var/value = 0
	for(var/datum/export/E in ex.total_amount)
		var/export_text = E.total_printout(ex,notes = FALSE) //Don't want nanotrasen messages, makes no sense here.
		if(!export_text)
			continue

		status_report += export_text + "<br>"
		value += ex.total_value[E]

	if(!total_report)
		total_report = ex
	else
		total_report.exported_atoms += ex.exported_atoms
		for(var/datum/export/E in ex.total_amount)
			total_report.total_amount[E] += ex.total_amount[E]
			total_report.total_value[E] += ex.total_value[E]

	points += value

	pad.visible_message("<span class='notice'>[pad] activates!</span>")
	flick(pad.sending_state,pad)
	pad.icon_state = pad.idle_state
	sending = FALSE
	updateDialog()

/obj/machinery/computer/piratepad_control/proc/start_sending()
	if(sending)
		return
	sending = TRUE
	status_report = "Sending..."
	pad.visible_message("<span class='notice'>[pad] starts charging up.</span>")
	pad.icon_state = pad.warmup_state
	sending_timer = addtimer(CALLBACK(src,.proc/send),warmup_time, TIMER_STOPPABLE)

/obj/machinery/computer/piratepad_control/proc/stop_sending()
	if(!sending)
		return
	sending = FALSE
	status_report = "Idle"
	pad.icon_state = pad.idle_state
	deltimer(sending_timer)

/obj/machinery/computer/piratepad_control/Topic(href, href_list)
	if(..())
		return
	if(pad)
		if(href_list["recalc"])
			recalc()
		if(href_list["send"])
			start_sending()
		if(href_list["stop"])
			stop_sending()
		updateDialog()
	else
		updateDialog()

/datum/export/pirate
	export_category = EXPORT_PIRATE

//Attempts to find the thing on station
/datum/export/pirate/proc/find_loot()
	return

/datum/export/pirate/ransom
	cost = 3000
	unit_name = "hostage"
	export_types = list(/mob/living/carbon/human)

/datum/export/pirate/ransom/find_loot()
	var/list/head_minds = SSjob.get_living_heads()
	var/list/head_mobs = list()
	for(var/datum/mind/M in head_minds)
		head_mobs += M.current
	if(head_mobs.len)
		return pick(head_mobs)

/datum/export/pirate/ransom/get_cost(atom/movable/AM)
	var/mob/living/carbon/human/H = AM
	if(H.stat != CONSCIOUS || !H.mind || !H.mind.assigned_role) //mint condition only
		return 0
	else
		if(H.mind.assigned_role in GLOB.command_positions)
			return 3000
		else
			return 1000

/datum/export/pirate/parrot
	cost = 2000
	unit_name = "alive parrot"
	export_types = list(/mob/living/simple_animal/parrot)

/datum/export/pirate/parrot/find_loot()
	for(var/mob/living/simple_animal/parrot/P in GLOB.alive_mob_list)
		var/turf/T = get_turf(P)
		if(T && is_station_level(T.z))
			return P

/datum/export/pirate/cash
	cost = 1
	unit_name = "bills"
	export_types = list(/obj/item/stack/spacecash)

/datum/export/pirate/cash/get_amount(obj/O)
	var/obj/item/stack/spacecash/C = O
	return ..() * C.amount * C.value