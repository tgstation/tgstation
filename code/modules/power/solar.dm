#define SOLAR_MAX_DIST 40
#define SOLARGENRATE 1500 // upgrade factor can happen later, regular solars start with rglass panels

var/list/solars_list = list()

/obj/machinery/power/solar
	icon = 'icons/obj/power.dmi'
	density = 1

/obj/machinery/power/solar/New(loc)
	..(loc)
	solars_list += src

	if(ticker)
		initialize()

/obj/machinery/power/solar/Destroy()
	solars_list -= src
	..()

/obj/machinery/power/solar/initialize()
	..()
	connect_to_network()

// this is here because it is fucking here. If you found this, you're lucky !
/obj/item/weapon/paper/solar
	name = "paper - 'Going green with Greencorps! Instrunctions on setting up your own solar array.'"
	info = "<h1>Welcome</h1><p>We at Greencorps we love the environment, and space. With this package you will help mother nature and produce energy without using fossil fuel or plasma! The Singularity Engine is dangerous while solar energy is safe, which is why it's better. Now here is how you setup your own solar array.</p><p>You can make a solar panel by wrenching the solar assembly onto a cable node. Add a glass panel, reinforced or regular glass will do, which will finish the construction of your solar panel. It's that easy!.</p><p>Now after setting up 19 more of these solar panels you will want to create a solar tracker to keep track of mother nature's gift, the sun. These are the same steps as before except you insert the tracker equipment circuit into the assembly before performing the final step of adding the glass. You now have a tracker! Now the last step is to add a computer to calculate the sun's movements and to send commands to the solar panels to change direction with the sun. Setting up the solar computer is the same as setting up any computer, so you should have no trouble in doing that. You do need to put a wire node under the computer, and the wire needs to be connected to the tracker.</p><p>Congratulations, you should have a working solar array. If you are having trouble, here are some tips. Make sure all solar equipment are on a cable node, even the computer. You can always deconstruct your creations if you make a mistake.</p><p>That's all to it, be safe, be green!</p>"

//Solar Assembly - For construction of solar arrays
/obj/machinery/power/solar_assembly
	name = "solar panel assembly"
	desc = "A solar panel assembly kit, allows constructions of a solar panel, or with a tracking circuit board, a solar tracker"
	icon = 'icons/obj/power.dmi'
	icon_state = "sp_base"
	anchored = 0
	density = 0
	var/tracker = 0
	var/glass_type = null

//Give back the glass type we were supplied with
/obj/machinery/power/solar_assembly/proc/give_glass() //And the lord said unto him, 'Give that fucker glass'
	if(glass_type)
		var/obj/item/stack/sheet/S = new glass_type(get_turf(src))
		S.amount = 2
		glass_type = null //Memory vars ho !

/obj/machinery/power/solar_assembly/attackby(var/obj/item/weapon/W, var/mob/user)
	if(!anchored && isturf(loc))
		if(iswrench(W))
			anchored = 1
			density = 1
			user.visible_message("<span class='notice'>[user] wrenches [src] down.</span>", \
			"<span class='notice'>You wrench [src] down.</span>")
			playsound(get_turf(src), 'sound/items/Ratchet.ogg', 75, 1)
			return 1
	else
		if(iswrench(W))
			anchored = 0
			density = 0
			user.visible_message("<span class='notice'>[user] unwrenches [src] from the ground.</span>", \
			"<span class='notice'>You unwrench [src] from the ground.</span>")
			playsound(get_turf(src), 'sound/items/Ratchet.ogg', 75, 1)
			return 1

		if(istype(W, /obj/item/stack/sheet/glass))
			var/obj/item/stack/sheet/glass/S = W
			if(S.amount >= 2)
				glass_type = W.type
				S.use(2)
				playsound(get_turf(src), 'sound/machines/click.ogg', 50, 1)
				user.visible_message("<span class='notice'>[user] carefully adds glass to [src].</span>", \
				"<span class='notice'>You carefully add glass to [src].</span>")
				if(tracker)
					new /obj/machinery/power/solar/panel/tracker(get_turf(src), src)
				else
					new /obj/machinery/power/solar/panel(get_turf(src), src)
			else
				user << "<span class='notice'>You lack enough [W.type] to finish the solar.</span>"
			return 1

	if(!tracker)
		if(istype(W, /obj/item/weapon/tracker_electronics))
			tracker = 1
			user.drop_item()
			qdel(W)
			user.visible_message("<span class='notice'>[user] inserts the electronics into [src].</span>", \
			"<span class='notice'>You insert the electronics into [src].</span>")
			return 1
	else
		if(iscrowbar(W))
			new /obj/item/weapon/tracker_electronics(src.loc)
			tracker = 0
			user.visible_message("<span class='notice'>[user] takes the electronics out of [src].</span>", \
			"<span class='notice'>You take the electronics out of [src].</span>")
			return 1
	..()