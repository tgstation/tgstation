//Items for nuke theft, supermatter theft traitor objective


// STEALING THE NUKE

//the nuke core - objective item
/obj/item/nuke_core
	name = "plutonium core"
	desc = "Extremely radioactive. Wear goggles."
	icon = 'icons/obj/antags/syndicate_tools.dmi'
	icon_state = "plutonium_core"
	inhand_icon_state = "plutoniumcore"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/pulse = 0
	var/cooldown = 0
	var/pulseicon = "plutonium_core_pulse"

/obj/item/nuke_core/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/nuke_core/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/nuke_core/attackby(obj/item/nuke_core_container/container, mob/user)
	if(istype(container))
		container.load(src, user)
	else
		return ..()

/obj/item/nuke_core/process()
	if(cooldown < world.time - 60)
		cooldown = world.time
		flick(pulseicon, src)
		radiation_pulse(get_turf(src), max_range = 2, threshold = RAD_EXTREME_INSULATION)

/obj/item/nuke_core/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[capitalize(user.declent_ru(NOMINATIVE))] трет [declent_ru(ACCUSATIVE)] об себя! Кажется, [user.ru_p_they()] пытается совершить самоубийство!"))
	return TOXLOSS

//nuke core box, for carrying the core
/obj/item/nuke_core_container
	name = "nuke core container"
	desc = "Solid container for radioactive objects."
	icon = 'icons/obj/antags/syndicate_tools.dmi'
	icon_state = "core_container_empty"
	inhand_icon_state = "tile"
	lefthand_file = 'icons/mob/inhands/items/tiles_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/tiles_righthand.dmi'
	var/obj/item/nuke_core/core

/obj/item/nuke_core_container/Destroy()
	QDEL_NULL(core)
	return ..()

/obj/item/nuke_core_container/proc/load(obj/item/nuke_core/ncore, mob/user)
	if(core || !istype(ncore))
		return FALSE
	ncore.forceMove(src)
	core = ncore
	icon_state = "core_container_loaded"
	to_chat(user, span_warning("Контейнер герметизируется..."))
	addtimer(CALLBACK(src, PROC_REF(seal)), 5 SECONDS)
	return TRUE

/obj/item/nuke_core_container/proc/seal()
	if(istype(core))
		STOP_PROCESSING(SSobj, core)
		icon_state = "core_container_sealed"
		playsound(src, 'sound/items/deconstruct.ogg', 60, TRUE)
		if(ismob(loc))
			to_chat(loc, span_warning("[src] надежно запечатывается, радиация [core.declent_ru(GENITIVE)] сдерживается."))

/obj/item/nuke_core_container/attackby(obj/item/nuke_core/core, mob/user)
	if(istype(core))
		if(!user.temporarilyRemoveItemFromInventory(core))
			to_chat(user, span_warning("[capitalize(core.declent_ru(NOMINATIVE))] застревает на вашей руке!"))
			return
		else
			load(core, user)
	else
		return ..()

//snowflake screwdriver, works as a key to start nuke theft, traitor only
/obj/item/screwdriver/nuke
	name = "screwdriver"
	desc = "A screwdriver with an ultra thin tip that's carefully designed to boost screwing speed."
	icon = 'icons/obj/antags/syndicate_tools.dmi'
	icon_state = "screwdriver_nuke"
	post_init_icon_state = null
	inhand_icon_state = "screwdriver_nuke"
	toolspeed = 0.5
	random_color = FALSE
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_colors = null

/obj/item/screwdriver/nuke/get_belt_overlay()
	return mutable_appearance('icons/obj/clothing/belt_overlays.dmi', "screwdriver_nuke")

/obj/item/paper/guides/antag/nuke_instructions
	default_raw_text = "Как вскрыть терминал самоуничтожения Нанотрейзен и извлечь из него плутониевое ядро:<br>\
	<ul>\
	<li>С помощью отвертки с очень тонким наконечником (прилагается) отвинтите переднюю панель терминала</li>\
	<li>Подденьте и снимите переднюю панель с помощью лома</li>\
	<li>Разрежьте внутреннюю металлическую пластину с помощью сварки</li>\
	<li>Подденьте внутреннюю пластину ломом, чтобы обнажить радиоактивное ядро</li>\
	<li>Используйте контейнер для ядра, чтобы извлечь плутониевое ядро; для герметизации контейнера потребуется некоторое время</li>\
	<li>???</li>\
	</ul>"

/obj/item/paper/guides/antag/hdd_extraction
	default_raw_text = "<h1>Кража исходного кода и Вы! - руководство для идиотов по уничтожению исследований и разработок Нанотрейзен</h1><br>\
	Ходят слухи, что Нанотрейзен используют свои научные сервера для создания чего-то ужасного! Они дали ему кодовое название «Проект Гуны», что бы это ни значило.<br>\
	Этого нельзя допустить. Ниже приведены все наши данные о том, как украсть их исходный код и подорвать их исследовательские усилия:<br>\
	<ul>\
	<li>Найдите физические серверные мэйнфреймы РнД. Разведка предполагает, что они хранятся в специально охлаждаемых помещениях в глубине их научного отдела.</li>\
	<li>Нанотрейзен - корпорация, не отличающаяся изысканностью дизайна. Вы должны быть в состоянии определить главный сервер по каким-либо отличительным знакам.</li>\
	<li>Инструменты можно найти на месте. Отвертка, лом и кусачки - это все, что вам нужно для работы.</li>\
	<li>Винты передней панели спрятаны в углублениях за наклейками. Их легко открутить, как только вы узнаете, что они там есть.</li>\
	<li>Вероятно, жесткий диск находится в надежном корпусе. Возможно, вам придется поддеть его ломом, но это не должно нанести большого вреда.</li>\
	<li>Наконец, аккуратно перережьте все соединительные провода жесткого диска. Не торопитесь, перерезание неправильного провода может привести к уничтожению всех данных!</li>\
	</ul>\
	Извлечение этого диска гарантированно подорвет исследовательскую работу, независимо от того, какие данные на нем содержатся.<br>\
	Вероятно, эта штука имеет сложную фиксацию. После извлечения ее уже не вернуть на место. Если экипаж узнает, то скорее всего, будет в бешенстве как пчелы!<br>\
	Переживите смену, заберите и не повредите жесткий диск.<br>\
	Справитесь - получите заветную зеленую отметку в свой послужной список за это задание. Провалите задание - красный цвет станет последним в вашей жизни.<br>\
	Не разочаровывайте нас.<br>"

/obj/item/disk/computer/hdd_theft
	name = "r&d server hard disk drive"
	desc = "For some reason, people really seem to want to steal this. The source code on this drive is probably used for something awful!"
	max_capacity = 512
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	sticker_icon_state = "o_nt"

// STEALING SUPERMATTER

/obj/item/paper/guides/antag/supermatter_sliver
	default_raw_text = "Как безопасно извлечь осколок суперматерии:<br>\
	<ul>\
	<li>Вы должны постоянно иметь активную магнитную фиксацию вблизи активного кристалла суперматерии.</li>\
	<li>Подойдите к активному кристаллу суперматерии, используя средства индивидуальной защиты от радиации. НЕ ВСТУПАЙТЕ В ФИЗИЧЕСКИЙ КОНТАКТ.</li>\
	<li>С помощью суперматериального скальпеля (прилагается) отрежьте осколок кристалла.</li>\
	<li>Используйте суперматериальные щипцы для извлечения (прилагаются), чтобы безопасно поднять отрезанный осколок.</li>\
	<li>Физический контакт любого предмета с осколком превратит его в пыль, а также вас самих.</li>\
	<li>С помощью щипцов поместите осколок в предусмотренный контейнер, которому потребуется некоторое время для герметизации.</li>\
	<li>Убирайтесь к чертовой матери, пока кристалл не расслоился!</li>\
	<li>???</li>\
	</ul>"

/obj/item/nuke_core/supermatter_sliver
	name = "supermatter sliver"
	desc = "A tiny, highly volatile sliver of a supermatter crystal. Do not handle without protection!"
	icon_state = "supermatter_sliver"
	inhand_icon_state = null //touching it dusts you, so no need for an inhand icon.
	pulseicon = "supermatter_sliver_pulse"
	layer = ABOVE_MOB_LAYER

/obj/item/nuke_core/supermatter_sliver/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_FISHING_ROD_CAST, PROC_REF(on_hook))

/obj/item/nuke_core/supermatter_sliver/proc/on_hook(obj/item/nuke_core/supermatter_sliver/source, obj/item/fishing_rod/rod, mob/user)
	SIGNAL_HANDLER

	//hook gets dusted but the rod remains intact
	attackby(rod.hook, user)

	return FISHING_ROD_CAST_HANDLED

/obj/item/nuke_core/supermatter_sliver/attack_tk(mob/user) // no TK dusting memes
	return

/obj/item/nuke_core/supermatter_sliver/can_be_pulled(user, force) // no drag memes
	return FALSE

/obj/item/nuke_core/supermatter_sliver/attackby(obj/item/W, mob/living/user, list/modifiers, list/attack_modifiers)
	if(istype(W, /obj/item/hemostat/supermatter))
		var/obj/item/hemostat/supermatter/tongs = W
		if (tongs.sliver)
			to_chat(user, span_warning("[capitalize(tongs.declent_ru(NOMINATIVE))] уже держит осколок суперматерии!"))
			return FALSE
		forceMove(tongs)
		tongs.sliver = src
		tongs.update_appearance()
		to_chat(user, span_notice("Вы осторожно поднимаете [declent_ru(ACCUSATIVE)] с помощью [tongs.declent_ru(GENITIVE)]."))
	else if(istype(W, /obj/item/scalpel/supermatter) || istype(W, /obj/item/nuke_core_container/supermatter/)) // we don't want it to dust
		return
	else
		to_chat(user, span_notice("[capitalize(W.declent_ru(NOMINATIVE))] и [declent_ru(NOMINATIVE)] обращаются в пыль от прикосновения друг с другом!"))
		radiation_pulse(user, max_range = 2, threshold = RAD_EXTREME_INSULATION, chance = 40)
		playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
		qdel(W)
		qdel(src)

/obj/item/nuke_core/supermatter_sliver/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!isliving(hit_atom))
		return ..()
	var/mob/living/victim = hit_atom
	if(victim.incorporeal_move || HAS_TRAIT(victim, TRAIT_GODMODE)) //try to keep this in sync with supermatter's consume fail conditions
		return ..()
	var/mob/thrower = throwingdatum?.get_thrower()
	if(istype(thrower))
		log_combat(thrower, hit_atom, "consumed", src)
		message_admins("[src] has consumed [key_name_admin(victim)] [ADMIN_JMP(src)], thrown by [key_name_admin(thrower)].")
		investigate_log("has consumed [key_name(victim)], thrown by [key_name(thrower)]", INVESTIGATE_ENGINE)
	else
		message_admins("[src] has consumed [key_name_admin(victim)] [ADMIN_JMP(src)] via throw impact.")
		investigate_log("has consumed [key_name(victim)] via throw impact.", INVESTIGATE_ENGINE)
	victim.visible_message(span_danger("Когда [declent_ru(NOMINATIVE)] врезается в [victim.declent_ru(ACCUSATIVE)], они обращаются в пыль от прикосновения друг с другом, и тишина заполняет комнату..."),\
		span_userdanger("[capitalize(declent_ru(NOMINATIVE))] врезается в вас, и все внезапно затихает. \n[capitalize(declent_ru(NOMINATIVE))] обращается в пыль, и как только вы замечаете это, вы тоже обращаетесь."),\
		span_hear("Все внезапно затихает."))
	victim.investigate_log("has been dusted by [src].", INVESTIGATE_DEATHS)
	victim.dust()
	radiation_pulse(src, max_range = 2, threshold = RAD_EXTREME_INSULATION, chance = 40)
	playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
	qdel(src)

/obj/item/nuke_core/supermatter_sliver/pickup(mob/living/user)
	..()
	if(!isliving(user) || HAS_TRAIT(user, TRAIT_GODMODE)) //try to keep this in sync with supermatter's consume fail conditions
		return FALSE
	user.visible_message(span_danger("[capitalize(user.declent_ru(NOMINATIVE))] протягивает руку и пытается поднять [declent_ru(ACCUSATIVE)]. [capitalize(user.ru_p_them())] тело начинает светиться и вспыхивает, а затем обращается в пыль!"),\
			span_userdanger("Вы тянетесь к [declent_ru(DATIVE)] руками. Это было глупо..."),\
			span_hear("Все внезапно затихает."))
	radiation_pulse(user, max_range = 2, threshold = RAD_EXTREME_INSULATION, chance = 40)
	playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
	user.investigate_log("has been dusted by [src].", INVESTIGATE_DEATHS)
	user.dust()

/obj/item/nuke_core_container/supermatter
	name = "supermatter bin"
	desc = "A tiny receptacle that releases an inert hyper-noblium mix upon sealing, allowing a sliver of a supermatter crystal to be safely stored."
	var/obj/item/nuke_core/supermatter_sliver/sliver

/obj/item/nuke_core_container/supermatter/Destroy()
	QDEL_NULL(sliver)
	return ..()

/obj/item/nuke_core_container/supermatter/load(obj/item/hemostat/supermatter/T, mob/user)
	if(!istype(T) || !T.sliver)
		return FALSE
	T.sliver.forceMove(src)
	sliver = T.sliver
	T.sliver = null
	T.icon_state = "supermatter_tongs"
	icon_state = "core_container_loaded"
	to_chat(user, span_warning("Контейнер герметизируется..."))
	addtimer(CALLBACK(src, PROC_REF(seal)), 5 SECONDS)
	return TRUE

/obj/item/nuke_core_container/supermatter/seal()
	if(istype(sliver))
		STOP_PROCESSING(SSobj, sliver)
		icon_state = "core_container_sealed"
		playsound(src, 'sound/items/Deconstruct.ogg', 60, TRUE)
		if(ismob(loc))
			to_chat(loc, span_warning("[capitalize(declent_ru(NOMINATIVE))] надежно герметизируется, [sliver.declent_ru(NOMINATIVE)] содержится в безопасности."))

/obj/item/scalpel/supermatter
	name = "supermatter scalpel"
	desc = "A scalpel with a fragile tip of condensed hyper-noblium gas, searingly cold to the touch, that can safely shave a sliver off a supermatter crystal."
	icon = 'icons/obj/antags/syndicate_tools.dmi'
	icon_state = "supermatter_scalpel"
	toolspeed = 0.5
	damtype = BURN
	usesound = 'sound/items/weapons/bladeslice.ogg'
	var/usesLeft

/obj/item/scalpel/supermatter/Initialize(mapload)
	. = ..()
	usesLeft = rand(2, 4)

/obj/item/hemostat/supermatter
	name = "supermatter extraction tongs"
	desc = "A pair of tongs made from condensed hyper-noblium gas, searingly cold to the touch, that can safely grip a supermatter sliver."
	icon = 'icons/obj/antags/syndicate_tools.dmi'
	icon_state = "supermatter_tongs"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	inhand_icon_state = "supermatter_tongs"
	toolspeed = 0.75
	damtype = BURN
	var/obj/item/nuke_core/supermatter_sliver/sliver

/obj/item/hemostat/supermatter/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/hemostat/supermatter/Destroy()
	QDEL_NULL(sliver)
	return ..()

/obj/item/hemostat/supermatter/update_icon_state()
	icon_state = "supermatter_tongs[sliver ? "_loaded" : null]"
	inhand_icon_state = "supermatter_tongs[sliver ? "_loaded" : null]"
	return ..()

/obj/item/hemostat/supermatter/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!sliver)
		return ..()
	if (istype(interacting_with, /obj/item/nuke_core_container/supermatter))
		var/obj/item/nuke_core_container/supermatter/container = interacting_with
		container.load(src, user)
		return ITEM_INTERACT_SUCCESS
	if(ismovable(interacting_with) && interacting_with != sliver)
		Consume(interacting_with, user)
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/item/hemostat/supermatter/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum) // no instakill supermatter javelins
	if(sliver)
		sliver.forceMove(loc)
		visible_message(span_notice("[capitalize(sliver.declent_ru(NOMINATIVE))] выпадает из [declent_ru(GENITIVE)] при падении на землю."))
		sliver = null
		update_appearance()
	return ..()

/obj/item/hemostat/supermatter/proc/Consume(atom/movable/AM, mob/living/user)
	if(ismob(AM))
		if(!isliving(AM))
			return
		var/mob/living/victim = AM
		if(victim.incorporeal_move || HAS_TRAIT(victim, TRAIT_GODMODE)) //try to keep this in sync with supermatter's consume fail conditions
			return
		victim.investigate_log("has been dusted by [src].", INVESTIGATE_DEATHS)
		victim.dust()
		message_admins("[src] has consumed [key_name_admin(victim)] [ADMIN_JMP(src)].")
		investigate_log("has consumed [key_name(victim)].", INVESTIGATE_ENGINE)
	else if(istype(AM, /obj/singularity))
		return
	else
		investigate_log("has consumed [AM].", INVESTIGATE_ENGINE)
		qdel(AM)
	if (user)
		log_combat(user, AM, "consumed", sliver, "via [src]")
		user.visible_message(span_danger("Когда [user.declent_ru(NOMINATIVE)] прикасается к [AM.declent_ru(DATIVE)] с помощью [declent_ru(GENITIVE)], они все обращаются в пыль, и тишина заполняет комнату..."),\
			span_userdanger("Вы прикасаетесь к [AM.declent_ru(DATIVE)] с помощью [declent_ru(GENITIVE)], и всё внезапно замолкает.\n[capitalize(AM.declent_ru(NOMINATIVE))] и [sliver.declent_ru(NOMINATIVE)] обращаются в пыль, и как только вы замечаете это, вы тоже обращаетесь."),\
			span_hear("Все внезапно затихает."))
		user.investigate_log("has been dusted by [src].", INVESTIGATE_DEATHS)
		user.dust()
	radiation_pulse(src, max_range = 2, threshold = RAD_EXTREME_INSULATION, chance = 40)
	playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
	QDEL_NULL(sliver)
	update_appearance()
