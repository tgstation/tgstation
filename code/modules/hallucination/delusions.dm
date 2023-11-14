/// A hallucination that makes us and (possibly) other people look like something else.
/datum/hallucination/delusion
	abstract_hallucination_parent = /datum/hallucination/delusion

	/// The duration of the delusions
	var/duration = 30 SECONDS

	/// If TRUE, this delusion affects us
	var/affects_us = TRUE
	/// If TRUE, this hallucination affects all humans in existence
	var/affects_all_humans = FALSE
	/// If TRUE, people in view of our hallcuinator won't be affected (requires affects_all_humans)
	var/skip_nearby = FALSE
	/// If TRUE, we will play the wabbajack sound effect to the hallucinator
	var/play_wabbajack = FALSE
	/// If TRUE, any mob (even nonhumans) in view of our hallcuinator will be affected
	var/include_nearby_mobs = FALSE
	/// If TRUE, the delusion will constantly polymorph affected mobs
	var/randomize = FALSE

	/// The file the delusion image is made from
	var/delusion_icon_file
	/// The icon state of the delusion image
	var/delusion_icon_state
	/// Do we use a generated icon? If yes no icon file or state needed.
	var/dynamic_icon = FALSE
	/// The name of the delusion image
	var/delusion_name

	/// A list of all images we've made
	var/list/image/delusions

/datum/hallucination/delusion/New(
	mob/living/hallucinator,
	duration,
	affects_us,
	affects_all_humans,
	skip_nearby,
	play_wabbajack,
	include_nearby_mobs,
	randomize,
)

	if(isnum(duration))
		src.duration = duration
	if(!isnull(affects_us))
		src.affects_us = affects_us
	if(!isnull(affects_all_humans))
		src.affects_all_humans = affects_all_humans
	if(!isnull(skip_nearby))
		src.skip_nearby = skip_nearby
	if(!isnull(play_wabbajack))
		src.play_wabbajack = play_wabbajack
	if(!isnull(include_nearby_mobs))
		src.include_nearby_mobs = include_nearby_mobs
	if(!isnull(randomize))
		src.randomize = randomize

	return ..()

/datum/hallucination/delusion/Destroy()
	if(!QDELETED(hallucinator) && LAZYLEN(delusions))
		hallucinator.client?.images -= delusions
		LAZYNULL(delusions)

	return ..()

/datum/hallucination/delusion/start()
	if(!hallucinator.client || (!delusion_icon_file && !randomize))
		return FALSE

	feedback_details += "Delusion: [delusion_name]"

	var/list/mob/living/funny_looking_mobs = list()

	// The delusion includes others - all humans
	if(affects_all_humans)
		funny_looking_mobs |= GLOB.human_list.Copy()

	// The delusion includes us - we might be in it already, we might not
	if(affects_us)
		funny_looking_mobs |= hallucinator
	else // The delusion should not inlude us
		funny_looking_mobs -= hallucinator

	// The delusion shouldn not include anyone in view of us
	if(skip_nearby)
		for(var/mob/living/nearby_mob in view(hallucinator))
			if(nearby_mob == hallucinator) // Already handled by affects_us
				continue
			funny_looking_mobs -= nearby_mob

	// The delusion includes all mobs within view (even ones that aren't human)
	if(include_nearby_mobs)
		for(var/mob/living/nearby_mob in get_hearers_in_view(15, hallucinator))
			if(nearby_mob == hallucinator) // Already handled by affects_us
				continue
			funny_looking_mobs |= nearby_mob

	for(var/mob/living/found_mob in funny_looking_mobs)
		var/image/funny_image
		if(randomize)
			var/datum/hallucination/delusion/random_delusion
			while(!random_delusion)
				random_delusion = get_random_valid_hallucination_subtype(/datum/hallucination/delusion/preset)
				if(initial(random_delusion.dynamic_icon))
					random_delusion = null // try again

			funny_image = image(initial(random_delusion.delusion_icon_file), found_mob, initial(random_delusion.delusion_icon_state))
			funny_image.name = initial(random_delusion.delusion_name)
			funny_image.override = TRUE
		else
			funny_image = make_delusion_image(found_mob)

		LAZYADD(delusions, funny_image)
		hallucinator.client.images |= funny_image

	if(play_wabbajack)
		to_chat(hallucinator, span_hear("...wabbajack...wabbajack..."))
		hallucinator.playsound_local(get_turf(hallucinator), 'sound/magic/staff_change.ogg', 50, TRUE)

	if(duration > 0)
		QDEL_IN(src, duration)

	return TRUE

/datum/hallucination/delusion/proc/make_delusion_image(mob/over_who)
	var/image/funny_image = image(delusion_icon_file, over_who, dynamic_icon ? "" : delusion_icon_state)
	funny_image.name = delusion_name
	funny_image.override = TRUE
	return funny_image

/// Used for making custom delusions.
/datum/hallucination/delusion/custom
	random_hallucination_weight = 0

/datum/hallucination/delusion/custom/New(
	mob/living/hallucinator,
	duration,
	affects_us,
	affects_all_humans,
	skip_nearby,
	play_wabbajack,
	include_nearby_mobs,
	randomize,
	custom_icon_file,
	custom_icon_state,
	custom_name,
)

	if(!custom_icon_file || !custom_icon_state)
		stack_trace("Custom delusion hallucination was created without any custom icon information passed.")

	src.delusion_icon_file = custom_icon_file
	src.delusion_icon_state = custom_icon_state
	src.delusion_name = custom_name

	return ..()

/datum/hallucination/delusion/preset
	abstract_hallucination_parent = /datum/hallucination/delusion/preset
	random_hallucination_weight = 2

/datum/hallucination/delusion/preset/nothing
	delusion_icon_file = 'icons/effects/effects.dmi'
	delusion_icon_state = "nothing"
	delusion_name = "..."

/datum/hallucination/delusion/preset/curse
	delusion_icon_file = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	delusion_icon_state = "curseblob"
	delusion_name = "???"

/datum/hallucination/delusion/preset/monkey
	delusion_icon_file = 'icons/mob/human/human.dmi'
	delusion_icon_state = "monkey"
	delusion_name = "monkey"

/datum/hallucination/delusion/preset/monkey/start()
	delusion_name += " ([rand(1, 999)])"
	return ..()

/datum/hallucination/delusion/preset/corgi
	delusion_icon_file = 'icons/mob/simple/pets.dmi'
	delusion_icon_state = "corgi"
	delusion_name = "corgi"

/datum/hallucination/delusion/preset/fox
	delusion_icon_file = 'icons/mob/simple/pets.dmi'
	delusion_icon_state = "fox"
	delusion_name = "fox"

/datum/hallucination/delusion/preset/pug
	delusion_icon_file = 'icons/mob/simple/pets.dmi'
	delusion_icon_state = "pug"
	delusion_name = "pug"

/datum/hallucination/delusion/preset/lisa
	delusion_icon_file = 'icons/mob/simple/pets.dmi'
	delusion_icon_state = "lisa"
	delusion_name = "lisa"

/datum/hallucination/delusion/preset/puppy
	delusion_icon_file = 'icons/mob/simple/pets.dmi'
	delusion_icon_state = "puppy"
	delusion_name = "puppy"

/datum/hallucination/delusion/preset/sloth
	delusion_icon_file = 'icons/mob/simple/pets.dmi'
	delusion_icon_state = "sloth"
	delusion_name = "sloth"

/datum/hallucination/delusion/preset/ant
	delusion_icon_file = 'icons/mob/simple/pets.dmi'
	delusion_icon_state = "ant"
	delusion_name = "ant"

/datum/hallucination/delusion/preset/cow
	delusion_icon_file = 'icons/mob/simple/cows.dmi'
	delusion_icon_state = "cow"
	delusion_name = "cow"

/datum/hallucination/delusion/preset/chicken
	delusion_icon_file = 'icons/mob/simple/animal.dmi'
	delusion_icon_state = "chicken_brown"
	delusion_name = "chicken"

/datum/hallucination/delusion/preset/chick
	delusion_icon_file = 'icons/mob/simple/animal.dmi'
	delusion_icon_state = "chick"
	delusion_name = "chick"

/datum/hallucination/delusion/preset/lizard
	delusion_icon_file = 'icons/mob/simple/animal.dmi'
	delusion_icon_state = "lizard"
	delusion_name = "lizard"

/datum/hallucination/delusion/preset/bear
	delusion_icon_file = 'icons/mob/simple/animal.dmi'
	delusion_icon_state = "bear"
	delusion_name = "bear"

/datum/hallucination/delusion/preset/tomato
	delusion_icon_file = 'icons/mob/simple/animal.dmi'
	delusion_icon_state = "tomato"
	delusion_name = "tomato"

/datum/hallucination/delusion/preset/mushroom
	delusion_icon_file = 'icons/mob/simple/animal.dmi'
	delusion_icon_state = "mushroom"
	delusion_name = "mushroom"

/datum/hallucination/delusion/preset/mouse
	delusion_icon_file = 'icons/mob/simple/animal.dmi'
	delusion_icon_state = "mouse_brown"
	delusion_name = "mouse"

/datum/hallucination/delusion/preset/parrot
	delusion_icon_file = 'icons/mob/simple/animal.dmi'
	delusion_icon_state = "parrot_fly"
	delusion_name = "parrot"

/datum/hallucination/delusion/preset/bat
	delusion_icon_file = 'icons/mob/simple/animal.dmi'
	delusion_icon_state = "bat"
	delusion_name = "bat"

/datum/hallucination/delusion/preset/butterfly
	delusion_icon_file = 'icons/mob/simple/animal.dmi'
	delusion_icon_state = "butterfly"
	delusion_name = "butterfly"

/datum/hallucination/delusion/preset/frog
	delusion_icon_file = 'icons/mob/simple/animal.dmi'
	delusion_icon_state = "frog"
	delusion_name = "frog"

/datum/hallucination/delusion/preset/crab
	delusion_icon_file = 'icons/mob/simple/animal.dmi'
	delusion_icon_state = "crab"
	delusion_name = "crab"

/datum/hallucination/delusion/preset/snake
	delusion_icon_file = 'icons/mob/simple/animal.dmi'
	delusion_icon_state = "snake"
	delusion_name = "snake"

/datum/hallucination/delusion/preset/goat
	delusion_icon_file = 'icons/mob/simple/animal.dmi'
	delusion_icon_state = "goat"
	delusion_name = "goat"

/datum/hallucination/delusion/preset/goose
	delusion_icon_file = 'icons/mob/simple/animal.dmi'
	delusion_icon_state = "goose"
	delusion_name = "goose"

/datum/hallucination/delusion/preset/pig
	delusion_icon_file = 'icons/mob/simple/animal.dmi'
	delusion_icon_state = "pig"
	delusion_name = "pig"

/datum/hallucination/delusion/preset/cockroach
	delusion_icon_file = 'icons/mob/simple/animal.dmi'
	delusion_icon_state = "cockroach"
	delusion_name = "cockroach"

/datum/hallucination/delusion/preset/faithless
	delusion_icon_file = 'icons/mob/simple/animal.dmi'
	delusion_icon_state = "faithless"
	delusion_name = "faithless"

/datum/hallucination/delusion/preset/thing
	delusion_icon_file = 'icons/mob/simple/animal.dmi'
	delusion_icon_state = "otherthing"
	delusion_name = "thing"

/datum/hallucination/delusion/preset/penguin
	delusion_icon_file = 'icons/mob/simple/penguins.dmi'
	delusion_icon_state = "penguin"
	delusion_name = "penguin"

/datum/hallucination/delusion/preset/rabbit
	delusion_icon_file = 'icons/mob/simple/rabbit.dmi'
	delusion_icon_state = "rabbit_white"
	delusion_name = "rabbit"

/datum/hallucination/delusion/preset/sheep
	delusion_icon_file = 'icons/mob/simple/sheep.dmi'
	delusion_icon_state = "sheep"
	delusion_name = "sheep"

/datum/hallucination/delusion/preset/gorilla
	delusion_icon_file = 'icons/mob/simple/gorilla.dmi'
	delusion_icon_state = "crawling"
	delusion_name = "gorilla"

/datum/hallucination/delusion/preset/gondola
	delusion_icon_file = 'icons/mob/simple/gondolas.dmi'
	delusion_icon_state = "gondola"
	delusion_name = "gondola"

/datum/hallucination/delusion/preset/slime
	delusion_icon_file = 'icons/mob/simple/slimes.dmi'
	delusion_icon_state = "rainbow adult slime"
	delusion_name = "slime"

/datum/hallucination/delusion/preset/hivebot
	delusion_icon_file = 'icons/mob/simple/hivebot.dmi'
	delusion_icon_state = "basic"
	delusion_name = "hivebot"

/datum/hallucination/delusion/preset/spider
	delusion_icon_file = 'icons/mob/simple/arachnoid.dmi'
	delusion_icon_state = "guard"
	delusion_name = "guard"

/datum/hallucination/delusion/preset/spider_baby
	delusion_icon_file = 'icons/mob/simple/arachnoid.dmi'
	delusion_icon_state = "spiderling"
	delusion_name = "spiderling"

/datum/hallucination/delusion/preset/prophet
	delusion_icon_file = 'icons/mob/nonhuman-player/eldritch_mobs.dmi'
	delusion_icon_state = "raw_prophet"
	delusion_name = "raw prophet"

/datum/hallucination/delusion/preset/stalker
	delusion_icon_file = 'icons/mob/nonhuman-player/eldritch_mobs.dmi'
	delusion_icon_state = "stalker"
	delusion_name = "stalker"

/datum/hallucination/delusion/preset/blobpod
	delusion_icon_file = 'icons/mob/nonhuman-player/blob.dmi'
	delusion_icon_state = "blobpod"
	delusion_name = "blobpod"

/datum/hallucination/delusion/preset/blobbernaut
	delusion_icon_file = 'icons/mob/nonhuman-player/blob.dmi'
	delusion_icon_state = "blobbernaut"
	delusion_name = "blobbernaut"

/datum/hallucination/delusion/preset/guardian
	delusion_icon_file = 'icons/mob/nonhuman-player/guardian.dmi'
	delusion_icon_state = "techexample"
	delusion_name = "guardian"

/datum/hallucination/delusion/preset/space_dragon
	delusion_icon_file = 'icons/mob/nonhuman-player/spacedragon.dmi'
	delusion_icon_state = "spacedragon"
	delusion_name = "space dragon"

/datum/hallucination/delusion/preset/alien_queen
	delusion_icon_file = 'icons/mob/nonhuman-player/alienqueen.dmi'
	delusion_icon_state = "alienq"
	delusion_name = "alien queen"

/datum/hallucination/delusion/preset/facehugger
	delusion_icon_file = 'icons/mob/nonhuman-player/alien.dmi'
	delusion_icon_state = "facehugger"
	delusion_name = "facehugger"

/datum/hallucination/delusion/preset/larva
	delusion_icon_file = 'icons/mob/nonhuman-player/alien.dmi'
	delusion_icon_state = "larva0"
	delusion_name = "larva"

/datum/hallucination/delusion/preset/alien_drone
	delusion_icon_file = 'icons/mob/nonhuman-player/alien.dmi'
	delusion_icon_state = "alienh"
	delusion_name = "alien drone"

/datum/hallucination/delusion/preset/lusty_xenomaid
	delusion_icon_file = 'icons/mob/nonhuman-player/alien.dmi'
	delusion_icon_state = "maid"
	delusion_name = "lusty xenomaid"

/datum/hallucination/delusion/preset/legion
	delusion_icon_file = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	delusion_icon_state = "legion"
	delusion_name = "legion"

/datum/hallucination/delusion/preset/hivelord
	delusion_icon_file = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	delusion_icon_state = "hivelord"
	delusion_name = "hivelord"

/datum/hallucination/delusion/preset/gutlunch
	delusion_icon_file = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	delusion_icon_state = "gutlunch"
	delusion_name = "gutlunch"

/datum/hallucination/delusion/preset/basilisk
	delusion_icon_file = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	delusion_icon_state = "basilisk"
	delusion_name = "basilisk"

/datum/hallucination/delusion/preset/ash_whelp
	delusion_icon_file = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	delusion_icon_state = "ash_whelp"
	delusion_name = "ash_whelp"

/datum/hallucination/delusion/preset/brimdemon
	delusion_icon_file = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	delusion_icon_state = "brimdemon"
	delusion_name = "brimdemon"

/datum/hallucination/delusion/preset/watcher
	delusion_icon_file = 'icons/mob/simple/lavaland/lavaland_monsters_wide.dmi'
	delusion_icon_state = "watcher"
	delusion_name = "watcher"

/datum/hallucination/delusion/preset/goldgrub
	delusion_icon_file = 'icons/mob/simple/lavaland/lavaland_monsters_wide.dmi'
	delusion_icon_state = "goldgrub"
	delusion_name = "goldgrub"

/datum/hallucination/delusion/preset/goliath
	delusion_icon_file = 'icons/mob/simple/lavaland/lavaland_monsters_wide.dmi'
	delusion_icon_state = "goliath"
	delusion_name = "goliath"

/datum/hallucination/delusion/preset/bileworm
	delusion_icon_file = 'icons/mob/simple/lavaland/bileworm.dmi'
	delusion_icon_state = "bileworm"
	delusion_name = "bileworm"

/datum/hallucination/delusion/preset/bubblegum
	delusion_icon_file = 'icons/mob/simple/lavaland/96x96megafauna.dmi'
	delusion_icon_state = "bubblegum"
	delusion_name = "bubblegum"

/datum/hallucination/delusion/preset/mega_legion
	delusion_icon_file = 'icons/mob/simple/lavaland/96x96megafauna.dmi'
	delusion_icon_state = "mega_legion"
	delusion_name = "mega legion"

/datum/hallucination/delusion/preset/eva
	delusion_icon_file = 'icons/mob/simple/lavaland/96x96megafauna.dmi'
	delusion_icon_state = "eva"
	delusion_name = "eva"

/datum/hallucination/delusion/preset/dragon
	delusion_icon_file = 'icons/mob/simple/lavaland/96x96megafauna.dmi'
	delusion_icon_state = "dragon"
	delusion_name = "dragon"

/datum/hallucination/delusion/preset/bubblegum
	delusion_icon_file = 'icons/mob/simple/lavaland/96x96megafauna.dmi'
	delusion_icon_state = "bubblegum"
	delusion_name = "bubblegum"

/datum/hallucination/delusion/preset/carp
	delusion_icon_file = 'icons/mob/simple/carp.dmi'
	delusion_icon_state = "carp"
	delusion_name = "carp"

/datum/hallucination/delusion/preset/eyeball
	delusion_icon_file = 'icons/mob/simple/carp.dmi'
	delusion_icon_state = "eyeball"
	delusion_name = "eyeball"

/datum/hallucination/delusion/preset/skeleton
	delusion_icon_file = 'icons/mob/human/human.dmi'
	delusion_icon_state = "skeleton"
	delusion_name = "skeleton"

/datum/hallucination/delusion/preset/zombie
	delusion_icon_file = 'icons/mob/human/human.dmi'
	delusion_icon_state = "zombie"
	delusion_name = "zombie"

/datum/hallucination/delusion/preset/demon
	delusion_icon_file = 'icons/mob/simple/demon.dmi'
	delusion_icon_state = "slaughter_demon"
	delusion_name = "demon"

/datum/hallucination/delusion/preset/cyborg
	delusion_icon_file = 'icons/mob/silicon/robots.dmi'
	delusion_icon_state = "robot"
	delusion_name = "cyborg"
	play_wabbajack = TRUE

/datum/hallucination/delusion/preset/cyborg/make_delusion_image(mob/over_who)
	. = ..()
	hallucinator.playsound_local(get_turf(over_who), 'sound/voice/liveagain.ogg', 75, TRUE)

/datum/hallucination/delusion/preset/ghost
	delusion_icon_file = 'icons/mob/simple/mob.dmi'
	delusion_icon_state = "ghost"
	delusion_name = "ghost"
	affects_all_humans = TRUE

/datum/hallucination/delusion/preset/ghost/make_delusion_image(mob/over_who)
	var/image/funny_image = ..()
	funny_image.name = over_who.name
	DO_FLOATING_ANIM(funny_image)
	return funny_image

/datum/hallucination/delusion/preset/revenant
	delusion_icon_file = 'icons/mob/simple/mob.dmi'
	delusion_icon_state = "revenant_idle"
	delusion_name = "revenant"

/datum/hallucination/delusion/preset/syndies
	random_hallucination_weight = 1
	dynamic_icon = TRUE
	delusion_name = "Syndicate"
	affects_all_humans = TRUE
	affects_us = FALSE

/datum/hallucination/delusion/preset/syndies/make_delusion_image(mob/over_who)
	delusion_icon_file = getFlatIcon(get_dynamic_human_appearance(
		mob_spawn_path = pick(
			/obj/effect/mob_spawn/corpse/human/syndicatesoldier,
			/obj/effect/mob_spawn/corpse/human/syndicatecommando,
			/obj/effect/mob_spawn/corpse/human/syndicatestormtrooper,
		),
		r_hand = pick(
			/obj/item/knife/combat/survival,
			/obj/item/melee/energy/sword/saber,
			/obj/item/gun/ballistic/automatic/pistol,
			/obj/item/gun/ballistic/automatic/c20r,
			/obj/item/gun/ballistic/shotgun/bulldog,
		),
	))

	return ..()

/// Hallucination used by the nightmare vision goggles to turn everyone except you into mares
/datum/hallucination/delusion/preset/mare
	delusion_icon_file = 'icons/obj/clothing/masks.dmi'
	delusion_icon_state = "horsehead"
	delusion_name = "mare"
	affects_us = FALSE
	affects_all_humans = TRUE
	random_hallucination_weight = 0
