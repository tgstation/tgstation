
/obj/item/gun/energy/mounted
	name = "mounted e-gun"
	desc = "The parent of all mounted energy guns"
	icon = 'icons/obj/items_cyborg.dmi'
	inhand_icon_state = "armcannonlase"
	ammo_x_offset = 1
	shaded_charge = 1
	force = 5
	selfcharge = 1
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	can_flashlight = FALSE

/obj/item/gun/energy/mounted/dropped()
	..()

/obj/item/gun/energy/mounted/laser
	name = "mounted laser"
	desc = "An arm mounted cannon that fires lethal lasers."
	icon_state = "laser_cyborg"
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun)

/obj/item/gun/energy/mounted/taser
	name = "mounted taser"
	desc = "An arm mounted dual-mode weapon that fires electrodes and disabler shots."
	icon_state = "taser"
	inhand_icon_state = "armcannonstun4"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/disabler)
	ammo_x_offset = 2

/obj/item/gun/energy/mounted/leachgun
	name = "mounted leach-rifle"
	desc = "Exchange your own vitality for awesome power!\n Use in-hand to begin the recharge proccess."
	icon_state = "leach_gun"
	inhand_icon_state = "armcannonleach"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/leach)
	selfcharge = 0
	var/cooldown = 0

/obj/item/gun/energy/mounted/leachgun/attack_self(mob/living/user)
	if(cooldown > world.time)
		to_chat(user, "<span class='userwarning'>The [src] is still getting ready to recharge again.</span>")
		return
	if(src.cell.percent() == 100)
		to_chat(user, "<span class='userwarning'>The [src] is already fully charged.</span>")
		return
	cooldown = (world.time + 20 SECONDS)
	to_chat(user, "<span class='userdanger'>You begin the recharging proccess...</span>")
	do
		if(do_after(user, 3 SECONDS, timed_action_flags = (IGNORE_USER_LOC_CHANGE|IGNORE_HELD_ITEM)))
			to_chat(user, "<span class='userdanger'>[pick("It hurts...", "You feel your energy being draining away...", "Your body goes numb...")]</span>")
			user.emote(pick("twitch","scream"))
			do_sparks(1, TRUE, src)
			user.adjustStaminaLoss(20, 0)
			user.Dizzy(10)
			user.Jitter(15)
			cell.give(300)
			src.update_icon()
		else
			emergencydump(user)
			return
	while(src.cell.percent() < 100)
	if(do_after(user, 7 SECONDS, timed_action_flags = (IGNORE_USER_LOC_CHANGE|IGNORE_HELD_ITEM)))
		to_chat(user, "<span class='userdanger'>[pick("You feel relief as the draining stops...", "The pain is over...", "The strain on your body subsides...")]</span>")
		playsound (src, pick('sound/effects/sparks1.ogg', 'sound/effects/sparks2.ogg','sound/effects/sparks3.ogg'), 20, TRUE, )
	else
		emergencydump(user)
		return
	if (user.getStaminaLoss() + user.getFireLoss() + user.getBruteLoss() > 60) // collapse if sufficantly wounded or over drained
		to_chat(user,"<span class='warning'>You collapse in relief</span>")
		user.adjustStaminaLoss(200, 0)
		user.emote("moan")


/obj/item/gun/energy/mounted/leachgun/proc/emergencydump(mob/living/user) // used when somthing unexpected happens durring the recharge
		to_chat(user,"<span class='warning'>UNEXPECTED ANOMALY: Emergency dropout protocol initiated</span>")
		user.adjustStaminaLoss(200, 0)
		user.emote("moan")
