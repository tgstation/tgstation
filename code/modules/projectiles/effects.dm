/obj/effect/overlay/temp/projectile
	icon = 'icons/obj/projectiles_hitscan.dmi'
	layer = MOB_LAYER
	anchored = 1
	duration = 5
	randomdir = FALSE

/obj/effect/overlay/temp/projectile/New(var/turf/location)
	if(istype(location))
		loc = location
	..()

/obj/effect/overlay/temp/projectile/proc/set_transform(var/matrix/M)
	if(istype(M))
		transform = M

/obj/effect/overlay/temp/projectile/tracer
	icon_state = "beam_red"

/obj/effect/overlay/temp/projectile/muzzle
	icon_state = "muzzle_red"

/obj/effect/overlay/temp/projectile/impact
	icon_state = "impact_red"

/obj/effect/overlay/temp/projectile/tracer/pulse
	icon_state = "beam_pulse"

/obj/effect/overlay/temp/projectile/muzzle/pulse
	icon_state = "muzzle_pulse"

/obj/effect/overlay/temp/projectile/impact/pulse
	icon_state = "impact_pulse"

/obj/effect/overlay/temp/projectile/tracer/stun
	icon_state = "beam_stun"

/obj/effect/overlay/temp/projectile/muzzle/stun
	icon_state = "muzzle_stun"

/obj/effect/overlay/temp/projectile/impact/stun
	icon_state = "impact_stun"

/obj/effect/overlay/temp/projectile/tracer/xray
	icon_state = "beam_green"

/obj/effect/overlay/temp/projectile/muzzle/xray
	icon_state = "muzzle_green"

/obj/effect/overlay/temp/projectile/impact/xray
	icon_state = "impact_green"

/obj/effect/overlay/temp/projectile/tracer/heavy
	icon_state = "beam_heavy"

/obj/effect/overlay/temp/projectile/muzzle/heavy
	icon_state = "muzzle_heavy"

/obj/effect/overlay/temp/projectile/impact/heavy
	icon_state = "impact_heavy"

/obj/effect/overlay/temp/projectile/tracer/disable
	icon_state = "beam_omni"

/obj/effect/overlay/temp/projectile/muzzle/disable
	icon_state = "muzzle_omni"

/obj/effect/overlay/temp/projectile/impact/disable
	icon_state = "impact_omni"

/obj/effect/overlay/temp/projectile/tracer/blue
	icon_state = "beam_blue"

/obj/effect/overlay/temp/projectile/muzzle/blue
	icon_state = "muzzle_blue"

/obj/effect/overlay/temp/projectile/impact/blue
	icon_state = "impact_blue"