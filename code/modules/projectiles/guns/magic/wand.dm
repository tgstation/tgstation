/obj/item/weapon/gun/magic/wand/
	name = "wand of nothing"
	desc = "It's not just a stick, it's a MAGIC stick!"
	ammo_type = /obj/item/ammo_casing/magic
	icon_state = "nothingwand"
	item_state = "wand"
	w_class = 2
	can_charge = 0
	max_charges = 100 //100, 50, 50, 34 (max charge distribution by 25%ths)
	var/variable_charges = 1

/obj/item/weapon/gun/magic/wand/New()
	if(prob(75) && variable_charges) //25% chance of listed max charges, 50% chance of 1/2 max charges, 25% chance of 1/3 max charges
		if(prob(33))
			max_charges = Ceiling(max_charges / 3)
		else
			max_charges = Ceiling(max_charges / 2)
	..()

/obj/item/weapon/gun/magic/wand/examine()
	..()
	usr << "Has [charges] charge\s remaining."
	return

/obj/item/weapon/gun/magic/wand/update_icon()
	icon_state = "[initial(icon_state)][charges ? "" : "-drained"]"

/obj/item/weapon/gun/magic/wand/attack(atom/target as mob, mob/living/user as mob)
	if(target == user)
		return
	..()

/obj/item/weapon/gun/magic/wand/afterattack(atom/target as mob, mob/living/user as mob)
	if(!charges)
		shoot_with_empty_chamber(user)
		return
	if(target == user)
		zap_self(user)
	else
		..()
	update_icon()


/obj/item/weapon/gun/magic/wand/proc/zap_self(mob/living/user as mob)
	user.visible_message("<span class='notice'>[user] zaps \himself with [src]!</span>")
	playsound(user, fire_sound, 50, 1)
	user.attack_log += "\[[time_stamp()]\] <b>[user]/[user.ckey]</b> zapped \himself with a <b>[src]</b>"

/obj/item/weapon/gun/magic/wand/death
	name = "wand of death"
	desc = "This deadly wand overwhelms the victim's body with pure energy, slaying them without fail."
	ammo_type = /obj/item/ammo_casing/magic/death
	icon_state = "deathwand"
	max_charges = 3 //3, 2, 2, 1

/obj/item/weapon/gun/magic/wand/death/zap_self(mob/living/user as mob)
	var/message ="<span class='warning'>You irradiate yourself with pure energy! "
	message += pick("Do not pass go. Do not collect 200 zorkmids.</span>","You feel more confident in your spell casting skills.</span>","You Die...</span>","Do you want your possessions identified?</span>")
	user << message
	user.adjustOxyLoss(500)
	charges--
	..()

/obj/item/weapon/gun/magic/wand/resurrection
	name = "wand of healing"
	desc = "This wand uses healing magics to heal and revive. They are rarely utilized within the Wizard Federation for some reason."
	ammo_type = /obj/item/ammo_casing/magic/heal
	icon_state = "revivewand"
	max_charges = 10 //10, 5, 5, 4

/obj/item/weapon/gun/magic/wand/resurrection/zap_self(mob/living/user as mob)
	user.revive()
	user << "<span class='notice'>You feel great!</span>"
	charges--
	..()

/obj/item/weapon/gun/magic/wand/polymorph
	name = "wand of polymorph"
	desc = "This wand is attuned to chaos and will radically alter the victim's form."
	ammo_type = /obj/item/ammo_casing/magic/change
	icon_state = "polywand"
	max_charges = 10 //10, 5, 5, 4

/obj/item/weapon/gun/magic/wand/polymorph/zap_self(mob/living/user as mob)
	..() //because the user mob ceases to exists by the time wabbajack fully resolves
	wabbajack(user)
	charges--

/obj/item/weapon/gun/magic/wand/teleport
	name = "wand of teleportation"
	desc = "This wand will wrench targets through space and time to move them somewhere else."
	ammo_type = /obj/item/ammo_casing/magic/teleport
	icon_state = "telewand"
	max_charges = 10 //10, 5, 5, 4

/obj/item/weapon/gun/magic/wand/teleport/zap_self(mob/living/user as mob)
	do_teleport(user, user, 10)
	var/datum/effect/effect/system/harmless_smoke_spread/smoke = new /datum/effect/effect/system/harmless_smoke_spread()
	smoke.set_up(10, 0, user.loc)
	smoke.start()
	charges--
	..()

/obj/item/weapon/gun/magic/wand/door
	name = "wand of door creation"
	desc = "This particular wand can create doors in any wall for the unscrupulous wizard who shuns teleportation magics."
	ammo_type = /obj/item/ammo_casing/magic/door
	icon_state = "doorwand"
	max_charges = 20 //20, 10, 10, 7

/obj/item/weapon/gun/magic/wand/door/zap_self()
	return

/obj/item/weapon/gun/magic/wand/fireball
	name = "wand of fireball"
	desc = "This wand shoots scorching balls of fire that explode into destructive flames."
	ammo_type = /obj/item/ammo_casing/magic/fireball
	icon_state = "firewand"
	max_charges = 8 //8, 4, 4, 3

/obj/item/weapon/gun/magic/wand/fireball/zap_self(mob/living/user as mob)
	explosion(user.loc, -1, 0, 2, 3, 0, flame_range = 2)
	charges--
	..()