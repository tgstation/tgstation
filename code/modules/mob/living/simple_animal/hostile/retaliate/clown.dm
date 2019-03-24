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

/mob/living/simple_animal/hostile/retaliate/clown/fleshclown
	name = "Fleshclown"
	desc = "A being forged out of the pure essence of pranking, cursed into existence by a cruel maker."
	icon = 'icons/mob/Clown_mobs.dmi'
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
	maxHealth = 200
	health = 200
	speed = 1
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 15
	attacktext = "limply slaps"
	attack_sound = 'sound/items/bikehorn.ogg'
	obj_damage = 5
	environment_smash = ENVIRONMENT_SMASH_NONE
	del_on_death = 1
	loot = list(/obj/item/clothing/suit/hooded/bloated_human, /obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/item/soap)

/mob/living/simple_animal/hostile/retaliate/clown/ClownHulk
	name = "Honk Hulk"
	desc = "A cruel and fearsome clown. Don't make him angry."
	icon = 'icons/mob/Clown_mobs.dmi'
	icon_state = "Honkhulk"
	icon_living = "Honkhulk"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	turns_per_move = 5
	response_help = "tries desperately to appease"
	response_disarm = "foolishly pushes"
	response_harm = "angers"
	speak = list("HONK", "Honk!", "HAUAUANK!!!", "GUUURRRRAAAHHH!!!")
	emote_see = list("honks", "sweats", "grunts")
	speak_chance = 5
	a_intent = INTENT_HARM
	maxHealth = 500
	health = 500
	pixel_x = -16
	speed = 2
	harm_intent_damage = 20
	melee_damage_lower = 10
	melee_damage_upper = 30
	attacktext = "pummels"
	attack_sound = 'sound/items/bikehorn.ogg'
	obj_damage = 30
	environment_smash = ENVIRONMENT_SMASH_WALLS
	del_on_death = 5
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/effect/particle_effect/foam, /obj/item/soap)

/mob/living/simple_animal/hostile/retaliate/clown/longface
	name = "Longface"
	desc = "Often found walking into the bar."
	icon = 'icons/mob/Clown_mobs.dmi'
	icon_state = "Long Face"
	icon_living = "Long Face"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	turns_per_move = 5
	response_help = "tries awkwardly to hug"
	response_disarm = "pushes the unweildy frame of"
	response_harm = "tries to shut up"
	speak = list("YA-HONK!!!")
	emote_see = list("honks", "squeaks")
	speak_chance = 30
	a_intent = INTENT_HARM
	maxHealth = 150
	health = 150
	pixel_x = -16
	speed = 5
	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "YA-HONKs"
	attack_sound = 'sound/items/bikehorn.ogg'
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/effect/particle_effect/foam, /obj/item/soap)

/mob/living/simple_animal/hostile/retaliate/clown/Chlown
	name = "Chlown"
	desc = "A real lunkhead who somehow gets all the girls"
	icon = 'icons/mob/Clown_mobs.dmi'
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
	health = 500
	pixel_x = -16
	speed = 5
	harm_intent_damage = 14
	melee_damage_lower = 10
	melee_damage_upper = 20
	attacktext = "steals your girlfriend"
	attack_sound = 'sound/items/bikehorn.ogg'
	obj_damage = 30
	environment_smash = ENVIRONMENT_SMASH_WALLS
	del_on_death = 5
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/human, /obj/effect/particle_effect/foam, /obj/item/soap)

/mob/living/simple_animal/hostile/retaliate/clown/honcmunculus
	name = "Honkmunculus"
	desc = "A slender wiry figure of alchemical origin."
	icon = 'icons/mob/Clown_mobs.dmi'
	icon_state = "honkmunculus"
	icon_living = "honkmunculus"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	turns_per_move = 5
	response_help = "skeptically pokes"
	response_disarm = "pushes the unweildy frame of"
	response_harm = "Robusts"
	speak = list("honk")
	emote_see = list("squirms", "writhes")
	speak_chance = 1
	a_intent = INTENT_HARM
	maxHealth = 200
	health = 200
	pixel_x = -16
	speed = 10
	harm_intent_damage = 8
	melee_damage_lower = 5
	melee_damage_upper = 15
	attacktext = "ferociously mauls"
	attack_sound = 'sound/items/bikehorn.ogg'
	loot = list(/obj/item/clothing/mask/gas/clown_hat, /obj/effect/gibspawner/xeno/bodypartless, /obj/effect/particle_effect/foam, /obj/item/soap)
