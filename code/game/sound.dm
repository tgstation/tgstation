var/list/shatter_sound = list('sound/effects/Glassbr1.ogg','sound/effects/Glassbr2.ogg','sound/effects/Glassbr3.ogg')
var/list/explosion_sound = list('sound/effects/Explosion1.ogg','sound/effects/Explosion2.ogg','sound/effects/Explosion3.ogg','sound/effects/Explosion4.ogg','sound/effects/Explosion5.ogg','sound/effects/Explosion6.ogg')
var/list/small_explosion_sound = list('sound/effects/Explosion_Small1.ogg','sound/effects/Explosion_Small2.ogg','sound/effects/Explosion_Small3.ogg')
var/list/spark_sound = list('sound/effects/sparks1.ogg','sound/effects/sparks2.ogg','sound/effects/sparks3.ogg','sound/effects/sparks4.ogg')
var/list/rustle_sound = list('sound/effects/rustle1.ogg','sound/effects/rustle2.ogg','sound/effects/rustle3.ogg','sound/effects/rustle4.ogg','sound/effects/rustle5.ogg')
var/list/punch_sound = list('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
var/list/clown_sound = list('sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg')
var/list/swing_hit_sound = list('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')
var/list/hiss_sound = list('sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg')
var/list/page_sound = list('sound/effects/pageturn1.ogg', 'sound/effects/pageturn2.ogg','sound/effects/pageturn3.ogg')
var/list/mechstep_sound = list('sound/mecha/mechstep1.ogg', 'sound/mecha/mechstep2.ogg')
var/list/gib_sound = list('sound/effects/gib1.ogg', 'sound/effects/gib2.ogg', 'sound/effects/gib3.ogg')
var/list/mommicomment_sound = list('sound/voice/mommi_comment1.ogg', 'sound/voice/mommi_comment2.ogg', 'sound/voice/mommi_comment3.ogg', 'sound/voice/mommi_comment5.ogg', 'sound/voice/mommi_comment6.ogg', 'sound/voice/mommi_comment7.ogg', 'sound/voice/mommi_comment8.ogg')
var/list/polaroid_sound = list('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg')
var/list/male_scream_sound = list('sound/misc/malescream1.ogg', 'sound/misc/malescream2.ogg', 'sound/misc/malescream3.ogg', 'sound/misc/malescream4.ogg', 'sound/misc/malescream5.ogg')
var/list/female_scream_sound = list('sound/misc/femalescream1.ogg', 'sound/misc/femalescream2.ogg', 'sound/misc/femalescream3.ogg', 'sound/misc/femalescream4.ogg', 'sound/misc/femalescream5.ogg')
var/list/lightning_sound = list('sound/effects/lightning/chainlightning1.ogg', 'sound/effects/lightning/chainlightning2.ogg', 'sound/effects/lightning/chainlightning3.ogg', 'sound/effects/lightning/chainlightning4.ogg', 'sound/effects/lightning/chainlightning5.ogg', 'sound/effects/lightning/chainlightning6.ogg', 'sound/effects/lightning/chainlightning7.ogg')

//var/list/gun_sound = list('sound/weapons/Gunshot.ogg', 'sound/weapons/Gunshot2.ogg','sound/weapons/Gunshot3.ogg','sound/weapons/Gunshot4.ogg')

//gas_modified controls if a sound is affected by how much gas there is in the atmosphere of the source
//space sounds have no gas modification, for example. Though >space sounds
/proc/playsound(var/atom/source, soundin, vol as num, vary, extrarange as num, falloff, var/gas_modified = 1)
	var/turf/turf_source = get_turf(source)

	ASSERT(!isnull(turf_source))

	var/frequency = get_rand_frequency() // Same frequency for everybody

/* What's going on in this block?
	If the proc isn't set to not be modified by air, the following steps occur:
	- The atmospheric pressure of the turf where the sound is played is determined
	- A calculation is made as to the fraction of one atmosphere that the pressure is at, in tenths e.g. 0.1, 0.3, 0.7, never exceeding 1
	- If the proc has extrarange, the fraction of this extrarange that applies is equal to that of the pressure of the tile
	- If the proc has NO extrarange, the fraction of the 7 range is used, so a sound only trasmits to those in the screen at regular pressure
	- This means that at low or 0 pressure, sound doesn't trasmit from the tile at all! How cool is that?
*/
	if(!extrarange)
		extrarange = 0
	if(!vol) //don't do that
		return

	if(gas_modified && turf_source && !turf_source.c_airblock(turf_source)) //if the sound is modified by air, and we are on an airflowing tile
		var/atmosphere = 0
		var/datum/gas_mixture/current_air = turf_source.return_air()
		if(current_air)
			atmosphere = current_air.return_pressure()
		else
			atmosphere = 0 //no air

		//message_admins("We're starting off with [atmosphere], [extrarange], and [vol]")
		var/atmos_modifier = round(atmosphere/ONE_ATMOSPHERE, 0.1)
		var/total_range = world.view + extrarange //this must be positive.
		total_range = min ( round( (total_range) * sqrt(atmos_modifier), 1 ), (total_range * 2)  ) //upper range of twice the original range. Range technically falls off with the root of pressure (see Newtonian sound)
		extrarange = total_range - world.view
		vol = min( round( (vol) * atmos_modifier, 1 ), vol * 2) //upper range of twice the volume. Trust me, otherwise you get 10000 volume in a plasmafire
		//message_admins("We've adjusted the sound of [source] at [turf_source.loc] to have a range of [7 + extrarange] and a volume of [vol]")

	var/Dist = world.view + extrarange

	// Looping through the player list has the added bonus of working for mobs inside containers
	for (var/mob/player in player_list)
		if(!player || !player.client)
			continue

		var/turf/player_turf = get_turf(player)

		if (player_turf && turf_source && player_turf.z == turf_source.z)
			if(get_dist(player_turf, turf_source) <= Dist)
				player.playsound_local(turf_source, soundin, vol, vary, frequency, falloff, gas_modified)

var/const/FALLOFF_SOUNDS = 1
var/const/SURROUND_CAP = 7

#define MIN_SOUND_PRESSURE	2 //2 kPa of pressure required to at least hear sound
/mob/proc/playsound_local(var/turf/turf_source, soundin, vol as num, vary, frequency, falloff, gas_modified)
	if(!src.client)
		return

	if(ear_deaf > 0)
		vol = vol / (1 + ear_deaf)

	if(gas_modified)
		var/turf/current_turf = get_turf(src)
		if(!current_turf)
			return

		var/datum/gas_mixture/environment = current_turf.return_air()
		var/atmosphere = 0
		if(environment)
			atmosphere = environment.return_pressure()

		/// Local sound modifications ///
		if(atmosphere < MIN_SOUND_PRESSURE) //no sound reception in space, boyos
			vol = 0
		else
			vol = min( vol * atmosphere / ONE_ATMOSPHERE, vol) //sound can't be amplified from low to high pressure, but can be reduced
		/// end ///

	soundin = get_sfx(soundin)

	var/sound/S = sound(soundin, 0, 0, 0, vol)

	if (vary)
		if(frequency)
			S.frequency = frequency
		else
			S.frequency = get_rand_frequency()

	if(isturf(turf_source))
		// 3D sounds, the technology is here!
		var/turf/T = get_turf(src)

		var/dx = turf_source.x - T.x // Hearing from the right/left
		S.x = round(Clamp(dx, -SURROUND_CAP, SURROUND_CAP), 1)

		var/dz = turf_source.y - T.y // Hearing from infront/behind
		S.z = round(Clamp(dz, -SURROUND_CAP, SURROUND_CAP), 1)

		// The y value is for above your head, but there is no ceiling in 2d spessmens.
		S.y = 1

		S.falloff = (falloff ? falloff : FALLOFF_SOUNDS)

	to_chat(src, S)

/client/proc/playtitlemusic()
	if(!ticker || !ticker.login_music)	return
	if(prefs.toggles & SOUND_LOBBY)
		if(istype(src))
			src << sound(ticker.login_music, repeat = 0, wait = 0, volume = 85, channel = 1) // MAD JAMS


/proc/get_rand_frequency()
	return rand(32000, 55000) //Frequency stuff only works with 45kbps oggs.

/proc/get_sfx(soundin)
	if(istext(soundin))
		switch(soundin)
			if ("shatter") soundin = pick(shatter_sound)
			if ("explosion") soundin = pick(explosion_sound)
			if ("explosion_small") soundin = pick(small_explosion_sound)
			if ("sparks") soundin = pick(spark_sound)
			if ("rustle") soundin = pick(rustle_sound)
			if ("punch") soundin = pick(punch_sound)
			if ("clownstep") soundin = pick(clown_sound)
			if ("swing_hit") soundin = pick(swing_hit_sound)
			if ("hiss") soundin = pick(hiss_sound)
			if ("pageturn") soundin = pick(page_sound)
			if ("mechstep") soundin = pick(mechstep_sound)
			if ("gib") soundin = pick(gib_sound)
			if ("mommicomment") soundin = pick(mommicomment_sound)
			if ("polaroid") soundin = pick(polaroid_sound)
			if ("malescream") soundin = pick(male_scream_sound)
			if ("femalescream") soundin = pick(female_scream_sound)
			//if ("gunshot") soundin = pick(gun_sound)
	return soundin
