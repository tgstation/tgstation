
/obj/machinery/medical
	name = "Medical Unit"
	desc = "If you see this something went horrbily, horrbily wrong."
	icon = 'icons/obj/machines/medical_machinery.dmi'
	icon_state = "mechanical_liver"
	density = TRUE
	anchored = TRUE
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	payment_department = ACCOUNT_MED
	idle_power_usage = 100
	active_power_usage = 750
	///Whos is attached to the life support.
	var/mob/living/carbon/attached

/obj/machinery/medical/Initialize()
	. = ..()
	START_PROCESSING(SSmachines, src)

/obj/machinery/medical/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	anchored = !anchored
	return

/obj/machinery/medical/MouseDrop(mob/living/target)
	. = ..()
	if(!ishuman(usr) || !usr.canUseTopic(src, BE_CLOSE) || !isliving(target))
		return

	if(attached)
		usr.visible_message("<span class='warning'>[usr] deattaches [src] from [target].</span>", "<span class='notice'>You deattach [src] from [target].</span>")
		clear_status()
		attached = null
		return

	if(!target.has_dna())
		to_chat(usr, "<span class='danger'>The [name] beeps: \"warning, incompatible creature!\"</span>")
		return

	if(Adjacent(target) && usr.Adjacent(target))
		usr.visible_message("<span class='warning'>[usr] attaches [src] to [target].</span>", "<span class='notice'>You attach [src] to [target].</span>")
		add_fingerprint(usr)
		attached = target
		update_overlays()

/obj/machinery/medical/process()

	update_overlays()
	update_icon()

	if(!attached)
		use_power = IDLE_POWER_USE
		return

	if(machine_stat && (NOPOWER|BROKEN))
		clear_status()
		return

	if(!(get_dist(src, attached) <= 1 && isturf(attached.loc))) //you will most likely have multiple machines hooked up to you. Running away from them is a bad idea.
		to_chat(attached, "<span class='userdanger'>The [name] lines are ripped out of you!</span>")
		attached.apply_damage(20, BRUTE, BODY_ZONE_CHEST)
		attached.apply_damage(15, BRUTE, pick(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM))
		clear_status()
		attached = null
		return

	use_power = ACTIVE_POWER_USE

	return

/**
  * Properly gets rid of status effects from the attached
  *
  * Internal function, you shouldn't be calling this from anywhere else. Gets rid of all the status effects, traits and other shit you might have
  * put on the attached victim. Automatically updates overlays in case you have some, and changes power to idle power use.
  */
/obj/machinery/medical/proc/clear_status()
	update_overlays()
	use_power = IDLE_POWER_USE
	return


