/*****************Pickaxes & Drills & Shovels****************/
/obj/item/pickaxe
	name = "pickaxe"
	icon = 'icons/obj/mining.dmi'
	icon_state = "pickaxe"
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	throwforce = 10
	inhand_icon_state = "pickaxe"
	worn_icon_state = "pickaxe"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	custom_materials = list(/datum/material/iron=2000) //one sheet, but where can you make them?
	tool_behaviour = TOOL_MINING
	toolspeed = 1
	usesound = list('sound/effects/picaxe1.ogg', 'sound/effects/picaxe2.ogg', 'sound/effects/picaxe3.ogg')
	attack_verb_simple = list("hit", "pierce", "mine", "attack")
	attack_verb_continuous = list("hits", "pierces", "mines", "attacks")
	force = 15
	armour_penetration = 25 // Somewhere between spears and broadswords.
	wound_bonus = 60 // With 15 force this must be at least 56 to inflict a compound fracture on a [BIO_JUST_BONE] bodypart with a hairline fracture.
	sharpness = SHARP_POINTY

/obj/item/pickaxe/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] begins digging into [user.p_their()] chest! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	if(use_tool(user, user, 30, volume=50))
		return BRUTELOSS
	user.visible_message("<span class='suicide'>[user] couldn't do it!</span>")
	return SHAME

/obj/item/pickaxe/rusted
	name = "rusty pickaxe"
	desc = "A pickaxe that's been left to rust."
	attack_verb_simple = list("ineffectively hit")
	attack_verb_continuous = list("ineffectively hits")
	force = 1
	throwforce = 1

/obj/item/pickaxe/mini
	name = "compact pickaxe"
	desc = "A smaller, compact version of the standard pickaxe."
	icon_state = "minipick"
	worn_icon_state = "pickaxe"
	force = 10
	throwforce = 7
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron=1000)

/obj/item/pickaxe/silver
	name = "silver-plated pickaxe"
	desc = "A silver-plated pickaxe that mines slightly faster than standard-issue."
	icon_state = "spickaxe"
	inhand_icon_state = "spickaxe"
	worn_icon_state = "spickaxe"
	toolspeed = 0.5 //mines faster than a normal pickaxe, bought from mining vendor
	force = 18

/obj/item/pickaxe/diamond
	name = "diamond-tipped pickaxe"
	desc = "A pickaxe with a diamond pick head. Extremely robust at cracking rock walls and digging up dirt."
	icon_state = "dpickaxe"
	inhand_icon_state = "dpickaxe"
	worn_icon_state = "dpickaxe"
	toolspeed = 0.3
	force = 20

/obj/item/pickaxe/drill
	name = "mining drill"
	desc = "An electric mining drill for the especially scrawny."
	icon_state = "handdrill"
	inhand_icon_state = "jackhammer"
	worn_icon_state = "jackhammer"
	slot_flags = ITEM_SLOT_BELT
	toolspeed = 0.6 //available from roundstart, faster than a pickaxe.
	attack_verb_simple = list("hit", "pierce", "mine", "drill", "attack")
	attack_verb_continuous = list("hits", "pierces", "mines", "drills", "attacks")
	usesound = 'sound/weapons/drill.ogg'
	hitsound = 'sound/weapons/drill.ogg'
	force = 18
	armour_penetration = -40 // Apparently drills have trouble chewing through fibers and smooth metal because they're designed for rock.
	wound_bonus = -17 // Since they can't get through your armor they aren't going to chew through your skin are they? Must roll a rough abrasion before they can roll a open laceration. Cannot roll a weeping avulsion through armor.
	bare_wound_bonus = 75 // WARNING: DO NOT APPLY TOPICALLY, SEVERE HEMORRHAGE MAY OCCUR. NOTE: I don't like how high this is either but, in order to be able to inflict a critical bone wound on a BIO_JUST_BONE bodypart with 18 force and no armor the total wound bonus must be at least _58_. This is literally as low as I can make this without refactoring how wounds are dealt.
	sharpness = SHARP_EDGED // The drill head is wider than most pointy objects, likely serrated, and spinning at high speed.

/obj/item/pickaxe/drill/cyborg
	name = "cyborg mining drill"
	desc = "An integrated electric mining drill."
	flags_1 = NONE

/obj/item/pickaxe/drill/cyborg/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CYBORG_ITEM_TRAIT)

/obj/item/pickaxe/drill/diamonddrill
	name = "diamond-tipped mining drill"
	desc = "Yours is the drill that will pierce the heavens!"
	icon_state = "diamonddrill"
	toolspeed = 0.2
	force = 20
	armour_penetration = -25 // Better at handling armor than a normal drill.

/obj/item/pickaxe/drill/cyborg/diamond //This is the BORG version!
	name = "diamond-tipped cyborg mining drill" //To inherit the NODROP_1 flag, and easier to change borg specific drill mechanics.
	desc = "Yours is the drill that will pierce the heavens!" // Copied from the regular diamond drill.
	icon_state = "diamonddrill"
	toolspeed = 0.2
	force = 20
	armour_penetration = -25

/obj/item/pickaxe/drill/jackhammer
	name = "sonic jackhammer"
	desc = "Cracks rocks with sonic blasts."
	icon_state = "jackhammer"
	inhand_icon_state = "jackhammer"
	worn_icon_state = "jackhammer"
	toolspeed = 0.1 //the epitome of powertools. extremely fast mining
	usesound = 'sound/weapons/sonic_jackhammer.ogg'
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	attack_verb_simple = list("hit", "pierce", "mine", "slam", "attack")
	attack_verb_continuous = list("hits", "pierces", "mines", "slams", "attacks")
	force = 5 // Sound usually passes through the body relatively harmlessly.
	armour_penetration = 80
	sharpness = SHARP_NONE
	wound_bonus = 80 // Must be >= 76 to inflict compound fractures through armor if the bodypart already has a hairline fracture.
	bare_wound_bonus = 30 // It is pumping rock-shattering levels of ultrasound directly into your body. That's going to do _nasty_ things to your bones.

/obj/item/pickaxe/improvised
	name = "improvised pickaxe"
	desc = "A pickaxe made with a knife and crowbar taped together, how does it not break?"
	icon_state = "ipickaxe"
	inhand_icon_state = "ipickaxe"
	worn_icon_state = "pickaxe"
	force = 10
	throwforce = 7
	toolspeed = 3 //3 times slower than a normal pickaxe
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron=12050) //metal needed for a crowbar and for a knife, why the FUCK does a knife cost 6 metal sheets while a crowbar costs 0.025 sheets? shit makes no sense fuck this

/obj/item/shovel
	name = "shovel"
	desc = "A large tool for digging and moving dirt."
	icon = 'icons/obj/mining.dmi'
	icon_state = "shovel"
	worn_icon_state = "shovel"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 8
	tool_behaviour = TOOL_SHOVEL
	toolspeed = 1
	usesound = 'sound/effects/shovel_dig.ogg'
	throwforce = 4
	inhand_icon_state = "shovel"
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron=50)
	attack_verb_continuous = list("bashes", "bludgeons", "thrashes", "whacks")
	attack_verb_simple = list("bash", "bludgeon", "thrash", "whack")
	sharpness = SHARP_EDGED

/obj/item/shovel/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 150, 40) //it's sharp, so it works, but barely.

/obj/item/shovel/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] begins digging their own grave! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	if(use_tool(user, user, 30, volume=50))
		return BRUTELOSS
	user.visible_message("<span class='suicide'>[user] couldn't do it!</span>")
	return SHAME

/obj/item/shovel/spade
	name = "spade"
	desc = "A small tool for digging and moving dirt."
	icon_state = "spade"
	inhand_icon_state = "spade"
	worn_icon_state = "spade"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL

/obj/item/shovel/serrated
	name = "serrated bone shovel"
	desc = "A wicked tool that cleaves through dirt just as easily as it does flesh. The design was styled after ancient lavaland tribal designs."
	icon_state = "shovel_bone"
	inhand_icon_state = "shovel_bone"
	worn_icon_state = "shovel_serr"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	force = 15
	throwforce = 12
	w_class = WEIGHT_CLASS_NORMAL
	toolspeed = 0.7
	attack_verb_continuous = list("slashes", "impales", "stabs", "slices")
	attack_verb_simple = list("slash", "impale", "stab", "slice")
