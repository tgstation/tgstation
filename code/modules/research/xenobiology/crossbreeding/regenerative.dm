/*
Regenerative extracts:
	Work like a legion regenerative core.
	Has a unique additional effect.
*/
/obj/item/slimecross/regenerative
	name = "regenerative extract"
	desc = "It's filled with a milky substance, and pulses like a heartbeat."
	effect = "regenerative"
	icon_state = "regenerative"

/obj/item/slimecross/regenerative/proc/core_effect(mob/living/carbon/human/target, mob/user)
	return
/obj/item/slimecross/regenerative/proc/core_effect_before(mob/living/carbon/human/target, mob/user)
	return


/obj/item/slimecross/regenerative/afterattack(atom/target,mob/user,prox)
	. = ..()
	if(!prox || !isliving(target))
		return
	var/mob/living/H = target
	if(H.stat == DEAD)
		to_chat(user, "<span class='warning'>[src] will not work on the dead!</span>")
		return
	if(H != user)
		user.visible_message("<span class='notice'>[user] crushes the [src] over [H], the milky goo quickly regenerating all of [H.p_their()] injuries!</span>",
			"<span class='notice'>You squeeze the [src], and it bursts over [H], the milky goo regenerating [H.p_their()] injuries.</span>")
	else
		user.visible_message("<span class='notice'>[user] crushes the [src] over [user.p_them()]self, the milky goo quickly regenerating all of [user.p_their()] injuries!</span>",
			"<span class='notice'>You squeeze the [src], and it bursts in your hand, splashing you with milky goo which quickly regenerates your injuries!</span>")
	core_effect_before(H, user)
	H.revive(full_heal = 1)
	core_effect(H, user)
	playsound(target, 'sound/effects/splat.ogg', 40, 1)
	qdel(src)

/obj/item/slimecross/regenerative/grey
	colour = "grey" //Has no bonus effect.

/obj/item/slimecross/regenerative/orange
	colour = "orange"

/obj/item/slimecross/regenerative/orange/core_effect_before(mob/living/target, mob/user)
	target.visible_message("<span class='warning'>The [src] boils over!</span>")
	for(var/turf/turf in range(1,target))
		if(!locate(/obj/effect/hotspot) in turf)
			new /obj/effect/hotspot(turf)

/obj/item/slimecross/regenerative/purple
	colour = "purple"

/obj/item/slimecross/regenerative/purple/core_effect(mob/living/target, mob/user)
	target.reagents.add_reagent("regen_jelly",10)

/obj/item/slimecross/regenerative/blue
	colour = "blue"

/obj/item/slimecross/regenerative/blue/core_effect(mob/living/target, mob/user)
	if(isturf(target.loc))
		var/turf/open/T = get_turf(target)
		T.MakeSlippery(TURF_WET_WATER, min_wet_time = 10, wet_time_to_add = 5)
		target.visible_message("<span class='warning'>The milky goo in the extract gets all over the floor!</span>")

/obj/item/slimecross/regenerative/metal
	colour = "metal"

/obj/item/slimecross/regenerative/metal/core_effect(mob/living/target, mob/user)
	target.visible_message("<span class='warning'>The milky goo hardens and reshapes itself, encasing [target]!</span>")
	var/obj/structure/closet/C = new /obj/structure/closet(target.loc)
	C.name = "slimy closet"
	C.desc = "Looking closer, it seems to be made of a sort of solid, opaque, metal-like goo."
	target.forceMove(C)

/obj/item/slimecross/regenerative/yellow
	colour = "yellow"

/obj/item/slimecross/regenerative/yellow/core_effect(mob/living/target, mob/user)
	var/list/batteries = list()
	for(var/obj/item/stock_parts/cell/C in target.GetAllContents())
		if(C.charge < C.maxcharge)
			batteries += C
	if(batteries.len)
		var/obj/item/stock_parts/cell/ToCharge = pick(batteries)
		ToCharge.charge = ToCharge.maxcharge
		to_chat(target, "<span class='notice'>You feel a strange electrical pulse, and one of your electrical items was recharged.</span>")

/obj/item/slimecross/regenerative/darkpurple
	colour = "dark purple"

/obj/item/slimecross/regenerative/darkpurple/core_effect(mob/living/target, mob/user)
	var/equipped = 0
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/purple(null), SLOT_SHOES)
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(null), SLOT_W_UNIFORM)
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/purple(null), SLOT_GLOVES)
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/head/soft/purple(null), SLOT_HEAD)
	if(equipped > 0)
		target.visible_message("<span class='notice'>The milky goo congeals into clothing!</span>")

/obj/item/slimecross/regenerative/darkblue
	colour = "dark blue"

/obj/item/slimecross/regenerative/darkblue/core_effect(mob/living/target, mob/user)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	var/fireproofed = FALSE
	if(H.get_item_by_slot(SLOT_WEAR_SUIT))
		fireproofed = TRUE
		var/obj/item/clothing/C = H.get_item_by_slot(SLOT_WEAR_SUIT)
		fireproof(C)
	if(H.get_item_by_slot(SLOT_HEAD))
		fireproofed = TRUE
		var/obj/item/clothing/C = H.get_item_by_slot(SLOT_HEAD)
		fireproof(C)
	if(fireproofed)
		target.visible_message("<span class='notice'>Some of [target]'s clothing gets coated in the goo, and turns blue!</span>")

/obj/item/slimecross/regenerative/darkblue/proc/fireproof(obj/item/clothing/C)
	C.name = "fireproofed [C.name]"
	C.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	C.add_atom_colour("#000080", FIXED_COLOUR_PRIORITY)
	C.max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	C.heat_protection = C.body_parts_covered
	C.resistance_flags |= FIRE_PROOF

/obj/item/slimecross/regenerative/silver
	colour = "silver"

/obj/item/slimecross/regenerative/silver/core_effect(mob/living/target, mob/user)
	target.nutrition = NUTRITION_LEVEL_FULL - 1
	to_chat(target, "<span class='notice'>You feel satiated.</span>")

/obj/item/slimecross/regenerative/bluespace
	colour = "bluespace"
	var/turf/open/T

/obj/item/slimecross/regenerative/bluespace/core_effect(mob/living/target, mob/user)
	target.visible_message("<span class='warning'>[src] disappears in a shower of sparks!</span>","<span class='danger'>The milky goo teleports you somewhere it remembers!</span>")
	do_sparks(5,FALSE,target)
	target.forceMove(T)
	do_sparks(5,FALSE,target)

/obj/item/slimecross/regenerative/bluespace/Initialize()
	. = ..()
	T = get_turf(src)

/obj/item/slimecross/regenerative/sepia
	colour = "sepia"

/obj/item/slimecross/regenerative/sepia/core_effect(mob/living/target, mob/user)
	new /obj/effect/timestop(get_turf(target), 2, 50, list(user,target))

/obj/item/slimecross/regenerative/cerulean
	colour = "cerulean"

/obj/item/slimecross/regenerative/cerulean/core_effect(mob/living/target, mob/user)
	src.forceMove(user.loc)
	var/obj/item/slimecross/X = new /obj/item/slimecross/regenerative(user.loc)
	X.name = name
	X.desc = desc
	user.put_in_active_hand(X)
	to_chat(user, "<span class='notice'>Some of the milky goo congeals in your hand!</span>")

/obj/item/slimecross/regenerative/pyrite
	colour = "pyrite"

/obj/item/slimecross/regenerative/pyrite/core_effect(mob/living/target, mob/user)
	target.visible_message("<span class='warning'>The milky goo coating [target] leaves [target.p_them()] a different color!</span>")
	target.add_atom_colour(rgb(rand(0,255),rand(0,255),rand(0,255)),WASHABLE_COLOUR_PRIORITY)

/obj/item/slimecross/regenerative/red
	colour = "red"

/obj/item/slimecross/regenerative/red/core_effect(mob/living/target, mob/user)
	to_chat(target, "<span class='notice'>You feel... <i>faster.</i></span>")
	target.reagents.add_reagent("ephedrine",3)

/obj/item/slimecross/regenerative/green
	colour = "green"

/obj/item/slimecross/regenerative/green/core_effect(mob/living/target, mob/user)
	if(isslime(target))
		target.visible_message("<span class='warning'>The [target] suddenly changes color!</span>")
		var/mob/living/simple_animal/slime/S = target
		S.random_colour()
	if(isjellyperson(target))
		target.reagents.add_reagent("slime_toxin",5)


/obj/item/slimecross/regenerative/pink
	colour = "pink"

/obj/item/slimecross/regenerative/pink/core_effect(mob/living/target, mob/user)
	to_chat(target, "<span class='notice'>You feel more calm.</span>")
	target.reagents.add_reagent("krokodil",4)

/obj/item/slimecross/regenerative/gold
	colour = "gold"

/obj/item/slimecross/regenerative/gold/core_effect(mob/living/target, mob/user)
	var/newcoin = pick(/obj/item/coin/silver, /obj/item/coin/iron, /obj/item/coin/gold, /obj/item/coin/diamond, /obj/item/coin/plasma, /obj/item/coin/uranium)
	var/obj/item/coin/C = new newcoin(target.loc)
	playsound(C, 'sound/items/coinflip.ogg', 50, 1)
	target.put_in_hand(C)

/obj/item/slimecross/regenerative/oil
	colour = "oil"

/obj/item/slimecross/regenerative/oil/core_effect(mob/living/target, mob/user)
	playsound(src, 'sound/weapons/flash.ogg', 100, 1)
	for(var/mob/living/L in view(user,7))
		L.flash_act()

/obj/item/slimecross/regenerative/black
	colour = "black"

/obj/item/slimecross/regenerative/black/core_effect_before(mob/living/target, mob/user)
	var/dummytype = target.type
	var/mob/living/dummy = new dummytype(target.loc)
	to_chat(target, "<span class='notice'>The milky goo flows from your skin, forming an imperfect copy of you.</span>")
	if(iscarbon(target))
		var/mob/living/carbon/T = target
		var/mob/living/carbon/D = dummy
		T.dna.transfer_identity(D)
		D.updateappearance(mutcolor_update=1)
		D.real_name = T.real_name
	dummy.adjustBruteLoss(target.getBruteLoss())
	dummy.adjustFireLoss(target.getFireLoss())
	dummy.adjustToxLoss(target.getToxLoss())
	dummy.adjustOxyLoss(200)

/obj/item/slimecross/regenerative/lightpink
	colour = "light pink"

/obj/item/slimecross/regenerative/lightpink/core_effect(mob/living/target, mob/user)
	if(!isliving(user))
		return
	if(target == user)
		return
	var/mob/living/U = user
	U.revive(full_heal = 1)
	to_chat(U, "<span class='notice'>Some of the milky goo sprays onto you, as well!</span>")

/obj/item/slimecross/regenerative/adamantine
	colour = "adamantine"

/obj/item/slimecross/regenerative/adamantine/core_effect(mob/living/target, mob/user) //WIP - Find out why this doesn't work.
	target.apply_status_effect(STATUS_EFFECT_SLIMESKIN)

/obj/item/slimecross/regenerative/rainbow
	colour = "rainbow"

/obj/item/slimecross/regenerative/rainbow/core_effect(mob/living/target, mob/user)
	target.apply_status_effect(STATUS_EFFECT_RAINBOWPROTECTION)