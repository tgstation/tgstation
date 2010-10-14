var/list/cultists = list()
var/wordtravel = null
var/wordself = null
var/wordsee = null
var/wordhell = null
var/wordblood = null
var/wordjoin = null
var/wordtech = null
var/worddestr = null
var/runedec = 0

/proc/runerandom() //randomizes word meaning
	var/list/runewords=list("ire","ego","nahlizet","certum","veri","jatkaa","mgar","balaq")
	wordtravel=pick(runewords)
	runewords-=wordtravel
	wordself=pick(runewords)
	runewords-=wordself
	wordsee=pick(runewords)
	runewords-=wordsee
	wordhell=pick(runewords)
	runewords-=wordhell
	wordblood=pick(runewords)
	runewords-=wordblood
	wordjoin=pick(runewords)
	runewords-=wordjoin
	wordtech=pick(runewords)
	runewords-=wordtech
	worddestr=pick(runewords)
	runewords-=worddestr

/obj/rune
	anchored = 1
	icon = 'magic.dmi'
	icon_state = "1"
	var/visibility = 0


	var
		word1
		word2
		word3

// travel self [word] - Teleport to [rune with word destination matching] (works in pairs)
// see blood Hell - Create a new tome
// join blood self - Incorporate person over the rune into the group
// Hell join self - Summon TERROR
// destroy see technology - EMP rune
// travel blood self - Drain blood
// see Hell join - See invisible
// blood join Hell - Raise dead
// blood see destroy - Hide nearby runes
// Hell join blood - Leave your body and ghost around
// blood see travel - Manifest a ghost into a mortal body
// Hell tech join - Imbue a rune into a talisman

	examine()
		if(!cultists.Find(usr))
			usr << "A strange collection of symbols drawn in blood."
		else
			usr << "A spell circle drawn in blood. It reads: <i>[word1] [word2] [word3]</i>."

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
		if(!src.visibility)
			src.visibility=1
		if(word1 == wordtravel && word2 == wordself)
			return teleport(src.word3)
		if(word1 == wordsee && word2 == wordblood && word3 == wordhell)
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
		if(word1 == wordjoin && word2 == wordblood && word3 == wordself)
			return convert()
		if(word1 == wordhell && word2 == wordjoin && word3 == wordself)
			return tearreality()
		if(word1 == worddestr && word2 == wordsee && word3 == wordtech)
			return emp(src.loc,1)
		if(word1 == wordtravel && word2 == wordblood && word3 == wordself)
			return drain()
		if(word1 == wordsee && word2 == wordhell && word3 == wordjoin)
			return seer()
		if(word1 == wordblood && word2 == wordjoin && word3 == wordhell)
			return raise()
		if(word1 == wordblood && word2 == wordsee && word3 == worddestr)
			return obscure(4)
		if(word1 == wordhell && word2 == wordjoin && word3 == wordblood)
			return ajourney()
		if(word1 == wordblood && word2 == wordsee && word3 == wordtravel)
			return manifest()
		if(word1 == wordhell && word2 == wordtech && word3 == wordjoin)
			return sigil()
		else
			return fizzle()


	proc
		fizzle()
			usr.say(pick("B'ADMINES SP'WNIN SH'T","IC'IN O'OC","RO'SHA'M I'SA GRI'FF'N ME'AI","TOX'IN'S O'NM FI'RAH","IA BL'AME TOX'IN'S","FIR'A NON'AN RE'SONA","A'OI I'RS ROUA'GE","LE'OAN JU'STA SP'A'C Z'EE SH'EF","IA PT'WOBEA'RD, IA A'DMI'NEH'LP"))
			for (var/mob/V in viewers(src))
				V.show_message("\red The markings pulse with a small burst of light, then fall dark.", 3, "\red You hear a faint fizzle.", 2)
			return

		check_icon()
			if(word1 == wordtravel && word2 == wordself)
				icon_state = "2"
				return
			if(word1 == wordjoin && word2 == wordblood && word3 == wordself)
				icon_state = "3"
				return
			if(word1 == wordhell && word2 == wordjoin && word3 == wordself)
				icon_state = "3"
				src.icon += rgb(100, 0 , 150)
				return
			if(word1 == wordsee && word2 == wordblood && word3 == wordhell)
				icon_state = "3"
				src.icon -= rgb(255, 255 , 255)
				return
			if(word1 == worddestr && word2 == wordsee && word3 == wordtech)
				icon_state = "2"
				src.icon += rgb(0, 50 , 0)
				return
			if(word1 == wordtravel && word2 == wordblood && word3 == wordself)
				icon_state = "2"
				src.icon -= rgb(255, 255 , 255)
				return
			if(word1 == wordsee && word2 == wordhell && word3 == wordjoin)
				icon_state = "2"
				src.icon += rgb(0, 0 , 200)
				return
			if(word1 == wordblood && word2 == wordjoin && word3 == wordhell)
				icon_state = "3"
				src.icon += rgb(255, 255 , 255)
				return
			if(word1 == wordblood && word2 == wordsee && word3 == worddestr)
				icon_state = "3"
				src.icon += rgb(-255, 255 , -255)
				return
			if(word1 == wordhell && word2 == wordjoin && word3 == wordblood)
				icon_state = "2"
				src.icon += rgb(-255, 255 , -255)
				return
			if(word1 == wordblood && word2 == wordsee && word3 == wordtravel)
				icon_state = "2"
				src.icon -= rgb(255, 255 , 255)
				src.icon += rgb(0, 0 , 255)
				return
			if(word1 == wordhell && word2 == wordtech && word3 == wordjoin)
				icon_state = "3"
				src.icon -= rgb(255, 255 , 255)
				src.icon += rgb(0, 0 , 255)
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
		if(!wordtravel)
			runerandom()
		if(cultists.Find(user))
			var/C = 0
			for(var/obj/rune/N in world)
				C++
			if (C>=26+runedec) //including the useless rune at the secret room, shouldn't count against the limit of 25 runes - Urist
				switch(alert("The cloth of reality can't take that much of a strain. By creating another rune, you risk locally tearing reality apart, which would prove fatal to you. Do you still wish to scribe the rune?",,"Yes","No"))
					if("Yes")
						if(prob(C*5-105-runedec*5)) //including the useless rune at the secret room, shouldn't count against the limit - Urist
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

/obj/item/weapon/tome/imbued //admin tome, spawns working runes without waiting

	attack_self(mob/user as mob)
		if(!wordtravel)
			runerandom()
		if(user)
			var/r
			var/list/runes = list("teleport", "tome", "convert", "tear in reality", "emp", "drain", "seer", "raise", "obscure", "astral journey", "manifest", "imbue talisman")
			r = input("Choose a rune to scribe", "Rune Scribing") in runes
			switch(r)
				if("teleport")
					var/list/words = list("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar")
					var/beacon
					if(usr)
						beacon = input("Select the last rune", "Rune Scribing") in words
					var/obj/rune/R = new /obj/rune(user.loc)
					R.word1=wordtravel
					R.word2=wordself
					R.word3=beacon
					R.check_icon()
				if("tome")
					var/obj/rune/R = new /obj/rune(user.loc)
					R.word1=wordsee
					R.word2=wordblood
					R.word3=wordhell
					R.check_icon()
				if("convert")
					var/obj/rune/R = new /obj/rune(user.loc)
					R.word1=wordjoin
					R.word2=wordblood
					R.word3=wordself
					R.check_icon()
				if("tear in reality")
					var/obj/rune/R = new /obj/rune(user.loc)
					R.word1=wordhell
					R.word2=wordjoin
					R.word3=wordself
					R.check_icon()
				if("emp")
					var/obj/rune/R = new /obj/rune(user.loc)
					R.word1=worddestr
					R.word2=wordsee
					R.word3=wordtech
					R.check_icon()
				if("drain")
					var/obj/rune/R = new /obj/rune(user.loc)
					R.word1=wordtravel
					R.word2=wordblood
					R.word3=wordself
					R.check_icon()
				if("seer")
					var/obj/rune/R = new /obj/rune(user.loc)
					R.word1=wordsee
					R.word2=wordhell
					R.word3=wordjoin
					R.check_icon()
				if("raise")
					var/obj/rune/R = new /obj/rune(user.loc)
					R.word1=wordblood
					R.word2=wordjoin
					R.word3=wordhell
					R.check_icon()
				if("obscure")
					var/obj/rune/R = new /obj/rune(user.loc)
					R.word1=wordblood
					R.word2=wordsee
					R.word3=worddestr
					R.check_icon()
				if("astral journey")
					var/obj/rune/R = new /obj/rune(user.loc)
					R.word1=wordhell
					R.word2=wordjoin
					R.word3=wordblood
					R.check_icon()
				if("manifest")
					var/obj/rune/R = new /obj/rune(user.loc)
					R.word1=wordblood
					R.word2=wordsee
					R.word3=wordtravel
					R.check_icon()
				if("imbue talisman")
					var/obj/rune/R = new /obj/rune(user.loc)
					R.word1=wordhell
					R.word2=wordtech
					R.word3=wordjoin
					R.check_icon()

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

/obj/item/weapon/paper/talisman
	icon_state = "papertalisman"
	var/imbue = null

	attack_self(mob/user as mob)
		usr.bruteloss+=20
		switch(imbue)
			if("newtome")
				call(/obj/rune/proc/tomesummon)()
			if("emp")
				call(/obj/rune/proc/emp)(usr.loc,4)
			if("conceal")
				call(/obj/rune/proc/obscure)(2)
			if("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar")
				call(/obj/rune/proc/teleport)(imbue)
		if(src)
			del(src)
		return