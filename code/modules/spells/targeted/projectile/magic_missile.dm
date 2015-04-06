/spell/targeted/projectile/magic_missile
	name = "Magic Missile"
	desc = "This spell fires several, slow moving, magic projectiles at nearby targets."

	school = "evocation"
	charge_max = 150
	spell_flags = NEEDSCLOTHES
	invocation = "FORTI GY AMA"
	invocation_type = SpI_SHOUT
	range = 7
	cooldown_min = 90 //15 deciseconds reduction per rank

	max_targets = 0

	proj_type = /obj/item/projectile/spell_projectile/seeking/magic_missile
	duration = 10
	proj_step_delay = 5

	hud_state = "wiz_mm"

	amt_paralysis = 3
	amt_stunned = 3

	amt_dam_fire = 10

/spell/targeted/projectile/magic_missile/prox_cast(var/list/targets, atom/spell_holder)
	spell_holder.visible_message("<span class='danger'>\The [spell_holder] pops with a flash!</span>")
	for(var/mob/living/M in targets)
		apply_spell_damage(M)
	return

//PROJECTILE

/obj/item/projectile/spell_projectile/seeking/magic_missile
	name = "magic missile"
	icon_state = "magicm"

	proj_trail = 1
	proj_trail_lifespan = 5
	proj_trail_icon_state = "magicmd"