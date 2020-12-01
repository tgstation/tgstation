//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
#define HYPO_SPRAY 0
#define HYPO_INJECT 1

#define WAIT_SPRAY 25
#define WAIT_INJECT 25
#define SELF_SPRAY 15
#define SELF_INJECT 15

#define DELUXE_WAIT_SPRAY 0
#define DELUXE_WAIT_INJECT 5
#define DELUXE_SELF_SPRAY 10
#define DELUXE_SELF_INJECT 10

#define COMBAT_WAIT_SPRAY 0
#define COMBAT_WAIT_INJECT 0
#define COMBAT_SELF_SPRAY 0
#define COMBAT_SELF_INJECT 0

/obj/item/hypospray/mkii
	name = "hypospray mk.II"
	icon_state = "hypo2"
	icon = 'modular_skyrat/modules/hyposprays/icons/hyposprays.dmi'
	desc = "A new development from DeForest Medical, this hypospray takes 60-unit vials as the drug supply for easy swapping."
	w_class = WEIGHT_CLASS_TINY
	var/list/allowed_containers = list(/obj/item/reagent_containers/glass/bottle/vial/small)
	var/mode = HYPO_INJECT
	var/obj/item/reagent_containers/glass/bottle/vial/vial
	var/start_vial = /obj/item/reagent_containers/glass/bottle/vial/small
	var/spawnwithvial = TRUE
	var/inject_wait = WAIT_INJECT
	var/spray_wait = WAIT_SPRAY
	var/spray_self = SELF_SPRAY
	var/inject_self = SELF_INJECT
	var/quickload = FALSE
	var/penetrates = FALSE

/obj/item/hypospray/mkii/brute
	start_vial = /obj/item/reagent_containers/glass/bottle/vial/small/bicaridine

/obj/item/hypospray/mkii/toxin
	start_vial = /obj/item/reagent_containers/glass/bottle/vial/small/antitoxin

/obj/item/hypospray/mkii/oxygen
	start_vial = /obj/item/reagent_containers/glass/bottle/vial/small/dexalin

/obj/item/hypospray/mkii/burn
	start_vial = /obj/item/reagent_containers/glass/bottle/vial/small/kelotane

/obj/item/hypospray/mkii/tricord
	start_vial = /obj/item/reagent_containers/glass/bottle/vial/small/tricord

/obj/item/hypospray/mkii/enlarge
	spawnwithvial = FALSE

/obj/item/hypospray/mkii/CMO
	name = "hypospray mk.II deluxe"
	allowed_containers = list(/obj/item/reagent_containers/glass/bottle/vial/small, /obj/item/reagent_containers/glass/bottle/vial/large)
	icon_state = "cmo2"
	desc = "The Deluxe Hypospray can take larger-size vials. It also acts faster and delivers more reagents per spray."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	start_vial = /obj/item/reagent_containers/glass/bottle/vial/large/cmo
	inject_wait = DELUXE_WAIT_INJECT
	spray_wait = DELUXE_WAIT_SPRAY
	spray_self = DELUXE_SELF_SPRAY
	inject_self = DELUXE_SELF_INJECT

/obj/item/hypospray/mkii/Initialize()
	. = ..()
	if(!spawnwithvial)
		update_icon()
		return
	if(start_vial)
		vial = new start_vial
	update_icon()

/obj/item/hypospray/mkii/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/hypospray/mkii/update_icon_state()
	icon_state = "[initial(icon_state)][vial ? "" : "-e"]"

/obj/item/hypospray/mkii/examine(mob/user)
	. = ..()
	if(vial)
		. += "[vial] has [vial.reagents.total_volume]u remaining."
	else
		. += "It has no vial loaded in."
	. += "[src] is set to [mode ? "Inject" : "Spray"] contents on application."

/obj/item/hypospray/mkii/proc/unload_hypo(obj/item/I, mob/user)
	if((istype(I, /obj/item/reagent_containers/glass/bottle/vial)))
		var/obj/item/reagent_containers/glass/bottle/vial/V = I
		V.forceMove(user.loc)
		user.put_in_hands(V)
		to_chat(user, "<span class='notice'>You remove [vial] from [src].</span>")
		vial = null
		update_icon()
		playsound(loc, 'sound/weapons/empty.ogg', 50, 1)
	else
		to_chat(user, "<span class='notice'>This hypo isn't loaded!</span>")
		return

/obj/item/hypospray/mkii/attackby(obj/item/I, mob/living/user)
	if((istype(I, /obj/item/reagent_containers/glass/bottle/vial) && vial != null))
		if(!quickload)
			to_chat(user, "<span class='warning'>[src] can not hold more than one vial!</span>")
			return FALSE
		unload_hypo(vial, user)
	if((istype(I, /obj/item/reagent_containers/glass/bottle/vial)))
		var/obj/item/reagent_containers/glass/bottle/vial/V = I
		if(!is_type_in_list(V, allowed_containers))
			to_chat(user, "<span class='notice'>[src] doesn't accept this type of vial.</span>")
			return FALSE
		if(!user.transferItemToLoc(V,src))
			return FALSE
		vial = V
		user.visible_message("<span class='notice'>[user] has loaded a vial into [src].</span>","<span class='notice'>You have loaded [vial] into [src].</span>")
		update_icon()
		playsound(loc, 'sound/weapons/autoguninsert.ogg', 35, 1)
		return TRUE
	else
		to_chat(user, "<span class='notice'>This doesn't fit in [src].</span>")
		return FALSE

/obj/item/hypospray/mkii/AltClick(mob/user)
	. = ..()
	if(vial)
		vial.attack_self(user)
		return TRUE

/obj/item/hypospray/mkii/emag_act(mob/user)
	. = ..()
	if(obj_flags & EMAGGED)
		to_chat(user, "[src] happens to be already overcharged.")
		return
	inject_wait = COMBAT_WAIT_INJECT
	spray_wait = COMBAT_WAIT_SPRAY
	spray_self = COMBAT_SELF_INJECT
	inject_self = COMBAT_SELF_SPRAY
	penetrates = TRUE
	to_chat(user, "You overcharge [src]'s control circuit.")
	obj_flags |= EMAGGED
	return TRUE

/obj/item/hypospray/mkii/attack_hand(mob/user)
	. = ..() //Don't bother changing this or removing it from containers will break.

/obj/item/hypospray/mkii/attack(obj/item/I, mob/user, params)
	return

/obj/item/hypospray/mkii/afterattack(atom/target, mob/user, proximity)
	if(!vial || !proximity || !isliving(target))
		return
	var/mob/living/L = target

	if(!L.reagents || !L.can_inject(user, TRUE, user.zone_selected, penetrates))
		return

	if(iscarbon(L))
		var/obj/item/bodypart/affecting = L.get_bodypart(check_zone(user.zone_selected))
		if(!affecting)
			to_chat(user, "<span class='warning'>The limb is missing!</span>")
			return
	//Always log attemped injections for admins
	var/contained = vial.reagents.log_list()
	log_combat(user, L, "attemped to inject", src, addition="which had [contained]")

	if(!vial)
		to_chat(user, "<span class='notice'>[src] doesn't have any vial installed!</span>")
		return
	if(!vial.reagents.total_volume)
		to_chat(user, "<span class='notice'>[src]'s vial is empty!</span>")
		return

	var/fp_verb = mode == HYPO_SPRAY ? "spray" : "inject"
	//var/method = mode == HYPO_SPRAY ? TOUCH : INJECT

	if(L != user)
		L.visible_message("<span class='danger'>[user] is trying to [fp_verb] [L] with [src]!</span>", \
						"<span class='userdanger'>[user] is trying to [fp_verb] you with [src]!</span>")
	if(!do_mob(user, L, inject_wait, extra_checks = CALLBACK(L, /mob/living/proc/can_inject, user, FALSE, user.zone_selected, penetrates)))
		return
	if(!vial.reagents.total_volume)
		return
	log_attack("<font color='red'>[user.name] ([user.ckey]) applied [src] to [L.name] ([L.ckey]), which had [contained] (INTENT: [uppertext(user.a_intent)]) (MODE: [mode])</font>")
	if(L != user)
		L.visible_message("<span class='danger'>[user] uses the [src] on [L]!</span>", \
						"<span class='userdanger'>[user] uses the [src] on you!</span>")
	else
		L.log_message("<font color='orange'>applied [src] to themselves ([contained]).</font>", INDIVIDUAL_ATTACK_LOG)

	//var/fraction = min(vial.amount_per_transfer_from_this/vial.reagents.total_volume, 1)
	//vial.reagents.reaction(L, method, fraction)
	vial.reagents.trans_to(target, vial.amount_per_transfer_from_this)
	var/long_sound = vial.amount_per_transfer_from_this >= 15
	playsound(loc, long_sound ? 'modular_skyrat/modules/hyposprays/sound/hypospray_long.ogg' : pick('modular_skyrat/modules/hyposprays/sound/hypospray.ogg','modular_skyrat/modules/hyposprays/sound/hypospray2.ogg'), 50, 1, -1)
	to_chat(user, "<span class='notice'>You [fp_verb] [vial.amount_per_transfer_from_this] units of the solution. The hypospray's cartridge now contains [vial.reagents.total_volume] units.</span>")

/obj/item/hypospray/mkii/attack_self(mob/living/user)
	if(user)
		if(user.incapacitated())
			return
		else if(!vial)
			to_chat(user, "This Hypo needs to be loaded first!")
			return
		else
			unload_hypo(vial,user)

/obj/item/hypospray/mkii/CtrlClick(mob/living/user)
	. = ..()
	if(user.canUseTopic(src, FALSE) && user.get_active_held_item(src))
		switch(mode)
			if(HYPO_SPRAY)
				mode = HYPO_INJECT
				to_chat(user, "[src] is now set to inject contents on application.")
			if(HYPO_INJECT)
				mode = HYPO_SPRAY
				to_chat(user, "[src] is now set to spray contents on application.")
		return TRUE

/obj/item/hypospray/mkii/examine(mob/user)
	. = ..()
	. += "<span class='notice'><b>Ctrl-Click</b> it to toggle its mode from spraying to injecting and vice versa.</span>"
//I need a drink.

#undef HYPO_SPRAY
#undef HYPO_INJECT
#undef WAIT_SPRAY
#undef WAIT_INJECT
#undef SELF_SPRAY
#undef SELF_INJECT
#undef DELUXE_WAIT_SPRAY
#undef DELUXE_WAIT_INJECT
#undef DELUXE_SELF_SPRAY
#undef DELUXE_SELF_INJECT
#undef COMBAT_WAIT_SPRAY
#undef COMBAT_WAIT_INJECT
#undef COMBAT_SELF_SPRAY
#undef COMBAT_SELF_INJECT
