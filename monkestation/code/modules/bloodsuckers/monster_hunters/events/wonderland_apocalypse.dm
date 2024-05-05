/datum/dimension_theme/wonderland
	icon = 'icons/mob/simple/rabbit.dmi'
	icon_state = "rabbit_white"
	replace_floors = list(/turf/open/misc/grass/jungle/wonderland = 1)
	replace_walls = /turf/closed/wall/mineral/wood
	replace_objs = list(\
		/obj/structure/chair = list(/obj/structure/chair/wood = 1), \
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/wood = 1, /obj/machinery/door/airlock/wood/glass = 1), \
		/obj/structure/table = list(/obj/structure/table/wood = 1), \
		/obj/machinery/holopad  = list(/obj/structure/flora/tree/jungle = 1 ), \
		/obj/machinery/atmospherics/components/unary/vent_scrubber = list(/obj/structure/flora/tree/dead = 1))


/turf/open/misc/grass/jungle/wonderland
	underfloor_accessibility = UNDERFLOOR_HIDDEN

/datum/round_event_control/wonderlandapocalypse
	name = "Apocalypse"
	typepath = /datum/round_event/wonderlandapocalypse
	max_occurrences = 0
	weight = 0
	alert_observers = FALSE
	category = EVENT_CATEGORY_SPACE

/datum/round_event/wonderlandapocalypse/announce(fake)
	if(!fake && SSsecurity_level.get_current_level_as_number() < SEC_LEVEL_DELTA)
		SSsecurity_level.set_level(SEC_LEVEL_DELTA)
	priority_announce(
		text = "What the heELl is going on?! WEeE have detected  massive up-spikes in ##@^^?? coming fr*m yoOourr st!*i@n! GeEeEEET out of THERE NOW!!",
		title = Gibberish("[command_name()] Higher Dimensional Affairs", TRUE, 45),
		sound = 'monkestation/sound/bloodsuckers/monsterhunterintro.ogg',
		color_override = "purple"
	)

/datum/round_event/wonderlandapocalypse/start()
	SSshuttle.emergency_no_recall = TRUE
	for(var/i = 1 to 16)
		new /obj/effect/anomaly/dimensional/wonderland(get_safe_random_station_turf(), null, FALSE)
	for(var/i = 1 to 4)
		var/obj/structure/wonderland_rift/rift = new(get_safe_random_station_turf())
		notify_ghosts("A doorway to the wonderland has been opened!", source = rift, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Wonderland Rift Opened")
	for(var/mob/living/target as anything in GLOB.mob_living_list)
		if(QDELETED(target))
			continue
		var/area/centcom/target_area = get_area(target)
		if(istype(target_area) && target_area.grace)
			continue
		addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living, apply_status_effect), /datum/status_effect/wonderland_district), rand(5 SECONDS, 10 SECONDS))
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_CREATED, PROC_REF(apply_pressure_to_new_mob))

/datum/round_event/wonderlandapocalypse/proc/apply_pressure_to_new_mob(datum/source, mob/living/target)
	SIGNAL_HANDLER
	if(!istype(target) || QDELING(target))
		return
	var/area/centcom/target_area = get_area(target)
	if(istype(target_area) && target_area.grace)
		return
	target.apply_status_effect(/datum/status_effect/wonderland_district)

/obj/effect/anomaly/dimensional/wonderland
	aSignal = null
	range = 5
	immortal = TRUE
	drops_core = FALSE
	relocations_left = -1

/obj/effect/anomaly/dimensional/wonderland/Initialize(mapload, new_lifespan, drops_core)
	INVOKE_ASYNC(src, PROC_REF(prepare_area), /datum/dimension_theme/wonderland)
	return ..()

/obj/effect/anomaly/dimensional/wonderland/relocate()
	var/datum/anomaly_placer/placer = new()
	var/area/new_area = placer.findValidArea()
	var/turf/new_turf = placer.findValidTurf(new_area)
	src.forceMove(new_turf)
	prepare_area(new_theme_path = /datum/dimension_theme/wonderland)

/obj/structure/wonderland_rift
	name = "Wonderland Door"
	desc = "A door leading to a magical beautiful land."
	icon = 'monkestation/icons/mob/infils.dmi'
	icon_state = "cyborg_rift"
	anchored = TRUE
	density = FALSE
	plane = MASSIVE_OBJ_PLANE
	armor_type = /datum/armor/wonderland_rift
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// Have we already spawned an enemy?
	var/enemy_spawned = FALSE

/datum/armor/wonderland_rift
	melee = 100
	energy = 100
	bomb = 100
	fire = 100
	acid = 100

/obj/structure/wonderland_rift/attack_ghost(mob/user)
	. = ..()
	if(.)
		return
	summon_rabbit(user)
	if(enemy_spawned)
		qdel(src)


/obj/structure/wonderland_rift/proc/summon_rabbit(mob/user)
	var/spawn_check = tgui_alert(user, "Become a Jabberwocky?", "Wonderland Rift", list("Yes", "No"))
	if(spawn_check != "Yes" || QDELETED(src) || QDELETED(user) || enemy_spawned)
		return FALSE
	enemy_spawned = TRUE
	var/mob/living/basic/red_rabbit/evil_rabbit = new(get_turf(src))
	evil_rabbit.key = user.key
	to_chat(evil_rabbit, span_boldwarning("Destroy everything, spare no one."))

/datum/status_effect/wonderland_district
	id = "wonderland_district"
	alert_type = null
	tick_interval = -1

/datum/status_effect/wonderland_district/on_apply()
	. = ..()
	if(FACTION_RABBITS in owner?.faction)
		return FALSE
	to_chat(owner, span_warning("You feel an ominous pressure fill the air around you..."))
	RegisterSignal(owner, COMSIG_ENTER_AREA, PROC_REF(on_enter_area))
	RegisterSignal(owner, COMSIG_MOB_AFTER_SPELL_CAST, PROC_REF(after_spell_cast))

/datum/status_effect/wonderland_district/on_remove()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_ENTER_AREA, COMSIG_MOB_AFTER_SPELL_CAST))

/datum/status_effect/wonderland_district/proc/on_enter_area(datum/source, area/centcom/new_area)
	SIGNAL_HANDLER
	if(istype(new_area) && new_area.grace)
		qdel(src)

/datum/status_effect/wonderland_district/proc/after_spell_cast(datum/source, datum/action/cooldown/spell/spell, atom/cast_on)
	SIGNAL_HANDLER
	if(!istype(spell) || QDELING(spell) || !spell.antimagic_flags) // don't affect non-magic spells.
		return
	make_visible()
	INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob/living, emote), "scream")
	owner.visible_message(span_warning("[owner] doubles over in pain, violently coughing up blood!"), span_userdanger("An overwhelming pressure fills your body as you cast [spell.name || "magic"], filling you with excruciating pain down to the very core of your being!"))
	owner.take_overall_damage(brute = rand(5, 15))
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.vomit(lost_nutrition = 0, blood = TRUE, distance = rand(1, 2), message = FALSE)

/datum/status_effect/wonderland_district/proc/make_visible()
	if(alert_type && !QDELETED(linked_alert))
		return
	alert_type = /atom/movable/screen/alert/status_effect/wonderland_district
	linked_alert = owner.throw_alert(id, alert_type)
	linked_alert.attached_effect = src

/atom/movable/screen/alert/status_effect/wonderland_district
	name = "Wonderland Manifestation"
	desc = "An omnipresent pressure surrounds you, causing any use of magic to overload your body!"
	icon = 'monkestation/icons/hud/screen_alert.dmi'
	icon_state = "wonderland"
