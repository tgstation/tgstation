/////////// derelictsulaco items

/obj/item/paper/crumpled/ruins/derelict_sulaco/captain
	name = "bloody paper scrap"
	icon_state = "scrap_bloodied"
	default_raw_text = "We gave it our all, yet we still lost. Now we're just waiting for the self-destruct to go off. But I had a good run. We all did. I led and fought with the bravest, most sincere people I ever had the pleasure of meeting.<BR><BR>Semper fi.<BR><BR>*Captain Romero Hernan*"

/obj/item/paper/ruins/derelict_sulaco/birthday
	name = "to our captain"
	desc = "Although faint, you can make out the words 'always faithful!' on the back of this photo."
	icon = 'icons/obj/weapons/items_and_weapons.dmi'
	icon_state = "photo"
	show_written_words = FALSE
	
	default_raw_text = "*This looks to be a photo of the captain's birthday, held in a festivized cafeteria. The crew's smiles and laughter beam through discolored film, where one staff officer has his superior enveloped in a warm hug. Everyone looks happy together. A gift is being forced into the captain's hands: some silly, mischievous-looking 'runner' plushie.*"

/obj/item/clothing/suit/armor/vest/marine/sulaco
	name = "damaged tactical armor vest"
	desc = "An old, roughed up set of the finest mass produced, stamped plasteel armor. This piece of equipment has lost most of its protective qualities to time, yet it is still more than serviceable for giving xenos the middle finger."
	armor_type = /datum/armor/derelict_marine
 
/obj/item/clothing/head/helmet/marine/sulaco
	name = "damaged tactical combat helmet"
	desc = "A tactical black helmet, barely sealed from outside hazards with a plate of glass and not much else. Not as protective as it used to be, but it is still completely functional."
	armor_type = /datum/armor/derelict_marine

/datum/armor/derelict_marine
	melee = 20
	bullet = 20
	bio = 100
	fire = 40
	acid = 50
	wound = 20
