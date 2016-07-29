/*
BS12 object based lighting system
*/

/*
Changes from TG DAL:
  -	Lighting is done using objects instead of subareas.
  - Animated transitions. (newer TG DAL has this)
  - Full colours with mixing.
  - Support for lights on shuttles.

  - Code:
	  - Instead of one flat luminosity var, light is represented by 3 atom vars:
		  - light_range; range in tiles of the light, used for calculating falloff,
		  - light_power; multiplier for the brightness of lights,
		  - light_color; hex string representing the RGB colour of the light.
	  - SetLuminosity() is now set_light() and takes the three variables above.
		  - Variables can be left as null to not update them.
	  - SetOpacity() is now set_opacity().
	  - Areas have luminosity set to 1 permanently, no hard-lighting.
	  - Objects inside other objects can have lights and they properly affect the turf. (flashlights)
	  - area/master and area/list/related have been eviscerated since subareas aren't needed.
*/

/*
Relevant vars/procs:

global: (uh, I placed the only one in lighting_system.dm)
  - var/list/all_lighting_overlays; Just a list of ALL of the lighting overlays.

atom: (lighting_atom.dm)
  - var/light_range; range in tiles of the light, used for calculating falloff
  - var/light_power; multiplier for the brightness of lights
  - var/light_color; hex string representing the RGB colour of the light

  - var/datum/light_source/light; light source datum for this atom, only present if light_range && light_power
  - var/list/light_sources; light sources in contents that are shining through this object, including this object

  - proc/set_light(l_range, l_power, l_color):
	  - Sets light_range/power/color to non-null args and calls update_light()
  - proc/set_opacity(new_opacity):
	  - Sets opacity to new_opacity.
	  - If opacity has changed, call turf.reconsider_lights() to fix light occlusion
  - proc/update_light():
	  - Updates the light var on this atom, deleting or creating as needed and calling .update()


turf: (lighting_turf.dm)
  - var/list/affecting_lights; list of light sources that are shining onto this turf
  - var/list/lighting_overlays; list of lighting overlays in the turf. (only used if higher resolutions
  - var/lighting_overlay; ref to the lighting overlay (only used if resolution is 1)

  - proc/reconsider_lights():
	  - Force all light sources shining onto this turf to update

  - proc/lighting_clear_overlays():
	  - Delete (manual GC) all light overlays on this turf, used when changing turf to space
  - proc/lighting_build_overlays():
	  - Create lighting overlays for this turf
  - proc/get_lumcount(var/minlum = 0, var/maxlum = 1)
  	  - Returns a decimal according to the amount of lums on a turf's overlay (also averages them)
  	  - With default arguments (based on the fact that 0 = pitch black and 1 = full bright), it will return .5 for a 50% lit tile.

atom/movable/lighting_overlay: (lighting_overlay.dm)
  - var/lum_r, var/lum_g, var/lum_b; lumcounts of each colour
  - var/needs_update; set on update_lumcount, checked by lighting process

  - var/xoffset, var/yoffset; (only present when using sub-tile overlays) fractional offset of this overlay in the tile

  - proc/update_lumcount(delta_r, delta_g, delta_b):
      - Change the lumcount vars and queue the overlay for update
  - proc/update_overlay()
	  - Called by the lighting process to update the color of the overlay
*/
