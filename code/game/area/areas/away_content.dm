/*
Unused icons for new areas are "awaycontent1" ~ "awaycontent30"
*/


// Away Missions
/area/awaymission
	name = "Strange Location"
	icon_state = "away"
	has_gravity = STANDARD_GRAVITY
	ambientsounds = AWAY_MISSION

/area/awaymission/beach
	name = "Beach"
	icon_state = "away"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	ambientsounds = list('sound/ambience/sea_shanty2.ogg')

/area/awaymission/errorroom
	name = "Super Secret Room"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	has_gravity = STANDARD_GRAVITY

/area/awaymission/vr
	name = "Virtual Reality"
	icon_state = "awaycontent1"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	var/pacifist = TRUE // if when you enter this zone, you become a pacifist or not
	var/death = FALSE // if when you enter this zone, you die

/area/awaymission/mrboneswildride
	name = "House of Spooks"
	icon_state = "SPOOKEDYA"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	ambientsounds = list('sound/ambience/sea_shanty2.ogg')

/area/awaymission/mrboneswildride/Entered(atom/movable/M)
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/doomed = M
		var/list/not_bones = doomed.GetAllContents()
		for(var/obj/item/teleportation_scroll/way_out in not_bones)
			qdel(way_out)