
/obj/item/device/pressure_plate
	name = "pressure plate"
	desc = "An electronic device that triggers when stepped on."
	item_state = "flash"
	icon_state = "pressureplate"
	level = 1
	var/trigger_mob = TRUE 
	var/trigger_structure = TRUE //closets, crates, etc... wall girders O_o
	var/trigger_item = TRUE
	var/trigger_mob_min_size = MOB_SIZE_HUMAN //only trigger for those and bigger
	var/trigger_item_min_w_class = WEIGHT_CLASS_HUGE //same but for items
	var/trigger_silent = FALSE
	var/sound/trigger_sound = 'sound/effects/pressureplate.ogg'
	var/obj/item/device/assembly/signaler/sigdev = null
	var/roundstart_signaller = FALSE
	var/roundstart_signaller_freq = FREQ_PRESSURE_PLATE
	var/roundstart_signaller_code = 30
	var/roundstart_hide = FALSE
	var/removable_signaller = TRUE
	var/active = FALSE
	var/image/tile_overlay = null
	var/crossed = FALSE
	var/pre_trigger_delay = 3 //will not activate if triggered before within pre_trigger
	var/post_trigger_delay = 3 //delay between pre_trigger and actual trigger

/obj/item/device/pressure_plate/Initialize()
	. = ..()
	if(roundstart_signaller)
		sigdev = new
		sigdev.code = roundstart_signaller_code
		sigdev.frequency = roundstart_signaller_freq
		if(isopenturf(loc))
			hide(TRUE)

/obj/item/device/pressure_plate/Crossed(atom/movable/AM)
	. = ..()
	if(!active)
		return
	if(trigger_mob && isliving(AM))
		var/mob/living/L = AM
		if(L.mob_size < trigger_mob_min_size)
			return
		step_living(L)
	else if(isitem(AM) && trigger_item)
		var/obj/item/I = AM
		if(I.w_class<trigger_item_min_w_class)
			return
		step_item(I)
	else if(istype(AM, /obj/structure) && trigger_structure)
		var/obj/structure/S = AM
		step_struct(S)
	else
		return
	if(tile_overlay)
		loc.overlays -= tile_overlay
		tile_overlay.pixel_y = -1
		loc.overlays += tile_overlay
	crossed = TRUE
	if(!trigger_silent)
		if(isturf(loc))
			loc.visible_message("<span class='danger'>Click!</span>")
			playsound(loc, trigger_sound, 50, 1)

/obj/item/device/pressure_plate/Uncrossed(atom/movable/AM)
	. = ..()
	if(!active)
		return
	if(crossed)
		if(isliving(AM) && trigger_mob)
			var/mob/living/L = AM
			if(L.mob_size < trigger_mob_min_size)
				return
			unstep_living(L)
		else if(isitem(AM) && trigger_item)
			var/obj/item/I = AM
			if(I.w_class<trigger_item_min_w_class)
				return
			unstep_item(I)
		else if(istype(AM, /obj/structure) && trigger_structure)
			var/obj/structure/S = AM
			unstep_struct(S)
		else
			return
		playsound(loc, trigger_sound, 50, 1)
		addtimer(CALLBACK(src, .proc/pre_trigger), pre_trigger_delay)
		if(tile_overlay)
			loc.overlays -= tile_overlay
			tile_overlay.pixel_y = 1
			loc.overlays += tile_overlay
		crossed = FALSE

/obj/item/device/pressure_plate/proc/pre_trigger()
	if(crossed)
		return
	addtimer(CALLBACK(src, .proc/trigger), post_trigger_delay)

/obj/item/device/pressure_plate/proc/trigger()
	if(istype(sigdev))
		sigdev.signal()

/obj/item/device/pressure_plate/proc/step_living(mob/living/L)
	to_chat(L, "<span class='warning'>You feel a click under your feet!</span>")
/obj/item/device/pressure_plate/proc/unstep_living(mob/living/L)
	to_chat(L, "<span class='warning'>You feel something click back into place as you step off [loc]!</span>")
/obj/item/device/pressure_plate/proc/step_item(obj/item/I)
	return
/obj/item/device/pressure_plate/proc/unstep_item(obj/item/I)
	return
/obj/item/device/pressure_plate/proc/step_struct(obj/structure/S)
	return
/obj/item/device/pressure_plate/proc/unstep_struct(obj/structure/S)
	return

/obj/item/device/pressure_plate/attackby(obj/item/I, mob/living/L)
	if(istype(I, /obj/item/device/assembly/signaler) && !istype(sigdev) && removable_signaller && L.transferItemToLoc(I, src))
		sigdev = I
		to_chat(L, "<span class='notice'>You attach [I] to [src]!</span>")
	return ..()

/obj/item/device/pressure_plate/attack_self(mob/living/L)
	if(removable_signaller && istype(sigdev))
		to_chat(L, "<span class='notice'>You remove [sigdev] from [src]</span>")
		if(!L.put_in_hands(sigdev))
			sigdev.forceMove(get_turf(src))
		sigdev = null
	return ..()

/obj/item/device/pressure_plate/hide(yes)
	if(yes)
		invisibility = INVISIBILITY_MAXIMUM
		anchored = TRUE
		icon_state = null
		active = TRUE
		var/turf/T = get_turf(src)
		if(tile_overlay)
			qdel(tile_overlay)
		spawn(0)
			tile_overlay = image(icon = T.icon, icon_state = T.icon_state)
			tile_overlay.pixel_y = 1
			if(tile_overlay)
				loc.overlays += tile_overlay
	else
		if(crossed && prob(84)) 
			trigger()	//16% chance to safely disarm
		invisibility = initial(invisibility)
		anchored = FALSE
		icon_state = initial(icon_state)
		active = FALSE
		if(tile_overlay)
			loc.overlays -= tile_overlay

