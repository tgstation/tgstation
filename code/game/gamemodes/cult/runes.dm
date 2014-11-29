var/list/sacrificed = list()

/obj/effect/rune
	var/atom/movable/overlay/c_animation = null
	var/nullblock = 0

/obj/effect/rune/cultify()
	return

/obj/effect/rune/proc/findNullRod(var/atom/target)
	if(istype(target,/obj/item/weapon/nullrod))
		var/turf/T = get_turf(target)
		nullblock = 1
		T.nullding()
		return 1
	else if(target.contents)
		for(var/atom/A in target.contents)
			findNullRod(A)
	return 0

/obj/effect/rune/proc/invocation(var/animation_icon)
	c_animation = new /atom/movable/overlay(src.loc)
	c_animation.name = "cultification"
	c_animation.density = 0
	c_animation.anchored = 1
	c_animation.icon = 'icons/effects/effects.dmi'
	c_animation.layer = 5
	c_animation.master = src.loc
	c_animation.icon_state = "[animation_icon]"
	flick("cultification",c_animation)
	spawn(10)
		del(c_animation)

/////////////////////////////////////////FIRST RUNE
/obj/effect/rune/proc/teleport(var/key)
	var/mob/living/user = usr
	var/allrunesloc[]
	allrunesloc = new/list()
	var/index = 0
//	var/tempnum = 0
	for(var/obj/effect/rune/R in rune_list)
		if(R == src)
			continue
		if(R.word1 == cultwords["travel"] && R.word2 == cultwords["self"] && R.word3 == key && R.z != 2)
			index++
			allrunesloc.len = index
			allrunesloc[index] = R.loc
	if(index >= 5)
		user << "<span class='warning'>You feel pain, as rune disappears in reality shift caused by too much wear of space-time fabric</span>"
		if (istype(user, /mob/living))
			user.take_overall_damage(5, 0)
		qdel(src)
	if(allrunesloc && index != 0)
		if(istype(src,/obj/effect/rune))
			user.say("Sas[pick("'","`")]so c'arta forbici!")//Only you can stop auto-muting
		else
			user.whisper("Sas[pick("'","`")]so c'arta forbici!")
		if(universe.name != "Hell Rising")
			user.visible_message("<span class='warning'> [user] disappears in a flash of red light!</span>", \
			"<span class='warning'> You feel as your body gets dragged through the dimension of Nar-Sie!</span>", \
			"<span class='warning'> You hear a sickening crunch and sloshing of viscera.</span>")
		else
			user.visible_message("<span class='warning'> [user] disappears in a flash of red light!</span>", \
			"<span class='warning'> You feel as your body gets dragged through a tunnel of viscera !</span>", \
			"<span class='warning'> You hear a sickening crunch and sloshing of viscera.</span>")

		if(istype(src,/obj/effect/rune))
			invocation("rune_teleport")

		user.loc = allrunesloc[rand(1,index)]
		return
	if(istype(src,/obj/effect/rune))
		return	fizzle() //Use friggin manuals, Dorf, your list was of zero length.
	else
		call(/obj/effect/rune/proc/fizzle)()
		return


/obj/effect/rune/proc/itemport(var/key)
//	var/allrunesloc[]
//	allrunesloc = new/list()
//	var/index = 0
//	var/tempnum = 0
	var/culcount = 0
	var/runecount = 0
	var/obj/effect/rune/IP = null
	var/mob/living/user = usr
	var/swapping[] = null
	for(var/obj/effect/rune/R in rune_list)
		if(R == src)
			continue
		if(R.word1 == cultwords["travel"] && R.word2 == cultwords["other"] && R.word3 == key)
			IP = R
			runecount++
	if(runecount >= 2)
		user << "<span class='warning'>You feel pain, as rune disappears in reality shift caused by too much wear of space-time fabric</span>"
		if (istype(user, /mob/living))
			user.take_overall_damage(5, 0)
		qdel(src)
	for(var/mob/living/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			culcount++
	if(culcount>=3)
		user.say("Sas[pick("'","`")]so c'arta forbici tarem!")

		nullblock = 0
		for(var/turf/T1 in range(src,1))
			findNullRod(T1)
		if(nullblock)
			user.visible_message("<span class='warning'>A nearby null rod seems to be blocking the transfer.</span>")
			return

		for(var/turf/T2 in range(IP,1))
			findNullRod(T2)
		if(nullblock)
			user.visible_message("<span class='warning'>A null rod seems to be blocking the transfer on the other side.</span>")
			return

		user.visible_message("<span class='warning'>You feel air moving from the rune - like as it was swapped with somewhere else.</span>", \
		"<span class='warning'>You feel air moving from the rune - like as it was swapped with somewhere else.</span>", \
		"<span class='warning'>You smell ozone.</span>")

		swapping = list()
		for(var/obj/O in IP.loc)//filling a list with all the teleportable atoms on the other rune
			if(!O.anchored)
				swapping += O
		for(var/mob/M in IP.loc)
			swapping += M

		for(var/obj/O in src.loc)//sending the items on the rune to the other rune
			if(!O.anchored)
				O.loc = IP.loc
		for(var/mob/M in src.loc)
			M.loc = IP.loc

		for(var/obj/O in swapping)//bringing the items previously marked from the other rune to our rune
			O.loc = src.loc
		for(var/mob/M in swapping)
			M.loc = src.loc

		swapping = 0
		return
	return fizzle()


/////////////////////////////////////////SECOND RUNE

/obj/effect/rune/proc/tomesummon()
	if(istype(src,/obj/effect/rune))
		usr.say("N[pick("'","`")]ath reth sh'yro eth d'raggathnor!")
	else
		usr.whisper("N[pick("'","`")]ath reth sh'yro eth d'raggathnor!")
	usr.visible_message("<span class='warning'>Rune disappears with a flash of red light, and in its place now a book lies.</span>", \
	"<span class='warning'>You are blinded by the flash of red light! After you're able to see again, you see that now instead of the rune there's a book.</span>", \
	"<span class='warning'>You hear a pop and smell ozone.</span>")
	if(istype(src,/obj/effect/rune))
		new /obj/item/weapon/tome(src.loc)
	else
		new /obj/item/weapon/tome(usr.loc)
	qdel(src)
	return



/////////////////////////////////////////THIRD RUNE

/obj/effect/rune/proc/convert()
	for(var/mob/living/carbon/M in src.loc)
		if(iscultist(M))
			usr << "<span class='warning'>You cannot convert what is already a follower of Nar-Sie.</span>"
			return 0
		if(M.stat==DEAD)
			usr << "<span class='warning'>You cannot convert the dead.</span>"
			return 0
		if(!M.mind)
			usr << "<span class='warning'>You cannot convert that which has no soul</span>"
			return 0
		if((ticker.mode.name == "cult") && (M.mind == ticker.mode:sacrifice_target))
			usr << "<span class='warning'>The Geometer of blood wants this mortal for himself.</span>"
			return 0
		usr.say("Mah[pick("'","`")]weyh pleggh at e'ntrath!")
		nullblock = 0
		for(var/turf/T in range(M,1))
			findNullRod(T)
		if(nullblock)
			usr.visible_message("<span class='warning'>Something is blocking the conversion!</span>")
			return 0
		invocation("rune_convert")
		M.visible_message("<span class='warning'>[M] writhes in pain as the markings below him glow a bloody red.</span>", \
		"<span class='danger'>AAAAAAHHHH!.</span>", \
		"<span class='warning'>You hear an anguished scream.</span>")
		if(is_convertable_to_cult(M.mind) && !jobban_isbanned(M, "cultist"))//putting jobban check here because is_convertable uses mind as argument
			ticker.mode.add_cultist(M.mind)
			M.mind.special_role = "Cultist"
			M << "<span class='sinister'>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</span>"
			M << "<span class='sinister'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</span>"
			log_admin("[usr]([ckey(usr.key)]) has converted [M] ([ckey(M.key)]) to the cult at [M.loc.x], [M.loc.y], [M.loc.z]")
			return 1
		else
			M << "<span class='sinister'>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</span>"
			M << "<span class='warning'><b>And you were able to force it out of your mind. You now know the truth, there's something horrible out there, stop it and its minions at all costs.</b></span>"
			return 0

	usr.say("Mah[pick("'","`")]weyh pleggh at e'ntrath!")
	usr.show_message("\red The markings pulse with a small burst of light, then fall dark.", 3, "\red You hear a faint fizzle.", 2)
	usr << "<span class='notice'> You remembered the words correctly, but the rune isn't working. Maybe your ritual is missing something important.</span>"



/////////////////////////////////////////FOURTH RUNE

/obj/effect/rune/proc/tearreality()
	var/cultist_count = 0
	if(universe.name == "Hell Rising")
		for(var/mob/N in range(1,src))
			if(iscultist(N))
				N << "<span class='warning'>This plane of reality has already been torn into Nar-Sie's realm.</span>"
	else
		for(var/mob/M in range(1,src))
			if(iscultist(M) && !M.stat)
				M.say("Tok-lyr rqa'nap g[pick("'","`")]lt-ulotf!")
				cultist_count += 1
		if(cultist_count >= 9)
			new /obj/machinery/singularity/narsie/large(src.loc,cultspawn=1)
			if(ticker.mode.name == "cult")
				ticker.mode:eldergod = 0
			return
		else
			return fizzle()

/////////////////////////////////////////FIFTH RUNE

/obj/effect/rune/proc/emp(var/U,var/range_red) //range_red - var which determines by which number to reduce the default emp range, U is the source loc, needed because of talisman emps which are held in hand at the moment of using and that apparently messes things up -- Urist
	if(istype(src,/obj/effect/rune))
		usr.say("Ta'gh fara[pick("'","`")]qha fel d'amar det!")
	else
		usr.whisper("Ta'gh fara[pick("'","`")]qha fel d'amar det!")
	playsound(U, 'sound/items/Welder2.ogg', 25, 1)
	var/turf/T = get_turf(U)
	if(T)
		T.hotspot_expose(700,125,surfaces=1)
	var/rune = src // detaching the proc - in theory
	empulse(U, (range_red - 2), range_red)
	qdel(rune)
	return

/////////////////////////////////////////SIXTH RUNE

/obj/effect/rune/proc/drain()
	var/drain = 0
	for(var/obj/effect/rune/R in rune_list)
		if(R.word1==cultwords["travel"] && R.word2==cultwords["blood"] && R.word3==cultwords["self"])
			for(var/mob/living/carbon/D in R.loc)
				if(D.stat!=2)
					nullblock = 0
					for(var/turf/T in range(D,1))
						findNullRod(T)
					if(!nullblock)
						var/bdrain = rand(1,25)
						D << "<span class='warning'>You feel weakened.</span>"
						D.take_overall_damage(bdrain, 0)
						drain += bdrain
	if(!drain)
		return fizzle()
	usr.say ("Yu[pick("'","`")]gular faras desdae. Havas mithum javara. Umathar uf'kal thenar!")
	usr.visible_message("\red Blood flows from the rune into [usr]!", \
	"<span class='warning'>The blood starts flowing from the rune and into your frail mortal body. You feel... empowered.</span>", \
	"<span class='warning'>You hear a liquid flowing.</span>")
	var/mob/living/user = usr
	if(user.bhunger)
		user.bhunger = max(user.bhunger-2*drain,0)
	if(drain>=50)
		user.visible_message("\red [user]'s eyes give off eerie red glow!", \
		"<span class='warning'>...but it wasn't nearly enough. You crave, crave for more. The hunger consumes you from within.</span>", \
		"<span class='warning'>You hear a heartbeat.</span>")
		user.bhunger += drain
		src = user
		spawn()
			for (,user.bhunger>0,user.bhunger--)
				sleep(50)
				user.take_overall_damage(3, 0)
		return
	user.heal_organ_damage(drain%5, 0)
	drain-=drain%5
	for (,drain>0,drain-=5)
		sleep(2)
		user.heal_organ_damage(5, 0)
	return






/////////////////////////////////////////SEVENTH RUNE

/obj/effect/rune/proc/seer()
	if(usr.loc==src.loc)
		if(usr.seer==1)
			usr.say("Rash'tla sektath mal[pick("'","`")]zua. Zasan therium viortia.")
			usr << "<span class='warning'>The world beyond fades from your vision.</span>"
			usr.see_invisible = SEE_INVISIBLE_LIVING
			usr.seer = 0
		else if(usr.see_invisible!=SEE_INVISIBLE_LIVING)
			usr << "<span class='warning'>The world beyond flashes your eyes but disappears quickly, as if something is disrupting your vision.</span>"
			usr.see_invisible = SEE_INVISIBLE_OBSERVER
			usr.seer = 0
		else
			usr.say("Rash'tla sektath mal[pick("'","`")]zua. Zasan therium vivira. Itonis al'ra matum!")
			usr << "<span class='warning'>The world beyond opens to your eyes.</span>"
			usr.see_invisible = SEE_INVISIBLE_OBSERVER
			usr.seer = 1
		return
	usr.say("Rash'tla sektath mal[pick("'","`")]zua. Zasan therium vivira. Itonis al'ra matum!")
	usr.show_message("\<span class='warning'>The markings pulse with a small burst of light, then fall dark.</span>", 3, "<span class='warning'>You hear a faint fizzle.</span>", 2)
	usr << "<span class='notice'> You remembered the words correctly, but the rune isn't reacting. Maybe you should position yourself differently.</span>"

/////////////////////////////////////////EIGHTH RUNE

/obj/effect/rune/proc/raise()
	var/mob/living/carbon/human/corpse_to_raise
	var/mob/living/carbon/human/body_to_sacrifice

	var/is_sacrifice_target = 0
	for(var/mob/living/carbon/human/M in src.loc)
		if(M.stat == DEAD)
			if((ticker.mode.name == "cult") && (M.mind == ticker.mode:sacrifice_target))
				is_sacrifice_target = 1
			else
				corpse_to_raise = M
				if(M.key)
					M.ghostize(1)	//kick them out of their body
				break
	if(!corpse_to_raise)
		if(is_sacrifice_target)
			usr << "<span class='warning'>The Geometer of blood wants this mortal for himself.</span>"
		return fizzle()


	is_sacrifice_target = 0
	find_sacrifice:
		for(var/obj/effect/rune/R in rune_list)
			if(R.word1==cultwords["blood"] && R.word2==cultwords["join"] && R.word3==cultwords["hell"])
				for(var/mob/living/carbon/human/N in R.loc)
					if((ticker.mode.name == "cult") && (N.mind) && (N.mind == ticker.mode:sacrifice_target))
						is_sacrifice_target = 1
					else
						if(N.stat!= DEAD)
							nullblock = 0
							for(var/turf/T in range(N,1))
								findNullRod(T)
							if(nullblock)
								return fizzle()
							else
								body_to_sacrifice = N
								break find_sacrifice

	if(!body_to_sacrifice)
		if (is_sacrifice_target)
			usr << "<span class='warning'>The Geometer of blood wants that corpse for himself.</span>"
		else
			usr << "<span class='warning'>The sacrifical corpse is not dead. You must free it from this world of illusions before it may be used.</span>"
		return fizzle()

	var/mob/dead/observer/ghost
	for(var/mob/dead/observer/O in loc)
		if(!O.client)	continue
		if(O.mind && O.mind.current && O.mind.current.stat != DEAD)	continue
		ghost = O
		break

	if(!ghost)
		usr << "<span class='warning'>You require a restless spirit which clings to this world. Beckon their prescence with the sacred chants of Nar-Sie.</span>"
		return fizzle()

	corpse_to_raise.revive()

	corpse_to_raise.key = ghost.key	//the corpse will keep its old mind! but a new player takes ownership of it (they are essentially possessed)
									//This means, should that player leave the body, the original may re-enter
	usr.say("Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!")
	corpse_to_raise.visible_message("<span class='warning'>[corpse_to_raise]'s eyes glow with a faint red as he stands up, slowly starting to breathe again.</span>", \
	"<span class='warning'>Life... I am alive again...</span>", \
	"<span class='warning'>You hear a faint, slightly familiar whisper.</span>")
	body_to_sacrifice.visible_message("<span class='warning'>[body_to_sacrifice] is torn apart, a black smoke swiftly dissipating from his remains!</span>", \
	"<span class='warning'>You feel as your blood boils, tearing you apart.</span>", \
	"<span class='warning'>You hear a thousand voices, all crying in pain.</span>")
	body_to_sacrifice.gib()

//	if(ticker.mode.name == "cult")
//		ticker.mode:add_cultist(corpse_to_raise.mind)
//	else
//		ticker.mode.cult |= corpse_to_raise.mind

	corpse_to_raise << "<span class='sinister'>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</span>"
	corpse_to_raise << "<span class='sinister'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</span>"
	return





/////////////////////////////////////////NINETH RUNE

/obj/effect/rune/proc/obscure(var/rad)
	var/S=0
	for(var/obj/effect/rune/R in orange(rad,src))
		if(R!=src)
			R.invisibility=INVISIBILITY_OBSERVER
		S=1
	if(S)
		if(istype(src,/obj/effect/rune))
			usr.say("Kla[pick("'","`")]atu barada nikt'o!")
			for (var/mob/V in viewers(src))
				V.show_message("\red The rune turns into gray dust, veiling the surrounding runes.", 3)
			qdel(src)
		else
			usr.whisper("Kla[pick("'","`")]atu barada nikt'o!")
			usr << "<span class='warning'>Your talisman turns into gray dust, veiling the surrounding runes.</span>"
			for (var/mob/V in orange(1,src))
				if(V!=usr)
					V.show_message("<span class='warning'>Dust emanates from [usr]'s hands for a moment.</span>", 3)

		return
	if(istype(src,/obj/effect/rune))
		return	fizzle()
	else
		call(/obj/effect/rune/proc/fizzle)()
		return

/////////////////////////////////////////TENTH RUNE

/obj/effect/rune/proc/ajourney() //some bits copypastaed from admin tools - Urist
	if(usr.loc==src.loc)
		var/mob/living/carbon/human/L = usr
		usr.say("Fwe[pick("'","`")]sh mah erl nyag r'ya!")
		usr.visible_message("<span class='warning'>[usr]'s eyes glow blue as \he freezes in place, absolutely motionless.</span>", \
		"<span class='warning'>The shadow that is your spirit separates itself from your body. You are now in the realm beyond. While this is a great sight, being here strains your mind and body. Hurry...</span>", \
		"<span class='warning'>You hear only complete silence for a moment.</span>")
		usr.ghostize(1)
		L.ajourn = 1
		while(L)
			if(L.key)
				L.ajourn=0
				return
			else
				L.take_organ_damage(10, 0)
			sleep(100)
	return fizzle()




/////////////////////////////////////////ELEVENTH RUNE

/obj/effect/rune/proc/manifest()
	var/obj/effect/rune/this_rune = src
	src = null
	if(usr.loc!=this_rune.loc)
		return this_rune.fizzle()
	var/mob/dead/observer/ghost
	for(var/mob/dead/observer/O in this_rune.loc)
		if(!O.client)	continue
		if(O.mind && O.mind.current && O.mind.current.stat != DEAD)	continue
		ghost = O
		break
	if(!ghost)
		return this_rune.fizzle()
	if(jobban_isbanned(ghost, "cultist"))
		return this_rune.fizzle()

	usr.say("Gal'h'rfikk harfrandid mud[pick("'","`")]gib!")

	var/mob/living/carbon/human/manifested/D = new(this_rune.loc)
	D.key = ghost.key
	D.icon = null
	D.invisibility = 101
	D.canmove = 0
	var/atom/movable/overlay/animation = null

	usr.visible_message("<span class='warning'> A shape forms in the center of the rune. A shape of... a man.<BR>The world feels blury as your soul permeates this temporary body.</span>", \
	"<span class='warning'> A shape forms in the center of the rune. A shape of... a man.</span>", \
	"<span class='warning'> You hear liquid flowing.</span>")

	animation = new(D.loc)
	animation.layer = usr.layer + 1
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = this_rune
	flick("appear-hm", animation)
	sleep(5)
	D.invisibility = 0
	sleep(10)
	D.real_name = "Unknown"
	var/chose_name = 0
	for(var/obj/item/weapon/paper/P in this_rune.loc)
		if(P.info)
			D.real_name = copytext(P.info, 1, MAX_NAME_LEN)
			chose_name = 1
			break
	if(!chose_name)
		D.real_name = "[pick(first_names_male)] [pick(last_names)]"
	D.universal_speak = 1
	D.status_flags &= ~GODMODE


	if(ticker.mode.name == "cult")
		ticker.mode:add_cultist(D.mind)
	else
		ticker.mode.cult+=D.mind
	ticker.mode.update_cult_icons_added(D.mind)
	D.canmove = 1
	del(animation)

	D.mind.special_role = "Cultist"
	D << "<span class='sinister'>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</span>"
	D << "<span class='sinister'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</span>"


	var/mob/living/user = usr
	while(this_rune && user && user.stat==CONSCIOUS && user.client && user.loc==this_rune.loc)
		user.take_organ_damage(1, 0)
		sleep(30)
	if(D)
		D.visible_message("<span class='warning'>[D] slowly dissipates into dust and bones.</span>", \
		"<span class='warning'>You feel pain, as bonds formed between your soul and this homunculus break.</span>", \
		"<span class='warning'>You hear faint rustle.</span>")
		D.dust()
	return





/////////////////////////////////////////TWELFTH RUNE

/obj/effect/rune/proc/talisman()//only tome, communicate, hide, reveal, emp, teleport, deafen, blind, stun and armor runes can be imbued
	var/obj/item/weapon/paper/newtalisman
	var/unsuitable_newtalisman = 0
	for(var/obj/item/weapon/paper/P in src.loc)
		if(!P.info)
			newtalisman = P
			break
		else
			unsuitable_newtalisman = 1
	if (!newtalisman)
		if (unsuitable_newtalisman)
			usr << "<span class='warning'>The blank is tainted. It is unsuitable.</span>"
		return fizzle()

	if (istype(newtalisman, /obj/item/weapon/paper/nano))//I mean, cult and technology don't mix well together right?
		usr << "<span class='warning'>This piece of technologically advanced paper is unsuitable.</span>"
		return fizzle()

	var/obj/effect/rune/imbued_from
	var/obj/item/weapon/paper/talisman/T
	for(var/obj/effect/rune/R in orange(1,src))
		if(R==src)
			continue
		if(R.word1==cultwords["travel"] && R.word2==cultwords["self"])  //teleport
			T = new(src.loc)
			T.imbue = "[R.word3]"
			imbued_from = R
			break
		if(R.word1==cultwords["see"] && R.word2==cultwords["blood"] && R.word3==cultwords["hell"]) //tome
			T = new(src.loc)
			T.imbue = "newtome"
			imbued_from = R
			break
		if(R.word1==cultwords["destroy"] && R.word2==cultwords["see"] && R.word3==cultwords["technology"]) //emp
			T = new(src.loc)
			T.imbue = "emp"
			imbued_from = R
			break
		if(R.word1==cultwords["blood"] && R.word2==cultwords["see"] && R.word3==cultwords["destroy"]) //conceal
			T = new(src.loc)
			T.imbue = "conceal"
			imbued_from = R
			break
		if(R.word1==cultwords["hell"] && R.word2==cultwords["destroy"] && R.word3==cultwords["other"]) //armor
			T = new(src.loc)
			T.imbue = "armor"
			imbued_from = R
			break
		if(R.word1==cultwords["blood"] && R.word2==cultwords["see"] && R.word3==cultwords["hide"]) //reveal
			T = new(src.loc)
			T.imbue = "revealrunes"
			imbued_from = R
			break
		if(R.word1==cultwords["hide"] && R.word2==cultwords["other"] && R.word3==cultwords["see"]) //deafen
			T = new(src.loc)
			T.imbue = "deafen"
			imbued_from = R
			break
		if(R.word1==cultwords["destroy"] && R.word2==cultwords["see"] && R.word3==cultwords["other"]) //blind
			T = new(src.loc)
			T.imbue = "blind"
			imbued_from = R
			break
		if(R.word1==cultwords["self"] && R.word2==cultwords["other"] && R.word3==cultwords["technology"]) //communicate
			T = new(src.loc)
			T.imbue = "communicate"
			imbued_from = R
			break
		if(R.word1==cultwords["join"] && R.word2==cultwords["hide"] && R.word3==cultwords["technology"]) //stun
			T = new(src.loc)
			T.imbue = "runestun"
			imbued_from = R
			break
	if (imbued_from)
		for (var/mob/V in viewers(src))
			V.show_message("<span class='warning'>The runes turn into dust, which then forms into an arcane image on the paper.</span>", 3)
		usr.say("H'drak v[pick("'","`")]loso, mir'kanas verbot!")
		qdel(imbued_from)
		qdel(newtalisman)
		invocation("rune_imbue")
	else
		return fizzle()

/////////////////////////////////////////THIRTEENTH RUNE

/obj/effect/rune/proc/mend()
	var/mob/living/user = usr
	src = null
	user.say("Uhrast ka'hfa heldsagen ver[pick("'","`")]lot!")
	user.take_overall_damage(200, 0)
	runedec+=10
	user.visible_message("<span class='warning'>[user] keels over dead, his blood glowing blue as it escapes his body and dissipates into thin air.</span>", \
	"<span class='warning'>In the last moment of your humble life, you feel an immense pain as fabric of reality mends... with your blood.</span>", \
	"<span class='warning'>You hear faint rustle.</span>")
	for(,user.stat==2)
		sleep(600)
		if (!user)
			return
	runedec-=10
	return


/////////////////////////////////////////FOURTEETH RUNE

// returns 0 if the rune is not used. returns 1 if the rune is used.
/obj/effect/rune/proc/communicate()
	. = 1 // Default output is 1. If the rune is deleted it will return 1
	var/input = stripped_input(usr, "Please choose a message to tell to the other acolytes.", "Voice of Blood", "")
	if(!input)
		if (istype(src))
			fizzle()
			return 0
		else
			return 0
	if(istype(src,/obj/effect/rune))
		usr.say("O bidai nabora se[pick("'","`")]sma!")
	else
		usr.whisper("O bidai nabora se[pick("'","`")]sma!")

	if(istype(src,/obj/effect/rune))
		usr.say("[input]")
	else
		usr.whisper("[input]")
	for(var/datum/mind/H in ticker.mode.cult)
		if (H.current)
			H.current << "<span class='sinister'> \b [input]</span>"//changed from red to purple - Deity Link
	qdel(src)
	return 1

/////////////////////////////////////////FIFTEENTH RUNE

/obj/effect/rune/proc/sacrifice()
	var/list/mob/living/cultsinrange = list()
	var/ritualresponse = ""
	var/sacrificedone = 0

	//how many cultists do we have near the rune
	for(var/mob/living/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			cultsinrange += C
			C.say("Barhah hra zar[pick("'","`")]garis!")

	//checking for null rods
	nullblock = 0
	for(var/turf/T in range(src,1))
		findNullRod(T)
	if(nullblock)
		usr << "<span class='warning'>The presence of a null rod is perturbing the ritual.</span>"
		return

	for(var/atom/A in loc)
		if(iscultist(A))
			continue
		var/satisfaction = 0
//Humans and Animals
		if(istype(A,/mob/living/carbon) || istype(A,/mob/living/simple_animal))//carbon mobs and simple animals
			var/mob/living/M = A
			if ((ticker.mode.name == "cult") && (M.mind == ticker.mode:sacrifice_target))
				if(cultsinrange.len >= 3)
					sacrificed += M.mind
					M.gib()
					sacrificedone = 1
					invocation("rune_sac")
					ritualresponse += "The Geometer of Blood gladly accepts this sacrifice, your objective is now complete."
				else
					ritualresponse += "You need more cultists to perform the ritual and complete your objective."
			else
				if(M.stat != DEAD)
					if(cultsinrange.len >= 3)
						if(M.mind)				//living players
							ritualresponse += "The Geometer of Blood gladly accepts this sacrifice."
							satisfaction = 100
						else					//living NPCs
							ritualresponse += "The Geometer of Blood accepts this being in sacrifice. Somehow you get the feeling that beings with souls would make a better offering."
							satisfaction = 50
						sacrificedone = 1
						invocation("rune_sac")
						M.gib()
					else
						ritualresponse += "The victim is still alive, you will need more cultists chanting for the sacrifice to succeed."
				else
					if(M.mind)					//dead players
						ritualresponse += "The Geometer of Blood accepts this sacrifice."
						satisfaction = 50
					else						//dead NPCs
						ritualresponse += "The Geometer of Blood accepts your meager sacrifice."
						satisfaction = 10
					sacrificedone = 1
					invocation("rune_sac")
					M.gib()
//Borgs and MoMMis
		else if(istype(A, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/B = A
			var/obj/item/device/mmi/O = locate() in B
			if(O)
				if((ticker.mode.name == "cult") && (O.brainmob.mind == ticker.mode:sacrifice_target))
					if(cultsinrange.len >= 3)
						ritualresponse += "The Geometer of Blood accepts this sacrifice, your objective is now complete."
						sacrificedone = 1
						invocation("rune_sac")
						B.dust()
					else
						ritualresponse += "You need more cultists to perform the ritual and complete your objective."
				else
					if(B.stat != DEAD)
						if(cultsinrange.len >= 3)
							ritualresponse += "The Geometer of Blood accepts to destroy that pile of machinery."
							sacrificedone = 1
							invocation("rune_sac")
							B.dust()
						else
							ritualresponse += "That machine is still working, you will need more cultists chanting for the sacrifice to destroy it."
					else
						ritualresponse += "The Geometer of Blood accepts to destroy that pile of machinery."
						sacrificedone = 1
						invocation("rune_sac")
						B.dust()
//MMI
		else if(istype(A, /obj/item/device/mmi))
			var/obj/item/device/mmi/I = A
			var/mob/living/carbon/brain/N = I.brainmob
			if(N)//the MMI has a player's brain in it
				if((ticker.mode.name == "cult") && (N.mind == ticker.mode:sacrifice_target))
					ritualresponse += "You need to place that brain back inside a body before you can complete your objective."
				else
					ritualresponse += "The Geometer of Blood accepts to destroy that pile of machinery."
					sacrificedone = 1
					invocation("rune_sac")
					I.on_fire = 1
					I.ashify()
//Brain
		else if(istype(A, /obj/item/organ/brain))
			var/obj/item/organ/brain/R = A
			var/mob/living/carbon/brain/N = R.brainmob
			if(N)//the brain is a player's
				if((ticker.mode.name == "cult") && (N.mind == ticker.mode:sacrifice_target))
					ritualresponse += "You need to place that brain back inside a body before you can complete your objective."
				else
					ritualresponse += "The Geometer of Blood accepts to destroy that brain."
					sacrificedone = 1
					invocation("rune_sac")
					R.on_fire = 1
					R.ashify()
//Carded AIs
		else if(istype(A, /obj/item/device/aicard))
			var/obj/item/device/aicard/D = A
			var/mob/living/silicon/ai/T = locate() in D
			if(T)//there is an AI on the card
				if((ticker.mode.name == "cult") && (T.mind == ticker.mode:sacrifice_target))//what are the odds this ever happens?
					sacrificed += T.mind
					ritualresponse += "With a sigh, the Geometer of Blood accepts this sacrifice, your objective is now complete."//since you cannot debrain an AI.
				else
					ritualresponse += "The Geometer of Blood accepts to destroy that piece of technological garbage."
				sacrificedone = 1
				invocation("rune_sac")
				D.on_fire = 1
				D.ashify()

		else
			continue

//feedback
		for(var/mob/living/C in cultsinrange)
			if(ritualresponse != "")
				C << "<span class='sinister'>[ritualresponse]</span>"
				if(prob(satisfaction))
					ticker.mode:grant_runeword(C)

	if(!sacrificedone)
		for(var/mob/living/C in cultsinrange)
			C << "<span class='warning'>There is nothing fit for sacrifice on the rune.</span>"

/////////////////////////////////////////SIXTEENTH RUNE

/obj/effect/rune/proc/revealrunes(var/obj/W as obj)
	var/go=0
	var/rad
	var/S=0
	if(istype(W,/obj/effect/rune))
		rad = 6
		go = 1
	if (istype(W,/obj/item/weapon/paper/talisman))
		rad = 4
		go = 1
	if (istype(W,/obj/item/weapon/nullrod))
		rad = 1
		go = 1
	if(go)
		for(var/obj/effect/rune/R in orange(rad,src))
			if(R!=src)
				R:visibility=15
			S=1
	if(S)
		if(istype(W,/obj/item/weapon/nullrod))
			usr << "<span class='warning'>Arcane markings suddenly glow from underneath a thin layer of dust!</span>"
			return
		if(istype(W,/obj/effect/rune))
			usr.say("Nikt[pick("'","`")]o barada kla'atu!")
			for (var/mob/V in viewers(src))
				V.show_message("<span class='warning'>The rune turns into red dust, reveaing the surrounding runes.</span>", 3)
			qdel(src)
			return
		if(istype(W,/obj/item/weapon/paper/talisman))
			usr.whisper("Nikt[pick("'","`")]o barada kla'atu!")
			usr << "<span class='warning'>Your talisman turns into red dust, revealing the surrounding runes.</span>"
			for (var/mob/V in orange(1,usr.loc))
				if(V!=usr)
					V.show_message("<span class='warning'>Red dust emanates from [usr]'s hands for a moment.</span>", 3)
			return
		return
	if(istype(W,/obj/effect/rune))
		return	fizzle()
	if(istype(W,/obj/item/weapon/paper/talisman))
		call(/obj/effect/rune/proc/fizzle)()
		return

/////////////////////////////////////////SEVENTEENTH RUNE

/obj/effect/rune/proc/wall()
	usr.say("Khari[pick("'","`")]d! Eske'te tannin!")
	src.density = !src.density
	var/mob/living/user = usr
	user.take_organ_damage(2, 0)
	if(src.density)
		usr << "<span class='warning'>Your blood flows into the rune, and you feel that the very space over the rune thickens.</span>"
	else
		usr << "<span class='warning'>Your blood flows into the rune, and you feel as the rune releases its grasp on space.</span>"
	return

/////////////////////////////////////////EIGHTTEENTH RUNE

/obj/effect/rune/proc/freedom()
	var/mob/living/user = usr
	var/list/mob/living/carbon/cultists = new
	for(var/datum/mind/H in ticker.mode.cult)
		if (istype(H.current,/mob/living/carbon))
			cultists+=H.current
	var/list/mob/living/carbon/users = new
	for(var/mob/living/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			users+=C
	if(users.len>=3)
		var/mob/living/carbon/cultist = input("Choose the one who you want to free", "Followers of Geometer") as null|anything in (cultists - users)
		if(!cultist)
			return fizzle()
		if (cultist == user) //just to be sure.
			return
		if(!(cultist.buckled || \
			cultist.handcuffed || \
			istype(cultist.wear_mask, /obj/item/clothing/mask/muzzle) || \
			(istype(cultist.loc, /obj/structure/closet)&&cultist.loc:welded) || \
			(istype(cultist.loc, /obj/structure/closet/secure_closet)&&cultist.loc:locked) || \
			(istype(cultist.loc, /obj/machinery/dna_scannernew)&&cultist.loc:locked) \
		))
			user << "<span class='warning'>The [cultist] is already free.</span>"
			return
		cultist.buckled = null
		if (cultist.handcuffed)
			cultist.handcuffed.loc = cultist.loc
			cultist.handcuffed = null
			cultist.update_inv_handcuffed()
		if (cultist.legcuffed)
			cultist.legcuffed.loc = cultist.loc
			cultist.legcuffed = null
			cultist.update_inv_legcuffed()
		if (istype(cultist.wear_mask, /obj/item/clothing/mask/muzzle))
			cultist.u_equip(cultist.wear_mask)
		if(istype(cultist.loc, /obj/structure/closet)&&cultist.loc:welded)
			cultist.loc:welded = 0
		if(istype(cultist.loc, /obj/structure/closet/secure_closet)&&cultist.loc:locked)
			cultist.loc:locked = 0
		if(istype(cultist.loc, /obj/machinery/dna_scannernew)&&cultist.loc:locked)
			cultist.loc:locked = 0
		for(var/mob/living/carbon/C in users)
			user.take_overall_damage(10, 0)
			C.say("Khari[pick("'","`")]d! Gual'te nikka!")
		qdel(src)
	return fizzle()

/////////////////////////////////////////NINETEENTH RUNE

/obj/effect/rune/proc/cultsummon()
	var/mob/living/user = usr
	var/list/mob/living/carbon/cultists = new
	for(var/datum/mind/H in ticker.mode.cult)
		if (istype(H.current,/mob/living/carbon))
			cultists+=H.current
	var/list/mob/living/carbon/users = new
	for(var/mob/living/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			users+=C
	if(users.len>=3)
		var/mob/living/carbon/cultist = input("Choose the one who you want to summon", "Followers of Geometer") as null|anything in (cultists - user)
		if(!cultist)
			return fizzle()
		if (cultist == user) //just to be sure.
			return
		if(cultist.buckled || cultist.handcuffed || (!isturf(cultist.loc) && !istype(cultist.loc, /obj/structure/closet)))
			user << "<span class='warning'>You cannot summon the [cultist], for his shackles of blood are strong</span>"
			return fizzle()
		var/turf/T = get_turf(cultist)
		T.invocanimation("rune_teleport")
		cultist.loc = src.loc
		cultist.lying = 1
		cultist.regenerate_icons()
		T << visible_message("<span class='warning'>[cultist] suddenly disappears in a flash of red light!</span>")
		for(var/mob/living/carbon/human/C in orange(1,src))
			if(iscultist(C) && !C.stat)
				C.say("N'ath reth sh'yro eth d[pick("'","`")]rekkathnor!")
				C.take_overall_damage(15, 0)
		user.visible_message("<span class='warning'>The rune disappears with a flash of red light, and in its place now a body lies.</span>", \
		"<span class='warning'>You are blinded by the flash of red light! After you're able to see again, you see that now instead of the rune there's a body.</span>", \
		"<span class='warning'>You hear a pop and smell ozone.</span>")
		qdel(src)
	return fizzle()

/////////////////////////////////////////TWENTIETH RUNES

/obj/effect/rune/proc/deafen()
	var/affected = 0
	for(var/mob/living/carbon/C in range(7,src))
		if (iscultist(C))
			continue
		nullblock = 0
		for(var/turf/T in range(C,1))
			findNullRod(T)
		if(nullblock)
			continue
		C.ear_deaf += 50
		C.show_message("<span class='warning'>The world around you suddenly becomes quiet.</span>", 3)
		affected++
		if(prob(1))
			C.sdisabilities |= DEAF
	if(affected)
		usr.say("Sti[pick("'","`")] kaliedir!")
		usr << "<span class='warning'>The world becomes quiet as the deafening rune dissipates into fine dust.</span>"
		qdel(src)
	else
		return fizzle()

/obj/effect/rune/proc/blind()
	var/affected = 0
	for(var/mob/living/carbon/C in viewers(src))
		if (iscultist(C))
			continue
		nullblock = 0
		for(var/turf/T in range(C,1))
			findNullRod(T)
		if(nullblock)
			continue
		C.eye_blurry += 50
		C.eye_blind += 20
		if(prob(5))
			C.disabilities |= NEARSIGHTED
			if(prob(10))
				C.sdisabilities |= BLIND
		C << "<span class='warning'>Suddenly you see red flash that blinds you.</span>"
		affected++
	if(affected)
		usr.say("Sti[pick("'","`")] kaliesin!")
		usr << "<span class='warning'>The rune flashes, blinding those who not follow the Nar-Sie, and dissipates into fine dust.</span>"
		qdel(src)
	else
		return fizzle()


/obj/effect/rune/proc/bloodboil() //cultists need at least one DANGEROUS rune. Even if they're all stealthy.
/*
			var/list/mob/living/carbon/cultists = new
			for(var/datum/mind/H in ticker.mode.cult)
				if (istype(H.current,/mob/living/carbon))
					cultists+=H.current
*/
	var/culcount = 0 //also, wording for it is old wording for obscure rune, which is now hide-see-blood.
//	var/list/cultboil = list(cultists-usr) //and for this words are destroy-see-blood.
	for(var/mob/living/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			culcount++
	if(culcount>=3)
		for(var/mob/living/carbon/M in viewers(usr))
			if(iscultist(M))
				continue
			nullblock = 0
			for(var/turf/T in range(M,1))
				findNullRod(T)
			if(nullblock)
				continue
			M.take_overall_damage(51,51)
			M << "<span class='warning'>Your blood boils!</span>"
			if(prob(5))
				spawn(5)
					M.gib()
		for(var/obj/effect/rune/R in view(src))
			if(prob(10))
				explosion(R.loc, -1, 0, 1, 5)
		for(var/mob/living/carbon/human/C in orange(1,src))
			if(iscultist(C) && !C.stat)
				C.say("Dedo ol[pick("'","`")]btoh!")
				C.take_overall_damage(15, 0)
		qdel(src)
	else
		return fizzle()
	return

// WIP rune, I'll wait for Rastaf0 to add limited blood.

/obj/effect/rune/proc/burningblood()
	var/culcount = 0
	for(var/mob/living/carbon/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			culcount++
	if(culcount >= 5)
		for(var/obj/effect/rune/R in rune_list)
			if(R.blood_DNA == src.blood_DNA)
				for(var/mob/living/M in orange(2,R))
					M.take_overall_damage(0,15)
					if (R.invisibility>M.see_invisible)
						M << "<span class='warning'>Aargh it burns!</span>"
					else
						M << "<span class='warning'>The rune suddenly ignites, burning you!</span>"
					var/turf/T = get_turf(R)
					T.hotspot_expose(700,125,surfaces=1)
		for(var/obj/effect/decal/cleanable/blood/B in world)
			if(B.blood_DNA == src.blood_DNA)
				for(var/mob/living/M in orange(1,B))
					M.take_overall_damage(0,5)
					M << "<span class='warning'>The blood suddenly ignites, burning you!</span>"
					var/turf/T = get_turf(B)
					T.hotspot_expose(700,125,surfaces=1)
					del(B)
		qdel(src)

//////////             Rune 24 (counting burningblood, which kinda doesnt work yet.)

/obj/effect/rune/proc/runestun(var/mob/living/T as mob)///When invoked as rune, flash and stun everyone around.
	usr.say("Fuu ma[pick("'","`")]jin!")
	for(var/mob/living/L in viewers(src))

		nullblock = 0
		for(var/turf/TU in range(L,1))
			findNullRod(TU)
		if(!nullblock)
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				flick("e_flash", C.flash)
				if(C.stuttering < 1 && (!(M_HULK in C.mutations)))
					C.stuttering = 1
				C.Weaken(1)
				C.Stun(1)
				C.visible_message("<span class='warning'>The rune explodes in a bright flash.</span>")

			else if(issilicon(L))
				var/mob/living/silicon/S = L
				S.Weaken(5)
				S.visible_message("<span class='warning'>BZZZT... The rune has exploded in a bright flash.</span>")
	qdel(src)
	return

/////////////////////////////////////////TWENTY-FIFTH RUNE

/obj/effect/rune/proc/armor()
	var/mob/living/user = usr
	if(!istype(src,/obj/effect/rune))
		usr.whisper("Sa tatha najin")
		if(ishuman(user))
			usr.visible_message("<span class='warning'> In flash of red light, a set of armor appears on [usr]...</span>", \
			"<span class='warning'> You are blinded by the flash of red light! After you're able to see again, you see that you are now wearing a set of armor.</span>")
			user.equip_to_slot_or_del(new /obj/item/clothing/head/culthood/alt(user), slot_head)
			user.equip_to_slot_or_del(new /obj/item/clothing/suit/cultrobes/alt(user), slot_wear_suit)
			user.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult(user), slot_shoes)
			user.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/cultpack(user), slot_back)
			//the above update their overlay icons cache but do not call update_icons()
			//the below calls update_icons() at the end, which will update overlay icons by using the (now updated) cache
			user.put_in_hands(new /obj/item/weapon/melee/cultblade(user))	//put in hands or on floor
		else if(ismonkey(user))
			var/mob/living/carbon/monkey/K = user
			K.visible_message("<span class='warning'> The rune disappears with a flash of red light, [K] now looks like the cutest of all followers of Nar-Sie...</span>", \
			"<span class='warning'> You are blinded by the flash of red light! After you're able to see again, you see that you are now wearing a set of armor. Might not offer much protection due to its size though.</span>")
			if(!istype(K.uniform, /obj/item/clothing/monkeyclothes/cultrobes))
				var/obj/item/clothing/monkeyclothes/cultrobes/CR = new /obj/item/clothing/monkeyclothes/cultrobes(user.loc)
				K.wearclothes(CR)
			if(!istype(K.hat, /obj/item/clothing/head/culthood/alt))
				var/obj/item/clothing/head/culthood/alt/CH = new /obj/item/clothing/head/culthood/alt(user.loc)
				K.wearhat(CH)
			K.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/cultpack(K), slot_back)
			K.put_in_hands(new /obj/item/weapon/melee/cultblade(K))
		return
	else
		usr.say("Sa tatha najin")
		for(var/mob/living/M in src.loc)
			if(iscultist(M))
				if(ishuman(M))
					M.visible_message("<span class='warning'> In flash of red light, and a set of armor appears on [M]...</span>", \
					"<span class='warning'> You are blinded by the flash of red light! After you're able to see again, you see that you are now wearing a set of armor.</span>")
					M.equip_to_slot_or_del(new /obj/item/clothing/head/culthood/alt(M), slot_head)
					M.equip_to_slot_or_del(new /obj/item/clothing/suit/cultrobes/alt(M), slot_wear_suit)
					M.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult(M), slot_shoes)
					M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/cultpack(M), slot_back)
					M.put_in_hands(new /obj/item/weapon/melee/cultblade(M))
				else if(ismonkey(M))
					var/mob/living/carbon/monkey/K = M
					K.visible_message("<span class='warning'> The rune disappears with a flash of red light, [K] now looks like the cutest of all followers of Nar-Sie...</span>", \
					"<span class='warning'> You are blinded by the flash of red light! After you're able to see again, you see that you are now wearing a set of armor. Might not offer much protection due to its size though.</span>")
					var/obj/item/clothing/monkeyclothes/cultrobes/CR = new /obj/item/clothing/monkeyclothes/cultrobes(loc)
					K.wearclothes(CR)
					var/obj/item/clothing/head/culthood/alt/CH = new /obj/item/clothing/head/culthood/alt(loc)
					K.wearhat(CH)
					K.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/cultpack(K), slot_back)
					K.put_in_hands(new /obj/item/weapon/melee/cultblade(K))
				else if(isconstruct(M))
					var/construct_class
					if(universe.name == "Hell Rising")
						var/list/construct_types = list("Artificer", "Wraith", "Juggernaut", "Harvester")
						construct_class = input("Please choose which type of construct you wish [M] to become.", "Construct Transformation") in construct_types
						switch(construct_class)
							if("Juggernaut")
								var/mob/living/simple_animal/construct/armoured/C = new /mob/living/simple_animal/construct/armoured (get_turf(src.loc))
								M.mind.transfer_to(C)
								del(M)
								C << "<B>You are now a Juggernaut. Though slow, your shell can withstand extreme punishment, create temporary walls and even deflect energy weapons, and rip apart enemies and walls alike.</B>"
								ticker.mode.update_cult_icons_added(C.mind)
							if("Wraith")
								var/mob/living/simple_animal/construct/wraith/C = new /mob/living/simple_animal/construct/wraith (get_turf(src.loc))
								M.mind.transfer_to(C)
								del(M)
								C << "<B>You are a now Wraith. Though relatively fragile, you are fast, deadly, and even able to phase through walls.</B>"
								ticker.mode.update_cult_icons_added(C.mind)
							if("Artificer")
								var/mob/living/simple_animal/construct/builder/C = new /mob/living/simple_animal/construct/builder (get_turf(src.loc))
								M.mind.transfer_to(C)
								del(M)
								C << "<B>You are now an Artificer. You are incredibly weak and fragile, but you are able to construct new floors and walls, to break some walls apart, to repair allied constructs (by clicking on them), </B><I>and most important of all create new constructs</I><B> (Use your Artificer spell to summon a new construct shell and Summon Soulstone to create a new soulstone).</B>"
								ticker.mode.update_cult_icons_added(C.mind)
							if("Harvester")
								var/mob/living/simple_animal/construct/harvester/C = new /mob/living/simple_animal/construct/harvester (get_turf(src.loc))
								M.mind.transfer_to(C)
								del(M)
								C << "<B>You are now an Harvester. You are as fast and powerful as Wraiths, but twice as durable.<br>No living (or dead) creature can hide from your eyes, and no door or wall shall place itself between you and your victims.<br>Your role consists of neutralizing any non-cultist living being in the area and transport them to Nar-Sie. To do so, place yourself above an incapacited target and use your \"Harvest\" spell."
								ticker.mode.update_cult_icons_added(C.mind)
					else
						var/list/construct_types = list("Artificer", "Wraith", "Juggernaut")
						construct_class = input("Please choose which type of construct you wish [M] to become.", "Construct Transformation") in construct_types
						switch(construct_class)
							if("Juggernaut")
								var/mob/living/simple_animal/construct/armoured/C = new /mob/living/simple_animal/construct/armoured (get_turf(src.loc))
								M.mind.transfer_to(C)
								del(M)
								C << "<B>You are now a Juggernaut. Though slow, your shell can withstand extreme punishment, create temporary walls and even deflect energy weapons, and rip apart enemies and walls alike.</B>"
								ticker.mode.update_cult_icons_added(C.mind)
							if("Wraith")
								var/mob/living/simple_animal/construct/wraith/C = new /mob/living/simple_animal/construct/wraith (get_turf(src.loc))
								M.mind.transfer_to(C)
								del(M)
								C << "<B>You are a now Wraith. Though relatively fragile, you are fast, deadly, and even able to phase through walls.</B>"
								ticker.mode.update_cult_icons_added(C.mind)
							if("Artificer")
								var/mob/living/simple_animal/construct/builder/C = new /mob/living/simple_animal/construct/builder (get_turf(src.loc))
								M.mind.transfer_to(C)
								del(M)
								C << "<B>You are now an Artificer. You are incredibly weak and fragile, but you are able to construct new floors and walls, to break some walls apart, to repair allied constructs (by clicking on them), </B><I>and most important of all create new constructs</I><B> (Use your Artificer spell to summon a new construct shell and Summon Soulstone to create a new soulstone).</B>"
								ticker.mode.update_cult_icons_added(C.mind)
				del(src)
				return
			else
				usr << "<span class='warning'>Only the followers of Nar-Sie may be given their armor.</span>"
				M << "<span class='warning'>Only the followers of Nar-Sie may be given their armor.</span>"
	user << "<span class='note'> You have to be standing on top of the rune.</span>"
	return