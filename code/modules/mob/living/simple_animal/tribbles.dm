var/global/totaltribbles = 0   //global variable so it updates for all tribbles, not just the new one being made.


/mob/living/simple_animal/tribble
	name = "tribble"
	desc = "It's a small furry creature that makes a soft trill."
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "tribble1"
	icon_living = "tribble1"
	icon_dead = "tribble1_dead"
	speak = list("Prrrrr...")
	speak_emote = list("purrs", "trills")
	emote_hear = list("shuffles", "purrs")
	emote_see = list("trundles around", "rolls")
	speak_chance = 10
	turns_per_move = 5
	maxHealth = 10
	health = 10
	meat_type = /obj/item/stack/sheet/fur
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "whacks"
	harm_intent_damage = 5
	var/gestation = 0
	var/maxtribbles = 50     //change this to change the max limit
	wander = 1


/mob/living/simple_animal/tribble/New()
	..()
	var/list/types = list("tribble1","tribble2","tribble3")
	src.icon_state = pick(types)
	src.icon_living = src.icon_state
	src.icon_dead = "[src.icon_state]_dead"
	//random pixel offsets so they cover the floor
	src.pixel_x = rand(-5.0, 5)
	src.pixel_y = rand(-5.0, 5)
	totaltribbles += 1


/mob/living/simple_animal/tribble/attack_hand(mob/user as mob)
	..()
	if(src.stat != DEAD)
		new /obj/item/toy/tribble(user.loc)
		for(var/obj/item/toy/tribble/T in user.loc)
			T.icon_state = src.icon_state
			T.item_state = src.icon_state
			T.gestation = src.gestation
			T.pickup(user)
			user.put_in_active_hand(T)
			del(src)


/mob/living/simple_animal/tribble/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/scalpel))
		user << "<span class='notice'>You try to neuter the tribble, but it's moving too much and you fail!</span>"
	else if(istype(O, /obj/item/weapon/cautery))
		user << "<span class='notice'>You try to un-neuter the tribble, but it's moving too much and you fail!</span>"
	..()


/mob/living/simple_animal/tribble/proc/procreate()
	..()
	if(totaltribbles <= maxtribbles)
		for(var/mob/living/simple_animal/tribble/F in src.loc)
			if(!F || F == src)
				new /mob/living/simple_animal/tribble(src.loc)
				gestation = 0


/mob/living/simple_animal/tribble/Life()
	..()
	if(src.health > 0) //no mostly dead procreation
		if(gestation != null) //neuter check
			if(gestation < 30)
				gestation++
			else if(gestation >= 30)
				if(prob(80))
					src.procreate()


/mob/living/simple_animal/tribble/Die() // Gotta make sure to remove tribbles from the list on death
	..()
	totaltribbles -= 1


//||Item version of the trible ||
/obj/item/toy/tribble
	name = "tribble"
	desc = "It's a small furry creature that makes a soft trill."
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "tribble1"
	item_state = "tribble1"
	var/gestation = 0

/obj/item/toy/tribble/attack_self(mob/user as mob) //hug that tribble (and play a sound if we add one)
	..()
	user << "<span class='notice'>You nuzzle the tribble and it trills softly.</span>"

/obj/item/toy/tribble/dropped(mob/user as mob) //now you can't item form them to get rid of them all so easily
	..()
	new /mob/living/simple_animal/tribble(user.loc)
	for(var/mob/living/simple_animal/tribble/T in user.loc)
		T.icon_state = src.icon_state
		T.icon_living = src.icon_state
		T.icon_dead = "[src.icon_state]_dead"
		T.gestation = src.gestation

	user << "<span class='notice'>The tribble gets up and wanders around.</span>"
	del(src)

/obj/item/toy/tribble/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob) //neutering and un-neutering
	..()
	if(istype(O, /obj/item/weapon/scalpel) && src.gestation != null)
		gestation = null
		user << "<span class='notice'>You neuter the tribble so that it can no longer re-produce.</span>"
	else if (istype(O, /obj/item/weapon/cautery) && src.gestation == null)
		gestation = 0
		user << "<span class='notice'>You fuse some recently cut tubes together, it should be able to reproduce again.</span>"



//|| Tribble Cage - Lovingly lifted from the lamarr-cage ||
/obj/structure/tribble_cage
	name = "Lab Cage"
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "labcage1"
	desc = "A glass lab container for storing interesting creatures."
	density = 1
	anchored = 1
	unacidable = 1//Dissolving the case would also delete tribble
	var/health = 30
	var/occupied = 1
	var/destroyed = 0

/obj/structure/tribble_cage/ex_act(severity)
	switch(severity)
		if (1)
			new /obj/item/weapon/shard( src.loc )
			Break()
			del(src)
		if (2)
			if (prob(50))
				src.health -= 15
				src.healthcheck()
		if (3)
			if (prob(50))
				src.health -= 5
				src.healthcheck()


/obj/structure/tribble_cage/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	src.healthcheck()
	return


/obj/structure/tribble_cage/blob_act()
	if (prob(75))
		new /obj/item/weapon/shard( src.loc )
		Break()
		del(src)


/obj/structure/tribble_cage/meteorhit(obj/O as obj)
		new /obj/item/weapon/shard( src.loc )
		Break()
		del(src)


/obj/structure/tribble_cage/proc/healthcheck()
	if (src.health <= 0)
		if (!( src.destroyed ))
			src.density = 0
			src.destroyed = 1
			new /obj/item/weapon/shard( src.loc )
			playsound(src, "shatter", 70, 1)
			Break()
	else
		playsound(src.loc, 'sound/effects/Glasshit.ogg', 75, 1)
	return

/obj/structure/tribble_cage/update_icon()
	if(src.destroyed)
		src.icon_state = "labcageb[src.occupied]"
	else
		src.icon_state = "labcage[src.occupied]"
	return


/obj/structure/tribble_cage/attackby(obj/item/weapon/W as obj, mob/user as mob)
	src.health -= W.force
	src.healthcheck()
	..()
	return

/obj/structure/tribble_cage/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/tribble_cage/attack_hand(mob/user as mob)
	if (src.destroyed)
		return
	else
		usr << text("\blue You kick the lab cage.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] kicks the lab cage.", usr)
		src.health -= 2
		healthcheck()
		return

/obj/structure/tribble_cage/proc/Break()
	if(occupied)
		new /mob/living/simple_animal/tribble( src.loc )
		occupied = 0
	update_icon()
	return


//||Fur-bricator and Fur Products ||
/obj
	var/f_amt = 0	// registers fur amount as an object variable


/obj/item/stack/sheet/fur //basic fur sheets (very lumpy furry piles of sheets)
	name = "pile of fur"
	desc = "The by-product of tribbles."
	singular_name = "fur piece"
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "sheet-fur"
	origin_tech = "materials=2"
	f_amt = 1000
	max_amount = 50

/obj/item/clothing/ears/earmuffs/tribblemuffs //earmuffs but with tribbles
	name = "earmuffs"
	desc = "Protects your hearing from loud noises, and quiet ones as well."
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "tribblemuffs"
	item_state = "tribblemuffs"
	f_amt = 2000

/obj/item/clothing/gloves/furgloves
	desc = "These gloves are warm and furry."
	name = "fur gloves"
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "furglovesico"
	item_state = "furgloves"
	f_amt = 3000

	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT

/obj/item/clothing/head/furcap
	name = "fur cap"
	desc = "A warm furry cap."
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "furcap"
	item_state = "furcap"
	f_amt = 5000

	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT

/obj/item/clothing/shoes/furboots
	name = "fur boots"
	desc = "Warm, furry boots."
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "furboots"
	item_state = "furboots"
	f_amt = 4000

	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT


var/global/list/furbricator_recipes = list( \
		new /obj/item/stack/sheet/fur(), \
		new /obj/item/clothing/ears/earmuffs/tribblemuffs(), \
		new /obj/item/clothing/gloves/furgloves(), \
		new /obj/item/clothing/head/furcap(), \
		new /obj/item/clothing/shoes/furboots(), \
	)

//placeholder values until I make more clothes
var/global/list/furbricator_recipes_hidden = list( \
		new /obj/item/stack/sheet/fur(), \
		new /obj/item/stack/sheet/fur(), \
		new /obj/item/stack/sheet/fur(), \
	)

//Lovingly lifted from the autolathe code, and tweaked to run on fur.
/obj/machinery/furbricator
	name = "Fur-bricator"
	desc = "It produces items using fur."
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "furbricator"
	density = 1

	var/f_amount = 0.0
	var/max_f_amount = 150000.0
	var/operating = 0.0
	var/opened = 0.0
	anchored = 1.0
	var/list/L = list()
	var/list/LL = list()
	var/hacked = 0
	var/disabled = 0
	var/shocked = 0
	var/list/wires = list()
	var/hack_wire
	var/disable_wire
	var/shock_wire
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 100
	var/busy = 0

	proc
		wires_win(mob/user as mob)
			..()
			var/dat as text
			dat += "Fur-bricator Wires:<BR>"
			for(var/wire in src.wires)
				dat += text("[wire] Wire: <A href='?src=\ref[src];wire=[wire];act=wire'>[src.wires[wire] ? "Mend" : "Cut"]</A> <A href='?src=\ref[src];wire=[wire];act=pulse'>Pulse</A><BR>")

			dat += text("The red light is [src.disabled ? "off" : "on"].<BR>")
			dat += text("The green light is [src.shocked ? "off" : "on"].<BR>")
			dat += text("The blue light is [src.hacked ? "off" : "on"].<BR>")
			user << browse("<HTML><HEAD><TITLE>Fur-bricator Hacking</TITLE></HEAD><BODY>[dat]</BODY></HTML>","window=furbricator_hack")
			onclose(user, "furbricator_hack")

		regular_win(mob/user as mob)
			..()
			var/dat as text
			dat = text("<B>Fur Amount:</B> [src.f_amount] cm<sup>3</sup> (MAX: [max_f_amount])<HR>")
			var/list/objs = list()
			objs += src.L
			if (src.hacked)
				objs += src.LL
			for(var/obj/t in objs)
				var/title = "[t.name] ([t.f_amt] m)"
				if (f_amount<t.f_amt)
					dat += title + "<br>"
					continue
				dat += "<A href='?src=\ref[src];make=\ref[t]'>[title]</A>"
				if (istype(t, /obj/item/stack))
					var/obj/item/stack/S = t
					var/max_multiplier = round(f_amount/S.f_amt)
					if (max_multiplier>1)
						dat += " |"
					if (max_multiplier>10)
						dat += " <A href='?src=\ref[src];make=\ref[t];multiplier=[10]'>x[10]</A>"
					if (max_multiplier>25)
						dat += " <A href='?src=\ref[src];make=\ref[t];multiplier=[25]'>x[25]</A>"
					if (max_multiplier>1)
						dat += " <A href='?src=\ref[src];make=\ref[t];multiplier=[max_multiplier]'>x[max_multiplier]</A>"
				dat += "<br>"
			user << browse("<HTML><HEAD><TITLE>Fur-bricator Control Panel</TITLE></HEAD><BODY><TT>[dat]</TT></BODY></HTML>", "window=furbricator_regular")
			onclose(user, "furbricator_regular")

		shock(mob/user, prb)
			..()
			if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
				return 0
			if(!prob(prb))
				return 0
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, src)
			s.start()
			if (electrocute_mob(user, get_area(src), src, 0.7))
				return 1
			else
				return 0

	interact(mob/user as mob)
		..()
		if(..())
			return
		if (src.shocked)
			src.shock(user,50)
		if (src.opened)
			wires_win(user,50)
			return
		if (src.disabled)
			user << "\red You press the button, but nothing happens."
			return
		regular_win(user)
		return

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		..()
		if (stat)
			return 1
		if (busy)
			user << "\red The Fur-bricator is busy. Please wait for completion of previous operation."
			return 1
		if (istype(O, /obj/item/weapon/screwdriver))
			if (!opened)
				src.opened = 1
				src.icon_state = "furbricator_t"
				user << "You open the maintenance hatch of [src]."
			else
				src.opened = 0
				src.icon_state = "furbricator"
				user << "You close the maintenance hatch of [src]."
			return 1

		if (src.f_amount + O.f_amt > max_f_amount)
			user << "\red The Fur-bricator is full. Please remove fur from the autolathe in order to insert more."
			return 1
		if (O.f_amt == 0)
			user << "\red This object does not contain significant amounts of fur, or cannot be accepted by the Fur-bricator due to size or hazardous materials."
			return 1
	/*
		if (istype(O, /obj/item/weapon/grab) && src.hacked)
			var/obj/item/weapon/grab/G = O
			if (prob(25) && G.affecting)
				G.affecting.gib()
				f_amount += 50000
			return
	*/

		var/amount = 1
		var/obj/item/stack/stack
		var/f_amt = O.f_amt
		if (istype(O, /obj/item/stack))
			stack = O
			amount = stack.amount
			if (f_amt)
				amount = min(amount, round((max_f_amount-src.f_amount)/f_amt))
				flick("furbricator_o",src)//plays metal insertion animation
			stack.use(amount)
		else
			usr.before_take_item(O)
			O.loc = src
		icon_state = "furbricator"
		busy = 1
		use_power(max(1000, (f_amt)*amount/10))
		src.f_amount += f_amt * amount
		user << "You insert [amount] sheet[amount>1 ? "s" : ""] to the autolathe."
		if (O && O.loc == src)
			del(O)
		busy = 0
		src.updateUsrDialog()

	attack_paw(mob/user as mob)
		..()
		return src.attack_hand(user)

	attack_hand(mob/user as mob)
		..()
		user.set_machine(src)
		interact(user)


	Topic(href, href_list)
		..()
		if(..())
			return
		usr.set_machine(src)
		src.add_fingerprint(usr)
		if (!busy)
			if(href_list["make"])
				var/turf/T = get_step(src.loc, get_dir(src,usr))
				var/obj/template = locate(href_list["make"])
				var/multiplier = text2num(href_list["multiplier"])
				if (!multiplier) multiplier = 1
				var/power = max(2000, (template.f_amt)*multiplier/5)
				if(src.f_amount >= template.f_amt*multiplier)
					busy = 1
					use_power(power)
					icon_state = "furbricator"
					flick("furbricator_n",src)
					spawn(16)
						use_power(power)
						spawn(16)
							use_power(power)
							spawn(16)
								src.f_amount -= template.f_amt*multiplier
								if(src.f_amount < 0)
									src.f_amount = 0
								var/obj/new_item = new template.type(T)
								if (multiplier>1)
									var/obj/item/stack/S = new_item
									S.amount = multiplier
								busy = 0
								src.updateUsrDialog()
			if(href_list["act"])
				var/temp_wire = href_list["wire"]
				if(href_list["act"] == "pulse")
					if (!istype(usr.get_active_hand(), /obj/item/device/multitool))
						usr << "You need a multitool!"
					else
						if(src.wires[temp_wire])
							usr << "You can't pulse a cut wire."
						else
							if(src.hack_wire == temp_wire)
								src.hacked = !src.hacked
								spawn(100) src.hacked = !src.hacked
							if(src.disable_wire == temp_wire)
								src.disabled = !src.disabled
								src.shock(usr,50)
								spawn(100) src.disabled = !src.disabled
							if(src.shock_wire == temp_wire)
								src.shocked = !src.shocked
								src.shock(usr,50)
								spawn(100) src.shocked = !src.shocked
				if(href_list["act"] == "wire")
					if (!istype(usr.get_active_hand(), /obj/item/weapon/wirecutters))
						usr << "You need wirecutters!"
					else
						wires[temp_wire] = !wires[temp_wire]
						if(src.hack_wire == temp_wire)
							src.hacked = !src.hacked
						if(src.disable_wire == temp_wire)
							src.disabled = !src.disabled
							src.shock(usr,50)
						if(src.shock_wire == temp_wire)
							src.shocked = !src.shocked
							src.shock(usr,50)
		else
			usr << "\red The furbricator is busy. Please wait for completion of previous operation."
		src.updateUsrDialog()
		return


	New()
		..()
		src.L = furbricator_recipes
		src.LL = furbricator_recipes_hidden
		src.wires["Light Red"] = 0
		src.wires["Dark Red"] = 0
		src.wires["Blue"] = 0
		src.wires["Green"] = 0
		src.wires["Yellow"] = 0
		src.wires["Black"] = 0
		src.wires["White"] = 0
		src.wires["Gray"] = 0
		src.wires["Orange"] = 0
		src.wires["Pink"] = 0
		var/list/w = list("Light Red","Dark Red","Blue","Green","Yellow","Black","White","Gray","Orange","Pink")
		src.hack_wire = pick(w)
		w -= src.hack_wire
		src.shock_wire = pick(w)
		w -= src.shock_wire
		src.disable_wire = pick(w)
		w -= src.disable_wire