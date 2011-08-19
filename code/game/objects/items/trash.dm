//Added by Jack Rost
/obj/item/trash
	icon = 'trash.dmi'
	w_class = 1.0
	desc = "It's \a trash"
	raisins
		name = "4no raisins"
		icon_state= "4no_raisins"
	candy
		name = "Candy"
		icon_state= "candy"
	cheesie
		name = "Cheesie honkers"
		icon_state = "cheesie_honkers"
	chips
		name = "Chips"
		icon_state = "chips"
	popcorn
		name = "Popcorn"
		icon_state = "popcorn"
	sosjerky
		name = "Sosjerky"
		icon_state = "sosjerky"
	syndi_cakes
		name = "Syndi cakes"
		icon_state = "syndi_cakes"
	waffles
		name = "Waffles"
		icon_state = "waffles"
	plate
		name = "Plate"
		icon_state = "plate"
	snack_bowl
		name = "Snack bowl"
		icon_state	= "snack_bowl"
	pistachios
		name = "Pistachios pack"
		icon_state = "pistachios_pack"
	semki
		name = "Semki pack"
		icon_state = "semki_pack"
	tray
		name = "Tray"
		icon_state = "tray"
	candle
		name = "candle"
		icon = 'candle.dmi'
		icon_state = "candle4"

/obj/item/trash/attack(mob/M as mob, mob/living/user as mob)
	return

/obj/item/trash/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/trashbag))
		var/obj/item/weapon/trashbag/S = W
		if (S.mode == 1)
			for (var/obj/item/trash/O in locate(src.x,src.y,src.z))
				if (S.contents.len < S.capacity)
					S.contents += O;
				else
					user << "\blue The bag is full."
					break
			user << "\blue You pick up all trash."
		else
			if (S.contents.len < S.capacity)
				S.contents += src;
			else
				user << "\blue The bag is full."
		S.update_icon()
	return

/obj/item/weapon/trashbag
	icon = 'trash.dmi'
	icon_state = "trashbag0"
	item_state = "trashbag"
	name = "Trash bag"
	var/mode = 1;  //0 = pick one at a time, 1 = pick all on tile
	var/capacity = 25; //the number of trash it can carry.
	flags = FPRINT | TABLEPASS | ONBELT
	w_class = 1

/obj/item/weapon/trashbag/update_icon()
	if(contents.len == 0)
		icon_state = "trashbag0"
	else if(contents.len < 12)
		icon_state = "trashbag1"
	else if(contents.len < 25)
		icon_state = "trashbag2"
	else icon_state = "trashbag3"

/obj/item/weapon/trashbag/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/trash))
		var/obj/item/trash/O = W
		src.contents += O;
	return

/obj/item/weapon/trashbag/verb/toggle_mode()
	set name = "Switch Bag Method"
	set category = "Object"

	mode = !mode
	switch (mode)
		if(1)
			usr << "The bag now picks up all trash in a tile at once."
		if(0)
			usr << "The bag now picks up one trash at a time."