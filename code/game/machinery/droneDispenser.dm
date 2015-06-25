/obj/machinery/droneDispenser
	name = "drone shell dispenser"
	desc = "A hefty machine that, when supplied with metal and glass, will periodically create a drone shell. Does not need to be manually operated."
	icon = 'icons/obj/machines/droneDispenser.dmi'
	icon_state = "on"
	anchored = 1
	density = 1
	var/health = 500
	var/maxHealth = 500
	var/metal = 0
	var/glass = 0
	var/broken = 0
	var/droneMadeRecently = 0
	var/cooldownTime = 1800 //3 minutes
	var/dispenseType = /obj/item/drone_shell/ //Now a custom variable, so you can assign custom objects for dispensing.
	var/efficiency = 1 //How efficient the dispenser is with using materials

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
	dispenseType = /obj/item/drone_shell/syndrone/

/obj/machinery/droneDispenser/examine(mob/user)
	..()
	if(broken)
		user << "<span class='danger'>It's heavily damaged and requires repairs.</span>"
		return
	if(droneMadeRecently && !stat)
		user << "<span class='notice'>The control screen indicates that is recharging.</span>"
	user << "<span class='notice'>It has [metal] units of metal stored.</span>"
	user << "<span class='notice'>It has [glass] units of glass stored.</span>"

/obj/machinery/droneDispenser/proc/takeDamage(var/amount)
	if(broken || !health)
		return
	health -= amount
	if(health <= 0)
		visible_message("<span class='warning'>[src] lets out a torrent of sparks and falls silent.</span>")
		var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread
		sparks.set_up(5, 1, src)
		sparks.start()
		broken = 1
		icon_state = "off"

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
	if(stat & (NOPOWER|BROKEN) || !anchored || broken)
		return
	if(droneMadeRecently || metal < 1000 || glass < 1000)
		return
	droneMadeRecently = 1
	visible_message("<span class='notice'>[src] whirs to life!</span>")
	playsound(src, 'sound/items/rped.ogg', 50, 1)
	icon_state = "make"
	spawn(30)
		icon_state = "[initial(icon_state)]"
		visible_message("<span class='notice'>[src] dispenses a drone shell.</span>")
		metal -= 1000 / efficiency
		glass -= 1000 / efficiency
		if(metal < 0) metal = 0
		if(glass < 0) glass = 0
		var/turf/T = get_turf(src)
		T = get_step(T, SOUTHEAST)
		new dispenseType(T)
		use_power(1000)
		icon_state = "recharge"
		spawn(cooldownTime)
			icon_state = "[initial(icon_state)]"
			droneMadeRecently = 0
			playsound(src, 'sound/machines/ping.ogg', 50, 1)
			audible_message("<span class='notice'>[src] pings.</span>")

/obj/machinery/droneDispenser/attackby(obj/item/O, mob/living/user)
	if(istype(O, /obj/item/stack))
		add_fingerprint(user)
		if(!O.m_amt && !O.g_amt)
			return ..()
		if(!user.unEquip(O))
			user << "<span class='warning'>[O] is stuck to your hand, you can't get it off!</span>"
			return
		var/obj/item/stack/sheets = O
		if(broken)
			if(sheets.m_amt && sheets.amount <= 10)
				user << "<span class='notice'>You start replacing [src]'s damaged plating with [sheets]...</span>"
				if(!do_after(user, 60))
					return
				user.visible_message("<span class='notice'>[user] adds new plating to [src].</span>", \
									 "<span class='notice'>You replace the damaged plating.</span>")
				sheets.use(10)
				if(!sheets.amount)
					user.drop_item()
					qdel(sheets)
				health = maxHealth
				broken = 0
				droneMadeRecently = 0
				return
			else if(sheets.m_amt && sheets.amount > 10)
				user << "<span class='notice'>You need ten sheets of metal to repair [src].</span>"
				return
			else
				user << "<span class='warning'>[src] is broken and not accepting materials.</span>"
				return
		var/stack = sheets.amount
		stack = (input(user, "How many sheets do you want to add?.", "Drone Dispenser", "[stack]") as num)
		if(stack <= 0)
			return
		if(!user.canUseTopic(src))
			return
		stack = Clamp(stack, 0, sheets.amount)
		sheets.use(stack)
		if(!sheets.amount)
			user.drop_item()
			O.loc = src
		metal += O.m_amt * stack
		glass += O.g_amt * stack
		user << "<span class='notice'>You insert [stack] sheet[stack > 1 ? "s" : ""] to [src].</span>"
		if((O && O.loc == src) || !sheets.amount)
			qdel(O)
		return
	else if(istype(O, /obj/item/weapon) && !broken)
		add_fingerprint(user)
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		if((O.flags&NOBLUDGEON) || !O.force )
			return
		playsound(src, 'sound/weapons/smash.ogg', 50, 1)
		visible_message("<span class='danger'>[user] hits [src] with [O].</span>")
		if(O.damtype == BURN || O.damtype == BRUTE)
			takeDamage(O.force)
		return
	..()
