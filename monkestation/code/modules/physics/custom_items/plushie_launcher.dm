/obj/item/plushie_launcher
	name = "weh cannon"
	desc = "High speed lizards coming your way!"
	icon = 'icons/obj/weapons/guns/ballistic.dmi'
	icon_state = "revolver"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	inhand_icon_state = "gun"
	worn_icon_state = "gun"
	///the spawned path of our plushie
	var/plushie_path = /obj/item/toy/plush/lizard_plushie
	///the force of the plushie
	var/plushie_force = 14
	///fire sound
	var/fire_sound = 'sound/weapons/gun/general/grenade_launch.ogg'
	///the sound the plushie makes while bouncing
	var/bounce_sound = 'monkestation/sound/voice/weh.ogg'
	///fire count
	var/fire_count = 1

/obj/item/plushie_launcher/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!plushie_path)
		return
	for(var/num = 1 to fire_count)
		var/obj/item = new plushie_path(get_turf(src))
		var/list/calculated = calculate_projectile_angle_and_pixel_offsets(item, get_turf(target) && target)
		var/spread = (num - (fire_count * 0.5)) * rand(10, 20)
		var/bounce_angle = calculated[1] + spread
		item.AddComponent(/datum/component/movable_physics, \
				physics_flags = MPHYSICS_QDEL_WHEN_NO_MOVEMENT, \
				angle = bounce_angle, \
				horizontal_velocity = plushie_force, \
				horizontal_friction = rand(0.2 * 100, 0.24 * 100) * 0.75 * 0.01, \
				vertical_friction = 10 * 0.75 * 0.05, \
				z_floor = 0, \
				bounce_callback = CALLBACK(src, PROC_REF(bounce_sound), item), \
			)
		playsound(get_turf(src), fire_sound, 50, TRUE)

/obj/item/plushie_launcher/proc/bounce_sound(obj/item/item)
	playsound(get_turf(item), bounce_sound, 50, TRUE)

/obj/item/plushie_launcher/shotgun
	name = "weh shotgun"
	desc = "High speed lizards coming your way!"
	icon_state = "shotgun"
	worn_icon_state = null
	lefthand_file = 'icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'icons/mob/inhands/weapons/64x_guns_right.dmi'
	inhand_icon_state = "shotgun"
	inhand_x_dimension = 64
	inhand_y_dimension = 64

	fire_count = 4
