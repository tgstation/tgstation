/obj/machinery/computer
	name = "computer"
	icon = 'icons/obj/computer.dmi'
	density = 1
	anchored = 1.0
	use_power = 1
	idle_power_usage = 300
	active_power_usage = 300
	var/obj/item/weapon/circuitboard/circuit = null //if circuit==null, computer can't disassembly
	var/processing = 0
	var/brightness_on = 2

/obj/machinery/computer/New(location, obj/item/weapon/circuitboard/C)
	..(location)
	if(C && istype(C))
		circuit = C
	else
		if(circuit)
			circuit = new circuit(null)
	power_change()

/obj/machinery/computer/initialize()
	power_change()

/obj/machinery/computer/process()
	if(stat & (NOPOWER|BROKEN))
		return 0
	return 1

/obj/machinery/computer/emp_act(severity)
	if(prob(20/severity)) set_broken()
	..()


/obj/machinery/computer/ex_act(severity, target)
	if(target == src)
		qdel(src)
		return
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(25))
				qdel(src)
				return
			if (prob(50))
				verbs.Cut()
				set_broken()
		if(3.0)
			if (prob(25))
				verbs.Cut()
				set_broken()
		else
	return

/obj/machinery/computer/bullet_act(var/obj/item/projectile/Proj)
	if(prob(Proj.damage))
		if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
			set_broken()
	..()


/obj/machinery/computer/blob_act()
	if (prob(75))
		verbs.Cut()
		set_broken()
		density = 0

/obj/machinery/computer/update_icon()
	..()
	icon_state = initial(icon_state)
	SetLuminosity(brightness_on)
	// Broken
	if(stat & BROKEN)
		icon_state += "b"

	// Unpowered
	else if(stat & NOPOWER)
		icon_state = initial(icon_state)
		icon_state += "0"
		SetLuminosity(0)



/obj/machinery/computer/power_change()
	..()
	update_icon()
	return

/obj/machinery/computer/proc/set_broken()
	if(circuit) //no circuit, no breaking
		stat |= BROKEN
		update_icon()
	return

/obj/machinery/computer/attackby(I as obj, user as mob, params)
	if(istype(I, /obj/item/weapon/screwdriver) && circuit)
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		user << "<span class='notice'>You start to disconnect the monitor...</span>"
		if(do_after(user, 20))
			var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
			A.circuit = circuit
			A.anchored = 1
			circuit = null
			for (var/obj/C in src)
				C.loc = src.loc
			if (src.stat & BROKEN)
				user << "<span class='notice'>The broken glass falls out.</span>"
				new /obj/item/weapon/shard( src.loc )
				A.state = 3
				A.icon_state = "3"
			else
				user << "<span class='notice'>You disconnect the monitor.</span>"
				A.state = 4
				A.icon_state = "4"
			qdel(src)
	return

/obj/machinery/computer/attack_hand(user)
	. = ..()
	return

/obj/machinery/computer/attack_paw(mob/living/user)
	user.do_attack_animation(src)
	if(circuit)
		if(prob(10))
			user.visible_message("<span class='danger'>[user.name] smashes the [src.name] with its paws.</span>",\
			"<span class='danger'>You smash the [src.name] with your paws.</span>",\
			"<span class='italics'>You hear a smashing sound.</span>")
			set_broken()
			return
	user.visible_message("<span class='danger'>[user.name] smashes against the [src.name] with its paws.</span>",\
	"<span class='danger'>You smash against the [src.name] with your paws.</span>",\
	"<span class='italics'>You hear hear a clicking sound.</span>")

/obj/machinery/computer/attack_alien(mob/living/user)
	user.do_attack_animation(src)
	if(circuit)
		if(prob(80))
			user.visible_message("<span class='danger'>[user.name] smashes the [src.name] with its claws.</span>",\
			"<span class='danger'>You smash the [src.name] with your claws.</span>",\
			"<span class='italics'>You hear a smashing sound.</span>")
			set_broken()
			return
	user.visible_message("<span class='danger'>[user.name] smashes against the [src.name] with its claws.</span>",\
	"<span class='danger'>You smash against the [src.name] with your claws.</span>",\
	"<span class='italics'>You hear a clicking sound.</span>")
