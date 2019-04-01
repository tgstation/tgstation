/*
* All weapon related code goes here.
*/


/*
* Five Seven
*/

/obj/item/projectile/bullet/fiveseven
	damage = 24

/obj/item/ammo_casing/fiveseven
	desc = "A 5.7x28mm casing"
	caliber = "5.7x28mm"
	projectile_type = /obj/item/projectile/bullet/fiveseven


/obj/item/ammo_box/magazine/fiveseven
	name = "5.7x28mm magazine"
	icon_state = "45"
	icon = 'icons/oldschool/perseus.dmi'
	//origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/fiveseven
	caliber = "5.7x28mm"
	max_ammo = 20
	multiple_sprites = 0

// PIN

/obj/item/device/firing_pin/implant/perseus
	cant_be_craft_removed = 1
	var/required = /datum/extra_role/perseus
	var/emagged = 0

/obj/item/device/firing_pin/implant/perseus/pin_auth(mob/living/user)
	if(emagged)
		return 1
	if(check_perseus(user))
		return 1
	return 0

/obj/item/device/firing_pin/implant/perseus/emag_act(mob/living/user)
	return

/obj/item/device/firing_pin/implant/perseus/auth_fail(mob/living/user)
	var/datum/effect_system/spark_spread/S = new(get_turf(src))
	S.set_up(3, 0, get_turf(src))
	S.start()
	to_chat(user, "<div class='warning'>The [src] shocks you.</div>")
	user.AdjustKnockdown(40)

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
		if(istype(I, /obj/item/card/emag) && !emagged  && istype(pin,/obj/item/device/firing_pin/implant/perseus))
			emagged = 1
			var/obj/item/device/firing_pin/implant/perseus/ppin = pin
			ppin.emagged = 1
			to_chat(M, "<div class='notice'>You emag the [src].</div>")
			var/datum/effect_system/spark_spread/system = new()
			system.set_up(3, 0, get_turf(src))
			system.start()
		..()

/*
* Stun Knife
*/

/*
* Variables
*/

#define SKNIFE_RECHARGES 1 //set to 1 if you want the stun knife to require charge and to automatically recharge.

/obj/item/stun_knife
	name = "Stun Knife"
	icon = 'icons/oldschool/perseus.dmi'
	lefthand_file = 'icons/oldschool/perseus_inhand_left.dmi'
	righthand_file = 'icons/oldschool/perseus_inhand_right.dmi'
	icon_state = "sknife"
	item_state = "sknife"
	force = 0 //We start in stun move, force 0.
	w_class = 2
	hitsound = 'sound/weapons/bladeslice.ogg'
	flags_1 = CONDUCT_1
	throw_speed = 3
	throw_range = 6
	throwforce = 2
	materials = list(MAT_METAL=12000)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)

	var/locked = 1 //Will it shock you if you are not perseus.
	var/mode = 1 //0 = attack | 1 = stun

	//power supply
	var/obj/item/stock_parts/cell/power_supply
	var/charge_cost = 125
	var/charge_interval = 50 //time between charge ticks
	var/charge_per_tick = 200
	var/last_recharge = 0 //the world.time of last recharge

	//offense
	var/lethalforce = 17 //Force changes to this when lethal mode is on.
	var/lethalsharpness = IS_SHARP_ACCURATE
	var/stun_time = 4
	var/max_stacked_stun = 12 //User must stun multiple times to get max stun
	var/last_stun = 0 //the world.time of the last time a stun happened, this is used to delay recharging.
	var/last_stun_delay = 80 //how long from the last stun does the knife start recharging again.
	var/list/lethal_attack_verbs = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

	//knife is now emaggable
	var/emagged = 0

	process()
		if((last_recharge+charge_interval <= world.time) && (last_stun+last_stun_delay <= world.time))
			last_recharge = world.time
			if(power_supply)
				power_supply.give(charge_per_tick)

	update_icon()
		icon_state = "[initial(icon_state)][mode]"
		item_state = icon_state

	Initialize()
		..()
		if(SKNIFE_RECHARGES)
			power_supply = new()
			power_supply.give(power_supply.maxcharge)
			SSobj.processing += src
		update_icon()

	examine()
		..()
		if(power_supply && SKNIFE_RECHARGES)
			var/remaining = power_supply.charge
			if(power_supply.charge < charge_cost)
				remaining = 0
			to_chat(usr,"<font color='blue'>Energy level is at [round(remaining/power_supply.maxcharge*100,1)]%.</font>")
		if(emagged)
			to_chat(usr,"<font color='red'>It looks damaged.</font>")

	attack(var/mob/living/M, var/mob/living/user)
		if(locked && !emagged)
			if(!check_perseus(user))
				. = 1
				var/datum/effect_system/spark_spread/S = new(get_turf(src))
				S.set_up(3, 0, get_turf(src))
				S.start()
				to_chat(user, "<div class='warning'>The [src] shocks you.</div>")
				user.AdjustKnockdown(40)
				return
		if(mode)
			if(!issilicon(M))
				var/do_stun = 1
				if(SKNIFE_RECHARGES && !power_supply.use(charge_cost))
					do_stun = 0
					to_chat(user,"<div class='warning'>The [src] is out of charge!</div>")
				if(do_stun)
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						if(H.check_shields(src, 0, "[user]'s [name]", MELEE_ATTACK)) //No message; check_shields() handles that
							playsound(H, 'sound/weapons/genhit.ogg', 50, 1)
							return
					do_stun(M,user)
			else
				. = 1
		..()

	proc/do_stun(mob/living/M, mob/living/user)
		last_stun = world.time
		var/theknockdown = M.AmountKnockdown()
		if(theknockdown <= 0)
			M.SetKnockdown(stun_time*10)
		else
			M.SetKnockdown(min(theknockdown+(stun_time*10),max_stacked_stun*10))
		var/turf/T = get_turf(M)
		playsound(get_turf(src), "sparks", 100, 1)
		T.visible_message("<span class='danger'> [M] has been stunned by [user] with \the [src]")
		add_logs(user, M, "stunned", object=src.name, addition=" (DAMAGE: [src.force]) (REMHP: [M.health - src.force]) (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])")

	attack_self(var/mob/user)
		..()
		mode = !mode
		to_chat(user, "<div class='notice'>The [src] is now set to [mode ? "stun" : "lethal"].</div>")
		force = mode == 0 ? lethalforce : initial(force)
		sharpness = mode == 0 ? lethalsharpness : initial(sharpness)
		throwforce = mode == 0 ? round(lethalforce*0.7,1) : initial(throwforce)
		attack_verb = mode == 0 ? lethal_attack_verbs : initial(attack_verb)
		update_icon()

	emag_act(mob/living/user)
		if(!emagged)
			emagged = 1
			to_chat(user, "<div class='notice'>You emag the [src].</div>")
			var/datum/effect_system/spark_spread/system = new()
			system.set_up(3, 0, get_turf(src))
			system.start()

	get_cell()
		return power_supply

	unlocked/
		locked = 0

/*
* perseus medbeam gun with implant lock
*/

/obj/item/gun/medbeam/perseus
	name = "Perseus Enforcer's Medical Beamgun"
	pin = /obj/item/device/firing_pin/implant/perseus

/obj/item/gun/medbeam/perseus/emag_act(mob/living/user)
	var/obj/item/device/firing_pin/implant/perseus/ppin = pin
	if(istype(ppin) && !ppin.emagged)
		ppin.emagged = 1
		to_chat(user, "<div class='notice'>You emag the [src].</div>")
		var/datum/effect_system/spark_spread/system = new()
		system.set_up(3, 0, get_turf(src))
		system.start()
