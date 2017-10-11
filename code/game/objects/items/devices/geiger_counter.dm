#define RAD_LEVEL_NORMAL 100
#define RAD_LEVEL_MODERATE 500
#define RAD_LEVEL_HIGH 1000
#define RAD_LEVEL_VERY_HIGH 2000
#define RAD_LEVEL_CRITICAL 5000

#define RAD_MEASURE_SMOOTHING 20

/obj/item/device/geiger_counter //DISCLAIMER: I know nothing about how real-life Geiger counters work. This will not be realistic. ~Xhuis
	name = "geiger counter"
	desc = "A handheld device used for detecting and measuring radiation pulses."
	icon_state = "geiger_off"
	item_state = "multitool"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL = 150, MAT_GLASS = 150)
	var/scanning = 0
	var/radiation_count = 0
	var/current_tick_amount = 0
	var/last_tick_amount = 0

/obj/item/device/geiger_counter/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/device/geiger_counter/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/device/geiger_counter/process()
	if(emagged)
		if(radiation_count < 200)
			radiation_count++
		return 0
	if(radiation_count > 0)
		radiation_count-=10
		update_icon()
	if(current_tick_amount)
		if(isliving(loc))
			var/mob/living/M = loc
			if(!emagged)
				to_chat(M, "<span class='boldannounce'>[icon2html(src, M)] RADIATION PULSE DETECTED.</span>")
				to_chat(M, "<span class='boldannounce'>[icon2html(src, M)] Severity: [current_tick_amount]</span>")
			else
				to_chat(M, "<span class='boldannounce'>[icon2html(src, M)] !@%$AT!(N P!LS! D/TEC?ED.</span>")
				to_chat(M, "<span class='boldannounce'>[icon2html(src, M)] &!F2rity: <=[current_tick_amount]#1</span>")
		last_tick_amount = current_tick_amount

	current_tick_amount = 0

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

	to_chat(user, "<span class='notice'>The last radiation amount detected was [last_tick_amount]</span>")

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
	if(amount <= RAD_BACKGROUND_RADIATION || !scanning)
		return
	radiation_count = (radiation_count - (radiation_count/RAD_MEASURE_SMOOTHING)) + (amount/RAD_MEASURE_SMOOTHING)
	current_tick_amount += amount
	update_icon()

/obj/item/device/geiger_counter/attack_self(mob/user)
	scanning = !scanning
	update_icon()
	to_chat(user, "<span class='notice'>[icon2html(src, user)] You switch [scanning ? "on" : "off"] [src].</span>")

/obj/item/device/geiger_counter/attack(mob/living/M, mob/user)
	if(user.a_intent == INTENT_HELP)
		if(!emagged)
			user.visible_message("<span class='notice'>[user] scans [M] with [src].</span>", "<span class='notice'>You scan [M]'s radiation levels with [src]...</span>")
			addtimer(CALLBACK(src, .proc/scan, M, user), 20, TIMER_UNIQUE) // Let's not have spamming GetAllContents
		else
			user.visible_message("<span class='notice'>[user] scans [M] with [src].</span>", "<span class='danger'>You project [src]'s stored radiation into [M]'s body!</span>")
			M.rad_act(radiation_count)
			radiation_count = 0
		return 1
	..()

/obj/item/device/geiger_counter/proc/scan(atom/A, mob/user)
	var/rad_strength = 0
	for(var/i in get_rad_contents(A)) // Yes it's intentional that you can't detect radioactive things under rad protection. Gives traitors a way to hide their glowing green rocks.
		var/atom/thing = i
		if(!thing)
			continue
		var/datum/component/radioactive/radiation = thing.GetComponent(/datum/component/radioactive)
		if(radiation)
			rad_strength += radiation.strength

	if(isliving(A))
		var/mob/living/M = A
		if(!M.radiation)
			to_chat(user, "<span class='notice'>[icon2html(src, user)] Radiation levels within normal boundaries.</span>")
		else
			to_chat(user, "<span class='boldannounce'>[icon2html(src, user)] Subject is irradiated. Radiation levels: [M.radiation].</span>")

	if(rad_strength)
		to_chat(user, "<span class='boldannounce'>[icon2html(src, user)] Subject has irradiated objects on them. Radioactive strength: [rad_strength]</span>")
	else
		to_chat(user, "<span class='notice'>[icon2html(src, user)] Subject is free of radioactive contamination.</span>")

/obj/item/device/geiger_counter/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/screwdriver) && emagged)
		if(scanning)
			to_chat(user, "<span class='warning'>Turn off [src] before you perform this action!</span>")
			return 0
		user.visible_message("<span class='notice'>[user] unscrews [src]'s maintenance panel and begins fiddling with its innards...</span>", "<span class='notice'>You begin resetting [src]...</span>")
		playsound(user, I.usesound, 50, 1)
		if(!do_after(user, 40*I.toolspeed, target = user))
			return 0
		user.visible_message("<span class='notice'>[user] refastens [src]'s maintenance panel!</span>", "<span class='notice'>You reset [src] to its factory settings!</span>")
		playsound(user, 'sound/items/screwdriver2.ogg', 50, 1)
		emagged = FALSE
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
	if(emagged)
		return
	if(scanning)
		to_chat(user, "<span class='warning'>Turn off [src] before you perform this action!</span>")
		return 0
	to_chat(user, "<span class='warning'>You override [src]'s radiation storing protocols. It will now generate small doses of radiation, and stored rads are now projected into creatures you scan.</span>")
	emagged = TRUE

#undef RAD_LEVEL_NORMAL
#undef RAD_LEVEL_MODERATE
#undef RAD_LEVEL_HIGH
#undef RAD_LEVEL_VERY_HIGH
#undef RAD_LEVEL_CRITICAL
