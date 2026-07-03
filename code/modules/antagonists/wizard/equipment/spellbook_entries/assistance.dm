#define SPELLBOOK_CATEGORY_ASSISTANCE "Поддержка"
// Wizard spells that assist the caster in some way
/datum/spellbook_entry/summonitem
	name = "Summon Item"
	desc = "Возвращает в вашу руку ранее отмеченный предмет из любой точки вселенной."
	spell_type = /datum/action/cooldown/spell/summonitem
	category = SPELLBOOK_CATEGORY_ASSISTANCE
	cost = 1

/datum/spellbook_entry/charge
	name = "Charge"
	desc = "Это заклинание можно использовать для подзарядки самых разных предметов в ваших руках, от магических артефактов до электрических компонентов. Креативный волшебник может даже использовать его, чтобы наделить магической силой своего товарища."
	spell_type = /datum/action/cooldown/spell/charge
	category = SPELLBOOK_CATEGORY_ASSISTANCE
	cost = 1

/datum/spellbook_entry/shapeshift
	name = "Wild Shapeshift"
	desc = "Примите на время облик другого существа, чтобы использовать его способности. После того как вы сделали свой выбор, его нельзя изменить."
	spell_type = /datum/action/cooldown/spell/shapeshift/wizard
	category = SPELLBOOK_CATEGORY_ASSISTANCE
	cost = 1

/datum/spellbook_entry/tap
	name = "Soul Tap"
	desc = "Заряжайте свои заклинания, используя собственную душу!"
	spell_type = /datum/action/cooldown/spell/tap
	category = SPELLBOOK_CATEGORY_ASSISTANCE
	cost = 1

/datum/spellbook_entry/item/staffanimation
	name = "Staff of Animation"
	desc = "Арканный посох, способный стрелять зарядами эльдрической энергии, которые заставляют оживать неодушевленные предметы. Эта магия не действует на машины."
	item_path = /obj/item/gun/magic/staff/animate
	category = SPELLBOOK_CATEGORY_ASSISTANCE

/datum/spellbook_entry/item/soulstones
	name = "Soulstone Shard Kit"
	desc = "Осколки камней душ - древние инструменты, способные захватить и использовать души мертвых и умирающих. \
		Заклинание Artificer позволяет создавать магические машины для пойманных душ, которыми они могут управлять."
	item_path = /obj/item/storage/belt/soulstone/full
	category = SPELLBOOK_CATEGORY_ASSISTANCE

/datum/spellbook_entry/item/soulstones/try_equip_item(mob/living/carbon/human/user, obj/item/to_equip)
	var/was_equipped = user.equip_to_slot_if_possible(to_equip, ITEM_SLOT_BELT, disable_warning = TRUE)
	to_chat(user, span_notice("[capitalize(to_equip.declent_ru(NOMINATIVE))] призывается [was_equipped ? "на вашем поясе" : "у ваших ног"]."))

/datum/spellbook_entry/item/soulstones/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy = TRUE)
	. =..()
	if(!.)
		return

	var/datum/action/cooldown/spell/conjure/construct/bonus_spell = new(user.mind || user)
	bonus_spell.Grant(user)

/datum/spellbook_entry/item/necrostone
	name = "A Necromantic Stone"
	desc = "Камень некроманта способен воскресить трех мертвецов в виде скелетов-рабов, подчиненных вам."
	item_path = /obj/item/necromantic_stone
	category = SPELLBOOK_CATEGORY_ASSISTANCE

/datum/spellbook_entry/item/contract
	name = "Contract of Apprenticeship"
	desc = "Магический контракт, привязывающий ученика волшебника к вашей службе, при использовании вызовет его на вашу сторону."
	item_path = /obj/item/antag_spawner/contract
	category = SPELLBOOK_CATEGORY_ASSISTANCE
	refundable = TRUE

/datum/spellbook_entry/item/guardian
	name = "Guardian Deck"
	desc = "Колода карт хранителей Таро, способная привязать к вашему телу личного хранителя. Существует несколько типов хранителей, но они все будут переносить на вас определенный урон. \
	Разумно будет избегать покупки их с чем-то, что может заставить вас поменяться телами с другими."
	item_path = /obj/item/guardian_creator/wizard
	category = SPELLBOOK_CATEGORY_ASSISTANCE

/datum/spellbook_entry/item/bloodbottle
	name = "Bottle of Blood"
	desc = "Бутылка с магической кровью, запах которой привлекает \
		внепространственных существ, если ее разбить. Но будьте осторожны, \
		существа, вызываемые магией крови, неизбирательны \
		в своих убийствах, и вы сами можете стать жертвой."
	item_path = /obj/item/antag_spawner/slaughter_demon
	limit = 3
	category = SPELLBOOK_CATEGORY_ASSISTANCE
	refundable = TRUE

/datum/spellbook_entry/item/hugbottle
	name = "Bottle of Tickles"
	desc = "Бутылка с волшебным напитком, запах которого притягивает  \
		очаровательных внепространственных существ, если его разбить. Эти существа \
		похожи на демонов резни, но они не убивают своих жертв навсегда, \
		вместо этого помещая их во внепространственный мир обьятий, \
		из которого они освобождаются после смерти демона. Хаотично, но не окончательно \
		деструктивно. С другой стороны, реакция экипажа может быть очень \
		разрушительной."
	item_path = /obj/item/antag_spawner/slaughter_demon/laughter
	cost = 1 //non-destructive; it's just a jape, sibling!
	limit = 3
	category = SPELLBOOK_CATEGORY_ASSISTANCE
	refundable = TRUE

/datum/spellbook_entry/item/vendormancer
	name = "Scepter of Vendormancy"
	desc = "Скипетр, содержащий силу Рунической Вендормантии. \
		Он может вызвать до 3 рунических вендоров, которые со временем разлагаются, но могут быть \
		брошены в противников или непосредственно взорваны. Если заряды \
		кончатся, после длительного периода времени они восстановятся."
	item_path = /obj/item/runic_vendor_scepter
	category = SPELLBOOK_CATEGORY_ASSISTANCE

#undef SPELLBOOK_CATEGORY_ASSISTANCE
