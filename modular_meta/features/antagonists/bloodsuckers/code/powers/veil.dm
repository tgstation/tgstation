/datum/action/cooldown/bloodsucker/veil
	name = "Veil of Many Faces"
	desc = "Disguise yourself under a random identity."
	button_icon_state = "power_veil"
	power_explanation = "Veil of Many Faces: \n\
		Activating Veil of Many Faces will shroud you in smoke and change your identity.\n\
		Your name, voice, and appearance will be completely randomized. \n\
		Turning the ability off again will undo its effects.\n\
		Clothing, gear, and security/medical HUD status is kept the same while this power is active."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_FRENZY
	purchase_flags = BLOODSUCKER_DEFAULT_POWER
	bloodcost = 15
	constant_bloodcost = 0.1
	cooldown_time = 10 SECONDS
	// Outfit Vars
//	var/list/original_items = list()
	// Identity Vars
	var/prev_gender
	var/prev_skin_tone
	var/prev_hair_style
	var/prev_facial_hair_style
	var/prev_hair_color
	var/prev_facial_hair_color
	var/prev_underwear
	var/prev_undershirt
	var/prev_socks
	var/prev_disfigured
	var/list/prev_features // For lizards and such
	var/disguise_name

/datum/action/cooldown/bloodsucker/veil/ActivatePower(trigger_flags)
	. = ..()
	cast_effect() // POOF
//	if(blahblahblah)
//		Disguise_Outfit()
	veil_user()
	owner.balloon_alert(owner, "veil turned on.")

/* // Meant to disguise your character's clothing into fake ones.
/datum/action/cooldown/bloodsucker/veil/proc/Disguise_Outfit()
	return
	// Step One: Back up original items
*/

/datum/action/cooldown/bloodsucker/veil/proc/veil_user()
	// Change Name/Voice
	var/mob/living/carbon/human/user = owner
	to_chat(owner, span_warning("You mystify the air around your person: your identity is now altered."))

	// Store Prev Appearance
	disguise_name = user.generate_random_mob_name()
	prev_gender = user.gender
	prev_skin_tone = user.skin_tone
	prev_hair_style = user.hairstyle
	prev_facial_hair_style = user.facial_hairstyle
	prev_hair_color = user.hair_color
	prev_facial_hair_color = user.facial_hair_color
	prev_underwear = user.underwear
	prev_undershirt = user.undershirt
	prev_socks = user.socks
//	prev_eye_color
	prev_disfigured = HAS_TRAIT(user, TRAIT_DISFIGURED) // I was disfigured! //prev_disabilities = user.disabilities
	prev_features = user.dna.features

	// Change Appearance
	user.gender = pick(MALE, FEMALE, PLURAL, NEUTER)
	user.skin_tone = pick(GLOB.skin_tones)
	user.hairstyle = random_hairstyle(user.gender)
	user.facial_hairstyle = pick(random_facial_hairstyle(user.gender), "Shaved")
	user.hair_color = "#[random_short_color()]"
	user.facial_hair_color = user.hair_color
	user.underwear = random_underwear(user.gender)
	user.undershirt = random_undershirt(user.gender)
	user.socks = random_socks(user.gender)
	//user.eye_color = random_eye_color()
	if(prev_disfigured)
		REMOVE_TRAIT(user, TRAIT_DISFIGURED, null)
	user.dna.features = user.dna.species.randomize_features()

	// Apply Appearance
	user.update_body(is_creating = TRUE) // Outfit and underware, also body.
	user.update_body_parts(update_limb_data = TRUE)

	RegisterSignal(user, COMSIG_HUMAN_GET_VISIBLE_NAME, PROC_REF(return_disguise_name))

/datum/action/cooldown/bloodsucker/veil/proc/return_disguise_name(mob/living/carbon/human/user, list/identity)
	SIGNAL_HANDLER

	identity[VISIBLE_NAME_FACE] = disguise_name
	user.SetSpecialVoice(disguise_name)

/datum/action/cooldown/bloodsucker/veil/DeactivatePower()
	. = ..()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/user = owner
	// Revert Identity
	user.UnsetSpecialVoice()

	// Revert Appearance
	user.gender = prev_gender
	user.skin_tone = prev_skin_tone
	user.hairstyle = prev_hair_style
	user.facial_hairstyle = prev_facial_hair_style
	user.hair_color = prev_hair_color
	user.facial_hair_color = prev_facial_hair_color
	user.underwear = prev_underwear
	user.undershirt = prev_undershirt
	user.socks = prev_socks

	//user.disabilities = prev_disabilities // Restore HUSK, CLUMSY, etc.
	if(prev_disfigured)
		//We are ASSUMING husk. // user.status_flags |= DISFIGURED // Restore "Unknown" disfigurement
		ADD_TRAIT(user, TRAIT_DISFIGURED, TRAIT_HUSK)
	user.dna.features = prev_features

	// Apply Appearance
	user.update_body(is_creating = TRUE) // Outfit and underware, also body.
	user.update_body_parts(update_limb_data = TRUE) // Body itself, maybe skin color?

	cast_effect() // POOF
	owner.balloon_alert(owner, "veil turned off.")

	UnregisterSignal(user, COMSIG_HUMAN_GET_VISIBLE_NAME)


// CAST EFFECT // General effect (poof, splat, etc) when you cast. Doesn't happen automatically!
/datum/action/cooldown/bloodsucker/veil/proc/cast_effect()
	// Effect
	playsound(get_turf(owner), 'sound/effects/magic/smoke.ogg', 20, 1)
	var/datum/effect_system/steam_spread/bloodsucker/puff = new /datum/effect_system/steam_spread/()
	puff.set_up(3, 0, get_turf(owner))
	puff.attach(owner) //OPTIONAL
	puff.start()
	owner.spin(8, 1) //Spin around like a loon.

/obj/effect/particle_effect/fluid/smoke/vampsmoke
	opacity = FALSE
	lifetime = 0

/obj/effect/particle_effect/fluid/smoke/vampsmoke/fade_out(frames = 0.8 SECONDS)
	..(frames)
