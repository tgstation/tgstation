
/obj/item/device/pressure_plate
	name = "pressure plate"
	desc = "Useful for autismforts"
	item_state = "flash"
	icon_state = "pressureplate"
	var/trigger_mob = TRUE
	var/trigger_item = FALSE
	var/trigger_silent = FALSE
	var/sound/trigger_sound = 'sound/effects/pressureplate.ogg'
	var/obj/item/device/assembly/signaler/sigdev = null
	var/roundstart_signaller = FALSE
	var/roundstart_signaller_freq = 1447
	var/roundstart_signaller_code = 30
	var/roundstart_hide = FALSE
	var/removable_signaller = TRUE
	var/active = FALSE

/obj/item/device/pressure_plate/Initialize()
	..()
	if(roundstart_signaller)
		sigdev = new
		sigdev.code = roundstart_signaller_code
		sigdev.frequency = roundstart_signaller_freq
		if(istype(loc, /turf/open))
			hide(TRUE)

/obj/item/device/pressure_plate/proc/stepped_on(atom/movable/AM)
	if(!active)
		return
	if(isliving(AM) && trigger_mob)
		var/mob/living/L = AM
		step_living(L)
	else if(trigger_item)
		step_item(AM)
	if(!trigger_silent)
		if(isturf(loc))
			loc.visible_message("<span class='danger'>Click!</span>")
			playsound(loc, trigger_sound, 50, 1)
	if(istype(sigdev))
		sigdev.signal()

/obj/item/device/pressure_plate/proc/step_living(mob/living/L)
	L << "<span class='warning'>You feel a click under your feet!</span>"

/obj/item/device/pressure_plate/proc/step_item(atom/movable/AM)
	return

/obj/item/device/pressure_plate/attackby(obj/item/I, mob/living/L)
	if(istype(I, /obj/item/device/assembly/signaler) && !istype(sigdev) && removable_signaller)
		sigdev = I
		I.forceMove(src)
	L << "<span class='notice'>You attach [I] to [src]!</span>"

/obj/item/device/pressure_plate/attack_self(mob/living/L)
	if(removable_signaller && istype(sigdev))
		L << "<span class='notice'>You remove [sigdev] from [src]</span>"
		if(!L.put_in_hands(sigdev))
			sigdev.forceMove(get_turf(src))
		sigdev = null

/obj/item/device/pressure_plate/hide(yes)
	if(yes)
		invisibility = INVISIBILITY_MAXIMUM
		anchored = TRUE
		icon_state = null
		active = TRUE
	else
		invisibility = initial(invisibility)
		anchored = FALSE
		icon_state = initial(icon_state)
		active = FALSE

