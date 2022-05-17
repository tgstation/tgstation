#define BLOB_REROLL_RADIUS 60

/mob/camera/blob/proc/can_buy(cost = 15)
	if(blob_points < cost)
		to_chat(src, span_warning("You cannot afford this, you need at least [cost] resources!"))
		balloon_alert(src, "need [cost-blob_points] more resource\s!")
		return FALSE
	add_points(-cost)
	return TRUE

/mob/camera/blob/proc/place_blob_core(placement_override = BLOB_NORMAL_PLACEMENT, pop_override = FALSE)
	if(placed && placement_override != BLOB_FORCE_PLACEMENT)
		return TRUE
	if(placement_override == BLOB_NORMAL_PLACEMENT)
		if(!pop_override)
			for(var/mob/living/M in range(7, src))
				if(ROLE_BLOB in M.faction)
					continue
				if(M.client)
					to_chat(src, span_warning("There is someone too close to place your blob core!"))
					return FALSE
			for(var/mob/living/M in view(13, src))
				if(ROLE_BLOB in M.faction)
					continue
				if(M.client)
					to_chat(src, span_warning("Someone could see your blob core from here!"))
					return FALSE
		var/turf/T = get_turf(src)
		if(T.density)
			to_chat(src, span_warning("This spot is too dense to place a blob core on!"))
			return FALSE
		if(!is_valid_turf(T))
			to_chat(src, span_warning("You cannot place your core here!"))
			return FALSE
		for(var/obj/O in T)
			if(istype(O, /obj/structure/blob))
				if(istype(O, /obj/structure/blob/normal))
					qdel(O)
				else
					to_chat(src, span_warning("There is already a blob here!"))
					return FALSE
			else if(O.density)
				to_chat(src, span_warning("This spot is too dense to place a blob core on!"))
				return FALSE
		if(!pop_override && world.time <= manualplace_min_time && world.time <= autoplace_max_time)
			to_chat(src, span_warning("It is too early to place your blob core!"))
			return FALSE
	else if(placement_override == BLOB_RANDOM_PLACEMENT)
		var/turf/T = pick(GLOB.blobstart)
		forceMove(T) //got overrided? you're somewhere random, motherfucker
	if(placed && blob_core)
		blob_core.forceMove(loc)
	else
		var/obj/structure/blob/special/core/core = new(get_turf(src), src, 1)
		core.overmind = src
		blobs_legit += src
		blob_core = core
		core.update_appearance()
	update_health_hud()
	placed = TRUE
	announcement_time = world.time + OVERMIND_ANNOUNCEMENT_MAX_TIME
	return TRUE

/mob/camera/blob/proc/transport_core()
	if(blob_core)
		forceMove(blob_core.drop_location())

/mob/camera/blob/proc/jump_to_node()
	if(GLOB.blob_nodes.len)
		var/list/nodes = list()
		for(var/i in 1 to GLOB.blob_nodes.len)
			var/obj/structure/blob/special/node/B = GLOB.blob_nodes[i]
			nodes["Blob Node #[i] ([get_area_name(B)])"] = B
		var/node_name = tgui_input_list(src, "Choose a node to jump to", "Node Jump", nodes)
		if(isnull(node_name))
			return FALSE
		if(isnull(nodes[node_name]))
			return FALSE
		var/obj/structure/blob/special/node/chosen_node = nodes[node_name]
		if(chosen_node)
			forceMove(chosen_node.loc)

/mob/camera/blob/proc/createSpecial(price, blobstrain, minSeparation, needsNode, turf/T)
	if(!T)
		T = get_turf(src)
	var/obj/structure/blob/B = (locate(/obj/structure/blob) in T)
	if(!B)
		to_chat(src, span_warning("There is no blob here!"))
		balloon_alert(src, "no blob here!")
		return
	if(!istype(B, /obj/structure/blob/normal))
		to_chat(src, span_warning("Unable to use this blob, find a normal one."))
		balloon_alert(src, "need normal blob!")
		return
	if(needsNode)
		var/area/A = get_area(src)
		if(!(A.area_flags & BLOBS_ALLOWED)) //factory and resource blobs must be legit
			to_chat(src, span_warning("This type of blob must be placed on the station!"))
			balloon_alert(src, "can't place off-station!")
			return
		if(nodes_required && !(locate(/obj/structure/blob/special/node) in orange(BLOB_NODE_PULSE_RANGE, T)) && !(locate(/obj/structure/blob/special/core) in orange(BLOB_CORE_PULSE_RANGE, T)))
			to_chat(src, span_warning("You need to place this blob closer to a node or core!"))
			balloon_alert(src, "too far from node or core!")
			return //handholdotron 2000
	if(minSeparation)
		for(var/obj/structure/blob/L in orange(minSeparation, T))
			if(L.type == blobstrain)
				to_chat(src, span_warning("There is a similar blob nearby, move more than [minSeparation] tiles away from it!"))
				L.balloon_alert(src, "too close!")
				return
	if(!can_buy(price))
		return
	var/obj/structure/blob/N = B.change_to(blobstrain, src)
	return N

/mob/camera/blob/proc/toggle_node_req()
	nodes_required = !nodes_required
	if(nodes_required)
		to_chat(src, span_warning("You now require a nearby node or core to place factory and resource blobs."))
	else
		to_chat(src, span_warning("You no longer require a nearby node or core to place factory and resource blobs."))

/mob/camera/blob/proc/create_shield(turf/T)
	var/obj/structure/blob/shield/S = locate(/obj/structure/blob/shield) in T
	if(S)
		if(!can_buy(BLOB_UPGRADE_REFLECTOR_COST))
			return
		if(S.get_integrity() < S.max_integrity * 0.5)
			add_points(BLOB_UPGRADE_REFLECTOR_COST)
			to_chat(src, span_warning("This shield blob is too damaged to be modified properly!"))
			return
		to_chat(src, span_warning("You secrete a reflective ooze over the shield blob, allowing it to reflect projectiles at the cost of reduced integrity."))
		S = S.change_to(/obj/structure/blob/shield/reflective, src)
		S.balloon_alert(src, "upgraded to [S.name]!")
	else
		S = createSpecial(BLOB_UPGRADE_STRONG_COST, /obj/structure/blob/shield, 0, FALSE, T)
		S?.balloon_alert(src, "upgraded to [S.name]!")

/mob/camera/blob/proc/create_blobbernaut()
	var/turf/T = get_turf(src)
	var/obj/structure/blob/special/factory/B = locate(/obj/structure/blob/special/factory) in T
	if(!B)
		to_chat(src, span_warning("You must be on a factory blob!"))
		return
	if(B.naut) //if it already made a blobbernaut, it can't do it again
		to_chat(src, span_warning("This factory blob is already sustaining a blobbernaut."))
		return
	if(B.get_integrity() < B.max_integrity * 0.5)
		to_chat(src, span_warning("This factory blob is too damaged to sustain a blobbernaut."))
		return
	if(!can_buy(BLOBMOB_BLOBBERNAUT_RESOURCE_COST))
		return

	B.naut = TRUE //temporary placeholder to prevent creation of more than one per factory.
	to_chat(src, span_notice("You attempt to produce a blobbernaut."))
	var/list/mob/dead/observer/candidates = poll_ghost_candidates("Do you want to play as a [blobstrain.name] blobbernaut?", ROLE_BLOB, ROLE_BLOB, 50) //players must answer rapidly
	if(LAZYLEN(candidates)) //if we got at least one candidate, they're a blobbernaut now.
		B.modify_max_integrity(initial(B.max_integrity) * 0.25) //factories that produced a blobbernaut have much lower health
		B.update_appearance()
		B.visible_message(span_warning("<b>The blobbernaut [pick("rips", "tears", "shreds")] its way out of the factory blob!</b>"))
		playsound(B.loc, 'sound/effects/splat.ogg', 50, TRUE)
		var/mob/living/simple_animal/hostile/blob/blobbernaut/blobber = new /mob/living/simple_animal/hostile/blob/blobbernaut(get_turf(B))
		flick("blobbernaut_produce", blobber)
		B.naut = blobber
		blobber.factory = B
		blobber.overmind = src
		blobber.update_icons()
		blobber.adjustHealth(blobber.maxHealth * 0.5)
		blob_mobs += blobber
		var/mob/dead/observer/C = pick(candidates)
		blobber.key = C.key
		SEND_SOUND(blobber, sound('sound/effects/blobattack.ogg'))
		SEND_SOUND(blobber, sound('sound/effects/attackblob.ogg'))
		to_chat(blobber, "<b>You are a blobbernaut!</b>")
		to_chat(blobber, "You are powerful, hard to kill, and slowly regenerate near nodes and cores, [span_cultlarge("but will slowly die if not near the blob")] or if the factory that made you is killed.")
		to_chat(blobber, "You can communicate with other blobbernauts and overminds via <b>:b</b>")
		to_chat(blobber, "Your overmind's blob reagent is: <b><font color=\"[blobstrain.color]\">[blobstrain.name]</b></font>!")
		to_chat(blobber, "The <b><font color=\"[blobstrain.color]\">[blobstrain.name]</b></font> reagent [blobstrain.shortdesc ? "[blobstrain.shortdesc]" : "[blobstrain.description]"]")
	else
		to_chat(src, span_warning("You could not conjure a sentience for your blobbernaut. Your points have been refunded. Try again later."))
		add_points(BLOBMOB_BLOBBERNAUT_RESOURCE_COST)
		B.naut = null

/mob/camera/blob/proc/relocate_core()
	var/turf/T = get_turf(src)
	var/obj/structure/blob/special/node/B = locate(/obj/structure/blob/special/node) in T
	if(!B)
		to_chat(src, span_warning("You must be on a blob node!"))
		return
	if(!blob_core)
		to_chat(src, span_userdanger("You have no core and are about to die! May you rest in peace."))
		return
	var/area/A = get_area(T)
	if(isspaceturf(T) || A && !(A.area_flags & BLOBS_ALLOWED))
		to_chat(src, span_warning("You cannot relocate your core here!"))
		return
	if(!can_buy(BLOB_POWER_RELOCATE_COST))
		return
	var/turf/old_turf = get_turf(blob_core)
	var/olddir = blob_core.dir
	blob_core.forceMove(T)
	blob_core.setDir(B.dir)
	B.forceMove(old_turf)
	B.setDir(olddir)

/mob/camera/blob/proc/remove_blob(turf/T)
	var/obj/structure/blob/B = locate() in T
	if(!B)
		to_chat(src, span_warning("There is no blob there!"))
		return
	if(B.point_return < 0)
		to_chat(src, span_warning("Unable to remove this blob."))
		return
	if(max_blob_points < B.point_return + blob_points)
		to_chat(src, span_warning("You have too many resources to remove this blob!"))
		return
	if(B.point_return)
		add_points(B.point_return)
		to_chat(src, span_notice("Gained [B.point_return] resources from removing \the [B]."))
		B.balloon_alert(src, "+[B.point_return] resource\s")
	qdel(B)

/mob/camera/blob/proc/expand_blob(turf/T)
	if(world.time < last_attack)
		return
	var/list/possibleblobs = list()
	for(var/obj/structure/blob/AB in range(T, 1))
		possibleblobs += AB
	if(!possibleblobs.len)
		to_chat(src, span_warning("There is no blob adjacent to the target tile!"))
		return
	if(can_buy(BLOB_EXPAND_COST))
		var/attacksuccess = FALSE
		for(var/mob/living/L in T)
			if(ROLE_BLOB in L.faction) //no friendly/dead fire
				continue
			if(L.stat != DEAD)
				attacksuccess = TRUE
			blobstrain.attack_living(L, possibleblobs)
		var/obj/structure/blob/B = locate() in T
		if(B)
			if(attacksuccess) //if we successfully attacked a turf with a blob on it, only give an attack refund
				B.blob_attack_animation(T, src)
				add_points(BLOB_ATTACK_REFUND)
			else
				to_chat(src, span_warning("There is a blob there!"))
				add_points(BLOB_EXPAND_COST) //otherwise, refund all of the cost
		else
			var/list/cardinalblobs = list()
			var/list/diagonalblobs = list()
			for(var/I in possibleblobs)
				var/obj/structure/blob/IB = I
				if(get_dir(IB, T) in GLOB.cardinals)
					cardinalblobs += IB
				else
					diagonalblobs += IB
			var/obj/structure/blob/OB
			if(cardinalblobs.len)
				OB = pick(cardinalblobs)
				if(!OB.expand(T, src))
					add_points(BLOB_ATTACK_REFUND) //assume it's attacked SOMETHING, possibly a structure
			else
				OB = pick(diagonalblobs)
				if(attacksuccess)
					OB.blob_attack_animation(T, src)
					playsound(OB, 'sound/effects/splat.ogg', 50, TRUE)
					add_points(BLOB_ATTACK_REFUND)
				else
					add_points(BLOB_EXPAND_COST) //if we're attacking diagonally and didn't hit anything, refund
		if(attacksuccess)
			last_attack = world.time + CLICK_CD_MELEE
		else
			last_attack = world.time + CLICK_CD_RAPID

/mob/camera/blob/proc/rally_spores(turf/T)
	to_chat(src, "You rally your spores.")
	var/list/surrounding_turfs = block(locate(T.x - 1, T.y - 1, T.z), locate(T.x + 1, T.y + 1, T.z))
	if(!surrounding_turfs.len)
		return
	for(var/mob/living/simple_animal/hostile/blob/blobspore/BS in blob_mobs)
		if(isturf(BS.loc) && get_dist(BS, T) <= 35 && !BS.key)
			BS.LoseTarget()
			BS.Goto(pick(surrounding_turfs), BS.move_to_delay)

/mob/camera/blob/proc/strain_reroll()
	if (!free_strain_rerolls && blob_points < BLOB_POWER_REROLL_COST)
		to_chat(src, span_warning("You need at least [BLOB_POWER_REROLL_COST] resources to reroll your strain again!"))
		return

	open_reroll_menu()

/// Open the menu to reroll strains
/mob/camera/blob/proc/open_reroll_menu()
	if (!strain_choices)
		strain_choices = list()

		var/list/new_strains = GLOB.valid_blobstrains.Copy() - blobstrain.type
		for (var/_ in 1 to BLOB_POWER_REROLL_CHOICES)
			var/datum/blobstrain/strain = pick_n_take(new_strains)

			var/image/strain_icon = image('icons/mob/blob.dmi', "blob_core")
			strain_icon.color = initial(strain.color)

			var/info_text = span_boldnotice("[initial(strain.name)]")
			info_text += "<br>[span_notice("[initial(strain.analyzerdescdamage)]")]"
			if (!isnull(initial(strain.analyzerdesceffect)))
				info_text += "<br>[span_notice("[initial(strain.analyzerdesceffect)]")]"

			var/datum/radial_menu_choice/choice = new
			choice.image = strain_icon
			choice.info = info_text

			strain_choices[initial(strain.name)] = choice

	var/strain_result = show_radial_menu(src, src, strain_choices, radius = BLOB_REROLL_RADIUS, tooltips = TRUE)
	if (isnull(strain_result))
		return

	if (!free_strain_rerolls && !can_buy(BLOB_POWER_REROLL_COST))
		return

	for (var/_other_strain in GLOB.valid_blobstrains)
		var/datum/blobstrain/other_strain = _other_strain
		if (initial(other_strain.name) == strain_result)
			set_strain(other_strain)

			if (free_strain_rerolls)
				free_strain_rerolls -= 1

			last_reroll_time = world.time
			strain_choices = null

			return

/mob/camera/blob/proc/blob_help()
	to_chat(src, "<b>As the overmind, you can control the blob!</b>")
	to_chat(src, "Your blob reagent is: <b><font color=\"[blobstrain.color]\">[blobstrain.name]</b></font>!")
	to_chat(src, "The <b><font color=\"[blobstrain.color]\">[blobstrain.name]</b></font> reagent [blobstrain.description]")
	if(blobstrain.effectdesc)
		to_chat(src, "The <b><font color=\"[blobstrain.color]\">[blobstrain.name]</b></font> reagent [blobstrain.effectdesc]")
	to_chat(src, "<b>You can expand, which will attack people, damage objects, or place a Normal Blob if the tile is clear.</b>")
	to_chat(src, "<i>Normal Blobs</i> will expand your reach and can be upgraded into special blobs that perform certain functions.")
	to_chat(src, "<b>You can upgrade normal blobs into the following types of blob:</b>")
	to_chat(src, "<i>Shield Blobs</i> are strong and expensive blobs which take more damage. In additon, they are fireproof and can block air, use these to protect yourself from station fires. Upgrading them again will result in a reflective blob, capable of reflecting most projectiles at the cost of the strong blob's extra health.")
	to_chat(src, "<i>Resource Blobs</i> are blobs which produce more resources for you, build as many of these as possible to consume the station. This type of blob must be placed near node blobs or your core to work.")
	to_chat(src, "<i>Factory Blobs</i> are blobs that spawn blob spores which will attack nearby enemies. This type of blob must be placed near node blobs or your core to work.")
	to_chat(src, "<i>Blobbernauts</i> can be produced from factories for a cost, and are hard to kill, powerful, and moderately smart. The factory used to create one will become fragile and briefly unable to produce spores.")
	to_chat(src, "<i>Node Blobs</i> are blobs which grow, like the core. Like the core it can activate resource and factory blobs.")
	to_chat(src, "<b>In addition to the buttons on your HUD, there are a few click shortcuts to speed up expansion and defense.</b>")
	to_chat(src, "<b>Shortcuts:</b> Click = Expand Blob <b>|</b> Middle Mouse Click = Rally Spores <b>|</b> Ctrl Click = Create Shield Blob <b>|</b> Alt Click = Remove Blob")
	to_chat(src, "Attempting to talk will send a message to all other overminds, allowing you to coordinate with them.")
	if(!placed && autoplace_max_time <= world.time)
		to_chat(src, span_big("<font color=\"#EE4000\">You will automatically place your blob core in [DisplayTimeText(autoplace_max_time - world.time)].</font>"))
		to_chat(src, span_big("<font color=\"#EE4000\">You [manualplace_min_time ? "will be able to":"can"] manually place your blob core by pressing the Place Blob Core button in the bottom right corner of the screen.</font>"))

#undef BLOB_REROLL_RADIUS
