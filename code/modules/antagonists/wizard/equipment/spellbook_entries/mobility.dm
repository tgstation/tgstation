#define SPELLBOOK_CATEGORY_MOBILITY "Мобильность"
// Wizard spells that aid mobiilty(or stealth?)
/datum/spellbook_entry/mindswap
	name = "Mindswap"
	desc = "Позволяет вам поменяться телами с целью, находящейся рядом с вами. Вы оба заснете, когда это произойдет, и будет совершенно очевидно, что вы - тело цели, если кто-то увидит, как вы это делаете.."
	spell_type = /datum/action/cooldown/spell/pointed/mind_transfer
	category = SPELLBOOK_CATEGORY_MOBILITY

/datum/spellbook_entry/knock
	name = "Knock"
	desc = "Открывает ближайшие двери и шкафы."
	spell_type = /datum/action/cooldown/spell/aoe/knock
	category = SPELLBOOK_CATEGORY_MOBILITY
	cost = 1

/datum/spellbook_entry/blink
	name = "Blink"
	desc = "Случайным образом телепортирует вас на небольшое расстояние."
	spell_type = /datum/action/cooldown/spell/teleport/radius_turf/blink
	category = SPELLBOOK_CATEGORY_MOBILITY

/datum/spellbook_entry/teleport
	name = "Teleport"
	desc = "Телепортирует вас в выбранную вами область."
	spell_type = /datum/action/cooldown/spell/teleport/area_teleport/wizard
	category = SPELLBOOK_CATEGORY_MOBILITY

/datum/spellbook_entry/jaunt
	name = "Ethereal Jaunt"
	desc = "Превращает вас в эфирную форму, временно делая вас невидимым и способным проходить сквозь стены."
	spell_type = /datum/action/cooldown/spell/jaunt/ethereal_jaunt
	category = SPELLBOOK_CATEGORY_MOBILITY

/datum/spellbook_entry/swap
	name = "Swap"
	desc = "Поменяйтесь местами с любой живой целью в пределах девяти плиток. Нажмите ПКМ, чтобы отметить вторую цель. Вы всегда будете меняться местами с основной целью."
	spell_type = /datum/action/cooldown/spell/pointed/swap
	category = SPELLBOOK_CATEGORY_MOBILITY
	cost = 1

/datum/spellbook_entry/item/warpwhistle
	name = "Warp Whistle"
	desc = "Странный свисток, который перенесет вас в далекое безопасное место на станции. В начале каждого использования есть окно уязвимости."
	item_path = /obj/item/warp_whistle
	category = SPELLBOOK_CATEGORY_MOBILITY
	cost = 1

/datum/spellbook_entry/item/staffdoor
	name = "Staff of Door Creation"
	desc = "Особый посох, способный превращать твердые стены в украшенные двери. Пригодится для передвижения при отсутствии другого вида передвижения. Не работает со стеклом."
	item_path = /obj/item/gun/magic/staff/door
	cost = 1
	category = SPELLBOOK_CATEGORY_MOBILITY

/datum/spellbook_entry/item/teleport_rod
	name = /obj/item/teleport_rod::name
	desc = /obj/item/teleport_rod::desc
	item_path = /obj/item/teleport_rod
	cost = 2 // Puts it at 3 cost if you go for safety instant summons, but teleporting anywhere on screen is pretty good.
	category = SPELLBOOK_CATEGORY_MOBILITY

/datum/spellbook_entry/ghostliness
	name = "Forsake Body"
	desc = "A necromantic spell which permanently severs your soul from your body, and partially anchors it to the material plane. \
	In this state, you can enter a state of incorporeality, allowing you to pass through solid matter. This, however, includes \
	most such matter on or inside of you."
	spell_type = /datum/action/cooldown/spell/ghostliness
	category = SPELLBOOK_CATEGORY_MOBILITY
	no_coexistence_typecache = list(/datum/spellbook_entry/lichdom, /datum/spellbook_entry/splattercasting)

#undef SPELLBOOK_CATEGORY_MOBILITY
