/obj/effect/mob_spawn/human/lavaknight
	name = "odd cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise a faint glow underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "a displaced knight from another dimension"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	random = TRUE
	outfit = /datum/outfit/lavaknight
	mob_species = /datum/species/human
	flavour_text = "<font size=3><b>Y</b></font><b>ou are a knight who conveniently has some form of retrograde amnesia. \
	You cannot remember where you came from. However, a few things remain burnt into your mind, most prominently a vow to never harm another sapient being under any circumstances unless it is hellbent on ending your life. \
	Remember: hostile creatures and such are fair game for attacking, but <span class='danger'>under no circumstances are you to attack anything capable of thought and/or speech</span> unless it has made it its life's calling to chase you to the ends of the earth."
	assignedrole = "Cydonian Knight"

/obj/effect/mob_spawn/human/lavaknight/special(mob/living/new_spawn)
	if(ishuman(new_spawn))
		var/mob/living/carbon/human/H = new_spawn
		H.dna.features["mam_ears"] = "Cat, Big"	//cat people
		H.dna.features["mcolor"] = H.hair_color
		H.update_body()

/obj/effect/mob_spawn/human/lavaknight/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

/datum/outfit/lavaknight
	name = "Cydonian Knight"
	uniform = /obj/item/clothing/under/assistantformal
	mask = /obj/item/clothing/mask/breath
	shoes = /obj/item/clothing/shoes/sneakers/black
	r_pocket = /obj/item/melee/transforming/energy/sword/cx
	suit = /obj/item/clothing/suit/space/hardsuit/lavaknight
	suit_store = /obj/item/tank/internals/oxygen
	id = /obj/item/card/id/knight

/datum/outfit/lavaknight/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/knight/W = H.wear_id
	W.assignment = "Knight"
	W.registered_name = H.real_name
	W.id_color = "#0000FF" //Regular knights get simple blue. Doesn't matter much because it's variable anyway
	W.update_label(H.real_name)
	W.update_icon()

/datum/outfit/lavaknight/captain
	name ="Cydonian Knight Captain"
	l_pocket = /obj/item/twohanded/hypereutactic

/datum/outfit/lavaknight/captain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/knight/W = H.wear_id
	W.assignment = "Knight Captain"
	W.registered_name = H.real_name
	W.id_color = "#FFD700" //Captains get gold, duh. Doesn't matter because it's variable anyway
	W.update_label(H.real_name)
	W.update_icon()


/obj/effect/mob_spawn/human/lavaknight/captain
	name = "odd gilded cryogenics pod"
	desc = "A humming cryo pod that appears to be gilded. You can barely recognise a faint glow underneath the built up ice. The machine is attempting to wake up its occupant."
	flavour_text = "<font size=3><b>Y</b></font><b>ou are a knight who conveniently has some form of retrograde amnesia. \
	You cannot remember where you came from. However, a few things remain burnt into your mind, most prominently a vow to never harm another sapient being under any circumstances unless it is hellbent on ending your life. \
	Remember: hostile creatures and such are fair game for attacking, but <span class='danger'>under no circumstances are you to attack anything capable of thought and/or speech</span> unless it has made it its life's calling to chase you to the ends of the earth. \
	You feel a natural instict to lead, and as such, you should strive to lead your comrades to safety, and hopefully home. You also feel a burning determination to uphold your vow, as well as your fellow comrade's."
	outfit = /datum/outfit/lavaknight/captain
