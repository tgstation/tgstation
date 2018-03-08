//WEAPON TYPE- Acts as a force multiplier and speed multiplier
#define MELEE_TYPE_DAGGER 0.5
#define MELEE_TYPE_SWORD 2
#define MELEE_TYPE_GREATSWORD 3.5
#define MELEE_TYPE_MACE 3
#define MELEE_TYPE_WARHAMMER 5

//STABBINESS DEFINES - //Affects the rate of reagent transfer and the type, values below 1 are considered blunt and will apply touch effects
#define TRANSFER_SHARP 1
#define TRANSFER_SHARPER 1.5
#define TRANSFER_SHARPEST 2
#define TRANSFER_PARTIALLY_BLUNT 0.5
#define TRANSFER_BLUNT 0.1
#define TRANSFER_SHARP_BONUS 0.4


//SPECIAL TRAITS
#define SPECIAL_TRAIT_MAXIMUM 5
#define SPECIAL_TRAIT_ADD_COST 50
#define SPECIAL_TRAIT_ADD_SPEED_DEBUFF 1
#define SPECIAL_TRAIT_METALLIC /datum/special_trait/metallic
#define SPECIAL_TRAIT_SHARP /datum/special_trait/sharp
#define SPECIAL_TRAIT_RADIOACTIVE /datum/special_trait/radioactive
#define SPECIAL_TRAIT_ULTRADENSE /datum/special_trait/ultradense
#define SPECIAL_TRAIT_MAGNETIC /datum/special_trait/magnetic
#define SPECIAL_TRAIT_REFLECTIVE /datum/special_trait/reflective
#define SPECIAL_TRAIT_BOUNCY /datum/special_trait/bouncy
#define SPECIAL_TRAIT_UNSTABLE /datum/special_trait/unstable
#define SPECIAL_TRAIT_FIRE /datum/special_trait/fire
#define SPECIAL_TRAIT_CRYO /datum/special_trait/cryo
#define SPECIAL_TRAIT_ACID /datum/special_trait/acid
#define SPECIAL_TRAIT_FLUIDIC /datum/special_trait/fluidic
#define SPECIAL_TRAIT_EXPLOSIVE /datum/special_trait/explosive

//SPECIAL IDENTIFIERS - saving me some istype checks
#define FORGED_MELEE_SINGLEHANDED "singlehanded"
#define FORGED_MELEE_TWOHANDED "twohanded"
#define FORGED_BULLET_CASING "bullet"
#define FORGED_INGOT = "ingot"

//SPECIAL TRAIT DATUMS

/datum/special_trait
	var/name//these are for analysis in game so people can actually see what the traits are
	var/desc//
	var/effectiveness = 100//probability of the trait being activated if it's a constant or on hit effect


/datum/special_trait/proc/on_apply(obj/item/I, type)
	return


/datum/special_trait/proc/on_hit(atom/target, mob/user, obj/item/I, type)
	return


/datum/special_trait/metallic
	name = "Metallic"
	desc = "30% buff to all damage, found in practically all metals"


/datum/special_trait/metallic/on_apply(obj/item/I, type)
	if(type && I)
		switch(type)
			if(FORGED_MELEE_SINGLEHANDED)
				var/obj/item/forged/F = I
				F.force = F.force * 1.3
				F.throwforce = F.throwforce * 1.3
			if(FORGED_MELEE_TWOHANDED)
				var/obj/item/twohanded/forged/F = I
				F.force_unwielded = F.force_unwielded * 1.3
				F.force_wielded = F.force_wielded * 1.3
				F.throwforce = F.throwforce * 1.3
			if(FORGED_BULLET_CASING)
				var/obj/item/projectile/bullet/forged/F = I
				F.damage = F.damage * 1.3
				F.armour_penetration += 10


/datum/special_trait/sharp
	name = "Sharp"
	desc = "Makes sharp weapons sharper, increases armour penetration and shifts reagent transfer more towards direct injection as opposed to touch"


/datum/special_trait/sharp/on_apply(obj/item/I, type)
	if(type && I)
		switch(type)
			if(FORGED_MELEE_SINGLEHANDED)
				var/obj/item/forged/F = I
				F.armour_penetration += 10
				F.stabby += TRANSFER_SHARP_BONUS
				if(F.sharpness == IS_SHARP)
					F.sharpness = IS_SHARP_ACCURATE
			if(FORGED_MELEE_TWOHANDED)
				var/obj/item/twohanded/forged/F = I
				F.armour_penetration += 10
				F.stabby += TRANSFER_SHARP_BONUS
				if(F.sharpness == IS_SHARP)
					F.sharpness = IS_SHARP_ACCURATE
			if(FORGED_BULLET_CASING)
				var/obj/item/projectile/bullet/forged/F = I
				F.dismemberment += 20


/datum/special_trait/radioactive
	name = "Radioactive"
	desc = "Continously irradiates the surrounding area, quite dangerous to the user!"


/datum/special_trait/radioactive/on_apply(obj/item/I, type)
	if(type && I)
		switch(type)
			if(FORGED_MELEE_SINGLEHANDED)
				var/obj/item/forged/F = I
				F.radioactive = TRUE
				START_PROCESSING(SSobj, F)
			if(FORGED_MELEE_TWOHANDED)
				var/obj/item/twohanded/forged/F = I
				F.radioactive = TRUE
				START_PROCESSING(SSobj, F)
			if(FORGED_BULLET_CASING)
				var/obj/item/projectile/bullet/forged/F = I
				F.radioactive = TRUE


/datum/special_trait/ultradense
	name = "Ultradense"
	desc = "Found in exceptionally dense materials, allows bullets to penetrate and adds knockback to all weapons"


/datum/special_trait/ultradense/on_apply(obj/item/I, type)
	if(type && I)
		switch(type)
			if(FORGED_BULLET_CASING)
				var/obj/item/projectile/bullet/forged/F = I
				if(F.damage >= 20)
					F.forcedodge = TRUE
					F.range = F.range * 0.5//oof


/datum/special_trait/ultradense/on_hit(atom/target, mob/user, obj/item/I, type)
	if(I && target && type)
		if(type == FORGED_BULLET_CASING)
			var/obj/item/projectile/bullet/forged/F = I
			if(isliving(target))
				var/mob/living/M = target
				M.throw_at(get_edge_target_turf(M, F.dir),1 ,5)
		else//we assume it's melee
			if(isliving(target))
				var/mob/living/M = target
				M.throw_at(get_edge_target_turf(M, user.dir),1 ,5)


/datum/special_trait/magnetic
	name = "Magnetic"
	desc = "High chance of throwing all metal items to the object's location when activated"
	effectiveness = 50


/datum/special_trait/magnetic/on_hit(atom/target, mob/user, obj/item/I, type)
	if(I && type)
		if(type == FORGED_BULLET_CASING)
			for(var/obj/O in orange(I, 5))
				if(O && !O.anchored && O.flags_1 & CONDUCT_1)
					O.throw_at(I, 4, 3)
		else if(user)
			for(var/obj/O in orange(user, 5))
				if(O && !O.anchored && O.flags_1 & CONDUCT_1)
					O.throw_at(user, 4, 3)

/datum/special_trait/reflective
	name = "Reflective"
	desc = "Adds block chance to melee weapons"


/datum/special_trait/reflective/on_apply(obj/item/I, type)
	if(type != FORGED_BULLET_CASING)
		I.block_chance += 50


/datum/special_trait/bouncy
	name = "Bouncy"
	desc = "100% ricochet chance for bullets, only works on certain surfaces"


/datum/special_trait/bouncy/on_apply(obj/item/I, type)
	if(type == FORGED_BULLET_CASING)
		var/obj/item/projectile/bullet/forged/F = I
		F.ricochets_max += 10
		F.ricochet_chance = 100


/datum/special_trait/unstable
	name = "Unstable"
	desc = "Stats randomly change when applied"

/datum/special_trait/unstable/on_hit(atom/target, mob/user, obj/item/I, type)
	if(type && I)
		switch(type)
			if(FORGED_MELEE_SINGLEHANDED)
				var/obj/item/forged/F = I
				F.force = rand(1, 80)
				F.speed = rand(CLICK_CD_RAPID, CLICK_CD_MELEE * 5)
				F.stabby = rand(TRANSFER_BLUNT, TRANSFER_SHARPEST)
			if(FORGED_MELEE_TWOHANDED)
				var/obj/item/twohanded/forged/F = I
				F.force_wielded = rand(1, 80)
				F.force_unwielded = max(0.1, F.force_wielded / 3)
				F.speed = rand(CLICK_CD_RAPID, CLICK_CD_MELEE * 5)
				F.stabby = rand(TRANSFER_BLUNT, TRANSFER_SHARPEST)
			if(FORGED_BULLET_CASING)
				var/obj/item/projectile/bullet/forged/F = I
				F.damage = rand(1, 80)
				F.speed = rand(0, 5)
				F.damage_type = pick(BRUTE, BURN, TOX, OXY, CLONE)


/datum/special_trait/fire
	name = "Fire"
	desc = "Found in various pyrotechnic reagents, small chance to ignite on hit and acts as an open flame in regards to flammable gases. This may burn your hands!"
	effectiveness = 10


/datum/special_trait/fire/on_apply(obj/item/I, type)
	if(I && type)
		switch(type)
			if(FORGED_MELEE_SINGLEHANDED)
				var/obj/item/forged/F = I
				F.fire = TRUE
				F.add_overlay(GLOB.fire_overlay, TRUE)
				START_PROCESSING(SSobj, I)
			if(FORGED_MELEE_TWOHANDED)
				var/obj/item/twohanded/forged/F = I
				F.fire = TRUE
				F.add_overlay(GLOB.fire_overlay, TRUE)
				START_PROCESSING(SSobj, I)
			if(FORGED_BULLET_CASING)
				var/obj/item/projectile/bullet/forged/F = I
				F.fire = TRUE
				F.add_overlay(GLOB.fire_overlay, TRUE)


/datum/special_trait/fire/on_hit(atom/target, mob/user, obj/item/I, type)
	if(I && target)
		if(isliving(target))
			var/mob/living/M = target
			M.adjust_fire_stacks(1)//only one because chances are this is already a chem that adds fire stacks
			M.IgniteMob()

	if(user && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.gloves)
			return
		var/hit_zone = (C.held_index_to_dir(C.active_hand_index) == "l" ? "l_":"r_") + "arm"
		var/obj/item/bodypart/affecting = C.get_bodypart(hit_zone)
		if(affecting)
			if(affecting.receive_damage(0, 5))
				to_chat(C, "<span class='userdanger'>The fire scorches your hand!</span>")


/datum/special_trait/cryo
	name = "Cryo"
	desc = "Found in cold reagents, fairly small chance to chill target on hit"
	effectiveness = 15


/datum/special_trait/cryo/on_apply(obj/item/I, type)
	if(I)
		I.add_atom_colour(GLOB.freon_color_matrix, FIXED_COLOUR_PRIORITY)
		I.alpha -= 25

/datum/special_trait/cryo/on_hit(atom/target, mob/user, obj/item/I, type)
	if(I && target)
		if(isliving(target))
			var/mob/living/M = target
			M.bodytemperature = max(M.bodytemperature - rand(50, 100), TCMB)


/datum/special_trait/acid
	name = "Acidic"
	desc = "Self explanatory, chance to apply acid to whatever it touches: including the user's hand!"
	effectiveness = 25
	var/datum/reagent/acid

/datum/special_trait/acid/on_apply(obj/item/I, type)
	if(I)
		acid = new /datum/reagent/toxin/acid/fluacid
		I.resistance_flags |= ACID_PROOF
		I.acid_act(INFINITY, 1)

/datum/special_trait/acid/on_hit(atom/target, mob/user, obj/item/I, type)
	if(I && target)
		if(isliving(target))
			acid.reaction_mob(target, TOUCH, 2)
		else if(isturf(target))
			acid.reaction_turf(target, TOUCH, 2)
		else if(isobj(target))
			acid.reaction_obj(target, TOUCH, 2)

	if(user && iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.gloves)
			return
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(H.dna && H.dna.species)
				if(H.has_trait(TRAIT_PIERCEIMMUNE))
					return
		var/hit_zone = (C.held_index_to_dir(C.active_hand_index) == "l" ? "l_":"r_") + "arm"
		var/obj/item/bodypart/affecting = C.get_bodypart(hit_zone)
		if(affecting)
			if(affecting.receive_damage(0, 5))
				to_chat(C, "<span class='userdanger'>The acid burns your hand!</span>")


/datum/special_trait/fluidic
	name = "Fluidic"
	desc = "Chance to randomly spray its reagent type in all directions on hit!"
	effectiveness = 15

/datum/special_trait/fluidic/on_hit(atom/target, mob/user, obj/item/I, type)
	if(I && type)
		switch(type)
			if(FORGED_MELEE_SINGLEHANDED)
				if(user)
					var/obj/item/forged/F = I
					splash(1, F, user, TOUCH, 2)

			if(FORGED_MELEE_TWOHANDED)
				if(user)
					var/obj/item/twohanded/forged/F = I
					splash(1, F, user, TOUCH, 2)

			if(FORGED_BULLET_CASING)
				var/obj/item/projectile/bullet/forged/F = I
				splash(1, F, F, TOUCH, 2)


/datum/special_trait/explosive
	name = "Explosive"
	desc = "Dangerous and self explanatory!"
	effectiveness = 5

/datum/special_trait/explosive/on_hit(atom/target, mob/user, obj/item/I, type)
	if(I && type)
		if(type == FORGED_BULLET_CASING)
			explosion(get_turf(I), 0, 1, 2, 4)
		else if(user)
			explosion(user, 0, 1, 2, 4)

/datum/special_trait/proc/splash(radius, obj/item/forged/source, epicenter, type, amount)
	for(var/atom/A in view(radius, epicenter))
		if(isliving(A))
			source.reagent_type.reaction_mob(A, type, amount)
		else if(isturf(A))
			source.reagent_type.reaction_turf(A, type, amount)
		else if(isobj(A))
			source.reagent_type.reaction_obj(A, type, amount)