/obj/item/reagent_containers/medspray
	name = "medical spray"
	desc = "A medical spray bottle, designed for precision application, with an unscrewable cap."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "medspray"
	item_state = "spraycan"
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
	volume = 60
	var/can_fill_from_container = TRUE
	var/apply_type = PATCH
	var/apply_method = "spray"
	var/self_delay = 30
	var/squirt_mode = 0
	var/squirt_amount = 5
	custom_price = 40

/obj/item/reagent_containers/medspray/attack_self(mob/user)
	squirt_mode = !squirt_mode
	if(squirt_mode)
		amount_per_transfer_from_this = squirt_amount
	else
		amount_per_transfer_from_this = initial(amount_per_transfer_from_this)
	to_chat(user, "<span class='notice'>You will now apply the medspray's contents in [squirt_mode ? "short bursts":"extended sprays"]. You'll now use [amount_per_transfer_from_this] units per use.</span>")

/obj/item/reagent_containers/medspray/attack(mob/M, mob/user, def_zone)
	if(!reagents || !reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return

	if(M == user)
		M.visible_message("<span class='notice'>[user] attempts to [apply_method] [src] on [user.p_them()]self.</span>")
		if(self_delay)
			if(!do_mob(user, M, self_delay))
				return
			if(!reagents || !reagents.total_volume)
				return
		to_chat(M, "<span class='notice'>You [apply_method] yourself with [src].</span>")

	else
		log_combat(user, M, "attempted to apply", src, reagents.log_list())
		M.visible_message("<span class='danger'>[user] attempts to [apply_method] [src] on [M].</span>", \
							"<span class='userdanger'>[user] attempts to [apply_method] [src] on [M].</span>")
		if(!do_mob(user, M))
			return
		if(!reagents || !reagents.total_volume)
			return
		M.visible_message("<span class='danger'>[user] [apply_method]s [M] down with [src].</span>", \
							"<span class='userdanger'>[user] [apply_method]s [M] down with [src].</span>")

	if(!reagents || !reagents.total_volume)
		return

	else
		log_combat(user, M, "applied", src, reagents.log_list())
		playsound(src, 'sound/effects/spray2.ogg', 50, 1, -6)
		var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1)
		reagents.reaction(M, apply_type, fraction)
		reagents.trans_to(M, amount_per_transfer_from_this, transfered_by = user)
	return

/obj/item/reagent_containers/medspray/styptic
	name = "medical spray (styptic powder)"
	desc = "A medical spray bottle, designed for precision application, with an unscrewable cap. This one contains styptic powder, for treating cuts and bruises."
	icon_state = "brutespray"
	list_reagents = list("styptic_powder" = 60)

/obj/item/reagent_containers/medspray/silver_sulf
	name = "medical spray (silver sulfadiazine)"
	desc = "A medical spray bottle, designed for precision application, with an unscrewable cap. This one contains silver sulfadiazine, useful for treating burns."
	icon_state = "burnspray"
	list_reagents = list("silver_sulfadiazine" = 60)

/obj/item/reagent_containers/medspray/synthflesh
	name = "medical spray (synthflesh)"
	desc = "A medical spray bottle, designed for precision application, with an unscrewable cap. This one contains synthflesh, an apex brute and burn healing agent."
	icon_state = "synthspray"
	list_reagents = list("synthflesh" = 60)
	custom_price = 80

/obj/item/reagent_containers/medspray/sterilizine
	name = "sterilizer spray"
	desc = "Spray bottle loaded with non-toxic sterilizer. Useful in preparation for surgery."
	list_reagents = list("sterilizine" = 60)
