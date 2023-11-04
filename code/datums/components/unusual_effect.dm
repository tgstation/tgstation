
/particles/unusual_effect
	icon = 'icons/effects/particles/pollen.dmi'
	icon_state = "pollen"
	width = 100
	height = 100
	count = 1000
	spawning = 4
	lifespan = 0.7 SECONDS
	fade = 1 SECONDS
	grow = -0.01
	velocity = list(0, 0)
	position = generator(GEN_CIRCLE, 0, 16, NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(0, -0.2), list(0, 0.2))
	gravity = list(0, 0.95)
	scale = generator(GEN_VECTOR, list(0.3, 0.3), list(1,1), NORMAL_RAND)
	rotation = 30
	spin = generator(GEN_NUM, -20, 20)

/// Creates a cool looking effect on the movable.
/// In the future, this could be expanded to have more interesting particles and effects.
/datum/component/unusual_effect
	dupe_mode = COMPONENT_DUPE_HIGHLANDER

	var/obj/effect/abstract/particle_holder/special_effects

	var/color

	COOLDOWN_DECLARE(glow_cooldown)

/datum/component/unusual_effect/Initialize(color, include_particles = FALSE)
	var/atom/movable/parent_movable = parent
	if (!istype(parent_movable))
		return COMPONENT_INCOMPATIBLE

	src.color = color
	parent_movable.add_filter("unusual_effect", 2, list("type" = "outline", "color" = color, "size" = 2))
	if(include_particles)
		special_effects = new(parent_movable, /particles/unusual_effect)
	START_PROCESSING(SSobj, src)

/datum/component/unusual_effect/Destroy(force, silent)
	var/atom/movable/parent_movable = parent
	if (istype(parent_movable))
		parent_movable.remove_filter("unusual_effect")
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/component/unusual_effect/process(seconds_per_tick)
	var/atom/movable/parent_movable = parent
	var/filter = parent_movable.get_filter("unusual_effect")
	if (!filter)
		parent_movable.add_filter("unusual_effect", 2, list("type" = "outline", "color" = color, "size" = 2))
		return
	if(!COOLDOWN_FINISHED(src, glow_cooldown))
		return

	animate(filter, alpha = 110, time = 1.5 SECONDS, loop = -1)
	animate(alpha = 40, time = 2.5 SECONDS)
	COOLDOWN_START(src, glow_cooldown, 4 SECONDS)
