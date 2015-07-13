//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32


var/wordtravel = null
var/wordself = null
var/wordsee = null
var/wordhell = null
var/wordblood = null
var/wordjoin = null
var/wordtech = null
var/worddestr = null
var/wordother = null
//var/wordhear = null
//var/wordfree = null
var/wordhide = null
var/runedec = 0
var/engwords = list("travel", "blood", "join", "hell", "destroy", "technology", "self", "see", "other", "hide")

/client/proc/check_words() // -- Urist
	set category = "Special Verbs"
	set name = "Check Rune Words"
	set desc = "Check the rune-word meaning"
	if(!wordtravel)
		runerandom()
	usr << "[wordtravel] is travel, [wordblood] is blood, [wordjoin] is join, [wordhell] is Hell, [worddestr] is destroy, [wordtech] is technology, [wordself] is self, [wordsee] is see, [wordother] is other, [wordhide] is hide."

/mob/proc/cult_add_comm()
	verbs += /mob/living/proc/cult_innate_comm

/mob/living/proc/cult_innate_comm()
	set category = "Cultist"
	set name = "Communicate"

	if(!iscultist(usr))		//they shouldn't have this verb, but just to be sure...
		return

	if(usr.incapacitated())
		return	//dead men tell no tales

	var/input = stripped_input(usr, "Please choose a message to tell to the other acolytes.", "Voice of Blood", "")
	if(!input)					// TO-DO: Add some kind of filter to corrupt the inputted text
		return

	if(ishuman(usr) || ismonkey(usr))	//Damage only applies to humans and monkeys, to allow constructs to communicate
		usr.visible_message("<span class='warning'>[usr.name] starts clawing at \his arms with \his fingernails!</span>", "<span class='warning'>You begin slicing open your arms with your fingers!</span>")
		apply_damage(10,BRUTE, "l_arm")
		apply_damage(10,BRUTE, "r_arm")
		sleep(50)
		if(usr.incapacitated())
			return	//Hard to drawn intrinsic symbols when you're bleeding out in your cell.
		var/turf/location = loc
		if(istype(location, /turf/simulated))	// tearing your arms apart is going to spill a bit of blood, in fact thats the idea
			location.add_blood(usr)				// TO-DO change this to a badly drawn rune
		apply_damage(10,BRUTE, "l_arm")		// does a metric fuck ton of damage because this meant to be an emergency method of communication.
		apply_damage(10,BRUTE, "r_arm")
		if(usr.incapacitated())
			return
		usr.visible_message("<span class='warning'>[usr.name] paints strange symbols with their own blood.</span>", "<span class='warning'>You paint a messy rune with your own blood.</span>")
		sleep(20)

	cultist_commune(usr, 0, 1, input)
	return


/proc/runerandom() //randomizes word meaning
	var/list/runewords=list("ire","ego","nahlizet","certum","veri","jatkaa","mgar","balaq", "karazet", "geeri") ///"orkan" and "allaq" removed.
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
//	wordhear=pick(runewords)
//	runewords-=wordhear
//	wordfree=pick(runewords)
//	runewords-=wordfree
	wordhide=pick(runewords)
	runewords-=wordhide


/obj/effect/rune
	desc = "A strange collection of symbols drawn in blood."
	anchored = 1
	icon = 'icons/obj/rune.dmi'
	icon_state = "1"
	unacidable = 1
	layer = TURF_LAYER


	var/word1
	var/word2
	var/word3
// Places these combos are mentioned: this file - twice in the rune code, once in imbued tome, once in tome's HTML runes.dm - in the imbue rune code. If you change a combination - dont forget to change it everywhere.

// travel self [word] - Teleport to random [rune with word destination matching]
// travel other [word] - Portal to rune with word destination matching - kinda doesnt work. At least the icon. No idea why.
// see blood Hell - Create a new tome
// join blood self - Incorporate person over the rune into the group
// Hell join self - Summon TERROR
// destroy see technology - EMP rune
// travel blood self - Drain blood
// see Hell join - See invisible
// blood join Hell - Raise dead

// hide see blood - Hide nearby runes
// blood see hide - Reveal nearby runes  - The point of this rune is that its reversed obscure rune. So you always know the words to reveal the rune once oyu have obscured it.

// Hell travel self - Leave your body and ghost around
// blood see travel - Manifest a ghost into a mortal body
// Hell tech join - Imbue a rune into a talisman
// Hell blood join - Sacrifice rune
// destroy travel self - Wall rune
// join other self - Summon cultist rune
// travel technology other - Freeing rune    //    other blood travel was freedom join other

// hide other see - Deafening rune     //     was destroy see hear
// destroy see other - Blinding rune
// destroy see blood - BLOOD BOIL

// self other technology - Communication rune  //was other hear blood
// join hide technology - stun rune. Rune color: bright pink.
/obj/effect/rune/New()
	..()
	var/image/blood = image(loc = src)
	blood.override = 1
	for(var/mob/living/silicon/ai/AI in player_list)
		AI.client.images += blood

/obj/effect/rune/examine(mob/user)
	..()
	if(iscultist(user))
		user << "This spell circle reads: <i>[word1] [word2] [word3]</i>."



/obj/effect/rune/attackby(I as obj, user as mob, params)
	if(istype(I, /obj/item/weapon/tome) && iscultist(user))
		user << "<span class='notice'>You retrace your steps, carefully undoing the lines of the rune.</span>"
		qdel(src)
		return
	else if(istype(I, /obj/item/weapon/nullrod))
		user << "<span class='notice'>You disrupt the vile magic with the deadening field of the null rod!</span>"
		qdel(src)
		return
	return


/obj/effect/rune/attack_hand(mob/living/user as mob)		// OH GOD this is horrible
	if(!iscultist(user))
		user << "<span class='warning'>You can't mouth the arcane scratchings without fumbling over them!</span>"
		return
	var/message = "<span class='warning'>You are unable to speak the words of the rune!</span>"
	if(!user.can_speak(message) && (user.mind && !user.mind.miming))
		user << message
		return
	if(!word1 || !word2 || !word3 || prob(user.getBrainLoss()))
		return fizzle(user)
	if(word1 == wordtravel && word2 == wordself)
		return teleport(src.word3)
	if(word1 == wordsee && word2 == wordblood && word3 == wordhell)
		return tomesummon()
	if(word1 == wordhell && word2 == worddestr && word3 == wordother)
		return armor()
	if(word1 == wordjoin && word2 == wordblood && word3 == wordself)
		return convert()
	if(word1 == wordhell && word2 == wordjoin && word3 == wordself)
		return tearreality()
	if(word1 == worddestr && word2 == wordsee && word3 == wordtech)
		return emp(src.loc,3)
	if(word1 == wordtravel && word2 == wordblood && word3 == wordself)
		return drain()
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
	if(word1 == wordblood && word2 == wordsee && word3 == wordhide)
		return revealrunes(src)
	if(word1 == worddestr && word2 == wordtravel && word3 == wordself)
		return wall()
	if(word1 == wordtravel && word2 == wordtech && word3 == wordother)
		return freedom()
	if(word1 == wordjoin && word2 == wordother && word3 == wordself)
		return cultsummon()
	if(word1 == wordhide && word2 == wordother && word3 == wordsee)
		return deafen()
	if(word1 == worddestr && word2 == wordsee && word3 == wordother)
		return blind()
	if(word1 == worddestr && word2 == wordsee && word3 == wordblood)
		return bloodboil()
	if(word1 == wordself && word2 == wordother && word3 == wordtech)
		return communicate()
	if(word1 == wordtravel && word2 == wordother)
		return itemport(src.word3)
	if(word1 == wordjoin && word2 == wordhide && word3 == wordtech)
		return runestun()
	if(word1 == wordtravel && word2 == wordhell && word3 == wordtech)
		return summon_shell()
	else
		user.take_overall_damage(30, 0)
		user << "<span class='danger'>You feel the life draining from you, as if Lord Nar-Sie is displeased with you.</span>"
		return fizzle(user)


/obj/effect/rune/proc/fizzle(var/mob/living/cultist = null)
	var/gibberish = pick("B'ADMINES SP'WNIN SH'T","IC'IN O'OC","RO'SHA'M I'SA GRI'FF'N ME'AI","TOX'IN'S O'NM FI'RAH","IA BL'AME TOX'IN'S","FIR'A NON'AN RE'SONA","A'OI I'RS ROUA'GE","LE'OAN JU'STA SP'A'C Z'EE SH'EF","IA PT'WOBEA'RD, IA A'DMI'NEH'LP")

	if(cultist)
		if(istype(src,/obj/effect/rune))
			cultist.say(gibberish)
		else
			cultist.whisper(gibberish)
	visible_message("<span class='danger'>The markings pulse with a small burst of light, then fall dark.</span>", 3, "<span class='italics'>You hear a faint fizzle.</span>", 2)
	return

/obj/effect/rune/proc/check_icon()
	src.color = rgb(255, 0, 0)
	if(word1 == wordtravel && word2 == wordself)
		icon_state = "2"
		src.color = rgb(0, 0, 255)
		return
	if(word1 == wordjoin && word2 == wordblood && word3 == wordself)
		icon_state = "3"
		return
	if(word1 == wordhell && word2 == wordjoin && word3 == wordself)
		icon_state = "4"
		return
	if(word1 == wordsee && word2 == wordblood && word3 == wordhell)
		icon_state = "5"
		src.color = rgb(0, 0 , 255)
		return
	if(word1 == worddestr && word2 == wordsee && word3 == wordtech)
		icon_state = "5"
		return
	if(word1 == wordtravel && word2 == wordblood && word3 == wordself)
		icon_state = "2"
		return
	if(word1 == wordsee && word2 == wordhell && word3 == wordjoin)
		icon_state = "4"
		src.color = rgb(0, 0 , 255)
		return
	if(word1 == wordblood && word2 == wordjoin && word3 == wordhell)
		icon_state = "1"
		return
	if(word1 == wordhide && word2 == wordsee && word3 == wordblood)
		icon_state = "1"
		src.color = rgb(0, 0 , 255)
		return
	if(word1 == wordhell && word2 == wordtravel && word3 == wordself)
		icon_state = "6"
		src.color = rgb(0, 0 , 255)
		return
	if(word1 == wordblood && word2 == wordsee && word3 == wordtravel)
		icon_state = "6"
		return
	if(word1 == wordhell && word2 == wordtech && word3 == wordjoin)
		icon_state = "3"
		src.color = rgb(0, 0 , 255)
		return
	if(word1 == wordhell && word2 == wordblood && word3 == wordjoin)
		icon_state = "[rand(1,6)]"
		src.color = rgb(255, 255, 255)
		return
	if(word1 == wordblood && word2 == wordsee && word3 == wordhide)
		icon_state = "4"
		src.color = rgb(255, 255, 255)
		return
	if(word1 == worddestr && word2 == wordtravel && word3 == wordself)
		icon_state = "1"
		src.color = rgb(255, 0, 0)
		return
	if(word1 == wordtravel && word2 == wordtech && word3 == wordother)
		icon_state = "4"
		src.color = rgb(255, 0, 255)
		return
	if(word1 == wordjoin && word2 == wordother && word3 == wordself)
		icon_state = "2"
		src.color = rgb(0, 255, 0)
		return
	if(word1 == wordhide && word2 == wordother && word3 == wordsee)
		icon_state = "4"
		src.color = rgb(0, 255, 0)
		return
	if(word1 == worddestr && word2 == wordsee && word3 == wordother)
		icon_state = "4"
		src.color = rgb(0, 0, 255)
		return
	if(word1 == worddestr && word2 == wordsee && word3 == wordblood)
		icon_state = "4"
		src.color = rgb(255, 0, 0)
		return
	if(word1 == wordself && word2 == wordother && word3 == wordtech)
		icon_state = "3"
		src.color = rgb(200, 0, 0)
		return
	if(word1 == wordtravel && word2 == wordother)
		icon_state = "1"
		src.color = rgb(200, 0, 0)
		return
	if(word1 == wordjoin && word2 == wordhide && word3 == wordtech)
		icon_state = "2"
		src.color = rgb(100, 0, 100)
		return
	icon_state="[rand(1,6)]" //random shape and color for dummy runes
	src.color = rgb(rand(1,255),rand(1,255),rand(1,255))


/obj/item/weapon/tome
	name = "arcane tome"
	desc = "An old, dusty tome with frayed edges and a sinister looking cover."
	icon_state ="tome"
	throw_speed = 2
	throw_range = 5
	w_class = 2.0
	var/notedat = ""
	var/tomedat = ""
	var/list/words = list("ire" = "ire", "ego" = "ego", "nahlizet" = "nahlizet", "certum" = "certum", "veri" = "veri", "jatkaa" = "jatkaa", "balaq" = "balaq", "mgar" = "mgar", "karazet" = "karazet", "geeri" = "geeri")


	tomedat = {"<html>
				<head>
				<style>
				h1 {font-size: 25px; margin: 15px 0px 5px;}
				h2 {font-size: 20px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<h1>The scriptures of Nar-Sie, The One Who Sees, The Geometer of Blood.</h1>

				<i>The book is written in an unknown dialect, there are lots of pictures of various complex geometric shapes. You find some notes in english that give you basic understanding of the many runes written in the book. The notes give you an understanding what the words for the runes should be. However, you do not know how to write all these words in this dialect.</i><br>
				<i>Below is the summary of the runes.</i> <br>

				<h2>Contents</h2>
				<p>
				<b>Teleport self: </b>Travel Self (word)<br>
				<b>Teleport other: </b>Travel Other (word)<br>
				<b>Summon new tome: </b>See Blood Hell<br>
				<b>Convert a person: </b>Join Blood Self<br>
				<b>Summon Nar-Sie: </b>Hell Join Self<br>
				<b>Disable technology: </b>Destroy See Technology<br>
				<b>Drain blood: </b>Travel Blood Self<br>
				<b>Raise dead: </b>Blood Join Hell<br>
				<b>Hide runes: </b>Hide See Blood<br>
				<b>Reveal hidden runes: </b>Blood See Hide<br>
				<b>Leave your body: </b>Hell travel self<br>
				<b>Ghost Manifest: </b>Blood See Travel<br>
				<b>Imbue a talisman: </b>Hell Technology Join<br>
				<b>Sacrifice: </b>Hell Blood Join<br>
				<b>Create a wall: </b>Destroy Travel Self<br>
				<b>Summon cultist: </b>Join Other Self<br>
				<b>Free a cultist: </b>Travel technology other<br>
				<b>Deafen: </b>Hide Other See<br>
				<b>Blind: </b>Destroy See Other<br>
				<b>Blood Boil: </b>Destroy See Blood<br>
				<b>Communicate: </b>Self Other Technology<br>
				<b>Stun: </b>Join Hide Technology<br>
				<b>Summon Cultist Armor: </b>Hell Destroy Other<br>
				<b>See Invisible: </b>See Hell Join<br>
				</p>
				<h2>Rune Descriptions</h2>
				<h3>Teleport self</h3>
				Teleport rune is a special rune, as it only needs two words, with the third word being destination. Basically, when you have two runes with the same destination, invoking one will teleport you to the other one. If there are more than 2 runes, you will be teleported to a random one. Runes with different third words will create separate networks. You can imbue this rune into a talisman, giving you a great escape mechanism.<br>
				<h3>Teleport other</h3>
				Teleport other allows for teleportation for any movable object to another rune with the same third word. <br>
				<h3>Summon new tome</h3>
				Invoking this rune summons a new arcane tome.
				<h3>Convert a person</h3>
				This rune opens target's mind to the realm of Nar-Sie, which usually results in this person joining the cult. However, some people (mostly the ones who posess high authority) have strong enough will to stay true to their old ideals. <br>
				<h3>Summon Nar-Sie</h3>
				The ultimate rune. It summons the Avatar of Nar-Sie himself, tearing a huge hole in reality and consuming everything around it. Summoning it is the final goal of any cult.<br>
				<h3>Disable Technology</h3>
				Invoking this rune creates a strong electromagnetic pulse in a small radius, making it basically analogic to an EMP grenade. You can imbue this rune into a talisman, making it a decent defensive item.<br>
				<h3>Drain Blood</h3>
				This rune instantly heals you of some brute damage at the expense of a person placed on top of the rune. Whenever you invoke a drain rune, ALL drain runes on the station are activated, draining blood from anyone located on top of those runes. This includes yourself, though the blood you drain from yourself just comes back to you. This might help you identify this rune when studying words. One drain gives up to 25HP per each victim, but you can repeat it if you need more. Draining only works on living people, so you might need to recharge your "Battery" once its empty. Drinking too much blood at once might cause blood hunger.<br>
				<h3>Raise Dead</h3>
				This rune allows for the resurrection of any dead person. You will need a dead human body and a living human sacrifice. Make 2 raise dead runes. Put a living non-braindead human on top of one, and a dead body on the other one. When you invoke the rune, the life force of the living human will be transferred into the dead body, allowing a ghost standing on top of the dead body to enter it, instantly and fully healing it. Use other runes to ensure there is a ghost ready to be resurrected.<br>
				<h3>Hide runes</h3>
				This rune makes all nearby runes completely invisible. They are still there and will work if activated somehow, but you cannot invoke them directly if you do not see them.<br>
				<h3>Reveal runes</h3>
				This rune is made to reverse the process of hiding a rune. It reveals all hidden runes in a rather large area around it.
				<h3>Leave your body</h3>
				This rune gently rips your soul out of your body, leaving it intact. You can observe the surroundings as a ghost as well as communicate with other ghosts. Your body takes damage while you are there, so ensure your journey is not too long, or you might never come back.<br>
				<h3>Manifest a ghost</h3>
				Unlike the Raise Dead rune, this rune does not require any special preparations or vessels. Instead of using full lifeforce of a sacrifice, it will drain YOUR lifeforce. Stand on the rune and invoke it. If theres a ghost standing over the rune, it will materialise, and will live as long as you dont move off the rune or die. You can put a paper with a name on the rune to make the new body look like that person.<br>
				<h3>Imbue a talisman</h3>
				This rune allows you to imbue the magic of some runes into paper talismans. Create an imbue rune, then an appropriate rune beside it. Put an empty piece of paper on the imbue rune and invoke it. You will now have a one-use talisman with the power of the target rune. Using a talisman drains some health, so be careful with it. You can imbue a talisman with power of the following runes: summon tome, reveal, conceal, teleport, tisable technology, communicate, deafen, blind and stun.<br>
				<h3>Sacrifice</h3>
				Sacrifice rune allows you to sacrifice a living thing or a body to the Geometer of Blood. Monkeys and dead humans are the most basic sacrifices, they might or might not be enough to gain His favor. A living human is what a real sacrifice should be, however, you will need 3 people chanting the invocation to sacrifice a living person.
				<h3>Create a wall</h3>
				Invoking this rune solidifies the air above it, creating an an invisible wall. To remove the wall, simply invoke the rune again.
				<h3>Summon cultist</h3>
				This rune allows you to summon a fellow cultist to your location. The target cultist must be unhandcuffed ant not buckled to anything. You also need to have 3 people chanting at the rune to successfully invoke it. Invoking it takes heavy strain on the bodies of all chanting cultists.<br>
				<h3>Free a cultist</h3>
				This rune unhandcuffs and unbuckles any cultist of your choice, no matter where he is. Invoking it takes heavy strain on the bodies of all chanting cultists.<br>
				<h3>Deafen</h3>
				This rune temporarily deafens all non-cultists around you.<br>
				<h3>Blind</h3>
				This rune temporarily blinds all non-cultists around you. Very robust. Use together with the deafen rune to leave your enemies completely helpless.<br>
				<h3>Blood boil</h3>
				This rune boils the blood all non-cultists in visible range. The damage is enough to instantly critically hurt any person. You need 3 cultists invoking the rune for it to work. This rune is unreliable and may cause unpredicted effect when invoked. It also drains significant amount of your health when successfully invoked.<br>
				<h3>Communicate</h3>
				Invoking this rune allows you to relay a message to all cultists on the station and nearby space objects.
				<h3>Stun</h3>
				Unlike other runes, this ons is supposed to be used in talisman form. When invoked directly, it simply releases some dark energy, briefly stunning everyone around. When imbued into a talisman, you can force all of its energy into one person, stunning him so hard he cant even speak. However, effect wears off rather fast.<br>
				<h3>Equip Armor</h3>
				When this rune is invoked, either from a rune or a talisman, it will equip the user with the armor of the followers of Nar-Sie. To use this rune to its fullest extent, make sure you are not wearing any form of headgear, armor, gloves or shoes, and make sure you are not holding anything in your hands.<br>
				<h3>See Invisible</h3>
				When invoked when standing on it, this rune allows the user to see the the world beyond as long as he does not move.<br>
				</body>
				</html>
				"}


/obj/item/weapon/tome/Topic(href,href_list[])
	if (src.loc == usr)
		var/number = text2num(href_list["number"])
		if (usr.stat|| usr.restrained())
			return
		switch(href_list["action"])
			if("clear")
				words[words[number]] = words[number]
			if("read")
				if(usr.get_active_hand() != src)
					return
				usr << browse("[tomedat]", "window=Arcane Tome")
				return
			if("change")
				words[words[number]] = input("Enter the translation for [words[number]]", "Word notes") in engwords
				for (var/entry in words)
					if ((words[entry] == words[words[number]]) && (entry != words[number]))
						words[entry] = entry
		notedat = {"
					<br><b>Word translation notes</b> <br>
					[words[1]] is <a href='byond://?src=\ref[src];number=1;action=change'>[words[words[1]]]</A> <A href='byond://?src=\ref[src];number=1;action=clear'>Clear</A><BR>
					[words[2]] is <A href='byond://?src=\ref[src];number=2;action=change'>[words[words[2]]]</A> <A href='byond://?src=\ref[src];number=2;action=clear'>Clear</A><BR>
					[words[3]] is <a href='byond://?src=\ref[src];number=3;action=change'>[words[words[3]]]</A> <A href='byond://?src=\ref[src];number=3;action=clear'>Clear</A><BR>
					[words[4]] is <a href='byond://?src=\ref[src];number=4;action=change'>[words[words[4]]]</A> <A href='byond://?src=\ref[src];number=4;action=clear'>Clear</A><BR>
					[words[5]] is <a href='byond://?src=\ref[src];number=5;action=change'>[words[words[5]]]</A> <A href='byond://?src=\ref[src];number=5;action=clear'>Clear</A><BR>
					[words[6]] is <a href='byond://?src=\ref[src];number=6;action=change'>[words[words[6]]]</A> <A href='byond://?src=\ref[src];number=6;action=clear'>Clear</A><BR>
					[words[7]] is <a href='byond://?src=\ref[src];number=7;action=change'>[words[words[7]]]</A> <A href='byond://?src=\ref[src];number=7;action=clear'>Clear</A><BR>
					[words[8]] is <a href='byond://?src=\ref[src];number=8;action=change'>[words[words[8]]]</A> <A href='byond://?src=\ref[src];number=8;action=clear'>Clear</A><BR>
					[words[9]] is <a href='byond://?src=\ref[src];number=9;action=change'>[words[words[9]]]</A> <A href='byond://?src=\ref[src];number=9;action=clear'>Clear</A><BR>
					[words[10]] is <a href='byond://?src=\ref[src];number=10;action=change'>[words[words[10]]]</A> <A href='byond://?src=\ref[src];number=10;action=clear'>Clear</A><BR>
					"}
		usr << browse("[notedat]", "window=notes")
//	call(/obj/item/weapon/tome/proc/edit_notes)()
	else
		usr << browse(null, "window=notes")
		return


//	proc/edit_notes()     FUCK IT. Cant get it to work properly. - K0000
//		world << "its been called! [usr]"
//		notedat = {"
//		<br><b>Word translation notes</b> <br>
//			[words[1]] is <a href='byond://?src=\ref[src];number=1;action=change'>[words[words[1]]]</A> <A href='byond://?src=\ref[src];number=1;action=clear'>Clear</A><BR>
//			[words[2]] is <A href='byond://?src=\ref[src];number=2;action=change'>[words[words[2]]]</A> <A href='byond://?src=\ref[src];number=2;action=clear'>Clear</A><BR>
//			[words[3]] is <a href='byond://?src=\ref[src];number=3;action=change'>[words[words[3]]]</A> <A href='byond://?src=\ref[src];number=3;action=clear'>Clear</A><BR>
//			[words[4]] is <a href='byond://?src=\ref[src];number=4;action=change'>[words[words[4]]]</A> <A href='byond://?src=\ref[src];number=4;action=clear'>Clear</A><BR>
//			[words[5]] is <a href='byond://?src=\ref[src];number=5;action=change'>[words[words[5]]]</A> <A href='byond://?src=\ref[src];number=5;action=clear'>Clear</A><BR>
//			[words[6]] is <a href='byond://?src=\ref[src];number=6;action=change'>[words[words[6]]]</A> <A href='byond://?src=\ref[src];number=6;action=clear'>Clear</A><BR>
//			[words[7]] is <a href='byond://?src=\ref[src];number=7;action=change'>[words[words[7]]]</A> <A href='byond://?src=\ref[src];number=7;action=clear'>Clear</A><BR>
//			[words[8]] is <a href='byond://?src=\ref[src];number=8;action=change'>[words[words[8]]]</A> <A href='byond://?src=\ref[src];number=8;action=clear'>Clear</A><BR>
//			[words[9]] is <a href='byond://?src=\ref[src];number=9;action=change'>[words[words[9]]]</A> <A href='byond://?src=\ref[src];number=9;action=clear'>Clear</A><BR>
//			[words[10]] is <a href='byond://?src=\ref[src];number=10;action=change'>[words[words[10]]]</A> <A href='byond://?src=\ref[src];number=10;action=clear'>Clear</A><BR>
//					"}
//		usr << "whatev"
//		usr << browse(null, "window=tank")

/obj/item/weapon/tome/attack(mob/living/M as mob, mob/living/user as mob)
	if(istype(M,/mob/dead))
		M.invisibility = 0
		user.visible_message( \
			"<span class='danger'>[user] drags the ghost to our plane of reality!</span>", \
			"<span class='danger'>You drag the ghost to our plane of reality!</span>" \
		)
		add_logs(user, M, "smacked", src)
		return
	if(!istype(M))
		return
	if(!iscultist(user))
		return ..()
	if(iscultist(M))
		if(M.reagents && M.reagents.has_reagent("holywater")) //allows cultists to be rescued from the clutches of ordained religion
			user << "<span class='notice'>You remove the taint from [M].</span>"
			var/holy2unholy = M.reagents.get_reagent_amount("holywater")
			M.reagents.del_reagent("holywater")
			M.reagents.add_reagent("unholywater",holy2unholy)
			add_logs(user, M, "smacked", src, " removing the holy water from them")
		return
	M.take_organ_damage(0,rand(5,20)) //really lucky - 5 hits for a crit
	M.visible_message("<span class='danger'>[user] beats [M] with the arcane tome!</span>", \
					"<span class='userdanger'>[user] beats you with the tome, and you feel a searing heat inside you!</span>")
	add_logs(user, M, "smacked", src)


/obj/item/weapon/tome/attack_self(mob/living/user as mob)
	usr = user
	if(!usr.canmove || usr.stat || usr.restrained())
		return

	if(!wordtravel)
		runerandom()
	if(iscultist(user))
		var/C = 0
		for(var/obj/effect/rune/N in world)
			C++
		if (!istype(user.loc,/turf))
			user << "<span class='danger'>You do not have enough space to write a proper rune.</span>"
			return
		switch(alert("You open the tome",,"Commune","Scribe a rune", "Notes")) //Fuck the "Cancel" option. Rewrite the whole tome interface yourself if you want it to work better. And input() is just ugly. - K0000
			if("Cancel")
				return
			if("Commune")
				if(usr.get_active_hand() != src)
					return
				var/input = stripped_input(usr, "Please choose a message to tell to the other acolytes.", "Voice of Blood", "")
				if(!input)
					return
				cultist_commune(user, 1, 0, input)
				return
			if("Notes")
				if(usr.get_active_hand() != src)
					return
				notedat = {"
					<a href='byond://?src=\ref[src];action=read'>Read the Arcane Tome.</A></BR>
					<br><b>Word translation notes</b> <br>
					[words[1]] is <a href='byond://?src=\ref[src];number=1;action=change'>[words[words[1]]]</A> <A href='byond://?src=\ref[src];number=1;action=clear'>Clear</A><BR>
					[words[2]] is <A href='byond://?src=\ref[src];number=2;action=change'>[words[words[2]]]</A> <A href='byond://?src=\ref[src];number=2;action=clear'>Clear</A><BR>
					[words[3]] is <a href='byond://?src=\ref[src];number=3;action=change'>[words[words[3]]]</A> <A href='byond://?src=\ref[src];number=3;action=clear'>Clear</A><BR>
					[words[4]] is <a href='byond://?src=\ref[src];number=4;action=change'>[words[words[4]]]</A> <A href='byond://?src=\ref[src];number=4;action=clear'>Clear</A><BR>
					[words[5]] is <a href='byond://?src=\ref[src];number=5;action=change'>[words[words[5]]]</A> <A href='byond://?src=\ref[src];number=5;action=clear'>Clear</A><BR>
					[words[6]] is <a href='byond://?src=\ref[src];number=6;action=change'>[words[words[6]]]</A> <A href='byond://?src=\ref[src];number=6;action=clear'>Clear</A><BR>
					[words[7]] is <a href='byond://?src=\ref[src];number=7;action=change'>[words[words[7]]]</A> <A href='byond://?src=\ref[src];number=7;action=clear'>Clear</A><BR>
					[words[8]] is <a href='byond://?src=\ref[src];number=8;action=change'>[words[words[8]]]</A> <A href='byond://?src=\ref[src];number=8;action=clear'>Clear</A><BR>
					[words[9]] is <a href='byond://?src=\ref[src];number=9;action=change'>[words[words[9]]]</A> <A href='byond://?src=\ref[src];number=9;action=clear'>Clear</A><BR>
					[words[10]] is <a href='byond://?src=\ref[src];number=10;action=change'>[words[words[10]]]</A> <A href='byond://?src=\ref[src];number=10;action=clear'>Clear</A><BR>
					"}	// whoever screwed the tabbing on this originally is an asshole.
//					call(/obj/item/weapon/tome/proc/edit_notes)()
				user << browse("[notedat]", "window=notes")
				return
			if("Scribe a rune")		//fixed more assbackward tabbing
				if(usr.get_active_hand() != src)
					return
				if (C>=26+runedec+ticker.mode.cult.len) //including the useless rune at the secret room, shouldn't count against the limit of 25 runes - Urist
					alert("The cloth of reality can't take that much of a strain. Remove some runes first!")
					return
				var/list/dictionary = list(
					"convert" = list("join","blood","self"),
					"wall" = list("destroy","travel","self"),
					"blood boil" = list("destroy","see","blood"),
					"blood drain" = list("travel","blood","self"),
					"raise dead" = list("blood","join","hell"),
					"summon narsie" = list("hell","join","self"),
					"communicate" = list("self","other","technology"),
					"emp" = list("destroy","see","technology"),
					"manifest" = list("blood","see","travel"),
					"summon tome" = list("see","blood","hell"),
					"see invisible" = list("see","hell","join"),
					"hide" = list("hide","see","blood"),
					"reveal" = list("blood","see","hide"),
					"astral journey" = list("hell","travel","self"),
					"imbue" = list("hell","technology","join"),
					"sacrifice" = list("hell","blood","join"),
					"summon cultist" = list("join","other","self"),
					"free cultist" = list("travel","technology","other"),
					"deafen" = list("hide","other","see"),
					"blind" = list("destroy","see","other"),
					"stun" = list("join","hide","technology"),
					"armor" = list("hell","destroy","other"),
					"teleport" = list("travel","self"),
					"teleport other" = list("travel","other"),
					"summon shell" = list("travel","hell","technology")
					)


				var/list/scribewords = list("none")

				var/list/english = list()

				for (var/entry in words)
					if (words[entry] != entry)
						english+=list(words[entry] = entry)

				for (var/entry in dictionary)
					var/list/required = dictionary[entry]
					if (length(english&required) == required.len)
						scribewords += entry

				var/chosen_rune = null


				if(usr)
					chosen_rune = input ("Choose a rune to scribe.") in scribewords
					if (!chosen_rune)
						return
					if (chosen_rune == "none")
						user << "<span class='danger'>You decide against scribing a rune, perhaps you should take this time to study your notes.</span>"
						return
					if (chosen_rune == "teleport")
						dictionary[chosen_rune] += input ("Choose a destination word") in english
					if (chosen_rune == "teleport other")
						dictionary[chosen_rune] += input ("Choose a destination word") in english

				if(user.get_active_hand() != src)
					return

				for (var/mob/V in viewers(src))
					V.show_message("<span class='danger'>[user] slices open a finger and begins to chant and paint symbols on the floor.</span>", 3, "<span class='italics'>You hear chanting.</span>", 2)
				user << "<span class='userdanger'>You slice open one of your fingers and begin drawing a rune on the floor whilst chanting the ritual that binds your life essence with the dark arcane energies flowing through the surrounding world.</span>"
				user.take_overall_damage((rand(9)+1)/10) // 0.1 to 1.0 damage
				if(do_after(user, 50, target = user))
					if(usr.get_active_hand() != src)
						return
					var/mob/living/carbon/human/H = user
					var/obj/effect/rune/R = new /obj/effect/rune(user.loc)
					user << "<span class='danger'>You finish drawing the arcane markings of the Geometer.</span>"
					var/list/required = dictionary[chosen_rune]
					R.word1 = english[required[1]]
					R.word2 = english[required[2]]
					R.word3 = english[required[3]]
					R.check_icon()
					R.blood_DNA = list()
					R.blood_DNA[H.dna.unique_enzymes] = H.dna.blood_type
				return
	else
		user << "The book seems full of illegible scribbles. Is this a joke?"
		return

/obj/item/weapon/tome/attackby(obj/item/weapon/tome/T as obj, mob/living/user as mob, params)
	if(istype(T, /obj/item/weapon/tome)) // sanity check to prevent a runtime error
		switch(alert("Copy the runes from your tome?",,"Copy", "Cancel"))
			if("cancel")
				return
	//	var/list/nearby = viewers(1,src) //- Fuck this as well. No clue why this doesnt work. -K0000
	//		if (T.loc != user)
	//			return
	//	for(var/mob/M in nearby)
	//		if(M == user)
		for(var/entry in words)
			words[entry] = T.words[entry]
		user << "<span class='notice'>You copy the translation notes from your tome.</span>"


/obj/item/weapon/tome/examine(mob/user)
	..()
	if(iscultist(user))
		user << "The scriptures of Nar-Sie, The One Who Sees, The Geometer of Blood. Contains the details of every ritual his followers could think of."

/obj/item/weapon/tome/imbued //admin tome, spawns working runes without waiting
	w_class = 2.0
	var/cultistsonly = 1
	attack_self(mob/user as mob)
		if(src.cultistsonly && !iscultist(usr))
			return
		if(!wordtravel)
			runerandom()
		if(user)
			var/r
			if (!istype(user.loc,/turf))
				user << "<span class='danger'>You do not have enough space to write a proper rune.</span>"
			var/list/runes = list("teleport", "itemport", "tome", "armor", "convert", "tear in reality", "emp", "drain", "raise", "obscure", "reveal", "astral journey", "manifest", "imbue talisman", "sacrifice", "wall", "freedom", "cultsummon", "deafen", "blind", "bloodboil", "communicate", "stun", "summon shell")
			r = input("Choose a rune to scribe", "Rune Scribing") in runes //not cancellable.
			var/obj/effect/rune/R = new /obj/effect/rune
			if(istype(user, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = user
				R.blood_DNA = list()
				R.blood_DNA[H.dna.unique_enzymes] = H.dna.blood_type
			switch(r)
				if("teleport")
					var/list/words = list("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri")
					var/beacon
					if(usr)
						beacon = input("Select the last rune", "Rune Scribing") in words
					R.word1=wordtravel
					R.word2=wordself
					R.word3=beacon
					R.loc = user.loc
					R.check_icon()
				if("itemport")
					var/list/words = list("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri")
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
				if("armor")
					R.word1=wordhell
					R.word2=worddestr
					R.word3=wordother
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
					R.word1=wordblood
					R.word2=wordsee
					R.word3=wordhide
					R.loc = user.loc
					R.check_icon()
				if("wall")
					R.word1=worddestr
					R.word2=wordtravel
					R.word3=wordself
					R.loc = user.loc
					R.check_icon()
				if("freedom")
					R.word1=wordtravel
					R.word2=wordtech
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
					R.word1=wordhide
					R.word2=wordother
					R.word3=wordsee
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
					R.word1=wordself
					R.word2=wordother
					R.word3=wordtech
					R.loc = user.loc
					R.check_icon()
				if("stun")
					R.word1=wordjoin
					R.word2=wordhide
					R.word3=wordtech
					R.loc = user.loc
					R.check_icon()
				if("summon shell")
					R.word1=wordtravel
					R.word2=wordhell
					R.word3=wordtech
					R.loc = user.loc
					R.check_icon()
