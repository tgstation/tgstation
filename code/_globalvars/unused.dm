var/dna_ident = 1 // unused global variable
var/shuttle_z = 2	//unused, was written to by a shuttle landmark
var/list/reg_dna = list(  ) // unused, was written to when making unique DNA

	/////////////// old events system global variables
var/eventchance = 3 //% per 5 mins
var/event = 0
var/hadevent = 0
var/blobevent = 0
	///////////////
var/skipupdate = 0
var/list/jobMax = list()
var/forceblob = 0
var/shuttlecoming = 0
var/datum/debug/debugobj

var/list/liftable_structures = list(
	/obj/machinery/autolathe,
	/obj/machinery/constructable_frame,
	/obj/machinery/hydroponics,
	/obj/machinery/computer,
	/obj/structure/optable,
	/obj/structure/dispenser,
	/obj/machinery/gibber,
	/obj/machinery/microwave,
	/obj/machinery/vending,
	/obj/machinery/seed_extractor,
	/obj/machinery/space_heater,
	/obj/machinery/recharge_station,
	/obj/machinery/flasher,
	/obj/structure/stool,
	/obj/structure/closet,
	/obj/machinery/photocopier,
	/obj/structure/filingcabinet,
	/obj/structure/reagent_dispensers,
	/obj/machinery/portable_atmospherics/canister
	)