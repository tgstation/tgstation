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
