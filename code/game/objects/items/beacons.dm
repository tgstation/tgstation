///The all new home for beacons that spawn objects, structures, atoms, whatever to the station via supply pods.
/obj/item/sup_beacon
	name = "beacon"
	desc = "N.T. approved supply beacon, but this one shouldn't exist!"
	icon = 'icons/obj/objects.dmi'
	icon_state = "supply_beacon"
	///Has the beacon been used already?
	var/used
	///What is the thing this beacon sends to the station?
	var/obj/beacon_contents = /obj/item/reagent_containers/food/snacks/cookie

/obj/item/sup_beacon/attack_self()
	if(used)
		return
	loc.visible_message("<span class='warning'>\The [src] begins to beep loudly!</span>")
	used = TRUE
	addtimer(CALLBACK(src, .proc/launch_payload), 40)

/**
  * Creates a new beacon_contents object, shoves it in a supply pod, and launches it at the station from nullspace.
  */
/obj/item/sup_beacon/proc/launch_payload()
	var/obj/structure/closet/supplypod/centcompod/toLaunch = new()
	if(!beacon_contents)
		return
	new beacon_contents(toLaunch)
	new /obj/effect/pod_landingzone(drop_location(), toLaunch)
	qdel(src)

//******SERVICE EQUIPMENT******

///Roulette wheel
/obj/item/sup_beacon/roulette
	name = "roulette wheel beacon"
	desc = "N.T. approved roulette wheel beacon, toss it down and you will have a complementary roulette wheel delivered to you."
	beacon_contents = /obj/machinery/roulette

///Beer Dispenser
/obj/item/sup_beacon/beer_dispenser
	name = "beer dispenser beacon"
	desc = "N.T. approved alcohol dispenser beacon, toss it down and you'll have a fully ready bar in no time. Remember to ID everyone!"
	beacon_contents = /obj/machinery/chem_dispenser/drinks/beer

///Soda Dispenser
/obj/item/sup_beacon/soda_dispenser
	name = "soda dispenser beacon"
	desc = "N.T. approved soda dispenser beacon, toss it down and you'll have a fully ready drink station. Drink cola to feel SUPER!"
	beacon_contents = /obj/machinery/chem_dispenser/drinks

///Microwave
/obj/item/sup_beacon/microwave
	name = "microwave beacon"
	desc = "N.T. approved microwave beacon, toss it down and you'll have a fully ready kitchen. Okay, well not FULLY ready, but it worked in college, right?"
	beacon_contents = /obj/machinery/microwave

///Food processor
/obj/item/sup_beacon/processor
	name = "food processor beacon"
	desc = "N.T. approved food processor beacon, toss it down and you'll have a fully ready food prep machine. It slices, it dices, it even makes julianne fries!"
	beacon_contents = /obj/machinery/processor

/obj/item/sup_beacon/hydroponics
	name = "hydroponics tray beacon"
	desc = "N.T. approved hydroponics tray beacon, toss it down and you'll have a fully ready hydroponics tray. Grow's just about anything the stomache desires."
	beacon_contents = /obj/machinery/hydroponics

//******Medical******

///Statis Bed
/obj/item/sup_beacon/stasis
	name = "stasis bed beacon"
	desc = "N.T. approved stasis bed beacon, toss it down and you'll have a fully ready statis bed. Turn anywhere into an operating theator! Or don't!"
	beacon_contents = /obj/machinery/stasis

/obj/item/sup_beacon/chem_dispenser
	name = "chemistry dispenser beacon"
	desc = "N.T. approved chemistry dispenser beacon, toss it down and you'll have a fully ready chemistry dispenser. Faster than starting an inter-departmental warzone!"
	beacon_contents = /obj/machinery/chem_dispenser

/obj/item/sup_beacon/chem_heater
	name = "chemistry heater beacon"
	desc = "N.T. approved chemistery heater beacon, toss it down and you'll have a fully ready chemistry heater. Infinitely safer than doing it on the stove."
	beacon_contents = /obj/machinery/chem_heater

/obj/item/sup_beacon/chem_master
	name = "chemistry master beacon"
	desc = "N.T. approved chemistry master beacon, toss it down and you'll have a fully ready chemistry master. Even we don't know where all those little bottles come from."
	beacon_contents = /obj/machinery/chem_master

//******Engineering******

/obj/item/sup_beacon/emitter
	name = "emitter beacon"
	desc = "N.T. approved emitter beacon, toss it down and you'll have a fully ready laser emitter. Turn those rookie engine numbers into some BIG rookie numbers."
	beacon_contents = /obj/machinery/power/emitter

/obj/item/sup_beacon/freezer
	name = "atmospherics freezer beacon"
	desc = "N.T. approved freezer beacon, toss it down and you'll have a fully ready atmospherics freezer. Keep cool, "
	beacon_contents = /obj/machinery/atmospherics/components/unary/thermomachine/freezer

//******Security******

/obj/item/sup_beacon/weapon_recharger
	name = "weapon recharger beacon"
	desc = "N.T. approved weapon recharger beacon, toss it down and you'll have a fully ready recharger. Makes short work of shorter stunpod cells."
	beacon_contents = /obj/machinery/recharger

/obj/item/sup_beacon/cameras
	name = "camera console beacon"
	desc = "N.T. approved camera console beacon, toss it down and you'll have a fully ready camera console. Home survailance... anywhere!"
	beacon_contents = /obj/machinery/computer/security

