/obj/projectile/energy/fisher
	name = "attenuated kinetic force"
	alpha = 0
	damage = 0
	damage_type = BRUTE
	armor_flag = BOMB
	range = 21
	projectile_phasing = PASSTABLE | PASSMOB | PASSMACHINE | PASSSTRUCTURE
	hitscan = TRUE
	var/disrupt_duration = 10 SECONDS

/obj/projectile/energy/fisher/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	var/lights_flickered = 0
	if(SEND_SIGNAL(target, COMSIG_HIT_BY_SABOTEUR, disrupt_duration) & COMSIG_SABOTEUR_SUCCESS)
		lights_flickered++
	if(!isliving(target))
		return
	var/list/things_to_disrupt = list()
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		things_to_disrupt = human_target.get_all_gear()
	else
		var/mob/living/living_target = target // i guess this covers borgs too?
		things_to_disrupt = living_target.get_equipped_items(include_pockets = TRUE, include_accessories = TRUE)
	for(var/obj/item/thingy as anything in things_to_disrupt)
		if(SEND_SIGNAL(thingy, COMSIG_HIT_BY_SABOTEUR, disrupt_duration) & COMSIG_SABOTEUR_SUCCESS)
			lights_flickered++
	if(lights_flickered)
		to_chat(target, span_warning("Your light [lights_flickered > 1 ? "sources flick" : "source flicks"] off."))

/obj/projectile/energy/fisher/melee
	range = 1
	suppressed = SUPPRESSED_VERY
	disrupt_duration = 20 SECONDS
