//TODO: cult item interactions, make boss do more damage to cult item weilders and take more damage from cult items
/mob/living/simple_animal/hostile/boss/clockmaster
	name = "Clockwork Priest"
	desc = "A man who has gone mad with the promise of great power from a dead god."
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	boss_abilities = list(/datum/action/boss/turret_summon, /datum/action/boss/steam_traps, /datum/action/boss/cogscarab_swarm)
	assign_abilities = FALSE
	faction = list("clockwork")
	speech_span = SPAN_BRASS
	del_on_death = TRUE
	icon = 'icons/mob/simple_human.dmi'
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
	loot = list(/obj/effect/temp_visual/paperwiz_dying)
	projectiletype = /obj/projectile/temp/hot
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
	AssignAbilities()
	ranged = TRUE
	for(var/obj/structure/emergency_shield/clockmaster_plot_armor/plot_armor in urange(1, src))
		plot_armor.Destroy()

/obj/structure/emergency_shield/clockmaster_plot_armor
	name = "plot armor"
	desc = "A shield summoned by the Clockpriest so you can't interrupt his evil monologue."
	max_integrity = 10000
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
		if(istype(nearby_mob, /mob/living/simple_animal/hostile/ocular_warden) || istype(nearby_mob, /mob/living/simple_animal/hostile/cogscarab))
			nearby_mob.gib()
		RemoveAbilities()
		to_chat(nearby_mob, span_warning("You feel yourself tense up at the sound of [src]!"))
	say("ENOUGH!")
	sleep(3 SECONDS)
	say("I should of known relying on a mere mortal was a foolish endevour, such feeble creations cannot be trusted with divine work.")
	sleep(5 SECONDS)
	if(is_there_a_cult_in_here)//bro seriously did you think he wouldn't notice??
		say("Let alone when that WRETCHED Blood Mother DARES to show herself here through the mark on her heretical dogs.")
		sleep(4 SECONDS)
		say("Have you come to finish the job? To try and finally snuff out my divine light and rust away my carapace to blow away in the wind?")
		sleep(5 SECONDS)
		monologue_camera_shake()
		say("WELL, YOU CAN FORGET IT, WRETCH.")
		sleep(3 SECONDS)
		monologue_camera_shake()
		say("I WILL NOT BE LEFT TO ROT IN THIS HELLSCAPE BY THE LIKES OF YOU!")
		sleep(3 SECONDS)
		monologue_camera_shake()
		say("NOW BARE WITNESS, HERETIC! AND LET HER KNOW THIS AS I TEAR YOU FROM YOUR MORTAL COIL:")
		sleep(3 SECONDS)
		monologue_camera_shake()
		say("I AM COMING FOR HER NEXT.")
		sleep(3 SECONDS)
	else
		say("I will just simply have to take over from here, lest I let you sully my chances of recreation.")
		sleep(5 SECONDS)
		say("Now, bare witness to true divine power!")
		sleep(3 SECONDS)
	monologue_camera_shake()
	say("Rhedpu qdt ijuqc, qzeydut yd wbehyeki kdyied!")
	sleep(3 SECONDS)
	monologue_camera_shake()
	say("Wbyijudydw cujqb, vehuluh ijqdtydw!")
	sleep(3 SECONDS)
	monologue_camera_shake()
	say("Buj cu qhyiu edsu cehu, qdt sbuqdiu jxu mehbt ev jxyi VYBJX!!")
	sleep(3 SECONDS)
	monologue_camera_shake()
	say("Y. QC. HUDUMUT!")
	sleep(2 SECONDS)
	for(var/obj/structure/emergency_shield/clockmaster_plot_armor/plot_armor in urange(1, src))
		plot_armor.Destroy()
	new /mob/living/simple_animal/hostile/boss/clockmaster/phase_two(get_turf(src))
	gib()


//TODO: actually make the abilities for his 2nd stage
/mob/living/simple_animal/hostile/boss/clockmaster/phase_two
	name = "Justicar of Bronze"
	desc = "How can you kill a god? What a grand and intoxicating innocence."
	boss_abilities = list(/datum/action/boss/turret_summon, /datum/action/boss/steam_traps, /datum/action/boss/cogscarab_swarm)
	speech_span = SPAN_RATVAR

/mob/living/simple_animal/hostile/boss/clockmaster/phase_two/tell_them_my_evil_plan()
	have_i_explained_my_evil_plan = TRUE
	say("y'all mfers dead af lmao")
	AssignAbilities()
