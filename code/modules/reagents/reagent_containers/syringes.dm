////////////////////////////////////////////////////////////////////////////////
/// Syringes.
////////////////////////////////////////////////////////////////////////////////
#define SYRINGE_DRAW 0
#define SYRINGE_INJECT 1
#define SYRINGE_BROKEN 2

#define INJECTION_BODY 0
#define INJECTION_SUIT_PORT 1

/obj/item/weapon/reagent_containers/syringe
	name = "syringe"
	desc = "A syringe."
	icon = 'icons/obj/syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	amount_per_transfer_from_this = 5
	sharpness = 1
	possible_transfer_amounts = null //list(5,10,15)
	volume = 15
	starting_materials = list(MAT_GLASS = 1000)
	w_type = RECYK_GLASS

	var/mode = SYRINGE_DRAW
	var/can_draw_blood = TRUE
	var/can_stab = TRUE

	// List of types that can be injected regardless of the CONTAINEROPEN flag
	// TODO Remove snowflake
	var/injectable_types = list(/obj/item/weapon/reagent_containers/food,
	                            /obj/item/slime_extract,
	                            /obj/item/clothing/mask/cigarette,
	                            /obj/item/weapon/storage/fancy/cigarettes,
	                            /obj/item/weapon/implantcase/chem,
	                            /obj/item/weapon/reagent_containers/pill/time_release)

/obj/item/weapon/reagent_containers/syringe/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='danger'>[user] appears to be injecting an air bubble using a [src.name]! It looks like \he's trying to commit suicide.</span>")
	return(OXYLOSS)

/obj/item/weapon/reagent_containers/syringe/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/syringe/pickup(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/syringe/dropped(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/syringe/attack_self(mob/user as mob)
	switch(mode)
		if(SYRINGE_DRAW)
			mode = SYRINGE_INJECT
		if(SYRINGE_INJECT)
			mode = SYRINGE_DRAW
		if(SYRINGE_BROKEN)
			return
	update_icon()

/obj/item/weapon/reagent_containers/syringe/attack_hand(var/mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/syringe/attack_paw(var/mob/user)
	return attack_hand(user)

/obj/item/weapon/reagent_containers/syringe/afterattack(obj/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag == 0) // not adjacent
		return

	if(!target.reagents) return

	if(mode == SYRINGE_BROKEN)
		to_chat(user, "<span class='warning'>\The [src] is broken!</span>")
		return

	if (user.a_intent == I_HURT && ismob(target))
		if((M_CLUMSY in user.mutations) && prob(50))
			target = user

		if (target != user && !can_stab) // You still can stab yourself if you're clumsy, honk
			to_chat(user, "<span class='notice'>You can't grasp \the [src] properly for stabbing!</span>")
			return

		syringestab(target, user)
		return

	if (mode == SYRINGE_DRAW)
		handle_draw(target, user)
	else if (mode == SYRINGE_INJECT)
		handle_inject(target, user)

/obj/item/weapon/reagent_containers/syringe/update_icon()
	if(mode == SYRINGE_BROKEN)
		icon_state = "broken"
		overlays.len = 0
		return
	var/rounded_vol = round(reagents.total_volume,5)
	overlays.len = 0
	if(ismob(loc))
		var/injoverlay
		switch(mode)
			if (SYRINGE_DRAW)
				injoverlay = "draw"
			if (SYRINGE_INJECT)
				injoverlay = "inject"
		overlays += injoverlay
	icon_state = "[rounded_vol]"
	item_state = "syringe_[rounded_vol]"

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "syringe10")

		filling.icon_state = "syringe[rounded_vol]"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		overlays += filling

/obj/item/weapon/reagent_containers/syringe/proc/handle_draw(var/atom/target, var/mob/user)
	if (!target)
		return

	if (src.is_full())
		to_chat(user, "<span class='warning'>\The [src] is full.</span>")
		return

	// Drawing from mobs draws from their blood or equivalent
	if (ismob(target))
		if (!can_draw_blood)
			to_chat(user, "This needle isn't designed for drawing fluids from living things.")
			return

		if (istype(target, /mob/living/carbon/slime))
			to_chat(user, "<span class='warning'>You are unable to locate any blood.</span>")
			return

		if (reagents.has_reagent("blood")) // TODO Current reagent system can't handle multiple blood sources properly
			to_chat(user, "<span class='warning'>There is already a blood sample in this syringe!</span>")
			return
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.species && (H.species.chem_flags & NO_INJECT))
				user.visible_message("<span class='warning'>[user] attempts to poke [H] with \the [src] but it won't go in!</span>", "<span class='notice'>You fail to pierce [H] with \the [src]</span>")
				return

		if (iscarbon(target))
			var/mob/living/carbon/T = target
			if (!T.dna)
				to_chat(user, "<span class='warning'>You are unable to locate any blood.</span>")
				warning("Tried to draw blood or equivalent from [target] (\ref[target]) but it's missing their DNA datum!")
				return

			if (M_NOCLONE in T.mutations) // Target has been husked
				to_chat(user, "<span class='warning'>You are unable to locate any blood.</span>")
				return

			var/amount = src.reagents.maximum_volume - src.reagents.total_volume
			var/datum/reagent/B = T.take_blood(null, amount)
			//reagents.add_reagent("blood",
			if (B)
				reagents.add_reagent("blood", amount, B.data)
				user.visible_message("<span class='notice'>[user] takes a blood sample from [target].</span>",
									 "<span class='notice'>You take a blood sample from [target].</span>")
			else
				user.visible_message("<span class='warning'>[user] inserts the syringe into [target], draws back the plunger and gets... nothing?</span>",\
					"<span class='warning'>You insert the syringe into [target], draw back the plunger and get... nothing?</span>")
	// Drawing from objects draws their contents
	else if (isobj(target))
		if (!target.is_open_container() && !istype(target, /obj/structure/reagent_dispensers) && !istype(target, /obj/item/slime_extract))
			to_chat(user, "<span class='warning'>You cannot directly remove reagents from this object.")
			return

		var/tx_amount = 0
		if (istype(target, /obj/item/weapon/reagent_containers) || istype(target, /obj/structure/reagent_dispensers))
			tx_amount = transfer_sub(target, src, amount_per_transfer_from_this, user)
		else
			tx_amount = target.reagents.trans_to(src, amount_per_transfer_from_this)

		if (tx_amount > 0)
			to_chat(user, "<span class='notice'>You fill \the [src] with [tx_amount] units of the solution.</span>")
		else if (tx_amount == 0)
			to_chat(user, "<span class='warning'>\The [target] is empty.</span>")

	if (src.is_full())
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/weapon/reagent_containers/syringe/proc/handle_inject(var/atom/target, var/mob/user)
	if (src.is_empty())
		to_chat(user, "<span class='warning'>\The [src] is empty.</span>")
		return

	// TODO Remove snowflake
	if (!ismob(target) && !target.is_open_container() && !is_type_in_list(target, injectable_types))
		to_chat(user, "<span class='warning'>You cannot directly fill this object.</span>")
		return

	if (target.reagents.total_volume >= target.reagents.maximum_volume)
		to_chat(user, "<span class='warning'>\The [target] is full.</span>")
		return

	// Attempting to inject someone else takes time
	if (ismob(target) && target != user)
		if (get_injection_action(target) == INJECTION_SUIT_PORT)
			user.visible_message("<span class='warning'>[user] begins hunting for an injection port \the [src] on [target]'s suit!</span>",
								 "<span class='warning'>You begin hunting for an injection port for \the [src] on [target]'s suit!</span>")
		else
			user.visible_message("<span class='warning'>[user] is trying to inject [target] with \the [src]!</span>",
								 "<span class='warning'>You try to inject [target] with \the [src]!</span>")

		if (!do_mob(user, target, get_injection_time(target)))
			return

		user.visible_message("<span class='warning'>[user] injects [target] with the \the [src]!</span>",
							 "<span class='warning'>You inject [target] with \the [src]!</span>")

		if (istype(target, /mob/living))
			var/reagent_names = english_list(get_reagent_names())
			add_attacklogs(user, target, "injected", object = src, addition = "Reagents: [reagent_names]", admin_warn = TRUE)

	// Handle transfers and mob reactions
	var/list/bad_reagents = reagents.get_bad_reagent_names() // Used for logging
	var/tx_amount = min(amount_per_transfer_from_this, reagents.total_volume)
	if (ismob(target))
		// TODO Every reagent reacts with the full volume instead of being scaled accordingly
		// TODO which is pretty irrelevant now but should be fixed
		reagents.reaction(target, INGEST)

	tx_amount = reagents.trans_to(target, tx_amount)
	to_chat(user, "<span class='notice'>You inject [tx_amount] units of the solution. The syringe now contains [reagents.total_volume] units.</span>")

	// Log transfers of 'bad things' (/vg/)
	if (tx_amount > 0 && isobj(target) && target:log_reagents && bad_reagents && bad_reagents.len > 0)
		log_reagents(user, src, target, tx_amount, bad_reagents)

	if (src.is_empty())
		mode = SYRINGE_DRAW
		update_icon()

// Injecting people with a space suit/hardsuit is harder
/obj/item/weapon/reagent_containers/syringe/proc/get_injection_time(var/mob/target)
	if (istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		return (H.wear_suit && istype(H.wear_suit, /obj/item/clothing/suit/space)) ? 60 : 30
	else
		return 30

/obj/item/weapon/reagent_containers/syringe/proc/get_injection_action(var/mob/target)
	if (istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		return (H.wear_suit && istype(H.wear_suit,/obj/item/clothing/suit/space)) ? INJECTION_SUIT_PORT : INJECTION_BODY
	else
		return INJECTION_BODY

/obj/item/weapon/reagent_containers/syringe/proc/syringestab(mob/living/carbon/target as mob, mob/living/carbon/user as mob)
	if (ishuman(target))
		var/mob/living/carbon/human/H = target
		var/target_zone = check_zone(user.zone_sel.selecting, target)
		var/datum/organ/external/affecting = H.get_organ(target_zone)

		if (!affecting)
			return
		else if (affecting.status & ORGAN_DESTROYED)
			to_chat(user, "What [affecting.display_name]?")
			return

		var/hit_area = affecting.display_name
		if((user != target) && H.check_shields(7, "the [src.name]"))
			return

		// Check for protection on the targeted area and show messages
		var/deflected = (target != user && target.getarmor(target_zone, "melee") > 5 && prob(50))

		add_attacklogs(user, target, (deflected ? "attempted to inject" : "injected"), object = src, addition = "Deflected: [deflected ? "YES" : "NO"]; Reagents: [english_list(get_reagent_names())]", admin_warn = !deflected)

		if (deflected)
			user.visible_message("<span class='danger'>[user] tries to stab [target] in \the [hit_area] with \the [src], but the attack is deflected by armor!</span>", "<span class='danger'>You try to stab [target] in \the [hit_area] with \the [src], but the attack is deflected by armor!</span>")
			user.u_equip(src, 1)
			qdel(src)
			return // Avoid the transfer since we're using qdel
		else
			user.visible_message("<span class='danger'>[user] stabs [target] in \the [hit_area] with \the [src]!</span>", "<span class='danger'>You stab [target] in \the [hit_area] with \the [src]!</span>")
			affecting.take_damage(3)
	else
		user.visible_message("<span class='danger'>[user] stabs [target] with \the [src]!</span>", "<span class='danger'>You stab [target] with \the [src]!</span>")
		target.take_organ_damage(3)// 7 is the same as crowbar punch

	// Break the syringe and transfer some of the reagents to the target
	src.reagents.reaction(target, INGEST)
	var/syringestab_amount_transferred = rand(0, (reagents.total_volume - 5)) //nerfed by popular demand
	src.reagents.trans_to(target, syringestab_amount_transferred)
	src.desc += " It is broken."
	src.mode = SYRINGE_BROKEN
	src.add_blood(target)
	src.add_fingerprint(usr)
	src.update_icon()

/obj/item/weapon/reagent_containers/syringe/giant
	name = "giant syringe"
	desc = "A syringe used for lethal injections."
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = null
	volume = 50

	can_draw_blood = FALSE
	can_stab = FALSE

/obj/item/weapon/reagent_containers/syringe/giant/get_injection_time(var/mob/target)
	if (istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		return (H.wear_suit && istype(H.wear_suit, /obj/item/clothing/suit/space)) ? 330 : 300
	else
		return 300

/obj/item/weapon/reagent_containers/syringe/giant/update_icon()
	if (mode == SYRINGE_BROKEN)
		icon_state = "broken"
		return

	var/rounded_vol = round(reagents.total_volume, 50)
	icon_state = (ismob(loc) ? "[mode == SYRINGE_DRAW ? "d" : "i"][rounded_vol]" : "[rounded_vol]")
	item_state = "syringe_[rounded_vol]"

////////////////////////////////////////////////////////////////////////////////
/// Syringes. END
////////////////////////////////////////////////////////////////////////////////



/obj/item/weapon/reagent_containers/syringe/inaprovaline
	name = "Syringe (inaprovaline)"
	desc = "Contains inaprovaline - used to stabilize patients."
/obj/item/weapon/reagent_containers/syringe/inaprovaline/New()
	..()
	reagents.add_reagent("inaprovaline", 15)
	mode = SYRINGE_INJECT
	update_icon()

/obj/item/weapon/reagent_containers/syringe/antitoxin
	name = "Syringe (anti-toxin)"
	desc = "Contains anti-toxins."
/obj/item/weapon/reagent_containers/syringe/antitoxin/New()
	..()
	reagents.add_reagent("anti_toxin", 15)
	mode = SYRINGE_INJECT
	update_icon()

/obj/item/weapon/reagent_containers/syringe/antiviral
	name = "Syringe (spaceacillin)"
	desc = "Contains antiviral agents."
/obj/item/weapon/reagent_containers/syringe/antiviral/New()
	..()
	reagents.add_reagent("spaceacillin", 15)
	mode = SYRINGE_INJECT
	update_icon()

/obj/item/weapon/reagent_containers/syringe/charcoal
	name = "Syringe (Activated Charcoal)"
	desc = "Contains activated charcoal - used to treat overdoses."
/obj/item/weapon/reagent_containers/syringe/charcoal/New()
	..()
	reagents.add_reagent("charcoal", 15)
	mode = SYRINGE_INJECT
	update_icon()

/obj/item/weapon/reagent_containers/syringe/giant/chloral
	name = "Lethal Injection Syringe"
	desc = "Puts people into a sleep they'll never wake up from."
/obj/item/weapon/reagent_containers/syringe/giant/chloral/New()
	..()
	reagents.add_reagent("chloralhydrate", 50)
	mode = SYRINGE_INJECT
	update_icon()


//Robot syringes
//Not special in any way, code wise. They don't have added variables or procs.
/obj/item/weapon/reagent_containers/syringe/robot/antitoxin
	name = "Syringe (anti-toxin)"
	desc = "Contains anti-toxins."
/obj/item/weapon/reagent_containers/syringe/robot/antitoxin/New()
	..()
	reagents.add_reagent("anti_toxin", 15)
	mode = SYRINGE_INJECT
	update_icon()

/obj/item/weapon/reagent_containers/syringe/robot/inoprovaline
	name = "Syringe (inoprovaline)"
	desc = "Contains inaprovaline - used to stabilize patients."
/obj/item/weapon/reagent_containers/syringe/robot/inoprovaline/New()
	..()
	reagents.add_reagent("inaprovaline", 15)
	mode = SYRINGE_INJECT
	update_icon()

/obj/item/weapon/reagent_containers/syringe/robot/charcoal
	name = "Syringe (Activated Charcoal)"
	desc = "Contains activated charcoal - used to treat overdoses."
/obj/item/weapon/reagent_containers/syringe/robot/charcoal/New()
	..()
	reagents.add_reagent("charcoal", 15)
	mode = SYRINGE_INJECT
	update_icon()

/obj/item/weapon/reagent_containers/syringe/robot/mixed
	name = "Syringe (mixed)"
	desc = "Contains inaprovaline & anti-toxins."
/obj/item/weapon/reagent_containers/syringe/robot/mixed/New()
	..()
	reagents.add_reagent("inaprovaline", 7)
	reagents.add_reagent("anti_toxin", 8)
	mode = SYRINGE_INJECT
	update_icon()
