/*!
 * Tier 1 knowledge: Stealth and general utility
 */

/datum/heretic_knowledge/void_cloak
	name = "Накидка Пустоты"
	desc = "Позволяет трансмутировать осколок стекла, простыню, и любую верхнюю одежду (например броню или костюм), \
		чтобы создать накидку Пустоты. Пока капюшон опущен, накидка защищает вас от космоса и действует как фокусировка. \
		Когда капюшон поднят, плащ полностью невидим. Он также обеспечивает неплохую броню и \
		имеет карманы, в которые можно поместить один из ваших клинков, различные ритуальные компоненты (например, органы) и небольшие еретические безделушки."
	gain_text = "Сова хранит то, что не обрело формы в действительности, но уже существует в теории. А таких сущностей немало."
	required_atoms = list(
		/obj/item/shard = 1,
		/obj/item/clothing/suit = 1,
		/obj/item/bedsheet = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/void)
	cost = 1
	research_tree_icon_path = 'icons/obj/clothing/suits/armor.dmi'
	research_tree_icon_state = "void_cloak"
	drafting_tier = 1

/datum/heretic_knowledge/medallion
	name = "Пепельные глаза"
	desc = "Позволяет трансмутировать глаза, свечу, и осколок стекла в Потусторонний медальон. \
		При ношении Потусторонний медальон дает термальное зрение, а также работает как фокусировка."
	gain_text = "Пронзительный взгляд вёл их сквозь обыденность. Ни темнота, ни ужас не могли их остановить."
	required_atoms = list(
		/obj/item/organ/eyes = 1,
		/obj/item/shard = 1,
		/obj/item/flashlight/flare/candle = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/eldritch_amulet)
	cost = 1
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "eye_medalion"
	drafting_tier = 1

/datum/heretic_knowledge/essence // AKA Eldritch Flask
	name = "Священный ритуал"
	desc = "Позволяет трансмутировать ёмкость с водой и осколок стекла во флягу Потусторонней эссенции. \
		Потустороннюю эссенцию можно употреблять для мощного исцеления или дать язычникам, для смертельного отравления"
	gain_text = "Это наш старый рецепт. Нашептала мне Сова. \
		Созданная Жрецом - жидкость, которая существовала и нет одновременно."
	required_atoms = list(
		/obj/structure/reagent_dispensers/watertank = 1,
		/obj/item/shard = 1,
	)
	result_atoms = list(/obj/item/reagent_containers/cup/beaker/eldritch)
	cost = 1
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "eldritch_flask"
	drafting_tier = 1

/datum/heretic_knowledge/phylactery
	name = "Филактерия проклятия"
	desc = "Позволяет трансмутировать лист стекла и мак в филактерию, способную мгновенно вытягивать кровь, даже на большой дистанции. \
		Имейте в виду, что ваша цель все еще может почувствовать укол."
	gain_text = "Настойка, извращённая в форму кровососущего паразита. \
		Выбрала ли она этот облик сама, или же это - шутка больного разума, породившего этот мерзкий артефакт, - вопрос, над которым лучше не задумываться."
	required_atoms = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/food/grown/poppy = 1,
	)
	result_atoms = list(/obj/item/reagent_containers/cup/phylactery)
	cost = 1
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "phylactery_2"
	drafting_tier = 1

/datum/heretic_knowledge/crucible
	name = "Зубастый тигель"
	desc = "Позволяет трансмутировать переносной бак с водой и стол, чтобы создать Зубастый тигель. \
		Зубастый Тигель открывает возможность варить могущественные зелья, как для боя, так и общего назначения, однако между использованиями его нужно подкармливать органами, или частями тела."
	gain_text = "Это чистейшая агония. Мне не удалось призвать образ Аристократа, \
		но, привлёкши внимание Жреца, я наткнулся на иной рецепт…"
	required_atoms = list(
		/obj/structure/reagent_dispensers/watertank = 1,
		/obj/structure/table = 1,
	)
	result_atoms = list(/obj/structure/destructible/eldritch_crucible)
	cost = 1
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "crucible"
	drafting_tier = 1

/datum/heretic_knowledge/eldritch_coin
	name = "Потусторонняя монета"
	desc = "Позволяет трансмутировать лист плазмы и алмаз, чтобы создать Потустороннюю монету \
		Монета откроет или закроет ближайшие двери если выпадет орёл, и заболтирует их, если выпадет решка. \
		Если вставить монету в шлюз, она сожжет его плату, оставив шлюз открытым, если он не болтирован."
	gain_text = "Мансус - место для всех видов греха. Но алчность занимает в нём особое место."
	required_atoms = list(
		/obj/item/stack/sheet/mineral/diamond = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	result_atoms = list(/obj/item/coin/eldritch)
	cost = 1
	research_tree_icon_path = 'icons/obj/economy.dmi'
	research_tree_icon_state = "coin_heretic"
	drafting_tier = 1

/**
 * This allows heretics to choose if they want to rush all the influences and take them stealthily, or
 * Construct a codex and take what's left with more points.
 * Another downside to having the book is strip searches, which means that it's not just a free nab, at least until you get exposed - and when you do, you'll probably need the faster drawing speed.
 * Overall, it's a tradeoff between speed and stealth or power.
 */
/datum/heretic_knowledge/codex_cicatrix
	name = "Кодекс Цикатрикс"
	desc = "Позволяет трансмутировать книгу, любую ручку, любое тело (животного или человека) и шкуру или кожу, чтобы создать кодекс Цикатрикс. \
		Кодекс Цикатрикс можно использовать при извлечении влияний для получения дополнительных знаний, но при этом возрастает риск быть замеченным. \
		Его также можно использовать для того, чтобы легче рисовать и удалять руны трансмутации, и использоваться в качестве фокусировки"
	gain_text = "Оккультизм оставляет фрагменты знаний и силы везде и всюду. Кодекс Цикатрикс - один из таких примеров. \
		В кожаном переплете и на старых страницах открывается путь к Мансусу."
	required_atoms = list(
		list(/obj/item/toy/eldritch_book, /obj/item/book) = 1,
		/obj/item/pen = 1,
		list(/mob/living, /obj/item/stack/sheet/leather, /obj/item/stack/sheet/animalhide, /obj/item/food/deadmouse) = 1,
	)
	result_atoms = list(/obj/item/codex_cicatrix)
	cost = 1
	priority = MAX_KNOWLEDGE_PRIORITY - 4
	drafting_tier = 1
	is_shop_only = TRUE
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "book"

	var/static/list/non_mob_bindings = typecacheof(list(
		/obj/item/stack/sheet/leather,
		/obj/item/stack/sheet/animalhide,
		/obj/item/food/deadmouse,
	))

/datum/heretic_knowledge/codex_cicatrix/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	if(!.)
		return FALSE

	for(var/thingy in atoms)
		if(is_type_in_typecache(thingy, non_mob_bindings))
			selected_atoms += thingy
			return TRUE
		else if(isliving(thingy))
			var/mob/living/body = thingy
			if(body.stat != DEAD)
				continue
			selected_atoms += body
			return TRUE
	return FALSE

/datum/heretic_knowledge/codex_cicatrix/cleanup_atoms(list/selected_atoms)
	var/mob/living/body = locate() in selected_atoms
	if(!body)
		return ..()
	// A golem or an android doesn't have skin!
	var/exterior_text = "skin"
	// If carbon, it's the limb. If not, it's the body.
	var/atom/movable/ripped_thing = body

	// We will check if it's a carbon's body.
	// If it is, we will damage a random bodypart, and check that bodypart for its body type, to select between 'skin' or 'exterior'.
	if(iscarbon(body))
		var/mob/living/carbon/carbody = body
		var/obj/item/bodypart/bodypart = pick(carbody.get_bodyparts())
		ripped_thing = bodypart

		carbody.apply_damage(25, BRUTE, bodypart, sharpness = SHARP_EDGED)
		if(!(bodypart.bodytype & BODYTYPE_ORGANIC))
			exterior_text = "exterior"
	else
		body.apply_damage(25, BRUTE, sharpness = SHARP_EDGED)
		// If it is not a carbon mob, we will just check biotypes and damage it directly.
		if(body.mob_biotypes & (MOB_MINERAL|MOB_ROBOTIC))
			exterior_text = "exterior"

	// Procure book for flavor text. This is why we call parent at the end.
	var/obj/item/book/le_book = locate() in selected_atoms
	if(!le_book)
		stack_trace("Somehow, no book in codex cicatrix selected atoms! [english_list(selected_atoms)]")
	playsound(body, 'sound/items/poster/poster_ripped.ogg', 100, TRUE)
	body.do_jitter_animation()
	body.visible_message(span_danger("Ужасный рвущийся звук раздается, когда [ripped_thing.declent_ru(ACCUSATIVE)] [exterior_text] вырывается наружу, обволакивая всё вокруг [le_book || "книги"], приобретая жуткий, потусторонний оттенок!"))
	return ..()

/**
 * Warren King's Welcome
 * Offers an alternative way besides stealing an ID or visiting the HoP to gain access to maintenance
 * Additionally changes all nearby airlock's access's to ACCESS_HERETIC
 */
/datum/heretic_knowledge/bookworm
	name = "Приветствие Уоррена Кинга"
	desc = "Позволяет трансмутировать 10 обрезков провода, лист бумаги и мультитул, чтобы заклеймить ближайшие ID-карты и шлюзы. \
		Заклеймленные ID-карты получат доступ к техническим тоннелям и внешним шлюзам. \
		Заклеймленные шлюзы будут доступны только для тех, кто имеет заклеймленную ID-карту."
	gain_text = "Впившееся в осквернённые жестокостью кости пальцев, моё мрачное приглашение рывком обращает мой мутный, подташнивающий разум к массивной двери. \
		Свет медленно пляшет в ползущей тьме, укрывая зловонный променад бесконечными кознями. \
		Но Король скоро получит свой фунт плоти. Даже здесь налоговик требует свою долю. Ибо есть тысяча ртов, ждущих пищи."
	required_atoms = list(
		/obj/item/stack/cable_coil = 10,
		/obj/item/paper = 1,
		/obj/item/multitool = 1,
	)
	cost = 1
	priority = MAX_KNOWLEDGE_PRIORITY - 3
	drafting_tier = 1
	research_tree_icon_path = 'icons/obj/card.dmi'
	research_tree_icon_state = "eldritch"

/datum/heretic_knowledge/bookworm/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/item/card/id/used_id in atoms)
		selected_atoms += used_id
	var/obj/item/card/user_card = user.get_idcard(hand_first = TRUE)
	if(user_card)
		selected_atoms += user_card

/datum/heretic_knowledge/bookworm/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/item/card/id/improved_id in selected_atoms)
		improved_id.add_access(list(ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_HERETIC), mode = FORCE_ADD_ALL)
		selected_atoms -= improved_id
	for(var/obj/machinery/door/airlock/door in view(7, loc))
		door.req_one_access = null
		door.req_access = list(ACCESS_HERETIC)
		door.wires?.cut(WIRE_AI)
		new /obj/effect/temp_visual/eldritch_sparks(door.loc)
		var/obj/effect/light_emitter/light = new(door.loc)
		light.set_light(1.75, 1.5, COLOR_PUCE)
		QDEL_IN(light, 1 SECONDS)
		playsound(door, 'sound/effects/magic.ogg', 20, vary = TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, ignore_walls = FALSE)
		playsound(door, SFX_SPARKS, 33, vary = TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, ignore_walls = FALSE)

	return TRUE
