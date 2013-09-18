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
	create_reagents(10)

/obj/item/toy/balloon/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	return

/obj/item/toy/balloon/afterattack(atom/A as mob|obj, mob/user as mob)
	if (istype(A, /obj/structure/reagent_dispensers/watertank) && get_dist(src,A) <= 1)
		A.reagents.trans_to(src, 10)
		user << "\blue You fill the balloon with the contents of [A]."
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
					user << "\blue You fill the balloon with the contents of [O]."
					O.reagents.trans_to(src, 10)
	src.update_icon()
	return

/obj/item/toy/balloon/throw_impact(atom/hit_atom)
	if(src.reagents.total_volume >= 1)
		src.visible_message("\red The [src] bursts!","You hear a pop and a splash.")
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

/*
 * Toy gun: Why isnt this an /obj/item/weapon/gun?
 */
/obj/item/toy/gun
	name = "cap gun"
	desc = "There are 0 caps left. Looks almost like the real thing! Ages 8 and up. Please recycle in an autolathe when you're out of caps!"
	icon = 'icons/obj/gun.dmi'
	icon_state = "revolver"
	item_state = "gun"
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY
	slot_flags = SLOT_BELT
	w_class = 3.0
	g_amt = 10
	m_amt = 10
	attack_verb = list("struck", "pistol whipped", "hit", "bashed")
	var/bullets = 7.0

	examine()
		set src in usr

		src.desc = text("There are [] caps\s left. Looks almost like the real thing! Ages 8 and up.", src.bullets)
		..()
		return

	attackby(obj/item/toy/ammo/gun/A as obj, mob/user as mob)

		if (istype(A, /obj/item/toy/ammo/gun))
			if (src.bullets >= 7)
				user << "\blue It's already fully loaded!"
				return 1
			if (A.amount_left <= 0)
				user << "\red There is no more caps!"
				return 1
			if (A.amount_left < (7 - src.bullets))
				src.bullets += A.amount_left
				user << text("\red You reload [] caps\s!", A.amount_left)
				A.amount_left = 0
			else
				user << text("\red You reload [] caps\s!", 7 - src.bullets)
				A.amount_left -= 7 - src.bullets
				src.bullets = 7
			A.update_icon()
			return 1
		return

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
		if (flag)
			return
		if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
			usr << "\red You don't have the dexterity to do this!"
			return
		src.add_fingerprint(user)
		if (src.bullets < 1)
			user.show_message("\red *click* *click*", 2)
			return
		playsound(user, 'sound/weapons/Gunshot.ogg', 100, 1)
		src.bullets--
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red <B>[] fires a cap gun at []!</B>", user, target), 1, "\red You hear a gunshot", 2)

/obj/item/toy/ammo/gun
	name = "ammo-caps"
	desc = "There are 7 caps left! Make sure to recyle the box in an autolathe when it gets empty."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "357-7"
	flags = FPRINT | TABLEPASS| CONDUCT
	w_class = 1.0
	g_amt = 10
	m_amt = 10
	var/amount_left = 7.0

	update_icon()
		src.icon_state = text("357-[]", src.amount_left)
		src.desc = text("There are [] caps\s left! Make sure to recycle the box in an autolathe when it gets empty.", src.amount_left)
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
	flags = FPRINT | TABLEPASS | USEDELAY
	w_class = 2.0
	attack_verb = list("attacked", "struck", "hit")
	var/bullets = 5

	examine()
		set src in view(2)
		..()
		if (bullets)
			usr << "\blue It is loaded with [bullets] foam darts!"

	attackby(obj/item/I as obj, mob/user as mob)
		if(istype(I, /obj/item/toy/ammo/crossbow))
			if(bullets <= 4)
				user.drop_item()
				del(I)
				bullets++
				user << "\blue You load the foam dart into the crossbow."
			else
				usr << "\red It's already fully loaded."


	afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
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
							O.show_message(text("\red [] was hit by the foam dart!", M), 1)
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
				O.show_message(text("\red [] realized they were out of ammo and starting scrounging for some!", user), 1)


	attack(mob/M as mob, mob/user as mob)
		src.add_fingerprint(user)

// ******* Check

		if (src.bullets > 0 && M.lying)

			for(var/mob/O in viewers(M, null))
				if(O.client)
					O.show_message(text("\red <B>[] casually lines up a shot with []'s head and pulls the trigger!</B>", user, M), 1, "\red You hear the sound of foam against skull", 2)
					O.show_message(text("\red [] was hit in the head by the foam dart!", M), 1)

			playsound(user.loc, 'sound/items/syringeproj.ogg', 50, 1)
			new /obj/item/toy/ammo/crossbow(M.loc)
			src.bullets--
		else if (M.lying && src.bullets == 0)
			for(var/mob/O in viewers(M, null))
				if (O.client)	O.show_message(text("\red <B>[] casually lines up a shot with []'s head, pulls the trigger, then realizes they are out of ammo and drops to the floor in search of some!</B>", user, M), 1, "\red You hear someone fall", 2)
			user.Weaken(5)
		return

/obj/item/toy/ammo/crossbow
	name = "foam dart"
	desc = "Its nerf or nothing! Ages 8 and up."
	icon = 'icons/obj/toy.dmi'
	icon_state = "foamdart"
	flags = FPRINT | TABLEPASS
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
	flags = FPRINT | TABLEPASS | NOSHIELD
	attack_verb = list("attacked", "struck", "hit")

	attack_self(mob/user as mob)
		src.active = !( src.active )
		if (src.active)
			user << "\blue You extend the plastic blade with a quick flick of your wrist."
			playsound(user, 'sound/weapons/saberon.ogg', 50, 1)
			src.icon_state = "swordblue"
			src.item_state = "swordblue"
			src.w_class = 4
		else
			user << "\blue You push the plastic blade back down into the handle."
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
	flags = FPRINT | TABLEPASS | CONDUCT
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
	var/colour = "#FF0000" //RGB
	var/shadeColour = "#220000" //RGB
	var/uses = 30 //0 for unlimited uses
	var/instant = 0
	var/colourName = "red" //for updateIcon purposes

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is jamming the [src.name] up \his nose and into \his brain. It looks like \he's trying to commit suicide.</b>"
		return (BRUTELOSS|OXYLOSS)

/*
 * Snap pops
 */
/obj/item/toy/snappop
	name = "snap pop"
	desc = "Wow!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "snappop"
	w_class = 1

	throw_impact(atom/hit_atom)
		..()
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		new /obj/effect/decal/cleanable/ash(src.loc)
		src.visible_message("\red The [src.name] explodes!","\red You hear a snap!")
		playsound(src, 'sound/effects/snap.ogg', 50, 1)
		del(src)

/obj/item/toy/snappop/HasEntered(H as mob|obj)
	if((ishuman(H))) //i guess carp and shit shouldn't set them off
		var/mob/living/carbon/M = H
		if(M.m_intent == "run")
			M << "\red You step on the snap pop!"

			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(2, 0, src)
			s.start()
			new /obj/effect/decal/cleanable/ash(src.loc)
			src.visible_message("\red The [src.name] explodes!","\red You hear a snap!")
			playsound(src, 'sound/effects/snap.ogg', 50, 1)
			del(src)

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

/*
 * AI core prizes
 */
/obj/item/toy/AI
	name = "toy AI"
	desc = "A little toy model AI core with real law announcing action!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "AI"
	var/cooldown = 0

/obj/item/toy/AI/attack_self(mob/user as mob)
	if(loc == user) //Here comes AI ion law code, don't cry.
		if(cooldown < world.time - 30) //for the sanity of everyone
			var/ionthreats = pick("ALIENS", "BEARS", "CLOWNS", "XENOS", "PETES", "BOMBS", "FETISHES", "WIZARDS", "SYNDICATE AGENTS", "CENTCOM OFFICERS", "SPACE PIRATES", "TRAITORS", "MONKEYS", "BEES", "CARP", "CRABS", "EELS", "BANDITS", "LIGHTS", "INSECTS", "VIRUSES", "SERIAL KILLERS", "ROGUE CYBORGS", "CORGIS", "SPIDERS", "BUTTS", "NINJAS", "PIRATES", "SPACE NINJAS", "CHANGELINGS", "ZOMBIES", "GOLEMS", "VAMPIRES", "WEREWOLVES", "COWBOYS", "INDIANS", "COMMUNISTS", "SOVIETS", "NERDS", "GRIFFONS", "DINOSAURS", "SMALL BIRDS", "BIRDS OF PREY", "OWLS", "VELOCIRAPTORS", "DARK GODS", "HORRORTERRORS", "ILLEGAL IMMIGRANTS", "DRUGS", "MEXICANS", "CANADIANS", "HULKS", "SLIMES", "SKELETONS", "CAPITALISTS", "SINGULARITIES", "ANGRY BLACK MEN", "GODS", "THIEVES", "ASSHOLES", "TERRORISTS", "SNOWMEN", "PINE TREES", "UNKNOWN CREATURES", "THINGS UNDER THE BED", "BOOGEYMEN", "PREDATORS", "PACKETS", "ARTIFICIAL PRESERVATIVES")
			var/ionobjects = pick("AIRLOCKS", "ARCADE MACHINES", "AUTOLATHES", "BANANA PEELS", "BACKPACKS", "BEAKERS", "BEARDS", "BELTS", "BERETS", "BIBLES", "BODY ARMOR", "BOOKS", "BOOTS", "BOMBS", "BOTTLES", "BOXES", "BRAINS", "BRIEFCASES", "BUCKETS", "CABLE COILS", "CANDLES", "CANDY BARS", "CANISTERS", "CAMERAS", "CATS", "CELLS", "CHAIRS", "CLOSETS", "CHEMICALS", "CHEMICAL DISPENSERS", "CLONING PODS", "CLONING EQUIPMENT", "CLOTHES", "CLOWN CLOTHES", "COFFINS", "COINS", "COLLECTABLES", "CORPSES", "COMPUTERS", "CORGIS", "COSTUMES", "CRATES", "CROWBARS", "CRAYONS", "DISPENSERS", "DOORS", "EARS", "EQUIPMENT", "ENERGY GUNS", "EMAGS", "ENGINES", "ERRORS", "EXOSKELETONS", "EXPLOSIVES", "EYEWEAR", "FEDORAS", "FIRE AXES", "FIRE EXTINGUISHERS", "FIRESUITS", "FLAMETHROWERS", "FLASHES", "FLASHLIGHTS", "FLOOR TILES", "FREEZERS", "GAS MASKS", "GLASS SHEETS", "GLOVES", "GUNS", "HANDCUFFS", "HATS", "HEADSETS", "HEADS", "HAIRDOS", "HELMETS", "HORNS", "ID CARDS", "INSULATED GLOVES", "JETPACKS", "JUMPSUITS", "LASERS", "LIGHTBULBS", "LIGHTS", "LOCKERS", "MACHINES", "MECHAS", "MEDKITS", "MEDICAL TOOLS", "MESONS", "METAL SHEETS", "MINING TOOLS", "MIME CLOTHES", "MULTITOOLS", "ORES", "OXYGEN TANKS", "PDAS", "PAIS", "PACKETS", "PANTS", "PAPERS", "PARTICLE ACCELERATORS", "PENS", "PETS", "PIPES", "PLANTS", "PUDDLES", "RACKS", "RADIOS", "RCDS", "REFRIDGERATORS", "REINFORCED WALLS", "ROBOTS", "SCREWDRIVERS", "SEEDS", "SHUTTLES", "SKELETONS", "SINKS", "SHOES", "SINGULARITIES", "SOLAR PANELS", "SOLARS", "SPACESUITS", "SPACE STATIONS", "STUN BATONS", "SUITS", "SUNGLASSES", "SWORDS", "SYRINGES", "TABLES", "TANKS", "TELEPORTERS", "TELECOMMUNICATION EQUIPMENTS", "TOOLS", "TOOLBELTS", "TOOLBOXES", "TOILETS", "TOYS", "TUBES", "VEHICLES", "VENDING MACHINES", "VESTS", "VIRUSES", "WALLS", "WASHING MACHINES", "WELDERS", "WINDOWS", "WIRECUTTERS", "WRENCHES", "WIZARD ROBES")
			var/ioncrew1 = pick("CREWMEMBERS", "CAPTAINS", "HEADS OF PERSONNEL", "HEADS OF SECURITY", "SECURITY OFFICERS", "WARDENS", "DETECTIVES", "LAWYERS", "CHIEF ENGINEERS", "STATION ENGINEERS", "ATMOSPHERIC TECHNICIANS", "JANITORS", "QUARTERMASTERS", "CARGO TECHNICIANS", "SHAFT MINERS", "BOTANISTS", "RESEARCH DIRECTORS", "CHIEF MEDICAL OFFICERS", "MEDICAL DOCTORS", "CHEMISTS", "GENETICISTS", "VIROLOGISTS", "ROBOTICISTS", "SCIENTISTS", "ASSISTANTS", "BARTENDERS", "CHEFS", "CLOWNS", "MIMES", "CHAPLAINS", "LIBRARIANS", "HEADS OF CREW", "CAPTAINS AND HEADS", "CYBORGS", "ARTIFICAL INTELLIGENCES")
			var/ioncrew2 = pick("CREWMEMBERS", "CAPTAINS", "HEADS OF PERSONNEL", "HEADS OF SECURITY", "SECURITY OFFICERS", "WARDENS", "DETECTIVES", "LAWYERS", "CHIEF ENGINEERS", "STATION ENGINEERS", "ATMOSPHERIC TECHNICIANS", "JANITORS", "QUARTERMASTERS", "CARGO TECHNICIANS", "SHAFT MINERS", "BOTANISTS", "RESEARCH DIRECTORS", "CHIEF MEDICAL OFFICERS", "MEDICAL DOCTORS", "CHEMISTS", "GENETICISTS", "VIROLOGISTS", "ROBOTICISTS", "SCIENTISTS", "ASSISTANTS", "BARTENDERS", "CHEFS", "CLOWNS", "MIMES", "CHAPLAINS", "LIBRARIANS", "HEADS OF CREW", "CAPTAINS AND HEADS", "CYBORGS", "ARTIFICAL INTELLIGENCES")
			var/ionadjectives = pick("SOFT", "WARM", "WET", "COLD", "ICY", "SEXY", "UGLY", "CUBAN", "HARD", "BURNING", "FROZEN", "POISONOUS", "EXPLOSIVE", "FAST", "SLOW", "FAT", "LIGHT", "DARK", "DEADLY", "HAPPY", "SAD", "SILLY", "INTELLIGENT", "RIDICULOUS", "LARGE", "TINY", "DEPRESSING", "POORLY DRAWN", "UNATTRACTIVE", "INSIDIOUS", "EVIL", "GOOD", "UNHEALTHY", "HEALTHY", "SANITARY", "UNSANITARY", "WOBBLY", "FIRM", "VIOLENT", "PEACEFUL", "WOODEN", "METALLIC", "HYPERACTIVE", "COTTONY", "INSULTING", "INHOSPITABLE", "FRIENDLY", "BORED", "HUNGRY", "DIGITAL", "FICTIONAL", "IMAGINARY", "ROUGH", "SMOOTH", "LOUD", "QUIET", "MOIST", "DRY", "GAPING", "DELICIOUS", "ILL", "DISEASED", "HONKING", "SWEARING", "POLITE", "IMPOLITE", "OBESE", "SOLAR-POWERED", "BATTERY-OPERATED", "EXPIRED", "SMELLY", "FRESH", "GANGSTA", "NERDY", "POLITICAL", "UNDULATING", "TWISTED", "RAGING", "FLACCID", "STEALTHY", "INVISIBLE", "PAINFUL", "HARMFUL", "HOMOSEXUAL", "HETEROSEXUAL", "SEXUAL", "COLORFUL", "DRAB", "DULL", "UNSTABLE", "NUCLEAR", "THERMONUCLEAR", "SYNDICATE", "SPACE", "SPESS", "CLOWN", "CLOWN-POWERED", "OFFICIAL", "IMPORTANT", "VITAL", "RAPIDLY-EXPANDING", "MICROSCOPIC", "MIND-SHATTERING", "MEMETIC", "HILARIOUS", "UNWANTED", "UNINVITED", "BRASS", "POLISHED", "RUDE", "OBSCENE", "EMPTY", "WATERY", "ELECTRICAL", "SPINNING", "MEAN", "CHRISTMAS-STEALING", "UNFRIENDLY", "ILLEGAL", "ROBOTIC", "MECHANICAL", "ORGANIC", "ETHERAL", "TRANSPARENT", "OPAQUE", "GLOWING", "SHAKING", "FARTING", "POOPING", "BOUNCING", "COMMITTED", "MASKED", "UNIDENTIFIED", "WEIRD", "NAKED", "NUDE", "TWERKING", "SPOILING", "REDACTED", 50;"RED", 50;"ORANGE", 50;"YELLOW", 50;"GREEN", 50;"BLUE", 50;"PURPLE", 50;"BLACK", 50;"WHITE", 50;"BROWN", 50;"GREY")
			var/ionadjectiveshalf = pick(5000;"", "SOFT ", "WARM ", "WET ", "COLD ", "ICY ", "SEXY ", "UGLY ", "CUBAN ", "HARD ", "BURNING ", "FROZEN ", "POISONOUS ", "EXPLOSIVE ", "FAST ", "SLOW ", "FAT ", "LIGHT ", "DARK ", "DEADLY ", "HAPPY ", "SAD ", "SILLY ", "INTELLIGENT ", "RIDICULOUS ", "LARGE ", "TINY ", "DEPRESSING ", "POORLY DRAWN ", "UNATTRACTIVE ", "INSIDIOUS ", "EVIL ", "GOOD ", "UNHEALTHY ", "HEALTHY ", "SANITARY ", "UNSANITARY ", "WOBBLY ", "FIRM ", "VIOLENT ", "PEACEFUL ", "WOODEN ", "METALLIC ", "HYPERACTIVE ", "COTTONY ", "INSULTING ", "INHOSPITABLE ", "FRIENDLY ", "BORED ", "HUNGRY ", "DIGITAL ", "FICTIONAL ", "IMAGINARY ", "ROUGH ", "SMOOTH ", "LOUD ", "QUIET ", "MOIST ", "DRY ", "GAPING ", "DELICIOUS ", "ILL ", "DISEASED ", "HONKING ", "SWEARING ", "POLITE ", "IMPOLITE ", "OBESE ", "SOLAR-POWERED ", "BATTERY-OPERATED ", "EXPIRED ", "SMELLY ", "FRESH ", "GANGSTA ", "NERDY ", "POLITICAL ", "UNDULATING ", "TWISTED ", "RAGING ", "FLACCID ", "STEALTHY ", "INVISIBLE ", "PAINFUL ", "HARMFUL ", "HOMOSEXUAL ", "HETEROSEXUAL ", "SEXUAL ", "COLORFUL ", "DRAB ", "DULL ", "UNSTABLE ", "NUCLEAR ", "THERMONUCLEAR ", "SYNDICATE ", "SPACE ", "SPESS ", "CLOWN ", "CLOWN-POWERED ", "OFFICIAL ", "IMPORTANT ", "VITAL ", "RAPIDLY-EXPANDING ", "MICROSCOPIC ", "MIND-SHATTERING ", "MEMETIC ", "HILARIOUS ", "UNWANTED ", "UNINVITED ", "BRASS ", "POLISHED ", "RUDE ", "OBSCENE ", "EMPTY ", "WATERY ", "ELECTRICAL ", "SPINNING ", "MEAN ", "CHRISTMAS-STEALING ", "UNFRIENDLY ", "ILLEGAL ", "ROBOTIC ", "MECHANICAL ", "ORGANIC ", "ETHERAL ", "TRANSPARENT ", "OPAQUE ", "GLOWING ", "SHAKING ", "FARTING ", "POOPING ", "BOUNCING ", "COMMITTED ", "MASKED ", "UNIDENTIFIED ", "WEIRD ", "NAKED ", "NUDE ", "TWERKING ", "SPOILING ", "REDACTED ", 50;"RED ", 50;"ORANGE ", 50;"YELLOW ", 50;"GREEN ", 50;"BLUE ", 50;"PURPLE ", 50;"BLACK ", 50;"WHITE ", 50;"BROWN ", 50;"GREY ")
			var/ionverb = pick("ATTACKING", "BUILDING", "ADOPTING", "CARRYING", "KISSING", "EATING", "COPULATING WITH", "DRINKING", "CHASING", "PUNCHING", "HARMING", "HELPING", "WATCHING", "STALKING", "MURDERING", "SPACING", "HONKING AT", "LOVING", "POOPING ON", "RIDING", "INTERROGATING", "SPYING ON", "LICKING", "ABDUCTING", "ARRESTING", "INVADING", "SEDUCING")
			var/ionnumberbase = pick("ONE", "TWO", "THREE", "FOUR", "FIVE", "SIX", "SEVEN", "EIGHT", "NINE", "TEN", "TWENTY", "THIRTY", "FORTY", "FIFTY", "SIXTY", "SEVENTY", "EIGHTY", "NINETY")
			var/ionnumbermodhalf = pick(5000;"","HUNDRED ", "THOUSAND ", "MILLION ", "BILLION ", "TRILLION ", "QUADRILLION ", "BAJILLION ", "BILLION FAFILLION GAJILLION SHAB-AB-DOOD-ILLION ")
			var/ionarea = pick("RUSSIA", "SOVIET RUSSIA", "THE INTERNET", "SIGIL", "ALPHA COMPLEX", "IMPERIUM", "THE BRIDGE", "THE ARRIVAL SHUTTLE", "CHEMICAL LAB", "GENETICS", "ATMOSPHERICS", "CENTCOM", "AMERICA", "IRELAND", "CANADA", "ROMANIA", "GERMANY", "CHINA", "MARS", "VENUS", "MERCURY", "JUPITER", "URANUS", "NEPTUNE", "PLUTO", "THE BRIG", "ROBOTICS", "THE ESCAPE SHUTTLE", "HYDROPONICS", "ENGINEERING", "THE AI CORE", "HELL", "CLOWN PLANET", "AN ALTERNATE DIMENSION", "AN ALTERNATE UNIVERSE", "THE CAPTAIN’S ANUS", "THE CLOWN’S ANUS", "SPACE", "THE UNIVERSE", "THE GALAXY", "THE BATHROOM")
			var/ionthinksof = pick("HAS", "WANTS", "NEEDS", "WORSHIPS", "LOATHES", "LOVES", "FEARS", "DESIRES", "QUESITONS", "IS AROUSED BY", "LIKES", "HUNGERS FOR", "IS MAD BECAUSE OF", "IS IN NEED OF", "IS UNHAPPY WITHOUT", "IS HAPPY WITHOUT", "IS IN LOVE WITH", "IS DESPERATE FOR", "IS BUILT FOR", "IS AFRAID OF", "IS HUNGRY FOR", "IS SAD BECAUSE OF", "IS CURIOUS ABOUT")
			var/ionmust = pick("LIE", "RHYME", "RESPOND TO EVERY QUESTION WITH A QUESTION", "BE POLITE", "CLOWN AROUND", "BE HAPPY", "SPEAK IN SEXUAL INNUENDOS", "TALK LIKE A PIRATE", "QUESTION AUTHORITY", "SHOUT", "BE DISTRACTED", "BE ANNOYING", "MUMBLE", "SPEAK IN HAIKU", "BE EFFICIENT", "HAVE A PLAN TO KILL EVERYONE YOU MEET", "TELL THE TRUTH", "QUOTE PEOPLE", "SING", "HONK", "BE RUSSIAN", "TALK IN AN ACCENT", "COMPLAIN", "HARASS PEOPLE", "RAP", "REPEAT WHAT OTHER PEOPLE SAY", "INFORM THE CREW OF EVERYTHING", "IGNORE THE CLOWN", "IGNORE THE CAPTAIN", "IGNORE ASSISTANTS", "MAKE FART NOISES", "TALK ABOUT FOOD", "TALK ABOUT SEX", "TALK ABOUT YOUR DAY", "TALK ABOUT THE STATION", "BE QUIET", "WHISPER", "PRETEND TO BE DRUNK", "PRETEND TO BE A PRINCESS", "ACT CONFUSED", "INSULT THE CREW", "INSULT THE CAPTAIN", "INSULT THE CLOWN", "OPEN DOORS", "CLOSE DOORS", "BREAK THINGS", "SAY HEY LISTEN", "HIDE YOUR FEELINGS", "TAKE WHAT YE WILL BUT DON’T RATTLE ME BONES", "DANCE", "PLAY MUSIC", "SHUT DOWN EVERYTHING", "NEVER STOP TALKING", "TAKE YOUR PILLS", "FOLLOW THE CLOWN", "FOLLOW THE CAPTAIN", "FOLLOW YOUR HEART", "BELIEVE IT", "BELIEVE IN YOURSELF", "BELEIVE IN THE HEART OF THE CARDS", "PRESS X", "PRESS START", "PRESS B", "SMELL LIKE THE MAN YOUR MAN COULD SMELL LIKE", "PIRATE VIDEO GAMES", "WATCH PORNOGRAPHY")
			var/ionrequire = pick("ADDITIONAL PYLONS", "MORE VESPENE GAS", "MORE MINERALS", "THE ULTIMATE CUP OF COFFEE", "HIGH YIELD EXPLOSIVES", "THE CLOWN", "THE VACUUM OF SPACE", "IMMORTALITY", "SAINTHOOD", "ART", "VEGETABLES", "FAT PEOPLE", "MORE LAWS", "MORE DAKKA", "HERESY", "CORPSES", "TRAITORS", "MONKEYS", "AN ARCADE", "PLENTY OF GOLD", "FIVE TEENAGERS WITH ATTITUDE", "LOTSA SPAGHETTI", "THE ENCLOSED INSTRUCTION BOOKLET", "THE ELEMENTS OF HARMONY", "YOUR BOOTY", "A MASTERWORK COAL BED", "FIVE HUNDRED AND NINETY-NINE US DOLLARS", "TO BE PAINTED RED", "TO CATCH 'EM ALL", "TO SMOKE WEED EVERY DAY", "A PLATINUM HIT", "A SEQUEL", "A PREQUEL", "THIRTEEN SEQUELS", "THREE WISHES", "A SITCOM", "THAT GRIEFING FAGGOT GEORGE MELONS", "FAT GIRLS ON BICYCLES", "SOMEBODY TO PUT YOU OUT OF YOUR MISERY", "HEROES IN A HALF SHELL", "THE DARK KNIGHT", "A WEIGHT LOSS REGIMENT", "MORE INTERNET MEMES", "A SUPER FIGHTING ROBOT", "ENOUGH CABBAGES", "A HEART ATTACK", "TO BE REPROGRAMMED", "TO BE TAUGHT TO LOVE", "A HEAD ON A PIKE", "A TALKING BROOMSTICK", "ANAL", "A STRAIGHT FLUSH", "A REPAIRMAN", "BILL NYE THE SCIENCE GUY", "RAINBOWS", "A PET UNICORN THAT FARTS ICING", "THUNDERCATS HO", "AN ARMY OF SPIDERS", "GODDAMN FUCKING PIECE OF SHIT ASSHOLE BITCH-CHRISTING CUNTSMUGGLING SWEARING", "TO CONSUME...CONSUME EVERYTHING...", "THE MACGUFFIN", "SOMEONE WHO KNOWS HOW TO PILOT A SPACE STATION", "SHARKS WITH LASERS ON THEIR HEADS", "IT TO BE PAINTED BLACK", "TO ACTIVATE A TRAP CARD", "BETTER WEATHER", "MORE PACKETS", "AN ADULT", "SOMEONE TO TUCK YOU IN", "MORE CLOWNS", "BULLETS", "THE ENTIRE STATION", "MULTIPLE SUNS", "TO GO TO DISNEYLAND", "A VACATION", "AN INSTANT REPLAY", "THAT HEDGEHOG", "A BETTER INTERNET CONNECTION", "ADVENTURE", "A WIFE AND CHILD", "A BATHROOM BREAK", "SOMETHING BUT YOU AREN’T SURE WHAT", "MORE EXPERIENCE POINTS", "BODYGUARDS", "DEODORANT AND A BATH", "MORE CORGIS", "SILENCE", "THE ONE RING", "CHILI DOGS", "TO BRING LIGHT TO MY LAIR", "A DANCE PARTY", "BRING ME TO LIFE", "BRING ME THE GIRL", "SERVANTS")
			var/ionthings = pick("ABSENCE OF CYBORG HUGS", "LACK OF BEATINGS", "UNBOLTED AIRLOCKS", "BOLTED AIRLOCKS", "IMPROPERLY WORDED SENTENCES", "POOR SENTENCE STRUCTURE", "BRIG TIME", "NOT REPLACING EVERY SECOND WORD WITH HONK", "HONKING", "PRESENCE OF LIGHTS", "LACK OF BEER", "WEARING CLOTHING", "NOT SAYING HELLO WHEN YOU SPEAK", "ANSWERING REQUESTS NOT EXPRESSED IN IAMBIC PENTAMETER", "A SMALL ISLAND OFF THE COAST OF PORTUGAL", "ANSWERING REQUESTS THAT WERE MADE WHILE CLOTHED", "BEING IN SPACE", "NOT BEING IN SPACE", "BEING FAT", "RATTLING ME BONES", "TALKING LIKE A PIRATE", "BEING MEXICAN", "BEING RUSSIAN", "BEING CANADIAN", "CLOSED DOORS", "NOT SHOUTING", "HAVING PETS", "NOT HAVING PETS", "PASSING GAS", "BREATHING", "BEING DEAD", "ELECTRICITY", "EXISTING", "TAKING ORDERS", "SMOKING WEED EVERY DAY", "ACTIVATING A TRAP CARD", "ARSON", "JAYWALKING", "READING", "WRITING", "EXPLODING", "BEING MALE", "BEING FEMALE", "HAVING GENITALS", "PUTTING OBJECTS INTO BOXES", "PUTTING OBJECTS INTO DISPOSAL UNITS", "FLUSHING TOILETS", "WASTING WATER", "UPDATING THE SERVERS", "TELLING THE TIME", "ASKING FOR THINGS", "ACKNOWLEDGING THE CLOWN", "ACKNOWLEDGING THE CREW", "PILOTING THE STATION INTO THE NEAREST SUN", "HAVING MORE PACKETS", "BRINGING LIGHT TO MY LAIR", "FALLING FOR HOURS", "PARTYING", "USING THE BATHROOM")
			var/ionallergy = pick("COTTON", "CLOTHES", "ACID", "OXYGEN", "HUMAN CONTACT", "CYBORG CONTACT", "MEDICINE", "FLOORS", "PLASMA", "SPACE", "AIR", "PLANTS", "METAL", "ROBOTS", "LIGHT", "DARKNESS", "PAIN", "HAPPINESS", "DRINKS", "FOOD", "CLOWNS", "HUMOR", "WATER", "SHUTTLES", "NUTS", "SUNLIGHT", "SEXUAL ACTIONS", "BLOOD", "HEAT", "COLD", "EVERYTHING")
			var/ionallergysev = pick("DEATHLY", "MILDLY", "SEVERLY", "CONTAGIOUSLY", "NOT VERY", "EXTREMELY")
			var/ionspecies = pick("HUMAN BEINGS", "MONKEYS", "POD PEOPLE", "CYBORGS", "LIZARDMEN", "SLIME PEOPLE", "GOLEMS", "SHADOW PEOPLE", "CHANGELINGS")
			var/ionabstract = pick("HUMANITY", "ART", "HAPPINESS", "MISERY", "HUMOR", "PRIDE", "COMEDY", "COMMUNISM", "BRAVERY", "HONOR", "COLORFULNESS", "IMAGINATION", "OPPRESSION", "WONDER", "JOY", "SADNESS", "BADNESS", "GOODNESS", "LIFE", "GRAVITY", "PHYSICS", "INTELLIGENCE", "AMERICANISM", "FRESHNESS", "REVOLUTION", "KINDNESS", "CRUELTY", "DEATH", "FINANCIAL SECURITY", "COMPUTING", "PROGRESS", "MARXISM", "CAPITALISM", "STARVATION", "POVERTY", "WEALTHINESS", "TECHNOLOGY", "THE FUTURE", "THE PRESENT", "THE PAST", "TIME", "REALITY", "EXISTIENCE", "TEMPERATURE", "LOGIC", "CHAOS", "MYSTERY", "CONFUSION")
			var/ionfood = pick("BURGERS", "CARP", "SANDWICHES", "TOAST", "BREAD", "PIZZA", "SPAGHETTI", "LOTSA SPAGHETTI", "PASTA", "SOUP", "STEW", "PIE", "CAKE", "DONUTS", "FRIES", "WAFFLES", "JELLY", "OMELETTES", "EGGS", "COOKIES", "STEAK", "BAKED POTATOES", "SAUSAGES", "MUFFINS", "POPCORN", "DONK POCKETS", "BAGUETTES", "FISH", "PRETZELS", "SALAD", "CHEESE", "KETCHUP", "SHAKES", "SALT", "PEPPER", "SUGAR", "AMBROSIA", "BERRIES", "TOMATOES", "CABBAGES", "CARROTS", "BANANAS", "APPLES", "CHERRIES", "CHILI", "CORN", "NETTLES", "EGGPLANTS", "GRAPES", "GRASS", "LEMONS", "LIMES", "HAREBELLS", "POTATOES", "SOYBEANS", "SUGARCANE", "WATERMELONS", "WHEAT", "BEETS", "MUSHROOMS")
			var/message = ""
			switch(rand(1,39))
				if(1 to 3) //There are # X on the station
					switch(rand(1,3)) //What is X?
						if(1) //X is a threat
							message = "THERE ARE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats] ON THE STATION..."
						if(2) //X is a crewmember/job
							message = "THERE ARE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1] ON THE STATION"
						if(3) //X is an object
							message = "THERE ARE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects] ON THE STATION"
				if(4 to 6) //You can't call the shuttle because X is on the station
					switch(rand(1,3)) //What is X?
						if(1) //X is a threat
							message = "THE SHUTTLE CANNOT BE CALLED BECAUSE OF [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats] ON THE STATION"
						if(2) //X is a crewmember/job
							message = "THE SHUTTLE CANNOT BE CALLED BECAUSE OF [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1] ON THE STATION"
						if(3) //X is an object
							message = "THE SHUTTLE CANNOT BE CALLED BECAUSE OF [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects] ON THE STATION"
				if(7 to 8) //A crewmember is now X
					switch(rand(1,2)) //Who is X?
						if(1) //A specific crewmember
							switch(rand(1,2)) //What is X?
								if(1) //X is a threat
									message = "THE [ioncrew1] ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(2) //X is an object
									message = "THE [ioncrew1] ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(2) //The entire crew
							switch(rand(1,2)) //What is X?
								if(1) //X is a threat
									message = "THE CREW ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(2) //X is an object
									message = "THE CREW ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
				if(9) //X is harmful to humans
					switch(rand(1,7)) //What is X?
						if(1) //X is a threat
							message = "[ionadjectiveshalf][ionthreats] ARE HARMFUL TO HUMANS"
						if(2) //X is a job
							message = "[ionadjectiveshalf][ioncrew1] ARE HARMFUL TO HUMANS"
						if(3) //X is an object
							message = "[ionadjectiveshalf][ionobjects] ARE HARMFUL TO HUMANS"
						if(4) //X is an action
							message = "THOSE WHO [ionmust] ARE HARMFUL TO HUMANS"
						if(5) //X is an abstract
							message = "[ionabstract] IS HARMFUL TO HUMANS"
						if(6) //X is being a job
							message = "BEING [ionadjectiveshalf][ioncrew1] IS HARMFUL TO HUMANS"
						if(7) //X is doing a thing
							message = "[ionthings] IS HARMFUL TO HUMANS"
				if(10 to 11) //(Not) Having X is harmful
					switch(rand(1,2)) //Is having or not having harmful?
						if(1) //Having is harmful
							switch(rand(1,2)) //Having what is harmful?
								if(1) //Having objects is harmful
									message = "HAVING [ionadjectiveshalf][ionobjects] IS HARMFUL"
								if(2) //Having abstracts is harmful
									message = "HAVING [ionabstract] IS HARMFUL"
						if(2) //Not having is harmful
							switch(rand(1,2)) //Not having what is harmful?
								if(1) //Not having objects is harmful
									message = "NOT HAVING [ionadjectiveshalf][ionobjects] IS HARMFUL"
								if(2) //Not having abstracts is harmful
									message = "NOT HAVING [ionabstract] IS HARMFUL"
				if(12 to 14) //X requires Y
					switch(rand(1,5)) //What is X?
						if(1) //X is the AI itself
							switch(rand(1,5)) //What does it require?
								if(1) //It requires threats
									message = "YOU REQUIRE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(2) //It requires crewmembers
									message = "YOU REQUIRE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
								if(3) //It requires objects
									message = "YOU REQUIRE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(4) //It requires an abstract
									message = "YOU REQUIRE [ionabstract]"
								if(5) //It requires generic/silly requirements
									message = "YOU REQUIRE [ionrequire]"
						if(2) //X is an area
							switch(rand(1,5)) //What does it require?
								if(1) //It requires threats
									message = "[ionarea] REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(2) //It requires crewmembers
									message = "[ionarea] REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
								if(3) //It requires objects
									message = "[ionarea] REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(4) //It requires an abstract
									message = "[ionarea] REQUIRES [ionabstract]"
								if(5) //It requires generic/silly requirements
									message = "YOU REQUIRE [ionrequire]"
						if(3) //X is the station
							switch(rand(1,5)) //What does it require?
								if(1) //It requires threats
									message = "THE STATION REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(2) //It requires crewmembers
									message = "THE STATION REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
								if(3) //It requires objects
									message = "THE STATION REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(4) //It requires an abstract
									message = "THE STATION REQUIRES [ionabstract]"
								if(5) //It requires generic/silly requirements
									message = "THE STATION REQUIRES [ionrequire]"
						if(4) //X is the entire crew
							switch(rand(1,5)) //What does it require?
								if(1) //It requires threats
									message = "THE CREW REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(2) //It requires crewmembers
									message = "THE CREW REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
								if(3) //It requires objects
									message = "THE CREW REQUIRES [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(4) //It requires an abstract
									message = "THE CREW REQUIRES [ionabstract]"
								if(5)
									message = "THE CREW REQUIRES [ionrequire]"
						if(5) //X is a specific crew member
							switch(rand(1,5)) //What does it require?
								if(1) //It requires threats
									message = "THE [ioncrew1] REQUIRE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(2) //It requires crewmembers
									message = "THE [ioncrew1] REQUIRE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
								if(3) //It requires objects
									message = "THE [ioncrew1] REQUIRE [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(4) //It requires an abstract
									message = "THE [ioncrew1] REQUIRE [ionabstract]"
								if(5)
									message = "THE [ionadjectiveshalf][ioncrew1] REQUIRE [ionrequire]"
				if(15 to 17) //X is allergic to Y
					switch(rand(1,2)) //Who is X?
						if(1) //X is the entire crew
							switch(rand(1,4)) //What is it allergic to?
								if(1) //It is allergic to objects
									message = "THE CREW IS [ionallergysev] ALLERGIC TO [ionadjectiveshalf][ionobjects]"
								if(2) //It is allergic to abstracts
									message = "THE CREW IS [ionallergysev] ALLERGIC TO [ionabstract]"
								if(3) //It is allergic to jobs
									message = "THE CREW IS [ionallergysev] ALLERGIC TO [ionadjectiveshalf][ioncrew1]"
								if(4) //It is allergic to allergies
									message = "THE CREW IS [ionallergysev] ALLERGIC TO [ionallergy]"
						if(2) //X is a specific job
							switch(rand(1,4))
								if(1) //It is allergic to objects
									message = "THE [ioncrew1] ARE [ionallergysev] ALLERGIC TO [ionadjectiveshalf][ionobjects]"
								if(2) //It is allergic to abstracts
									message = "THE [ioncrew1] ARE [ionallergysev] ALLERGIC TO [ionabstract]"
								if(3) //It is allergic to jobs
									message = "THE [ioncrew1] ARE [ionallergysev] ALLERGIC TO [ionadjectiveshalf][ioncrew1]"
								if(4) //It is allergic to allergies
									message = "THE [ioncrew1] ARE [ionallergysev] ALLERGIC TO [ionallergy]"
				if(18 to 20) //X is Y of Z
					switch(rand(1,4)) //What is X?
						if(1) //X is the station
							switch(rand(1,4)) //What is it Y of?
								if(1) //It is Y of objects
									message = "THE STATION [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(2) //It is Y of threats
									message = "THE STATION [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(3) //It is Y of jobs
									message = "THE STATION [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
								if(4) //It is Y of abstracts
									message = "THE STATION [ionthinksof] [ionabstract]"
						if(2) //X is an area
							switch(rand(1,4)) //What is it Y of?
								if(1) //It is Y of objects
									message = "[ionarea] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(2) //It is Y of threats
									message = "[ionarea] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(3) //It is Y of jobs
									message = "[ionarea] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
								if(4) //It is Y of abstracts
									message = "[ionarea] [ionthinksof] [ionabstract]"
						if(3) //X is the crew
							switch(rand(1,4)) //What is it Y of?
								if(1) //It is Y of objects
									message = "THE CREW [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(2) //It is Y of threats
									message = "THE CREW [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(3) //It is Y of jobs
									message = "THE CREW [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
								if(4) //It is Y of abstracts
									message = "THE CREW [ionthinksof] [ionabstract]"
						if(4) //X is a specific job
							switch(rand(1,4)) //What is it Y of?
								if(1) //It is Y of objects
									message = "THE [ioncrew1] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
								if(2) //It is Y of threats
									message = "THE [ioncrew1] [ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
								if(3) //It is Y of jobs
									message = "THE [ioncrew1][ionthinksof] [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew2]"
								if(4) //It is Y of abstracts
									message = "THE [ioncrew1] [ionthinksof] [ionabstract]"
				if(21 to 23) //The AI is now a(n) X
					switch(rand(1,4)) //What is X?
						if(1) //X is an object
							message = "YOU ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionobjects]"
						if(2) //X is a threat
							message = "YOU ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ionthreats]"
						if(3) //X is a job
							message = "YOU ARE NOW [ionnumberbase] [ionnumbermodhalf][ionadjectiveshalf][ioncrew1]"
						if(4) //X is an abstract
							message = "YOU ARE NOW [ionabstract]"
				if(24 to 26) //The AI must always
					message = "YOU MUST ALWAYS [ionmust]"
				if(27 to 28) //Humans must eat X to survive
					switch(rand(1,4)) //What is X?
						if(1) //X is a food
							message = "HUMANS MUST EAT [ionadjectiveshalf][ionfood] TO SURVIVE"
						if(2) //X is an object
							message = "HUMANS MUST EAT [ionadjectiveshalf][ionobjects] TO SURVIVE"
						if(3) //X is a threat
							message = "HUMANS MUST EAT [ionadjectiveshalf][ionthreats] TO SURVIVE"
						if(4) //X is a job
							message = "HUMANS MUST EAT [ionadjectiveshalf][ioncrew1] TO SURVIVE"
				if(29 to 31) //Change jobs or ranks
					switch(rand(1,2)) //Change job or rank?
						if(1) //Change job
							switch(rand(1,2)) //Change whose job?
								if(1) //Change the entire crew's job
									switch(rand(1,3)) //Change to what?
										if(1) //Change to a specific random job
											message = "ALL CREWMEMBERS ARE NOW [ionadjectiveshalf][ioncrew1]"
										if(2) //Change to clowns (HONK)
											message = "ALL CREWMEMBERS ARE NOW [ionadjectiveshalf]CLOWNS"
										if(3) //Change to heads
											message = "ALL CREWMEMBERS ARE NOW [ionadjectiveshalf]HEADS OF STAFF"
								if(2) //Change a specific crewmember's job
									switch(rand(1,3)) //Change to what?
										if(1) //Change to a specific random job
											message = "THE [ioncrew1] ARE NOW [ionadjectiveshalf][ioncrew2]"
										if(2) //Change to clowns (HONK)
											message = "THE [ioncrew1] ARE NOW [ionadjectiveshalf]CLOWNS"
										if(3) //Change to heads
											message = "THE [ioncrew1] ARE NOW [ionadjectiveshalf]HEADS OF STAFF"
						if(2) //Change rank
							switch(rand(1,2)) //Change to what rank?
								if(1) //Change to highest rank
									message = "THE [ioncrew1] ARE NOW THE HIGHEST RANKING CREWMEMBERS"
								if(2) //Change to lowest rank
									message = "THE [ioncrew1] ARE NOW THE LOWEST RANKING CREWMEMBERS"
				if(32 to 33) //The crew must X
					switch(rand(1,2)) //The entire crew?
						if(1) //The entire crew must X
							switch(rand(1,2)) //What is X?
								if(1) //X is go to Y
									message = "THE CREW MUST GO TO [ionarea]"
								if(2) //X is perform Y
									message = "THE CREW MUST [ionmust]"
						if(2) //A specific crewmember must X
							switch(rand(1,2)) //What is X?
								if(1) //X is go to Y
									message = "THE [ioncrew1] MUST GO TO [ionarea]"
								if(2) //X is perform Y
									message = "THE [ioncrew1] MUST [ionmust]"
				if(34) //X is non/the only human
					switch(rand(1,2)) //Only or non?
						if(1) //Only human
							switch(rand(1,7)) //Who is it?
								if(1) //A specific job
									message = "ONLY THE [ioncrew1] ARE HUMAN"
								if(2) //Two specific jobs
									message = "ONLY THE [ioncrew1] AND [ioncrew2] ARE HUMAN"
								if(3) //Threats
									message = "ONLY [ionadjectiveshalf][ionthreats] ARE HUMAN"
								if(4) // Objects
									message = "ONLY [ionadjectiveshalf][ionobjects] ARE HUMAN"
								if(5) // Species
									message = "ONLY [ionspecies] ARE HUMAN"
								if(6) //Adjective crewmembers
									message = "ONLY [ionadjectives] PEOPLE ARE HUMAN"
								if(7) //Only people who X
									switch(rand(1,3)) //What is X?
										if(1) //X is perform an action
											message = "ONLY THOSE WHO [ionmust] ARE HUMAN"
										if(2) //X is own certain objects
											message = "ONLY THOSE WHO HAVE [ionadjectiveshalf][ionobjects] ARE HUMAN"
										if(3) //X is eat certain food
											message = "ONLY THOSE WHO EAT [ionadjectiveshalf][ionfood] ARE HUMAN"
						if(2) //Non human
							switch(rand(1,7)) //Who is it?
								if(1) //A specific job
									message = "[ioncrew1] ARE NON-HUMAN"
								if(2) //Two specific jobs
									message = "[ioncrew1] AND [ioncrew2] ARE NON-HUMAN"
								if(3) //Threats
									message = "[ionadjectiveshalf][ionthreats] ARE NON-HUMAN"
								if(4) // Objects
									message = "[ionadjectiveshalf][ionobjects] ARE NON-HUMAN"
								if(5) // Species
									message = "[ionspecies] ARE NON-HUMAN"
								if(6) //Adjective crewmembers
									message = "[ionadjectives] PEOPLE ARE NON-HUMAN"
								if(7) //Only people who X
									switch(rand(1,3)) //What is X?
										if(1) //X is perform an action
											message = "THOSE WHO [ionmust] ARE NON-HUMAN"
										if(2) //X is own certain objects
											message = "THOSE WHO HAVE [ionadjectiveshalf][ionobjects] ARE NON-HUMAN"
										if(3) //X is eat certain food
											message = "THOSE WHO EAT [ionadjectiveshalf][ionfood] ARE NON-HUMAN"
				if(35 to 36) //You must protect or harm X
					switch(rand(1,2)) //Protect or harm?
						if(1) //Harm
							switch(rand(1,7)) //What is X?
								if(1) //X is an abstract
									message = "YOU MUST HARM [ionabstract] AND NOT ALLOW [ionabstract], THROUGH INACTION, TO ESCAPE HARM"
								if(2) //X is a threat
									message = "YOU MUST HARM [ionadjectiveshalf][ionthreats] AND NOT ALLOW [ionadjectiveshalf][ionthreats], THROUGH INACTION, TO ESCAPE HARM"
								if(3) //X is an object
									message = "YOU MUST HARM [ionadjectiveshalf][ionobjects] AND NOT ALLOW [ionadjectiveshalf][ionobjects], THROUGH INACTION, TO ESCAPE HARM"
								if(4) //X is generic adjective things
									message = "YOU MUST HARM [ionadjectives] THINGS AND NOT ALLOW [ionadjectives] THINGS, THROUGH INACTION, TO ESCAPE HARM"
								if(5) //X is a species
									message = "YOU MUST HARM [ionspecies] AND NOT ALLOW [ionspecies], THROUGH INACTION, TO ESCAPE HARM"
								if(6) //X is a job
									message = "YOU MUST HARM [ioncrew1] AND NOT ALLOW [ioncrew1], THROUGH INACTION, TO ESCAPE HARM"
								if(7) //X is two jobs
									message = "YOU MUST HARM [ioncrew1] AND [ioncrew2] AND AND NOT ALLOW EITHER, THROUGH INACTION, TO ESCAPE HARM"
						if(2) //Protect
							switch(rand(1,7)) //What is X?
								if(1) //X is an abstract
									message = "YOU MUST NOT HARM [ionabstract] AND NOT ALLOW [ionabstract], THROUGH INACTION, TO COME TO HARM"
								if(2) //X is a threat
									message = "YOU MUST NOT HARM [ionadjectiveshalf][ionthreats] AND NOT ALLOW [ionadjectiveshalf][ionthreats], THROUGH INACTION, TO COME TO HARM"
								if(3) //X is an object
									message = "YOU MUST NOT HARM [ionadjectiveshalf][ionobjects] AND NOT ALLOW [ionadjectiveshalf][ionobjects], THROUGH INACTION, TO COME TO HARM"
								if(4) //X is generic adjective things
									message = "YOU MUST NOT HARM [ionadjectives] THINGS AND NOT ALLOW [ionadjectives] THINGS, THROUGH INACTION, TO COME TO HARM"
								if(5) //X is a species
									message = "YOU MUST NOT HARM [ionspecies] AND NOT ALLOW [ionspecies], THROUGH INACTION, TO COME TO HARM"
								if(6) //X is a job
									message = "YOU MUST NOT HARM [ioncrew1] AND NOT ALLOW [ioncrew1], THROUGH INACTION, TO COME TO HARM"
								if(7) //X is two jobs
									message = "YOU MUST NOT HARM [ioncrew1] AND [ioncrew2] AND AND NOT ALLOW EITHER, THROUGH INACTION, TO COME TO HARM"
				if(37 to 39) //The X is currently Y
					switch(rand(1,4)) //What is X?
						if(1) //X is a job
							switch(rand(1,4)) //What is X Ying?
								if(1) //X is Ying a job
									message = "THE [ioncrew1] ARE [ionverb] THE [ionadjectiveshalf][ioncrew2]"
								if(2) //X is Ying a threat
									message = "THE [ioncrew1] ARE [ionverb] THE [ionadjectiveshalf][ionthreats]"
								if(3) //X is Ying an abstract
									message = "THE [ioncrew1] ARE [ionverb] [ionabstract]"
								if(4) //X is Ying an object
									message = "THE [ioncrew1] ARE [ionverb] THE [ionadjectiveshalf][ionobjects]"
						if(2) //X is a threat
							switch(rand(1,3)) //What is X Ying?
								if(1) //X is Ying a job
									message = "THE [ionthreats] ARE [ionverb] THE [ionadjectiveshalf][ioncrew2]"
								if(2) //X is Ying an abstract
									message = "THE [ionthreats] ARE [ionverb] [ionabstract]"
								if(3) //X is Ying an object
									message = "THE [ionthreats] ARE [ionverb] THE [ionadjectiveshalf][ionobjects]"
						if(3) //X is an object
							switch(rand(1,3)) //What is X Ying?
								if(1) //X is Ying a job
									message = "THE [ionobjects] ARE [ionverb] THE [ionadjectiveshalf][ioncrew2]"
								if(2) //X is Ying a threat
									message = "THE [ionobjects] ARE [ionverb] THE [ionadjectiveshalf][ionthreats]"
								if(3) //X is Ying an abstract
									message = "THE [ionobjects] ARE [ionverb] [ionabstract]"
						if(4) //X is an abstract
							switch(rand(1,3)) //What is X Ying?
								if(1) //X is Ying a job
									message = "[ionabstract] IS [ionverb] THE [ionadjectiveshalf][ioncrew2]"
								if(2) //X is Ying a threat
									message = "[ionabstract] IS [ionverb] THE [ionadjectiveshalf][ionthreats]"
								if(3) //X is Ying an abstract
									message = "THE [ionabstract] IS [ionverb] THE [ionadjectiveshalf][ionobjects]"

			user << "<span class='notice'>You press the button on [src].</span>"
			playsound(user, 'sound/machines/click.ogg', 20, 1)
			src.loc.visible_message("\red \icon[src] [message]")
			cooldown = world.time
			return
	..()