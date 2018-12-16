var/const/EP_STUNTIME_SINGLE = 1 * 20
var/const/EP_STUNTIME_AOE = 1 * 20

var/const/IS_EP_SINGLE_STACKING = 1 * 20
var/const/IS_EP_AOE_STACKING = 1 * 20

var/const/EP_MAX_SINGLE_STACK = 7 * 20
var/const/EP_MAX_AOE_STACK = 7 * 20

/*
	EP90
*/

/obj/item/gun/energy/ep90
	name = "Energy Project-90"
	desc = "An ancient model, reworked to fire light energy pulses."
	icon = 'icons/oldschool/perseus.dmi'
	lefthand_file = 'icons/oldschool/perseus_inhand_left.dmi'
	righthand_file = 'icons/oldschool/perseus_inhand_right.dmi'
	icon_state = "ep90"
	w_class = 3.0
	item_state = "ep"
	cell_type = /obj/item/stock_parts/cell/magazine/ep90
	ammo_type = list(/obj/item/ammo_casing/energy/ep90_single, /obj/item/ammo_casing/energy/ep90_aoe, /obj/item/ammo_casing/energy/ep90_burst_3, /obj/item/ammo_casing/energy/ep90_burst_5)
	fire_sound = 'sound/toolbox/ep90.ogg'
	pin = /obj/item/device/firing_pin/implant/perseus
	//selfcharge = 0 //nerfing self charge. You can use your extra power cells, thats what theyre for. -falaskian
	//charge_delay = 2
	var/emagged = 0
	var/panel = 0

	attack_self(var/mob/living/user as mob)
		if(firing_burst)
			return
		select_fire(user)
		var/obj/item/ammo_casing/selected = ammo_type[select]
		if (istype(selected))
			burst_size = selected.burst
			fire_delay = selected.burst_delay

	update_icon()
		if(cell)
			icon_state = "[initial(icon_state)]_mag[round(cell.percent(), 25)][cell.training ? "_training" : ""]"
		else
			icon_state = "ep90"

	/*
	* Inserting and removing the cell (magazine)
	*/

	attack_hand(var/mob/living/M)
		if(cell && (M.held_items[1] == src || M.held_items[2] == src))
			cell.loc = get_turf(src)
			to_chat(M, "<div class='notice'>You remove the [cell] from the [src].</div>")
			var/obj/item/I = cell
			cell.update_icon()
			cell = 0
			update_icon()
			if(!M.equip_to_slot_if_possible(I, slot_hands))	return
			return
		. = ..()

	attackby(var/obj/item/I, var/mob/living/M)
		if(istype(I, /obj/item/stock_parts/cell/magazine/ep90))
			if(cell)
				to_chat(M, "<div class='warning'>There is already a power supply installed.</div>")
				return
			M.dropItemToGround(I)
			I.loc = src
			cell = I

			if (cell && cell.training)
				ammo_type = list(/obj/item/ammo_casing/energy/ep90_single/training, /obj/item/ammo_casing/energy/ep90_aoe/training, /obj/item/ammo_casing/energy/ep90_burst_3/training, /obj/item/ammo_casing/energy/ep90_burst_5/training)
			else if (cell && !cell.training)
				ammo_type = list(/obj/item/ammo_casing/energy/ep90_single, /obj/item/ammo_casing/energy/ep90_aoe, /obj/item/ammo_casing/energy/ep90_burst_3, /obj/item/ammo_casing/energy/ep90_burst_5)

			for (var/ammo_t2 in ammo_type)
				ammo_type += new ammo_t2(src)
				ammo_type -= ammo_t2

			chambered = ammo_type[select]
			to_chat(M, "<div class='notice'>You insert the [I] into the [src].</div>")
			update_icon()
		if(istype(I, /obj/item/screwdriver))
			panel = !panel
			to_chat(M, "<div class='danger'>You [panel ? "open" : "close"] the maintenance panel.</div>")
			playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
		if(istype(I, /obj/item/weldingtool) && emagged && panel && istype(pin,/obj/item/device/firing_pin/implant/perseus))
			var/obj/item/weldingtool/WT = I
			if(!WT.use(0))
				return
			playsound(loc, 'sound/items/Welder2.ogg', 40, 1)
			to_chat(M, "<div class='danger'>You repair the [src].</div>")
			emagged = 0
			var/obj/item/device/firing_pin/implant/perseus/ppin = pin
			ppin.emagged = 1
			selfcharge = 1
			for (var/obj/item/ammo_casing/E in ammo_type)
				if (E.BB)
					E.BB.emagged = 0
			var/datum/effect_system/spark_spread/system = new()
			system.set_up(3, 0, get_turf(src))
			system.start()
		. = ..()

	emag_act(mob/living/user)
		if(!emagged && istype(pin,/obj/item/device/firing_pin/implant/perseus))
			var/obj/item/device/firing_pin/implant/perseus/ppin = pin
			ppin.emagged = 1
			emagged = 1
			//selfcharge = 0 //commenting this because we nerfed ep90 self charge -falaskian
			for (var/obj/item/ammo_casing/E in ammo_type)
				if (E.BB)
					E.BB.emagged = 1
			to_chat(user, "<div class='notice'>You emag the [src].</div>")
			var/datum/effect_system/spark_spread/system = new()
			system.set_up(3, 0, get_turf(src))
			system.start()
		return

	examine()
		..()
		if(emagged)
			to_chat(usr, "\blue It's locking mechanism looks fried.")

/obj/item/gun/energy/ep90/can_trigger_gun(var/mob/living/user)
	if (panel)
		if (user)
			to_chat(user, "The panel of the [src] is open.")
		return 0
	else
		return ..()

/*
	EP90 Cell
*/

/obj/item/stock_parts/cell
	var/list/ammo_type_override = list()
	var/training = 0

/obj/item/stock_parts/cell/magazine
	name = "energy magazine"
	icon = 'icons/obj/ammo.dmi'
	item_state = "ammomagazine"
	w_class = 2

	update_icon()
		overlays.Cut()
		overlays += icon('icons/obj/ammo.dmi', icon_state = "[initial(icon_state)]mag[round(charge/maxcharge, 0.2)*100]")

	New()
		..()
		spawn(5)
			update_icon()

/obj/item/stock_parts/cell/magazine/ep90
	name = "ep90 energy magazine"
	icon_state = "ep90mag"
	icon = 'icons/oldschool/perseus.dmi'
	maxcharge = 1000

	update_icon()
		cut_overlays()
		add_overlay(icon('icons/oldschool/perseus.dmi', "ep90mag[round(charge/maxcharge, 0.2)*100][training ? "_training" : ""]"))
		icon_state = "[initial(icon_state)][training ? "_training" : ""]"


/obj/item/stock_parts/cell/magazine/ep90/attack_self(mob/user)
	training = !training
	update_icon()
	to_chat(user, "You switch the [src] to [training ? "training" : "combat"] mode.")

/*
* Projectiles
*/

/obj/item/projectile/
	var/emagged = 0

/obj/item/projectile/energy/ep90_single
	name = "energy"
	icon_state = "ep90shot"
	icon = 'icons/oldschool/perseus.dmi'
	hitsound = 'sound/weapons/taserhit.ogg'
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	stun = EP_STUNTIME_SINGLE
	knockdown = EP_STUNTIME_SINGLE
	stutter = EP_STUNTIME_SINGLE

	damage = 1
	damage_type = BURN
	flag = "energy"
	luminosity = 1

	on_hit(var/atom/target, var/blocked = 0)
		if(!isliving(target))	return 0
		if(isanimal(target))	return 0
		var/mob/living/L = target

		if(blocked >= 2)
			var/datum/effect_system/spark_spread/sparks = new
			sparks.set_up(1, 1, src)
			sparks.start()

		if(IS_EP_SINGLE_STACKING && !emagged && !check_perseus(L))
			if(blocked >= 100)	return 0
			if(issilicon(L))	return 0

			var/max = EP_MAX_SINGLE_STACK ? EP_MAX_SINGLE_STACK : INFINITY

			if((L.AmountStun() + stun) > max)	L.SetStun(max)
			else							L.AdjustStun(stun)

			if((L.AmountKnockdown() + knockdown) > max)	L.SetKnockdown(max)
			else							L.AdjustKnockdown(knockdown)

			if((L.stuttering + stutter) > max)	L.stuttering = max
			else								L.stuttering += stutter

			L.updatehealth()
			L.update_canmove()

		else if (check_perseus(L) && !emagged)
			if(blocked >= 100) return 0
			L.apply_effects(stun, knockdown, 0, 0, stutter)
		else if (emagged)
			L.apply_effects(3, 3, 0, 0, 3)

/*/obj/item/projectile
	var/bump_at_tile = 0*/

/obj/item/projectile/energy/ep90_aoe
	name = "energy"
	icon_state = "ep90shot"
	icon = 'icons/oldschool/perseus.dmi'
	hitsound = 'sound/weapons/taserhit.ogg'
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE

	stun = EP_STUNTIME_AOE
	knockdown = EP_STUNTIME_AOE
	stutter = EP_STUNTIME_AOE

	damage = 1
	damage_type = BURN
	flag = "energy"

	//bump_at_tile = 1
	luminosity = 1
	var/maxrange = 0

	on_hit(var/atom/target, var/blocked = 0)
		for(var/turf/T in range(1, target))
			new /obj/effect/particle_effect/sparks(get_turf(T))
			for(var/mob/living/M in T)
				if(IS_EP_AOE_STACKING && !emagged && !check_perseus(M))
					if((M.AmountKnockdown() + knockdown) > EP_MAX_AOE_STACK)
						M.SetKnockdown(EP_MAX_AOE_STACK)
					else
						M.AdjustKnockdown(knockdown)
					M.updatehealth()
					continue
				else if (check_perseus(M) && !emagged)
					M.SetKnockdown(EP_STUNTIME_AOE)
				else if (emagged)
					M.SetKnockdown(60)

	Range()
		if(!maxrange && firer && original)
			maxrange = get_dist(get_turf(firer),get_turf(original))+1
		if(isturf(original) && loc == original)
			Collide(loc)
		else
			maxrange = max(maxrange-1,0)
			if(maxrange <= 0)
				Collide(loc)
		return ..()

/*
	Ammo casings
*/
/obj/item/ammo_casing/
	var/burst = 0
	var/burst_delay = 0

/obj/item/ammo_casing/energy/ep90_single
	select_name = "semi-automatic fire"
	projectile_type = /obj/item/projectile/energy/ep90_single
	e_cost = 20
	fire_sound = 'sound/toolbox/ep90.ogg'

/obj/item/ammo_casing/energy/ep90_single/newshot(var/emagged = 0)
	if(!BB && projectile_type)
		BB = new projectile_type(src)
		BB.emagged = emagged

/obj/item/ammo_casing/energy/ep90_aoe
	select_name = "area-of-effect fire"
	projectile_type = /obj/item/projectile/energy/ep90_aoe
	e_cost = 100
	fire_sound = 'sound/toolbox/ep90.ogg'

/obj/item/ammo_casing/energy/ep90_aoe/newshot(var/emagged = 0)
	if(!BB && projectile_type)
		BB = new projectile_type(src)
		BB.emagged = emagged


/obj/item/ammo_casing/energy/ep90_burst_3
	select_name = "3-round-burst"
	projectile_type = /obj/item/projectile/energy/ep90_single
	e_cost = 20
	fire_sound = 'sound/toolbox/ep90.ogg'
	burst = 3
	burst_delay = 1.6

/obj/item/ammo_casing/energy/ep90_burst_3/newshot(var/emagged = 0)
	if(!BB && projectile_type)
		BB = new projectile_type(src)
		BB.emagged = emagged


/obj/item/ammo_casing/energy/ep90_burst_5
	select_name = "5-round-burst"
	projectile_type = /obj/item/projectile/energy/ep90_single
	e_cost = 20
	fire_sound = 'sound/toolbox/ep90.ogg'
	burst = 5
	burst_delay = 2.7

/obj/item/ammo_casing/energy/ep90_burst_5/newshot(var/emagged = 0)
	if(!BB && projectile_type)
		BB = new projectile_type(src)
		BB.emagged = emagged

/*
 *	Training Stuff
 */
/obj/item/projectile/energy/ep90_single/training
	icon_state = "ep90shot_training"

/obj/item/projectile/energy/ep90_single/training/on_hit(var/atom/target, var/blocked = 0)

	if(!isliving(target))	return 0
	if(isanimal(target))	return 0
	var/mob/living/L = target
	if(blocked >= 2)
		var/datum/effect_system/spark_spread/sparks = new
		sparks.set_up(1, 1, src)
		sparks.start()
	if(IS_EP_SINGLE_STACKING && check_perseus(L))
		if(blocked >= 100)	return 0
		if(issilicon(L))	return 0

		var/max = EP_MAX_SINGLE_STACK ? EP_MAX_SINGLE_STACK : INFINITY

		if((L.AmountStun() + stun) > max)	L.SetStun(max)
		else							L.AdjustStun(stun)

		if((L.AmountKnockdown() + knockdown) > max)	L.SetKnockdown(max)
		else							L.AdjustKnockdown(knockdown)

		if((L.stuttering + stutter) > max)	L.stuttering = max
		else								L.stuttering += stutter

		L.updatehealth()
		L.update_canmove()

	else if (check_perseus(L) && !emagged)
		if(blocked >= 100) return 0
		L.apply_effects(stun, knockdown, 0, 0, stutter)
	else if (emagged)
		L.apply_effects(3, 3, 0, 0, 3)

/obj/item/ammo_casing/energy/ep90_single/training
	projectile_type = /obj/item/projectile/energy/ep90_single/training

/obj/item/ammo_casing/energy/ep90_aoe/training
	projectile_type = /obj/item/projectile/energy/ep90_aoe/training

/obj/item/ammo_casing/energy/ep90_burst_3/training
	projectile_type = /obj/item/projectile/energy/ep90_single/training

/obj/item/ammo_casing/energy/ep90_burst_5/training
	projectile_type = /obj/item/projectile/energy/ep90_single/training

/obj/item/projectile/energy/ep90_aoe/training
	icon_state = "ep90shot_training"

/obj/item/projectile/energy/ep90_aoe/training
	on_hit(var/atom/target, var/blocked = 0)
		for(var/turf/T in range(1, target))
			new /obj/effect/particle_effect/sparks(get_turf(T))
			for(var/mob/living/M in T)
				if(IS_EP_AOE_STACKING && check_perseus(M))
					if((M.AmountKnockdown() + knockdown) > EP_MAX_AOE_STACK)
						M.SetKnockdown(EP_MAX_AOE_STACK)
					else
						M.AdjustKnockdown(knockdown)
					M.updatehealth()
					continue
				else if (check_perseus(M) && !emagged)
					M.SetKnockdown(EP_STUNTIME_AOE)
				else if (emagged)
					M.SetKnockdown(60)
