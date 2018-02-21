/mob/living/simple_animal/hostile/feral_cat
	name = "feral cat"
	desc = "Kitty!! Wait, no no DON'T BITE-"
	icon = 'icons/mob/pets.dmi'
	icon_state = "cat2"
	icon_living = "cat2"
	icon_dead = "cat2_dead"
	gender = MALE
	maxHealth = 30
	health = 30
	melee_damage_lower = 15
	melee_damage_upper = 7
	attacktext = "claws"
	speak = list("Meow!", "Esp!", "Purr!", "HSSSSS")
	speak_emote = list("purrs", "meows")
	emote_hear = list("meows", "mews")
	speak_chance = 1
	turns_per_move = 5
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_SMALL
	minbodytemp = 200
	maxbodytemp = 400
	see_in_dark = 6
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 2)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	gold_core_spawnable = 1
	faction = list("cat", "syndicate")
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 5

/mob/living/simple_animal/hostile/feral_cat/feral_mime_cat
	name = "Feral Mime Cat"
	maxHealth = 75
	health = 75
	desc = "Punished mime cat.. This one has been tampered with, its vow of silence broken."
	speak_emote = list("purrs", "meows", "screeches", "yells", "babbles incoherently")
	icon = 'hippiestation/icons/mob/pets.dmi'
	icon_state = "catmime2"
	icon_living = "catmime2"
	icon_dead = "catmime_defeated"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 2, /obj/item/clothing/mask/gas/mime = 1)
	var/static/meows = list("hippiestation/sound/creatures/mimeCatScream.ogg", "hippiestation/sound/creatures/mimeCatScream2.ogg")

/mob/living/simple_animal/hostile/feral_cat/feral_mime_cat/Life()
	..()
	if(prob(50) && stat != DEAD)
		playsound(src, pick(meows), 100, 1)
		visible_message("[name] lets out an unearthly howl!")
