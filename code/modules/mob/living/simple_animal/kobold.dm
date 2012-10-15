//kobold
/mob/living/simple_animal/kobold
	name = "kobold"
	desc = "A small, rat-like creature."
	icon = 'mob.dmi'
	icon_state = "kobold_idle"
	icon_living = "kobold_idle"
	icon_dead = "kobold_dead"
	//speak = list("You no take candle!","Ooh, pretty shiny.","Me take?","Where gold here...","Me likey.")
	speak_emote = list("mutters","hisses","grumbles")
	emote_hear = list("mutters under it's breath.","grumbles.", "yips!")
	emote_see = list("looks around suspiciously.", "scratches it's arm.","putters around a bit.")
	speak_chance = 15
	turns_per_move = 5
	see_in_dark = 6
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/sliceable/meat
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "kicks the"
	minbodytemp = 250
	min_oxy = 16 //Require atleast 16kPA oxygen
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius

/mob/living/simple_animal/kobold/Life()
	..()
	if(prob(15) && turns_since_move && !stat)
		flick("kobold_act",src)

/mob/living/simple_animal/kobold/Move(var/dir)
	..()
	if(!stat)
		flick("kobold_walk",src)
