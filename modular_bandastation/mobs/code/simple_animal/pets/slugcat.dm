// TODO - существа из слайм экстрактов + питомец в ксенобиологию

// /mob/living/basic/pet/slugcat
// 	name = "слизнекот"
// 	desc = "Удивительное существо, напоминающая кота и слизня в одном обличии. Но это не слизь, а иной вид существа. Гордость ксенобиологии. Крайне ловкое и умное, родом с планеты с опасной средой обитания. Обожает копья, не стоит давать ему его в лапки. На нем отлично смотрятся шляпы."
// 	icon = 'modular_bandastation/mobs/icons/pets.dmi'
// 	icon_state = "slugcat"
// 	icon_living = "slugcat"
// 	icon_dead = "slugcat_dead"
// 	icon_resting = "slugcat_rest"
// 	speak = list("Furrr.","Uhh.", "Hurrr.")
// 	gender = MALE
// 	turns_per_move = 5
// 	see_in_dark = 8
// 	health = 100
// 	maxHealth = 100
// 	blood_volume = BLOOD_VOLUME_NORMAL
// 	melee_damage_type = STAMINA
// 	melee_damage_lower = 0
// 	melee_damage_upper = 0
// 	attack_verb_continuous = "бьет"
// 	attack_verb_simple = "бьет"
// 	mob_size = MOB_SIZE_SMALL
// 	pass_flags = PASSTABLE
// 	butcher_results = list(/obj/item/food/meat = 5)
// 	response_help_continuous = "pets"
// 	response_help_simple = "pets"
// 	response_disarm_continuous = "gently pushes aside"
// 	response_disarm_simple = "gently pushes aside"
// 	response_harm_continuous = "kicks"
// 	response_harm_simple = "kicks"
// 	gold_core_spawnable = FRIENDLY_SPAWN
// 	footstep_type = FOOTSTEP_MOB_SLIME
// 	faction = list("slime","neutral")
// 	//holder_type = /obj/item/holder/cat2

// 	//Шляпы для слизнекота!
// 	var/obj/item/inventory_head
// 	var/obj/item/inventory_hand

// 	var/hat_offset_y = -8
// 	var/hat_offset_y_rest = -19
// 	var/hat_icon_file = 'icons/mob/clothing/head.dmi'
// 	var/hat_icon_state
// 	var/hat_alpha
// 	var/hat_color

// 	var/is_pacifist = FALSE
// 	var/is_reduce_damage = TRUE

// 	///icon state of the collar we can wear
// 	var/collar_icon_state

// /mob/living/basic/pet/slugcat/Initialize(mapload)
// 	. = ..()
// 	AddElement(/datum/element/wears_collar, collar_icon_state = collar_icon_state)
// 	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

// /mob/living/basic/pet/slugcat/monk
// 	name = "слизнекот-монах"
// 	desc = "Удивительное существо, напоминающая кота и слизня в одном обличии. Но это не слизь, а иной вид существа. Гордость ксенобиологии. Крайне ловкое и умное, родом с планеты с опасной средой обитания. Не любит охоту и не умеет пользоваться копьями. На нем отлично смотрятся шляпы."
// 	icon_state = "slugcat_monk"
// 	icon_living = "slugcat_monk"
// 	icon_dead = "slugcat_monk_dead"
// 	icon_resting = "slugcat_monk_rest"
// 	is_pacifist = TRUE
// 	gold_core_spawnable = FRIENDLY_SPAWN
// 	health = 80
// 	maxHealth = 80

// /mob/living/basic/pet/slugcat/hunter
// 	name = "слизнекот-охотник"
// 	desc = "Удивительное существо, напоминающая кота и слизня в одном обличии. Но это не слизь, а иной вид существа. Гордость ксенобиологии. Крайне ловкое и умное, родом с планеты с опасной средой обитания. Обожает копья и умело управляется ими, не стоит давать ему его в лапки. На нем отлично смотрятся шляпы."
// 	icon_state = "slugcat_hunter"
// 	icon_living = "slugcat_hunter"
// 	icon_dead = "slugcat_hunter_dead"
// 	icon_resting = "slugcat_hunter_rest"
// 	is_pacifist = FALSE
// 	is_reduce_damage = FALSE
// 	faction = list("slime","neutral","hostile")
// 	gold_core_spawnable = HOSTILE_SPAWN
// 	health = 150
// 	maxHealth = 150

// /mob/living/basic/pet/slugcat/gold	//for admins
// 	name = "золотой слизнекот"
// 	desc = "Уникальный золотой слизнекот полученный чудотворным путём."
// 	icon_state = "slugcat_gold"
// 	icon_living = "slugcat_gold"
// 	icon_dead = "slugcat_gold_dead"
// 	icon_resting = "slugcat_gold_rest"
// 	is_pacifist = FALSE
// 	is_reduce_damage = FALSE
// 	gold_core_spawnable = NO_SPAWN
// 	health = 300
// 	maxHealth = 300

// /mob/living/basic/pet/slugcat/New()
// 	..()
// 	regenerate_icons()


// /mob/living/basic/pet/slugcat/attackby__legacy__attackchain(obj/item/W, mob/user, params)
// 	if(stat != DEAD)
// 		if(istype(W, /obj/item/clothing/head) && user.a_intent == INTENT_HELP)
// 			place_on_head(user.get_active_hand(), user)
// 			return
// 		if(istype(W, /obj/item/spear) && user.a_intent != INTENT_HARM)
// 			place_to_hand(user.get_active_hand(), user)
// 			return

// 	. = ..()

// /mob/living/basic/pet/slugcat/death(gibbed)
// 	drop_hat()
// 	drop_hand()
// 	. = ..()

// /mob/living/basic/pet/slugcat/regenerate_icons()
// 	overlays.Cut()
// 	..()

// 	if(inventory_hand)
// 		if(istype(inventory_hand, /obj/item/spear))
// 			speared()

// 	if(inventory_head)
// 		var/image/head_icon

// 		if(!hat_icon_state)
// 			hat_icon_state = inventory_head.icon_state
// 		if(!hat_alpha)
// 			hat_alpha = inventory_head.alpha
// 		if(!hat_color)
// 			hat_color = inventory_head.color

// 		head_icon = get_hat_overlay()

// 		add_overlay(head_icon)

// /mob/living/basic/pet/slugcat/on_lying_down(updating = 1)
// 	if(inventory_head || inventory_hand)
// 		hat_offset_y = hat_offset_y_rest
// 		drop_hand()
// 		regenerate_icons()
// 	. = ..()

// /mob/living/basic/pet/slugcat/on_standing_up(updating = 1)
// 	if(inventory_head)
// 		hat_offset_y = initial(hat_offset_y)
// 		regenerate_icons()
// 	. = ..()

// /mob/living/basic/pet/slugcat/proc/speared()
// 	icon_state = "[initial(icon_state)]_spear"

// 	var/obj/item/spear/spear = inventory_hand

// 	attack_verb_continuous = "бьет копьем"
// 	attack_verb_simple = "бьет копьем"
// 	attack_sound = 'sound/weapons/bladeslice.ogg'
// 	melee_damage_type = BRUTE
// 	melee_damage_lower = round(spear.force_unwielded / (is_reduce_damage ? 2 : 1))
// 	melee_damage_upper = round(spear.force_wielded / (is_reduce_damage ? 2 : 1))
// 	obj_damage = spear.force

// /mob/living/basic/pet/slugcat/proc/unspeared()
// 	icon_state = initial(icon_state)
// 	attack_verb_continuous = initial(attack_verb_simple)
// 	attack_sound = initial(attack_sound)
// 	melee_damage_type = initial(melee_damage_type)
// 	melee_damage_lower = initial(melee_damage_lower)
// 	melee_damage_upper = initial(melee_damage_upper)
// 	obj_damage = initial(obj_damage)

// /mob/living/basic/pet/slugcat/proc/get_hat_overlay()
// 	if(hat_icon_file && hat_icon_state)
// 		var/image/slugI = image(hat_icon_file, hat_icon_state)
// 		slugI.alpha = hat_alpha
// 		slugI.color = hat_color
// 		slugI.pixel_y = hat_offset_y
// 		//slugI.transform = matrix(1, 0, 1, 0, 1, 0)
// 		return slugI

// /mob/living/basic/pet/slugcat/proc/place_on_head(obj/item/item_to_add, mob/user)
// 	if(!item_to_add)
// 		user.visible_message(
// 			span_notice("[user] похлопывает по голове [src.name]."),
// 			span_notice("Вы положили руку на голову [src.name]."))
// 		if(flags_2 & HOLOGRAM_2)
// 			return 0
// 		return 0

// 	if(!istype(item_to_add, /obj/item/clothing/head))
// 		to_chat(user, span_warning("[item_to_add.name] нельзя надеть на голову [src.name]!"))
// 		return 0

// 	if(inventory_head)
// 		if(user)
// 			to_chat(user, span_warning("Нельзя надеть больше одного головного убора на голову [src.name]!"))
// 		return 0

// 	if(user && !user.unEquip(item_to_add))
// 		to_chat(user, span_warning("[item_to_add.name] застрял в ваших руках, вы не можете его надеть на голову [src.name]!"))
// 		return 0

// 	user.visible_message(
// 		span_notice("[user] надевает [item_to_add].name на голову [real_name]."),
// 		span_notice("Вы надеваете [item_to_add.name] на голову [real_name]."),
// 		span_italics("Вы слышите как что-то нацепили."))
// 	item_to_add.forceMove(src)
// 	inventory_head = item_to_add
// 	regenerate_icons()

// 	return 1

// /mob/living/basic/pet/slugcat/proc/remove_from_head(mob/user)
// 	if(inventory_head)
// 		if(inventory_head.flags & NODROP)
// 			to_chat(user, span_warning("[inventory_head.name] застрял на голове [src.name]! Его невозможно снять!"))
// 			return TRUE

// 		to_chat(user, span_warning("Вы сняли [inventory_head.name] с головы [src.name]."))
// 		drop_item(inventory_head)
// 		user.put_in_hands(inventory_head)

// 		null_hat()

// 		regenerate_icons()
// 	else
// 		to_chat(user, span_warning("На голове [src.name] нет головного убора!"))
// 		return FALSE

// 	return TRUE

// /mob/living/basic/pet/slugcat/proc/drop_hat()
// 	if(inventory_head)
// 		drop_item(inventory_head)
// 		null_hat()
// 		regenerate_icons()

// /mob/living/basic/pet/slugcat/proc/null_hat()
// 	inventory_head = null
// 	hat_icon_state = null
// 	hat_alpha = null
// 	hat_color = null

// /mob/living/basic/pet/slugcat/proc/place_to_hand(obj/item/item_to_add, mob/user)
// 	if(!item_to_add)
// 		user.visible_message(
// 			span_notice("[user] пощупал лапки [src]."),
// 			span_notice("Вы пощупали лапки [src]."))
// 		if(flags_2 & HOLOGRAM_2)
// 			return 0
// 		return 0

// 	if(resting)
// 		to_chat(user, span_warning("[src.name] спит и не принимает [item_to_add.name]!"))
// 		return 0

// 	if(!istype(item_to_add, /obj/item/spear))
// 		to_chat(user, span_warning("[src.name] не принимает [item_to_add.name]!"))
// 		return 0

// 	if(inventory_hand)
// 		if(user)
// 			to_chat(user, span_warning("Лапки [src.name] заняты [inventory_hand.name]!"))
// 		return 0

// 	if(user && !user.drop_item(item_to_add))
// 		to_chat(user, span_warning("[item_to_add.name] застрял в ваших руках, вы не можете его дать [src.name]!"))
// 		return 0

// 	if(is_pacifist)
// 		to_chat(user, span_warning("[src.name] пацифист и не пользуется [item_to_add.name]!"))
// 		return 0

// 	user.visible_message(
// 		span_notice("[real_name] выхватывает [item_to_add] с рук [user]."),
// 		span_notice("[real_name] выхватывает [item_to_add] с ваших рук."),
// 		span_italics("Вы видите довольные глаза."))
// 	move_item_to_hand(item_to_add)

// 	return 1

// /mob/living/basic/pet/slugcat/proc/move_item_to_hand(obj/item/item_to_add)
// 	item_to_add.forceMove(src)
// 	inventory_hand = item_to_add
// 	regenerate_icons()

// /mob/living/basic/pet/slugcat/proc/remove_from_hand(mob/user)
// 	if(inventory_hand)
// 		if(inventory_hand.flags & NODROP)
// 			to_chat(user, span_warning("[inventory_hand.name] застрял в лапах [src]! Его невозможно отнять!"))
// 			return TRUE

// 		to_chat(user, span_warning("Вы забрали [inventory_hand.name] с лап [src]."))
// 		drop_item(inventory_hand)
// 		user.put_in_hands(inventory_hand)

// 		null_hand()

// 		regenerate_icons()
// 	else
// 		to_chat(user, span_warning("В лапах [src] нечего отбирать!"))
// 		return FALSE

// 	return TRUE

// /mob/living/basic/pet/slugcat/proc/drop_hand()
// 	if(inventory_hand)
// 		drop_item(inventory_hand)
// 		null_hand()
// 		regenerate_icons()

// /mob/living/basic/pet/slugcat/proc/null_hand()
// 	unspeared()
// 	inventory_hand = null
