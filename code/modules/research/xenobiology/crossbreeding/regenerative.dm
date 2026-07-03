/*
Regenerative extracts:
	Work like a legion regenerative core.
	Has a unique additional effect.
*/
/obj/item/slimecross/regenerative
	name = "regenerative extract"
	desc = "Он наполнен молочной субстанцией и пульсирует как бьющееся сердце."
	effect = "regenerative"
	icon_state = "regenerative"
	effect_desc = "Частично лечит твои ранения без дополнительных эффектов."

/obj/item/slimecross/regenerative/proc/core_effect(mob/living/carbon/human/target, mob/user)
	return
/obj/item/slimecross/regenerative/proc/core_effect_before(mob/living/carbon/human/target, mob/user)
	return

/obj/item/slimecross/regenerative/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		return
	var/mob/living/H = interacting_with
	if(H.stat == DEAD)
		to_chat(user, span_warning("[src.declent_ru(NOMINATIVE)] не сработает на мёртвых!"))
		return ITEM_INTERACT_BLOCKING
	if(H != user)
		user.visible_message(span_notice("[user.declent_ru(NOMINATIVE)] раздавливает [src.declent_ru(ACCUSATIVE)] над [H.declent_ru(INSTRUMENTAL)], молочная слизь быстро заживляет часть [H.ru_p_them()] ранений!"),
			span_notice("Вы раздавливаете [src.declent_ru(ACCUSATIVE)] и он лопается над [H.declent_ru(INSTRUMENTAL)], молочная слизь быстро заживляет часть [H.ru_p_them()] ранений."))
	else
		user.visible_message(span_notice("[user.declent_ru(NOMINATIVE)] раздавливает [src.declent_ru(ACCUSATIVE)] над собой, молочная слизь быстро заживляет часть [user.ru_p_them()] ранений!"),
			span_notice("Вы раздавливаете [src.declent_ru(ACCUSATIVE)] и он лопается в вашей руке, покрывая вас молочной слизью, которая быстро заживляет ваши ранения!"))
	core_effect_before(H, user)
	user.do_attack_animation(interacting_with)
	// BANDASTATION EDIT START
	var/list/extract_reagents = list(
		/datum/reagent/medicine/c2/helbital = 3,
		/datum/reagent/medicine/c2/lenturi = 4,
		/datum/reagent/medicine/c2/tirimol = 5,
	)
	extract_reagents += isjellyperson(H) ? list(/datum/reagent/toxin/amanitin = 7) :  list(/datum/reagent/medicine/c2/multiver = 15)
	if(H.reagents)
		H.reagents.add_reagent_list(extract_reagents)
	else
		H.adjust_brute_loss(-25)
		H.adjust_fire_loss(-25)
		H.adjust_tox_loss(-25)
	// BANDASTATION EDIT END
	core_effect(H, user)
	playsound(H, 'sound/effects/splat.ogg', 40, TRUE)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/item/slimecross/regenerative/grey
	colour = SLIME_TYPE_GREY //Has no bonus effect.
	effect_desc = "Частично лечит цель и больше ничего не делает."

/obj/item/slimecross/regenerative/orange
	colour = SLIME_TYPE_ORANGE

/obj/item/slimecross/regenerative/orange/core_effect_before(mob/living/target, mob/user)
	target.visible_message(span_warning("[src.declent_ru(NOMINATIVE)] закипает!"))
	for(var/turf/targetturf in RANGE_TURFS(1,target))
		if(!locate(/obj/effect/hotspot) in targetturf)
			new /obj/effect/hotspot(targetturf)

/obj/item/slimecross/regenerative/purple
	colour = SLIME_TYPE_PURPLE
	effect_desc = "Частично лечит цель и вводит ей немного регенеративного желе."

/obj/item/slimecross/regenerative/purple/core_effect(mob/living/target, mob/user)
	target.reagents.add_reagent(/datum/reagent/medicine/regen_jelly,10)

/obj/item/slimecross/regenerative/blue
	colour = SLIME_TYPE_BLUE
	effect_desc = "Частично лечит цель и делает пол мокрым."

/obj/item/slimecross/regenerative/blue/core_effect(mob/living/target, mob/user)
	if(isturf(target.loc))
		var/turf/open/T = get_turf(target)
		T.MakeSlippery(TURF_WET_WATER, min_wet_time = 10, wet_time_to_add = 5)
		target.visible_message(span_warning("Молочное желе из экстракта разливается на пол!"))

/obj/item/slimecross/regenerative/metal
	colour = SLIME_TYPE_METAL
	effect_desc = "Частично лечит цель и заключает её в шкаф."

/obj/item/slimecross/regenerative/metal/core_effect(mob/living/target, mob/user)
	target.visible_message(span_warning("The milky goo hardens and reshapes itself, encasing [target]!"))
	var/obj/structure/closet/C = new /obj/structure/closet(target.loc)
	C.name = "slimy closet"
	C.desc = "Если присмотреться, [C.ru_p_they()] выглядит сделанным из какого-то цельного, прозрачного, металлоподобного желе."
	if(target.mob_size > C.max_mob_size) //Prevents capturing megafauna or other large mobs in the closets
		C.bust_open()
		C.visible_message(span_warning("[target] is too big, and immediately breaks \the [C.name] open!"))
	else //This can't be allowed to actually happen to the too-big mobs or it breaks some actions
		target.forceMove(C)

/obj/item/slimecross/regenerative/yellow
	colour = SLIME_TYPE_YELLOW
	effect_desc = "Частично лечит цель и полностью перезаряжает один предмет у неё."

/obj/item/slimecross/regenerative/yellow/core_effect(mob/living/target, mob/user)
	var/list/batteries = list()
	for(var/obj/item/stock_parts/power_store/cell in assoc_to_values(target.get_all_cells()))
		if(cell.charge < cell.maxcharge)
			batteries += cell
	if(batteries.len)
		var/obj/item/stock_parts/power_store/ToCharge = pick(batteries)
		ToCharge.charge = ToCharge.maxcharge
		to_chat(target, span_notice("Ты чувствуешь странный электрический импульс, один из твоих электрических приборов перезарядился."))

/obj/item/slimecross/regenerative/darkpurple
	colour = SLIME_TYPE_DARK_PURPLE
	effect_desc = "Частично лечит цель и ей фиолетовую одежду, если она голая."

/obj/item/slimecross/regenerative/darkpurple/core_effect(mob/living/target, mob/user)
	var/equipped = 0
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/purple(null), ITEM_SLOT_FEET)
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(null), ITEM_SLOT_ICLOTHING)
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/purple(null), ITEM_SLOT_GLOVES)
	equipped += target.equip_to_slot_or_del(new /obj/item/clothing/head/soft/purple(null), ITEM_SLOT_HEAD)
	if(equipped > 0)
		target.visible_message(span_notice("Молочное желе застывает в виде одежды!"))

/obj/item/slimecross/regenerative/darkblue
	colour = SLIME_TYPE_DARK_BLUE
	effect_desc = "Частично лечит цель и защищает её одежду от огня."

/obj/item/slimecross/regenerative/darkblue/core_effect(mob/living/target, mob/user)
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
		target.visible_message(span_notice("Часть одежды [target.declent_ru(ACCUSATIVE)] покрывается желе и становится синей!"))

/obj/item/slimecross/regenerative/darkblue/proc/fireproof(obj/item/clothing/clothing_piece)
	clothing_piece.name = "fireproofed [clothing_piece.name]"
	clothing_piece.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	clothing_piece.add_atom_colour(color_transition_filter(COLOR_NAVY, SATURATION_OVERRIDE), FIXED_COLOUR_PRIORITY)
	clothing_piece.max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	clothing_piece.heat_protection = clothing_piece.body_parts_covered
	clothing_piece.resistance_flags |= FIRE_PROOF

/obj/item/slimecross/regenerative/silver
	colour = SLIME_TYPE_SILVER
	effect_desc = "Частично лечит цель и делает её живот круглым и полным."

/obj/item/slimecross/regenerative/silver/core_effect(mob/living/target, mob/user)
	target.set_nutrition(NUTRITION_LEVEL_FULL - 1)
	to_chat(target, span_notice("Ты чувствуешь себя сытым."))

/obj/item/slimecross/regenerative/bluespace
	colour = SLIME_TYPE_BLUESPACE
	effect_desc = "Частично лечит цель и телепортирует её на место создания этого ядра."
	var/turf/open/T

/obj/item/slimecross/regenerative/bluespace/core_effect(mob/living/target, mob/user)
	var/turf/old_location = get_turf(target)
	if(do_teleport(target, T, channel = TELEPORT_CHANNEL_QUANTUM)) //despite being named a bluespace teleportation method the quantum channel is used to preserve precision teleporting with a bag of holding
		old_location.visible_message(span_warning("[target.declent_ru(NOMINATIVE)] испаряется в столпе искр!"))
		to_chat(target, span_danger("Молочное желе телепортирует тебя в запомненное место!"))

	if(HAS_TRAIT(target, TRAIT_NO_TELEPORT))
		old_location.visible_message(span_warning("[target.declent_ru(NOMINATIVE)] немного искрит, но не может телепортироваться!"))

/obj/item/slimecross/regenerative/bluespace/Initialize(mapload)
	. = ..()
	T = get_turf(src)

/obj/item/slimecross/regenerative/sepia
	colour = SLIME_TYPE_SEPIA
	effect_desc = "Частично лечит цель. Через 10 секунд перемещает цель на изначальную позицию, где ядро было использовано с их предыдущими жизненными показателями."

/obj/item/slimecross/regenerative/sepia/core_effect_before(mob/living/target, mob/user)
	to_chat(target, span_notice("Ты пытаешься забыть где ты находился."))
	target.AddComponent(/datum/component/dejavu)

/obj/item/slimecross/regenerative/cerulean
	colour = SLIME_TYPE_CERULEAN
	effect_desc = "Частично лечит цель и создаёт второе регенеративное ядро без особых эффектов."

/obj/item/slimecross/regenerative/cerulean/core_effect(mob/living/target, mob/user)
	src.forceMove(user.loc)
	var/obj/item/slimecross/X = new /obj/item/slimecross/regenerative(user.loc)
	X.name = name
	X.desc = desc
	user.put_in_active_hand(X)
	to_chat(user, span_notice("Часть молочного желе застывает в твоих руках!"))

/obj/item/slimecross/regenerative/pyrite
	colour = SLIME_TYPE_PYRITE
	effect_desc = "Частично лечит и случайно перекрашивает цель."

/obj/item/slimecross/regenerative/pyrite/core_effect(mob/living/target, mob/user)
	target.visible_message(span_warning("Молочное желе покрывает [target.declent_ru(ACCUSATIVE)], перекрашивая [target.ru_p_them()] в другой цвет!"))
	target.add_atom_colour(color_transition_filter(rgb(rand(0,255), rand(0,255), rand(0,255)), SATURATION_OVERRIDE), WASHABLE_COLOUR_PRIORITY)

/obj/item/slimecross/regenerative/red
	colour = SLIME_TYPE_RED
	effect_desc = "Частично лечит цель и вводит ей немного эфедрина."

/obj/item/slimecross/regenerative/red/core_effect(mob/living/target, mob/user)
	to_chat(target, span_notice("Ты чувствуешь себя... <i>быстрее.</i>"))
	target.reagents.add_reagent(/datum/reagent/medicine/ephedrine,3)

/obj/item/slimecross/regenerative/green
	colour = SLIME_TYPE_GREEN
	effect_desc = "Частично лечит цель и изменяет вид или цвет слайма или слаймперсоны."

/obj/item/slimecross/regenerative/green/core_effect(mob/living/target, mob/user)
	if(isslime(target))
		target.visible_message(span_warning("[target.declent_ru(NOMINATIVE)] внезапно меняет цвет!"))
		var/mob/living/basic/slime/target_slime = target
		target_slime.set_slime_type()
	if(isjellyperson(target))
		target.reagents.add_reagent(/datum/reagent/mutationtoxin/jelly,5)

/obj/item/slimecross/regenerative/pink
	colour = SLIME_TYPE_PINK
	effect_desc = "Частично лечит цель и вводит ей немного крокодила."

/obj/item/slimecross/regenerative/pink/core_effect(mob/living/target, mob/user)
	to_chat(target, span_notice("You feel more calm."))
	target.reagents.add_reagent(/datum/reagent/drug/krokodil,4)

/obj/item/slimecross/regenerative/gold
	colour = SLIME_TYPE_GOLD
	effect_desc = "Частично лечит цель и производит случайную монету."

/obj/item/slimecross/regenerative/gold/core_effect(mob/living/target, mob/user)
	var/newcoin = get_random_coin()
	var/obj/item/coin/C = new newcoin(target.loc)
	playsound(C, 'sound/items/coinflip.ogg', 50, TRUE)
	target.put_in_hand(C)

/obj/item/slimecross/regenerative/oil
	colour = SLIME_TYPE_OIL
	effect_desc = "Частично лечит цель и ослепляет всех в зоне видимости."

/obj/item/slimecross/regenerative/oil/core_effect(mob/living/target, mob/user)
	playsound(src, 'sound/items/weapons/flash.ogg', 100, TRUE)
	for(var/mob/living/L in view(user,7))
		L.flash_act()

/obj/item/slimecross/regenerative/black
	colour = SLIME_TYPE_BLACK
	effect_desc = "Частично лечит цель и создаёт её неидеальную копию созданную из желе, которая инсценирует её смерть."

/obj/item/slimecross/regenerative/black/core_effect_before(mob/living/target, mob/user)
	var/dummytype = target.type
	// BANDASTATION EDIT: clone fix
	if((target.mob_biotypes & MOB_SPECIAL) || !iscarbon(target)) //Prevents megafauna and voidwalker duping in a lame way
		dummytype = /mob/living/basic/slime
		to_chat(user, span_warning("Молочное желе обтекает по [target.declent_ru(DATIVE)], стекая в маленькую лужицу."))
	var/mob/living/dummy = new dummytype(target.loc)
	to_chat(target, span_notice("Молочное желе обтекает по тебе, формируя неидеальную копию тебя."))
	if(iscarbon(target) && iscarbon(dummy))
		var/mob/living/carbon/carbon_target = target
		var/mob/living/carbon/carbon_dummy = dummy
		carbon_dummy.real_name = carbon_target.real_name
		carbon_target.dna.copy_dna(carbon_dummy.dna, COPY_DNA_SE|COPY_DNA_SPECIES)
		carbon_dummy.updateappearance(mutcolor_update = TRUE)
	dummy.adjust_brute_loss(target.get_brute_loss())
	dummy.adjust_fire_loss(target.get_fire_loss())
	dummy.adjust_tox_loss(target.get_tox_loss())
	dummy.death()

/obj/item/slimecross/regenerative/lightpink
	colour = SLIME_TYPE_LIGHT_PINK
	effect_desc = "Частично лечит цель и владельца."

/obj/item/slimecross/regenerative/lightpink/core_effect(mob/living/target, mob/user)
	if(!isliving(user))
		return
	if(target == user)
		return
	var/mob/living/U = user
	U.revive(HEAL_ALL & ~HEAL_REFRESH_ORGANS)
	to_chat(U, span_notice("Часть молочного желе попадает так же и на тебя!"))

/obj/item/slimecross/regenerative/adamantine
	colour = SLIME_TYPE_ADAMANTINE
	effect_desc = "Частично лечит цель и усиливает её броню."

/obj/item/slimecross/regenerative/adamantine/core_effect(mob/living/target, mob/user) //WIP - Find out why this doesn't work.
	target.apply_status_effect(/datum/status_effect/slimeskin)

/obj/item/slimecross/regenerative/rainbow
	colour = SLIME_TYPE_RAINBOW
	effect_desc = "Частично лечит цель и временно делает её бессмертной, но пацифистичной."

/obj/item/slimecross/regenerative/rainbow/core_effect(mob/living/target, mob/user)
	target.apply_status_effect(/datum/status_effect/rainbow_protection)
