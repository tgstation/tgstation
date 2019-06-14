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
	modifystate = TRUE //this is used for different icons based on the projectile type

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


//////////////EXTERNAL LENS////////////////////////////

/obj/item/external_lens
	name = "external lens"
	icon_state = "external"
	desc = "external lens."
	icon = 'icons/obj/guns/energy.dmi'
	var/stored_ammo_type = /obj/item/ammo_casing/energy/laser
	var/overlay = "laser"

/obj/item/external_lens/Initialize()
	. = ..()
	add_overlay(overlay)

/obj/item/external_lens/afterattack(atom/movable/AM, mob/user, flag)
	. = ..()
	if(user)
		AM.AddComponent(/datum/component/extralasers, stored_ammo_type, src, overlay)

/obj/item/external_lens/bitcoin
	name = "external lens: ticket dispenser"
	desc = "It uses a special frequency that IDs can read and activate a fast money transfer to your account."
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/bitcoin
	overlay = "bitcoin"

/obj/item/external_lens/ricochet
	name = "external lens: bouncing ray"
	desc = "By making the laser pass through an high density gas its able to create a small ball of hot plasma with high elasticity."
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/rico
	overlay = "ricochet"

/obj/item/external_lens/tracing
	name = "external lens: tracer ray"
	desc = "Marks your target with a special luminescent gel which makes them take more damage from lasers."
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/tracer
	overlay = "tracing"

/obj/item/external_lens/shocking
	name = "external lens: shocking ray"
	desc = "Condenses energy into sparks that shock your enemies."
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/shock
	overlay = "shocking"

/obj/item/external_lens/blinding
	name = "external lens: blinding ray"
	desc = "These ultra violet rays really do hurt the eyes, when you hit people with them."
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/blinding
	overlay = "blinding"

/obj/item/external_lens/stealth
	name = "external lens: stealth ray"
	desc = "These rays are almost invisible to the human eye, they are less efficent in the dark."
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/invisible
	overlay = "stealth"

/obj/item/external_lens/incendiary
	name = "external lens: incendiary ray"
	desc = "Heats up whatever it hits, causing them to burst into fire."
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/incendiary
	overlay = "incendiary"

/obj/item/external_lens/heavy
	name = "external lens: heavy bolt"
	desc = "Highly concentrated lasers that might break walls or doors."
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/heavy
	overlay = "heavy"

/obj/item/external_lens/economic
	name = "external lens: low power consuption ray"
	desc = "Trades fire power for high efficency, kill people with many smalls shots."
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/lowenergy
	overlay = "economic"

/obj/item/external_lens/scatter
	name = "external lens: scattershot"
	desc = "Diffusion lenses."
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/scatter/small
	overlay = "scatter"

/obj/item/external_lens/shield
	name = "external lens: barricade projector"
	desc = "Projects holobarricades which temporary absorb projectiles, watch out as even your target might use them as cover."
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/shield
	overlay = "shield"