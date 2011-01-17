var/list/cultists = list()
var/wordtravel = null
var/wordself = null
var/wordsee = null
var/wordhell = null
var/wordblood = null
var/wordjoin = null
var/wordtech = null
var/worddestr = null
var/wordother = null
var/wordhear = null
var/wordfree = null
var/wordhide = null
var/runedec = 0

/client/proc/check_words() // -- Urist
	set category = "Special Verbs"
	set name = "Check Rune Words"
	set desc = "Check the rune-word meaning"
	if(!wordtravel)
		runerandom()
	usr << "[wordtravel] is travel, [wordblood] is blood, [wordjoin] is join, [wordhell] is Hell, [worddestr] is destroy, [wordtech] is technology, [wordself] is self, [wordsee] is see, [wordfree] is freedom, [wordhear] is hear, [wordother] is other, [wordhide] is hide."


/proc/runerandom() //randomizes word meaning
	var/list/runewords=list("ire","ego","nahlizet","certum","veri","jatkaa","mgar","balaq", "karazet", "geeri", "orkan", "allaq")
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
	wordother=pick(runewords)
	runewords-=wordother
	wordhear=pick(runewords)
	runewords-=wordhear
	wordfree=pick(runewords)
	runewords-=wordfree
	wordhide=pick(runewords)
	runewords-=wordhide

/obj/rune
	anchored = 1
	icon = 'rune.dmi'
	icon_state = "1"
	var/visibility = 0
	unacidable = 1


	var
		word1
		word2
		word3

// travel self [word] - Teleport to random [rune with word destination matching]
// travel other [word] - Portal to rune with word destination matching
// see blood Hell - Create a new tome
// join blood self - Incorporate person over the rune into the group
// Hell join self - Summon TERROR
// destroy see technology - EMP rune
// travel blood self - Drain blood
// see Hell join - See invisible
// blood join Hell - Raise dead

// hide see blood - Hide nearby runes
// destroy hide blood - Reveal nearby runes

// Hell travel self - Leave your body and ghost around
// blood see travel - Manifest a ghost into a mortal body
// Hell tech join - Imbue a rune into a talisman
// Hell blood join - Sacrifice rune
// destroy travel self - Wall rune
// join other self - Summon cultist rune
// freedom join other - Freeing rune

// destroy see hear - Deafening rune
// destroy see other - Blinding rune
// destroy see blood - BLOOD BOIL

// other hear blood - Communication rune

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
			var/obj/item/weapon/storage/bible/bible = I
			user << "\blue You banish the vile magic with the blessing of [bible.deity_name]!"
			del(src)
			return
		return

	attack_hand(mob/user as mob)
		if(!cultists.Find(user))
			user << "You can't mouth the arcane scratchings without fumbling over them."
			return
		if(istype(user.wear_mask, /obj/item/clothing/mask/muzzle) || user.ear_deaf)
			user << "You need to be able to both speak and hear to use runes."
			return
		if(!word1 || !word2 || !word3 || prob(usr.brainloss))
			return fizzle()
//		if(!src.visibility)
//			src.visibility=1
		if(word1 == wordtravel && word2 == wordself)
			return teleport(src.word3)
		if(word1 == wordsee && word2 == wordblood && word3 == wordhell)
			return tomesummon()
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
		if(word1 == wordhide && word2 == wordsee && word3 == wordblood)
			return obscure(4)
		if(word1 == wordhell && word2 == wordtravel && word3 == wordself)
			return ajourney()
		if(word1 == wordblood && word2 == wordsee && word3 == wordtravel)
			return manifest()
		if(word1 == wordhell && word2 == wordtech && word3 == wordjoin)
			return talisman()
		if(word1 == wordhell && word2 == wordblood && word3 == wordjoin)
			return sacrifice()
		if(word1 == worddestr && word2 == wordhide && word3 == wordblood)
			return revealrunes(src)
		if(word1 == worddestr && word2 == wordtravel && word3 == wordself)
			return wall()
		if(word1 == wordfree && word2 == wordjoin && word3 == wordother)
			return freedom()
		if(word1 == wordjoin && word2 == wordother && word3 == wordself)
			return cultsummon()
		if(word1 == worddestr && word2 == wordsee && word3 == wordhear)
			return deafen()
		if(word1 == worddestr && word2 == wordsee && word3 == wordother)
			return blind()
		if(word1 == worddestr && word2 == wordsee && word3 == wordblood)
			return bloodboil()
		if(word1 == wordother && word2 == wordhear && word3 == wordblood)
			return communicate()
		if(word1 == wordtravel && word2 == wordother)
			return itemport(src.word3)
		else
			return fizzle()


	proc
		fizzle()
			if(istype(src,/obj/rune))
				usr.say(pick("B'ADMINES SP'WNIN SH'T","IC'IN O'OC","RO'SHA'M I'SA GRI'FF'N ME'AI","TOX'IN'S O'NM FI'RAH","IA BL'AME TOX'IN'S","FIR'A NON'AN RE'SONA","A'OI I'RS ROUA'GE","LE'OAN JU'STA SP'A'C Z'EE SH'EF","IA PT'WOBEA'RD, IA A'DMI'NEH'LP"))
			else
				usr.whisper(pick("B'ADMINES SP'WNIN SH'T","IC'IN O'OC","RO'SHA'M I'SA GRI'FF'N ME'AI","TOX'IN'S O'NM FI'RAH","IA BL'AME TOX'IN'S","FIR'A NON'AN RE'SONA","A'OI I'RS ROUA'GE","LE'OAN JU'STA SP'A'C Z'EE SH'EF","IA PT'WOBEA'RD, IA A'DMI'NEH'LP"))
			for (var/mob/V in viewers(src))
				V.show_message("\red The markings pulse with a small burst of light, then fall dark.", 3, "\red You hear a faint fizzle.", 2)
			return

		check_icon()
			if(word1 == wordtravel && word2 == wordself)
				icon_state = "2"
				src.icon += rgb(0, 0 , 255)
				return
			if(word1 == wordjoin && word2 == wordblood && word3 == wordself)
				icon_state = "3"
				return
			if(word1 == wordhell && word2 == wordjoin && word3 == wordself)
				icon_state = "4"
				return
			if(word1 == wordsee && word2 == wordblood && word3 == wordhell)
				icon_state = "5"
				src.icon += rgb(0, 0 , 255)
				return
			if(word1 == worddestr && word2 == wordsee && word3 == wordtech)
				icon_state = "5"
				return
			if(word1 == wordtravel && word2 == wordblood && word3 == wordself)
				icon_state = "2"
				return
			if(word1 == wordsee && word2 == wordhell && word3 == wordjoin)
				icon_state = "4"
				src.icon += rgb(0, 0 , 255)
				return
			if(word1 == wordblood && word2 == wordjoin && word3 == wordhell)
				icon_state = "1"
				return
			if(word1 == wordhide && word2 == wordsee && word3 == wordblood)
				icon_state = "1"
				src.icon += rgb(0, 0 , 255)
				return
			if(word1 == wordhell && word2 == wordtravel && word3 == wordself)
				icon_state = "6"
				src.icon += rgb(0, 0 , 255)
				return
			if(word1 == wordblood && word2 == wordsee && word3 == wordtravel)
				icon_state = "6"
				return
			if(word1 == wordhell && word2 == wordtech && word3 == wordjoin)
				icon_state = "3"
				src.icon += rgb(0, 0 , 255)
				return
			if(word1 == wordhell && word2 == wordblood && word3 == wordjoin)
				icon_state = "[rand(1,6)]"
				src.icon += rgb(255, 255, 255)
				return
			if(word1 == worddestr && word2 == wordhide && word3 == wordblood)
				icon_state = "4"
				src.icon += rgb(255, 255, 255)
				return
			if(word1 == worddestr && word2 == wordtravel && word3 == wordself)
				icon_state = "1"
				src.icon += rgb(255, 0, 0)
				return
			if(word1 == wordfree && word2 == wordjoin && word3 == wordother)
				icon_state = "4"
				src.icon += rgb(255, 0, 255)
				return
			if(word1 == wordjoin && word2 == wordother && word3 == wordself)
				icon_state = "2"
				src.icon += rgb(0, 255, 0)
				return
			if(word1 == worddestr && word2 == wordsee && word3 == wordhear)
				icon_state = "4"
				src.icon += rgb(0, 255, 0)
				return
			if(word1 == worddestr && word2 == wordsee && word3 == wordother)
				icon_state = "4"
				src.icon += rgb(0, 0, 255)
				return
			if(word1 == worddestr && word2 == wordsee && word3 == wordblood)
				icon_state = "4"
				src.icon += rgb(255, 0, 0)
				return
			if(word1 == wordother && word2 == wordhear && word3 == wordblood)
				icon_state = "3"
				src.icon += rgb(200, 0, 0)
				return
			if(word1 == wordtravel && word2 == wordother)
				icon_state = "1"
				src.icon += rgb(200, 0, 0)
				return
			icon_state="[rand(1,6)]" //random shape and color for dummy runes
			src.icon -= rgb(255,255,255)
			src.icon += rgb(rand(1,255),rand(1,255),rand(1,255))

/obj/item/weapon/tome
	name = "arcane tome"
	icon_state ="tome"
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	flags = FPRINT | TABLEPASS

	attack(mob/M as mob, mob/user as mob)
		if(!cultists.Find(user))
			return ..()
		if(cultists.Find(M))
			return
		M.fireloss += rand(5,20) //really lucky - 5 hits for a crit
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red <B>[] beats [] with the arcane tome!</B>", user, M), 1)
		M << "\red You feel searing heat inside!"



	attack_self(mob/user as mob)
		if(!wordtravel)
			runerandom()
		if(cultists.Find(user))
			var/C = 0
			for(var/obj/rune/N in world)
				C++
			if (!istype(user.loc,/turf))
				user << "\red You do not have enough space to write a proper rune."
				return
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
			var/list/words = list("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri", "orkan", "allaq")
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
				var/mob/living/carbon/human/H = user
				var/obj/rune/R = new /obj/rune(user.loc)
				user << "\red You finish drawing the arcane markings of the Geometer."
				R.word1 = w1
				R.word2 = w2
				R.word3 = w3
				R.check_icon()
				R.blood_DNA = H.dna.unique_enzymes
				R.blood_type = H.b_type
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
	w_class = 2.0
	var/cultistsonly = 1
	attack_self(mob/user as mob)
		if(src.cultistsonly && !cultists.Find(usr))
			return
		if(!wordtravel)
			runerandom()
		if(user)
			var/r
			if (!istype(user.loc,/turf))
				user << "\red You do not have enough space to write a proper rune."
			var/list/runes = list("teleport", "itemport", "tome", "convert", "tear in reality", "emp", "drain", "seer", "raise", "obscure", "reveal", "astral journey", "manifest", "imbue talisman", "sacrifice", "wall", "freedom", "cultsummon", "deafen", "blind", "bloodboil", "communicate")
			r = input("Choose a rune to scribe", "Rune Scribing") in runes //not cancellable.
			var/obj/rune/R = new /obj/rune
			if(istype(user, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = user
				R.blood_DNA = H.dna.unique_enzymes
				R.blood_type = H.b_type
			switch(r)
				if("teleport")
					var/list/words = list("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri", "orkan", "allaq")
					var/beacon
					if(usr)
						beacon = input("Select the last rune", "Rune Scribing") in words
					R.word1=wordtravel
					R.word2=wordself
					R.word3=beacon
					R.loc = user.loc
					R.check_icon()
				if("itemport")
					var/list/words = list("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri", "orkan", "allaq")
					var/beacon
					if(usr)
						beacon = input("Select the last rune", "Rune Scribing") in words
					R.word1=wordtravel
					R.word2=wordother
					R.word3=beacon
					R.loc = user.loc
					R.check_icon()
				if("tome")
					R.word1=wordsee
					R.word2=wordblood
					R.word3=wordhell
					R.loc = user.loc
					R.check_icon()
				if("convert")
					R.word1=wordjoin
					R.word2=wordblood
					R.word3=wordself
					R.loc = user.loc
					R.check_icon()
				if("tear in reality")
					R.word1=wordhell
					R.word2=wordjoin
					R.word3=wordself
					R.loc = user.loc
					R.check_icon()
				if("emp")
					R.word1=worddestr
					R.word2=wordsee
					R.word3=wordtech
					R.loc = user.loc
					R.check_icon()
				if("drain")
					R.word1=wordtravel
					R.word2=wordblood
					R.word3=wordself
					R.loc = user.loc
					R.check_icon()
				if("seer")
					R.word1=wordsee
					R.word2=wordhell
					R.word3=wordjoin
					R.loc = user.loc
					R.check_icon()
				if("raise")
					R.word1=wordblood
					R.word2=wordjoin
					R.word3=wordhell
					R.loc = user.loc
					R.check_icon()
				if("obscure")
					R.word1=wordhide
					R.word2=wordsee
					R.word3=wordblood
					R.loc = user.loc
					R.check_icon()
				if("astral journey")
					R.word1=wordhell
					R.word2=wordtravel
					R.word3=wordself
					R.loc = user.loc
					R.check_icon()
				if("manifest")
					R.word1=wordblood
					R.word2=wordsee
					R.word3=wordtravel
					R.loc = user.loc
					R.check_icon()
				if("imbue talisman")
					R.word1=wordhell
					R.word2=wordtech
					R.word3=wordjoin
					R.loc = user.loc
					R.check_icon()
				if("sacrifice")
					R.word1=wordhell
					R.word2=wordblood
					R.word3=wordjoin
					R.loc = user.loc
					R.check_icon()
				if("reveal")
					R.word1=worddestr
					R.word2=wordhide
					R.word3=wordblood
					R.loc = user.loc
					R.check_icon()
				if("wall")
					R.word1=worddestr
					R.word2=wordtravel
					R.word3=wordself
					R.loc = user.loc
					R.check_icon()
				if("freedom")
					R.word1=wordfree
					R.word2=wordjoin
					R.word3=wordother
					R.loc = user.loc
					R.check_icon()
				if("cultsummon")
					R.word1=wordjoin
					R.word2=wordother
					R.word3=wordself
					R.loc = user.loc
					R.check_icon()
				if("deafen")
					R.word1=worddestr
					R.word2=wordsee
					R.word3=wordhear
					R.loc = user.loc
					R.check_icon()
				if("blind")
					R.word1=worddestr
					R.word2=wordsee
					R.word3=wordother
					R.loc = user.loc
					R.check_icon()
				if("bloodboil")
					R.word1=worddestr
					R.word2=wordsee
					R.word3=wordblood
					R.loc = user.loc
					R.check_icon()
				if("communicate")
					R.word1=wordother
					R.word2=wordhear
					R.word3=wordblood
					R.loc = user.loc
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
	var/uses = 0

	attack_self(mob/user as mob)
		usr.bruteloss+=5
		switch(imbue)
			if("newtome")
				call(/obj/rune/proc/tomesummon)()
			if("emp")
				call(/obj/rune/proc/emp)(usr.loc,4)
			if("conceal")
				call(/obj/rune/proc/obscure)(2)
			if("revealrunes")
				call(/obj/rune/proc/revealrunes)(src)
			if("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri", "orkan")
				call(/obj/rune/proc/teleport)(imbue)
			if("communicate")
				call(/obj/rune/proc/communicate)()
			if("deafen")
				call(/obj/rune/proc/deafen)()
			if("blind")
				call(/obj/rune/proc/blind)()
			if("supply")
				supply()
		if(src && src.imbue!="supply")
			del(src)
		return

/obj/item/weapon/paper/talisman/supply
	imbue = "supply"
	uses = 3