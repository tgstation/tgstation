#define SPELLBOOK_CATEGORY_OFFENSIVE "Наступление"
// Offensive wizard spells
/datum/spellbook_entry/fireball
	name = "Fireball"
	desc = "Выпускает в цель взрывной огненный шар. Считается классическим среди всех волшебников."
	spell_type = /datum/action/cooldown/spell/pointed/projectile/fireball
	category = SPELLBOOK_CATEGORY_OFFENSIVE

/datum/spellbook_entry/spell_cards
	name = "Spell Cards"
	desc = "Пылающие жаром быстрые самонаводящиеся карты. Отправляйте своих врагов в теневую реальность с помощью их мистической силы!"
	spell_type = /datum/action/cooldown/spell/pointed/projectile/spell_cards
	category = SPELLBOOK_CATEGORY_OFFENSIVE

/datum/spellbook_entry/rod_form
	name = "Rod Form"
	desc = "Примите форму недвижимого стержня, уничтожающего все на своем пути. Приобретая это заклинание несколько раз, вы также увеличите урон от стержня и дальность его полета."
	spell_type = /datum/action/cooldown/spell/rod_form
	category = SPELLBOOK_CATEGORY_OFFENSIVE

/datum/spellbook_entry/disintegrate
	name = "Smite"
	desc = "Заряжает вашу руку нечестивой энергией, которая может быть использована для того, чтобы заставить тронутую жертву жестоко взорваться."
	spell_type = /datum/action/cooldown/spell/touch/smite
	category = SPELLBOOK_CATEGORY_OFFENSIVE

/datum/spellbook_entry/summon_simians
	name = "Summon Simians"
	desc = "Это заклинание проникает глубоко в элементальный план бананов (обезьяньих, а не клоунских) и \
		вызывает первобытных обезьян и малых горилл, которые тут же выходят из себя и нападают на все вокруг. Веселье! \
		Их слабые, легко манипулируемые умы будут убеждены, что вы один из их союзников, но только на минуту. Если только вы не обезьяна."
	spell_type = /datum/action/cooldown/spell/conjure/simian
	category = SPELLBOOK_CATEGORY_OFFENSIVE

/datum/spellbook_entry/blind
	name = "Blind"
	desc = "Временно ослепляет одну цель."
	spell_type = /datum/action/cooldown/spell/pointed/blind
	category = SPELLBOOK_CATEGORY_OFFENSIVE
	cost = 1

/datum/spellbook_entry/tie_shoes
	name = "Tie Shoes"
	desc = "This unassuming spell first unties, then knots the target's shoes. While weak at first glance, each upgrade quietens the spell, allowing it to untie laceless footwear and even summon shoes to knot!"
	spell_type = /datum/action/cooldown/spell/pointed/untie_shoes
	category = SPELLBOOK_CATEGORY_OFFENSIVE
	cost = 1

/datum/spellbook_entry/mutate
	name = "Mutate"
	desc = "Превращает вас в Халка и на короткое время дает лазерное зрение."
	spell_type = /datum/action/cooldown/spell/apply_mutations/mutate
	category = SPELLBOOK_CATEGORY_OFFENSIVE

/datum/spellbook_entry/fleshtostone
	name = "Flesh to Stone"
	desc = "Заряжает вашу руку силой, позволяющей превращать жертв в неподвижные статуи на длительное время."
	spell_type = /datum/action/cooldown/spell/touch/flesh_to_stone
	category = SPELLBOOK_CATEGORY_OFFENSIVE

/datum/spellbook_entry/teslablast
	name = "Tesla Blast"
	desc = "Зарядите заряд тесла-дуги и выпустите его в случайную ближайшую цель! Пока она заряжается, вы можете свободно перемещаться. Дуга проскакивает между целями и может сбить их с ног."
	spell_type = /datum/action/cooldown/spell/charged/beam/tesla
	category = SPELLBOOK_CATEGORY_OFFENSIVE

/datum/spellbook_entry/lightningbolt
	name = "Lightning Bolt"
	desc = "Выпустите молнию в своих врагов! Она перепрыгивает между целями, но не может сбить их с ног."
	spell_type = /datum/action/cooldown/spell/pointed/projectile/lightningbolt
	category = SPELLBOOK_CATEGORY_OFFENSIVE
	cost = 1

/datum/spellbook_entry/infinite_guns
	name = "Lesser Summon Guns"
	desc = "Зачем перезаряжаться, если у вас бесконечное количество пушек? Вызывает нескончаемый поток винтовок, которые наносят мало урона, но сбивают цели с ног. Для использования требуются обе свободные руки. Изучив это заклинание, вы не сможете выучить Arcane Barrage."
	spell_type = /datum/action/cooldown/spell/conjure_item/infinite_guns/gun
	category = SPELLBOOK_CATEGORY_OFFENSIVE
	cost = 3
	no_coexistence_typecache = list(/datum/action/cooldown/spell/conjure_item/infinite_guns/arcane_barrage)

/datum/spellbook_entry/arcane_barrage
	name = "Arcane Barrage"
	desc = "Выпустите в противников поток магической энергии с помощью этого (мощного) заклинания. Наносит гораздо больше урона, чем Lesser Summon Guns, но не сбивает цели с ног. Для использования требуются обе свободные руки. Изучив это заклинание, вы не сможете выучить Lesser Summon Gun."
	spell_type = /datum/action/cooldown/spell/conjure_item/infinite_guns/arcane_barrage
	category = SPELLBOOK_CATEGORY_OFFENSIVE
	cost = 3
	no_coexistence_typecache = list(/datum/action/cooldown/spell/conjure_item/infinite_guns/gun)

/datum/spellbook_entry/barnyard
	name = "Barnyard Curse"
	desc = "Это заклинание обрекает неудачливую душу на обладание речью и чертами лица домашнего скота."
	spell_type = /datum/action/cooldown/spell/pointed/barnyardcurse
	category = SPELLBOOK_CATEGORY_OFFENSIVE

/datum/spellbook_entry/splattercasting
	name = "Splattercasting"
	desc = "Значительно снижает время действия всех заклинаний, но каждое из них требует затрат крови, а также естественного \
		ее высасывания из вас с течением времени. Вы можете пополнять ее запасы из своих жертв, в частности из их шей."
	spell_type =  /datum/action/cooldown/spell/splattercasting
	category = SPELLBOOK_CATEGORY_OFFENSIVE
	no_coexistence_typecache = list(/datum/action/cooldown/spell/lichdom, /datum/spellbook_entry/ghostliness)

/datum/spellbook_entry/sanguine_strike
	name = "Exsanguinating Strike"
	desc = "Кровожадное заклинание, которое зачаровывает ваш следующий удар оружием, чтобы нанести больше урона, исцелить вас за нанесенный урон и пополнить запасы крови."
	spell_type =  /datum/action/cooldown/spell/sanguine_strike
	category = SPELLBOOK_CATEGORY_OFFENSIVE

/datum/spellbook_entry/scream_for_me
	name = "Scream For Me"
	desc = "Садистско-кровожадное заклинание, наносящее многочисленные тяжелые кровоточащие раны по всему телу жертвы."
	spell_type =  /datum/action/cooldown/spell/touch/scream_for_me
	cost = 1
	category = SPELLBOOK_CATEGORY_OFFENSIVE

/datum/spellbook_entry/item/staffchaos
	name = "Staff of Chaos"
	desc = "Капризный инструмент, который может стрелять всеми видами магии без всякой причины. Не рекомендуется использовать его на дорогих вам людях."
	item_path = /obj/item/gun/magic/staff/chaos
	category = SPELLBOOK_CATEGORY_OFFENSIVE

/datum/spellbook_entry/item/staffchange
	name = "Staff of Change"
	desc = "Артефакт, извергающий потоки сотрясающей энергии, которая заставляет саму форму цели изменяться."
	item_path = /obj/item/gun/magic/staff/change
	category = SPELLBOOK_CATEGORY_OFFENSIVE

/datum/spellbook_entry/item/mjolnir
	name = "Mjolnir"
	desc = "Могучий молот, одолженный у Тора, бога грома. Он трещит от едва сдерживаемой силы. Требует обе руки для раскрытия полного потенциала."
	item_path = /obj/item/mjollnir
	category = SPELLBOOK_CATEGORY_OFFENSIVE

/datum/spellbook_entry/item/singularity_hammer
	name = "Singularity Hammer"
	desc = "Молот, который создает мощное поле гравитации в месте удара, притягивая все, что находится рядом, к точке удара. Требует обе руки для раскрытия полного потенциала."
	item_path = /obj/item/singularityhammer
	category = SPELLBOOK_CATEGORY_OFFENSIVE

/datum/spellbook_entry/item/spellblade
	name = "Spellblade"
	desc = "Меч, способный стрелять вспышками энергии, отрывающими конечности у цели."
	item_path = /obj/item/gun/magic/staff/spellblade
	category = SPELLBOOK_CATEGORY_OFFENSIVE

/datum/spellbook_entry/item/highfrequencyblade
	name = "High Frequency Blade"
	desc = "Невероятно быстрый зачарованный клинок, резонирующий на достаточно высокой частоте, чтобы пронзить все насквозь."
	item_path = /obj/item/highfrequencyblade/wizard
	category = SPELLBOOK_CATEGORY_OFFENSIVE
	cost = 3

/datum/spellbook_entry/item/frog_contract
	name = "Frog Contract"
	desc = "Заключите договор с лягушками, чтобы завести своего собственного разрушительного питомца-хранителя!"
	item_path = /obj/item/frog_contract
	category = SPELLBOOK_CATEGORY_OFFENSIVE

/datum/spellbook_entry/item/staffshrink
	name = "Staff of Shrinking"
	desc = "An artefact that can shrink anything for a reasonable duration. Small structures can be walked over, and small people are very vulnerable (often because their armour no longer fits)."
	item_path = /obj/item/gun/magic/staff/shrink
	category = SPELLBOOK_CATEGORY_OFFENSIVE


#undef SPELLBOOK_CATEGORY_OFFENSIVE
