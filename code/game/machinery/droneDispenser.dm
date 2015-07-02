/obj/machinery/droneDispenser
	name = "drone shell dispenser"
	desc = "A hefty machine that, when supplied with metal and glass, will periodically create a drone shell. Does not need to be manually operated."
	icon = 'icons/obj/machines/droneDispenser.dmi'
	icon_state = "on"
	anchored = 1
	density = 1
	var/metal = 0
	var/glass = 0
	var/droneMadeRecently = 0
	var/outputDirection = SOUTH

/obj/machinery/droneDispenser/New()
	..()
	SSmachine.processing |= src

/obj/machinery/droneDispenser/Destroy()
	SSmachine.processing -= src
	..()

/obj/machinery/droneDispenser/preloaded
	metal = 5000
	glass = 5000

/obj/machinery/droneDispenser/syndrone //Please forgive me
	name = "syndrone shell dispenser"
	desc = "A suspicious machine that will create Syndicate exterminator drones when supplied with metal and glass. Disgusting."
	metal = 25000
	glass = 25000

/obj/machinery/droneDispenser/examine(mob/user)
	..()
	if(droneMadeRecently && !stat)
		user << "<span class='notice'>The control screen indicates that is recharging.</span>"
	user << "<span class='notice'>It has [metal] units of metal stored.</span>"
	user << "<span class='notice'>It has [glass] units of glass stored.</span>"

/obj/machinery/droneDispenser/power_change()
	..()
	if(stat & BROKEN)
		return
	else
		if(powered())
			stat &= ~NOPOWER
		else
			icon_state = "off"
			stat |= NOPOWER

/obj/machinery/droneDispenser/process()
	..()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		return
	if(droneMadeRecently || metal < 1000 || glass < 1000)
		return
	droneMadeRecently = 1
	var/turf/T = get_step(src,SOUTH)
	visible_message("<span class='notice'>[src] whirs to life!</span>")
	playsound(src, 'sound/items/rped.ogg', 50, 1)
	icon_state = "make"
	spawn(30)
		icon_state = "[initial(icon_state)]"
		visible_message("<span class='notice'>[src] dispenses a drone shell.</span>")
		metal -= 1000
		glass -= 1000
		if(metal < 0) metal = 0
		if(glass < 0) glass = 0
		if(istype(src, /obj/machinery/droneDispenser/syndrone))
			new /obj/item/drone_shell/syndrone(T)
		else
			new /obj/item/drone_shell(T)
		use_power(1000)
		icon_state = "recharge"
		spawn(1800) //3 minute cooldown between shells
			icon_state = "[initial(icon_state)]"
			droneMadeRecently = 0
			playsound(src, 'sound/machines/ping.ogg', 50, 1)
			audible_message("<span class='notice'>[src] pings.</span>")

/obj/machinery/droneDispenser/attackby(obj/item/O, mob/living/user)
	if(istype(O, /obj/item/stack))
		if(!O.materials[MAT_METAL] && !O.materials[MAT_GLASS])
			return ..()
		var/stack = 1
		var/obj/item/stack/sheets
		sheets = O
		stack = (input(user, "How many sheets do you want to add?.", "Drone Dispenser", "[stack]") as num)
		if(stack <= 0)
			return
		if(!user.canUseTopic(src))
			return
		stack = Clamp(stack, 0, sheets.max_amount)
		sheets.use(stack)
		if(!stack)
			if(!user.unEquip(O))
				user << "<span class='warning'>[O] is stuck to your hand, you can't get it off!</span>"
				return
			user.drop_item()
			O.loc = src
		metal += O.materials[MAT_METAL] * stack
		glass += O.materials[MAT_GLASS] * stack
		user << "<span class='notice'>You insert [stack] sheet[stack > 1 ? "s" : ""] to [src].</span>"
		if((O && O.loc == src) || !stack)
			qdel(O)
		return
	..()
