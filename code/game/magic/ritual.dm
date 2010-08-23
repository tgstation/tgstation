var/list/cultists = list()


/obj/rune
	anchored = 1
	icon = 'magic.dmi'
	icon_state = "1"


	var
		word1
		word2
		word3

// ire - travel
// ego - self
// nahlizet - see
// certum - Hell
// veri - blood
// jatkaa - join


// ire ego [word] - Teleport to [rune with word destination matching] (works in pairs)
// nahlizet veri certum - Create a new tome
// jatkaa veri ego - Incorporate person over the rune into the group
// certum jatkaa ego - Summon TERROR

	examine()
		set src in usr
		if(!cultists.Find(usr))
			src.desc = text("A strange collection of symbols drawn in blood.")
		else
			src.desc = "A spell circle drawn in blood. It reads: <i>[word1] [word2] [word3]</i>."
		..()
		return



	attack_hand(mob/user as mob)
		if(!cultists.Find(user))
			user << "You can't mouth the arcane scratchings without fumbling over them."
			return
		if(!word1 || !word2 || !word3)
			return fizzle()
		if(word1 == "ire" && word2 == "ego")
			for(var/obj/rune/R in world)
				if(R == src)
					continue
				if(R.word3 == src.word3 && R.word1 == src.word1 && R.word2 == src.word2)
					for (var/mob/V in viewers(src))
						V.show_message("\red [user] disappears in a flash of red light!", 3, "\red You hear a sickening crunch and sloshing of viscera.", 2)
					user.loc = R.loc
					return
			return	fizzle()
		if(word1 == "nahlizet" && word2 == "veri" && word3 == "certum")
			for (var/mob/V in viewers(src))
				V.show_message("\red There's a flash of red light. The rune disappears, and in its place a book lies", 3, "\red You hear a pop and smell ozone.", 2)
			new /obj/item/weapon/tome(src.loc)
			del(src)
		/*
			var/list/temprunes = list()
			var/list/runes = list()
			for(var/obj/rune/R in world)
				if(istype(R, /obj/rune))
					if(R.word1 == "nahlizet" && R.word2 == "veri" && R.word3 == "certum")
						runes.Add(R)
						var/atom/a = get_turf_loc(R)
						temprunes.Add(a.loc)
			var/chosen = input("Scry which rune?", "Scrying") in temprunes
			if(!chosen)
				return fizzle()
			var/selection_position = temprunes.Find(chosen)
			var/obj/rune/chosenrune = runes[selection_position]
//			user.client.eye = chosenrune
			user:current = chosenrune
			user.reset_view(chosenrune)

			return
		*/
		if(word1 == "jatkaa" && word2 == "veri" && word3 == "ego")
			for(var/mob/M in src.loc)
				if(cultists.Find(M))
					return fizzle()
				else
					cultists.Add(M)
					for (var/mob/V in viewers(src))
						V.show_message("\red [M] writhes in pain as the markings below him glow a bloody red.", 3, "\red You hear an anguished scream.", 2)
					M << "<font color=\"purple\"><b><i>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</b></i></font>"
					M<< "<font color=\"purple\"><b><i>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</b></i></font>"
					return
		if(word1 == "certum" && word2 == "jatkaa" && word3 == "ego")
			var/cultist_count = 0
			for(var/mob/M in orange(1,src))
				if(cultists.Find(M))
					cultist_count += 1
			if(cultist_count >= 6)
				var/obj/machinery/the_singularity/S = new /obj/machinery/the_singularity/(src.loc)
				S.icon = 'magic_terror.dmi'
				S.name = "Tear in the Fabric of Reality"
				S.desc = "Your mind begins to bubble and ooze as it tries to comprehend what it sees."
				S.pixel_x = -89
				S.pixel_y = -85
				message_admins("<h1><font color=\"purple\"><b><u>[key_name_admin(usr)] has summoned a Tear in the Fabric of Reality!", 1)
				return
			else
				return fizzle()

	proc
		fizzle()
			for (var/mob/V in viewers(src))
				V.show_message("\red The markings pulse with a small burst of light, then fall dark.", 3, "\red You hear a faint fizzle.", 2)
			return

		check_icon()
			if(word1 == "ire" && word2 == "ego")
				icon_state = "2"
				return
			if(word1 == "nahlizet" && word2 == "veri" && word3 == "certum")
				icon_state = "3"
				return
			if(word1 == "certum" && word2 == "jatkaa" && word3 == "ego")
				icon_state = "3"
				src.icon += rgb(100, 0 , 150)
				return
			icon_state = "1"


/obj/item/weapon/tome
	name = "arcane tome"
	icon_state ="tome"
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	flags = FPRINT | TABLEPASS

	attack_self(mob/user as mob)
		if(cultists.Find(user))
			var/choice = input("Scribe a rune on the ground here?", "Rune Scribing") in list("Yes", "No")
			if(choice == "No")
				return
			var/list/words = list("ire", "ego", "nahlizet", "certum", "veri", "jatkaa")
			var/w1 = input("Write your first rune:", "Rune Scribing") in words
			var/w2 = input("Write your second rune:", "Rune Scribing") in words
			var/w3 = input("Write your third rune:", "Rune Scribing") in words
			var/obj/rune/R = new /obj/rune(user.loc)
			R.word1 = w1
			R.word2 = w2
			R.word3 = w3
			R.check_icon()
			for (var/mob/V in viewers(src))
				V.show_message("\red [user] slices open a finger and paints symbols on the floor.", 3, "\red You hear someone drawing on a surface.", 2)
			return
		else
			user << "The book seems full of illegible scribbles. Is this a joke?"
			return

	examine()
		set src in usr
		usr << "An old, dusty tome with frayed edges and a sinister looking cover."


/obj/item/weapon/paperscrap
	name = "scrap of paper"
	icon_state = "scrap"
	throw_speed = 1
	throw_range = 2
	w_class = 1.0
	flags = FPRINT | TABLEPASS

	var
		data

	attack_self(mob/user as mob)
		view_scrap(user)

	examine()
		set src in usr
		view_scrap(usr)

	proc/view_scrap(var/viewer)
		viewer << browse(data)