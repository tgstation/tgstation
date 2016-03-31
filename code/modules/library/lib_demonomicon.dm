/obj/item/weapon/book/demonomicon
	name = "Demonomicon"
	icon_state ="demonomicon"
	throw_speed = 1
	throw_range = 10
	burn_state = LAVA_PROOF
	author = "Forces beyond your comprehension"
	unique = 1
	title = "The Demonomicon"
	var/inUse = 0





/obj/item/weapon/book/demonomicon/attack_self(mob/user)
	if(is_blind(user))
		return
	if(ismonkey(user))
		user << "<span class='notice'>You skim through the book but can't comprehend any of it.</span>"
		return
	if(inUse)
		user << "<span class='notice'>Someone else is reading it.</span>"
	if(ishuman(user))
		var/mob/living/carbon/human/U = user
		if(U.acedia)
			user << "<span class='notice'>None of this matters, why are you reading this?  You put the book down.</span>"
			return
		inUse = 1
		var/demonName = copytext(sanitize(input(user, "What demonic being do you wish to research?", "Demonomicon", null)  as text),1,MAX_MESSAGE_LEN)
		var/speed = 300
		var/correctness = 85
		var/willpower = 80
		if(U.job in list("Librarian")) // the librarian is both faster, and more accurate than normal crew members at research
			speed = 45
			correctness = 100
			willpower = 95
		if(U.job in list("Captain", "Security Officer", "Head of Security", "Detective", "Warden"))
			willpower = 90
		if(U.job in list("Clown")) // WHO GAVE THE CLOWN A DEMONOMICON?  BAD THINGS WILL HAPPEN!
			willpower = 25
		correctness -= U.getBrainLoss() *0.5 //Brain damage makes researching hard.
		speed += U.getBrainLoss() * 3
		user.visible_message("[user] opens [title] and begins reading intently.")
		if(do_after(U, speed, 0, U))
			var/usedName = demonName
			if(!prob(correctness))
				usedName += "x"
			var/datum/demoninfo/demon = demonInfo(usedName, 0)
			user << browse("Information on [demonName]<br><br><br>[demon.banlore()]<br>[demon.banelore()]<br>[demon.obligationlore()]<br>[demon.banishlore()]", "window=book[window_size != null ? ";size=[window_size]" : ""]")
		inUse = 0
		sleep(10)
		if(!prob(willpower))
			U.influenceSin()
		onclose(user, "book")

