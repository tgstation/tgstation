//Cat
/mob/living/simple_animal/cat
	name = "cat"
	desc = "Kitty!!"
	icon = 'mob.dmi'
	icon_state = "tempcat"
	icon_living = "tempcat"
	icon_dead = "catdeath"
	speak = list("Meow!","Esp!","Purr!","HSSSSS")
	speak_emote = list("purrs", "meows")
	emote_hear = list("meows","mews")
	emote_see = list("shakes it's head", "shivers")
	speak_chance = 1
	turns_per_move = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/sliceable/meat
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "kicks the"

//RUNTIME! SQUEEEEEEEE~
/mob/living/simple_animal/cat/Runtime
	name = "Runtime"
	desc = ""
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"