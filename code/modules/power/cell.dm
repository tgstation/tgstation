/obj/item/weapon/stock_parts/cell
	name = "power cell"
	desc = "A rechargeable electrochemical power cell."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
	item_state = "cell"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	origin_tech = "powerstorage=1"
	force = 5
	throwforce = 5
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	var/charge = 0	// note %age conveted to actual charge in New
	var/maxcharge = 1000
	materials = list(MAT_METAL=700, MAT_GLASS=50)
	var/rigged = 0		// true if rigged to explode
	var/chargerate = 100 //how much power is given every tick in a recharger
	var/self_recharge = 0 //does it self recharge, over time, or not?
	var/ratingdesc = TRUE
	var/grown_battery = FALSE // If it's a grown that acts as a battery, add a wire overlay to it.

/obj/item/weapon/stock_parts/cell/get_cell()
	return src

/obj/item/weapon/stock_parts/cell/New()
	..()
	START_PROCESSING(SSobj, src)
	charge = maxcharge
	if(ratingdesc)
		desc += " This one has a power rating of [maxcharge], and you should not swallow it."
	update_icon()

/obj/item/weapon/stock_parts/cell/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/weapon/stock_parts/cell/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("self_recharge")
			if(var_value)
				START_PROCESSING(SSobj, src)
			else
				STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/weapon/stock_parts/cell/process()
	if(self_recharge)
		give(chargerate * 0.25)
	else
		return PROCESS_KILL

/obj/item/weapon/stock_parts/cell/update_icon()
	cut_overlays()
	if(grown_battery)
		add_overlay("grown_wires")
	if(charge < 0.01)
		return
	else if(charge/maxcharge >=0.995)
		add_overlay("cell-o2")
	else
		add_overlay("cell-o1")

/obj/item/weapon/stock_parts/cell/proc/percent()		// return % charge of cell
	return 100*charge/maxcharge

// use power from a cell
/obj/item/weapon/stock_parts/cell/proc/use(amount)
	if(rigged && amount > 0)
		explode()
		return 0
	if(charge < amount)
		return 0
	charge = (charge - amount)
	if(!istype(loc, /obj/machinery/power/apc))
		SSblackbox.add_details("cell_used","[src.type]")
	return 1

// recharge the cell
/obj/item/weapon/stock_parts/cell/proc/give(amount)
	if(rigged && amount > 0)
		explode()
		return 0
	if(maxcharge < amount)
		amount = maxcharge
	var/power_used = min(maxcharge-charge,amount)
	charge += power_used
	return power_used

/obj/item/weapon/stock_parts/cell/examine(mob/user)
	..()
	if(rigged)
		to_chat(user, "<span class='danger'>This power cell seems to be faulty!</span>")
	else
		to_chat(user, "The charge meter reads [round(src.percent() )]%.")

/obj/item/weapon/stock_parts/cell/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is licking the electrodes of [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (FIRELOSS)

/obj/item/weapon/stock_parts/cell/attackby(obj/item/W, mob/user, params)
	..()
	if(istype(W, /obj/item/weapon/reagent_containers/syringe))
		var/obj/item/weapon/reagent_containers/syringe/S = W
		to_chat(user, "<span class='notice'>You inject the solution into the power cell.</span>")
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
	..()

/obj/item/weapon/stock_parts/cell/ex_act(severity, target)
	..()
	if(!QDELETED(src))
		switch(severity)
			if(2)
				if(prob(50))
					corrupt()
			if(3)
				if(prob(25))
					corrupt()


/obj/item/weapon/stock_parts/cell/blob_act(obj/structure/blob/B)
	ex_act(EXPLODE_DEVASTATE)

/obj/item/weapon/stock_parts/cell/proc/get_electrocute_damage()
	if(charge >= 1000)
		return Clamp(round(charge/10000), 10, 90) + rand(-5,5)
	else
		return 0

/* Cell variants*/
/obj/item/weapon/stock_parts/cell/crap
	name = "\improper Nanotrasen brand rechargeable AA battery"
	desc = "You can't top the plasma top." //TOTALLY TRADEMARK INFRINGEMENT
	maxcharge = 500
	materials = list(MAT_GLASS=40)
	rating = 2

/obj/item/weapon/stock_parts/cell/crap/empty/New()
	..()
	charge = 0

/obj/item/weapon/stock_parts/cell/secborg
	name = "security borg rechargeable D battery"
	origin_tech = null
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

/obj/item/weapon/stock_parts/cell/high/plus
	name = "high-capacity power cell+"
	desc = "Where did these come from?"
	icon_state = "h+cell"
	maxcharge = 15000
	chargerate = 2250

/obj/item/weapon/stock_parts/cell/high/empty/New()
	..()
	charge = 0

/obj/item/weapon/stock_parts/cell/super
	name = "super-capacity power cell"
	origin_tech = "powerstorage=3;materials=3"
	icon_state = "scell"
	maxcharge = 20000
	materials = list(MAT_GLASS=300)
	rating = 4
	chargerate = 2000

/obj/item/weapon/stock_parts/cell/super/empty/New()
	..()
	charge = 0

/obj/item/weapon/stock_parts/cell/hyper
	name = "hyper-capacity power cell"
	origin_tech = "powerstorage=4;engineering=4;materials=4"
	icon_state = "hpcell"
	maxcharge = 30000
	materials = list(MAT_GLASS=400)
	rating = 5
	chargerate = 3000

/obj/item/weapon/stock_parts/cell/hyper/empty/New()
	..()
	charge = 0

/obj/item/weapon/stock_parts/cell/bluespace
	name = "bluespace power cell"
	desc = "A rechargeable transdimensional power cell."
	origin_tech = "powerstorage=5;bluespace=4;materials=4;engineering=4"
	icon_state = "bscell"
	maxcharge = 40000
	materials = list(MAT_GLASS=600)
	rating = 6
	chargerate = 4000

/obj/item/weapon/stock_parts/cell/bluespace/empty/New()
	..()
	charge = 0

/obj/item/weapon/stock_parts/cell/infinite
	name = "infinite-capacity power cell!"
	icon_state = "icell"
	origin_tech =  "powerstorage=7"
	maxcharge = 30000
	materials = list(MAT_GLASS=1000)
	rating = 6
	chargerate = 30000

/obj/item/weapon/stock_parts/cell/infinite/use()
	return 1

/obj/item/weapon/stock_parts/cell/infinite/abductor
	name = "void core"
	desc = "An alien power cell that produces energy seemingly out of nowhere."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "cell"
	origin_tech =  "abductor=5;powerstorage=8;engineering=6"
	maxcharge = 50000
	rating = 12
	ratingdesc = FALSE

/obj/item/weapon/stock_parts/cell/infinite/abductor/update_icon()
	return


/obj/item/weapon/stock_parts/cell/potato
	name = "potato battery"
	desc = "A rechargeable starch based power cell."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "potato"
	origin_tech = "powerstorage=1;biotech=1"
	charge = 100
	maxcharge = 300
	materials = list()
	rating = 1
	grown_battery = TRUE //it has the overlays for wires

/obj/item/weapon/stock_parts/cell/high/slime
	name = "charged slime core"
	desc = "A yellow slime core infused with plasma, it crackles with power."
	origin_tech = "powerstorage=5;biotech=4"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "yellow slime extract"
	materials = list()
	self_recharge = 1 // Infused slime cores self-recharge, over time

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

/obj/item/weapon/stock_parts/cell/beam_rifle
	name = "beam rifle capacitor"
	desc = "A high powered capacitor that can provide huge amounts of energy in an instant"
	maxcharge = 50000
	chargerate = 5000	//Extremely energy intensive
	rating = 4

/obj/item/weapon/stock_parts/cell/beam_rifle/corrupt()
	return

/obj/item/weapon/stock_parts/cell/beam_rifle/emp_act(severity)
	charge = Clamp((charge-(10000/severity)),0,maxcharge)
