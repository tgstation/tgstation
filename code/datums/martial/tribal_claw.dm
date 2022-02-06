#define TAIL_SWEEP_COMBO "DDGH"
#define FACE_SCRATCH_COMBO "HD"
#define JUGULAR_CUT_COMBO "HHG"
#define TAIL_GRAB_COMBO "DHGG"

/datum/martial_art/tribal_claw
	name = "Tribal Claw"
	id = MARTIALART_TRIBALCLAW
	allow_temp_override = FALSE
	help_verb = /mob/living/carbon/human/proc/tribal_claw_help
	display_combos = TRUE

/datum/martial_art/tribal_claw/proc/check_streak(mob/living/A, mob/living/D)
	if(findtext(streak,TAIL_SWEEP_COMBO))
		streak = ""
		tailSweep(A,D)
		return TRUE
	if(findtext(streak,FACE_SCRATCH_COMBO))
		streak = ""
		faceScratch(A,D)
		return TRUE
	if(findtext(streak,JUGULAR_CUT_COMBO))
		streak = ""
		jugularCut(A,D)
		return TRUE
	if(findtext(streak,TAIL_GRAB_COMBO))
		streak = ""
		tailGrab(A,D)
		return TRUE
	return FALSE

//Tail Sweep, triggers an effect similar to Space Dragon's tail sweep but only affects stuff 1 tile next to you, basically 3x3.
/datum/martial_art/tribal_claw/proc/tailSweep(mob/living/A, mob/living/D)
	if(A == current_target)
		return
	log_combat(A, D, "tail sweeped(Tribal Claw)")
	D.visible_message("<span class='warning'>[A] sweeps [D]'s legs with their tail!</span>", \
						"<span class='userdanger'>[A] sweeps your legs with their tail!</span>")
	var/obj/effect/proc_holder/spell/aoe_turf/repulse/spacedragon/R = new
	R.cast(RANGE_TURFS(1,A))

//Face Scratch, deals 10 brute to head(reduced by armor), blurs the target's vision and gives them the confused effect for a short time.
/datum/martial_art/tribal_claw/proc/faceScratch(mob/living/A, mob/living/D)
	var/def_check = D.getarmor(BODY_ZONE_HEAD, "melee")
	log_combat(A, D, "face scratched (Tribal Claw)")
	D.visible_message("<span class='warning'>[A] scratches [D]'s face with their claws!</span>", \
						"<span class='userdanger'>[A] scratches your face with their claws!</span>")
	D.apply_damage(10, BRUTE, BODY_ZONE_HEAD, def_check)
	D.confused += 5
	D.blur_eyes(5)
	A.do_attack_animation(D, ATTACK_EFFECT_CLAW)
	playsound(get_turf(D), 'sound/weapons/slash.ogg', 50, 1, -1)

/*
Jugular Cut, can only be done if the target is in crit, being held in a tier 3 grab by the user or if they are sleeping.
Deals 15 brute to head(reduced by armor) and causes a rapid bleeding effect similar to throat slicing someone with a sharp item.
*/
/datum/martial_art/tribal_claw/proc/jugularCut(mob/living/A, mob/living/D)
	var/def_check = D.getarmor(BODY_ZONE_HEAD, "melee")
	if((D.health <= D.crit_threshold || (A.pulling == D && A.grab_state >= GRAB_NECK) || D.IsSleeping()))
		log_combat(A, D, "jugular cut (Tribal Claw)")
		D.visible_message("<span class='warning'>[A] cuts [D]'s jugular vein with their claws!</span>", \
							"<span class='userdanger'>[A] cuts your jugular vein!</span>")
		D.apply_damage(15, BRUTE, BODY_ZONE_HEAD, def_check)
		D.bleed_rate = CLAMP(D.bleed_rate + 20, 0, 30)
		D.apply_status_effect(/datum/status_effect/neck_slice)
		A.do_attack_animation(D, ATTACK_EFFECT_CLAW)
		playsound(get_turf(D), 'sound/weapons/slash.ogg', 50, 1, -1)
	else
		return basic_hit(A,D)

//Tail Grab, instantly puts your target in a T3 grab and makes them unable to talk for a short time.
/datum/martial_art/tribal_claw/proc/tailGrab(mob/living/A, mob/living/D)
	log_combat(A, D, "tail grabbed (Tribal Claw)")
	D.visible_message("<span class='warning'>[A] grabs [D] with their tail!</span>", \
						"<span class='userdanger'>[A] grabs you with their tail!</span>")
	D.grabbedby(A, 1)
	D.Knockdown(5) //Without knockdown target still stands up while T3 grabbed.
	A.setGrabState(GRAB_NECK)
	if(D.silent <= 10)
		D.silent = CLAMP(D.silent + 10, 0, 10)

/datum/martial_art/tribal_claw/harm_act(mob/living/A, mob/living/D)
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE

/datum/martial_art/tribal_claw/disarm_act(mob/living/A, mob/living/D)
	add_to_streak("D",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE

/datum/martial_art/tribal_claw/grab_act(mob/living/A, mob/living/D)
	add_to_streak("G",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE

/mob/living/carbon/human/proc/tribal_claw_help()
	set name = "Recall Teachings"
	set desc = "Remember the martial techniques of the Tribal Claw"
	set category = "Tribal Claw"

	to_chat(usr, "<b><i>You retreat inward and recall the teachings of the Tribal Claw...</i></b>")

	to_chat(usr, "<span class='notice'>Tail Sweep</span>: Disarm Disarm Grab Harm. Pushes everyone around you away and knocks them down.")
	to_chat(usr, "<span class='notice'>Face Scratch</span>: Harm Disarm. Damages your target's head and confuses them for a short time.")
	to_chat(usr, "<span class='notice'>Jugular Cut</span>: Harm Harm Grab. Causes your target to rapidly lose blood, works only if you grab your target by their neck, if they are sleeping, or in critical condition.")
	to_chat(usr, "<span class='notice'>Tail Grab</span>: Disarm Harm Grab Grab. Grabs your target by their neck and makes them unable to talk for a short time.")
