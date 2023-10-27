/**
 * The base object for the quantum server
 */
/obj/machinery/quantum_server
	name = "quantum server"

	circuit = /obj/item/circuitboard/machine/quantum_server
	density = TRUE
	desc = "A hulking computational machine designed to fabricate virtual domains."
	icon = 'icons/obj/machines/bitrunning.dmi'
	base_icon_state = "qserver"
	icon_state = "qserver"
	/// Affects server cooldown efficiency
	var/capacitor_coefficient = 1
	/// The loaded map template, map_template/virtual_domain
	var/datum/lazy_template/virtual_domain/generated_domain
	/// The loaded safehouse, map_template/safehouse
	var/datum/map_template/safehouse/generated_safehouse
	/// The connected console
	var/datum/weakref/console_ref
	/// If the current domain was a random selection
	var/domain_randomized = FALSE
	/// If any threats were spawned, adds to rewards
	var/domain_threats = 0
	/// Prevents multiple user actions. Handled by loading domains and cooldowns
	var/is_ready = TRUE
	/// List of available domains
	var/list/available_domains = list()
	/// Current plugged in users
	var/list/datum/weakref/avatar_connection_refs = list()
	/// Cached list of mutable mobs in zone for cybercops
	var/list/datum/weakref/mutation_candidate_refs = list()
	/// Any ghosts that have spawned in
	var/list/datum/weakref/spawned_threat_refs = list()
	/// Scales loot with extra players
	var/multiplayer_bonus = 1.1
	///The radio the console can speak into
	var/obj/item/radio/radio
	/// The amount of points in the system, used to purchase maps
	var/points = 0
	/// Keeps track of the number of times someone has built a hololadder
	var/retries_spent = 0
	/// Changes how much info is available on the domain
	var/scanner_tier = 1
	/// Length of time it takes for the server to cool down after resetting. Here to give runners downtime so their faces don't get stuck like that
	var/server_cooldown_time = 3 MINUTES
	/// Applies bonuses to rewards etc
	var/servo_bonus = 0
	/// The turfs we can place a hololadder on.
	var/turf/exit_turfs = list()

/obj/machinery/quantum_server/Initialize(mapload)
	. = ..()

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/quantum_server/LateInitialize()
	. = ..()

	if(isnull(console_ref))
		find_console()

	radio = new(src)
	radio.set_frequency(FREQ_SUPPLY)
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.recalculateChannels()

	RegisterSignals(src, list(COMSIG_MACHINERY_BROKEN, COMSIG_MACHINERY_POWER_LOST), PROC_REF(on_broken))
	RegisterSignal(src, COMSIG_QDELETING, PROC_REF(on_delete))
	RegisterSignal(src, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(src, COMSIG_BITRUNNER_SPAWN_GLITCH, PROC_REF(on_threat_created))

	// This further gets sorted in the client by cost so it's random and grouped
	available_domains = shuffle(subtypesof(/datum/lazy_template/virtual_domain))

/obj/machinery/quantum_server/Destroy(force)
	. = ..()

	available_domains.Cut()
	mutation_candidate_refs.Cut()
	avatar_connection_refs.Cut()
	spawned_threat_refs.Cut()
	QDEL_NULL(exit_turfs)
	QDEL_NULL(generated_domain)
	QDEL_NULL(generated_safehouse)
	QDEL_NULL(radio)

/obj/machinery/quantum_server/update_appearance(updates)
	if(isnull(generated_domain) || !is_operational)
		set_light(l_on = FALSE)
		return ..()

	set_light_color(is_ready ? LIGHT_COLOR_BABY_BLUE : LIGHT_COLOR_FIRE)
	set_light(l_range = 2, l_power = 1.5, l_on = TRUE)

	return ..()

/obj/machinery/quantum_server/update_icon_state()
	if(isnull(generated_domain) || !is_operational)
		icon_state = base_icon_state
		return ..()

	icon_state = "[base_icon_state]_[is_ready ? "on" : "off"]"
	return ..()

/obj/machinery/quantum_server/crowbar_act(mob/living/user, obj/item/crowbar)
	. = ..()

	if(!is_ready)
		balloon_alert(user, "it's scalding hot!")
		return TRUE
	if(length(avatar_connection_refs))
		balloon_alert(user, "all clients must disconnect!")
		return TRUE
	if(default_deconstruction_crowbar(crowbar))
		return TRUE
	return FALSE

/obj/machinery/quantum_server/screwdriver_act(mob/living/user, obj/item/screwdriver)
	. = ..()

	if(!is_ready)
		balloon_alert(user, "it's scalding hot!")
		return TRUE
	if(default_deconstruction_screwdriver(user, "[base_icon_state]_panel", icon_state, screwdriver))
		return TRUE
	return FALSE

/obj/machinery/quantum_server/RefreshParts()
	. = ..()

	var/capacitor_rating = 1.15
	var/datum/stock_part/capacitor/cap = locate() in component_parts
	capacitor_rating -= cap.tier * 0.15

	capacitor_coefficient = capacitor_rating

	var/datum/stock_part/scanning_module/scanner = locate() in component_parts
	if(scanner)
		scanner_tier = scanner.tier

	var/servo_rating = 0
	for(var/datum/stock_part/servo/servo in component_parts)
		servo_rating += servo.tier * 0.1

	servo_bonus = servo_rating

	SEND_SIGNAL(src, COMSIG_BITRUNNER_SERVER_UPGRADED, servo_rating)
