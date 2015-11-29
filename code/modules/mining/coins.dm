/obj/item/weapon/coin
	icon = 'icons/obj/items.dmi'
	name = "Coin"
	icon_state = "coin"
	flags = FPRINT
	siemens_coefficient = 1
	force = 0.0
	throwforce = 0.0
	w_class = 1.0
	var/string_attached
	var/material=MAT_IRON // Ore ID, used with coinbags.
	var/credits = 0 // How many credits is this coin worth?

/obj/item/weapon/coin/New()
	. = ..()
	pixel_x = rand(-8, 8)
	pixel_y = rand(-8, 0)

/obj/item/weapon/coin/recycle(var/datum/materials/rec)
	if(material==null)
		return NOT_RECYCLABLE
	rec.addAmount(material, 0.2) // 5 coins per sheet.
	return w_type

/obj/item/weapon/coin/gold
	material=MAT_GOLD
	name = "Gold coin"
	icon_state = "coin_gold"
	credits = 5
	melt_temperature=1064+T0C

/obj/item/weapon/coin/silver
	material=MAT_SILVER
	name = "Silver coin"
	icon_state = "coin_silver"
	credits = 1
	melt_temperature=961+T0C

/obj/item/weapon/coin/diamond
	material=MAT_DIAMOND
	name = "Diamond coin"
	icon_state = "coin_diamond"
	credits = 25

/obj/item/weapon/coin/iron
	material=MAT_IRON
	name = "Iron coin"
	icon_state = "coin_iron"
	credits = 0.01
	melt_temperature=MELTPOINT_STEEL

/obj/item/weapon/coin/plasma
	material=MAT_PLASMA
	name = "Solid plasma coin"
	icon_state = "coin_plasma"
	credits = 0.1
	melt_temperature=MELTPOINT_STEEL+500

/obj/item/weapon/coin/uranium
	material=MAT_URANIUM
	name = "Uranium coin"
	icon_state = "coin_uranium"
	credits = 25
	melt_temperature=1070+T0C

/obj/item/weapon/coin/clown
	material=MAT_CLOWN
	name = "Bananaium coin"
	icon_state = "coin_clown"
	credits = 1000
	melt_temperature=MELTPOINT_GLASS

/obj/item/weapon/coin/phazon
	material=MAT_PHAZON
	name = "Phazon coin"
	icon_state = "coin_phazon"
	credits = 2000
	melt_temperature=MELTPOINT_GLASS

/obj/item/weapon/coin/adamantine
	material="adamantine"
	name = "Adamantine coin"
	icon_state = "coin_adamantine"

/obj/item/weapon/coin/mythril
	material="mythril"
	name = "Mythril coin"
	icon_state = "coin_mythril"

/obj/item/weapon/coin/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/stack/cable_coil) )
		var/obj/item/stack/cable_coil/CC = W
		if(string_attached)
			to_chat(user, "<span class='notice'>There already is a string attached to this coin.</span>")
			return

		if(CC.amount <= 0)
			to_chat(user, "<span class='notice'>This cable coil appears to be empty.</span>")
			del(CC)
			return

		overlays += image('icons/obj/items.dmi',"coin_string_overlay")
		string_attached = 1
		to_chat(user, "<span class='notice'>You attach a string to the coin.</span>")
		CC.use(1)
	else if(istype(W,/obj/item/weapon/wirecutters) )
		if(!string_attached)
			..()
			return

		var/obj/item/stack/cable_coil/CC = new(user.loc)
		CC.amount = 1
		CC.update_icon()
		overlays = list()
		string_attached = null
		to_chat(user, "<span class='notice'>You detach the string from the coin.</span>")
	else ..()