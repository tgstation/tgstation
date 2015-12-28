/mob/living/simple_animal/hostile/syndicate
	name = "Syndicate Operative"
	desc = "Death to Nanotrasen."
	icon_state = "syndicate"
	icon_living = "syndicate"
	icon_dead = "syndicate_dead"
	icon_gib = "syndicate_gib"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	stat_attack = 1
	robust_searching = 1
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "punches"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = "harm"
	loot = list(/obj/effect/landmark/mobcorpse/syndicatesoldier)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	faction = list("syndicate")
	status_flags = CANPUSH
	del_on_death = 1

///////////////Sword and shield////////////

/mob/living/simple_animal/hostile/syndicate/melee
	melee_damage_lower = 25
	melee_damage_upper = 30
	icon_state = "syndicatemelee"
	icon_living = "syndicatemelee"
	loot = list(/obj/effect/landmark/mobcorpse/syndicatesoldier,
				/obj/item/weapon/melee/energy/sword/saber/red,
				/obj/item/weapon/shield/energy)
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	armour_penetration = 28
	status_flags = 0
	maxHealth = 170
	health = 170

/mob/living/simple_animal/hostile/syndicate/melee/bullet_act(obj/item/projectile/Proj)
	if(!Proj)	return
	if(prob(50))
		if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
			src.health -= Proj.damage
	else
		visible_message("<span class='danger'>[src] blocks [Proj] with its shield!</span>")
	return 0


/mob/living/simple_animal/hostile/syndicate/melee/space
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	icon_state = "syndicatemeleespace"
	icon_living = "syndicatemeleespace"
	name = "Syndicate Commando"
	loot = list(/obj/effect/landmark/mobcorpse/syndicatecommando,
				/obj/item/weapon/melee/energy/sword/saber/red,
				/obj/item/weapon/shield/energy)
	speed = 1

/mob/living/simple_animal/hostile/syndicate/melee/space/Process_Spacemove(movement_dir = 0)
	return

/mob/living/simple_animal/hostile/syndicate/ranged
	ranged = 1
	rapid = 1
	retreat_distance = 5
	minimum_distance = 5
	icon_state = "syndicateranged"
	icon_living = "syndicateranged"
	casingtype = /obj/item/ammo_casing/c45nostamina
	projectilesound = 'sound/weapons/Gunshot_smg.ogg'
	loot = list(/obj/effect/landmark/mobcorpse/syndicatesoldier,
				/obj/item/weapon/gun/projectile/automatic/c20r/unrestricted,
				/obj/item/weapon/shield/energy)

/mob/living/simple_animal/hostile/syndicate/ranged/space
	icon_state = "syndicaterangedpsace"
	icon_living = "syndicaterangedpsace"
	name = "Syndicate Commando"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	speed = 1
	loot = list(/obj/effect/landmark/mobcorpse/syndicatecommando,
				/obj/item/weapon/gun/projectile/automatic/c20r/unrestricted,
				/obj/item/weapon/shield/energy)

/mob/living/simple_animal/hostile/syndicate/ranged/space/Process_Spacemove(movement_dir = 0)
	return


/mob/living/simple_animal/hostile/syndicate/civilian
	minimum_distance = 10
	retreat_distance = 10
	environment_smash = 0

/mob/living/simple_animal/hostile/syndicate/civilian/Aggro()
	..()
	summon_backup(15)
	say("GUARDS!!")


/mob/living/simple_animal/hostile/viscerator
	name = "viscerator"
	desc = "A small, twin-bladed machine capable of inflicting very deadly lacerations."
	icon_state = "viscerator_attack"
	icon_living = "viscerator_attack"
	pass_flags = PASSTABLE
	health = 15
	maxHealth = 15
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "cuts"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	faction = list("syndicate")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	mob_size = MOB_SIZE_TINY
	flying = 1
	speak_emote = list("states")
	gold_core_spawnable = 1
	del_on_death = 1

/mob/living/simple_animal/hostile/viscerator/New()
	..()
	deathmessage = "<b>[src]</b> is smashed into pieces!"
