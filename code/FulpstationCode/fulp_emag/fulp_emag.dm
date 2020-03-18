/obj/item/card/emag/budget
	desc = "It's a card with a magnetic strip attached to some circuitry. This one appears to be a crude knockoff with a digital counter on closer inspection."
	name = "budget cryptographic sequencer"
	var/charges = 2
	var/cooldown = 300 //300 deciseconds
	var/freebie
	var/timestamp

/obj/item/card/emag/budget/Initialize()
	. = ..()
	maptext = "[charges]"


/obj/item/card/emag/budget/afterattack(atom/target, mob/user, proximity)
	if(!charges)
		to_chat(user, "<span class='warning'>[src] is out of charges and needs [((timestamp + cooldown) - world.time) / 10] more seconds to recharge!</span>")
		return

	if(check_emag_status(target, user)) //Check whether it's already emagged; if so, no need to progress. Exception for borgs that have their panel open because they can be repeatedly emagged.
		return

	. = ..()

	if(!check_emag_status(target, user, FALSE)) //Check whether there's a change in emag state; if not, we don't deduct a charge.
		return

	expend_charge(user)

/obj/item/card/emag/budget/proc/expend_charge(mob/user)

	if(freebie) //If we have a free use for whatever reason, like the borg delay, deduct a freebie and prevent charge usage.
		freebie = max(0, freebie - 1)
		return

	charges = max(charges - 1, 0)
	maptext = "[charges]"
	timestamp = world.time
	if(user)
		to_chat(user, "<span class='warning'>[src] has expended a charge and has [charges] charges remaining. It will regain a charge in [((timestamp + cooldown) - world.time) / 10] seconds.</span>")

	addtimer(CALLBACK(src, .proc/recharge), cooldown) //recharge proc

/obj/item/card/emag/budget/proc/recharge()
	charges = min(charges + 1, 2)
	maptext = "[charges]"
	playsound(loc, SEC_BODY_CAM_SOUND, get_clamped_volume(), TRUE, -1)


/obj/item/card/emag/budget/proc/check_emag_status(atom/A, mob/user, pre_check = TRUE)
	if(!A)
		return FALSE

	if(istype(A, /obj))
		var/obj/O = A
		if(istype(O, /obj/structure/closet))
			var/obj/structure/closet/C = O
			if(C.broken) //Because closets don't directly alter their emag status
				return TRUE

		if(O.obj_flags & EMAGGED)
			return TRUE

	if(istype(A, /mob/living/simple_animal/bot))
		var/mob/living/simple_animal/bot/B = A
		if(!B.emagged)
			return TRUE

	if(istype(A, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = A

		if(pre_check) //Checks specific to the pre-emag act
			if((world.time < R.emag_cooldown) && R.opened) //If the borg anti-spam check is on cooldown during the pre-check, and we can actually reprogram, fuggedabout it.
				return TRUE

			if(!R.locked && !R.opened) //Nothing emag can do here; need crowbar to pop the cover.
				return TRUE

			if(R.opened)
				expend_charge(user) //Need to pay the charge forward because of the borg subversion delay.
				freebie += 1 //Put a credit on this so we don't pay twice.

			return FALSE //If the cover is open excepting cooldown, or locked, we will always pass false for the pre-check and true for the post-check as borgs can be subverted any number of times.

		return TRUE //We always assume emag is true during the post-check so we can re-subvert borgs; further, we will deplete a charge if the cover was locked at the time of the pre-check.

	return FALSE


//EMAG INTERACTIONS

/mob/living/silicon/robot/proc/fulp_emag_features() //Enable kill mode.when emagged
	if(istype(module, /obj/item/robot_module/security)) //Thus far we only deal with security modules; there is support for others though.
		var/obj/item/gun/energy/e_gun/cyborg/T = check_for_item(/obj/item/gun/energy/e_gun/cyborg)
		if(!T)
			return
		if(emagged)
			T.ammo_type = list(/obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser)
		else if(!locate(/obj/item/borg/upgrade/e_gun_lethal) in upgrades) //Only revert if we don't have the requisite upgrade for lethals
			T.ammo_type = list(/obj/item/ammo_casing/energy/disabler)
		T.update_ammo_types()