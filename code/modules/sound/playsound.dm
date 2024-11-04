/**
 * Sets up a playsound datum with the minimum required information to play the sound.
 */
/proc/create_sound(source, sound)
	RETURN_TYPE(/datum/playsound)
	return new /datum/playsound(source, sound)

/**
 * Datum used to manage the playing of sounds.
 */
/datum/playsound
	/// The source of the sound.
	VAR_PRIVATE/atom/source
	/// The base sound file.
	VAR_PRIVATE/sound/sound
	/// The channel the sound is being played on.
	VAR_PRIVATE/channel

	/// The amount of wait time before the sound is played.
	VAR_PRIVATE/wait = 0
	/// The world.time the sound was played
	VAR_PRIVATE/start_time

	/// A list of listeners that will have the sound played to them.
	VAR_PRIVATE/list/mob/direct_listeners

	/// The volume the sound will be played at.
	VAR_PRIVATE/volume = 50
	/// The range of the sound.
	VAR_PRIVATE/range = SOUND_RANGE

	/// Does the sound allow reverb (simulates the sound bouncing off of walls)
	VAR_PRIVATE/use_reverb = TRUE
	/// The frequency the sound is played at.
	VAR_PRIVATE/frequency = null
	/// If TRUE the pitch of the sound is shifted for each listener.
	VAR_PRIVATE/vary = FALSE

	/// The exponent used to calculate distance falloff. Should be above 1.
	VAR_PRIVATE/falloff_exponent = SOUND_FALLOFF_EXPONENT
	/// The distance at which falloff begins to take effect.
	VAR_PRIVATE/falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE

	/// Is the sound affected by atmospheric conditions?
	VAR_PRIVATE/atmospherics_affected = TRUE
	/// Does the sound play through walls.
	VAR_PRIVATE/ignore_walls = FALSE

	/// Can this sound play through Z levels?
	VAR_PRIVATE/z_traversal_allowed = TRUE
	/// What is the penalty modifier for crossing a Z level?
	VAR_PRIVATE/z_traversal_modifier = 0.75

/datum/playsound/New(source, sound)
	..()

	if(source && !isatom(source))
		CRASH("Invalid source type ([source:type]) passed to [type]")

	src.source = source

	if(isnull(sound))
		CRASH("null sound passed to [type]")

	if(islist(sound))
		sound = pick(sound)

	if(istext(sound))
		if(fexists(sound))
			sound = sound(fcopy_rsc(sound))
		else
			sound = get_sfx(sound)

	if(isfile(sound))
		sound = sound(sound)

	if(!istype(sound, /sound))
		CRASH("Invalid sound type ([sound:type]) passed to [type]")
	src.sound = sound

/datum/playsound/Destroy(force)
	source = null
	sound = null
	return ..()

#define WITH_X(var) /datum/playsound/proc/##var(##var) {\
	RETURN_TYPE(/datum/playsound); \
	src.##var = ##var; \
	return src; \
}

WITH_X(channel)
WITH_X(volume)
WITH_X(wait)
WITH_X(use_reverb)
WITH_X(frequency)
WITH_X(vary)
WITH_X(falloff_exponent)
WITH_X(falloff_distance)
WITH_X(atmospherics_affected)
WITH_X(ignore_walls)
WITH_X(z_traversal_allowed)
WITH_X(z_traversal_modifier)

#undef WITH_X

/datum/playsound/proc/extra_range(extra_range)
	RETURN_TYPE(/datum/playsound)
	range = SOUND_RANGE + extra_range
	return src

/datum/playsound/proc/direct_listeners(...)
	RETURN_TYPE(/datum/playsound)
	if(args.len == 1 && islist(args[1]))
		src.direct_listeners = args[1].Copy()
	else
		src.direct_listeners = args.Copy()
	return src
