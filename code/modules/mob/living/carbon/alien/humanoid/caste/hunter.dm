/**
 * # Alien Hunter
 *
 * A fast-moving caste of alien capable of pouncing on prey, stunning them for a decent amount of time.  They are, however, the squishiest caste as well.
 *
 * The speedy ambusher and main component of the alien offensive.  Alien hunters are the fastest caste, moving at a speed faster than humans and most other
 * animals.  Hunters also have the unique ability to pounce on possible prey, which induces a hardstun should it successfully land on a target.  However, the
 * stun will be applied to the hunter should it hit a wall or be unlucky when pouncing a target with a shield.
 */
/mob/living/carbon/alien/humanoid/hunter
	name = "alien hunter"
	caste = "h"
	maxHealth = 125
	health = 125
	icon_state = "alienh"
	speed = -0.3
	///The mouse icon for when the hunter is ready to leap.
	var/atom/movable/screen/leap_icon = null

/mob/living/carbon/alien/humanoid/hunter/create_internal_organs()
	internal_organs += new /obj/item/organ/alien/plasmavessel/small
	..()

/mob/living/carbon/alien/humanoid/hunter/ClickOn(atom/A, params)
	face_atom(A)
	if(leap_on_click)
		leap_at(A)
		return
	return ..()

/mob/living/carbon/alien/humanoid/hunter/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!leaping)
		return ..()

	pounce_cooldown = world.time + pounce_cooldown_time
	if(!hit_atom)
		return
	if(!isliving(hit_atom))
		if(hit_atom.density && !hit_atom.CanPass(src))
			visible_message("<span class='danger'>[src] smashes into [hit_atom]!</span>", "<span class='alertalien'>[src] smashes into [hit_atom]!</span>")
			Paralyze(40, ignore_canstun = TRUE)
		return
	var/mob/living/living_target = hit_atom
	var/blocked = FALSE
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/H = hit_atom
		if(H.check_shields(src, FALSE, "the [name]", attack_type = LEAP_ATTACK))
			blocked = TRUE
	if(!blocked)
		living_target.visible_message("<span class='danger'>[src] pounces on [living_target]!</span>", "<span class='userdanger'>[src] pounces on you!</span>")
		living_target.Paralyze(100)
		var/turf/hit_target_turf = get_turf(living_target)
		if(living_target.CanPass(src, hit_target_turf))
			Move(hit_target_turf, get_dir(src, hit_target_turf))
		return
	Paralyze(40, ignore_canstun = TRUE)
	toggle_leap(FALSE)

/**
 * Used to toggle the hunter's leap ability.
 *
 * A proc which toggles whether or not the hunter is able to leap using left-click.  Doing this
 * changes the icon state of the hunter, along with toggling the ability on or off.  A message
 * will be displayed to the alien player when doing this if the message var is set to TRUE.
 * Arguments:
 * * message - Whether or not to display a message to the alien player when toggling the leap.
 */
/mob/living/carbon/alien/humanoid/hunter/proc/toggle_leap(message = TRUE)
	leap_on_click = !leap_on_click
	leap_icon.icon_state = "leap_[leap_on_click ? "on":"off"]"
	update_icons()
	if(message)
		to_chat(src, "<span class='noticealien'>You will now [leap_on_click ? "leap at":"slash at"] enemies!</span>")
	else
		return

#define MAX_ALIEN_LEAP_DIST 7

/**
 * Handles the hunter's leap.
 *
 * A proc which handles the action of the hunter leaping.  Does a few checks to see if the leap
 * is currently possible, and then if so sets the hunter up to leap at the desired atom A.
 * Arguments:
 * * leap_target - the atom at which the hunter will try to leap towards.
 */
/mob/living/carbon/alien/humanoid/hunter/proc/leap_at(atom/leap_target)
	if(body_position == LYING_DOWN || HAS_TRAIT(src, TRAIT_IMMOBILIZED) || leaping)
		return

	if(pounce_cooldown > world.time)
		to_chat(src, "<span class='alertalien'>You are too fatigued to pounce right now!</span>")
		return

	if(!has_gravity() || !leap_target.has_gravity())
		to_chat(src, "<span class='alertalien'>It is unsafe to leap without gravity!</span>")
		//It's also extremely buggy visually, so it's balance+bugfix
		return

	else //Maybe uses plasma in the future, although that wouldn't make any sense...
		leaping = TRUE
		//Because the leaping sprite is bigger than the normal one
		body_position_pixel_x_offset = -32
		body_position_pixel_y_offset = -32
		LAZYADD(weather_immunities,"lava")
		update_icons()
		throw_at(leap_target, MAX_ALIEN_LEAP_DIST, 2, src, FALSE, TRUE, callback = CALLBACK(src, .proc/leap_end))
		
#undef MAX_ALIEN_LEAP_DIST

/**
 * Handles the end of the hunter's leap.
 *
 * Reverts the status of the hunter to normal after the end of a leap.
 * Changes the internal tracker, removes the lava immunity, and then resets
 * the icons of the hunter.
 */
/mob/living/carbon/alien/humanoid/hunter/proc/leap_end()
	leaping = FALSE
	body_position_pixel_x_offset = 0
	body_position_pixel_y_offset = 0
	LAZYREMOVE(weather_immunities, "lava")
	update_icons()
