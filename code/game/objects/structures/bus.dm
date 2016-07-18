/obj/structure/bus/
	name = "bus"
	desc = "GO TO SCHOOL. READ A BOOK."
	icon = 'icons/obj/bus.dmi'
	density = 1
	anchored = 1

/obj/structure/bus/dense
	name = "bus"
	icon_state = "backwall"

/obj/structure/bus/passable
	name = "bus"
	icon_state = "frontwalltop"
	density = 0
	layer = ABOVE_ALL_MOB_LAYER //except for the stairs tile, which should be set to OBJ_LAYER aka 3.


/obj/structure/bus/passable/seat
	name = "seat"
	desc = "Buckle up! ...What do you mean, there's no seatbelts?!"
	icon_state = "backseat"
	pixel_y = 17
	layer = OBJ_LAYER


/obj/structure/bus/passable/seat/driver
	name = "driver's seat"
	desc = "Space Jesus is my copilot."
	icon_state = "driverseat"

/obj/structure/bus/passable/seat/driver/attack_hand(mob/user)
	playsound(src.loc, 'sound/items/carhorn.ogg', 50, 1)