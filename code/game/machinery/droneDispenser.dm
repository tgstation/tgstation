/obj/machinery/droneDispenser
	name = "drone shell dispenser"
	desc = "A hefty machine that, when supplied with metal and glass, will periodically create a drone shell. Does not need to be manually operated."
	icon = 'icons/obj/machines/droneDispenser.dmi'
	icon_state = "on"
	anchored = 1
	density = 1

	var/health = 100 //The health of the drone dispenser. It will break if it goes below 0
	var/max_health = 100

	var/icon_off = "off" //These variables allow for different icons when creating custom dispensers
	var/icon_on = "on"
	var/icon_recharging = "recharge"
	var/icon_creating = "make"

	var/metal = 0
	var/glass = 0
	var/use_materials = 1 //If this is set to 0, the dispenser will not require metal or glass to run

	var/droneMadeRecently = 0
	var/cooldownTime = 1800 //3 minutes
	var/dispense_type = /obj/item/drone_shell //The item the dispenser will create

	var/last_time //Used for hitting

/obj/machinery/droneDispenser/New()
	..()
	health = max_health
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
	dispense_type = /obj/item/drone_shell/syndrone
	cooldownTime = 100 //If we're gonna be a jackass, go the full mile - 10 second recharge timer

/obj/machinery/droneDispenser/hivebot //An example of a custom drone dispenser. This one requires no materials and creates basic hivebots
	name = "hivebot fabricator"
	desc = "A large, bulky machine that whirs with activity, steam hissing from vents in its sides."
	icon = 'icons/obj/objects.dmi'
	icon_state = "hivebot_fab"
	icon_off = "hivebot_fab"
	icon_on = "hivebot_fab"
	icon_recharging = "hivebot_fab"
	icon_creating = "hivebot_fab_on"
	use_materials = 0
	cooldownTime = 10 //Only 1 second - hivebots are extremely weak
	dispense_type = /mob/living/simple_animal/hostile/hivebot

/obj/machinery/droneDispenser/examine(mob/user)
	..()
	if(droneMadeRecently && !stat)
		user << "<span class='warning'>It is gently whirring and clicking. It seems to be recharging.</span>"
	if(stat & BROKEN)
		user << "<span class='warning'>[src] is smoking and steadily buzzing. It seems to be broken.</span>"
	if(use_materials)
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
	if(use_materials && (metal < 1000 || glass < 1000))
		return
	if(droneMadeRecently)
		icon_state = icon_recharging
		return
	droneMadeRecently = 1
	visible_message("<span class='notice'>[src] whirs to life!</span>")
	playsound(src, 'sound/items/rped.ogg', 50, 1)
	icon_state = icon_creating
	spawn(30)
		icon_state = icon_on
		if(use_materials)
			metal -= 1000
			glass -= 1000
			if(metal < 0)
				metal = 0
			if(glass < 0)
				glass = 0
			use_power(1000)
		new dispense_type(loc)
		icon_state = icon_recharging
		spawn(cooldownTime)
			icon_state = icon_on
			droneMadeRecently = 0
			playsound(src, 'sound/machines/ping.ogg', 50, 1)
			audible_message("<span class='notice'>[src] pings.</span>")

/obj/machinery/droneDispenser/attackby(obj/item/O, mob/living/user)
	if(istype(O, /obj/item/stack))
		if(!O.materials[MAT_METAL] && !O.materials[MAT_GLASS])
			return ..()
		if(!use_materials)
			user << "<span class='warning'>There isn't a place to insert [O]!</span>"
			return
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
	if(istype(O, /obj/item/weapon/weldingtool) && stat & BROKEN)
		var/obj/item/weapon/weldingtool/WT = O
		if(!WT.isOn())
			return
		if(WT.get_fuel() < 1)
			user << "<span class='warning'>You need more fuel to complete this task!</span>"
			return
		playsound(src, 'sound/items/Welder.ogg', 50, 1)
		user.visible_message("<span class='notice'>[user] begins patching up [src] with [WT].</span>", \
							 "<span class='notice'>You begin restoring the damage to [src]...</span>")
		if(!do_after(user, 40, target = src))
			return
		if(!src || !WT.remove_fuel(1, user)) return
		user.visible_message("<span class='notice'>[user] fixes [src]!</span>", \
							 "<span class='notice'>You restore [src] to operation.</span>")
		stat -= BROKEN
		icon_state = icon_on
		return
	if(O.force && stat != BROKEN)
		user.visible_message("<span class='danger'>[user] hits [src] with [O]!</span>", \
							 "<span class='warning'>You hit [src] with [O]!</span>")
		playsound(src, O.hitsound, 50, 1)
		health -= O.force
		health = Clamp(health, 0, max_health)
		if(health <= 0)
			audible_message("<span class='warning'>[src] lets out a tinny alarm before clunking and falling dark.</span>")
			playsound(src, 'sound/machines/warning-buzzer.ogg', 50, 1)
			stat = BROKEN
			icon_state = icon_off
		return
	..()
