/* Toys!
 * ContainsL
 *		Balloons
 *		Fake telebeacon
 *		Fake singularity
 *		Toy gun
 *		Toy crossbow
 *		Toy swords
 *		Crayons
 *		Snap pops
 *		Water flower
 *		Cards
 *		Toy nuke
 */


/obj/item/toy
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	force = 0


/*
 * Balloons
 */
/obj/item/toy/balloon
	name = "water balloon"
	desc = "A translucent balloon. There's nothing in it."
	icon = 'icons/obj/toy.dmi'
	icon_state = "waterballoon-e"
	item_state = "balloon-empty"

/obj/item/toy/balloon/New()
	create_reagents(10)

/obj/item/toy/balloon/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/toy/balloon/afterattack(atom/A as mob|obj, mob/user as mob, proximity)
	if(!proximity) return
	if (istype(A, /obj/structure/reagent_dispensers/watertank) && get_dist(src,A) <= 1)
		A.reagents.trans_to(src, 10)
		user << "<span class='notice'>You fill the balloon with the contents of [A].</span>"
		src.desc = "A translucent balloon with some form of liquid sloshing around in it."
		src.update_icon()
	return

/obj/item/toy/balloon/attackby(obj/O as obj, mob/user as mob)
	if(istype(O, /obj/item/weapon/reagent_containers/glass))
		if(O.reagents)
			if(O.reagents.total_volume < 1)
				user << "The [O] is empty."
			else if(O.reagents.total_volume >= 1)
				if(O.reagents.has_reagent("pacid", 1))
					user << "The acid chews through the balloon!"
					O.reagents.reaction(user)
					qdel(src)
				else
					src.desc = "A translucent balloon with some form of liquid sloshing around in it."
					user << "<span class='notice'>You fill the balloon with the contents of [O].</span>"
					O.reagents.trans_to(src, 10)
	src.update_icon()
	return

/obj/item/toy/balloon/throw_impact(atom/hit_atom)
	if(src.reagents.total_volume >= 1)
		src.visible_message("<span class='danger'>The [src] bursts!</span>","You hear a pop and a splash.")
		src.reagents.reaction(get_turf(hit_atom))
		for(var/atom/A in get_turf(hit_atom))
			src.reagents.reaction(A)
		src.icon_state = "burst"
		spawn(5)
			if(src)
				qdel(src)
	return

/obj/item/toy/balloon/update_icon()
	if(src.reagents.total_volume >= 1)
		icon_state = "waterballoon"
		item_state = "balloon"
	else
		icon_state = "waterballoon-e"
		item_state = "balloon-empty"

/obj/item/toy/syndicateballoon
	name = "syndicate balloon"
	desc = "There is a tag on the back that reads \"FUK NT!11!\"."
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	force = 0
	icon = 'icons/obj/weapons.dmi'
	icon_state = "syndballoon"
	item_state = "syndballoon"
	w_class = 4.0

/*
 * Fake singularity
 */
/obj/item/toy/spinningtoy
	name = "gravitational singularity"
	desc = "\"Singulo\" brand spinning toy."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_s1"

/*
 * Toy gun: Why isnt this an /obj/item/weapon/gun?
 */
/obj/item/toy/gun
	name = "cap gun"
	desc = "There are 0 caps left. Looks almost like the real thing! Ages 8 and up. Please recycle in an autolathe when you're out of caps!"
	icon = 'icons/obj/gun.dmi'
	icon_state = "revolver"
	item_state = "gun"
	flags =  CONDUCT
	slot_flags = SLOT_BELT
	w_class = 3.0
	g_amt = 10
	m_amt = 10
	attack_verb = list("struck", "pistol whipped", "hit", "bashed")
	var/bullets = 7.0

/obj/item/toy/gun/examine()
	set src in usr

	src.desc = text("There are [] cap\s left. Looks almost like the real thing! Ages 8 and up.", src.bullets)
	..()
	return

/obj/item/toy/gun/attackby(obj/item/toy/ammo/gun/A as obj, mob/user as mob)

	if (istype(A, /obj/item/toy/ammo/gun))
		if (src.bullets >= 7)
			user << "<span class='notice'>It's already fully loaded!</span>"
			return 1
		if (A.amount_left <= 0)
			user << "<span class='danger'>There are no more caps!</span>"
			return 1
		if (A.amount_left < (7 - src.bullets))
			src.bullets += A.amount_left
			user << text("<span class='danger'>You reload [] cap\s!</span>", A.amount_left)
			A.amount_left = 0
		else
			user << text("<span class='danger'>You reload [] cap\s!</span>", 7 - src.bullets)
			A.amount_left -= 7 - src.bullets
			src.bullets = 7
		A.update_icon()
		return 1
	return

/obj/item/toy/gun/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	if (flag)
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "<span class='danger'>You don't have the dexterity to do this!</span>"
		return
	src.add_fingerprint(user)
	if (src.bullets < 1)
		user.show_message("<span class='warning'>*click*</span>", 2)
		playsound(user, 'sound/weapons/empty.ogg', 100, 1)
		return
	playsound(user, 'sound/weapons/Gunshot.ogg', 100, 1)
	src.bullets--
	for(var/mob/O in viewers(user, null))
		O.show_message(text("<span class='danger'>[user] fires [src] at [target]!</span>"), 1,
						 "<span class='warning'> You hear a gunshot.</span>", 2)

/obj/item/toy/ammo/gun
	name = "ammo-caps"
	desc = "There are 7 caps left! Make sure to recyle the box in an autolathe when it gets empty."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "357-7"
	w_class = 1.0
	g_amt = 10
	m_amt = 10
	var/amount_left = 7.0

/obj/item/toy/ammo/gun/update_icon()
	src.icon_state = text("357-[]", src.amount_left)
	src.desc = text("There are [] cap\s left! Make sure to recycle the box in an autolathe when it gets empty.", src.amount_left)
	return

/*
 * Toy crossbow
 */

/obj/item/toy/crossbow
	name = "foam dart crossbow"
	desc = "A weapon favored by many overactive children. Ages 8 and up."
	icon = 'icons/obj/gun.dmi'
	icon_state = "crossbow"
	item_state = "crossbow"
	w_class = 2.0
	attack_verb = list("attacked", "struck", "hit")
	var/bullets = 5

/obj/item/toy/crossbow/examine()
	set src in view(2)
	..()
	if (bullets)
		usr << "<span class='notice'>It is loaded with [bullets] foam darts!</span>"

/obj/item/toy/crossbow/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/toy/ammo/crossbow))
		if(bullets <= 4)
			user.drop_item()
			qdel(I)
			bullets++
			user << "<span class='notice'>You load the foam dart into the crossbow.</span>"
		else
			usr << "<span class='danger'>It's already fully loaded.</span>"


/obj/item/toy/crossbow/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	if(!isturf(target.loc) || target == user) return
	if(flag) return

	if (locate (/obj/structure/table, src.loc))
		return
	else if (bullets)
		var/turf/trg = get_turf(target)
		var/obj/effect/foam_dart_dummy/D = new/obj/effect/foam_dart_dummy(get_turf(src))
		bullets--
		D.icon_state = "foamdart"
		D.name = "foam dart"
		playsound(user.loc, 'sound/items/syringeproj.ogg', 50, 1)

		for(var/i=0, i<6, i++)
			if (D)
				if(D.loc == trg) break
				step_towards(D,trg)

				for(var/mob/living/M in D.loc)
					if(!istype(M,/mob/living)) continue
					if(M == user) continue
					for(var/mob/O in viewers(world.view, D))
						O.show_message(text("<span class='danger'>[] was hit by the foam dart!</span>", M), 1)
					new /obj/item/toy/ammo/crossbow(M.loc)
					qdel(D)
					return

				for(var/atom/A in D.loc)
					if(A == user) continue
					if(A.density)
						new /obj/item/toy/ammo/crossbow(A.loc)
						qdel(D)

			sleep(1)

		spawn(10)
			if(D)
				new /obj/item/toy/ammo/crossbow(D.loc)
				qdel(D)

		return
	else if (bullets == 0)
		user.Weaken(5)
		for(var/mob/O in viewers(world.view, user))
			O.show_message(text("<span class='danger'>[] realized they were out of ammo and starting scrounging for some!</span>", user), 1)


/obj/item/toy/crossbow/attack(mob/M as mob, mob/user as mob)
	src.add_fingerprint(user)

// ******* Check

	if (src.bullets > 0 && M.lying)

		for(var/mob/O in viewers(M, null))
			if(O.client)
				O.show_message(text("<span class='userdanger'>[] casually lines up a shot with []'s head and pulls the trigger!</span>", user, M), 1, "<span class='danger'>You hear the sound of foam against skull.</span>", 2)
				O.show_message(text("<span class='danger'>[] was hit in the head by the foam dart!</span>", M), 1)

		playsound(user.loc, 'sound/items/syringeproj.ogg', 50, 1)
		new /obj/item/toy/ammo/crossbow(M.loc)
		src.bullets--
	else if (M.lying && src.bullets == 0)
		for(var/mob/O in viewers(M, null))
			if (O.client)	O.show_message(text("<span class='userdanger'>[] casually lines up a shot with []'s head, pulls the trigger, then realizes they are out of ammo and drops to the floor in search of some!</span>", user, M), 1, "<span class='danger'>You hear someone fall</span>", 2)
		user.Weaken(5)
	return

/obj/item/toy/ammo/crossbow
	name = "foam dart"
	desc = "Its nerf or nothing! Ages 8 and up."
	icon = 'icons/obj/toy.dmi'
	icon_state = "foamdart"
	w_class = 1.0

/obj/effect/foam_dart_dummy
	name = ""
	desc = ""
	icon = 'icons/obj/toy.dmi'
	icon_state = "null"
	anchored = 1
	density = 0


/*
 * Toy swords
 */
/obj/item/toy/sword
	name = "toy sword"
	desc = "A cheap, plastic replica of an energy sword. Realistic sounds! Ages 8 and up."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "sword0"
	item_state = "sword0"
	var/active = 0.0
	w_class = 2.0
	flags = NOSHIELD
	attack_verb = list("attacked", "struck", "hit")
	var/hacked = 0

/obj/item/toy/sword/attack_self(mob/user as mob)
	active = !( active )
	if (active)
		user << "<span class='notice'>You extend the plastic blade with a quick flick of your wrist.</span>"
		playsound(user, 'sound/weapons/saberon.ogg', 20, 1)
		if(hacked)
			icon_state = "swordrainbow"
			item_state = "swordrainbow"
		else
			icon_state = "swordblue"
			item_state = "swordblue"
		w_class = 4
	else
		user << "<span class='notice'>You push the plastic blade back down into the handle.</span>"
		playsound(user, 'sound/weapons/saberoff.ogg', 20, 1)
		icon_state = "sword0"
		item_state = "sword0"
		w_class = 2
	add_fingerprint(user)
	return

// Copied from /obj/item/weapon/melee/energy/sword/attackby
/obj/item/toy/sword/attackby(obj/item/weapon/W, mob/living/user)
	..()
	if(istype(W, /obj/item/toy/sword))
		if(W == src)
			user << "<span class='notice'>You try to attach the end of the plastic sword to... itself. You're not very smart, are you?</span>"
			if(ishuman(user))
				user.adjustBrainLoss(10)
		else if((W.flags & NODROP) || (flags & NODROP))
			user << "<span class='notice'>\the [flags & NODROP ? src : W] is stuck to your hand, you can't attach it to \the [flags & NODROP ? W : src]!</span>"
		else
			user << "<span class='notice'>You attach the ends of the two plastic swords, making a single double-bladed toy! You're fake-cool.</span>"
			var/obj/item/weapon/twohanded/dualsaber/toy/newSaber = new /obj/item/weapon/twohanded/dualsaber/toy(user.loc)
			if(hacked) // That's right, we'll only check the "original" "sword".
				newSaber.hacked = 1
				newSaber.item_color = "rainbow"
			user.unEquip(W)
			user.unEquip(src)
			qdel(W)
			qdel(src)
	else if(istype(W, /obj/item/device/multitool))
		if(hacked == 0)
			hacked = 1
			item_color = "rainbow"
			user << "<span class='warning'>RNBW_ENGAGE</span>"

			if(active)
				icon_state = "swordrainbow"
				// Updating overlays, copied from welder code.
				// I tried calling attack_self twice, which looked cool, except it somehow didn't update the overlays!!
				if(user.r_hand == src)
					user.update_inv_r_hand(0)
				else if(user.l_hand == src)
					user.update_inv_l_hand(0)
		else
			user << "<span class='warning'>It's already fabulous!</span>"

/*
 * Subtype of Double-Bladed Energy Swords
 */
/obj/item/weapon/twohanded/dualsaber/toy
	name = "double-bladed toy sword"
	desc = "A cheap, plastic replica of TWO energy swords.  Double the fun!"
	force = 0
	throwforce = 0
	throw_speed = 3
	throw_range = 5
	force_unwielded = 0
	force_wielded = 0
	origin_tech = null
	attack_verb = list("attacked", "struck", "hit")

/obj/item/weapon/twohanded/dualsaber/toy/IsShield()
	return 0

/obj/item/weapon/twohanded/dualsaber/toy/IsReflect()//Stops Toy Dualsabers from reflecting energy projectiles
	return 0

/obj/item/toy/katana
	name = "replica katana"
	desc = "Woefully underpowered in D20."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "katana"
	item_state = "katana"
	flags = CONDUCT
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 5
	throwforce = 5
	w_class = 3
	attack_verb = list("attacked", "slashed", "stabbed", "sliced")
	hitsound = 'sound/weapons/bladeslice.ogg'

/*
 * Crayons
 */

/obj/item/toy/crayon
	name = "crayon"
	desc = "A colourful crayon. Looks tasty. Mmmm..."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonred"
	w_class = 1.0
	attack_verb = list("attacked", "coloured")
	var/colour = "#FF0000" //RGB
	var/drawtype = "rune"
	var/list/graffiti = list("amyjon","face","matt","revolution","engie","guy","end","dwarf","uboa")
	var/list/letters = list("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
	var/uses = 30 //0 for unlimited uses
	var/instant = 0
	var/colourName = "red" //for updateIcon purposes
	var/dat

/obj/item/toy/crayon/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is jamming the [src.name] up \his nose and into \his brain. It looks like \he's trying to commit suicide.</span>")
	return (BRUTELOSS|OXYLOSS)

/obj/item/toy/crayon/New()
	..()
	name = "[colourName] crayon" //Makes crayons identifiable in things like grinders
	drawtype = pick(pick(graffiti), pick(letters), "rune[rand(1,6)]")

/obj/item/toy/crayon/attack_self(mob/living/user as mob)
	dat += "<center><h2>Currently selected: [drawtype]</h2><br>"
	dat += "<a href='?src=\ref[src];type=random_letter'>Random letter</a><a href='?src=\ref[src];type=letter'>Pick letter</a>"
	dat += "<hr>"
	dat += "<h3>Runes:</h3><br>"
	dat += "<a href='?src=\ref[src];type=random_rune'>Random rune</a>"
	for(var/i = 1; i <= 6; i++)
		dat += "<a href='?src=\ref[src];type=rune[i]'>Rune[i]</a>"
		if(!((i + 1) % 3)) //3 buttons in a row
			dat += "<br>"
	dat += "<hr>"
	graffiti.Find()
	dat += "<h3>Graffiti:</h3><br>"
	dat += "<a href='?src=\ref[src];type=random_graffiti'>Random graffiti</a>"
	var/c = 1
	for(var/T in graffiti)
		dat += "<a href='?src=\ref[src];type=[T]'>[T]</a>"
		if(!((c + 1) % 3)) //3 buttons in a row
			dat += "<br>"
		c++
	dat += "<hr>"
	var/datum/browser/popup = new(user, "crayon", name, 300, 500)
	popup.set_content(dat)
	popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	dat = ""

/obj/item/toy/crayon/Topic(href, href_list, hsrc)
	switch(href_list["type"])
		if("random_letter")
			drawtype = pick(letters)
		if("letter")
			drawtype = input("Choose the letter.", "Crayon scribbles") in letters
		if("random_rune")
			drawtype = "rune[rand(1,6)]"
		if("random_graffiti")
			drawtype = pick(graffiti)
		else
			drawtype = href_list["type"]

/obj/item/toy/crayon/afterattack(atom/target, mob/user as mob, proximity)
	if(!proximity) return
	if(istype(target,/turf/simulated/floor))
		if(letters.Find(drawtype))
			user << "You start drawing a letter on the [target.name]."
		else if(graffiti.Find(drawtype))
			user << "You start drawing graffiti on the [target.name]."
		else
			user << "You start drawing a rune on the [target.name]."
		if(instant || do_after(user, 50))
			new /obj/effect/decal/cleanable/crayon(target,colour,drawtype)
			user << "You finish drawing."
			if(uses)
				uses--
				if(!uses)
					user << "<span class='danger'>You used up your crayon!</span>"
					qdel(src)
	return

/obj/item/toy/crayon/attack(mob/M as mob, mob/user as mob)
	if(M == user)
		user << "You take a bite of the crayon. Delicious!"
		user.nutrition += 5
		if(uses)
			uses -= 5
			if(uses <= 0)
				user << "<span class='danger'>You ate your crayon!</span>"
				qdel(src)
	else
		..()

/*
 * Snap pops
 */

/obj/item/toy/snappop
	name = "snap pop"
	desc = "Wow!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "snappop"
	w_class = 1

/obj/item/toy/snappop/throw_impact(atom/hit_atom)
	..()
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	new /obj/effect/decal/cleanable/ash(src.loc)
	src.visible_message("<span class='suicide'> The [src.name] explodes!","</span> You hear a snap!")
	playsound(src, 'sound/effects/snap.ogg', 50, 1)
	qdel(src)

/obj/item/toy/snappop/Crossed(H as mob|obj)
	if((ishuman(H))) //i guess carp and shit shouldn't set them off
		var/mob/living/carbon/M = H
		if(M.m_intent == "run")
			M << "<span class='danger'>You step on the snap pop!</span>"

			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(2, 0, src)
			s.start()
			new /obj/effect/decal/cleanable/ash(src.loc)
			src.visible_message("<span class='danger'>The [src.name] explodes!</span>","<span class='danger'>You hear a snap!</span>")
			playsound(src, 'sound/effects/snap.ogg', 50, 1)
			qdel(src)

/*
 * Mech prizes
 */
/obj/item/toy/prize
	icon = 'icons/obj/toy.dmi'
	icon_state = "ripleytoy"
	var/cooldown = 0

//all credit to skasi for toy mech fun ideas
/obj/item/toy/prize/attack_self(mob/user as mob)
	if(!cooldown)
		user << "<span class='notice'>You play with [src].</span>"
		playsound(user, 'sound/mecha/mechstep.ogg', 20, 1)
		cooldown = 1
		spawn(30) cooldown = 0

/obj/item/toy/prize/attack_hand(mob/user as mob)
	if(loc == user)
		if(!cooldown)
			user << "<span class='notice'>You play with [src].</span>"
			playsound(user, 'sound/mecha/mechturn.ogg', 20, 1)
			cooldown = 1
			spawn(30) cooldown = 0
			return
	..()

/obj/item/toy/prize/ripley
	name = "toy Ripley"
	desc = "Mini-Mecha action figure! Collect them all! 1/11."

/obj/item/toy/prize/fireripley
	name = "toy firefighting Ripley"
	desc = "Mini-Mecha action figure! Collect them all! 2/11."
	icon_state = "fireripleytoy"

/obj/item/toy/prize/deathripley
	name = "toy deathsquad Ripley"
	desc = "Mini-Mecha action figure! Collect them all! 3/11."
	icon_state = "deathripleytoy"

/obj/item/toy/prize/gygax
	name = "toy Gygax"
	desc = "Mini-Mecha action figure! Collect them all! 4/11."
	icon_state = "gygaxtoy"

/obj/item/toy/prize/durand
	name = "toy Durand"
	desc = "Mini-Mecha action figure! Collect them all! 5/11."
	icon_state = "durandprize"

/obj/item/toy/prize/honk
	name = "toy H.O.N.K."
	desc = "Mini-Mecha action figure! Collect them all! 6/11."
	icon_state = "honkprize"

/obj/item/toy/prize/marauder
	name = "toy Marauder"
	desc = "Mini-Mecha action figure! Collect them all! 7/11."
	icon_state = "marauderprize"

/obj/item/toy/prize/seraph
	name = "toy Seraph"
	desc = "Mini-Mecha action figure! Collect them all! 8/11."
	icon_state = "seraphprize"

/obj/item/toy/prize/mauler
	name = "toy Mauler"
	desc = "Mini-Mecha action figure! Collect them all! 9/11."
	icon_state = "maulerprize"

/obj/item/toy/prize/odysseus
	name = "toy Odysseus"
	desc = "Mini-Mecha action figure! Collect them all! 10/11."
	icon_state = "odysseusprize"

/obj/item/toy/prize/phazon
	name = "toy Phazon"
	desc = "Mini-Mecha action figure! Collect them all! 11/11."
	icon_state = "phazonprize"

/*
 * AI core prizes
 */
/obj/item/toy/AI
	name = "toy AI"
	desc = "A little toy model AI core with real law announcing action!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "AI"
	var/cooldown = 0

/obj/item/toy/AI/attack_self(mob/user)
	if(!cooldown) //for the sanity of everyone
		var/message = generate_ion_law()
		user << "<span class='notice'>You press the button on [src].</span>"
		playsound(user, 'sound/machines/click.ogg', 20, 1)
		src.loc.visible_message("<span class='danger'>\icon[src] [message]</span>")
		cooldown = 1
		spawn(30) cooldown = 0
		return
	..()




/*
|| A Deck of Cards for playing various games of chance ||
*/



obj/item/toy/cards
	var/parentdeck = null
	var/deckstyle = "nanotrasen"
	var/card_hitsound = null
	var/card_force = 0
	var/card_throwforce = 0
	var/card_throw_speed = 3
	var/card_throw_range = 7
	var/list/card_attack_verb = list("attacked")

obj/item/toy/cards/New()
	..()

obj/item/toy/cards/proc/apply_card_vars(obj/item/toy/cards/newobj, obj/item/toy/cards/sourceobj) // Applies variables for supporting multiple types of card deck
	if(!istype(sourceobj))
		return

obj/item/toy/cards/deck
	name = "deck of cards"
	desc = "A deck of space-grade playing cards."
	icon = 'icons/obj/toy.dmi'
	deckstyle = "nanotrasen"
	icon_state = "deck_nanotrasen_full"
	w_class = 2.0
	var/cooldown = 0
	var/list/cards = list()

obj/item/toy/cards/deck/New()
	..()
	icon_state = "deck_[deckstyle]_full"
	for(var/i = 2; i <= 10; i++)
		cards += "[i] of Hearts"
		cards += "[i] of Spades"
		cards += "[i] of Clubs"
		cards += "[i] of Diamonds"
	cards += "King of Hearts"
	cards += "King of Spades"
	cards += "King of Clubs"
	cards += "King of Diamonds"
	cards += "Queen of Hearts"
	cards += "Queen of Spades"
	cards += "Queen of Clubs"
	cards += "Queen of Diamonds"
	cards += "Jack of Hearts"
	cards += "Jack of Spades"
	cards += "Jack of Clubs"
	cards += "Jack of Diamonds"
	cards += "Ace of Hearts"
	cards += "Ace of Spades"
	cards += "Ace of Clubs"
	cards += "Ace of Diamonds"


obj/item/toy/cards/deck/attack_hand(mob/user as mob)
	var/choice = null
	if(cards.len == 0)
		src.icon_state = "deck_[deckstyle]_empty"
		user << "<span class='notice'>There are no more cards to draw.</span>"
		return
	var/obj/item/toy/cards/singlecard/H = new/obj/item/toy/cards/singlecard(user.loc)
	choice = cards[1]
	H.cardname = choice
	H.parentdeck = src
	var/O = src
	H.apply_card_vars(H,O)
	src.cards -= choice
	H.pickup(user)
	user.put_in_active_hand(H)
	src.visible_message("<span class='notice'>[user] draws a card from the deck.</span>", "<span class='notice'>You draw a card from the deck.</span>")
	if(cards.len > 26)
		src.icon_state = "deck_[deckstyle]_full"
	else if(cards.len > 10)
		src.icon_state = "deck_[deckstyle]_half"
	else if(cards.len > 1)
		src.icon_state = "deck_[deckstyle]_low"

obj/item/toy/cards/deck/attack_self(mob/user as mob)
	if(cooldown < world.time - 50)
		cards = shuffle(cards)
		playsound(user, 'sound/items/cardshuffle.ogg', 50, 1)
		user.visible_message("<span class='notice'>[user] shuffles the deck.</span>", "<span class='notice'>You shuffle the deck.</span>")
		cooldown = world.time

obj/item/toy/cards/deck/attackby(obj/item/toy/cards/singlecard/C, mob/living/user)
	..()
	if(istype(C))
		if(C.parentdeck == src)
			if(!user.unEquip(C))
				user << "<span class='notice'>The card is stuck to your hand, you can't add it to the deck!</span>"
				return
			src.cards += C.cardname
			user.visible_message("<span class='notice'>[user] adds a card to the bottom of the deck.</span>","<span class='notice'>You add the card to the bottom of the deck.</span>")
			qdel(C)
		else
			user << "<span class='notice'>You can't mix cards from other decks.</span>"
		if(cards.len > 26)
			src.icon_state = "deck_[deckstyle]_full"
		else if(cards.len > 10)
			src.icon_state = "deck_[deckstyle]_half"
		else if(cards.len > 1)
			src.icon_state = "deck_[deckstyle]_low"


obj/item/toy/cards/deck/attackby(obj/item/toy/cards/cardhand/C, mob/living/user)
	..()
	if(istype(C))
		if(C.parentdeck == src)
			if(!user.unEquip(C))
				user << "<span class='notice'>The hand of cards is stuck to your hand, you can't add it to the deck!</span>"
				return
			src.cards += C.currenthand
			user.visible_message("<span class='notice'>[user] puts their hand of cards in the deck.</span>", "<span class='notice'>You put the hand of cards in the deck.</span>")
			qdel(C)
		else
			user << "<span class='notice'>You can't mix cards from other decks.</span>"
		if(cards.len > 26)
			src.icon_state = "deck_[deckstyle]_full"
		else if(cards.len > 10)
			src.icon_state = "deck_[deckstyle]_half"
		else if(cards.len > 1)
			src.icon_state = "deck_[deckstyle]_low"

/obj/item/toy/cards/deck/MouseDrop(atom/over_object)
	var/mob/M = usr
	if(usr.stat || !ishuman(usr) || !usr.canmove || usr.restrained())
		return
	if(Adjacent(usr))
		if(over_object == M && loc != M)
			M.put_in_hands(src)
			usr << "<span class='notice'>You pick up the deck.</span>"

		else if(istype(over_object, /obj/screen))
			switch(over_object.name)
				if("l_hand")
					M.put_in_l_hand(src)
				else if("r_hand")
					M.put_in_r_hand(src)
				usr << "<span class='notice'>You pick up the deck.</span>"
	else
		usr << "<span class='notice'>You can't reach it from here.</span>"



obj/item/toy/cards/cardhand
	name = "hand of cards"
	desc = "A number of cards not in a deck, customarily held in ones hand."
	icon = 'icons/obj/toy.dmi'
	icon_state = "nanotrasen_hand2"
	w_class = 1.0
	var/list/currenthand = list()
	var/choice = null


obj/item/toy/cards/cardhand/attack_self(mob/user as mob)
	user.set_machine(src)
	interact(user)

obj/item/toy/cards/cardhand/interact(mob/user)
	var/dat = "You have:<BR>"
	for(var/t in currenthand)
		dat += "<A href='?src=\ref[src];pick=[t]'>A [t].</A><BR>"
	dat += "Which card will you remove next?"
	var/datum/browser/popup = new(user, "cardhand", "Hand of Cards", 400, 240)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.set_content(dat)
	popup.open()


obj/item/toy/cards/cardhand/Topic(href, href_list)
	if(..())
		return
	if(usr.stat || !ishuman(usr) || !usr.canmove)
		return
	var/mob/living/carbon/human/cardUser = usr
	var/O = src
	if(href_list["pick"])
		if (cardUser.get_item_by_slot(slot_l_hand) == src || cardUser.get_item_by_slot(slot_r_hand) == src)
			var/choice = href_list["pick"]
			var/obj/item/toy/cards/singlecard/C = new/obj/item/toy/cards/singlecard(cardUser.loc)
			src.currenthand -= choice
			C.parentdeck = src.parentdeck
			C.cardname = choice
			C.apply_card_vars(C,O)
			C.pickup(cardUser)
			cardUser.put_in_any_hand_if_possible(C)
			cardUser.visible_message("<span class='notice'>[cardUser] draws a card from \his hand.</span>", "<span class='notice'>You take the [C.cardname] from your hand.</span>")

			interact(cardUser)
			if(src.currenthand.len < 3)
				src.icon_state = "[deckstyle]_hand2"
			else if(src.currenthand.len < 4)
				src.icon_state = "[deckstyle]_hand3"
			else if(src.currenthand.len < 5)
				src.icon_state = "[deckstyle]_hand4"
			if(src.currenthand.len == 1)
				var/obj/item/toy/cards/singlecard/N = new/obj/item/toy/cards/singlecard(src.loc)
				N.parentdeck = src.parentdeck
				N.cardname = src.currenthand[1]
				N.apply_card_vars(N,O)
				cardUser.unEquip(src)
				N.pickup(cardUser)
				cardUser.put_in_any_hand_if_possible(N)
				cardUser << "<span class='notice'>You also take [currenthand[1]] and hold it.</span>"
				cardUser << browse(null, "window=cardhand")
				qdel(src)
		return

obj/item/toy/cards/cardhand/attackby(obj/item/toy/cards/singlecard/C, mob/living/user)
	if(istype(C))
		if(C.parentdeck == src.parentdeck)
			src.currenthand += C.cardname
			user.unEquip(C)
			user.visible_message("<span class='notice'>[user] adds a card to their hand.</span>", "<span class='notice'>You add the [C.cardname] to your hand.</span>")
			interact(user)
			if(currenthand.len > 4)
				src.icon_state = "[deckstyle]_hand5"
			else if(currenthand.len > 3)
				src.icon_state = "[deckstyle]_hand4"
			else if(currenthand.len > 2)
				src.icon_state = "[deckstyle]_hand3"
			qdel(C)
		else
			user << "<span class='notice'>You can't mix cards from other decks.</span>"

obj/item/toy/cards/cardhand/apply_card_vars(obj/item/toy/cards/newobj,obj/item/toy/cards/sourceobj)
	..()
	newobj.deckstyle = sourceobj.deckstyle
	newobj.icon_state = "[deckstyle]_hand2" // Another dumb hack, without this the hand is invisible (or has the default deckstyle) until another card is added.
	newobj.card_hitsound = sourceobj.card_hitsound
	newobj.card_force = sourceobj.card_force
	newobj.card_throwforce = sourceobj.card_throwforce
	newobj.card_throw_speed = sourceobj.card_throw_speed
	newobj.card_throw_range = sourceobj.card_throw_range
	newobj.card_attack_verb = sourceobj.card_attack_verb


obj/item/toy/cards/singlecard
	name = "card"
	desc = "a card"
	icon = 'icons/obj/toy.dmi'
	icon_state = "singlecard_nanotrasen_down"
	w_class = 1.0
	var/cardname = null
	var/flipped = 0
	pixel_x = -5


obj/item/toy/cards/singlecard/examine()
	set src in usr.contents
	if(ishuman(usr))
		var/mob/living/carbon/human/cardUser = usr
		if(cardUser.get_item_by_slot(slot_l_hand) == src || cardUser.get_item_by_slot(slot_r_hand) == src)
			cardUser.visible_message("<span class='notice'>[cardUser] checks \his card.</span>", "<span class='notice'>The card reads: [src.cardname]</span>")
		else
			cardUser << "<span class='notice'>You need to have the card in your hand to check it.</span>"


obj/item/toy/cards/singlecard/verb/Flip()
	set name = "Flip Card"
	set category = "Object"
	set src in range(1)
	if(usr.stat || !ishuman(usr) || !usr.canmove || usr.restrained())
		return
	if(!flipped)
		src.flipped = 1
		if (cardname)
			src.icon_state = "sc_[cardname]_[deckstyle]"
			src.name = src.cardname
		else
			src.icon_state = "sc_Ace of Spades_[deckstyle]"
			src.name = "What Card"
		src.pixel_x = 5
	else if(flipped)
		src.flipped = 0
		src.icon_state = "singlecard_down_[deckstyle]"
		src.name = "card"
		src.pixel_x = -5

obj/item/toy/cards/singlecard/attackby(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/toy/cards/singlecard/))
		var/obj/item/toy/cards/singlecard/C = I
		if(C.parentdeck == src.parentdeck)
			var/obj/item/toy/cards/cardhand/H = new/obj/item/toy/cards/cardhand(user.loc)
			H.currenthand += C.cardname
			H.currenthand += src.cardname
			H.parentdeck = C.parentdeck
			H.apply_card_vars(H,C)
			user.unEquip(C)
			H.pickup(user)
			user.put_in_active_hand(H)
			user << "<span class='notice'>You combine the [C.cardname] and the [src.cardname] into a hand.</span>"
			qdel(C)
			qdel(src)
		else
			user << "<span class='notice'>You can't mix cards from other decks.</span>"

	if(istype(I, /obj/item/toy/cards/cardhand/))
		var/obj/item/toy/cards/cardhand/H = I
		if(H.parentdeck == parentdeck)
			H.currenthand += cardname
			user.unEquip(src)
			user.visible_message("<span class='notice'>[user] adds a card to \his hand.</span>", "<span class='notice'>You add the [cardname] to your hand.</span>")
			H.interact(user)
			if(H.currenthand.len > 4)
				H.icon_state = "[deckstyle]_hand5"
			else if(H.currenthand.len > 3)
				H.icon_state = "[deckstyle]_hand4"
			else if(H.currenthand.len > 2)
				H.icon_state = "[deckstyle]_hand3"
			qdel(src)
		else
			user << "<span class='notice'>You can't mix cards from other decks.</span>"


obj/item/toy/cards/singlecard/attack_self(mob/user)
	if(usr.stat || !ishuman(usr) || !usr.canmove || usr.restrained())
		return
	Flip()

obj/item/toy/cards/singlecard/apply_card_vars(obj/item/toy/cards/singlecard/newobj,obj/item/toy/cards/sourceobj)
	..()
	newobj.deckstyle = sourceobj.deckstyle
	newobj.icon_state = "singlecard_down_[deckstyle]" // Without this the card is invisible until flipped. It's an ugly hack, but it works.
	newobj.card_hitsound = sourceobj.card_hitsound
	newobj.hitsound = newobj.card_hitsound
	newobj.card_force = sourceobj.card_force
	newobj.force = newobj.card_force
	newobj.card_throwforce = sourceobj.card_throwforce
	newobj.throwforce = newobj.card_throwforce
	newobj.card_throw_speed = sourceobj.card_throw_speed
	newobj.throw_speed = newobj.card_throw_speed
	newobj.card_throw_range = sourceobj.card_throw_range
	newobj.throw_range = newobj.card_throw_range
	newobj.card_attack_verb = sourceobj.card_attack_verb
	newobj.attack_verb = newobj.card_attack_verb


/*
|| Syndicate playing cards, for pretending you're Gambit and playing poker for the nuke disk. ||
*/

obj/item/toy/cards/deck/syndicate
	name = "suspicious looking deck of cards"
	desc = "A deck of space-grade playing cards. They seem unusually rigid."
	deckstyle = "syndicate"
	card_hitsound = 'sound/weapons/bladeslice.ogg'
	card_force = 5
	card_throwforce = 10
	card_throw_speed = 3
	card_throw_range = 7
	card_attack_verb = list("attacked", "sliced", "diced", "slashed", "cut")


/obj/item/toy/nuke
	name = "\improper Nuclear Fission Explosive toy"
	desc = "A plastic model of a Nuclear Fission Explosive."
	icon = 'icons/obj/toy.dmi'
	icon_state = "nuketoyidle"
	w_class = 2.0
	var/cooldown = 0

/obj/item/toy/nuke/attack_self(mob/user)
	if (cooldown < world.time)
		cooldown = world.time + 1800 //3 minutes
		user.visible_message("<span class='warning'>[user] presses a button on [src]</span>", "<span class='notice'>You activate [src], it plays a loud noise!</span>", "<span class='notice'>You hear the click of a button.</span>")
		spawn(5) //gia said so
			icon_state = "nuketoy"
			playsound(src, 'sound/machines/Alarm.ogg', 100, 0, surround = 0)
			sleep(135)
			icon_state = "nuketoycool"
			sleep(cooldown - world.time)
			icon_state = "nuketoyidle"
	else
		var/timeleft = (cooldown - world.time)
		user << "<span class='alert'>Nothing happens, and '</span>[round(timeleft/10)]<span class='alert'>' appears on a small display.</span>"
