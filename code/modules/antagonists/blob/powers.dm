#define BLOB_REROLL_RADIUS 60

/** Simple price check */
/mob/camera/blob/proc/can_buy(cost = 15)
	if(blob_points < cost)
		to_chat(src, span_warning("You cannot afford this, you need at least [cost] resources!"))
		balloon_alert(src, "need [cost-blob_points] more resource\s!")
		return FALSE
	add_points(-cost)
	return TRUE

/** Places the core itself */
/mob/camera/blob/proc/place_blob_core(placement_override = BLOB_NORMAL_PLACEMENT, pop_override = FALSE)
	if(placed && placement_override != BLOB_FORCE_PLACEMENT)
		return TRUE

	if(placement_override == BLOB_NORMAL_PLACEMENT)
		if(!pop_override && !check_core_visibility())
			return FALSE
		var/turf/placement = get_turf(src)
		if(placement.density)
			to_chat(src, span_warning("This spot is too dense to place a blob core on!"))
			return FALSE
		if(!is_valid_turf(placement))
			to_chat(src, span_warning("You cannot place your core here!"))
			return FALSE
		if(!check_objects_tile(placement))
			return FALSE
		if(!pop_override && world.time <= manualplace_min_time && world.time <= autoplace_max_time)
			to_chat(src, span_warning("It is too early to place your blob core!"))
			return FALSE
	else
		if(placement_override == BLOB_RANDOM_PLACEMENT)
			var/turf/force_tile = pick(GLOB.blobstart)
			forceMove(force_tile) //got overrided? you're somewhere random, motherfucker

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

/** Checks proximity for mobs */
/mob/camera/blob/proc/check_core_visibility()
	for(var/mob/living/player in range(7, src))
		if(ROLE_BLOB in player.faction)
			continue
		if(player.client)
			to_chat(src, span_warning("There is someone too close to place your blob core!"))
			return FALSE

	for(var/mob/living/player in view(13, src))
		if(ROLE_BLOB in player.faction)
			continue
		if(player.client)
			to_chat(src, span_warning("Someone could see your blob core from here!"))
			return FALSE

	return TRUE


/** Checks for previous blobs or denose objects on the tile. */
/mob/camera/blob/proc/check_objects_tile(turf/placement)
	for(var/obj/object in placement)
		if(istype(object, /obj/structure/blob))
			if(istype(object, /obj/structure/blob/normal))
				qdel(object)
			else
				to_chat(src, span_warning("There is already a blob here!"))
				return FALSE
		else
			if(object.density)
				to_chat(src, span_warning("This spot is too dense to place a blob core on!"))
				return FALSE

	return TRUE

/** Moves the core elsewhere. */
/mob/camera/blob/proc/transport_core()
	if(blob_core)
		forceMove(blob_core.drop_location())

/** Jumps to a node */
/mob/camera/blob/proc/jump_to_node()
	if(!length(GLOB.blob_nodes))
		return FALSE

	var/list/nodes = list()
	for(var/index in 1 to length(GLOB.blob_nodes))
		var/obj/structure/blob/special/node/blob = GLOB.blob_nodes[index]
		nodes["Blob Node #[index] ([get_area_name(blob)])"] = blob

	var/node_name = tgui_input_list(src, "Choose a node to jump to", "Node Jump", nodes)
	if(isnull(node_name) || isnull(nodes[node_name]))
		return FALSE

	var/obj/structure/blob/special/node/chosen_node = nodes[node_name]
	if(chosen_node)
		forceMove(chosen_node.loc)

/** Places important blob structures */
/mob/camera/blob/proc/create_special(price, blobstrain, min_separation, needs_node, turf/tile)
	if(!tile)
		tile = get_turf(src)
	var/obj/structure/blob/blob = (locate(/obj/structure/blob) in tile)
	if(!blob)
		to_chat(src, span_warning("There is no blob here!"))
		balloon_alert(src, "no blob here!")
		return FALSE
	if(!istype(blob, /obj/structure/blob/normal))
		to_chat(src, span_warning("Unable to use this blob, find a normal one."))
		balloon_alert(src, "need normal blob!")
		return FALSE
	if(needs_node)
		var/area/area = get_area(src)
		if(!(area.area_flags & BLOBS_ALLOWED)) //factory and resource blobs must be legit
			to_chat(src, span_warning("This type of blob must be placed on the station!"))
			balloon_alert(src, "can't place off-station!")
			return FALSE
		if(nodes_required && !(locate(/obj/structure/blob/special/node) in orange(BLOB_NODE_PULSE_RANGE, tile)) && !(locate(/obj/structure/blob/special/core) in orange(BLOB_CORE_PULSE_RANGE, tile)))
			to_chat(src, span_warning("You need to place this blob closer to a node or core!"))
			balloon_alert(src, "too far from node or core!")
			return FALSE //handholdotron 2000
	if(min_separation)
		for(var/obj/structure/blob/other_blob in orange(min_separation, tile))
			if(other_blob.type == blobstrain)
				to_chat(src, span_warning("There is a similar blob nearby, move more than [min_separation] tiles away from it!"))
				other_blob.balloon_alert(src, "too close!")
				return FALSE
	if(!can_buy(price))
		return FALSE
	var/obj/structure/blob/node = blob.change_to(blobstrain, src)
	return node

/** Toggles requiring nodes */
/mob/camera/blob/proc/toggle_node_req()
	nodes_required = !nodes_required
	if(nodes_required)
		to_chat(src, span_warning("You now require a nearby node or core to place factory and resource blobs."))
	else
		to_chat(src, span_warning("You no longer require a nearby node or core to place factory and resource blobs."))

/** Creates a shield to reflect projectiles */
/mob/camera/blob/proc/create_shield(turf/tile)
	var/obj/structure/blob/shield/shield = locate(/obj/structure/blob/shield) in tile
	if(!shield)
		shield = create_special(BLOB_UPGRADE_STRONG_COST, /obj/structure/blob/shield, 0, FALSE, tile)
		shield?.balloon_alert(src, "upgraded to [shield.name]!")
		return FALSE

	if(!can_buy(BLOB_UPGRADE_REFLECTOR_COST))
		return FALSE

	if(shield.get_integrity() < shield.max_integrity * 0.5)
		add_points(BLOB_UPGRADE_REFLECTOR_COST)
		to_chat(src, span_warning("This shield blob is too damaged to be modified properly!"))
		return FALSE

	to_chat(src, span_warning("You secrete a reflective ooze over the shield blob, allowing it to reflect projectiles at the cost of reduced integrity."))
	shield = shield.change_to(/obj/structure/blob/shield/reflective, src)
	shield.balloon_alert(src, "upgraded to [shield.name]!")

/** Preliminary check before polling ghosts. */
/mob/camera/blob/proc/create_blobbernaut()
	var/turf/current_turf = get_turf(src)
	var/obj/structure/blob/special/factory/factory = locate(/obj/structure/blob/special/factory) in current_turf
	if(!factory)
		to_chat(src, span_warning("You must be on a factory blob!"))
		return FALSE
	if(factory.naut) //if it already made a blobbernaut, it can't do it again
		to_chat(src, span_warning("This factory blob is already sustaining a blobbernaut."))
		return FALSE
	if(factory.get_integrity() < factory.max_integrity * 0.5)
		to_chat(src, span_warning("This factory blob is too damaged to sustain a blobbernaut."))
		return FALSE
	if(!can_buy(BLOBMOB_BLOBBERNAUT_RESOURCE_COST))
		return FALSE

	factory.naut = TRUE //temporary placeholder to prevent creation of more than one per factory.
	to_chat(src, span_notice("You attempt to produce a blobbernaut."))
	pick_blobbernaut_candidate(factory)

/** Polls ghosts to get a blobbernaut candidate. */
/mob/camera/blob/proc/pick_blobbernaut_candidate(obj/structure/blob/special/factory/factory)
	if(!factory)
		return

	var/list/mob/dead/observer/candidates = poll_ghost_candidates("Do you want to play as a [blobstrain.name] blobbernaut?", ROLE_BLOB, ROLE_BLOB, 50)

	if(!length(candidates))
		to_chat(src, span_warning("You could not conjure a sentience for your blobbernaut. Your points have been refunded. Try again later."))
		add_points(BLOBMOB_BLOBBERNAUT_RESOURCE_COST)
		factory.naut = null //players must answer rapidly
		return FALSE

	factory.modify_max_integrity(initial(factory.max_integrity) * 0.25) //factories that produced a blobbernaut have much lower health
	factory.update_appearance()
	factory.visible_message(span_warning("<b>The blobbernaut [pick("rips", "tears", "shreds")] its way out of the factory blob!</b>"))
	playsound(factory.loc, 'sound/effects/splat.ogg', 50, TRUE)

	var/mob/living/simple_animal/hostile/blob/blobbernaut/blobber = new /mob/living/simple_animal/hostile/blob/blobbernaut(get_turf(factory))
	flick("blobbernaut_produce", blobber)

	factory.naut = blobber
	blobber.factory = factory
	blobber.overmind = src
	blobber.update_icons()
	blobber.adjustHealth(blobber.maxHealth * 0.5)
	blob_mobs += blobber

	var/mob/dead/observer/player = pick(candidates)
	blobber.key = player.key

	SEND_SOUND(blobber, sound('sound/effects/blobattack.ogg'))
	SEND_SOUND(blobber, sound('sound/effects/attackblob.ogg'))
	to_chat(blobber, span_infoplain("You are powerful, hard to kill, and slowly regenerate near nodes and cores, [span_cultlarge("but will slowly die if not near the blob")] or if the factory that made you is killed."))
	to_chat(blobber, span_infoplain("You can communicate with other blobbernauts and overminds <b>telepathically</b> by attempting to speak normally"))
	to_chat(blobber, span_infoplain("Your overmind's blob reagent is: <b><font color=\"[blobstrain.color]\">[blobstrain.name]</b></font>!"))
	to_chat(blobber, span_infoplain("The <b><font color=\"[blobstrain.color]\">[blobstrain.name]</b></font> reagent [blobstrain.shortdesc ? "[blobstrain.shortdesc]" : "[blobstrain.description]"]"))

/** Moves the core */
/mob/camera/blob/proc/relocate_core()
	var/turf/tile = get_turf(src)
	var/obj/structure/blob/special/node/blob = locate(/obj/structure/blob/special/node) in tile

	if(!blob)
		to_chat(src, span_warning("You must be on a blob node!"))
		return FALSE

	if(!blob_core)
		to_chat(src, span_userdanger("You have no core and are about to die! May you rest in peace."))
		return FALSE

	var/area/area = get_area(tile)
	if(isspaceturf(tile) || area && !(area.area_flags & BLOBS_ALLOWED))
		to_chat(src, span_warning("You cannot relocate your core here!"))
		return FALSE

	if(!can_buy(BLOB_POWER_RELOCATE_COST))
		return FALSE

	var/turf/old_turf = get_turf(blob_core)
	var/old_dir = blob_core.dir
	blob_core.forceMove(tile)
	blob_core.setDir(blob.dir)
	blob.forceMove(old_turf)
	blob.setDir(old_dir)

/** Searches the tile for a blob and removes it. */
/mob/camera/blob/proc/remove_blob(turf/tile)
	var/obj/structure/blob/blob = locate() in tile

	if(!blob)
		to_chat(src, span_warning("There is no blob there!"))
		return FALSE

	if(blob.point_return < 0)
		to_chat(src, span_warning("Unable to remove this blob."))
		return FALSE

	if(max_blob_points < blob.point_return + blob_points)
		to_chat(src, span_warning("You have too many resources to remove this blob!"))
		return FALSE

	if(blob.point_return)
		add_points(blob.point_return)
		to_chat(src, span_notice("Gained [blob.point_return] resources from removing \the [blob]."))
		blob.balloon_alert(src, "+[blob.point_return] resource\s")

	qdel(blob)

	return TRUE

/** Expands to nearby tiles */
/mob/camera/blob/proc/expand_blob(turf/tile)
	if(world.time < last_attack)
		return FALSE
	var/list/possible_blobs = list()

	for(var/obj/structure/blob/blob in range(tile, 1))
		possible_blobs += blob

	if(!length(possible_blobs))
		to_chat(src, span_warning("There is no blob adjacent to the target tile!"))
		return FALSE

	if(!can_buy(BLOB_EXPAND_COST))
		return FALSE

	var/attack_success
	for(var/mob/living/player in tile)
		if(!player.can_blob_attack())
			continue
		if(ROLE_BLOB in player.faction) //no friendly/dead fire
			continue
		if(player.stat != DEAD)
			attack_success = TRUE
		blobstrain.attack_living(player, possible_blobs)

	var/obj/structure/blob/blob = locate() in tile

	if(blob)
		if(attack_success) //if we successfully attacked a turf with a blob on it, only give an attack refund
			blob.blob_attack_animation(tile, src)
			add_points(BLOB_ATTACK_REFUND)
		else
			to_chat(src, span_warning("There is a blob there!"))
			add_points(BLOB_EXPAND_COST) //otherwise, refund all of the cost
	else
		directional_attack(tile, possible_blobs, attack_success)

	if(attack_success)
		last_attack = world.time + CLICK_CD_MELEE
	else
		last_attack = world.time + CLICK_CD_RAPID


/** Finds cardinal and diagonal attack directions */
/mob/camera/blob/proc/directional_attack(turf/tile, list/possible_blobs, attack_success = FALSE)
	var/list/cardinal_blobs = list()
	var/list/diagonal_blobs = list()

	for(var/obj/structure/blob/blob in possible_blobs)
		if(get_dir(blob, tile) in GLOB.cardinals)
			cardinal_blobs += blob
		else
			diagonal_blobs += blob

	var/obj/structure/blob/attacker
	if(length(cardinal_blobs))
		attacker = pick(cardinal_blobs)
		if(!attacker.expand(tile, src))
			add_points(BLOB_ATTACK_REFUND) //assume it's attacked SOMETHING, possibly a structure
	else
		attacker = pick(diagonal_blobs)
		if(attack_success)
			attacker.blob_attack_animation(tile, src)
			playsound(attacker, 'sound/effects/splat.ogg', 50, TRUE)
			add_points(BLOB_ATTACK_REFUND)
		else
			add_points(BLOB_EXPAND_COST) //if we're attacking diagonally and didn't hit anything, refund
	return TRUE

/** Rally spores to a location */
/mob/camera/blob/proc/rally_spores(turf/tile)
	to_chat(src, "You rally your spores.")
	var/list/surrounding_turfs = block(locate(tile.x - 1, tile.y - 1, tile.z), locate(tile.x + 1, tile.y + 1, tile.z))
	if(!length(surrounding_turfs))
		return FALSE
	for(var/mob/living/simple_animal/hostile/blob/blobspore/spore as anything in blob_mobs)
		if(isturf(spore.loc) && get_dist(spore, tile) <= 35 && !spore.key)
			spore.LoseTarget()
			spore.Goto(pick(surrounding_turfs), spore.move_to_delay)

/** Opens the reroll menu to change strains */
/mob/camera/blob/proc/strain_reroll()
	if (!free_strain_rerolls && blob_points < BLOB_POWER_REROLL_COST)
		to_chat(src, span_warning("You need at least [BLOB_POWER_REROLL_COST] resources to reroll your strain again!"))
		return FALSE

	open_reroll_menu()

/** Controls changing strains */
/mob/camera/blob/proc/open_reroll_menu()
	if (!strain_choices)
		strain_choices = list()

		var/list/new_strains = GLOB.valid_blobstrains.Copy() - blobstrain.type
		for (var/unused in 1 to BLOB_POWER_REROLL_CHOICES)
			var/datum/blobstrain/strain = pick_n_take(new_strains)

			var/image/strain_icon = image('icons/mob/nonhuman-player/blob.dmi', "blob_core")
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

#undef BLOB_REROLL_RADIUS
