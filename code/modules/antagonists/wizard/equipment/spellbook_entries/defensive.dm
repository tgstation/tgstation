#define SPELLBOOK_CATEGORY_DEFENSIVE "Защита"
// Defensive wizard spells
/datum/spellbook_entry/magicm
	name = "Magic Missile"
	desc = "Выпускает несколько медленно движущихся магических снарядов по ближайшим целям."
	spell_type = /datum/action/cooldown/spell/aoe/magic_missile
	category = SPELLBOOK_CATEGORY_DEFENSIVE

/datum/spellbook_entry/disabletech
	name = "Disable Tech"
	desc = "Отключает все оружие, камеры и большинство других устройств в радиусе действия."
	spell_type = /datum/action/cooldown/spell/emp/disable_tech
	category = SPELLBOOK_CATEGORY_DEFENSIVE
	cost = 1

/datum/spellbook_entry/repulse
	name = "Repulse"
	desc = "Отбрасывает все вокруг пользователя."
	spell_type = /datum/action/cooldown/spell/aoe/repulse/wizard
	category = SPELLBOOK_CATEGORY_DEFENSIVE

/datum/spellbook_entry/lightning_packet
	name = "Thrown Lightning"
	desc = "Выкованный из мистической энергии, мешочек чистой силы, \
		известный как мешочек заклинаний, появится в вашей руке и при броске оглушит цель."
	spell_type = /datum/action/cooldown/spell/conjure_item/spellpacket
	category = SPELLBOOK_CATEGORY_DEFENSIVE

/datum/spellbook_entry/timestop
	name = "Time Stop"
	desc = "Останавливает время для всех, кроме вас, позволяя вам свободно двигаться, \
		в то время как ваши враги и даже снаряды заморожены."
	spell_type = /datum/action/cooldown/spell/timestop
	category = SPELLBOOK_CATEGORY_DEFENSIVE

/datum/spellbook_entry/smoke
	name = "Smoke"
	desc = "Порождает облако удушливого дыма на вашем месте."
	spell_type = /datum/action/cooldown/spell/smoke
	category = SPELLBOOK_CATEGORY_DEFENSIVE
	cost = 1

/datum/spellbook_entry/forcewall
	name = "Force Wall"
	desc = "Создайте магический барьер, через который сможете пройти только вы."
	spell_type = /datum/action/cooldown/spell/forcewall
	category = SPELLBOOK_CATEGORY_DEFENSIVE
	cost = 1

/datum/spellbook_entry/lichdom
	name = "Bind Soul"
	desc = "Темный некромантический договор, который может навсегда привязать вашу душу к выбранному вами предмету, \
		превратив вас в бессмертного лича. Пока предмет остается нетронутым, вы будете возрождаться после смерти, \
		независимо от обстоятельств. Будьте осторожны - с каждым возрождением ваше тело будет слабеть, и \
		другим станет проще найти ваш предмет силы."
	spell_type =  /datum/action/cooldown/spell/lichdom
	category = SPELLBOOK_CATEGORY_DEFENSIVE
	no_coexistence_typecache = list(/datum/action/cooldown/spell/splattercasting, /datum/spellbook_entry/perks/wormborn, /datum/spellbook_entry/ghostliness)

/datum/spellbook_entry/chuunibyou
	name = "Chuuni Invocations"
	desc = "Заставляет все ваши заклинания выкрикивать призывы, а сами призывы становятся... глупыми. Вы немного исцеляетесь после произнесения заклинания."
	spell_type =  /datum/action/cooldown/spell/chuuni_invocations
	category = SPELLBOOK_CATEGORY_DEFENSIVE

/datum/spellbook_entry/spacetime_dist
	name = "Spacetime Distortion"
	desc = "Запутывает нити пространства-времени в области вокруг вас, \
		случайным образом изменяя расположение и делая невозможным правильное перемещение. Нити колеблются..."
	spell_type = /datum/action/cooldown/spell/spacetime_dist
	category = SPELLBOOK_CATEGORY_DEFENSIVE
	cost = 1

/datum/spellbook_entry/the_traps
	name = "The Traps!"
	desc = "Вызовите вокруг себя несколько ловушек. Они нанесут урон и разозлят любых врагов, которые на них наступят."
	spell_type = /datum/action/cooldown/spell/conjure/the_traps
	category = SPELLBOOK_CATEGORY_DEFENSIVE
	cost = 1

/datum/spellbook_entry/bees
	name = "Lesser Summon Bees"
	desc = "Это заклинание магически бьет по транспространственному улью, \
		мгновенно вызывая рой пчел в ваше местоположение. Эти пчелы НЕ дружелюбны ко кому-либо."
	spell_type = /datum/action/cooldown/spell/conjure/bee
	category = SPELLBOOK_CATEGORY_DEFENSIVE

/datum/spellbook_entry/duffelbag
	name = "Bestow Cursed Duffel Bag"
	desc = "Проклятие, прочно прикрепляющее к спине цели демонический вещмешок. \
		Сумка будет периодически наносить урон тому, к кому она прикреплена, \
		если ее не кормить регулярно, и независимо от того, кормили ее или нет, \
		она будет значительно замедлять передвижение того, кто ее носит."
	spell_type = /datum/action/cooldown/spell/touch/duffelbag
	category = SPELLBOOK_CATEGORY_DEFENSIVE
	cost = 1

/datum/spellbook_entry/item/staffhealing
	name = "Staff of Healing"
	desc = "Альтруистический посох, способный исцелять хромых и воскрешать мертвых."
	item_path = /obj/item/gun/magic/staff/healing
	cost = 1
	category = SPELLBOOK_CATEGORY_DEFENSIVE

/datum/spellbook_entry/item/lockerstaff
	name = "Staff of the Locker"
	desc = "Посох, стреляющий шкафчиками. Он съедает всех, в кого попадает на своем пути, оставляя после себя заваренный шкафчик с вашими жертвами."
	item_path = /obj/item/gun/magic/staff/locker
	category = SPELLBOOK_CATEGORY_DEFENSIVE

/datum/spellbook_entry/item/scryingorb
	name = "Scrying Orb"
	desc = "Накаленная сфера с потрескивающей энергией. Используя его, вы сможете выпустить свой дух при сохранении жизни, что позволит вам шпионить за станцией и разговаривать с умершими. Кроме того, купив его, вы навсегда получите рентгеновское зрение."
	item_path = /obj/item/scrying
	category = SPELLBOOK_CATEGORY_DEFENSIVE

/datum/spellbook_entry/item/wands
	name = "Wand Assortment"
	desc = "Коллекция палочек, позволяющих использовать их в самых разных целях. \
		У палочек ограниченное количество зарядов, поэтому будьте осторожны при их использовании. \
		Поставляется в удобном поясе или модной бандольере, если пояс уже экипирован."
	item_path = /obj/item/storage/belt/wands/full
	category = SPELLBOOK_CATEGORY_DEFENSIVE

/datum/spellbook_entry/item/wands/try_equip_item(mob/living/carbon/human/user, obj/item/to_equip)
	if (!istype(user.belt, /obj/item/storage/belt/wands))
		var/was_equipped = user.equip_to_slot_if_possible(to_equip, ITEM_SLOT_BELT, disable_warning = TRUE)
		to_chat(user, span_notice("[capitalize(to_equip.declent_ru(NOMINATIVE))] призывается [was_equipped ? "на ваш пояс" : "у ваших ног"]."))
		return

	// If you already have a wand belt you get a cool bandolier instead for your copious amount of wands
	var/obj/item/storage/belt/wand_bandolier/bandolier = new(user.drop_location())

	for (var/obj/item/wand_presumably in to_equip.atom_storage.real_location)
		bandolier.atom_storage.attempt_insert(wand_presumably, user, messages = FALSE)

	qdel(to_equip)

	var/was_equipped = user.equip_to_slot_if_possible(bandolier, ITEM_SLOT_SUITSTORE, disable_warning = TRUE)
	to_chat(user, span_notice("[capitalize(bandolier.declent_ru(NOMINATIVE))] призывается [was_equipped ? "вам на грудь" : "у ваших ног"]."))

/datum/spellbook_entry/item/wands/discount
	name = "Wand Assortment (Bargain Bin)"
	desc = "Случайная коллекция палочек, сотворённых учениками. \
		Неизвестно, что вы получите. \
		Поставляется в удобном поясе или модной бандольере, если пояс уже экипирован."
	cost = 1
	item_path = /obj/item/storage/belt/wands/full/discount
	category = SPELLBOOK_CATEGORY_DEFENSIVE

/datum/spellbook_entry/item/armor
	name = "Mastercrafted Armor Set"
	desc = "Артефактный комплект брони, позволяющий использовать заклинания \
		и обеспечивающий дополнительную защиту от атак и пустоты космоса. \
		Также дает силовой щит боевого мага."
	item_path = /obj/item/mod/control/pre_equipped/enchanted
	category = SPELLBOOK_CATEGORY_DEFENSIVE

/datum/spellbook_entry/item/armor/try_equip_item(mob/living/carbon/human/user, obj/item/to_equip)
	var/obj/item/mod/control/mod = to_equip
	var/obj/item/mod/module/storage/storage = locate() in mod.modules
	var/obj/item/back = user.back
	if(back)
		if(!user.dropItemToGround(back))
			return
		for(var/obj/item/item as anything in back.contents)
			item.forceMove(storage)
	if(!user.equip_to_slot_if_possible(mod, mod.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE))
		return
	if(!user.dropItemToGround(user.wear_suit) || !user.dropItemToGround(user.head))
		return
	mod.quick_activation()
	var/obj/item/mod/module/eradication_lock/lock_module = locate() in mod.modules
	lock_module.used()

#undef SPELLBOOK_CATEGORY_DEFENSIVE
