
//---------- actual energy field

/obj/effect/energy_field
	name = "energy field"
	desc = "Impenetrable field of energy, capable of blocking anything as long as it's active."
	icon = 'code/WorkInProgress/Cael_Aislinn/ShieldGen/shielding.dmi'
	icon_state = "shieldsparkles"
	anchored = 1
	layer = 4.1		//just above mobs
	density = 0
	invisibility = 101
	var/strength = 0

/obj/effect/energy_field/ex_act(var/severity)
	Stress(0.5 + severity)

/obj/effect/energy_field/bullet_act(var/obj/item/projectile/Proj)
	Stress(Proj.damage / 10)

/obj/effect/energy_field/meteorhit(obj/effect/meteor/M as obj)
	if(M)
		walk(M,0)
		Stress(2)

/obj/effect/energy_field/proc/Stress(var/severity)
	strength -= severity

	//if we take too much damage, drop out - the generator will bring us back up if we have enough power
	if(strength < 1)
		invisibility = 101
		density = 0
	else if(strength >= 1)
		invisibility = 0
		density = 1

/obj/effect/energy_field/proc/Strengthen(var/severity)
	strength += severity

	//if we take too much damage, drop out - the generator will bring us back up if we have enough power
	if(strength >= 1)
		invisibility = 0
		density = 1
	else if(strength < 1)
		invisibility = 101
		density = 0

/obj/effect/energy_field/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	//Purpose: Determines if the object (or airflow) can pass this atom.
	//Called by: Movement, airflow.
	//Inputs: The moving atom (optional), target turf, "height" and air group
	//Outputs: Boolean if can pass.

	//return (!density || !height || air_group)
	return !density
