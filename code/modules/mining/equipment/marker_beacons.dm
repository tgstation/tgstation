/*****************Marker Beacons**************************/
/obj/item/stack/marker_beacon
	name = "marker beacon"
	singular_name = "marker beacon"
	desc = "Canary-brand path illumination devices. Used by miners to mark paths and warn of danger."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "markerbeacon"
	merge_type = /obj/item/stack/marker_beacon
	max_amount = 100

/obj/item/stack/marker_beacon/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Use in-hand to place a [singular_name].</span>")

/obj/item/stack/marker_beacon/ten //miners start with 10 of these
	amount = 10

/obj/item/stack/marker_beacon/thirty //and they're bought in stacks of 1, 10, or 30
	amount = 30

/obj/item/stack/marker_beacon/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>You need more space to place a [singular_name] here.</span>")
		return
	if(locate(/obj/structure/marker_beacon) in user.loc)
		to_chat(user, "<span class='warning'>There is already a [singular_name] here.</span>")
		return
	if(use(1))
		to_chat(user, "<span class='notice'>You activate and anchor [amount ? "a":"the"] [singular_name] in place.</span>")
		playsound(user, 'sound/machines/click.ogg', 50, 1)
		var/obj/structure/marker_beacon/M = new /obj/structure/marker_beacon(user.loc)
		transfer_fingerprints_to(M)

/obj/structure/marker_beacon
	name = "marker beacon"
	desc = "A Canary-brand path illumination device. It is anchored in place and glowing steadily."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "markerbeacon-on"
	layer = BELOW_OPEN_DOOR_LAYER
	anchored = TRUE
	light_range = 2
	light_power = 3
	light_color = LIGHT_COLOR_FLARE

/obj/structure/marker_beacon/attack_hand(mob/living/user)
	to_chat(user, "<span class='notice'>You start picking [src] up...</span>")
	if(do_after(user, 20, target = src))
		var/obj/item/stack/marker_beacon/M = new(loc)
		transfer_fingerprints_to(M)
		if(user.put_in_hands(M, TRUE)) //delete the beacon if it fails
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			qdel(src) //otherwise delete us
