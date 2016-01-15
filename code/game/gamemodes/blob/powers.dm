/mob/camera/blob/proc/can_buy(cost = 15)
	if(blob_points < cost)
		src << "<span class='warning'>You cannot afford this!</span>"
		return 0
	add_points(-cost)
	return 1

// Power verbs

/mob/camera/blob/verb/transport_core()
	set category = "Blob"
	set name = "Jump to Core"
	set desc = "Move your camera to your core."
	if(blob_core)
		src.loc = blob_core.loc

/mob/camera/blob/verb/jump_to_node()
	set category = "Blob"
	set name = "Jump to Node"
	set desc = "Move your camera to a selected node."
	if(blob_nodes.len)
		var/list/nodes = list()
		for(var/i = 1; i <= blob_nodes.len; i++)
			nodes["Blob Node #[i]"] = blob_nodes[i]
		var/node_name = input(src, "Choose a node to jump to.", "Node Jump") in nodes
		var/obj/effect/blob/node/chosen_node = nodes[node_name]
		if(chosen_node)
			src.loc = chosen_node.loc

/mob/camera/blob/proc/createSpecial(price, blobType, nearEquals, turf/T)
	if(!T)
		T = get_turf(src)
	var/obj/effect/blob/B = (locate(/obj/effect/blob) in T)
	if(!B)
		src << "<span class='warning'>There is no blob here!</span>"
		return
	if(!istype(B, /obj/effect/blob/normal))
		src << "<span class='warning'>Unable to use this blob, find a normal one.</span>"
		return
	if(nearEquals)
		for(var/obj/effect/blob/L in orange(nearEquals, T))
			if(L.type == blobType)
				src << "<span class='warning'>There is a similar blob nearby, move more than [nearEquals] tiles away from it!</span>"
				return
	if(!can_buy(price))
		return
	var/obj/effect/blob/N = B.change_to(blobType, src)
	return N

/mob/camera/blob/verb/create_shield_power()
	set category = "Blob"
	set name = "Create Shield Blob (10)"
	set desc = "Create a shield blob, which will block fire and is hard to kill."
	create_shield()

/mob/camera/blob/proc/create_shield(turf/T)
	createSpecial(10, /obj/effect/blob/shield, 0, T)

/mob/camera/blob/verb/create_resource()
	set category = "Blob"
	set name = "Create Resource Blob (40)"
	set desc = "Create a resource tower which will generate resources for you."
	createSpecial(40, /obj/effect/blob/resource, 4)

/mob/camera/blob/verb/create_node()
	set category = "Blob"
	set name = "Create Node Blob (60)"
	set desc = "Create a node, which will power nearby factory and resource blobs."
	createSpecial(60, /obj/effect/blob/node, 5)

/mob/camera/blob/verb/create_factory()
	set category = "Blob"
	set name = "Create Factory Blob (60)"
	set desc = "Create a spore tower that will spawn spores to harass your enemies."
	createSpecial(60, /obj/effect/blob/factory, 7)

/mob/camera/blob/verb/create_blobbernaut()
	set category = "Blob"
	set name = "Create Blobbernaut (20)"
	set desc = "Create a powerful blobbernaut which is mildly smart and will attack enemies."
	var/turf/T = get_turf(src)
	var/obj/effect/blob/factory/B = locate(/obj/effect/blob/factory) in T
	if(!B)
		src << "<span class='warning'>You must be on a factory blob!</span>"
		return
	if(B.health < B.maxhealth*0.6) //if it's at less than 60% of its health, you can't blobbernaut it
		src << "<span class='warning'>This factory blob is too damaged to produce a blobbernaut.</span>"
		return
	if(!can_buy(20))
		return
	var/mob/living/simple_animal/hostile/blob/blobbernaut/blobber = new /mob/living/simple_animal/hostile/blob/blobbernaut(get_turf(B))
	B.take_damage(B.maxhealth*0.6, CLONE, null, 0) //take a bunch of damage, so you can't produce tons of blobbernauts from a single factory
	B.visible_message("<span class='warning'><b>The blobbernaut [pick("rips", "tears", "shreds")] its way out of the factory blob!</b></span>")
	B.spore_delay = world.time + 600 //one minute before it can spawn spores again
	blobber.overmind = src
	blobber.update_icons()
	blobber.AIStatus = AI_OFF
	blob_mobs.Add(blobber)
	var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as a [blob_reagent_datum.name] blobbernaut?", ROLE_BLOB, null, ROLE_BLOB, 50) //players must answer rapidly
	var/client/C = null
	if(candidates.len) //if we got at least one candidate, they're a blobbernaut now.
		C = pick(candidates)
		blobber.key = C.key
		blobber << 'sound/effects/blobattack.ogg'
		blobber << 'sound/effects/attackblob.ogg'
		blobber << "<b>You are a blobbernaut!</b>"
		blobber << "Your overmind's blob reagent is: <b><font color=\"[blob_reagent_datum.color]\">[blob_reagent_datum.name]</b></font>!"
		blobber << "The <b><font color=\"[blob_reagent_datum.color]\">[blob_reagent_datum.name]</b></font> reagent [blob_reagent_datum.shortdesc ? "[blob_reagent_datum.shortdesc]" : "[blob_reagent_datum.description]"]"
	else
		blobber.AIStatus = AI_ON //otherwise, they reactivate AI and continue

/mob/camera/blob/verb/relocate_core()
	set category = "Blob"
	set name = "Relocate Core (80)"
	set desc = "Swaps the locations of your core and the selected node."
	var/turf/T = get_turf(src)
	var/obj/effect/blob/node/B = locate(/obj/effect/blob/node) in T
	if(!B)
		src << "<span class='warning'>You must be on a blob node!</span>"
		return
	if(!can_buy(80))
		return
	var/turf/old_turf = blob_core.loc
	blob_core.loc = T
	B.loc = old_turf

/mob/camera/blob/verb/revert()
	set category = "Blob"
	set name = "Remove Blob"
	set desc = "Removes a blob, giving you back some resources."
	var/turf/T = get_turf(src)
	remove_blob(T)

/mob/camera/blob/proc/remove_blob(turf/T)
	var/obj/effect/blob/B = locate() in T
	if(!B)
		src << "<span class='warning'>There is no blob there!</span>"
		return
	if(B.point_return < 0)
		src << "<span class='warning'>Unable to remove this blob.</span>"
		return
	if(max_blob_points < B.point_return + blob_points)
		src << "<span class='warning'>You have too many resources to remove this blob!</span>"
		return
	if(B.point_return)
		add_points(B.point_return)
		src << "<span class='notice'>Gained [B.point_return] resources from removing \the [B].</span>"
	qdel(B)

/mob/camera/blob/verb/expand_blob_power()
	set category = "Blob"
	set name = "Expand/Attack Blob (5)"
	set desc = "Attempts to create a new blob in this tile. If the tile isn't clear, instead attacks it, damaging mobs and objects."
	var/turf/T = get_turf(src)
	expand_blob(T)

/mob/camera/blob/proc/expand_blob(turf/T)
	if(!can_attack())
		return
	var/obj/effect/blob/B = locate() in T
	if(B)
		src << "<span class='warning'>There is a blob there!</span>"
		return
	var/obj/effect/blob/OB = locate() in circlerange(T, 1)
	if(!OB)
		src << "<span class='warning'>There is no blob adjacent to the target tile!</span>"
		return
	if(!can_buy(5))
		return
	last_attack = world.time
	OB.expand(T, 0, src)
	for(var/mob/living/L in T)
		if("blob" in L.faction) //no friendly fire
			continue
		var/mob_protection = L.get_permeability_protection()
		blob_reagent_datum.reaction_mob(L, VAPOR, 25, 1, mob_protection)
		blob_reagent_datum.send_message(L)

/mob/camera/blob/verb/rally_spores_power()
	set category = "Blob"
	set name = "Rally Spores"
	set desc = "Rally your spores to move to a target location."
	var/turf/T = get_turf(src)
	rally_spores(T)

/mob/camera/blob/proc/rally_spores(turf/T)
	src << "You rally your spores."
	var/list/surrounding_turfs = block(locate(T.x - 1, T.y - 1, T.z), locate(T.x + 1, T.y + 1, T.z))
	if(!surrounding_turfs.len)
		return
	for(var/mob/living/simple_animal/hostile/blob/blobspore/BS in living_mob_list)
		if(BS.overmind == src && isturf(BS.loc) && get_dist(BS, T) <= 35)
			BS.LoseTarget()
			BS.Goto(pick(surrounding_turfs), BS.move_to_delay)

/mob/camera/blob/verb/blob_broadcast()
	set category = "Blob"
	set name = "Blob Broadcast"
	set desc = "Speak with your blob spores and blobbernauts as your mouthpieces."
	var/speak_text = input(src, "What would you like to say with your minions?", "Blob Broadcast", null) as text
	if(!speak_text)
		return
	else
		src << "You broadcast with your minions, <B>[speak_text]</B>"
	for(var/mob/living/simple_animal/hostile/blob/blob_minion in blob_mobs)
		if(blob_minion.overmind == src && blob_minion.stat == CONSCIOUS)
			blob_minion.say(speak_text)

/mob/camera/blob/verb/chemical_reroll()
	set category = "Blob"
	set name = "Reactive Chemical Adaptation (40)"
	set desc = "Replaces your chemical with a random, different one."
	if(!can_buy(40))
		return
	var/datum/reagent/blob/B = pick((subtypesof(/datum/reagent/blob) - blob_reagent_datum.type))
	blob_reagent_datum = new B
	for(var/obj/effect/blob/BL in blobs)
		BL.update_icon()
	for(var/mob/living/simple_animal/hostile/blob/BLO)
		BLO.update_icons()
	src << "Your reagent is now: <b><font color=\"[blob_reagent_datum.color]\">[blob_reagent_datum.name]</b></font>!"
	src << "The <b><font color=\"[blob_reagent_datum.color]\">[blob_reagent_datum.name]</b></font> reagent [blob_reagent_datum.description]"

/mob/camera/blob/verb/blob_help()
	set category = "Blob"
	set name = "*Blob Help*"
	set desc = "Help on how to blob."
	src << "<b>As the overmind, you can control the blob!</b>"
	src << "Your blob reagent is: <b><font color=\"[blob_reagent_datum.color]\">[blob_reagent_datum.name]</b></font>!"
	src << "The <b><font color=\"[blob_reagent_datum.color]\">[blob_reagent_datum.name]</b></font> reagent [blob_reagent_datum.description]"
	src << "<b>You can expand, which will attack people, damage objects, or place a Normal Blob if the tile is clear.</b>"
	src << "<i>Normal Blobs</i> will expand your reach and can be upgraded into special blobs that perform certain functions."
	src << "<b>You can upgrade normal blobs into the following types of blob:</b>"
	src << "<i>Shield Blobs</i> are strong and expensive blobs which take more damage. In additon, they are fireproof and can block air, use these to protect yourself from station fires."
	src << "<i>Resource Blobs</i> are blobs which produce more resources for you, build as many of these as possible to consume the station. This type of blob must be placed near node blobs or your core to work."
	src << "<i>Factory Blobs</i> are blobs that spawn blob spores which will attack nearby enemies. This type of blob must be placed near node blobs or your core to work."
	src << "<i>Blobbernauts</i> can be produced from factories for a cost, and are hard to kill, powerful, and moderately smart. The factory used to create one will become briefly fragile and unable to produce spores."
	src << "<i>Node Blobs</i> are blobs which grow, like the core. Like the core it can activate resource and factory blobs."
	src << "<b>In addition to the buttons on your HUD, there are a few click shortcuts to speed up expansion and defense.</b>"
	src << "<b>Shortcuts:</b> Click = Expand Blob <b>|</b> Middle Mouse Click = Rally Spores <b>|</b> Ctrl Click = Create Shield Blob <b>|</b> Alt Click = Remove Blob"
	src << "Attempting to talk will send a message to all other overminds, allowing you to coordinate with them."

/datum/action/innate/blob_earlyhelp
	name = "Blob Help"
	button_icon_state = "blob"
	background_icon_state = "bg_alien"

/datum/action/innate/blob_earlyhelp/CheckRemoval()
	if(ticker.mode.name != "blob" || !ishuman(owner))
		return 1
	var/datum/game_mode/blob/B = ticker.mode
	if(!owner.mind || !(owner.mind in B.infected_crew))
		return 1
	return 0

/datum/action/innate/blob_earlyhelp/Activate()
	owner << "<b>You are a blob!</b>"
	owner << "You will shortly burst, and should find a quiet place to do so, out of sight of the station."
	owner << "Alternatively, you could burst near a place that would hinder the station, such as telecomms or science."
	owner << "Once you burst, you can get additional information by <b>pressing this button again.</b>"