//todo: flushing, flushing heads, showers actually cleaning people

/obj/structure/toilet
	name = "toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one seems remarkably clean."
	icon = 'watercloset.dmi'
	icon_state = "toilet0"
	density = 0
	anchored = 1
	var/open = 0

/obj/structure/toilet/New()
	open = round(rand(0, 1))
	update_icon()

/obj/structure/toilet/attack_hand()
	open = !open
	update_icon()

/obj/structure/toilet/update_icon()
	icon_state = "toilet[open]"



/obj/structure/urinal
	name = "urinal"
	desc = "The HU-452, an experimental urinal."
	icon = 'watercloset.dmi'
	icon_state = "urinal"
	density = 0
	anchored = 1



/obj/structure/shower
	name = "shower"
	desc = "The HS-451. Installed in the 2550s by the Nanotrasen Hygiene Division."
	icon = 'watercloset.dmi'
	icon_state = "shower"
	density = 0
	anchored = 1
	var/on = 0
	var/mist = 0	//needs a var so we can make it linger~

//add heat controls? when emagged, you can freeze to death in it?

/obj/structure/shower/attack_hand()
	on = !on
	update_icon()

/obj/structure/shower/update_icon()
	overlays = null
	if(on)
		overlays += image('watercloset.dmi', src, "water", MOB_LAYER + 1, dir)
		spawn(50)
			if(src && on)
				overlays += image('watercloset.dmi', src, "mist", MOB_LAYER + 1, dir)
				mist = 1
	else if(mist)
		overlays += image('watercloset.dmi', src, "mist", MOB_LAYER + 1, dir)
		spawn(100)
			if(src && !on)
				overlays = null



/obj/item/weapon/bikehorn/rubberducky
	name = "rubber ducky"
	desc = "Rubber ducky you're so fine, you make bathtime lots of fuuun. Rubber ducky I'm awfully fooooond of yooooouuuu~"	//thanks doohl
	icon = 'watercloset.dmi'
	icon_state = "rubberducky"
	item_state = "rubberducky"