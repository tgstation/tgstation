

/obj/item/clothing/head/centhat
	name = "\improper Centcom hat"
	icon_state = "centcom"
	desc = "It's good to be emperor."
	item_state = "that"
	flags_inv = 0
	armor = list(melee = 30, bullet = 15, laser = 30, energy = 10, bomb = 25, bio = 0, rad = 0)
	strip_delay = 80

/obj/item/clothing/head/powdered_wig
	name = "powdered wig"
	desc = "A powdered wig."
	icon_state = "pwig"
	item_state = "pwig"

/obj/item/clothing/head/that
	name = "top-hat"
	desc = "It's an amish looking hat."
	icon_state = "tophat"
	item_state = "that"

/obj/item/clothing/head/redcoat
	name = "redcoat's hat"
	icon_state = "redcoat"
	desc = "<i>'I guess it's a redhead.'</i>"

/obj/item/clothing/head/mailman
	name = "mailman's hat"
	icon_state = "mailman"
	desc = "<i>'Right-on-time'</i> mail service head wear."

/obj/item/clothing/head/plaguedoctorhat
	name = "plague doctor's hat"
	desc = "These were once used by plague doctors. They're pretty much useless."
	icon_state = "plaguedoctor"
	permeability_coefficient = 0.01

/obj/item/clothing/head/hasturhood
	name = "hastur's hood"
	desc = "It's <i>unspeakably</i> stylish."
	icon_state = "hasturhood"
	flags = HEADCOVERSEYES|BLOCKHAIR

/obj/item/clothing/head/nursehat
	name = "nurse's hat"
	desc = "It allows quick identification of trained medical personnel."
	icon_state = "nursehat"

/obj/item/clothing/head/syndicatefake
	name = "black space-helmet replica"
	icon_state = "syndicate-helm-black-red"
	item_state = "syndicate-helm-black-red"
	desc = "A plastic replica of a Syndicate agent's space helmet. You'll look just like a real murderous Syndicate agent in this! This is a toy, it is not made for use in space!"
	flags = BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE

/obj/item/clothing/head/that
	name = "sturdy top-hat"
	desc = "It's an amish looking armored top hat."
	icon_state = "tophat"
	item_state = "that"
	flags_inv = 0

/obj/item/clothing/head/cardborg
	name = "cardborg helmet"
	desc = "A helmet made out of a box."
	icon_state = "cardborg_h"
	item_state = "cardborg_h"
	flags = HEADCOVERSEYES
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE

/obj/item/clothing/head/justice
	name = "justice hat"
	desc = "Fight for what's righteous!"
	icon_state = "justicered"
	item_state = "justicered"
	flags = HEADCOVERSEYES|BLOCKHAIR

/obj/item/clothing/head/justice/blue
	icon_state = "justiceblue"
	item_state = "justiceblue"

/obj/item/clothing/head/justice/yellow
	icon_state = "justiceyellow"
	item_state = "justiceyellow"

/obj/item/clothing/head/justice/green
	icon_state = "justicegreen"
	item_state = "justicegreen"

/obj/item/clothing/head/justice/pink
	icon_state = "justicepink"
	item_state = "justicepink"

/obj/item/clothing/head/rabbitears
	name = "rabbit ears"
	desc = "Wearing these makes you looks useless, and only good for your sex appeal."
	icon_state = "bunny"

/obj/item/clothing/head/flatcap
	name = "flat cap"
	desc = "A working man's cap."
	icon_state = "flat_cap"
	item_state = "detective"

/obj/item/clothing/head/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"

/obj/item/clothing/head/hgpiratecap
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "hgpiratecap"
	item_state = "hgpiratecap"

/obj/item/clothing/head/bandana
	name = "pirate bandana"
	desc = "Yarr."
	icon_state = "bandana"
	item_state = "bandana"

/obj/item/clothing/head/bowler
	name = "bowler-hat"
	desc = "Gentleman, elite aboard!"
	icon_state = "bowler"
	item_state = "bowler"

/obj/item/clothing/head/witchwig
	name = "witch costume wig"
	desc = "Eeeee~heheheheheheh!"
	icon_state = "witch"
	item_state = "witch"
	flags = BLOCKHAIR

/obj/item/clothing/head/chicken
	name = "chicken suit head"
	desc = "Bkaw!"
	icon_state = "chickenhead"
	item_state = "chickensuit"
	flags = BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE

/obj/item/clothing/head/griffin
	name = "griffon head"
	desc = "Why not 'eagle head'? Who knows."
	icon_state = "griffinhat"
	item_state = "griffinhat"
	flags = BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE

/obj/item/clothing/head/bearpelt
	name = "bear pelt hat"
	desc = "Fuzzy."
	icon_state = "bearpelt"
	item_state = "bearpelt"

/obj/item/clothing/head/xenos
	name = "xenos helmet"
	icon_state = "xenos"
	item_state = "xenos_helm"
	desc = "A helmet made out of chitinous alien hide."
	flags = BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE

/obj/item/clothing/head/fedora
	name = "fedora"
	icon_state = "fedora"
	item_state = "fedora"
	desc = "A really cool hat if you're a mobster. A really lame hat if you're not."

/obj/item/clothing/head/fedora/suicide_act(mob/user)
	if(user.gender == FEMALE)
		return 0
	var/mob/living/carbon/human/H = user
	user.visible_message("<span class='suicide'>[user] is donning [src]! It looks like they're trying to be nice to girls.</span>")
	user.say("M'lady.")
	sleep(10)
	H.facial_hair_style = "Neckbeard"
	return(BRUTELOSS)

/obj/item/clothing/head/sombrero
	name = "sombrero"
	icon_state = "sombrero"
	item_state = "sombrero"
	desc = "You can practically taste the fiesta."

/obj/item/clothing/head/sombrero/green
	name = "green sombrero"
	icon_state = "greensombrero"
	item_state = "greensombrero"
	desc = "As elegant as a dancing cactus."

/obj/item/clothing/head/sombrero/shamebrero
	name = "shamebrero"
	icon_state = "shamebrero"
	item_state = "shamebrero"
	desc = "Once it's on, it never comes off."
	flags = NODROP

/obj/item/clothing/head/cone
	desc = "This cone is trying to warn you of something!"
	name = "warning cone"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cone"
	item_state = "cone"
	force = 1.0
	throwforce = 3.0
	throw_speed = 2
	throw_range = 5
	w_class = 2.0
	attack_verb = list("warned", "cautioned", "smashed")

/obj/item/clothing/head/santa
	name = "santa hat"
	desc = "On the first day of christmas my employer gave to me!"
	icon_state = "santahatnorm"
	item_state = "that"
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT

/obj/item/clothing/head/jester
	name = "jester hat"
	desc = "A hat with bells, to add some merryness to the suit."
	icon_state = "jester_hat"

/obj/item/clothing/head/bombCollar
	name = "bomb collar"
	desc = "A metal collar with electronic locks designed to be worn around the neck. Can be triggered with a remote detonator."
	icon_state = "bombCollar"
	item_state = "electronic"
	strip_delay = 150
	unacidable = 1 //nice try!
	var/obj/item/device/collarDetonator/linked = null //The linked detonator
	var/locked = 0 //if the collar can be removed

/obj/item/clothing/head/bombCollar/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/screwdriver) && !locked && linked)
		user << "<span class='notice'>You unlink [src] from [linked].</span>"
		linked.linkedCollars.Remove(src)
		linked = null
		return
	..()

/obj/item/clothing/head/bombCollar/proc/detonate()
	audible_message("<span class='boldannounce'>[src] lets out a high-pitched squeal.</span>")
	playsound(src, "sound/machines/defib_charge.ogg", 100, 0)
	spawn(30)
		if(!iscarbon(loc) || !linked)
			audible_message("<span class='danger'>[src] lets out two beeps and falls silent.</span>")
			playsound(src, "sound/machines/defib_failed.ogg", 50, 0)
			return
		var/mob/living/carbon/H = loc
		if(!H || !istype(H))
			audible_message("<span class='danger'>[src] lets out two beeps and falls silent.</span>")
			playsound(src, "sound/machines/defib_failed.ogg", 50, 0)
			return
		explosion(H, -1, -1, 1, 1)
		H.apply_damage(200, BRUTE, "head")
		H.apply_damage(200, BURN, "head")
		if(ishuman(H))
			var/mob/living/carbon/human/HH = H
			HH.facial_hair_style = "Shaved"
			HH.hair_style = "Bald" //Hair burned away
		H.update_hair()
		H.visible_message("<span class='warning'>[H]'s bomb collar explodes!</span>", \
						  "<span class='userdanger'>Your collar explodes!</span>")
		if(flags & NODROP)
			flags -= NODROP
			H.unEquip(src)
		locked = 0
		qdel(src)
		return

/obj/item/device/collarDetonator
	name = "remote collar detonator"
	desc = "A wireless detonator used to control bomb collars."
	icon_state = "locator"
	w_class = 2
	var/list/linkedCollars = list()

/obj/item/device/collarDetonator/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/clothing/head/bombCollar))
		var/obj/item/clothing/head/bombCollar/C = W
		if(C.linked)
			user << "<span class='warning'>[C] is already linked to a detonator!</span>"
			return
		user << "<span class='notice'>You link [C] to [src] and add it to the control interface.</span>"
		var/newName = input(user, "Enter an ID for the collar.", "Collar ID")
		if(!newName)
			C.name = "[initial(C.name)] #[rand(1,99999)]"
		else
			C.name = "[initial(C.name)] - [newName]"
		linkedCollars.Add(C)
		C.linked = src
		return
	..()

/obj/item/device/collarDetonator/attack_self(mob/user as mob)
	if(!ishuman(user))
		user << "<span class='warning'>You aren't sure how to use this...</span>"
		return
	switch(alert("Select an option.","Bomb Collar Control","Locks","Detonation","Status"))
		if("Locks")
			var/choice = input(user, "Select collar to change.", "Locking Control") in linkedCollars
			if(!choice || !user.canUseTopic(src))
				return
			var/obj/item/clothing/head/bombCollar/collarToLock = choice
			if(!collarToLock)
				return
			if(!iscarbon(collarToLock.loc))
				user << "<span class='warning'>That collar isn't being held or worn by anyone.</span>"
				return
			var/mob/living/carbon/C = collarToLock.loc
			if(C.head != collarToLock)
				user << "<span class='warning'>That collar isn't around someone's neck.</span>"
				return
			collarToLock.audible_message("<span class='warning'>[collarToLock] softly clicks.</span>")
			switch(collarToLock.locked)
				if(0)
					collarToLock.locked = 1
					collarToLock.flags |= NODROP
					C << "<span class='boldannounce'>[collarToLock] tightens and locks around your neck.</span>"
					message_admins("[user] locked bomb collar worn by [C]")
				if(1)
					collarToLock.locked = 0
					collarToLock.flags -= NODROP
					C << "<span class='boldannounce'>[collarToLock] loosens around your neck.</span>"
					message_admins("[user] unlocked bomb collar worn by [C]")
			user << "<span class='notice'>You [collarToLock.locked ? "" : "dis"]engage [collarToLock]'s locks.</span>"
			return
		if("Detonation")
			var/choice = input(user, "Select collar to detonate.", "Detonation Control") in linkedCollars
			if(!choice || !user.canUseTopic(src))
				return
			var/obj/item/clothing/head/bombCollar/collarToDetonate = choice
			if(!collarToDetonate)
				return
			if(!iscarbon(collarToDetonate.loc))
				user << "<span class='warning'>That collar isn't being held or worn by anyone.</span>"
				return
			var/mob/living/carbon/C = collarToDetonate.loc
			if(C.head != collarToDetonate)
				user << "<span class='warning'>That collar isn't around someone's neck.</span>"
				return
			switch(alert("Are you sure about this?","Bomb Collar Detonation","Proceed","Exit"))
				if("Proceed")
					if(!collarToDetonate.locked)
						user << "<span class='warning'>That collar isn't locked.</span>"
						return
					user << "<span class='notice'>Detonation signal sent.</span>"
					linkedCollars.Remove(collarToDetonate)
					collarToDetonate.detonate()
					message_admins("[user] detonated bomb collar worn by [C]")
				if("Exit")
					return
			return
		if("Status")
			user << "<span class='notice'><b>Bomb Collar Status Report:</b></span>"
			for(var/obj/item/clothing/head/bombCollar/C in linkedCollars)
				var/turf/T = get_turf(C)
				user << "<b>[C]:</b> [iscarbon(C.loc) ? "Worn by [C.loc], " : ""][get_area(C)], [T.loc.x], [T.loc.y], [C.locked ? "<span class='boldannounce'>Locked</span>" : "<font color='green'><b>Unlocked</b></font>"]"
			return
