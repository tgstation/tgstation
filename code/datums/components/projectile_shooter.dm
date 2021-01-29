/*This is the projectile_shooter component, a ripoff of the [/datum/component/sound_player] component used for firing off projectiles when certain signals are triggered.
	This isn't a replacement for how guns work, this is a simply a modular way to fire bullets from things that don't otherwise fire bullets
	Usage :
		target.AddComponent(/datum/component/projectile_shooter, args)
	Arguments :
		projectile_type : What projectile do we shoot?
		shot_prob : If we only want to go off some of the time when a signal fires, this is the percent chance for it to fire
		signal_or_sig_list : Used to register the signal(s) you want to fire a shot when sent
*/
/datum/component/projectile_shooter
	/// What projectile do we shoot?
	var/projectile_type
	/// If we only want to go off some of the time when a signal fires, this is the percent chance for it to fire
	var/shot_prob

/datum/component/projectile_shooter/Initialize(projectile_type = /obj/projectile/bullet/c10mm, shot_prob = 100, signal_or_sig_list)
	src.projectile_type = projectile_type
	src.shot_prob = shot_prob

	// unarmed attack is a special case for gunboots so they can shoot someone you stomp on. This happens 100% of the time you kick, ignoring shot_prob
	if(islist(signal_or_sig_list) && (COMSIG_HUMAN_MELEE_UNARMED_ATTACK in signal_or_sig_list))
		signal_or_sig_list -= COMSIG_HUMAN_MELEE_UNARMED_ATTACK
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/check_equip)
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/check_dropped)

	RegisterSignal(parent, signal_or_sig_list, .proc/shoot_randomly) //Registers all the signals in signal_or_sig_list.

/// Whatever signals you hook up (minus the unarmed attack case) goes through here, and fires a projectile at a random tile around the parent's turf
/datum/component/projectile_shooter/proc/shoot_randomly()
	SIGNAL_HANDLER
	if(!prob(shot_prob))
		return

	var/atom/parent_atom = parent
	var/turf/random_target = get_offset_target_turf(get_turf(parent_atom), rand(-3, 3), rand(-3,3))
	INVOKE_ASYNC(src, .proc/pew, random_target)

/// This is where the magic happens, and a projectile is made and fired at wherever
/datum/component/projectile_shooter/proc/pew(atom/target)
	var/atom/parent_atom = parent
	var/atom/possible_owner = parent_atom.loc
	var/obj/projectile/shot = new projectile_type(get_turf(parent_atom))

	//Shooting Code:
	shot.spread = 0
	shot.original = target
	shot.fired_from = parent_atom
	shot.firer = parent_atom // don't hit ourself that would be really annoying
	shot.impacted = list(possible_owner = TRUE) // just to make sure we don't hit the wearer
	shot.def_zone = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	shot.preparePixelProjectile(target, possible_owner)
	if(!shot.suppressed)
		if(isliving(possible_owner))
			possible_owner.visible_message("<span class='danger'>[possible_owner]'s [parent_atom.name] fires \a [shot]!</span>", "", blind_message = "<span class='hear'>You hear a gunshot!</span>", vision_distance=COMBAT_MESSAGE_RANGE)
		else
			possible_owner.visible_message("<span class='danger'>[parent_atom] fires \a [shot]!</span>", blind_message = "<span class='hear'>You hear a gunshot!</span>", vision_distance=COMBAT_MESSAGE_RANGE)
	shot.fire()

/// For the special case of gunboots being able to shoot someone when you kick them
/datum/component/projectile_shooter/proc/check_kick(mob/living/carbon/human/kicking_person, atom/attacked_atom, proximity)
	SIGNAL_HANDLER
	if(!isliving(attacked_atom))
		return
	var/mob/living/attacked_living = attacked_atom
	if(attacked_living.body_position == LYING_DOWN)
		INVOKE_ASYNC(src, .proc/pew, attacked_living)

/// As above, special case for gun shoes so they can kick and shoot
/datum/component/projectile_shooter/proc/check_equip(datum/source, mob/living/user, slot)
	SIGNAL_HANDLER
	RegisterSignal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, .proc/check_kick)

/// As above, special case for gun shoes so they can kick and shoot
/datum/component/projectile_shooter/proc/check_dropped(datum/source, mob/living/user)
	SIGNAL_HANDLER
	UnregisterSignal(user, COMSIG_HUMAN_MELEE_UNARMED_ATTACK)
