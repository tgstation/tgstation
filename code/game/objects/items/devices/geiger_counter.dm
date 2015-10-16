#define RAD_LEVEL_NORMAL 10
#define RAD_LEVEL_MODERATE 30
#define RAD_LEVEL_HIGH 75
#define RAD_LEVEL_VERY_HIGH 125
#define RAD_LEVEL_CRITICAL 200

/obj/item/device/geiger_counter //DISCLAIMER: I know nothing about how real-life Geiger counters work. This will not be realistic. ~Xhuis
	name = "geiger counter"
	desc = "A handheld device used for detecting and measuring radiation pulses."
	icon_state = "geiger_off"
	item_state = "electronic"
	w_class = 2
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL = 150, MAT_GLASS = 150)
	var/scanning = 0
	var/radiation_count = 0

/obj/item/device/geiger_counter/New()
	..()
	SSobj.processing |= src

/obj/item/device/geiger_counter/Destroy()
	SSobj.processing.Remove(src)
	..()

/obj/item/device/geiger_counter/process()
	if(radiation_count > 0)
		radiation_count--
		update_icon()

/obj/item/device/geiger_counter/examine(mob/user)
	..()
	if(!scanning)
		return 1
	user << "<span class='info'>Alt-click it to clear stored radiation levels.</span>"
	switch(radiation_count)
		if(-INFINITY to RAD_LEVEL_NORMAL)
			user << "<span class='notice'>Ambient radiation level count reports that all is well.</span>"
		if(RAD_LEVEL_NORMAL + 1 to RAD_LEVEL_MODERATE)
			user << "<span class='disarm'>Ambient radiation levels slightly above average.</span>"
		if(RAD_LEVEL_MODERATE + 1 to RAD_LEVEL_HIGH)
			user << "<span class='warning'>Ambient radiation levels above average.</span>"
		if(RAD_LEVEL_HIGH + 1 to RAD_LEVEL_VERY_HIGH)
			user << "<span class='danger'>Ambient radiation levels highly above average.</span>"
		if(RAD_LEVEL_VERY_HIGH + 1 to RAD_LEVEL_CRITICAL)
			user << "<span class='suicide'>Ambient radiation levels nearing critical level.</span>"
		if(RAD_LEVEL_CRITICAL + 1 to INFINITY)
			user << "<span class='boldannounce'>Ambient radiation levels above critical level!</span>"

/obj/item/device/geiger_counter/update_icon()
	if(!scanning)
		icon_state = "geiger_off"
		return 1
	switch(radiation_count)
		if(-INFINITY to RAD_LEVEL_NORMAL)
			icon_state = "geiger_on_1"
		if(RAD_LEVEL_NORMAL + 1 to RAD_LEVEL_MODERATE)
			icon_state = "geiger_on_2"
		if(RAD_LEVEL_MODERATE + 1 to RAD_LEVEL_HIGH)
			icon_state = "geiger_on_3"
		if(RAD_LEVEL_HIGH + 1 to RAD_LEVEL_VERY_HIGH)
			icon_state = "geiger_on_4"
		if(RAD_LEVEL_VERY_HIGH + 1 to RAD_LEVEL_CRITICAL)
			icon_state = "geiger_on_4"
		if(RAD_LEVEL_CRITICAL + 1 to INFINITY)
			icon_state = "geiger_on_5"
	..()

/obj/item/device/geiger_counter/rad_act(amount)
	if(!amount && scanning)
		return 0
	radiation_count += amount
	if(isliving(loc))
		var/mob/living/M = loc
		M << "<span class='boldannounce'>\icon[src] WARNING: Radiation pulse detected.</span>"
		M << "<span class='boldannounce'>\icon[src] PULSE SEVERITY: [amount]</span>"
		M << "<span class='boldannounce'>\icon[src] CURRENT RADIATION COUNT: [radiation_count]</span>"
	update_icon()

/obj/item/device/geiger_counter/attack_self(mob/user)
	scanning = !scanning
	update_icon()
	user << "<span class='notice'>\icon[src] You switch [scanning ? "on" : "off"] [src].</span>"

/obj/item/device/geiger_counter/AltClick()
	..()
	if(!scanning)
		usr << "<span class='warning'>[src] must be on to reset its radiation level!</span>"
		return 0
	radiation_count = 0
	usr << "<span class='notice'>You flush [src]'s radiation counts, resetting it to normal.</span>"
	update_icon()
