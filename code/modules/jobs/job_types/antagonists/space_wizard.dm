/datum/job/space_wizard
	title = ROLE_WIZARD
	faction = ROLE_WIZARD

/datum/job/space_wizard/get_roundstart_spawn_point()
	SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_WIZARDDEN)
	return pick(GLOB.wizardstart)

/datum/job/space_wizard/get_latejoin_spawn_point()
	SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_WIZARDDEN)
	return pick(GLOB.wizardstart)
