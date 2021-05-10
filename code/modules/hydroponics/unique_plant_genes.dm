
// --- Below here are special, unique plant traits that only belong to certain plants. ---
// They are un-removable and cannot be mutated randomly, and should never be graftable.

/// Holymelon's anti-magic trait. Charges based on potency.
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

/// Traits that turn a plant into a weapon, giving them force and effects on attack.
/datum/plant_gene/trait/attack
	name = "On Attack Trait"
	/// The multiplier we apply to the potency to calculate force. Set to 0 to not affect the force.
	var/force_multiplier = 0

/datum/plant_gene/trait/attack/on_new_plant(obj/item/our_plant, newloc)
	. = ..()
	if(!.)
		return

	if(force_multiplier)
		var/obj/item/seeds/our_seed = our_plant.get_plant_seed()
		our_plant.force = round((5 + our_seed.potency * force_multiplier), 1)
	RegisterSignal(our_plant, COMSIG_ITEM_ATTACK, .proc/on_plant_attack)
	RegisterSignal(our_plant, COMSIG_ITEM_AFTERATTACK, .proc/after_plant_attack)

/*
 * Plant effects ON attack.
 *
 * our_plant - our plant, that we're attacking with
 * user - the person who is attacking with the plant
 * target - the person who is attacked by the plant
 */
/datum/plant_gene/trait/attack/proc/on_plant_attack(obj/item/our_plant, mob/living/target, mob/living/user)
	SIGNAL_HANDLER

/*
 * Plant effects AFTER attack.
 *
 * our_plant - our plant, that we're attacking with
 * user - the person who is attacking with the plant
 * target - the person who is attacked by the plant
 */
/datum/plant_gene/trait/attack/proc/after_plant_attack(obj/item/our_plant, atom/target, mob/user)
	SIGNAL_HANDLER

/// Novaflower's attack effects (sets people on fire) + degradation on attack
/datum/plant_gene/trait/attack/novaflower_attack
	name = "Heated Petals"
	force_multiplier = 0.2

/datum/plant_gene/trait/attack/novaflower_attack/on_plant_attack(obj/item/our_plant, mob/living/target, mob/living/user)
	. = ..()

	var/obj/item/seeds/our_seed = our_plant.get_plant_seed()
	to_chat(target, "<span class='danger'>You are lit on fire from the intense heat of [our_plant]!</span>")
	target.adjust_fire_stacks(our_seed.potency / 20)
	if(target.IgniteMob())
		message_admins("[ADMIN_LOOKUPFLW(user)] set [ADMIN_LOOKUPFLW(target)] on fire with [our_plant] at [AREACOORD(user)]")
		log_game("[key_name(user)] set [key_name(target)] on fire with [our_plant] at [AREACOORD(user)]")
	our_plant.investigate_log("was used by [key_name(user)] to burn [key_name(target)] at [AREACOORD(user)]", INVESTIGATE_BOTANY)

/datum/plant_gene/trait/attack/novaflower_attack/after_plant_attack(obj/item/our_plant, atom/target, mob/user)
	. = ..()

	if(our_plant.force > 0)
		our_plant.force -= rand(1, (our_plant.force / 3) + 1)
	else
		to_chat(user, "<span class='warning'>All the petals have fallen off [our_plant] from violent whacking!</span>")
		qdel(our_plant)

/// Sunflower's attack effect (shows cute text)
/datum/plant_gene/trait/attack/sunflower_attack
	name = "Bright Petals"

/datum/plant_gene/trait/attack/sunflower_attack/after_plant_attack(obj/item/our_plant, mob/living/target, mob/living/user)
	. = ..()

	if(!istype(target))
		return

	user.visible_message("<font color='green'>[user] smacks [target] with their [our_plant.name]! <font color='orange'><b>FLOWER POWER!</b></font></font>", ignored_mobs = list(target, user))
	if(target != user)
		to_chat(target, "<font color='green'>[user] smacks you with [our_plant]!<font color='orange'><b>FLOWER POWER!</b></font></font>")
	to_chat(user, "<font color='green'>Your [our_plant.name]'s <font color='orange'><b>FLOWER POWER</b></font> strikes [target]!</font>")

/// Normal nettle's force + degradation on attack
/datum/plant_gene/trait/attack/nettle_attack
	name = "Sharpened Leaves"
	force_multiplier = 0.2

/datum/plant_gene/trait/attack/nettle_attack/after_plant_attack(obj/item/our_plant, atom/target, mob/user)
	. = ..()

	if(our_plant.force > 0)
		our_plant.force -= rand(1, (our_plant.force / 3) + 1)
	else
		to_chat(user, "<span class='warning'>All the leaves have fallen off [our_plant] from violent whacking.</span>")
		qdel(our_plant)

/// Deathnettle force + effects on attack (stun) + degradation on attack
/datum/plant_gene/trait/attack/nettle_attack/death
	name = "Aggressive Sharpened Leaves"
	force_multiplier = 0.4

/datum/plant_gene/trait/attack/nettle_attack/death/on_plant_attack(obj/item/our_plant, mob/living/target, mob/living/user)
	. = ..()

	to_chat(target, "<span class='danger'>You are stunned by the powerful acid of [our_plant]!</span>")
	user.visible_message("<span class='danger'>[user] stuns [target] with the powerful acids of [our_plant]!")
	log_combat(user, target, "attacked with deathnettle", our_plant)
	our_plant.investigate_log("was used by [key_name(user)] to stun [key_name(target)] at [AREACOORD(user)]", INVESTIGATE_BOTANY)

	target.adjust_blurriness(our_plant.force / 7)
	if(prob(20))
		target.Unconscious(our_plant.force / 0.3)
		target.Paralyze(our_plant.force / 0.75)
	target.drop_all_held_items()

/// Traits for plants with backfire effects. These are negative effects that occur when a plant is handled without gloves/unsafely.
/datum/plant_gene/trait/backfire
	name = "Backfire Trait"
	/// A list of extra traits to check to be considered safe.
	var/traits_to_check
	/// A list of extra genes to check to be considered safe.
	var/genes_to_check

/datum/plant_gene/trait/backfire/on_new_plant(obj/item/our_plant, newloc)
	. = ..()
	if(!.)
		return

	our_plant.AddElement(/datum/element/plant_backfire, traits_to_check, genes_to_check)
	RegisterSignal(our_plant, COMSIG_PLANT_ON_BACKFIRE, .proc/backfire_effect)

/*
 * The backfire effect. Override with plant-specific effects.
 *
 * user - the person who is carrying the plant
 * our_plant - our plant
 */
/datum/plant_gene/trait/backfire/proc/backfire_effect(obj/item/our_plant, mob/living/carbon/user)
	SIGNAL_HANDLER

/// Rose's prick on backfire
/datum/plant_gene/trait/backfire/rose_thorns
	name = "Rose Thorns"
	traits_to_check = list(TRAIT_PIERCEIMMUNE)

/datum/plant_gene/trait/backfire/rose_thorns/backfire_effect(obj/item/our_plant, mob/living/carbon/user)
	. = ..()

	var/obj/item/seeds/our_seed = our_plant.get_plant_seed()
	if(!our_seed.get_gene(/datum/plant_gene/trait/sticky) && prob(66))
		to_chat(user, "<span class='danger'>[our_plant]'s thorns nearly prick your hand. Best be careful.</span>")
		return

	to_chat(user, "<span class='danger'>[our_plant]'s thorns prick your hand. Ouch.</span>")
	our_plant.investigate_log("rose-pricked [key_name(user)] at [AREACOORD(user)]", INVESTIGATE_BOTANY)
	var/obj/item/bodypart/affecting = user.get_active_hand()
	if(affecting?.receive_damage(2))
		user.update_damage_overlays()

/// Novaflower's hand burn on backfire
/datum/plant_gene/trait/backfire/novaflower_heat
	name = "Burning Stem"

/datum/plant_gene/trait/backfire/novaflower_heat/backfire_effect(obj/item/our_plant, mob/living/carbon/user)
	. = ..()

	to_chat(user, "<span class='danger'>[our_plant] singes your bare hand!</span>")
	our_plant.investigate_log("self-burned [key_name(user)] for [our_plant.force] at [AREACOORD(user)]", INVESTIGATE_BOTANY)
	var/obj/item/bodypart/affecting = user.get_active_hand()
	if(affecting?.receive_damage(0, our_plant.force, wound_bonus = CANT_WOUND))
		user.update_damage_overlays()
	return BACKFIRE_CANCEL_ACTION

/// Normal Nettle hannd burn on backfire
/datum/plant_gene/trait/backfire/nettle_burn
	name = "Stinging Stem"

/datum/plant_gene/trait/backfire/nettle_burn/backfire_effect(obj/item/our_plant, mob/living/carbon/user)
	. = ..()

	to_chat(user, "<span class='danger'>[our_plant] burns your bare hand!</span>")
	our_plant.investigate_log("self-burned [key_name(user)] for [our_plant.force] at [AREACOORD(user)]", INVESTIGATE_BOTANY)
	var/obj/item/bodypart/affecting = user.get_active_hand()
	if(affecting?.receive_damage(0, our_plant.force, wound_bonus = CANT_WOUND))
		user.update_damage_overlays()

/// Deathnettle hand burn + stun on backfire
/datum/plant_gene/trait/backfire/nettle_burn/death
	name = "Aggressive Stinging Stem"

/datum/plant_gene/trait/backfire/nettle_burn/death/backfire_effect(obj/item/our_plant, mob/living/carbon/user)
	. = ..()

	if(prob(50))
		user.Paralyze(100)
		to_chat(user, "<span class='userdanger'>You are stunned by the powerful acids of [our_plant]!</span>")
	return BACKFIRE_CANCEL_ACTION

/// Ghost-Chili heating up on backfire
/datum/plant_gene/trait/backfire/chili_heat
	name = "Active Capsicum Glands"
	/// The mob currently holding the chili.
	var/mob/living/carbon/human/held_mob
	/// The chili this gene is tied to, to track it for processing.
	var/obj/item/our_chili

/datum/plant_gene/trait/backfire/chili_heat/on_new_plant(obj/item/our_plant, newloc)
	. = ..()
	if(!.)
		return

	RegisterSignal(our_plant, list(COMSIG_PARENT_PREQDELETED, COMSIG_ITEM_DROPPED), .proc/stop_backfire_effect)

/*
 * Begin processing the trait on backfire.
 *
 * our_plant - our source plant, which is backfiring
 * user - the mob holding our plant
 */
/datum/plant_gene/trait/backfire/chili_heat/backfire_effect(obj/item/our_plant, mob/living/carbon/user)
	. = ..()

	held_mob = user
	START_PROCESSING(SSobj, src)

/*
 * Stop processing the trait when we're dropped or deleted.
 *
 * our_plant - our source plant
 */
/datum/plant_gene/trait/backfire/chili_heat/proc/stop_backfire_effect(datum/source)
	SIGNAL_HANDLER

	held_mob = null
	STOP_PROCESSING(SSobj, src)

/*
 * The processing of our trait. Heats up the mob ([held_mob]) currently holding the source plant ([our_chili]).
 * Stops processing if we're no longer being held by [held mob].
 */
/datum/plant_gene/trait/backfire/chili_heat/process(delta_time)
	if(our_chili.loc == held_mob)
		if(held_mob.is_holding(our_chili))
			held_mob.adjust_bodytemperature(7.5 * TEMPERATURE_DAMAGE_COEFFICIENT * delta_time)
			if(DT_PROB(5, delta_time))
				to_chat(held_mob, "<span class='warning'>Your hand holding [our_chili] burns!</span>")
	else
		stop_backfire_effect()

/// Bluespace Tomato squashing on the user on backfire
/datum/plant_gene/trait/backfire/bluespace
	name = "Bluespace Volatility"

/datum/plant_gene/trait/backfire/bluespace/backfire_effect(obj/item/our_plant, mob/living/carbon/user)
	. = ..()

	if(prob(50))
		to_chat(user, "<span class='danger'>[our_plant] slips out of your hand!</span>")
		INVOKE_ASYNC(our_plant, /obj/item/.proc/attack_self, user)
		return BACKFIRE_CANCEL_ACTION

/// Traits for plants that can be activated to turn into a mob.
/datum/plant_gene/trait/mob_transformation
	name = "Dormat Ferocity"
	/// The typepath to what mob spawns from this plant.
	var/killer_plant
	/// Whether our attatched plant is currently waking up or not.
	var/awakening = FALSE

/datum/plant_gene/trait/mob_transformation/on_new_plant(obj/item/our_plant, newloc)
	. = ..()
	if(!.)
		return

	our_plant.AddElement(/datum/element/plant_backfire)
	RegisterSignal(our_plant, COMSIG_PLANT_ON_BACKFIRE, .proc/early_awakening)
	RegisterSignal(our_plant, COMSIG_ITEM_ATTACK_SELF, .proc/manual_awakening)
	RegisterSignal(our_plant, COMSIG_ITEM_PRE_ATTACK, .proc/pre_consumption_check)

/*
 * Before we can eat our plant, check to see if it's waking up. Don't eat it if it is.
 *
 * our_plant - signal source, the plant we're eating
 * target - the mob eating the plant
 * user - the mob feeding someone the plant (generally, target == user)
 */
/datum/plant_gene/trait/mob_transformation/proc/pre_consumption_check(obj/item/our_plant, atom/target, mob/user)
	SIGNAL_HANDLER

	if(!awakening)
		return

	if(!ismob(target))
		return

	if(target != user)
		to_chat(user, "<span class='warning'>[our_plant] is twitching and shaking, preventing you from feeding it to [target].</span>")
	to_chat(target, "<span class='warning'>[our_plant] is twitching and shaking, preventing you from eating it.</span>")
	return COMPONENT_CANCEL_ATTACK_CHAIN

/*
 * Called when a user manually activates the plant.
 * Checks if the critera is met to spawn it, and spawns it in 3 seconds if it is.
 *
 * our_plant - our plant that we're waking up
 * user - the mob activating the plant
 */
/datum/plant_gene/trait/mob_transformation/proc/manual_awakening(obj/item/our_plant, mob/user)
	SIGNAL_HANDLER

	if(awakening || isspaceturf(user.loc))
		return

	to_chat(user, "<span class='notice'>You begin to awaken [our_plant]...</span>")
	begin_awaken(our_plant, 3 SECONDS)
	log_game("[key_name(user)] awakened a [our_plant] at [AREACOORD(user)].")

/*
 * Called when a user accidentally activates the plant via backfire effect.
 *
 * our_plant - our plant, which is waking up
 * user - the mob handling the plant
 */
/datum/plant_gene/trait/mob_transformation/proc/early_awakening(obj/item/our_plant, mob/living/carbon/user)
	SIGNAL_HANDLER

	if(!awakening && !isspaceturf(user.loc) && prob(25))
		to_chat(user, "<span class='danger'>[our_plant] begins to growl and shake!</span>")
		begin_awaken(our_plant, 1 SECONDS)

/*
 * Actually begin the process of awakening the plant.
 *
 * awaken_time - the time, in seconds, it will take for the plant to spawn.
 */
/datum/plant_gene/trait/mob_transformation/proc/begin_awaken(obj/item/our_plant, awaken_time)
	awakening = TRUE
	addtimer(CALLBACK(src, .proc/awaken, our_plant), awaken_time)

/*
 * Actually awaken the plant, spawning the mob designated by the [killer_plant] typepath.
 *
 * our_plant - the plant that's waking up
 */
/datum/plant_gene/trait/mob_transformation/proc/awaken(obj/item/our_plant)
	if(QDELETED(our_plant))
		return
	if(!ispath(killer_plant))
		return

	var/obj/item/seeds/our_seed = our_plant.get_plant_seed()
	var/mob/living/spawned_mob = new killer_plant(our_plant.drop_location())
	spawned_mob.maxHealth += round(our_seed.endurance / 3)
	spawned_mob.health = spawned_mob.maxHealth
	if(ishostile(spawned_mob))
		var/mob/living/simple_animal/hostile/spawned_simplemob = spawned_mob
		spawned_simplemob.melee_damage_lower += round(our_seed.potency / 10)
		spawned_simplemob.melee_damage_upper += round(our_seed.potency / 10)
		spawned_simplemob.move_to_delay -= round(our_seed.production / 50)
	our_plant.forceMove(our_plant.drop_location())
	spawned_mob.visible_message("<span class='notice'>[our_plant] growls as it suddenly awakens!</span>")
	qdel(our_plant)

/// Killer Tomato's transformation gene.
/datum/plant_gene/trait/mob_transformation/tomato
	killer_plant = /mob/living/simple_animal/hostile/killertomato

/// Plants eaten in 1 bite.
/datum/plant_gene/trait/one_bite
	name = "Large Bites"

/datum/plant_gene/trait/one_bite/on_new_plant(obj/item/our_plant, newloc)
	. = ..()
	if(!.)
		return

	var/obj/item/food/grown/grown_plant = our_plant
	if(istype(grown_plant))
		grown_plant.bite_consumption_mod = 100

/// Traits for plants with a different base volume.
/datum/plant_gene/trait/modified_volume
	name = "Deep Vesicles"
	/// The new number we set the plant's max_volume to.
	var/new_capcity = 100

/datum/plant_gene/trait/modified_volume/on_new_plant(obj/item/our_plant, newloc)
	. = ..()
	if(!.)
		return

	var/obj/item/food/grown/grown_plant = our_plant
	if(istype(grown_plant))
		grown_plant.max_volume = new_capcity

/datum/plant_gene/trait/modified_volume/omega_weed
	name = "Dank Vesicles"
	new_capcity = 420
