GLOBAL_LIST_EMPTY(anchoring_crystals) //list of all anchoring crystals

#define CRYSTAL_SHIELD_DELAY 50 SECONDS //how long until shields start to recharge
#define CRYSTAL_CHARGE_TIMER 360 //how long in seconds do crystals take to charge, 6 MINTUES
#define CRYSTAL_CHARGING 0 //crystal is currently charging
#define CRYSTAL_LOCATION_ANNOUNCED 1 //the location of the crystal has been anouced to the crew
#define FULLY_CHARGED 2 //the crystal is fully charged
#define SHIELD_ACTIVE "active" //the shield is currently active
#define SHIELD_DEFLECT "deflect" //the shield is currently in its deflecting animation
#define SHIELD_BREAK "break" //the shield is currently in its breaking animation
#define SHIELD_BROKEN "broken" //the shield is currently broken
#define SERVANT_CAPACITY_TO_GIVE 2 //how many extra server slots do we give on first charged crystal
/obj/structure/destructible/clockwork/anchoring_crystal
	name = "Anchoring Crystal"
	desc = "A strange crystal that you cant quite seem to focus on."
	icon = 'monkestation/icons/obj/clock_cult/clockwork_objects.dmi'
	icon_state = "obelisk"
	break_message = span_warning("As the Anchoring Crystal shatters you swear you hear a faint scream.")
	break_sound = 'monkestation/sound/machines/clockcult/ark_damage.ogg'
	immune_to_servant_attacks = TRUE
	clockwork_desc = "This will help anchor reebe to this realm, allowing for greater power."
	can_rotate = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	armor_type = /datum/armor/anchoring_crystal
	max_integrity = 300 //pretty hard to break
	///how many hits this can take before taking structure damage, not using the component as its only for items/mobs
	var/shields = 3
	///what charge state is this crystal
	var/charge_state = CRYSTAL_CHARGING
	///what area is this in
	var/area/crystal_area
	///theme for transforming the area
	var/static/datum/dimension_theme/clock_theme
	///timer var for charging
	var/charging_for = 0
	///due to the way overlays are handled we have to handle everything for them within a single SIGNAL_HANDLER proc, this var is used for keeping track of what to set our overlay state to next
	var/overlay_state = SHIELD_ACTIVE
	///cooldown for when we were last hit
	COOLDOWN_DECLARE(recently_hit_cd)

/datum/armor/anchoring_crystal
	bio = 100
	bomb = 100 //we dont want bombing to be good
	energy = 100
	fire = 100
	acid = 100
	melee = -15 //weak to melee, subject to change
	laser = 60 //resistant to lasers
	bullet = 30

/obj/structure/destructible/clockwork/anchoring_crystal/Initialize(mapload)
	. = ..()
	crystal_area = get_area(src)
	GLOB.anchoring_crystals += src
	if(!clock_theme)
		clock_theme = new /datum/dimension_theme/clockwork(is_cult = TRUE)

	start_turf_conversion()
	send_clock_message(null, span_bigbrass(span_bold("An Anchoring Crystal has been created at [crystal_area], defend it!")))

	if(length(GLOB.anchoring_crystals) >= 2)
		priority_announce("Reality warping object detected aboard the station.", "Higher Dimensional Affairs", ANNOUNCER_SPANOMALIES, has_important_message = TRUE)

	START_PROCESSING(SSprocessing, src)
	RegisterSignal(src, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	update_icon()

	var/datum/objective/anchoring_crystals/crystals_objective = locate() in GLOB.main_clock_cult?.objectives
	if(crystal_area in crystals_objective?.valid_areas) //if a crystal gets destroyed you cant use that area again
		crystals_objective.valid_areas -= crystal_area

	SSshuttle.registerHostileEnvironment(src) //removed on destruction or once the scripture is off cooldown
	var/datum/scripture/create_structure/anchoring_crystal/crystal_scripture
	addtimer(CALLBACK(src, PROC_REF(clear_hostile_environment)), ANCHORING_CRYSTAL_COOLDOWN + initial(crystal_scripture.invocation_time)) //also give them time to invoke
	GLOB.clock_warp_areas |= crystal_area

/obj/structure/destructible/clockwork/anchoring_crystal/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	COOLDOWN_START(src, recently_hit_cd, CRYSTAL_SHIELD_DELAY)
	if(shields >= 1)
		shields--
		src.visible_message("The attack is deflected by the shield of [src].")
		if(shields > 0)
			overlay_state = SHIELD_DEFLECT
		else
			overlay_state = SHIELD_BREAK
		do_sparks(2, TRUE, src)
		update_icon()
		damage_amount = 0 //dont take damage if we have shields
	. = ..()

/obj/structure/destructible/clockwork/anchoring_crystal/process(seconds_per_tick)
	for(var/mob/living/affected_mob in crystal_area)
		if(IS_CLOCK(affected_mob))
			affected_mob.adjustToxLoss(-2.5 * seconds_per_tick) //slightly better tox healing as well as better stam healing around it for servants
			affected_mob.stamina.adjust(7.5 * seconds_per_tick, TRUE)
			continue
		affected_mob.adjust_silence_up_to(5 SECONDS * seconds_per_tick, 2 MINUTES)

	if(charge_state == FULLY_CHARGED) //if fully charged then add the power and return
		GLOB.clock_power = min(GLOB.clock_power + (10 * seconds_per_tick), GLOB.max_clock_power)
		return

	charging_for = min(charging_for + seconds_per_tick, CRYSTAL_CHARGE_TIMER)

	if(shields < initial(shields) && COOLDOWN_FINISHED(src, recently_hit_cd))
		playsound(src, 'sound/magic/charge.ogg', 50, TRUE)
		shields++
		overlay_state = SHIELD_ACTIVE
		update_icon()

	if(charging_for >= CRYSTAL_CHARGE_TIMER)
		finish_charging()
		return

	if(charge_state < CRYSTAL_LOCATION_ANNOUNCED && charging_for >= (CRYSTAL_CHARGE_TIMER * 0.4))
		charge_state = CRYSTAL_LOCATION_ANNOUNCED
		if(length(GLOB.anchoring_crystals) >= 2)
			priority_announce("Reality warping object located in [crystal_area].", "Central Command Higher Dimensional Affairs", ANNOUNCER_SPANOMALIES, has_important_message = TRUE)

/obj/structure/destructible/clockwork/anchoring_crystal/Destroy()
	send_clock_message(null, span_bigbrass(span_bold("The Anchoring Crystal at [crystal_area] has been destroyed!")))
	GLOB.anchoring_crystals -= src
	STOP_PROCESSING(SSprocessing, src)
	UnregisterSignal(src, COMSIG_ATOM_UPDATE_OVERLAYS)
	SSshuttle.clearHostileEnvironment(src)
	return ..()

/obj/structure/destructible/clockwork/anchoring_crystal/examine(mob/user) //needs to be here as it has updating information
	. = ..()
	if(IS_CLOCK(user) || isobserver(user))
		. += span_brass("[charge_state == FULLY_CHARGED ? "It is fully charged and is indestructable." : "It will be fully charged in [(CRYSTAL_CHARGE_TIMER - charging_for)] seconds."]")

//called on init, transforms the turfs and objs in the area of the crystal to clockwork versions
/obj/structure/destructible/clockwork/anchoring_crystal/proc/start_turf_conversion()
	var/timer_counter = 1 //used by the addtimer()
	for(var/turf/turf_to_transform in crystal_area)
		if(!clock_theme.can_convert(turf_to_transform))
			continue
		addtimer(CALLBACK(src, PROC_REF(do_turf_conversion), turf_to_transform), 3 * timer_counter)
		timer_counter++

/obj/structure/destructible/clockwork/anchoring_crystal/proc/do_turf_conversion(turf/converted_turf)
	if(QDELETED(src) || !clock_theme.can_convert(converted_turf))
		return

	clock_theme.apply_theme(converted_turf)
	new /obj/effect/temp_visual/ratvar/beam(converted_turf)
	if(istype(converted_turf, /turf/closed/wall))
		new /obj/effect/temp_visual/ratvar/wall(converted_turf)
	else if(istype(converted_turf, /turf/open/floor))
		new /obj/effect/temp_visual/ratvar/floor(converted_turf)

//do all the stuff for finishing charging
/obj/structure/destructible/clockwork/anchoring_crystal/proc/finish_charging()
	send_clock_message(null, span_bigbrass(span_bold("The Anchoring Crystal at [crystal_area] has fully charged! [anchoring_crystal_charge_message(TRUE)]")))
	charge_state = FULLY_CHARGED
	resistance_flags += INDESTRUCTIBLE
	atom_integrity = INFINITY
	set_armor(/datum/armor/immune)
	if(length(GLOB.anchoring_crystals) >= 2)
		priority_announce("Reality in [crystal_area] has been destabilized, all personnel are advised to avoid the area.", \
						  "Central Command Higher Dimensional Affairs", ANNOUNCER_SPANOMALIES, has_important_message = TRUE)

	GLOB.max_clock_power += 1000
	SSshuttle.clearHostileEnvironment(src)
	var/datum/scripture/create_structure/anchoring_crystal/creation_scripture = /datum/scripture/create_structure/anchoring_crystal
	if(locate(creation_scripture) in GLOB.clock_scriptures_by_type)
		creation_scripture = GLOB.clock_scriptures_by_type[creation_scripture]
		creation_scripture.update_info()

	switch(get_charged_anchor_crystals())
		if(1) //add 2 more max servants and increase replica fabricator build speed
			GLOB.main_clock_cult.max_human_servants += SERVANT_CAPACITY_TO_GIVE
		if(ANCHORING_CRYSTALS_TO_SUMMON + 1) //create a steam helios on reebe
			if(length(GLOB.abscond_markers))
				var/turf/created_at = get_turf(pick(GLOB.abscond_markers))
				new /obj/vehicle/sealed/mecha/steam_helios(created_at)
				new /obj/effect/temp_visual/steam(created_at)
			else if(GLOB.clock_ark)
				new /obj/vehicle/sealed/mecha/steam_helios(get_turf(GLOB.clock_ark))
			else
				message_admins("No valid location for Steam Helios creation.")
		if(ANCHORING_CRYSTALS_TO_SUMMON + 2) //lock the anchoring crystal scripture and unlock the golem scripture
			var/datum/scripture/create_structure/anchoring_crystal/crystal_scripture = GLOB.clock_scriptures_by_type[/datum/scripture/create_structure/anchoring_crystal]
			crystal_scripture.unique_lock()

			var/datum/scripture/transform_to_golem/golem_scripture = GLOB.clock_scriptures_by_type[/datum/scripture/transform_to_golem]
			golem_scripture.unique_unlock(TRUE)

//set the shield overlay
/obj/structure/destructible/clockwork/anchoring_crystal/proc/on_update_overlays(atom/crystal, list/overlays)
	SIGNAL_HANDLER

	var/mutable_appearance/shield_appearance = mutable_appearance('monkestation/icons/obj/clock_cult/clockwork_effects.dmi', \
																  overlay_state == SHIELD_BROKEN ? "broken" : "clock_shield", ABOVE_OBJ_LAYER)
	if(overlay_state == SHIELD_DEFLECT)
		shield_appearance.icon_state = "clock_shield_deflect"
		overlay_state = SHIELD_ACTIVE
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 3)
	else if(overlay_state == SHIELD_BREAK)
		shield_appearance.icon_state = "clock_shield_break"
		overlay_state = SHIELD_BROKEN
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 2)
	overlays += shield_appearance

/obj/structure/destructible/clockwork/anchoring_crystal/proc/clear_hostile_environment()
	if(QDELETED(src))
		return

	SSshuttle.clearHostileEnvironment(src)

///return a message based off of what this anchoring crystal did/will do for the cult
/proc/anchoring_crystal_charge_message(completed = FALSE)
	var/message = ""
	switch(get_charged_anchor_crystals())
		if(0)
			message = "[completed ? "We can now" : "We will be able to"] support 2 more servants and gain faster build speed with replica fabricators on reebe."
		if(ANCHORING_CRYSTALS_TO_SUMMON - 1)
			message = "[completed ? "We can now" : "We will be able to"] open the ark."
		if(ANCHORING_CRYSTALS_TO_SUMMON)
			message = "The Steam Helios, a strong 2 pilot mech, [completed ? "has been" : "will be"] summoned to reebe."
		if(ANCHORING_CRYSTALS_TO_SUMMON + 1)
			message = "Humaniod servants [completed ? "may now" : "will be able to"] ascend their form to that of a clockwork golem, giving them innate armor, environmental immunity, \
					   and faster invoking for most scriptures."
	return message

///returns how many charged anchor crystals there are
/proc/get_charged_anchor_crystals()
	var/charged_count = 0
	for(var/obj/structure/destructible/clockwork/anchoring_crystal/checked_crystal in GLOB.anchoring_crystals)
		if(checked_crystal.charge_state == FULLY_CHARGED)
			charged_count++
	return charged_count

#undef CRYSTAL_SHIELD_DELAY
#undef CRYSTAL_CHARGE_TIMER
#undef CRYSTAL_CHARGING
#undef CRYSTAL_LOCATION_ANNOUNCED
#undef FULLY_CHARGED
#undef SHIELD_ACTIVE
#undef SHIELD_DEFLECT
#undef SHIELD_BREAK
#undef SHIELD_BROKEN
#undef SERVANT_CAPACITY_TO_GIVE
