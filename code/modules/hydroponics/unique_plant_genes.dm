
// --- Below here are special, unique plant traits that only belong to certain plants. ---
// They are un-removable and cannot be mutated randomly, and should never be graftable.
/// Holymelon's anti-magic trait
/datum/plant_gene/trait/anti_magic
	name = "Anti-Magic Vacuoles"
	/// The amount of anti-magic blocking uses we have.
	var/shield_uses = 1

/datum/plant_gene/trait/anti_magic/on_new_plant(obj/item/our_plant, newloc)
	. = ..()
	if(!.)
		return
	var/obj/item/seeds/our_seed = our_plant.get_plant_seed()
	shield_uses = round(our_seed.potency / 20)
	our_plant.AddComponent(/datum/component/anti_magic, TRUE, TRUE, FALSE, ITEM_SLOT_HANDS, shield_uses, TRUE, CALLBACK(src, .proc/block_magic), CALLBACK(src, .proc/expire)) //deliver us from evil o melon god

/*
 * The proc called when the holymelon successfully blocks a spell.
 *
 * user - the mob who's using the melon
 * major - whether the spell was 'major' or not
 * our_plant - our plant, who's eating the magic spell
 */
/datum/plant_gene/trait/anti_magic/proc/block_magic(mob/user, major, obj/item/our_plant)
	if(major)
		to_chat(user, "<span class='warning'>[our_plant] hums slightly, and seems to decay a bit.</span>")

/*
 * The proc called when the holymelon uses up all of its anti-magic charges.
 *
 * user - the mob who's using the melon
 * major - whether the spell was 'major' or not
 * our_plant - our plant, who tragically melted protecting us from magics
 */
/datum/plant_gene/trait/anti_magic/proc/expire(mob/user, obj/item/our_plant)
	to_chat(user, "<span class='warning'>[our_plant] rapidly turns into ash!</span>")
	new /obj/effect/decal/cleanable/ash(our_plant.drop_location())
	qdel(our_plant)

/// Rose's prickly thorns on pickup.
/datum/plant_gene/trait/rose_thorns
	name = "Rose Thorns"

/datum/plant_gene/trait/rose_thorns/on_new_plant(obj/item/our_plant, newloc)
	. = ..()
	if(!.)
		return

	our_plant.AddElement(/datum/element/plant_backfire, list(TRAIT_PIERCEIMMUNE))
	RegisterSignal(our_plant, COMSIG_PLANT_ON_BACKFIRE, .proc/prick_holder)

/*
 * Pricks the person holding our rose, dealing very minor damage.
 *
 * user - the person who is carrying the rose
 * our_plant - our rose
 */
/datum/plant_gene/trait/rose_thorns/proc/prick_holder(obj/item/our_plant, mob/living/carbon/user)
	SIGNAL_HANDLER

	var/obj/item/seeds/our_seed = our_plant.get_plant_seed()
	if(!our_seed?.get_gene(/datum/plant_gene/trait/sticky) && prob(66))
		to_chat(user, "<span class='danger'>[our_plant]'s thorns nearly prick your hand. Best be careful.</span>")
		return

	to_chat(user, "<span class='danger'>[our_plant]'s thorns prick your hand. Ouch.</span>")
	our_plant.investigate_log("rose-pricked [key_name(user)] at [AREACOORD(user)]", INVESTIGATE_BOTANY)
	var/obj/item/bodypart/affecting = user.get_active_hand()
	if(affecting?.receive_damage(2))
		user.update_damage_overlays()

/// Novaflower's burn on pickup
/datum/plant_gene/trait/novaflower_heat
	name = "Burning Stem"

/datum/plant_gene/trait/novaflower_heat/on_new_plant(obj/item/our_plant, newloc)
	. = ..()
	if(!.)
		return

	our_plant.AddElement(/datum/element/plant_backfire)
	RegisterSignal(our_plant, COMSIG_PLANT_ON_BACKFIRE, .proc/singe_holder)

/*
 * Burn the person holding the novaflower's hand. Their active hand takes burn = the novaflower's force.
 *
 * user - the carbon who is holding the flower.
 */
/datum/plant_gene/trait/novaflower_heat/proc/singe_holder(obj/item/our_plant, mob/living/carbon/user)
	SIGNAL_HANDLER

	to_chat(user, "<span class='danger'>[our_plant] singes your bare hand!</span>")
	our_plant.investigate_log("self-burned [key_name(user)] for [our_plant.force] at [AREACOORD(user)]", INVESTIGATE_BOTANY)
	var/obj/item/bodypart/affecting = user.get_active_hand()
	if(affecting?.receive_damage(0, our_plant.force, wound_bonus = CANT_WOUND))
		user.update_damage_overlays()
	return BACKFIRE_CANCEL_ACTION

/// Novaflower fire on attack
/datum/plant_gene/trait/novaflower_attack
	name = "Heated Petals"

/datum/plant_gene/trait/novaflower_attack/on_new_plant(obj/item/our_plant, newloc)
	. = ..()
	if(!.)
		return

	var/obj/item/seeds/our_seed = our_plant.get_plant_seed()
	our_plant.force = round((5 + our_seed.potency / 5), 1)
	RegisterSignal(our_plant, COMSIG_ITEM_ATTACK, .proc/on_flower_attack)
	RegisterSignal(our_plant, COMSIG_ITEM_AFTERATTACK, .proc/after_flower_attack)

/datum/plant_gene/trait/novaflower_attack/proc/on_flower_attack(obj/item/our_plant, mob/living/target, mob/living/user)
	SIGNAL_HANDLER

	var/obj/item/seeds/our_seed = our_plant.get_plant_seed()
	to_chat(target, "<span class='danger'>You are lit on fire from the intense heat of [our_plant]!</span>")
	target.adjust_fire_stacks(our_seed.potency / 20)
	if(target.IgniteMob())
		message_admins("[ADMIN_LOOKUPFLW(user)] set [ADMIN_LOOKUPFLW(target)] on fire with [our_plant] at [AREACOORD(user)]")
		log_game("[key_name(user)] set [key_name(target)] on fire with [our_plant] at [AREACOORD(user)]")
	our_plant.investigate_log("was used by [key_name(user)] to burn [key_name(target)] at [AREACOORD(user)]", INVESTIGATE_BOTANY)

/datum/plant_gene/trait/novaflower_attack/proc/after_flower_attack(obj/item/our_plant, atom/target, mob/user)
	SIGNAL_HANDLER

	if(our_plant.force > 0)
		our_plant.force -= rand(1, (our_plant.force / 3) + 1)
	else
		to_chat(user, "<span class='warning'>All the petals have fallen off [our_plant] from violent whacking!</span>")
		qdel(our_plant)

/// Sunflower flavor text on attack
/datum/plant_gene/trait/sunflower_attack
	name = "Bright Petals"

/datum/plant_gene/trait/sunflower_attack/on_new_plant(obj/item/our_plant, newloc)
	. = ..()
	if(!.)
		return

	RegisterSignal(our_plant, COMSIG_ITEM_AFTERATTACK, .proc/after_flower_attack)

/datum/plant_gene/trait/sunflower_attack/proc/after_flower_attack(obj/item/our_plant, mob/living/target, mob/living/user)
	SIGNAL_HANDLER

	user.visible_message("<font color='green'>[user] smacks [target] with their [our_plant]!<font color='orange'><b>FLOWER POWER!</b></font></font>", ignored_mobs = list(target, user))
	to_chat(target, "<font color='green'>[user] smacks you with [our_plant]!<font color='orange'><b>FLOWER POWER!</b></font></font>")
	to_chat(user, "<font color='green'>Your [our_plant]'s <font color='orange'><b>FLOWER POWER</b></font> strikes [target]!</font>")

/// Normal Nettle force + leaves falling off
/datum/plant_gene/trait/nettle_attack
	name = "Stinging Nettles"
	/// The multiplier we apply to the potency to calculate force.
	var/force_multiplier = 0.2

/datum/plant_gene/trait/nettle_attack/on_new_plant(obj/item/our_plant, newloc)
	. = ..()
	if(!.)
		return

	var/obj/item/seeds/our_seed = our_plant.get_plant_seed()
	our_plant.force = round((5 + our_seed.potency * force_multiplier), 1)
	RegisterSignal(our_plant, COMSIG_ITEM_AFTERATTACK, .proc/after_nettle_attack)

/datum/plant_gene/trait/nettle_attack/proc/after_nettle_attack(obj/item/our_plant, atom/target, mob/user)
	SIGNAL_HANDLER

	if(our_plant.force > 0)
		our_plant.force -= rand(1, (our_plant.force / 3) + 1)
	else
		to_chat(user, "<span class='warning'>All the petals have fallen off [our_plant] from violent whacking!</span>")
		qdel(our_plant)

/datum/plant_gene/trait/nettle_attack/death
	name = "Aggressive Stinging Nettles"
	force_multiplier = 0.4

/datum/plant_gene/trait/nettle_attack/death/on_new_plant(obj/item/our_plant, newloc)
	. = ..()
	if(!.)
		return

	RegisterSignal(our_plant, COMSIG_ITEM_ATTACK, .proc/on_deathnettle_attack)

/datum/plant_gene/trait/nettle_attack/death/proc/on_deathnettle_attack(obj/item/our_plant, mob/living/target, mob/living/user)
	SIGNAL_HANDLER

	to_chat(target, "<span class='danger'>You are stunned by the powerful acid of [our_plant]!</span>")
	user.visible_message("<span class='danger'>[user] stuns [target] with the powerful acids of [our_plant]!")
	log_combat(user, target, "attacked with deathnettle", our_plant)
	our_plant.investigate_log("was used by [key_name(user)] to stun [key_name(target)] at [AREACOORD(user)]", INVESTIGATE_BOTANY)

	target.adjust_blurriness(our_plant.force / 7)
	if(prob(20))
		target.Unconscious(our_plant.force / 0.3)
		target.Paralyze(our_plant.force / 0.75)
	target.drop_all_held_items()

/// Normal Nettle burn on attack/pickup
/datum/plant_gene/trait/nettle_burn
	name = "Stinging Stem"

/datum/plant_gene/trait/nettle_burn/on_new_plant(obj/item/our_plant, newloc)
	. = ..()
	if(!.)
		return

	our_plant.AddElement(/datum/element/plant_backfire, list(TRAIT_PIERCEIMMUNE))
	RegisterSignal(our_plant, COMSIG_PLANT_ON_BACKFIRE, .proc/burn_holder)

/*
 * Burn the person holding the nettle's hands. Their active hand takes burn = the nettle's force.
 *
 * user - the carbon who is holding the nettle.
 */
/datum/plant_gene/trait/nettle_burn/proc/burn_holder(obj/item/our_plant, mob/living/carbon/user)
	to_chat(user, "<span class='danger'>[our_plant] burns your bare hand!</span>")
	our_plant.investigate_log("self-burned [key_name(user)] for [our_plant.force] at [AREACOORD(user)]", INVESTIGATE_BOTANY)
	var/obj/item/bodypart/affecting = user.get_active_hand()
	if(affecting?.receive_damage(0, our_plant.force, wound_bonus = CANT_WOUND))
		user.update_damage_overlays()

/// DeathNettle burn on attack/pickup
/datum/plant_gene/trait/nettle_burn/death
	name = "Aggressive Stinging Stem"

/datum/plant_gene/trait/nettle_burn/death/burn_holder(obj/item/our_plant, mob/living/carbon/user)
	. = ..()
	if(prob(50))
		user.Paralyze(100)
		to_chat(user, "<span class='userdanger'>You are stunned by the powerful acids of [our_plant]!</span>")
	return BACKFIRE_CANCEL_ACTION
