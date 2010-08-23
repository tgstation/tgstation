/* new portable generator - work in progress

/obj/machinery/power/port_gen
	name = "portable generator"
	desc = "A portable generator used for emergency backup power."
	icon = 'generator.dmi'
	icon_state = "off"
	density = 1
	anchored = 0
	directwired = 0
	var/t_status = 0
	var/t_per = 5000
	var/filter = 1
	var/tank = null
	var/turf/inturf
	var/starter = 0
	var/rpm = 0
	var/rpmtarget = 0
	var/capacity = 1e6
	var/turf/outturf
	var/lastgen


/obj/machinery/power/port_gen/process()
ideally we're looking to generate 5000

/obj/machinery/power/port_gen/attackby(obj/item/weapon/W, mob/user)
tank [un]loading stuff

/obj/machinery/power/port_gen/attack_hand(mob/user)
turn on/off

/obj/machinery/power/port_gen/examine()
display round(lastgen) and plasmatank amount

*/