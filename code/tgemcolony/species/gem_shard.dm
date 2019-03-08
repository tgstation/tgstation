/obj/item/shard/gem
	name = "Shattered Gem"
	desc = "It appears to be the remains of Ruby cut-000"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "rubyshard"
	w_class = WEIGHT_CLASS_TINY
	force = 5
	throwforce = 10
	item_state = "shard-glass"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	materials = list(MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	attack_verb = list("stabbed", "slashed", "sliced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	resistance_flags = ACID_PROOF
	armor = list("melee" = 100, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 100)
	max_integrity = 40
	sharpness = IS_SHARP

/obj/item/shard/gem/random/Initialize()
	..()
	var/gemtype = pick("Ruby","Amethyst","Rose Quartz","Agate","Pearl","Bismuth")
	if(gemtype == "Ruby")
		icon_state = "rubyshard"
	if(gemtype == "Amethyst")
		icon_state = "amethystshard"
	if(gemtype == "Rose Quartz")
		icon_state = "rosequartzshard"
	if(gemtype == "Agate")
		icon_state = "agateshard"
	if(gemtype == "Pearl")
		icon_state = "pearlshard"
	if(gemtype == "Bismuth")
		icon_state = "bismuthshard"
	name = "Shattered [gemtype]"
	desc = "It appears to be the remains of [gemtype] cut-[pick("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9")][pick("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9")][pick("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9")]"