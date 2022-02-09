#define TAIL_SWEEP_COMBO "DDGH"
#define FACE_SCRATCH_COMBO "HD"
#define JUGULAR_CUT_COMBO "HHG"
#define TAIL_GRAB_COMBO "DHGG"

/datum/martial_art/tribal_claw
	name = "Tribal Claw"
	id = MARTIALART_TRIBALCLAW
	allow_temp_override = FALSE
	help_verb = /mob/living/carbon/proc/tribal_claw_help
	display_combos = TRUE

/datum/martial_art/tribal_claw/proc/check_streak(mob/living/carbon/attacker, mob/living/carbon/defender)
	if(findtext(streak, TAIL_SWEEP_COMBO))
		streak = ""
		tailSweep(attacker, defender)
		return TRUE
	if(findtext(streak, FACE_SCRATCH_COMBO))
		streak = ""
		faceScratch(attacker, defender)
		return TRUE
	if(findtext(streak, JUGULAR_CUT_COMBO))
		streak = ""
		jugularCut(attacker, defender)
		return TRUE
	if(findtext(streak, TAIL_GRAB_COMBO))
		streak = ""
		tailGrab(attacker, defender)
		return TRUE
	return FALSE

//Tail Sweep, triggers an effect similar to a xeno's tail sweep but only affects stuff 1 tile next to you, basically 3x3.
/datum/martial_art/tribal_claw/proc/tailSweep(mob/living/carbon/attacker, mob/living/carbon/defender)
	if(attacker == current_target)
		return
	log_combat(attacker, defender, "tail sweeped(Tribal Claw)")
	defender.visible_message("<span class='warning'>[attacker] sweeps [defender]'s legs with their tail!</span>", \
						"<span class='userdanger'>[attacker] sweeps your legs with their tail!</span>")
	var/obj/effect/proc_holder/spell/aoe_turf/repulse/lizard_tail/tail_hit = new
	tail_hit.cast(RANGE_TURFS(1,attacker))

//Face Scratch, deals 10 brute to head(reduced by armor), blurs the target's vision and gives them the confused effect for a short time.
/datum/martial_art/tribal_claw/proc/faceScratch(mob/living/carbon/attacker, mob/living/carbon/defender)
	var/def_check = defender.getarmor(BODY_ZONE_HEAD, "melee")
	log_combat(attacker, defender, "face scratched (Tribal Claw)")
	defender.visible_message("<span class='warning'>[attacker] scratches [defender]'s face with their claws!</span>", \
						"<span class='userdanger'>[attacker] scratches your face with their claws!</span>")
	defender.apply_damage(10, BRUTE, BODY_ZONE_HEAD, def_check)
	defender.add_confusion(5)
	defender.blur_eyes(5)
	attacker.do_attack_animation(defender, ATTACK_EFFECT_CLAW)
	playsound(get_turf(defender), 'sound/weapons/slash.ogg', 50, 1, -1)

/*
Jugular Cut, can only be done if the target is in crit, being held in a tier 3 grab by the user or if they are sleeping.
Deals 15 brute to head(reduced by armor) and causes a rapid bleeding effect similar to throat slicing someone with a sharp item.
*/
/datum/martial_art/tribal_claw/proc/jugularCut(mob/living/carbon/attacker, mob/living/carbon/defender)
	var/def_check = defender.getarmor(BODY_ZONE_HEAD, "melee")
	if((defender.health <= defender.crit_threshold || (attacker.pulling == defender && attacker.grab_state >= GRAB_NECK) || defender.IsSleeping()))
		log_combat(attacker, defender, "jugular cut (Tribal Claw)")
		defender.visible_message("<span class='warning'>[attacker] cuts [defender]'s jugular vein with their claws!</span>", \
							"<span class='userdanger'>[attacker] cuts your jugular vein!</span>")
		defender.apply_damage(15, BRUTE, BODY_ZONE_HEAD, def_check)
		var/obj/item/bodypart/slit_throat = defender.get_bodypart(BODY_ZONE_HEAD)
		if(slit_throat)
			var/datum/wound/slash/severe/throatcut = new
			throatcut.apply_wound(slit_throat)
		defender.apply_status_effect(/datum/status_effect/neck_slice)
		attacker.do_attack_animation(defender, ATTACK_EFFECT_CLAW)
		playsound(get_turf(defender), 'sound/weapons/slash.ogg', 50, 1, -1)

//Tail Grab, instantly puts your target in a T3 grab and makes them unable to talk for a short time.
/datum/martial_art/tribal_claw/proc/tailGrab(mob/living/carbon/attacker, mob/living/carbon/defender)
	log_combat(attacker, defender, "tail grabbed (Tribal Claw)")
	defender.visible_message("<span class='warning'>[attacker] grabs [defender] with their tail!</span>", \
						"<span class='userdanger'>[attacker] grabs you with their tail!</span>")
	defender.grabbedby(attacker, 1)
	defender.Knockdown(5) //Without knockdown target still stands up while T3 grabbed.
	attacker.setGrabState(GRAB_NECK)
	if(defender.silent <= 10)
		defender.silent = clamp(defender.silent + 10, 0, 10)

/datum/martial_art/tribal_claw/harm_act(mob/living/carbon/attacker, mob/living/carbon/defender)
	add_to_streak("H", defender)
	if(check_streak(attacker, defender))
		return TRUE
	return FALSE

/datum/martial_art/tribal_claw/disarm_act(mob/living/carbon/attacker, mob/living/carbon/defender)
	add_to_streak("D", defender)
	if(check_streak(attacker, defender))
		return TRUE
	return FALSE

/datum/martial_art/tribal_claw/grab_act(mob/living/carbon/attacker, mob/living/carbon/defender)
	add_to_streak("G", defender)
	if(check_streak(attacker, defender))
		return TRUE
	return FALSE

/mob/living/carbon/proc/tribal_claw_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of the Tribal Claw"
	set category = "Tribal Claw"

	to_chat(usr, "<b><i>You retreat inward and recall the teachings of the Tribal Claw...</i></b>")

	to_chat(usr, "<span class='notice'>Tail Sweep</span>: Disarm Disarm Grab Harm. Pushes everyone around you away and knocks them down.")
	to_chat(usr, "<span class='notice'>Face Scratch</span>: Harm Disarm. Damages your target's head and confuses them for a short time.")
	to_chat(usr, "<span class='notice'>Jugular Cut</span>: Harm Harm Grab. Causes your target to rapidly lose blood, works only if you grab your target by their neck, if they are sleeping, or in critical condition.")
	to_chat(usr, "<span class='notice'>Tail Grab</span>: Disarm Harm Grab Grab. Grabs your target by their neck and makes them unable to talk for a short time.")
