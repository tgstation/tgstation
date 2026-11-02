// Ratwood update_see_sky() (game/turfs/turf.dm, change_turf.dm): a roof built during the round shades what lies under it from
// the sun and the weather, and one taken down lets the sky in again. The map's sky is laid out when the map is built
// (build/prepare_rockhill.ts applySunlight()): a turf under the open sky lies in the sunlit part of its area,
// <area>/sunlit (rockhill/sunlight.dm). Here a turf that gains or loses the sky moves between its area and that sunlit part
// with TG's set_turf_to_area(): its base light, the light library's turf data (lighting_build_overlay() and
// lighting_clear_overlay(), lighting/overrides.dm), the weather that falls on the sunlit areas (rockhill/weather.dm) and
// the crops that need the sky (farming/config.dm) follow the area. The sun's border is rebuilt around the turf: a sky turf
// next to a shaded one is a sun emitter (GLOB.rockhill_sun_emitters, the sun channel of the light library, lighting/sun.dm).

/// How many levels down from a changed turf the sky is looked at again (Ratwood: 5).
#define ROCKHILL_SKY_DEPTH 5

/// Ratwood ChangeTurf(): when a turf turns into open space or open space into a floor, the turfs under it look at the sky
/// again. Only on the Rockhill map's areas, and only during the round: the map's own sky is laid out when it is built.
/turf/AfterChange(flags, oldType)
	. = ..()
	if(!istype(loc, /area/rogue) || SSatoms.initialized != INITIALIZATION_INNEW_REGULAR)
		return
	if(!isopenspaceturf(src) && !ispath(oldType, /turf/open/openspace))
		return
	var/turf/current = src
	for(var/level in 0 to ROCKHILL_SKY_DEPTH)
		if(!current)
			break
		current.rockhill_update_sky()
		current = GET_TURF_BELOW(current)

/// Ratwood can_see_sky() by the map builder's rule: an open turf sees the sky when every turf above it up to the top level is
/// open space and the top one lies in an outdoor area.
/turf/proc/rockhill_sees_sky()
	if(isclosedturf(src))
		return FALSE
	var/turf/top = src
	var/turf/above = GET_TURF_ABOVE(top)
	while(above)
		if(!isopenspaceturf(above))
			return FALSE
		top = above
		above = GET_TURF_ABOVE(top)
	var/area/top_area = top.loc
	return top_area.outdoors

/// Ratwood update_see_sky(): the turf moves into the sunlit part of its area when it sees the sky, back into the area when
/// it no longer does, and the sun's border around it is rebuilt.
/turf/proc/rockhill_update_sky()
	var/area/rogue/here = loc
	if(!istype(here))
		return
	var/sees_sky = rockhill_sees_sky()
	if(sees_sky == here.rockhill_sunlit)
		return
	var/target_type = sees_sky ? text2path("[here.type]/sunlit") : here.parent_type
	if(!ispath(target_type, /area/rogue))
		return
	// The area the map has, or a new one when no turf of the map lay in it yet (the sunlit part of a house).
	var/area/rogue/target = GLOB.areas_by_type[target_type]
	var/created = !target
	if(created)
		target = new target_type
	if(target.rockhill_sunlit != sees_sky)
		return
	set_turf_to_area(src, target)
	if(created)
		target.reg_in_areas_in_z()
		require_area_resort()
	for(var/turf/near as anything in RANGE_TURFS(1, src))
		near.rockhill_update_sun_emitter()

/// Ratwood's sun on the edge of the sky (rockhill/sunlight.dm, /area/rogue/LateInitialize()): a sky turf next to a shaded one
/// shines into it on the light library's sun channel; one that no longer borders the shade, or lost the sky, stops.
/turf/proc/rockhill_update_sun_emitter()
	var/area/rogue/here = loc
	var/should_shine = FALSE
	if(istype(here) && here.rockhill_sunlit)
		for(var/turf/neighbor as anything in RANGE_TURFS(1, src))
			var/area/rogue/neighbor_area = neighbor.loc
			if(istype(neighbor_area) && !neighbor_area.rockhill_sunlit)
				should_shine = TRUE
				break
	var/shines = rogue_light_channel == ROGUE_LIGHT_CHANNEL_SUN
	if(should_shine == shines)
		return
	if(should_shine)
		GLOB.rockhill_sun_emitters += src
		rogue_light_channel = ROGUE_LIGHT_CHANNEL_SUN
		rockhill_light_emitter(src, GLOB.starlight_color)
		return
	GLOB.rockhill_sun_emitters -= src
	set_light(l_on = FALSE)
	rogue_light_channel = ROGUE_LIGHT_CHANNEL_LAMP

#undef ROCKHILL_SKY_DEPTH
