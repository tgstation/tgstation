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

/obj/structure/spawner/Initialize(mapload)
	. = ..()
	AddComponent(spawner_type, mob_types, spawn_time, max_mobs, faction, spawn_text, CALLBACK(src, PROC_REF(on_mob_spawn)))

/obj/structure/spawner/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(faction_check(faction, user.faction, FALSE) && !user.client)
		return
	return ..()

/obj/structure/spawner/proc/on_mob_spawn(atom/created_atom)
	return

/obj/structure/spawner/syndicate
	name = "warp beacon"
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"
	spawn_text = "warps in from"
	mob_types = list(/mob/living/basic/syndicate/ranged)
	faction = list(ROLE_SYNDICATE)

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
		/mob/living/basic/wumborian_fugu,
		/mob/living/simple_animal/hostile/asteroid/hivelord,
	)
	faction = list(FACTION_MINING)

/obj/structure/spawner/mining/goldgrub
	name = "goldgrub den"
	desc = "A den housing a nest of goldgrubs, annoying but arguably much better than anything else you'll find in a nest."
	mob_types = list(/mob/living/basic/mining/goldgrub)

/obj/structure/spawner/mining/goliath
	name = "goliath den"
	desc = "A den housing a nest of goliaths, oh god why?"
	mob_types = list(/mob/living/basic/mining/goliath/ancient)

/obj/structure/spawner/mining/hivelord
	name = "hivelord den"
	desc = "A den housing a nest of hivelords."
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/hivelord)

/obj/structure/spawner/mining/basilisk
	name = "basilisk den"
	desc = "A den housing a nest of basilisks, bring a coat."
	mob_types = list(/mob/living/basic/mining/basilisk)

/obj/structure/spawner/mining/wumborian
	name = "wumborian fugu den"
	desc = "A den housing a nest of wumborian fugus, how do they all even fit in there?"
	mob_types = list(/mob/living/basic/wumborian_fugu)

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

/obj/structure/spawner/sentient
	var/role_name = "A sentient mob"
	var/assumed_control_message = "You are a sentient mob from a badly coded spawner"

/obj/structure/spawner/sentient/on_mob_spawn(atom/created_atom)
	created_atom.AddComponent(\
		/datum/component/ghost_direct_control,\
		role_name = src.role_name,\
		assumed_control_message = src.assumed_control_message,\
		after_assumed_control = CALLBACK(src, PROC_REF(became_player_controlled)),\
	)
	return

/obj/structure/spawner/sentient/proc/became_player_controlled(mob/proteon)
	return

/obj/structure/spawner/sentient/proteon_spawner
	name = "eldritch gateway"
	desc = "A dizzying structure that somehow links into Nar'Sie's own domain. The screams of the damned echo continously..."
	icon = 'icons/obj/antags/cult/structures.dmi'
	icon_state = "hole"
	light_power = 2
	light_color = COLOR_CULT_RED
	max_integrity = 50
	density = FALSE
	max_mobs = 2
	spawn_time = 1 MINUTES
	mob_types = list(/mob/living/simple_animal/hostile/construct/proteon)
	spawn_text = "arises from"
	faction = list(FACTION_CULT)
	role_name = "A proteon cult construct"
	assumed_control_message = null

 // not AI
/obj/structure/spawner/sentient/proteon_spawner/examine_status(mob/user)
	if(IS_CULTIST(user) || !isliving(user))
		return span_cult("It's at <b>[round(atom_integrity * 100 / max_integrity)]%</b> stability.")
	return ..()

/obj/structure/spawner/sentient/proteon_spawner/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(!isconstruct(user))
		return ..()

	var/mob/living/simple_animal/hostile/construct/healer = user
	if(!healer.can_repair)
		return ..()

	if(atom_integrity >= max_integrity)
		to_chat(user, span_cult("You cannot repair [src], as it's undamaged!"))
		return

	user.changeNext_move(CLICK_CD_MELEE)
	atom_integrity = min(max_integrity, atom_integrity + 5)
	Beam(user, icon_state = "sendbeam", time = 0.4 SECONDS)
	user.visible_message(
		span_danger("[user] repairs [src]."),
		span_cult("You repair [src], leaving it at <b>[round(atom_integrity * 100 / max_integrity)]%</b> stability.")
		)

/obj/structure/spawner/sentient/proteon_spawner/examine(mob/user)
	. = ..()
	if(!IS_CULTIST(user) && isliving(user))
		var/mob/living/luser = user
		luser.adjustOrganLoss(ORGAN_SLOT_BRAIN, 25)
		. += span_danger("The voices of the damned echo relentlessly in your mind, rebounding on the walls of your self ever stronger the more you focus on [src]. Best keep away...")
	else
		. += span_cult("The gateway will create weak proteon constructs that may be controlled by the spirits of the dead.")
		. += span_cultbold("You may use a ritual knife to slice your palm open, sending the gateway into a powerful frenzy that doubles its capacity and halves its cooldown, but this will eventually destroy it.")
		// logic for above handled in cult_ritual_item component

/obj/structure/spawner/sentient/proteon_spawner/became_player_controlled(mob/proteon)
	proteon.add_filter("awoken_proteon", 3, list("type" = "outline", "color" = COLOR_CULT_RED, "size" = 2))
	visible_message(span_cultbold("[proteon] awakens, glowing an eerie red as it stirs from its stupor!")) // only this owrks
	playsound(proteon, 'sound/items/haunted/ghostitemattack.ogg', 100, TRUE)
	proteon.balloon_alert_to_viewers("awoken!")
	addtimer(CALLBACK(src, PROC_REF(remove_player_outline), proteon), 8 SECONDS)

/obj/structure/spawner/sentient/proteon_spawner/proc/remove_player_outline(mob/proteon)
	proteon.remove_filter("awoken_proteon")
	return

/obj/structure/spawner/sentient/proteon_spawner/proc/buff_spawner(mob/living/carbon/human/cultist)

	// Returns if cultist has one arm.
	var/obj/item/bodypart/bad_bodypart = cultist.get_inactive_hand()
	if(!bad_bodypart) // we dontn like cripples round these parts
		to_chat(cultist, span_cult("You have no spare palm to slice open."))
		return

	// Do_after for this, makes it clear that you're breaking the gateway by doing this.
	cultist.balloon_alert(cultist, "surging gateway...")
	to_chat(cultist, span_cult("You hold your knife and palm over [src], steeling yourself to surge the gateway, increasing its power <b>which will damage and, eventually, destroy it</b>..."))
	if(!do_after(cultist, 5 SECONDS, target = src))
		cultist.balloon_alert(cultist, "cancelled")
		to_chat(cultist, span_cult("You withdraw your knife."))
		return

	// Actual gateway surging.
	new /obj/effect/temp_visual/cleave(src) // looks cool
	add_filter("frenzied_gateway", 1, list("type" = "outline", "color" = "#882a2a", "size" = 1))
	START_PROCESSING(SSobj, src)
	max_mobs = 4
	spawn_time = 30 SECONDS
	light_power = 6

	// Cuts the cultist's arm open.
	var/obj/item/bodypart/bodypart = cultist.get_active_hand()
	if(!bodypart) // ???
		return
	bodypart.receive_damage(brute = 15, sharpness = SHARP_EDGED)
	to_chat(cultist, span_cultitalic("You slash your palm open, spreading blood all over [src]. It tastes the blood, and goes into a frenzy!"))

// The integrity divisions are meant to make the effects wackier and stronger until the gateway breaks apart completely.
/obj/structure/spawner/sentient/proteon_spawner/process(seconds_per_tick)
	. = ..()
	take_damage((max_integrity / 2.5 MINUTES))
	if(get_integrity() <= 0) // avoids dividing by zero
		deconstruct()

	var/practical_integrity = max(get_integrity(), 0.1)

	Shake(3 / practical_integrity, seconds_per_tick) // the lower integrity is, the more it rumbles
	if(prob(25 * seconds_per_tick))
		visible_message(span_cultbold("[src] rumbles and quakes, bits of it falling off around the edges!"))

	light_power = 10 / practical_integrity

	var/filter = get_filter("frenzied_gateway")
	if(!filter)
		return

	animate(filter, size = 5 / practical_integrity, time = seconds_per_tick)

/obj/structure/spawner/sentient/proteon_spawner/deconstruct(disassembled)
	playsound('sound/hallucinations/veryfar_noise.ogg', 125)
	visible_message(span_cultbold("[src] completely falls apart, the screams of the damned peaking before slowly fading away..."))
	return ..()

