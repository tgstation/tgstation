/*

Miscellaneous traitor devices

BATTERER

RADIOACTIVE MICROLASER

*/

/*

The Batterer, like a flashbang but 50% chance to knock people over. Can be either very
effective or pretty fucking useless.

*/

/obj/item/device/batterer
	name = "mind batterer"
	desc = "A strange device with twin antennas."
	icon_state = "batterer"
	throwforce = 5
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	item_state = "electronic"
	origin_tech = "magnets=3;combat=3;syndicate=3"

	var/times_used = 0 //Number of times it's been used.
	var/max_uses = 2


/obj/item/device/batterer/attack_self(mob/living/carbon/user, flag = 0, emp = 0)
	if(!user) 	return
	if(times_used >= max_uses)
		to_chat(user, "<span class='danger'>The mind batterer has been burnt out!</span>")
		return

	add_logs(user, null, "knocked down people in the area", src)

	for(var/mob/living/carbon/human/M in urange(10, user, 1))
		if(prob(50))

			M.Weaken(rand(10,20))
			if(prob(25))
				M.Stun(rand(5,10))
			to_chat(M, "<span class='userdanger'>You feel a tremendous, paralyzing wave flood your mind.</span>")

		else
			to_chat(M, "<span class='userdanger'>You feel a sudden, electric jolt travel through your head.</span>")

	playsound(src.loc, 'sound/misc/interference.ogg', 50, 1)
	to_chat(user, "<span class='notice'>You trigger [src].</span>")
	times_used += 1
	if(times_used >= max_uses)
		icon_state = "battererburnt"

/*
		The radioactive microlaser, a device disguised as a health analyzer used to irradiate people.

		The strength of the radiation is determined by the 'intensity' setting, while the delay between
	the scan and the irradiation kicking in is determined by the wavelength.

		Each scan will cause the microlaser to have a brief cooldown period. Higher intensity will increase
	the cooldown, while higher wavelength will decrease it.

		Wavelength is also slightly increased by the intensity as well.
*/

/obj/item/device/healthanalyzer/rad_laser
	materials = list(MAT_METAL=400)
	origin_tech = "magnets=3;biotech=5;syndicate=3"
	var/irradiate = 1
	var/intensity = 69.0 // how much damage the radiation does
	var/wavelength = 10 // time it takes for the radiation to kick in, in seconds
	var/used = 0 // is it cooling down?

/obj/item/device/healthanalyzer/rad_laser/attack(mob/living/M, mob/living/user)
	..()
	if(!irradiate)
		return
	if(!used)
		add_logs(user, M, "irradiated", src)
		var/cooldown = round(max(10, (intensity*5 - wavelength/4))) * 10
		used = 1
		icon_state = "health1"
		handle_cooldown(cooldown) // splits off to handle the cooldown while handling wavelength
		to_chat(user, "<span class='warning'>Successfully irradiated [M].</span>")
		spawn((wavelength+(intensity*4))*5)
			if(M)
				M.rad_act(intensity*10)
	else
		to_chat(user, "<span class='warning'>The radioactive microlaser is still recharging.</span>")

/obj/item/device/healthanalyzer/rad_laser/proc/handle_cooldown(cooldown)
	spawn(cooldown)
		used = 0
		icon_state = "health"

/obj/item/device/shadowcloak
	name = "cloaker belt"
	desc = "Makes you invisible for short periods of time. Recharges in darkness."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utilitybelt"
	item_state = "utility"
	slot_flags = SLOT_BELT
	attack_verb = list("whipped", "lashed", "disciplined")

	var/mob/living/carbon/human/user = null
	var/charge = 300
	var/max_charge = 300
	var/on = 0
	var/old_alpha = 0
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/device/shadowcloak/ui_action_click(mob/user)
	if(user.get_item_by_slot(slot_belt) == src)
		if(!on)
			Activate(usr)
		else
			Deactivate()
	return

/obj/item/device/shadowcloak/item_action_slot_check(slot, mob/user)
	if(slot == slot_belt)
		return 1

/obj/item/device/shadowcloak/proc/Activate(mob/living/carbon/human/user)
	if(!user)
		return
	to_chat(user, "<span class='notice'>You activate [src].</span>")
	src.user = user
	START_PROCESSING(SSobj, src)
	old_alpha = user.alpha
	on = 1

/obj/item/device/shadowcloak/proc/Deactivate()
	to_chat(user, "<span class='notice'>You deactivate [src].</span>")
	STOP_PROCESSING(SSobj, src)
	if(user)
		user.alpha = old_alpha
	on = 0
	user = null

/obj/item/device/shadowcloak/dropped(mob/user)
	..()
	if(user && user.get_item_by_slot(slot_belt) != src)
		Deactivate()

/obj/item/device/shadowcloak/process()
	if(user.get_item_by_slot(slot_belt) != src)
		Deactivate()
		return
	var/turf/T = get_turf(src)
	if(on)
		var/lumcount = T.get_lumcount()
		if(lumcount > 0.3)
			charge = max(0,charge - 25)//Quick decrease in light
		else
			charge = min(max_charge,charge + 50) //Charge in the dark
		animate(user,alpha = Clamp(255 - charge,0,255),time = 10)


/obj/item/device/jammer
	name = "radio jammer"
	desc = "Device used to disrupt nearby radio communication."
	icon_state = "jammer"
	var/active = FALSE
	var/range = 12

/obj/item/device/jammer/attack_self(mob/user)
	to_chat(user,"<span class='notice'>You [active ? "deactivate" : "activate"] the [src]<span>") 
	active = !active
	if(active)
		GLOB.active_jammers |= src
	else
		GLOB.active_jammers -= src
	update_icon()

	