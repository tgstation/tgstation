/obj/item/weapon/book/codex_gigas
	name = "Codex Gigas"
	icon_state ="demonomicon"
	throw_speed = 1
	throw_range = 10
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	author = "Forces beyond your comprehension"
	unique = 1
	title = "The codex gigas"
	var/inUse = 0





/obj/item/weapon/book/codex_gigas/attack_self(mob/user)
	if(is_blind(user))
		user << "<span class='warning'>As you are trying to read, you suddenly feel very stupid.</span>"
		return
	if(ismonkey(user))
		user << "<span class='notice'>You skim through the book but can't comprehend any of it.</span>"
		return
	if(inUse)
		user << "<span class='notice'>Someone else is reading it.</span>"
	if(ishuman(user))
		var/mob/living/carbon/human/U = user
		if(U.check_acedia())
			user << "<span class='notice'>None of this matters, why are you reading this?  You put the [title] down.</span>"
			return
		inUse = 1
		var/devilName = copytext(sanitize(input(user, "What infernal being do you wish to research?", "Codex Gigas", null)  as text),1,MAX_MESSAGE_LEN)
		var/speed = 300
		var/correctness = 85
		var/willpower = 98
		if(U.job in list("Librarian")) // the librarian is both faster, and more accurate than normal crew members at research
			speed = 45
			correctness = 100
			willpower = 100
		if(U.job in list("Captain", "Security Officer", "Head of Security", "Detective", "Warden"))
			willpower = 99
		if(U.job in list("Clown")) // WHO GAVE THE CLOWN A DEMONOMICON?  BAD THINGS WILL HAPPEN!
			willpower = 25
		correctness -= U.getBrainLoss() *0.5 //Brain damage makes researching hard.
		speed += U.getBrainLoss() * 3
		user.visible_message("[user] opens [title] and begins reading intently.")
		if(do_after(U, speed, 0, U))
			var/usedName = devilName
			if(!prob(correctness))
				usedName += "x"
			var/datum/devilinfo/devil = devilInfo(usedName, 0)
			user << browse("Information on [devilName]<br><br><br>[lawlorify[LORE][devil.ban]]<br>[lawlorify[LORE][devil.bane]]<br>[lawlorify[LORE][devil.obligation]]<br>[lawlorify[LORE][devil.banish]]", "window=book[window_size != null ? ";size=[window_size]" : ""]")
		inUse = 0
		sleep(10)
		if(!prob(willpower))
			U.influenceSin()
		onclose(user, "book")

