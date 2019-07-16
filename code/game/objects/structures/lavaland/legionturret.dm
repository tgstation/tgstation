///A basic turret that shoots at nearby mobs. Intended to be used for the legion megafauna.
/obj/structure/legionturret
	name = "\improper Legion sentinel"
	desc = "The eye pierces your soul."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "legion_turret"
	density = TRUE
	anchored = TRUE
	light_power = 0.5
	light_range = 2
	max_integrity = 80
	luminosity = 6
	layer = ABOVE_OBJ_LAYER
	armor = list("melee" = 0, "bullet" = 0, "laser" = 100, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	///What kind of projectile the actual damaging part should be.
	var/projectile_type = /obj/item/projectile/beam/legion
	///Cooldown between shots.
	var/firing_cooldown = 2
	///Ticks on every process. If smaller than firing_cooldown, this tries to shoot.
	var/firing_timer = 0
	///How long it takes between shooting the tracer and the projectile.
	var/shot_delay = 8
	///Compared with the targeted mobs. If they have the faction, turret won't shoot.
	var/faction = list("mining")

/obj/structure/legionturret/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	flick("legion_turret_intro", src)

/obj/structure/legionturret/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

///Handles an extremely basic basic AI. Runs on SSobj
/obj/structure/legionturret/process()
	firing_timer++
	if(firing_cooldown > firing_timer) //make sure all turrets fire at the same time.
		return
	firing_timer = 0
	for(var/mob/living/L in circlerange(src, 7)&oview(6, src))
		if(L.stat == DEAD || L.stat == UNCONSCIOUS)
			continue
		if(faction_check(faction, L.faction))
			continue
		fire(L)

///Called when attacking a target. Shoots a projectile at the turf underneat the target.
/obj/structure/legionturret/proc/fire(atom/target)
	var/turf/T = get_turf(target)
	var/turf/T1 = get_turf(src)
	if(!T || !T1)
		return
	//someone has buried tracer code in spaghetti. OOF OUCH
	var/angle = Get_Angle(T1, T)
	var/datum/point/vector/V = new(T1.x, T1.y, T1.z, 0, 0, angle) //Let's see if this works.
	generate_tracer_between_points(V, V.return_vector_after_increments(6), /obj/effect/projectile/tracer/legion/tracer, 0, shot_delay, 0, 0, 0, null) //REEE I hate you this.
	playsound(src, 'sound/machines/airlockopen.ogg', 100, TRUE)
	addtimer(CALLBACK(src, .proc/fire_beam, angle), shot_delay)

///Called shot_delay after the turret shot the tracer. Shoots a projectile into the same direction.
/obj/structure/legionturret/proc/fire_beam(angle)
	var/obj/item/projectile/ouchie = new projectile_type(loc)
	ouchie.firer = src
	ouchie.fire(angle)
	playsound(src, 'sound/effects/bin_close.ogg', 100, TRUE)

///Used for the legion turret.
/obj/item/projectile/beam/legion
	name = "blood pulse"
	hitsound = 'sound/magic/magic_missile.ogg'
	damage = 19
	range = 6
	eyeblur = 0
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
