/datum/action/cooldown/spell/conjure_item/summon_mjollnir
	name = "Summon Mjollnir"
	desc = "Summons the mighty Mjollnir to you for a limited time."
	invocation_type = INVOCATION_SHOUT
	invocation = "I HAV TH POWR"
	button_icon = 'icons/obj/weapons/hammer.dmi'
	button_icon_state = "mjollnir0"
	cooldown_time = 70 SECONDS
	spell_max_level = 1
	item_type = /obj/item/mjollnir

/datum/action/cooldown/spell/conjure_item/summon_mjollnir/post_created(atom/cast_on, atom/created)
	var/obj/item/mjollnir/hammer = created
	hammer.AddComponent(/datum/component/throw_bounce, \
						bounce_charge_max = 1, \
						targeting_range = 5)
	QDEL_IN(hammer, 35 SECONDS)
