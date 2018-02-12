/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/obj/effect/proc_holder/spell/bloodsucker/veil
	name = "Veil of Predation"
	desc = "Further hide your identity, that you may hunt in secrecy without revealing your mortal disguise."
	bloodcost = 10
	bloodcost_constant = 0.2
	charge_max = 100
	amToggleable = TRUE
	action_icon_state = "power_human"				// State for that image inside icon
	stat_allowed = CONSCIOUS

	// LOOK UP: get_visible_name() in human_helpers.dm
	// NAME: name_override (in mob/living/carbon/human) as your Vamp name, then back to "" when done.
	// VOICE: use SetSpecialVoice() and UnsetSpecialVoice() in say.dm (human folder)

	// TODO: Hide outfit, create some cloak to cover you? Use clothing/suit/space to simulate hiding your actual clothes!
	// Check out check_obscured_slots() in human.dm to see how game finds obscuring clothing, and flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT  inside /obj/item/clothing

	// Things to Remember
	var/prev_gender
	var/prev_skin_tone
	var/prev_hair_style
	var/prev_facial_hair_style
	var/prev_hair_color
	var/prev_facial_hair_color
	var/prev_underwear
	var/prev_undershirt
	var/prev_socks

	//var/prev_disabilities // REMOVED: Disability revamp broke this. Don't worry about this anyway. If you're husked, then go heal.
	var/prev_disfigured
	var/list/prev_features	// For lizards and such

// CAST CHECK //	// USE THIS TO SEE IF WE CAN EVEN ACTIVATE THIS POWER //  Called from Click()
///obj/effect/proc_holder/spell/bloodsucker/veil/cast_check(skipcharge = 0,mob/living/user = usr) //checks if the spell can be cast based on its settings; skipcharge is used when an additional cast_check is called inside the spell
//	// Run Checks...
//	return



// APPLY EFFECT //	// USE THIS FOR THE SPELL EFFECT //
/obj/effect/proc_holder/spell/bloodsucker/veil/cast(list/targets, mob/living/user = usr) 		// NOTE: Called from perform() in /proc_holder/spell
	..() // DEFAULT

	if (!ishuman(user))
		return 0

	// Spend Blood
	pay_blood_cost()

	// Change Name/Voice
	var/mob/living/carbon/human/H = user
	H.name_override = H.dna.species.random_name(H.gender)
	H.name = H.name_override
	H.SetSpecialVoice(H.name_override)
	to_chat(user, "<span class='warning'>You mystify the air around your person. Your identity is now altered.</span>")

	// Store Prev Appearance
	prev_gender = H.gender
	prev_skin_tone = H.skin_tone
	prev_hair_style = H.hair_style
	prev_facial_hair_style = H.facial_hair_style
	prev_hair_color = H.hair_color
	prev_facial_hair_color = H.facial_hair_color
	prev_underwear = H.underwear
	prev_undershirt = H.undershirt
	prev_socks = H.socks
	//prev_eye_color
	prev_disfigured = H.has_trait(TRAIT_DISFIGURED) // I was disfigured! //prev_disabilities = H.disabilities
	prev_features = H.dna.features

	// Change Appearance
	H.gender = pick(MALE, FEMALE)
	H.skin_tone = random_skin_tone()
	H.hair_style = random_hair_style(H.gender)
	H.facial_hair_style = pick(random_facial_hair_style(H.gender),"Shaved")
	H.hair_color = random_short_color()
	H.facial_hair_color = H.hair_color
	H.underwear = random_underwear(H.gender)
	H.undershirt = random_undershirt(H.gender)
	H.socks = random_socks(H.gender)
	//H.eye_color = random_eye_color()
	H.remove_trait(TRAIT_DISFIGURED) // H.status_flags &= ~DISFIGURED //H.disabilities = 0 // Disable HUSK, CLUMSY, etc.
	H.dna.features = random_features()

	// Mutant Parts
	//H.dna.species.mutant_bodyparts // List of appropriate parts.

	// Apply Appearance
	H.update_body() // Outfit and underware, also body.
	//H.update_mutant_bodyparts() // Lizard tails etc
	H.update_hair()
	H.update_body_parts()

	// Cast Effect (poof!)
	cast_effect(user)

	// Wait here til we deactivate power or go unconscious
	while (active && user && user.stat <= stat_allowed)
		sleep(10)

	// Wait for a moment if you fell unconscious...
	if (active && user && user.stat > stat_allowed)
		sleep(50)

	// I removed this power or disabled this manually. Abort.
	if (!user || !active)
		return

	// Done
	cancel_spell(user)



// END SPELL //	// WHEN A SPELL COMES TO AN END, NO MATTER HOW IT HAPPENED.
/obj/effect/proc_holder/spell/bloodsucker/veil/end_active_spell(mob/living/user = usr, dispmessage="")
	dispmessage = (user.stat == 0) ? "<span class='warning'>With a flourish, you dismiss your temporary disguise.</span>" : ""
	..()

	if (!ishuman(user))
		return 0

	var/mob/living/carbon/human/H = user

	// Revert Identity
	H.UnsetSpecialVoice()
	H.name_override = null
	H.name = H.real_name

	// Revert Appearance
	H.gender = prev_gender
	H.skin_tone = prev_skin_tone
	H.hair_style = prev_hair_style
	H.facial_hair_style = prev_facial_hair_style
	H.hair_color = prev_hair_color
	H.facial_hair_color = prev_facial_hair_color
	H.underwear = prev_underwear
	H.undershirt = prev_undershirt
	H.socks = prev_socks

	//H.disabilities = prev_disabilities // Restore HUSK, CLUMSY, etc.
	if (prev_disfigured)
		H.add_trait(TRAIT_DISFIGURED, "husk") // NOTE: We are ASSUMING husk. // H.status_flags |= DISFIGURED	// Restore "Unknown" disfigurement
	H.dna.features = prev_features

	// Apply Appearance
	H.update_body() // Outfit and underware, also body.
	H.update_hair()
	H.update_body_parts()	// Body itself, maybe skin color?

	cast_effect(user)


// CAST EFFECT //	// General effect (poof, splat, etc) when you cast. Doesn't happen automatically!
/obj/effect/proc_holder/spell/bloodsucker/veil/cast_effect(mob/living/user = usr)
	// Effect
	playsound(get_turf(user), 'sound/magic/smoke.ogg', 20, 1)
	var/datum/effect_system/steam_spread/puff = new /datum/effect_system/steam_spread/()
	puff.effect_type = /obj/effect/particle_effect/smoke/vampsmoke
	puff.set_up(3, 0, get_turf(user))
	puff.start()
	user.spin(8, 1) // Spin around like a loon.

	..()

/obj/effect/particle_effect/smoke/vampsmoke
	opaque = FALSE
	amount = 0
	lifetime = 0
/obj/effect/particle_effect/smoke/vampsmoke/fade_out(frames = 6)
	..(frames)

// POWER IDEAS:

// Vampiric Form: 	Appear as a sprite with your vamp name, not your own. Either hide all gear and create new, temporary stuff, or create a vamp sprite and replace player icon.
//
// Strength:		Toggle on and click person to shove them, or click a door to pry it open.
//
// Speed:			Increase projectile dodge (while on?), click to dash to an area at incredible speed.
//
// Strength + Speed: Dash turns into a grab if you click a person.






