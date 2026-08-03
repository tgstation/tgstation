/*!
 * Tier 3 knowledge: Summons
 */
/datum/heretic_knowledge/summon/rusty
	name = "Ритуал Ржавчины"
	desc = "Позволяет создать Ржавохода. \
		Ржавоход превосходно распространяет ржавчину и умеренно силён в бою."
	transmute_text = "Трансмутируйте лужу рвоты, 15 мотков кабеля и 10 листов железа."
	gain_text = "Я объединил свои знания о созидании с моим стремлением к разрушению. Маршал знал моё имя, и Ржавые Холмы отозвались эхом."
	required_atoms = list(
		/obj/effect/decal/cleanable/vomit = 1,
		/obj/item/stack/sheet/iron = 10,
		/obj/item/stack/cable_coil = 15,
	)
	mob_to_summon = /mob/living/basic/heretic_summon/rust_walker
	cost = 2
	poll_ignore_define = POLL_IGNORE_RUST_SPIRIT
	drafting_tier = 3

/datum/heretic_knowledge/summon/maid_in_mirror
	name = "Горничная из Зазеркалья"
	desc = "Позволяет создать горничную из Зазеркалья. \
			Горничные из Зазеркалья сильные бойцы, способные становиться бестелесными, входя в Зазеркальное царство и выходя из него, они выполняют роль разведчиков и мастеров засад.\
			Их атаки также накладывают Холод Пустоты."
	transmute_text = "Трансмутируйте пять листов стекла, любой костюм и лёгкие."
	gain_text = "В каждом отражении скрыты врата в невообразимый мир невиданных цветов и людей, что никогда не встречались.\
			Подъём сделан из стекла, а стены - из ножей. И каждый шаг - это кровь, если у вас нет проводника."

	required_atoms = list(
		/obj/item/stack/sheet/glass = 5,
		/obj/item/clothing/suit = 1,
		/obj/item/organ/lungs = 1,
	)
	cost = 2

	mob_to_summon = /mob/living/basic/heretic_summon/maid_in_the_mirror
	poll_ignore_define = POLL_IGNORE_MAID_IN_MIRROR
	drafting_tier = 3

/datum/heretic_knowledge/summon/ashy
	name = "Пепельный ритуал"
	desc = "Позволяет создать духа пепла. \
		Духи пепла обладают рывком на короткую дистанцию и способны дистанционно вызывать кровотечение у врагов. \
		Также они могут, на некоторое время, создать вокруг себя кольцо огня. \
		И хотя их запас здоровья довольно мал, они могут пассивно восстанавливать его со временем."
	transmute_text = "Трансмутируйте горсть пепла, книгу и костёр."
	gain_text = "Я объединил свой голод с жаждой разрушения. Маршал знал моё имя, а Ночной Дозорный наблюдал за происходящим."
	required_atoms = list(
		/obj/effect/decal/cleanable/ash = 1,
		/obj/item/book = 1,
		/obj/structure/bonfire = 1,
		)
	mob_to_summon = /mob/living/basic/heretic_summon/ash_spirit
	cost = 2

	poll_ignore_define = POLL_IGNORE_ASH_SPIRIT
	drafting_tier = 3

/// The max health given to Shattered Risen
#define RISEN_MAX_HEALTH 125

/datum/heretic_knowledge/limited_amount/risen_corpse
	name = "Разбитый ритуал"
	desc = "Позволяет создать Разбитого восставшего. \
		Разбитые восставшие это сильные гули с 125 здоровья, но не могут держать предметы, \
		вместо этого имеют в руках два жестоких оружия. Вы можете иметь только одного."
	transmute_text = "Трансмутируйте труп с душой, пару латексных или нитриловых перчаток."
	gain_text = "Я узрел как холодная, раздирающая сила вернула этот труп к полу-жизни. \
		Движения хрустящие, как сломанное стекло. Руки больше не похожи на человеческие - \
		в каждом сжатом кулаке жестокие гнезда острых костяных осколков."

	required_atoms = list(
		/obj/item/clothing/suit = 1,
		/obj/item/clothing/gloves/latex = 1,
	)
	limit = 1
	cost = 2
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "ghoul_shattered"
	drafting_tier = 3

/datum/heretic_knowledge/limited_amount/risen_corpse/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/body in atoms)
		if(body.stat != DEAD)
			continue
		if(!IS_VALID_GHOUL_MOB(body) || HAS_TRAIT(body, TRAIT_HUSK))
			to_chat(user, span_hierophant_warning("[capitalize(body.declent_ru(NOMINATIVE))] не в подходящем состоянии для превращения в гуля."))
			continue
		if(!body.mind)
			to_chat(user, span_hierophant_warning("[capitalize(body.declent_ru(NOMINATIVE))] не имеет разума и не может быть превращен в гуля."))
			continue
		if(!body.client && !body.mind.get_ghost(ghosts_with_clients = TRUE))
			to_chat(user, span_hierophant_warning("[capitalize(body.declent_ru(NOMINATIVE))] не имеет души и не может быть превращен в гуля."))
			continue

		// We will only accept valid bodies with a mind, or with a ghost connected that used to control the body
		selected_atoms += body
		return TRUE

	loc.balloon_alert(user, "ритуал провален, нет подходящего тела!")
	return FALSE

/datum/heretic_knowledge/limited_amount/risen_corpse/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/mob/living/carbon/human/soon_to_be_ghoul = locate() in selected_atoms
	if(QDELETED(soon_to_be_ghoul)) // No body? No ritual
		stack_trace("[type] reached on_finished_recipe without a human in selected_atoms to make a ghoul out of.")
		loc.balloon_alert(user, "ритуал провален, нет подходящего тела!")
		return FALSE

	soon_to_be_ghoul.grab_ghost()
	if(!soon_to_be_ghoul.mind || !soon_to_be_ghoul.client)
		stack_trace("[type] reached on_finished_recipe without a minded / cliented human in selected_atoms to make a ghoul out of.")
		loc.balloon_alert(user, "ритуал провален, нет подходящего тела!")
		return FALSE

	selected_atoms -= soon_to_be_ghoul
	make_risen(user, soon_to_be_ghoul)
	return TRUE

/// Make [victim] into a shattered risen ghoul.
/datum/heretic_knowledge/limited_amount/risen_corpse/proc/make_risen(mob/living/user, mob/living/carbon/human/victim)
	user.log_message("created a shattered risen out of [key_name(victim)].", LOG_GAME)
	victim.log_message("became a shattered risen of [key_name(user)]'s.", LOG_VICTIM, log_globally = FALSE)
	message_admins("[ADMIN_LOOKUPFLW(user)] created a shattered risen, [ADMIN_LOOKUPFLW(victim)].")

	victim.apply_status_effect(
		/datum/status_effect/ghoul,
		RISEN_MAX_HEALTH,
		user.mind,
		CALLBACK(src, PROC_REF(apply_to_risen)),
		CALLBACK(src, PROC_REF(remove_from_risen)),
	)

/// Callback for the ghoul status effect - what effects are applied to the ghoul.
/datum/heretic_knowledge/limited_amount/risen_corpse/proc/apply_to_risen(mob/living/risen)
	LAZYADD(created_items, WEAKREF(risen))
	risen.AddComponent(/datum/component/mutant_hands, mutant_hand_path = /obj/item/mutant_hand/shattered_risen)

/// Callback for the ghoul status effect - cleaning up effects after the ghoul status is removed.
/datum/heretic_knowledge/limited_amount/risen_corpse/proc/remove_from_risen(mob/living/risen)
	LAZYREMOVE(created_items, WEAKREF(risen))
	qdel(risen.GetComponent(/datum/component/mutant_hands))

#undef RISEN_MAX_HEALTH

/// The "hand" "weapon" used by shattered risen
/obj/item/mutant_hand/shattered_risen
	name = "bone-shards"
	desc = "То, что когда-то казалось обычным человеческим кулаком, теперь превратилось в гнездо острых костяных осколков."
	color = "#001aff"
	hitsound = SFX_SHATTER
	force = 16
	wound_bonus = -30
	exposed_wound_bonus = 15
	demolition_mod = 1.5
	sharpness = SHARP_EDGED

/datum/heretic_knowledge/summon/fire_shark
	name = "Пылающая акула"
	desc = "Позволяет создать огненную акулу. \
		Огненные акулы быстры и сильны в группах, но быстро погибают. Они также обладают высокой устойчивостью к огненным атакам. \
		Огненные акулы впрыскивают флогистон в своих жертв и извергают плазму после своей смерти."
	transmute_text = "Трансмутируйте горсть пепла, печень и лист плазмы."
	gain_text = "Колыбель туманности была холодной, но не мертвой. Свет и тепло проникают даже в самую глубокую тьму, и за ними охотятся их собственные хищники."

	required_atoms = list(
		/obj/effect/decal/cleanable/ash = 1,
		/obj/item/organ/liver = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	mob_to_summon = /mob/living/basic/heretic_summon/fire_shark
	cost = 2

	poll_ignore_define = POLL_IGNORE_FIRE_SHARK

	research_tree_icon_dir = EAST
	drafting_tier = 3

/datum/heretic_knowledge/mad_mask
	name = "Маска Безумия"
	desc = "Создаёт Маску Безумия.<br>\
		Маска вселяет страх в язычников, которые становятся ее свидетелями, вызывая у них потерю выносливости, галлюцинации и безумие.<br>\
		Её также можно насильно надеть на язычника, чтобы он не смог ее снять..."
	transmute_text = "Трансмутируйте любую маску, четыре зажжённые свечи, оглушающую дубинку и печень."
	gain_text = "Дозор носил странные одежды на службе. Они позволяли ходить по городу, будто оставаясь незамеченными массами."
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
	drafting_tier = 3

/datum/heretic_knowledge/mad_mask/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/item/flashlight/flare/candle/candle in atoms)
		if(!candle.light_on)
			atoms -= candle

/datum/heretic_knowledge/mad_mask/prepare_atom_for_ritual_test(atom/what)
	. = ..()
	if(istype(what, /obj/item/flashlight/flare/candle))
		what.set_light_on(TRUE)

/datum/heretic_knowledge/mansus_gate
	name = "Ключи к чёрному ходу"
	desc = "Открывает чёрный ход в Мансус.<br>\
		Вход в контейнер перенесёт вас в Мансус, давая безопасное убежище для трансмутации или хранения снаряжения."
	transmute_text = "Трансмутируйте шкаф и Кодекс Цикатрикс или Кодекс Морбус."
	notice = "Только согласные или мёртвые могут пройти через чёрный ход.\
		<br>Попытка провести жертвоприношение так близко к богам может разгневать их.\
		<br>Вы можете создать только один чёрный ход."
	gain_text = "В любой области безопасность сильна лишь настолько, насколько сильно её самое слабое место. \
		Кодекс говорит о чёрных ходах в Мансус - вратах с дрянными цепями, дверях с хрупкими замками, люках с ржавыми петлями. \
		С правильным ключом я легко смогу этим воспользоваться."
	required_atoms = list(
		/obj/structure/closet = 1,
		list(/obj/item/codex_cicatrix, /obj/item/codex_cicatrix/morbus) = 1,
	)
	cost = 2
	research_tree_icon_path = 'icons/effects/effects.dmi'
	research_tree_icon_state = "anom"
	drafting_tier = 3
	is_shop_only = TRUE
	VAR_PRIVATE/used = FALSE

/datum/heretic_knowledge/mansus_gate/can_be_invoked(datum/antagonist/heretic/invoker)
	return !used

/datum/heretic_knowledge/mansus_gate/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/obj/structure/closet/locker = locate() in selected_atoms
	if(isnull(locker))
		stack_trace("Locker not found in selected atoms for mansus gate recipe!")
		return FALSE

	used = TRUE
	INVOKE_ASYNC(src, PROC_REF(setup_link), locker)
	return TRUE

/datum/heretic_knowledge/mansus_gate/cleanup_atoms(list/selected_atoms)
	for(var/obj/structure/closet/locker in selected_atoms)
		selected_atoms -= locker
	return ..()

/datum/heretic_knowledge/mansus_gate/proc/setup_link(obj/structure/closet/crate/locker)
	var/datum/map_template/masus_backdoor/backdoor = new()
	var/datum/turf_reservation/reservation = SSmapping.request_turf_block_reservation(
		width = backdoor.width,
		height = backdoor.height,
		reservation_type = /datum/turf_reservation/indestructible_plating,
	)
	var/turf/bottom_left = reservation.bottom_left_turfs[1]
	backdoor.load(bottom_left)
	var/obj/structure/closet/new_link = locate() in backdoor.created_atoms
	new_link.resistance_flags |= INDESTRUCTIBLE
	new_link.set_anchored(TRUE)
	new_link.anchorable = FALSE
	new_link.divable = FALSE
	new_link.contents_pressure_protection = 1
	new_link.contents_thermal_insulation = 1
	locker.resistance_flags |= INDESTRUCTIBLE
	locker.divable = FALSE
	locker.contents_pressure_protection = 1
	locker.contents_thermal_insulation = 1
	GLOB.closet_teleport_controller.create_new_link(list(locker, new_link), subtle = TRUE)
	RegisterSignal(new_link, COMSIG_CLOSET_TELEPORTER_PRE_SENDING, PROC_REF(closet_teleport_logic))
	RegisterSignal(locker, COMSIG_CLOSET_TELEPORTER_PRE_SENDING, PROC_REF(closet_teleport_logic))

/datum/heretic_knowledge/mansus_gate/proc/closet_teleport_logic(obj/structure/closet/crate/locker, atom/movable/sending_through)
	SIGNAL_HANDLER

	if(!is_station_level(locker.z))
		return CLOSET_TELEPORT_FORCED

	if(isliving(sending_through) && !consents_to_entry(sending_through))
		locker.balloon_alert(sending_through, "дверь отвергает вас!")
		return CLOSET_TELEPORT_BLOCKED

	for(var/mob/living/entering in sending_through.get_all_contents())
		if(!consents_to_entry(entering))
			if(isliving(sending_through))
				locker.balloon_alert(sending_through, "дверь отвергает вас!")
			return CLOSET_TELEPORT_BLOCKED

	return CLOSET_TELEPORT_FORCED

/datum/heretic_knowledge/mansus_gate/proc/consents_to_entry(mob/living/entering)
	if(IS_HERETIC_OR_MONSTER(entering))
		return TRUE
	if(!INCAPACITATED_IGNORING(entering, INCAPABLE_GRAB|INCAPABLE_STASIS))
		return TRUE
	return FALSE

/datum/map_template/masus_backdoor
	name = "The Mansus"
	mappath = "_maps/templates/mansus_backdoor.dmm"
	width = 59
	height = 51
	returns_created_atoms = TRUE

/area/centcom/heretic_backdoor
	name = "Mansus"
	icon_state = "heretic"
	requires_power = TRUE
	always_unpowered = TRUE
	ambience_index = AMBIENCE_SPOOKY
	sound_environment = SOUND_ENVIRONMENT_PLAIN
	area_flags = NOTELEPORT | HIDDEN_AREA | BLOCK_SUICIDE | NO_BOH
	static_lighting = FALSE
	base_lighting_alpha = 200
	base_lighting_color = "#FFF4AA"

/area/centcom/heretic_backdoor/Entered(atom/movable/arrived, area/old_area)
	. = ..()
	if(isliving(arrived))
		var/mob/living/arrived_mob = arrived
		arrived_mob.add_movespeed_modifier(/datum/movespeed_modifier/heretic_backdoor_slowdown)
		arrived_mob.adjust_temp_blindness(1 SECONDS)
		arrived_mob.adjust_eye_blur(2 SECONDS)
		addtimer(CALLBACK(src, PROC_REF(greet_message), arrived_mob), 2 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)
		if(!IS_HERETIC_OR_MONSTER(arrived_mob))
			arrived_mob.apply_status_effect(/datum/status_effect/necropolis_curse, CURSE_BLINDING)

/area/centcom/heretic_backdoor/Exited(atom/movable/gone, direction)
	. = ..()
	if(isliving(gone))
		var/mob/living/gone_mob = gone
		gone_mob.remove_movespeed_modifier(/datum/movespeed_modifier/heretic_backdoor_slowdown)
		gone_mob.remove_status_effect(/datum/status_effect/necropolis_curse)
		gone_mob.adjust_temp_blindness(1 SECONDS)
		gone_mob.adjust_eye_blur(2 SECONDS)

/area/centcom/heretic_backdoor/proc/greet_message(mob/living/arrived_mob)
	if(QDELETED(arrived_mob) || get_area(arrived_mob) != src)
		return
	to_chat(arrived_mob, span_mansus("Пустое солнце сияет сверху."))

/datum/movespeed_modifier/heretic_backdoor_slowdown
	multiplicative_slowdown = 0.5
