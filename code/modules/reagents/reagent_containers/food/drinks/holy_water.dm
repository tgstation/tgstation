/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater
	name = "Flask of Holy Water"
	desc = "A flask of the chaplain's holy water."
	icon_state = "holyflask"
	bottleheight = 25
	molotov = -1
	isGlass = 1
	smashtext = ""
	smashname = "broken flask"

/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater/New()
	..()
	reagents.add_reagent(HOLYWATER, 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater/attack(mob/living/M as mob, mob/user as mob, def_zone)
	return

/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater/afterattack(var/atom/target, var/mob/user, var/adjacency_flag, var/click_params)
	if(!adjacency_flag)
		return

	//Holy water flasks only splash 5u instead of the whole contents
	transfer(target, user, can_send = TRUE, can_receive = TRUE, splashable_units = 5)
