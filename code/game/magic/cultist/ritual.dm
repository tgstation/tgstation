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
// mgar - technology
// balaq - destroy


// ire ego [word] - Teleport to [rune with word destination matching] (works in pairs)
// nahlizet veri certum - Create a new tome
// jatkaa veri ego - Incorporate person over the rune into the group
// certum jatkaa ego - Summon TERROR
// balaq nahlizet mgar - EMP rune
// ire veri ego - Drain blood
// nahlizet certum jatkaa - See invisible
// veri jatkaa certum - Raise dead

	examine()
		set src in usr
		if(!cultists.Find(usr))
			src.desc = text("A strange collection of symbols drawn in blood.")
		else
			src.desc = "A spell circle drawn in blood. It reads: <i>[word1] [word2] [word3]</i>."
		..()
		return

	attackby(I as obj, user as mob)
		if(istype(I, /obj/item/weapon/tome) && cultists.Find(user))
			user << "You retrace your steps, carefully undoing the lines of the rune."
			del(src)
			return
		else if(istype(I, /obj/item/weapon/storage/bible) && usr.mind && (usr.mind.assigned_role == "Chaplain"))
			user << "\blue You banish the vile magic with the blessing of God!"
			del(src)
			return
		return

	attack_hand(mob/user as mob)
		if(!cultists.Find(user))
			user << "You can't mouth the arcane scratchings without fumbling over them."
			return
		if(!word1 || !word2 || !word3 || prob(usr.brainloss))
			return fizzle()

		if(word1 == "ire" && word2 == "ego")
			return teleport(src.word3)
		if(word1 == "nahlizet" && word2 == "veri" && word3 == "certum")
			return tomesummon()
/*
		if(word1 == "ire" && word2 == "certum" && word3 == "jatkaa")
			var/list/temprunes = list()
			var/list/runes = list()
			for(var/obj/rune/R in world)
				if(istype(R, /obj/rune))
					if(R.word1 == "ire" && R.word2 == "certum" && R.word3 == "jatkaa")
						runes.Add(R)
						var/atom/a = get_turf_loc(R)
						temprunes.Add(a.loc)
			var/chosen = input("Scry which rune?", "Scrying") in temprunes
			if(!chosen)
				return fizzle()
			var/selection_position = temprunes.Find(chosen)
			var/obj/rune/chosenrune = runes[selection_position]
			user.client.eye = chosenrune
			user:current = chosenrune
			user.reset_view(chosenrune)
*/
		if(word1 == "jatkaa" && word2 == "veri" && word3 == "ego")
			return convert()
		if(word1 == "certum" && word2 == "jatkaa" && word3 == "ego")
			return tearreality()
		if(word1 == "balaq" && word2 == "nahlizet" && word3 == "mgar")
			return emp()
		if(word1 == "ire" && word2 == "veri" && word3 == "ego")
			return drain()
		if(word1 == "nahlizet" && word2 == "certum" && word3 == "jatkaa")
			return seer()
		if(word1 == "veri" && word2 == "jatkaa" && word3 == "certum")
			return raise()
		else
			return fizzle()


	proc
		fizzle()
			usr.say(pick("B'ADMINES SP'WNIN SH'T","IC'IN O'OC","RO'SHA'M I'SA GRI'FF'N ME'AI","TOX'IN'S O'NM FI'RAH","IA BL'AME TOX'IN'S","FIR'A NON'AN RE'SONA","A'OI I'RS ROUA'GE","LE'OAN JU'STA SP'A'C Z'EE SH'EF","IA PT'WOBEA'RD, IA A'DMI'NEH'LP"))
			for (var/mob/V in viewers(src))
				V.show_message("\red The markings pulse with a small burst of light, then fall dark.", 3, "\red You hear a faint fizzle.", 2)
			return

		check_icon()
			if(word1 == "ire" && word2 == "ego")
				icon_state = "2"
				return
			if(word1 == "jatkaa" && word2 == "veri" && word3 == "ego")
				icon_state = "3"
				return
			if(word1 == "certum" && word2 == "jatkaa" && word3 == "ego")
				icon_state = "3"
				src.icon += rgb(100, 0 , 150)
				return
			if(word1 == "nahlizet" && word2 == "ire" && word3 == "certum")
				icon_state = "2"
				src.icon += rgb(0, 50 , 0)
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
			var/C = 0
			for(var/obj/rune/N in world)
				C++
			if (C>=25)
				switch(alert("The cloth of reality can't take that much of a strain. By creating another rune, you risk locally tearing reality apart, which would prove fatal to you. Do you still wish to scribe the rune?",,"Yes","No"))
					if("Yes")
						if(prob(C*5-100))
							usr.emote("scream")
							user << "\red A tear momentarily appears in reality. Before it closes, you catch a glimpse of that which lies beyond. That proves to be too much for your mind."
							usr.gib(1)
							return
					if("No")
						return
			else
				if(alert("Scribe a rune?",,"Yes","No")=="No")
					return
			var/list/words = list("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar")
			var/w1
			var/w2
			var/w3
			if(usr)
				w1 = input("Write your first rune:", "Rune Scribing") in words
			if(usr)
				w2 = input("Write your second rune:", "Rune Scribing") in words
			if(usr)
				w3 = input("Write your third rune:", "Rune Scribing") in words
			for (var/mob/V in viewers(src))
				V.show_message("\red [user] slices open a finger and begins to chant and paint symbols on the floor.", 3, "\red You hear chanting.", 2)
			user << "\red You slice open one of your fingers and begin drawing a rune on the floor whilst chanting the ritual that binds your life essence with the dark arcane energies flowing through the surrounding world."
			user.bruteloss += 1
			if(do_after(user, 50))
				var/obj/rune/R = new /obj/rune(user.loc)
				user << "\red You finish drawing the arcane markings of the Geometer."
				R.word1 = w1
				R.word2 = w2
				R.word3 = w3
				R.check_icon()
			return
		else
			user << "The book seems full of illegible scribbles. Is this a joke?"
			return

	examine()
		set src in usr
		if(!cultists.Find(usr))
			usr << "An old, dusty tome with frayed edges and a sinister looking cover."
		else
			usr << "The scriptures of Nar-Sie, The One Who Sees, The Geometer of Blood. Contains the details of every ritual his followers could think of. Most of these are useless, though."


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