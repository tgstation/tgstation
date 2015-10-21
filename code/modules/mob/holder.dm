// Helper object for picking simple mobs up, mostly ported from Bay.

/obj/item/weapon/holder
	name = "holder"
	desc = "You shouldn't ever see this."
	var/mob/living/storedmob // the mob corresponding to the holder

/mob/living/var/holder_type
/mob/living/proc/get_scooped(var/mob/living/carbon/grabber)
	if(!holder_type || buckled)
		return

	var/obj/item/weapon/holder/H = new holder_type(loc)
	H.storedmob = src
	H.name = loc.name
	grabber.put_in_hands(H)
	src.loc = H
	H.attack_hand(grabber)

	grabber << "<span class='notice'>You scoop up [src].</span>"
	src << "<span class='warning'>[grabber] scoops you up!</span>"
	return

/obj/item/weapon/holder/attackby(obj/item/weapon/W as obj, mob/user as mob)
	for(var/mob/M in src.contents)
		M.attackby(W,user)

/obj/item/weapon/holder/dropped(mob/living/user as mob)
	contents -= storedmob
	storedmob.loc = get_turf(src)
	storedmob.reset_view()
	storedmob.dir = SOUTH //Looks better
	storedmob = null
	qdel(src)
	..()


/obj/item/weapon/holder/proc/escape()
	if(istype(loc, /mob/living))
		var/mob/living/L = loc
		L << "<span class='warning'>[storedmob] is trying to escape!</span>"
		if(!do_after(storedmob, 50, target = L))
			return
		L.unEquip(src)
		L.drop_item()
		L.visible_message("<span class='warning'>[storedmob] wriggles free!</span>")

/obj/item/weapon/holder/relaymove()
	escape()

/obj/item/weapon/holder/container_resist()
	escape()

// Mobs that can be held

/obj/item/weapon/holder/cat
	name = "cat"
	desc = "Kitty!!"
	icon_state = "cat"

/obj/item/weapon/holder/drone
	name = "drone (hiding)"
	desc = "This drone is scared and has curled up into a ball."
	icon = 'icons/mob/drone.dmi'
	icon_state = "drone_maint_hat"
	origin_tech = "magnets=3;engineering=5"