/obj/item/weapon/storage/briefcase
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	icon_state = "briefcase"
	flags = CONDUCT
	force = 8
	hitsound = "swing_hit"
	throw_speed = 2
	throw_range = 4
	w_class = 4
	max_w_class = 3
	max_combined_w_class = 21
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")
	resistance_flags = FLAMMABLE
	obj_integrity = 150
	max_integrity = 150

/obj/item/weapon/storage/briefcase/lawyer/New()
	new /obj/item/weapon/pen(src)
	var/obj/item/weapon/folder/folder =  new /obj/item/weapon/folder/blue(src)
	for(var/i in 1 to 6)
		new /obj/item/weapon/paper(folder)
	..()

/obj/item/weapon/storage/briefcase/sniperbundle
	name = "briefcase"
	desc = "Its label reads genuine hardened Captain leather, but suspiciously has no other tags or branding. Smells like L'Air du Temps."
	icon_state = "briefcase"
	flags = CONDUCT
	force = 10
	hitsound = "swing_hit"
	throw_speed = 2
	throw_range = 4
	w_class = 4
	max_w_class = 3
	max_combined_w_class = 21
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")
	resistance_flags = FLAMMABLE
	obj_integrity = 150
	max_integrity = 150

/obj/item/weapon/storage/briefcase/sniperbundle/New()
	..()
	new /obj/item/weapon/gun/ballistic/automatic/sniper_rifle/syndicate(src)
	new /obj/item/clothing/neck/tie/red(src)
	new /obj/item/clothing/under/syndicate/sniper(src)
	new /obj/item/ammo_box/magazine/sniper_rounds/soporific(src)
	new /obj/item/ammo_box/magazine/sniper_rounds/haemorrhage(src)
	new /obj/item/weapon/suppressor/specialoffer(src)

/obj/item/weapon/storage/briefcase/leather/
	desc = "A briefcase made from real skin from mutilated animal corpses!"
	force = 10