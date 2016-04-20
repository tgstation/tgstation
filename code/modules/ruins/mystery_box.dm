//Originally coded by ISaidNo, later modified by Kelenius. Ported from Baystation12.
// And then I, coiax, butchered the file to make a NEW BETTER mystery box

/obj/item/weapon/storage/briefcase/mystery
	name = "mystery box"
	desc = "A seemingly discarded, dusty suitcase. It has a keypad, along with scorch marks along the side."
	icon_state = "secure"
	burn_state = FIRE_PROOF

	var/code = null

	var/attempts = 3
	var/codelen = 4

	var/locked = TRUE

/obj/item/weapon/storage/briefcase/mystery/New()
	..()
	var/list/digits = list("1", "2", "3", "4", "5", "6", "7", "8", "9", "z")
	code = ""
	for(var/i = 0, i < codelen, i++)
		var/dig = pick(digits)
		code += dig

	add_loot()


/obj/item/weapon/storage/briefcase/mystery/proc/add_loot(loot)
	if(!loot)
		loot = rand(1,100)

	switch(loot)
		if(1 to 5) //5% chance
			new /obj/item/weapon/reagent_containers/food/drinks/bottle/rum(src)
			new /obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/deus(src)
			new /obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey(src)
			new /obj/item/weapon/lighter(src)
		if(6 to 10)
			new /obj/item/weapon/bedsheet(src)
			new /obj/item/weapon/kitchen/knife(src)
			new /obj/item/weapon/wirecutters(src)
			new /obj/item/weapon/screwdriver(src)
			new /obj/item/weapon/weldingtool(src)
			new /obj/item/weapon/hatchet(src)
			new /obj/item/weapon/crowbar(src)
		if(11 to 15)
			new /obj/item/weapon/reagent_containers/glass/beaker/bluespace(src)
		if(16 to 20)
			for(var/i in 1 to 10)
				new /obj/item/weapon/ore/diamond(src)
		if(21 to 25)
			for(var/i in 1 to 5)
				new /obj/item/weapon/poster/contraband(src)
		if(26 to 30)
			for(var/i in 1 to 3)
				new /obj/item/weapon/reagent_containers/glass/beaker/noreact(src)
		if(31 to 35)
			new /obj/item/seeds/cash(src)
		if(36 to 40)
			new /obj/item/weapon/melee/baton(src)
		if(41 to 45)
			new /obj/item/clothing/under/shorts/red(src)
			new /obj/item/clothing/under/shorts/blue(src)
		if(46 to 50)
			new /obj/item/clothing/under/chameleon(src)
			for(var/i in 1 to 7)
				new /obj/item/clothing/tie/horrible(src)
		if(51 to 52) // 2% chance
			new /obj/item/weapon/melee/classic_baton(src)
		if(53 to 54)
			new /obj/item/toy/balloon(src)
		if(55 to 56)
			var/newitem = pick(subtypesof(/obj/item/toy/prize))
			new newitem(src)
		if(57 to 58)
			new /obj/item/toy/syndicateballoon(src)
		if(59 to 60)
			new /obj/item/weapon/gun/energy/kinetic_accelerator/hyper(src)
			new /obj/item/clothing/suit/space(src)
			new /obj/item/clothing/head/helmet/space(src)
		if(61 to 62)
			for(var/i in 1 to 5)
				new /obj/item/clothing/head/kitty(src)
				new /obj/item/clothing/tie/petcollar(src)
		if(63 to 64)
			for(var/i in 1 to rand(4, 7))
				var/newcoin = pick(/obj/item/weapon/coin/silver, /obj/item/weapon/coin/silver, /obj/item/weapon/coin/silver, /obj/item/weapon/coin/iron, /obj/item/weapon/coin/iron, /obj/item/weapon/coin/iron, /obj/item/weapon/coin/gold, /obj/item/weapon/coin/diamond, /obj/item/weapon/coin/plasma, /obj/item/weapon/coin/uranium)
				new newcoin(src)
		if(65)
			new /obj/item/clothing/suit/ianshirt(src)
			new /obj/item/clothing/suit/hooded/ian_costume(src)
		if(66)
			// don't worry, even if you fuck up and fail to unlock the
			// case, the immortal candy bar will tp somewhere else
			new /obj/item/weapon/reagent_containers/food/snacks/candy/youtried
		if(67 to 68)
			for(var/i in 1 to rand(4, 7))
				var /newitem = pick(subtypesof(/obj/item/weapon/stock_parts) - /obj/item/weapon/stock_parts/subspace)
				new newitem(src)
		if(69 to 70)
			for(var/i in 1 to 5)
				new /obj/item/weapon/ore/bluespace_crystal(src)
		if(71 to 72)
			new /obj/item/weapon/pickaxe/drill(src)
		if(73 to 74)
			new /obj/item/weapon/pickaxe/drill/jackhammer(src)
		if(75 to 76)
			new /obj/item/weapon/pickaxe/diamond(src)
		if(77 to 78)
			new /obj/item/weapon/pickaxe/drill/diamonddrill(src)
		if(79 to 80)
			new /obj/item/weapon/cane(src)
			new /obj/item/clothing/head/collectable/tophat(src)
		if(81 to 82)
			new /obj/item/weapon/gun/energy/plasmacutter(src)
		if(83 to 84)
			new /obj/item/toy/katana(src)
		if(85 to 86)
			new /obj/item/weapon/defibrillator/compact(src)
		if(87) //1% chance
			new /obj/item/weed_extract(src)
		if(88)
			new /obj/item/organ/internal/brain(src)
		if(89)
			new /obj/item/organ/internal/brain/alien(src)
		if(90)
			new /obj/item/organ/internal/heart(src)
		if(91)
			new /obj/item/device/soulstone/anybody(src)
		if(92)
			new /obj/item/weapon/katana(src)
		if(93)
			new /obj/item/weapon/dnainjector/xraymut(src)
		if(94)
			new /obj/item/weapon/storage/backpack/clown(src)
			new /obj/item/clothing/under/rank/clown(src)
			new /obj/item/clothing/shoes/clown_shoes(src)
			new /obj/item/device/pda/clown(src)
			new /obj/item/clothing/mask/gas/clown_hat(src)
			new /obj/item/weapon/bikehorn(src)
			new /obj/item/toy/crayon/rainbow(src)
			new /obj/item/weapon/reagent_containers/spray/waterflower(src)
		if(95)
			new /obj/item/clothing/under/rank/mime(src)
			new /obj/item/clothing/shoes/sneakers/black(src)
			new /obj/item/device/pda/mime(src)
			new /obj/item/clothing/gloves/color/white(src)
			new /obj/item/clothing/mask/gas/mime(src)
			new /obj/item/clothing/head/beret(src)
			new /obj/item/clothing/suit/suspenders(src)
			new /obj/item/toy/crayon/mime(src)
			new /obj/item/weapon/reagent_containers/food/drinks/bottle/bottleofnothing(src)
		if(96)
			new /obj/item/weapon/hand_tele(src)
		if(97)
			new /obj/item/clothing/mask/balaclava
			new /obj/item/weapon/gun/projectile/automatic/pistol(src)
			new /obj/item/ammo_box/magazine/m10mm(src)
		if(98)
			new /obj/item/weapon/katana/cursed(src)
		if(99)
			new /obj/item/weapon/storage/belt/champion(src)
			new /obj/item/clothing/mask/luchador(src)
		if(100)
			new /obj/item/clothing/head/bearpelt(src)

/obj/item/weapon/storage/briefcase/mystery/attack_hand(mob/user)
	if(locked)
		user << "<span class='notice'>You try entering some digits on the keypad.</span>"
		var/input = input(usr, "Enter [codelen] digits.", "Deca-Code Lock", "") as text
		if(user.canUseTopic(src, 1))
			if (input == code)
				user << "<span class='notice'>The [src] unlocks!</span>"
				unlock()
			else
				src.audible_message("The [src] makes an annoyed buzzing sound.", "A red light flashes on the [src].")
				playsound(loc, 'sound/machines/buzz-two.ogg', 50, 0)
				attempts--
				if(attempts == 0)
					boom(user)
	else
		return ..()

/obj/item/weapon/storage/briefcase/mystery/proc/unlock()
	src.audible_message("Tinny congratulatory music plays, as you hear the [src] unlock.", "The lights on the [src] all go green.")
	playsound(loc, 'sound/effects/yourwinner.ogg', 50, 0)
	locked = FALSE
	desc += " The lights on it are all green."
	// It's not relockable, it is now an ordinary briefcase


/obj/item/weapon/storage/briefcase/mystery/Destroy()
	// If for any reason it's blown up without playing by the rules,
	// you only get the youtried wrapper
	if(locked)
		for(var/atom/movable/AM in src)
			qdel(AM)

		src += new /obj/item/trash/candy/youtried
	..()

/obj/item/weapon/storage/briefcase/mystery/attack_animal(mob/user)
	if(locked)
		boom(user)
	else ..()

/obj/item/weapon/storage/briefcase/mystery/attackby(obj/item/weapon/W, mob/user)
	if(locked)
		if(istype(W, /obj/item/weapon/card/emag))
			// No.
			boom(user)
		else if(istype(W, /obj/item/device/multitool))
			user << "<span class='notice'>The [W] doesn't seem to be able to interface with the [src].</span>"
		else ..()
	else ..()

/obj/item/weapon/storage/briefcase/mystery/proc/boom(mob/user)
	if(!locked)
		// Anti-tamper system is disabled when unlocked.
		// Anti-tamper shouldn't trigger when unlocked anyway
		return

	src.visible_message("[src]'s anti-tamper system activates! Light flashes through the gaps! You smell smoke...", "A harsh alarm sounds, and then a hiss. You smell smoke...")

	for(var/atom/movable/AM in src)
		qdel(AM)

	src += new /obj/item/trash/candy/youtried

/obj/item/weapon/reagent_containers/food/snacks/candy/youtried
	name = "'UTried' candy"
	desc = "It\'s a delicious 'UTried' candy bar, still in its wrapper. For some reason, you can only open it a little bit."
	// Yes, this is an INFINITE candy bar. Which makes the empty wrapper
	// even more consuming.
	trash = /obj/item/weapon/reagent_containers/food/snacks/candy/youtried

/obj/item/weapon/reagent_containers/food/snacks/candy/youtried/New()
	..()
	// Why would't ghosts want to follow an immortal candy bar?
	poi_list |= src

/obj/item/weapon/reagent_containers/food/snacks/candy/youtried/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] eating the [src] far too quickly! It doesn't look like \he's going to stop!")
	src.visible_message("<span class='warning'>The [src] shines brightly for a moment, and then dims.</span>", "You hear a faint hum.")
	var/turf/T = get_turf(user)

	var/obj/item/weapon/reagent_containers/food/snacks/candy/youtried/child = new(T)
	child.name = " (" + user.real_name + " flavour)"
	child.desc = " This bar seems to be flavoured with " + user.real_name + "."
	qdel(child)
	// Why yes, this does make a new immortal candy bar and then teleport
	// it somewhere else.
	// I SURE HOPE THIS ISN'T HOW IMMORTAL CANDY BARS REPRODUCE, UNTIL
	// SOMEONE TRIES TO LOCK IT AWAY, BUT ONE DAY, PANDORA OPENS THE BOX
	// AND THE BARS WILL CONSUME US ALL
	return (TOXLOSS | OXYLOSS)

/obj/item/weapon/reagent_containers/food/snacks/candy/youtried/Destroy()
	// I DID MOST DEFINITELY NOT COPY AND PASTE THIS FROM THE NUKE DISK
	// CODE, HOW DARE YOU ACCUSE ME OF SUCH A THING
	if(blobstart.len > 0)
		var/turf/targetturf = get_turf(pick(blobstart))
		var/turf/diskturf = get_turf(src)
		if(ismob(loc))
			var/mob/M = loc
			M.remove_from_mob(src)
		if(istype(loc, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = loc
			S.remove_from_storage(src, diskturf)
		forceMove(targetturf) //move the disc, so ghosts remain orbitting it even if it's "destroyed"
	else
		throw EXCEPTION("Unable to find a blobstart landmark")
	return QDEL_HINT_LETMELIVE //Cancel destruction regardless of success

/obj/item/trash/candy/youtried
	name = "'UTried' candy wrapper"
	desc = "It\'s a 'UTried' candy wrapper. It's slightly burnt, and smells toxic. A warning on it warns the wrapper is not suitable for consumption by carbon based lifeforms."
	burn_state = FIRE_PROOF // CANNOT BURN WHAT HAS ALREADY BEEN BURNT
	// But the wrapper is not immortal, it's just annoying.

/obj/item/trash/candy/youtried/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is swallowing the [src]. It looks like \he's trying to commit suicide...</span>")

	// TODO when the stomach organ is implemented, move it to that instead
	if(istype(user, /mob/living/carbon))
		var/mob/living/carbon/C = user
		C.stomach_contents += src
	src.loc = user

	return (TOXLOSS | OXYLOSS)
