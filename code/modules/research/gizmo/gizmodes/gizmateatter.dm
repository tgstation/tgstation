// When activated, trying to find the item of material(which will be taken from random-weighed pool)
// and then - pulling its into itself
// and starting the producement sound, like shredding or something
// after 10 seconds - threw out new material sheet(its also can be anything, but with weights)
// So its material transofer, its more chances to get smth like 10 metall sheets -> 5 glass
// but its also possible to roll like Plasma -> Hautium\Zaukerit   but chances are low
// The configuration is setted to one gizmo, when its spawned(initialized)
/datum/gizmodes/material_eatter
	guaranteed_active_gizmodes = list(/datum/gizpulse/mood_pulser/positive, /datum/gizpulse/mood_pulser/negative)
	possible_active_modes = list(
		/datum/gizpulse/radiation_pulse = 1,
	)

    // reference to gizmo machinery object itself, to use it like a target\turf, to which materials are pulled
    var/gizmo_machine = controller.gizmo

/datum/gizpulse/material_eatter

/datum/gizpulse/material_eatter/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
    nearest_input_object = gizmo.find_the_nearest_object_of_the_material()

/datum/gizpulse/pie_thrower/proc/find_the_nearest_object_of_the_material(atom/movable/holder)
