#define COOLANT_INPUT_GATE airs[1]
#define MODERATOR_INPUT_GATE airs[2]
#define COOLANT_OUTPUT_GATE airs[3]

#define RBMK_TEMPERATURE_OPERATING 640 //Celsius
#define RBMK_TEMPERATURE_CRITICAL 800 //At this point the entire ship is alerted to a meltdown. This may need altering
#define RBMK_TEMPERATURE_MELTDOWN 900

#define RBMK_PRESSURE_OPERATING 1000 //PSI
#define RBMK_PRESSURE_CRITICAL 1469.59 //PSI

#define RBMK_MAX_CRITICALITY 3 //No more criticality than N for now.

#define RBMK_POWER_FLAVOURISER 1000 //To turn those KWs into something usable

//Math. Lame.
#define KPA_TO_PSI(A) (A/6.895)
#define PSI_TO_KPA(A) (A*6.895)
#define KELVIN_TO_CELSIUS(A) (A-273.15)
#define CELSIUS_TO_KELVIN(A) (A+273.15)
#define MEGAWATTS /1e+6

//Reference: Heaters go up to 500K.
//Hot plasmaburn: 14164.95 C.

/**
What is this?
Moderators list (Not gonna keep this accurate forever):
Fuel Type:
Oxygen: Power production multiplier. Allows you to run a low plasma, high oxy mix, and still get a lot of power.
Plasma: Power production gas. More plasma -> more power, but it enriches your fuel and makes the reactor much, much harder to control.
Tritium: Extremely efficient power production gas. Will cause chernobyl if used improperly.
Moderation Type:
N2: Helps you regain control of the reaction by increasing control rod effectiveness, will massively boost the rad production of the reactor.
CO2: Super effective shutdown gas for runaway reactions. MASSIVE RADIATION PENALTY!
Pluoxium: Same as N2, but no cancer-rads!
Permeability Type:
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
*/

//Remember kids. If the reactor itself is not physically powered by an APC, it cannot shove coolant in!

/obj/machinery/atmospherics/components/trinary/nuclear_reactor
	name = "Advanced Gas-Cooled Nuclear Reactor"
	desc = "A tried and tested design which can output stable power at an acceptably low risk. The moderator can be changed to provide different effects."
	icon = 'icons/obj/rbmk.dmi'
	icon_state = "reactor_map"
	pixel_x = -32
	pixel_y = -32
	density = FALSE //It burns you if you're stupid enough to walk over it.
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	light_color = LIGHT_COLOR_CYAN
	dir = 8 //Less headache inducing :))
	var/id = null //Change me mappers
	//Variables essential to operation
	var/temperature = 0 //Lose control of this -> Meltdown
	var/vessel_integrity = 1000 //How long can the reactor withstand overpressure / meltdown? This gives you a fair chance to react to even a massive pipe fire
	var/pressure = 0 //Lose control of this -> Blowout
	var/K = 0 //Rate of reaction.
	var/desired_k = 0
	var/control_rod_effectiveness = 0.65 //Starts off with a lot of control over K. If you flood this thing with plasma, you lose your ability to control K as easily.
	var/power = 0 //0-100%. A function of the maximum heat you can achieve within operating temperature
	var/power_modifier = 1 //Upgrade me with parts, science! Flat out increase to physical power output when loaded with plasma.
	var/list/fuel_rods = list()
	//Secondary variables.
	var/next_slowprocess = 0
	var/gas_absorption_effectiveness = 0.5
	var/gas_absorption_constant = 0.5 //We refer to this one as it's set on init, randomized.
	var/minimum_coolant_level = 5
	var/warning = FALSE //Have we begun warning the crew of their impending death?
	var/next_warning = 0 //To avoid spam.
	var/last_power_produced = 0 //For logging purposes
	var/next_flicker = 0 //Light flicker timer
	var/base_power_modifier = RBMK_POWER_FLAVOURISER
	var/slagged = FALSE //Is this reactor even usable any more?
	//Console statistics.
	var/last_coolant_temperature = 0
	var/last_output_temperature = 0
	var/last_heat_delta = 0 //For administrative cheating only. Knowing the delta lets you know EXACTLY what to set K at.
	var/gasefficency = 0.15

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/preset
	id = "default_reactor_for_lazy_mappers"

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/examine(mob/user)
	. = ..()
	if(!Adjacent(src, user))
		return
	if(!do_after(user, 1 SECONDS, target=src))
		return
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

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/attackby(obj/item/W, mob/user, params)
	..()
	if(istype(W, /obj/item/fuel_rod))
		if(power >= 20)
			to_chat(user, "<span class='notice'>You cannot insert fuel into [src] when it has been raised above 20% power.</span>")
			return FALSE
		if(fuel_rods.len >= 5)
			to_chat(user, "<span class='warning'>[src] is already at maximum fuel load.</span>")
			return FALSE
		to_chat(user, "<span class='notice'>You start to insert [W] into [src]...</span>")
		radiation_pulse(src, temperature)
		if(do_after(user, 5 SECONDS, target=src))
			if(!fuel_rods.len)
				start_up() //That was the first fuel rod. Let's heat it up.
			fuel_rods += W
			W.forceMove(src)
			radiation_pulse(src, temperature) //Wear protective equipment when even breathing near a reactor!
		return TRUE
	if(istype(W, /obj/item/sealant))
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
			playsound(src, 'sound/effects/spray2.ogg', 50, 1, -6)
			user.visible_message("<span class='warning'>[user] applies sealant to some of [src]'s worn out seals.</span>", "<span class='notice'>You apply sealant to some of [src]'s worn out seals.</span>")
			vessel_integrity += 10
			vessel_integrity = clamp(vessel_integrity, 0, initial(vessel_integrity))
		return TRUE

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/welder_act(mob/living/user, obj/item/I)
	if(power >= 20)
		to_chat(user, "<span class='notice'>You can't repair [src] while it is running at above 20% power.</span>")
		return FALSE
	if(vessel_integrity > 0.5 * initial(vessel_integrity))
		to_chat(user, "<span class='notice'>[src] is free from cracks. Further repairs must be carried out with flexi-seal sealant.</span>")
		return FALSE
	if(I.use_tool(src, user, 0, volume=40))
		vessel_integrity += 20
		to_chat(user, "<span class='notice'>You weld together some of [src]'s cracks. This'll do for now.</span>")
	return TRUE

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/Initialize()
	. = ..()
	icon_state = "reactor_off"
	gas_absorption_effectiveness = rand(5, 6)/10 //All reactors are slightly different. This will result in you having to figure out what the balance is for K.
	gas_absorption_constant = gas_absorption_effectiveness //And set this up for the rest of the round.
	STOP_PROCESSING(SSmachines, src) //We'll handle this one ourselves.

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(isliving(AM) && temperature > 0)
		var/mob/living/L = AM
		L.adjust_bodytemperature(clamp(temperature, BODYTEMP_COOLING_MAX, BODYTEMP_HEATING_MAX)) //If you're on fire, you heat up!

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/has_fuel()
	return fuel_rods?.len

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/process()
	update_parents()
	//Let's get our gasses sorted out.
	var/datum/gas_mixture/coolant_input = airs[1]
	var/datum/gas_mixture/moderator_input = airs[2]
	var/datum/gas_mixture/coolant_output = airs[3]

	var/datum/gas_mixture/removed_coolant

	//Firstly, heat up the reactor based off of K.
	removed_coolant = coolant_input.remove(gasefficency * coolant_input.total_moles())
	var/input_moles = removed_coolant.total_moles() //Firstly. Do we have enough moles of coolant?
	if(input_moles >= minimum_coolant_level)
		last_coolant_temperature = removed_coolant.return_temperature()
		//Important thing to remember, once you slot in the fuel rods, this thing will not stop making heat, at least, not unless you can live to be thousands of years old which is when the spent fuel finally depletes fully.
		var/heat_delta = (removed_coolant.return_temperature() / 100) * gas_absorption_effectiveness //Take in the gas as a cooled input, cool the reactor a bit. The optimum, 100% balanced reaction sits at K=1, coolant input temp of 200K / -73 celsius.
		last_heat_delta = heat_delta
		temperature += heat_delta
		color = null
	else
		if(has_fuel())
			temperature += temperature / 500 //This isn't really harmful early game, but when your reactor is up to full power, this can get out of hand quite quickly.
			vessel_integrity -= temperature / 200 //Think fast loser.
			take_damage(10) //Just for the sound effect, to let you know you've fucked up.
			color = "[COLOR_RED]"
	removed_coolant.temperature = CELSIUS_TO_KELVIN(temperature)
	last_output_temperature = KELVIN_TO_CELSIUS(removed_coolant.return_temperature())
	pressure = KPA_TO_PSI(removed_coolant.return_pressure())
	coolant_output.merge(removed_coolant)
	removed_coolant.clear()

	power = (temperature / RBMK_TEMPERATURE_CRITICAL) * 100
	var/radioactivity_spice_multiplier = 1 //Some gasses make the reactor a bit spicy.
	var/depletion_modifier = 0.035 //How rapidly do your rods decay
	gas_absorption_effectiveness = gas_absorption_constant

	var/datum/gas_mixture/removed_moderator
	removed_moderator = moderator_input.remove(gasefficency * moderator_input.total_moles())

	removed_moderator.assert_gases(/datum/gas/oxygen, /datum/gas/hydrogen, /datum/gas/plasma, /datum/gas/tritium, /datum/gas/carbon_dioxide, /datum/gas/pluoxium, /datum/gas/nitrogen, /datum/gas/water_vapor, /datum/gas/hypernoblium, /datum/gas/bz, /datum/gas/nitryl)
	var/combined_moles = removed_moderator.total_moles()

	if(combined_moles >= minimum_coolant_level)
		var/total_fuel_moles = removed_moderator.gases[/datum/gas/plasma][MOLES] + removed_moderator.gases[/datum/gas/hydrogen][MOLES] * 1.5 + removed_moderator.gases[/datum/gas/tritium][MOLES] * 3
		var/power_modifier = max((removed_moderator.gases[/datum/gas/oxygen][MOLES] / combined_moles * 10), 1)
		if(total_fuel_moles >= minimum_coolant_level) //You at least need SOME fuel.
			var/power_produced = max((total_fuel_moles / combined_moles * 10), 1)
			last_power_produced = max(0,((power_produced * power_modifier) * combined_moles))
			last_power_produced *= (power/100) //Aaaand here comes the cap. Hotter reactor => more power.
			last_power_produced *= base_power_modifier //Finally, we turn it into actual usable numbers.
			radioactivity_spice_multiplier += removed_moderator.gases[/datum/gas/tritium][MOLES] / 5 //Chernobyl 2.
			var/turf/T = get_turf(src)
			var/obj/structure/cable/C = T.get_cable_node()
			if(!C || !C.powernet)
				return
			else
				C.powernet.newavail += last_power_produced
		var/total_control_moles = removed_moderator.gases[/datum/gas/nitrogen][MOLES] + removed_moderator.gases[/datum/gas/carbon_dioxide][MOLES] * 2 + removed_moderator.gases[/datum/gas/pluoxium][MOLES] * 3 //N2 helps you control the reaction at the cost of making it absolutely blast you with rads. Pluoxium has the same effect but without the rads!
		if(total_control_moles >= minimum_coolant_level)
			var/control_bonus = total_control_moles / 250 //1 mol of n2 -> 0.002 bonus control rod effectiveness, if you want a super controlled reaction, you'll have to sacrifice some power.
			control_rod_effectiveness = initial(control_rod_effectiveness) + control_bonus
			radioactivity_spice_multiplier += removed_moderator.gases[/datum/gas/nitrogen][MOLES] / 25 //An example setup of 50 moles of n2 (for dealing with spent fuel) leaves us with a radioactivity spice multiplier of 3.
			radioactivity_spice_multiplier += removed_moderator.gases[/datum/gas/carbon_dioxide][MOLES] / 12.5
		var/total_permeability_moles = removed_moderator.gases[/datum/gas/bz][MOLES] + removed_moderator.gases[/datum/gas/water_vapor][MOLES] * 2 + removed_moderator.gases[/datum/gas/hypernoblium][MOLES] * 10
		if(total_permeability_moles >= minimum_coolant_level)
			var/permeability_bonus = total_permeability_moles / 500
			gas_absorption_effectiveness = gas_absorption_constant + permeability_bonus
		var/total_degradation_moles = removed_moderator.gases[/datum/gas/nitryl][MOLES] //Because it's quite hard to get.
		if(total_degradation_moles >= minimum_coolant_level*0.5) //I'll be nice.
			depletion_modifier += total_degradation_moles / 15 //Oops! All depletion. This causes your fuel rods to get SPICY.
			playsound(src, pick('sound/machines/sm/accent/normal/1.ogg','sound/machines/sm/accent/normal/2.ogg','sound/machines/sm/accent/normal/3.ogg','sound/machines/sm/accent/normal/4.ogg','sound/machines/sm/accent/normal/5.ogg'), 100, TRUE)
		//From this point onwards, we clear out the remaining gasses.
		removed_moderator.clear()

		K += total_fuel_moles / 1000
	var/fuel_power = 0 //So that you can't magically generate K with your control rods.
	if(!has_fuel())  //Reactor must be fuelled and ready to go before we can heat it up boys.
		K = 0
	else
		for(var/obj/item/fuel_rod/FR in fuel_rods)
			K += FR.fuel_power
			fuel_power += FR.fuel_power
			FR.deplete(depletion_modifier)
	//Firstly, find the difference between the two numbers.
	var/difference = abs(K - desired_k)
	//Then, hit as much of that goal with our cooling per tick as we possibly can.
	difference = clamp(difference, 0, control_rod_effectiveness) //And we can't instantly zap the K to what we want, so let's zap as much of it as we can manage....
	if(difference > fuel_power && desired_k > K)
		message_admins("Not enough fuel to get [difference]. We have fuel [fuel_power]")
		difference = fuel_power //Again, to stop you being able to run off of 1 fuel rod.
	if(K != desired_k)
		if(desired_k > K)
			K += difference
		else if(desired_k < K)
			K -= difference

	K = clamp(K, 0, RBMK_MAX_CRITICALITY)
	if(has_fuel())
		temperature += K
	else
		temperature -= 10 //Nothing to heat us up, so.
	handle_alerts() //Let's check if they're about to die, and let them know.
	update_icon()
	radiation_pulse(src, temperature * radioactivity_spice_multiplier)
	if(power >= 90 && world.time >= next_flicker) //You're overloading the reactor. Give a more subtle warning that power is getting out of control.
		next_flicker = world.time + 1.5 MINUTES
		for(var/obj/machinery/light/L in GLOB.machines)
			if(prob(25) && is_station_level(L.z)) //If youre running the reactor cold though, no need to flicker the lights.
				L.flicker()

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/handle_alerts()
	var/alert = FALSE //If we have an alert condition, we'd best let people know.
	if(K <= 0 && temperature <= 0)
		shut_down()
	//First alert condition: Overheat
	if(temperature >= RBMK_TEMPERATURE_CRITICAL)
		alert = TRUE
		if(temperature >= RBMK_TEMPERATURE_MELTDOWN)
			vessel_integrity -= (temperature / 100)
			if(vessel_integrity <= temperature/100) //It wouldn't be able to tank another hit.
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
		playsound(loc, 'sound/machines/clockcult/steam_whoosh.ogg', 100, TRUE)
		var/turf/T = get_turf(src)
		T.atmos_spawn_air("water_vapor=[pressure/100];TEMP=[CELSIUS_TO_KELVIN(temperature)]")
		vessel_integrity -= (pressure/100)
		if(vessel_integrity <= pressure/100) //It wouldn't be able to tank another hit.
			blowout()
			return
	if(warning)
		if(!alert) //Congrats! You stopped the meltdown / blowout.
			warning = FALSE
			set_light(0)
			light_color = LIGHT_COLOR_CYAN
			set_light(10)
	else
		if(!alert)
			return
		if(world.time < next_warning)
			return
		next_warning = world.time + 30 SECONDS //To avoid engis pissing people off when reaaaally trying to stop the meltdown or whatever.
		warning = TRUE //Start warning the crew of the imminent danger.
		set_light(0)
		light_color = COLOR_RED
		set_light(10)

//Failure condition 1: Meltdown. Achieved by having heat go over tolerances. This is less devastating because it's easier to achieve.
//Results: Engineering becomes unusable and your engine irreparable
/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/meltdown()
	set waitfor = FALSE
	SSair.atmos_machinery -= src //Annd we're now just a useless brick.
	slagged = TRUE
	update_icon()
	STOP_PROCESSING(SSmachines, src)
	icon_state = "reactor_slagged"
	AddComponent(/datum/component/radioactive, 15000 , src)
	for(var/a in GLOB.apcs_list)
		var/obj/machinery/power/apc/A = a
		if(is_station_level(a) && prob(70))
			A.overload_lighting()
	var/datum/gas_mixture/coolant_input = COOLANT_INPUT_GATE
	var/datum/gas_mixture/moderator_input = MODERATOR_INPUT_GATE
	var/datum/gas_mixture/coolant_output = COOLANT_OUTPUT_GATE
	var/turf/T = get_turf(src)
	coolant_input.temperature = CELSIUS_TO_KELVIN(temperature * 2)
	moderator_input.temperature = CELSIUS_TO_KELVIN(temperature * 2)
	coolant_output.temperature = CELSIUS_TO_KELVIN(temperature * 2)
	T.assume_air(coolant_input)
	T.assume_air(moderator_input)
	T.assume_air(coolant_output)
	explosion(get_turf(src), 0, 5, 10, 20, TRUE, TRUE)
	empulse(get_turf(src), 25, 15)

//Failure condition 2: Blowout. Achieved by reactor going over-pressured. This is a round-ender because it requires more fuckery to achieve.
/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/blowout()
	explosion(get_turf(src), 15, 35, 35, 40, TRUE, TRUE)
	meltdown() //Double kill.

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/update_icon()
	icon_state = "reactor_off"
	switch(temperature)
		if(0 to 200)
			icon_state = "reactor_on"
		if(200 to RBMK_TEMPERATURE_OPERATING)
			icon_state = "reactor_hot"
		if(RBMK_TEMPERATURE_OPERATING to 750)
			icon_state = "reactor_veryhot"
		if(750 to RBMK_TEMPERATURE_CRITICAL) //Point of no return.
			icon_state = "reactor_overheat"
		if(RBMK_TEMPERATURE_CRITICAL to INFINITY)
			icon_state = "reactor_meltdown"
	if(!has_fuel())
		icon_state = "reactor_off"
	if(slagged)
		icon_state = "reactor_slagged"
	cut_overlays()
	for(var/direction in GLOB.cardinals)
		if(!(direction & initialize_directions))
			continue
		var/obj/machinery/atmospherics/node = findConnecting(direction)

		var/image/cap
		if(node)
			cap = getpipeimage(icon, "cap", direction, node.pipe_color, piping_layer = piping_layer, trinary = TRUE)
		else
			cap = getpipeimage(icon, "cap", direction, piping_layer = piping_layer, trinary = TRUE)

		add_overlay(cap)
	return..()


//Startup, shutdown

/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/start_up()
	START_PROCESSING(SSmachines, src)
	desired_k = 1
	set_light(10)
	//var/area/AR = get_area(src)
	//AR.set_looping_ambience('nsv13/sound/effects/rbmk/reactor_hum.ogg')
	//var/startup_sound = pick('nsv13/sound/effects/ship/reactor/startup.ogg', 'nsv13/sound/effects/ship/reactor/startup2.ogg')
	//playsound(loc, startup_sound, 100)

//Shuts off the fuel rods, ambience, etc. Keep in mind that your temperature may still go up!
/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/shut_down()
	STOP_PROCESSING(SSmachines, src)
	set_light(0)
	//var/area/AR = get_area(src)
	//AR.set_looping_ambience('nsv13/sound/ambience/shipambience.ogg')
	K = 0
	desired_k = 0
	temperature = 0
	update_icon()

/obj/item/fuel_rod
	name = "Uranium-238 Fuel Rod"
	desc = "A titanium sheathed rod containing a measure of enriched uranium-dioxide powder, used to kick off a fission reaction."
	icon = 'icons/obj/rbmk.dmi'
	icon_state = "irradiated"
	w_class = WEIGHT_CLASS_BULKY
	var/depletion = 0 //Each fuel rod will deplete in around 30 minutes.
	var/fuel_power = 0.10

/obj/item/fuel_rod/proc/deplete(amount=0.035)
	depletion += amount
	if(depletion >= 100)
		fuel_power = 0.20
		name = "Plutonium-239 Fuel Rod"
		desc = "A highly energetic titanium sheathed rod containing a sizeable measure of weapons grade uranium, it's highly efficient as nuclear fuel, but will cause the reaction to get out of control if not properly utilised."
		icon_state = "inferior"
		AddComponent(/datum/component/radioactive, 1500 , src)
	else
		fuel_power = 0.10

/obj/item/fuel_rod/Initialize()
	.=..()
	AddComponent(/datum/component/radioactive, 350 , src)

/obj/item/sealant




/obj/machinery/computer/reactor
	name = "Reactor control console"
	desc = "Scream"
	icon_state = "oldcomp"
	icon_screen = "library"
	icon_keyboard = null
	var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/reactor = null
	var/id = "default_reactor_for_lazy_mappers"

/obj/machinery/computer/reactor/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	addtimer(CALLBACK(src, .proc/link_to_reactor), 10 SECONDS)

/obj/machinery/computer/reactor/proc/link_to_reactor()
	for(var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/asdf in GLOB.machines)
		if(asdf.id && asdf.id == id)
			reactor = asdf
			return TRUE
	return FALSE

#define FREQ_RBMK_CONTROL 1439.69

/obj/machinery/computer/reactor/control_rods
	name = "Control rod management computer"
	desc = "A computer which can remotely raise / lower the control rods of a reactor."
	icon_screen = "rbmk_rods"

/obj/machinery/computer/reactor/control_rods/attack_hand(mob/living/user)
	. = ..()
	ui_interact(user)

/obj/machinery/computer/reactor/control_rods/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src,  ui)
	if(!ui)
		ui = new(user, src, "RbmkControlRods", name)
		ui.open()

/obj/machinery/computer/reactor/control_rods/ui_act(action, params)
	if(..())
		return
	if(!reactor)
		return
	if(action == "input")
		var/input = text2num(params["target"])
		reactor.desired_k = clamp(input, 0, 3)

/obj/machinery/computer/reactor/control_rods/ui_data(mob/user)
	var/list/data = list()
	data["control_rods"] = 0
	data["k"] = 0
	data["desiredK"] = 0
	if(reactor)
		data["k"] = reactor.K
		data["desiredK"] = reactor.desired_k
		data["control_rods"] = 100 - (reactor.desired_k / 3 * 100) //Rod insertion is extrapolated as a function of the percentage of K
	return data

/obj/machinery/computer/reactor/stats
	name = "Reactor Statistics Console"
	desc = "A console for monitoring the statistics of a nuclear reactor."
	icon_screen = "rbmk_stats"
	var/next_stat_interval = 0
	var/list/psiData = list()
	var/list/powerData = list()
	var/list/tempInputData = list()
	var/list/tempOutputdata = list()

/obj/machinery/computer/reactor/stats/attack_hand(mob/living/user)
	. = ..()
	ui_interact(user)

/obj/machinery/computer/reactor/stats/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RbmkStats", name)
		ui.open()

/obj/machinery/computer/reactor/stats/process()
	if(world.time >= next_stat_interval)
		next_stat_interval = world.time + 1 SECONDS //You only get a slow tick.
		psiData += (reactor) ? reactor.pressure : 0
		if(psiData.len > 100) //Only lets you track over a certain timeframe.
			psiData.Cut(1, 2)
		powerData += (reactor) ? reactor.power*10 : 0 //We scale up the figure for a consistent:tm: scale
		if(powerData.len > 100) //Only lets you track over a certain timeframe.
			powerData.Cut(1, 2)
		tempInputData += (reactor) ? reactor.last_coolant_temperature : 0 //We scale up the figure for a consistent:tm: scale
		if(tempInputData.len > 100) //Only lets you track over a certain timeframe.
			tempInputData.Cut(1, 2)
		tempOutputdata += (reactor) ? reactor.last_output_temperature : 0 //We scale up the figure for a consistent:tm: scale
		if(tempOutputdata.len > 100) //Only lets you track over a certain timeframe.
			tempOutputdata.Cut(1, 2)

/obj/machinery/computer/reactor/stats/ui_data(mob/user)
	var/list/data = list()
	data["powerData"] = powerData
	data["psiData"] = psiData
	data["tempInputData"] = tempInputData
	data["tempOutputdata"] = tempOutputdata
	data["coolantInput"] = reactor ? reactor.last_coolant_temperature : 0
	data["coolantOutput"] = reactor ? reactor.last_output_temperature : 0
	data["power"] = reactor ? reactor.power : 0
	data ["psi"] = reactor ? reactor.pressure : 0
	return data

/obj/machinery/computer/reactor/fuel_rods
	name = "Reactor Fuel Management Console"
	desc = "A console which can remotely raise fuel rods out of nuclear reactors."
	icon_screen = "rbmk_fuel"

/obj/machinery/computer/reactor/fuel_rods/attack_hand(mob/living/user)
	. = ..()
	if(!reactor)
		return FALSE
	if(reactor.power > 20)
		to_chat(user, "<span class='warning'>You cannot remove fuel from [reactor] when it is above 20% power.</span>")
		return FALSE
	if(!reactor.fuel_rods.len)
		to_chat(user, "<span class='warning'>[reactor] does not have any fuel rods loaded.</span>")
		return FALSE
	var/atom/movable/fuel_rod = input(usr, "Select a fuel rod to remove", "[src]", null) as null|anything in reactor.fuel_rods
	if(!fuel_rod)
		return
	//playsound(src, pick('nsv13/sound/effects/rbmk/switch.ogg','nsv13/sound/effects/rbmk/switch2.ogg','nsv13/sound/effects/rbmk/switch3.ogg'), 100, FALSE)
	//playsound(reactor, 'nsv13/sound/effects/ship/freespace2/crane_1.wav', 100, FALSE)
	fuel_rod.forceMove(get_turf(reactor))
	reactor.fuel_rods -= fuel_rod

//Preset pumps for mappers. You can also set the id tags yourself.
/obj/machinery/atmospherics/components/binary/pump/rbmk_input
	id = "rbmk_input"
	frequency = FREQ_RBMK_CONTROL

/obj/machinery/atmospherics/components/binary/pump/rbmk_output
	id = "rbmk_output"
	frequency = FREQ_RBMK_CONTROL

/obj/machinery/atmospherics/components/binary/pump/rbmk_moderator
	id = "rbmk_moderator"
	frequency = FREQ_RBMK_CONTROL

/obj/machinery/computer/reactor/pump
	name = "Reactor inlet valve computer"
	desc = "A computer which controls valve settings on an advanced gas cooled reactor. Alt click it to remotely set pump pressure."
	icon_screen = "rbmk_input"
	id = "rbmk_input"
	var/datum/radio_frequency/radio_connection
	var/on = FALSE

/obj/machinery/computer/reactor/pump/AltClick(mob/user)
	. = ..()
	var/newPressure = input(user, "Set new output pressure (kPa)", "Remote pump control", null) as num
	if(!newPressure)
		return
	signal(on, newPressure) //Number sanitization is handled on the actual pumps themselves.

/obj/machinery/computer/reactor/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/reactor/attack_ai(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/reactor/pump/attack_hand(mob/living/user)
	. = ..()
	if(!is_operational)
		return FALSE
	//playsound(loc, pick('nsv13/sound/effects/rbmk/switch.ogg','nsv13/sound/effects/rbmk/switch2.ogg','nsv13/sound/effects/rbmk/switch3.ogg'), 100, FALSE)
	visible_message("<span class='notice>[src]'s switch flips [on ? "off" : "on"].</span>")
	on = !on
	signal(on)

/obj/machinery/computer/reactor/pump/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	radio_connection = SSradio.add_object(src, FREQ_RBMK_CONTROL,filter=RADIO_ATMOSIA)

/obj/machinery/computer/reactor/pump/proc/signal(power, set_output_pressure=null)
	var/datum/signal/signal
	if(!set_output_pressure) //Yes this is stupid, but technically if you pass through "set_output_pressure" onto the signal, it'll always try and set its output pressure and yeahhh...
		signal = new(list(
			"tag" = id,
			"frequency" = FREQ_RBMK_CONTROL,
			"timestamp" = world.time,
			"power" = power,
			"sigtype" = "command"
		))
	else
		signal = new(list(
			"tag" = id,
			"frequency" = FREQ_RBMK_CONTROL,
			"timestamp" = world.time,
			"power" = power,
			"set_output_pressure" = set_output_pressure,
			"sigtype" = "command"
		))
	radio_connection.post_signal(src, signal, filter=RADIO_ATMOSIA)

//Preset subtypes for mappers
/obj/machinery/computer/reactor/pump/rbmk_input
	name = "Reactor inlet valve computer"
	icon_screen = "rbmk_input"
	id = "rbmk_input"

/obj/machinery/computer/reactor/pump/rbmk_output
	name = "Reactor output valve computer"
	icon_screen = "rbmk_output"
	id = "rbmk_output"

/obj/machinery/computer/reactor/pump/rbmk_moderator
	name = "Reactor moderator valve computer"
	icon_screen = "rbmk_moderator"
	id = "rbmk_moderator"

//SPENT FUEL POOL
//FINALLY WE CAN RECREATE THE ROBLOX NUCLEAR DISASTER - 18/08/2020

/turf/open/indestructible/pool/spentfuel
	name = "Spent fuel pool"
	desc = "A dumping ground for spent nuclear fuel, can you touch the bottom?."
	icon = 'icons/obj/pool.dmi'
	icon_state = "pool"

/turf/open/indestructible/pool/spentfuel/wall
	icon_state = "poolwall"

//Monitoring program.
/datum/computer_file/program/nuclear_monitor
	filename = "rbmkmonitor"
	filedesc = "Nuclear Reactor Monitoring"
	ui_header = "smmon_0.gif"
	program_icon_state = "smmon_0"
	extended_desc = "This program connects to specially calibrated sensors to provide information on the status of nuclear reactors."
	requires_ntnet = TRUE
	transfer_access = ACCESS_CONSTRUCTION
	size = 2
	tgui_id = "NtosRbmkStats"
	var/active = TRUE //Easy process throttle
	var/next_stat_interval = 0
	var/list/psiData = list()
	var/list/powerData = list()
	var/list/tempInputData = list()
	var/list/tempOutputdata = list()
	var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/reactor //Our reactor.

/datum/computer_file/program/nuclear_monitor/process_tick()
	..()
	if(!reactor || !active)
		return FALSE
	var/stage = 0
	//This is dirty but i'm lazy wahoo!
	if(reactor.power > 0)
		stage = 1
	if(reactor.power >= 40)
		stage = 2
	if(reactor.temperature >= RBMK_TEMPERATURE_OPERATING)
		stage = 3
	if(reactor.temperature >= RBMK_TEMPERATURE_CRITICAL)
		stage = 4
	if(reactor.temperature >= RBMK_TEMPERATURE_MELTDOWN)
		stage = 5
		if(reactor.vessel_integrity <= 100) //Bye bye! GET OUT!
			stage = 6
	ui_header = "smmon_[stage].gif"
	program_icon_state = "smmon_[stage]"
	if(istype(computer))
		computer.update_icon()
	if(world.time >= next_stat_interval)
		next_stat_interval = world.time + 1 SECONDS //You only get a slow tick.
		psiData += (reactor) ? reactor.pressure : 0
		if(psiData.len > 100) //Only lets you track over a certain timeframe.
			psiData.Cut(1, 2)
		powerData += (reactor) ? reactor.power*10 : 0 //We scale up the figure for a consistent:tm: scale
		if(powerData.len > 100) //Only lets you track over a certain timeframe.
			powerData.Cut(1, 2)
		tempInputData += (reactor) ? reactor.last_coolant_temperature : 0 //We scale up the figure for a consistent:tm: scale
		if(tempInputData.len > 100) //Only lets you track over a certain timeframe.
			tempInputData.Cut(1, 2)
		tempOutputdata += (reactor) ? reactor.last_output_temperature : 0 //We scale up the figure for a consistent:tm: scale
		if(tempOutputdata.len > 100) //Only lets you track over a certain timeframe.
			tempOutputdata.Cut(1, 2)

/datum/computer_file/program/nuclear_monitor/run_program(mob/living/user)
	. = ..(user)
	//No reactor? Go find one then.
	if(!reactor)
		for(var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/R in GLOB.machines)
			if(is_station_level(R))
				reactor = R
				break
	active = TRUE

/datum/computer_file/program/nuclear_monitor/kill_program(forced = FALSE)
	active = FALSE
	..()

/datum/computer_file/program/nuclear_monitor/ui_data()
	var/list/data = get_header_data()
	data["powerData"] = powerData
	data["psiData"] = psiData
	data["tempInputData"] = tempInputData
	data["tempOutputdata"] = tempOutputdata
	data["coolantInput"] = reactor ? reactor.last_coolant_temperature : 0
	data["coolantOutput"] = reactor ? reactor.last_output_temperature : 0
	data["power"] = reactor ? reactor.power : 0
	data ["psi"] = reactor ? reactor.pressure : 0
	return data

/datum/computer_file/program/nuclear_monitor/ui_act(action, params)
	if(..())
		return TRUE

	switch(action)
		if("swap_reactor")
			var/list/choices = list()
			for(var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/R in GLOB.machines)
				if(!is_station_level(R))
					continue
				choices += R
			reactor = input(usr, "What reactor do you wish to monitor?", "[src]", null) as null|anything in choices
			powerData = list()
			psiData = list()
			tempInputData = list()
			tempOutputdata = list()
			return TRUE