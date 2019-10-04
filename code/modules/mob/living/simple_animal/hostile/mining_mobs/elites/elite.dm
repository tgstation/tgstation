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
	ranged = 1
	obj_damage = 5
	var/chosen_attack = 1
	vision_range = 6
	aggro_vision_range = 18
	var/list/attack_action_types = list()
	environment_smash = ENVIRONMENT_SMASH_NONE  //This is to prevent elites smashing up the mining station, we'll make sure they can smash minerals fine below.
	harm_intent_damage = 0 //Punching elites gets you nowhere
	var/obj/structure/elite_tumor/myparent = null
	var/can_talk = 0
	var/obj/loot_drop = null
	stat_attack = UNCONSCIOUS
	layer = LARGE_MOB_LAYER
	sentience_type = SENTIENCE_BOSS
	hud_type = /datum/hud/lavaland_elite
	
		
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
	. = ..()
	if(ismineralturf(target))
		var/turf/closed/mineral/M = target
		M.gets_drilled()
		
//Elites can't talk (normally)!
/mob/living/simple_animal/hostile/asteroid/elite/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
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
	var/mob/living/simple_animal/hostile/asteroid/elite/M
	var/chosen_message
	var/chosen_attack_num = 0

/datum/action/innate/elite_attack/Grant(mob/living/L)
	if(istype(L, /mob/living/simple_animal/hostile/asteroid/elite))
		M = L
		return ..()
	return FALSE

/datum/action/innate/elite_attack/Activate()
	M.chosen_attack = chosen_attack_num
	to_chat(M, chosen_message)
	
/mob/living/simple_animal/hostile/asteroid/elite/Life()
	. = ..()
	if(isturf(loc))
		for(var/obj/structure/elite_tumor/tumor in loc)
			if(tumor == myparent && myparent.activity == TUMOR_PASSIVE)
				adjustHealth(-maxHealth*0.05)
				var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(src))
				H.color = "#FF0000"
	if(myparent)
		if(myparent.activity == TUMOR_ACTIVE && myparent.activator.stat == DEAD)
			myparent.onEliteWon()
	update_health_hud()

/mob/living/simple_animal/hostile/asteroid/elite/death()
	. = ..()
	if(myparent)
		myparent.onEliteLoss()
		
/mob/living/simple_animal/hostile/asteroid/elite/update_health_hud()
	if(hud_used)
		var/severity = 0
		var/healthpercent = (health/maxHealth) * 100
		switch(healthpercent)
			if(100 to INFINITY)
				hud_used.healths.icon_state = "elite_health0"
			if(80 to 100)
				hud_used.healths.icon_state = "elite_health1"
				severity = 1
			if(60 to 80)
				hud_used.healths.icon_state = "elite_health2"
				severity = 2
			if(40 to 60)
				hud_used.healths.icon_state = "elite_health3"
				severity = 3
			if(20 to 40)
				hud_used.healths.icon_state = "elite_health4"
				severity = 4
			if(10 to 20)
				hud_used.healths.icon_state = "elite_health5"
				severity = 5
			if(1 to 20)
				hud_used.healths.icon_state = "elite_health6"
				severity = 6
			else
				hud_used.healths.icon_state = "elite_health7"
				severity = 7
		if(severity > 0)
			overlay_fullscreen("brute", /obj/screen/fullscreen/brute, severity)
		else
			clear_fullscreen("brute")

//The Glowing Tumor, the actual "spawn-point" of elites, handles the spawning, arena, and procs for dealing with basic scenarios.

/obj/structure/elite_tumor
	name = "pulsing tumor"
	desc = "An odd, pulsing tumor sticking out of the ground.  You fell compelled to reach out and touch it..."
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
	resistance_flags = INDESTRUCTIBLE
	var/activity = TUMOR_INACTIVE
	var/boosted = FALSE
	var/times_won = 0
	var/mob/living/carbon/human/activator = null
	var/mob/living/simple_animal/hostile/asteroid/elite/mychild = null
	var/potentialspawns = list(/mob/living/simple_animal/hostile/asteroid/elite/broodmother,
								/mob/living/simple_animal/hostile/asteroid/elite/pandora,
								/mob/living/simple_animal/hostile/asteroid/elite/legionnaire,
								/mob/living/simple_animal/hostile/asteroid/elite/herald)
	icon = 'icons/obj/lavaland/tumor.dmi'
	icon_state = "tumor"
	pixel_x = -16
	light_color = LIGHT_COLOR_RED
	light_range = 3
	anchored = TRUE
	density = FALSE
	
/obj/structure/elite_tumor/attack_hand(mob/user)
	switch(activity)
		if(TUMOR_INACTIVE)
			if(istype(user, /mob/living/carbon/human))
				activity = TUMOR_ACTIVE
				var/mob/dead/observer/elitemind = null
				visible_message("<span class='boldwarning'>The tumor begins to convulse.  Your instincts tell you to step back.</span>")
				activator = user
				if(boosted)
					visible_message("<span class='boldwarning'>Something within the tumor stirs...</span>")
					var/list/candidates = pollCandidatesForMob("Do you want to play as a lavaland elite?", ROLE_SENTIENCE, null, ROLE_SENTIENCE, 50, src, POLL_IGNORE_SENTIENCE_POTION)
					if(candidates.len)
						audible_message("<span class='boldwarning'>The stirring sounds increase in volume!</span>")
						elitemind = pick(candidates)
						SEND_SOUND(elitemind, sound('sound/effects/magic.ogg'))
						to_chat(elitemind, "<b>You have been chosen to play as a Lavaland Elite.\nIn a few seconds, you will be summoned on Lavaland as a monster to fight your activator, in a fight to the death.\nYour attacks can be switched using the buttons on the top left of the HUD, and used by clicking on targets or tiles similar to a gun.\nWhile the opponent might have an upper hand with  powerful mining equipment and tools, you have great power normally limited by AI mobs.\nIf you want to win, you'll have to use your powers in creative ways to ensure the kill.  It's suggested you try using them all as soon as possible.\nShould you win, you'll receive extra information regarding what to do after.  Good luck!</b>")
						addtimer(CALLBACK(src, .proc/spawn_elite, elitemind), 100)
						return
					else
						visible_message("<span class='boldwarning'>The stirring stops, and nothing emerges.  Perhaps try again later.</span>")
						activity = TUMOR_INACTIVE
						activator = null
						return
				else
					addtimer(CALLBACK(src, .proc/spawn_elite), 30)
				return
		if(TUMOR_PASSIVE)
			if(istype(user, /mob/living/carbon/human))
				activity = TUMOR_ACTIVE
				visible_message("<span class='boldwarning'>The tumor convulses as your arm enters its radius.  Your instincts tell you to step back.</span>")
				activator = user
				INVOKE_ASYNC(src, .proc/arena_trap)
				if(boosted)
					SEND_SOUND(mychild, sound('sound/effects/magic.ogg'))
					to_chat(mychild, "<b>Someone has activated your tumor.  You will be returned to fight shortly, get ready!</b>")
				addtimer(CALLBACK(src, .proc/return_elite), 30)
				return

				
obj/structure/elite_tumor/proc/spawn_elite(var/mob/dead/observer/elitemind)
	var/selectedspawn = pick(potentialspawns)
	mychild = new selectedspawn(loc)
	mychild.myparent = src
	visible_message("<span class='boldwarning'>[mychild] emerges from the tumor!</span>")
	playsound(loc,'sound/effects/phasein.ogg', 200, 0, 50, TRUE, TRUE)
	if(boosted)
		mychild.key = elitemind.key
		mychild.sentience_act()
	INVOKE_ASYNC(src, .proc/arena_trap)
	return

obj/structure/elite_tumor/proc/return_elite()
	mychild.forceMove(loc)
	visible_message("<span class='boldwarning'>[mychild] emerges from the tumor!</span>")
	playsound(loc,'sound/effects/phasein.ogg', 200, 0, 50, TRUE, TRUE)
	mychild.revive(full_heal = TRUE, admin_revive = TRUE)
	if(boosted)
		mychild.maxHealth = mychild.maxHealth * 2
		mychild.health = mychild.maxHealth
	return
		
/obj/structure/elite_tumor/Initialize()
	. = ..()
	AddComponent(/datum/component/gps, "Menacing Signal")
		
/obj/structure/elite_tumor/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(istype(W, /obj/item/organ/regenerative_core) && activity == TUMOR_INACTIVE && !boosted)
		var/obj/item/organ/regenerative_core/core = W
		if(core.preserved)
			visible_message("<span class='boldwarning'>As [user] drops the core into the tumor, the tumor appears to swell.</span>")
			icon_state = "advanced_tumor"
			boosted = TRUE
			light_range = 6
			desc = "[desc]  This one seems to glow with a strong intensity."
			qdel(core)
			return TRUE
			
/obj/structure/elite_tumor/proc/arena_trap()
	var/turf/T = get_turf(src)
	if(T && activity == TUMOR_ACTIVE)
		for(var/t in RANGE_TURFS(12, T))
			if(t && get_dist(t, T) == 12)
				var/obj/effect/temp_visual/elite_tumor_wall/newwall
				newwall = new /obj/effect/temp_visual/elite_tumor_wall(t, src)
				newwall.activator = src.activator
				newwall.ourelite = src.mychild
		addtimer(CALLBACK(src, .proc/arena_checks), 50)
		return

/obj/structure/elite_tumor/proc/arena_checks()
	if(src) //Checking to see if we still exist
		INVOKE_ASYNC(src, .proc/arena_trap)  //Gets another arena trap queued up for when this one runs out.
		INVOKE_ASYNC(src, .proc/border_check)  //Checks to see if our fighters got out of the arena somehow.
	return
		
/obj/effect/temp_visual/elite_tumor_wall
	name = "magic wall"
	icon = 'icons/turf/walls/hierophant_wall_temp.dmi'
	icon_state = "wall"

	duration = 50
	smooth = SMOOTH_TRUE
	layer = BELOW_MOB_LAYER
	var/mob/living/carbon/human/activator = null
	var/mob/living/simple_animal/hostile/asteroid/elite/ourelite = null
	color = rgb(255,0,0)
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	light_color = LIGHT_COLOR_RED
	
/obj/effect/temp_visual/elite_tumor_wall/Initialize(mapload, new_caster)
	. = ..()
	queue_smooth_neighbors(src)
	queue_smooth(src)

/obj/effect/temp_visual/elite_tumor_wall/Destroy()
	queue_smooth_neighbors(src)
	return ..()

/obj/effect/temp_visual/elite_tumor_wall/CanPass(atom/movable/mover, turf/target)
	if(mover == ourelite || mover == activator)
		return FALSE
	else
		return TRUE
		
/obj/structure/elite_tumor/proc/border_check()
	if(activity == TUMOR_ACTIVE)
		if(activator != null && get_dist(src, activator) >= 12)
			if(loc)
				activator.forceMove(loc)
				visible_message("<span class='boldwarning'>[activator] suddenly reappears above the tumor!</span>")
				playsound(loc,'sound/effects/phasein.ogg', 200, 0, 50, TRUE, TRUE)
		if(mychild != null && get_dist(src, mychild) >= 12)
			if(loc)
				mychild.forceMove(loc)
				visible_message("<span class='boldwarning'>[mychild] suddenly reappears above the tumor!</span>")
				playsound(loc,'sound/effects/phasein.ogg', 200, 0, 50, TRUE, TRUE)
	
obj/structure/elite_tumor/proc/onEliteLoss()
	playsound(loc,'sound/effects/tendril_destroyed.ogg', 200, 0, 50, TRUE, TRUE)
	visible_message("<span class='boldwarning'>The tumor begins to convulse violently before beginning to dissipate.</span>")
	mychild.myparent = null
	if(activity == TUMOR_ACTIVE)
		visible_message("<span class='boldwarning'>As the tumor closes, something is forced up from down below.</span>")
		var/obj/structure/closet/crate/necropolis/tendril/lootbox = new /obj/structure/closet/crate/necropolis/tendril(loc)
		if(boosted)
			var/lootpick = rand(1, 2)
			if(lootpick == 1 && mychild.loot_drop != null)
				lootbox.contents += new mychild.loot_drop(lootbox.loc)
			else
				lootbox.contents += new /obj/item/tumor_shard(lootbox.loc)
	qdel(src)
	
obj/structure/elite_tumor/proc/onEliteWon()
	times_won++
	activity = TUMOR_PASSIVE
	activator = null
	mychild.revive(full_heal = TRUE, admin_revive = TRUE)
	if(boosted)
		mychild.maxHealth = mychild.maxHealth * 0.5
		mychild.health = mychild.maxHealth
		if(times_won == 1)
			SEND_SOUND(mychild, sound('sound/effects/magic.ogg'))
			to_chat(mychild, "<span class='boldwarning'>As the life in the activator's eyes fade, the forcefield around you dies out and you feel your power subside.\nDespite this inferno being your home, you feel as if you aren't welcome here anymore.\nWithout any guidance, your purpose is now for you to decide.</span>")
			to_chat(mychild, "<b>Your max health has been halved, but can now heal by standing on your tumor.  Note, it's your only way to heal.\nBear in mind, if anyone interacts with your tumor, you'll be resummoned here to carry out another fight.  In such a case, you will regain your full max health.\nAlso, be weary of your fellow inhabitants, they likely won't be happy to see you!</b>")
			
/obj/item/tumor_shard
	name = "tumor shard"
	desc = "A strange, sharp, crystal shard from an odd tumor on Lavaland.  Stabbing the corpse of a lavaland elite with this will revive them, assuming their soul still lingers.  Revived lavaland elites only have half their max health, but are completely loyal to their reviver."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "crevice_shard"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	item_state = "screwdriver_head"
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	
/obj/item/tumor_shard/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(istype(target, /mob/living/simple_animal/hostile/asteroid/elite) && proximity_flag)
		var/mob/living/simple_animal/hostile/asteroid/elite/E = target
		if(E.stat == DEAD && E.sentience_type == SENTIENCE_BOSS)
			if(E.key)
				E.faction = list("neutral")
				E.revive(full_heal = TRUE, admin_revive = TRUE)
				user.visible_message("<span class='notice'>[user] stabs [E] with [src], reviving it.</span>")
				SEND_SOUND(E, sound('sound/effects/magic.ogg'))
				to_chat(E, "<span class='userdanger'>You have been revived by [user].  While you can't speak to them, you owe [user] a great debt.  Assist [user.p_them()] in achieving [user.p_their()] goals, regardless of risk.</span")
				E.maxHealth = E.maxHealth * 0.5
				E.health = E.maxHealth
				E.desc = "[E.desc]  However, this one appears appears less wild in nature, and calmer around people."
				E.sentience_type = SENTIENCE_ORGANIC
				qdel(src)
				return
			else
				user.visible_message("<span class='notice'>It appears [E] is unable to be revived right now.  Perhaps try again later.</span>")
				return
		else
			to_chat(user, "<span class='info'>[src] only works on a dead, sentient lavaland elite.  If this one's been revived before, perhaps try a lazarus injection.</span>")
			return
	else
		to_chat(user, "<span class='info'>[src] only works on a sentient lavaland elite.</span>")
		return