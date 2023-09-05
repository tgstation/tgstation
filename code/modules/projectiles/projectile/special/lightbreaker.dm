/obj/projectile/energy/fisher
	name = "attenuated kinetic force"
	alpha = 0
	damage = 0
	damage_type = BRUTE
	armor_flag = BOMB
	range = 7
	projectile_phasing = PASSTABLE | PASSMOB | PASSMACHINE | PASSSTRUCTURE
	hitscan = TRUE
	var/disrupt_duration = 2 SECONDS

/obj/projectile/energy/fisher/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	var/list/things_to_disrupt = list()
	if(!isliving(target))
		SEND_SIGNAL(target, COMSIG_DISRUPTED_LIGHTS, disrupt_duration) // we just send this through if it's not something living
		return
	var/lights_flickered = 0
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		things_to_disrupt = human_target.get_all_gear()
	else
		var/mob/living/living_target = target // i guess this covers borgs too?
		things_to_disrupt = living_target.get_equipped_items(include_pockets = TRUE, include_accessories = TRUE)
	for(var/obj/item/thingy as anything in things_to_disrupt)
		if(istype(thingy, /obj/item/flashlight))
			var/obj/item/flashlight/light = thingy
			SEND_SIGNAL(light, COMSIG_DISRUPTED_LIGHTS, disrupt_duration)
			lights_flickered++
			continue
		var/datum/component/seclite_attachable/attached = thingy.GetComponent(/datum/component/seclite_attachable)
		if(attached?.light)
			SEND_SIGNAL(attached.parent, COMSIG_DISRUPTED_LIGHTS, disrupt_duration)
			lights_flickered++
	if(lights_flickered)
		to_chat(target, span_warning("Your light [lights_flickered > 1 ? "sources flick" : "source flicks"] off."))
