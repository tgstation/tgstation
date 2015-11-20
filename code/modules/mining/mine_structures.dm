/***********************Wall-mounted Lanterns************************/

//Pretty large snowflake overall because it's too different from lights to inherit them
/obj/item/mounted/frame/hanging_lantern_hook
	name = "wall-mounted lantern hook"
	desc = "Attach to wall to create a lantern hanging hook."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "hanginglantern-construct-frame"
	sheets_refunded = 1

/obj/item/mounted/frame/hanging_lantern_hook/do_build(turf/on_wall, mob/user)
	new /obj/structure/hanging_lantern_hook(get_turf(user), get_dir(user, on_wall), 1)
	qdel(src)

/obj/structure/hanging_lantern_hook
	name = "wall-mounted lantern hook"
	desc = "Include a lantern to produce static and reliable lighting."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "hanginglantern-construct"
	anchored = 1
	layer = 5
/obj/structure/hanging_lantern_hook/New(loc, newdir)
	..()
	dir = newdir

/obj/structure/hanging_lantern_hook/attackby(obj/item/weapon/W as obj, mob/user as mob)

	src.add_fingerprint(user)
	if(istype(W, /obj/item/weapon/wrench))
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 75, 1)
		user.visible_message("<span class='warning'>[user] begins deconstructing \the [src].</span>", \
		"<span class='notice'>You begin deconstructing \the [src].</span>")
		if(do_after(user, src, 30))
			new /obj/item/mounted/frame/hanging_lantern_hook(get_turf(user))
			user.visible_message("<span class='warning'>[user] deconstructs \the [src].</span>", \
			"<span class='notice'>You deconstruct \the [src].</span>")
			qdel(src)
	else if(istype(W, /obj/item/device/flashlight/lantern))
		user.visible_message("<span class='notice'>[user] puts \a [W.name] on the \the [src].</span>", \
		"<span class='notice'>You put \a [W.name] on the \the [src].</span>")
		playsound(get_turf(src), 'sound/machines/click.ogg', 20, 1)
		qdel(W)
		var/obj/structure/hanging_lantern/L = new/obj/structure/hanging_lantern(get_turf(src)) // Obligatory "fuck dylan".
		L.dir = dir
		qdel(src)

/obj/structure/hanging_lantern
	name = "wall-mounted lantern"
	desc = "Produces a steady, reliable and warm light in the absence of electricity or even cilivization."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "hanginglantern"
	anchored = 1
	layer = 5
	light_range = 6 //Luminosity of hanging lanterns
	light_power = 2
	light_color = LIGHT_COLOR_TUNGSTEN
	ghost_write = 0 //Can't be too safe
	ghost_read = 0
	var/flickering = 0 //SPOOK

/obj/structure/hanging_lantern/attack_hand(mob/user)

	user.visible_message("<span class='notice'>[user] takes the mining lantern off the \the [src].</span>", \
	"<span class='notice'>You take the mining lantern off the \the [src].</span>")
	playsound(get_turf(src), 'sound/machines/click.ogg', 20, 1)
	new /obj/structure/hanging_lantern_hook(get_turf(src), src.dir)
	var/obj/item/device/flashlight/lantern/lantern = new /obj/item/device/flashlight/lantern(get_turf(src))
	user.put_in_hands(lantern)
	alllights -= src
	qdel(src)

//Direct rip from lights with a few adjustments, not much to worry about since it's not machinery
/obj/structure/hanging_lantern/proc/flicker(var/amount = rand(10, 20))
	if(flickering)
		return
	//Store our light's vars in here
	flickering = 1
	spawn(0)
		for(var/i = 0; i < amount; i++)
			set_light(0)
			spawn(rand(5, 15))
				set_light(6, 2, LIGHT_COLOR_TUNGSTEN)
		set_light(6, 2, LIGHT_COLOR_TUNGSTEN)
	flickering = 0

/obj/structure/hanging_lantern/spook()
	if(..())
		flicker()
