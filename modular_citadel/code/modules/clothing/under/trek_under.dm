/*/////////////////////////////////////////////////////////////////////////////////
///////																		///////
///////								Star Trek Stuffs						///////
///////																		///////
*//////////////////////////////////////////////////////////////////////////////////
//  <3 Nienhaus && Joan.
// I made the Voy and DS9 stuff tho. - Poojy



/obj/item/clothing/under/rank/trek
	name = "Section 31 Uniform"
	desc = "Oooh... right."
	icon = 'modular_citadel/icons/mob/clothing/trek_item_icon.dmi'
	icon_override = 'modular_citadel/icons/mob/clothing/trek_mob_icon.dmi'
	item_state = ""
	can_adjust = FALSE	//to prevent you from "wearing it casually"

//TOS
/obj/item/clothing/under/rank/trek/command
	name = "Command Uniform"
	desc = "The uniform worn by command officers in the mid 2260s."
	icon_state = "trek_command"
	item_state = "trek_command"
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10,"energy" = 10, "bomb" = 0, "bio" = 10, "rad" = 10, "fire" = 0, "acid" = 0) // Considering only staff heads get to pick it

/obj/item/clothing/under/rank/trek/engsec
	name = "Operations Uniform"
	desc = "The uniform worn by operations officers of the mid 2260s. You feel strangely vulnerable just seeing this..."
	icon_state = "trek_engsec"
	item_state = "trek_engsec"

/obj/item/clothing/under/rank/trek/medsci
	name = "MedSci Uniform"
	desc = "The uniform worn by medsci officers in the mid 2260s."
	icon_state = "trek_medsci"
	item_state = "trek_medsci"
	permeability_coefficient = 0.50

//TNG
/obj/item/clothing/under/rank/trek/command/next
	desc = "The uniform worn by command officers. This one's from the mid 2360s."
	icon_state = "trek_next_command"
	item_state = "trek_next_command"

/obj/item/clothing/under/rank/trek/engsec/next
	desc = "The uniform worn by operation officers. This one's from the mid 2360s."
	icon_state = "trek_next_engsec"
	item_state = "trek_next_engsec"

/obj/item/clothing/under/rank/trek/medsci/next
	desc = "The uniform worn by medsci officers. This one's from the mid 2360s."
	icon_state = "trek_next_medsci"
	item_state = "trek_next_medsci"

//ENT
/obj/item/clothing/under/rank/trek/command/ent
	desc = "The uniform worn by command officers of the 2140s."
	icon_state = "trek_ent_command"
	item_state = "trek_ent_command"

/obj/item/clothing/under/rank/trek/engsec/ent
	desc = "The uniform worn by operations officers of the 2140s."
	icon_state = "trek_ent_engsec"
	item_state = "trek_ent_engsec"

/obj/item/clothing/under/rank/trek/medsci/ent
	desc = "The uniform worn by medsci officers of the 2140s."
	icon_state = "trek_ent_medsci"
	item_state = "trek_ent_medsci"

//VOY
/obj/item/clothing/under/rank/trek/command/voy
	desc = "The uniform worn by command officers of the 2370s."
	icon_state = "trek_voy_command"
	item_state = "trek_voy_command"

/obj/item/clothing/under/rank/trek/engsec/voy
	desc = "The uniform worn by operations officers of the 2370s."
	icon_state = "trek_voy_engsec"
	item_state = "trek_voy_engsec"

/obj/item/clothing/under/rank/trek/medsci/voy
	desc = "The uniform worn by medsci officers of the 2370s."
	icon_state = "trek_voy_medsci"
	item_state = "trek_voy_medsci"

//DS9

/obj/item/clothing/suit/storage/trek/ds9
	name = "Padded Overcoat"
	desc = "The overcoat worn by all officers of the 2380s."
	icon = 'modular_citadel/icons/mob/clothing/trek_item_icon.dmi'
	icon_state = "trek_ds9_coat"
	icon_override = 'modular_citadel/icons/mob/clothing/trek_mob_icon.dmi'
	item_state = "trek_ds9_coat"
	body_parts_covered = CHEST|GROIN|ARMS
	permeability_coefficient = 0.50
	allowed = list(
		/obj/item/flashlight, /obj/item/analyzer,
		/obj/item/radio, /obj/item/tank/internals/emergency_oxygen,
		/obj/item/reagent_containers/hypospray, /obj/item/healthanalyzer,/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/glass/bottle/vial,/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/pill,/obj/item/storage/pill_bottle, /obj/item/restraints/handcuffs,/obj/item/hypospray
		)
	armor = list("melee" = 10, "bullet" = 5, "laser" = 5,"energy" = 5, "bomb" = 5, "bio" = 5, "rad" = 10, "fire" = 10, "acid" = 0)

/obj/item/clothing/suit/storage/trek/ds9/admiral // Only for adminuz
	name = "Admiral Overcoat"
	desc = "Admirality specialty coat to keep flag officers fashionable and protected."
	icon_state = "trek_ds9_coat_adm"
	item_state = "trek_ds9_coat_adm"
	permeability_coefficient = 0.01
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50,"energy" = 50, "bomb" = 50, "bio" = 50, "rad" = 50, "fire" = 50, "acid" = 50)

/obj/item/clothing/under/rank/trek/command/ds9
	desc = "The uniform worn by command officers of the 2380s."
	icon_state = "trek_command"
	item_state = "trek_ds9_command"

/obj/item/clothing/under/rank/trek/engsec/ds9
	desc = "The uniform worn by operations officers of the 2380s."
	icon_state = "trek_engsec"
	item_state = "trek_ds9_engsec"

/obj/item/clothing/under/rank/trek/medsci/ds9
	desc = "The uniform undershirt worn by medsci officers of the 2380s."
	icon_state = "trek_medsci"
	item_state = "trek_ds9_medsci"

//MODERN ish Joan sqrl sprites. I think

//For general use
/obj/item/clothing/suit/storage/fluff/fedcoat
	name = "Federation Uniform Jacket (Red)"
	desc = "A uniform jacket from the United Federation. Starfleet still uses this uniform and there are variations of it. Set phasers to awesome."

	icon = 'modular_citadel/icons/mob/clothing/trek_item_icon.dmi'
	icon_override = 'modular_citadel/icons/mob/clothing/trek_mob_icon.dmi'
	icon_state = "fedcoat"
	item_state = "fedcoat"

	blood_overlay_type = "coat"
	body_parts_covered = CHEST|GROIN|ARMS
	allowed = list(
				/obj/item/tank/internals/emergency_oxygen,
				/obj/item/flashlight,
				/obj/item/analyzer,
				/obj/item/radio,
				/obj/item/gun,
				/obj/item/melee/baton,
				/obj/item/restraints/handcuffs,
				/obj/item/reagent_containers/hypospray,
				/obj/item/hypospray,
				/obj/item/healthanalyzer,
				/obj/item/reagent_containers/syringe,
				/obj/item/reagent_containers/glass/bottle/vial,
				/obj/item/reagent_containers/glass/beaker,
				/obj/item/storage/pill_bottle,
				/obj/item/taperecorder)
	armor = list("melee" = 10, "bullet" = 5, "laser" = 5,"energy" = 5, "bomb" = 5, "bio" = 5, "rad" = 10, "fire" = 10, "acid" = 0)
	var/unbuttoned = 0

	verb/toggle()
		set name = "Toggle coat buttons"
		set category = "Object"
		set src in usr

		if(!usr.canmove || usr.stat || usr.restrained())
			return 0

		switch(unbuttoned)
			if(0)
				icon_state = "[initial(icon_state)]_open"
				item_state = "[initial(item_state)]_open"
				unbuttoned = 1
				usr << "You unbutton the coat."
			if(1)
				icon_state = "[initial(icon_state)]"
				item_state = "[initial(item_state)]"
				unbuttoned = 0
				usr << "You button up the coat."
		usr.update_inv_wear_suit()

	//Variants
/obj/item/clothing/suit/storage/fluff/fedcoat/medsci
		desc = "A uniform jacket from the United Federation. Starfleet still uses this uniform and there are variations of it. Wearing this may make you feel all scientific."
		icon_state = "fedblue"
		item_state = "fedblue"

/obj/item/clothing/suit/storage/fluff/fedcoat/eng
		desc = "A uniform jacket from the United Federation. Starfleet still uses this uniform and there are variations of it.Wearing it may make you feel like checking a warp core, whatever that is."
		icon_state = "fedeng"
		item_state = "fedeng"

/obj/item/clothing/suit/storage/fluff/fedcoat/capt
		desc = "A uniform jacket from the United Federation. Starfleet still uses this uniform and there are variations of it. You feel like a commanding officer of Starfleet."
		icon_state = "fedcapt"
		item_state = "fedcapt"

//"modern" ones for fancy

/obj/item/clothing/suit/storage/fluff/modernfedcoat
	name = "Modern Federation Uniform Jacket"
	desc = "A modern uniform jacket from the United Federation. Their Starfleet had recently started using these uniforms. Wearing this makes you feel like a competant commander."
	icon = 'modular_citadel/icons/mob/clothing/trek_item_icon.dmi'
	icon_override = 'modular_citadel/icons/mob/clothing/trek_mob_icon.dmi'
	icon_state = "fedmodern"
	item_state = "fedmodern"
	body_parts_covered = CHEST|GROIN|ARMS
	allowed = list(
				/obj/item/tank/internals/emergency_oxygen,
				/obj/item/flashlight,
				/obj/item/gun,
				/obj/item/melee/baton,
				/obj/item/restraints/handcuffs,
				/obj/item/taperecorder)
	armor = list("melee" = 45, "bullet" = 25, "laser" = 25,"energy" = 25, "bomb" = 25, "bio" = 25, "rad" = 50, "fire" = 50, "acid" = 50)

	//Variants
/obj/item/clothing/suit/storage/fluff/modernfedcoat/medsci
		desc = "A modern uniform jacket from the United Federation. Their Starfleet had recently started using these uniforms. Wearing this makes you feel like a scientist or a pilot."
		icon_state = "fedmodernblue"
		item_state = "fedmodernblue"

/obj/item/clothing/suit/storage/fluff/modernfedcoat/eng
		desc = "A modern uniform jacket from the United Federation. Their Starfleet had recently started using these uniforms. You feel like you can handle any type of technical engineering problems."
		icon_state = "fedmoderneng"
		item_state = "fedmoderneng"

/obj/item/clothing/suit/storage/fluff/modernfedcoat/sec
		desc = "A modern uniform jacket from the United Federation. Their Starfleet had recently started using these uniforms. This uniform makes you want to protect and serve as an officer."
		icon_state = "fedmodernsec"
		item_state = "fedmodernsec"

/obj/item/clothing/head/caphat/formal/fedcover
	name = "Federation Officer's Cap"
	desc = "An officer's cap that demands discipline from the one who wears it."
	icon = 'modular_citadel/icons/mob/clothing/trek_item_icon.dmi'
	icon_state = "fedcapofficer"
	icon_override = 'modular_citadel/icons/mob/clothing/trek_mob_icon.dmi'
	item_state = "fedcapofficer_mob"
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10,"energy" = 10, "bomb" = 0, "bio" = 10, "rad" = 10, "fire" = 0, "acid" = 0)

	//Variants
/obj/item/clothing/head/caphat/formal/fedcover/medsci
		icon_state = "fedcapsci"
		item_state = "fedcapsci_mob"

/obj/item/clothing/head/caphat/formal/fedcover/eng
		icon_state = "fedcapeng"
		item_state = "fedcapeng_mob"

/obj/item/clothing/head/caphat/formal/fedcover/sec
		icon_state = "fedcapsec"
		item_state = "fedcapsec_mob"
