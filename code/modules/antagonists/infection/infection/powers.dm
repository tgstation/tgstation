GLOBAL_LIST_EMPTY(infection_spawns)

/obj/effect/landmark/infection_start
	name = "infectionstart"
	icon_state = "infection_start"

/obj/effect/landmark/infection_start/Initialize(mapload)
	..()
	GLOB.infection_spawns += get_turf(src)
	return INITIALIZE_HINT_QDEL

////////////////////////
// Overmind Abilities //
////////////////////////

/mob/camera/commander/proc/place_infection_core()
	if(placed)
		return
	var/turf/start = pick(GLOB.infection_spawns)
	forceMove(get_turf(start))
	var/obj/structure/infection/core/I = new(get_turf(start), src, base_point_rate, 1)
	infection_core = I
	I.update_icon()
	update_health_hud()
	reset_perspective()
	transport_core()
	placed = TRUE

/mob/camera/commander/proc/can_buy(cost = 0)
	if(infection_points < cost)
		to_chat(src, "<span class='warning'>You cannot afford this, you need at least [cost] resources!</span>")
		return FALSE
	add_points(-cost)
	return TRUE

/mob/camera/commander/proc/can_upgrade(cost = 1)
	var/diff = upgrade_points - cost
	if(diff < 0)
		to_chat(src, "<span class='warning'>You cannot afford this, you need at least [diff * -1] more upgrade points! Destroy beacons to acquire them!</span>")
		return FALSE
	upgrade_points = diff
	return TRUE

/mob/camera/commander/verb/transport_core()
	set category = "Infection"
	set name = "Jump to Core"
	set desc = "Move your camera to your core."
	if(infection_core)
		forceMove(infection_core.drop_location())

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
			if(istype(L, infectionType) || L.building == infectionType)
				to_chat(src, "<span class='warning'>There is a similar infection nearby, move more than [nearEquals] tiles away from it!</span>")
				return
	if(!can_buy(price))
		return
	var/obj/structure/infection/N = I.change_to(infectionType, src)
	return N

/mob/camera/commander/verb/toggle_node_req()
	set category = "Infection"
	set name = "Toggle Node Requirement"
	set desc = "Toggle requiring nodes to place resource and factory infections."
	nodes_required = !nodes_required
	if(nodes_required)
		to_chat(src, "<span class='warning'>You now require a nearby node or core to place factory and resource infections.</span>")
	else
		to_chat(src, "<span class='warning'>You no longer require a nearby node or core to place factory and resource infections.</span>")

/mob/camera/commander/proc/create_spore()
	to_chat(src, "<span class='warning'>Attempting to create a sentient spore...</span>")

	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as an evolving infection spore?", ROLE_INFECTION, null, ROLE_INFECTION, 50) //players must answer rapidly
	if(LAZYLEN(candidates)) //if we got at least one candidate, they're a sentient spore now.
		var/mob/dead/observer/C = pick(candidates)
		var/datum/mind/spore_mind = C.mind
		spore_mind.add_antag_datum(/datum/antagonist/infection/spore)
		return TRUE
	to_chat(src, "<span class='warning'>You could not conjure a sentience for your spore. Try again later.</span>")
	upgrade_points++

/mob/camera/commander/verb/evolve_menu()
	set category = "Infection"
	set name = "Evolution"
	set desc = "Improve yourself and your army to be unstoppable."
	menu_handler.ui_interact(src)

/mob/camera/commander/verb/revert()
	set category = "Infection"
	set name = "Remove Infection"
	set desc = "Removes an infection, giving you back some resources."
	var/turf/T = get_turf(src)
	remove_infection(T)

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

/mob/camera/commander/verb/rally_spores_power()
	set category = "Infection"
	set name = "Rally Spores"
	set desc = "Rally your spores to move to a target location."
	var/turf/T = get_turf(src)
	rally_spores(T)

/mob/camera/commander/proc/rally_spores(turf/T)
	to_chat(src, "You direct your selected spores.")
	var/list/surrounding_turfs = block(locate(T.x - 1, T.y - 1, T.z), locate(T.x + 1, T.y + 1, T.z))
	if(!surrounding_turfs.len)
		return
	for(var/mob/living/simple_animal/hostile/infection/infectionspore/IS in infection_mobs)
		if(isturf(IS.loc) && get_dist(IS, T) <= 35)
			IS.LoseTarget()
			IS.Goto(pick(surrounding_turfs), IS.move_to_delay)

/mob/camera/commander/verb/infection_broadcast()
	set category = "Infection"
	set name = "Infection Broadcast"
	set desc = "Speak with your infection spores and infesternauts as your mouthpieces."
	var/speak_text = input(src, "What would you like to say with your minions?", "Infection Broadcast", null) as text
	if(!speak_text)
		return
	else
		to_chat(src, "You broadcast with your minions, <B>[speak_text]</B>")
	for(var/INF in infection_mobs)
		var/mob/living/simple_animal/hostile/infection/IN = INF
		if(IN.stat == CONSCIOUS)
			IN.say(speak_text)

/mob/camera/commander/verb/infection_help()
	set category = "Infection"
	set name = "*Infection Help*"
	set desc = "Help on how to infection."
	to_chat(src, "<b>As the commander, you command the nearly impossible to kill infection!</b>")
	to_chat(src, "<b>Your job is to delegate resources. Upgrade your defenses and create an army of sentient spores. Protect the boss creatures and destroy the beacons to win.</b>")
	to_chat(src, "<i>Normal Infections</i> will expand your reach and can be upgraded into special infections that perform certain functions.")
	to_chat(src, "<b>You can upgrade normal infections into the following types of infection:</b>")
	to_chat(src, "<i>Shield Infections</i> are bulky infections that can take a beating. You can upgrade them to make them resistant to more effects and gain more maximum health.")
	to_chat(src, "<i>Resource Infections</i> produce 1 resource every couple of seconds for you. They produce 2 more resources for each time they are upgraded.")
	to_chat(src, "<i>Factory Infections</i> produce mindless spores that obey you and attack intruders. Factories produce 2 more spores for each time they are ugpraded.")
	to_chat(src, "<i>Sentient Spores</i> are constantly evolving creatures that do not die as long as you live, they simply regenerate themselves from you.")
	to_chat(src, "<i>Node Infections</i> constantly grow more infections around them. When upgraded they spread faster, though they expand slower as they age. These are the only way you can damage the beacons when they spread on them.")
	to_chat(src, "<b>In addition to the buttons on your HUD, there are a few click shortcuts to speed up expansion and defense.</b>")
	to_chat(src, "<b>Shortcuts:</b> Click = Upgrade Infection (Must be near infection) <b>|</b> Middle Mouse Click = Move selected spores <b>|</b> Ctrl Click = Create Shield Infection <b>|</b> Alt Click = Remove Infection")
	if(!placed && autoplace_time <= world.time)
		to_chat(src, "<span class='big'><font color=\"#EE4000\">You will automatically place your core in [DisplayTimeText(max(autoplace_time - world.time, 0))].</font></span>")