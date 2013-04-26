/obj/item/weapon/dnainjector
	name = "\improper DNA injector"
	desc = "This injects the person with DNA."
	icon = 'icons/obj/items.dmi'
	icon_state = "dnainjector"
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	var/dnatype = null
	var/dna = null
	var/block = null
	var/ue = null

/obj/item/weapon/dnainjector/attack_paw(mob/user)
	return attack_hand(user)


/obj/item/weapon/dnainjector/proc/inject(mob/M, mob/user)
	if(M.stat == DEAD)	//prevents dead people from having their DNA changed
		user << "<span class='notice'>You can't modify [M]'s DNA while \he's dead.</span>"
		return

	if(isliving(M))
		M.radiation += rand(20, 50)

	if(dnatype == "ui")
		if(!block)	//isolated block?
			if(ue)	//unique enzymes? yes
				M.dna.uni_identity = dna
				updateappearance(M, M.dna.uni_identity)
				M.real_name = ue
				M.name = ue
			else	//unique enzymes? no
				M.dna.uni_identity = dna
				updateappearance(M, M.dna.uni_identity)
		else
			M.dna.uni_identity = setblock(M.dna.uni_identity,block, dna, 3)
			updateappearance(M, M.dna.uni_identity)

	else if(dnatype == "se")
		if(!block)	//isolated block?
			M.dna.struc_enzymes = dna
			domutcheck(M, null)
		else
			M.dna.struc_enzymes = setblock(M.dna.struc_enzymes,block, dna, 3)
			domutcheck(M, null, 1)


/obj/item/weapon/dnainjector/attack(mob/target, mob/user)
	if(!ishuman(user))
		user << "<span class='notice'>You don't have the dexterity to do this!</span>"
		return
	if(!ishuman(target) && !ismonkey(target))
		user << "<span class='notice'>You can't inject [target].</span>"
		return

	target.attack_log += text("\[[time_stamp()]\] <font color='orange'>[user.name] ([user.ckey]) attempted to inject with [name]</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [name] to attempt to inject [target.name] ([target.ckey])</font>")
	log_attack("<font color='red'>[user.name] ([user.ckey]) used the [name] to attempt to inject [target.name] ([target.ckey])</font>")

	if(target != user)
		target.visible_message("<span class='danger'>[user] is trying to inject [target] with [src]!</span>", \
								"<span class='userdanger'>[user] is trying to inject [target] with [src]!</span>")

		if(!do_mob(user, target))
			return
		if(!src)
			return

		if(ishuman(target))	//check for monkeying people.
			if(dnatype == "se")
				if(isblockon(getblock(dna, 14,3),14))
					message_admins("[key_name_admin(user)] injected [key_name_admin(target)] with the [name] \red(MONKEY)")

		target.visible_message("<span class='danger'>[user] injects [target] with the syringe with [src]!", \
						"<span class='userdanger'>[user] injects [target] with the syringe with [src]!")

	else
		user << "<span class='notice'>You inject yourself with [src].</span>"

	target.attack_log += "\[[time_stamp()]\] <font color='orange'>Has been injected with [name] by [user.name] ([user.ckey])</font>"
	user.attack_log += "\[[time_stamp()]\] <font color='red'>Used the [name] to inject [target.name] ([target.ckey])</font>"
	log_attack("<font color='red'>[user.name] ([user.ckey]) used the [name] to inject [target.name] ([target.ckey])</font>")

	user.drop_item()
	inject(target, user)	//Now we actually do the heavy lifting.
	loc = null				//garbage collect


/obj/item/weapon/dnainjector/antihulk
	name = "\improper DNA injector (Anti-Hulk)"
	desc = "Cures green skin."
	dnatype = "se"
	dna = "708"
	//block = 2
	New()
		..()
		block = HULKBLOCK

/obj/item/weapon/dnainjector/hulkmut
	name = "\improper DNA injector (Hulk)"
	desc = "This will make you big and strong, but give you a bad skin condition."
	dnatype = "se"
	dna = "FED"
	//block = 2
	New()
		..()
		block = HULKBLOCK

/obj/item/weapon/dnainjector/xraymut
	name = "\improper DNA injector (Xray)"
	desc = "Finally you can see what the Captain does."
	dnatype = "se"
	dna = "FED"
	//block = 8
	New()
		..()
		block = XRAYBLOCK

/obj/item/weapon/dnainjector/antixray
	name = "\improper DNA injector (Anti-Xray)"
	desc = "It will make you see harder."
	dnatype = "se"
	dna = "708"
	//block = 8
	New()
		..()
		block = XRAYBLOCK

/////////////////////////////////////
/obj/item/weapon/dnainjector/antiglasses
	name = "\improper DNA injector (Anti-Glasses)"
	desc = "Toss away those glasses!"
	dnatype = "se"
	dna = "708"
	block = 1

/obj/item/weapon/dnainjector/glassesmut
	name = "\improper DNA injector (Glasses)"
	desc = "Will make you need dorkish glasses."
	dnatype = "se"
	dna = "BD6"
	block = 1

/obj/item/weapon/dnainjector/epimut
	name = "\improper DNA injector (Epi.)"
	desc = "Shake shake shake the room!"
	dnatype = "se"
	dna = "FA0"
	block = 3

/obj/item/weapon/dnainjector/antiepi
	name = "\improper DNA injector (Anti-Epi.)"
	desc = "Will fix you up from shaking the room."
	dnatype = "se"
	dna = "708"
	block = 3
////////////////////////////////////
/obj/item/weapon/dnainjector/anticough
	name = "\improper DNA injector (Anti-Cough)"
	desc = "Will stop that aweful noise."
	dnatype = "se"
	dna = "708"
	block = 5

/obj/item/weapon/dnainjector/coughmut
	name = "\improper DNA injector (Cough)"
	desc = "Will bring forth a sound of horror from your throat."
	dnatype = "se"
	dna = "BD6"
	block = 5

/obj/item/weapon/dnainjector/clumsymut
	name = "\improper DNA injector (Clumsy)"
	desc = "Makes clown minions."
	dnatype = "se"
	dna = "FA0"
	//block = 6
	New()
		..()
		block = CLUMSYBLOCK

/obj/item/weapon/dnainjector/anticlumsy
	name = "\improper DNA injector (Anti-Clumy)"
	desc = "Apply this for Security Clown."
	dnatype = "se"
	dna = "708"
	//block = 6
	New()
		..()
		block = CLUMSYBLOCK

/obj/item/weapon/dnainjector/antitour
	name = "\improper DNA injector (Anti-Tour.)"
	desc = "Will cure tourrets."
	dnatype = "se"
	dna = "708"
	block = 7

/obj/item/weapon/dnainjector/tourmut
	name = "\improper DNA injector (Tour.)"
	desc = "Gives you a nasty case off tourrets."
	dnatype = "se"
	dna = "BD6"
	block = 7

/obj/item/weapon/dnainjector/stuttmut
	name = "\improper DNA injector (Stutt.)"
	desc = "Makes you s-s-stuttterrr"
	dnatype = "se"
	dna = "FA0"
	block = 9

/obj/item/weapon/dnainjector/antistutt
	name = "\improper DNA injector (Anti-Stutt.)"
	desc = "Fixes that speaking impairment."
	dnatype = "se"
	dna = "708"
	block = 9

/obj/item/weapon/dnainjector/antifire
	name = "\improper DNA injector (Anti-Fire)"
	desc = "Cures fire."
	dnatype = "se"
	dna = "708"
	//block = 10
	New()
		..()
		block = FIREBLOCK

/obj/item/weapon/dnainjector/firemut
	name = "\improper DNA injector (Fire)"
	desc = "Gives you fire."
	dnatype = "se"
	dna = "FED"
	//block = 10
	New()
		..()
		block = FIREBLOCK

/obj/item/weapon/dnainjector/blindmut
	name = "\improper DNA injector (Blind)"
	desc = "Makes you not see anything."
	dnatype = "se"
	dna = "FA0"
	//block = 11
	New()
		..()
		block = BLINDBLOCK

/obj/item/weapon/dnainjector/antiblind
	name = "\improper DNA injector (Anti-Blind)"
	desc = "ITS A MIRACLE!!!"
	dnatype = "se"
	dna = "708"
	//block = 11
	New()
		..()
		block = BLINDBLOCK

/obj/item/weapon/dnainjector/antitele
	name = "\improper DNA injector (Anti-Tele.)"
	desc = "Will make you not able to control your mind."
	dnatype = "se"
	dna = "708"
	//block = 12
	New()
		..()
		block = TELEBLOCK

/obj/item/weapon/dnainjector/telemut
	name = "\improper DNA injector (Tele.)"
	desc = "Super brain man!"
	dnatype = "se"
	dna = "FED"
	//block = 12
	New()
		..()
		block = TELEBLOCK

/obj/item/weapon/dnainjector/telemut/darkbundle
	name = "\improper DNA injector"
	desc = "Good. Let the hate flow through you."
/obj/item/weapon/dnainjector/telemut/darkbundle/attack(mob/M, mob/user)
	..()
	domutcheck(M,null) //guarantees that it works instead of getting a dud injector.

/obj/item/weapon/dnainjector/deafmut
	name = "\improper DNA injector (Deaf)"
	desc = "Sorry, what did you say?"
	dnatype = "se"
	dna = "FA0"
	//block = 13
	New()
		..()
		block = DEAFBLOCK

/obj/item/weapon/dnainjector/antideaf
	name = "\improper DNA injector (Anti-Deaf)"
	desc = "Will make you hear once more."
	dnatype = "se"
	dna = "708"
	//block = 13
	New()
		..()
		block = DEAFBLOCK

/obj/item/weapon/dnainjector/h2m
	name = "\improper DNA injector (Human > Monkey)"
	desc = "Will make you a flea bag."
	dnatype = "se"
	dna = "FA0"
	block = 14

/obj/item/weapon/dnainjector/m2h
	name = "\improper DNA injector (Monkey > Human)"
	desc = "Will make you...less hairy."
	dnatype = "se"
	dna = "708"
	block = 14