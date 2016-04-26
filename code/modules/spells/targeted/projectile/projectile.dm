/*
Projectile spells make special projectiles (obj/item/spell_projectile) and fire them at targets
Dumbfire projectile spells fire directly ahead of the user
spell_projectiles call their spell's (carried) prox_cast when they get in range of a target
If the spell_projectile is seeking, it will update its target every process and follow them
*/

/spell/targeted/projectile
	name = "projectile spell"

	range = 7

	var/proj_type = /obj/item/projectile/spell_projectile //use these. They are very nice

	var/proj_step_delay = 1 //lower = faster
	var/cast_prox_range = 1

/spell/targeted/projectile/cast(list/targets, mob/user = usr)

	if(istext(proj_type))
		proj_type = text2path(proj_type) // sanity filters

	for(var/atom/target in targets)
		var/obj/item/projectile/projectile = new proj_type(user.loc, user.dir)

		if(!projectile)
			return

		projectile.original = target
		projectile.starting = get_turf(user)
		projectile.target = get_turf(target)
		projectile.shot_from = user //fired from the user
		projectile.current = projectile.original
		projectile.yo = target.y - user.y
		projectile.xo = target.x - user.x
		projectile.kill_count = src.duration
		projectile.step_delay = proj_step_delay
		if(istype(projectile, /obj/item/projectile/spell_projectile))
			var/obj/item/projectile/spell_projectile/SP = projectile
			SP.carried = src //casting is magical
		spawn()
			projectile.OnFired()
			projectile.process()
	return

/spell/targeted/projectile/proc/choose_prox_targets(mob/user = usr, var/atom/movable/spell_holder)
	var/list/targets = list()
	for(var/mob/living/M in range(spell_holder, cast_prox_range))
		if(M == user && !(spell_flags & INCLUDEUSER))
			continue
		if(spell_holder.Adjacent(M))
			targets += M
	return targets

/spell/targeted/projectile/proc/prox_cast(var/list/targets, var/atom/movable/spell_holder)
	return targets