//wip wip wup
/obj/structure/mirror
	name = "mirror"
	desc = "Mirror mirror on the wall, who's the most robust of them all?"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	density = 0
	anchored = 1
	var/shattered = 0


/obj/structure/mirror/attack_hand(mob/user as mob)
	if(shattered)	return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user

		var/userloc = H.loc

		//see code/modules/mob/new_player/preferences.dm at approx line 545 for comments!
		//this is largely copypasted from there.

		//handle facial hair (if necessary)
		if(H.gender == MALE)
			var/new_style = input(user, "Select a facial hair style", "Grooming")  as null|anything in facial_hair_styles_list
			if(userloc != H.loc) return	//no tele-grooming
			if(new_style)
				H.facial_hair_style = new_style
		else
			H.facial_hair_style = "Shaved"

		//handle normal hair
		var/new_style = input(user, "Select a hair style", "Grooming")  as null|anything in hair_styles_list
		if(userloc != H.loc) return	//no tele-grooming
		if(new_style)
			H.hair_style = new_style

		H.update_hair()


/obj/structure/mirror/proc/shatter()
	if(shattered)	return
	shattered = 1
	icon_state = "mirror_broke"
	playsound(src, "shatter", 70, 1)
	desc = "Oh no, seven years of bad luck!"


/obj/structure/mirror/bullet_act(var/obj/item/projectile/Proj)
	if(prob(Proj.damage * 2))
		if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
			if(!shattered)
				shatter()
			else
				playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
	..()


/obj/structure/mirror/attackby(obj/item/I as obj, mob/living/user as mob, params)
	user.do_attack_animation(src)
	if(I.damtype == STAMINA)
		return
	if(shattered)
		playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		return

	if(prob(I.force * 2))
		visible_message("<span class='warning'>[user] smashes [src] with [I].</span>")
		shatter()
	else
		visible_message("<span class='warning'>[user] hits [src] with [I]!</span>")
		playsound(src.loc, 'sound/effects/Glasshit.ogg', 70, 1)


/obj/structure/mirror/attack_alien(mob/living/user as mob)
	user.do_attack_animation(src)
	if(islarva(user)) return
	if(shattered)
		playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		return
	user.visible_message("<span class='danger'>[user] smashes [src]!</span>")
	shatter()


/obj/structure/mirror/attack_animal(mob/living/user as mob)
	if(!isanimal(user)) return
	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0) return
	M.do_attack_animation(src)
	if(shattered)
		playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		return
	user.visible_message("<span class='danger'>[user] smashes [src]!</span>")
	shatter()


/obj/structure/mirror/attack_slime(mob/living/user as mob)
	user.do_attack_animation(src)
	if(shattered)
		playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		return
	user.visible_message("<span class='danger'>[user] smashes [src]!</span>")
	shatter()

/obj/structure/mirror/magic
	name = "magic mirror"
	desc = "Turn and face the strange... face."
	icon_state = "magic_mirror"


/obj/structure/mirror/magic/attack_hand(mob/user as mob)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user

	var/choice = input(user, "Something to change?", "Magical Grooming") as null|anything in list("name", "race", "gender", "hair", "eyes")

	switch(choice)
		if("name")
			var/newname = copytext(sanitize(input(H, "Who are we again?", "Name change", H.name) as null|text),1,MAX_NAME_LEN)

			if(!newname)
				return

			H.real_name = newname
			H.name = newname
			if(H.mind)
				H.mind.name = newname

		if("race")
			var/newrace
			var/racechoice = input(H, "What are we again?", "Race change") as null|anything in species_list
			newrace = species_list[racechoice]

			if(!newrace || !H.dna)
				return

			hardset_dna(H, null, null, null, null, newrace)

			if(H.dna.species.use_skintones)
				var/new_s_tone = input(user, "What are we again?", "Race change")  as null|anything in skin_tones

				if(new_s_tone)
					H.skin_tone = new_s_tone

			if(MUTCOLORS in H.dna.species.specflags)
				var/new_mutantcolor = input(user, "Choose your skin color:", "Race change") as color|null
				if(new_mutantcolor)
					var/temp_hsv = RGBtoHSV(new_mutantcolor)

					if(ReadHSV(temp_hsv)[3] >= ReadHSV("#7F7F7F")[3]) // mutantcolors must be bright
						H.dna.features["mcolor"] = sanitize_hexcolor(new_mutantcolor)

					else
						H << "<span class='notice'>Invalid color. Your color is not bright enough.</span>"

			H.regenerate_icons()

		if("gender")
			if(!(H.gender in list("male", "female"))) //blame the patriarchy
				return

			if(H.gender == "male")
				if(alert(H, "Become a Witch?", "Confirmation", "Yes", "No") == "Yes")
					H.gender = "female"
					H << "<span class='notice'>Man, you feel like a woman!</span>"
					H.regenerate_icons()
			else
				if(alert(H, "Become a Warlock?", "Confirmation", "Yes", "No") == "Yes")
					H.gender = "male"
					H << "<span class='notice'>Whoa man, you feel like a man!</span>"
					H.regenerate_icons()

		if("hair")
			var/hairchoice = alert(H, "Hair style or hair color?", "Change Hair", "Style", "Color")

			if(hairchoice == "Style") //So you just want to use a mirror then?
				..()
			else
				var/new_hair_color = input(H, "Choose your hair color", "Hair Color") as null|color
				if(new_hair_color)
					H.hair_color = sanitize_hexcolor(new_hair_color)
				if(H.gender == "male")
					var/new_face_color = input(H, "Choose your facial hair color", "Hair Color") as null|color
					if(new_face_color)
						H.facial_hair_color = sanitize_hexcolor(new_face_color)

				H.update_hair()

		if("eyes")
			var/new_eye_color = input(H, "Choose your eye color", "Eye Color") as null|color
			if(new_eye_color)
				H.eye_color = sanitize_hexcolor(new_eye_color)
				H.update_body()