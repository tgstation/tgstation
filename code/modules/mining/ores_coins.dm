/**********************Mineral ores**************************/

/obj/item/weapon/ore
	name = "Rock"
	icon = 'icons/obj/mining.dmi'
	icon_state = "ore"

/obj/item/weapon/ore/uranium
	name = "Uranium ore"
	icon_state = "Uranium ore"
	origin_tech = "materials=5"

/obj/item/weapon/ore/iron
	name = "Iron ore"
	icon_state = "Iron ore"
	origin_tech = "materials=1"

/obj/item/weapon/ore/glass
	name = "Sand"
	icon_state = "Glass ore"
	origin_tech = "materials=1"

	attack_self(mob/living/user as mob) //It's magic I ain't gonna explain how instant conversion with no tool works. -- Urist
		var/location = get_turf(user)
		for(var/obj/item/weapon/ore/glass/sandToConvert in location)
			new /obj/item/stack/sheet/mineral/sandstone(location)
			del(sandToConvert)
		new /obj/item/stack/sheet/mineral/sandstone(location)
		del(src)

/obj/item/weapon/ore/plasma
	name = "Plasma ore"
	icon_state = "Plasma ore"
	origin_tech = "materials=2"

/obj/item/weapon/ore/silver
	name = "Silver ore"
	icon_state = "Silver ore"
	origin_tech = "materials=3"

/obj/item/weapon/ore/gold
	name = "Gold ore"
	icon_state = "Gold ore"
	origin_tech = "materials=4"

/obj/item/weapon/ore/diamond
	name = "Diamond ore"
	icon_state = "Diamond ore"
	origin_tech = "materials=6"

/obj/item/weapon/ore/clown
	name = "Bananium ore"
	icon_state = "Clown ore"
	origin_tech = "materials=4"

/obj/item/weapon/ore/slag
	name = "Slag"
	desc = "Completely useless"
	icon_state = "slag"

/obj/item/weapon/ore/New()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8


/*****************************Coin********************************/

/obj/item/weapon/coin
	icon = 'icons/obj/economy.dmi'
	name = "coin"
	icon_state = "coin"
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 1
	throwforce = 3
	w_class = 1.0
	var/string_attached
	var/list/sideslist = list("heads","tails")
	var/cmineral = null
	var/cooldown = 0

/obj/item/weapon/coin/New()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8

	icon_state = "coin_[cmineral]_heads"
	if(cmineral)
		name = "[cmineral] coin"

/obj/item/weapon/coin/gold
	cmineral = "gold"

/obj/item/weapon/coin/silver
	cmineral = "silver"

/obj/item/weapon/coin/diamond
	cmineral = "diamond"

/obj/item/weapon/coin/iron
	cmineral = "iron"

/obj/item/weapon/coin/plasma
	cmineral = "plasma"

/obj/item/weapon/coin/uranium
	cmineral = "uranium"

/obj/item/weapon/coin/clown
	cmineral = "bananium"

/obj/item/weapon/coin/adamantine
	cmineral = "adamantine"

/obj/item/weapon/coin/mythril
	cmineral = "mythril"

/obj/item/weapon/coin/twoheaded
	cmineral = "iron"
	desc = "Hey, this coin's the same on both sides!"
	sideslist = list("heads")


/obj/item/weapon/coin/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/cable_coil) )
		var/obj/item/weapon/cable_coil/CC = W
		if(string_attached)
			user << "\blue There already is a string attached to this coin."
			return

		if(CC.amount <= 0)
			user << "\blue This cable coil appears to be empty."
			del(CC)
			return

		overlays += image('icons/obj/economy.dmi',"coin_string_overlay")
		string_attached = 1
		user << "\blue You attach a string to the coin."
		CC.use(1)
	else if(istype(W,/obj/item/weapon/wirecutters))
		if(!string_attached)
			..()
			return

		var/obj/item/weapon/cable_coil/CC = new/obj/item/weapon/cable_coil(user.loc)
		CC.amount = 1
		CC.update_icon()
		overlays = list()
		string_attached = null
		user << "\blue You detach the string from the coin."
	else ..()

/obj/item/weapon/coin/attack_self(mob/user as mob)
	if(cooldown < world.time - 15)
		var/coinflip = pick(sideslist)
		cooldown = world.time
		flick("coin_[cmineral]_flip", src)
		icon_state = "coin_[cmineral]_[coinflip]"
		playsound(user.loc, 'sound/items/coinflip.ogg', 50, 1)
		if(do_after(user, 15))
			user.visible_message("<span class='notice'>[user] has flipped [src]. It lands on [coinflip].</span>", \
								 "<span class='notice'>You flip [src]. It lands on [coinflip].</span>", \
								 "<span class='notice'>You hear the clattering of loose change.</span>")