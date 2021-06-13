/obj/item/gun/ballistic/automatic/pistol/deagle/ctf
	desc = "This looks like it could really hurt in melee."
	force = 75
	mag_type = /obj/item/ammo_box/magazine/m50/ctf

/obj/item/gun/ballistic/automatic/pistol/deagle/ctf/dropped()
	. = ..()
	addtimer(CALLBACK(src, .proc/floor_vanish), 1)

/obj/item/gun/ballistic/automatic/pistol/deagle/ctf/proc/floor_vanish()
	if(isturf(loc))
		qdel(src)

/obj/item/ammo_box/magazine/m50/ctf
	ammo_type = /obj/item/ammo_casing/a50/ctf

/obj/item/ammo_casing/a50/ctf
	projectile_type = /obj/projectile/bullet/ctf

/obj/projectile/bullet/ctf
	damage = 0

/obj/projectile/bullet/ctf/prehit_pierce(atom/target)
	if(is_ctf_target(target))
		damage = 60
		return PROJECTILE_PIERCE_NONE /// hey uhh don't hit anyone behind them
	. = ..()

/obj/item/gun/ballistic/automatic/laser/ctf
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf
	desc = "This looks like it could really hurt in melee."
	force = 50

/obj/item/gun/ballistic/automatic/laser/ctf/dropped()
	. = ..()
	addtimer(CALLBACK(src, .proc/floor_vanish), 1)

/obj/item/gun/ballistic/automatic/laser/ctf/proc/floor_vanish()
	if(isturf(loc))
		qdel(src)

/obj/item/ammo_box/magazine/recharge/ctf
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf

/obj/item/ammo_box/magazine/recharge/ctf/dropped()
	. = ..()
	addtimer(CALLBACK(src, .proc/floor_vanish), 1)

/obj/item/ammo_box/magazine/recharge/ctf/proc/floor_vanish()
	if(isturf(loc))
		qdel(src)

/obj/item/ammo_casing/caseless/laser/ctf
	projectile_type = /obj/projectile/beam/ctf

/obj/projectile/beam/ctf
	damage = 0
	icon_state = "omnilaser"

/obj/projectile/beam/ctf/prehit_pierce(atom/target)
	if(is_ctf_target(target))
		damage = 150
		return PROJECTILE_PIERCE_NONE /// hey uhhh don't hit anyone behind them
	. = ..()

/proc/is_ctf_target(atom/target)
	. = FALSE
	if(istype(target, /obj/structure/barricade/security/ctf))
		. = TRUE
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		for(var/obj/machinery/capture_the_flag/CTF in GLOB.machines)
			if(H in CTF.spawned_mobs)
				. = TRUE
				break

// SHIELDED HARDSUIT

/obj/item/clothing/suit/space/hardsuit/shielded/ctf
	name = "white shielded hardsuit"
	desc = "Standard issue hardsuit for playing capture the flag."
	icon_state = "ert_medical"
	inhand_icon_state = "ert_medical"
	hardsuit_type = "ert_medical"
	// Adding TRAIT_NODROP is done when the CTF spawner equips people
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0) // CTF gear gives no protection outside of the shield
	slowdown = 0
	max_charges = 5
	recharge_amount = 30
	lose_multiple_charges = TRUE

/obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf
	name = "shielded hardsuit helmet"
	desc = "Standard issue hardsuit helmet for playing capture the flag."
	icon_state = "hardsuit0-ert_medical"
	inhand_icon_state = "hardsuit0-ert_medical"
	hardsuit_type = "ert_medical"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)

// RED TEAM GUNS

/obj/item/gun/ballistic/automatic/laser/ctf/red
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/red

/obj/item/ammo_box/magazine/recharge/ctf/red
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/red

/obj/item/ammo_casing/caseless/laser/ctf/red
	projectile_type = /obj/projectile/beam/ctf/red

/obj/projectile/beam/ctf/red
	icon_state = "laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser

// BLUE TEAM GUNS

/obj/item/gun/ballistic/automatic/laser/ctf/blue
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/blue

/obj/item/ammo_box/magazine/recharge/ctf/blue
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/blue

/obj/item/ammo_casing/caseless/laser/ctf/blue
	projectile_type = /obj/projectile/beam/ctf/blue

/obj/projectile/beam/ctf/blue
	icon_state = "bluelaser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser

// GREEN TEAM GUNS

/obj/item/gun/ballistic/automatic/laser/ctf/green
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/green

/obj/item/ammo_box/magazine/recharge/ctf/green
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/green

/obj/item/ammo_casing/caseless/laser/ctf/green
	projectile_type = /obj/projectile/beam/ctf/green

/obj/projectile/beam/ctf/green
	icon_state = "xray"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser

// YELLOW TEAM GUNS

/obj/item/gun/ballistic/automatic/laser/ctf/yellow
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/yellow

/obj/item/ammo_box/magazine/recharge/ctf/yellow
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/yellow

/obj/item/ammo_casing/caseless/laser/ctf/yellow
	projectile_type = /obj/projectile/beam/ctf/yellow

/obj/projectile/beam/ctf/yellow
	icon_state = "gaussstrong"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/yellow_laser

// RED TEAM SUITS

/obj/item/clothing/suit/space/hardsuit/shielded/ctf/red
	name = "red shielded hardsuit"
	icon_state = "ert_security"
	inhand_icon_state = "ert_security"
	hardsuit_type = "ert_security"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/red
	shield_icon = "shield-red"

/obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/red
	icon_state = "hardsuit0-ert_security"
	inhand_icon_state = "hardsuit0-ert_security"
	hardsuit_type = "ert_security"

// BLUE TEAM SUITS

/obj/item/clothing/suit/space/hardsuit/shielded/ctf/blue
	name = "blue shielded hardsuit"
	icon_state = "ert_command"
	inhand_icon_state = "ert_command"
	hardsuit_type = "ert_commander"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/blue
	shield_icon = "shield-old"

/obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/blue
	icon_state = "hardsuit0-ert_commander"
	inhand_icon_state = "hardsuit0-ert_commander"
	hardsuit_type = "ert_commander"

// GREEN TEAM SUITS

/obj/item/clothing/suit/space/hardsuit/shielded/ctf/green
	name = "green shielded hardsuit"
	icon_state = "ert_green"
	inhand_icon_state = "ert_green"
	hardsuit_type = "ert_green"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/green
	shield_icon = "shield-green"

/obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/green
	icon_state = "hardsuit0-ert_green"
	inhand_icon_state = "hardsuit0-ert_green"
	hardsuit_type = "ert_green"

// YELLOW TEAM SUITS

/obj/item/clothing/suit/space/hardsuit/shielded/ctf/yellow
	name = "yellow shielded hardsuit"
	icon_state = "ert_engineer"
	inhand_icon_state = "ert_engineer"
	hardsuit_type = "ert_engineer"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/yellow
	shield_icon = "shield-yellow"

/obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/yellow
	icon_state = "hardsuit0-ert_engineer"
	inhand_icon_state = "hardsuit0-ert_engineer"
	hardsuit_type = "ert_engineer"
