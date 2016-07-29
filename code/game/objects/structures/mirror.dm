<<<<<<< HEAD
//wip wip wup
/obj/structure/mirror
	name = "mirror"
	desc = "Mirror mirror on the wall, who's the most robust of them all?"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	density = 0
	anchored = 1
	var/shattered = 0


/obj/structure/mirror/attack_hand(mob/user)
	if(shattered || !Adjacent(user))
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user

		var/userloc = H.loc

		//see code/modules/mob/new_player/preferences.dm at approx line 545 for comments!
		//this is largely copypasted from there.

		//handle facial hair (if necessary)
		if(H.gender == MALE)
			var/new_style = input(user, "Select a facial hair style", "Grooming")  as null|anything in facial_hair_styles_list
			if(userloc != H.loc)
				return	//no tele-grooming
			if(new_style)
				H.facial_hair_style = new_style
		else
			H.facial_hair_style = "Shaved"

		//handle normal hair
		var/new_style = input(user, "Select a hair style", "Grooming")  as null|anything in hair_styles_list
		if(userloc != H.loc)
			return	//no tele-grooming
		if(new_style)
			H.hair_style = new_style

		H.update_hair()


/obj/structure/mirror/proc/shatter()
	icon_state = "mirror_broke"
	playsound(src, "shatter", 70, 1)
	desc = "Oh no, seven years of bad luck!"
	shattered = 1


/obj/structure/mirror/bullet_act(obj/item/projectile/P)
	. = ..()
	take_damage(P.damage, P.damage_type, 0)


/obj/structure/mirror/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weapon/weldingtool) && user.a_intent != "harm")
		var/obj/item/weapon/weldingtool/WT = I
		if(shattered)
			user.changeNext_move(CLICK_CD_MELEE)
			if(WT.remove_fuel(0, user))
				user << "<span class='notice'>You begin repairing [src]...</span>"
				playsound(src, 'sound/items/Welder.ogg', 100, 1)
				if(do_after(user, 10/I.toolspeed, target = src))
					if(!user || !WT || !WT.isOn())
						return
					user << "<span class='notice'>You repair [src].</span>"
					shattered = 0
					icon_state = initial(icon_state)
					desc = initial(desc)
	else
		return ..()

/obj/structure/mirror/attacked_by(obj/item/I, mob/living/user)
	..()
	take_damage(I.force, I.damtype)

/obj/structure/mirror/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(50))
				qdel(src)
			else
				take_damage(5)
		if(3)
			if(prob(75))
				take_damage(5)

/obj/structure/mirror/proc/take_damage(damage, damage_type = BRUTE, sound_effect = 1)
	switch(damage_type)
		if(BRUTE)
		if(BURN)
		else
			return
	if(!shattered)
		if(damage)
			shatter()
	else if(sound_effect)
		playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)

/obj/structure/mirror/proc/attack_generic(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	user.visible_message("<span class='danger'>[user] smashes [src]!</span>")
	take_damage(5)

/obj/structure/mirror/attack_alien(mob/living/user)
	attack_generic(user)

/obj/structure/mirror/attack_animal(mob/living/simple_animal/M)
	if(M.melee_damage_upper <= 0)
		return
	attack_generic(M)

/obj/structure/mirror/attack_slime(mob/living/user)
	attack_generic(user)

/obj/structure/mirror/magic
	name = "magic mirror"
	desc = "Turn and face the strange... face."
	icon_state = "magic_mirror"
	var/list/races_blacklist = list("skeleton", "agent", "angel", "military_synth")
	var/list/choosable_races = list()

/obj/structure/mirror/magic/New()
	if(!choosable_races.len)
		for(var/speciestype in subtypesof(/datum/species))
			var/datum/species/S = new speciestype()
			if(!(S.id in races_blacklist))
				choosable_races += S.id
	..()

/obj/structure/mirror/magic/lesser/New()
	choosable_races = roundstart_species
	..()

/obj/structure/mirror/magic/badmin/New()
	for(var/speciestype in subtypesof(/datum/species))
		var/datum/species/S = new speciestype()
		choosable_races += S.id
	..()

/obj/structure/mirror/magic/attack_hand(mob/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user

	var/choice = input(user, "Something to change?", "Magical Grooming") as null|anything in list("name", "race", "gender", "hair", "eyes")

	if(!Adjacent(user))
		return

	switch(choice)
		if("name")
			var/newname = copytext(sanitize(input(H, "Who are we again?", "Name change", H.name) as null|text),1,MAX_NAME_LEN)

			if(!newname)
				return
			if(!Adjacent(user))
				return
			H.real_name = newname
			H.name = newname
			if(H.dna)
				H.dna.real_name = newname
			if(H.mind)
				H.mind.name = newname

		if("race")
			var/newrace
			var/racechoice = input(H, "What are we again?", "Race change") as null|anything in choosable_races
			newrace = species_list[racechoice]

			if(!newrace)
				return
			if(!Adjacent(user))
				return
			H.set_species(newrace, icon_update=0)

			if(H.dna.species.use_skintones)
				var/new_s_tone = input(user, "Choose your skin tone:", "Race change")  as null|anything in skin_tones

				if(new_s_tone)
					H.skin_tone = new_s_tone
					H.dna.update_ui_block(DNA_SKIN_TONE_BLOCK)

			if(MUTCOLORS in H.dna.species.specflags)
				var/new_mutantcolor = input(user, "Choose your skin color:", "Race change") as color|null
				if(new_mutantcolor)
					var/temp_hsv = RGBtoHSV(new_mutantcolor)

					if(ReadHSV(temp_hsv)[3] >= ReadHSV("#7F7F7F")[3]) // mutantcolors must be bright
						H.dna.features["mcolor"] = sanitize_hexcolor(new_mutantcolor)

					else
						H << "<span class='notice'>Invalid color. Your color is not bright enough.</span>"

			H.update_body()
			H.update_hair()
			H.update_body_parts()
			H.update_mutations_overlay() // no hulk lizard

		if("gender")
			if(!(H.gender in list("male", "female"))) //blame the patriarchy
				return
			if(!Adjacent(user))
				return
			if(H.gender == "male")
				if(alert(H, "Become a Witch?", "Confirmation", "Yes", "No") == "Yes")
					H.gender = "female"
					H << "<span class='notice'>Man, you feel like a woman!</span>"
				else
					return

			else
				if(alert(H, "Become a Warlock?", "Confirmation", "Yes", "No") == "Yes")
					H.gender = "male"
					H << "<span class='notice'>Whoa man, you feel like a man!</span>"
				else
					return
			H.dna.update_ui_block(DNA_GENDER_BLOCK)
			H.update_body()
			H.update_mutations_overlay() //(hulk male/female)

		if("hair")
			var/hairchoice = alert(H, "Hair style or hair color?", "Change Hair", "Style", "Color")
			if(!Adjacent(user))
				return
			if(hairchoice == "Style") //So you just want to use a mirror then?
				..()
			else
				var/new_hair_color = input(H, "Choose your hair color", "Hair Color") as null|color
				if(new_hair_color)
					H.hair_color = sanitize_hexcolor(new_hair_color)
					H.dna.update_ui_block(DNA_HAIR_COLOR_BLOCK)
				if(H.gender == "male")
					var/new_face_color = input(H, "Choose your facial hair color", "Hair Color") as null|color
					if(new_face_color)
						H.facial_hair_color = sanitize_hexcolor(new_face_color)
						H.dna.update_ui_block(DNA_FACIAL_HAIR_COLOR_BLOCK)
				H.update_hair()

		if("eyes")
			var/new_eye_color = input(H, "Choose your eye color", "Eye Color") as null|color
			if(!Adjacent(user))
				return
			if(new_eye_color)
				H.eye_color = sanitize_hexcolor(new_eye_color)
				H.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
				H.update_body()
	if(choice)
		curse(user)

/obj/structure/mirror/magic/proc/curse(mob/living/user)
	return
=======
//wip wip wup
/obj/structure/mirror
	name = "mirror"
	desc = "Mirror mirror on the wall, who's the most robust of them all? Touching the mirror will bring out Nanotrasen's state of the art hair modification system."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	density = 0
	anchored = 1
	var/shattered = 0


/obj/structure/mirror/attack_hand(mob/user as mob)
	if(shattered)	return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(isvampire(H))
			if(!(VAMP_MATURE in H.mind.vampire.powers))
				to_chat(H, "<span class='notice'>You don't see anything.</span>")
				return
		if(user.hallucinating())
			switch(rand(1,100))
				if(1 to 20)
					to_chat(H, "<span class='sinister'>You look like [pick("a monster","a goliath","a catbeast","a ghost","a chicken","the mailman","a demon")]! Your heart skips a beat.</span>")
					H.Weaken(4)
					return
				if(21 to 40)
					to_chat(H, "<span class='sinister'>There's [pick("somebody","a monster","a little girl","a zombie","a ghost","a catbeast","a demon")] standing behind you!</span>")
					H.emote("scream",,, 1)
					H.dir = turn(H.dir, 180)
					return
				if(41 to 50)
					to_chat(H, "<span class='notice'>You don't see anything.</span>")
					return
		var/userloc = H.loc

		//see code/modules/mob/new_player/preferences.dm at approx line 545 for comments!
		//this is largely copypasted from there.

		//handle facial hair (if necessary)
		if(H.gender == MALE)
			var/list/species_facial_hair = list()
			if(H.species)
				for(var/i in facial_hair_styles_list)
					var/datum/sprite_accessory/facial_hair/tmp_facial = facial_hair_styles_list[i]
					if(H.species.name in tmp_facial.species_allowed)
						species_facial_hair += i
			else
				species_facial_hair = facial_hair_styles_list

			var/new_style = input(user, "Select a facial hair style", "Grooming")  as null|anything in species_facial_hair
			if(userloc != H.loc) return	//no tele-grooming
			if(new_style)
				H.f_style = new_style

		//handle normal hair
		var/list/species_hair = list()
		if(H.species)
			for(var/i in hair_styles_list)
				var/datum/sprite_accessory/hair/tmp_hair = hair_styles_list[i]
				if(H.species.name in tmp_hair.species_allowed)
					species_hair += i
		else
			species_hair = hair_styles_list

		var/new_style = input(user, "Select a hair style", "Grooming")  as null|anything in species_hair
		if(userloc != H.loc) return	//no tele-grooming
		if(new_style)
			H.h_style = new_style

		H.update_hair()


/obj/structure/mirror/proc/shatter()
	if(shattered)	return
	shattered = 1
	icon_state = "mirror_broke"
	playsound(src, "shatter", 70, 1)
	desc = "Oh no, seven years of bad luck!"


/obj/structure/mirror/bullet_act(var/obj/item/projectile/Proj)
	if(prob(Proj.damage * 2))
		if(!shattered)
			shatter()
		else
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
	..()


/obj/structure/mirror/attackby(obj/item/I as obj, mob/user as mob)
	if ((shattered) && (istype(I, /obj/item/stack/sheet/glass/glass)))
		var/obj/item/stack/sheet/glass/glass/stack = I
		if ((stack.amount - 2) < 0)
			to_chat(user, "<span class='warning'>You need more glass to do that.</span>")
		else
			stack.use(2)
			shattered = 0
			icon_state = "mirror"
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 80, 1)

	else if(shattered)
		playsound(get_turf(src), 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		return

	else if(prob(I.force * 2))
		visible_message("<span class='warning'>[user] smashes [src] with [I]!</span>")
		shatter()
	else
		visible_message("<span class='warning'>[user] hits [src] with [I]!</span>")
		playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 70, 1)


/obj/structure/mirror/attack_alien(mob/user as mob)
	if(islarva(user)) return
	if(shattered)
		playsound(get_turf(src), 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		return
	user.visible_message("<span class='danger'>[user] smashes [src]!</span>")
	shatter()


/obj/structure/mirror/attack_animal(mob/user as mob)
	if(!isanimal(user)) return
	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0) return
	if(shattered)
		playsound(get_turf(src), 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		return
	user.visible_message("<span class='danger'>[user] smashes [src]!</span>")
	shatter()


/obj/structure/mirror/attack_slime(mob/user as mob)
	if(!isslimeadult(user)) return
	if(shattered)
		playsound(get_turf(src), 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		return
	user.visible_message("<span class='danger'>[user] smashes [src]!</span>")
	shatter()

/obj/structure/mirror/kick_act()
	..()
	shatter()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
