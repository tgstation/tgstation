//////////////////////////Demonic Watcher - Start//////////////////////////
/obj/item/crusher_trophy/demon_core
	name = "demonic core"
	desc = "The chipped core of a demonic watcher, it gently hums with weak bluespace energy."
	icon = 'modular_skyrat/modules/modular_items/icons/obj/lavaland/artefacts.dmi'
	icon_state = "demon_core"
	denied_type = /obj/item/crusher_trophy/demon_core

/obj/item/crusher_trophy/demon_core/effect_desc()
	return "mark detonation to normalise your body and core temperature"

/obj/item/crusher_trophy/demon_core/on_mark_detonation(mob/living/target, mob/living/user)
	user.bodytemperature = user.get_body_temp_normal()
	if(ishuman(user))
		var/mob/living/carbon/human/humi = user
		humi.coretemperature = humi.get_body_temp_normal()
	..()

/mob/living/simple_animal/hostile/asteroid/ice_demon/spawn_crusher_loot()
	for(var/item_path in crusher_loot)
		new item_path(loc)
//////////////////////////Demonic Watcher - End//////////////////////////
