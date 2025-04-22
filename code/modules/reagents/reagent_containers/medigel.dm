/obj/item/reagent_containers/medigel
	name = "medical gel"
	desc = "A medical gel applicator bottle, designed for precision application, with an unscrewable cap."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "medigel"
	inhand_icon_state = "spraycan"
	worn_icon_state = "spraycan"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	item_flags = NOBLUDGEON
	obj_flags = UNIQUE_RENAME
	reagent_flags = OPENCONTAINER
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10)
	volume = 60
	var/can_fill_from_container = TRUE
	var/apply_type = PATCH
	var/apply_method = "spray" //the thick gel is sprayed and then dries into patch like film.
	var/self_delay = 30
	custom_price = PAYCHECK_CREW * 2
	unique_reskin = list(
		"Blue" = "medigel_blue",
		"Cyan" = "medigel_cyan",
		"Green" = "medigel_green",
		"Red" = "medigel_red",
		"Orange" = "medigel_orange",
		"Purple" = "medigel_purple"
	)


/obj/item/reagent_containers/medigel/mode_change_message(mob/user)
	var/squirt_mode = amount_per_transfer_from_this == initial(amount_per_transfer_from_this)
	to_chat(user, span_notice("You will now apply the medigel's contents in [squirt_mode ? "extended sprays":"short bursts"]. You'll now use [amount_per_transfer_from_this] units per use."))

/obj/item/reagent_containers/medigel/attack(mob/M, mob/user, def_zone)
	if(!reagents || !reagents.total_volume)
		to_chat(user, span_warning("[src] is empty!"))
		return

	if(M == user)
		M.visible_message(span_notice("[user] attempts to [apply_method] [src] on [user.p_them()]self."))
		if(self_delay)
			if(!do_after(user, self_delay, M))
				return
			if(!reagents || !reagents.total_volume)
				return
		to_chat(M, span_notice("You [apply_method] yourself with [src]."))

	else
		log_combat(user, M, "attempted to apply", src, reagents.get_reagent_log_string())
		M.visible_message(span_danger("[user] attempts to [apply_method] [src] on [M]."), \
							span_userdanger("[user] attempts to [apply_method] [src] on you."))
		if(!do_after(user, CHEM_INTERACT_DELAY(3 SECONDS, user), M))
			return
		if(!reagents || !reagents.total_volume)
			return
		M.visible_message(span_danger("[user] [apply_method]s [M] down with [src]."), \
							span_userdanger("[user] [apply_method]s you down with [src]."))

	if(!reagents || !reagents.total_volume)
		return

	else
		log_combat(user, M, "applied", src, reagents.get_reagent_log_string())
		playsound(src, 'sound/effects/spray.ogg', 30, TRUE, -6)
		reagents.trans_to(M, amount_per_transfer_from_this, transferred_by = user, methods = apply_type)
	return

/obj/item/reagent_containers/medigel/libital
	name = "medical gel (libital)"
	desc = "A medical gel applicator bottle, designed for precision application, with an unscrewable cap. This one contains libital, for treating cuts and bruises. Libital does minor liver damage. Diluted with granibitaluri."
	icon_state = "brutegel"
	current_skin = "brutegel"
	list_reagents = list(/datum/reagent/medicine/c2/libital = 24, /datum/reagent/medicine/granibitaluri = 36)

/obj/item/reagent_containers/medigel/aiuri
	name = "medical gel (aiuri)"
	desc = "A medical gel applicator bottle, designed for precision application, with an unscrewable cap. This one contains aiuri, useful for treating burns. Aiuri does minor eye damage. Diluted with granibitaluri."
	icon_state = "burngel"
	current_skin = "burngel"
	list_reagents = list(/datum/reagent/medicine/c2/aiuri = 24, /datum/reagent/medicine/granibitaluri = 36)

/obj/item/reagent_containers/medigel/synthflesh
	name = "medical gel (synthflesh)"
	desc = "A medical gel applicator bottle, designed for precision application, with an unscrewable cap. This one contains synthflesh, a slightly toxic medicine capable of healing bruises, burns, and husks."
	icon_state = "synthgel"
	current_skin = "synthgel"
	list_reagents = list(/datum/reagent/medicine/c2/synthflesh = 60)
	list_reagents_purity = 1
	amount_per_transfer_from_this = 60
	possible_transfer_amounts = list(5, 10, 60)
	custom_price = PAYCHECK_CREW * 5

/obj/item/reagent_containers/medigel/synthflesh/examine(mob/user)
	. = ..()
	if(reagents.total_volume >= 60)
		. += span_info("One full bottle can restore a corpse husked by burns.")

/obj/item/reagent_containers/medigel/synthflesh/attack(mob/M, mob/user, def_zone)
	if(iscarbon(M))
		var/mob/living/carbon/carbies = M
		if(HAS_TRAIT_FROM(carbies, TRAIT_HUSK, BURN) && carbies.getFireLoss() > UNHUSK_DAMAGE_THRESHOLD * 2.5)
			// give them a warning if the mob is a husk but synthflesh won't unhusk yet
			carbies.visible_message(span_boldwarning("[carbies]'s burns need to be repaired first before synthflesh will unhusk it!"))

	return ..()

/obj/item/reagent_containers/medigel/sterilizine
	name = "sterilizer gel"
	desc = "gel bottle loaded with non-toxic sterilizer. Useful in preparation for surgery."
	icon_state = "medigel_blue"
	current_skin = "medigel_blue"
	list_reagents = list(/datum/reagent/space_cleaner/sterilizine = 60)
	custom_price = PAYCHECK_CREW * 2
