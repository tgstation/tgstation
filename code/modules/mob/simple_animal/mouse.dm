/mob/living/simple_animal/mouse
	name = "mouse"
	desc = "It's a small, disease-ridden rodent."
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	speak = list("Squeek!","SQUEEK!","Squeek?")
	speak_emote = list("squeeks")
	emote_hear = list("squeeks")
	emote_see = list("runs in a circle", "shakes", "scritches at something")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	health = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "splats the"
	density = 0
	var/color = "gray" //brown, gray and white

/mob/living/simple_animal/mouse/Life()
	..()
	if(!stat && prob(speak_chance))
		for(var/mob/M in view())
			M << "\blue \icon[src] Squeek!"
			M << 'sound/effects/mousesqueek.ogg'

/mob/living/simple_animal/mouse/white
	color = "white"
	icon_state = "mouse_white"

/mob/living/simple_animal/mouse/brown
	color = "brown"
	icon_state = "mouse_brown"

/mob/living/simple_animal/mouse/New()
	if(!color)
		color = pick( list("brown","gray","white") )
	icon_state = "mouse_[color]"
	icon_living = "mouse_[color]"
	icon_dead = "mouse_[color]_dead"
	desc = "It's a small, [color], disease-ridden rodent."

/mob/living/simple_animal/mouse/proc/splat()
	src.health = 0
	src.stat = DEAD
	src.icon_dead = "mouse_[color]_splat"
	src.icon_state = "mouse_[color]_splat"

/proc/ismouse(var/obj/O)
	return istype(O,/mob/living/simple_animal/mouse)
