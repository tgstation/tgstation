GLOBAL_LIST_EMPTY(infection_spawns)
GLOBAL_LIST_EMPTY(infection_gravity_spawns)

/datum/map_template/infection_start
    name = "Infection Start"
    mappath = '_maps/templates/infection_spawn.dmm'

/obj/effect/landmark/infection_start
	name = "infection start"
	icon_state = "infection_start"

/obj/effect/landmark/infection_start/Initialize(mapload)
	..()
	GLOB.infection_spawns += get_turf(src)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/infection_gravity_spawn
	name = "infection gravity spawn"
	icon_state = "infection_gravity"

/obj/effect/landmark/infection_gravity_spawn/Initialize(mapload)
	..()
	GLOB.infection_gravity_spawns += get_turf(src)
	return INITIALIZE_HINT_QDEL

////////////////////////
// Overmind Abilities //
////////////////////////

/*
	Places the infection core but delayed and gives a tell with the shuttle ripples
*/
/mob/camera/commander/proc/place_infection_core()
	if(placed || placing)
		return
	placing = TRUE
	var/turf/start = pick(GLOB.infection_spawns)
	var/datum/map_template/infection_start/template = new
	var/list/hit_turfs = template.get_affected_turfs(start, centered = TRUE)
	var/list/ripples = list()
	for(var/turf/T in hit_turfs)
		ripples += new /obj/effect/abstract/ripple(T, 200)
	sleep(200)
	for(var/ripple in ripples)
		qdel(ripple)
	for(var/turf/T in hit_turfs)
		for(var/i in 1 to 10)
			for(var/atom/thing in T.contents)
				if(isliving(thing))
					var/mob/M = thing
					M.visible_message("<span class='warning'>The infection meteor slams into [M]!</span>")
					M.gib()
				else
					thing.blob_act()
	template.load(start, centered = TRUE)
	forceMove(start)
	var/obj/structure/infection/core/I = new(start, src, base_point_rate, 1)
	infection_core = I
	I.update_icon()
	update_health_hud()
	reset_perspective()
	transport_core()
	placing = FALSE
	placed = TRUE

/*
	If the commander can afford to buy this much with infection points
*/
/mob/camera/commander/proc/can_buy(cost = 0)
	if(infection_points < cost)
		to_chat(src, "<span class='warning'>You cannot afford this, you need at least [cost] resources!</span>")
		return FALSE
	add_points(-cost)
	return TRUE

/*
	If the commander can afford to buy this much with upgrade points
*/
/mob/camera/commander/proc/can_upgrade(cost = 1)
	var/diff = upgrade_points - cost
	if(diff < 0)
		to_chat(src, "<span class='warning'>You cannot afford this, you need at least [diff * -1] more upgrade points! Destroy beacons to acquire them!</span>")
		return FALSE
	upgrade_points = diff
	return TRUE

/*
	Moves the camera to the core
*/
/mob/camera/commander/verb/transport_core()
	set category = "Infection"
	set name = "Jump to Core"
	set desc = "Move your camera to your core."
	if(infection_core)
		forceMove(infection_core.drop_location())

/*
	Moves the camera to a selected node
*/
/mob/camera/commander/verb/jump_to_node()
	set category = "Infection"
	set name = "Jump to Node"
	set desc = "Move your camera to a selected node."
	if(GLOB.infection_nodes.len)
		var/list/nodes = list()
		for(var/i in 1 to GLOB.infection_nodes.len)
			var/obj/structure/infection/node/N = GLOB.infection_nodes[i]
			nodes["Infection Node #[i]"] = N
		var/node_name = input(src, "Choose a node to jump to.", "Node Jump") in nodes
		var/obj/structure/infection/node/chosen_node = nodes[node_name]
		if(chosen_node)
			forceMove(chosen_node.loc)

/*
	Handles the initial creation of a special type of infection
*/
/mob/camera/commander/proc/createSpecial(price, infectionType, nearEquals, needsNode, turf/T)
	if(!T)
		T = get_turf(src)
	var/obj/structure/infection/I = (locate(/obj/structure/infection) in T)
	if(!I)
		to_chat(src, "<span class='warning'>There is no infection here!</span>")
		return
	if(!istype(I, /obj/structure/infection/normal))
		to_chat(src, "<span class='warning'>Unable to use this infection, find a normal one.</span>")
		return
	if(I.building)
		to_chat(src, "<span class='warning'>This infection is currently being built on already!</span>")
		return
	if(needsNode && nodes_required)
		if(!(locate(/obj/structure/infection/node) in orange(3, T)) && !(locate(/obj/structure/infection/core) in orange(4, T)))
			to_chat(src, "<span class='warning'>You need to place this infection closer to a node or core!</span>")
			return //handholdotron 2000
	if(nearEquals)
		for(var/obj/structure/infection/L in orange(nearEquals, T))
			if(SAME_INFECTION_TYPE(L, infectionType))
				to_chat(src, "<span class='warning'>There is a similar infection nearby, move more than [nearEquals] tiles away from it!</span>")
				return
	if(!can_buy(price))
		return
	var/obj/structure/infection/N = I.change_to(infectionType, src)
	return N

/*
	Attempts to create another spore for the infection commander
*/
/mob/camera/commander/proc/create_spore(poll_ghosts = TRUE)

	var/list/mob/dead/observer/candidates = list()
	if(poll_ghosts)
		to_chat(src, "<span class='warning'>Attempting to create a sentient slime...</span>")
		candidates = pollGhostCandidates("Do you want to play as an evolving infection slime?", ROLE_INFECTION, null, ROLE_INFECTION, 50) //players must answer rapidly
	if(LAZYLEN(candidates) || !poll_ghosts) //if we got at least one candidate, they're a sentient spore now.
		var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/S = new /mob/living/simple_animal/hostile/infection/infectionspore/sentient(src, null, src)
		if(poll_ghosts)
			var/mob/dead/observer/C = pick(candidates)
			S.key = C.key
		var/turf/T = get_turf(src)
		S.create_respawn_mob(T)
		if(!infection_core)
			// roundstart boys get gifts
			S.add_points(1000)
			to_chat(S, "<b>It costs no points to revert your form before the meteor has landed, explore your evolutions while you have time.</b>")
		S.update_icons()
		S.infection_help()
		infection_mobs += S
		return S
	to_chat(src, "<span class='warning'>You could not conjure a sentience for your slime. Try again later.</span>")
	upgrade_points++
	return FALSE

/*
	Opens the evolution menu
*/
/mob/camera/commander/verb/evolve_menu()
	set category = "Infection"
	set name = "Evolution"
	set desc = "Improve yourself and your army to be unstoppable."
	menu_handler.ui_interact(src)

/*
	Deletes an infection to give back resources
*/
/mob/camera/commander/verb/revert()
	set category = "Infection"
	set name = "Remove Infection"
	set desc = "Removes an infection, giving you back some resources."
	var/turf/T = get_turf(src)
	remove_infection(T)

/*
	Actual proc handling removal of the infection structure
	Fails if the structure has a negative point return
*/
/mob/camera/commander/proc/remove_infection(turf/T)
	var/obj/structure/infection/I = locate() in T
	if(!I)
		to_chat(src, "<span class='warning'>There is no infection there!</span>")
		return
	if(I.point_return < 0)
		to_chat(src, "<span class='warning'>Unable to remove this infection.</span>")
		return
	if(I.point_return)
		add_points(I.point_return)
		to_chat(src, "<span class='notice'>Gained [I.point_return] resources from removing \the [I].</span>")
	qdel(I)

/*
	Moves all spores the camera can see to the point middle clicked on
*/
/mob/camera/commander/verb/rally_spores_power()
	set category = "Infection"
	set name = "Rally Slimes"
	set desc = "Rally your slimes to move to a target location."
	var/turf/T = get_turf(src)
	rally_spores(T)

/*
	Actual proc handling moving of the spores to the point clicked
*/
/mob/camera/commander/proc/rally_spores(turf/T)
	to_chat(src, "You direct the slimes you can see.")
	var/list/surrounding_turfs = block(locate(T.x - 1, T.y - 1, T.z), locate(T.x + 1, T.y + 1, T.z))
	if(!surrounding_turfs.len)
		return
	for(var/mob/living/simple_animal/hostile/infection/infectionspore/IS in infection_mobs && urange(7, src))
		if(isturf(IS.loc) && get_dist(IS, T) <= 35)
			IS.LoseTarget()
			IS.Goto(pick(surrounding_turfs), IS.move_to_delay)

/*
	Help guide for playing the infection commander
*/
/mob/camera/commander/verb/infection_help()
	set category = "Infection"
	set name = "*Infection Help*"
	set desc = "Help on how to infection."
	to_chat(src, "<b>As the commander, you command the nearly impossible to kill infection!</b>")
	to_chat(src, "<b>Your job is to delegate resources. Upgrade your defenses and create an army of sentient slimes. Protect the boss creatures and destroy the beacons to win.</b>")
	to_chat(src, "<i>Normal Infections</i> will expand your reach and can be upgraded into special infections that perform certain functions.")
	to_chat(src, "<b>You can upgrade normal infections into various types, using the powers on your action bar.</b>")
	to_chat(src, "<b>To destroy the beacons, place nodes nearby which will expand on them and drain their power.</b>")
	to_chat(src, "<b>Destroying beacons grants you upgrade points which can be used to unlock powers in your evolution shop on the HUD.</b>")
	to_chat(src, "<i>You may also bring corpses of sentient humans to your core in order to convert them into evolving slimes.</i>")
	to_chat(src, "<b>In addition to the buttons on your HUD, there are a few click shortcuts to speed up expansion and defense.</b>")
	to_chat(src, "<b>Shortcuts:</b> Click = Upgrade Infection (Must be near infection) <b>|</b> Middle Mouse Click = Move slimes on screen <b>|</b> Ctrl Click = Create Shield Infection <b>|</b> Alt Click = Remove Infection")
	if(!placed && autoplace_time <= world.time)
		to_chat(src, "<span class='big'><font color=\"#EE4000\">You will automatically place your core in [DisplayTimeText(max(autoplace_time - world.time, 0))].</font></span>")