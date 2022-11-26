/obj/item/organ/internal/brain/psyker
	name = "psyker brain"
	desc = "This brain is blue, split into two hemispheres, and has immense psychic powers. Why does that even exist?"
	icon_state = "brain-psyker"

/obj/item/organ/internal/brain/psyker/Insert(mob/living/carbon/inserted_into, special, drop_if_replaced, no_id_transfer)
	if(!istype(inserted_into.get_bodypart(BODY_ZONE_HEAD), /obj/item/bodypart/head/psyker))
		return FALSE
	. = ..()
	inserted_into.AddComponent(/datum/component/echolocation)

/obj/item/bodypart/head/psyker
	limb_id = BODYPART_ID_PSYKER
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodypart_traits = list(TRAIT_DISFIGURED, TRAIT_BALD, TRAIT_SHAVED, TRAIT_BLIND, TRAIT_UNINTELLIGIBLE_SPEECH)

/mob/living/carbon/human/proc/psykerize()
	if(stat == DEAD || !get_bodypart(BODY_ZONE_HEAD))
		return
	to_chat(src, span_userdanger("You feel unwell..."))
	sleep(5 SECONDS)
	if(stat == DEAD || !get_bodypart(BODY_ZONE_HEAD))
		return
	to_chat(src, span_userdanger("It hurts!"))
	emote("scream")
	apply_damage(30, BRUTE, BODY_ZONE_HEAD)
	sleep(5 SECONDS)
	var/obj/item/bodypart/head/old_head = get_bodypart(BODY_ZONE_HEAD)
	var/obj/item/organ/internal/brain/old_brain = getorganslot(ORGAN_SLOT_BRAIN)
	var/obj/item/organ/internal/old_eyes = getorganslot(ORGAN_SLOT_EYES)
	if(stat == DEAD || !old_head || !old_brain)
		return
	to_chat(src, span_userdanger("Your head splits open! Your brain mutates!"))
	emote("scream")
	var/obj/item/bodypart/head/psyker/psyker_head = new()
	psyker_head.receive_damage(brute = 50)
	if(!psyker_head.replace_limb(src, special = TRUE))
		return
	qdel(old_head)
	var/obj/item/organ/internal/brain/psyker/psyker_brain = new()
	old_brain.before_organ_replacement(psyker_brain)
	old_brain.Remove(src, special = TRUE, no_id_transfer = TRUE)
	qdel(old_brain)
	psyker_brain.Insert(src, special = TRUE, drop_if_replaced = FALSE)
	if(old_eyes)
		qdel(old_eyes)

/datum/religion_rites/nullrod_transformation
	name = "Transmogrify"
	desc = "Your full power needs a firearm to be realized. You may transform your null rod into one."
	ritual_length = 10 SECONDS
	///The rod that will be transmogrified.
	var/obj/item/nullrod/transformation_target

/datum/religion_rites/nullrod_transformation/perform_rite(mob/living/user, atom/religious_tool)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/human_user = user
	var/datum/brain_trauma/special/burdened/burden = human_user.has_trauma_type(/datum/brain_trauma/special/burdened)
	if(!burden || burden.burden_level < 9)
		to_chat(human_user, span_warning("You aren't burdened enough."))
		return FALSE
	for(var/obj/item/nullrod/null_rod in get_turf(religious_tool))
		transformation_target = null_rod
		return ..()
	to_chat(human_user, span_warning("You need to place a null rod on [religious_tool] to do this!"))
	return FALSE

/datum/religion_rites/nullrod_transformation/invoke_effect(mob/living/user, atom/movable/religious_tool)
	..()
	var/obj/item/nullrod/null_rod = transformation_target
	transformation_target = null
	if(QDELETED(null_rod) || null_rod.loc != get_turf(religious_tool))
		to_chat(user, span_warning("Your target left the altar!"))
		return FALSE
	to_chat(user, span_warning("[null_rod] turns into a gun!"))
	user.emote("smile")
	qdel(null_rod)
	new /obj/item/gun/ballistic/revolver/chaplain(get_turf(religious_tool))
	return TRUE

/obj/item/gun/ballistic/revolver/chaplain
	name = "chaplain's revolver"
	desc = "Holy smokes."
	icon_state = "chaplain"
	force = 10
	fire_sound = 'sound/weapons/gun/revolver/shot.ogg'
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev77
	obj_flags = UNIQUE_RENAME
	actions_types = list(/datum/action/item_action/pray_refill)
	/// List of all possible names and descriptions.
	var/static/list/possible_names = list(
		//cool latin
		"Requiescat" = "May they rest in peace.",
		"Requiem" = "They will never reach truth.",
		"Vade Retro" = "Having a gun might make exorcisms more effective, who knows?",
		"Extra Nos" = "Salvation is given externally.",
		"Ordo Salutis" = "First step? Fire.",
		//other religious stuff
		"Absolution" = "Free of your sins.",
		"Rod of God" = "Splitting the red sea again.",
		"Holy Grail" = "You found it!",
		"Burning Bush" = "Useful for any burning ambush.",
		"Judgement" = "First of all, damn. Alpha much? Dude, so cool, and so are you! Strong, too!",
		"Paradiso" = "A divine end to the comedy of life.",
		//music
		"DVNO" = "Don't need to ask my name to figure out how cool I am.",
		"Venus Supermax" = "Did you know nearly everyone working and living on Venus is involved in sulfur extraction? Quite fitting for this weapon of gunpowder.",
		"Nirvana" = "The giver of quietude, freedom, and highest happiness.",
		"Cerebrum Dispersio" = "Latin for \"brain splitting\". How fitting.",
		"Ultimort" = "Your hope dies last.",
		"Lifelight" = "No escape, no greater fate to be made.",
		"Bendbreaker" = "FRAGILE: Please do not bend or break.",
		//video games
		"Pop Pop" = "The name referring to an onomatopeia (phonetic imitation) of a gun firing.",
		"Justice" = "Justice is Splendor.",
		"Splendor" = "Splendor is Justice.",
		"Revelation" = "Awaken your faith.",
		"New Safety M62" = "This model of firearm is popular hundreds of years later due to masculine associations created by the film industry.",
		"Unmaker" = "What the !@#%* is this!",
		"INKVD" = "Savior of the soul and fighter against dirty thoughts.",
		"Life Leech" = "An artifact said to draw its power from the life energy of others.",
		"Nullray" = "Starless metal on the barrel imbibes light and routes it to the null place. The grip acrylic is patterned after ley lines.",
		"Mortis" = "Put your faith into this weapon working.",
		//movies shows comics
		"Ramiel" = "Literally meaning \"God has thundered\". You could even interpret the gunshot as a thunder.",
		"Daredevil" = "Hey now, you won't be reckless with this, will you?",
		"Lacytanga" = "Rules are written by the strong.",
	)

/obj/item/gun/ballistic/revolver/chaplain/Initialize(mapload)
	. = ..()
	name = pick(possible_names)
	desc = possible_names[name]

/obj/item/gun/ballistic/revolver/chaplain/attack_self(mob/living/user)
	pray_refill(user)

/obj/item/gun/ballistic/revolver/chaplain/suicide_act(mob/living/user)
	. = ..()
	name = "Habemus Papam"
	desc = "I announce to you a great joy."

/obj/item/gun/ballistic/revolver/chaplain/proc/pray_refill(mob/living/carbon/human/user)
	if(DOING_INTERACTION_WITH_TARGET(user, src) || !istype(user))
		return
	var/datum/brain_trauma/special/burdened/burden = user.has_trauma_type(/datum/brain_trauma/special/burdened)
	if(!burden || burden.burden_level < 9)
		to_chat(user, span_warning("You aren't burdened enough."))
		return
	user.manual_emote("presses [user.p_their()] palms together...")
	if(!do_after(user, 5 SECONDS, src))
		balloon_alert(user, "interrupted!")
		return
	user.say("#Oh great [GLOB.deity], give me the ammunition I need!", forced = "ammo prayer")
	magazine.top_off()
	user.playsound_local(get_turf(src), 'sound/magic/magic_block_holy.ogg', 50, TRUE)
	chamber_round()

/datum/action/item_action/pray_refill
	name = "Refill"
	desc = "Perform a prayer, to refill your weapon."

/obj/item/ammo_box/magazine/internal/cylinder/rev77
	name = "chaplain revolver cylinder"
	ammo_type = /obj/item/ammo_casing/c77
	caliber = CALIBER_77
	max_ammo = 5

/obj/item/ammo_casing/c77
	name = ".77 bullet casing"
	desc = "A .77 bullet casing."
	caliber = CALIBER_77
	projectile_type = /obj/projectile/bullet/c77
	custom_materials = null

/obj/projectile/bullet/c77
	name = ".77 bullet"
	damage = 18
	ricochets_max = 2
	ricochet_chance = 50
	ricochet_auto_aim_angle = 10
	ricochet_auto_aim_range = 3
	wound_bonus = -10
	embedding = null
