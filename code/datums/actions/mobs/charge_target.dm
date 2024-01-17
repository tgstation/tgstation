/datum/action/cooldown/mob_cooldown/charge_target
	name = "Charge Target"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Gain a burst of speed to chase down a target."
	cooldown_time = 6 SECONDS
	var/size = 1

/datum/action/cooldown/mob_cooldown/charge_target/Activate(atom/target_atom)
	disable_cooldown_actions()
	charge(target_atom)
	StartCooldown()
	enable_cooldown_actions()
	return TRUE

/datum/action/cooldown/mob_cooldown/charge_target/proc/charge(atom/target)
	visible_message(span_warning("<b>[owner] charges!</b>"))
	owner.SpinAnimation(speed = 20, loops = 3, parallel = FALSE)
	if(ishostile(owner))
		var/mob/living/simple_animal/hostile/hostile_mob = owner
		hostile_mob.retreat_distance = 0
		hostile_mob.minimum_distance = 0
		hostile_mob.set_varspeed(0)
	addtimer(CALLBACK(src, PROC_REF(reset_charge)), 60)
	var/mob/living/living_mob = target
	if(!istype(living_mob) || living_mob.stat != DEAD) //I know, weird syntax, but it just works.
		addtimer(CALLBACK(src, PROC_REF(throw_thyself)), 20)

///This is the proc that actually does the throwing. Charge only adds a timer for this.
/datum/action/cooldown/mob_cooldown/charge_target/proc/throw_thyself()
	playsound(owner, 'sound/weapons/sonic_jackhammer.ogg', 50, TRUE)
	owner.throw_at(target, 7, 1.1, owner, FALSE, FALSE, CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), owner, 'sound/effects/meteorimpact.ogg', 50 * size, TRUE, 2), INFINITY)

///Resets the charge buffs.
/datum/action/cooldown/mob_cooldown/charge_target/proc/reset_charge()
	if(ishostile(owner))
		var/mob/living/simple_animal/hostile/hostile_mob = owner
		hostile_mob.retreat_distance = 5
		hostile_mob.minimum_distance = 5
		hostile_mob.set_varspeed(2)
