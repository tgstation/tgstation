#define HYPO_SPRAY 0
#define HYPO_INJECT 1

#define WAIT_SPRAY 25
#define WAIT_INJECT 25
#define SELF_SPRAY 15
#define SELF_INJECT 15

#define DELUXE_WAIT_SPRAY 20
#define DELUXE_WAIT_INJECT 20
#define DELUXE_SELF_SPRAY 10
#define DELUXE_SELF_INJECT 10

#define COMBAT_WAIT_SPRAY 0
#define COMBAT_WAIT_INJECT 0
#define COMBAT_SELF_SPRAY 0
#define COMBAT_SELF_INJECT 0

//A vial-loaded hypospray. Cartridge-based!
/obj/item/hypospray/mkii
	name = "hypospray mk.II"
	icon = 'modular_citadel/icons/obj/hypospraymkii.dmi'
	icon_state = "hypo2"
	desc = "A new development from DeForest Medical, this hypospray takes 30-unit vials as the drug supply for easy swapping."
	w_class = WEIGHT_CLASS_TINY
	var/list/allowed_containers = list(/obj/item/reagent_containers/glass/bottle/vial/tiny, /obj/item/reagent_containers/glass/bottle/vial/small)
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
	start_vial = /obj/item/reagent_containers/glass/bottle/vial/small/preloaded/bicaridine

/obj/item/hypospray/mkii/toxin
	start_vial = /obj/item/reagent_containers/glass/bottle/vial/small/preloaded/antitoxin

/obj/item/hypospray/mkii/oxygen
	start_vial = /obj/item/reagent_containers/glass/bottle/vial/small/preloaded/dexalin

/obj/item/hypospray/mkii/burn
	start_vial = /obj/item/reagent_containers/glass/bottle/vial/small/preloaded/kelotane

/obj/item/hypospray/mkii/tricord
	start_vial = /obj/item/reagent_containers/glass/bottle/vial/small/preloaded/tricord

/obj/item/hypospray/mkii/CMO
	name = "hypospray mk.II deluxe"
	allowed_containers = list(/obj/item/reagent_containers/glass/bottle/vial/tiny, /obj/item/reagent_containers/glass/bottle/vial/small, /obj/item/reagent_containers/glass/bottle/vial/large)
	icon_state = "cmo2"
	desc = "The Deluxe Hypospray can take larger-size vials. It also acts faster and delivers more reagents per spray."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	start_vial = /obj/item/reagent_containers/glass/bottle/vial/large/preloaded/CMO
	inject_wait = DELUXE_WAIT_INJECT
	spray_wait = DELUXE_WAIT_SPRAY
	spray_self = DELUXE_SELF_SPRAY
	inject_self = DELUXE_SELF_INJECT

/obj/item/hypospray/mkii/CMO/combat
	name = "combat hypospray mk.II"
	desc = "A combat-ready deluxe hypospray that acts almost instantly. It can be tactically reloaded by using a vial on it."
	icon_state = "combat2"
	start_vial = /obj/item/reagent_containers/glass/bottle/vial/large/preloaded/combat
	inject_wait = COMBAT_WAIT_INJECT
	spray_wait = COMBAT_WAIT_SPRAY
	spray_self = COMBAT_SELF_SPRAY
	inject_self = COMBAT_SELF_INJECT
	quickload = TRUE
	penetrates = TRUE

/obj/item/hypospray/mkii/Initialize()
	. = ..()
	if(!spawnwithvial)
		update_icon()
		return
	if(start_vial)
		vial = new start_vial
	update_icon()

/obj/item/hypospray/mkii/update_icon()
	..()
	icon_state = "[initial(icon_state)][vial ? "" : "-e"]"
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()
	return

/obj/item/hypospray/mkii/examine(mob/user)
	. = ..()
	to_chat(user, "[vial] has [vial.reagents.total_volume]u remaining.")
	to_chat(user, "[src] is set to [mode ? "Inject" : "Spray"] contents on application.")

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
	return FALSE

/obj/item/hypospray/mkii/AltClick(mob/user)
	if(vial)
		vial.attack_self(user)

// Gunna allow this for now, still really don't approve - Pooj
/obj/item/hypospray/mkii/emag_act(mob/user)
	inject_wait = COMBAT_WAIT_INJECT
	spray_wait = COMBAT_WAIT_SPRAY
	spray_self = COMBAT_SELF_INJECT
	inject_self = COMBAT_SELF_SPRAY
	penetrates = TRUE
	to_chat(user, "You overcharge [src]'s control circuit.")

/obj/item/hypospray/mkii/attack_hand(mob/user)
	. = ..() //Don't bother changing this or removing it from containers will break.

/obj/item/hypospray/mkii/attack(obj/item/I, mob/user, params)
	return

/obj/item/hypospray/mkii/afterattack(atom/target, mob/user, proximity)
	if(!vial)
		return

	if(!proximity)
		return

	if(!ismob(target))
		return

	var/mob/living/L
	if(isliving(target))
		L = target
		if(!penetrates && !L.can_inject(user, 1)) //This check appears another four times, since otherwise the penetrating sprays will break in do_mob.
			return

	if(!L && !target.is_injectable()) //only checks on non-living mobs, due to how can_inject() handles
		to_chat(user, "<span class='warning'>You cannot directly fill [target]!</span>")
		return

	if(target.reagents.total_volume >= target.reagents.maximum_volume)
		to_chat(user, "<span class='notice'>[target] is full.</span>")
		return

	if(ishuman(L))
		var/obj/item/bodypart/affecting = L.get_bodypart(check_zone(user.zone_selected))
		if(!affecting)
			to_chat(user, "<span class='warning'>The limb is missing!</span>")
			return
		if(affecting.status != BODYPART_ORGANIC)
			to_chat(user, "<span class='notice'>Medicine won't work on a robotic limb!</span>")
			return

	var/contained = vial.reagents.log_list()
	add_logs(user, L, "attemped to inject", src, addition="which had [contained]")
//Always log attemped injections for admins
	if(vial != null)
		switch(mode)
			if(HYPO_INJECT)
				if(L) //living mob
					if(L != user)
						L.visible_message("<span class='danger'>[user] is trying to inject [L] with [src]!</span>", \
										"<span class='userdanger'>[user] is trying to inject [L] with [src]!</span>")
						if(!do_mob(user, L, inject_wait))
							return
						if(!penetrates && !L.can_inject(user, 1))
							return
						if(!vial.reagents.total_volume)
							return
						if(L.reagents.total_volume >= L.reagents.maximum_volume)
							return
						L.visible_message("<span class='danger'>[user] uses the [src] on [L]!</span>", \
										"<span class='userdanger'>[user] uses the [src] on [L]!</span>")
					else
						if(!do_mob(user, L, inject_self))
							return
						if(!penetrates && !L.can_inject(user, 1))
							return
						if(!vial.reagents.total_volume)
							return
						if(L.reagents.total_volume >= L.reagents.maximum_volume)
							return
						log_attack("<font color='red'>[user.name] ([user.ckey]) applied [src] to [L.name] ([L.ckey]), which had [contained] (INTENT: [uppertext(user.a_intent)]) (MODE: [src.mode])</font>")
						L.log_message("<font color='orange'>applied [src] to  themselves ([contained]).</font>", INDIVIDUAL_ATTACK_LOG)

				var/fraction = min(vial.amount_per_transfer_from_this/vial.reagents.total_volume, 1)
				vial.reagents.reaction(L, INJECT, fraction)
				vial.reagents.trans_to(target, vial.amount_per_transfer_from_this)
				if(vial.amount_per_transfer_from_this >= 15)
					playsound(loc,'sound/items/hypospray_long.ogg',50, 1, -1)
				if(vial.amount_per_transfer_from_this < 15)
					playsound(loc,  pick('sound/items/hypospray.ogg','sound/items/hypospray2.ogg'), 50, 1, -1)
				to_chat(user, "<span class='notice'>You inject [vial.amount_per_transfer_from_this] units of the solution. The hypospray's cartridge now contains [vial.reagents.total_volume] units.</span>")

			if(HYPO_SPRAY)
				if(L) //living mob
					if(L != user)
						L.visible_message("<span class='danger'>[user] is trying to spray [L] with [src]!</span>", \
										"<span class='userdanger'>[user] is trying to spray [L] with [src]!</span>")
						if(!do_mob(user, L, spray_wait))
							return
						if(!penetrates && !L.can_inject(user, 1))
							return
						if(!vial.reagents.total_volume)
							return
						if(L.reagents.total_volume >= L.reagents.maximum_volume)
							return
						L.visible_message("<span class='danger'>[user] uses the [src] on [L]!</span>", \
										"<span class='userdanger'>[user] uses the [src] on [L]!</span>")
					else
						if(!do_mob(user, L, spray_self))
							return
						if(!penetrates && !L.can_inject(user, 1))
							return
						if(!vial.reagents.total_volume)
							return
						if(L.reagents.total_volume >= L.reagents.maximum_volume)
							return
						log_attack("<font color='red'>[user.name] ([user.ckey]) applied [src] to [L.name] ([L.ckey]), which had [contained] (INTENT: [uppertext(user.a_intent)]) (MODE: [src.mode])</font>")
						L.log_message("<font color='orange'>applied [src] to  themselves ([contained]).</font>", INDIVIDUAL_ATTACK_LOG)
				var/fraction = min(vial.amount_per_transfer_from_this/vial.reagents.total_volume, 1)
				vial.reagents.reaction(L, PATCH, fraction)
				vial.reagents.trans_to(target, vial.amount_per_transfer_from_this)
				if(vial.amount_per_transfer_from_this >= 15)
					playsound(loc,'sound/items/hypospray_long.ogg',50, 1, -1)
				if(vial.amount_per_transfer_from_this < 15)
					playsound(loc,  pick('sound/items/hypospray.ogg','sound/items/hypospray2.ogg'), 50, 1, -1)
				to_chat(user, "<span class='notice'>You spray [vial.amount_per_transfer_from_this] units of the solution. The hypospray's cartridge now contains [vial.reagents.total_volume] units.</span>")
	else
		to_chat(user, "<span class='notice'>[src] doesn't work here!</span>")
		return

/obj/item/hypospray/mkii/attack_self(mob/living/user)
	if(user)
		if(user.incapacitated())
			return
		else if(!vial)
			to_chat(user, "This Hypo needs to be loaded first!")
			return
		else
			unload_hypo(vial,user)

/obj/item/hypospray/mkii/verb/modes()
	set name = "Toggle Application Mode"
	set category = "Object"
	set src in usr
	var/mob/M = usr
	switch(mode)
		if(HYPO_SPRAY)
			mode = HYPO_INJECT
			to_chat(M, "[src] is now set to inject contents on application.")
		if(HYPO_INJECT)
			mode = HYPO_SPRAY
			to_chat(M, "[src] is now set to spray contents on application.")
