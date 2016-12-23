/* Stellar Engine

A minature star to power the station!

After ignition, the star shines super brightly, requiring eye protection in
order to stop blindness. Everything the star can see is heated up. Everything
that the star touches and touches the star is consumed, and added to its mass.

The star attempts to drift towards the "centre of gravity".
1) If it is in containment, the centre is the centre of the pen.
2) If it is loose, and there is a singularity beacon, the centre is the beacon.
3) If it's loose and there's no beacon, the centre is the middle mass of the
station.
*/

/obj/singularity/minature_star
	name = "minature star"
	desc = "A ball of superhot gas undergoing a self sustaining fusion \
		reaction. It is so hot, it emits electromagnetic radiation in a \
		wide spectrum."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_s1"
	color = "#FFFF00"

	luminosity = 10
	grav_pull = 0

// Heat things that we bump into, and that bump into us

/obj/singularity/minature_star/Bump(atom/A)

/obj/singularity/minature_star/Bumped(atom/A)

/obj/singularity/minature_star/supermatter_eat()
	desc = "[initial(desc)] The light it emits is confusing and hypnotising."
	name = "supermatter-charged [initial(name)]
