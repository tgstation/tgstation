/datum/species/gem
	name = "Ruby"
	id = "ruby"
	limbs_id = "human"
	sexes = TRUE
	var/height = "small"
	fixed_mut_color = "C22"
	hair_color = "911"
	var/hairstyle = "Afro (Square)"
	species_traits = list(HAIR,LIPS,MUTCOLORS,NOBLOOD,NO_UNDERWEAR) //no mutcolors, and can burn
	inherent_traits = list(TRAIT_NOHUNGER,TRAIT_RESISTHEAT,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOFIRE,TRAIT_RADIMMUNE,TRAIT_NODISMEMBER)
	inherent_biotypes = list(MOB_GEM, MOB_HUMANOID)
	default_features = list("mcolor" = "F22", "wings" = "None")
	var/datum/action/weapon = new/datum/action/innate/gem/weapon
	var/datum/action/fusion = new/datum/action/innate/gem/fusion
	var/datum/action/unfuse = new/datum/action/innate/gem/unfuse
	var/datum/action/ability1 = null
	var/datum/action/ability2 = null

/datum/species/gem/peridot
	name = "Peridot"
	id = "peridot"
	height = "normal"
	fixed_mut_color = "2C2"
	hair_color = "AFA"
	hairstyle = "Afro (Triangle)"
	weapon = null

/datum/species/gem/jade
	name = "Jade"
	id = "jade"
	height = "normal"
	fixed_mut_color = "2C2"
	hair_color = "AFA"
	hairstyle = "Ponytail 4"
	weapon = new/datum/action/innate/gem/weapon/jadedagger

/datum/species/gem/amethyst
	name = "Amethyst"
	id = "amethyst"
	height = "big" //They're Quartz Soldiers.
	fixed_mut_color = "C6C"
	hair_color = "FAF"
	armor = 50
	hairstyle = "Long Hair 3"
	weapon = new/datum/action/innate/gem/weapon/amethystwhip

/datum/species/gem/agate
	name = "Agate"
	id = "agate"
	height = "big" //They're Quartz Soldiers.
	fixed_mut_color = "C66"
	hair_color = "FCC"
	armor = 50
	hairstyle = "Updo"
	weapon = new/datum/action/innate/gem/weapon/agatewhip

/datum/species/gem/sapphire
	name = "Sapphire"
	id = "sapphire"
	height = "small"
	fixed_mut_color = "66C"
	hair_color = "CCF"
	hairstyle = "Sapphire Hair"
	weapon = null
	ability1 = new/datum/action/innate/gem/findmob

/datum/species/gem/agate/homeworld
	fixed_mut_color = "66C"
	hair_color = "CCF"

/datum/species/gem/pearl
	name = "Pearl"
	id = "pearl"
	height = "normal"
	fixed_mut_color = "FCF"
	hair_color = "F6C"
	hairstyle = "Spiky 3"
	weapon = new/datum/action/innate/gem/weapon/pearlspear
	ability1 = new/datum/action/innate/gem/store
	ability2 = new/datum/action/innate/gem/withdraw

/datum/species/gem/pearl/homeworld
	fixed_mut_color = "6C6"
	hair_color = "CFC"
	hairstyle = "Sapphire Hair"

/datum/species/gem/rosequartz
	name = "Rose Quartz"
	id = "rosequartz" //They're Quartz Soldiers.
	height = "big"
	fixed_mut_color = "FC9"
	hair_color = "F9C"
	hairstyle = "Drill Hair (Extended)"
	weapon = new/datum/action/innate/gem/weapon/roseshield
	ability1 = new/datum/action/innate/gem/healingtears

/datum/species/gem/bismuth
	name = "Bismuth"
	id = "bismuth" //They're Quartz Soldiers.
	height = "big"
	fixed_mut_color = "C6C"
	hair_color = "FFF"
	hairstyle = "Bismuth Hair"
	weapon = new/datum/action/innate/gem/weapon/bismuthpick
	ability1 = new/datum/action/innate/gem/smelt

/mob/living/carbon/human/species/gem
	race = /datum/species/gem

/datum/species/gem/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(weapon != null)
		weapon.Grant(C)
	fusion.Grant(C)
	unfuse.Grant(C)
	if(ability1 != null)
		ability1.Grant(C)
	if(ability2 != null)
		ability2.Grant(C)
	C.add_trait(SPECIES_TRAIT)
	C.gender = "female"
	if(ishuman(C))
		var/mob/living/carbon/human/N = C
		N.hair_style = hairstyle
		N.hair_color = hair_color
		spawn(1)
		if(N.isfusion == TRUE)
			if(height == "big")
				N.resize = 1.4
			else if(height == "normal")
				N.resize = 1.2
	sleep(1)
	C.revive(full_heal = TRUE, admin_revive = TRUE)

/datum/species/gem/on_species_loss(mob/living/carbon/C)
	C.remove_trait(SPECIES_TRAIT)
	weapon.Remove(C)
	fusion.Remove(C)
	unfuse.Remove(C)
	if(ability1 != null)
		ability1.Remove(C)
	if(ability2 != null)
		ability2.Remove(C)
	C.resize = 1
	..()

/datum/species/gem/spec_death(gibbed, mob/living/carbon/human/H)
	if(gibbed)
		return
	if(H.summoneditem != null)
		QDEL_NULL(H.summoneditem)
		H.regenerate_icons()

	if(H.isfusion == FALSE)
		new /obj/effect/temp_visual/gem_poof(get_turf(H))
		if(H.suiciding)
			H.visible_message("<span class='danger'>[H] shattered themself!</span>")
			H.unequip_everything()
			for(var/atom/movable/A in H.stored_items)
				H.stored_items.Remove(A)
				A.forceMove(H.drop_location())
			var/obj/item/shard/gem/shard = new/obj/item/shard/gem
			shard.loc = H.loc
			shard.icon_state = "[id]shard"
			shard.name = "Shattered [id]"
			shard.desc = "It appears to be the remains of [H.name]"
			QDEL_NULL(H)
		else

			H.visible_message("<span class='danger'>[H] was poofed!</span>")
			new /obj/structure/gem(get_turf(H), H)
	else
		for(var/atom/movable/A in H.fused_with)
			H.fused_with.Remove(A)
			A.forceMove(H.drop_location())
			if(ishuman(A))
				var/mob/living/carbon/human/M = A
				M.myfusion = FALSE
				M.reset_perspective()
				if(H.willingunfuse == FALSE)
					M.adjustStaminaLoss(200)
		H.visible_message("<span class='danger'>[H] unfused!</span>")
		var/mob/domfuse = H.dominantfuse
		domfuse.key = H.key
		spawn(5)
		del(H)
	..()

/obj/structure/gem
	name = "Gem"
	desc = "Just needs time to reform..."
	max_integrity = 50
	var/gemhealth = 50
	armor = list("melee" = 90, "bullet" = 90, "laser" = 25, "energy" = 80, "bomb" = 50, "bio" = 100, "fire" = -50, "acid" = -50)
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "ruby"

	var/revive_time = 600
	var/mob/living/carbon/human/gem

/obj/structure/gem/Initialize(mapload, mob/living/carbon/human/H)
	. = ..()
	if(!QDELETED(H) && is_species(H, /datum/species/gem))
		H.forceMove(src)
		gem = H
		name = H.name
		icon_state = H.dna.species.id
		to_chat(gem, "<span class='notice'>You start focusing, preparing to reform...</span>")
		addtimer(CALLBACK(src, .proc/revive), revive_time)
	else
		return INITIALIZE_HINT_QDEL

/obj/structure/gem/Destroy()

	if(gem)
		gem.unequip_everything()
		var/obj/item/shard/gem/shard = new/obj/item/shard/gem
		shard.loc = src.loc
		shard.icon_state = "[gem.dna.species.id]shard"
		shard.name = "Shattered [gem.dna.species.id]"
		shard.desc = "It appears to be the remains of [gem.name]"
		QDEL_NULL(gem)
	return ..()

/obj/structure/gem/proc/revive()
	if(QDELETED(src) || QDELETED(gem)) //QDELETED also checks for null, so if no cloth golem is set this won't runtime
		return
	if(gem.suiciding || gem.hellbound)
		QDEL_NULL(gem)
		return

	invisibility = INVISIBILITY_MAXIMUM //disappear before the animation
	new /obj/effect/temp_visual/gem_reform(get_turf(src))
	if(gem.revive(full_heal = TRUE, admin_revive = TRUE))
		gem.grab_ghost() //won't pull if it's a suicide
	sleep(12)
	gem.forceMove(get_turf(src))
	gem.visible_message("<span class='danger'>[src] rises, a bright lit emits and a Body takes form!</span>","<span class='userdanger'>You reform your body!</span>")
	gem = null
	qdel(src)

/obj/structure/gem/attackby(obj/item/P, mob/living/carbon/human/user, params)
	. = ..()

	if(istype(P, /obj/item/pickaxe))
		var/obj/item/pickaxe/pickaxe = P
		gemhealth = gemhealth-pickaxe.force
		pickaxe.play_tool_sound(src, volume=50)
		if(gemhealth > 0)
			visible_message("<span class='danger'>[usr.name] strikes [name]'s Gemstone using [P.name]!</span>")
			log_combat("[key_name(user)] attacks [name]'s gemstone")
			log_admin("[key_name(user)] attacks [name]'s gemstone.")
		else
			visible_message("<span class='danger'>[usr.name] shatters [name] using [P.name]!</span>")
			log_combat("[key_name(user)] shattered [name]")
			log_admin("[key_name(user)] shattered [name]")
			src.Destroy()

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

