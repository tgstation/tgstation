/obj/item/weapon/gun/energy/ionrifle
	name = "ion rifle"
	desc = "A man-portable anti-armor weapon designed to disable mechanical threats at range."
	icon_state = "ionrifle"
	item_state = null	//so the human update icon uses the icon_state instead.
	origin_tech = "combat=2;magnets=4"
	can_flashlight = 1
	w_class = 5
	flags =  CONDUCT
	slot_flags = SLOT_BACK
	ammo_type = list(/obj/item/ammo_casing/energy/ion)
	ammo_x_offset = 3
	flight_x_offset = 17
	flight_y_offset = 9

/obj/item/weapon/gun/energy/ionrifle/emp_act(severity)
	return

/obj/item/weapon/gun/energy/ionrifle/carbine
	name = "ion carbine"
	desc = "The MK.II Prototype Ion Projector is a lightweight carbine version of the larger ion rifle, built to be ergonomic and efficient."
	icon_state = "ioncarbine"
	origin_tech = "combat=4;magnets=4;materials=4"
	w_class = 3
	slot_flags = SLOT_BELT
	pin = null
	ammo_x_offset = 2
	flight_x_offset = 18
	flight_y_offset = 11

/obj/item/weapon/gun/energy/decloner
	name = "biological demolecularisor"
	desc = "A gun that discharges high amounts of controlled radiation to slowly break a target into component elements."
	icon_state = "decloner"
	origin_tech = "combat=5;materials=4;powerstorage=3"
	ammo_type = list(/obj/item/ammo_casing/energy/declone)
	pin = null
	ammo_x_offset = 1

/obj/item/weapon/gun/energy/decloner/update_icon()
	..()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(power_supply.charge > shot.e_cost)
		overlays += "decloner_spin"

/obj/item/weapon/gun/energy/floragun
	name = "floral somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells."
	icon_state = "flora"
	item_state = "gun"
	ammo_type = list(/obj/item/ammo_casing/energy/flora/yield, /obj/item/ammo_casing/energy/flora/mut)
	origin_tech = "materials=2;biotech=3;powerstorage=3"
	modifystate = 1
	ammo_x_offset = 1
	selfcharge = 1

/obj/item/weapon/gun/energy/meteorgun
	name = "meteor gun"
	desc = "For the love of god, make sure you're aiming this the right way!"
	icon_state = "riotgun"
	item_state = "c20r"
	w_class = 4
	ammo_type = list(/obj/item/ammo_casing/energy/meteor)
	cell_type = "/obj/item/weapon/stock_parts/cell/potato"
	clumsy_check = 0 //Admin spawn only, might as well let clowns use it.
	selfcharge = 1

/obj/item/weapon/gun/energy/meteorgun/pen
	name = "meteor pen"
	desc = "The pen is mightier than the sword."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = 1

/obj/item/weapon/gun/energy/mindflayer
	name = "\improper Mind Flayer"
	desc = "A prototype weapon recovered from the ruins of Research-Station Epsilon."
	icon_state = "xray"
	item_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/mindflayer)
	ammo_x_offset = 2

/obj/item/weapon/gun/energy/kinetic_accelerator
	name = "proto-kinetic accelerator"
	desc = "According to Nanotrasen accounting, this is mining equipment. It's been modified for extreme power output to crush rocks, but often serves as a miner's first defense against hostile alien life; it's not very powerful unless used in a low pressure environment."
	icon_state = "kineticgun"
	item_state = "kineticgun"
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic)
	cell_type = "/obj/item/weapon/stock_parts/cell/emproof"
	needs_permit = 0 // Aparently these are safe to carry? I'm sure Golliaths would disagree.
	var/overheat_time = 16
	unique_rename = 1
	weapon_weight = WEAPON_HEAVY
	origin_tech = "combat=2;powerstorage=1"

/obj/item/weapon/gun/energy/kinetic_accelerator/super
	name = "super-kinetic accelerator"
	desc = "An upgraded, superior version of the proto-kinetic accelerator."
	icon_state = "kineticgun_u"
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/super)
	overheat_time = 15
	origin_tech = "combat=3;powerstorage=2"

/obj/item/weapon/gun/energy/kinetic_accelerator/hyper
	name = "hyper-kinetic accelerator"
	desc = "An upgraded, even more superior version of the proto-kinetic accelerator."
	icon_state = "kineticgun_h"
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/hyper)
	overheat_time = 14
	origin_tech = "combat=4;powerstorage=3"

/obj/item/weapon/gun/energy/kinetic_accelerator/shoot_live_shot()
	..()
	spawn(overheat_time)
		reload()

/obj/item/weapon/gun/energy/kinetic_accelerator/emp_act(severity)
	return

/obj/item/weapon/gun/energy/kinetic_accelerator/proc/reload()
	power_supply.give(500)
	if(!suppressed)
		playsound(src.loc, 'sound/weapons/kenetic_reload.ogg', 60, 1)
	else
		loc << "<span class='warning'>[src] silently charges up.<span>"
	update_icon()

/obj/item/weapon/gun/energy/kinetic_accelerator/update_icon()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(power_supply.charge < shot.e_cost)
		icon_state = "[initial(icon_state)]_empty"
	else
		icon_state = initial(icon_state)

/obj/item/weapon/gun/energy/kinetic_accelerator/crossbow
	name = "mini energy crossbow"
	desc = "A weapon favored by syndicate stealth specialists."
	icon_state = "crossbow"
	item_state = "crossbow"
	w_class = 2
	materials = list(MAT_METAL=2000)
	origin_tech = "combat=2;magnets=2;syndicate=5"
	suppressed = 1
	ammo_type = list(/obj/item/ammo_casing/energy/bolt)
	weapon_weight = WEAPON_LIGHT
	unique_rename = 0
	overheat_time = 20

/obj/item/weapon/gun/energy/kinetic_accelerator/crossbow/large
	name = "energy crossbow"
	desc = "A reverse engineered weapon using syndicate technology."
	icon_state = "crossbowlarge"
	w_class = 3
	materials = list(MAT_METAL=4000)
	origin_tech = "combat=2;magnets=2;syndicate=3" //can be further researched for more syndie tech
	suppressed = 0
	ammo_type = list(/obj/item/ammo_casing/energy/bolt/large)
	pin = null

/obj/item/weapon/gun/energy/kinetic_accelerator/suicide_act(mob/user)
	if(!suppressed)
		playsound(src.loc, 'sound/weapons/kenetic_reload.ogg', 60, 1)
	user.visible_message("<span class='suicide'>[user] cocks the [src.name] and pretends to blow \his brains out! It looks like \he's trying to commit suicide!</b></span>")
	shoot_live_shot()
	return (OXYLOSS)

/obj/item/weapon/gun/energy/plasmacutter
	name = "plasma cutter"
	desc = "A mining tool capable of expelling concentrated plasma bursts. You could use it to cut limbs off of xenos! Or, you know, mine stuff."
	icon_state = "plasmacutter"
	item_state = "plasmacutter"
	modifystate = -1
	origin_tech = "combat=1;materials=3;magnets=2;plasmatech=2;engineering=1"
	ammo_type = list(/obj/item/ammo_casing/energy/plasma)
	flags = CONDUCT | OPENCONTAINER
	attack_verb = list("attacked", "slashed", "cut", "sliced")
	can_charge = 0
	heat = 3800

/obj/item/weapon/gun/energy/plasmacutter/examine(mob/user)
	..()
	if(power_supply)
		user <<"<span class='notice'>[src] is [round(power_supply.percent())]% charged.</span>"

/obj/item/weapon/gun/energy/plasmacutter/attackby(obj/item/A, mob/user)
	if(istype(A, /obj/item/stack/sheet/mineral/plasma))
		var/obj/item/stack/sheet/S = A
		S.use(1)
		power_supply.give(1000)
		user << "<span class='notice'>You insert [A] in [src], recharging it.</span>"
	else if(istype(A, /obj/item/weapon/ore/plasma))
		qdel(A)
		power_supply.give(500)
		user << "<span class='notice'>You insert [A] in [src], recharging it.</span>"
	else
		..()

/obj/item/weapon/gun/energy/plasmacutter/update_icon()
	return

/obj/item/weapon/gun/energy/plasmacutter/adv
	name = "advanced plasma cutter"
	icon_state = "adv_plasmacutter"
	origin_tech = "combat=3;materials=4;magnets=3;plasmatech=3;engineering=2"
	ammo_type = list(/obj/item/ammo_casing/energy/plasma/adv)

/obj/item/weapon/gun/energy/wormhole_projector
	name = "bluespace wormhole projector"
	desc = "A projector that emits high density quantum-coupled bluespace beams."
	ammo_type = list(/obj/item/ammo_casing/energy/wormhole, /obj/item/ammo_casing/energy/wormhole/orange)
	item_state = null
	icon_state = "wormhole_projector"
	var/obj/effect/portal/blue
	var/obj/effect/portal/orange

/obj/item/weapon/gun/energy/wormhole_projector/update_icon()
	icon_state = "[initial(icon_state)][select]"
	item_state = icon_state
	return

/obj/item/weapon/gun/energy/wormhole_projector/process_chamber()
	..()
	select_fire()

/obj/item/weapon/gun/energy/wormhole_projector/proc/portal_destroyed(obj/effect/portal/P)
	if(P.icon_state == "portal")
		blue = null
		if(orange)
			orange.target = null
	else
		orange = null
		if(blue)
			blue.target = null

/obj/item/weapon/gun/energy/wormhole_projector/proc/create_portal(obj/item/projectile/beam/wormhole/W)
	var/obj/effect/portal/P = new /obj/effect/portal(get_turf(W), null, src)
	P.precision = 0
	if(W.name == "bluespace beam")
		qdel(blue)
		blue = P
	else
		qdel(orange)
		P.icon_state = "portal1"
		orange = P
	if(orange && blue)
		blue.target = get_turf(orange)
		orange.target = get_turf(blue)


/* 3d printer 'pseudo guns' for borgs */

/obj/item/weapon/gun/energy/printer
	name = "cyborg lmg"
	desc = "A machinegun that fires 3d-printed flachettes slowly regenerated using a cyborg's internal power source."
	icon_state = "l6closed0"
	icon = 'icons/obj/guns/projectile.dmi'
	cell_type = "/obj/item/weapon/stock_parts/cell/secborg"
	ammo_type = list(/obj/item/ammo_casing/energy/c3dbullet)
	can_charge = 0

/obj/item/weapon/gun/energy/printer/update_icon()
	return

/obj/item/weapon/gun/energy/printer/emp_act()
	return

/obj/item/weapon/gun/energy/printer/newshot()
	..()
	robocharge()

/obj/item/weapon/gun/energy/temperature
	name = "temperature gun"
	icon_state = "freezegun"
	desc = "A gun that changes temperatures."
	origin_tech = "combat=3;materials=4;powerstorage=3;magnets=2"
	ammo_type = list(/obj/item/ammo_casing/energy/temp, /obj/item/ammo_casing/energy/temp/hot)
	cell_type = "/obj/item/weapon/stock_parts/cell/high"
	pin = null

/obj/item/weapon/gun/energy/laser/instakill
	name = "instakill rifle"
	icon_state = "instagib"
	item_state = "instagib"
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit."
	ammo_type = list(/obj/item/ammo_casing/energy/instakill)
	force = 60
	origin_tech = null

/obj/item/weapon/gun/energy/laser/instakill/red
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit. This one has a red design."
	icon_state = "instagibred"
	item_state = "instagibred"
	ammo_type = list(/obj/item/ammo_casing/energy/instakill/red)

/obj/item/weapon/gun/energy/laser/instakill/blue
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit. This one has a blue design."
	icon_state = "instagibblue"
	item_state = "instagibblue"
	ammo_type = list(/obj/item/ammo_casing/energy/instakill/blue)

/obj/item/weapon/gun/energy/laser/instakill/emp_act() //implying you could stop the instagib
	return