///A basic turret that shoots at nearby mobs. Intended to be used for the legion megafauna.
/obj/structure/legionturret
	name = "Legion head"
	desc = "The eyes pierce your soul."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "legion_turret"
	density = TRUE
	anchored = TRUE
	light_power = 0.1
	light_range = 2
	max_integrity = 80
	armor = list("melee" = 0, "bullet" = 0, "laser" = 100, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	var/tracer_type = /obj/item/projectile/beam/legion_tracer ///What kind of projectile the tracer should be
	var/projectile_type = /obj/item/projectile/beam/legion ///What kind of projectile the actual damaging part should be.
	var/firing_cooldown = 2 ///Cooldown between shots.
	var/firing_timer = 0 ///Ticks on every process. If smaller than firing_cooldown, this tries to shoot.
	var/shot_delay = 4 ///How long it takes between shooting the tracer and the projectile.
	var/faction = list("mining") ///Compared with the targeted mobs. If they have the faction, turret won't shoot.

/obj/structure/legionturret/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	flick("legion_turret_intro", src)

/obj/structure/legionturret/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

///Handles an extremely basic basic AI. Runs on SSobj
/obj/structure/legionturret/process()
	firing_timer++
	if(firing_cooldown > firing_timer) //make sure all turrets fire at the same time.
		return
	firing_timer = 0
	for(var/mob/living/L in circlerange(src, 7)&oview(6, src))
		if(L.stat == DEAD)
			continue
		if(faction_check(faction, L.faction))
			continue
		fire(L)

///Called when attacking a target. Shoots a projectile at the turf underneat the target.
/obj/structure/legionturret/proc/fire(atom/target)
	var/turf/T = get_turf(target)
	if(!T)
		return
	var/obj/item/projectile/tracer = new tracer_type(loc)
	tracer.firer = src
	tracer.preparePixelProjectile(target, src)
	tracer.fire()
	playsound(src, 'sound/machines/airlockopen.ogg', 100, TRUE)
	addtimer(CALLBACK(src, .proc/fire_beam, tracer.Angle), shot_delay)

///Called shot_delay after the turret shot the tracer. Shoots a projectile into the same direction.
/obj/structure/legionturret/proc/fire_beam(angle)
	var/obj/item/projectile/ouchie = new projectile_type(loc)
	ouchie.firer = src
	ouchie.fire(angle)
	playsound(src, 'sound/effects/bin_close.ogg', 100, TRUE)

///Used for the legion turret.
/obj/item/projectile/beam/legion_tracer
	name = "tracer"
	icon_state = "u_laser"
	damage = 0
	nodamage = TRUE
	range = 6
	eyeblur = 0
	light_color = LIGHT_COLOR_RED
	tracer_type = /obj/effect/projectile/tracer/legion/tracer
	muzzle_type = /obj/effect/projectile/tracer/legion/tracer
	impact_type = /obj/effect/projectile/tracer/legion/tracer
	hitscan = TRUE
	suppressed = TRUE
	movement_type = UNSTOPPABLE

///Used for the legion turret.
/obj/item/projectile/beam/legion
	name = "blood pulse"
	icon_state = "u_laser"
	hitsound = 'sound/magic/magic_missile.ogg'
	damage = 19
	range = 6
	light_color = LIGHT_COLOR_RED
	impact_effect_type = /obj/effect/temp_visual/kinetic_blast
	tracer_type = /obj/effect/projectile/tracer/legion
	muzzle_type = /obj/effect/projectile/tracer/legion
	impact_type = /obj/effect/projectile/tracer/legion
	hitscan = TRUE
	movement_type = UNSTOPPABLE

///Used for the legion turret tracer.
/obj/effect/projectile/tracer/legion/tracer
	icon = 'icons/effects/beam.dmi'
	icon_state = "blood_light"

///Used for the legion turret beam.
/obj/effect/projectile/tracer/legion
	icon = 'icons/effects/beam.dmi'
	icon_state = "blood"
