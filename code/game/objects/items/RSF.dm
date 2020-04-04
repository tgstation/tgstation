/*
CONTAINS:
RSF

*/
/obj/item/rsf
	name = "\improper Rapid-Service-Fabricator"
	desc = "A device used to rapidly deploy service items."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rsf"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	opacity = 0
	density = FALSE
	anchored = FALSE
	item_flags = NOBLUDGEON
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	var/matter = 0
	var/max_matter = 30
	var/to_despense
	w_class = WEIGHT_CLASS_NORMAL
	var/list/cost_by_item = list(/obj/item/reagent_containers/food/drinks/drinkingglass = 20,
								/obj/item/paper = 10,
								/obj/item/pen = 50,
								/obj/item/storage/pill_bottle/dice = 200,
								/obj/item/clothing/mask/cigarette = 10,
								)
	var/list/matter_by_item = list(/obj/item/rcd_ammo = 10,)

/obj/item/rsf/Initialize()
	. = ..()
	to_despense = cost_by_item[1]

/obj/item/rsf/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It currently holds [(matter/max_matter) * 100]% matter.</span>"

/obj/item/rsf/cyborg
	matter = 30

/obj/item/rsf/attackby(obj/item/W, mob/user, params)
	if(is_type_in_list(W,matter_by_item))
		if(matter > max_matter)
			to_chat(user, "<span class='warning'>The RSF can't hold any more matter!</span>")
			return
		qdel(W)
		matter += matter_by_item[W.type]
		if(matter > max_matter)
			matter = max_matter
		playsound(src.loc, 'sound/machines/click.ogg', 10, TRUE)
		to_chat(user, "<span class='notice'>The RSF now holds [(matter/max_matter) * 100]% matter.</span>")
		icon_state = "rsf"
	else
		return ..()

/obj/item/rsf/attack_self(mob/user)
	if(!user)
		return
	playsound(src.loc, 'sound/effects/pop.ogg', 50, FALSE)
	var/list/item_list = list()
	for(var/meme in cost_by_item)
		message_admins(meme)
		var/atom/test = new meme()
		item_list[test.name] = image(icon = test.icon, icon_state = test.icon_state)
	var/atom/item_result = show_radial_menu(user, src, item_list, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE)
	if(!check_menu(user))
		return
	to_despense = item_result
	// Change mode

/obj/item/rsf/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/rsf/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if (!(istype(A, /obj/structure/table) || isfloorturf(A)))
		return
	message_admins("I'm in [to_despense] [cost_by_item[to_despense]]")
	if(use_matter(cost_by_item[to_despense], user))
		playsound(src.loc, 'sound/machines/click.ogg', 10, TRUE)
		to_chat(user, "<span class='notice'>Dispensing [to_despense.name]...</span>")
		var/atom/meme = new to_despense(get_turf(A))

/obj/item/rsf/proc/use_matter(charge, mob/user)
	message_admins("Using [charge]")
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		var/end_charge = R.cell.charge - charge
		if(end_charge >= 0)
			R.cell.charge = end_charge
			return TRUE
		to_chat(user, "<span class='warning'>You do not have enough power to use [src].</span>")
	else
		if(matter - 1 >= 0)
			matter--
			to_chat(user, "<span class='notice'>The RSF now holds [(matter/max_matter) * 100]% matter.</span>")
			return TRUE
		to_chat(user, "<span class='warning'>\The [src] doesn't have enough matter left.</span>")
	icon_state = "rsf_empty"
	return FALSE

/obj/item/rsf/cookiesynth
	name = "Cookie Synthesizer"
	desc = "A self-recharging device used to rapidly deploy cookies."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	var/toxin = FALSE
	var/cooldown = 0
	var/cooldowndelay = 10
	w_class = WEIGHT_CLASS_NORMAL
	cost_by_item = list(/obj/item/reagent_containers/food/snacks/cookie = 100,)

/obj/item/rsf/cookiesynth/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It currently holds [matter]/10 cookie-units.</span>"

/obj/item/rsf/cookiesynth/attackby()
	return

/obj/item/rsf/cookiesynth/emag_act(mob/user)
	obj_flags ^= EMAGGED
	if(obj_flags & EMAGGED)
		to_chat(user, "<span class='warning'>You short out [src]'s reagent safety checker!</span>")
	else
		to_chat(user, "<span class='warning'>You reset [src]'s reagent safety checker!</span>")
		toxin = 0

/obj/item/rsf/cookiesynth/attack_self(mob/user)
	var/mob/living/silicon/robot/P = null
	if(iscyborg(user))
		P = user
	if((obj_flags & EMAGGED)&&!toxin)
		toxin = 1
		to_chat(user, "<span class='alert'>Cookie Synthesizer hacked.</span>")
	else if(P.emagged&&!toxin)
		toxin = 1
		to_chat(user, "<span class='alert'>Cookie Synthesizer hacked.</span>")
	else
		toxin = 0
		to_chat(user, "<span class='notice'>Cookie Synthesizer reset.</span>")

/obj/item/rsf/cookiesynth/process()
	if(matter < 10)
		matter++

/obj/item/rsf/cookiesynth/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(cooldown > world.time)
		return
	if(!proximity)
		return
	if (!(istype(A, /obj/structure/table) || isfloorturf(A)))
		return
	if(matter < 1)
		to_chat(user, "<span class='warning'>[src] doesn't have enough matter left. Wait for it to recharge!</span>")
		return
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		if(!R.cell || R.cell.charge < 400)
			to_chat(user, "<span class='warning'>You do not have enough power to use [src].</span>")
			return
	var/turf/T = get_turf(A)
	playsound(src.loc, 'sound/machines/click.ogg', 10, TRUE)
	to_chat(user, "<span class='notice'>Fabricating Cookie...</span>")
	var/obj/item/reagent_containers/food/snacks/cookie/S = new /obj/item/reagent_containers/food/snacks/cookie(T)
	if(toxin)
		S.reagents.add_reagent(/datum/reagent/toxin/chloralhydrate, 10)
	if (iscyborg(user))
		var/mob/living/silicon/robot/R = user
		R.cell.charge -= 100
	else
		matter--
	cooldown = world.time + cooldowndelay
