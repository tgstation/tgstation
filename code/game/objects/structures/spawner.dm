/obj/structure/spawner
	name = "monster nest"
	icon = 'icons/mob/simple/animal.dmi'
	icon_state = "hole"
	max_integrity = 100

	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	anchored = TRUE
	density = TRUE

	var/max_mobs = 5
	var/spawn_time = 30 SECONDS
	var/mob_types = list(/mob/living/basic/carp)
	var/spawn_text = "emerges from"
	var/faction = list(FACTION_HOSTILE)
	var/spawner_type = /datum/component/spawner
	/// is this spawner taggable with a mining scanner?
	var/scanner_taggable = FALSE
	/// has this tendril been tagged/analyzed by a mining scanner?
	var/gps_tagged = FALSE
	/// short identifier for the mob it spawns. probably stick around 3 characters or less?
	var/mob_gps_id = "???"
	/// short identifier for what kind of spawner it is.
	var/spawner_gps_id = "Creature Nest"

/obj/structure/spawner/attackby(obj/item/item, mob/user, params)
	if(scanner_taggable)
		if(!istype(item, /obj/item/mining_scanner) && !istype(item, /obj/item/t_scanner/adv_mining_scanner))
			return ..()
		gps_tag(user)

/// Tag the spawner, prefixing its GPS entry with an identifier - or giving it one, if nonexistent.
/obj/structure/spawner/proc/gps_tag(mob/user)
	if(gps_tagged)
		balloon_alert(user, "already tagged!")
		return
	balloon_alert(user, "tagged on GPS!")
	gps_tagged = TRUE
	var/new_tag = "\[[mob_gps_id]-[rand(100,999)]\] " + spawner_gps_id
	var/datum/component/gps/our_gps = GetComponent(/datum/component/gps)
	if(our_gps)
		our_gps.gpstag = new_tag
		return
	AddComponent(/datum/component/gps, new_tag)

/obj/structure/spawner/Initialize(mapload)
	. = ..()
	AddComponent(spawner_type, mob_types, spawn_time, max_mobs, faction, spawn_text)

/obj/structure/spawner/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(faction_check(faction, user.faction, FALSE) && !user.client)
		return
	return ..()


/obj/structure/spawner/syndicate
	name = "warp beacon"
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"
	spawn_text = "warps in from"
	mob_types = list(/mob/living/basic/syndicate/ranged)
	faction = list(ROLE_SYNDICATE)
	mob_gps_id = "SYN" // syndicate
	spawner_gps_id = "Hostile Warp Beacon"

/obj/structure/spawner/skeleton
	name = "bone pit"
	desc = "A pit full of bones, and some still seem to be moving..."
	icon_state = "hole"
	icon = 'icons/mob/simple/lavaland/nest.dmi'
	max_integrity = 150
	max_mobs = 15
	spawn_time = 15 SECONDS
	mob_types = list(/mob/living/simple_animal/hostile/skeleton)
	spawn_text = "climbs out of"
	faction = list(FACTION_SKELETON)
	mob_gps_id = "SKL" // skeletons
	spawner_gps_id = "Bone Pit"

/obj/structure/spawner/clown
	name = "Laughing Larry"
	desc = "A laughing, jovial figure. Something seems stuck in his throat."
	icon_state = "clownbeacon"
	icon = 'icons/obj/device.dmi'
	max_integrity = 200
	max_mobs = 15
	spawn_time = 15 SECONDS
	mob_types = list(
		/mob/living/basic/clown,
		/mob/living/basic/clown/banana,
		/mob/living/basic/clown/clownhulk,
		/mob/living/basic/clown/clownhulk/chlown,
		/mob/living/basic/clown/clownhulk/honkmunculus,
		/mob/living/basic/clown/fleshclown,
		/mob/living/basic/clown/mutant/glutton,
		/mob/living/basic/clown/honkling,
		/mob/living/basic/clown/longface,
		/mob/living/basic/clown/lube,
	)
	spawn_text = "climbs out of"
	faction = list(FACTION_CLOWN)
	mob_gps_id = "???" // clowns
	spawner_gps_id = "Clown Planet Distortion"

/obj/structure/spawner/mining
	name = "monster den"
	desc = "A hole dug into the ground, harboring all kinds of monsters found within most caves or mining asteroids."
	icon_state = "hole"
	max_integrity = 200
	max_mobs = 3
	icon = 'icons/mob/simple/lavaland/nest.dmi'
	spawn_text = "crawls out of"
	mob_types = list(
		/mob/living/basic/mining/basilisk,
		/mob/living/basic/mining/goldgrub,
		/mob/living/basic/mining/goliath/ancient,
		/mob/living/basic/mining/hivelord,
		/mob/living/basic/wumborian_fugu,
	)
	faction = list(FACTION_MINING)

/obj/structure/spawner/mining/goldgrub
	name = "goldgrub den"
	desc = "A den housing a nest of goldgrubs, annoying but arguably much better than anything else you'll find in a nest."
	mob_types = list(/mob/living/basic/mining/goldgrub)
	mob_gps_id = "GG"

/obj/structure/spawner/mining/goliath
	name = "goliath den"
	desc = "A den housing a nest of goliaths, oh god why?"
	mob_types = list(/mob/living/basic/mining/goliath/ancient)
	mob_gps_id = "GL|A"

/obj/structure/spawner/mining/hivelord
	name = "hivelord den"
	desc = "A den housing a nest of hivelords."
	mob_types = list(/mob/living/basic/mining/hivelord)
	mob_gps_id = "HL"

/obj/structure/spawner/mining/basilisk
	name = "basilisk den"
	desc = "A den housing a nest of basilisks, bring a coat."
	mob_types = list(/mob/living/basic/mining/basilisk)
	mob_gps_id = "BK"

/obj/structure/spawner/mining/wumborian
	name = "wumborian fugu den"
	desc = "A den housing a nest of wumborian fugus, how do they all even fit in there?"
	mob_types = list(/mob/living/basic/wumborian_fugu)
	mob_gps_id = "WF"

/obj/structure/spawner/nether
	name = "netherworld link"
	desc = null //see examine()
	icon_state = "nether"
	max_integrity = 50
	spawn_time = 60 SECONDS
	max_mobs = 15
	icon = 'icons/mob/simple/lavaland/nest.dmi'
	spawn_text = "crawls through"
	mob_types = list(
		/mob/living/basic/blankbody,
		/mob/living/basic/creature,
		/mob/living/basic/migo,
	)
	faction = list(FACTION_NETHER)
	scanner_taggable = TRUE
	mob_gps_id = "?!?"
	spawner_gps_id = "Netheric Distortion"

/obj/structure/spawner/nether/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/structure/spawner/nether/examine(mob/user)
	. = ..()
	if(isskeleton(user) || iszombie(user))
		. += "A direct link to another dimension full of creatures very happy to see you. [span_nicegreen("You can see your house from here!")]"
	else
		. += "A direct link to another dimension full of creatures not very happy to see you. [span_warning("Entering the link would be a very bad idea.")]"

/obj/structure/spawner/nether/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(isskeleton(user) || iszombie(user))
		to_chat(user, span_notice("You don't feel like going home yet..."))
	else
		user.visible_message(span_warning("[user] is violently pulled into the link!"), \
							span_userdanger("Touching the portal, you are quickly pulled through into a world of unimaginable horror!"))
		contents.Add(user)

/obj/structure/spawner/nether/process(seconds_per_tick)
	for(var/mob/living/living_mob in contents)
		if(living_mob)
			playsound(src, 'sound/magic/demon_consume.ogg', 50, TRUE)
			living_mob.adjustBruteLoss(60 * seconds_per_tick)
			new /obj/effect/gibspawner/generic(get_turf(living_mob), living_mob)
			if(living_mob.stat == DEAD)
				var/mob/living/basic/blankbody/newmob = new(loc)
				newmob.name = "[living_mob]"
				newmob.desc = "It's [living_mob], but [living_mob.p_their()] flesh has an ashy texture, and [living_mob.p_their()] face is featureless save an eerie smile."
				src.visible_message(span_warning("[living_mob] reemerges from the link!"))
				qdel(living_mob)
