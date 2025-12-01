/obj/structure/window/fulltile/voidwalker
	name = "void-smeared window"
	desc = "This window darkens the view of the other side, to the point that nothing but the glow of the stars can be made out. Nothing reflects in the pane."
	max_integrity = 75 //Doesn't have the damage deflection of a reinforced window
	/// Particle effect for making the window look spooky.
	var/obj/effect/abstract/particle_holder/spooky_particles

/obj/structure/window/fulltile/voidwalker/Initialize(mapload, direct)
	. = ..()
	spooky_particles = new(src, /particles/void_window)
	add_atom_colour("#642a949d", FIXED_COLOUR_PRIORITY)

/obj/structure/window/fulltile/voidwalker/Destroy()
	. = ..()
	QDEL_NULL(spooky_particles)

/particles/void_window
	icon = 'icons/effects/particles/goop.dmi'
	icon_state = list("goop_1" = 6, "goop_2" = 2, "goop_3" = 1)
	width = 100
	height = 100
	count = 100
	spawning = 2
	lifespan = 2 SECONDS
	fade = 4 SECONDS
	velocity = list(0, 0.2, 0)
	position = generator(GEN_BOX, list(-8,-16,0), list(8,16,0), NORMAL_RAND)
	drift = generator(GEN_BOX, list(-8,-16,0), list(8,16,0), NORMAL_RAND)
	spin = generator(GEN_NUM, list(-5,5), NORMAL_RAND)
	friction = 0.5
	gravity = list(0, 0)
	grow = 0.05
	color = "#26114d9d"
	scale = list(0.75, 0.85)
