/datum/heretic_knowledge_tree_column/ash
	route = PATH_ASH
	ui_bgr = "node_ash"
	complexity = "Низкая"
	complexity_color = COLOR_GREEN
	icon = list(
		"icon" = 'icons/obj/weapons/khopesh.dmi',
		"state" = "ash_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	description = list(
		"Путь Пепла завязан на огне, подвижности и беспощадном контроле над одиночными противниками.",
		"Выбирайте этот путь, если вы начинающий еретик или вам нравится стиль игры «бей и беги».",
	)
	pros = list(
		"Очень силен, даже в начале своего пути.",
		"Легкий доступ к заклинаниям передвижения и расширенному зрению.",
		"Очень мощный эффект от метки.",
	)
	cons = list(
		"Обладает меньшей силой, чем большинство еретиков, за исключением их начальных способностей.",
		"Недостаточно устойчив в затяжных противостояниях.",
		"Полагается на быстрые и мощные удары, прежде чем его противники успеют принять надлежащие контрмеры.",
	)
	tips = list(
		"«Хватка Мансуса» накладывает короткую слепоту и метку, которая при срабатывании вашего клинка наносит противнику критический урон по выносливости. Метка может распространяться на ближайших противников.",
		"Выбирая этот путь, вы станете невосприимчивы к высоким температурам. Однако помните, что ваша одежда всё равно может сгореть! Если вы хотите защитить себя от собственного огня, наденьте Выжженную мантию.",
		"Ваша Выжженная мантия будет генерировать огненные заряды на вашем теле (убедитесь, что вы включили этот эффект!). При достижении 5 огненных зарядов ваши пепельные заклинания станут сильнее (об этом будет свидетельствовать выделение заклинаний зеленым цветом).",
		"«Пепельный проход» имеет короткое время перезарядки и способно снимать оковы. При усилении оно даёт более длительный сдвиг, а также снимает оглушение и критический урон по выносливости.",
		"«Взрыв вулкана» может быстро расправиться с вашими врагами, если они будут настолько глупы, что соберутся вместе. Если усилить эту способность, она не будет требовать времени на применение и будет генерировать в два раза больше огненных зарядов. Сожги язычников до пепла!",
		"Не пренебрегайте маской Безумия. Она будет медленно истощать силы ваших врагов и вызывать у них галлюцинации.",
		"Постарайтесь поджечь как можно больше врагов! «Перерождение Ночного Дозорного» исцелит вас, а время восстановления умения сократится в зависимости от того, сколько существ вы поглотили.",
		"Ваше вознесение даёт вам полную неуязвимость к опасностям окружающей среды, включая бомбы! Но вы по-прежнему уязвимы для более традиционного оружия. Не будьте слишком самоуверенны.",
	)

	start = /datum/heretic_knowledge/limited_amount/starting/base_ash
	knowledge_tier1 = /datum/heretic_knowledge/spell/ash_passage
	guaranteed_side_tier1 = /datum/heretic_knowledge/medallion
	knowledge_tier2 = /datum/heretic_knowledge/spell/fire_blast
	guaranteed_side_tier2 = /datum/heretic_knowledge/rifle
	robes = /datum/heretic_knowledge/armor/ash
	knowledge_tier3 = /datum/heretic_knowledge/mad_mask
	guaranteed_side_tier3 = /datum/heretic_knowledge/summon/ashy
	blade = /datum/heretic_knowledge/blade_upgrade/ash
	knowledge_tier4 = /datum/heretic_knowledge/spell/flame_birth
	ascension = /datum/heretic_knowledge/ultimate/ash_final

/datum/heretic_knowledge/limited_amount/starting/base_ash
	name = "Секрет Ночного Дозорного"
	desc = "Открывает перед вами путь пепла. \
		Позволяет трансмутировать спичку и нож в Пепельный клинок. \
		Одновременно можно иметь только два."
	gain_text = "Городская стража знает своих дозорных. Если вы спросите их ночью, они могут рассказать вам о пепельном фонаре."
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/item/match = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/ash)
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "ash_blade"
	mark_type = /datum/status_effect/eldritch/ash
	eldritch_passive = /datum/status_effect/heretic_passive/ash

/datum/heretic_knowledge/limited_amount/starting/base_ash/on_mansus_grasp(mob/living/source, mob/living/target)
	. = ..()

	if(target.is_blind())
		return

	if(!target.get_organ_slot(ORGAN_SLOT_EYES))
		return

	to_chat(target, span_danger("Яркий зеленый свет ужасно жжет глаза!"))
	target.adjust_organ_loss(ORGAN_SLOT_EYES, 15)
	target.set_eye_blur_if_lower(20 SECONDS)

/datum/heretic_knowledge/limited_amount/starting/base_ash/trigger_mark(mob/living/source, mob/living/target)
	. = ..()
	if(!.)
		return

	// Also refunds 75% of charge!
	var/datum/action/cooldown/spell/touch/mansus_grasp/grasp = locate() in source.actions
	if(grasp)
		grasp.next_use_time -= round(grasp.cooldown_time*0.75)
		grasp.build_all_button_icons()

/datum/heretic_knowledge/spell/ash_passage
	name = "Пепельный проход"
	desc = "Дарует вам «Пепельный проход» - заклинание, которое позволяет вам исчезнуть из реальности и переместиться на небольшое расстояние, пройдя сквозь любые стены. \
			При усиленном заклинании избавит вас от оглушения и оков, а также увеличит радиус действия."
	gain_text = "Он знал, как ходить между мирами."

	action_to_add = /datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash
	cost = 2
	drafting_tier = 5

/datum/heretic_knowledge/spell/fire_blast
	name = "Взрыв вулкана"
	desc = "Дарует вам «Взрыв вулкана» - заклинание, которое после короткой зарядки выстреливает лучом энергии \
		в ближайшего врага, поджигая и обжигая его. Если они не потушат себя, \
		луч продолжит движение к другой цели. \
		При усилении не имеет зарядки и выстреливает большим количеством пламени."
	gain_text = "Ни один огонь не был достаточно горячим, чтобы разжечь их. Ни один огонь не был достаточно ярким, чтобы спасти их. Ни один огонь не вечен."
	action_to_add = /datum/action/cooldown/spell/charged/beam/fire_blast
	cost = 2
	research_tree_icon_frame = 7

/datum/heretic_knowledge/armor/ash
	name = "Выжженная мантия"
	desc = "Позволяет трансмутировать стол (или костюм), маску и спичку, чтобы создать Выжженную мантию. \
		Она обеспечивает полную защиту от огня и способна пассивно генерировать больше огненных зарядов. \
		Когда у вас будет достаточно огня, вы сможете использовать усиленные версии своих пепельных заклинаний. \
		Позволяет фокусироваться, находясь в капюшоне."
	gain_text = "Стражи остаются там, где упали, и исчезают из виду. \
			И всё же ветер, гуляющий по городу, зовёт их обратно на службу, в воздух поднимается пыль, а силуэт павшего растворяется в дымке."
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/ash)
	research_tree_icon_state = "ash_armor"
	required_atoms = list(
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/match = 1,
	)

/datum/heretic_knowledge/mad_mask
	name = "Маска Безумия"
	desc = "Позволяет трансмутировать любую маску, четыре свечи, станбатон и печень, чтобы создать маску Безумия. \
		Маска вселяет страх в язычников, которые становятся ее свидетелями, вызывая у них потерю стамины, галлюцинации и безумие. \
		Его также можно насильно надеть на язычника, чтобы он не смог его снять..."
	gain_text = "Ночной Дозорный был потерян. Так считал Дозор. И все же он ходил по миру, незамеченный массами."
	required_atoms = list(
		/obj/item/organ/liver = 1,
		/obj/item/melee/baton/security = 1,  // Technically means a cattleprod is valid
		/obj/item/clothing/mask = 1,
		/obj/item/flashlight/flare/candle = 4,
	)
	result_atoms = list(/obj/item/clothing/mask/madness_mask)
	cost = 2
	research_tree_icon_path = 'icons/obj/clothing/masks.dmi'
	research_tree_icon_state = "mad_mask"

/datum/heretic_knowledge/blade_upgrade/ash
	name = "Огненный клинок"
	desc = "Ваш клинок теперь поджигает врагов при атаке."
	gain_text = "Он вернулся, с клинком в руке, он размахивал и размахивал, когда пепел падал с неба. \
		Его город, люди, за которыми он поклялся наблюдать... и он наблюдал, пока все они сгорали дотла."


	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_ash"

/datum/heretic_knowledge/blade_upgrade/ash/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return

	target.adjust_fire_stacks(1)
	target.ignite_mob()

/datum/heretic_knowledge/spell/flame_birth
	name = "Перерождение Ночного Дозорного"
	desc = "Дарует вам «Прерождение Ночного Дозорного» - заклинание, которое тушит вас \
		и обжигает всех ближайших язычников, которые в данный момент горят, исцеляя вас за каждую пораженную цель. \
		Если цель находится в критическом состоянии, она мгновенно умрёт."
	gain_text = "Огонь был неизбежным, и все же жизнь оставалась в его обугленном теле. \
		Ночной дозорный был конкретным человеком, всегда бдительным."
	action_to_add = /datum/action/cooldown/spell/aoe/fiery_rebirth
	cost = 2
	research_tree_icon_frame = 5
	is_final_knowledge = TRUE

/datum/heretic_knowledge/ultimate/ash_final
	name = "Ритуал Пепельного Лорда"
	desc = "Ритуал вознесения Пути пепла. \
		Принесите 3 горящих трупа или хаска к руне трансмутации, чтобы завершить ритуал. \
		После завершения вы становитесь предвестником пламени и получаете две способности. \
		«Каскад», который вызывает массивное, растущее огненное кольцо вокруг вас, \
		и «Клятва пламени», заставляющая вас пассивно создавать кольцо пламени, во время передвижения. \
		Некоторые известные заклинания пепла также будут усилены. \
		У вас также появится иммунитет к огню, космосу и подобным опасностям окружающей среды."
	gain_text = "Дозор мертв, и Ночной Дозорный сгорел вместе с ним. И все же его огонь горит вечно, \
		ибо он принес человечеству обряд! Его взгляд продолжается, и теперь я един с пламенем, \
		УЗРИТЕ МОЕ ВОЗНЕСЕНИЕ, ПЕПЕЛЬНЫЙ ФОНАРЬ ВОСПЛАМЕНИТСЯ ВНОВЬ!"

	ascension_achievement = /datum/award/achievement/misc/ash_ascension
	announcement_text = "%SPOOKY% Бойтесь пламени, ибо Пепельный Лорд, %NAME%, вознесся! Пламя поглотит всех! %SPOOKY%"
	announcement_sound = 'sound/music/antag/heretic/ascend_ash.ogg'
	/// A static list of all traits we apply on ascension.
	var/static/list/traits_to_apply = list(
		TRAIT_BOMBIMMUNE,
		TRAIT_NOBREATH,
		TRAIT_NOFIRE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
	)

/datum/heretic_knowledge/ultimate/ash_final/is_valid_sacrifice(mob/living/carbon/human/sacrifice)
	. = ..()
	if(!.)
		return

	if(sacrifice.on_fire)
		return TRUE
	if(HAS_TRAIT_FROM(sacrifice, TRAIT_HUSK, BURN))
		return TRUE
	return FALSE

/datum/heretic_knowledge/ultimate/ash_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	var/datum/action/cooldown/spell/fire_sworn/circle_spell = new(user.mind)
	circle_spell.Grant(user)

	var/datum/action/cooldown/spell/fire_cascade/big/screen_wide_fire_spell = new(user.mind)
	screen_wide_fire_spell.Grant(user)

	var/datum/action/cooldown/spell/charged/beam/fire_blast/existing_beam_spell = locate() in user.actions
	if(existing_beam_spell)
		existing_beam_spell.max_beam_bounces *= 2 // Double beams
		existing_beam_spell.beam_duration *= 0.66 // Faster beams
		existing_beam_spell.cooldown_time *= 0.66 // Lower cooldown

	var/datum/action/cooldown/spell/aoe/fiery_rebirth/fiery_rebirth = locate() in user.actions
	fiery_rebirth?.cooldown_time *= 0.16

	user.add_traits(traits_to_apply, type)
