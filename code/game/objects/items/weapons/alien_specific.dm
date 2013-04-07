//This file contains xenoborg specic weapons.

/obj/item/weapon/melee/energy/alien/claws
	color
	name = "energy claws"
	desc = "Zap zap Wap Wap."
	icon = 'icons/mob/alien.dmi'
	icon_state = "borg-laser-claws"
	force = 15.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	flags = FPRINT | TABLEPASS | NOSHIELD
	attack_verb = list("attacked", "slashed", "gored", "sliced", "torn", "ripped", "butchered", "cut")

//Bottles for borg liquid squirters. PSSH PSSH
/obj/item/weapon/reagent_containers/spray/alien
	name = "liquid synthesizer"
	desc = "squirts alien liquids."
	icon = 'icons/mob/alien.dmi'
	icon_state = "borg-default"

/obj/item/weapon/reagent_containers/spray/alien/smoke
	name = "smoke synthesizer"
	desc = "squirts smokey liquids."
	icon = 'icons/mob/alien.dmi'
	icon_state = "borg-spray-smoke"

/obj/item/weapon/reagent_containers/spray/alien/smoke/afterattack(atom/A as mob|obj, mob/user as mob)
	if(istype(A, /obj/structure/reagent_dispensers) && get_dist(src,A) <= 1)
		if(!A.reagents.total_volume && A.reagents)
			user << "<span class='notice'>\The [A] is empty.</span>"
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			user << "<span class='notice'>\The [src] is full.</span>"
			return
	reagents.remove_reagent(25,"water")
	var/datum/effect/effect/system/bad_smoke_spread/smoke = new /datum/effect/effect/system/bad_smoke_spread()
	smoke.set_up(5, 0, user.loc)
	smoke.start()
	playsound(user.loc, 'sound/effects/bamf.ogg', 50, 2)

/obj/item/weapon/reagent_containers/spray/alien/acid
	name = "acid synthesizer"
	desc = "squirts burny liquids."
	icon = 'icons/mob/alien.dmi'
	icon_state = "borg-spray-acid"

/obj/item/weapon/reagent_containers/spray/alien/stun
	name = "paralytic toxin synthesizer"
	desc = "squirts viagra."
	icon = 'icons/mob/alien.dmi'
	icon_state = "borg-spray-stun"

//SKREEEEEEEEEEEE tool

/obj/item/device/flash/alien
	name = "eye flash"
	desc = "Useful for taking pictures, making friends and flash-frying chips."
	icon = 'icons/mob/alien.dmi'
	icon_state = "borg-flash"

//heat vision

/obj/item/borg/sight/thermal/alien
	name = "thermal module"
	icon = 'icons/mob/alien.dmi'
	icon_state = "borg-extra-vision"