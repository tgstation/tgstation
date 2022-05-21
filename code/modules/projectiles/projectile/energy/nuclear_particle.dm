//Nuclear particle projectile - a deadly side effect of fusion
/obj/projectile/energy/nuclear_particle
	name = "nuclear particle"
	icon_state = "nuclear_particle"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	armor_flag = ENERGY
	damage_type = TOX
	damage = 10
	speed = 0.4
	hitsound = 'sound/weapons/emitter2.ogg'
	impact_type = /obj/effect/projectile/impact/xray
	var/static/list/particle_colors = list(
		"red" = "#FF0000",
		"blue" = "#00FF00",
		"green" = "#0000FF",
		"yellow" = "#FFFF00",
		"cyan" = "#00FFFF",
		"purple" = "#FF00FF"
	)
	var/internal_power = 0

/obj/projectile/energy/nuclear_particle/Initialize(mapload, internal_power = 0)
	. = ..()
	//Random color time!
	var/our_color = pick(particle_colors)
	add_atom_colour(particle_colors[our_color], FIXED_COLOUR_PRIORITY)
	set_light(2, 1.5, particle_colors[our_color]) //Range of 2, brightness of 1.5
	src.internal_power = internal_power

/obj/projectile/energy/nuclear_particle/on_hit(atom/target, blocked, pierce_hit)
	if (ishuman(target))
		radiation_pulse(target, max_range = 0, threshold = RAD_FULL_INSULATION)

	..()

/atom/proc/fire_nuclear_particle(angle = rand(0,360), speed = 0.4, internal_power = 0) //used by fusion to fire random nuclear particles. Fires one particle in a random direction.
	var/obj/projectile/energy/nuclear_particle/particle = new /obj/projectile/energy/nuclear_particle(src, internal_power)
	particle.speed = speed
	particle.fire(angle)
