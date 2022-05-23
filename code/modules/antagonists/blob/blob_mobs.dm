
////////////////
// BASE TYPE //
////////////////

//Do not spawn
/mob/living/simple_animal/hostile/blob
	icon = 'icons/mob/blob.dmi'
	pass_flags = PASSBLOB
	faction = list(ROLE_BLOB)
	bubble_icon = "blob"
	speak_emote = null //so we use verb_yell/verb_say/etc
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	unique_name = 1
	combat_mode = TRUE
	see_in_dark = NIGHTVISION_FOV_RANGE
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	initial_language_holder = /datum/language_holder/empty
	retreat_distance = null //! retreat doesn't obey pass_flags, so won't work on blob mobs.
	var/mob/camera/blob/overmind = null
	var/obj/structure/blob/special/factory = null
	var/independent = FALSE

/mob/living/simple_animal/hostile/blob/update_icons()
	if(overmind)
		add_atom_colour(overmind.blobstrain.color, FIXED_COLOUR_PRIORITY)
	else
		remove_atom_colour(FIXED_COLOUR_PRIORITY)

/mob/living/simple_animal/hostile/blob/Initialize(mapload)
	. = ..()
	if(!independent) //no pulling people deep into the blob
		remove_verb(src, /mob/living/verb/pulled)
	else
		pass_flags &= ~PASSBLOB

/mob/living/simple_animal/hostile/blob/Destroy()
	if(overmind)
		overmind.blob_mobs -= src
	return ..()

/mob/living/simple_animal/hostile/blob/get_status_tab_items()
	. = ..()
	if(overmind)
		. += "Blobs to Win: [overmind.blobs_legit.len]/[overmind.blobwincount]"

/mob/living/simple_animal/hostile/blob/blob_act(obj/structure/blob/B)
	if(stat != DEAD && health < maxHealth)
		for(var/i in 1 to 2)
			var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(src)) //hello yes you are being healed
			if(overmind)
				H.color = overmind.blobstrain.complementary_color
			else
				H.color = "#000000"
		adjustHealth(-maxHealth*BLOBMOB_HEALING_MULTIPLIER)

/mob/living/simple_animal/hostile/blob/fire_act(exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature)
		adjustFireLoss(clamp(0.01 * exposed_temperature, 1, 5))
	else
		adjustFireLoss(5)

/mob/living/simple_animal/hostile/blob/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(istype(mover, /obj/structure/blob))
		return TRUE

///override to use astar/JPS instead of walk_to so we can take our blob pass_flags into account.
/mob/living/simple_animal/hostile/blob/Goto(target, delay, minimum_distance)
	if(prevent_goto_movement)
		return FALSE
	if(target == src.target)
		approaching_target = TRUE
	else
		approaching_target = FALSE

	SSmove_manager.jps_move(moving = src, chasing = target, delay = delay, repath_delay = 2 SECONDS, minimum_distance = minimum_distance, simulated_only = FALSE, skip_first = TRUE, timeout = 5 SECONDS, flags = MOVEMENT_LOOP_IGNORE_GLIDE)
	return TRUE

/mob/living/simple_animal/hostile/blob/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	for(var/obj/structure/blob/B in range(1, src))
		return 1
	return ..()

/mob/living/simple_animal/hostile/blob/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null)
	if(sanitize)
		message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	var/spanned_message = say_quote(message)
	var/rendered = "<font color=\"#EE4000\"><b>\[Blob Telepathy\] [real_name]</b> [spanned_message]</font>"
	for(var/M in GLOB.mob_list)
		if(isovermind(M) || istype(M, /mob/living/simple_animal/hostile/blob))
			to_chat(M, rendered)
		if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [rendered]")

////////////////
// BLOB SPORE //
////////////////

/mob/living/simple_animal/hostile/blob/blobspore
	name = "blob spore"
	desc = "A floating, fragile spore."
	icon_state = "blobpod"
	icon_living = "blobpod"
	health_doll_icon = "blobpod"
	health = BLOBMOB_SPORE_HEALTH
	maxHealth = BLOBMOB_SPORE_HEALTH
	verb_say = "psychically pulses"
	verb_ask = "psychically probes"
	verb_exclaim = "psychically yells"
	verb_yell = "psychically screams"
	melee_damage_lower = BLOBMOB_SPORE_DMG_LOWER
	melee_damage_upper = BLOBMOB_SPORE_DMG_UPPER
	environment_smash = ENVIRONMENT_SMASH_NONE
	obj_damage = 0
	attack_verb_continuous = "hits"
	attack_verb_simple = "hit"
	attack_sound = 'sound/weapons/genhit1.ogg'
	del_on_death = TRUE
	deathmessage = "explodes into a cloud of gas!"
	gold_core_spawnable = NO_SPAWN //gold slime cores should only spawn the independent subtype
	var/death_cloud_size = 1 //size of cloud produced from a dying spore
	var/mob/living/carbon/human/oldguy
	var/is_zombie = FALSE
	///Whether or not this is a fragile spore from Distributed Neurons
	var/is_weak = FALSE

/mob/living/simple_animal/hostile/blob/blobspore/Initialize(mapload, obj/structure/blob/special/linked_node)
	. = ..()
	AddElement(/datum/element/simple_flying)
	if(istype(linked_node))
		factory = linked_node
		factory.spores += src
		if(linked_node.overmind && istype(linked_node.overmind.blobstrain, /datum/blobstrain/reagent/distributed_neurons) && !istype(src, /mob/living/simple_animal/hostile/blob/blobspore/weak))
			notify_ghosts("A controllable spore has been created in \the [get_area(src)].", source = src, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Sentient Spore Created")
		add_cell_sample()

/mob/living/simple_animal/hostile/blob/blobspore/Life(delta_time = SSMOBS_DT, times_fired)
	if(!is_zombie && isturf(src.loc))
		for(var/mob/living/carbon/human/H in view(src,1)) //Only for corpse right next to/on same tile
			if(!is_weak && H.stat == DEAD)
				Zombify(H)
				break
	if(factory && z != factory.z)
		death()
	return ..()

/mob/living/simple_animal/hostile/blob/blobspore/attack_ghost(mob/user)
	. = ..()
	if(.)
		return
	humanize_pod(user)

/mob/living/simple_animal/hostile/blob/blobspore/proc/humanize_pod(mob/user)
	if((!overmind || istype(src, /mob/living/simple_animal/hostile/blob/blobspore/weak) || !istype(overmind.blobstrain, /datum/blobstrain/reagent/distributed_neurons)) && !is_zombie)
		return
	if(key || stat)
		return
	var/pod_ask = tgui_alert(usr, "Are you bulbous enough?", "Blob Spore", list("Yes", "No"))
	if(pod_ask == "No" || QDELETED(src))
		return
	if(key)
		to_chat(user, span_warning("Someone else already took this spore!"))
		return
	key = user.key
	log_game("[key_name(src)] took control of [name].")

/mob/living/simple_animal/hostile/blob/blobspore/proc/Zombify(mob/living/carbon/human/H)
	is_zombie = 1
	if(H.wear_suit)
		var/obj/item/clothing/suit/armor/A = H.wear_suit
		maxHealth += A.armor.melee //That zombie's got armor, I want armor!
	maxHealth += 40
	health = maxHealth
	name = "blob zombie"
	desc = "A shambling corpse animated by the blob."
	mob_biotypes |= MOB_HUMANOID
	melee_damage_lower += 8
	melee_damage_upper += 11
	obj_damage = 20 //now that it has a corpse to puppet, it can properly attack structures
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	movement_type = GROUND
	death_cloud_size = 0
	icon = H.icon
	icon_state = "zombie"
	H.hairstyle = null
	H.update_hair()
	H.forceMove(src)
	oldguy = H
	update_icons()
	visible_message(span_warning("The corpse of [H.name] suddenly rises!"))
	if(!key)
		notify_ghosts("\A [src] has been created in \the [get_area(src)].", source = src, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Blob Zombie Created")

/mob/living/simple_animal/hostile/blob/blobspore/death(gibbed)
	// On death, create a small smoke of harmful gas (s-Acid)
	var/datum/effect_system/fluid_spread/smoke/chem/spores = new
	var/turf/location = get_turf(src)

	// Create the reagents to put into the air
	create_reagents(10)



	if(overmind?.blobstrain)
		overmind.blobstrain.on_sporedeath(src)
	else
		reagents.add_reagent(/datum/reagent/toxin/spore, 10)

	// Attach the smoke spreader and setup/start it.
	spores.attach(location)
	spores.set_up(death_cloud_size, location = location, carry = reagents, silent = TRUE)
	spores.start()
	if(factory)
		factory.spore_delay = world.time + factory.spore_cooldown //put the factory on cooldown

	..()

/mob/living/simple_animal/hostile/blob/blobspore/Destroy()
	if(factory)
		factory.spores -= src
		factory = null
	if(oldguy)
		oldguy.forceMove(loc)
		oldguy = null
	return ..()

/mob/living/simple_animal/hostile/blob/blobspore/update_icons()
	if(overmind)
		add_atom_colour(overmind.blobstrain.complementary_color, FIXED_COLOUR_PRIORITY)
	else
		remove_atom_colour(FIXED_COLOUR_PRIORITY)
	if(is_zombie)
		copy_overlays(oldguy, TRUE)
		var/mutable_appearance/blob_head_overlay = mutable_appearance('icons/mob/blob.dmi', "blob_head")
		if(overmind)
			blob_head_overlay.color = overmind.blobstrain.complementary_color
		color = initial(color)//looks better.
		add_overlay(blob_head_overlay)

/mob/living/simple_animal/hostile/blob/blobspore/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_BLOBSPORE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/simple_animal/hostile/blob/blobspore/independent
	gold_core_spawnable = HOSTILE_SPAWN
	independent = TRUE

/mob/living/simple_animal/hostile/blob/blobspore/weak
	name = "fragile blob spore"
	health = 15
	maxHealth = 15
	melee_damage_lower = 1
	melee_damage_upper = 2
	death_cloud_size = 0
	is_weak = TRUE

/////////////////
// BLOBBERNAUT //
/////////////////

/mob/living/simple_animal/hostile/blob/blobbernaut
	name = "blobbernaut"
	desc = "A hulking, mobile chunk of blobmass."
	icon_state = "blobbernaut"
	icon_living = "blobbernaut"
	icon_dead = "blobbernaut_dead"
	health = BLOBMOB_BLOBBERNAUT_HEALTH
	maxHealth = BLOBMOB_BLOBBERNAUT_HEALTH
	damage_coeff = list(BRUTE = 0.5, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	melee_damage_lower = BLOBMOB_BLOBBERNAUT_DMG_SOLO_LOWER
	melee_damage_upper = BLOBMOB_BLOBBERNAUT_DMG_SOLO_UPPER
	obj_damage = BLOBMOB_BLOBBERNAUT_DMG_OBJ
	attack_verb_continuous = "slams"
	attack_verb_simple = "slam"
	attack_sound = 'sound/effects/blobattack.ogg'
	verb_say = "gurgles"
	verb_ask = "demands"
	verb_exclaim = "roars"
	verb_yell = "bellows"
	force_threshold = 10
	pressure_resistance = 50
	mob_size = MOB_SIZE_LARGE
	hud_type = /datum/hud/living/blobbernaut

/mob/living/simple_animal/hostile/blob/blobbernaut/Initialize(mapload)
	. = ..()
	add_cell_sample()

/mob/living/simple_animal/hostile/blob/blobbernaut/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_BLOBBERNAUT, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/simple_animal/hostile/blob/blobbernaut/Life(delta_time = SSMOBS_DT, times_fired)
	if(!..())
		return
	var/list/blobs_in_area = range(2, src)
	if(independent)
		return // strong independent blobbernaut that don't need no blob
	var/damagesources = 0
	if(!(locate(/obj/structure/blob) in blobs_in_area))
		damagesources++

	if(!factory)
		damagesources++
	else
		if(locate(/obj/structure/blob/special/core) in blobs_in_area)
			adjustHealth(-maxHealth*BLOBMOB_BLOBBERNAUT_HEALING_CORE * delta_time)
			var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(src)) //hello yes you are being healed
			if(overmind)
				H.color = overmind.blobstrain.complementary_color
			else
				H.color = "#000000"
		if(locate(/obj/structure/blob/special/node) in blobs_in_area)
			adjustHealth(-maxHealth*BLOBMOB_BLOBBERNAUT_HEALING_NODE * delta_time)
			var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(src))
			if(overmind)
				H.color = overmind.blobstrain.complementary_color
			else
				H.color = "#000000"

	if(damagesources)
		adjustHealth(maxHealth * BLOBMOB_BLOBBERNAUT_HEALTH_DECAY * damagesources * delta_time) //take 2.5% of max health as damage when not near the blob or if the naut has no factory, 5% if both
		var/image/I = new('icons/mob/blob.dmi', src, "nautdamage", MOB_LAYER+0.01)
		I.appearance_flags = RESET_COLOR
		if(overmind)
			I.color = overmind.blobstrain.complementary_color
		flick_overlay_view(I, src, 8)

/mob/living/simple_animal/hostile/blob/blobbernaut/AttackingTarget()
	. = ..()
	if(. && isliving(target) && overmind)
		overmind.blobstrain.blobbernaut_attack(target, src)

/mob/living/simple_animal/hostile/blob/blobbernaut/update_icons()
	..()
	if(overmind) //if we have an overmind, we're doing chemical reactions instead of pure damage
		melee_damage_lower = BLOBMOB_BLOBBERNAUT_DMG_LOWER
		melee_damage_upper = BLOBMOB_BLOBBERNAUT_DMG_UPPER
		attack_verb_continuous = overmind.blobstrain.blobbernaut_message
	else
		melee_damage_lower = initial(melee_damage_lower)
		melee_damage_upper = initial(melee_damage_upper)
		attack_verb_continuous = initial(attack_verb_continuous)

/mob/living/simple_animal/hostile/blob/blobbernaut/death(gibbed)
	..(gibbed)
	if(factory)
		factory.naut = null //remove this naut from its factory
		factory.max_integrity = initial(factory.max_integrity)
	flick("blobbernaut_death", src)

/mob/living/simple_animal/hostile/blob/blobbernaut/independent
	independent = TRUE
	gold_core_spawnable = HOSTILE_SPAWN
