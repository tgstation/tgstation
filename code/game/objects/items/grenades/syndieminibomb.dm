/obj/item/grenade/syndieminibomb
	desc = "A syndicate manufactured explosive used to sow destruction and chaos."
	name = "syndicate minibomb"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "syndicate"
	item_state = "flashbang"
	ex_dev = 1
	ex_heavy = 2
	ex_light = 4
	ex_flame = 2

/obj/item/grenade/syndieminibomb/prime()
	. = ..()
	update_mob()
	resolve()

/obj/item/grenade/syndieminibomb/concussion
	name = "HE Grenade"
	desc = "A compact shrapnel grenade meant to devastate nearby organisms and cause some damage in the process. Pull pin and throw opposite direction."
	icon_state = "concussion"
	ex_heavy = 2
	ex_light = 3
	ex_flame = 3

/obj/item/grenade/frag
	name = "frag grenade"
	desc = "An anti-personnel fragmentation grenade, this weapon excels at killing soft targets by shredding them with metal shrapnel."
	icon_state = "frag"
	shrapnel_type = /obj/projectile/bullet/shrapnel
	shrapnel_radius = 4
	ex_heavy = 1
	ex_light = 3
	ex_flame = 4

/obj/item/grenade/frag/mega
	name = "FRAG grenade"
	desc = "An anti-everything fragmentation grenade, this weapon excels at killing anything any everything by shredding them with metal shrapnel."
	shrapnel_type = /obj/projectile/bullet/shrapnel/mega
	shrapnel_radius = 12

/obj/item/grenade/frag/prime()
	. = ..()
	update_mob()
	resolve()

/obj/item/grenade/gluon
	desc = "An advanced grenade that releases a harmful stream of gluons inducing radiation in those nearby. These gluon streams will also make victims feel exhausted, and induce shivering. This extreme coldness will also likely wet any nearby floors."
	name = "gluon frag grenade"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "bluefrag"
	item_state = "flashbang"
	var/freeze_range = 4
	var/rad_damage = 350
	var/stamina_damage = 30

/obj/item/grenade/gluon/prime()
	. = ..()
	update_mob()
	playsound(loc, 'sound/effects/empulse.ogg', 50, TRUE)
	radiation_pulse(src, rad_damage)
	for(var/turf/T in view(freeze_range,loc))
		if(isfloorturf(T))
			var/turf/open/floor/F = T
			F.MakeSlippery(TURF_WET_PERMAFROST, 6 MINUTES)
			for(var/mob/living/carbon/L in T)
				L.adjustStaminaLoss(stamina_damage)
				L.adjust_bodytemperature(-230)
	resolve()
