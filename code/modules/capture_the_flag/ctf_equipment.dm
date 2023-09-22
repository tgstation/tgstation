// GENERIC PROJECTILE

/obj/projectile/beam/ctf
	damage = 0
	icon_state = "omnilaser"

/obj/projectile/beam/ctf/prehit_pierce(atom/target)
	if(!is_ctf_target(target))
		damage = 0
		return PROJECTILE_PIERCE_NONE /// hey uhhh don't hit anyone behind them
	. = ..()

/obj/projectile/beam/ctf/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(is_ctf_target(target) && blocked == FALSE)
		if(iscarbon(target))
			var/mob/living/carbon/target_mob = target
			target_mob.apply_damage(150)
		return BULLET_ACT_HIT

/obj/item/ammo_box/magazine/recharge/ctf
	ammo_type = /obj/item/ammo_casing/laser/ctf

/obj/item/ammo_box/magazine/recharge/ctf/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/delete_on_drop)

/obj/item/ammo_casing/laser/ctf
	projectile_type = /obj/projectile/beam/ctf/

/obj/item/ammo_casing/laser/ctf/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/delete_on_drop)

// LASER RIFLE

/obj/item/gun/ballistic/automatic/laser/ctf
	accepted_magazine_type = /obj/item/ammo_box/magazine/recharge/ctf/rifle
	desc = "This looks like it could really hurt in melee."
	force = 50
	weapon_weight = WEAPON_HEAVY
	slot_flags = null

/obj/item/gun/ballistic/automatic/laser/ctf/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/delete_on_drop)

/obj/item/ammo_box/magazine/recharge/ctf/rifle
	ammo_type = /obj/item/ammo_casing/laser/ctf/rifle

/obj/item/ammo_casing/laser/ctf/rifle
	projectile_type = /obj/projectile/beam/ctf/rifle

/obj/projectile/beam/ctf/rifle
	damage = 45
	light_color = LIGHT_COLOR_BLUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser

// LASER SHOTGUN

/obj/item/gun/ballistic/shotgun/ctf
	name = "laser shotgun"
	desc = "This looks like it could really hurt in melee."
	icon_state = "ctfshotgun"
	inhand_icon_state = "shotgun_combat"
	worn_icon_state = "gun"
	slot_flags = null
	accepted_magazine_type = /obj/item/ammo_box/magazine/recharge/ctf/shotgun
	empty_indicator = TRUE
	fire_sound = 'sound/weapons/gun/shotgun/shot_alt.ogg'
	semi_auto = TRUE
	internal_magazine = FALSE
	tac_reloads = TRUE

/obj/item/gun/ballistic/shotgun/ctf/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/delete_on_drop)

/obj/item/ammo_box/magazine/recharge/ctf/shotgun
	ammo_type = /obj/item/ammo_casing/laser/ctf/shotgun
	max_ammo = 6

/obj/item/ammo_casing/laser/ctf/shotgun
	projectile_type = /obj/projectile/beam/ctf/shotgun
	pellets = 6
	variance = 25

/obj/projectile/beam/ctf/shotgun
	damage = 15
	light_color = LIGHT_COLOR_BLUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser

// MARKSMAN RIFLE

/obj/item/gun/ballistic/automatic/laser/ctf/marksman
	name = "designated marksman rifle"
	icon_state = "ctfmarksman"
	inhand_icon_state = "ctfmarksman"
	accepted_magazine_type = /obj/item/ammo_box/magazine/recharge/ctf/marksman
	fire_delay = 1 SECONDS

/obj/item/gun/ballistic/automatic/laser/ctf/marksman/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/scope, range_modifier = 1.7)

/obj/item/ammo_box/magazine/recharge/ctf/marksman
	ammo_type = /obj/item/ammo_casing/laser/ctf/marksman
	max_ammo = 10

/obj/item/ammo_casing/laser/ctf/marksman
	projectile_type = /obj/projectile/beam/ctf/marksman

/obj/projectile/beam/ctf/marksman
	damage = 30
	hitscan = TRUE
	tracer_type = /obj/effect/projectile/tracer/laser/blue
	muzzle_type = /obj/effect/projectile/muzzle/laser/blue
	impact_type = /obj/effect/projectile/impact/laser/blue

// DESERT EAGLE

/obj/item/gun/ballistic/automatic/pistol/deagle/ctf
	desc = "This looks like it could really hurt in melee."
	force = 75
	accepted_magazine_type = /obj/item/ammo_box/magazine/recharge/ctf/deagle

/obj/item/gun/ballistic/automatic/pistol/deagle/ctf/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/delete_on_drop)

/obj/item/ammo_box/magazine/recharge/ctf/deagle
	ammo_type = /obj/item/ammo_casing/laser/ctf/deagle
	max_ammo = 7

/obj/item/ammo_casing/laser/ctf/deagle
	projectile_type = /obj/projectile/beam/ctf/deagle

/obj/projectile/beam/ctf/deagle
	icon_state = "bullet"
	damage = 60
	light_color = COLOR_WHITE
	impact_effect_type = /obj/effect/temp_visual/impact_effect

// INSTAKILL RIFLE

/obj/item/gun/energy/laser/instakill
	name = "instakill rifle"
	icon_state = "instagib"
	inhand_icon_state = "instagib"
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit."
	w_class = WEIGHT_CLASS_BULKY
	ammo_type = list(/obj/item/ammo_casing/energy/instakill)
	force = 60
	slot_flags = null
	charge_sections = 5
	ammo_x_offset = 2
	shaded_charge = FALSE

/obj/item/gun/energy/laser/instakill/emp_act() //implying you could stop the instagib
	return

/obj/item/gun/energy/laser/instakill/ctf/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/delete_on_drop)

/obj/item/ammo_casing/energy/instakill
	projectile_type = /obj/projectile/beam/instakill
	e_cost = 0
	select_name = "DESTROY"

/obj/projectile/beam/instakill
	name = "instagib laser"
	icon_state = "purple_laser"
	damage = 200
	damage_type = BURN
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	light_color = LIGHT_COLOR_PURPLE

/obj/projectile/beam/instakill/on_hit(atom/target)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/target_mob = target
		target_mob.visible_message(span_danger("[target_mob] explodes into a shower of gibs!"))
		target_mob.gib()

// SHIELDED VEST

/obj/item/clothing/suit/armor/vest/ctf
	name = "white shielded vest"
	desc = "Standard issue vest for playing capture the flag."
	icon = 'icons/mob/clothing/suits/ctf.dmi'
	worn_icon = 'icons/mob/clothing/suits/ctf.dmi'
	icon_state = "standard"
	// Adding TRAIT_NODROP is done when the CTF spawner equips people
	armor_type = /datum/armor/none
	allowed = null
	greyscale_config = /datum/greyscale_config/ctf_standard
	greyscale_config_worn = /datum/greyscale_config/ctf_standard/worn
	greyscale_colors = "#ffffff"

	///Icon state to be fed into the shielded component
	var/team_shield_icon = "shield-old"
	var/max_charges = 150
	var/recharge_start_delay = 12 SECONDS
	var/charge_increment_delay = 1 SECONDS
	var/charge_recovery = 30
	var/lose_multiple_charges = TRUE
	var/show_charge_as_alpha = TRUE

/obj/item/clothing/suit/armor/vest/ctf/equipped(mob/user, slot)
	. = ..()
	if(!slot || slot & ITEM_SLOT_HANDS)
		return
	AddComponent(/datum/component/shielded, max_charges = max_charges, recharge_start_delay = recharge_start_delay, charge_increment_delay = charge_increment_delay, \
	charge_recovery = charge_recovery, lose_multiple_charges = lose_multiple_charges, show_charge_as_alpha = show_charge_as_alpha, shield_icon = team_shield_icon)

// LIGHT SHIELDED VEST

/obj/item/clothing/suit/armor/vest/ctf/light
	name = "light white shielded vest"
	desc = "Lightweight vest for playing capture the flag."
	icon_state = "light"
	greyscale_config = /datum/greyscale_config/ctf_light
	greyscale_config_worn = /datum/greyscale_config/ctf_light/worn
	slowdown = -0.25
	max_charges = 30

// RED TEAM GUNS

// Rifle
/obj/item/gun/ballistic/automatic/laser/ctf/red
	accepted_magazine_type = /obj/item/ammo_box/magazine/recharge/ctf/rifle/red

/obj/item/ammo_box/magazine/recharge/ctf/rifle/red
	ammo_type = /obj/item/ammo_casing/laser/ctf/rifle/red

/obj/item/ammo_casing/laser/ctf/rifle/red
	projectile_type = /obj/projectile/beam/ctf/rifle/red

/obj/projectile/beam/ctf/rifle/red
	icon_state = "laser"
	light_color = COLOR_SOFT_RED
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser

// Shotgun
/obj/item/gun/ballistic/shotgun/ctf/red
	accepted_magazine_type = /obj/item/ammo_box/magazine/recharge/ctf/shotgun/red

/obj/item/ammo_box/magazine/recharge/ctf/shotgun/red
	ammo_type = /obj/item/ammo_casing/laser/ctf/shotgun/red

/obj/item/ammo_casing/laser/ctf/shotgun/red
	projectile_type = /obj/projectile/beam/ctf/shotgun/red

/obj/projectile/beam/ctf/shotgun/red
	icon_state = "laser"
	light_color = COLOR_SOFT_RED
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser

// DMR
/obj/item/gun/ballistic/automatic/laser/ctf/marksman/red
	accepted_magazine_type = /obj/item/ammo_box/magazine/recharge/ctf/marksman/red

/obj/item/ammo_box/magazine/recharge/ctf/marksman/red
	ammo_type = /obj/item/ammo_casing/laser/ctf/marksman/red

/obj/item/ammo_casing/laser/ctf/marksman/red
	projectile_type = /obj/projectile/beam/ctf/marksman/red

/obj/projectile/beam/ctf/marksman/red
	icon_state = "laser"
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

// Instakill
/obj/item/gun/energy/laser/instakill/ctf/red
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit. This one has a red design."
	icon_state = "instagibred"
	inhand_icon_state = "instagibred"
	ammo_type = list(/obj/item/ammo_casing/energy/instakill/red)

/obj/item/ammo_casing/energy/instakill/red
	projectile_type = /obj/projectile/beam/instakill/red

/obj/projectile/beam/instakill/red
	icon_state = "red_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = COLOR_SOFT_RED

// BLUE TEAM GUNS

// Rifle
/obj/item/gun/ballistic/automatic/laser/ctf/blue
	accepted_magazine_type = /obj/item/ammo_box/magazine/recharge/ctf/rifle/blue

/obj/item/ammo_box/magazine/recharge/ctf/rifle/blue
	ammo_type = /obj/item/ammo_casing/laser/ctf/rifle/blue

/obj/item/ammo_casing/laser/ctf/rifle/blue
	projectile_type = /obj/projectile/beam/ctf/rifle/blue

/obj/projectile/beam/ctf/rifle/blue
	icon_state = "bluelaser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser

// Shotgun
/obj/item/gun/ballistic/shotgun/ctf/blue
	accepted_magazine_type = /obj/item/ammo_box/magazine/recharge/ctf/shotgun/blue

/obj/item/ammo_box/magazine/recharge/ctf/shotgun/blue
	ammo_type = /obj/item/ammo_casing/laser/ctf/shotgun/blue

/obj/item/ammo_casing/laser/ctf/shotgun/blue
	projectile_type = /obj/projectile/beam/ctf/shotgun/blue

/obj/projectile/beam/ctf/shotgun/blue
	icon_state = "bluelaser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser

// DMR
/obj/item/gun/ballistic/automatic/laser/ctf/marksman/blue
	accepted_magazine_type = /obj/item/ammo_box/magazine/recharge/ctf/marksman/blue

/obj/item/ammo_box/magazine/recharge/ctf/marksman/blue
	ammo_type = /obj/item/ammo_casing/laser/ctf/marksman/blue

/obj/item/ammo_casing/laser/ctf/marksman/blue
	projectile_type = /obj/projectile/beam/ctf/marksman/blue

/obj/projectile/beam/ctf/marksman/blue

// Instakill
/obj/item/gun/energy/laser/instakill/ctf/blue
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit. This one has a blue design."
	icon_state = "instagibblue"
	inhand_icon_state = "instagibblue"
	ammo_type = list(/obj/item/ammo_casing/energy/instakill/blue)

/obj/item/ammo_casing/energy/instakill/blue
	projectile_type = /obj/projectile/beam/instakill/blue

/obj/projectile/beam/instakill/blue
	icon_state = "blue_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE

// GREEN TEAM GUNS

// Rifle
/obj/item/gun/ballistic/automatic/laser/ctf/green
	accepted_magazine_type = /obj/item/ammo_box/magazine/recharge/ctf/rifle/green

/obj/item/ammo_box/magazine/recharge/ctf/rifle/green
	ammo_type = /obj/item/ammo_casing/laser/ctf/rifle/green

/obj/item/ammo_casing/laser/ctf/rifle/green
	projectile_type = /obj/projectile/beam/ctf/rifle/green

/obj/projectile/beam/ctf/rifle/green
	icon_state = "xray"
	light_color = COLOR_VERY_PALE_LIME_GREEN
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser

// Shotgun
/obj/item/gun/ballistic/shotgun/ctf/green
	accepted_magazine_type = /obj/item/ammo_box/magazine/recharge/ctf/shotgun/green

/obj/item/ammo_box/magazine/recharge/ctf/shotgun/green
	ammo_type = /obj/item/ammo_casing/laser/ctf/shotgun/green

/obj/item/ammo_casing/laser/ctf/shotgun/green
	projectile_type = /obj/projectile/beam/ctf/shotgun/green

/obj/projectile/beam/ctf/shotgun/green
	icon_state = "xray"
	light_color = COLOR_VERY_PALE_LIME_GREEN
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser

// DMR
/obj/item/gun/ballistic/automatic/laser/ctf/marksman/green
	accepted_magazine_type = /obj/item/ammo_box/magazine/recharge/ctf/marksman/green

/obj/item/ammo_box/magazine/recharge/ctf/marksman/green
	ammo_type = /obj/item/ammo_casing/laser/ctf/marksman/green

/obj/item/ammo_casing/laser/ctf/marksman/green
	projectile_type = /obj/projectile/beam/ctf/marksman/green

/obj/projectile/beam/ctf/marksman/green
	icon_state = "xray"
	tracer_type = /obj/effect/projectile/tracer/xray
	muzzle_type = /obj/effect/projectile/muzzle/xray
	impact_type = /obj/effect/projectile/impact/xray

// Instakill
/obj/item/gun/energy/laser/instakill/ctf/green
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit. This one has a green design."
	icon_state = "instagibgreen"
	inhand_icon_state = "instagibgreen"
	ammo_type = list(/obj/item/ammo_casing/energy/instakill/green)

/obj/item/ammo_casing/energy/instakill/green
	projectile_type = /obj/projectile/beam/instakill/green

/obj/projectile/beam/instakill/green
	icon_state = "green_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = COLOR_VERY_PALE_LIME_GREEN

// YELLOW TEAM GUNS

// Rifle
/obj/item/gun/ballistic/automatic/laser/ctf/yellow
	accepted_magazine_type = /obj/item/ammo_box/magazine/recharge/ctf/rifle/yellow

/obj/item/ammo_box/magazine/recharge/ctf/rifle/yellow
	ammo_type = /obj/item/ammo_casing/laser/ctf/rifle/yellow

/obj/item/ammo_casing/laser/ctf/rifle/yellow
	projectile_type = /obj/projectile/beam/ctf/rifle/yellow

/obj/projectile/beam/ctf/rifle/yellow
	icon_state = "gaussstrong"
	light_color = COLOR_VERY_SOFT_YELLOW
	impact_effect_type = /obj/effect/temp_visual/impact_effect/yellow_laser

// Shotgun
/obj/item/gun/ballistic/shotgun/ctf/yellow
	accepted_magazine_type = /obj/item/ammo_box/magazine/recharge/ctf/shotgun/yellow

/obj/item/ammo_box/magazine/recharge/ctf/shotgun/yellow
	ammo_type = /obj/item/ammo_casing/laser/ctf/shotgun/yellow

/obj/item/ammo_casing/laser/ctf/shotgun/yellow
	projectile_type = /obj/projectile/beam/ctf/shotgun/yellow

/obj/projectile/beam/ctf/shotgun/yellow
	icon_state = "gaussstrong"
	light_color = COLOR_VERY_SOFT_YELLOW
	impact_effect_type = /obj/effect/temp_visual/impact_effect/yellow_laser

// DMR
/obj/item/gun/ballistic/automatic/laser/ctf/marksman/yellow
	accepted_magazine_type = /obj/item/ammo_box/magazine/recharge/ctf/marksman/yellow

/obj/item/ammo_box/magazine/recharge/ctf/marksman/yellow
	ammo_type = /obj/item/ammo_casing/laser/ctf/marksman/yellow

/obj/item/ammo_casing/laser/ctf/marksman/yellow
	projectile_type = /obj/projectile/beam/ctf/marksman/yellow

/obj/projectile/beam/ctf/marksman/yellow
	icon_state = "gaussstrong"
	tracer_type = /obj/effect/projectile/tracer/solar
	muzzle_type = /obj/effect/projectile/muzzle/solar
	impact_type = /obj/effect/projectile/impact/solar

// Instakill
/obj/item/gun/energy/laser/instakill/ctf/yellow
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit. This one has a yellow design."
	icon_state = "instagibyellow"
	inhand_icon_state = "instagibyellow"
	ammo_type = list(/obj/item/ammo_casing/energy/instakill/yellow)

/obj/item/ammo_casing/energy/instakill/yellow
	projectile_type = /obj/projectile/beam/instakill/yellow

/obj/projectile/beam/instakill/yellow
	icon_state = "yellow_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/yellow_laser
	light_color = COLOR_VERY_SOFT_YELLOW

// RED TEAM SUITS

// Regular
/obj/item/clothing/suit/armor/vest/ctf/red
	name = "red shielded vest"
	inhand_icon_state = null
	team_shield_icon = "shield-red"
	greyscale_colors = COLOR_VIVID_RED

// Light
/obj/item/clothing/suit/armor/vest/ctf/light/red
	name = "light red shielded vest"
	inhand_icon_state = null
	team_shield_icon = "shield-red"
	greyscale_colors = COLOR_VIVID_RED

// BLUE TEAM SUITS

// Regular
/obj/item/clothing/suit/armor/vest/ctf/blue
	name = "blue shielded vest"
	inhand_icon_state = null
	team_shield_icon = "shield-old"
	greyscale_colors = COLOR_DARK_CYAN

// Light
/obj/item/clothing/suit/armor/vest/ctf/light/blue
	name = "light blue shielded vest"
	inhand_icon_state = null
	team_shield_icon = "shield-old"
	greyscale_colors = COLOR_DARK_CYAN

// GREEN TEAM SUITS

// Regular
/obj/item/clothing/suit/armor/vest/ctf/green
	name = "green shielded vest"
	inhand_icon_state = null
	team_shield_icon = "shield-green"
	greyscale_colors = COLOR_LIME

// Light
/obj/item/clothing/suit/armor/vest/ctf/light/green
	name = "light green shielded vest"
	inhand_icon_state = null
	team_shield_icon = "shield-green"
	greyscale_colors = COLOR_LIME

// YELLOW TEAM SUITS

// Regular
/obj/item/clothing/suit/armor/vest/ctf/yellow
	name = "yellow shielded vest"
	inhand_icon_state = null
	team_shield_icon = "shield-yellow"
	greyscale_colors = COLOR_VIVID_YELLOW

// Light
/obj/item/clothing/suit/armor/vest/ctf/light/yellow
	name = "light yellow shielded vest"
	inhand_icon_state = null
	team_shield_icon = "shield-yellow"
	greyscale_colors = COLOR_VIVID_YELLOW
