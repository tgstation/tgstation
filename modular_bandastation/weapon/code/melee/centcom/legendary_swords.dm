#define LEGENDARY_SWORDS_CKEY_WHITELIST list("mooniverse")

/obj/item/dualsaber/legendary_saber
	name = "Malice"
	desc = "\"Злоба\" - один из легендарных энергетических мечей Галактики. Словно источая мистическую энергию, \"Злоба\" является олицетворением самой Тьмы, вызывающей трепет и ужас врагов её владельца. Гладкая и простая рукоять меча не может похвастаться орнаментами, узорами или древними рунами, но способна выплескивать рванный энергетический клинок кроваво-красного света, словно кричащий о непокорности и ярости своего владельца.  Некоторые истории гласят, что в этом клинке прибывает сама темная сущность могущества и бесконечного гнева, готовая исполнить волю своего хозяина даже за пределами пространства и времени. \n Создатель: Согда К'Трим. Текущий владелец: Миднайт Блэк."
	icon = 'modular_bandastation/weapon/icons/melee/legendary.dmi'
	lefthand_file = 'modular_bandastation/weapon/icons/melee/inhands/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/melee/inhands/righthand.dmi'
	icon_state = "mid_dualsaber0"
	inhand_icon_state = "mid_dualsaber0"
	saber_color = "midnight"
	light_color = LIGHT_COLOR_INTENSE_RED
	hit_wield = 'modular_bandastation/weapon/sound/melee/mid_saberhit.ogg'
	var/wieldsound = 'modular_bandastation/weapon/sound/melee/mid_saberon.ogg'
	var/unwieldsound = 'modular_bandastation/weapon/sound/melee/mid_saberoff.ogg'
	var/saber_name = "mid"
	var/ranged = FALSE
	var/power = 1
	var/refusal_text = "Злоба неподвластна твоей воле, усмрить её сможет лишь сильнейший."
	var/datum/enchantment/enchant
	possible_colors = null
	block_chance = 88
	two_hand_force = 35
	attack_speed = CLICK_CD_RAGE_MELEE
	bypass_nodrop = TRUE

/obj/item/dualsaber/legendary_saber/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ckey_and_role_locked_pickup, TRUE, LEGENDARY_SWORDS_CKEY_WHITELIST, pickup_damage = 10, refusal_text = refusal_text)
	var/datum/component/two_handed/th = src.GetComponent(/datum/component/two_handed)
	th.wieldsound = wieldsound
	th.unwieldsound = unwieldsound
	src.add_enchantment(new/datum/enchantment/dash())

/obj/item/dualsaber/legendary_saber/update_icon_state()
	. = ..()
	icon_state = inhand_icon_state = HAS_TRAIT(src, TRAIT_WIELDED) ? "[saber_name]_dualsaber[saber_color][HAS_TRAIT(src, TRAIT_WIELDED)]" : "[saber_name]_dualsaber0"

/obj/item/dualsaber/legendary_saber/sorrow_catcher
	name = "Sorrow Catcher"
	desc = "\"Ловец  Скорби\" -  один из легендарных энергетических мечей Галактики. \
	Согласно легенде, предсмертные крики тех, кого сразило это оружие вырываются при каждой его активации, создавая специфических \"плачущий\" звук. "
	icon_state = "gr_dualsaber0"
	inhand_icon_state  = "gr_dualsaber0"
	saber_color = "gromov"
	refusal_text = "Ну, заплачь."
	light_color = LIGHT_COLOR_LIGHT_CYAN
	saber_name = "gr"
	wieldsound = 'modular_bandastation/weapon/sound/melee/gr_saberon.ogg'
	unwieldsound = 'modular_bandastation/weapon/sound/melee/gr_saberoff.ogg'
	hit_wield = 'modular_bandastation/weapon/sound/melee/gr_saberhit.ogg'

/obj/item/dualsaber/legendary_saber/flame
	name = "Flame"
	desc = "\"Пламя\" - один из легендарных энергетических мечей Галактики. \
	Согласно легенде, этот меч - оружие завоевателей и праведников, долго время являвшийся фамильной реликвией одного знатного Эллизианского дома."
	icon_state = "sh_dualsaber0"
	inhand_icon_state = "sh_dualsaber0"
	saber_color = "sharlotta"
	refusal_text = "Кровь и свет принадлежат лишь одному."
	light_color = LIGHT_COLOR_LAVENDER
	saber_name = "sh"
	wieldsound = 'modular_bandastation/weapon/sound/melee/sh_saberon.ogg'
	unwieldsound = 'modular_bandastation/weapon/sound/melee/sh_saberoff.ogg'
	hit_wield = 'modular_bandastation/weapon/sound/melee/sh_saberhit.ogg'

/obj/item/dualsaber/legendary_saber/devotion
	name = "Oath's Fidelity"
	desc = "\"Верность Клятве\" - один из легендарных энергетических мечей Галактики. \
	В настоящий момент утерян."
	icon_state = "kir_dualsaber0"
	inhand_icon_state = "kir_dualsaber0"
	saber_color = "kirien"
	refusal_text = "Только достойный узрит свет."
	light_color = LIGHT_COLOR_VIVID_GREEN
	saber_name = "kir"
	wieldsound = 'modular_bandastation/weapon/sound/melee/kir_saberon.ogg'
	unwieldsound = 'modular_bandastation/weapon/sound/melee/kir_saberoff.ogg'
	hit_wield = 'modular_bandastation/weapon/sound/melee/kir_saberhit.ogg'

/obj/item/dualsaber/legendary_saber/sister
	name = "Light Sister"
	desc = "\"Светлая Сестра\" - один из легендарных энергетических мечей Галактики. \
	Согласно легенде, этот элегантный меч был создан для одного из лидеров Синдиката прошлого, что по иронии судьбы была им же и убита."
	icon_state = "norm_dualsaber0"
	inhand_icon_state = "norm_dualsaber0"
	saber_color = "normandy"
	refusal_text = "Ты не принадлежишь сестре, верни её законному владельцу."
	light_color = LIGHT_COLOR_HOLY_MAGIC
	saber_name = "norm"
	wieldsound = 'modular_bandastation/weapon/sound/melee/norm_saberon.ogg'
	unwieldsound = 'modular_bandastation/weapon/sound/melee/norm_saberoff.ogg'
	hit_wield = 'modular_bandastation/weapon/sound/melee/norm_saberhit.ogg'

/obj/item/dualsaber/legendary_saber/flee_catcher
	name = "Flee Catcher"
	desc = "\"Ловец Бегущих\" - один из легендарных энергетических мечей Галактики. \
	Согласно легенде, это потрепанное временем оружие есть страшная кара всех беглецов и предателей, всегда находящая цель."
	icon_state = "kel_dualsaber0"
	inhand_icon_state = "kel_dualsaber0"
	saber_color = "kelly"
	refusal_text = "Ловец бегущих не слушается тебя, кажется он хочет вернуться к хозяину."
	light_color = LIGHT_COLOR_HOLY_MAGIC
	saber_name = "kel"
	wieldsound = 'modular_bandastation/weapon/sound/melee/kel_saberon.ogg'
	unwieldsound = 'modular_bandastation/weapon/sound/melee/kel_saberoff.ogg'
	hit_wield = 'modular_bandastation/weapon/sound/melee/kel_saberhit.ogg'

/obj/item/dualsaber/legendary_saber/bsword
	name = "Sunderer"
	desc = "\"Рассекающий\" — легендарный двуручный меч, покрытый напылением из разрушенного энергетического кристалла. Согласно легенде, кузнец стремился создать меч, который убивает не изяществом, а неизбежностью."
	icon_state = "hel_dualsaber0"
	inhand_icon_state = "hel_dualsaber0"
	worn_icon = 'modular_bandastation/weapon/icons/melee/melee_back.dmi'
	saber_color = "kirien"
	refusal_text = "Только достойный узрит свет."
	light_color = LIGHT_COLOR_VIVID_GREEN
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	saber_name = "hel"
	wieldsound = 'modular_bandastation/weapon/sound/melee/kir_saberon.ogg'
	unwieldsound = 'modular_bandastation/weapon/sound/melee/kir_saberoff.ogg'
	hit_wield = 'modular_bandastation/weapon/sound/melee/kir_saberhit.ogg'

/obj/item/dualsaber/legendary_saber/orphan
	name = "Orphan"
	desc = "\"Сирота\" -  один из легендарных энергетических мечей Галактики. \
	Элегантное на вид, но вселяющее ужас орудие неизвестного происхождения."
	icon_state = "lex_dualsaber0"
	inhand_icon_state = "lex_dualsaber0"
	saber_color = "lebel"
	refusal_text = "Сироте ты не хозяин."
	light_color = COLOR_AMMO_INCENDIARY
	saber_name = "lex"
	wieldsound = 'modular_bandastation/weapon/sound/melee/lex_saberon.ogg'
	unwieldsound = 'modular_bandastation/weapon/sound/melee/lex_saberoff.ogg'
	hit_wield = 'modular_bandastation/weapon/sound/melee/lex_saberhit.ogg'

/obj/item/dualsaber/legendary_saber/pre_attack(atom/A, mob/living/user, params)
	var/charged = FALSE
	var/proximity = get_proximity(A, user)
	if(isliving(A))
		charged = enchant?.on_legendary_hit(A, usr, proximity, src)
	if(!proximity && !charged)
		return COMPONENT_SKIP_ATTACK
	return ..()

/obj/item/dualsaber/legendary_saber/proc/add_enchantment(datum/enchantment/E)
	enchant = E
	enchant.on_gain(src)
	enchant.power *= power
	for(var/path in enchant.actions_types)
		add_item_action(path)
	enchant.actions_types = null

/obj/item/dualsaber/legendary_saber/proc/get_proximity(atom/A, mob/living/user)
	reach = 1
	var/proximity = A.IsReachableBy(user)
	reach = enchant.range
	return proximity

/datum/enchantment/dash
	name = "Рывок"
	desc = "Этот клинок несёт владельца прямо к цели. Никто не уйдёт."
	ranged = TRUE
	range = 5
	actions_types = list(/datum/action/item_action/legendary_saber/rage)
	var/movespeed = 0.8
	var/on_leap_cooldown = FALSE
	var/charging = FALSE
	var/anim_time = 3 DECISECONDS
	var/anim_loop = 3 DECISECONDS
	var/rage_dashes = 7

/datum/enchantment/proc/on_legendary_hit(mob/living/target, mob/living/user, proximity, obj/item/dualsaber/legendary_saber/S)
	if(world.time < cooldown)
		return FALSE
	if(!istype(target))
		return FALSE
	if(target.stat == DEAD)
		return FALSE
	if(!ranged && !proximity)
		return FALSE
	cooldown = world.time + initial(cooldown)
	return TRUE

/datum/enchantment/dash/on_legendary_hit(mob/living/target, mob/living/user, proximity, obj/item/dualsaber/legendary_saber/S)
	if(proximity || !HAS_TRAIT(S, TRAIT_WIELDED)) // don't put it on cooldown if adjacent
		return FALSE
	. = ..()
	if(!.)
		return FALSE
	return charge(user, target, S)

/datum/enchantment/dash/proc/charge(mob/living/user, atom/chargeat, obj/item/dualsaber/legendary_saber/S)
	if(on_leap_cooldown)
		return FALSE
	if(!chargeat)
		return FALSE
	var/turf/destination_turf  = get_turf(chargeat)
	if(!destination_turf)
		return FALSE
	charging = TRUE
	S.block_chance = 100
	var/obj/effect/temp_visual/decoy/D = new /obj/effect/temp_visual/decoy(user.loc, user)
	animate(D, alpha = 0, color = "#271e77", transform = matrix()*1, time = anim_time, loop = anim_loop)
	var/i
	for(i=0, i<5, i++)
		spawn(i * 9 MILLISECONDS)
			step_to(user, destination_turf , 1, movespeed)
			var/obj/effect/temp_visual/decoy/D2 = new /obj/effect/temp_visual/decoy(user.loc, user)
			animate(D2, alpha = 0, color = "#271e77", transform = matrix()*1, time = anim_time, loop = anim_loop)

	spawn(45 MILLISECONDS)
		if(get_dist(user, destination_turf) > 1)
			charging = FALSE
		S.block_chance = initial(S.block_chance)
	if(!charging)
		return FALSE
	return charge_end(user, S)

/datum/enchantment/dash/proc/charge_end(mob/living/user, obj/item/dualsaber/legendary_saber/S)
	charging = FALSE
	user.apply_damage(10, STAMINA)
	return TRUE

/datum/action/item_action/legendary_saber/rage
	name = "Swordsman Rage"

/datum/action/item_action/legendary_saber/rage/Trigger(trigger_flags)
	. = ..()
	var/log_message = "[usr.name] triggered [name]"
	log_combat(log_message)
	message_admins(log_message)
	var/mob/living/user = usr
	var/obj/item/dualsaber/legendary_saber/S = src.target
	var/list/mob/living/charged_targets = list(user)
	var/datum/enchantment/dash/dash = S.enchant
	var/mob/range_center = user
	for(var/count in 1 to dash.rage_dashes)
		var/mob/living/target
		for(var/turf/T in RANGE_TURFS(3, range_center))
			for(var/mob/living/L in T.contents)
				if(!(L in charged_targets))
					target = L
					charged_targets += L
					if(!do_after(user, 5 DECISECONDS, target, IGNORE_USER_LOC_CHANGE | IGNORE_TARGET_LOC_CHANGE))
						target = null
					break
			if(target)
				break
		if(!target)
			break
		S.melee_attack_chain(user, target)
		range_center = target
	return
