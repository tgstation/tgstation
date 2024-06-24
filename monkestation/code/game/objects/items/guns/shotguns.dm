//god fucking bless brazil
/obj/item/gun/ballistic/shotgun/doublebarrel/brazil
	name = "six-barreled \"TRABUCO\" shotgun"
	desc = "Dear fucking god, what the fuck even is this!? Theres a green flag with a blue circle and a yellow diamond around it. Some text in the circle says: \"ORDEM E PROGRESSO.\""
	icon_state = "shotgun_brazil"
	slot_flags = NONE
	icon = 'monkestation/icons/obj/guns/48x32guns.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'icons/mob/inhands/weapons/64x_guns_right.dmi'
	w_class = WEIGHT_CLASS_BULKY
	force = 15 //blunt edge and really heavy
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/six
	burst_size = 6
	pb_knockback = 12
	unique_reskin = null
	recoil = 5
	weapon_weight = WEAPON_LIGHT
	fire_sound = 'monkestation/sound/weapons/gun/shotgun/quadfire.ogg'
	rack_sound = 'monkestation/sound/weapons/gun/shotgun/quadrack.ogg'
	load_sound = 'monkestation/sound/weapons/gun/shotgun/quadinsert.ogg'
	fire_sound_volume = 50
	rack_sound_volume = 50
	can_be_sawn_off = FALSE

	var/knockback_distance = 12
	var/death = 10

/obj/item/gun/ballistic/shotgun/doublebarrel/brazil/shoot_live_shot(mob/living/user, pointblank, atom/pbtarget, message)
	. = ..()
	var/atom/throw_target = get_edge_target_turf(user, get_dir(pbtarget, user))
	user.throw_at(throw_target, knockback_distance, 2)
	if(prob(death))
		user.gib()

/obj/item/gun/ballistic/shotgun/doublebarrel/brazil/death
	name = "Force of Nature"
	desc = "So you have chosen death."
	icon_state = "shotgun_e"
	worn_icon_state = "none"
	burst_size = 100
	pb_knockback = 40
	recoil = 10
	fire_sound_volume = 100
	knockback_distance = 100
	death = 100
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/shot/hundred


/obj/item/ammo_box/magazine/internal/shot/six
	name = "six-barrel shotgun internal magazine"
	max_ammo = 1
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/six

/obj/item/ammo_casing/shotgun/buckshot/six
	pellets = 36
	variance = 25
	projectile_type = /obj/projectile/bullet/pellet/shotgun_death

/obj/item/ammo_box/magazine/internal/shot/hundred
	name = "hundred-barrel shotgun internal magazine"
	max_ammo = 1
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/hundred

/obj/item/ammo_casing/shotgun/buckshot/hundred
	pellets = 600
	variance = 25

/obj/projectile/bullet/pellet/shotgun_death
	name = "buckshot pellet"
	damage = 25
	wound_bonus = 10
	bare_wound_bonus = 10

	ricochets_max = 6
	ricochet_chance = 240
	ricochet_decay_chance = 0.9
	ricochet_decay_damage = 0.8
	ricochet_auto_aim_range = 2
	ricochet_auto_aim_angle = 30
	ricochet_incidence_leeway = 75
