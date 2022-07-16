//Chaplain Suit Subtypes
//If any new staple chaplain items get added, put them in these lists
/obj/item/clothing/suit/chaplainsuit
	allowed = list(/obj/item/storage/book/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)
	worn_icon = 'icons/mob/clothing/suits/chaplain.dmi'

/obj/item/clothing/suit/chaplainsuit/armor
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor = list(MELEE = 50, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 0, BIO = 0, FIRE = 80, ACID = 80, WOUND = 20)
	clothing_flags = BLOCKS_SHOVE_KNOCKDOWN
	strip_delay = 80
	equip_delay_other = 60

/obj/item/clothing/suit/hooded/chaplainsuit
	allowed = list(/obj/item/storage/book/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)

//Suits
/obj/item/clothing/suit/chaplainsuit/holidaypriest
	name = "holiday priest"
	desc = "This is a nice holiday, my son."
	icon_state = "holidaypriest"
	inhand_icon_state = "w_suit"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/chaplainsuit/nun
	name = "nun robe"
	desc = "Maximum piety in this star system."
	icon_state = "nun"
	inhand_icon_state = "nun"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS|HANDS
	flags_inv = HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/chaplainsuit/bishoprobe
	name = "bishop's robes"
	desc = "Glad to see the tithes you collected were well spent."
	icon_state = "bishoprobe"
	inhand_icon_state = "bishoprobe"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/chaplainsuit/armor/studentuni
	name = "student robe"
	desc = "The uniform of a bygone institute of learning."
	icon_state = "studentuni"
	inhand_icon_state = "studentuni"
	body_parts_covered = ARMS|CHEST

/obj/item/clothing/suit/chaplainsuit/armor/witchhunter
	name = "witchunter garb"
	desc = "This worn outfit saw much use back in the day."
	icon_state = "witchhunter"
	inhand_icon_state = "witchhunter"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS

/obj/item/clothing/suit/hooded/chaplainsuit/monkhabit
	name = "monk's habit"
	desc = "A few steps above rended sackcloth."
	icon_state = "monkfrock"
	worn_icon = 'icons/mob/clothing/suits/chaplain.dmi'
	inhand_icon_state = "monkfrock"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	hoodtype = /obj/item/clothing/head/hooded/monkhabit

/obj/item/clothing/head/hooded/monkhabit
	name = "monk's hood"
	desc = "For when a man wants to cover up his tonsure."
	icon_state = "monkhood"
	inhand_icon_state = "monkhood"
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEEARS

/obj/item/clothing/suit/chaplainsuit/monkrobeeast
	name = "eastern monk's robes"
	desc = "Best combined with a shaved head."
	icon_state = "monkrobeeast"
	inhand_icon_state = "monkrobeeast"
	body_parts_covered = GROIN|LEGS
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/chaplainsuit/whiterobe
	name = "white robe"
	desc = "Good for clerics and sleepy crewmembers."
	icon_state = "whiterobe"
	inhand_icon_state = "whiterobe"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/chaplainsuit/clownpriest
	name = "Robes of the Honkmother"
	desc = "Meant for a clown of the cloth."
	icon_state = "clownpriest"
	inhand_icon_state = "clownpriest"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEJUMPSUIT
	allowed = list(/obj/item/megaphone/clown, /obj/item/soap, /obj/item/food/pie/cream, /obj/item/bikehorn, /obj/item/bikehorn/golden, /obj/item/bikehorn/airhorn, /obj/item/instrument/bikehorn, /obj/item/reagent_containers/food/drinks/soda_cans/canned_laughter, /obj/item/toy/crayon, /obj/item/toy/crayon/spraycan, /obj/item/toy/crayon/spraycan/lubecan, /obj/item/grown/bananapeel, /obj/item/food/grown/banana)

/obj/item/clothing/head/helmet/chaplain/clock
	name = "forgotten helmet"
	desc = "It has the unyielding gaze of a god eternally forgotten."
	icon_state = "clockwork_helmet"
	inhand_icon_state = "clockwork_helmet_inhand"
	armor = list(MELEE = 50, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 0, BIO = 0, FIRE = 80, ACID = 80)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	strip_delay = 8 SECONDS
	dog_fashion = null

/obj/item/clothing/suit/chaplainsuit/armor/clock
	name = "forgotten armour"
	desc = "It sounds like hissing steam, ticking cogs, gone silent, It looks like a dead machine, trying to tick with life."
	icon_state = "clockwork_cuirass"
	inhand_icon_state = "clockwork_cuirass_inhand"
	allowed = list(/obj/item/storage/book/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)
	slowdown = 0
	clothing_flags = NONE

/obj/item/clothing/head/helmet/chaplain
	name = "crusader helmet"
	desc = "Deus Vult."
	icon_state = "knight_templar"
	inhand_icon_state = "knight_templar"
	armor = list(MELEE = 50, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 0, BIO = 0, FIRE = 80, ACID = 80)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	strip_delay = 80
	dog_fashion = null

/obj/item/clothing/suit/chaplainsuit/armor/templar
	name = "crusader armour"
	desc = "God wills it!"
	icon_state = "knight_templar"
	inhand_icon_state = "knight_templar"
	allowed = list(/obj/item/storage/book/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)
	slowdown = 0
	clothing_flags = NONE

/obj/item/clothing/head/helmet/chaplain/cage
	name = "cage"
	desc = "A cage that restrains the will of the self, allowing one to see the profane world for what it is."
	flags_inv = NONE
	icon_state = "cage"
	inhand_icon_state = "cage"
	worn_y_offset = 7

/obj/item/clothing/head/helmet/chaplain/ancient
	name = "ancient helmet"
	desc = "None may pass!"
	icon_state = "knight_ancient"
	inhand_icon_state = "knight_ancient"

/obj/item/clothing/suit/chaplainsuit/armor/ancient
	name = "ancient armour"
	desc = "Defend the treasure..."
	icon_state = "knight_ancient"
	inhand_icon_state = "knight_ancient"

/obj/item/clothing/head/helmet/chaplain/witchunter_hat
	name = "witchunter hat"
	desc = "This hat saw much use back in the day."
	icon_state = "witchhunterhat"
	inhand_icon_state = "witchhunterhat"
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEEYES

/obj/item/clothing/head/helmet/chaplain/adept
	name = "adept hood"
	desc = "Its only heretical when others do it."
	icon_state = "crusader"
	inhand_icon_state = "crusader"
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS

/obj/item/clothing/suit/chaplainsuit/armor/adept
	name = "adept robes"
	desc = "The ideal outfit for burning the unfaithful."
	icon_state = "crusader"
	inhand_icon_state = "crusader"

/obj/item/clothing/suit/chaplainsuit/armor/crusader
	name = "Crusader's Armour"
	desc = "Armour that's comprised of metal and cloth."
	icon_state = "crusader"
	w_class = WEIGHT_CLASS_BULKY
	slowdown = 2.0 //gotta pretend we're balanced.
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 60, BIO = 0, FIRE = 60, ACID = 60)

/obj/item/clothing/suit/chaplainsuit/armor/crusader/red
	icon_state = "crusader-red"

/obj/item/clothing/suit/chaplainsuit/armor/crusader/blue
	icon_state = "crusader-blue"

/obj/item/clothing/suit/hooded/chaplain_hoodie
	name = "follower hoodie"
	desc = "Hoodie made for acolytes of the chaplain."
	icon_state = "chaplain_hoodie"
	worn_icon = 'icons/mob/clothing/suits/chaplain.dmi'
	inhand_icon_state = "chaplain_hoodie"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/storage/book/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)
	hoodtype = /obj/item/clothing/head/hooded/chaplain_hood

/obj/item/clothing/head/hooded/chaplain_hood
	name = "follower hood"
	desc = "Hood made for acolytes of the chaplain."
	icon_state = "chaplain_hood"
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS

/obj/item/clothing/suit/hooded/chaplain_hoodie/leader
	name = "leader hoodie"
	desc = "Now you're ready for some 50 dollar bling water."
	icon_state = "chaplain_hoodie_leader"
	inhand_icon_state = "chaplain_hoodie_leader"
	hoodtype = /obj/item/clothing/head/hooded/chaplain_hood/leader

/obj/item/clothing/head/hooded/chaplain_hood/leader
	name = "leader hood"
	desc = "I mean, you don't /have/ to seek bling water. I just think you should."
	icon_state = "chaplain_hood_leader"
