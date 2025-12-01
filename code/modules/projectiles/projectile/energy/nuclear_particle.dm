//Nuclear particle projectile - a deadly side effect of fusion
/obj/projectile/energy/nuclear_particle
	name = "nuclear particle"
	icon_state = "nuclear_particle"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	armor_flag = ENERGY
	damage_type = TOX
	damage = 10
	speed = 2.5
	hitsound = 'sound/items/weapons/emitter2.ogg'
	impact_type = /obj/effect/projectile/impact/xray
	var/static/list/particle_colors = list(
		"red" = COLOR_RED,
		"blue" = COLOR_VIBRANT_LIME,
		"green" = COLOR_BLUE,
		"yellow" = COLOR_YELLOW,
		"cyan" = COLOR_CYAN,
		"purple" = COLOR_MAGENTA
	)

/obj/projectile/energy/nuclear_particle/Initialize(mapload)
	. = ..()
	//Random color time!
	var/our_color = pick(particle_colors)
	add_atom_colour(particle_colors[our_color], FIXED_COLOUR_PRIORITY)
	set_light(4, 3, particle_colors[our_color]) //Range of 4, brightness of 3 - Same range as a flashlight

/obj/projectile/energy/nuclear_particle/on_hit(atom/target, blocked, pierce_hit)
	if (ishuman(target))
		SSradiation.irradiate(target)

	return ..()

/atom/proc/fire_nuclear_particle(angle = rand(0,360)) //used by fusion to fire random nuclear particles. Fires one particle in a random direction.
	var/obj/projectile/energy/nuclear_particle/P = new /obj/projectile/energy/nuclear_particle(src)
	P.fire(angle)
