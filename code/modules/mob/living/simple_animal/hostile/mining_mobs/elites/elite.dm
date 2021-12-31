#define TUMOR_INACTIVE 0
#define TUMOR_ACTIVE 1
#define TUMOR_PASSIVE 2

//Elite mining mobs
/mob/living/simple_animal/hostile/asteroid/elite
	name = "elite"
	desc = "An elite monster, found in one of the strange tumors on lavaland."
	icon = 'icons/mob/lavaland/lavaland_elites.dmi'
	faction = list("boss")
	robust_searching = TRUE
	ranged_ignores_vision = TRUE
	ranged = TRUE
	obj_damage = 30
	vision_range = 6
	aggro_vision_range = 18
	environment_smash = ENVIRONMENT_SMASH_NONE  //This is to prevent elites smashing up the mining station (entirely), we'll make sure they can smash minerals fine below.
	harm_intent_damage = 0 //Punching elites gets you nowhere
	stat_attack = HARD_CRIT
	layer = LARGE_MOB_LAYER
	sentience_type = SENTIENCE_BOSS
	var/chosen_attack = 1
	var/list/attack_action_types = list()
	var/can_talk = FALSE
	var/obj/loot_drop = null

//Gives player-controlled variants the ability to swap attacks
/mob/living/simple_animal/hostile/asteroid/elite/Initialize(mapload)
	. = ..()
	for(var/action_type in attack_action_types)
		var/datum/action/innate/elite_attack/attack_action = new action_type()
		attack_action.Grant(src)

//Prevents elites from attacking members of their faction (can't hurt themselves either) and lets them mine rock with an attack despite not being able to smash walls.
/mob/living/simple_animal/hostile/asteroid/elite/AttackingTarget()
	if(istype(target, /mob/living/simple_animal/hostile))
		var/mob/living/simple_animal/hostile/M = target
		if(faction_check_mob(M))
			return FALSE
	if(istype(target, /obj/structure/elite_tumor))
		var/obj/structure/elite_tumor/T = target
		if(T.mychild == src && T.activity == TUMOR_PASSIVE)
			var/elite_remove = tgui_alert(usr,"Re-enter the tumor?", "Despawn yourself?", list("Yes", "No"))
			if(elite_remove == "No" || QDELETED(src) || !Adjacent(T))
				return
			T.mychild = null
			T.activity = TUMOR_INACTIVE
			T.icon_state = "advanced_tumor"
			qdel(src)
			return FALSE
	. = ..()
	if(ismineralturf(target))
		var/turf/closed/mineral/M = target
		M.gets_drilled()
	if(istype(target, /obj/vehicle/sealed/mecha))
		var/obj/vehicle/sealed/mecha/M = target
		M.take_damage(50, BRUTE, MELEE, 1)

//Elites can't talk (normally)!
/mob/living/simple_animal/hostile/asteroid/elite/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = null)
	if(can_talk)
		. = ..()
		return TRUE
	return FALSE

/*Basic setup for elite attacks, based on Whoneedspace's megafauna attack setup.
While using this makes the system rely on OnFire, it still gives options for timers not tied to OnFire, and it makes using attacks consistent accross the board for player-controlled elites.*/

/datum/action/innate/elite_attack
	name = "Elite Attack"
	icon_icon = 'icons/mob/actions/actions_elites.dmi'
	button_icon_state = ""
	background_icon_state = "bg_default"
	///The displayed message into chat when this attack is selected
	var/chosen_message
	///The internal attack ID for the elite's OpenFire() proc to use
	var/chosen_attack_num = 0

/datum/action/innate/elite_attack/New()
	..()
	button.maptext = ""
	button.maptext_x = 8
	button.maptext_y = 0
	button.maptext_width = 24
	button.maptext_height = 12

/datum/action/innate/elite_attack/process()
	if(owner == null)
		STOP_PROCESSING(SSfastprocess, src)
		qdel(src)
		return
	var/mob/living/simple_animal/hostile/asteroid/elite/elite_owner = owner
	var/timeleft = max(elite_owner.ranged_cooldown - world.time, 0)
	if(timeleft == 0)
		button.maptext = ""
		UpdateButtonIcon()
	else
		button.maptext = "<b class='maptext'>[round(timeleft/10, 0.1)]</b>"

/datum/action/innate/elite_attack/Grant(mob/living/L)
	if(istype(L, /mob/living/simple_animal/hostile/asteroid/elite))
		START_PROCESSING(SSfastprocess, src)
		return ..()
	return FALSE

/datum/action/innate/elite_attack/Activate()
	var/mob/living/simple_animal/hostile/asteroid/elite/elite_owner = owner
	elite_owner.chosen_attack = chosen_attack_num
	to_chat(elite_owner, chosen_message)

//The Pulsing Tumor, the actual "spawn-point" of elites, handles the spawning, arena, and procs for dealing with basic scenarios.

/obj/structure/elite_tumor
	name = "pulsing tumor"
	desc = "An odd, pulsing tumor sticking out of the ground.  You feel compelled to reach out and touch it..."
	armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 100, BIO = 100, FIRE = 100, ACID = 100)
	resistance_flags = INDESTRUCTIBLE
	icon = 'icons/obj/lavaland/tumor.dmi'
	icon_state = "tumor"
	pixel_x = -16
	base_pixel_x = -16
	light_color = COLOR_SOFT_RED
	light_range = 3
	anchored = TRUE
	density = FALSE
	var/activity = TUMOR_INACTIVE
	var/boosted = FALSE
	var/times_won = 0
	var/mob/living/carbon/human/activator
	var/mob/living/simple_animal/hostile/asteroid/elite/mychild = null
	var/potentialspawns = list(/mob/living/simple_animal/hostile/asteroid/elite/broodmother,
								/mob/living/simple_animal/hostile/asteroid/elite/pandora,
								/mob/living/simple_animal/hostile/asteroid/elite/legionnaire,
								/mob/living/simple_animal/hostile/asteroid/elite/herald)

/obj/structure/elite_tumor/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(ishuman(user))
		switch(activity)
			if(TUMOR_PASSIVE)
				// Prevents the user from being forcemoved back and forth between two elite arenas.
				if(HAS_TRAIT(user, TRAIT_ELITE_CHALLENGER))
					user.visible_message(span_warning("[user] reaches for [src] with [user.p_their()] arm, but nothing happens."),
						span_warning("You reach for [src] with your arm... but nothing happens."))
					return
				activity = TUMOR_ACTIVE
				user.visible_message(span_boldwarning("[src] convulses as [user]'s arm enters its radius.  Uh-oh..."),
					span_boldwarning("[src] convulses as your arm enters its radius.  Your instincts tell you to step back."))
				make_activator(user)
				if(boosted)
					mychild.playsound_local(get_turf(mychild), 'sound/effects/magic.ogg', 40, 0)
					to_chat(mychild, "<b>Someone has activated your tumor.  You will be returned to fight shortly, get ready!</b>")
				addtimer(CALLBACK(src, .proc/return_elite), 30)
				INVOKE_ASYNC(src, .proc/arena_checks)
			if(TUMOR_INACTIVE)
				if(HAS_TRAIT(user, TRAIT_ELITE_CHALLENGER))
					user.visible_message(span_warning("[user] reaches for [src] with [user.p_their()] arm, but nothing happens."),
						span_warning("You reach for [src] with your arm... but nothing happens."))
					return
				activity = TUMOR_ACTIVE
				var/mob/dead/observer/elitemind = null
				visible_message(span_boldwarning("[src] begins to convulse.  Your instincts tell you to step back."))
				make_activator(user)
				if(!boosted)
					addtimer(CALLBACK(src, .proc/spawn_elite), 30)
					return
				visible_message(span_boldwarning("Something within [src] stirs..."))
				var/list/candidates = poll_candidates_for_mob("Do you want to play as a lavaland elite?", ROLE_SENTIENCE, ROLE_SENTIENCE, 5 SECONDS, src, POLL_IGNORE_SENTIENCE_POTION)
				if(candidates.len)
					audible_message(span_boldwarning("The stirring sounds increase in volume!"))
					elitemind = pick(candidates)
					elitemind.playsound_local(get_turf(elitemind), 'sound/effects/magic.ogg', 40, 0)
					to_chat(elitemind, "<b>You have been chosen to play as a Lavaland Elite.\nIn a few seconds, you will be summoned on Lavaland as a monster to fight your activator, in a fight to the death.\nYour attacks can be switched using the buttons on the top left of the HUD, and used by clicking on targets or tiles similar to a gun.\nWhile the opponent might have an upper hand with  powerful mining equipment and tools, you have great power normally limited by AI mobs.\nIf you want to win, you'll have to use your powers in creative ways to ensure the kill.  It's suggested you try using them all as soon as possible.\nShould you win, you'll receive extra information regarding what to do after.  Good luck!</b>")
					addtimer(CALLBACK(src, .proc/spawn_elite, elitemind), 100)
				else
					visible_message(span_boldwarning("The stirring stops, and nothing emerges.  Perhaps try again later."))
					activity = TUMOR_INACTIVE
					clear_activator(user)

/obj/structure/elite_tumor/proc/spawn_elite(mob/dead/observer/elitemind)
	var/selectedspawn = pick(potentialspawns)
	mychild = new selectedspawn(loc)
	visible_message(span_boldwarning("[mychild] emerges from [src]!"))
	playsound(loc,'sound/effects/phasein.ogg', 200, 0, 50, TRUE, TRUE)
	if(boosted)
		mychild.key = elitemind.key
		mychild.sentience_act()
		notify_ghosts("\A [mychild] has been awakened in \the [get_area(src)]!", source = mychild, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Lavaland Elite awakened")
	icon_state = "tumor_popped"
	RegisterSignal(mychild, COMSIG_PARENT_QDELETING, .proc/mychild_gone_missing)
	INVOKE_ASYNC(src, .proc/arena_checks)

/obj/structure/elite_tumor/proc/mychild_gone_missing()
	SIGNAL_HANDLER
	mychild = null

/obj/structure/elite_tumor/proc/return_elite()
	mychild.forceMove(loc)
	visible_message(span_boldwarning("[mychild] emerges from [src]!"))
	playsound(loc,'sound/effects/phasein.ogg', 200, 0, 50, TRUE, TRUE)
	mychild.revive(full_heal = TRUE, admin_revive = TRUE)
	if(boosted)
		mychild.maxHealth = mychild.maxHealth * 2
		mychild.health = mychild.maxHealth
		notify_ghosts("\A [mychild] has been challenged in \the [get_area(src)]!", source = mychild, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Lavaland Elite challenged")

/obj/structure/elite_tumor/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gps, "Menacing Signal")
	START_PROCESSING(SSobj, src)

/obj/structure/elite_tumor/Destroy()
	STOP_PROCESSING(SSobj, src)
	mychild = null
	clear_activator(activator)
	return ..()

/obj/structure/elite_tumor/proc/make_activator(mob/user)
	if(activator)
		return
	activator = user
	ADD_TRAIT(user, TRAIT_ELITE_CHALLENGER, REF(src))
	RegisterSignal(user, COMSIG_PARENT_QDELETING, .proc/clear_activator)

/obj/structure/elite_tumor/proc/clear_activator(mob/source)
	SIGNAL_HANDLER
	if(!activator)
		return
	activator = null
	REMOVE_TRAIT(source, TRAIT_ELITE_CHALLENGER, REF(src))
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)

/obj/structure/elite_tumor/process(delta_time)
	if(isturf(loc))
		for(var/mob/living/simple_animal/hostile/asteroid/elite/elitehere in loc)
			if(elitehere == mychild && activity == TUMOR_PASSIVE)
				mychild.adjustHealth(-mychild.maxHealth*0.025*delta_time)
				var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(mychild))
				H.color = "#FF0000"

/obj/structure/elite_tumor/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/organ/regenerative_core) && activity == TUMOR_INACTIVE && !boosted)
		var/obj/item/organ/regenerative_core/core = I
		visible_message(span_boldwarning("As [user] drops the core into [src], [src] appears to swell."))
		icon_state = "advanced_tumor"
		boosted = TRUE
		set_light_range(6)
		desc = "[desc]  This one seems to glow with a strong intensity."
		qdel(core)
		return TRUE

/obj/structure/elite_tumor/proc/arena_checks()
	if(activity != TUMOR_ACTIVE || QDELETED(src))
		return
	INVOKE_ASYNC(src, .proc/fighters_check)  //Checks to see if our fighters died.
	INVOKE_ASYNC(src, .proc/arena_trap)  //Gets another arena trap queued up for when this one runs out.
	INVOKE_ASYNC(src, .proc/border_check)  //Checks to see if our fighters got out of the arena somehow.
	if(!QDELETED(src))
		addtimer(CALLBACK(src, .proc/arena_checks), 50)

/obj/structure/elite_tumor/proc/fighters_check()
	if(QDELETED(mychild) || mychild.stat == DEAD)
		onEliteLoss()
		return
	if(QDELETED(activator) || activator.stat == DEAD || (activator.health <= HEALTH_THRESHOLD_DEAD && HAS_TRAIT(activator, TRAIT_NODEATH)))
		if(!QDELETED(activator) && HAS_TRAIT(activator, TRAIT_NODEATH)) // dust the unkillable activator
			activator.dust(drop_items = TRUE)
		onEliteWon()

/obj/structure/elite_tumor/proc/arena_trap()
	var/turf/T = get_turf(src)
	if(loc == null)
		return
	var/datum/weakref/activator_ref = WEAKREF(activator)
	var/datum/weakref/mychild_ref = WEAKREF(mychild)
	for(var/t in RANGE_TURFS(12, T))
		if(get_dist(t, T) == 12)
			var/obj/effect/temp_visual/elite_tumor_wall/newwall
			newwall = new /obj/effect/temp_visual/elite_tumor_wall(t, src)
			newwall.activator_ref = activator_ref
			newwall.ourelite_ref = mychild_ref

/obj/structure/elite_tumor/proc/border_check()
	if(activator != null && get_dist(src, activator) >= 12)
		activator.forceMove(loc)
		visible_message(span_boldwarning("[activator] suddenly reappears above [src]!"))
		playsound(loc,'sound/effects/phasein.ogg', 200, 0, 50, TRUE, TRUE)
	if(mychild != null && get_dist(src, mychild) >= 12)
		mychild.forceMove(loc)
		visible_message(span_boldwarning("[mychild] suddenly reappears above [src]!"))
		playsound(loc,'sound/effects/phasein.ogg', 200, 0, 50, TRUE, TRUE)

/obj/structure/elite_tumor/proc/onEliteLoss()
	playsound(loc,'sound/effects/tendril_destroyed.ogg', 200, 0, 50, TRUE, TRUE)
	visible_message(span_boldwarning("[src] begins to convulse violently before beginning to dissipate."))
	visible_message(span_boldwarning("As [src] closes, something is forced up from down below."))
	var/obj/structure/closet/crate/necropolis/tendril/lootbox = new /obj/structure/closet/crate/necropolis/tendril(loc)
	if(boosted)
		if(mychild.loot_drop != null && prob(50))
			new mychild.loot_drop(lootbox)
		else
			new /obj/item/tumor_shard(lootbox)
	qdel(src)

/obj/structure/elite_tumor/proc/onEliteWon()
	activity = TUMOR_PASSIVE
	clear_activator(activator)
	mychild.revive(full_heal = TRUE, admin_revive = TRUE)
	if(boosted)
		times_won++
		mychild.maxHealth = mychild.maxHealth * 0.4
		mychild.health = mychild.maxHealth
	if(times_won == 1)
		mychild.playsound_local(get_turf(mychild), 'sound/effects/magic.ogg', 40, 0)
		to_chat(mychild, span_boldwarning("As the life in the activator's eyes fade, the forcefield around you dies out and you feel your power subside.\nDespite this inferno being your home, you feel as if you aren't welcome here anymore.\nWithout any guidance, your purpose is now for you to decide."))
		to_chat(mychild, "<b>Your max health has been halved, but can now heal by standing on your tumor.  Note, it's your only way to heal.\nBear in mind, if anyone interacts with your tumor, you'll be resummoned here to carry out another fight.  In such a case, you will regain your full max health.\nAlso, be weary of your fellow inhabitants, they likely won't be happy to see you!</b>")
		to_chat(mychild, "<span class='big bold'>Note that you are a lavaland monster, and thus not allied to the station.  You should not cooperate or act friendly with any station crew unless under extreme circumstances!</span>")

/obj/item/tumor_shard
	name = "tumor shard"
	desc = "A strange, sharp, crystal shard from an odd tumor on Lavaland.  Stabbing the corpse of a lavaland elite with this will revive them, assuming their soul still lingers.  Revived lavaland elites only have half their max health, but are completely loyal to their reviver."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "crevice_shard"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	inhand_icon_state = "screwdriver_head"
	throwforce = 5
	atom_size = ITEM_SIZE_SMALL
	throw_speed = 3
	throw_range = 5

/obj/item/tumor_shard/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(istype(target, /mob/living/simple_animal/hostile/asteroid/elite) && proximity_flag)
		var/mob/living/simple_animal/hostile/asteroid/elite/E = target
		if(E.stat != DEAD || E.sentience_type != SENTIENCE_BOSS || !E.key)
			user.visible_message(span_notice("It appears [E] is unable to be revived right now.  Perhaps try again later."))
			return
		E.faction = list("[REF(user)]")
		E.revive(full_heal = TRUE, admin_revive = TRUE)
		user.visible_message(span_notice("[user] stabs [E] with [src], reviving it."))
		E.playsound_local(get_turf(E), 'sound/effects/magic.ogg', 40, 0)
		to_chat(E, "<span class='userdanger'>You have been revived by [user]. While you can't speak to them, you owe [user] a great debt.  Assist [user.p_them()] in achieving [user.p_their()] goals, regardless of risk.</span>")
		to_chat(E, "<span class='big bold'>Note that you now share the loyalties of [user].  You are expected not to intentionally sabotage their faction unless commanded to!</span>")
		E.maxHealth = E.maxHealth * 0.4
		E.health = E.maxHealth
		E.desc = "[E.desc]  However, this one appears appears less wild in nature, and calmer around people."
		E.sentience_type = SENTIENCE_ORGANIC
		qdel(src)
	else
		to_chat(user, span_info("[src] only works on the corpse of a sentient lavaland elite."))

/obj/effect/temp_visual/elite_tumor_wall
	name = "magic wall"
	icon = 'icons/turf/walls/hierophant_wall_temp.dmi'
	icon_state = "hierophant_wall_temp-0"
	base_icon_state = "hierophant_wall_temp"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_HIERO_WALL)
	canSmoothWith = list(SMOOTH_GROUP_HIERO_WALL)
	duration = 50
	layer = BELOW_MOB_LAYER
	color = rgb(255,0,0)
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	light_color = COLOR_SOFT_RED
	var/datum/weakref/activator_ref
	var/datum/weakref/ourelite_ref

/obj/effect/temp_visual/elite_tumor_wall/Initialize(mapload, new_caster)
	. = ..()
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH_NEIGHBORS(src)
		QUEUE_SMOOTH(src)

/obj/effect/temp_visual/elite_tumor_wall/Destroy()
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH_NEIGHBORS(src)
	return ..()

/obj/effect/temp_visual/elite_tumor_wall/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(mover == ourelite_ref.resolve() || mover == activator_ref.resolve())
		return FALSE
