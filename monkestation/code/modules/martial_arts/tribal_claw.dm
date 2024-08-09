//ported directly from Bee, cleaned up and updated to function with TG. thanks bee!

#define TAIL_SWEEP_COMBO "DH"
#define FACE_SCRATCH_COMBO "HH"
#define JUGULAR_CUT_COMBO "HD"
#define TAIL_GRAB_COMBO "DDG"

/datum/martial_art/tribal_claw
	name = "Tribal Claw"
	id = MARTIALART_TRIBALCLAW
	allow_temp_override = FALSE
	help_verb = /mob/living/carbon/human/proc/tribal_claw_help

/datum/martial_art/tribal_claw/proc/check_streak(mob/living/carbon/human/attacker, mob/living/carbon/human/target)
	if(findtext(streak,TAIL_SWEEP_COMBO))
		streak = ""
		tailSweep(attacker,target)
		return TRUE
	if(findtext(streak,FACE_SCRATCH_COMBO))
		streak = ""
		faceScratch(attacker,target)
		return TRUE
	if(findtext(streak,JUGULAR_CUT_COMBO))
		streak = ""
		jugularCut(attacker,target)
		return TRUE
	if(findtext(streak,TAIL_GRAB_COMBO))
		streak = ""
		tailGrab(attacker,target)
		return TRUE
	return FALSE

//Tail Sweep, triggers an effect similar to Alien Queen's tail sweep but only affects stuff 1 tile next to you, basically 3x3.
/datum/martial_art/tribal_claw/proc/tailSweep(mob/living/carbon/human/attacker, mob/living/carbon/human/target)
	if(attacker == current_target)
		return
	log_combat(attacker, target, "tail sweeped(Tribal Claw)", name)
	target.visible_message(span_warning("[attacker] sweeps [target]'s legs with their tail!"), \
						span_userdanger("[attacker] sweeps your legs with their tail!"))
	var/static/datum/action/cooldown/spell/aoe/repulse/martial/lizard/tail_sweep = new
	tail_sweep.cast(attacker)

//Face Scratch, deals 10 brute to head(reduced by armor), blurs the target's vision and gives them the confused effect for a short time.
/datum/martial_art/tribal_claw/proc/faceScratch(mob/living/carbon/human/attacker, mob/living/carbon/human/target)
	var/def_check = target.getarmor(BODY_ZONE_HEAD, MELEE)
	log_combat(attacker, target, "face scratched (Tribal Claw)", name)
	target.visible_message(span_warning("[attacker] scratches [target]'s face with their claws!"), \
						span_userdanger("[attacker] scratches your face with their claws!"))
	target.apply_damage(10, BRUTE, BODY_ZONE_HEAD, def_check)
	target.adjust_confusion(5 SECONDS)
	target.adjust_eye_blur(5 SECONDS)
	attacker.do_attack_animation(target, ATTACK_EFFECT_CLAW)
	playsound(get_turf(target), 'sound/weapons/slash.ogg', 50, 1, -1)

/*
Jugular Cut, can only be done if the target is in crit, being held in a tier 3 grab by the user or if they are sleeping.
Deals 15 brute to head(reduced by armor) and causes a rapid bleeding effect similar to throat slicing someone with a sharp item.
*/
//LIES!! TG completely FUCKED throat slitting and it's EXTREMELY DIFFICULT to replicate. This absolutely sucked to code.


/datum/martial_art/tribal_claw/proc/jugularCut(mob/living/carbon/attacker, mob/living/carbon/target)
	var/def_check = target.getarmor(BODY_ZONE_HEAD, MELEE)
	var/wound_type = /datum/wound/slash/flesh/critical
	var/obj/item/bodypart/head = target.get_bodypart(BODY_ZONE_HEAD)
	var/datum/wound/slash/flesh/jugcut = new wound_type()

	if((target.health <= target.crit_threshold || (attacker.pulling == target && attacker.grab_state >= GRAB_NECK) || target.IsSleeping()))
		log_combat(attacker, target, "jugular cut (Tribal Claw)", name)
		target.visible_message(span_warning("[attacker] cuts [target]'s jugular vein with their claws!"), \
							span_userdanger("[attacker] cuts your jugular vein!"))
		target.apply_damage(15, BRUTE, BODY_ZONE_HEAD, def_check)
		jugcut.apply_wound(head)
		attacker.do_attack_animation(target, ATTACK_EFFECT_CLAW)
		playsound(get_turf(target), 'sound/weapons/slash.ogg', 50, 1, -1)
	else
		//the original code says that this should be a basic attack instead, but not quite sure I could get that to work without fanangling
		return MARTIAL_ATTACK_FAIL


//Tail Grab, instantly puts your target in a T3 grab and makes them unable to talk for a short time.
/datum/martial_art/tribal_claw/proc/tailGrab(mob/living/carbon/human/attacker, mob/living/carbon/human/target)
	log_combat(attacker, target, "tail grabbed (Tribal Claw)", name)
	target.visible_message(span_warning("[attacker] grabs [target] with their tail!"), \
						span_userdanger("[attacker] grabs you with their tail!6</span>"))
	target.grabbedby(attacker, 1)
	target.Knockdown(5) //Without knockdown target still stands up while T3 grabbed.
	attacker.setGrabState(GRAB_NECK)
	target.adjust_silence_up_to(10 SECONDS, 10 SECONDS)

/datum/martial_art/tribal_claw/harm_act(mob/living/carbon/human/attacker, mob/living/carbon/human/target)
	add_to_streak("H",target)
	if(check_streak(attacker,target))
		return TRUE
	return FALSE

/datum/martial_art/tribal_claw/disarm_act(mob/living/carbon/human/attacker, mob/living/carbon/human/target)
	add_to_streak("D",target)
	if(check_streak(attacker,target))
		return TRUE
	return FALSE

/datum/martial_art/tribal_claw/grab_act(mob/living/carbon/human/attacker, mob/living/carbon/human/target)
	add_to_streak("G",target)
	if(check_streak(attacker,target))
		return TRUE
	return FALSE

/mob/living/carbon/human/proc/tribal_claw_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of the Tribal Claw"
	set category = "Tribal Claw"

	to_chat(usr, "<b><i>You retreat inward and recall the teachings of the Tribal Claw...</i></b>")

	to_chat(usr, span_notice("Tail Sweep</span>: Disarm Harm. Pushes everyone around you away and knocks them down."))
	to_chat(usr, span_notice("Face Scratch</span>: Harm Harm. Damages your target's head and confuses them for a short time."))
	to_chat(usr, span_notice("Jugular Cut</span>: Harm Disarm. Causes your target to rapidly lose blood, works only if you grab your target by their neck, if they are sleeping, or in critical condition."))
	to_chat(usr, span_notice("Tail Grab</span>: Disarm Disarm Grab. Grabs your target by their neck and makes them unable to talk for a short time."))
