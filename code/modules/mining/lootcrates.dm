// this can go anywhere, probably best in the crates file i guess
/obj/structure/closet/crate/secure/loot
	desc = "What could be inside?"
	name = "Abandoned Crate"
	icon_state = "securecrate"
	icon_opened = "securecrateopen"
	icon_closed = "securecrate"
	var/code = null
	var/lastattempt = null
	var/attempts = 3
	locked = 1
	var/min = 1
	var/max = 10

/obj/structure/closet/crate/secure/loot/New()
	..()
	code = rand(min,max)
	overlays = null
	overlays += redlight
	var/loot = rand(1,7)
	switch(loot)
		if(1)	//420 get *burp*
			new/obj/item/weapon/reagent_containers/food/drinks/bottle/rum(src)
			new/obj/item/weapon/reagent_containers/food/drinks/bottle/rum(src)
			new/obj/item/weapon/reagent_containers/food/drinks/bottle/rum(src)
			new/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiadeus(src)
			new/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiadeus(src)
			new/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey(src)
			new/obj/item/weapon/lighter/zippo(src)
		if(2)	//stash
			new/obj/item/weapon/pickaxe/drill(src)
			new/obj/item/device/taperecorder(src)
			new/obj/item/clothing/suit/space/rig(src)
			new/obj/item/clothing/head/helmet/space/rig(src)
		if(3)	//rich as McNano
			new/obj/item/weapon/coin/diamond(src)
			new/obj/item/weapon/coin/diamond(src)
			new/obj/item/weapon/coin/diamond(src)
			new/obj/item/weapon/coin/diamond(src)
			new/obj/item/weapon/coin/diamond(src)
			new/obj/item/weapon/coin/diamond(src)
			new/obj/item/weapon/coin/diamond(src)
			new/obj/item/weapon/coin/diamond(src)
			new/obj/item/weapon/coin/diamond(src)
			new/obj/item/weapon/coin/diamond(src)
			new/obj/item/weapon/coin/diamond(src)
			new/obj/item/weapon/coin/diamond(src)
		if(4)	//Clown's Tomb
			new/mob/living/carbon/monkey(src)
			new/obj/item/clothing/shoes/clown_shoes(src)
			new/obj/item/clothing/under/rank/clown(src)
			new/obj/item/clothing/mask/gas/clown_hat(src)
			new/obj/item/weapon/bananapeel(src)
		if(5)	// HAPPY BIRTHDAY
			new/obj/item/weapon/reagent_containers/food/snacks/sliceable/birthdaycake(src)
			new/obj/item/weapon/reagent_containers/food/snacks/sliceable/birthdaycake(src)
			new/obj/item/weapon/reagent_containers/food/snacks/sliceable/birthdaycake(src)
			new/obj/item/weapon/reagent_containers/food/snacks/sliceable/birthdaycake(src)
			new/obj/item/weapon/reagent_containers/food/snacks/sliceable/birthdaycake(src)
			new/obj/item/weapon/reagent_containers/food/snacks/sliceable/birthdaycake(src)
			new/obj/item/weapon/lighter/zippo(src)
		if(6)
			return
		if(7)
			new/obj/item/weapon/reagent_containers/glass/beaker/old(src)

/obj/structure/closet/crate/secure/loot/attack_hand(mob/user as mob)
	if(locked)
		user << "\blue The crate is locked with a H.O.N.K-code lock."
		var/input = input(usr, "Enter digit from [min] to [max].", "Deca-Code Lock", "") as num
		if (input == src.code)
			user << "\blue The crate unlocks!"
			overlays = null
			overlays += greenlight
			src.locked = 0
		else if (input == null || input > max || input < min) user << "You leave the crate alone."
		else
			user << "\red A red light flashes."
			src.lastattempt = input
			src.attempts--
			if (src.attempts == 0)
				user << "\red The crate's anti-tamper system activates!"
				var/turf/T = get_turf(src.loc)
				explosion(T, 0, 1, 2, 1)
				del(src)
				return
	else return ..()

/obj/structure/closet/crate/secure/loot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(locked)
		if (istype(W, /obj/item/weapon/card/emag))
			user << "\blue The crate unlocks!"
			overlays = null
			overlays += greenlight
			src.locked = 0
		if (istype(W, /obj/item/device/multitool))
			user << "H.O.N.K-CODE LOCK REPORT:"
			if (src.attempts == 1) user << "\red * Anti-Tamper Bomb will activate on next failed access attempt."
			else user << "* Anti-Tamper Bomb will activate after [src.attempts] failed access attempts."
			if (lastattempt == null)
				user << "* No attempt has been made to open the crate thus far."
				return
			// hot and cold
			if (src.code > src.lastattempt) user << "* Last access attempt lower than expected code."
			else user << "* Last access attempt higher than expected code."
		else ..()
	else ..()
