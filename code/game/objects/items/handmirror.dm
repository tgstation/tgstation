/obj/item/mirror
	name = "Hand Mirror"
	desc = "Mirror mirror in your hand, who's the best in all the land?"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"

/obj/item/mirror/attack_self(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user

		//see code/modules/mob/dead/new_player/preferences.dm at approx line 545 for comments!
		//this is largely copypasted from there.

		//handle facial hair (if necessary)
		if(H.gender == MALE)
			var/new_style = input(user, "Select a facial hair style", "Grooming")  as null|anything in GLOB.facial_hair_styles_list
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return	//no tele-grooming
			if(new_style)
				H.facial_hair_style = new_style
		else
			H.facial_hair_style = "Shaved"

		//handle normal hair
		var/new_style = input(user, "Select a hair style", "Grooming")  as null|anything in GLOB.hair_styles_list
		if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
			return	//no tele-grooming
		if(new_style)
			H.hair_style = new_style

		H.update_hair()