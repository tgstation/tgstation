/*
* All weapon related code goes here.
*/

/*
* Variables
*/
var/const/SKNIFE_STUNTIME = 6
var/const/SKNIFE_CHARGE_COST = 125 // floor(1000 / n) = # of hits, 1000 / # of hits = cost

var/const/USE_SKNIFE_CHARGES = 1
var/const/SKNIFE_IS_AUTO_RECHARGING = 0
var/const/SKNIFE_CHARGE_INTERVAL = 50
var/const/SKNIFE_LETHAL_USE_CHARGE = 0

/*
* Five Seven
*/

/obj/item/projectile/bullet/fiveseven
	damage = 49
	knockdown = 120

/obj/item/ammo_casing/fiveseven
	desc = "A 5.7x28mm casing"
	caliber = "5.7x28mm"
	projectile_type = /obj/item/projectile/bullet/fiveseven


/obj/item/ammo_box/magazine/fiveseven
	name = "5.7x28mm magazine"
	icon_state = "45"
	icon = 'icons/oldschool/perseus.dmi'
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/fiveseven
	caliber = "5.7x28mm"
	max_ammo = 20
	multiple_sprites = 0

// PIN

/obj/item/device/firing_pin/implant/perseus
	req_implant = /obj/item/implant/enforcer

/obj/item/device/firing_pin/implant/perseus/pin_auth(mob/living/user)
	if(emagged)
		return 1
	else return ..()

/obj/item/device/firing_pin/implant/perseus/emag_act(mob/living/user)
	return

/obj/item/device/firing_pin/implant/perseus/auth_fail(mob/living/user)
	var/datum/effect_system/spark_spread/S = new(get_turf(src))
	S.set_up(3, 0, get_turf(src))
	S.start()
	to_chat(user, "<div class='warning'>The [src] shocks you.</div>")
	user.AdjustKnockdown(2)

/obj/item/gun/ballistic/fiveseven
	name = "five-seven"
	icon = 'icons/oldschool/perseus.dmi'
	icon_state = "fiveseven"
	mag_type = /obj/item/ammo_box/magazine/fiveseven
	pin = /obj/item/device/firing_pin/implant/perseus
	force = 10
	var/emagged = 0

	update_icon()
		return

	examine()
		..()
		if(emagged)
			to_chat(usr, "\blue It's locking mechanism looks fried.")

	attackby(var/obj/item/I, var/mob/living/M)
		if(istype(I, /obj/item/card/emag) && !emagged)
			emagged = 1
			pin.emagged = 1
			to_chat(M, "<div class='notice'>You emag the [src].</div>")
			var/datum/effect_system/spark_spread/system = new()
			system.set_up(3, 0, get_turf(src))
			system.start()
		..()

/*
* Stun Knife
*/

/obj/item/stun_knife
	name = "Stun Knife"
	icon = 'icons/oldschool/perseus.dmi'
	lefthand_file = 'icons/oldschool/perseus_inhand_left.dmi'
	righthand_file = 'icons/oldschool/perseus_inhand_right.dmi'
	icon_state = "sknife"
	item_state = "sknife"

	force = 17
	throwforce = 2
	w_class = 2

	var/locked = /obj/item/implant/enforcer
	var/mode = 1 //0 = attack | 1 = stun
	var/obj/item/stock_parts/cell/power_supply

	update_icon()
		icon_state = "[initial(icon_state)][mode]"
		item_state = icon_state

	New()
		..()
		if(USE_SKNIFE_CHARGES)
			power_supply = new()
			if(SKNIFE_IS_AUTO_RECHARGING)
				SSobj.processing += src
		update_icon()

	examine()
		..()


	attack(var/mob/living/M, var/mob/living/user)
		if(locked)
			if(!user.check_contents_for(locked))
				var/datum/effect_system/spark_spread/S = new(get_turf(src))
				S.set_up(3, 0, get_turf(src))
				S.start()
				to_chat(user, "<div class='warning'>The [src] shocks you.</div>")
				user.Knockdown(40)
				return
		add_fingerprint(user)
		//user.do_attack_animation(M)
		switch(mode)
			if(1)
				if(issilicon(M))
					return
				M.SetStun(SKNIFE_STUNTIME * 20)
				M.SetKnockdown(SKNIFE_STUNTIME * 20)
				M.stuttering = SKNIFE_STUNTIME
				M.lastattacker = user
				var/turf/T = get_turf(M)
				T.visible_message("<span class='danger'> [M] has been stunned by [user] with \the [src]")
				add_logs(user, M, "stunned", object=src.name, addition=" (DAMAGE: [src.force]) (REMHP: [M.health - src.force]) (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])")
			if(0)
				M.apply_damage(force, BRUTE)
				M.lastattacker = user
				var/turf/T = get_turf(M)
				T.visible_message("<span class='danger'> [M] has been attacked by [user] with \the [src]")
				add_logs(user, M, "stabbed", object=src.name, addition=" (DAMAGE: [src.force]) (REMHP: [M.health - src.force]) (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])")

	attack_self(var/mob/user)
		..()
		mode = !mode
		to_chat(user, "<div class='notice'>The [src] is now set to [mode ? "stun" : "lethal"].</div>")
		force = mode == 0 ? 17 : 1
		update_icon()

	unlocked/
		locked = 0
