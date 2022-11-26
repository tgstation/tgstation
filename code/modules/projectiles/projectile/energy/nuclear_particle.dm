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
	///Internal energy to release on impact (used on the SM and the nuclear accumulator)
	var/internal_power = 0
	///Additional effects, electrocutes and shocks the mob, light emp if the mob is a silicon
	var/dangerous = FALSE

/obj/projectile/energy/nuclear_particle/Initialize(mapload, internal_power = 0, icon_state, dangerous = FALSE)
	. = ..()
	//Random color time!
	src.internal_power = internal_power
	src.dangerous = dangerous
	if(!icon_state)
		//Random color time!
		var/our_color = pick(particle_colors)
		add_atom_colour(particle_colors[our_color], FIXED_COLOUR_PRIORITY)
		set_light(2, 1.5, particle_colors[our_color]) //Range of 2, brightness of 1.5
	else
		src.icon_state = icon_state
		update_colours()

/obj/projectile/energy/nuclear_particle/on_hit(atom/target, blocked, pierce_hit)
	if (!isliving(target))
		return ..()

	radiation_pulse(target, max_range = 0, threshold = RAD_FULL_INSULATION)

	if(!dangerous || !prob(35))
		return ..()

	var/mob/living/hit_mob = target
	ADD_TRAIT(hit_mob, TRAIT_BEING_SHOCKED, WAS_SHOCKED)
	addtimer(TRAIT_CALLBACK_REMOVE(hit_mob, TRAIT_BEING_SHOCKED, WAS_SHOCKED), 1 SECONDS)
	var/shock_damage = min(round(internal_power/10), 90) + rand(-5, 5)
	hit_mob.electrocute_act(shock_damage, src, 1, SHOCK_TESLA)
	if(issilicon(hit_mob))
		var/mob/living/silicon/hit_silicon = hit_mob
		hit_silicon.emp_act(EMP_LIGHT)

	return ..()

/obj/projectile/energy/nuclear_particle/proc/update_colours()
	var/list/colour = color_matrix_rotate_hue(internal_power / 30)
	add_atom_colour(colour, FIXED_COLOUR_PRIORITY)

/atom/proc/fire_nuclear_particle(angle = rand(0,360), speed = 0.4, internal_power = 0, set_icon_state, dangerous = FALSE) //used by fusion to fire random nuclear particles. Fires one particle in a random direction.
	var/obj/projectile/energy/nuclear_particle/particle = new /obj/projectile/energy/nuclear_particle(src, internal_power, set_icon_state, dangerous)
	particle.speed = speed
	particle.fire(angle)
