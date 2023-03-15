/obj/effect/decal/nuclear_waste
	name = "Plutonium sludge"
	desc = "A writhing pool of heavily irradiated, spent reactor fuel. A shovel should clear it up! Just sprinkle a little graphite on it, it will be fine. though you probably shouldn't step through this..."
	icon = 'monkestation/icons/obj/machinery/reactor_parts.dmi'
	icon_state = "nuclearwaste"
	alpha = 150
	light_color = LIGHT_COLOR_CYAN
	color = "#ff9eff"
	var/random_icon_states = list("waste1")

/obj/effect/decal/nuclear_waste/Initialize(mapload)
	. = ..()
	if(random_icon_states && (icon_state == initial(icon_state)) && length(random_icon_states) > 0)
		icon_state = pick(random_icon_states)
	set_light(3)

/// The one that actually does the irradiating. This is to avoid every bit of sludge PROCESSING
/obj/effect/decal/nuclear_waste/epicenter
	name = "Dense nuclear sludge"

/// Clean way of spawning nuclear gunk after a reactor wastecore meltdown.
/obj/effect/landmark/nuclear_waste_spawner
	name = "Nuclear Waste Spawner"
	var/range = 3

/obj/effect/landmark/nuclear_waste_spawner/strong
	name = "Nuclear Waste Spawner Strong"
	range = 8

//Spawns nuclear_waste_spawners on map
/obj/machinery/atmospherics/components/trinary/nuclear_reactor/proc/sludge_spawner_preload()
	/// Smaller scale spawn for spawning range to power output
	var/short_range = CLAMP(power/10, 5, 25)
	for(var/turf/open/floor in orange(short_range, get_turf(src)))
		if(prob(1)) //Prob of Spawn for sludge spawner
			new /obj/effect/landmark/nuclear_waste_spawner(floor)
		continue

	/// Larger scale spawn for spawning range to power output
	var/longe_range = CLAMP(power, 5, 200)
	for(var/turf/open/floor in orange(longe_range, get_turf(src)))
		if(prob(5)) //Prob of Spawn for sludge spawner
			new /obj/effect/landmark/nuclear_waste_spawner(floor)
		continue

/obj/effect/landmark/nuclear_waste_spawner/proc/fire()
	playsound(loc, 'sound/effects/gib_step.ogg', 100)
	new /obj/effect/decal/nuclear_waste/epicenter(get_turf(src))
	for(var/turf/open/floor in orange(range, get_turf(src)))
		if(prob(20)) //Scatter the sludge, don't smear it everywhere
			new /obj/effect/decal/nuclear_waste(floor)
			continue
	qdel(src)

/obj/effect/decal/nuclear_waste/epicenter/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/decal/nuclear_waste/epicenter/ComponentInitialize()
	AddComponent(/datum/component/radioactive, 1500, src, 0)

/obj/effect/decal/nuclear_waste/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(isliving(AM))
		var/mob/living/L = AM
		playsound(loc, 'sound/effects/gib_step.ogg', HAS_TRAIT(L, TRAIT_LIGHT_STEP) ? 20 : 50, 1)
	radiation_pulse(src, 500, 5) //MORE RADS

/obj/effect/decal/nuclear_waste/attackby(obj/item/tool, mob/user)
	if(tool.tool_behaviour == TOOL_SHOVEL)
		radiation_pulse(src, 1000, 5) //MORE RADS
		to_chat(user, "<span class='notice'>You start to clear [src]...</span>")
		if(tool.use_tool(src, user, 50, volume=100))
			to_chat(user, "<span class='notice'>You clear [src].</span>")
			qdel(src)
			return
	. = ..()

/datum/weather/nuclear_fallout
	name = "nuclear fallout"
	desc = "Irradiated dust falls down everywhere."
	telegraph_duration = 50
	telegraph_message = "<span class='boldwarning'>The air suddenly becomes dusty..</span>"
	weather_message = "<span class='userdanger'><i>You feel a wave of hot ash fall down on you.</i></span>"
	weather_overlay = "light_ash"
	telegraph_overlay = "light_snow"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	weather_color = "green"
	telegraph_sound = null
	weather_sound = 'monkestation/sound/effects/rbmk/falloutwind.ogg'
	end_duration = 100
	area_type = /area
	protected_areas = list(/area/maintenance, /area/ai_monitored/turret_protected/ai_upload, /area/ai_monitored/turret_protected/ai_upload_foyer,
	/area/ai_monitored/turret_protected/ai, /area/storage/emergency/starboard, /area/storage/emergency/port, /area/shuttle)
	target_trait = ZTRAIT_STATION
	end_message = "<span class='notice'>The ash stops falling.</span>"
	immunity_type = "rad"

/datum/weather/nuclear_fallout/weather_act(mob/living/L)
	L.rad_act(100)

/datum/weather/nuclear_fallout/telegraph()
	..()
	status_alarm(TRUE)

/datum/weather/nuclear_fallout/proc/status_alarm(active)	//Makes the status displays show the radiation warning for those who missed the announcement.
	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)
	if(!frequency)
		return

	var/datum/signal/signal = new
	if (active)
		signal.data["command"] = "alert"
		signal.data["picture_state"] = "radiation"
	else
		signal.data["command"] = "shuttle"

	var/atom/movable/virtualspeaker/virt = new(null)
	frequency.post_signal(virt, signal)

/datum/weather/nuclear_fallout/end()
	if(..())
		return
	status_alarm(FALSE)

