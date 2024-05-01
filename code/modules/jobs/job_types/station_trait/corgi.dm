/datum/job/corgi
	title = JOB_CORGI
	description = "Get your doggo legs, assist people, ask the HoP to pet you, all while getting sporiadically buffed by observers."
	faction = FACTION_STATION
	total_positions = 0
	spawn_positions = 0
	supervisors = SUPERVISOR_HOP
	spawn_type = /mob/living/basic/pet/dog/corgi
	config_tag = "CORGI"
	random_spawns_possible = FALSE
	display_order = JOB_DISPLAY_ORDER_CORGI
	departments_list = list(/datum/job_department/cargo)
	mail_goodies = list(
		/obj/item/dog_bone = 1,
		/obj/item/clothing/neck/petcollar = 1,
	)
	rpg_title = "Royal Hound"
	allow_bureaucratic_error = FALSE
	job_flags = STATION_TRAIT_JOB_FLAGS | JOB_NEW_PLAYER_JOINABLE | JOB_EQUIP_RANK
	///Make sure that players that reached CC without dying once get an achievement at the end of the round.
	var/list/corgi_cheevo_callbacks

/datum/job/corgi/get_roundstart_spawn_point()
	return find_safe_turf(extended_safety_checks = TRUE, dense_atoms = FALSE)

/datum/job/corgi/get_spawn_mob(client/player_client, atom/spawn_point)
	var/static/ian_accessible = TRUE
	var/mob/living/basic/pet/dog/corgi/dog
	if(!ian_accessible)
		ian_accessible = FALSE
		dog = locate(/mob/living/basic/pet/dog/corgi/ian) in GLOB.mob_list
		if(!dog) //it may be a puppy, so let's double-check
			dog = locate(/mob/living/basic/pet/dog/corgi/puppy/ian) in GLOB.mob_list
		if(dog && !dog.mind && dog.stat == CONSCIOUS) //doggo.exe found and not already running or crashed
			return dog

	if(prob(50) && !(locate(/mob/living/basic/pet/dog/corgi/lisa) in GLOB.mob_list))
		dog = new /mob/living/basic/pet/dog/corgi/lisa(spawn_point)
	else
		dog = new spawn_type(spawn_point)
		dog.fully_replace_character_name(dog.real_name, pick(GLOB.dog_names))
	return dog

/datum/job/corgi/after_spawn(mob/living/basic/pet/dog/corgi/spawned, client/player_client)
	. = ..()
	if(!istype(spawned, spawn_type))
		return

	// Makes this station trait job more interesting. They probably won't go anywhere without a little external help.

	// Also gives 'em a couple extra lives to survive eventual tiders.
	spawned.AddComponent(/datum/component/multiple_lives, 2)
	RegisterSignal(spawned, COMSIG_ON_MULTIPLE_LIVES_RESPAWN, PROC_REF(do_corgi_respawn))

	add_components(spawned)

	var/datum/callback/cheevo_callback = CALLBACK(src, PROC_REF(award_cheevo), spawned)
	SSticker.round_end_events += cheevo_callback
	LAZYSET(corgi_cheevo_callbacks, REF(spawned), cheevo_callback)
	RegisterSignals(spawned, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING), PROC_REF(void_cheevo))

///Award the achievement if conditions are met.
/datum/job/corgi/proc/award_cheevo(mob/living/basic/pet/dog/corgi/dog)
	if(dog.client && dog.onCentCom())
		dog.client.give_award(/datum/award/achievement/jobs/corgi_lossless, dog)

/datum/job/corgi/proc/void_cheevo(mob/living/basic/pet/dog/corgi/dog)
	SIGNAL_HANDLER
	var/corgi_ref = REF(dog)
	SSticker.round_end_events -= corgi_cheevo_callbacks[corgi_ref]
	LAZYREMOVE(corgi_cheevo_callbacks, corgi_ref)
	UnregisterSignal(dog, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING))

///Manages adding the deadchat component to the doggo as well as other bits like squeezing through doors.
/datum/job/corgi/proc/add_components(mob/living/basic/pet/dog/corgi/dog)
	dog.AddElement(/datum/element/door_squeeze_through)

	var/dchat_commands
	if(isnull(dchat_commands))
		dchat_commands = list(
			"up" = CALLBACK(src, PROC_REF(signal_dir), dog, "up"),
			"down" = CALLBACK(src, PROC_REF(signal_dir), dog, "down"),
			"left" = CALLBACK(src, PROC_REF(signal_dir), dog, "left"),
			"right" = CALLBACK(src, PROC_REF(signal_dir), dog, "right"),
			"spin" = CALLBACK(dog, TYPE_PROC_REF(/mob, emote), dog, "spin"),
			"bark" = CALLBACK(dog, TYPE_PROC_REF(/mob/living/basic/pet/dog/corgi, bork)),
			"careful" = CALLBACK(src, PROC_REF(be_careful), dog),
			"goodboy" = CALLBACK(src, PROC_REF(summon_treat), dog),
			"speed" = CALLBACK(src, PROC_REF(grant_speed), dog),
			"protect" = CALLBACK(src, PROC_REF(grant_protection), dog),
			"voiceofgod" = CALLBACK(src, PROC_REF(grant_voice_of_god), dog),
			"atmosres" = CALLBACK(src, PROC_REF(grant_atmos_resist), dog),
			"teleaway" = CALLBACK(src, PROC_REF(teleport_away), dog),
			"tipoftheround" = CALLBACK(src, PROC_REF(give_tip_of_the_round), dog),
		)
	var/static/dchat_cooldowns = list(
		"tipoftheround" = 6 MINUTES,
		"goodboy" = 7 MINUTES,
		"speed" = 8 MINUTES,
		"protect" = 8 MINUTES,
		"voiceofgod" = 9 MINUTES,
		"teleaway" = 9 MINUTES,
		"atmosres" = 10 MINUTES,
	)
	var/static/dchat_tooltips = list(
		"goodboy" = "give 'em a treat, which they can use to restore their health",
		"speed" = "extra action and movespeed for 90 seconds",
		"protect" = "reduces damage taken for 45 seconds",
		"voiceofgod" = "the next message spoken will be as if they've got the Voice of God",
		"atmosres" = "grants heat and pressure resistance for 90 seconds",
		"teleaway" = "teleport the dog away, preferably somewhere safe",
		"tipoftheround" = "give 'em a tip, like the ones you see in the lobby while the game is starting",
	)
	dog.AddComponent(/datum/component/deadchat_control, DEMOCRACY_MODE, dchat_commands, 18 SECONDS, null, dchat_cooldowns, dchat_tooltips)

/// Moves the dog somewhere safe, and makes sure the deadchat_control comp and equipment are retained.
/datum/job/corgi/proc/do_corgi_respawn(mob/living/basic/pet/dog/corgi/old_dog, mob/living/basic/pet/dog/corgi/new_dog, gibbed, lives_left)
	SIGNAL_HANDLER

	var/turf/current_turf = get_turf(new_dog)
	var/turf/adventure_turf = find_safe_turf(extended_safety_checks = TRUE, dense_atoms = FALSE)

	do_smoke(location = current_turf)
	if(adventure_turf)
		new_dog.forceMove(adventure_turf)
		do_smoke(location = adventure_turf)
		playsound(adventure_turf, 'sound/magic/teleport_diss.ogg', 40)
	playsound(current_turf, 'sound/magic/teleport_diss.ogg', 40)

	if(!gibbed) //the doggo is the same. We don't need to reapply the equipment and stuff.s
		return

	add_components(new_dog)

	if(lives_left)
		RegisterSignal(new_dog, COMSIG_ON_MULTIPLE_LIVES_RESPAWN, PROC_REF(do_corgi_respawn))

	if(old_dog.inventory_back)
		var/obj/item/old_dog_back = old_dog.inventory_back
		old_dog.inventory_back = null
		old_dog_back.forceMove(new_dog)
		new_dog.inventory_back = old_dog_back

	if(old_dog.inventory_head)
		var/obj/item/old_dog_hat = old_dog.inventory_head
		old_dog.inventory_head = null
		new_dog.place_on_head(old_dog_hat)

	if(old_dog.collar)
		var/obj/item/clothing/neck/petcollar/collar = old_dog.collar
		collar.forceMove(new_dog)
		old_dog.collar = null
		new_dog.collar = collar

	new_dog.update_corgi_fluff()
	new_dog.regenerate_icons()

/datum/job/corgi/proc/signal_dir(mob/living/basic/pet/dog/corgi/dog, direction)
	var/message = pick(
		"Your sixth sense is tingling, pointing <b>[direction]</b>ward.",
		"Something is telling you to tread <b>[direction]</b>... or maybe not.",
		"Observers suggests you go <b>[direction]</b>.",
		"The spirits are heeding you <b>[direction]</b>.",
	)
	to_chat(dog, span_deadsay(message))

/datum/job/corgi/proc/be_careful(mob/living/basic/pet/dog/corgi/dog)
	var/message = pick(
		"Your sixth sense is telling you to be careful...",
		"You feel danger ahead...",
		"Observers are hoping you stay safe.,,",
	)
	to_chat(dog, message)

/datum/job/corgi/proc/summon_treat(mob/living/basic/pet/dog/corgi/dog)
	var/atom/location = dog.loc.drop_location()
	var/obj/item/dog_bone/treat = new (location)
	to_chat(dog, span_boldnicegreen("\a [treat] appears at your feet! Good boy."))

/datum/job/corgi/proc/grant_speed(mob/living/basic/pet/dog/corgi/dog)
	dog.apply_status_effect(/datum/status_effect/ian_speed)

/datum/job/corgi/proc/grant_protection(mob/living/basic/pet/dog/corgi/dog)
	dog.apply_status_effect(/datum/status_effect/ian_protection)

/datum/job/corgi/proc/grant_voice_of_god(mob/living/basic/pet/dog/corgi/dog)
	dog.apply_status_effect(/datum/status_effect/limited_buff/single_use_vog)

/datum/job/corgi/proc/grant_atmos_resist(mob/living/basic/pet/dog/corgi/dog)
	dog.apply_status_effect(/datum/status_effect/ian_atmos)

/datum/job/corgi/proc/teleport_away(mob/living/basic/pet/dog/corgi/dog)
	var/turf/current_turf = get_turf(dog)
	var/turf/safe_turf = find_safe_turf(extended_safety_checks = TRUE, dense_atoms = FALSE)
	if(!safe_turf || !do_teleport(dog, safe_turf, no_effects = TRUE))
		to_chat(dog, span_smallnotice("you feel something trying to tug you to safety... to no avail."))
		return

	do_smoke(location = current_turf)
	dog.forceMove(safe_turf)
	do_smoke(location = safe_turf)
	playsound(current_turf, 'sound/magic/teleport_diss.ogg', 40)
	playsound(safe_turf, 'sound/magic/teleport_diss.ogg', 40)

/datum/job/corgi/proc/give_tip_of_the_round(mob/living/basic/pet/dog/corgi/dog)
	send_tip_of_the_round(dog)
