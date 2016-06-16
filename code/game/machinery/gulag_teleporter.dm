/*
The gulag teleporter teleports a prisoner to the gulag outpost.
It automatically strips the prisoner and equips a prisoner ID, prisoner jumpsuit and oranges sneakers.
You can set the amount of points in the console
The console is located at computer/gulag_teleporter.dm
*/

//Gulag teleporter
/obj/machinery/gulag_teleporter
	name = "labor camp teleporter"
	desc = "A bluespace teleporter used for teleporting prisoners to the labor camp."
	icon = 'icons/obj/machines/implantchair.dmi'
	icon_state = "implantchair"
	state_open = 0
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 200
	active_power_usage = 5000
	var/locked = FALSE
	var/list/stored_items = list()
	var/jumpsuit_type = /obj/item/clothing/under/rank/prisoner
	var/shoes_type = /obj/item/clothing/shoes/sneakers/orange

/obj/machinery/gulag_teleporter/interact(mob/user)
	if(locked)
		user << "[src] is locked."
		return
	toggle_open()

/obj/machinery/gulag_teleporter/updateUsrDialog()
	return

/obj/machinery/gulag_teleporter/update_icon()
	//no power or maintenance -- no sprites currently
/*	if(stat & (NOPOWER|BROKEN))
		icon_state = initial(icon_state) + (state_open ? "_open" : "") + "_unpowered"
		return

	if((stat & MAINT) || panel_open)
		icon_state = initial(icon_state) + (state_open ? "_open" : "") + "_maintenance"
		return */

	//running and someone in there
	if(occupant)
		icon_state = initial(icon_state) + "_occupied"
		return

	//open/closed with no occupant
	icon_state = initial(icon_state) + (state_open ? "_open" : "")

/obj/machinery/gulag_teleporter/relaymove(mob/user)
	if(user.stat != CONSCIOUS)
		return
	if(locked)
		user << "[src] is locked!"
	open_machine()

/obj/machinery/gulag_teleporter/container_resist(mob/living/user)
	var/breakout_time = 600
	if(!locked)
		open_machine()
		return
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user << "<span class='notice'>You lean on the back of [src] and start pushing the door open... (this will take about a minute.)</span>"
	user.visible_message("<span class='italics'>You hear a metallic creaking from [src]!</span>")

	if(do_after(user,(breakout_time), target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src || state_open || !locked)
			return

		locked = FALSE
		visible_message("<span class='warning'>[user] successfully broke out of [src]!</span>")
		user << "<span class='notice'>You successfully break out of [src]!</span>"

		open_machine()

/obj/machinery/gulag_teleporter/proc/toggle_open(mob/user)
	/*if(panel_open)
		user << "<span class='notice'>Close the maintenance panel first.</span>"
		return
	*/
	if(state_open)
		close_machine()
		return

	open_machine()

// strips and stores all occupant's items
/obj/machinery/gulag_teleporter/proc/strip_occupant()
	stored_items[occupant] = list()
	for(var/obj/item/W in occupant)
		if(occupant.unEquip(W))
			stored_items[occupant] += W
			W.loc = null //temporary

//drops mob's item
/obj/machinery/gulag_teleporter/proc/drop_items(mob/prisoner)
	if(!stored_items[prisoner])
		return
	for(var/i in stored_items[prisoner])
		var/obj/item/W = i
		stored_items[prisoner] -= W
		W.forceMove(get_turf(src))

/obj/machinery/gulag_teleporter/proc/handle_prisoner(obj/item/id, datum/data/record/R)
	if(!ishuman(occupant))
		return
	strip_occupant()
	var/mob/living/carbon/human/prisoner = occupant
	if(jumpsuit_type)
		prisoner.equip_to_appropriate_slot(new jumpsuit_type)
	if(shoes_type)
		prisoner.equip_to_appropriate_slot(new shoes_type)
	if(id)
		prisoner.equip_to_appropriate_slot(id)
	if(R)
		R.fields["criminal"] = "Incarcerated"

//beacon that receives the teleported prisoner
/obj/structure/gulag_beacon
	name = "labor camp bluespace receiver pad"
	desc = "A recieving zone for bluespace teleportations."
	icon = 'icons/turf/floors.dmi'
	icon_state = "light_on-w"