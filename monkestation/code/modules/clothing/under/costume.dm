/obj/item/clothing/under/costume/villain
	alternative_screams = list(	'monkestation/sound/misc/robbie/robbie1.ogg',
								'monkestation/sound/misc/robbie/robbie2.ogg',
								'monkestation/sound/misc/robbie/robbie3.ogg',
								'monkestation/sound/misc/robbie/robbie4.ogg',
								'monkestation/sound/misc/robbie/robbie5.ogg',
								'monkestation/sound/misc/robbie/robbie6.ogg',
								'monkestation/sound/misc/robbie/robbie7.ogg',
								'monkestation/sound/misc/robbie/robbie8.ogg',
								'monkestation/sound/misc/robbie/robbie9.ogg',
								'monkestation/sound/misc/robbie/robbie10.ogg',
								'monkestation/sound/misc/robbie/robbie11.ogg',
								'monkestation/sound/misc/robbie/robbie12.ogg',
								'monkestation/sound/misc/robbie/robbie13.ogg',
								'monkestation/sound/misc/robbie/robbie14.ogg',
								'monkestation/sound/misc/robbie/robbie15.ogg')

/obj/item/clothing/under/costume/skyrat
	icon = 'monkestation/icons/obj/clothing/skyrat/under/costume.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/skyrat/under/costume.dmi'
	can_adjust = FALSE

//My least favorite file. Just... try to keep it sorted. And nothing over the top (The victorian dresses were way too much)

/*
*	UNSORTED
*/
/obj/item/clothing/under/costume/skyrat/cavalry
	name = "cavalry uniform"
	desc = "Dedicate yourself to something better. To loyalty, honour, for it only dies when everyone abandons it."
	icon_state = "cavalry" //specifically an 1890s US Army Cavalry Uniform

/obj/item/clothing/under/costume/deckers/alt //not even going to bother re-pathing this one because its such a unique case of 'TGs item has something but this alt doesnt'
	name = "deckers maskless outfit"
	desc = "A decker jumpsuit with neon blue coloring."
	icon = 'monkestation/icons/obj/clothing/skyrat/under/costume.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/skyrat/under/costume.dmi'
	icon_state = "decking_jumpsuit"
	can_adjust = FALSE

/obj/item/clothing/under/costume/worldchampiongi
	name = "World Champion Gi"
	desc = "Only the strongest wears this Gi, everyone else are just using tricks."
	icon = 'monkestation/icons/obj/clothing/uniforms.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/uniform.dmi'
	icon_state = "worldchampion_gi"
	can_adjust = FALSE

/obj/item/clothing/under/costume/streetmime
	name = "street mime suit"
	desc = "Although unorthodoxly colorful, it is practical for standing out in space France."
	icon = 'monkestation/icons/obj/clothing/uniforms.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/uniform.dmi'
	icon_state = "streetmime"
	can_adjust = FALSE

/obj/item/clothing/under/costume/milkman
	name = "milkman suit"
	desc = "I am the Milkman. My milk is delicious!"
	icon = 'monkestation/icons/obj/clothing/uniforms.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/uniform.dmi'
	icon_state = "milkman"
	can_adjust = FALSE

/obj/item/clothing/under/costume/tragic
	name = "tragic mime suit"
	desc = "A skin-tight black suit for theatre actors. You feel the need to remind a doctor to eat food and sleep."
	icon = 'monkestation/icons/obj/clothing/uniforms.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/uniform.dmi'
	icon_state = "tragic"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS|HANDS|FEET
	alternate_worn_layer = GLOVES_LAYER
	can_adjust = FALSE

/obj/item/clothing/under/costume/bee
	name = "bee hide costume"
	desc = "A suit made of beehide"
	icon = 'monkestation/icons/obj/clothing/uniforms.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/uniform.dmi'
	icon_state = "bee"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	can_adjust = FALSE

/*
*	LUNAR AND JAPANESE CLOTHES
*/

/obj/item/clothing/under/costume/skyrat/kamishimo
	name = "kamishimo"
	desc = "A traditional ancient Earth Japanese Kamishimo."
	icon_state = "kamishimo"

/obj/item/clothing/under/costume/skyrat/kimono
	name = "fancy kimono"
	desc = "A traditional ancient Earth Japanese Kimono. Longer and fancier than a yukata."
	icon_state = "kimono"
	body_parts_covered = CHEST|GROIN|ARMS
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	alternate_worn_layer = ABOVE_SHOES_LAYER

/*
*	CHRISTMAS CLOTHES
*/

/obj/item/clothing/under/costume/skyrat/christmas
	name = "christmas costume"
	desc = "Can you believe it guys? Christmas. Just a lightyear away!" //Lightyear is a measure of distance I hate it being used for this joke :(
	icon_state = "christmas"

/obj/item/clothing/under/costume/skyrat/christmas/green
	name = "green christmas costume"
	desc = "4:00, wallow in self-pity. 4:30, stare into the abyss. 5:00, solve world hunger, tell no one. 5:30, jazzercize; 6:30, dinner with me. I can't cancel that again. 7:00, wrestle with my self-loathing. I'm booked. Of course, if I bump the loathing to 9, I could still be done in time to lay in bed, stare at the ceiling and slip slowly into madness."
	icon_state = "christmas_green"

/obj/item/clothing/under/costume/skyrat/christmas/croptop
	name = "sexy christmas costume"
	desc = "About 550 years since the release of Mariah Carey's \"All I Want For Christmas is You\", society has yet to properly recover from its repercussions. Some still keep a gun as their christmas mantlepiece, just in case she's heard singing on their rooftop late in the night..."
	icon_state = "christmas_crop"
	body_parts_covered = CHEST|GROIN
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

/obj/item/clothing/under/costume/skyrat/christmas/croptop/green
	name = "sexy green christmas costume"
	desc = "Stupid. Ugly. Out of date. If I can't find something nice to wear I'm not going."
	icon_state = "christmas_crop_green"
