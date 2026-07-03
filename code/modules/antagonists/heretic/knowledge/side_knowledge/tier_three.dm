/*!
 * Tier 3 knowledge: Summons
 */
/datum/heretic_knowledge/summon/rusty
	name = "Ритуал Ржавчины"
	desc = "Позволяет трансмутировать лужу рвоты, 15 мотков провода, и 10 листов железа, чтобы создать Ржавохода. \
		Ржавоход превосходно распространяет ржавчину и умеренно силён в бою."
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
	desc = "Позволяет трансмутировать 5 листов стекла, любой костюм и лёгкие, чтобы создать горничную из Зазеркалья. \
			Горничные из Зазеркалья сильные бойцы, способные становиться бестелесными, входя в Зазеркальное царство и выходя из него, они выполняют роль разведчиков и мастеров засад.\
			Их атаки также накладывают Холод Пустоты."
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
	desc = "Позволяет трансмутировать костёр, горсть пепла и книгу для создания духа пепла. \
		Духи пепла обладают рывком на короткую дистанцию и способны дистанционно вызывать кровотечение у врагов. \
		Также они могут, на некоторое время, создать вокруг себя кольцо огня. \
		И хотя их запас здоровья довольно мал, они могут пассивно восстанавливать его со временем."
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
	desc = "Позволяет трансмутировать труп с душой, пару латексных или нитриловых перчаток, \
		и любой костюм, чтобы создать Разбитого восставшего. \
		Разбитые восставшие это сильные гули с 125 здоровья, но не могут держать предметы, \
		вместо этого имеют в руках два жестоких оружия. Вы можете иметь только одного."
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
	desc = "Позволяет трансмутировать горсть пепла, печень и лист плазмы, чтобы создать огненную акулу. \
		Огненные акулы быстры и сильны в группах, но быстро погибают. Они также обладают высокой устойчивостью к огненным атакам. \
		Огненные акулы впрыскивают флогистон в своих жертв и извергают плазму после своей смерти."
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
