/obj/item/gun/energy/laser
	name = "laser gun"
	desc = "A basic energy-based laser gun that fires concentrated beams of light which pass through glass and thin metal."
	icon_state = "laser"
	item_state = "laser"
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL=2000)
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun)
	ammo_x_offset = 1
	shaded_charge = 1
	var/obj/item/external_lens/stored = null

/obj/item/gun/energy/laser/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/external_lens))
		if(!stored)
			equiplens(I,user)
			return
	if(istype(I, /obj/item/crowbar))
		if(stored)
			unequiplens(user)
			return

/obj/item/gun/energy/laser/proc/equiplens(obj/item/external_lens/L, mob/user)
	var/shoot =  L.stored_ammo_type
	ammo_type  += new shoot (src)
	stored += L
	L.forceMove(src)
	return TRUE

/obj/item/gun/energy/laser/proc/unequiplens(mob/user)
	del(ammo_type[ammo_type.len]) //doesnt work
	var/turf/T = user.loc
	stored.forceMove(T)
	stored = null
	return TRUE

/obj/item/gun/energy/laser/practice
	name = "practice laser gun"
	desc = "A modified version of the basic laser gun, this one fires less concentrated energy bolts designed for target practice."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/practice)
	clumsy_check = 0
	item_flags = NONE

/obj/item/gun/energy/laser/retro
	name ="retro laser gun"
	icon_state = "retro"
	desc = "An older model of the basic lasergun, no longer used by Nanotrasen's private security or military forces. Nevertheless, it is still quite deadly and easy to maintain, making it a favorite amongst pirates and other outlaws."
	ammo_x_offset = 3

/obj/item/gun/energy/laser/retro/old
	name ="laser gun"
	icon_state = "retro"
	desc = "First generation lasergun, developed by Nanotrasen. Suffers from ammo issues but its unique ability to recharge its ammo without the need of a magazine helps compensate. You really hope someone has developed a better lasergun while you were in cryo."
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun/old)
	ammo_x_offset = 3

/obj/item/gun/energy/laser/captain
	name = "antique laser gun"
	icon_state = "caplaser"
	item_state = "caplaser"
	desc = "This is an antique laser gun. All craftsmanship is of the highest quality. It is decorated with assistant leather and chrome. The object menaces with spikes of energy. On the item is an image of Space Station 13. The station is exploding."
	force = 10
	ammo_x_offset = 3
	selfcharge = 1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/gun/energy/laser/captain/scattershot
	name = "scatter shot laser rifle"
	icon_state = "lasercannon"
	item_state = "laser"
	desc = "An industrial-grade heavy-duty laser rifle with a modified laser lens to scatter its shot into multiple smaller lasers. The inner-core can self-charge for theoretically infinite use."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter, /obj/item/ammo_casing/energy/laser)

/obj/item/gun/energy/laser/cyborg
	can_charge = FALSE
	desc = "An energy-based laser gun that draws power from the cyborg's internal energy cell directly. So this is what freedom looks like?"
	use_cyborg_cell = TRUE

/obj/item/gun/energy/laser/cyborg/emp_act()
	return

/obj/item/gun/energy/laser/scatter
	name = "scatter laser gun"
	desc = "A laser gun equipped with a refraction kit that spreads bolts."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter, /obj/item/ammo_casing/energy/laser)

/obj/item/gun/energy/laser/scatter/shotty
	name = "energy shotgun"
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "cshotgun"
	item_state = "shotgun"
	desc = "A combat shotgun gutted and refitted with an internal laser system. Can switch between taser and scattered disabler shots."
	shaded_charge = 0
	pin = /obj/item/firing_pin/implant/mindshield
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter/disabler, /obj/item/ammo_casing/energy/electrode)

///Laser Cannon

/obj/item/gun/energy/lasercannon
	name = "accelerator laser cannon"
	desc = "An advanced laser cannon that does more damage the farther away the target is."
	icon_state = "lasercannon"
	item_state = "laser"
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	flags_1 =  CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	ammo_type = list(/obj/item/ammo_casing/energy/laser/accelerator)
	pin = null
	ammo_x_offset = 3

/obj/item/ammo_casing/energy/laser/accelerator
	projectile_type = /obj/item/projectile/beam/laser/accelerator
	select_name = "accelerator"
	fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/item/projectile/beam/laser/accelerator
	name = "accelerator laser"
	icon_state = "scatterlaser"
	range = 255
	damage = 6

/obj/item/projectile/beam/laser/accelerator/Range()
	..()
	damage += 7
	transform *= 1 + ((damage/7) * 0.2)//20% larger per tile

/obj/item/gun/energy/xray
	name = "\improper X-ray laser gun"
	desc = "A high-power laser gun capable of expelling concentrated X-ray blasts that pass through multiple soft targets and heavier materials."
	icon_state = "xray"
	item_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/xray)
	pin = null
	ammo_x_offset = 3

////////Laser Tag////////////////////

/obj/item/gun/energy/laser/bluetag
	name = "laser tag gun"
	icon_state = "bluetag"
	desc = "A retro laser gun modified to fire harmless blue beams of light. Sound effects included!"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/bluetag)
	item_flags = NONE
	clumsy_check = FALSE
	pin = /obj/item/firing_pin/tag/blue
	ammo_x_offset = 2
	selfcharge = TRUE

/obj/item/gun/energy/laser/bluetag/hitscan
	ammo_type = list(/obj/item/ammo_casing/energy/laser/bluetag/hitscan)

/obj/item/gun/energy/laser/redtag
	name = "laser tag gun"
	icon_state = "redtag"
	desc = "A retro laser gun modified to fire harmless beams red of light. Sound effects included!"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/redtag)
	item_flags = NONE
	clumsy_check = FALSE
	pin = /obj/item/firing_pin/tag/red
	ammo_x_offset = 2
	selfcharge = TRUE

/obj/item/gun/energy/laser/redtag/hitscan
	ammo_type = list(/obj/item/ammo_casing/energy/laser/redtag/hitscan)

/obj/item/external_lens
	name = "external lens: scatter ray"
	icon_state = "external_scatter"
	desc = "external lens."
	icon = 'icons/obj/guns/energy.dmi'
	var/stored_ammo_type = /obj/item/ammo_casing/energy/laser/scatter

/obj/item/external_lens/BTC
	name = "external lens: ticket dispenser"
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/bitcoin
	icon_state = "external_bitcoin"

/obj/item/external_lens/RIC
	name = "external lens: bouncing ray"
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/rico

/obj/item/external_lens/TRA
	name = "external lens: tracer ray"
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/tracer

/obj/item/external_lens/SHK
	name = "external lens: shocking ray"
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/shock

/obj/item/external_lens/BLN
	name = "external lens: blinding ray"
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/blinding

/obj/item/external_lens/STH
	name = "external lens: stealth ray"
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/invisible
	icon_state = "external_stealth"

/obj/item/external_lens/INC
	name = "external lens: incendiary ray"
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/incendiary

/obj/item/external_lens/HEA
	name = "external lens: heavy plasma bolt"
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/heavy
	icon_state = "external_heavy"

/obj/item/external_lens/ECO
	name = "external lens: low power consuption ray"
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/lowenergy

/obj/item/external_lens/SYP
	name = "external lens: cell syphoning"
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/syphon

/obj/item/external_lens/SYP/Initialize()
	. = ..()
	AddComponent(/datum/component/Scharge)

/datum/component/Scharge/Initialize()
	. = ..()
	RegisterSignal(parent,"syphon", .proc/charge)

/datum/component/Scharge/proc/charge(mob/FH) //doenst work
	var/obj/item/external_lens/LL = parent
	var/obj/item/gun/energy/laser/L = LL.loc
	if(ismob(L.loc))
		var/mob/living/carbon/human/H = L.loc
		if(FH == H)
			L.cell.give(200)