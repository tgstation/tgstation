///Unleashes a honkerblast similar to the honkmech weapon, but with more granular control.
/proc/honkerblast(atom/origin, light_range = 1, medium_range = 0, heavy_range = 0)
	var/origin_turf = get_turf(origin)
	var/list/lightly_honked = list()
	var/list/properly_honked = list()
	var/list/severely_honked = list()

	playsound(origin_turf, 'sound/items/airhorn.ogg', 100, TRUE)

	for(var/mob/living/carbon/victim as anything in hearers(max(light_range, medium_range, heavy_range), origin_turf))
		if(!victim.can_hear())
			continue
		var/distance = get_dist(origin_turf, victim.loc)
		if(distance <= heavy_range)
			severely_honked += victim
		else if(distance <= medium_range)
			properly_honked += victim
		else if(distance <= light_range)
			lightly_honked += victim

	for(var/mob/living/carbon/victim in severely_honked)
		victim.Unconscious(40)
		victim.Stun(100)
		victim.adjust_stutter(30 SECONDS)
		victim.set_jitter_if_lower(1000 SECONDS)
		var/obj/item/organ/internal/ears/ears = victim.getorganslot(ORGAN_SLOT_EARS)
		ears?.adjustEarDamage(10, 15)
		to_chat(victim, "<font color='red' size='8'>HONK</font>")
		var/obj/item/clothing/shoes/victim_shoes = victim.get_item_by_slot(ITEM_SLOT_FEET)
		if(!victim_shoes?.can_be_tied)
			continue
		victim_shoes.adjust_laces(SHOES_KNOTTED)

	for(var/mob/living/carbon/victim in properly_honked)
		victim.Paralyze(20)
		victim.Stun(50)
		victim.set_jitter_if_lower(500 SECONDS)
		var/obj/item/organ/internal/ears/ears = victim.getorganslot(ORGAN_SLOT_EARS)
		ears?.adjustEarDamage(7, 10)
		to_chat(victim, "<font color='red' size='5'>HONK</font>")

	for(var/mob/living/carbon/victim in lightly_honked)
		victim.Knockdown(20)
		victim.set_jitter_if_lower(200 SECONDS)
		var/obj/item/organ/internal/ears/ears = victim.getorganslot(ORGAN_SLOT_EARS)
		ears?.adjustEarDamage(4, 5)
		to_chat(victim, "<font color='red' size='2'>HONK</font>")
