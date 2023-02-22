//Do not spawn
/mob/living/simple_animal/hostile/blob
	icon = 'icons/mob/nonhuman-player/blob.dmi'
	pass_flags = PASSBLOB
	faction = list(ROLE_BLOB)
	bubble_icon = "blob"
	speak_emote = null //so we use verb_yell/verb_say/etc
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	unique_name = 1
	combat_mode = TRUE
	// ... Blob colored lighting
	lighting_cutoff_red = 20
	lighting_cutoff_green = 40
	lighting_cutoff_blue = 30
	initial_language_holder = /datum/language_holder/empty
	retreat_distance = null //! retreat doesn't obey pass_flags, so won't work on blob mobs.
	/// Blob camera that controls the blob
	var/mob/camera/blob/overmind = null
	/// The factory producing spores, blobbernauts
	var/obj/structure/blob/special/factory = null
	/// If this is related to anything else
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
		for(var/unused in 1 to 2)
			var/obj/effect/temp_visual/heal/heal_effect = new /obj/effect/temp_visual/heal(get_turf(src)) //hello yes you are being healed
			if(overmind)
				heal_effect.color = overmind.blobstrain.complementary_color
			else
				heal_effect.color = "#000000"
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
	for(var/obj/structure/blob/blob in range(1, src))
		return 1
	return ..()

/mob/living/simple_animal/hostile/blob/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null, message_range = 7, datum/saymode/saymode = null)
	if(sanitize)
		message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	var/spanned_message = say_quote(message)
	var/rendered = "<font color=\"#EE4000\"><b>\[Blob Telepathy\] [real_name]</b> [spanned_message]</font>"
	for(var/creature in GLOB.mob_list)
		if(isovermind(creature) || isblobmonster(creature))
			to_chat(creature, rendered)
		if(isobserver(creature))
			var/link = FOLLOW_LINK(creature, src)
			to_chat(creature, "[link] [rendered]")

