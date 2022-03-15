/obj/effect/proc_holder/spell/targeted/projectile/magic_missile
	name = "Magic Missile"
	desc = "This spell fires several, slow moving, magic projectiles at nearby targets."

	school = SCHOOL_EVOCATION
	charge_max = 200
	requires_wizard_garb = TRUE
	invocation = "FORTI GY AMA"
	invocation_type = INVOCATION_SHOUT
	range = 7
	cooldown_min = 60 //35 deciseconds reduction per rank
	max_targets = 0
	proj_type = /obj/projectile/magic/spell/magic_missile
	action_icon_state = "magicm"
	sound = 'sound/magic/magic_missile.ogg'

/obj/projectile/magic/spell/magic_missile
	name = "magic missile"
	icon_state = "magicm"
	range = 20
	speed = 5
	trigger_range = 0
	linger = TRUE
	nodamage = FALSE
	paralyze = 60
	hitsound = 'sound/magic/mm_hit.ogg'

	trail = TRUE
	trail_lifespan = 5
	trail_icon_state = "magicmd"

/obj/projectile/magic/spell/magic_missile/on_hit(target)
	. = ..()
	if(ismob(target))
		var/mob/M = target
		if(M.anti_magic_check())
			M.visible_message(span_warning("[src] vanishes on contact with [target]!"))
			return BULLET_ACT_BLOCK
