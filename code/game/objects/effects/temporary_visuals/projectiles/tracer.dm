/obj/effect/projectile/tracer
	name = "beam"
	icon = 'icons/obj/weapons/guns/projectiles_tracer.dmi'

/obj/effect/projectile/tracer/laser
	name = "laser"
	icon_state = "beam"

/obj/effect/projectile/tracer/laser/blue
	icon_state = "beam_blue"

/obj/effect/projectile/tracer/disabler
	name = "disabler"
	icon_state = "beam_omni"

/obj/effect/projectile/tracer/xray
	name = "\improper X-ray laser"
	icon_state = "xray"

/obj/effect/projectile/tracer/pulse
	name = "pulse laser"
	icon_state = "u_laser"

/obj/effect/projectile/tracer/plasma_cutter
	name = "plasma blast"
	icon_state = "plasmacutter"

/obj/effect/projectile/tracer/stun
	name = "stun beam"
	icon_state = "stun"

/obj/effect/projectile/tracer/heavy_laser
	name = "heavy laser"
	icon_state = "beam_heavy"

/obj/effect/projectile/tracer/solar
	name = "solar beam"
	icon_state = "solar"

/obj/effect/projectile/tracer/solar/thin
	icon_state = "solar_thin"

/obj/effect/projectile/tracer/solar/thinnest
	icon_state = "solar_thinnest"

//BEAM RIFLE
/obj/effect/projectile/tracer/tracer/beam_rifle
	icon_state = "tracer_beam"

/obj/effect/projectile/tracer/tracer/aiming
	icon_state = "pixelbeam_greyscale"
	plane = ABOVE_LIGHTING_PLANE

/obj/effect/projectile/tracer/wormhole
	icon_state = "wormhole_g"

/obj/effect/projectile/tracer/laser/emitter
	name = "emitter beam"
	icon_state = "emitter"

/obj/effect/projectile/tracer/sniper
	icon_state = "sniper"

/obj/effect/projectile/tracer/lightning
	icon = 'icons/effects/beam.dmi'
	icon_state = "lightning2"

/obj/effect/projectile/tracer/lightning/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/effect/projectile/tracer/lightning/update_icon_state()
	. = ..()
	icon_state = "lightning[rand(1, 12)]"
