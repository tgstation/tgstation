//ASH CLOTHING
/datum/armor/ash_headdress
	melee = 15
	bullet = 25
	laser = 15
	energy = 15
	bomb = 20
	bio = 10

/datum/armor/clothing_under/ash_robes
	melee = 15
	bullet = 25
	laser = 15
	energy = 15
	bomb = 20
	bio = 10

/datum/armor/ash_plates
	melee = 15
	bullet = 25
	laser = 15
	energy = 15
	bomb = 20
	bio = 10

/datum/armor/bone_greaves
	melee = 15
	bullet = 25
	laser = 15
	energy = 15
	bomb = 20
	bio = 50

/obj/item/clothing/head/ash_headdress
	name = "ash headdress"
	desc = "A headdress that shows the dominance of the walkers of ash."
	icon = 'monkestation/code/modules/blueshift/icons/ashwalker_clothing.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/ashwalker_clothing_mob.dmi'
	icon_state = "headdress"
	supports_variations_flags = NONE
	armor_type = /datum/armor/ash_headdress

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_recipe/ash_headdress
	name = "Ash Headdress"
	result = /obj/item/clothing/head/ash_headdress
	category = CAT_CLOTHING
	always_available = FALSE

/obj/item/clothing/head/ash_headdress/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate, 2, /obj/item/stack/sheet/animalhide/goliath_hide, list(MELEE = 5, BULLET = 2, LASER = 2))

/obj/item/clothing/head/ash_headdress/winged
	name = "winged ash headdress"
	icon_state = "wing_headdress"

/datum/crafting_recipe/ash_recipe/ash_headdress/winged
	name = "Winged Ash Headdress"
	result = /obj/item/clothing/head/ash_headdress/winged
	always_available = FALSE

/obj/item/clothing/under/costume/gladiator/ash_walker/ash_robes
	name = "ash robes"
	desc = "A set of hand-made robes. The bones still seem to have some muscle still attached."
	icon = 'monkestation/code/modules/blueshift/icons/ashwalker_clothing.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/ashwalker_clothing_mob.dmi'
	icon_state = "robes"
	armor_type = /datum/armor/clothing_under/ash_robes

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_recipe/ash_robes
	name = "Ash Robes"
	result = /obj/item/clothing/under/costume/gladiator/ash_walker/ash_robes
	category = CAT_CLOTHING
	always_available = FALSE

/obj/item/clothing/under/costume/gladiator/ash_walker/ash_robes/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate, 2, /obj/item/stack/sheet/animalhide/goliath_hide, list(MELEE = 5, BULLET = 2, LASER = 2))

/obj/item/clothing/under/costume/gladiator/ash_walker/ash_plates
	name = "ash combat plates"
	desc = "A combination of bones and hides, strung together by watcher sinew."
	icon = 'monkestation/code/modules/blueshift/icons/ashwalker_clothing.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/ashwalker_clothing_mob.dmi'
	icon_state = "combat_plates"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	armor_type = /datum/armor/clothing_under/ash_robes

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null

/datum/crafting_recipe/ash_recipe/ash_plates
	name = "Ash Combat Plates"
	result = /obj/item/clothing/under/costume/gladiator/ash_walker/ash_plates
	category = CAT_CLOTHING
	always_available = FALSE

/obj/item/clothing/under/costume/gladiator/ash_walker/ash_plates/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate, 2, /obj/item/stack/sheet/animalhide/goliath_hide, list(MELEE = 5, BULLET = 2, LASER = 2))

/obj/item/clothing/under/costume/gladiator/ash_walker/ash_plates/decorated
	name = "decorated ash combat plates"
	icon_state = "dec_breastplate"

/datum/crafting_recipe/ash_recipe/ash_plates/decorated
	name = "Decorated Ash Combat Plates"
	result = /obj/item/clothing/under/costume/gladiator/ash_walker/ash_plates/decorated
	category = CAT_CLOTHING
	always_available = FALSE

/obj/item/clothing/shoes/bone_greaves
	name = "bone greaves"
	desc = "For when you're expecting to step on spiky things. Offers modest protection to your feet."
	icon = 'monkestation/code/modules/blueshift/icons/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/feet.dmi'
	worn_icon_digitigrade = 'monkestation/code/modules/blueshift/icons/feet_digi.dmi'
	icon_state = "bone_greaves"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION
	armor_type = /datum/armor/bone_greaves

/datum/crafting_recipe/ash_recipe/bone_greaves
	name = "Bone Greaves"
	result = /obj/item/clothing/shoes/bone_greaves
	reqs = list(
   		/obj/item/stack/sheet/bone = 2,
   		/obj/item/stack/sheet/sinew = 1,
    )
	category = CAT_CLOTHING

/obj/item/clothing/gloves/military/ashwalk
	icon = 'monkestation/code/modules/blueshift/icons/gloves.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/hands.dmi'
	name = "ash coated bronze gloves"
	desc = "Some sort of thin material with the backing of bronze plates."
	icon_state = "legionlegat"

/obj/item/clothing/gloves/military/claw
	icon = 'monkestation/code/modules/blueshift/icons/gloves.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/hands.dmi'
	name = "tribal claw glove"
	desc = "A gauntlet fashioned from the hand of a long-dead creature. Judging by the claws, whoever brought the beast down must have had a hard fight."
	icon_state = "claw"

/obj/item/clothing/head/shamanash
	name = "shaman skull"
	desc = "The skull of a long dead animal bolted to the front of a repurposed pan."
	icon = 'monkestation/code/modules/blueshift/icons/hats.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/head.dmi'
	icon_state = "shamskull"
	supports_variations_flags = NONE

/obj/item/clothing/suit/ashwalkermantle
	icon = 'monkestation/code/modules/blueshift/icons/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/suit.dmi'
	name = "tanned hide"
	desc = "The tanned hide of some brown furred creature."
	icon_state = "mantle_liz"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/ashwalkermantle/cape
	icon = 'monkestation/code/modules/blueshift/icons/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/suit.dmi'
	name = "brown leather cape"
	desc = "An ash coated cloak."
	icon_state = "desertcloak"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/neck/cloak/tribalmantle
	name = "ornate mantle"
	desc = "An ornate mantle commonly worn by a shaman or chieftain."
	icon = 'monkestation/code/modules/blueshift/icons/cloaks.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/neck.dmi'
	icon_state = "tribal-mantle"

/obj/item/clothing/shoes/jackboots/ashwalker
	name = "ash coated bronze boots"
	desc = "Boots decorated with poorly forged metal."
	icon = 'monkestation/code/modules/blueshift/icons/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/feet.dmi'
	icon_state = "legionmetal"
	supports_variations_flags = NONE

/obj/item/clothing/shoes/jackboots/ashwalker/legate
	icon = 'monkestation/code/modules/blueshift/icons/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/feet.dmi'
	icon_state = "legionlegate"
	supports_variations_flags = NONE

/obj/item/clothing/shoes/wraps/ashwalker
	icon = 'monkestation/code/modules/blueshift/icons/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/feet.dmi'
	name = "ash coated foot wraps"
	desc = "May hurt for less than normal legs."
	icon_state = "rag"
	supports_variations_flags = NONE

/obj/item/clothing/shoes/wraps/ashwalker/tribalwraps
	icon = 'monkestation/code/modules/blueshift/icons/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/feet.dmi'
	worn_icon_digitigrade = 'monkestation/code/modules/blueshift/icons/feet_digi.dmi'
	name = "ornate leg wraps"
	desc = "An ornate set of leg wraps commonly worn by a shaman or chieftain."
	icon_state = "tribalcuffs"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/shoes/wraps/ashwalker/mundanewraps
	icon = 'monkestation/code/modules/blueshift/icons/shoes.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/feet.dmi'
	worn_icon_digitigrade = 'monkestation/code/modules/blueshift/icons/feet_digi.dmi'
	name = "tribal leg wraps"
	desc = "A mundane set of leg wraps often worn by tribal villagers."
	icon_state = "mundanecuffs"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/under/costume/gladiator/ash_walker/greentrib
	icon = 'monkestation/code/modules/blueshift/icons/uniforms.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/uniform.dmi'
	name = "ash covered leaves"
	desc = "Green leaves coated with a thick layer of ash. Praise the Nercopolis."
	icon_state = "tribal_m"

/obj/item/clothing/under/costume/gladiator/ash_walker/yellow
	icon = 'monkestation/code/modules/blueshift/icons/uniforms.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/uniform.dmi'
	name = "ash walker rags"
	desc = "Rags from Lavaland, coated with light ash. This one seems to be for the juniors of a tribe. Praise the Nercopolis."
	icon_state = "tribalrags"

/obj/item/clothing/under/costume/gladiator/ash_walker/chiefrags
	icon = 'monkestation/code/modules/blueshift/icons/uniforms.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/uniform.dmi'
	name = "old ash walker rags"
	desc = "Rags from Lavaland, coated with heavy ash. This one seems to be for the elders of a tribe. Praise the Nercopolis."
	icon_state = "chiefrags"

/obj/item/clothing/under/costume/gladiator/ash_walker/shaman
	icon = 'monkestation/code/modules/blueshift/icons/uniforms.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/uniform.dmi'
	name = "decorated ash walker rags"
	desc = "Rags from Lavaland, drenched with ash, it has fine jewel coated bones sewn around the neck. This one seems to be for the shaman of a tribe. Praise the Nercopolis."
	icon_state = "shamanrags"

/obj/item/clothing/under/costume/gladiator/ash_walker/robe
	icon = 'monkestation/code/modules/blueshift/icons/uniforms.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/uniform.dmi'
	name = "ash walker robes"
	desc = "A robe from the ashlands. This one seems to be for ...Everyone, really. Praise the Nercopolis."
	icon_state = "robe_liz"

/obj/item/clothing/under/costume/gladiator/ash_walker/tribal
	icon = 'monkestation/code/modules/blueshift/icons/uniforms.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/uniform.dmi'
	name = "ash walker tin"
	desc = "Thin tin bolted over poorly tanned leather."
	icon_state = "tribal"

/obj/item/clothing/under/costume/gladiator/ash_walker/white
	icon = 'monkestation/code/modules/blueshift/icons/uniforms.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/uniform.dmi'
	name = "white ash walker rags"
	desc = "A poorly sewn dress made of white materials."
	icon_state = "lizcheo"

/obj/item/clothing/under/costume/gladiator/ash_walker/chestwrap
	icon = 'monkestation/code/modules/blueshift/icons/uniforms.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/uniform.dmi'
	name = "loincloth and chestwrap"
	desc = "A poorly sewn dress made of white materials."
	icon_state = "chestwrap"

/obj/item/clothing/under/costume/gladiator/ash_walker/caesar_clothes
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/uniforms.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/uniform.dmi'
	name = "ash walker tunic"
	desc = "A tattered red tunic of reddened fabric."
	icon_state = "caesar_clothes"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/under/costume/gladiator/ash_walker/legskirt_d
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/uniforms.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/uniform.dmi'
	name = "ash walker waistcloth"
	desc = "A unisex waistcloth to serve as a kilt or skirt."
	icon_state = "legskirt_d"

#define LANGUAGE_TRANSLATOR "translator"
/obj/item/clothing/neck/necklace/ashwalker
	name = "ashen necklace"
	desc = "A necklace crafted from ash, connected to the Necropolis through the core of a Legion. This imbues overdwellers with an unnatural understanding of Ashtongue, the native language of Lavaland, while worn."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/neck.dmi'
	icon_state = "ashnecklace"
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/neck.dmi'
	icon_state = "ashnecklace"
	w_class = WEIGHT_CLASS_SMALL //allows this to fit inside of pockets.

/obj/item/clothing/neck/necklace/ashwalker/cursed
	name = "cursed ashen necklace"
	desc = "A necklace crafted from ash, connected to the Necropolis through the core of a Legion. This imbues overdwellers with an unnatural understanding of Ashtongue, the native language of Lavaland, while worn. Cannot be removed!"

/obj/item/clothing/neck/necklace/ashwalker/cursed/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

//uses code from the pirate hat.
/obj/item/clothing/neck/necklace/ashwalker/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(slot & ITEM_SLOT_NECK)
		user.grant_language(/datum/language/ashtongue/, source = LANGUAGE_TRANSLATOR)
		to_chat(user, span_boldnotice("Slipping the necklace on, you feel the insidious creep of the Necropolis enter your bones, and your very shadow. You find yourself with an unnatural knowledge of Ashtongue; but the amulet's eye stares at you."))

/obj/item/clothing/neck/necklace/ashwalker/dropped(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(ITEM_SLOT_NECK) == src && !QDELETED(src)) //This can be called as a part of destroy
		user.remove_language(/datum/language/ashtongue/, source = LANGUAGE_TRANSLATOR)
		to_chat(user, span_boldnotice("You feel the alien mind of the Necropolis lose its interest in you as you remove the necklace. The eye closes, and your mind does as well, losing its grasp of Ashtongue."))


// ashtongue for ashwalkers
/datum/language_holder/lizard/ash
	understood_languages = list(/datum/language/ashtongue = list(LANGUAGE_ATOM))
	spoken_languages = list(/datum/language/ashtongue = list(LANGUAGE_ATOM))
	selected_language = /datum/language/ashtongue

/datum/language/ashtongue
	name = "Ashtongue"
	desc = "A language derived from Draconic, altered and morphed into a strange tongue by the enigmatic will of the Necropolis, a half-successful attempt at patterning its own alien communication methods onto mundane races. It's become nigh-incomprehensible to speakers of the original language."
	key = "l"
	flags = TONGUELESS_SPEECH
	space_chance = 70
	syllables = list(
		"za", "az", "ze", "ez", "zi", "iz", "zo", "oz", "zu", "uz", "zs", "sz",
		"ha", "ah", "he", "eh", "hi", "ih", "ho", "oh", "hu", "uh", "hs", "sh",
		"la", "al", "le", "el", "li", "il", "lo", "ol", "lu", "ul", "ls", "sl",
		"ka", "ak", "ke", "ek", "ki", "ik", "ko", "ok", "ku", "uk", "ks", "sk",
		"sa", "as", "se", "es", "si", "is", "so", "os", "su", "us", "ss", "ss",
		"ra", "ar", "re", "er", "ri", "ir", "ro", "or", "ru", "ur", "rs", "sr",
		"er", "sint", "en", "et", "nor", "bahr", "sint", "un", "ku", "lakor", "eri",
		"noj", "dashilu", "as", "ot", "lih", "morh", "ghinu", "kin", "sha", "marik", "jibu",
		"sudas", "fut", "kol", "bivi", "pohim", "devohr", "ru", "huirf", "neiris", "sut",
		"viepn","bag","docu","kar","xlaqf","raa","qwos","nen","ty","von","kytaf","xin",
		"devehr", "iru", "gher", "gan", "ujil", "lacor", "bahris", "ghar", "alnef", "wah",
		"khurdhar", "bar", "et", "ilu", "dash", "diru", "noj", "de", "damjulan", "luvahr",
		"telshahr", "tifur", "enhi", "am", "bahr", "nei", "neibahri", "n'chow", "n'wah",
		"baak","hlaf","pyk","znu","agr","ith","na'ar","uah","plhu","six","fhler","bjel","scee",
		"lleri","dttm","aggr","uujl","hjjifr","wuth","aav","inya","sod","bli","min","fril","bli","'ddn","tun'da",
		"'ad","iir","krei","tii'","ruuk","nei","zirua","surai","lieket","miruk","ettirup","mireez","cqiek",
		"brut","vaahk","nah'za","diierk","piut","vuurk","cs'eer","jeirk","qiruvk",
	)
	icon_state = "ashtongue"
	icon = 'monkestation/code/modules/blueshift/icons/language.dmi'
	default_priority = 90
