//Nuclear particle projectile - a deadly side effect of fusion
/obj/item/projectile/energy/nuclear_particle
	name = "nuclear particle"
	icon_state = "nuclear_particle"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	damage = 20
	damage_type = TOX
	irradiate = 2500 //enough to knockdown and induce vomiting
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

/obj/item/projectile/energy/nuclear_particle/Initialize()
	. = ..()
	//Random color time!
	var/our_color = pick(particle_colors)
	add_atom_colour(particle_colors[our_color], FIXED_COLOUR_PRIORITY)
	set_light(4, 3, particle_colors[our_color]) //Range of 4, brightness of 3 - Same range as a flashlight

/atom/proc/fire_nuclear_particles(power_ratio) //used by fusion to fire random # of nuclear particles - power ratio determines about how many are fired
	var/random_particles = rand(3,6)
	var/particles_to_fire
	var/particles_fired
	switch(power_ratio) //multiply random_particles * factor for whatever tier
		if(0 to FUSION_MID_TIER_THRESHOLD)
			particles_to_fire = random_particles * FUSION_PARTICLE_FACTOR_LOW
		if(FUSION_MID_TIER_THRESHOLD to FUSION_HIGH_TIER_THRESHOLD)
			particles_to_fire = random_particles * FUSION_PARTICLE_FACTOR_MID
		if(FUSION_HIGH_TIER_THRESHOLD to FUSION_SUPER_TIER_THRESHOLD)
			particles_to_fire = random_particles * FUSION_PARTICLE_FACTOR_HIGH
		if(FUSION_SUPER_TIER_THRESHOLD to INFINITY)
			particles_to_fire = random_particles * FUSION_PARTICLE_FACTOR_SUPER
	while(particles_to_fire)
		particles_fired++
		var/angle = rand(0,360)
		var/obj/item/projectile/energy/nuclear_particle/P = new /obj/item/projectile/energy/nuclear_particle(src)
		addtimer(CALLBACK(P, /obj/item/projectile.proc/fire, angle), particles_fired) //multiply particles fired * delay so the particles end up stagnated (once every decisecond)
		particles_to_fire--