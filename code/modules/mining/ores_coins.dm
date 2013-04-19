/**********************Mineral ores**************************/

/obj/item/mining/ore
	name = "Rock"
	icon = 'icons/obj/mining.dmi'
	icon_state = "ore"


/obj/item/mining/ore/uranium
	name = "Uranium ore"
	icon_state = "Uranium ore"
	origin_tech = "materials=5"

/obj/item/mining/ore/iron
	name = "Iron ore"
	icon_state = "Iron ore"
	origin_tech = "materials=1"

/obj/item/mining/ore/glass
	name = "Sand"
	icon_state = "Glass ore"
	origin_tech = "materials=1"

	attack_self(mob/living/user as mob) //It's magic I ain't gonna explain how instant conversion with no tool works. -- Urist
		var/location = get_turf(user)
		for(var/obj/item/mining/ore/glass/sandToConvert in location)
			new /obj/item/part/stack/sheet/mineral/sandstone(location)
			del(sandToConvert)
		new /obj/item/part/stack/sheet/mineral/sandstone(location)
		del(src)

/obj/item/mining/ore/plasma
	name = "Plasma ore"
	icon_state = "Plasma ore"
	origin_tech = "materials=2"

/obj/item/mining/ore/silver
	name = "Silver ore"
	icon_state = "Silver ore"
	origin_tech = "materials=3"

/obj/item/mining/ore/gold
	name = "Gold ore"
	icon_state = "Gold ore"
	origin_tech = "materials=4"

/obj/item/mining/ore/diamond
	name = "Diamond ore"
	icon_state = "Diamond ore"
	origin_tech = "materials=6"

/obj/item/mining/ore/clown
	name = "Bananium ore"
	icon_state = "Clown ore"
	origin_tech = "materials=4"

/obj/item/mining/ore/slag
	name = "Slag"
	desc = "Completely useless"
	icon_state = "slag"

/obj/item/mining/ore/New()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8


/*****************************Coin********************************/

/obj/item/money/coin
	icon = 'icons/obj/items.dmi'
	name = "Coin"
	icon_state = "coin"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 0.0
	throwforce = 0.0
	w_class = 1.0
	var/string_attached

/obj/item/money/coin/New()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8

/obj/item/money/coin/gold
	name = "Gold coin"
	icon_state = "coin_gold"

/obj/item/money/coin/silver
	name = "Silver coin"
	icon_state = "coin_silver"

/obj/item/money/coin/diamond
	name = "Diamond coin"
	icon_state = "coin_diamond"

/obj/item/money/coin/iron
	name = "Iron coin"
	icon_state = "coin_iron"

/obj/item/money/coin/plasma
	name = "Solid plasma coin"
	icon_state = "coin_plasma"

/obj/item/money/coin/uranium
	name = "Uranium coin"
	icon_state = "coin_uranium"

/obj/item/money/coin/clown
	name = "Bananaium coin"
	icon_state = "coin_clown"

/obj/item/money/coin/adamantine
	name = "Adamantine coin"
	icon_state = "coin_adamantine"

/obj/item/money/coin/mythril
	name = "Mythril coin"
	icon_state = "coin_mythril"

/obj/item/money/coin/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/part/cable_coil) )
		var/obj/item/part/cable_coil/CC = W
		if(string_attached)
			user << "\blue There already is a string attached to this coin."
			return

		if(CC.amount <= 0)
			user << "\blue This cable coil appears to be empty."
			del(CC)
			return

		overlays += image('icons/obj/items.dmi',"coin_string_overlay")
		string_attached = 1
		user << "\blue You attach a string to the coin."
		CC.use(1)
	else if(istype(W,/obj/item/part/wirecutters) )
		if(!string_attached)
			..()
			return

		var/obj/item/part/cable_coil/CC = new/obj/item/part/cable_coil(user.loc)
		CC.amount = 1
		CC.updateicon()
		overlays = list()
		string_attached = null
		user << "\blue You detach the string from the coin."
	else ..()