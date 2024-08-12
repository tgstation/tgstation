#define FROG_VOLUME				50
#define FROG_NOISE_COOLDOWN		1.5 SECONDS
#define FROG_FALLOFF_EXPONENT	20 // same as bike horn

/mob/living/basic/frog
	/// Cooldown for frogs making their frog noise
	COOLDOWN_DECLARE(frogspam_cooldown)

/mob/living/basic/frog/proc/on_entered(datum/source, mob/living/stepper)
	SIGNAL_HANDLER
	if(stat || !isliving(stepper) || stepper.mob_size <= MOB_SIZE_TINY || !COOLDOWN_FINISHED(src, frogspam_cooldown))
		return
	playsound(
		src,
		stepped_sound,
		vol = FROG_VOLUME,
		vary = TRUE,
		extrarange = MEDIUM_RANGE_SOUND_EXTRARANGE,
		falloff_exponent = FROG_FALLOFF_EXPONENT,
		ignore_walls = FALSE, // I DO NOT WANT TO HEAR THIS THING FROM THE NEXT DEPARTMENT OVER
		mixer_channel = CHANNEL_SQUEAK,
	)
	COOLDOWN_START(src, frogspam_cooldown, FROG_NOISE_COOLDOWN)

#undef FROG_FALLOFF_EXPONENT
#undef FROG_NOISE_COOLDOWN
#undef FROG_VOLUME
