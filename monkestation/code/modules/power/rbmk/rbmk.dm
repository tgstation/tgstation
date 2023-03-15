//For my sanity :))

#define COOLANT_INPUT_GATE airs[1]
#define MODERATOR_INPUT_GATE airs[2]
#define COOLANT_OUTPUT_GATE airs[3]

#define RBMK_TEMPERATURE_OPERATING 600 //Celsius	//Default: 640
//At this point the entire ship is alerted to a meltdown. This may need altering
#define RBMK_TEMPERATURE_CRITICAL 950 //Celsius		//Default: 800
#define RBMK_TEMPERATURE_MELTDOWN 1000 //Celsius		//Default: 900

//How many process()ing ticks the reactor can sustain without coolant before slowly taking damage
#define RBMK_NO_COOLANT_TOLERANCE 5	//Default: 5

#define RBMK_PRESSURE_OPERATING 2000 //kPa		//Default: 1000 PSI //No more PSI
#define RBMK_PRESSURE_CRITICAL 10000 //kPa	//Default: 1469.59 PSI

//No more criticality than N for now.
#define RBMK_MAX_CRITICALITY 3		//Default: 3

//To turn those KWs into something usable
#define RBMK_POWER_FLAVOURISER 10		//Default: 8000 //I want some use out of turbines for power

//Reference: Heaters go up to 500K.
//Hot plasmaburn: 14164.95 C.

/**
What is this?
Moderator Inputs:
	Fuel Type:
	Oxygen: Power production multiplier. Allows you to run a low plasma, high oxy mix, and still get a lot of power.
	Plasma: Power production gas. More plasma -> more power, but it enriches your fuel and makes the reactor much, much harder to control.
	Tritium: Extremely efficient power production gas. Will cause chernobyl if used improperly.

	Moderation Type:
	N2: Helps you regain control of the reaction by increasing control rod effectiveness, will massively boost the rad production of the reactor.
	CO2: Super effective shutdown gas for runaway reactions. MASSIVE RADIATION PENALTY!
	Pluoxium: Same as N2, but no cancer-rads!

	Permeability Type (Coolant loop speed):
	BZ: Increases your reactor's ability to transfer its heat to the coolant, thus letting you cool it down faster (but your output will get hotter)
	Water Vapour: More efficient permeability modifier
	Hyper Noblium: Extremely efficient permeability increase. (10x as efficient as bz)

	Depletion type:
	Nitryl: When you need weapons grade plutonium yesterday. Causes your fuel to deplete much, much faster. Not a huge amount of use outside of sabotage.

Sabotage:
	Meltdown:
	Flood reactor moderator with plasma, they won't be able to mitigate the reaction with control rods.
	Shut off coolant entirely. Raise control rods.
	Swap all fuel out with spent fuel, as it's way stronger.

	Blowout:
	Shut off exit valve for quick overpressure.
	Cause a pipefire in the coolant line (LETHAL).
	Tack heater onto coolant line (can also cause straight meltdown)

Tips:
Be careful to not exhaust your plasma supply. I recommend you DON'T max out the moderator input when youre running plasma + o2, or you're at a tangible risk of running out of those gasses from atmos.
The reactor CHEWS through moderator. It does not do this slowly. Be very careful with that!

//Remember kids. If the reactor itself is not physically powered by an APC, it cannot shove coolant in!

*/

/obj/machinery/atmospherics/components/trinary/nuclear_reactor
	name = "Advanced Gas-Cooled Nuclear Reactor"
	desc = "A tried and tested design which can output stable power at an acceptably low risk. The moderator can be changed to provide different effects."
	icon = 'monkestation/icons/obj/machinery/rbmk.dmi'
	icon_state = "reactor_map"
	pixel_x = -32
	pixel_y = -32
	processing_flags = START_PROCESSING_MANUALLY
	density = FALSE //It burns you if you're stupid enough to walk over it.
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	light_color = LIGHT_COLOR_CYAN
	dir = 8 //Less headache inducing :))
	var/id = null //Change me mappers

	// Variables essential to operation
	/// Lose control of this -> Meltdown
	var/temperature = 0
	/// How long can the reactor withstand overpressure / meltdown? This gives you a fair chance to react to even a massive pipe fire
	var/vessel_integrity = 400
	/// Lose control of this -> Blowout
	var/pressure = 0
	/// Rate of reaction.
	var/K = 0
	/// Control rod desired_k
	var/desired_k = 0
	/// Starts off with a lot of control over K. If you flood this thing with plasma, you lose your ability to control K as easily.
	var/control_rod_effectiveness = 0.65
	/// 0-100%. A function of the maximum heat you can achieve within operating temperature
	var/power = 0
	/// Used for moderator gasses power modifications
	var/power_modifier = 1
	//Amount of Fuels_rods in reactor
	var/list/fuel_rods = list()

	// Secondary variables.
	/// Used for slowing gas processing in process
	var/next_slowprocess = 0
	/// Default gas_absorption before being randomized slightly
	var/gas_absorption_effectiveness = 0.5
	/// We refer to this one as it's set on init, randomized.
	var/gas_absorption_constant = 0.5
	/// The minimum coolant level
	var/minimum_coolant_level = 5
	/// Have we begun warning the crew of their impending death?
	var/warning = FALSE
	/// To avoid spam.
	var/next_warning = 0
	/// For logging purposes
	var/last_power_produced = 0
	/// Light flicker timer
	var/next_flicker = 0
	/// Define connection to determine power produced directly from the reactor
	var/base_power_modifier = RBMK_POWER_FLAVOURISER
	/// Slag that reactor. Is this reactor even usable any more?
	var/slagged = FALSE

	//Console statistics.
	var/last_coolant_temperature = 0
	var/last_output_temperature = 0
	//For administrative cheating only. Knowing the delta lets you know EXACTLY what to set K at.
	var/last_heat_delta = 0

	//How many times in succession did we not have enough coolant? Decays twice as fast as it accumulates.
	var/no_coolant_ticks = 0

	var/last_user = null
	var/current_desired_k = null

	var/lastwarning = 0
	var/obj/item/radio/radio
	var/radio_key = /obj/item/encryptionkey/headset_eng
	var/engineering_channel = "Engineering"
	var/common_channel = null

	var/datum/looping_sound/rbmk_reactor/soundloop

	///Spawn state of if sludge spawners have been spawned
	var/sludge_spawned = FALSE

//Use this in your maps if you want everything to be preset.
/obj/machinery/atmospherics/components/trinary/nuclear_reactor/preset
	id = "default_reactor_for_lazy_mappers"

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/destroyed
	icon_state = "reactor_slagged"
	slagged = TRUE
	vessel_integrity = 0
	color = null
	radio = null
	radio_key = null

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/examine(mob/user)
	. = ..()
	if(Adjacent(src, user))
		if(do_after(user, 1 SECONDS, target=src))
			var/percent = vessel_integrity / initial(vessel_integrity) * 100
			var/msg = "<span class='warning'>The reactor looks operational.</span>"
			switch(percent)
				if(0 to 10)
					msg = "<span class='boldwarning'>[src]'s seals are dangerously warped and you can see cracks all over the reactor vessel! </span>"
				if(10 to 40)
					msg = "<span class='boldwarning'>[src]'s seals are heavily warped and cracked! </span>"
				if(40 to 60)
					msg = "<span class='warning'>[src]'s seals are holding, but barely. You can see some micro-fractures forming in the reactor vessel.</span>"
				if(60 to 80)
					msg = "<span class='warning'>[src]'s seals are in-tact, but slightly worn. There are no visible cracks in the reactor vessel.</span>"
				if(80 to 90)
					msg = "<span class='notice'>[src]'s seals are in good shape, and there are no visible cracks in the reactor vessel.</span>"
				if(95 to 100)
					msg = "<span class='notice'>[src]'s seals look factory new, and the reactor's in excellent shape.</span>"
			. += msg

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/attackby(obj/item/obj_item, mob/user, params)
	update_icon()
	if(istype(obj_item, /obj/item/fuel_rod))
		if(power >= 20)
			to_chat(user, "<span class='notice'>You cannot insert fuel into [src] when it has been raised above 20% power.</span>")
			return FALSE
		if(fuel_rods.len >= 5)
			to_chat(user, "<span class='warning'>[src] is already at maximum fuel load.</span>")
			return FALSE
		to_chat(user, "<span class='notice'>You start to insert [obj_item] into [src]...</span>")
		radiation_pulse(src, temperature)
		if(do_after(user, 5 SECONDS, target=src))
			if(!fuel_rods.len)
				start_up() //That was the first fuel rod. Let's heat it up.
				message_admins("Reactor first started up by [ADMIN_LOOKUPFLW(user)] in [ADMIN_VERBOSEJMP(src)]")
				investigate_log("Reactor first started by [key_name(user)] at [AREACOORD(src)]", INVESTIGATE_ENGINES)
			fuel_rods += obj_item
			obj_item.forceMove(src)
			radiation_pulse(src, temperature) //Wear protective equipment when even breathing near a reactor!
			investigate_log("Rod added to reactor by [key_name(user)] at [AREACOORD(src)]", INVESTIGATE_ENGINES)
		return TRUE
	if(!slagged && istype(obj_item, /obj/item/sealant))
		if(power >= 20)
			to_chat(user, "<span class='notice'>You cannot repair [src] while it is running at above 20% power.</span>")
			return FALSE
		if(vessel_integrity >= 350)
			to_chat(user, "<span class='notice'>[src]'s seals are already in-tact, repairing them further would require a new set of seals.</span>")
			return FALSE
		if(vessel_integrity <= 0.5 * initial(vessel_integrity)) //Heavily damaged.
			to_chat(user, "<span class='notice'>[src]'s reactor vessel is cracked and worn, you need to repair the cracks with a welder before you can repair the seals.</span>")
			return FALSE
		if(do_after(user, 5 SECONDS, target=src))
			if(vessel_integrity >= 350)	//They might've stacked doafters
				to_chat(user, "<span class='notice'>[src]'s seals are already in-tact, repairing them further would require a new set of seals.</span>")
				return FALSE
			playsound(src, 'sound/effects/spray2.ogg', 50, 1, -6)
			user.visible_message("<span class='warning'>[user] applies sealant to some of [src]'s worn out seals.</span>", "<span class='notice'>You apply sealant to some of [src]'s worn out seals.</span>")
			vessel_integrity += 10
			vessel_integrity = CLAMP(vessel_integrity, 0, initial(vessel_integrity))
		return TRUE
	return ..()

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/welder_act(mob/living/user, obj/item/item_tool)
	update_icon()
	if(slagged)
		to_chat(user, "<span class='notice'>You can't repair [src], it's completely slagged!</span>")
		return FALSE
	if(power >= 20)
		to_chat(user, "<span class='notice'>You can't repair [src] while it is running at above 20% power.</span>")
		return FALSE
	if(vessel_integrity > 0.5 * initial(vessel_integrity))
		to_chat(user, "<span class='notice'>[src] is free from cracks. Further repairs must be carried out with flexi-seal sealant.</span>")
		return FALSE
	if(item_tool.use_tool(src, user, 0, volume=40))
		if(vessel_integrity > 0.5 * initial(vessel_integrity))
			to_chat(user, "<span class='notice'>[src] is free from cracks. Further repairs must be carried out with flexi-seal sealant.</span>")
			return FALSE
		vessel_integrity += 20
		to_chat(user, "<span class='notice'>You weld together some of [src]'s cracks. This'll do for now.</span>")
	return TRUE

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/Initialize(mapload)
	. = ..()
	icon_state = "reactor_off"
	gas_absorption_effectiveness = rand(5, 6)/10 //All reactors are slightly different. This will result in you having to figure out what the balance is for K.
	gas_absorption_constant = gas_absorption_effectiveness //And set this up for the rest of the round.
	STOP_PROCESSING(SSmachines, src) //We'll handle this one ourselves.

	radio = new(src)
	radio.keyslot = new radio_key
	radio.listening = 0
	radio.recalculateChannels()

	investigate_log("has been created.", INVESTIGATE_ENGINES)
	soundloop = new(list(src), FALSE)

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/process()
	update_parents() //Update the pipenet to register new gas mixes
	if(next_slowprocess < world.time)
		slowprocess()
		//Set to wait for another second before processing again, we don't need to process more than once a second
		next_slowprocess = world.time + 0.3 SECONDS

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/has_fuel()
	return fuel_rods?.len

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/slowprocess()
	if(slagged)
		STOP_PROCESSING(SSmachines, src)
		return

	//Reactor hum soundloop
	if(power)
		soundloop.volume = CLAMP(power, 1, 30)

	//Let's get our gasses sorted out.
	var/datum/gas_mixture/coolant_input = COOLANT_INPUT_GATE
	var/datum/gas_mixture/moderator_input = MODERATOR_INPUT_GATE
	var/datum/gas_mixture/coolant_output = COOLANT_OUTPUT_GATE

	//Firstly, heat up the reactor based off of K.
	var/input_moles = coolant_input.total_moles() //Firstly. Do we have enough moles of coolant?
	if(input_moles >= minimum_coolant_level)
		last_coolant_temperature = KELVIN_TO_CELSIUS(coolant_input.return_temperature())
		//Important thing to remember, once you slot in the fuel rods, this thing will not stop making heat, at least, not unless you can live to be thousands of years old which is when the spent fuel finally depletes fully.
		//Take in the gas as a cooled input, cool the reactor a bit.
		//The optimum, 100% balanced reaction sits at K=1, coolant input temp of 200K / -73 celsius.
		var/heat_delta = (KELVIN_TO_CELSIUS(coolant_input.return_temperature()) / 100) * gas_absorption_effectiveness
		last_heat_delta = heat_delta
		temperature += heat_delta
		coolant_output.merge(coolant_input) //And now, shove the input into the output.
		coolant_input.clear() //Clear out anything left in the input gate.
		color = null
		no_coolant_ticks = max(0, no_coolant_ticks-2)	//Needs half as much time to recover the ticks than to acquire them
	else
		if(has_fuel())
			no_coolant_ticks++
			if(no_coolant_ticks > RBMK_NO_COOLANT_TOLERANCE)
				temperature += temperature / 250//This isn't really harmful early game, but when your reactor is up to full power, this can get out of hand quite quickly.
				vessel_integrity -= temperature / 400 //Think fast loser.
				take_damage(10) //Just for the sound effect, to let you know you've fucked up.
				color = COLOR_RED
				investigate_log("Reactor taking damage from the lack of coolant", INVESTIGATE_ENGINES)
	//Now, heat up the output and set our pressure.
	coolant_output.set_temperature(CELSIUS_TO_KELVIN(temperature)) //Heat the coolant output gas that we just had pass through us.
	last_output_temperature = KELVIN_TO_CELSIUS(coolant_output.return_temperature())
	pressure = coolant_output.return_pressure()
	power = clamp(((temperature / RBMK_TEMPERATURE_CRITICAL) * 110), 0, 1000)
	var/radioactivity_spice_multiplier = 1 //Some gasses make the reactor a bit spicy.
	var/depletion_modifier = 0.035 //How rapidly do your rods decay
	gas_absorption_effectiveness = gas_absorption_constant
	//Next up, handle moderators!
	if(moderator_input.total_moles() >= minimum_coolant_level)

		var/total_fuel_moles = moderator_input.get_moles(GAS_PLASMA) + (moderator_input.get_moles(GAS_TRITIUM)*10)
		var/power_modifier = max((moderator_input.get_moles(GAS_O2) / moderator_input.total_moles() * 10), 1) //You can never have negative IPM. For now.
		if(total_fuel_moles >= minimum_coolant_level) //You at least need SOME fuel.
			var/power_produced = max((total_fuel_moles / moderator_input.total_moles() * 50), 1)
			last_power_produced = max(0,((power_produced*power_modifier)*moderator_input.total_moles()))
			last_power_produced *= (power/100) //Aaaand here comes the cap. Hotter reactor => more power.
			last_power_produced *= base_power_modifier //Finally, we turn it into actual usable numbers.
			radioactivity_spice_multiplier += moderator_input.get_moles(GAS_TRITIUM) / 5 //Chernobyl 2.
			var/turf/reactor_turf = get_turf(src)
			if(power >= 5)
				var/nucleium_output = clamp((110 - power), 5, 100) //Increases Waste ouput which helps tell the turbines to be more efficient
				coolant_output.adjust_moles(GAS_NITRYL, total_fuel_moles/100) //Shove out nitryl into the air when it's fuelled. You need to filter this off, or you're gonna have a bad time.
				coolant_output.adjust_moles(GAS_NUCLEIUM, total_fuel_moles/nucleium_output) //Shove out nucleium into the air when it's fuelled. You need to filter this off, or you're gonna have a bad time.

			var/obj/structure/cable/cable_node = reactor_turf.get_cable_node()
			if(!cable_node?.powernet)
				return
			else
				cable_node.powernet.newavail += last_power_produced

		var/total_control_moles = moderator_input.get_moles(GAS_N2) + (moderator_input.get_moles(GAS_CO2)*2) + (moderator_input.get_moles(GAS_PLUOXIUM)*3) //N2 helps you control the reaction at the cost of making it absolutely blast you with rads. Pluoxium has the same effect but without the rads!
		if(total_control_moles >= minimum_coolant_level)
			var/control_bonus = total_control_moles / 250 //1 mol of n2 -> 0.002 bonus control rod effectiveness, if you want a super controlled reaction, you'll have to sacrifice some power.
			control_rod_effectiveness = initial(control_rod_effectiveness) + control_bonus
			radioactivity_spice_multiplier += moderator_input.get_moles(GAS_N2) / 25 //An example setup of 50 moles of n2 (for dealing with spent fuel) leaves us with a radioactivity spice multiplier of 3.
			radioactivity_spice_multiplier += moderator_input.get_moles(GAS_CO2) / 12.5

		var/total_permeability_moles = moderator_input.get_moles(GAS_BZ) + (moderator_input.get_moles(GAS_H2O)*2) + (moderator_input.get_moles(GAS_HYPERNOB)*10)
		if(total_permeability_moles >= minimum_coolant_level)
			var/permeability_bonus = total_permeability_moles / 500
			gas_absorption_effectiveness = gas_absorption_constant + permeability_bonus

		var/total_degradation_moles = moderator_input.get_moles(GAS_NITRYL) //Because it's quite hard to get.
		if(total_degradation_moles >= minimum_coolant_level*0.5) //I'll be nice.
			depletion_modifier += total_degradation_moles / 15 //Oops! All depletion. This causes your fuel rods to get SPICY.
			playsound(src, pick('sound/machines/sm/accent/normal/1.ogg','sound/machines/sm/accent/normal/2.ogg','sound/machines/sm/accent/normal/3.ogg','sound/machines/sm/accent/normal/4.ogg','sound/machines/sm/accent/normal/5.ogg'), 100, TRUE)

		//From this point onwards, we clear out the remaining gasses.
		moderator_input.clear() //Woosh. And the soul is gone.
		K += total_fuel_moles / 1000

	var/fuel_power = 0 //So that you can't magically generate K with your control rods.
	if(!has_fuel())  //Reactor must be fuelled and ready to go before we can heat it up boys.
		K = 0
	else
		for(var/obj/item/fuel_rod/fuel_rod in fuel_rods)
			K += fuel_rod.fuel_power
			fuel_power += fuel_rod.fuel_power
			fuel_rod.deplete(depletion_modifier)
	//Firstly, find the difference between the two numbers.
	var/difference = abs(K - desired_k)
	//Then, hit as much of that goal with our cooling per tick as we possibly can.
	difference = CLAMP(difference, 0, control_rod_effectiveness) //And we can't instantly zap the K to what we want, so let's zap as much of it as we can manage....
	if(difference > fuel_power && desired_k > K)
		investigate_log("Reactor has not enough fuel to get [difference]. We have fuel [fuel_power]", INVESTIGATE_ENGINES)
		difference = fuel_power //Again, to stop you being able to run off of 1 fuel rod.
	if(K != desired_k)
		if(desired_k > K)
			K += difference
		else if(desired_k < K)
			K -= difference
	if(K == desired_k && last_user && current_desired_k != desired_k)
		current_desired_k = desired_k
		message_admins("Reactor desired criticality set to [desired_k] by [ADMIN_LOOKUPFLW(last_user)] in [ADMIN_VERBOSEJMP(src)]")
		investigate_log("reactor desired criticality set to [desired_k] by [key_name(last_user)] at [AREACOORD(src)]", INVESTIGATE_ENGINES)

	K = CLAMP(K, 0, RBMK_MAX_CRITICALITY)
	if(has_fuel())
		temperature += K
	else
		temperature -= 10 //Nothing to heat us up, so.
	handle_alerts() //Let's check if they're about to die, and let them know.
	radio_alerts() //New Radio Alert proc since handle_alerts is getting big
	update_icon()
	//Radiation Pulse Range Increase to 3 //Monkestation Edit
	radiation_pulse(src, (temperature*radioactivity_spice_multiplier), 3)
	//You're overloading the reactor. Give a more subtle warning that power is getting out of control.
	if(power >= 90 && world.time >= next_flicker)
		next_flicker = world.time + 1.5 MINUTES
		for(var/obj/machinery/light/lights in GLOB.machines)
		//If youre running the reactor cold though, no need to flicker the lights.
			if(prob(25) && lights.z == z)
				lights.flicker()
		investigate_log("Reactor overloading at [power]% power", INVESTIGATE_ENGINES)
	for(var/atom/movable/atom_on_reactor in get_turf(src))
		if(isliving(atom_on_reactor))
			var/mob/living/living_mob = atom_on_reactor
			var/temp_diff = CELSIUS_TO_KELVIN(temperature) - living_mob.bodytemperature
			if(temp_diff <= 0)
				continue
			living_mob.adjust_bodytemperature(CLAMP(temp_diff / 2, 1, BODYTEMP_HEATING_MAX)) //If you're on fire, you heat up!
		if(istype(atom_on_reactor, /obj/item/reagent_containers/food) && !istype(atom_on_reactor, /obj/item/reagent_containers/food/drinks))
			playsound(src, pick('sound/machines/fryer/deep_fryer_1.ogg', 'sound/machines/fryer/deep_fryer_2.ogg'), 100, TRUE)
			var/obj/item/reagent_containers/food/grilled_item = atom_on_reactor
			if(prob(80))
				return //To give the illusion that it's actually cooking omegalul.
			switch(power)
				if(20 to 39)
					grilled_item.name = "grilled [initial(grilled_item.name)]"
					grilled_item.desc = "[initial(atom_on_reactor.desc)] It's been grilled over a nuclear reactor."
					if(!(grilled_item.foodtype & FRIED))
						grilled_item.foodtype |= FRIED
				if(40 to 70)
					grilled_item.name = "heavily grilled [initial(grilled_item.name)]"
					grilled_item.desc = "[initial(atom_on_reactor.desc)] It's been heavily grilled through the magic of nuclear fission."
					if(!(grilled_item.foodtype & FRIED))
						grilled_item.foodtype |= FRIED
				if(70 to 95)
					grilled_item.name = "Three-Mile Nuclear-Grilled [initial(grilled_item.name)]"
					grilled_item.desc = "A [initial(grilled_item.name)]. It's been put on top of a nuclear reactor running at extreme power by some badass engineer."
					if(!(grilled_item.foodtype & FRIED))
						grilled_item.foodtype |= FRIED
				if(95 to INFINITY)
					grilled_item.name = "Ultimate Meltdown Grilled [initial(grilled_item.name)]"
					grilled_item.desc = "A [initial(grilled_item.name)]. A grill this perfect is a rare technique only known by a few engineers who know how to perform a 'controlled' meltdown whilst also having the time to throw food on a reactor. I'll bet it tastes amazing."
					if(!(grilled_item.foodtype & FRIED))
						grilled_item.foodtype |= FRIED

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/relay(var/sound, var/message=null, loop = FALSE, channel = null) //Sends a sound + text message to the crew of a ship
	for(var/mob/mobs in GLOB.player_list)
		if(mobs.z == z)
			var/area/A = get_area(mobs)
			if(A != subtypesof(/area/space))
				if(sound)
					if(channel) //Doing this forbids overlapping of sounds
						SEND_SOUND(mobs, sound(sound, repeat = loop, wait = 0, volume = 100, channel = channel))
					else
						SEND_SOUND(mobs, sound(sound, repeat = loop, wait = 0, volume = 100))
				if(message)
					to_chat(mobs, message)

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/stop_relay(channel) //Stops all playing sounds for crewmen on N channel.
	for(var/mob/mobs in GLOB.player_list)
		if(mobs.z == z)
			mobs.stop_sound_channel(channel)

// Method for alerting the station on the radio
/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/radio_alerts()
	if((REALTIMEOFDAY - lastwarning) / 6 >= WARNING_DELAY)

		if(temperature >= RBMK_TEMPERATURE_CRITICAL)
			radio.talk_into(src, "Reactor Temperature Critical at [temperature] C.", engineering_channel)
			lastwarning = REALTIMEOFDAY - (WARNING_DELAY)
			if(vessel_integrity <= 200)
				radio.talk_into(src, "REACTOR MELTDOWN IMMINENT at [temperature] C. Please seek your nearest radiation lockers for protection.", common_channel)
				lastwarning = REALTIMEOFDAY - (WARNING_DELAY)

		if(pressure >= RBMK_PRESSURE_CRITICAL)
			radio.talk_into(src, "Reactor Pressure Critical at [pressure] kPa.", engineering_channel)
			lastwarning = REALTIMEOFDAY - (WARNING_DELAY)
			if(vessel_integrity <= 200)
				radio.talk_into(src, "Reactor Pressure Critical at [pressure] kPa. PRESSURE BLOWOUT IMMINENT. Please seek shelter and your nearest radiation lockers for protection.", common_channel)
				lastwarning = REALTIMEOFDAY - (WARNING_DELAY)

//Method to handle sound effects, reactor warnings, all that jazz.
/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/handle_alerts()
	var/alert = FALSE //If we have an alert condition, we'd best let people know.
	if(K <= 0 && temperature <= 0)
		shut_down()
	//First alert condition: Overheat
	if(temperature >= RBMK_TEMPERATURE_CRITICAL)
		alert = TRUE
		if(temperature >= RBMK_TEMPERATURE_MELTDOWN)
			light_color = LIGHT_COLOR_BLOOD_MAGIC
			vessel_integrity -= (temperature / 100)
			if(vessel_integrity <= temperature / 100) //It wouldn't be able to tank another hit.
				investigate_log("Reactor melted down at [temperature] C with desired criticality at [desired_k]", INVESTIGATE_ENGINES)
				meltdown() //Oops! All meltdown
				return
	else
		alert = FALSE
	if(temperature < -200) //That's as cold as I'm letting you get it, engineering.
		color = COLOR_CYAN
		temperature = -200
	else
		color = null
	//Second alert condition: Overpressurized (the more lethal one)
	if(pressure >= RBMK_PRESSURE_CRITICAL)
		alert = TRUE
		shake_animation(0.5)
		playsound(loc, 'sound/machines/clockcult/steam_whoosh.ogg', 100, TRUE)
		var/turf/reactor_turf = get_turf(src)
		reactor_turf.atmos_spawn_air("water_vapor=[pressure/100];TEMP=[CELSIUS_TO_KELVIN(temperature)]")
		var/pressure_damage = min(pressure/100, initial(vessel_integrity)/60)	//You get 60 seconds (if you had full integrity), worst-case. But hey, at least it can't be instantly nuked with a pipe-fire.. though it's still very difficult to save.
		vessel_integrity -= pressure_damage
		if(vessel_integrity <= pressure_damage) //It wouldn't
			investigate_log("Reactor blowout at [pressure] kPa with desired criticality at [desired_k]", INVESTIGATE_ENGINES)
			blowout()
			return
	if(warning)
		if(!alert) //Congrats! You stopped the meltdown / blowout.
			stop_relay(CHANNEL_ENGINE_ALERT)
			warning = FALSE
			set_light(0)
			light_color = LIGHT_COLOR_CYAN
			set_light(10)
			investigate_log("Reactor stabilizing at [pressure] kPa and [temperature] C.", INVESTIGATE_ENGINES)
			message_admins("Reactor stabilizing at [pressure] kPa and [temperature] C. [ADMIN_VERBOSEJMP(src)]")
			radio.talk_into(src, "REACTOR STABILIZED at [pressure] kPa and [temperature] C." , common_channel)
	else
		if(!alert)
			return
		if(world.time < next_warning)
			return
		next_warning = world.time + 30 SECONDS //To avoid engis pissing people off when reaaaally trying to stop the meltdown or whatever.
		warning = TRUE //Start warning the crew of the imminent danger.
		relay('monkestation/sound/effects/rbmk/alarm.ogg', null, loop = TRUE, channel = CHANNEL_ENGINE_ALERT)
		set_light(0)
		light_color = LIGHT_COLOR_BLOOD_MAGIC
		set_light(10)

//Failure condition 1: Meltdown. Achieved by having heat go over tolerances. This is less devastating because it's easier to achieve.
//Results: Engineering becomes unusable and your engine irreparable
/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/meltdown()
	set waitfor = FALSE
	SSair.stop_processing_machine(src) //Annd we're now just a useless brick.
	slagged = TRUE
	update_icon()
	STOP_PROCESSING(SSmachines, src)
	icon_state = "reactor_slagged"
	AddComponent(/datum/component/radioactive, (temperature*15), src)
	relay('monkestation/sound/effects/rbmk/meltdown.ogg', "<span class='userdanger'>You hear a horrible metallic hissing.</span>")
	stop_relay(CHANNEL_ENGINE_ALERT)
	for(var/obj/machinery/power/apc/apc in GLOB.apcs_list)
		if(prob(70))
			apc.overload_lighting()
	var/datum/gas_mixture/coolant_input = COOLANT_INPUT_GATE
	var/datum/gas_mixture/moderator_input = MODERATOR_INPUT_GATE
	var/datum/gas_mixture/coolant_output = COOLANT_OUTPUT_GATE
	var/turf/reactor_turf = get_turf(src)
	coolant_input.set_temperature(CELSIUS_TO_KELVIN(temperature)*2)
	moderator_input.set_temperature(CELSIUS_TO_KELVIN(temperature)*2)
	coolant_output.set_temperature(CELSIUS_TO_KELVIN(temperature)*2)
	reactor_turf.assume_air(coolant_input)
	reactor_turf.assume_air(moderator_input)
	reactor_turf.assume_air(coolant_output)
	QDEL_NULL(soundloop)
	//Default explosion was: explosion(get_turf(src), 0, 5, 10, 20, TRUE, TRUE)
	explosion(get_turf(src), 0, 0, 10, 15, TRUE, TRUE, 0, FALSE, 4)
	///Added scaling calculations for pulses so you have to put effort with meltdown severity
	///Power goes from 0 to 100
	radiation_pulse(get_turf(src), (500+(power*60)), (10+(power)), TRUE) //BIG flash of rads
	empulse(get_turf(src), (10+(power/5)), (5+(power/5)), TRUE)
	var/obj/effect/landmark/nuclear_waste_spawner/nuclear_waste_spawner = new /obj/effect/landmark/nuclear_waste_spawner/strong(get_turf(src))
	nuclear_waste_spawner.fire() //This will take out engineering for a decent amount of time as they have to clean up the sludge.

//Failure condition 2: Blowout. Achieved by reactor going over-pressured. This is a round-ender because it requires more fuckery to achieve.
/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/blowout()
	//Default explosion was: explosion(get_turf(src), 0, MAX_EX_HEAVY_RANGE, GLOB.MAX_EX_LIGHT_RANGE, GLOB.MAX_EX_FLASH_RANGE)
	explosion(get_turf(src), 0, 4, GLOB.MAX_EX_LIGHT_RANGE, GLOB.MAX_EX_FLASH_RANGE)
	meltdown() //Double kill.
	relay('monkestation/sound/effects/rbmk/explode.ogg')
	priority_announce("High levels of radiation detected. Maintenance is best shielded from radiation.", "Nuclear Blowout Alert", ANNOUNCER_RADIATION)

	sleep(50)
	SSweather.run_weather("nuclear fallout") //Maybe replace with a radioactive gas spawn from the sludge spawners if weather is too weird
	sludge_spawner_preload()

	sleep(60)
	for(var/landmark in GLOB.landmarks_list)
		if(istype(landmark, /obj/effect/landmark/nuclear_waste_spawner))
			var/obj/effect/landmark/nuclear_waste_spawner/waste_spawner = landmark
			if(is_station_level(waste_spawner.z)) //Begin the SLUDGING
				waste_spawner.fire()

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/update_icon()
	icon_state = "reactor_off"
	switch(temperature)
		if(0 to 100)
			icon_state = "reactor_on"
		if(100 to RBMK_TEMPERATURE_OPERATING)
			icon_state = "reactor_hot"
		if(RBMK_TEMPERATURE_OPERATING to 800)
			icon_state = "reactor_veryhot"
		if(800 to RBMK_TEMPERATURE_CRITICAL) //Point of no return.
			icon_state = "reactor_overheat"
		if(RBMK_TEMPERATURE_CRITICAL to INFINITY)
			icon_state = "reactor_meltdown"

	var/percent = vessel_integrity / initial(vessel_integrity) * 100
	switch(percent)
		if(0 to 10)
			cut_overlay()
			add_overlay("reactor_damaged_4")
		if(10 to 40)
			cut_overlay()
			add_overlay("reactor_damaged_3")
		if(40 to 60)
			cut_overlay()
			add_overlay("reactor_damaged_2")
		if(60 to 80)
			cut_overlay()
			add_overlay("reactor_damaged_1")
		if(80 to 90)
			cut_overlay()
		if(95 to 100)
			cut_overlay()
	if(!has_fuel())
		icon_state = "reactor_off"
	if(slagged)
		icon_state = "reactor_slagged"

//Startup, shutdown
/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/start_up()
	if(slagged)
		return // No :)
	SSair.start_processing_machine(src)
	START_PROCESSING(SSmachines, src)
	desired_k = 1
	set_light(10)
	var/startup_sound = pick('monkestation/sound/effects/rbmk/startup.ogg', 'monkestation/sound/effects/rbmk/startup2.ogg')
	playsound(loc, startup_sound, 80)
	soundloop = new(list(src), TRUE)

//Shuts off the fuel rods, ambience, etc. Keep in mind that your temperature may still go up!
/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/shut_down()
	STOP_PROCESSING(SSmachines, src)
	SSair.stop_processing_machine(src)
	stop_relay(CHANNEL_ENGINE_ALERT)

	investigate_log("Reactor shutdown at [pressure] kPa and [temperature] C.", INVESTIGATE_ENGINES)
	message_admins("Reactor shutdown at [pressure] kPa and [temperature] C. [ADMIN_VERBOSEJMP(src)]")
	radio.talk_into(src, "REACTOR SHUTDOWN INITIATED at [pressure] kPa and [temperature] C. Venting remaining gasses and stablizating reactions. Please eject fuel rods and make any necessary repairs before restarting the reactor." , engineering_channel)

	playsound(loc, 'sound/effects/turbolift/turbolift-close.ogg', 100)
	set_light(0)

	sleep(20)
	playsound(loc, 'sound/machines/clockcult/steam_whoosh.ogg', 100, TRUE)
	var/turf/reactor_turf = get_turf(src)
	reactor_turf.atmos_spawn_air("water_vapor=[pressure/10];TEMP=[CELSIUS_TO_KELVIN(temperature)]")

	K = 0
	desired_k = 0
	temperature = 0
	pressure = 0
	update_icon()
	QDEL_NULL(soundloop)
