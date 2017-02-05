/obj/effect/proc_holder/spell/targeted/tesla
	name = "Tesla Blast"
	desc = "Blast lightning at your foes!"
	charge_type = "recharge"
	charge_max	= 300
	clothes_req = 1
	invocation = "UN'LTD P'WAH!"
	invocation_type = "shout"
	range = 7
	cooldown_min = 30
	selection_type = "view"
	random_target = 1
	var/ready = 0
	var/image/halo = null
	var/sound/Snd // so far only way i can think of to stop a sound, thank MSO for the idea.

	action_icon_state = "lightning"

/obj/effect/proc_holder/spell/targeted/tesla/Click()
	if(!ready && cast_check())
		StartChargeup()
	return 1

/obj/effect/proc_holder/spell/targeted/tesla/proc/StartChargeup(mob/user = usr)
	ready = 1
	user << "<span class='notice'>You start gathering the power.</span>"
	Snd = new/sound('sound/magic/lightning_chargeup.ogg',channel = 7)
	halo = image("icon"='icons/effects/effects.dmi',"icon_state" ="electricity","layer" = EFFECTS_LAYER)
	user.overlays.Add(halo)
	playsound(get_turf(user), Snd, 50, 0)
	if(do_mob(user,user,100,1))
		if(ready && cast_check(skipcharge=1))
			choose_targets()
		else
			revert_cast(user, 0)
	else
		revert_cast(user, 0)

/obj/effect/proc_holder/spell/targeted/tesla/proc/Reset(mob/user = usr)
	ready = 0
	if(halo)
		user.overlays.Remove(halo)

/obj/effect/proc_holder/spell/targeted/tesla/revert_cast(mob/user = usr, message = 1)
	if(message)
		user << "<span class='notice'>No target found in range.</span>"
	Reset(user)
	..()

/obj/effect/proc_holder/spell/targeted/tesla/cast(list/targets, mob/user = usr)
	ready = 0
	var/mob/living/carbon/target = targets[1]
	Snd=sound(null, repeat = 0, wait = 1, channel = Snd.channel) //byond, why you suck?
	playsound(get_turf(user),Snd,50,0)// Sorry MrPerson, but the other ways just didn't do it the way i needed to work, this is the only way.
	if(get_dist(user,target)>range)
		user << "<span class='notice'>They are too far away!</span>"
		Reset(user)
		return

	playsound(get_turf(user), 'sound/magic/lightningbolt.ogg', 50, 1)
	user.Beam(target,icon_state="lightning[rand(1,12)]",time=5)

	Bolt(user,target,30,5,user)
	Reset(user)

/obj/effect/proc_holder/spell/targeted/tesla/proc/Bolt(mob/origin,mob/target,bolt_energy,bounces,mob/user = usr)
	origin.Beam(target,icon_state="lightning[rand(1,12)]",time=5)
	var/mob/living/carbon/current = target
	if(bounces < 1)
		current.electrocute_act(bolt_energy,"Lightning Bolt",safety=1)
		playsound(get_turf(current), 'sound/magic/LightningShock.ogg', 50, 1, -1)
	else
		current.electrocute_act(bolt_energy,"Lightning Bolt",safety=1)
		playsound(get_turf(current), 'sound/magic/LightningShock.ogg', 50, 1, -1)
		var/list/possible_targets = new
		for(var/mob/living/M in view_or_range(range,target,"view"))
			if(user == M || target == M && los_check(current,M)) // || origin == M ? Not sure double shockings is good or not
				continue
			possible_targets += M
		if(!possible_targets.len)
			return
		var/mob/living/next = pick(possible_targets)
		if(next)
			Bolt(current,next,max((bolt_energy-5),5),bounces-1,user)

/obj/effect/proc_holder/spell/lightningbolt
	name = "Lightning Bolt"
	desc = "Fire a high powered lightning bolt at your foes!"
	school = "evocation"
	charge_max = 200
	clothes_req = 1
	invocation = "UN'LTD P'WAH"
	invocation_type = "shout"
	cooldown_min = 30
	var/projectile_type = /obj/item/projectile/magic/aoe/lightning
	action_icon_state = "lightning"
	sound = 'sound/magic/lightningbolt.ogg'
	active = FALSE

/obj/effect/proc_holder/spell/lightningbolt/Click()
	var/mob/living/user = usr
	if(!istype(user))
		return
	var/msg
	if(!can_cast(user))
		msg = "<span class='warning'>You can no longer cast Lightning Bolt!</span>"
		remove_ranged_ability(msg)
		return
	if(active)
		msg = "<span class='notice'>You reabsorb the energy in your hands...</span>"
		remove_ranged_ability(msg)
	else
		msg = "<span class='notice'>You charge your hands with arcane lightning! <B>Left-click to shoot it at a target!</B></span>"
		add_ranged_ability(user, msg, TRUE)

/obj/effect/proc_holder/spell/lightningbolt/update_icon()
	if(!action)
		return
	action.button_icon_state = "lightning[active]"
	action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/lightningbolt/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return FALSE
	if(!cast_check(0, ranged_ability_user))
		remove_ranged_ability()
		return FALSE
	var/list/targets = list(target)
	perform(targets,user = ranged_ability_user)
	return TRUE

/obj/effect/proc_holder/spell/lightningbolt/cast(list/targets, mob/living/user)
	var/target = targets[1]
	var/turf/T = user.loc
	var/turf/U = get_step(user, user.dir) // Get the tile infront of the move, based on their direction
	if(!isturf(U) || !isturf(T))
		return FALSE
	var/obj/item/projectile/P = new projectile_type(user.loc)
	P.current = get_turf(user)
	P.preparePixelProjectile(target, get_turf(target), user)
	P.fire()
	user.newtonian_move(get_dir(U, T))
	remove_ranged_ability() //Auto-disable the ability once successfully performed
	return TRUE
