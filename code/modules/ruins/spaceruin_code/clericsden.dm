/////////// cleric's den items.

/obj/item/paper/fluff/ruins/clericsden/contact
	info = "Father Aurellion, the ritual is complete, and soon our brothers at the bastion will see the error of our ways. After all, a god of clockwork or blood? Preposterous. Only the TRUE GOD should have so much power. Signed, Father Odivallus."

/obj/item/paper/fluff/ruins/clericsden/warning
	info = "FATHER ODIVALLUS DO NOT GO FORWARD WITH THE RITUAL. THE ASTEROID WE'RE ANCHORED TO IS UNSTABLE, YOU WILL DESTROY THE STATION. I HOPE THIS REACHES YOU IN TIME. FATHER AURELLION."

/mob/living/simple_animal/hostile/construct/proteon
	name = "Proteon"
	real_name = "Proteon"
	desc = "A weaker construct meant to scour ruins for objects of Nar'Sie's affection. Those barbed claws are no joke."
	icon_state = "proteon"
	icon_living = "proteon"
	maxHealth = 35
	health = 35
	melee_damage_lower = 8
	melee_damage_upper = 10
	retreat_distance = 4 //AI proteons will rapidly move in and out of combat to avoid conflict, but will still target and follow you.
	attack_verb_continuous = "pinches"
	attack_verb_simple = "pinch"
	environment_smash = ENVIRONMENT_SMASH_WALLS
	attack_sound = 'sound/weapons/punch2.ogg'
	playstyle_string = "<b>You are a Proteon. Your abilities in combat are outmatched by most combat constructs, but you are still fast and nimble. Run metal and supplies, and cooperate with your fellow cultists.</b>"

/mob/living/simple_animal/hostile/construct/proteon/hostile //Style of mob spawned by trapped cult runes in the cleric ruin.
	AIStatus = AI_ON
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES //standard ai construct behavior, breaks things if it wants, but not walls.

//Primary reward: the cleric's mace design disk.
/obj/item/disk/design_disk/adv/cleric_mace
	name = "Enshrined Disc of Smiting"

/obj/item/disk/design_disk/adv/cleric_mace/Initialize()
	. = ..()
	var/datum/design/cleric_mace/M = new
	blueprints[1] = M

/obj/item/melee/cleric_mace
	name = "cleric mace"
	desc = "The grandson of the club, yet the grandfather of the baseball bat. Most notably used by holy orders in days past."
	icon = 'icons/obj/items/cleric_mace.dmi'
	icon_state = "default"
	inhand_icon_state = "default"
	worn_icon_state = "default_worn"

	greyscale_config = /datum/greyscale_config/cleric_mace
	greyscale_config_inhand_left = /datum/greyscale_config/cleric_mace_lefthand
	greyscale_config_inhand_right = /datum/greyscale_config/cleric_mace_righthand
	greyscale_config_worn = /datum/greyscale_config/cleric_mace
	greyscale_colors = "#FFFFFF"

	material_flags = MATERIAL_ADD_PREFIX | MATERIAL_GREYSCALE | MATERIAL_AFFECT_STATISTICS //Material type changes the prefix as well as the color.
	custom_materials = list(/datum/material/iron = 12000)  //Defaults to an Iron Mace.
	slot_flags = ITEM_SLOT_BELT
	force = 14
	w_class = WEIGHT_CLASS_BULKY
	throwforce = 8
	block_chance = 10
	armour_penetration = 50
	attack_verb_continuous = list("smacks", "strikes", "cracks", "beats")
	attack_verb_simple = list("smack", "strike", "crack", "beat")
