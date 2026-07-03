/datum/round_event_control/mice_migration
	name = "Mice Migration"
	typepath = /datum/round_event/mice_migration
	weight = 10
	category = EVENT_CATEGORY_ENTITIES
	description = "A horde of mice arrives, and perhaps even the Rat King themselves."

/datum/round_event/mice_migration
	var/minimum_mice = 5
	var/maximum_mice = 15

/datum/round_event/mice_migration/announce(fake)
	var/cause = pick("космозимы", "сокращения бюджета", "Рагнарёка",
		"того, что космос холодный", "\[ДАННЫЕ УДАЛЕНЫ\]", "климатических изменений",
		"неудачи")
	var/plural = pick("кучка", "орда", "стая", "рой", "не более чем [maximum_mice]")
	var/name = pick("грызунов", "мышей", "проводоедов", "\[ДАННЫЕ УДАЛЕНЫ\]", "поглощающих энергию паразитов")
	var/movement = pick("мигрировала", "зароилась", "убежала в панике", "проникла")
	var/location = pick("технические тоннели", "технические помещения",
		"\[ДАННЫЕ УДАЛЕНЫ\]", "кишащее сочными проводами место")

	priority_announce("Из-за [cause], [plural] [name] [movement] \
		в [location].", "Оповещение о миграции",
		'sound/mobs/non-humanoids/mouse/mousesqueek.ogg')

/datum/round_event/mice_migration/start()
	SSminor_mapping.trigger_migration(rand(minimum_mice, maximum_mice))
