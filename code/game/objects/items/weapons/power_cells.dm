/obj/item/weapon/stock_parts/cell
	name = "power cell"
	desc = "A rechargable electrochemical power cell."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
	origin_tech = "powerstorage=1"
	force = 5.0
	throwforce = 5.0
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	var/charge = 0	// note %age conveted to actual charge in New
	var/maxcharge = 1000
	m_amt = 700
	g_amt = 50
	var/rigged = 0		// true if rigged to explode
	var/minor_fault = 0 //If not 100% reliable, it will build up faults.
	var/construction_cost = list("metal"=750,"glass"=75)
	var/construction_time=100

/obj/item/weapon/stock_parts/cell/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is licking the electrodes of the [src.name]! It looks like \he's trying to commit suicide.</span>")
	return (FIRELOSS)

/obj/item/weapon/stock_parts/cell/crap
	name = "\improper Nanotrasen brand rechargable AA battery"
	desc = "You can't top the plasma top." //TOTALLY TRADEMARK INFRINGEMENT
	origin_tech = "powerstorage=0"
	maxcharge = 500
	g_amt = 40
	rating = 2

/obj/item/weapon/stock_parts/cell/crap/empty/New()
	..()
	charge = 0

/obj/item/weapon/stock_parts/cell/secborg
	name = "security borg rechargable D battery"
	origin_tech = "powerstorage=0"
	maxcharge = 600	//600 max charge / 100 charge per shot = six shots
	g_amt = 40
	rating = 2.5

/obj/item/weapon/stock_parts/cell/secborg/empty/New()
	..()
	charge = 0

/obj/item/weapon/stock_parts/cell/high
	name = "high-capacity power cell"
	origin_tech = "powerstorage=2"
	icon_state = "hcell"
	maxcharge = 10000
	g_amt = 60
	rating = 3

/obj/item/weapon/stock_parts/cell/high/empty/New()
	..()
	charge = 0

/obj/item/weapon/stock_parts/cell/super
	name = "super-capacity power cell"
	origin_tech = "powerstorage=5"
	icon_state = "scell"
	maxcharge = 20000
	g_amt = 70
	construction_cost = list("metal"=750,"glass"=100)
	rating = 4

/obj/item/weapon/stock_parts/cell/super/empty/New()
	..()
	charge = 0

/obj/item/weapon/stock_parts/cell/hyper
	name = "hyper-capacity power cell"
	origin_tech = "powerstorage=6"
	icon_state = "hpcell"
	maxcharge = 30000
	g_amt = 80
	construction_cost = list("metal"=500,"glass"=150,"gold"=200,"silver"=200)
	rating = 5

/obj/item/weapon/stock_parts/cell/hyper/empty/New()
	..()
	charge = 0

/obj/item/weapon/stock_parts/cell/infinite
	name = "infinite-capacity power cell!"
	icon_state = "icell"
	origin_tech =  null
	maxcharge = 30000
	g_amt = 80
	rating = 6
	use()
		return 1

/obj/item/weapon/stock_parts/cell/potato
	name = "potato battery"
	desc = "A rechargable starch based power cell."
	origin_tech = "powerstorage=1"
	icon = 'icons/obj/power.dmi' //'icons/obj/harvest.dmi'
	icon_state = "potato_cell" //"potato_battery"
	charge = 100
	maxcharge = 300
	m_amt = 0
	g_amt = 0
	minor_fault = 1
	rating = 1

/obj/item/weapon/stock_parts/cell/slime
	name = "charged slime core"
	desc = "A yellow slime core infused with plasma, it crackles with power."
	origin_tech = "powerstorage=2;biotech=4"
	icon = 'icons/mob/slimes.dmi' //'icons/obj/harvest.dmi'
	icon_state = "yellow slime extract" //"potato_battery"
	maxcharge = 10000
	m_amt = 0
	g_amt = 0
	rating = 3
