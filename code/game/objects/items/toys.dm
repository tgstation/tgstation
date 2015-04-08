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
 */


/obj/item/toy
	throwforce = 0
	throw_speed = 4
	throw_range = 20
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
	. = ..()
	create_reagents(10)

/obj/item/toy/balloon/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/toy/balloon/afterattack(atom/A as mob|obj, mob/user as mob)
	if (istype(A, /obj/structure/reagent_dispensers/watertank) && get_dist(src,A) <= 1)
		A.reagents.trans_to(src, 10)
		user << "<span class = 'notice'>You fill the balloon with the contents of [A].</span>"
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
					del(src)
				else
					src.desc = "A translucent balloon with some form of liquid sloshing around in it."
					user << "<span class = 'info'>You fill the balloon with the contents of [O].</span>"
					O.reagents.trans_to(src, 10)
	src.update_icon()
	return

/obj/item/toy/balloon/throw_impact(atom/hit_atom)
	if(src.reagents.total_volume >= 1)
		src.visible_message("<span class = 'danger'>The [src] bursts!</span>","You hear a pop and a splash.")
		src.reagents.reaction(get_turf(hit_atom))
		for(var/atom/A in get_turf(hit_atom))
			src.reagents.reaction(A)
		src.icon_state = "burst"
		spawn(5)
			if(src)
				del(src)
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
	throw_speed = 4
	throw_range = 20
	force = 0
	icon = 'icons/obj/weapons.dmi'
	icon_state = "syndballoon"
	item_state = "syndballoon"
	w_class = 4.0

/*
 * Fake telebeacon
 */
/obj/item/toy/blink
	name = "electronic blink toy game"
	desc = "Blink.  Blink.  Blink. Ages 8 and up."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	item_state = "signaler"

/*
 * Fake singularity
 */
/obj/item/toy/spinningtoy
	name = "Gravitational Singularity"
	desc = "\"Singulo\" brand spinning toy."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_s1"

	suicide_act(mob/user)
		viewers(user) << "<span class = 'danger'><b>[user] is putting \his head into the [src.name]! It looks like \he's  trying to commit suicide!</b></span>"
		return (BRUTELOSS|TOXLOSS|OXYLOSS)


/*
 * Toy gun: Why isnt this an /obj/item/weapon/gun?
 */
/obj/item/toy/gun
	name = "cap gun"
	desc = "It almost looks like the real thing! Ages 8 and up. Please recycle in an autolathe when you're out of caps!"
	icon = 'icons/obj/gun.dmi'
	icon_state = "revolver"
	item_state = "gun"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	w_class = 3.0
	g_amt = 10
	m_amt = 10
	w_type = RECYK_MISC
	melt_temperature = MELTPOINT_PLASTIC
	attack_verb = list("struck", "pistol whipped", "hit", "bashed")
	var/bullets = 7.0

/obj/item/toy/gun/examine(mob/user)
	..()
	user << "There [bullets == 1 ? "is" : "are"] [bullets] cap\s left."

/obj/item/toy/gun/attackby(obj/item/toy/ammo/gun/A as obj, mob/user as mob)
	if (istype(A, /obj/item/toy/ammo/gun))
		if (src.bullets >= 7)
			user << "<span class = 'notice'>It's already fully loaded!</span>"
			return 1
		if (A.amount_left <= 0)
			user << "<span class = 'warning'>There is no more caps!</span>"
			return 1
		if (A.amount_left < (7 - src.bullets))
			src.bullets += A.amount_left
			user << text("<span class = 'warning'>You reload [] caps\s!</span>", A.amount_left)
			A.amount_left = 0
		else
			user << text("<span class = 'warning'>You reload [] caps\s!</span>", 7 - src.bullets)
			A.amount_left -= 7 - src.bullets
			src.bullets = 7
		A.update_icon()
		return 1
	return

/obj/item/toy/gun/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	if (flag)
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "<span class = 'warning'>You don't have the dexterity to do this!</span>"
		return
	src.add_fingerprint(user)
	if (src.bullets < 1)
		user.show_message("<span class = 'danger'>*click* *click*</span>", 2)
		playsound(user, 'sound/weapons/empty.ogg', 100, 1)
		return
	playsound(user, 'sound/weapons/Gunshot.ogg', 100, 1)
	src.bullets--
	for(var/mob/O in viewers(user, null))
		O.show_message(text("<span class = 'danger'><B>[] fires a cap gun at []!</B></span>", user, target), 1, "<span class = 'danger'>You hear a gunshot</span>", 2)

/obj/item/toy/ammo/gun
	name = "ammo-caps"
	desc = "There are 7 caps left! Make sure to recyle the box in an autolathe when it gets empty."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "357-7"
	flags = FPRINT
	siemens_coefficient = 1
	w_class = 1.0
	g_amt = 10
	m_amt = 10
	melt_temperature = MELTPOINT_PLASTIC
	w_type = RECYK_MISC
	var/amount_left = 7.0

/obj/item/toy/ammo/gun/update_icon()
	src.icon_state = text("357-[]", src.amount_left)
	src.desc = text("There are [] caps\s left! Make sure to recycle the box in an autolathe when it gets empty.", src.amount_left)
	return

/obj/item/toy/ammo/gun/examine(mob/user)
	..()
	user << "There [amount_left == 1 ? "is" : "are"] [amount_left] cap\s left."


/*
 * Toy crossbow
 */

/obj/item/toy/crossbow
	name = "foam dart crossbow"
	desc = "A weapon favored by many overactive children. Ages 8 and up."
	icon = 'icons/obj/gun.dmi'
	icon_state = "crossbow"
	item_state = "crossbow"
	flags = FPRINT
	w_class = 2.0
	attack_verb = list("attacked", "struck", "hit")
	var/bullets = 5

/obj/item/toy/crossbow/examine(mob/user)
	..()
	if (bullets)
		user << "<span class = 'info'>It is loaded with [bullets] foam dart\s!</span>"

/obj/item/toy/crossbow/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/toy/ammo/crossbow))
		if(bullets <= 4)
			user.drop_item()
			del(I)
			bullets++
			user << "<span class = 'info'>You load the foam dart into the crossbow.</span>"
		else
			usr << "<span class = 'warning'>It's already fully loaded.</span>"


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
						O.show_message(text("<span class = 'danger'>[] was hit by the foam dart!</span>", M), 1)
					new /obj/item/toy/ammo/crossbow(M.loc)
					del(D)
					return

				for(var/atom/A in D.loc)
					if(A == user) continue
					if(A.density)
						new /obj/item/toy/ammo/crossbow(A.loc)
						del(D)

			sleep(1)

		spawn(10)
			if(D)
				new /obj/item/toy/ammo/crossbow(D.loc)
				del(D)

		return
	else if (bullets == 0)
		user.Weaken(5)
		for(var/mob/O in viewers(world.view, user))
			O.show_message(text("<span class = 'danger'>[] realized they were out of ammo and starting scrounging for some!<span>", user), 1)


/obj/item/toy/crossbow/attack(mob/M as mob, mob/user as mob)
	src.add_fingerprint(user)

// ******* Check

	if (src.bullets > 0 && M.lying)

		for(var/mob/O in viewers(M, null))
			if(O.client)
				O.show_message(text("<span class = 'danger'><B>[] casually lines up a shot with []'s head and pulls the trigger!</B></span>", user, M), 1, "<span class = 'danger'>You hear the sound of foam against skull</span>", 2)
				O.show_message(text("<span class = 'danger'>[] was hit in the head by the foam dart!</span>", M), 1)

		playsound(user.loc, 'sound/items/syringeproj.ogg', 50, 1)
		new /obj/item/toy/ammo/crossbow(M.loc)
		src.bullets--
	else if (M.lying && src.bullets == 0)
		for(var/mob/O in viewers(M, null))
			if (O.client)	O.show_message(text("<span class = 'danger'><B>[] casually lines up a shot with []'s head, pulls the trigger, then realizes they are out of ammo and drops to the floor in search of some!</B></span>", user, M), 1, "<span class = 'danger'>You hear someone fall</span>", 2)
		user.Weaken(5)
	return

/obj/item/toy/ammo/crossbow
	name = "foam dart"
	desc = "Its nerf or nothing! Ages 8 and up."
	icon = 'icons/obj/toy.dmi'
	icon_state = "foamdart"
	flags = FPRINT
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
	flags = FPRINT
	attack_verb = list("attacked", "struck", "hit")

	attack_self(mob/user as mob)
		src.active = !( src.active )
		if (src.active)
			user << "<span class = 'info'>You extend the plastic blade with a quick flick of your wrist.</span>"
			playsound(user, 'sound/weapons/saberon.ogg', 50, 1)
			src.icon_state = "swordblue"
			src.item_state = "swordblue"
			src.w_class = 4
		else
			user << "<span class = 'info'>You push the plastic blade back down into the handle.</span>"
			playsound(user, 'sound/weapons/saberoff.ogg', 50, 1)
			src.icon_state = "sword0"
			src.item_state = "sword0"
			src.w_class = 2
		src.add_fingerprint(user)
		return

/obj/item/toy/katana
	name = "replica katana"
	desc = "Woefully underpowered in D20."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "katana"
	item_state = "katana"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 5
	throwforce = 5
	w_class = 3
	attack_verb = list("attacked", "slashed", "stabbed", "sliced")

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
	var/colour = "#A10808" //RGB
	var/shadeColour = "#220000" //RGB
	var/uses = 30 //0 for unlimited uses
	var/instant = 0
	var/colourName = "red" //for updateIcon purposes
	var/style_type = /datum/writing_style/crayon
	var/datum/writing_style/style

/obj/item/toy/crayon/New()
	..()

	style = new style_type

/obj/item/toy/crayon/proc/Format(var/mob/user,var/text,var/obj/item/weapon/paper/P)
	return style.Format(text,src,user,P)

/obj/item/toy/crayon/suicide_act(mob/user)
	viewers(user) << "<span class = 'danger'><b>[user] is jamming the [src.name] up \his nose and into \his brain. It looks like \he's trying to commit suicide.</b></span>"
	return (BRUTELOSS|OXYLOSS)




/*
 * Snap pops viral shit
 */
/obj/item/toy/snappop/virus
	name = "unstable goo"
	desc = "Your palm is oozing this stuff!"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "red slime extract"
	throwforce = 30.0
	throw_speed = 10
	throw_range = 30
	w_class = 1


/obj/item/toy/snappop/virus/throw_impact(atom/hit_atom)
	..()
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	new /obj/effect/decal/cleanable/ash(src.loc)
	src.visible_message("<span class = 'danger'>The [src.name] explodes!</span>","</span class = 'danger'>You hear a bang!</span>")


	playsound(src, 'sound/effects/snap.ogg', 50, 1)
	del(src)





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
	src.visible_message("<span class = 'danger'>The [src.name] explodes!</span>","<span class = 'danger'>You hear a snap!</span>")
	playsound(src, 'sound/effects/snap.ogg', 50, 1)
	del(src)

/obj/item/toy/snappop/Crossed(H as mob|obj)
	if((ishuman(H))) //i guess carp and shit shouldn't set them off
		var/mob/living/carbon/M = H
		if(M.m_intent == "run")
			M << "<span class = 'warning'>You step on the snap pop!</span>"

			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(2, 0, src)
			s.start()
			new /obj/effect/decal/cleanable/ash(src.loc)
			src.visible_message("<span class = 'danger'>The [src.name] explodes!</span>","<span class = 'danger'>You hear a snap!</span>")
			playsound(src, 'sound/effects/snap.ogg', 50, 1)
			del(src)

/*
 * Water flower
 */
/obj/item/toy/waterflower
	name = "Water Flower"
	desc = "A seemingly innocent sunflower...with a twist."
	icon = 'icons/obj/harvest.dmi'
	icon_state = "sunflower"
	item_state = "sunflower"
	var/empty = 0
	flags = 0

/obj/item/toy/waterflower/New()
	. = ..()
	create_reagents(10)
	reagents.add_reagent("water", 10)

/obj/item/toy/waterflower/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/toy/waterflower/afterattack(atom/A as mob|obj, mob/user as mob)

	if (istype(A, /obj/item/weapon/storage/backpack ) || istype(A, /obj/structure/stool/bed/chair/vehicle/clowncart))
		return

	else if (locate (/obj/structure/table, src.loc))
		return

	else if (istype(A, /obj/structure/reagent_dispensers/watertank) && get_dist(src,A) <= 1)
		A.reagents.trans_to(src, 10)
		user << "<span class = 'notice'>You refill your flower!</span>"
		return

	else if (src.reagents.total_volume < 1)
		src.empty = 1
		user << "<span class = 'notice'>Your flower has run dry!</span>"
		return

	else
		src.empty = 0


		var/obj/effect/decal/D = new/obj/effect/decal/(get_turf(src))
		D.name = "water"
		D.icon = 'icons/obj/chemical.dmi'
		D.icon_state = "chempuff"
		D.create_reagents(5)
		src.reagents.trans_to(D, 1)
		playsound(get_turf(src), 'sound/effects/spray3.ogg', 50, 1, -6)

		spawn(0)
			for(var/i=0, i<1, i++)
				step_towards(D,A)
				D.reagents.reaction(get_turf(D))
				for(var/atom/T in get_turf(D))
					D.reagents.reaction(T)
					if(ismob(T) && T:client)
						T:client << "<span class = 'danger'>[user] has sprayed you with water!</span>"
				sleep(4)
			del(D)

		return

/obj/item/toy/waterflower/examine(mob/user)
	..()
	user << "[src.reagents.total_volume] units of water left!"

/*
 * Mech prizes
 */
/obj/item/toy/prize
	icon = 'icons/obj/toy.dmi'
	icon_state = "ripleytoy"
	var/cooldown = 0

//all credit to skasi for toy mech fun ideas
/obj/item/toy/prize/attack_self(mob/user as mob)
	if(cooldown < world.time - 8)
		user << "<span class='notice'>You play with [src].</span>"
		playsound(user, 'sound/mecha/mechstep.ogg', 20, 1)
		cooldown = world.time

/obj/item/toy/prize/attack_hand(mob/user as mob)
	if(loc == user)
		if(cooldown < world.time - 8)
			user << "<span class='notice'>You play with [src].</span>"
			playsound(user, 'sound/mecha/mechturn.ogg', 20, 1)
			cooldown = world.time
			return
	..()

/obj/item/toy/prize/ripley
	name = "toy ripley"
	desc = "Mini-Mecha action figure! Collect them all! 1/11."

/obj/item/toy/prize/fireripley
	name = "toy firefighting ripley"
	desc = "Mini-Mecha action figure! Collect them all! 2/11."
	icon_state = "fireripleytoy"

/obj/item/toy/prize/deathripley
	name = "toy deathsquad ripley"
	desc = "Mini-Mecha action figure! Collect them all! 3/11."
	icon_state = "deathripleytoy"

/obj/item/toy/prize/gygax
	name = "toy gygax"
	desc = "Mini-Mecha action figure! Collect them all! 4/11."
	icon_state = "gygaxtoy"


/obj/item/toy/prize/durand
	name = "toy durand"
	desc = "Mini-Mecha action figure! Collect them all! 5/11."
	icon_state = "durandprize"

/obj/item/toy/prize/honk
	name = "toy H.O.N.K."
	desc = "Mini-Mecha action figure! Collect them all! 6/11."
	icon_state = "honkprize"

/obj/item/toy/prize/marauder
	name = "toy marauder"
	desc = "Mini-Mecha action figure! Collect them all! 7/11."
	icon_state = "marauderprize"

/obj/item/toy/prize/seraph
	name = "toy seraph"
	desc = "Mini-Mecha action figure! Collect them all! 8/11."
	icon_state = "seraphprize"

/obj/item/toy/prize/mauler
	name = "toy mauler"
	desc = "Mini-Mecha action figure! Collect them all! 9/11."
	icon_state = "maulerprize"

/obj/item/toy/prize/odysseus
	name = "toy odysseus"
	desc = "Mini-Mecha action figure! Collect them all! 10/11."
	icon_state = "odysseusprize"

/obj/item/toy/prize/phazon
	name = "toy phazon"
	desc = "Mini-Mecha action figure! Collect them all! 11/11."
	icon_state = "phazonprize"

/obj/item/toy/katana
	name = "replica katana"
	desc = "Woefully underpowered in D20."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "katana"
	item_state = "katana"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 5
	throwforce = 5
	w_class = 3
	attack_verb = list("attacked", "slashed", "stabbed", "sliced")



/*
 *	Taken from /tg/
 */
/obj/item/toy/cards
	name = "deck of cards"
	desc = "A deck of space-grade playing cards."
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_full"

	var/list/cards = list()

/obj/item/toy/cards/New()
	..()
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

/obj/item/toy/cards/attack_hand(mob/user as mob)
	var/choice = null
	if(!cards.len)
		src.icon_state = "deck_empty"
		user << "<span class = 'notice'>There are no more cards to draw.</span>"
		return
	var/obj/item/toy/singlecard/H = new/obj/item/toy/singlecard(user.loc)
	choice = cards[1]
	H.cardname = choice
	H.parentdeck = src
	src.cards -= choice
	H.pickup(user)
	user.put_in_active_hand(H)
	src.visible_message("<span class = 'notice'>[user] draws a card from the deck.</span>",
						"<span class = 'notice'>You draw a card from the deck.")
	if(cards.len > 26)
		src.icon_state = "deck_full"
	else if(cards.len > 10)
		src.icon_state = "deck_half"
	else if(cards.len > 1)
		src.icon_state = "deck_low"

/obj/item/toy/cards/attack_self(mob/user as mob)
	cards = shuffle(cards)
	playsound(user, 'sound/items/cardshuffle.ogg', 50, 1)
	user.visible_message("<span class = 'notice'>[user] shuffles the deck.</span>",
						 "<span class = 'notice'>You shuffle the deck.</span>")

/obj/item/toy/cards/attackby(obj/item/toy/singlecard/C, mob/living/user)
	..()
	if(istype(C))
		if(C.parentdeck == src)
			src.cards += C.cardname
			user.u_equip(C)
			user.visible_message("<span class = 'notice'>[user] adds a card to the bottom of the deck.</span>",
								 "You add the card to the bottom of the deck.</span>")
			qdel(C)
		else
			user << "<span class = 'warning'>You can't mix cards from other decks.</span>"
		if(cards.len > 26)
			src.icon_state = "deck_full"
		else if(cards.len > 10)
			src.icon_state = "deck_half"
		else if(cards.len > 1)
			src.icon_state = "deck_low"

/obj/item/toy/cards/attackby(obj/item/toy/cardhand/C, mob/living/user)
	..()
	if(istype(C))
		if(C.parentdeck == src)
			src.cards += C.currenthand
			user.u_equip(C)
			user.visible_message("<span class = 'notice'>[user] puts their hand of cards into the deck.</span>",
								 "<span class = 'notice'>You put the hand into the deck.</span>")
			qdel(C)
		else
			user << "<span class = 'warning'>You can't mix cards from other decks.</span>"
		if(cards.len > 26)
			src.icon_state = "deck_full"
		else if(cards.len > 10)
			src.icon_state = "deck_half"
		else if(cards.len > 1)
			src.icon_state = "deck_low"

/obj/item/toy/cards/MouseDrop(atom/over_object)
	var/mob/M = usr
	if(usr.stat || !ishuman(usr) || !usr.canmove || usr.restrained())
		return
	if(Adjacent(usr))
		if(over_object == M)
			M.put_in_hands(src)
			usr << "<span class = 'notice'>You pick up the deck.</span>"
		else if(istype(over_object, /obj/screen))
			switch(over_object.name)
				if("r_hand")
					M.u_equip(src)
					M.put_in_r_hand(src)
					usr << "<span class = 'notice'>You pick up the deck.</span>"
				if("l_hand")
					M.u_equip(src)
					M.put_in_l_hand(src)
					usr << "<span class = 'notice'>You pick up the deck.</span>"
	else
		usr << "<span class = 'warning'>You can't reach it from here.</span>"

/obj/item/toy/cardhand
	name = "hand of cards"
	desc = "A nmber of cards not in a deck, customarily held in ones hand."
	icon = 'icons/obj/toy.dmi'
	icon_state = "hand2"
	var/list/currenthand = list()
	var/obj/item/toy/cards/parentdeck = null
	var/choice = null

/obj/item/toy/cardhand/attack_self(mob/user as mob)
	user.set_machine(src)
	interact(user)

/obj/item/toy/cardhand/interact(mob/user)
	var/dat = "You have: <br>"
	for(var/t in currenthand)
		dat += "<a href = '?src=\ref[src];pick=[t]'>A [t].</a><br>"
	dat += "Which card will you remove next?"
	var/datum/browser/popup = new(user, "cardhand", "Hand of Cards", 400, 240)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.set_content(dat)
	popup.open()

/obj/item/toy/cardhand/Topic(href, href_list)
	if(..())
		return
	if(usr.stat || !ishuman(usr) || !usr.canmove)
		return
	var/mob/living/carbon/cardUser = usr
	if(href_list["pick"])
		if(cardUser.get_item_by_slot(slot_l_hand) == src || cardUser.get_item_by_slot(slot_r_hand) == src)
			var/choice = href_list["pick"]
			var/obj/item/toy/singlecard/C = new/obj/item/toy/singlecard(cardUser.loc)
			src.currenthand -= choice
			C.parentdeck = src.parentdeck
			C.cardname = choice
			C.pickup(cardUser)
			cardUser.put_in_any_hand_if_possible(C)
			cardUser.visible_message("<span class = 'notice'>[cardUser] draws a card from \his hand.<span>",
									 "<span class = 'notice'>You take the [C.cardname] from your hand.</span>")
			interact(cardUser)

			if(src.currenthand.len < 3)
				src.icon_state = "hand2"
			else if(src.currenthand.len < 4)
				src.icon_state = "hand3"
			else if(src.currenthand.len < 5)
				src.icon_state = "hand4"

			if(src.currenthand.len == 1)
				var/obj/item/toy/singlecard/N = new/obj/item/toy/singlecard(src.loc)
				N.parentdeck = src.parentdeck
				N.cardname = src.currenthand[1]
				cardUser.u_equip(src)
				N.pickup(cardUser)
				cardUser.put_in_any_hand_if_possible(N)
				cardUser << "<span class = 'notice'>You also take [currenthand[1]] and hold it.</span>"
				cardUser << browse(null, "window=cardhand")
				qdel(src)
		return

/obj/item/toy/cardhand/attackby(obj/item/toy/singlecard/C, mob/living/user)
	if(istype(C))
		if(C.parentdeck == src.parentdeck)
			src.currenthand += C.cardname
			user.u_equip(C)
			user.visible_message("<span class = 'notice'>[user] adds a card to their hand.</span>",
								 "<span class = 'notice'>You add the [C.cardname] to your hand.</span>")
			interact(user)
			if(currenthand.len > 4)
				src.icon_state = "hand5"
			if(currenthand.len > 3)
				src.icon_state = "hand4"
			if(currenthand.len > 2)
				src.icon_state = "hand3"
			qdel(C)
		else
			user << "span class = 'warning'> You can't mix cards from other decks.</span>"


/obj/item/toy/singlecard
	name = "card"
	desc = "\a card"
	icon = 'icons/obj/toy.dmi'
	icon_state = "singlecard_down"
	var/cardname = null
	var/obj/item/toy/cards/parentdeck = null
	var/flipped = 0
	pixel_x = -5

/obj/item/toy/singlecard/examine(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/cardUser = user
		if(cardUser.get_item_by_slot(slot_l_hand) == src || cardUser.get_item_by_slot(slot_r_hand) == src)
			cardUser.visible_message("<span class = 'notice'>[cardUser] checks \his card.",
									 "<span class = 'notice'>The card reads: [src.cardname]</span>")
		else
			cardUser << "<span class = 'notice'>You need to have the card in your hand to check it.</span>"

/obj/item/toy/singlecard/verb/Flip()
	set name = "Flip Card"
	set category = "Object"
	set src in range(1)
	if(usr.stat || !ishuman(usr) || !usr.canmove || usr.restrained())
		return
	if(!flipped)
		src.flipped = 1
		if(cardname)
			src.icon_state = "sc_[cardname]"
			src.name = src.cardname
		else
			src.icon_state = "sc_Ace of Spades"
			src.name = "What Card"
		src.pixel_x = 5
	else if(flipped)
		src.flipped = 0
		src.icon_state = "singlecard_down"
		src.name = "card"
		src.pixel_x = -5

/obj/item/toy/singlecard/attackby(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/toy/singlecard/))
		var/obj/item/toy/singlecard/C = I
		if(C.parentdeck == src.parentdeck)
			var/obj/item/toy/cardhand/H = new/obj/item/toy/cardhand(user.loc)
			H.currenthand += C.cardname
			H.currenthand += src.cardname
			H.parentdeck = C.parentdeck
			user.u_equip(C)
			H.pickup(user)
			user.put_in_active_hand(H)
			user << "<span class = 'notice'>You combine the [C.cardname] and the [src.cardname] into a hand.</span>"
			qdel(C)
			qdel(src)
		else
			user << "<span class = 'notice'>You can't mix cards from other decks.</span>"

/obj/item/toy/singlecard/attack_self(mob/user)
	if(usr.stat || !ishuman(usr) || !usr.canmove || usr.restrained())
		return
	Flip()

/*
 * OMG THEIF
 */
/obj/item/toy/gooncode
	name = "Goonecode"
	desc = "The holy grail of all programmers."
	icon = 'icons/obj/module.dmi'
	icon_state = "gooncode"

	suicide_act(mob/user)
		viewers(user) << "<span class = 'danger'>[user] is using [src.name]! It looks like \he's  trying to re-add poo!</span>"
		return (BRUTELOSS|FIRELOSS|TOXLOSS|OXYLOSS)


/obj/item/toy/minimeteor
	name = "Mini Meteor"
	desc = "Relive the horror of a meteor shower! SweetMeat-eor. Co is not responsible for any injury caused by Mini Meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "flaming"

	attack_self(mob/user as mob)
		playsound(user, 'sound/effects/bamf.ogg', 20, 1)

/obj/item/device/whisperphone
	name = "whisperphone"
	desc = "A device used to project your voice. Quietly."
	icon_state = "megaphone"
	item_state = "radio"
	w_class = 1.0
	flags = FPRINT
	siemens_coefficient = 1

	var/spamcheck = 0

/obj/item/device/whisperphone/attack_self(mob/living/user as mob)
	if (user.client)
		if(user.client.prefs.muted & MUTE_IC)
			src << "<span class = 'warning'>You cannot speak in IC (muted).</span>"
			return
	if(!ishuman(user))
		user << "<span class = 'warning'>You don't know how to use this!</span>"
		return
	if(user:miming || user.silent)
		user << "<span class = 'warning'>You find yourself unable to speak at all.</span>"
		return
	if(spamcheck)
		user << "<span class = 'warning'>\The [src] needs to recharge!</span>"
		return

	var/message = copytext(sanitize(input(user, "'Shout' a message?", "Whisperphone", null)  as text),1,MAX_MESSAGE_LEN)
	if(!message)
		return
	message = capitalize(message)
	if ((src.loc == user && usr.stat == 0))

		for(var/mob/O in (viewers(user)))
			O.show_message("<B>[user]</B> broadcasts, <i>\"[message]\"</i>",2)
		spamcheck = 1
		spawn(20)
			spamcheck = 0
		return


/obj/item/toy/gasha
	icon = 'icons/obj/toy.dmi'
	icon_state = "greyshirt"
	var/cooldown = 0

/obj/item/toy/gasha/greyshirt
	name = "toy greyshirt"
	desc = "Now with kung-fu grip action!"

/obj/item/toy/gasha/greytide
	name = "toy greytide"
	desc = "Includes small pieces, not for children under or above the age of 5."
	icon_state = "greytide"

/obj/item/toy/gasha/newcop
	name = "toy nuke-op"
	desc = "Mildly explosive."
	icon_state = "newcop"

/obj/item/toy/gasha/jani
	name = "toy janitor"
	desc = "cleanliness is next to godliness!"
	icon_state = "jani"

/obj/item/toy/gasha/miner
	name = "toy miner"
	desc = "Walk softly, and carry a ton of monsters."
	icon_state = "miner"

/obj/item/toy/gasha/clown
	name = "toy clown"
	desc = "HONK"
	icon_state = "clown"

/obj/item/toy/gasha/goliath
	name = "toy goliath"
	desc = "Now with fully articulated tentacles!"
	icon_state = "goliath"

/obj/item/toy/gasha/basilisk
	name = "toy basilisk"
	desc = "The eye has a strange shine to it."
	icon_state = "basilisk"

/obj/item/toy/gasha/mommi
	name = "toy MoMMI"
	desc = "*ping"
	icon_state = "mommi"

/obj/item/toy/gasha/guard
	name = "toy guard spider"
	desc = "Miniature giant spider, or just 'spider' for short."
	icon_state = "guard"

/obj/item/toy/gasha/hunter
	name = "toy hunter spider"
	desc = "As creepy looking as the real thing, but with 80% less chance of killing you."
	icon_state = "hunter"

/obj/item/toy/gasha/nurse
	name = "toy nurse spider"
	desc = "Not exactly what most people are hoping for when they hear 'nurse'."
	icon_state = "nurse"

/obj/item/toy/gasha/alium
	name = "toy alien"
	desc = "Has a great smile."
	icon_state = "alium"

/obj/item/toy/gasha/pomf
	name = "toy chicken"
	desc = "Cluck."
	icon_state = "pomf"

/obj/item/toy/gasha/engi
	name = "toy engineer"
	desc = "Probably better at setting up power than the real thing!"
	icon_state = "engi"

/obj/item/toy/gasha/atmos
	name = "toy atmos-tech"
	desc = "Can withstand high temperatures without melting!"
	icon_state = "atmos"

/obj/item/toy/gasha/sec
	name = "toy security"
	desc = "Won't search you on code green!"
	icon_state = "sec"

/obj/item/toy/gasha/plasman
	name = "toy plasmaman"
	desc = "All of the undending agony of the real thing, but in tiny plastic form!"
	icon_state = "plasman"

/obj/item/toy/gasha/shard
	name = "toy supermatter shard"
	desc = "Nowhere near as explosive as the real one."
	icon_state = "shard"

/obj/item/toy/gasha/corgitoy
	name = "plush corgi"
	desc = "Perfect for the pet owner on a tight budget!"
	icon_state = "corgitoy"

/obj/item/toy/gasha/borertoy
	name = "Mini Borer"
	desc = "Probably not something you should be playing with"
	icon_state = "borertoy"

/obj/item/toy/gasha/minislime
	name = "Pygmy Grey Slime"
	desc = "If you experience a tingling sensation in your hands, please stop playing with your pygmy slime immediately."
	icon_state = "minislime"

/obj/item/toy/gasha/AI/attack_self(mob/user as mob)
	if(cooldown < world.time - 8)
		playsound(user, 'sound/vox/doop.wav', 20, 1)
		cooldown = world.time

/obj/item/toy/gasha/AI/attack_hand(mob/user as mob)
	if(loc == user)
		if(cooldown < world.time - 8)
			playsound(user, 'sound/vox/doop.wav', 20, 1)
			cooldown = world.time
			return
	..()

/obj/item/toy/gasha/AI
	name = "Mini AI"
	desc = "Does not open doors."
	icon_state = "AI"

/obj/item/toy/gasha/AI/malf
	name = "Mini Malf"
	desc = "May be a bad influence for cyborgs"
	icon_state = "malfAI"

/obj/item/toy/gasha/minibutt/attack_self(mob/user as mob)
	if(cooldown < world.time - 8)
		playsound(user, 'sound/misc/fart.ogg', 20, 1)
		cooldown = world.time

/obj/item/toy/gasha/minibutt/attack_hand(mob/user as mob)
	if(loc == user)
		if(cooldown < world.time - 8)
			playsound(user, 'sound/misc/fart.ogg', 20, 1)
			cooldown = world.time
			return
	..()

/obj/item/toy/gasha/minibutt
	name = "mini-buttbot"
	desc = "Made from real gnome butts!"
	icon_state = "minibutt"