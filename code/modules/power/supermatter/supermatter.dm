//Ported from /vg/station13, which was in turn forked from baystation12;
//Please do not bother them with bugs from this port, however, as it has been modified quite a bit.
//Modifications include removing the world-ending full supermatter variation, and leaving only the shard.

#define NITROGEN_RETARDATION_FACTOR 2        //Higher == N2 slows reaction more
#define THERMAL_RELEASE_MODIFIER 5                //Higher == less heat released during reaction
#define PLASMA_RELEASE_MODIFIER 750                //Higher == less plasma released by reaction
#define OXYGEN_RELEASE_MODIFIER 325        //Higher == less oxygen released at high temperature/power
#define REACTION_POWER_MODIFIER 0.55                //Higher == more overall power


//These would be what you would get at point blank, decreases with distance
#define DETONATION_RADS 200
#define DETONATION_HALLUCINATION 600


#define WARNING_DELAY 30 		//seconds between warnings.

/obj/machinery/power/supermatter_shard
	name = "supermatter shard"
	desc = "A strangely translucent and iridescent crystal that looks like it used to be part of a larger structure. <span class='danger'>You get headaches just from looking at it.</span>"
	icon = 'icons/obj/supermatter.dmi'
	icon_state = "darkmatter_shard"
	density = 1
	anchored = 0
	luminosity = 4
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	critical_machine = TRUE

	var/gasefficency = 0.125

	var/base_icon_state = "darkmatter_shard"

	var/damage = 0
	var/damage_archived = 0
	var/safe_alert = "Crystalline hyperstructure returning to safe operating levels."
	var/warning_point = 50
	var/warning_alert = "Danger! Crystal hyperstructure instability!"
	var/emergency_point = 500
	var/emergency_alert = "CRYSTAL DELAMINATION IMMINENT."
	var/explosion_point = 900

	var/emergency_issued = 0

	var/explosion_power = 8

	var/lastwarning = 0				// Time in 1/10th of seconds since the last sent warning
	var/power = 0

	var/oxygen = 0					// Moving this up here for easier debugging.

	//Temporary values so that we can optimize this
	//How much the bullets damage should be multiplied by when it is added to the internal variables
	var/config_bullet_energy = 2
	//How much of the power is left after processing is finished?
//	var/config_power_reduction_per_tick = 0.5
	//How much hallucination should it produce per unit of power?
	var/config_hallucination_power = 0.1

	var/obj/item/device/radio/radio

	//for logging
	var/has_been_powered = 0
	var/has_reached_emergency = 0

	// For making hugbox supermatter
	var/takes_damage = 1
	var/produces_gas = 1
	var/obj/effect/countdown/supermatter/countdown

/obj/machinery/power/supermatter_shard/New()
	. = ..()
	countdown = new(src)
	countdown.start()
	poi_list |= src
	radio = new(src)
	radio.listening = 0
	investigate_log("has been created.", "supermatter")


/obj/machinery/power/supermatter_shard/Destroy()
	investigate_log("has been destroyed.", "supermatter")
	if(radio)
		qdel(radio)
		radio = null
	poi_list -= src
	if(countdown)
		qdel(countdown)
		countdown = null
	. = ..()

/obj/machinery/power/supermatter_shard/proc/explode()
	investigate_log("has exploded.", "supermatter")
	explosion(get_turf(src), explosion_power, explosion_power * 2, explosion_power * 3, explosion_power * 4, 1, 1)
	qdel(src)

/obj/machinery/power/supermatter_shard/process()
	var/turf/T = loc

	if(isnull(T))		// We have a null turf...something is wrong, stop processing this entity.
		return PROCESS_KILL

	if(!istype(T)) 	//We are in a crate or somewhere that isn't turf, if we return to turf resume processing but for now.
		return  //Yeah just stop.

	if(isspaceturf(T))	// Stop processing this stuff if we've been ejected.
		return

	if(damage > warning_point) // while the core is still damaged and it's still worth noting its status
		if((world.timeofday - lastwarning) / 10 >= WARNING_DELAY)
			var/stability = num2text(round((damage / explosion_point) * 100))

			if(damage > emergency_point)
				radio.talk_into(src, "[emergency_alert] Instability: [stability]%")
				lastwarning = world.timeofday
				if(!has_reached_emergency)
					investigate_log("has reached the emergency point for the first time.", "supermatter")
					message_admins("[src] has reached the emergency point <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>(JMP)</a>.")
					has_reached_emergency = 1

			else if(damage >= damage_archived) // The damage is still going up
				radio.talk_into(src, "[warning_alert] Instability: [stability]%")
				lastwarning = world.timeofday - 150

			else                                                 // Phew, we're safe
				radio.talk_into(src, "[safe_alert]")
				lastwarning = world.timeofday

		if(damage > explosion_point)
			for(var/mob in living_mob_list)
				var/mob/living/L = mob
				if(istype(L) && L.z == z)
					if(ishuman(mob))
						//Hilariously enough, running into a closet should make you get hit the hardest.
						var/mob/living/carbon/human/H = mob
						H.hallucination += max(50, min(300, DETONATION_HALLUCINATION * sqrt(1 / (get_dist(mob, src) + 1)) ) )
					var/rads = DETONATION_RADS * sqrt( 1 / (get_dist(L, src) + 1) )
					L.rad_act(rads)

			explode()

	//Ok, get the air from the turf
	var/datum/gas_mixture/env = T.return_air()

	var/datum/gas_mixture/removed

	if(produces_gas)
		//Remove gas from surrounding area
		removed = env.remove(gasefficency * env.total_moles())
	else
		// Pass all the gas related code an empty gas container
		removed = new()

	if(!removed || !removed.total_moles())
		if(takes_damage)
			damage += max((power-1600)/10, 0)
		power = min(power, 1600)
		return 1

	damage_archived = damage
	if(takes_damage)
		damage = max( damage + ( (removed.temperature - 800) / 150 ) , 0 )
	//Ok, 100% oxygen atmosphere = best reaction
	//Maxes out at 100% oxygen pressure
	var/removed_nitrogen = 0
	if(removed.gases["n2"])
		removed_nitrogen = (removed.gases["n2"][MOLES] * NITROGEN_RETARDATION_FACTOR)

	removed.assert_gases("o2", "plasma")

	oxygen = max(min((removed.gases["o2"][MOLES] - removed_nitrogen) / MOLES_CELLSTANDARD, 1), 0)

	var/temp_factor = 50

	if(oxygen > 0.8)
		// with a perfect gas mix, make the power less based on heat
		icon_state = "[base_icon_state]_glow"
	else
		// in normal mode, base the produced energy around the heat
		temp_factor = 30
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
	removed.gases["plasma"][MOLES] += max(device_energy / PLASMA_RELEASE_MODIFIER, 0)

	removed.gases["o2"][MOLES] += max((device_energy + removed.temperature - T0C) / OXYGEN_RELEASE_MODIFIER, 0)

	if(produces_gas)
		env.merge(removed)

	for(var/mob/living/carbon/human/l in view(src, min(7, round(power ** 0.25)))) // If they can see it without mesons on.  Bad on them.
		if(!istype(l.glasses, /obj/item/clothing/glasses/meson))
			var/D = sqrt(1 / max(1, get_dist(l, src)))
			l.hallucination += power * config_hallucination_power * D
			l.hallucination = Clamp(0, 200, l.hallucination)

	for(var/mob/living/l in range(src, round((power / 100) ** 0.25)))
		var/rads = (power / 10) * sqrt( 1 / max(get_dist(l, src),1) )
		l.rad_act(rads)

	power -= (power/500)**3

	return 1

/obj/machinery/power/supermatter_shard

/obj/machinery/power/supermatter_shard/bullet_act(obj/item/projectile/Proj)
	var/turf/L = loc
	if(!istype(L))		// We don't run process() when we are in space
		return 0	// This stops people from being able to really power up the supermatter
				// Then bring it inside to explode instantly upon landing on a valid turf.


	if(Proj.flag != "bullet")
		power += Proj.damage * config_bullet_energy
		if(!has_been_powered)
			investigate_log("has been powered for the first time.", "supermatter")
			message_admins("[src] has been powered for the first time <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>(JMP)</a>.")
			has_been_powered = 1
	else if(takes_damage)
		damage += Proj.damage * config_bullet_energy
	return 0

/obj/machinery/power/supermatter_shard/singularity_act()
	var/gain = 100
	investigate_log("Supermatter shard consumed by singularity.","singulo")
	message_admins("Singularity has consumed a supermatter shard and can now become stage six.")
	visible_message("<span class='userdanger'>[src] is consumed by the singularity!</span>")
	for(var/mob/M in mob_list)
		if(M.z == z)
			M << 'sound/effects/supermatter.ogg' //everyone goan know bout this
			M << "<span class='boldannounce'>A horrible screeching fills your ears, and a wave of dread washes over you...</span>"
	qdel(src)
	return(gain)

/obj/machinery/power/supermatter_shard/blob_act(obj/structure/blob/B)
	if(B && !isspaceturf(loc)) //does nothing in space
		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, 1)
		damage += B.obj_integrity * 0.5 //take damage equal to 50% of remaining blob health before it tried to eat us
		if(B.obj_integrity > 100)
			B.visible_message("<span class='danger'>\The [B] strikes at \the [src] and flinches away!</span>",\
			"<span class='italics'>You hear a loud crack as you are washed with a wave of heat.</span>")
			B.take_damage(100, BURN)
		else
			B.visible_message("<span class='danger'>\The [B] strikes at \the [src] and rapidly flashes to ash.</span>",\
			"<span class='italics'>You hear a loud crack as you are washed with a wave of heat.</span>")
			Consume(B)

/obj/machinery/power/supermatter_shard/attack_paw(mob/user)
	return attack_hand(user)


/obj/machinery/power/supermatter_shard/attack_robot(mob/user)
	if(Adjacent(user))
		return attack_hand(user)
	else
		user << "<span class='warning'>You attempt to interface with the control circuits but find they are not connected to your network. Maybe in a future firmware update.</span>"

/obj/machinery/power/supermatter_shard/attack_ai(mob/user)
	user << "<span class='warning'>You attempt to interface with the control circuits but find they are not connected to your network. Maybe in a future firmware update.</span>"

/obj/machinery/power/supermatter_shard/attack_hand(mob/living/user)
	if(!istype(user))
		return
	user.visible_message("<span class='danger'>\The [user] reaches out and touches \the [src], inducing a resonance... [user.p_their()] body starts to glow and bursts into flames before flashing into ash.</span>",\
		"<span class='userdanger'>You reach out and touch \the [src]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"</span>",\
		"<span class='italics'>You hear an unearthly noise as a wave of heat washes over you.</span>")

	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, 1)

	Consume(user)

/obj/machinery/power/supermatter_shard/proc/transfer_energy()
	for(var/obj/machinery/power/rad_collector/R in rad_collectors)
		if(R.z == z && get_dist(R, src) <= 15) //Better than using orange() every process
			R.receive_pulse(power/10)

/obj/machinery/power/supermatter_shard/attackby(obj/item/W, mob/living/user, params)
	if(!istype(W) || (W.flags & ABSTRACT) || !istype(user))
		return
	if(user.drop_item(W))
		Consume(W)
		user.visible_message("<span class='danger'>As [user] touches \the [src] with \a [W], silence fills the room...</span>",\
			"<span class='userdanger'>You touch \the [src] with \the [W], and everything suddenly goes silent.</span>\n<span class='notice'>\The [W] flashes into dust as you flinch away from \the [src].</span>",\
			"<span class='italics'>Everything suddenly goes silent.</span>")

		playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, 1)

		radiation_pulse(get_turf(src), 1, 1, 150, 1)


/obj/machinery/power/supermatter_shard/Bumped(atom/AM)
	if(isliving(AM))
		AM.visible_message("<span class='danger'>\The [AM] slams into \the [src] inducing a resonance... [AM.p_their()] body starts to glow and catch flame before flashing into ash.</span>",\
		"<span class='userdanger'>You slam into \the [src] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\"</span>",\
		"<span class='italics'>You hear an unearthly noise as a wave of heat washes over you.</span>")
	else if(isobj(AM) && !istype(AM, /obj/effect))
		AM.visible_message("<span class='danger'>\The [AM] smacks into \the [src] and rapidly flashes to ash.</span>", null,\
		"<span class='italics'>You hear a loud crack as you are washed with a wave of heat.</span>")
	else
		return

	playsound(get_turf(src), 'sound/effects/supermatter.ogg', 50, 1)

	Consume(AM)


/obj/machinery/power/supermatter_shard/proc/Consume(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/user = AM
		message_admins("[src] has consumed [key_name_admin(user)]<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A> (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</A>) <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>(JMP)</a>.")
		investigate_log("has consumed [key_name(user)].", "supermatter")
		user.dust()
		power += 200
	else if(isobj(AM) && !istype(AM, /obj/effect))
		investigate_log("has consumed [AM].", "supermatter")
		qdel(AM)

	power += 200

	//Some poor sod got eaten, go ahead and irradiate people nearby.
	radiation_pulse(get_turf(src), 4, 10, 500, 1)
	for(var/mob/living/L in range(10))
		investigate_log("has irradiated [L] after consuming [AM].", "supermatter")
		if(L in view())
			L.show_message("<span class='danger'>As \the [src] slowly stops resonating, you find your skin covered in new radiation burns.</span>", 1,\
				"<span class='danger'>The unearthly ringing subsides and you notice you have new radiation burns.</span>", 2)
		else
			L.show_message("<span class='italics'>You hear an uneartly ringing and notice your skin is covered in fresh radiation burns.</span>", 2)

// When you wanna make a supermatter shard for the dramatic effect, but
// don't want it exploding suddenly
/obj/machinery/power/supermatter_shard/hugbox
	takes_damage = 0
	produces_gas = 0
