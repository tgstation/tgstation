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
	set desc = "Transport back to your core."
	if(blob_core)
		src.loc = blob_core.loc

/mob/camera/blob/verb/jump_to_node()
	set category = "Blob"
	set name = "Jump to Node"
	set desc = "Transport back to a selected node."
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
	B.color = blob_reagent_datum.color
	var/obj/effect/blob/N = B.change_to(blobType, src)
	return N

/mob/camera/blob/verb/create_shield_power()
	set category = "Blob"
	set name = "Create Shield Blob (10)"
	set desc = "Create a shield blob."
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
	set desc = "Create a Node."
	createSpecial(60, /obj/effect/blob/node, 5)

/mob/camera/blob/verb/create_factory()
	set category = "Blob"
	set name = "Create Factory Blob (60)"
	set desc = "Create a Spore producing blob."
	createSpecial(60, /obj/effect/blob/factory, 7)

/mob/camera/blob/verb/create_storage()
	set category = "Blob"
	set name = "Create Storage Blob (20)"
	set desc = "Create a storage tower which will store extra resources for you. This increases your max resource cap by 50."
	createSpecial(20, /obj/effect/blob/storage, 3)

/mob/camera/blob/verb/create_blobbernaut()
	set category = "Blob"
	set name = "Create Blobbernaut (20)"
	set desc = "Create a powerful blob-being, a Blobbernaut"
	var/turf/T = get_turf(src)
	var/obj/effect/blob/B = locate(/obj/effect/blob) in T
	if(!B)
		src << "<span class='warning'>You must be on a blob!</span>"
		return
	if(!istype(B, /obj/effect/blob/factory))
		src << "<span class='warning'>Unable to use this blob, find a factory blob.</span>"
		return
	if(!can_buy(20))
		return
	var/mob/living/simple_animal/hostile/blob/blobbernaut/blobber = new /mob/living/simple_animal/hostile/blob/blobbernaut (get_turf(B))
	if(blobber)
		qdel(B)
	blobber.overmind = src
	blobber.update_icons()
	blob_mobs.Add(blobber)

/mob/camera/blob/verb/relocate_core()
	set category = "Blob"
	set name = "Relocate Core (80)"
	set desc = "Relocates your core to the node you are on, your old core will be turned into a node."
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
	set desc = "Attempts to create a new blob in this tile. If the tile isn't clear we will attack it, which might clear it."
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
	set desc = "Rally the spores to move to your location."
	var/turf/T = get_turf(src)
	rally_spores(T)

/mob/camera/blob/proc/rally_spores(turf/T)
	src << "You rally your spores."
	var/list/surrounding_turfs = block(locate(T.x - 1, T.y - 1, T.z), locate(T.x + 1, T.y + 1, T.z))
	if(!surrounding_turfs.len)
		return
	for(var/mob/living/simple_animal/hostile/blob/blobspore/BS in living_mob_list)
		if(isturf(BS.loc) && get_dist(BS, T) <= 35)
			BS.LoseTarget()
			BS.Goto(pick(surrounding_turfs), BS.move_to_delay)

/mob/camera/blob/verb/split_consciousness()
	set category = "Blob"
	set name = "Split consciousness (100) (One use)"
	set desc = "Expend resources to attempt to produce another sentient overmind"
	var/turf/T = get_turf(src)
	var/obj/effect/blob/node/B = locate(/obj/effect/blob/node) in T
	if(!B)
		src << "<span class='warning'>You must be on a blob node!</span>"
		return
	if(!can_buy(100))
		return
	verbs -= /mob/camera/blob/verb/split_consciousness
	new/obj/effect/blob/core/(get_turf(B), 200, null, blob_core.point_rate, 1)
	qdel(B)
	if(ticker && ticker.mode.name == "blob")
		var/datum/game_mode/blob/BL = ticker.mode
		BL.blobwincount += initial(BL.blobwincount) //Increase the victory condition by the set amount

/mob/camera/blob/verb/blob_broadcast()
	set category = "Blob"
	set name = "Blob Broadcast"
	set desc = "Speak with your blob spores and blobbernauts as your mouthpieces. This action is free."
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
	set desc = "Replaces your chemical with a different one"
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
	src << "<i>Storage Blobs</i> are blobs which allow you to store 50 more resources. These blobs do not need to be near nodes to function."
	src << "<i>Resource Blobs</i> are blobs which produce more resources for you, build as many of these as possible to consume the station. This type of blob must be placed near node blobs or your core to work."
	src << "<i>Factory Blobs</i> are blobs that spawn blob spores which will attack nearby enemies. This type of blob must be placed near node blobs or your core to work."
	src << "<i>Node Blobs</i> are blobs which grow, like the core. Like the core it can activate resource and factory blobs."
	src << "<b>In addition to the buttons on your HUD, there are a few click shortcuts to speed up expansion and defense.</b>"
	src << "<b>Shortcuts:</b> Click = Expand Blob <b>|</b> Middle Mouse Click = Rally Spores <b>|</b> Ctrl Click = Create Shield Blob <b>|</b> Alt Click = Remove Blob"

/datum/action/innate/blob_burst
	name = "Burst"
	button_icon_state = "blob"
	background_icon_state = "bg_alien"

/datum/action/innate/blob_burst/CheckRemoval()
	if(ticker.mode.name != "blob" || !ishuman(owner))
		return 1
	var/datum/game_mode/blob/B = ticker.mode
	if(!owner.mind || !(owner.mind in B.infected_crew))
		return 1
	return 0

/datum/action/innate/blob_burst/Activate()
	var/datum/game_mode/blob/B = ticker.mode
	B.burst_blob(owner.mind)
	Remove(owner)