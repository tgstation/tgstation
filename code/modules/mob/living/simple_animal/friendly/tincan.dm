//Robotics Tincan Pet
/mob/living/simple_animal/pet/drone/tincan
	name = "Tincan"
	real_name = "Tincan"
	desc = "Tincan, robotics favorite drone! How silicon does adorable."
	icon_state = "drone_tincan"
	icon_living = "drone_tincan"
	icon_dead = "drone_tincan_dead"
	speak = list("Science!", "Silly humans!","Beep boop","Im a big stompy mech.","DON'T BLOW THE BORGS!")
	speak_emote = list("chimes", "whirs")
	emote_hear = list("beeps", "boops", "pings","chimes")
	emote_see = list("spins in place", "vibrates")
	speak_chance = 1
	turns_per_move = 10
	wander = 5





//cute hearts for adorable drone pet
/mob/living/simple_animal/pet/drone/tincan/attack_hand(mob/living/carbon/human/M, mob/user)
	. = ..()
	switch(M.a_intent)
		if("help")	wuv(1,M)
		if("harm")	wuv(-1,M)

/mob/living/simple_animal/pet/drone/tincan/proc/wuv(change, mob/M)
	if(change)
		if(change > 0)
			flick_overlay(image('icons/mob/animal.dmi',src,"heart-ani3",MOB_LAYER+1), list(M.client), 20)
			emote("me", 1, "whirs around excitedly!")
		if(change < 1)
			emote("me", -1, "buzzes angrily.")


/mob/living/simple_animal/pet/drone/tincan/movement_delay()
	if(client && stat == CONSCIOUS && icon_state != "drone_tincan_move")
		icon_state = "drone_tincan_move"
	..()

