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
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "punches"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = "harm"
	var/corpse = /obj/effect/landmark/mobcorpse/syndicatesoldier
	var/weapon1
	var/weapon2
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	faction = list("syndicate")
	status_flags = CANPUSH

/mob/living/simple_animal/hostile/syndicate/death(gibbed)
	..(gibbed)
	if(corpse)
		new corpse (src.loc)
	if(weapon1)
		new weapon1 (src.loc)
	if(weapon2)
		new weapon2 (src.loc)
	qdel(src)
	return

///////////////Sword and shield////////////

/mob/living/simple_animal/hostile/syndicate/melee
	melee_damage_lower = 20
	melee_damage_upper = 25
	icon_state = "syndicatemelee"
	icon_living = "syndicatemelee"
	weapon1 = /obj/item/weapon/melee/energy/sword/saber/red
	weapon2 = /obj/item/weapon/shield/energy
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	status_flags = 0

/mob/living/simple_animal/hostile/syndicate/melee/attackby(obj/item/O, mob/user, params)
	if(O.force)
		if(prob(80))
			var/damage = O.force
			if (O.damtype == STAMINA)
				damage = 0
			health -= damage
			visible_message("<span class='danger'>[user] has attacked [src] with [O]!</span>")
		else
			visible_message("<span class='danger'>[src] blocks [O] with its shield!</span>")
		playsound(loc, O.hitsound, 25, 1, -1)
	else
		usr << "<span class='warning'>This weapon is ineffective, it does no damage!</span>"
		visible_message("<span class='warning'>[user] gently taps [src] with [O].</span>")


/mob/living/simple_animal/hostile/syndicate/melee/bullet_act(obj/item/projectile/Proj)
	if(!Proj)	return
	if(prob(65))
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
	corpse = /obj/effect/landmark/mobcorpse/syndicatecommando
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
	casingtype = /obj/item/ammo_casing/c45
	projectilesound = 'sound/weapons/Gunshot_smg.ogg'
	projectiletype = /obj/item/projectile/bullet/midbullet2

	weapon1 = /obj/item/weapon/gun/projectile/automatic/c20r

/mob/living/simple_animal/hostile/syndicate/ranged/space
	icon_state = "syndicaterangedpsace"
	icon_living = "syndicaterangedpsace"
	name = "Syndicate Commando"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	corpse = /obj/effect/landmark/mobcorpse/syndicatecommando
	speed = 1

/mob/living/simple_animal/hostile/syndicate/ranged/space/Process_Spacemove(movement_dir = 0)
	return



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

/mob/living/simple_animal/hostile/viscerator/death(gibbed)
	..(gibbed)
	visible_message("<span class='danger'><b>[src]</b> is smashed into pieces!</span>")
	qdel(src)
	return