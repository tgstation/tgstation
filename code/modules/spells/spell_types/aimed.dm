
/obj/effect/proc_holder/spell/aimed
	name = "aimed projectile spell"
	var/projectile_type = /obj/item/projectile/magic/teleport
	var/deactive_msg = "You discharge your projectile..."
	var/active_msg = "You charge your projectile!"
	var/base_icon_state = "projectile"
	var/active_icon_state = "projectile"
	var/list/projectile_var_overrides = list()
	var/projectile_amount = 1	//Projectiles per cast.
	var/current_amount = 0	//How many projectiles left.

/obj/effect/proc_holder/spell/aimed/Click()
	var/mob/living/user = usr
	if(!istype(user))
		return
	var/msg
	if(!can_cast(user))
		msg = "<span class='warning'>You can no longer cast [name]!</span>"
		remove_ranged_ability(msg)
		return
	if(active)
		msg = "<span class='notice'>[deactive_msg]</span>"
		remove_ranged_ability(msg)
	else
		msg = "<span class='notice'>[active_msg]<B>Left-click to shoot it at a target!</B></span>"
		current_amount = projectile_amount
		add_ranged_ability(user, msg, TRUE)

/obj/effect/proc_holder/spell/aimed/update_icon()
	if(!action)
		return
	action.button_icon_state = "[base_icon_state][active]"
	action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/aimed/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return FALSE
	var/ignore = (current_amount <= 0)
	if(!cast_check(ignore, ranged_ability_user))
		remove_ranged_ability()
		return FALSE
	var/list/targets = list(target)
	perform(targets,user = ranged_ability_user)
	return TRUE

/obj/effect/proc_holder/spell/aimed/cast(list/targets, mob/living/user)
	var/target = targets[1]
	var/turf/T = user.loc
	var/turf/U = get_step(user, user.dir) // Get the tile infront of the move, based on their direction
	if(!isturf(U) || !isturf(T))
		return FALSE
	fire_projectile(user, target)
	user.newtonian_move(get_dir(U, T))
	if(--current_amount <= 0)
		remove_ranged_ability() //Auto-disable the ability once you run out of bullets.
	return TRUE

/obj/effect/proc_holder/spell/aimed/proc/fire_projectile(mob/living/user, atom/target)
	var/obj/item/projectile/P = new projectile_type(user.loc)
	P.current = get_turf(user)
	P.firer = user
	P.preparePixelProjectile(target, get_turf(target), user)
	for(var/V in projectile_var_overrides)
		if(P.vars[V])
			P.vars[V] = projectile_var_overrides[V]
	P.fire()
	return TRUE

/obj/effect/proc_holder/spell/aimed/lightningbolt
	name = "Lightning Bolt"
	desc = "Fire a high powered lightning bolt at your foes!"
	school = "evocation"
	charge_max = 200
	clothes_req = 1
	invocation = "UN'LTD P'WAH"
	invocation_type = "shout"
	cooldown_min = 30
	active_icon_state = "lightning"
	base_icon_state = "lightning"
	sound = 'sound/magic/lightningbolt.ogg'
	active = FALSE
	projectile_var_overrides = list("tesla_range" = 15, "tesla_power" = 20000, "tesla_boom" = FALSE)
	active_msg = "You energize your hand with arcane lightning!"
	deactive_msg = "You let the energy flow out of your hands back into yourself..."
	projectile_type = /obj/item/projectile/magic/aoe/lightning

/obj/effect/proc_holder/spell/aimed/fireball
	name = "Fireball"
	desc = "This spell fires a fireball at a target and does not require wizard garb."
	school = "evocation"
	charge_max = 60
	clothes_req = 0
	invocation = "ONI SOMA"
	invocation_type = "shout"
	range = 20
	cooldown_min = 20 //10 deciseconds reduction per rank
	projectile_type = /obj/item/projectile/magic/aoe/fireball
	base_icon_state = "fireball"
	action_icon_state = "fireball0"
	sound = 'sound/magic/Fireball.ogg'
	active_msg = "You prepare to cast your fireball spell!"
	deactive_msg = "You extinguish your fireball... for now."
	active = FALSE
