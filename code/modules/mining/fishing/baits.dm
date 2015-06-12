/obj/item/weapon/fishing_bait
	name = "fishing bait"
	icon = 'icons/obj/fishing.dmi'
	icon_state = "bad_bait"
	desc = "Bait for fishing."
	var/rating = 0
	var/uses = 3

/obj/item/weapon/fishing_bait/proc/bait_effects(var/obj/item/weapon/fish/F)
	return

/obj/item/weapon/fishing_bait/bad
	name = "bad fishing bait"
	icon_state = "bad_bait"
	rating = 1
	uses = 3

/obj/item/weapon/fishing_bait/good
	name = "good fishing bait"
	icon_state = "good_bait"
	rating = 2
	uses = 6
/obj/item/weapon/fishing_bait/perfect
	name = "perfect fishing bait"
	icon_state = "perfect_bait"
	rating = 3
	uses = 9

/obj/item/weapon/fishing_bait/good/fattening
	name = "fattening fishing bait"
	desc = "Bait for fishing. Makes the caught fish fatter, and able to be harvested more."

/obj/item/weapon/fishing_bait/good/fattening/bait_effects(var/obj/item/weapon/fish/F)
	if(F && istype(F))
		F.harvest_times += 3
	return

/obj/item/weapon/fishing_bait/good/midas_touch
	name = "midas's touch fishing bait"
	desc = "Bait for fishing. Gives the caught fish a tint of gold."

/obj/item/weapon/fishing_bait/good/midas_touch/bait_effects(var/obj/item/weapon/fish/F)
	if(F && istype(F))
		F.harvest_drops += /obj/item/weapon/ore/gold/fish
	return