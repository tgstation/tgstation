
#define LASER_VISIBLE 1
#define LASER_BURN_MOB 2
#define LASER_KNOCKBACK_MOB 4
#define LASER_BURN_OBJECT 8
#define LASER_KNOCKBACK_OBJECT 16
#define LASER_BURN_WALL 32
#define LASER_STUN_MOB 64
#define LASER_EXPLODE_NONMOBS 128	//Oh god.

/obj/effect/proc_holder/spell/laser
	name = "Laser Blast"
	desc = "A powerful laser beam fired out of a user with their magical energies. Requires a short time to charge up."
	charge_max = 300
	cooldown_min = 50

	//Messages
	invocation = "FIRIN MAH LASER!!"
	invocation_type = "shout"
	var/charge_message = "<span class='warning'>You hear a thrumming sound...</span>"
	var/fire_message = "<span class='danger'>You hear a loud roar and the crackle of energy!</span>"

	//Firing state
	var/mob/living/caster = null
	var/firing = FALSE
	var/turf/last_loc = null
	var/atom/target = null

	//Charging state
	var/charging = FALSE
	var/charged = FALSE
	var/current_charge = 0
	var/charge_time = 30
	var/current_firing = 0
	var/fire_time = 60

	//Sounds
/*	var/begin_charge_sound = ''
	var/charging_sound = ''
	var/fire_sound = ''
	var/firing_loop = ''
	var/end_sound = ''
*/
	//Misc icons
	var/base_button_icon_state = ""

	//Damage
	var/list/atom/affected = list()
	var/damage_mobs = 3
	var/damagetype = "burn"
	var/damage_environment = 5
	var/laser_flags = LASER_VISIBLE|LASER_BURN_MOB|LASER_KNOCKBACK_MOB|LASER_BURN_WALL|LASER_BURN_OBJECT

	//Beam
	var/beam_size = 1
	var/beam_icon_leading
	var/beam_icon_tracer
	var/beam_icon_trailing
	var/obj/item/projectile/magic/effect_beam/leading_edge = null
	var/obj/item/projectile/magic/effect_beam/trailing_edge = null
	var/list/obj/item/projectile/magic/effect_beam/beam_segments = list()

/obj/effect/proc_holder/spell/laser/New()
	START_PROCESSING(SSflightpacks, src)
	..()

/obj/effect/proc_holder/spell/laser/Destroy()
	STOP_PROCESSING(SSflightpacks, src)
	..()

/obj/effect/proc_holder/spell/laser/Initialize()
	..()
	beam_icon_tracer = image(icon = 'icons/effects/96x96.dmi', icon_state = "magic_laser_tracer")
	beam_icon_leading = image(icon = 'icons/effects/96x96.dmi', icon_state = "magic_laser_tracer")
	beam_icon_trailing = image(icon = 'icons/effects/96x96.dmi', icon_state = "magic_laser_tracer")
	ranged_mousepointer = image(icon = 'icons/effects/effects.dmi', icon_state = "laser_mouse_target")
	update_icon()

/obj/effect/proc_holder/spell/laser/process()
	handle_charge()
	if(firing)
		handle_firing()
	handle_damage()

/obj/effect/proc_holder/spell/laser/proc/handle_firing()
	if(((caster && get_turf(caster)) != last_loc) && firing)
		stop_firing()
		return
	current_firing--
	if(current_firing <= 0)
		stop_firing()
	if(!leading_edge)
		leading_edge = fire_beam_segment(last_loc, target, beam_icon_leading)
		leading_edge.target_scan(src, beam_size)
		return
	if(trailing_edge)
		trailing_edge.icon_state = beam_icon_tracer
	trailing_edge = fire_beam_segment(last_loc, target, beam_icon_trailing)
	for(var/obj/item/projectile/magic/effect_beam/B in beam_segments)
		if(!B)
			beam_segments -= B
			continue
		B.target_scan(src, beam_size)

/obj/effect/proc_holder/spell/laser/proc/fire_beam_segment(turf/start, atom/target, icon_state_new)
	var/obj/item/projectile/magic/effect_beam/P = new /obj/item/projectile/magic/effect_beam(start)
	P.current = get_turf(caster)
	P.preparePixelProjectile(target, get_turf(target), start)
	P.fire()
	P.icon = icon_state_new
	P.host = src
	beam_segments += P
	return P

/obj/effect/proc_holder/spell/laser/Click()
	var/mob/living/user = usr
	caster = user
	if(!istype(user))
		return
	var/msg
	if(!can_cast(user))
		msg = "<span class='warning'>You can no longer cast [name]!</span>"
		remove_ranged_ability(msg)
		return
	if(active)
		msg = "<span class='notice'>You discharge [src]...</span>"
		remove_ranged_ability(msg)
	else
		msg = "<span class='notice'>You start charging [src]!</B></span>"
		current_firing = fire_time
		add_ranged_ability(user, msg, TRUE)

/obj/effect/proc_holder/spell/laser/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return FALSE
	if(charging && !charged)
		to_chat(caller, "<span class='warning'>[src] is still charging up!</span>")
		return FALSE
	if(!cast_check(FALSE, ranged_ability_user))
		remove_ranged_ability()
		return FALSE
	var/passlist = list()
	passlist += target
	perform(passlist, user = ranged_ability_user)
	return TRUE

/obj/effect/proc_holder/spell/laser/cast(list/targets, mob/living/user)
	var/target = targets[1]
	var/turf/T = user.loc
	var/turf/U = get_step(user, user.dir) // Get the tile infront of the move, based on their direction
	if(!isturf(U) || !isturf(T))
		return FALSE
	start_firing(user, target)
	user.newtonian_move(get_dir(U, T))
	remove_ranged_ability() //Auto-disable the ability once you run out of bullets.
	return TRUE

/obj/effect/proc_holder/spell/laser/proc/start_firing(mob/living/user, atom/target)
	for(var/mob/M in range(14, user))
		to_chat(M, fire_message)
	beam_segments = list()
	last_loc = get_turf(user)
	caster = user
	firing = TRUE

/obj/effect/proc_holder/spell/laser/proc/stop_firing()
	if(current_firing > 0)
		charge_counter = (charge_max * (current_firing / fire_time))
	firing = FALSE

/obj/effect/proc_holder/spell/laser/proc/handle_charge()
	if(charging)
		current_charge++
		if(current_charge > charge_time)
			charging = FALSE
			charged = TRUE
			to_chat(caster, "<span class='danger'>[src] has been fully charged! Left click anything to fire! Do not move during firing or your beam will stop!</span>")

/obj/effect/proc_holder/spell/laser/proc/handle_damage()
	var/list/atom/current = affected.Copy()
	affected = list()
	for(var/atom/A in current)
		if(A == ranged_ability_user)
			continue
		if(isliving(A))
			var/mob/living/L = A
			if(laser_flags & LASER_BURN_MOB)
				switch(damagetype)
					if("burn")
						L.adjustFireLoss(damage_mobs)
					if("brute")
						L.adjustBruteLoss(damage_mobs)
					if("tox")
						L.adjustToxLoss(damage_mobs)
					if("oxy")
						L.adjustOxyLoss(damage_mobs)
					if("clone")
						L.adjustCloneLoss(damage_mobs)
					if("brain")
						L.adjustBrainLoss(damage_mobs)
			if((laser_flags & LASER_KNOCKBACK_MOB) && !L.throwing)
				var/dir = pick(alldirs)
				var/target = get_turf(A)
				var/range = Clamp(damage_mobs, 0, 15)
				for(var/i = 0, i < range, i++)
					target = get_step(target, dir)
				L.throw_at(target, range, 3)
			if(laser_flags & LASER_STUN_MOB)
				L.Weaken(3)
		else if(laser_flags & LASER_EXPLODE_NONMOBS)
			A.ex_act(3)
		else if(istype(A, /turf/closed))
			if(laser_flags & LASER_BURN_WALL)
				if(prob(damage_environment*5))
					A.ex_act(2)
		else if(istype(A, /obj))
			var/obj/O = A
			if(laser_flags & LASER_BURN_OBJECT)
				O.take_damage(damage_environment, damage_type = BURN)
			if((laser_flags & LASER_KNOCKBACK_OBJECT) && !O.throwing)
				var/dir = pick(alldirs)
				var/target = get_turf(O)
				var/range = Clamp(damage_environment, 0, 15)
				for(var/i = 0, i < range, i++)
					target = get_step(target, dir)
				O.throw_at(target, range, 3)

/obj/effect/proc_holder/spell/laser/update_icon()
	if(!action)
		return
	action.button_icon_state = "[base_button_icon_state][active]"
	action.UpdateButtonIcon()

/obj/item/projectile/magic/effect_beam
	name = "laser beam"
	desc = "Why are you staring at this? RUN!"
	icon = null
	icon_state = null
	speed = 0.5
	forcedodge = TRUE
	var/obj/effect/proc_holder/spell/laser/host = null

/obj/item/projectile/magic/effect_beam/proc/target_scan(scan_range)
	for(var/atom/A in range(src, scan_range))
		host.affected[A] = A

/obj/item/projectile/magic/effect_beam/Destroy()
	host.beam_segments -= src
	..()

/obj/item/projectile/magic/effect_beam/on_hit(atom/target, blocked = 0)
	if(isliving(target))
		var/mob/living/L = target
		to_chat(L, "You are seared by the [src]!")
	if(istype(target, /turf/closed))
		host.affected[target] = target
		qdel(src)
