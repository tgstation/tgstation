#define DEFAULT_SPRITE_LIST "default_sprites"

/datum/controller/subsystem/accessories
	var/list/body_markings

/datum/controller/subsystem/accessories/setup_lists()
	. = ..()

	body_markings = init_sprite_accessory_subtypes(/datum/sprite_accessory/body_marking)[DEFAULT_SPRITE_LIST]

#undef DEFAULT_SPRITE_LIST
