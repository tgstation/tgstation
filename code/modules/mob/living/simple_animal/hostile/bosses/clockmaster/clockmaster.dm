/**
 *Clockmaster
 *
 *Clockmaster only spawns at the very end of the caves away mission on the 4th floor. He, along with a recently converted following of miners, are attempting to resurrect the once
 *long forgotten Rat-Var from his ashen resting place. Keeps some distance from the player and shoots a projectile that pierces armor. Has a pre-battle monologue with nearby
 *players before the fight actually begins. Cultists present during this fight take additional damage from all of his attacks but also deal more damage. If a cultist is present
 *during the first dialogue interaction, he will remark about this but not give away who the cultist actually is.
 *
 *He has 2 phases, each with their own unique attacks (located in phase_one_attacks.dm and phase_two_attacks.dm respectively)
 *
 *PHASE ONE:
 *Raise Ocular Warden - Summons 4 ocular warden turrets at predefined locations, dealing cold damage. The clockmaster shoots a projectile that deals bonus damage to people who
 *are suffering from extreme temperatures in either direction. Can trigger ability again to replenish lost turrets even if ones are still active.
 *
 *Steam Vent Trap - Activates the vents scattered around the arena, blowing scorching steam out of them. Running into these vests while active throws you in a random direction and
 *causes burn damage. Will disable after 30 seconds.
 *
 *Cogscarab Swarm - Summons 4 cogscarabs to act as trash mobs to draw attention off him. Can have up to 8 cogscarabs at a time.
 *
 *When Clockmaster gets to half health on his first phase, he will trigger a mid-combat dialogue where he summons shields around himself and destroys any active clockwork mobs. 
 *All nearby players are stunned for the duration of the dialogue as he spawns in the phase two version of himself.
 *
 *PHASE TWO:
 *Sevtug's Wrath - Summons a square around him and stops moving, if a player is caught in this square after 4 seconds they are thrown back and take toxin/brain damage, as well as
 *given 30 seconds of hallucinations. The boss takes half damage during this attack since he cannot move or use other abilities during it.
 *
 *Nzcrentr's Retribution - Marks a random nearby player as a target and draws a beam between them to distinguish who was chosen. The boss then will rapidly charge towards the
 *victim in a straight line trying to hit them. If he hits, throw the player back and cause major brute damage. Can miss the target since he aims for the floor below the mob
 *instead of the mob itself.
 *
 *Inath-Neq's Undying Legion - Summons 8 clockwork marauders in the corners of the arena and places a shield around themselves. The shield will not go down until all marauders
 *are fully dead. Deadlier version of cogscarab swarm. Cannot use other abilities during this attack.
 *
 *Steam Vent Trap - Same as the first phase's ability.
 *
 *Difficulty: Medium-Hard (advised to bring a couple friends or your own deathsquad suit)
 *
 *SHITCODE AHEAD. YOU WERE WARNED.
 */

/mob/living/simple_animal/hostile/boss/clockmaster
	name = "Clockwork Priest"
	desc = "A man who has gone mad with the promise of great power from a dead god."
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_BOSS
	boss_abilities = list(/datum/action/boss/turret_summon, /datum/action/boss/steam_traps, /datum/action/boss/cogscarab_swarm)
	mid_ability = TRUE //prevents the boss from going hog-wild on spawn since he's got some words for the players
	faction = list("clockwork")
	speech_span = SPAN_BRASS
	del_on_death = TRUE
	icon = 'icons/mob/simple/simple_human.dmi'
	icon_state = "clockminer"
	ranged = FALSE
	environment_smash = ENVIRONMENT_SMASH_NONE
	minimum_distance = 3
	retreat_distance = 3
	obj_damage = 0
	melee_damage_lower = 10
	melee_damage_upper = 20
	health = 2000
	maxHealth = 2000
	speed = 1
	loot = list()
	projectiletype = /obj/projectile/energy/inferno
	projectilesound = 'sound/weapons/emitter.ogg'
	attack_sound = 'sound/hallucinations/growl1.ogg'
	var/is_in_phase_2 = FALSE //are we past the health threshold and gone through our mid-way monologue?
	var/have_i_explained_my_evil_plan = FALSE //have we gone through our introduction monologue?
	var/is_there_a_cult_in_here = FALSE //if we noticed there was a cultist amongඞ the initial group during the introduction

/mob/living/simple_animal/hostile/boss/clockmaster/proc/monologue_camera_shake() //i use this enough to where i feel obligated to make it a separate proc
	for(var/mob/living/nearby_mob in urange(16, src))
		shake_camera(nearby_mob, 2, 3)

/mob/living/simple_animal/hostile/boss/clockmaster/Aggro()
	if(!have_i_explained_my_evil_plan)
		tell_them_my_evil_plan()
	..()

/mob/living/simple_animal/hostile/boss/clockmaster/proc/tell_them_my_evil_plan()
	have_i_explained_my_evil_plan = TRUE
	for(var/turf/target_tile as anything in RANGE_TURFS(1, src))
		if(!(locate(/obj/structure/emergency_shield/clockmaster_plot_armor) in target_tile))
			new /obj/structure/emergency_shield/clockmaster_plot_armor(target_tile)
	say("Welcome to the holy resting grounds of His Eminence, Grand in his Shining Bronze and cleansing steam. Have you come to repent for your trangressions?")
	sleep(5 SECONDS)
	say("I would only hope so, considering the alternative is that you've come to stop His recreation.")
	sleep(4 SECONDS)
	say("Sadly, His Eminence has no room for heretical dogs such as yourselves.")
	for(var/mob/living/nearby_mob in urange(16, src))
		if(IS_CULTIST(nearby_mob))//did you really come to the ratvar-themed boss and NOT expect to be called out?
			say("..ESPECIALLY for those who bare the mark of that wretched blood mother. You have a lot of nerve tainting these sacred grounds with your filth, scum.")
			is_there_a_cult_in_here = TRUE
	sleep(5 SECONDS)
	say("Fret not, for once I have cleansed you from the filth of your mortal coil, His Eminence will happily take your soul to power one of his grand designs.")
	sleep(5 SECONDS)
	say("Now, do not resist. It will only take a moment.")
	sleep(3 SECONDS)
	mid_ability = FALSE
	ranged = TRUE
	for(var/obj/structure/emergency_shield/clockmaster_plot_armor/plot_armor in urange(1, src))
		plot_armor.Destroy()

/obj/structure/emergency_shield/clockmaster_plot_armor
	name = "plot armor"
	desc = "A shield summoned by the Clockpriest so you can't interrupt his evil monologue."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	icon_state = "shield-red"

/mob/living/simple_animal/hostile/boss/clockmaster/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(health < maxHealth*0.5 && !is_in_phase_2)
		get_angry()


//activates at 50% hp, does a cool monologue before killing this mob and spawning the next stage
//TODO: cool transforming annimation before it spawns the 2nd phase
/mob/living/simple_animal/hostile/boss/clockmaster/proc/get_angry()
	is_in_phase_2 = TRUE
	ranged = FALSE
	speech_span = SPAN_RATVAR
	name = "Awakened Clockwork Priest"
	desc = "A shell of a man who has gone mad with the promise of great power from a not-so-dead god."
	for(var/turf/target_tile as anything in RANGE_TURFS(1, src))
		if(!(locate(/obj/structure/emergency_shield/clockmaster_plot_armor) in target_tile))
			new /obj/structure/emergency_shield/clockmaster_plot_armor(target_tile)
	for(var/mob/living/nearby_mob in urange(16, src))//you ain't running from this stun bucko
		shake_camera(nearby_mob, 2, 3)
		nearby_mob.Paralyze(25 SECONDS)
		//killing nearby clockcult mobs to prevent players from getting owned during the monologue
		if(istype(nearby_mob, /mob/living/simple_animal/hostile/clockwork))
			nearby_mob.gib()
		to_chat(nearby_mob, span_warning("You feel yourself tense up at the sound of [src]!"))
	say("ENOUGH!")
	mid_ability = TRUE
	sleep(3 SECONDS)
	say("I should of known relying on a mere mortal was a foolish endevour, such feeble creations cannot be trusted with divine work.")
	sleep(5 SECONDS)
	if(is_there_a_cult_in_here)//bro seriously did you think he wouldn't notice??
		say("Let alone when that WRETCHED Blood Mother DARES to show herself here through the mark on her heretical dogs.")
		sleep(4 SECONDS)
		say("Have you come to finish the job? To fully banish his divine light to eternal damnation on that Celestial Derelict?")
		sleep(5 SECONDS)
		monologue_camera_shake()
		say("WELL, YOU CAN FORGET IT WRETCH!")
		sleep(3 SECONDS)
		say("Far too long has his divine prescence been left here to rust among the ash, but NO LONGER!")
		sleep(4 SECONDS)
		say("Before I return you to the filth from wence you came, let your wretched blood mother know this one as a parting message:")
		sleep(5 SECONDS)
		monologue_camera_shake()
		say("WE ARE COMING FOR HER NEXT.")
		sleep(3 SECONDS)
	else
		say("I will just simply have to take over from here, lest I let you sully his chance at proper recreation.")
		sleep(5 SECONDS)
		say("Now, bare witness to true divine power!")
		sleep(3 SECONDS)
	monologue_camera_shake()
	icon = 'icons/effects/96x96.dmi'
	icon_state = "placeholder_clockmaster"
	pixel_x = -16
	base_pixel_x = -16
	maptext_height = 64
	maptext_width = 64
	playsound(src, 'sound/magic/clockwork/ratvar_rises.ogg', 100)
	say("Rhedpu qdt ijuqc, qzeydut yd wbehyeki kdyied!")
	sleep(3 SECONDS)
	monologue_camera_shake()
	say("Wbyijudydw cujqb, vehuluh ijqdtydw!")
	sleep(3 SECONDS)
	monologue_camera_shake()
	say("Buj cu qhyiu edsu cehu, qdt sbuqdiu jxu mehbt ev jxyi VYBJX!!")
	sleep(5 SECONDS)
	monologue_camera_shake()
	say("Y. QC. HUDUMUT!")
	sleep(3 SECONDS)
	for(var/obj/structure/emergency_shield/clockmaster_plot_armor/plot_armor in urange(1, src))
		plot_armor.Destroy()
	new /mob/living/simple_animal/hostile/boss/clockmaster/phase_two(get_turf(src))
	gib()


//TODO: make cool sprite based on nezbere
/mob/living/simple_animal/hostile/boss/clockmaster/phase_two
	name = "Punished Nezbere"
	desc = "A zealot follower and former General to an ancient machine god, now desperate to bring back his former deity by any means neccesary."
	boss_abilities = list(/datum/action/boss/brain_blast, /datum/action/boss/spinning_bronze, /datum/action/boss/marauder_swarm, /datum/action/boss/steam_traps)
	speech_span = SPAN_RATVAR
	minimum_distance = 0
	retreat_distance = 0
	speed = 3

/mob/living/simple_animal/hostile/boss/clockmaster/phase_two/tell_them_my_evil_plan()
	have_i_explained_my_evil_plan = TRUE
	say("y'all mfers dead af lmao")
	mid_ability = FALSE

//phase 2 has an attack that throws the mob, if he happens to get launched by a steam vent and hit someone too that'd be pretty funny
/mob/living/simple_animal/hostile/boss/clockmaster/phase_two/throw_impact(mob/living/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(istype(hit_atom))
		playsound(src, attack_sound, 100, TRUE)
		hit_atom.apply_damage(22, wound_bonus = CANT_WOUND)
		hit_atom.safe_throw_at(get_step(src, get_dir(src, hit_atom)), 2)


//placeholder for public test
/mob/living/simple_animal/hostile/boss/clockmaster/map_maker
	name = "Map Maker"
	desc = "A man in an engineering uniform, he looks tired."
	icon_state = "map_maker"
	loot = list(/obj/structure/closet/syndicate/resources/everything)

/mob/living/simple_animal/hostile/boss/clockmaster/map_maker/tell_them_my_evil_plan()
	have_i_explained_my_evil_plan = TRUE
	for(var/turf/target_tile as anything in RANGE_TURFS(1, src))
		if(!(locate(/obj/structure/emergency_shield/clockmaster_plot_armor) in target_tile))
			new /obj/structure/emergency_shield/clockmaster_plot_armor(target_tile)
	say("Oh, you're here already? I thought I had at least another week..")
	sleep(3 SECONDS)
	say("Well, this part isn't exactly ready for public use yet. Wish you knew that before you fought through all that shit, huh?")
	sleep(4 SECONDS)
	say("Don't worry, I'll throw you some pity loot as compensation for making it this far. It won't be as good as the actual rewards once I'm done though.")
	sleep(5 SECONDS)
	say("There should be a feedback thread up by this point along with the github PR itself to leave any notes/criticsm you may have so far. I'd really appreciate it.")
	sleep(6 SECONDS)
	say("Alright, gotta go. Take the rift behind me to get back to the main mining post. Try not to distract the workers, they're busy making the arena.")
	sleep(5 SECONDS)
	for(var/obj/structure/emergency_shield/clockmaster_plot_armor/plot_armor in urange(1, src))
		plot_armor.Destroy()
	gib()
