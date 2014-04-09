//contains scanner

/obj/item/device/scanner
	name = "simple scanner"
	desc = "A very simple scanner with 2 slots for scanner modules."
	icon_state = "atmos"
	item_state = "analyzer"
	w_class = 2.0
	flags = CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	m_amt = 30
	g_amt = 20
	origin_tech = "magnets=1;engineering=1"

	var/module_capacity = 2
	var/list/obj/item/weapon/scanner_module/modules = list()
	var/panel_open = 0
	var/logging = 0
	var/list/log = list()
	var/scanning = 0


/obj/item/device/scanner/proc/add_log(var/msg, var/mob/user, var/broadcast = 1)
	if(broadcast && user)
		user.show_message(msg,1)
	if(logging)
		log += "&nbsp;&nbsp;[msg]"



/obj/item/device/scanner/attackby(obj/item/O, mob/user)

	//open panel
	if(istype(O, /obj/item/weapon/screwdriver/))
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		if(!panel_open)
			panel_open = 1
			user << "<span class='notice'>You open the module panel of \the [src].</span>"
		else
			panel_open = 0
			user << "<span class='notice'>You close the module panel of \the [src].</span>"
		return

	//remove modules
	if(istype(O, /obj/item/weapon/crowbar) && panel_open == 1)
		var/turf/T = get_turf(user)

		if(T)
			for(var/obj/item/weapon/scanner_module/M in modules)
				M.loc = T
			modules = list()
		return

	//add module
	if(istype(O, /obj/item/weapon/scanner_module) && panel_open == 1)
		if(modules.len >= module_capacity)
			user << "<span class='notice'>All module slots of [src] are used. There is no space for another module.</span>"
			return
		if(!user.unEquip(O))
			user << "<span class='notice'>\the [O] is stuck to your hand, you can't put it in \the [src]!</span>"
			return
		O.loc = src
		modules += O
		user << "<span class='notice'>You insert \the [O] into \the [src].</span>"
		return
	return


/obj/item/device/scanner/attack(mob/living/M as mob, mob/user as mob)
	return

//TODO: stupid check
/obj/item/device/scanner/afterattack(atom/A, mob/user as mob, proximity)
	if(scanning)
		return

	if(panel_open == 1)
		user << "<span class='notice'>You cannot use \the [src]. The module panel is still open.</span>"
		return

	if(modules.len == 0)
		user << "<span class='notice'>No scanner modules installed.</span>"
		return

	user.visible_message("<span class='alert'>[user] has used \the [src] on \the [A].</span>")

	add_log("<B>[worldtime2text()][get_print_timestamp()] - [A]</B>", 0)

	for(var/obj/item/weapon/scanner_module/mod in modules)
		mod.scan(A, user, src)

	src.add_fingerprint(user)

/obj/item/device/scanner/attack_self(var/mob/user)
	if(scanning)
		return

	if(panel_open == 1)
		user << "<span class='notice'>You cannot use \the [src]. The module panel is still open.</span>"
		return

	for(var/obj/item/weapon/scanner_module/mod in modules)
		if(mod.scan_on_attack_self)
			mod.scan(user, user, src)

	if(logging)
		if(log.len && !scanning)

			user << "<span class='notice'>Printing report, please wait...</span>"
			scanning = 1
			spawn(60)

				// Create our paper
				var/obj/item/weapon/paper/P = new(get_turf(src))
				P.name = "paper- 'Scanner Report'"
				P.info = "<center><font size='6'><B>Scanner Report</B></font></center><HR><BR>"
				P.info += list2text(log, "<BR>")
				P.info += "<HR><B>Notes:</B><BR>"
				P.info_links = P.info

				if(ismob(loc))
					var/mob/M = loc
					M.put_in_hands(P)
					M << "<span class='notice'>Report printed. Log cleared.<span>"

				scanning = 0
				// Clear the logs
				log = list()
		else
			user << "<span class='notice'>The scanner has no logs or is in use.</span>"
	else
		return

	return

/obj/item/device/scanner/proc/get_print_timestamp()
	return time2text(world.time + 432000, ":ss")


//MEDBAY SCANNER
/obj/item/device/scanner/medbay_scanner
	name = "medbay scanner"
	desc = "A 2 slot scanner, usually used by doctors to scan patients."
	icon_state = "health"
	item_state = "analyzer"
	module_capacity = 2
	logging = 0
	origin_tech = "engineering=2"
	m_amt = 1500
	g_amt = 500

/obj/item/device/scanner/medbay_scanner/full

/obj/item/device/scanner/medbay_scanner/full/New()
	..()

	modules += new /obj/item/weapon/scanner_module/health_module/L1
	modules += new /obj/item/weapon/scanner_module/virus_module/L1

/obj/item/device/scanner/medbay_scanner/advanced
	name = "advanced medbay scanner"
	desc = "A 3 slot scanner, usually used by doctors to scan patients."
	origin_tech = "magnets=2;engineering=3"
	module_capacity = 3
	m_amt = 1500
	g_amt = 500

/obj/item/device/scanner/medbay_scanner/advanced/full

/obj/item/device/scanner/medbay_scanner/advanced/full/New()
	..()

	modules += new /obj/item/weapon/scanner_module/health_module/L1
	modules += new /obj/item/weapon/scanner_module/virus_module/L1
	modules += new /obj/item/weapon/scanner_module/blood_reagent_module/L2

//DETECTIVE SCANNER
/obj/item/device/scanner/detective_scanner
	name = "forensic scanner"
	desc = "A 4 slot scanner, used by the detective to scan objects for traces of criminals."
	icon_state = "forensic1"
	item_state = "electronic"
	module_capacity = 4
	logging = 1
	origin_tech = "magnets=3;engineering=3"
	m_amt = 1500
	g_amt = 1000

/obj/item/device/scanner/detective_scanner/full

/obj/item/device/scanner/detective_scanner/full/New()
	..()

	modules += new /obj/item/weapon/scanner_module/fingerprint_module/L2
	modules += new /obj/item/weapon/scanner_module/fiber_module/L2
	modules += new /obj/item/weapon/scanner_module/blood_dna_module/L2
	modules += new /obj/item/weapon/scanner_module/reagent_module/L2

/obj/item/device/scanner/detective_scanner/advanced
	name = "advanced forensic scanner"
	desc = "A 5 slot scanner, used by the detective to scan objects for traces of criminals."
	origin_tech = "magnets=3;engineering=4"
	module_capacity = 5
	m_amt = 2000
	g_amt = 1000

/obj/item/device/scanner/detective_scanner/advanced/full

/obj/item/device/scanner/detective_scanner/advanced/full/New()
	..()

	modules += new /obj/item/weapon/scanner_module/fingerprint_module/L2
	modules += new /obj/item/weapon/scanner_module/fiber_module/L2
	modules += new /obj/item/weapon/scanner_module/blood_dna_module/L2
	modules += new /obj/item/weapon/scanner_module/reagent_module/L2
	modules += new /obj/item/weapon/scanner_module/blood_reagent_module/L3

//ENGINEERING SCANNER
/obj/item/device/scanner/engineering_scanner
	name = "engineering scanner"
	desc = "A 2 slot scanner designed for a dangerous workplace."
	origin_tech = "engineering=2"
	module_capacity = 2
	m_amt = 1500
	g_amt = 500

/obj/item/device/scanner/engineering_scanner/full/New()
	..()

	modules += new /obj/item/weapon/scanner_module/atmos_module/L1
	modules += new /obj/item/weapon/scanner_module/electric_module/L1

//MINING SCANNER mining + empty slot
/obj/item/device/scanner/mining_scanner
	name = "mining scanner"
	desc = "A 2 slot scanner designed to improve the mining experience."
	icon_state = "mining"
	item_state = "analyzer"
	origin_tech = "magnets=1;engineering=1"
	module_capacity = 2
	logging = 0

/obj/item/device/scanner/mining_scanner/full/New()
	..()

	modules += new /obj/item/weapon/scanner_module/mining_module

//BLOOD SCANNER
/obj/item/device/scanner/blood_scanner
	name = "blood scanner"
	desc = "A 1 slot scanner designed to replace the old mass spectrometers."
	icon_state = "spectrometer"
	item_state = "analyzer"
	origin_tech = "magnets=1;engineering=1"
	module_capacity = 1
	logging = 0

/obj/item/device/scanner/blood_scanner/full/New()
	..()

	modules += new /obj/item/weapon/scanner_module/blood_reagent_module/L1



