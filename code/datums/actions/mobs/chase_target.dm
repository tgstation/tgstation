/datum/action/cooldown/mob_cooldown/chase_target
	name = "Chase Target"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Gain a burst of speed to chase down a target."
	cooldown_time = 6 SECONDS
	/// Affects volume of the charge tell depending on the size of the mob charging
	var/size = 1

/datum/action/cooldown/mob_cooldown/chase_target/Activate(atom/target_atom)
	disable_cooldown_actions()
	charge(target_atom)
	StartCooldown()
	enable_cooldown_actions()
	return TRUE

/// Causes the mob to gain speed and charge at a target
/datum/action/cooldown/mob_cooldown/chase_target/proc/charge(atom/target)
	var/mob/living/living_mob = target
	if(istype(living_mob) && living_mob.stat == DEAD)
		return
	owner.visible_message(span_boldwarning("[owner] charges!"))
	owner.SpinAnimation(speed = 20, loops = 3, parallel = FALSE)
	if(ishostile(owner))
		var/mob/living/simple_animal/hostile/hostile_mob = owner
		hostile_mob.retreat_distance = 0
		hostile_mob.minimum_distance = 0
		hostile_mob.set_varspeed(0)
		addtimer(CALLBACK(src, PROC_REF(reset_charge)), 6 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(throw_thyself)), 2 SECONDS)

/// This is the proc that actually does the throwing. Charge only adds a timer for this.
/datum/action/cooldown/mob_cooldown/chase_target/proc/throw_thyself()
	playsound(owner, 'sound/items/weapons/sonic_jackhammer.ogg', 50, TRUE)
	owner.throw_at(target, 7, 1.1, owner, FALSE, FALSE, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), owner, 'sound/effects/meteorimpact.ogg', 50 * size, TRUE, 2), INFINITY)

/// Resets the charge buffs.
/datum/action/cooldown/mob_cooldown/chase_target/proc/reset_charge()
	var/mob/living/simple_animal/hostile/hostile_mob = owner
	hostile_mob.retreat_distance = 5
	hostile_mob.minimum_distance = 5
	hostile_mob.set_varspeed(2)
