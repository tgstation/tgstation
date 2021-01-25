/mob/living/simple_animal/hostile/cockroach
	name = "cockroach"
	desc = "This station is just crawling with bugs."
	icon_state = "cockroach"
	icon_dead = "cockroach"
	health = 1
	maxHealth = 1
	turns_per_move = 5
	loot = list(/obj/effect/decal/cleanable/insectguts)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 270
	maxbodytemp = INFINITY
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	mob_biotypes = MOB_ORGANIC|MOB_BUG
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "splats"
	response_harm_simple = "splat"
	speak_emote = list("chitters")
	density = FALSE
	melee_damage_lower = 0
	melee_damage_upper = 0
	obj_damage = 0
	ventcrawler = VENTCRAWLER_ALWAYS
	gold_core_spawnable = FRIENDLY_SPAWN
	verb_say = "chitters"
	verb_ask = "chitters inquisitively"
	verb_exclaim = "chitters loudly"
	verb_yell = "chitters loudly"
	del_on_death = TRUE
	environment_smash = ENVIRONMENT_SMASH_NONE
	faction = list("neutral")
	var/squish_chance = 50

/mob/living/simple_animal/hostile/cockroach/Initialize()
	. = ..()
	add_cell_sample()
	make_squashable()

/mob/living/simple_animal/hostile/cockroach/proc/make_squashable()
	AddElement(/datum/element/squashable, squash_chance = 50, squash_damage = 1)

/mob/living/simple_animal/hostile/cockroach/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_COCKROACH, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 7)

/obj/projectile/glockroachbullet
	damage = 10 //same damage as a hivebot
	damage_type = BRUTE

/obj/item/ammo_casing/glockroach
	name = "0.9mm bullet casing"
	desc = "A... 0.9mm bullet casing? What?"
	projectile_type = /obj/projectile/glockroachbullet

/mob/living/simple_animal/hostile/cockroach/glockroach
	name = "glockroach"
	desc = "HOLY SHIT, THAT COCKROACH HAS A GUN!"
	icon_state = "glockroach"
	melee_damage_lower = 5
	melee_damage_upper = 5
	obj_damage = 20
	gold_core_spawnable = HOSTILE_SPAWN
	projectilesound = 'sound/weapons/gun/pistol/shot.ogg'
	projectiletype = /obj/projectile/glockroachbullet
	casingtype = /obj/item/ammo_casing/glockroach
	ranged = TRUE
	faction = list("hostile")

/mob/living/simple_animal/hostile/cockroach/death(gibbed)
	if(SSticker.mode && SSticker.mode.station_was_nuked) //If the nuke is going off, then cockroaches are invincible. Keeps the nuke from killing them, cause cockroaches are immune to nukes.
		return
	..()

/mob/living/simple_animal/hostile/cockroach/ex_act() //Explosions are a terrible way to handle a cockroach.
	return

/mob/living/simple_animal/hostile/cockroach/hauberoach
	name = "hauberoach"
	desc = "Is that cockroach wearing a tiny yet immaculate replica 19th century Prussian spiked helmet? ...Is that a bad thing?"
	icon_state = "hauberoach"
	attack_verb_continuous = "rams its spike into"
	attack_verb_simple = "ram your spike into"
	melee_damage_lower = 5
	melee_damage_upper = 20
	obj_damage = 20
	gold_core_spawnable = HOSTILE_SPAWN
	attack_sound = 'sound/weapons/bladeslice.ogg'
	faction = list("hostile")
	sharpness = SHARP_POINTY
	squish_chance = 0 // manual squish if relevant

/mob/living/simple_animal/hostile/cockroach/hauberoach/Initialize()
	. = ..()
	AddElement(/datum/element/caltrop, min_damage = 10, max_damage = 15, flags = (CALTROP_BYPASS_SHOES | CALTROP_SILENT))

/mob/living/simple_animal/hostile/cockroach/hauberoach/make_squashable()
	AddElement(/datum/element/squashable, squash_chance = 100, squash_damage = 1, squash_callback = /mob/living/simple_animal/hostile/cockroach/hauberoach/.proc/on_squish)

///Proc used to override the squashing behavior of the normal cockroach.
/mob/living/simple_animal/hostile/cockroach/hauberoach/proc/on_squish(mob/living/cockroach, mob/living/living_target)
	if(!istype(living_target))
		return FALSE //We failed to run the invoke. Might be because we're a structure. Let the squashable element handle it then!
	if(!HAS_TRAIT(living_target, TRAIT_PIERCEIMMUNE))
		living_target.visible_message("<span class='danger'>[living_target] steps onto [cockroach]'s spike!</span>", "<span class='userdanger'>You step onto [cockroach]'s spike!</span>")
		return TRUE
	living_target.visible_message("<span class='notice'>[living_target] squashes [cockroach], not even noticing its spike.</span>", "<span class='notice'>You squashed [cockroach], not even noticing its spike.</span>")
	return FALSE

/mob/living/simple_animal/hostile/cockroach/glockroach/prime
	name = "glockroach prime"
	desc = "The ultimate form of the glockroach. Featuring altered mod polarities that offer greater customization."
	icon_state = "glockroach-prime"
	gold_core_spawnable = NO_SPAWN
	health = 2 //extra armor
	maxHealth = 2
	ranged_cooldown_time = 20 //shuuts faster

/mob/living/simple_animal/hostile/cockroach/glockroach/umbra
	name = "glockroach umbra"
	desc = "All miracles require sacrifices. But even i make mistakes, like you."
	icon_state = "glockroach-umbra"
	melee_damage_lower = 10
	melee_damage_upper = 10
	obj_damage = 30
	gold_core_spawnable = NO_SPAWN
	projectiletype = /obj/projectile/glockroachbullet/umbra
	casingtype = /obj/item/ammo_casing/glockroach/umbra

/obj/projectile/glockroachbullet/umbra
	damage = 20 //double damage

/obj/item/ammo_casing/glockroach/umbra
	name = ".045 ACP bullet casing"
	desc = "This is cursed on so many levels."
	projectile_type = /obj/projectile/glockroachbullet/umbra

/mob/living/simple_animal/hostile/cockroach/glockroach/magnum
	name = "magnumroach"
	desc = "Three five rot- Revolveroa- MAGNUMROACH." //reference to hiimdaisy
	icon_state = "magnumroach"
	melee_damage_lower = 10
	melee_damage_upper = 10
	obj_damage = 40
	gold_core_spawnable = NO_SPAWN
	projectilesound = 'sound/weapons/gun/revolver/shot.ogg'
	projectiletype = /obj/projectile/glockroachbullet/magnum
	casingtype = /obj/item/ammo_casing/glockroach/magnum
	health = 100 //The miniboss.
	maxHealth = 100

/mob/living/simple_animal/hostile/cockroach/glockroach/magnum/make_squashable()
	AddElement(/datum/element/squashable, squash_chance = 50, squash_damage = 100) //they're a glass cannon

/obj/projectile/glockroachbullet/magnum
	damage = 60 //its a 357

/obj/item/ammo_casing/glockroach/magnum
	name = ".0357 bullet casing"
	desc = "Itty bitty revolver ammunition."
	projectile_type = /obj/projectile/glockroachbullet/magnum

/mob/living/simple_animal/hostile/cockroach/glockroach/deagle
	name = "deagleroach"
	desc = "The king of the glockroaches. Mutations have caused them to have a desert eagle."
	icon_state = "deagleroach"
	melee_damage_lower = 10
	melee_damage_upper = 10
	obj_damage = 40 //double damage
	gold_core_spawnable = NO_SPAWN
	projectiletype = /obj/projectile/glockroachbullet/deagle
	casingtype = /obj/item/ammo_casing/glockroach/deagle
	squish_chance = 1 //1 percent chance. Take your best shot.
	health = 200 //hardy
	maxHealth = 200

/mob/living/simple_animal/hostile/cockroach/glockroach/deagle/make_squashable()
	AddElement(/datum/element/squashable, squash_chance = 1, squash_damage = 200)

/obj/projectile/glockroachbullet/deagle
	damage = 75 //deagle is stronk.

/obj/item/ammo_casing/glockroach/deagle
	name = ".05 AE bullet casing"
	desc = "A tiny desert eagle bullet casing."
	projectile_type = /obj/projectile/glockroachbullet/deagle

/mob/living/simple_animal/hostile/cockroach/glockroach/god
	name = "godroach"
	desc = "Life...Hope...Dreams...where do they come from? And where are they headed? All these things I AM GOING TO DESTROY!"
	icon_state = "godroach"
	melee_damage_lower = 9001
	melee_damage_upper = 9001
	obj_damage = 9001
	gold_core_spawnable = NO_SPAWN
	projectiletype = /obj/projectile/glockroachbullet/god
	casingtype = /obj/item/ammo_casing/glockroach/god
	squish_chance = 0 //oh no
	health = 13372462 //oh NO
	maxHealth = 13372462
	ranged_cooldown_time = 1

/mob/living/simple_animal/hostile/cockroach/glockroach/god/make_squashable()
	AddElement(/datum/element/squashable, squash_chance = 0, squash_damage = 0)

/obj/projectile/glockroachbullet/god
	damage = 9001 //oh dear god

/obj/item/ammo_casing/glockroach/god
	name = "transcendental mini bullet casing"
	desc = "This miniature bullet casing breaks the laws of the universe."
	projectile_type = /obj/projectile/glockroachbullet/god
