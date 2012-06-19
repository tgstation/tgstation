
//---------- actual energy field

/obj/effect/energy_field
	name = "energy field"
	desc = "Impenetrable field of energy, capable of blocking anything as long as it's active."
	icon = 'shielding.dmi'
	icon_state = "shieldsparkles"
	anchored = 1
	layer = 2.1
	density = 0
	invisibility = 2
	var/strength = 0
	var/obj/machinery/shield_gen/parent
	var/stress = 0

/obj/effect/energy_field/ex_act(var/severity)
	Stress(2)
	//nothing

/obj/effect/energy_field/meteorhit(obj/effect/meteor/M as obj)
	if(M)
		walk(M,0)

/obj/effect/energy_field/proc/Stress(var/severity)
	strength -= severity
	stress += severity

	//if we take too much damage, drop out - the generator will bring us back up if we have enough power
	if(strength < 1)
		invisibility = 2
		density = 0

/obj/effect/energy_field/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	//Purpose: Determines if the object (or airflow) can pass this atom.
	//Called by: Movement, airflow.
	//Inputs: The moving atom (optional), target turf, "height" and air group
	//Outputs: Boolean if can pass.

	//return (!density || !height || air_group)
	return 0
