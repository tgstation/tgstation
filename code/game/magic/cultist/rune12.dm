/obj/rune/proc/talisman()//only hide, emp, teleport and tome runes can be imbued atm
	for(var/obj/rune/R in orange(1,src))
		if(R==src)
			continue
		if(R.word1==wordtravel && R.word2==wordself)
			for(var/obj/item/weapon/paper/P in src.loc)
				if(P.info)
					usr << "\red The blank is tainted. It is unsuitable."
					return
				del(P)
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(src.loc)
				T.imbue = "[R.word3]"
				T.info = "[R.word3]"
				for (var/mob/V in viewers(src))
					V.show_message("\red The runes turn into dust, which then forms into an arcane image on the paper.", 3)
				del(R)
				del(src)
				usr.say("H'drak v'loso, mir'kanas verbot!")
				return
		if(R.word1==wordsee && R.word2==wordblood && R.word3==wordhell)
			for(var/obj/item/weapon/paper/P in src.loc)
				if(P.info)
					usr << "\red The blank is tainted. It is unsuitable."
					return
				del(P)
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(src.loc)
				T.imbue = "newtome"
				for (var/mob/V in viewers(src))
					V.show_message("\red The runes turn into dust, which then forms into an arcane image on the paper.", 3)
				del(R)
				del(src)
				usr.say("H'drak v'loso, mir'kanas verbot!")
				return
		if(R.word1==worddestr && R.word2==wordsee && R.word3==wordtech)
			for(var/obj/item/weapon/paper/P in src.loc)
				if(P.info)
					usr << "\red The blank is tainted. It is unsuitable."
					return
				del(P)
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(src.loc)
				T.imbue = "emp"
				for (var/mob/V in viewers(src))
					V.show_message("\red The runes turn into dust, which then forms into an arcane image on the paper.", 3)
				del(R)
				del(src)
				usr.say("H'drak v'loso, mir'kanas verbot!")
				return
		if(R.word1==wordblood && R.word2==wordsee && R.word3==worddestr)
			for(var/obj/item/weapon/paper/P in src.loc)
				if(P.info)
					usr << "\red The blank is tainted. It is unsuitable."
					return
				del(P)
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(src.loc)
				T.imbue = "conceal"
				for (var/mob/V in viewers(src))
					V.show_message("\red The runes turn into dust, which then forms into an arcane image on the paper.", 3)
				del(R)
				del(src)
				usr.say("H'drak v'loso, mir'kanas verbot!")
				return
		if(R.word1==worddestr && R.word2==wordsee && R.word3==wordblood)
			for(var/obj/item/weapon/paper/P in src.loc)
				if(P.info)
					usr << "\red The blank is tainted. It is unsuitable."
					return
				del(P)
				var/obj/item/weapon/paper/talisman/T = new /obj/item/weapon/paper/talisman(src.loc)
				T.imbue = "revealrunes"
				for (var/mob/V in viewers(src))
					V.show_message("\red The runes turn into dust, which then forms into an arcane image on the paper.", 3)
				del(R)
				del(src)
				usr.say("H'drak v'loso, mir'kanas verbot!")
				return
	return fizzle()