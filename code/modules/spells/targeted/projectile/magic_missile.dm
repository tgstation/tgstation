/spell/targeted/projectile/magic_missile
	name = "Magic Missile"
	desc = "This spell fires several, slow moving, magic projectiles at nearby targets."

	school = "evocation"
	charge_max = 150
	spell_flags = NEEDSCLOTHES
	invocation = "FORTI GY AMA"
	invocation_type = "shout"
	range = 7
	cooldown_min = 90 //15 deciseconds reduction per rank

	max_targets = 0

	proj_type = /obj/item/projectile/spell_projectile/seeking/magic_missile
	duration = 10
	proj_step_delay = 5

/spell/targeted/projectile/magic_missile/prox_cast(var/list/targets, atom/spell_holder)
	targets = ..()
	spell_holder.visible_message("<span class='danger'>\The [spell_holder] pops with a flash!</span>")
	for(var/mob/living/M in targets)
		M.Stun(3)
		M.Weaken(3)
		M.adjustFireLoss(10)
	return

//PROJECTILE

/obj/item/projectile/spell_projectile/seeking/magic_missile
	name = "magic missile"
	icon_state = "magicm"

	proj_trail = 1
	proj_trail_lifespan = 5
	proj_trail_icon_state = "magicmd"