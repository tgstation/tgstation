//Glyphids, based off the game Deep Rock Galactic

#define GLYPHID_IDLE 0
#define SPINNING_WEB 1
#define BUILDING_TOWER 3
#define MOVING_TO_TARGET 3

/mob/living/simple_animal/hostile/glyphid
	name = "glyphid"
	desc = "A colony-based insectoid.  Watch those jaws."
	icon_state = "nurse"
	icon_living = "nurse"
	icon_dead = "nurse_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	speak_emote = list("chitters", "roars")
	turns_per_move = 5
	see_in_dark = 10
	response_help  = "rubs the hard chitin of"
	response_disarm = "gently pushes aside"
	response_harm   = "bashes"
	maxHealth = 90
	health = 90
	speed = 0
	var/busy = GLYPHID_IDLE
	spacewalk = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	var/playable_glyphid = TRUE
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	deathmessage = "screeches before falling limp."
	var/datum/action/innate/glyphid/build_tower/build_tower
	
	var/amount_grown = 0
	var/max_grown = 200

	obj_damage = 30
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "chomps on and slices"
	attack_sound = 'sound/weapons/bite.ogg'
	friendly = "glyphid nuzzles"

	//Glyphids aren't affected by cold.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500

	faction = list("glyphid")
	gold_core_spawnable = NO_SPAWN
	
	do_footstep = TRUE
	
/mob/living/simple_animal/hostile/glyphid/Topic(href, href_list)
	if(href_list["activate"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost) && playable_glyphid)
			humanize_glyphid(ghost)

/mob/living/simple_animal/hostile/glyphid/Login()
	..()
	to_chat(src, "<span class='notice'>Expand and defend the swarm!</span>")

/mob/living/simple_animal/hostile/glyphid/attack_ghost(mob/user)
	. = ..()
	if(.)
		return
	humanize_glyphid(user)

/mob/living/simple_animal/hostile/glyphid/proc/humanize_glyphid(mob/user)
	if(key || !playable_glyphid || stat)//Someone is in it, it's dead, or the fun police are shutting it down
		return false
	var/glyphid_ask = alert("Become a glyphid?", "Do you hate dwarves?", "Yes", "No")
	if(glyphid_ask == "No" || !src || QDELETED(src))
		return true
	if(key)
		to_chat(user, "<span class='notice'>Someone else already took this glyphid.</span>")
		return true
	key = user.key
	return true
	
/mob/living/simple_animal/hostile/glyphid/swarmer
	name = "glyphid swarmer"
	desc = "A tiny, pink insect.  Watch your toes."
	response_help  = "rubs"
	maxHealth = 12
	health = 12
	obj_damage = 5
	melee_damage_lower = 2
	melee_damage_upper = 2
	attacktext = "nibbles on"
	speed = -1
	color = rgb(248,24,148)
	var/datum/action/innate/glyphid/swarmer/swarmer_evolve/swarmer_evolve
	
/mob/living/simple_animal/hostile/glyphid/swarmer/Life()
	if (notransform)
		return
	if(..()) //not dead
		// GROW!
		if(amount_grown < max_grown)
			amount_grown++

/mob/living/simple_animal/hostile/glyphid/swarmer/Initialize()
	. = ..()
	swarmer_evolve = new
	swarmer_evolve.Grant(src)
	src.transform *= 0.5
	
/mob/living/simple_animal/hostile/glyphid/swarmer/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Progress: [amount_grown]/[max_grown]")
		
/mob/living/simple_animal/hostile/glyphid/swarmer/Life()
	if (notransform)
		return
	if(..()) //not dead
		// GROW!
		if(amount_grown < max_grown)
			amount_grown++
		
/mob/living/simple_animal/hostile/glyphid/grunt
	name = "glyphid grunt"
	desc = "The backbone of the glyphid's hierarchy.  Watch out for that nasty bite."
	maxHealth = 50
	health = 50
	max_grown = 300
	melee_damage_lower = 10
	melee_damage_upper = 10
	speed = 1
	color = rgb(152,251,152)
	var/datum/action/innate/glyphid/grunt/grunt_evolve/grunt_evolve
	
/mob/living/simple_animal/hostile/glyphid/grunt/Initialize()
	. = ..()
	build_tower = new
	build_tower.Grant(src)
	grunt_evolve = new
	grunt_evolve.Grant(src)
	
/mob/living/simple_animal/hostile/glyphid/grunt/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Progress: [amount_grown]/[max_grown]")
		
/mob/living/simple_animal/hostile/glyphid/grunt/Life()
	if (notransform)
		return
	if(..()) //not dead
		// GROW!
		if(amount_grown < max_grown)
			amount_grown++
			
/mob/living/simple_animal/hostile/glyphid/silkspinner
	name = "glyphid silkspinner"
	desc = "The support unit of the glyphids.  Uses silk strands to heal wounds of other glyphids."
	maxHealth = 30
	health = 30
	max_grown = 400
	color = rgb(255,0,255)
	var/heal_power = 10
	friendly = "sprays biofluid onto"
	melee_damage_lower = 0
	melee_damage_upper = 0
	var/datum/action/innate/glyphid/silkspinner/lay_web/lay_web
	var/datum/action/innate/glyphid/silkspinner/silkspinner_evolve/silkspinner_evolve
	
/mob/living/simple_animal/hostile/glyphid/silkspinner/Initialize()
	. = ..()
	lay_web = new
	lay_web.Grant(src)
	silkspinner_evolve = new
	silkspinner_evolve.Grant(src)
	
/mob/living/simple_animal/hostile/glyphid/silkspinner/AttackingTarget()
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat != DEAD)
			L.heal_overall_damage(heal_power, heal_power)
			new /obj/effect/temp_visual/heal(get_turf(target), "#80F5FF")

/mob/living/simple_animal/hostile/glyphid/silkspinner/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Progress: [amount_grown]/[max_grown]")
		
/mob/living/simple_animal/hostile/glyphid/silkspinner/Life()
	if (notransform)
		return
	if(..()) //not dead
		// GROW!
		if(amount_grown < max_grown)
			amount_grown++
	
/mob/living/simple_animal/hostile/glyphid/exploder
	name = "glyphid exploder"
	desc = "The powerhouse of the glyphid hierarchy.  Closes the gap with its target quickly, and then explodes."
	maxHealth = 20
	health = 20
	color = rgb(255,1,1)
	var/datum/action/innate/glyphid/exploder/explode/explode
	
/mob/living/simple_animal/hostile/glyphid/exploder/Initialize()
	. = ..()
	explode = new
	explode.Grant(src)
	
/mob/living/simple_animal/hostile/glyphid/veteran
	name = "glyphid veteran"
	desc = "An advanced variation of the glyphid grunt.  More of the same, just tougher."
	maxHealth = 80
	health = 80
	max_grown = 300
	melee_damage_lower = 20
	melee_damage_upper = 20
	speed = 1
	color = rgb(152,251,152)
	var/datum/action/innate/glyphid/veteran/veteran_evolve/veteran_evolve
	
/mob/living/simple_animal/hostile/glyphid/veteran/Initialize()
	. = ..()
	veteran_evolve = new
	veteran_evolve.Grant(src)
	src.transform *= 1.2
	
/mob/living/simple_animal/hostile/glyphid/veteran/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Progress: [amount_grown]/[max_grown]")
		
/mob/living/simple_animal/hostile/glyphid/veteran/Life()
	if (notransform)
		return
	if(..()) //not dead
		// GROW!
		if(amount_grown < max_grown)
			amount_grown++

/mob/living/simple_animal/hostile/glyphid/acidspitter
	name = "glyphid acidspitter"
	desc = "The sniper of the glyphid hierarchy.  Shoots toxic acid at targets."
	maxHealth = 60
	health = 60
	color = rgb(114,228,250)
	projectiletype = /obj/item/projectile/temp/acidspitter
	projectilesound = 'sound/effects/spray3.ogg'
	ranged = 1
	ranged_message = "spits at"
	ranged_cooldown_time = 30
	
/obj/item/projectile/temp/acidspitter
	name = "acid spit"
	icon_state = "tentacle_end"
	damage = 20
	damage_type = BRUTE
	color = rgb(255,255,0)
	
/mob/living/simple_animal/hostile/glyphid/acidspitter/Initialize()
	. = ..()
	src.transform *= 1.2
	
/mob/living/simple_animal/hostile/glyphid/praetorian
	name = "glyphid praetorian"
	desc = "The tank of the glyphid hierarchy.  Takes quite the beating, and hits like a truck."
	maxHealth = 500
	health = 500
	max_grown = 2000
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	obj_damage = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 2
	color = rgb(114,228,250)
	var/datum/action/innate/glyphid/praetorian/praetorian_evolve/praetorian_evolve
	
/mob/living/simple_animal/hostile/glyphid/praetorian/Initialize()
	. = ..()
	src.transform *= 1.5
	
/mob/living/simple_animal/hostile/glyphid/praetorian/Initialize()
	. = ..()
	praetorian_evolve = new
	praetorian_evolve.Grant(src)
	
/mob/living/simple_animal/hostile/glyphid/praetorian/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Progress: [amount_grown]/[max_grown]")
		
/mob/living/simple_animal/hostile/glyphid/praetorian/Life()
	if (notransform)
		return
	if(..()) //not dead
		// GROW!
		if(amount_grown < max_grown)
			amount_grown++
	
/mob/living/simple_animal/hostile/glyphid/dreadnought
	name = "glyphid dreadnought"
	desc = "The be-all-end-all of glyphids.  Take EXTREME precaution in engaging."
	maxHealth = 800
	health = 800
	melee_damage_lower = 50
	melee_damage_upper = 50
	ranged = 1
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	obj_damage = 400
	speed = 2
	color = rgb(114,228,250)
	projectiletype = /obj/item/projectile/magic/aoe/fireball
	ranged_cooldown_time = 100
	
/mob/living/simple_animal/hostile/glyphid/dreadnought/Initialize()
	. = ..()
	src.transform *= 2
	mob_spell_list += new /obj/effect/proc_holder/spell/aoe_turf/repulse/glyphid(src)

//	
//Glyphid powers below
//
		
/datum/action/innate/glyphid/build_tower
	name = "Construct Tower"
	desc = "Construct a tower to support your numbers."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "lay_eggs"
		
/datum/action/innate/glyphid/build_tower/Activate()
	if(!istype(owner, /mob/living/simple_animal/hostile/glyphid))
		return
	var/mob/living/simple_animal/hostile/glyphid/S = owner

	if(!isturf(S.loc))
		return
	var/turf/T = get_turf(S)

	var/obj/structure/spawner/glyphid/W = locate() in T
	if(W)
		to_chat(S, "<span class='warning'>There's already a tower here!</span>")
		return

	if(S.busy != BUILDING_TOWER)
		S.busy = BUILDING_TOWER
		S.visible_message("<span class='notice'>[S] begins to shape up dirt and excrete biomass...</span>","<span class='notice'>You begin to build a tower...</span>")
		S.stop_automated_movement = TRUE
		if(do_after(S, 800, target = T))
			if(S.busy == BUILDING_TOWER && S.loc == T)
				new /obj/structure/spawner/glyphid(T)
		S.busy = GLYPHID_IDLE
		S.stop_automated_movement = FALSE
	else
		to_chat(S, "<span class='warning'>You're already building a tower!</span>")
		
/obj/structure/spider/biofluid
	icon_state = "stickyweb1"
	color = rgb(152,251,152)
	name = "biofluid"
	desc = "It seems sticky and smells awful."

/obj/structure/spider/biofluid/Initialize()
	if(prob(50))
		icon_state = "stickyweb2"
	. = ..()

/obj/structure/spider/biofluid/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /mob/living/simple_animal/hostile/glyphid))
		return TRUE
	else if(isliving(mover))
		if(istype(mover.pulledby, /mob/living/simple_animal/hostile/glyphid))
			return TRUE
		if(prob(50))
			to_chat(mover, "<span class='danger'>You get stuck in \the [src] for a moment.</span>")
			return FALSE
	else if(istype(mover, /obj/item/projectile))
		return prob(30)
	return TRUE

/datum/action/innate/glyphid/silkspinner/lay_web
	name = "Excrete Biofluid"
	desc = "Excrete a web-like substance to slow intruders."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "lay_web"

/datum/action/innate/glyphid/silkspinner/lay_web/Activate()
	if(!istype(owner, /mob/living/simple_animal/hostile/glyphid/silkspinner))
		return
	var/mob/living/simple_animal/hostile/glyphid/silkspinner/S = owner

	if(!isturf(S.loc))
		return
	var/turf/T = get_turf(S)

	var/obj/structure/spider/biofluid/W = locate() in T
	if(W)
		to_chat(S, "<span class='warning'>There's already a web here!</span>")
		return

	if(S.busy != SPINNING_WEB)
		S.busy = SPINNING_WEB
		S.visible_message("<span class='notice'>[S] begins to secrete a sticky substance.</span>","<span class='notice'>You begin to excrete biofluid.</span>")
		S.stop_automated_movement = TRUE
		if(do_after(S, 40, target = T))
			if(S.busy == SPINNING_WEB && S.loc == T)
				new /obj/structure/spider/biofluid(T)
		S.busy = GLYPHID_IDLE
		S.stop_automated_movement = FALSE
	else
		to_chat(S, "<span class='warning'>You're already excreting biofluid!</span>")
		
/datum/action/innate/glyphid/exploder/explode
	name = "Explode"
	desc = "Activate the chemicals in your abdomen and explode."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "sacredflame"

/datum/action/innate/glyphid/exploder/Activate()
	var/mob/living/simple_animal/hostile/glyphid/exploder/H = owner
	to_chat(owner, "<span class='notice'>You explode!</span>")
	explosion(get_turf(H),1,2,2,flame_range = 3)
	if(H)
		H.gib()

/mob/living/simple_animal/hostile/glyphid/proc/glyphid_evolve(mob/living/simple_animal/hostile/glyphid/new_glyphid)
	to_chat(src, "<span class='noticealien'>You begin to evolve!</span>")
	visible_message("<span class='alertalien'>[src] begins to twist and contort!</span>")
	if(mind)
		mind.transfer_to(new_glyphid)
	qdel(src)
		
/datum/action/innate/glyphid/swarmer/swarmer_evolve
	name = "Evolve"
	desc = "Evolve into a higher glyphid caste."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "lay_eggs"
		
/datum/action/innate/glyphid/swarmer/swarmer_evolve/Activate()
	var/mob/living/simple_animal/hostile/glyphid/swarmer/L = owner

	if(L.amount_grown >= L.max_grown)
		to_chat(L, "<span class='name'>You are growing into a more capable form.  It is time to choose your future.</span>")
		to_chat(L, "<span class='info'>There are three forms to choose from:</span>")
		to_chat(L, "<span class='name'>Grunts</span> <span class='info'>are the everyman, with the ability to build towers and have good melee capability.</span>")
		to_chat(L, "<span class='name'>Webspitters</span> <span class='info'>are the ranged protectors, slowing down threats with web shots so other glyphids can handle them.</span>")
		to_chat(L, "<span class='name'>Exploders</span> <span class='info'>are the glass cannons, being able to explode on command.</span>")
		var/glyphid_caste = alert(L, "Please choose which glyphid caste you shall belong to.",,"Grunt","Silkspinner","Exploder")

		if(L.health == 0) //something happened to us while we were choosing.
			return

		var/mob/living/simple_animal/hostile/glyphid/new_glyphid
		switch(glyphid_caste)
			if("Grunt")
				new_glyphid = new /mob/living/simple_animal/hostile/glyphid/grunt(L.loc)
			if("Silkspinner")
				new_glyphid = new /mob/living/simple_animal/hostile/glyphid/silkspinner(L.loc)
			if("Exploder")
				new_glyphid = new /mob/living/simple_animal/hostile/glyphid/exploder(L.loc)

		L.glyphid_evolve(new_glyphid)
		return 0
	else
		to_chat(owner, "<span class='danger'>You are not fully grown.</span>")
		return 0
		
/datum/action/innate/glyphid/grunt/grunt_evolve
	name = "Evolve"
	desc = "Evolve into a glyphid veteran."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "lay_eggs"
		
/datum/action/innate/glyphid/grunt/grunt_evolve/Activate()
	var/mob/living/simple_animal/hostile/glyphid/grunt/L = owner
	if(L.amount_grown >= L.max_grown)
		var/mob/living/simple_animal/hostile/glyphid/new_glyphid
		new_glyphid = new /mob/living/simple_animal/hostile/glyphid/veteran(L.loc)
		L.glyphid_evolve(new_glyphid)
		return 0
	else
		to_chat(owner, "<span class='danger'>You are not fully grown.</span>")
		return 0
		
/datum/action/innate/glyphid/veteran/veteran_evolve
	name = "Evolve"
	desc = "Evolve into a glyphid praetorian."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "lay_eggs"
		
/datum/action/innate/glyphid/veteran/veteran_evolve/Activate()
	var/mob/living/simple_animal/hostile/glyphid/veteran/L = owner
	if(L.amount_grown >= L.max_grown)
		var/mob/living/simple_animal/hostile/glyphid/new_glyphid
		new_glyphid = new /mob/living/simple_animal/hostile/glyphid/praetorian(L.loc)
		L.glyphid_evolve(new_glyphid)
		return 0
	else
		to_chat(owner, "<span class='danger'>You are not fully grown.</span>")
		return 0

/datum/action/innate/glyphid/praetorian/praetorian_evolve
	name = "Evolve"
	desc = "Evolve into a glyphid dreadnought."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "lay_eggs"
		
/datum/action/innate/glyphid/praetorian/praetorian_evolve/Activate()
	var/mob/living/simple_animal/hostile/glyphid/praetorian/L = owner
	if(L.amount_grown >= L.max_grown)
		var/mob/living/simple_animal/hostile/glyphid/new_glyphid
		new_glyphid = new /mob/living/simple_animal/hostile/glyphid/dreadnought(L.loc)
		L.glyphid_evolve(new_glyphid)
		return 0
	else
		to_chat(owner, "<span class='danger'>You are not fully grown.</span>")
		return 0
	
/datum/action/innate/glyphid/silkspinner/silkspinner_evolve
	name = "Evolve"
	desc = "Evolve into a glyphid acidspitter."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "lay_eggs"
	
/datum/action/innate/glyphid/silkspinner/silkspinner_evolve/Activate()
	var/mob/living/simple_animal/hostile/glyphid/silkspinner/L = owner
	if(L.amount_grown >= L.max_grown)
		var/mob/living/simple_animal/hostile/glyphid/new_glyphid
		new_glyphid = new /mob/living/simple_animal/hostile/glyphid/acidspitter(L.loc)
		L.glyphid_evolve(new_glyphid)
		return 0
	else
		to_chat(owner, "<span class='danger'>You are not fully grown.</span>")
		return 0
		
/obj/effect/proc_holder/spell/aoe_turf/repulse/glyphid
	name = "Ground Pound"
	desc = "Smash the ground, knocking everyone away from you."
	sound = 'sound/effects/meteorimpact.ogg'
	charge_max = 150
	clothes_req = FALSE
	antimagic_allowed = TRUE
	range = 2
	cooldown_min = 150
	invocation_type = "none"
	anti_magic_check = FALSE

/obj/effect/proc_holder/spell/aoe_turf/repulse/glyphid/cast(list/targets,mob/user = usr)
	..(targets, user, 60)
