#define REGENERATIVE_EXTRACT_TOX_HEAL_AMOUNT -60
#define REGENERATIVE_EXTRACT_PHYSICAL_HEAL_AMOUNT -40
#define REGENERATIVE_EXTRACT_OXY_HEAL_AMOUNT -400
#define REGENERATIVE_EXTRACT_ORGAN_HEAL_AMOUNT -25

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

	var/static/list/bodypart_replacement_table = list(
		/obj/item/bodypart/arm/right = /obj/item/bodypart/arm/right/slime,
		/obj/item/bodypart/arm/left = /obj/item/bodypart/arm/left/slime,
		/obj/item/bodypart/leg/right = /obj/item/bodypart/leg/right/slime,
		/obj/item/bodypart/leg/left = /obj/item/bodypart/leg/left/slime,
		/obj/item/bodypart/head = /obj/item/bodypart/head/slime,
		/obj/item/bodypart/chest = /obj/item/bodypart/chest/slime,
	)

/obj/item/slimecross/regenerative/proc/core_effect(mob/living/target, mob/user)
	var/visible_message = "[user] crushes [src] over [target], the milky goo quickly regenerating all of [target.p_their()] injuries!"
	var/self_message = "You squeeze [src], and it bursts over [target], the milky goo regenerating [target.p_their()] injuries."

	var/obj/item/bodypart/type_to_instantiate
	var/obj/item/bodypart/targetted_part
	if (ishuman(target))
		var/mob/living/carbon/human/human_target = target
		targetted_part = get_bodypart_to_replace(user, human_target)

		if (!bodypart_valid_for_healing(targetted_part, user, target))
			return FALSE

		for (var/obj/item/bodypart/iterated_typepath as anything in bodypart_replacement_table)
			if (istype(targetted_part, iterated_typepath))
				type_to_instantiate = bodypart_replacement_table[iterated_typepath]
				break

		if(human_target != user)
			visible_message = "[user] crushes [src] over [human_target], the milky goo enveloping [human_target.p_their()] [targetted_part.name] and perfecting it into slime!"
			self_message = "You crush [src] over [human_target], the milky goo enveloping [human_target.p_their()] [targetted_part.name] and perfecting it into slime!"
		else
			visible_message = "[user] crushes [src] over [user.p_them()]self, the milky goo enveloping [user.p_their()] [targetted_part.name] and perfecting it into slime!"
			self_message = "You crush [src] over yourself, the milky goo enveloping your [targetted_part.name] and perfecting it into slime!"

		user.visible_message(span_notice(visible_message), span_notice(self_message))

	do_healing(target, user, type_to_instantiate, targetted_part)

	return TRUE

/obj/item/slimecross/regenerative/proc/get_bodypart_to_replace(mob/living/user, mob/living/carbon/human/target)
	var/obj/item/bodypart/targetted_part = target.get_bodypart(user.zone_selected)
	return targetted_part

/obj/item/slimecross/regenerative/proc/do_healing(mob/living/target, mob/user, obj/item/bodypart/type_to_instantiate, obj/item/bodypart/targetted_part)
	if (ishuman(target) && !isnull(type_to_instantiate))
		var/obj/item/bodypart/slime_bodypart = new type_to_instantiate()
		slime_bodypart.replace_limb(target, special = TRUE)
		qdel(targetted_part)

		perform_limb_specific_healing(slime_bodypart, target)

	var/tox_heal_amount = REGENERATIVE_EXTRACT_TOX_HEAL_AMOUNT
	if (HAS_TRAIT(target, TRAIT_TOXINLOVER))
		tox_heal_amount = -tox_heal_amount
	target.adjustToxLoss(tox_heal_amount)

	target.adjustBruteLoss(REGENERATIVE_EXTRACT_PHYSICAL_HEAL_AMOUNT)
	target.adjustFireLoss(REGENERATIVE_EXTRACT_PHYSICAL_HEAL_AMOUNT)
	target.adjustOxyLoss(REGENERATIVE_EXTRACT_OXY_HEAL_AMOUNT)

/obj/item/slimecross/regenerative/afterattack(atom/target, mob/user, prox)
	. = ..()
	if(!prox || !isliving(target))
		return
	var/mob/living/living_target = target
	if (!core_effect(living_target, user))
		return
	playsound(living_target, 'sound/effects/splat.ogg', 40, TRUE)
	qdel(src)

/obj/item/slimecross/regenerative/proc/bodypart_valid_for_healing(obj/item/bodypart/bodypart_to_check, mob/living/user, mob/living/carbon/human/target, silent = FALSE)
	if (isnull(bodypart_to_check) || isnull(target))
		return FALSE

	for (var/obj/item/clothing/iter_clothing as anything in target.get_clothing_on_part(bodypart_to_check))
		if (iter_clothing.clothing_flags & THICKMATERIAL)
			if (!silent)
				to_chat(user, span_warning("The clothing on [target.p_their()] [bodypart_to_check] is too thick!"))
			return FALSE

	if (bodypart_to_check.limb_id == SPECIES_SLIMEPERSON)
		if (!silent)
			var/their_or_your = (target == user ? "Your" : "[target.p_Their()]")
			to_chat(user, span_warning("[their_or_your] [bodypart_to_check.name] is already slimey! [src] will have no effect!"))
		return FALSE

	return TRUE

/obj/item/slimecross/regenerative/proc/perform_limb_specific_healing(obj/item/bodypart/bodypart_to_heal, mob/living/carbon/target)
	for (var/obj/item/organ/iterated_organ as anything in bodypart_to_heal.get_organs())
		iterated_organ.apply_organ_damage(REGENERATIVE_EXTRACT_ORGAN_HEAL_AMOUNT)
		if (istype(iterated_organ, /obj/item/organ/internal/brain))
			var/obj/item/organ/internal/brain/found_brain = iterated_organ
			found_brain.cure_all_traumas(TRAUMA_RESILIENCE_LOBOTOMY)

	if (istype(bodypart_to_heal, /obj/item/bodypart/chest))
		target.fully_heal(HEAL_TEMP|HEAL_BLOOD|HEAL_NEGATIVE_DISEASES|HEAL_NEGATIVE_MUTATIONS|HEAL_ALL_REAGENTS)
		target.reagents.add_reagent(/datum/reagent/toxin/plasma, 9)

/obj/item/slimecross/regenerative/grey
	colour = SLIME_TYPE_GREY //Has no bonus effect.
	effect_desc = "Fully heals the target and does nothing else."

/obj/item/slimecross/regenerative/orange
	colour = SLIME_TYPE_ORANGE

/obj/item/slimecross/regenerative/orange/core_effect(mob/living/target, mob/user)
	. = ..()
	if (!.)
		return FALSE

	target.visible_message(span_warning("The [src] boils over!"))
	for(var/turf/targetturf in RANGE_TURFS(1,target))
		if(!locate(/obj/effect/hotspot) in targetturf)
			new /obj/effect/hotspot(targetturf)

/obj/item/slimecross/regenerative/purple
	colour = SLIME_TYPE_PURPLE
	effect_desc = "Fully heals the target and injects them with some regen jelly."

/obj/item/slimecross/regenerative/purple/core_effect(mob/living/target, mob/user)
	. = ..()
	if (!.)
		return FALSE

	target.reagents.add_reagent(/datum/reagent/medicine/regen_jelly,10)

/obj/item/slimecross/regenerative/blue
	colour = SLIME_TYPE_BLUE
	effect_desc = "Fully heals the target and makes the floor wet."

/obj/item/slimecross/regenerative/blue/core_effect(mob/living/target, mob/user)
	. = ..()
	if (!.)
		return FALSE

	if(isturf(target.loc))
		var/turf/open/T = get_turf(target)
		T.MakeSlippery(TURF_WET_WATER, min_wet_time = 10, wet_time_to_add = 5)
		target.visible_message(span_warning("The milky goo in the extract gets all over the floor!"))

/obj/item/slimecross/regenerative/metal
	colour = SLIME_TYPE_METAL
	effect_desc = "Fully heals the target and encases the target in a locker."

/obj/item/slimecross/regenerative/metal/core_effect(mob/living/target, mob/user)
	. = ..()
	if (!.)
		return FALSE

	target.visible_message(span_warning("The milky goo hardens and reshapes itself, encasing [target]!"))
	var/obj/structure/closet/C = new /obj/structure/closet(target.loc)
	C.name = "slimy closet"
	C.desc = "Looking closer, it seems to be made of a sort of solid, opaque, metal-like goo."
	target.forceMove(C)

/obj/item/slimecross/regenerative/yellow
	colour = SLIME_TYPE_YELLOW
	effect_desc = "Fully heals the target and fully recharges a single item on the target."

/obj/item/slimecross/regenerative/yellow/core_effect(mob/living/target, mob/user)
	. = ..()
	if (!.)
		return FALSE

	var/list/batteries = list()
	for(var/obj/item/stock_parts/cell/C in target.get_all_contents())
		if(C.charge < C.maxcharge)
			batteries += C
	if(batteries.len)
		var/obj/item/stock_parts/cell/ToCharge = pick(batteries)
		ToCharge.charge = ToCharge.maxcharge
		to_chat(target, span_notice("You feel a strange electrical pulse, and one of your electrical items was recharged."))

/obj/item/slimecross/regenerative/darkpurple
	colour = SLIME_TYPE_DARK_PURPLE
	effect_desc = "Fully heals the target and gives them purple clothing if they are naked."

/obj/item/slimecross/regenerative/darkpurple/core_effect(mob/living/target, mob/user)
	. = ..()
	if (!.)
		return FALSE

	var/equipped = 0
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/purple(null), ITEM_SLOT_FEET)
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(null), ITEM_SLOT_ICLOTHING)
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/purple(null), ITEM_SLOT_GLOVES)
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/head/soft/purple(null), ITEM_SLOT_HEAD)
	if(equipped > 0)
		target.visible_message(span_notice("The milky goo congeals into clothing!"))

/obj/item/slimecross/regenerative/darkblue
	colour = SLIME_TYPE_DARK_BLUE
	effect_desc = "Fully heals the target and fireproofs their clothes."

/obj/item/slimecross/regenerative/darkblue/core_effect(mob/living/target, mob/user)
	. = ..()
	if (!.)
		return FALSE

	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	var/fireproofed = FALSE
	if(H.get_item_by_slot(ITEM_SLOT_OCLOTHING))
		fireproofed = TRUE
		var/obj/item/clothing/C = H.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		fireproof(C)
	if(H.get_item_by_slot(ITEM_SLOT_HEAD))
		fireproofed = TRUE
		var/obj/item/clothing/C = H.get_item_by_slot(ITEM_SLOT_HEAD)
		fireproof(C)
	if(fireproofed)
		target.visible_message(span_notice("Some of [target]'s clothing gets coated in the goo, and turns blue!"))

/obj/item/slimecross/regenerative/darkblue/proc/fireproof(obj/item/clothing/C)
	C.name = "fireproofed [C.name]"
	C.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	C.add_atom_colour("#000080", FIXED_COLOUR_PRIORITY)
	C.max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	C.heat_protection = C.body_parts_covered
	C.resistance_flags |= FIRE_PROOF

/obj/item/slimecross/regenerative/silver
	colour = SLIME_TYPE_SILVER
	effect_desc = "Fully heals the target and makes their belly feel round and full."

/obj/item/slimecross/regenerative/silver/core_effect(mob/living/target, mob/user)
	. = ..()
	if (!.)
		return FALSE

	target.set_nutrition(NUTRITION_LEVEL_FULL - 1)
	to_chat(target, span_notice("You feel satiated."))

/obj/item/slimecross/regenerative/bluespace
	colour = SLIME_TYPE_BLUESPACE
	effect_desc = "Fully heals the target and teleports them to where this core was created."
	var/turf/open/T

/obj/item/slimecross/regenerative/bluespace/core_effect(mob/living/target, mob/user)
	. = ..()
	if (!.)
		return FALSE

	var/turf/old_location = get_turf(target)
	if(do_teleport(target, T, channel = TELEPORT_CHANNEL_QUANTUM)) //despite being named a bluespace teleportation method the quantum channel is used to preserve precision teleporting with a bag of holding
		old_location.visible_message(span_warning("[target] disappears in a shower of sparks!"))
		to_chat(target, span_danger("The milky goo teleports you somewhere it remembers!"))


/obj/item/slimecross/regenerative/bluespace/Initialize(mapload)
	. = ..()
	T = get_turf(src)

/obj/item/slimecross/regenerative/sepia
	colour = SLIME_TYPE_SEPIA
	effect_desc = "Fully heals the target. After 10 seconds, relocate the target to the initial position the core was used with their previous health status."

/obj/item/slimecross/regenerative/sepia/core_effect(mob/living/target, mob/user)
	. = ..()
	if (!.)
		return FALSE

	to_chat(target, span_notice("You try to forget how you feel."))
	target.AddComponent(/datum/component/dejavu)

/obj/item/slimecross/regenerative/cerulean
	colour = SLIME_TYPE_CERULEAN
	effect_desc = "Fully heals the target and makes a second regenerative core with no special effects."

/obj/item/slimecross/regenerative/cerulean/core_effect(mob/living/target, mob/user)
	. = ..()
	if (!.)
		return FALSE

	src.forceMove(user.loc)
	var/obj/item/slimecross/X = new /obj/item/slimecross/regenerative(user.loc)
	X.name = name
	X.desc = desc
	user.put_in_active_hand(X)
	to_chat(user, span_notice("Some of the milky goo congeals in your hand!"))

/obj/item/slimecross/regenerative/pyrite
	colour = SLIME_TYPE_PYRITE
	effect_desc = "Fully heals and randomly colors the target."

/obj/item/slimecross/regenerative/pyrite/core_effect(mob/living/target, mob/user)
	. = ..()
	if (!.)
		return FALSE

	target.visible_message(span_warning("The milky goo coating [target] leaves [target.p_them()] a different color!"))
	target.add_atom_colour(rgb(rand(0,255),rand(0,255),rand(0,255)),WASHABLE_COLOUR_PRIORITY)

/obj/item/slimecross/regenerative/red
	colour = SLIME_TYPE_RED
	effect_desc = "Fully heals the target and injects them with some ephedrine."

/obj/item/slimecross/regenerative/red/core_effect(mob/living/target, mob/user)
	. = ..()
	if (!.)
		return FALSE

	to_chat(target, span_notice("You feel... <i>faster.</i>"))
	target.reagents.add_reagent(/datum/reagent/medicine/ephedrine,3)

/obj/item/slimecross/regenerative/green
	colour = SLIME_TYPE_GREEN
	effect_desc = "Fully heals the target and changes the spieces or color of a slime or jellyperson."

/obj/item/slimecross/regenerative/green/core_effect(mob/living/target, mob/user)
	. = ..()
	if (!.)
		return FALSE

	if(isslime(target))
		target.visible_message(span_warning("The [target] suddenly changes color!"))
		var/mob/living/simple_animal/slime/S = target
		S.random_colour()
	if(isjellyperson(target))
		target.reagents.add_reagent(/datum/reagent/mutationtoxin/jelly,5)

/obj/item/slimecross/regenerative/pink
	colour = SLIME_TYPE_PINK
	effect_desc = "Fully heals the target and injects them with some krokodil."

/obj/item/slimecross/regenerative/pink/core_effect(mob/living/target, mob/user)
	. = ..()
	if (!.)
		return FALSE

	to_chat(target, span_notice("You feel more calm."))
	target.reagents.add_reagent(/datum/reagent/drug/krokodil,4)

/obj/item/slimecross/regenerative/gold
	colour = SLIME_TYPE_GOLD
	effect_desc = "Fully heals the target and produces a random coin."

/obj/item/slimecross/regenerative/gold/core_effect(mob/living/target, mob/user)
	. = ..()
	if (!.)
		return FALSE

	var/newcoin = get_random_coin()
	var/obj/item/coin/C = new newcoin(target.loc)
	playsound(C, 'sound/items/coinflip.ogg', 50, TRUE)
	target.put_in_hand(C)

/obj/item/slimecross/regenerative/oil
	colour = SLIME_TYPE_OIL
	effect_desc = "Fully heals the target and flashes everyone in sight."

/obj/item/slimecross/regenerative/oil/core_effect(mob/living/target, mob/user)
	. = ..()
	if (!.)
		return FALSE

	playsound(src, 'sound/weapons/flash.ogg', 100, TRUE)
	for(var/mob/living/L in view(user,7))
		L.flash_act()

/obj/item/slimecross/regenerative/black
	colour = SLIME_TYPE_BLACK
	effect_desc = "Fully heals the target and creates an imperfect duplicate of them made of slime, that fakes their death."

/obj/item/slimecross/regenerative/black/core_effect(mob/living/target, mob/user)
	. = ..()
	if (!.)
		return FALSE

	var/dummytype = target.type
	if(ismegafauna(target)) //Prevents megafauna duping in a lame way
		dummytype = /mob/living/simple_animal/slime
		to_chat(user, span_warning("The milky goo flows over [target], falling into a weak puddle."))
	var/mob/living/dummy = new dummytype(target.loc)
	to_chat(target, span_notice("The milky goo flows from your skin, forming an imperfect copy of you."))
	if(iscarbon(target))
		var/mob/living/carbon/T = target
		var/mob/living/carbon/D = dummy
		T.dna.transfer_identity(D)
		D.updateappearance(mutcolor_update=1)
		D.real_name = T.real_name
	dummy.adjustBruteLoss(target.getBruteLoss())
	dummy.adjustFireLoss(target.getFireLoss())
	dummy.adjustToxLoss(target.getToxLoss())
	dummy.death()

/obj/item/slimecross/regenerative/lightpink
	colour = SLIME_TYPE_LIGHT_PINK
	effect_desc = "Fully heals the target and also heals the user."

/obj/item/slimecross/regenerative/lightpink/core_effect(mob/living/target, mob/user)
	. = ..()
	if (!.)
		return FALSE

	if(!isliving(user))
		return
	if(target == user)
		return
	if (ishuman(user))
		var/obj/item/bodypart/type_to_instantiate
		var/mob/living/carbon/human/human_user = user
		var/obj/item/bodypart/targetted_part = get_bodypart_to_replace(user, human_user)

		if (bodypart_valid_for_healing(targetted_part, user, target, silent = TRUE))
			for (var/obj/item/bodypart/iterated_typepath as anything in bodypart_replacement_table)
				if (istype(targetted_part, iterated_typepath))
					type_to_instantiate = bodypart_replacement_table[iterated_typepath]
					break

		if (!isnull(type_to_instantiate))
			to_chat(user, span_notice("Some of the milky goo sprays onto you, as well!"))
			do_healing(user, user, type_to_instantiate, targetted_part)

/obj/item/slimecross/regenerative/adamantine
	colour = SLIME_TYPE_ADAMANTINE
	effect_desc = "Fully heals the target and boosts their armor."

/obj/item/slimecross/regenerative/adamantine/core_effect(mob/living/target, mob/user) //WIP - Find out why this doesn't work.
	. = ..()
	if (!.)
		return FALSE

	target.apply_status_effect(/datum/status_effect/slimeskin)

/obj/item/slimecross/regenerative/rainbow
	colour = SLIME_TYPE_RAINBOW
	effect_desc = "Fully heals the target and temporarily makes them immortal, but pacifistic."

/obj/item/slimecross/regenerative/rainbow/core_effect(mob/living/target, mob/user)
	. = ..()
	if (!.)
		return FALSE

	target.apply_status_effect(/datum/status_effect/rainbow_protection)

#undef REGENERATIVE_EXTRACT_TOX_HEAL_AMOUNT
#undef REGENERATIVE_EXTRACT_PHYSICAL_HEAL_AMOUNT
#undef REGENERATIVE_EXTRACT_OXY_HEAL_AMOUNT
#undef REGENERATIVE_EXTRACT_ORGAN_HEAL_AMOUNT
