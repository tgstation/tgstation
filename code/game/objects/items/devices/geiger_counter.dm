#define RAD_LEVEL_NORMAL 10
#define RAD_LEVEL_MODERATE 30
#define RAD_LEVEL_HIGH 75
#define RAD_LEVEL_VERY_HIGH 125
#define RAD_LEVEL_CRITICAL 200

/obj/item/device/geiger_counter //DISCLAIMER: I know nothing about how real-life Geiger counters work. This will not be realistic. ~Xhuis
	name = "geiger counter"
	desc = "A handheld device used for detecting and measuring radiation pulses."
	icon_state = "geiger_off"
	item_state = "multitool"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL = 150, MAT_GLASS = 150)
	var/scanning = 0
	var/radiation_count = 0
	var/emagged = 0

/obj/item/device/geiger_counter/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/device/geiger_counter/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/device/geiger_counter/process()
	if(emagged)
		if(radiation_count < 20)
			radiation_count++
		return 0
	if(radiation_count > 0)
		radiation_count--
		update_icon()

/obj/item/device/geiger_counter/examine(mob/user)
	..()
	if(!scanning)
		return 1
	to_chat(user, "<span class='info'>Alt-click it to clear stored radiation levels.</span>")
	if(emagged)
		to_chat(user, "<span class='warning'>The display seems to be incomprehensible.</span>")
		return 1
	switch(radiation_count)
		if(-INFINITY to RAD_LEVEL_NORMAL)
			to_chat(user, "<span class='notice'>Ambient radiation level count reports that all is well.</span>")
		if(RAD_LEVEL_NORMAL + 1 to RAD_LEVEL_MODERATE)
			to_chat(user, "<span class='disarm'>Ambient radiation levels slightly above average.</span>")
		if(RAD_LEVEL_MODERATE + 1 to RAD_LEVEL_HIGH)
			to_chat(user, "<span class='warning'>Ambient radiation levels above average.</span>")
		if(RAD_LEVEL_HIGH + 1 to RAD_LEVEL_VERY_HIGH)
			to_chat(user, "<span class='danger'>Ambient radiation levels highly above average.</span>")
		if(RAD_LEVEL_VERY_HIGH + 1 to RAD_LEVEL_CRITICAL)
			to_chat(user, "<span class='suicide'>Ambient radiation levels nearing critical level.</span>")
		if(RAD_LEVEL_CRITICAL + 1 to INFINITY)
			to_chat(user, "<span class='boldannounce'>Ambient radiation levels above critical level!</span>")

/obj/item/device/geiger_counter/update_icon()
	if(!scanning)
		icon_state = "geiger_off"
		return 1
	if(emagged)
		icon_state = "geiger_on_emag"
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
	if(emagged)
		amount = Clamp(amount, 0, 25) //Emagged geiger counters can only accept 25 radiation at a time
	radiation_count += amount
	if(isliving(loc))
		var/mob/living/M = loc
		if(!emagged)
			to_chat(M, "<span class='boldannounce'>[bicon(src)] RADIATION PULSE DETECTED.</span>")
			to_chat(M, "<span class='boldannounce'>[bicon(src)] Severity: [amount]</span>")
		else
			to_chat(M, "<span class='boldannounce'>[bicon(src)] !@%$AT!(N P!LS! D/TEC?ED.</span>")
			to_chat(M, "<span class='boldannounce'>[bicon(src)] &!F2rity: <=[amount]#1</span>")
	update_icon()

/obj/item/device/geiger_counter/attack_self(mob/user)
	scanning = !scanning
	update_icon()
	to_chat(user, "<span class='notice'>[bicon(src)] You switch [scanning ? "on" : "off"] [src].</span>")

/obj/item/device/geiger_counter/attack(mob/living/M, mob/user)
	if(user.a_intent == INTENT_HELP)
		if(!emagged)
			user.visible_message("<span class='notice'>[user] scans [M] with [src].</span>", "<span class='notice'>You scan [M]'s radiation levels with [src]...</span>")
			if(!M.radiation)
				to_chat(user, "<span class='notice'>[bicon(src)] Radiation levels within normal boundaries.</span>")
				return 1
			else
				to_chat(user, "<span class='boldannounce'>[bicon(src)] Subject is irradiated. Radiation levels: [M.radiation].</span>")
				return 1
		else
			user.visible_message("<span class='notice'>[user] scans [M] with [src].</span>", "<span class='danger'>You project [src]'s stored radiation into [M]'s body!</span>")
			M.rad_act(radiation_count)
			radiation_count = 0
		return 1
	..()

/obj/item/device/geiger_counter/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver) && emagged)
		if(scanning)
			to_chat(user, "<span class='warning'>Turn off [src] before you perform this action!</span>")
			return 0
		user.visible_message("<span class='notice'>[user] unscrews [src]'s maintenance panel and begins fiddling with its innards...</span>", "<span class='notice'>You begin resetting [src]...</span>")
		playsound(user, I.usesound, 50, 1)
		if(!do_after(user, 40*I.toolspeed, target = user))
			return 0
		user.visible_message("<span class='notice'>[user] refastens [src]'s maintenance panel!</span>", "<span class='notice'>You reset [src] to its factory settings!</span>")
		playsound(user, 'sound/items/Screwdriver2.ogg', 50, 1)
		emagged = 0
		radiation_count = 0
		update_icon()
		return 1
	else
		return ..()

/obj/item/device/geiger_counter/AltClick(mob/living/user)
	if(!istype(user) || user.incapacitated())
		return ..()
	if(!scanning)
		to_chat(usr, "<span class='warning'>[src] must be on to reset its radiation level!</span>")
		return 0
	radiation_count = 0
	to_chat(usr, "<span class='notice'>You flush [src]'s radiation counts, resetting it to normal.</span>")
	update_icon()

/obj/item/device/geiger_counter/emag_act(mob/user)
	if(!emagged)
		if(scanning)
			to_chat(user, "<span class='warning'>Turn off [src] before you perform this action!</span>")
			return 0
		to_chat(user, "<span class='warning'>You override [src]'s radiation storing protocols. It will now generate small doses of radiation, and stored rads are now projected into creatures you scan.</span>")
		emagged = 1

#undef RAD_LEVEL_NORMAL
#undef RAD_LEVEL_MODERATE
#undef RAD_LEVEL_HIGH
#undef RAD_LEVEL_VERY_HIGH
#undef RAD_LEVEL_CRITICAL
