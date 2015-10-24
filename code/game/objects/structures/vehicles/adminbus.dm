///////////////////////////////////////////////////////////////
//Deity Link, giving a new meaning to the Adminbus since 2014//
///////////////////////////////////////////////////////////////
/*
#define MAX_CAPACITY 16

/obj/structure/bed/chair/vehicle/adminbus//Fucking release the passengers and unbuckle yourself from the bus before you delete it.
	name = "\improper Adminbus"
	desc = "Shit just got fucking real."
	icon = 'icons/obj/bus.dmi'
	icon_state = "adminbus"
	can_spacemove=1
	layer = FLY_LAYER+1
	pixel_x = -32
	pixel_y = -32
	var/can_move=1
	var/list/passengers = list()
	var/unloading = 0
	var/bumpers = 1//1=capture mobs 2=roll over mobs(deals light brute damage and push them down) 3=gib mobs
	var/door_mode = 0//0=closed door, players cannot climb or leave on their own 1=openned door, players can climb and leave on their own
	var/list/spawned_mobs = list()//keeps track of every mobs spawned by the bus, so we can remove them all with the push of a button in needed
	var/hook = 1
	var/list/hookshot = list()
	var/obj/structure/singulo_chain/chain_base = null
	var/list/chain = list()
	var/obj/machinery/singularity/singulo = null
	var/roadlights = 0
	var/obj/structure/buslight/lightsource = null
	var/list/spawnedbombs = list()
	var/list/spawnedlasers = list()
	var/obj/structure/teleportwarp/warp = null
	var/obj/machinery/media/jukebox/superjuke/adminbus/busjuke = null

/*

Shit's not done. Needs missiles and new rims.