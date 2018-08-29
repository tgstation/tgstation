#define RAD_LEVEL_NORMAL 9
#define RAD_LEVEL_MODERATE 100
#define RAD_LEVEL_HIGH 400
#define RAD_LEVEL_VERY_HIGH 800
#define RAD_LEVEL_CRITICAL 1500

#define RAD_MEASURE_SMOOTHING 5

#define RAD_GRACE_PERIOD 2

/obj/item/geiger_counter //DISCLAIMER: I know nothing about how real-life Geiger counters work. This will not be realistic. ~Xhuis
	name = "\improper Geiger counter"
	desc = "A handheld device used for detecting and measuring radiation pulses."
	icon = 'icons/obj/device.dmi'
	icon_state = "geiger_off"
	item_state = "multitool"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	materials = list(MAT_METAL = 150, MAT_GLASS = 150)

	var/grace = RAD_GRACE_PERIOD
	var/datum/looping_sound/geiger/soundloop

	var/scanning = FALSE
	var/radiation_count = 0
	var/current_tick_amount = 0
	var/last_tick_amount = 0
	var/fail_to_receive = 0
	var/current_warning = 1

/obj/item/geiger_counter/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

	soundloop = new(list(src), FALSE)

/obj/item/geiger_counter/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/geiger_counter/process()
	update_icon()
	update_sound()

	if(!scanning)
		current_tick_amount = 0
		return

	radiation_count -= radiation_count/RAD_MEASURE_SMOOTHING
	radiation_count += current_tick_amount/RAD_MEASURE_SMOOTHING

	if(current_tick_amount)
		grace = RAD_GRACE_PERIOD
		last_tick_amount = current_tick_amount

	else if(!(obj_flags & EMAGGED))
		grace--
		if(grace <= 0)
			radiation_count = 0

	current_tick_amount = 0

/obj/item/geiger_counter/examine(mob/user)
	..()
	if(!scanning)
		return 1
	to_chat(user, "<span class='info'>Alt-click it to clear stored radiation levels.</span>")
	if(obj_flags & EMAGGED)
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

/obj/item/geiger_counter/update_icon()
	if(!scanning)
		icon_state = "geiger_off"
		return 1
	if(obj_flags & EMAGGED)
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

/obj/item/geiger_counter/proc/update_sound()
	var/datum/looping_sound/geiger/loop = soundloop
	if(!scanning)
		loop.stop()
		return
	if(!radiation_count)
		loop.stop()
		return
	loop.last_radiation = radiation_count
	loop.start()

/obj/item/geiger_counter/rad_act(amount)
	. = ..()
	if(amount <= RAD_BACKGROUND_RADIATION || !scanning)
		return
	current_tick_amount += amount
	update_icon()

/obj/item/geiger_counter/attack_self(mob/user)
	scanning = !scanning
	update_icon()
	to_chat(user, "<span class='notice'>[icon2html(src, user)] You switch [scanning ? "on" : "off"] [src].</span>")

/obj/item/geiger_counter/afterattack(atom/target, mob/user)
	. = ..()
	if(user.a_intent == INTENT_HELP)
		if(!(obj_flags & EMAGGED))
			user.visible_message("<span class='notice'>[user] scans [target] with [src].</span>", "<span class='notice'>You scan [target]'s radiation levels with [src]...</span>")
			addtimer(CALLBACK(src, .proc/scan, target, user), 20, TIMER_UNIQUE) // Let's not have spamming GetAllContents
		else
			user.visible_message("<span class='notice'>[user] scans [target] with [src].</span>", "<span class='danger'>You project [src]'s stored radiation into [target]!</span>")
			target.rad_act(radiation_count)
			radiation_count = 0
		return TRUE

/obj/item/geiger_counter/proc/scan(atom/A, mob/user)
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
		to_chat(user, "<span class='boldannounce'>[icon2html(src, user)] Target contains radioactive contamination. Radioactive strength: [rad_strength]</span>")
	else
		to_chat(user, "<span class='notice'>[icon2html(src, user)] Target is free of radioactive contamination.</span>")

/obj/item/geiger_counter/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/screwdriver) && (obj_flags & EMAGGED))
		if(scanning)
			to_chat(user, "<span class='warning'>Turn off [src] before you perform this action!</span>")
			return 0
		user.visible_message("<span class='notice'>[user] unscrews [src]'s maintenance panel and begins fiddling with its innards...</span>", "<span class='notice'>You begin resetting [src]...</span>")
		if(!I.use_tool(src, user, 40, volume=50))
			return 0
		user.visible_message("<span class='notice'>[user] refastens [src]'s maintenance panel!</span>", "<span class='notice'>You reset [src] to its factory settings!</span>")
		obj_flags &= ~EMAGGED
		radiation_count = 0
		update_icon()
		return 1
	else
		return ..()

/obj/item/geiger_counter/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE))
		return ..()
	if(!scanning)
		to_chat(usr, "<span class='warning'>[src] must be on to reset its radiation level!</span>")
		return 0
	radiation_count = 0
	to_chat(usr, "<span class='notice'>You flush [src]'s radiation counts, resetting it to normal.</span>")
	update_icon()

/obj/item/geiger_counter/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	if(scanning)
		to_chat(user, "<span class='warning'>Turn off [src] before you perform this action!</span>")
		return 0
	to_chat(user, "<span class='warning'>You override [src]'s radiation storing protocols. It will now generate small doses of radiation, and stored rads are now projected into creatures you scan.</span>")
	obj_flags |= EMAGGED

/obj/item/geiger_counter/cyborg
	var/datum/component/mobhook

/obj/item/geiger_counter/cyborg/equipped(mob/user)
	. = ..()
	if (mobhook && mobhook.parent != user)
		QDEL_NULL(mobhook)
	if (!mobhook)
		mobhook = user.AddComponent(/datum/component/redirect, list(COMSIG_ATOM_RAD_ACT = CALLBACK(src, .proc/redirect_rad_act)))

/obj/item/geiger_counter/cyborg/proc/redirect_rad_act(datum/source, amount)
	rad_act(amount)

/obj/item/geiger_counter/cyborg/dropped()
	. = ..()
	QDEL_NULL(mobhook)

#undef RAD_LEVEL_NORMAL
#undef RAD_LEVEL_MODERATE
#undef RAD_LEVEL_HIGH
#undef RAD_LEVEL_VERY_HIGH
#undef RAD_LEVEL_CRITICAL
