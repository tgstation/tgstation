/mob/living/simple_animal/hostile/retaliate/clown
	name = "Clown"
	desc = "A denizen of clown planet."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "clown"
	icon_living = "clown"
	icon_dead = "clown_dead"
	icon_gib = "clown_gib"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "gently pushes aside"
	response_harm = "robusts"
	speak = list("HONK", "Honk!", "Welcome to clown planet!")
	emote_see = list("honks", "squeaks")
	speak_chance = 1
	a_intent = INTENT_HARM
	maxHealth = 75
	health = 75
	speed = 1
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "attacks"
	attack_sound = 'sound/items/bikehorn.ogg'
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	del_on_death = 1
	loot = list(/obj/effect/mob_spawn/human/clown/corpse)

	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 270
	maxbodytemp = 370
	unsuitable_atmos_damage = 10

	do_footstep = TRUE

/mob/living/simple_animal/hostile/retaliate/clown/handle_temperature_damage()
	if(bodytemperature < minbodytemp)
		adjustBruteLoss(10)
	else if(bodytemperature > maxbodytemp)
		adjustBruteLoss(15)

/mob/living/simple_animal/hostile/retaliate/clown/attack_hand(mob/living/carbon/human/M)
	..()
	playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)

/mob/living/simple_animal/hostile/retaliate/clown/banana
	name = "Clownana"
	desc = "A fusion of clown and banana DNA birthed from a botany experiment gone wrong."
	icon = 'icons/mob/clown_mobs.dmi'
	icon_state = "banana tree"
	icon_living = "banana tree"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "peels"
	response_harm = "peels"
	speak = list("HONK", "Honk!", "YA-HONK!!!")
	emote_see = list("honks", "bites into the banana", "plucks a banana off its head", "photosynthesizes")
	speak_chance = 5
	maxHealth = 120
	health = 100
	speed = 10
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/item/soap)
	var/banana_time = 20

/mob/living/simple_animal/hostile/retaliate/clown/banana/Life()
	. = ..()
	if(banana_time < world.time)
		new /obj/item/grown/bananapeel(loc)
		banana_time = world.time + rand(20,60)

/mob/living/simple_animal/hostile/retaliate/clown/fleshclown
	name = "Fleshclown"
	desc = "A being forged out of the pure essence of pranking, cursed into existence by a cruel maker."
	icon = 'icons/mob/clown_mobs.dmi'
	icon_state = "no no no no no no no no no no no no no"
	icon_living = "no no no no no no no no no no no no no"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	turns_per_move = 5
	response_help = "reluctantly pokes"
	response_disarm = "sinks his hands into the spongy flesh of"
	response_harm = "cleanses the world of"
	speak = list("HONK", "Honk!", "I didn't ask for this", "I feel constant and horrible pain", "YA-HONK!!!", "this body is a merciless and unforgiving prison", "I was born out of mirthful pranking but I live in suffering")
	emote_see = list("honks", "sweats", "jiggles", "contemplates its existence")
	speak_chance = 5
	a_intent = INTENT_HARM
	ventcrawler = VENTCRAWLER_ALWAYS
	maxHealth = 140
	health = 100
	speed = 5
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 15
	attacktext = "limply slaps"
	attack_sound = 'sound/items/bikehorn.ogg'
	obj_damage = 5
	environment_smash = ENVIRONMENT_SMASH_NONE
	del_on_death = 1
	loot = list(/obj/item/clothing/suit/hooded/bloated_human, /obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/item/soap)

/mob/living/simple_animal/hostile/retaliate/clown/clownhulk
	name = "Honk Hulk"
	desc = "A cruel and fearsome clown. Don't make him angry."
	icon = 'icons/mob/clown_mobs.dmi'
	icon_state = "honkhulk"
	icon_living = "honkhulk"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	turns_per_move = 5
	response_help = "tries desperately to appease"
	response_disarm = "foolishly pushes"
	response_harm = "angers"
	speak = list("HONK", "Honk!", "HAUAUANK!!!", "GUUURRRRAAAHHH!!!")
	emote_see = list("honks", "sweats", "grunts")
	speak_chance = 5
	a_intent = INTENT_HARM
	maxHealth = 400
	health = 200
	pixel_x = -16
	speed = 2
	harm_intent_damage = 15
	melee_damage_lower = 15
	melee_damage_upper = 20
	attacktext = "pummels"
	attack_sound = 'sound/items/bikehorn.ogg'
	obj_damage = 30
	environment_smash = ENVIRONMENT_SMASH_WALLS
	del_on_death = 5
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/item/soap)

/mob/living/simple_animal/hostile/retaliate/clown/longface
	name = "Longface"
	desc = "Often found walking into the bar."
	icon = 'icons/mob/clown_mobs.dmi'
	icon_state = "long face"
	icon_living = "long face"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	turns_per_move = 10
	response_help = "tries awkwardly to hug"
	response_disarm = "pushes the unwieldy frame of"
	response_harm = "tries to shut up"
	speak = list("YA-HONK!!!")
	emote_see = list("honks", "squeaks")
	speak_chance = 60
	a_intent = INTENT_HARM
	maxHealth = 150
	health = 150
	pixel_x = -16
	speed = 10
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "YA-HONKs"
	attack_sound = 'sound/items/bikehorn.ogg'
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/item/soap)

/mob/living/simple_animal/hostile/retaliate/clown/chlown
	name = "Chlown"
	desc = "A real lunkhead who somehow gets all the girls"
	icon = 'icons/mob/clown_mobs.dmi'
	icon_state = "chlown"
	icon_living = "chlown"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	turns_per_move = 5
	response_help = "submits to"
	response_disarm = "tries to assert dominance over"
	response_harm = "makes a weak beta attack at"
	speak = list("HONK", "Honk!", "Bruh", "cheeaaaahhh?")
	emote_see = list("asserts his dominance", "emasculates everyone implicitly")
	speak_chance = 5
	a_intent = INTENT_HARM
	maxHealth = 500
	health = 300
	pixel_x = -16
	speed = 5
	harm_intent_damage = 14
	melee_damage_lower = 10
	melee_damage_upper = 20
	armour_penetration = 20
	attacktext = "steals the girlfriend of"
	attack_sound = 'sound/items/airhorn2.ogg'
	obj_damage = 30
	environment_smash = ENVIRONMENT_SMASH_WALLS
	del_on_death = 5
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/effect/particle_effect/foam, /obj/item/soap)

/mob/living/simple_animal/hostile/retaliate/clown/honcmunculus
	var/datum/reagent/funjuice = "methamphetamine"
	name = "Honkmunculus"
	desc = "A slender wiry figure of alchemical origin."
	icon = 'icons/mob/clown_mobs.dmi'
	icon_state = "honkmunculus"
	icon_living = "honkmunculus"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	turns_per_move = 5
	response_help = "skeptically pokes"
	response_disarm = "pushes the unwieldy frame of"
	response_harm = "robusts"
	speak = list("honk")
	emote_see = list("squirms", "writhes")
	speak_chance = 1
	a_intent = INTENT_HARM
	maxHealth = 200
	health = 100
	pixel_x = -16
	speed = 20
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "ferociously mauls"
	attack_sound = 'sound/items/bikehorn.ogg'
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/xeno/bodypartless, /obj/effect/particle_effect/foam, /obj/item/soap)

/mob/living/simple_animal/hostile/retaliate/clown/honcmunculus/AttackingTarget()
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		if(L.reagents)
			L.reagents.add_reagent(funjuice, rand(1,5))


/mob/living/simple_animal/hostile/retaliate/clown/destroyer
	name = "The Destroyer"
	desc = "An ancient being born of arcane honking."
	icon = 'icons/mob/clown_mobs.dmi'
	icon_state = "destroyer"
	icon_living = "destroyer"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	turns_per_move = 5
	response_help = "tries desperately to appease"
	response_disarm = "bounces off of"
	response_harm = "bounces off of"
	speak = list("HONK!!!", "The Honkmother is merciful, so I must act out her wrath.", "parce mihi ad beatus honkmother placet mihi ut peccata committere,", "DIE!!!")
	emote_see = list("honks", "sweats", "grunts")
	speak_chance = 10
	a_intent = INTENT_HARM
	maxHealth = 400
	health = 400
	pixel_x = -16
	speed = 5
	harm_intent_damage = 30
	melee_damage_lower = 20
	melee_damage_upper = 40
	armour_penetration = 30
	attacktext = "acts out divine vengeance on"
	attack_sound = 'sound/items/bikehorn.ogg'
	obj_damage = 50
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	del_on_death = 5
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/effect/particle_effect/foam, /obj/item/soap)

/mob/living/simple_animal/hostile/retaliate/clown/mutant
	name = "Unknown"
	desc = "Kill it for its own sake."
	icon = 'icons/mob/clown_mobs.dmi'
	icon_state = "mutant"
	icon_living = "mutant"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	turns_per_move = 5
	response_help = "reluctantly sinks a finger into"
	response_disarm = "squishes into"
	response_harm = "squishes into"
	speak = list("aaaaaahhhhuuhhhuhhhaaaaa", "AAAaaauuuaaAAAaauuhhh", "huuuuuh... hhhhuuuooooonnnnkk", "HuaUAAAnKKKK")
	emote_see = list("squirms", "writhes", "pulsates", "froths", "oozes")
	speak_chance = 5
	a_intent = INTENT_HARM
	maxHealth = 130
	health = 35
	pixel_x = -16
	speed = 10
	harm_intent_damage = 10
	melee_damage_lower = 10
	melee_damage_upper = 20
	attacktext = "awkwardly flails at"
	attack_sound = 'sound/items/bikehorn.ogg'
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/xeno/bodypartless, /obj/item/soap, /obj/effect/gibspawner/generic, /obj/effect/gibspawner/generic/animal, /obj/effect/gibspawner/human/bodypartless, /obj/effect/gibspawner/human)

/mob/living/simple_animal/hostile/retaliate/clown/blob
	var/datum/reagent/funjuice = "skewium"
	name = "Something that was once a clown"
	desc = "A grotesque bulging figure far mutated from it's original state."
	icon = 'icons/mob/clown_mobs.dmi'
	icon_state = "blob"
	icon_living = "blob"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	turns_per_move = 10
	response_help = "reluctantly sinks a finger into"
	response_disarm = "squishes into"
	response_harm = "squishes into"
	speak = list("hey, buddy", "HONK!!!", "H-h-h-H-HOOOOONK!!!!", "HONKHONKHONK!!!", "HEY, BUCKO, GET BACK HERE!!!", "HOOOOOOOONK!!!")
	emote_see = list("jiggles", "wobbles")
	speak_chance = 20
	a_intent = INTENT_HARM
	maxHealth = 300
	health = 200
	pixel_x = -16
	mob_size = MOB_SIZE_LARGE
	speed = 20
	harm_intent_damage = 10
	melee_damage_lower = 10
	melee_damage_upper = 15
	attacktext = "bounces off of"
	attack_sound = 'sound/items/bikehorn.ogg'
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/xeno/bodypartless, /obj/effect/particle_effect/foam, /obj/item/soap, /obj/effect/gibspawner/generic, /obj/effect/gibspawner/generic/animal, /obj/effect/gibspawner/human/bodypartless, /obj/effect/gibspawner/human)

/mob/living/simple_animal/hostile/retaliate/clown/blob/AttackingTarget()
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		if(L.reagents)
			L.reagents.add_reagent(funjuice, rand(1,5))