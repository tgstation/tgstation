/obj/machinery/droneDispenser //Most customizable machine 2015
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
	var/metal_cost = 1000
	var/glass_cost = 1000
	var/power_used = 1000

	var/droneMadeRecently = 0
	var/cooldownTime = 1800 //3 minutes
	var/dispense_type = /obj/item/drone_shell //The item the dispenser will create

	var/work_sound = 'sound/items/rped.ogg'
	var/create_sound = 'sound/items/Deconstruct.ogg'
	var/recharge_sound = 'sound/machines/ping.ogg'

	var/begin_create_message = "whirs to life!"
	var/end_create_message = "dispenses a drone shell."
	var/recharge_message = "pings."
	var/recharging_text = "It is whirring and clicking. It seems to be recharging."

	var/break_message = "lets out a tinny alarm before falling dark."
	var/break_sound = 'sound/machines/warning-buzzer.ogg'

/obj/machinery/droneDispenser/New()
	..()
	health = max_health
	SSmachine.processing |= src

/obj/machinery/droneDispenser/Destroy()
	SSmachine.processing -= src
	return ..()

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
	end_create_message = "dispenses a suspicious drone shell."

/obj/machinery/droneDispenser/syndrone/badass //Please forgive me
	name = "badass syndrone shell dispenser"
	desc = "A suspicious machine that will create Syndicate exterminator drones when supplied with metal and glass. Disgusting. This one seems ominous."
	dispense_type = /obj/item/drone_shell/syndrone/badass
	end_create_message = "dispenses a ominous suspicious drone shell."

// I don't need your forgiveness, this is awesome.
/obj/machinery/droneDispenser/snowflake
	name = "snowflake drone shell dispenser"
	desc = "A hefty machine that, when supplied with metal and glass, will periodically create a snowflake drone shell. Does not need to be manually operated."
	dispense_type = /obj/item/drone_shell/snowflake //The item the dispenser will create
	// Those holoprojectors aren't cheap
	metal_cost = 2000
	glass_cost = 2000
	power_used = 2000

/obj/machinery/droneDispenser/snowflake/preloaded
	metal = 10000
	glass = 10000

/obj/machinery/droneDispenser/hivebot //An example of a custom drone dispenser. This one requires no materials and creates basic hivebots
	name = "hivebot fabricator"
	desc = "A large, bulky machine that whirs with activity, steam hissing from vents in its sides."
	icon = 'icons/obj/objects.dmi'
	icon_state = "hivebot_fab"
	icon_off = "hivebot_fab"
	icon_on = "hivebot_fab"
	icon_recharging = "hivebot_fab"
	icon_creating = "hivebot_fab_on"
	metal_cost = 0
	glass_cost = 0
	power_used = 0
	cooldownTime = 10 //Only 1 second - hivebots are extremely weak
	dispense_type = /mob/living/simple_animal/hostile/hivebot
	begin_create_message = "closes and begins fabricating something within."
	end_create_message = "slams open, revealing out a hivebot!"
	recharge_sound = null
	recharge_message = null

/obj/machinery/droneDispenser/swarmer
	name = "swarmer fabricator"
	desc = "An alien machine of unknown origin. It whirs and hums with green-blue light, the air above it shimmering."
	icon = 'icons/obj/machines/gateway.dmi'
	icon_state = "toffcenter"
	icon_off = "toffcenter"
	icon_on = "toffcenter"
	icon_recharging = "toffcenter"
	icon_creating = "offcenter"
	metal_cost = 0
	glass_cost = 0
	cooldownTime = 300 //30 seconds
	dispense_type = /obj/item/unactivated_swarmer
	begin_create_message = "hums softly as an interface appears above it, scrolling by at unreadable speed."
	end_create_message = "materializes a strange shell, which drops to the ground."
	recharging_text = "Its lights are slowly increasing in brightness."
	work_sound = 'sound/effects/EMPulse.ogg'
	create_sound = 'sound/effects/phasein.ogg'
	break_sound = 'sound/effects/EMPulse.ogg'
	break_message = "slowly falls dark, lights stuttering."

/obj/machinery/droneDispenser/examine(mob/user)
	..()
	if(droneMadeRecently && !stat && recharging_text)
		user << "<span class='warning'>[recharging_text]</span>"
	if(stat & BROKEN)
		user << "<span class='warning'>[src] is smoking and steadily buzzing. It seems to be broken.</span>"
	if(metal_cost)
		user << "<span class='notice'>It has [metal] units of metal stored.</span>"
	if(glass_cost)
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
	if((metal_cost && glass_cost) && (metal < metal_cost || glass < glass_cost))
		return
	if(droneMadeRecently)
		icon_state = icon_recharging
		return
	droneMadeRecently = 1
	if(begin_create_message)
		visible_message("<span class='notice'>[src] [begin_create_message]</span>")
	if(work_sound)
		playsound(src, work_sound, 50, 1)
	icon_state = icon_creating
	sleep(30)
	icon_state = icon_on
	metal -= metal_cost
	glass -= glass_cost
	if(metal < 0)
		metal = 0
	if(glass < 0)
		glass = 0
	if(power_used)
		use_power(power_used)
	new dispense_type(loc)
	if(create_sound)
		playsound(src, create_sound, 50, 1)
	if(end_create_message)
		visible_message("<span class='notice'>[src] [end_create_message]</span>")
	icon_state = icon_recharging
	sleep(cooldownTime)
	if(!(stat & BROKEN))
		icon_state = icon_on
	else
		icon_state = icon_off
	droneMadeRecently = 0
	if(recharge_sound)
		playsound(src, recharge_sound, 50, 1)
	if(recharge_message)
		visible_message("<span class='notice'>[src] [recharge_message]</span>")

/obj/machinery/droneDispenser/attackby(obj/item/O, mob/living/user)
	if(istype(O, /obj/item/stack))
		if(!O.materials[MAT_METAL] && !O.materials[MAT_GLASS])
			return ..()
		if(!metal_cost && !glass_cost)
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
	else if(istype(O, /obj/item/weapon/weldingtool))
		if(stat & BROKEN)
			var/obj/item/weapon/weldingtool/WT = O
			if(!WT.isOn())
				return
			if(WT.get_fuel() < 1)
				user << "<span class='warning'>You need more fuel to complete this task!</span>"
				return
			playsound(src, 'sound/items/Welder.ogg', 50, 1)
			user.visible_message("<span class='notice'>[user] begins patching up [src] with [WT].</span>", \
								 "<span class='notice'>You begin restoring the damage to [src]...</span>")
			if(!do_after(user, 40/O.toolspeed, target = src))
				return
			if(!src || !WT.remove_fuel(1, user)) return
			user.visible_message("<span class='notice'>[user] fixes [src]!</span>", \
								 "<span class='notice'>You restore [src] to operation.</span>")
			stat &= ~BROKEN
			health = max_health
			if(!stat)
				icon_state = icon_on
		else
			user << "<span class='warning'>[src] doesn't need repairs.</span>"
	else
		return ..()

/obj/machinery/droneDispenser/take_damage(damage, damage_type = BRUTE, sound_effect = 1)
	switch(damage_type)
		if(BURN)
			if(sound_effect)
				playsound(src.loc, 'sound/items/Welder.ogg', 100, 1)
		if(BRUTE)
			if(sound_effect)
				if(damage)
					playsound(loc, 'sound/weapons/smash.ogg', 50, 1)
				else
					playsound(loc, 'sound/weapons/tap.ogg', 50, 1)
		else
			return
	health = max(health - damage, 0)
	if(!health && !(stat & BROKEN))
		if(break_message)
			audible_message("<span class='warning'>[src] [break_message]</span>")
		if(break_sound)
			playsound(src, break_sound, 50, 1)
		stat |= BROKEN
		icon_state = icon_off

