/obj/item/weapon/stock_parts/cell
	name = "power cell"
	desc = "A rechargable electrochemical power cell."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
	item_state = "cell"
	origin_tech = "powerstorage=1"
	force = 5.0
	throwforce = 5.0
	throw_speed = 2
	throw_range = 5
	w_class = 2
	var/charge = 0	// note %age conveted to actual charge in New
	var/maxcharge = 1000
	materials = list(MAT_METAL=700, MAT_GLASS=50)
	var/rigged = 0		// true if rigged to explode
	var/minor_fault = 0 //If not 100% reliable, it will build up faults.
	var/chargerate = 100 //how much power is given every tick in a recharger

/obj/item/weapon/stock_parts/cell/New()
	..()
	charge = maxcharge
	desc = "This cell has a power rating of [maxcharge], and you should not swallow it."
	updateicon()

/obj/item/weapon/stock_parts/cell/proc/updateicon()
	overlays.Cut()
	if(charge < 0.01)
		return
	else if(charge/maxcharge >=0.995)
		overlays += image('icons/obj/power.dmi', "cell-o2")
	else
		overlays += image('icons/obj/power.dmi', "cell-o1")

/obj/item/weapon/stock_parts/cell/proc/percent()		// return % charge of cell
	return 100.0*charge/maxcharge

// use power from a cell
/obj/item/weapon/stock_parts/cell/proc/use(amount)
	if(rigged && amount > 0)
		explode()
		return 0
	if(charge < amount)	return 0
	charge = (charge - amount)
	if(!istype(loc, /obj/machinery/power/apc))
		feedback_add_details("cell_used","[src.type]")
	return 1

// recharge the cell
/obj/item/weapon/stock_parts/cell/proc/give(amount)
	if(rigged && amount > 0)
		explode()
		return 0
	if(maxcharge < amount)
		amount = maxcharge
	var/power_used = min(maxcharge-charge,amount)
	if(crit_fail)	return 0
	if(!prob(reliability))
		minor_fault++
		if(prob(minor_fault))
			crit_fail = 1
			return 0
	charge += power_used
	return power_used

/obj/item/weapon/stock_parts/cell/examine(mob/user)
	..()
	if(crit_fail || rigged)
		user << "<span class='danger'>This power cell seems to be faulty!</span>"
	else
		user << "The charge meter reads [round(src.percent() )]%."

/obj/item/weapon/stock_parts/cell/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is licking the electrodes of the [src.name]! It looks like \he's trying to commit suicide.</span>")
	return (FIRELOSS)

/obj/item/weapon/stock_parts/cell/attackby(obj/item/W, mob/user, params)
	..()
	if(istype(W, /obj/item/weapon/reagent_containers/syringe))
		var/obj/item/weapon/reagent_containers/syringe/S = W
		user << "<span class='notice'>You inject the solution into the power cell.</span>"
		if(S.reagents.has_reagent("plasma", 5))
			rigged = 1
		S.reagents.clear_reagents()


/obj/item/weapon/stock_parts/cell/proc/explode()
	var/turf/T = get_turf(src.loc)
/*
 * 1000-cell	explosion(T, -1, 0, 1, 1)
 * 2500-cell	explosion(T, -1, 0, 1, 1)
 * 10000-cell	explosion(T, -1, 1, 3, 3)
 * 15000-cell	explosion(T, -1, 2, 4, 4)
 * */
	if (charge==0)
		return
	var/devastation_range = -1 //round(charge/11000)
	var/heavy_impact_range = round(sqrt(charge)/60)
	var/light_impact_range = round(sqrt(charge)/30)
	var/flash_range = light_impact_range
	if (light_impact_range==0)
		rigged = 0
		corrupt()
		return
	//explosion(T, 0, 1, 2, 2)
	explosion(T, devastation_range, heavy_impact_range, light_impact_range, flash_range)
	qdel(src)

/obj/item/weapon/stock_parts/cell/proc/corrupt()
	charge /= 2
	maxcharge = max(maxcharge/2, chargerate)
	if (prob(10))
		rigged = 1 //broken batterys are dangerous

/obj/item/weapon/stock_parts/cell/emp_act(severity)
	charge -= 1000 / severity
	if (charge < 0)
		charge = 0
	if(reliability != 100 && prob(50/severity))
		reliability -= 10 / severity
	..()

/obj/item/weapon/stock_parts/cell/ex_act(severity, target)
	..()
	if(!gc_destroyed)
		switch(severity)
			if(2)
				if(prob(50))
					corrupt()
			if(3)
				if(prob(25))
					corrupt()


/obj/item/weapon/stock_parts/cell/blob_act()
	ex_act(1)

/obj/item/weapon/stock_parts/cell/proc/get_electrocute_damage()
	if(charge >= 1000)
		return Clamp(round(charge/10000), 10, 90) + rand(-5,5)
	else
		return 0

/* Cell variants*/
/obj/item/weapon/stock_parts/cell/crap
	name = "\improper Nanotrasen brand rechargable AA battery"
	desc = "You can't top the plasma top." //TOTALLY TRADEMARK INFRINGEMENT
	origin_tech = "powerstorage=0"
	maxcharge = 500
	materials = list(MAT_GLASS=40)
	rating = 2

/obj/item/weapon/stock_parts/cell/crap/empty/New()
	..()
	charge = 0

/obj/item/weapon/stock_parts/cell/secborg
	name = "security borg rechargable D battery"
	origin_tech = "powerstorage=0"
	maxcharge = 600	//600 max charge / 100 charge per shot = six shots
	materials = list(MAT_GLASS=40)
	rating = 2.5

/obj/item/weapon/stock_parts/cell/secborg/empty/New()
	..()
	charge = 0

/obj/item/weapon/stock_parts/cell/pulse //200 pulse shots
	name = "pulse rifle power cell"
	maxcharge = 40000
	rating = 3
	chargerate = 1500

/obj/item/weapon/stock_parts/cell/pulse/carbine //25 pulse shots
	name = "pulse carbine power cell"
	maxcharge = 5000

/obj/item/weapon/stock_parts/cell/pulse/pistol //10 pulse shots
	name = "pulse pistol power cell"
	maxcharge = 2000

/obj/item/weapon/stock_parts/cell/high
	name = "high-capacity power cell"
	origin_tech = "powerstorage=2"
	icon_state = "hcell"
	maxcharge = 10000
	materials = list(MAT_GLASS=60)
	rating = 3
	chargerate = 1500

/obj/item/weapon/stock_parts/cell/high/empty/New()
	..()
	charge = 0

/obj/item/weapon/stock_parts/cell/super
	name = "super-capacity power cell"
	origin_tech = "powerstorage=5"
	icon_state = "scell"
	maxcharge = 20000
	materials = list(MAT_GLASS=70)
	rating = 4
	chargerate = 2000

/obj/item/weapon/stock_parts/cell/super/empty/New()
	..()
	charge = 0

/obj/item/weapon/stock_parts/cell/hyper
	name = "hyper-capacity power cell"
	origin_tech = "powerstorage=6"
	icon_state = "hpcell"
	maxcharge = 30000
	materials = list(MAT_GLASS=80)
	rating = 5
	chargerate = 3000

/obj/item/weapon/stock_parts/cell/hyper/empty/New()
	..()
	charge = 0

/obj/item/weapon/stock_parts/cell/bluespace
	name = "bluespace power cell"
	origin_tech = "powerstorage=7"
	icon_state = "bscell"
	maxcharge = 40000
	materials = list(MAT_GLASS=80)
	rating = 6
	chargerate = 4000

/obj/item/weapon/stock_parts/cell/bluespace/empty/New()
	..()
	charge = 0

/obj/item/weapon/stock_parts/cell/infinite
	name = "infinite-capacity power cell!"
	icon_state = "icell"
	origin_tech =  null
	maxcharge = 30000
	materials = list(MAT_GLASS=80)
	rating = 6
	chargerate = 30000
	use()
		return 1

/obj/item/weapon/stock_parts/cell/potato
	name = "potato battery"
	desc = "A rechargable starch based power cell."
	origin_tech = "powerstorage=1"
	icon = 'icons/obj/power.dmi' //'icons/obj/hydroponics/harvest.dmi'
	icon_state = "potato_cell" //"potato_battery"
	charge = 100
	maxcharge = 300
	materials = list()
	minor_fault = 1
	rating = 1

/obj/item/weapon/stock_parts/cell/high/slime
	name = "charged slime core"
	desc = "A yellow slime core infused with plasma, it crackles with power."
	origin_tech = "powerstorage=2;biotech=4"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "yellow slime extract"
	materials = list()

/obj/item/weapon/stock_parts/cell/emproof
	name = "\improper EMP-proof cell"
	desc = "An EMP-proof cell."
	maxcharge = 500
	rating = 2

/obj/item/weapon/stock_parts/cell/emproof/empty/New()
	..()
	charge = 0

/obj/item/weapon/stock_parts/cell/emproof/emp_act(severity)
	return

/obj/item/weapon/stock_parts/cell/emproof/corrupt()
	return
