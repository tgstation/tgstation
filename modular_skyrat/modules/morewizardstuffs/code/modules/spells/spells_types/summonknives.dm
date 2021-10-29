/obj/effect/proc_holder/spell/aimed/summonknives
	name = "Summon Knives"
	desc = "Throw several knives where you aim at!"
	invocation = "POIN'T ED'JIS!"
	action_icon_state = "projectile"
	invocation_type = INVOCATION_SHOUT
	charge_max = 200
	cooldown_min = 35
	projectile_type = /obj/projectile/summonedknife
	projectile_amount = 3
	projectiles_per_fire = 5
	var/projectile_initial_spread_amount = 30
	var/projectile_location_spread_amount = 12

/obj/effect/proc_holder/spell/aimed/summonknives/ready_projectile(obj/projectile/P, atom/target, mob/user, iteration)
	var/total_angle = projectile_initial_spread_amount * 2
	var/adjusted_angle = total_angle - ((projectile_initial_spread_amount / projectiles_per_fire) * 0.5)
	var/one_fire_angle = adjusted_angle / projectiles_per_fire
	var/current_angle = iteration * one_fire_angle - (projectile_initial_spread_amount / 2)
	P.pixel_x = rand(-projectile_location_spread_amount, projectile_location_spread_amount)
	P.pixel_y = rand(-projectile_location_spread_amount, projectile_location_spread_amount)
	P.preparePixelProjectile(target, user, null, current_angle)

/obj/projectile/summonedknife
	name = "Knife"
	icon = 'modular_skyrat/modules/morewizardstuffs/icons/obj/projectile.dmi'
	icon_state = "knife"
	damage_type = BRUTE
	damage = 10

