/// Trait for tracking if something already has the fake irradiation effect, so we don't waste time on effect operations if otherwise unnecessary
#define TRAIT_RADIOACTIVE_NEBULA_FAKE_IRRADIATED "radioactive_nebula_fake_irradiated"

/// Controls making objects irradiated when Radioactive Nebula is in effect.
SUBSYSTEM_DEF(radioactive_nebula)
	name = "Radioactive Nebula"
	dependencies = list(
		/datum/controller/subsystem/processing/station
	)
	flags = SS_BACKGROUND
	wait = 30 SECONDS

	VAR_PRIVATE
		datum/station_trait/nebula/hostile/radiation/radioactive_nebula

/datum/controller/subsystem/radioactive_nebula/Initialize()
	radioactive_nebula = locate() in SSstation.station_traits
	if (!radioactive_nebula)
		can_fire = FALSE
		return SS_INIT_NO_NEED

	// We don't *really* care that this happens by the time the server is ready to play.
	ASYNC
		irradiate_everything()

	// Don't leak that the station trait has been picked
	return SS_INIT_NO_MESSAGE

/// Makes something appear irradiated for the purposes of the Radioactive Nebula
/datum/controller/subsystem/radioactive_nebula/proc/fake_irradiate(atom/movable/target)
	if (HAS_TRAIT(target, TRAIT_RADIOACTIVE_NEBULA_FAKE_IRRADIATED))
		return

	ADD_TRAIT(target, TRAIT_RADIOACTIVE_NEBULA_FAKE_IRRADIATED, REF(src))

	if(iscarbon(target))//Don't actually make EVERY. SINGLE. THING. RADIOACTIVE. Just irradiate people
		target.AddComponent( \
			/datum/component/radioactive_exposure, \
			minimum_exposure_time = NEBULA_RADIATION_MINIMUM_EXPOSURE_TIME, \
			irradiation_chance_base = RADIATION_EXPOSURE_NEBULA_BASE_CHANCE, \
			irradiation_chance_increment = RADIATION_EXPOSURE_NEBULA_CHANCE_INCREMENT, \
			irradiation_interval = RADIATION_EXPOSURE_NEBULA_CHECK_INTERVAL, \
			source = src, \
			radioactive_areas = radioactive_nebula.radioactive_areas, \
		)
	else if(isobj(target)) //and fake the rest
		//outline clashes too much with other outlines and creates pretty ugly lines
		target.add_filter(GLOW_NEBULA, 2, list("type" = "drop_shadow", "color" = radioactive_nebula.nebula_radglow, "size" = 2))

/datum/controller/subsystem/radioactive_nebula/fire()
	irradiate_everything()

/// Loop through radioactive space (with lag checks) and make it all radioactive!
/datum/controller/subsystem/radioactive_nebula/proc/irradiate_everything()
	for (var/area/area as anything in get_areas(radioactive_nebula.radioactive_areas))
		for (var/list/zlevel_turfs as anything in area.get_zlevel_turf_lists())
			for (var/turf/area_turf as anything in zlevel_turfs)
				for (var/atom/movable/target as anything in area_turf)
					fake_irradiate(target)

			CHECK_TICK

/// Remove the fake radiation. The compontent we add to mobs handles its own removal
/datum/controller/subsystem/radioactive_nebula/proc/fake_unirradiate(atom/movable/leaver)
	REMOVE_TRAIT(leaver, TRAIT_RADIOACTIVE_NEBULA_FAKE_IRRADIATED, REF(src))
	leaver.remove_filter(GLOW_NEBULA)

#undef TRAIT_RADIOACTIVE_NEBULA_FAKE_IRRADIATED
