/datum/species/gehennite
	name = "Gehennite"
	brutemod = 1.2
	burnmod = 1.2
	coldmod = 1.2
	heatmod = 1.2
	id = "gehennite"
	mutantears = /obj/item/organ/ears/gehennite
	species_traits = list(LIPS)
	alternative_body_icon = 'icons/mob/gehennite_parts.dmi'
	var/awoken = FALSE
	var/datum/component/hand_offset

/datum/species/gehennite/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.become_blind(ROUNDSTART_TRAIT)
	H.overlay_fullscreen("total", /obj/screen/fullscreen/color_vision/black)

/datum/species/gehennite/on_species_loss(mob/living/carbon/human/H)
	.=..()
	H.clear_fullscreen("total")

/datum/action/innate/echo
	name = "Echolocate"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "meson"

/datum/action/innate/echo/Activate()
	SEND_SIGNAL(owner, COMSIG_ECHOLOCATION_PING)

/datum/species/gehennite/proc/awaken(mob/living/carbon/human/H) //uh oh spaghettio
	var/Itemlist = H.get_equipped_items(TRUE)
	Itemlist += H.held_items
	for(var/obj/item/W in Itemlist)
		H.dropItemToGround(W)
	hand_offset = H.AddComponent(/datum/component/hand_offset)

	brutemod = 0.7
	burnmod = 0.65
	coldmod = 0
	heatmod = 0.5
	inherent_traits = list(TRAIT_RESISTHEAT,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE, TRAIT_RADIMMUNE, TRAIT_VIRUSIMMUNE, TRAIT_PIERCEIMMUNE, TRAIT_NODISMEMBER, TRAIT_NOLIMBDISABLE,TRAIT_NOHUNGER, TRAIT_NOFIRE)
	sexes = 0
	hair_alpha = 0
	punchdamagelow = 30
	punchdamagehigh = 40
	punchstunthreshold = 25
	no_equip = list(SLOT_WEAR_MASK,SLOT_WEAR_ID ,SLOT_EARS, SLOT_WEAR_SUIT, SLOT_GLOVES, SLOT_SHOES, SLOT_W_UNIFORM, SLOT_S_STORE)
	nojumpsuit = TRUE
	damage_overlay_type = ""
	limbs_id = "gehennite"
	species_traits = list(NO_UNDERWEAR,NOEYESPRITES,NOFLASH,DRINKSBLOOD)
	alternative_body_icon = 'icons/mob/gehennite_parts.dmi'
	special_step_sounds = list('sound/creatures/gehennite_stomp.ogg')
	attack_sound = 'sound/creatures/gehennite_attack.ogg'
	awoken = TRUE
	say_mod = "bellows"
	H.update_body()
	H.update_hair()
	H.update_body_parts()



