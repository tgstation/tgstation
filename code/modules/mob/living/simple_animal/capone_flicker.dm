/mob/living/simple_animal/capone_flicker
	name = "Your Best Friend"
	desc = "...what the fuck?"
	gender = PLURAL
	icon = 'icons/mob/human_face.dmi'
	icon_state = "lips_spray_face"
	icon_living = "lips_spray_face"
	layer = GHOST_LAYER

/mob/living/simple_animal/capone_flicker/Initialize()
	resize = 1.5
	update_transform()
