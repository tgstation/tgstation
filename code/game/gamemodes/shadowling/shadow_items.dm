
//////SHADOW TUMOR!
/obj/item/organ/internal/shadowtumor
	name = "black tumor"
	desc = "A tiny black mass with red tendrils trailing from it. It seems to shrivel in the light."
	icon_state = "blacktumor"
	w_class = 1
	zone = "head"
	slot = "brain_tumor"
	var/health = 5

/obj/item/organ/internal/shadowtumor/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/organ/internal/shadowtumor/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/organ/internal/shadowtumor/process()
	if(isturf(loc))
		var/turf/T = loc
		var/light_count = T.get_lumcount()
		if(light_count > 0.25 && health > 0) //Die in the light
			min(health-1, 0)
		else if(light_count < 2 && health < 3) //Heal in the dark
			health = max(health+1, 5)
		if(health < 1)
			visible_message("<span class='warning'>[src] collapses in on itself!</span>")
			qdel(src)
	else
		health = max(health+0.25, 5)

/obj/item/organ/internal/shadowtumor/Insert(mob/living/carbon/M, special, drop_if_replaced)
	. = ..()
	add_thrall(M.mind)

/obj/item/organ/internal/shadowtumor/on_find(mob/living/finder)
	. = ..()
	finder.visible_message("<span class='danger'>[finder] opens up [owner]'s skull, revealing a pulsating black mass on [owner.p_their()] brain, with red tendrils attaching to other parts of [owner.p_their()] brain.</span>'")

/obj/item/organ/internal/shadowtumor/Remove(mob/living/carbon/M, special)
	if(M.dna.species.id == "l_shadowling") //Empowered thralls cannot be deconverted
		to_chat(M, "<span class='shadowling'><b><i>NOT LIKE THIS!</i></b></span>")
		M.visible_message("<span class='danger'>[M] suddenly slams upward and knocks down everyone!</span>")

		M.resting = FALSE //Remove all stuns
		M.SetStun(0, 0)
		M.SetKnockdown(0)
		M.SetUnconscious(0)
		for(var/mob/living/user in range(2, src))
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.Knockdown(6)
				C.apply_damage(20, "brute", "chest")
			else if(issilicon(user))
				var/mob/living/silicon/S = user
				S.Knockdown(8)
				S.apply_damage(20, "brute")
				playsound(S, 'sound/effects/bang.ogg', 50, 1)
		return FALSE
	var/obj/item/organ/eyes/eyes = M.getorganslot(ORGAN_SLOT_EYES)
	eyes.lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
	eyes.sight_flags = initial(eyes.sight_flags)
	M.update_sight()
	remove_thrall(M.mind)
	M.visible_message("<span class='warning'>A strange black mass falls from [M]'s head!</span>")
	new /obj/item/organ/internal/shadowtumor(get_turf(M))
	return ..()



//these weren't included in the species sprite by the sprite author

/obj/item/clothing/suit/space/shadowling
	name = "chitin shell"
	desc = "A dark, semi-transparent shell. Protects against vacuum, but not against the light of the stars." //Still takes damage from spacewalking but is immune to space itself
	alternate_worn_icon = 'icons/mob/suit.dmi'
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "sl_shell"
	item_state = "sl_shell"
	body_parts_covered = FULL_BODY //Shadowlings are immune to space
	cold_protection = FULL_BODY
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEGLOVES | HIDESHOES | HIDEJUMPSUIT
	slowdown = 0
	heat_protection = null //You didn't expect a light-sensitive creature to have heat resistance, did you?
	max_heat_protection_temperature = null
	armor = list(melee = 25, bullet = 0, laser = 0, energy = 0, bomb = 25, bio = 100, rad = 100)
	flags_1 = ABSTRACT_1 | NODROP_1 | DROPDEL_1 | THICKMATERIAL_1 | STOPSPRESSUREDMAGE_1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF


/obj/item/clothing/head/shadowling
	name = "chitin helm"
	desc = "A helmet-like enclosure of the head."
	alternate_worn_icon = 'icons/mob/suit.dmi'
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "sl_head"
	item_state = "sl_head"
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	flags_1 = ABSTRACT_1 | NODROP_1 | DROPDEL_1 | STOPSPRESSUREDMAGE_1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/alien/resin/wall/shadowling //For chrysalis
	name = "chrysalis wall"
	desc = "Some sort of purple substance in an egglike shape. It pulses and throbs from within and seems impenetrable."
	max_integrity = INFINITY