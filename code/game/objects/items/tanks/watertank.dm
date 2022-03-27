//Hydroponics tank and base code
/obj/item/watertank
	name = "backpack water tank"
	desc = "A S.U.N.S.H.I.N.E. brand watertank backpack with nozzle to water plants."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "waterbackpack"
	inhand_icon_state = "waterbackpack"
	lefthand_file = 'icons/mob/inhands/equipment/backpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/backpack_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	slowdown = 1
	actions_types = list(/datum/action/item_action/toggle_mister)
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 100, ACID = 30)
	resistance_flags = FIRE_PROOF

	var/obj/item/noz
	var/volume = 500

/obj/item/watertank/Initialize(mapload)
	. = ..()
	create_reagents(volume, OPENCONTAINER)
	noz = make_noz()
	RegisterSignal(noz, COMSIG_MOVABLE_MOVED, .proc/noz_move)

/obj/item/watertank/Destroy()
	QDEL_NULL(noz)
	return ..()


/obj/item/watertank/ui_action_click(mob/user)
	toggle_mister(user)

/obj/item/watertank/item_action_slot_check(slot, mob/user)
	if(slot == user.getBackSlot())
		return 1

/obj/item/watertank/proc/toggle_mister(mob/living/user)
	if(!istype(user))
		return
	if(user.get_item_by_slot(user.getBackSlot()) != src)
		to_chat(user, span_warning("The watertank must be worn properly to use!"))
		return
	if(user.incapacitated())
		return

	if(QDELETED(noz))
		noz = make_noz()
		RegisterSignal(noz, COMSIG_MOVABLE_MOVED, .proc/noz_move)
	if(noz in src)
		//Detach the nozzle into the user's hands
		if(!user.put_in_hands(noz))
			to_chat(user, span_warning("You need a free hand to hold the mister!"))
			return
	else
		//Remove from their hands and put back "into" the tank
		remove_noz()

/obj/item/watertank/verb/toggle_mister_verb()
	set name = "Toggle Mister"
	set category = "Object"
	toggle_mister(usr)

/obj/item/watertank/proc/make_noz()
	return new /obj/item/reagent_containers/spray/mister(src)

/obj/item/watertank/proc/noz_move(atom/movable/mover, atom/oldloc, direction)
	if(mover.loc == src || mover.loc == loc)
		return
	balloon_alert(loc, "nozzle snaps back")
	mover.forceMove(src)

/obj/item/watertank/equipped(mob/user, slot)
	..()
	if(slot != ITEM_SLOT_BACK)
		remove_noz()

/obj/item/watertank/proc/remove_noz()
	if(!QDELETED(noz))
		if(ismob(noz.loc))
			var/mob/M = noz.loc
			M.temporarilyRemoveItemFromInventory(noz, TRUE)
		noz.forceMove(src)

/obj/item/watertank/attack_hand(mob/user, list/modifiers)
	if (user.get_item_by_slot(user.getBackSlot()) == src)
		toggle_mister(user)
	else
		return ..()

/obj/item/watertank/MouseDrop(obj/over_object)
	var/mob/M = loc
	if(istype(M) && istype(over_object, /atom/movable/screen/inventory/hand))
		var/atom/movable/screen/inventory/hand/H = over_object
		M.putItemFromInventoryInHandIfPossible(src, H.held_index)
	return ..()

/obj/item/watertank/attackby(obj/item/attacking_item, mob/user, params)
	if(attacking_item == noz)
		remove_noz()
		return TRUE
	else
		return ..()

/obj/item/watertank/dropped(mob/user)
	..()
	remove_noz()

// This mister item is intended as an extension of the watertank and always attached to it.
// Therefore, it's designed to be "locked" to the player's hands or extended back onto
// the watertank backpack. Allowing it to be placed elsewhere or created without a parent
// watertank object will likely lead to weird behaviour or runtimes.
/obj/item/reagent_containers/spray/mister
	name = "water mister"
	desc = "A mister nozzle attached to a water tank."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "mister"
	inhand_icon_state = "mister"
	lefthand_file = 'icons/mob/inhands/equipment/mister_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mister_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = list(50)
	can_toggle_range = FALSE
	volume = 500
	item_flags = NOBLUDGEON | ABSTRACT  // don't put in storage
	slot_flags = NONE

	var/obj/item/watertank/tank

/obj/item/reagent_containers/spray/mister/Initialize(mapload)
	. = ..()
	tank = loc
	if(!tank?.reagents)
		return INITIALIZE_HINT_QDEL
	reagents = tank.reagents //This mister is really just a proxy for the tank's reagents

/obj/item/reagent_containers/spray/mister/afterattack(obj/target, mob/user, proximity)
	if(target.loc == loc) //Safety check so you don't fill your mister with mutagen or something and then blast yourself in the face with it
		return
	..()

//Janitor tank
/obj/item/watertank/janitor
	name = "backpack cleaner tank"
	desc = "A janitorial cleaner backpack with nozzle to clean blood and graffiti."
	icon_state = "waterbackpackjani"
	inhand_icon_state = "waterbackpackjani"
	custom_price = PAYCHECK_CREW * 5

/obj/item/watertank/janitor/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/space_cleaner, 500)

/obj/item/reagent_containers/spray/mister/janitor
	name = "janitor spray nozzle"
	desc = "A janitorial spray nozzle attached to a watertank, designed to clean up large messes."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "misterjani"
	inhand_icon_state = "misterjani"
	lefthand_file = 'icons/mob/inhands/equipment/mister_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mister_righthand.dmi'
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5, 10)
	current_range = 5

/obj/item/watertank/janitor/make_noz()
	return new /obj/item/reagent_containers/spray/mister/janitor(src)

/obj/item/reagent_containers/spray/mister/janitor/mode_change_message(mob/user)
	to_chat(user, span_notice("You [amount_per_transfer_from_this == 10 ? "remove" : "affix"] the nozzle. You'll now use [amount_per_transfer_from_this] units per spray."))

//Security tank
/obj/item/watertank/pepperspray
	name = "ANTI-TIDER-2500 suppression backpack"
	desc = "The ultimate crowd-control device; this tool allows the user to quickly and efficiently pacify groups of hostile targets."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "pepperbackpacksec"
	inhand_icon_state = "pepperbackpacksec"
	custom_price = PAYCHECK_CREW * 2
	volume = 1000

/obj/item/watertank/pepperspray/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/consumable/condensedcapsaicin, 1000)

/obj/item/reagent_containers/spray/mister/pepperspray
	name = "security spray nozzle"
	desc = "A pacifying spray nozzle attached to a pepperspray tank, designed to silence perps."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "mistersec"
	inhand_icon_state = "mistersec"
	lefthand_file = 'icons/mob/inhands/equipment/mister_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mister_righthand.dmi'
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5, 10)
	current_range = 6

/obj/item/watertank/pepperspray/make_noz()
	return new /obj/item/reagent_containers/spray/mister/pepperspray(src)

/obj/item/reagent_containers/spray/mister/pepperspray/mode_change_message(mob/user)
	to_chat(user, span_notice("You [amount_per_transfer_from_this == 10 ? "remove" : "affix"] the nozzle. You'll now use [amount_per_transfer_from_this] units per spray."))

//ATMOS FIRE FIGHTING BACKPACK

#define EXTINGUISHER 0
#define RESIN_LAUNCHER 1
#define RESIN_FOAM 2

/obj/item/watertank/atmos
	name = "backpack firefighter tank"
	desc = "A refrigerated and pressurized backpack tank with extinguisher nozzle, intended to fight fires. Swaps between extinguisher, resin launcher and a smaller scale resin foamer."
	inhand_icon_state = "waterbackpackatmos"
	icon_state = "waterbackpackatmos"
	worn_icon_state = "waterbackpackatmos"
	volume = 200
	slowdown = 0

/obj/item/watertank/atmos/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/water, 200)

/obj/item/watertank/atmos/make_noz()
	return new /obj/item/extinguisher/mini/nozzle(src)

/obj/item/watertank/atmos/dropped(mob/user)
	..()
	icon_state = "waterbackpackatmos"
	if(istype(noz, /obj/item/extinguisher/mini/nozzle))
		var/obj/item/extinguisher/mini/nozzle/N = noz
		N.nozzle_mode = 0

/obj/item/extinguisher/mini/nozzle
	name = "extinguisher nozzle"
	desc = "A heavy duty nozzle attached to a firefighter's backpack tank."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "atmos_nozzle"
	inhand_icon_state = "nozzleatmos"
	lefthand_file = 'icons/mob/inhands/equipment/mister_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mister_righthand.dmi'
	safety = 0
	max_water = 200
	power = 8
	force = 10
	precision = 1
	cooling_power = 5
	w_class = WEIGHT_CLASS_HUGE
	item_flags = ABSTRACT  // don't put in storage
	chem = null //holds no chems of its own, it takes from the tank.
	var/obj/item/tank
	var/nozzle_mode = 0
	var/metal_synthesis_cooldown = 0
	COOLDOWN_DECLARE(resin_cooldown)

/obj/item/extinguisher/mini/nozzle/Initialize(mapload)
	. = ..()
	tank = loc
	if (!tank?.reagents)
		return INITIALIZE_HINT_QDEL
	reagents = tank.reagents
	max_water = tank.reagents.maximum_volume


/obj/item/extinguisher/mini/nozzle/Destroy()
	reagents = null //This is a borrowed reference from the tank.
	tank = null
	return ..()

/obj/item/extinguisher/mini/nozzle/attack_self(mob/user)
	var/uses_pack = istype(tank, /obj/item/watertank/atmos)
	switch(nozzle_mode)
		if(EXTINGUISHER)
			nozzle_mode = RESIN_LAUNCHER
			if(uses_pack)
				tank.icon_state = "waterbackpackatmos_1"
			balloon_alert(user, "switched to resin launcher")
			return
		if(RESIN_LAUNCHER)
			nozzle_mode = RESIN_FOAM
			if(uses_pack)
				tank.icon_state = "waterbackpackatmos_2"
			balloon_alert(user, "switched to resin foam")
			return
		if(RESIN_FOAM)
			nozzle_mode = EXTINGUISHER
			if(uses_pack)
				tank.icon_state = "waterbackpackatmos_0"
			balloon_alert(user, "switched to fire extinguisher")
			return
	return

/obj/item/extinguisher/mini/nozzle/afterattack(atom/target, mob/user)
	if(AttemptRefill(target, user))
		return
	if(nozzle_mode == EXTINGUISHER)
		..()
		return
	var/Adj = user.Adjacent(target)
	if(nozzle_mode == RESIN_LAUNCHER)
		if(Adj)
			return //Safety check so you don't blast yourself trying to refill your tank
		var/datum/reagents/R = reagents
		if(R.total_volume < 100)
			balloon_alert(user, "not enough water!")
			return
		if(!COOLDOWN_FINISHED(src, resin_cooldown))
			balloon_alert(user, "still recharging!")
			return
		COOLDOWN_START(src, resin_cooldown, 10 SECONDS)
		R.remove_any(100)
		var/obj/effect/resin_container/resin = new (get_turf(src))
		log_game("[key_name(user)] used Resin Launcher at [AREACOORD(user)].")
		playsound(src,'sound/items/syringeproj.ogg',40,TRUE)
		var/delay = 2
		var/datum/move_loop/loop = SSmove_manager.move_towards(resin, target, delay, timeout = delay * 5, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
		RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, .proc/resin_stop_check)
		RegisterSignal(loop, COMSIG_PARENT_QDELETING, .proc/resin_landed)
		return

	if(nozzle_mode == RESIN_FOAM)
		if(!Adj|| !isturf(target))
			balloon_alert(user, "too far!")
			return
		for(var/S in target)
			if(istype(S, /obj/effect/particle_effect/foam/metal/resin) || istype(S, /obj/structure/foamedmetal/resin))
				balloon_alert(user, "already has resin!")
				return
		if(metal_synthesis_cooldown < 5)
			var/obj/effect/particle_effect/foam/metal/resin/F = new (get_turf(target))
			F.amount = 0
			metal_synthesis_cooldown++
			addtimer(CALLBACK(src, .proc/reduce_metal_synth_cooldown), 10 SECONDS)
		else
			balloon_alert(user, "still being synthesized!")
			return

/obj/item/extinguisher/mini/nozzle/proc/resin_stop_check(datum/move_loop/source, succeeded)
	SIGNAL_HANDLER
	if(succeeded)
		return
	resin_landed(source)
	qdel(source)

/obj/item/extinguisher/mini/nozzle/proc/resin_landed(datum/move_loop/source)
	SIGNAL_HANDLER
	if(!istype(source.moving, /obj/effect/resin_container) || QDELETED(source.moving))
		return
	var/obj/effect/resin_container/resin = source.moving
	resin.Smoke()

/obj/item/extinguisher/mini/nozzle/proc/reduce_metal_synth_cooldown()
	metal_synthesis_cooldown--

/obj/effect/resin_container
	name = "resin container"
	desc = "A compacted ball of expansive resin, used to repair the atmosphere in a room, or seal off breaches."
	icon = 'icons/effects/effects.dmi'
	icon_state = "frozen_smoke_capsule"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pass_flags = PASSTABLE
	anchored = TRUE

/obj/effect/resin_container/proc/Smoke()
	var/obj/effect/particle_effect/foam/metal/resin/S = new /obj/effect/particle_effect/foam/metal/resin(get_turf(loc))
	S.amount = 4
	playsound(src,'sound/effects/bamf.ogg',100,TRUE)
	qdel(src)

/obj/effect/resin_container/newtonian_move(direction, instant = FALSE) // Please don't spacedrift thanks
	return TRUE

#undef EXTINGUISHER
#undef RESIN_LAUNCHER
#undef RESIN_FOAM

/obj/item/reagent_containers/chemtank
	name = "backpack chemical injector"
	desc = "A chemical autoinjector that can be carried on your back."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "waterbackpackchem"
	inhand_icon_state = "waterbackpackchem"
	lefthand_file = 'icons/mob/inhands/equipment/backpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/backpack_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	slowdown = 1
	actions_types = list(/datum/action/item_action/activate_injector)

	var/on = FALSE
	volume = 300
	var/usage_ratio = 5 //5 unit added per 1 removed
	/// How much to inject per second
	var/injection_amount = 0.5
	amount_per_transfer_from_this = 5
	reagent_flags = OPENCONTAINER
	spillable = FALSE
	possible_transfer_amounts = list(5,10,15)
	fill_icon_thresholds = list(0, 15, 60)
	fill_icon_state = "backpack"

/obj/item/reagent_containers/chemtank/ui_action_click()
	toggle_injection()

/obj/item/reagent_containers/chemtank/item_action_slot_check(slot, mob/user)
	if(slot == ITEM_SLOT_BACK)
		return 1

/obj/item/reagent_containers/chemtank/proc/toggle_injection()
	var/mob/living/carbon/human/user = usr
	if(!istype(user))
		return
	if (user.get_item_by_slot(ITEM_SLOT_BACK) != src)
		to_chat(user, span_warning("The chemtank needs to be on your back before you can activate it!"))
		return
	if(on)
		turn_off()
	else
		turn_on()

//Todo : cache these.
/obj/item/reagent_containers/chemtank/worn_overlays(mutable_appearance/standing, isinhands = FALSE) //apply chemcolor and level
	. = ..()
	//inhands + reagent_filling
	if(isinhands || !reagents.total_volume)
		return

	var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "backpackmob-10")
	var/percent = round((reagents.total_volume / volume) * 100)
	switch(percent)
		if(0 to 15)
			filling.icon_state = "backpackmob-10"
		if(16 to 60)
			filling.icon_state = "backpackmob50"
		if(61 to INFINITY)
			filling.icon_state = "backpackmob100"

	filling.color = mix_color_from_reagents(reagents.reagent_list)
	. += filling

/obj/item/reagent_containers/chemtank/proc/turn_on()
	on = TRUE
	START_PROCESSING(SSobj, src)
	if(ismob(loc))
		to_chat(loc, span_notice("[src] turns on."))

/obj/item/reagent_containers/chemtank/proc/turn_off()
	on = FALSE
	STOP_PROCESSING(SSobj, src)
	if(ismob(loc))
		to_chat(loc, span_notice("[src] turns off."))

/obj/item/reagent_containers/chemtank/process(delta_time)
	if(!ishuman(loc))
		turn_off()
		return
	if(!reagents.total_volume)
		turn_off()
		return
	var/mob/living/carbon/human/user = loc
	if(user.back != src)
		turn_off()
		return

	var/inj_am = injection_amount * delta_time
	var/used_amount = inj_am / usage_ratio
	reagents.trans_to(user, used_amount, multiplier=usage_ratio, methods = INJECT)
	update_appearance()
	user.update_inv_back() //for overlays update
