
#define NITROGEN_RETARDATION_FACTOR 4        //Higher == N2 slows reaction more
#define THERMAL_RELEASE_MODIFIER 10                //Higher == less heat released during reaction
#define PLASMA_RELEASE_MODIFIER 1500                //Higher == less plasma released by reaction
#define OXYGEN_RELEASE_MODIFIER 750        //Higher == less oxygen released at high temperature/power
#define REACTION_POWER_MODIFIER 1.1                //Higher == more overall power

//These would be what you would get at point blank, decreases with distance
#define DETONATION_RADS 200
#define DETONATION_HALLUCINATION 600

#define WARNING_DELAY 30 		//seconds between warnings.
#define AUDIO_WARNING_DELAY 30

/obj/machinery/power/supermatter
	name = "Supermatter Crystal"
	desc = "A strangely translucent and iridescent crystal. \red You get headaches just from looking at it."
	icon = 'icons/obj/engine.dmi'
	icon_state = "darkmatter"
	density = 1
	anchored = 0

	var/max_luminosity = 8 // Now varies based on power.

	l_color = "#ffcc00"

	// What it's referred to in the alerts
	var/short_name = "Crystal"

	var/gasefficency = 0.25

	var/base_icon_state = "darkmatter"

	var/damage = 0
	var/damage_archived = 0
	var/warning_point = 100
	var/emergency_point = 700
	var/explosion_point = 1000

	var/emergency_issued = 0

	var/explosion_power = 8

	var/lastwarning = 0                        // Time in 1/10th of seconds since the last sent warning
	var/lastaudiowarning = 0
	var/power = 0

	var/oxygen = 0				  // Moving this up here for easier debugging.

	//Temporary values so that we can optimize this
	//How much the bullets damage should be multiplied by when it is added to the internal variables
	var/config_bullet_energy = 2
	//How much of the power is left after processing is finished?
//        var/config_power_reduction_per_tick = 0.5
	//How much hallucination should it produce per unit of power?
	var/config_hallucination_power = 0.1

	var/obj/item/device/radio/radio

	// Monitoring shit
	var/frequency = 0
	var/id_tag

/obj/machinery/power/supermatter/shard //Small subtype, less efficient and more sensitive, but less boom.
	name = "Supermatter Shard"
	short_name = "Shard"
	desc = "A strangely translucent and iridescent crystal that looks like it used to be part of a larger structure. \red You get headaches just from looking at it."
	icon_state = "darkmatter_shard"
	base_icon_state = "darkmatter_shard"

	warning_point = 50
	emergency_point = 500
	explosion_point = 900

	gasefficency = 0.125

	explosion_power = 8 // WAS 3 - N3X


/obj/machinery/power/supermatter/New()
	. = ..()
	radio = new (src)


/obj/machinery/power/supermatter/Destroy()
	del(radio)
	. = ..()

/obj/machinery/power/supermatter/proc/explode()
		explosion(get_turf(src), explosion_power, explosion_power * 2, explosion_power * 3, explosion_power * 4, 1)
		new /turf/unsimulated/wall/supermatter(get_turf(src))
		SetUniversalState(/datum/universal_state/supermatter_cascade)
		del(src)

/obj/machinery/power/supermatter/shard/explode()
		explosion(get_turf(src), explosion_power, explosion_power * 2, explosion_power * 3, explosion_power * 4, 1)
		del src
		return

/obj/machinery/power/supermatter/process()

	var/turf/L = loc
	if(isnull(L))		// We have a null turf...something is wrong, stop processing this entity.
		return PROCESS_KILL

	if(!istype(L)) 	//We are in a crate or somewhere that isn't turf, if we return to turf resume processing but for now.
		return  //Yeah just stop.

	if(istype(L, /turf/space))	// Stop processing this stuff if we've been ejected.
		return

	// Let's add beam energy first.
	for(var/obj/effect/beam/emitter/B in beams)
		power += B.get_damage() * config_bullet_energy

	var/stability = round((damage / explosion_point) * 100)
	if(damage > warning_point) // while the core is still damaged and it's still worth noting its status

		var/list/audio_sounds = list('sound/AI/supermatter_integrity_before.ogg')
		var/play_alert = 0
		var/audio_offset = 0
		if((world.timeofday - lastwarning) / 10 >= WARNING_DELAY)
			var/warning=""
			var/offset = 0

			audio_sounds += vox_num2list(stability)
			audio_sounds += list('sound/AI/supermatter_integrity_after.ogg')

			// Damage still low.
			if(damage >= damage_archived) // The damage is still going up
				warning = "Danger! [short_name] hyperstructure instability detected, now at [stability]%."
				offset=150

				if(damage > emergency_point)
					warning = "[uppertext(short_name)] INSTABILITY AT [stability]%. DELAMINATION IMMINENT - EVACUATE IMMEDIATELY."
					offset=0
					audio_sounds += list('sound/AI/supermatter_delam.ogg')
					//audio_offset = 100
				play_alert=1
			else
				warning = "[short_name] hyperstructure returning to safe operating levels. Instability: [stability]%"
			radio.autosay(warning, "Supermatter [short_name] Monitor")
			lastwarning = world.timeofday - offset

		if(play_alert && (world.timeofday - lastaudiowarning) / 10 >= AUDIO_WARNING_DELAY)
			for(var/sf in audio_sounds)
				var/sound/voice = sound(sf, wait = 1, channel = VOX_CHANNEL)
				voice.status = SOUND_STREAM
				world << voice
			lastaudiowarning = world.timeofday - audio_offset

		if(frequency)
			var/datum/radio_frequency/radio_connection = radio_controller.return_frequency(frequency)

			if(!radio_connection) return

			var/datum/signal/signal = new
			signal.source = src
			signal.transmission_method = 1
			signal.data = list(
				"tag" = id_tag,
				"device" = "SM",
				"instability" = stability,
				"damage" = damage,
				"power" = power,
				"sigtype" = "status"
			)
			radio_connection.post_signal(src, signal)

		if(damage > explosion_point)
			for(var/mob/living/mob in living_mob_list)
				if(istype(mob, /mob/living/carbon/human))
					//Hilariously enough, running into a closet should make you get hit the hardest.
					mob:hallucination += max(50, min(300, DETONATION_HALLUCINATION * sqrt(1 / (get_dist(mob, src) + 1)) ) )
				var/rads = DETONATION_RADS * sqrt( 1 / (get_dist(mob, src) + 1) )
				mob.apply_effect(rads, IRRADIATE)

			explode()

	//Ok, get the air from the turf
	var/datum/gas_mixture/env = L.return_air()

	//Remove gas from surrounding area
	var/datum/gas_mixture/removed = env.remove(gasefficency * env.total_moles)

	if(!removed || !removed.total_moles)
		damage += max((power-1600)/10, 0)
		power = min(power, 1600)
		return 1

	if (!removed)
		return 1

	damage_archived = damage
	damage = max( damage + ( (removed.temperature - 800) / 150 ) , 0 )
	//Ok, 100% oxygen atmosphere = best reaction
	//Maxes out at 100% oxygen pressure
	oxygen = max(min((removed.oxygen - (removed.nitrogen * NITROGEN_RETARDATION_FACTOR)) / MOLES_CELLSTANDARD, 1), 0)

	var/temp_factor = 100

	if(oxygen > 0.8)
		// with a perfect gas mix, make the power less based on heat
		icon_state = "[base_icon_state]_glow"
	else
		// in normal mode, base the produced energy around the heat
		temp_factor = 60
		icon_state = base_icon_state

	power = max( (removed.temperature * temp_factor / T0C) * oxygen + power, 0) //Total laser power plus an overload

	//We've generated power, now let's transfer it to the collectors for storing/usage
	transfer_energy()

	var/device_energy = power * REACTION_POWER_MODIFIER

	//To figure out how much temperature to add each tick, consider that at one atmosphere's worth
	//of pure oxygen, with all four lasers firing at standard energy and no N2 present, at room temperature
	//that the device energy is around 2140. At that stage, we don't want too much heat to be put out
	//Since the core is effectively "cold"

	//Also keep in mind we are only adding this temperature to (efficiency)% of the one tile the rock
	//is on. An increase of 4*C @ 25% efficiency here results in an increase of 1*C / (#tilesincore) overall.
	removed.temperature += (device_energy / THERMAL_RELEASE_MODIFIER)

	removed.temperature = max(0, min(removed.temperature, 2500))

	//Calculate how much gas to release
	removed.toxins += max(device_energy / PLASMA_RELEASE_MODIFIER, 0)

	removed.oxygen += max((device_energy + removed.temperature - T0C) / OXYGEN_RELEASE_MODIFIER, 0)

	removed.update_values()

	env.merge(removed)

	for(var/mob/living/carbon/human/l in view(src, min(7, round(power ** 0.25)))) // If they can see it without mesons on.  Bad on them.
		if(!istype(l.glasses, /obj/item/clothing/glasses/meson))
			l.hallucination = max(0, min(200, l.hallucination + power * config_hallucination_power * sqrt( 1 / max(1,get_dist(l, src)) ) ) )

	for(var/mob/living/l in range(src, round((power / 100) ** 0.25)))
		var/rads = (power / 10) * sqrt( 1 / get_dist(l, src) )
		l.apply_effect(rads, IRRADIATE)

	power -= (power/500)**3

	return 1


/obj/machinery/power/supermatter/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return {"
	<b>Main</b>
	<ul>
		<li><b>Frequency:</b> <a href="?src=\ref[src];set_freq=-1">[format_frequency(frequency)] GHz</a> (<a href="?src=\ref[src];set_freq=[initial(frequency)]">Reset</a>)</li>
		<li>[format_tag("ID Tag","id_tag")]</li>
	</ul>"}

/obj/machinery/power/supermatter/bullet_act(var/obj/item/projectile/Proj)
	var/turf/L = loc
	if(!istype(L))		// We don't run process() when we are in space
		return 0	// This stops people from being able to really power up the supermatter
				// Then bring it inside to explode instantly upon landing on a valid turf.


	if(Proj.flag != "bullet")
		power += Proj.damage * config_bullet_energy
	else
		damage += Proj.damage * config_bullet_energy
	return 0


/obj/machinery/power/supermatter/attack_paw(mob/user as mob)
	return attack_hand(user)


/obj/machinery/power/supermatter/attack_robot(mob/user as mob)
	if(Adjacent(user))
		return attack_hand(user)
	else
		attack_ai(user)

/obj/machinery/power/supermatter/attack_ghost(mob/user as mob)
	attack_ai(user)

/obj/machinery/power/supermatter/attack_ai(mob/user as mob)
	src.examine()
	var/stability = num2text(round((damage / explosion_point) * 100))
	user << "<span class = \"info\">Matrix Instability: [stability]%</span>"
	user << "<span class = \"info\">Damage: [format_num(damage)]</span>" // idfk what units we're using.
	user << "<span class = \"info\">Power: [format_num(power)]J</span>" // Same

/obj/machinery/power/supermatter/attack_hand(mob/user as mob)
	user.visible_message("<span class=\"warning\">\The [user] reaches out and touches \the [src], inducing a resonance... \his body starts to glow and bursts into flames before flashing into ash.</span>",\
		"<span class=\"danger\">You reach out and touch \the [src]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"</span>",\
		"<span class=\"warning\">You hear an unearthly noise as a wave of heat washes over you.</span>")

	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, 1)

	Consume(user)

/obj/machinery/power/supermatter/proc/transfer_energy()
	for(var/obj/machinery/power/rad_collector/R in rad_collectors)
		if(get_dist(R, src) <= 15) // Better than using orange() every process
			R.receive_pulse(power)
	return

/obj/machinery/power/supermatter/attackby(obj/item/weapon/W as obj, mob/living/user as mob)
	if(istype(W, /obj/item/device/multitool))
		update_multitool_menu(user)
		return 1

	user.visible_message("<span class=\"warning\">\The [user] touches \a [W] to \the [src] as a silence fills the room...</span>",\
		"<span class=\"danger\">You touch \the [W] to \the [src] when everything suddenly goes silent.\"</span>\n<span class=\"notice\">\The [W] flashes into dust as you flinch away from \the [src].</span>",\
		"<span class=\"warning\">Everything suddenly goes silent.</span>")

	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, 1)

	user.drop_from_inventory(W)
	Consume(W)

	user.apply_effect(150, IRRADIATE)


/obj/machinery/power/supermatter/Bumped(atom/AM as mob|obj)
	if(istype(AM, /mob/living))
		AM.visible_message("<span class=\"warning\">\The [AM] slams into \the [src] inducing a resonance... \his body starts to glow and catch flame before flashing into ash.</span>",\
		"<span class=\"danger\">You slam into \the [src] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\"</span>",\
		"<span class=\"warning\">You hear an unearthly noise as a wave of heat washes over you.</span>")
	else
		AM.visible_message("<span class=\"warning\">\The [AM] smacks into \the [src] and rapidly flashes to ash.</span>",\
		"<span class=\"warning\">You hear a loud crack as you are washed with a wave of heat.</span>")

	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, 1)

	Consume(AM)


/obj/machinery/power/supermatter/proc/Consume(var/mob/living/user)
	if(istype(user))
		user.dust()
		power += 200
	else
		del user

	power += 200

		//Some poor sod got eaten, go ahead and irradiate people nearby.
	for(var/mob/living/l in range(10))
		if(l in view())
			l.show_message("<span class=\"warning\">As \the [src] slowly stops resonating, you find your skin covered in new radiation burns.</span>", 1,\
				"<span class=\"warning\">The unearthly ringing subsides and you notice you have new radiation burns.</span>", 2)
		else
			l.show_message("<span class=\"warning\">You hear an uneartly ringing and notice your skin is covered in fresh radiation burns.</span>", 2)
		var/rads = 500 * sqrt( 1 / (get_dist(l, src) + 1) )
		l.apply_effect(rads, IRRADIATE, 0) // Permit blocking

