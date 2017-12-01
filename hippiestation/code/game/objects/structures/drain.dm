/obj/structure/drain
	name = "drain"
	desc = "Hooked up to a discrete series of underfloor pipes that lead...somewhere. High viscosity liquids may cause clogging."
	icon = 'hippiestation/icons/obj/drain.dmi'
	icon_state = "drain"
	density = FALSE
	anchored = TRUE
	layer = GAS_SCRUBBER_LAYER
	max_integrity = 400//it's small and made of thick strong metal
	var/can_weld_shut = TRUE
	var/datum/looping_sound/drain/soundloop
	var/counter = 0

/obj/structure/drain/Initialize()
	. =..()
	soundloop = new(list(src), FALSE)

/obj/structure/drain/process()
	soundloop.start()
	counter++
	for(var/obj/effect/liquid/L in view(4, src))
		if(!L.is_static && L.viscosity)
			var/chance = Clamp(50 / L.viscosity, 15, 100)
			if(get_dist(src,L) < 2)
				qdel(L)
			else if(prob(chance))
				step_to(L, src)
	if(counter > 25 || !can_weld_shut)
		STOP_PROCESSING(SSobj, src)
		counter = 0
		soundloop.stop()

/obj/structure/drain/attackby(obj/item/I,  mob/user, params)
	if(istype(I, /obj/item/weldingtool) && can_weld_shut)
		var/obj/item/weldingtool/WT = I
		if(WT.remove_fuel(0, user))
			to_chat(user, "<span class='notice'>You begin welding \the [src] shut...</span>")
			playsound(src, 'sound/items/welder.ogg', 40, 1)
			if(do_after(user, 100*WT.toolspeed, 1, target = src))
				if(!WT.isOn())
					return
				playsound(src, 'sound/items/welder.ogg', 50, 1)
				user.visible_message("<span class='notice'>[user] seals \the [src] shut.</span>")
				can_weld_shut = FALSE
				desc += " It looks permanently sealed!"
		return
	..()

/obj/structure/drain/AltClick(mob/living/user)
	if(isobserver(user))
		return

	if (!user.canUseTopic(src))
		to_chat(user, "<span class='info'>You can't do this right now!</span>")
		return
	if(!isprocessing)
		to_chat(user, "<span class='info'>You activate [src] via a digital switch.</span>")
		START_PROCESSING(SSobj, src)
	else
		to_chat(user, "<span class='info'>[src] is already active!</span>")

/obj/structure/drain/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()