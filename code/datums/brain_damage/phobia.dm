/datum/brain_trauma/mild/phobia
	name = "Фобия"
	desc = "Пациент чего-то необоснованно боится."
	scan_desc = "фобия"
	symptoms = "При воздействии определённого стимула испытывает \
		немедленную реакцию тревоги или страха, значительно превышающую обычную, \
		что может приводить к паническим атакам или нарушению социальной и профессиональной деятельности. \
		Физический контакт, такой как объятия, или приём лекарств, например, Псикодин, может уменьшить выраженность реакции."
	gain_text = span_warning("Вас начинают сильно беспокоить стандартные вещи...")
	lose_text = span_notice("Вы больше не испытываете страха перед стандартными вещами.")
	/// What do we fear exactly?
	var/phobia_type
	/// Specific terror handler to apply, in case we want
	var/terror_handler = /datum/terror_handler/phobia_source
	/// What mood event to apply when we see the thing & freak out.
	var/mood_event_type = /datum/mood_event/phobia

/datum/brain_trauma/mild/phobia/New(new_phobia_type)
	if(new_phobia_type)
		phobia_type = new_phobia_type

	if(!phobia_type)
		phobia_type = pick(GLOB.phobia_types)

	gain_text = span_warning("Вы начинаете находить [phobia_type] очень нервирующим...")
	lose_text = span_notice("Вы больше не боитесь [phobia_type].")
	scan_desc += " of [phobia_type]"
	return ..()

/datum/brain_trauma/mild/phobia/on_gain()
	. = ..()
	var/datum/component/fearful/fear = owner.AddComponentFrom(REF(src), /datum/component/fearful, list(/datum/terror_handler/startle))
	var/datum/terror_handler/phobia_source/phobia = fear.add_handler(terror_handler, REF(src))
	phobia.trigger_regex = GLOB.phobia_regexes[phobia_type]
	phobia.trigger_mobs = GLOB.phobia_mobs[phobia_type]
	phobia.trigger_objs = GLOB.phobia_objs[phobia_type]
	phobia.trigger_turfs = GLOB.phobia_turfs[phobia_type]
	phobia.trigger_species = GLOB.phobia_species[phobia_type]
	phobia.mood_event_type = mood_event_type

/datum/brain_trauma/mild/phobia/on_lose(silent)
	. = ..()
	owner.RemoveComponentSource(REF(src), /datum/component/fearful)

// Defined phobia types for badminry, not included in the RNG trauma pool to avoid diluting.

/datum/brain_trauma/mild/phobia/aliens
	phobia_type = "пришельцев"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/anime
	phobia_type = "аниме"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/authority
	phobia_type = "власти"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/birds
	phobia_type = "птиц"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/blood
	phobia_type = "крови"
	random_gain = FALSE
	terror_handler = /datum/terror_handler/phobia_source/blood

/datum/brain_trauma/mild/phobia/clowns
	phobia_type = "клоунов"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/conspiracies
	phobia_type = "заговоров"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/doctors
	phobia_type = "врачей"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/falling
	phobia_type = "падения"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/fish
	phobia_type = "рыбы"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/greytide
	phobia_type = "грейтайда"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/guns
	phobia_type = "оружия"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/insects
	phobia_type = "насекомых"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/lizards
	phobia_type = "ящериц"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/ocky_icky
	phobia_type = "ocky icky"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/robots
	phobia_type = "роботов"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/security
	phobia_type = "службы безопасности"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/skeletons
	phobia_type = "скелетов"
	mood_event_type = /datum/mood_event/spooked
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/snakes
	phobia_type = "змей"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/space
	phobia_type = "пространства"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/spiders
	phobia_type = "пауков"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/strangers
	phobia_type = "незнакомцев"
	random_gain = FALSE

/datum/brain_trauma/mild/phobia/supernatural
	phobia_type = "сверхъестественного"
	random_gain = FALSE
