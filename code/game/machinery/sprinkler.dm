/obj/machinery/sprinkler
	name = "sprinkler"
	desc = "An automated sprinkler capable of detecting fire and spraying coolant."
	icon = 'icons/obj/device.dmi'
	icon_state = "sprinkler0"
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	plane = FLOOR_PLANE
	max_integrity = 100
	armor = list("melee" = 20, "bullet" = 10, "laser" = 10, "energy" = 20, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 30)
	req_access = list(ACCESS_ENGINE)
	var/refill_loaded = FALSE
	var/cooldown = 0
	var/working = FALSE

/obj/machinery/sprinkler/examine(mob/user)
	. = ..()
	if(!refill_loaded)
		. += "<span class='notice'>It needs to be refilled.</span>"
	if(obj_flags&EMAGGED)
		. += "<span class='danger'>There is a purple LED blinking, what could it mean?</span>"

/obj/machinery/sprinkler/Initialize()
	. = ..()
	create_reagents(50)

/obj/machinery/sprinkler/interact(mob/user)
	if(!allowed(user))
		to_chat(user, "<span class='danger'>Access denied.</span>")
		return
	dispense()
	log_game("[user] has manually actived the sprinkler in [AREACOORD(src)]")

/obj/machinery/sprinkler/emag_act(mob/user)
	. = ..()
	if(obj_flags&EMAGGED)
		return
	playsound(src, "sparks", 75, 1)
	obj_flags|=EMAGGED
	reagents.remove_all(50)
	reagents.add_reagent(pick(/datum/reagent/clf3,
							  /datum/reagent/drug/space_drugs,
							  /datum/reagent/lube,
							  /datum/reagent/hellwater,
							  /datum/reagent/toxin/acid/fluacid,
							  /datum/reagent/napalm,
							  /datum/reagent/oxygen,
							  /datum/reagent/toxin/plasma,
							  /datum/reagent/carbondioxide,
							  /datum/reagent/consumable/ethanol/tequila),50)
	to_chat(user, "<span class='danger'>The war crime LED blinks twice.</span>")
	message_admins("[user] has emagged a fire sprinkler in [AREACOORD(src)].")
	log_game("[user] has emagged a fire sprinkler in [AREACOORD(src)].")
	refill_loaded = TRUE
	playsound(loc, 'sound/machines/beep.ogg', 100, 1)
	update_icon()

/obj/machinery/sprinkler/fire_act()
	. = ..()
	dispense()

/obj/machinery/sprinkler/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(I.tool_behaviour == TOOL_CROWBAR)
		if(!allowed(user))
			to_chat(user, "<span class='danger'>Access denied.</span>")
			return
		if(!working)
			to_chat(user, "You start uprooting \the [src]...")
			working = TRUE
			if(do_after(user, 70, target = src) && working)
				to_chat(user, "You have successfully detached \the [src].")
				new /obj/item/deployable_sprinkler (get_turf(src))
				qdel(src)
				return
			else
				working = FALSE
	else if(I.tool_behaviour == TOOL_WRENCH)
		if(!allowed(user))
			to_chat(user, "<span class='danger'>Access denied.</span>")
			return
		if(!refill_loaded)
			to_chat(user, "The sprinkler is empty.")
			return
		if(!working)
			to_chat(user, "You start opening the emergency cap...")
			working = TRUE
			if(do_after(user, 50, target = src) && working)
				to_chat(user, "You have successfully emptied \the [src].")
				reagents.reaction(user, TOUCH)
				reagents.remove_all(50)
				playsound(loc, 'sound/effects/extinguish.ogg', 75, 1, -3)
				obj_flags &= ~EMAGGED
				update_icon()
				return
			else
				working = FALSE
	else
		return ..()

/obj/machinery/sprinkler/proc/dispense()
	if(cooldown < world.time && refill_loaded)
		var/datum/effect_system/smoke_spread/chem/smoke_machine/smoke = new()
		smoke.set_up(reagents, 5, 8,  get_turf(src))
		smoke.start()
		cooldown = world.time + 200
		if(!reagents.total_volume)
			refill_loaded = FALSE
			update_icon()

/obj/machinery/sprinkler/update_icon()
	. = ..()
	if(refill_loaded)
		icon_state = "sprinkler1"
		return
	icon_state = "sprinkler0"

/obj/item/sprinkler_refill
	name = "sprinkler refill (water)"
	desc = "Apply this refill if the sprinkler light is red."
	icon = 'icons/obj/device.dmi'
	icon_state = "sprinkler_refill_water"
	w_class = WEIGHT_CLASS_SMALL
	var/used = FALSE
	var/chemtype = /datum/reagent/water

/obj/item/sprinkler_refill/Initialize()
	. = ..()
	create_reagents(50)
	reagents.add_reagent(chemtype, 50)
	update_icon()

/obj/item/sprinkler_refill/examine(mob/user)
	. = ..()
	if(used)
		. += "It has been used up, better throw it in the trash."

/obj/item/sprinkler_refill/update_icon()
	. = ..()
	cut_overlays()
	add_overlay(mutable_appearance(icon,"refill_[used ? "empty" : max(round(reagents.total_volume/10),1)]"))

/obj/item/sprinkler_refill/attack_obj(obj/O, mob/living/user)
	if(!used && istype(O, /obj/machinery/sprinkler))
		var/obj/machinery/sprinkler/S = O
		reagents.trans_to(S, 50, transfered_by = user)
		playsound(loc, 'sound/effects/refill.ogg', 50, 1, -6)
		to_chat(user, "You refill \the [S].")
		S.refill_loaded = TRUE
		S.update_icon()
		if(!reagents.total_volume)
			used = TRUE
		update_icon()

/obj/item/sprinkler_refill/foam
	name = "sprinkler refill (firefighting foam)"
	icon_state = "sprinkler_refill_foam"
	chemtype = /datum/reagent/firefighting_foam

/obj/item/deployable_sprinkler
	name = "deployable sprinkler"
	desc = "A self-deploying sprinkler, just press the button to activate it."
	icon = 'icons/obj/device.dmi'
	icon_state = "sprinkler_d"
	var/deploying = FALSE

/obj/item/deployable_sprinkler/attack_self(mob/user)
	. = ..()
	var/turf/T = get_turf(loc)
	if(locate(/obj/machinery/sprinkler) in T.contents)
		to_chat(user, "<span class='danger'>There is already a sprinkler here!</span>")
		return
	if(!deploying)
		to_chat(user, "You start planting \the [src]...")
		deploying = TRUE
		if(do_after(user, 50, target = src))
			to_chat(user, "You have activated \the [src].")
			new /obj/machinery/sprinkler (get_turf(src))
			qdel(src)
		else
			deploying = FALSE