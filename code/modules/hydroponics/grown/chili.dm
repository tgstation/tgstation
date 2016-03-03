// Chili
/obj/item/weapon/reagent_containers/food/snacks/grown/chili
	seed = /obj/item/seeds/chiliseed
	name = "chili"
	desc = "It's spicy! Wait... IT'S BURNING ME!!"
	icon_state = "chilipepper"
	filling_color = "#FF0000"
	reagents_add = list("capsaicin" = 0.25, "vitamin" = 0.04, "nutriment" = 0.04)
	bitesize_mod = 2


// Ice Chili
/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper
	seed = /obj/item/seeds/icepepperseed
	name = "ice pepper"
	desc = "It's a mutant strain of chili"
	icon_state = "icepepper"
	filling_color = "#0000CD"
	reagents_add = list("frostoil" = 0.25, "vitamin" = 0.02, "nutriment" = 0.02)
	bitesize_mod = 2


// Ghost Chili
/obj/item/weapon/reagent_containers/food/snacks/grown/ghost_chili
	seed = /obj/item/seeds/chilighost
	name = "ghost chili"
	desc = "It seems to be vibrating gently."
	icon_state = "ghostchilipepper"
	var/mob/held_mob
	filling_color = "#F8F8FF"
	reagents_add = list("condensedcapsaicin" = 0.3, "capsaicin" = 0.55, "nutriment" = 0.04)
	bitesize_mod = 4

/obj/item/weapon/reagent_containers/food/snacks/grown/ghost_chili/attack_hand(mob/user)
	..()
	if( istype(src.loc, /mob) )
		held_mob = src.loc
		SSobj.processing |= src

/obj/item/weapon/reagent_containers/food/snacks/grown/ghost_chili/process()
	if(held_mob && src.loc == held_mob)
		if( (held_mob.l_hand == src) || (held_mob.r_hand == src))
			if(hasvar(held_mob,"gloves") && held_mob:gloves)
				return
			held_mob.bodytemperature += 15 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(prob(10))
				held_mob << "<span class='warning'>Your hand holding [src] burns!</span>"
	else
		held_mob = null
		..()