/obj/item/weapon/grenade/syndieminibomb
	desc = "A syndicate manufactured explosive used to sow destruction and chaos"
	name = "syndicate minibomb"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "syndicate"
	item_state = "flashbang"
	origin_tech = "materials=3;magnets=4;syndicate=3"


/obj/item/weapon/grenade/syndieminibomb/prime()
	update_mob()
	explosion(src.loc,1,2,4,flame_range = 2)
	qdel(src)

/obj/item/weapon/grenade/syndieminibomb/concussion
	name = "HE Grenade"
	desc = "A compact shrapnel grenade meant to devestate nearby organisms and cause some damage in the process. Pull pin and throw opposite direction."
	icon_state = "concussion"
	origin_tech = "materials=3;magnets=4;syndicate=2"

/obj/item/weapon/grenade/syndieminibomb/concussion/prime()
	update_mob()
	explosion(src.loc,0,2,3,flame_range = 3)
	qdel(src)

/obj/item/weapon/grenade/syndieminibomb/concussion/frag
	name = "frag grenade"
	desc = "Fire in the hole."
	icon_state = "frag"

/obj/item/weapon/grenade/gluon
	desc = "An advanced grenade that releases a harmful stream of gluons inducing radiation in those nearby. These gluon streams will also make victims feel exhausted, and induce shivering. This extreme coldness will also likely wet any nearby floors."
	name = "gluon frag grenade"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "bluefrag"
	item_state = "flashbang"
	var/freeze_range = 4
	var/rad_damage = 35
	var/stamina_damage = 30

/obj/item/weapon/grenade/gluon/prime()
	update_mob()
	playsound(loc, 'sound/effects/EMPulse.ogg', 50, 1)
	radiation_pulse(loc,freeze_range,freeze_range+1,rad_damage)
	for(var/turf/T in view(freeze_range,loc))
		if(isfloorturf(T))
			var/turf/open/floor/F = T
			F.wet = TURF_WET_PERMAFROST
			addtimer(CALLBACK(F, /turf/open/floor.proc/MakeDry, TURF_WET_PERMAFROST), rand(3000, 3100))
			for(var/mob/living/carbon/L in T)
				L.adjustStaminaLoss(stamina_damage)
				L.bodytemperature -= 230
	qdel(src)
