// combo defines

#define BUSTER_COMBO "EEG"
#define SLOPPY_HARM "HHHH" //spamming GOTNS is not ideal
#define SLOPPY_HELP "EEEE" //don't think you can circumvent this with other intents either
#define SLOPPY_GRAB "GGGG" //nor this
#define SLOPPY_DISARM "DDDD" //definitely not this
#define FIREBALL_ONE_COMBO "EGD"
#define DROPKICK_COMBO "DEEH"
#define SURPRISE_COMBO "DDH"
#define MACHINE_GUN_COMBO "EHEH"
#define FIREBALL_TWO_COMBO "EDD"
#define HEADBUTT_COMBO "EHG"
#define HEADSLIDE_COMBO "GDDG"

// rest of the file

/datum/martial_art/proc/help_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return 0

/datum/martial_art/armstrong
	name = "Armstrong Style"
	help_verb = /mob/living/carbon/human/proc/armstrong_help
	max_streak_length = 4
	no_guns = TRUE
	block_chance = 75
	deflection_chance = 50
	allow_temp_override = FALSE
	var/current_exp = 1
	var/next_level_exp = 5
	var/static/exp_slope = 10.5
	var/current_level = 1
	var/level_cap = 30

/datum/martial_art/armstrong/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A.hud_used.combo_object.update_icon(streak, 60)
	if(findtext(streak,BUSTER_COMBO))
		streak = ""
		A.hud_used.combo_object.update_icon(streak)
		Buster(A,D)
		return 1
	if(findtext(streak,SLOPPY_HARM)) //more like this CODE is sloppy
		streak = ""
		A.hud_used.combo_object.update_icon(streak)
		Sloppy(A,D)
		return 1
	if(findtext(streak,SLOPPY_HELP))
		streak = ""
		A.hud_used.combo_object.update_icon(streak)
		Sloppy(A,D)
		return 1
	if(findtext(streak,SLOPPY_DISARM))
		streak = ""
		A.hud_used.combo_object.update_icon(streak)
		Sloppy(A,D)
		return 1
	if(findtext(streak,SLOPPY_GRAB))
		streak = ""
		A.hud_used.combo_object.update_icon(streak)
		Sloppy(A,D)
		return 1
	if(findtext(streak,FIREBALL_ONE_COMBO))
		streak = ""
		A.hud_used.combo_object.update_icon(streak)
		FireballOne(A,D)
		return 1
	if(findtext(streak,DROPKICK_COMBO))
		streak = ""
		A.hud_used.combo_object.update_icon(streak)
		Dropkick(A,D)
		return 1
	if(findtext(streak,SURPRISE_COMBO))
		streak = ""
		A.hud_used.combo_object.update_icon(streak)
		Surprise(A,D)
		return 1
	if(findtext(streak,MACHINE_GUN_COMBO))
		streak = ""
		A.hud_used.combo_object.update_icon(streak)
		MachineGun(A,D)
		return 1
	if(findtext(streak,FIREBALL_TWO_COMBO))
		streak = ""
		A.hud_used.combo_object.update_icon(streak)
		FireballTwo(A,D)
		return 1
	if(findtext(streak,HEADBUTT_COMBO))
		streak = ""
		A.hud_used.combo_object.update_icon(streak)
		Headbutt(A,D)
		return 1
	if(findtext(streak,HEADSLIDE_COMBO))
		streak = ""
		A.hud_used.combo_object.update_icon(streak)
		Headslide(A,D)
		return 1
	return 0

//special effects

/datum/martial_art/armstrong/proc/SloppyAnimate(mob/living/carbon/human/A)
	set waitfor = FALSE
	for(var/i in list(NORTH,SOUTH,EAST,WEST,EAST,SOUTH,NORTH,SOUTH,EAST,WEST,EAST,SOUTH))
		if(!A)
			break
		A.setDir(i)
		playsound(A.loc, 'hippiestation/sound/weapons/armstrong_punch.ogg', 35, 1, -1)
		sleep(1)

/datum/martial_art/armstrong/proc/MachineGunAnimate(mob/living/carbon/human/A)
	for(var/i in 1 to 10)
		playsound(A, 'hippiestation/sound/weapons/armstrong_punch.ogg', 75, 1, 5)
		A.do_attack_animation(ATTACK_EFFECT_PUNCH) // note: happens so fast that it's very hard to actually notice
		sleep(1)

/datum/martial_art/armstrong/proc/Sloppy(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(current_level <= 9)
		A.say("ATATATATATATAT!!")
		SloppyAnimate(A)
		D.visible_message("<span class='danger'>[A] sloppily flails around, striking [D]!</span>", \
									"<span class='userdanger'>[A] sends [D] flying with a rushed combo!</span>")
		var/obj/effect/proc_holder/spell/aoe_turf/repulse/R = new(null)
		var/list/turfs = list()
		for(var/turf/T in range(1,A))
			turfs.Add(T)
		R.cast(turfs)
		add_exp(4, A)
		add_logs(A, D, "sloppily flailed around (Armstrong)")
		A.playsound_local(get_turf(A), 'hippiestation/sound/effects/fart.ogg', 100, FALSE, pressure_affected = FALSE)
		return
	else
		A.Knockdown(10)
		D.Knockdown(15)
		var/atom/throw_target = get_edge_target_turf(D, get_dir(D, get_step_away(D, A)))
		D.throw_at(throw_target, 1, 1)
		A.throw_at(throw_target, 1, 1)
		D.visible_message("<span class='danger'>[A] sloppily punts [D] away, and trips!</span>", \
									"<span class='userdanger'>[A] punts [D] away with a rushed combo!</span>")
		add_logs(A, D, "sloppily flailed around (Armstrong)")
		A.playsound_local(get_turf(A), 'hippiestation/sound/misc/oof.ogg', 100, FALSE, pressure_affected = FALSE)
		return

// Actual combos

/datum/martial_art/armstrong/proc/Buster(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(current_level >= 2)
		add_logs(A, D, "buster punched (Armstrong)")
		D.visible_message("<span class='danger'>[A] buster punches [D]!</span>", \
									"<span class='userdanger'>[A] knocks down [D] with two strong punches!</span>")
		playsound(D.loc, 'hippiestation/sound/weapons/armstrong_zipper.ogg', 100, 1)
		A.playsound_local(get_turf(A), 'hippiestation/sound/weapons/armstrong_success.ogg', 50, FALSE, pressure_affected = FALSE)
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		D.adjustBruteLoss(8) //Decentish damage. It racks up to 18 if the victim hits a wall.
		D.Knockdown(20)
		add_exp(8, A)
		var/atom/throw_target = get_edge_target_turf(D, get_dir(D, get_step_away(D, A)))
		D.throw_at(throw_target, 1, 1)
		return

/datum/martial_art/armstrong/proc/FireballOne(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(current_level >= 5)
		D.visible_message("<span class='danger'>[A] blasts [D] with a weak fireball!</span>", \
									"<span class='userdanger'>[A] blasted [D] with a weak fireball!</span>")
		playsound(D.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
		var/atom/throw_target = get_edge_target_turf(D, get_dir(D, get_step_away(D, A)))
		playsound(get_turf(A), 'sound/magic/fireball.ogg', 25, 1)
		A.playsound_local(get_turf(A), 'hippiestation/sound/weapons/armstrong_success.ogg', 50, FALSE, pressure_affected = FALSE)
		D.throw_at(throw_target, 2, 4,A)
		D.adjust_fire_stacks(1)
		D.IgniteMob()
		add_exp(8, A)
		add_logs(A, D, "fireball-one (Armstrong)")
		return

/datum/martial_art/armstrong/proc/Dropkick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(current_level >= 6)
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		playsound(D.loc, 'hippiestation/sound/weapons/armstrong_punch.ogg', 50, 1, -1)
		A.playsound_local(get_turf(A), 'hippiestation/sound/weapons/armstrong_success.ogg', 50, FALSE, pressure_affected = FALSE)
		D.Knockdown(15)
		D.adjustBruteLoss(12)
		A.Knockdown(5)
		add_exp(12, A)
		var/atom/throw_target = get_edge_target_turf(D, get_dir(D, get_step_away(D, A)))
		A.throw_at(throw_target, 1, 1)
		D.visible_message("<span class='danger'>[A] dropkicks [D]!</span>", \
									"<span class='userdanger'>[A] dropkicked [D]!</span>")
		add_logs(A, D, "dropkicked (Armstrong)")
		return

/datum/martial_art/armstrong/proc/Surprise(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(current_level >= 3)
		playsound(D.loc, 'hippiestation/sound/weapons/armstrong_punch.ogg', 75, 0, -1)
		A.playsound_local(get_turf(A), 'hippiestation/sound/weapons/armstrong_success.ogg', 50, FALSE, pressure_affected = FALSE)
		D.Knockdown(80)
		D.emote("scream")
		D.adjustBruteLoss(8)
		add_exp(8, A)
		if(D.gender == FEMALE)
			D.visible_message("<span class='notice'>[A] scares [D] and they sheepishly fall over.</span>", \
										"<span class='userdanger'>[A] 'surprised' [D]!</span>") // we're not citadel
			A.say("BOO!")
		else
			A.do_attack_animation(D, ATTACK_EFFECT_KICK)
			D.visible_message("<span class='danger'><b>[A] kicks [D] in the dick!<b></span>", \
										"<span class='userdanger'>[A] 'surprised' [D]!</span>") // how the attack actually worked in LISA
		add_logs(A, D, "surprised (Armstrong)")
		return

/datum/martial_art/armstrong/proc/MachineGun(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(current_level >= 7)
		add_logs(A, D, "Machine Gun Fisted (Armstrong)")
		D.visible_message("<span class='danger'>[A] unleashes a flurry of punches on [D]!</span>", \
									"<span class='userdanger'>[A] punches [D] at the speed of a machine gun!</span>")
		A.playsound_local(get_turf(A), 'hippiestation/sound/weapons/armstrong_success.ogg', 50, FALSE, pressure_affected = FALSE)
		D.adjustBruteLoss(18) //punch punch punch
		MachineGunAnimate(A)
		D.Stun(10)
		add_exp(12, A)
		return

/datum/martial_art/armstrong/proc/FireballTwo(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(current_level >= 12)
		D.visible_message("<span class='danger'>[A] blasts [D] with a fireball!</span>", \
									"<span class='userdanger'>[A] blasted [D] with a weak fireball!</span>")
		playsound(D.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
		var/atom/throw_target = get_edge_target_turf(D, get_dir(D, get_step_away(D, A)))
		playsound(get_turf(A), 'sound/magic/fireball.ogg', 25, 1)
		A.playsound_local(get_turf(A), 'hippiestation/sound/weapons/armstrong_success.ogg', 50, FALSE, pressure_affected = FALSE)
		D.throw_at(throw_target, 2, 4,A)
		D.adjust_fire_stacks(3)
		D.adjustFireLoss(10)
		D.IgniteMob()
		var/datum/effect_system/explosion/E = new
		E.set_up(get_turf(D))
		E.start()
		add_exp(8, A)
		add_logs(A, D, "fireball-two (Armstrong)")
		return

/datum/martial_art/armstrong/proc/Headbutt(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(current_level >= 15)
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		D.visible_message("<span class='warning'>[A] headbutts [D]!</span>", \
						  "<span class='userdanger'>[A] headbutts you with atom-shattering strength!</span>")
		D.apply_damage(30, BRUTE, "head")
		playsound(get_turf(D), 'sound/effects/meteorimpact.ogg', 120, 1, -1)
		A.playsound_local(get_turf(A), 'hippiestation/sound/weapons/armstrong_success.ogg', 50, FALSE, pressure_affected = FALSE)
		D.AdjustUnconscious(15)
		D.adjustBrainLoss(30)
		var/datum/effect_system/explosion/E = new
		E.set_up(get_turf(D))
		E.start()
		add_logs(A, D, "atomic headbutted (Monkeyman)")
		return

/datum/martial_art/armstrong/proc/Headslide(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(current_level >= 13 && !D.stat && !D.IsKnockdown())
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		playsound(D.loc, 'sound/effects/suitstep1.ogg', 50, 1, -1)
		A.playsound_local(get_turf(A), 'hippiestation/sound/weapons/armstrong_success.ogg', 50, FALSE, pressure_affected = FALSE)
		D.Knockdown(80)
		D.adjustBruteLoss(10)
		A.Knockdown(5)
		add_exp(12, A)
		var/atom/throw_target = get_edge_target_turf(D, get_dir(D, get_step_away(D, A)))
		A.throw_at(throw_target, 3, 3)
		D.visible_message("<span class='danger'>[A] headslides underneath [D], tripping them!</span>", \
									"<span class='userdanger'>[A] headslid into [D]!</span>")
		add_logs(A, D, "headslide (Armstrong)")
		return

// Help/Hurt/Grab/Disarm acts

/datum/martial_art/armstrong/help_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("E",D)
	if(check_streak(A,D))
		return 1
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb_help = pick("left punches", "left hooks")
	D.visible_message("<span class='danger'>[A] [atk_verb_help] [D]!</span>", \
					  "<span class='userdanger'>[A] [atk_verb_help] you!</span>")
	D.apply_damage(rand(6,13), BRUTE) // lower base damage
	D.adjustStaminaLoss(rand(6,10)) // but higher stamina damage
	add_exp(rand(1,3))
	playsound(get_turf(D), 'hippiestation/sound/weapons/armstrong_punch.ogg', 75, 0, -1)
	A.playsound_local(get_turf(A), 'hippiestation/sound/weapons/armstrong_combo.ogg', 25, FALSE, pressure_affected = FALSE)
	if(prob(D.getBruteLoss()) && !D.lying)
		D.visible_message("<span class='warning'>Critical hit!</span>", "<span class='userdanger'>Critical hit!</span>")
		D.apply_damage(10, BRUTE)
		D.Knockdown(20)
	if(current_level >= 10)
		A.changeNext_move(CLICK_CD_RAPID) //O fortuna
		.= FALSE
	add_logs(A, D, "[atk_verb_help] (Armstrong)")
	return 1

/datum/martial_art/armstrong/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("H",D)
	if(check_streak(A,D))
		return 1
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb_harm = pick("right punches", "right hooks")
	D.visible_message("<span class='danger'>[A] [atk_verb_harm] [D]!</span>", \
					  "<span class='userdanger'>[A] [atk_verb_harm] you!</span>")
	D.apply_damage(rand(8,15), BRUTE) // higher base damage
	D.adjustStaminaLoss(rand(4,8)) // but lower stamina damage
	add_exp(rand(1,3))
	playsound(get_turf(D), 'hippiestation/sound/weapons/armstrong_punch.ogg', 50, 0, -1)
	A.playsound_local(get_turf(A), 'hippiestation/sound/weapons/armstrong_combo.ogg', 25, FALSE, pressure_affected = FALSE)
	if(prob(D.getBruteLoss()) && !D.lying)
		D.visible_message("<span class='warning'>Critical hit!</span>", "<span class='userdanger'>Critical hit!</span>")
		D.apply_damage(10, BRUTE)
		D.Knockdown(20)
	if(current_level >= 10)
		A.changeNext_move(CLICK_CD_RAPID)
		.= FALSE
	add_logs(A, D, "[atk_verb_harm] (Armstrong)")
	return 1

/datum/martial_art/armstrong/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("G",D)
	if(check_streak(A,D))
		return 1
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb_grab = pick("zipper punches", "one, two punches")
	D.visible_message("<span class='danger'>[A] [atk_verb_grab] [D]!</span>", \
					  "<span class='userdanger'>[A] [atk_verb_grab] you!</span>")
	D.apply_damage(rand(4,8), BRUTE) // left hand brute damage - weakened
	D.adjustStaminaLoss(rand(4,9)) // left hand stamina damage
	D.apply_damage(rand(6,12), BRUTE) // right hand brute damage - weakened
	D.adjustStaminaLoss(rand(3,8)) // right hand stamina damage
	add_exp(rand(2,4))
	playsound(get_turf(D), 'hippiestation/sound/weapons/armstrong_zipper.ogg', 50, 0, -1)
	A.playsound_local(get_turf(A), 'hippiestation/sound/weapons/armstrong_combo.ogg', 25, FALSE, pressure_affected = FALSE)
	if(prob(D.getBruteLoss()) && !D.lying)
		D.visible_message("<span class='warning'>Critical hit!</span>", "<span class='userdanger'>Critical hit!</span>")
		D.apply_damage(10, BRUTE)
	if(current_level >= 10)
		A.changeNext_move(CLICK_CD_RAPID)
		.= FALSE
	add_logs(A, D, "[atk_verb_grab] (Armstrong)")
	return 1

/datum/martial_art/armstrong/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("D",D)
	if(check_streak(A,D))
		return 1
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb_disarm = pick("double palm thrusts")
	D.visible_message("<span class='danger'>[A] [atk_verb_disarm] [D]!</span>", \
					  "<span class='userdanger'>[A] [atk_verb_disarm] you!</span>")
	D.apply_damage(rand(3,5), BRUTE) // weakest brute damage
	D.adjustStaminaLoss(rand(10,20)) // strongest stamina damage
	add_exp(rand(2,4))
	playsound(get_turf(D), 'hippiestation/sound/weapons/armstrong_palmthrust.ogg', 50, 0, -1)
	A.playsound_local(get_turf(A), 'hippiestation/sound/weapons/armstrong_combo.ogg', 25, FALSE, pressure_affected = FALSE)
	if(prob(D.getBruteLoss()) && !D.lying)
		D.visible_message("<span class='warning'>Critical hit!</span>", "<span class='userdanger'>Critical hit!</span>")
		D.apply_damage(10, BRUTE)
		D.adjustStaminaLoss(10)
	if(current_level >= 10)
		A.changeNext_move(CLICK_CD_RAPID)
		.= FALSE
	add_logs(A, D, "[atk_verb_disarm] (Armstrong)")
	return 1

// Help verb

/mob/living/carbon/human/proc/armstrong_help()
	set name = "Recall Teachings"
	set desc = "Remember how to Armstrong Style."
	set category = "Armstrong"

	to_chat(usr, "<b><i>You hear the voice of the hintmaster...</i></b>")
	to_chat(usr, "<span class='notice'>SLOPPY</span>: Spam Help/Harm intent. Flails around and knocks people around you down. Can't be used after you reach Level 10.")
	to_chat(usr, "<span class='notice'>BUSTER PUNCHES</span>: Help, Help, Grab. Knocks down and deals fair damage. Requires Level 2.")
	to_chat(usr, "<span class='notice'>SURPRISE ATTACK</span>: Disarm, Disarm, Harm. Knocks down and deals fair damage. Requires Level 3.")
	to_chat(usr, "<span class='notice'>FIREBALL 1</span>: Help Grab Disarm. A blast of flaming emotion. Sets the target on fire. Requires Level 5.")
	to_chat(usr, "<span class='notice'>DROPKICK</span>: Disarm Help Help Harm. A flying double foot press. Requires Level 6.")
	to_chat(usr, "<span class='notice'>FIREBALL 2</span>: Help Disarm Disarm. A blast of flaming emotion. Sets the target on fire. Requires Level 12.")
	to_chat(usr, "<span class='notice'>HEADSLIDE</span>: Grab Disarm Disarm Grab. A sliding head strike at the opponent's knees. Causes tripping. Requires Level 13.")
	to_chat(usr, "<span class='notice'>HEADBUTT</span>: Help Harm Grab. A full force slam with your shiny head. Knocks the target out temporarily. Requires Level 15.")

//Scroll necessary for learning the martial art

/obj/item/armstrong_scroll
	name = "balding scroll"
	desc = "An ancient looking scroll, bearing a picture of an overweight man wearing a poncho. Has a strong stench of alcohol and drugs."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	var/used = 0

/obj/item/armstrong_scroll/attack_self(mob/user)
	if(!ishuman(user))
		return
	if(!used)
		var/mob/living/carbon/human/H = user
		var/datum/martial_art/armstrong/F = new/datum/martial_art/armstrong(null)
		F.teach(H)
		to_chat(H, "<span class='boldannounce'>Examining the scroll teaches you Armstrong Style. The scroll is suddenly doused in alcohol, with the texts washing away.</span>")
		used = TRUE
		desc = "It's completely ruined!"
		name = "disgusting soggy paper"
		icon_state = "blankscroll"
	else
		var/mob/living/carbon/human/H = user
		H.visible_message("<span class='warning'>[H] stares at the scroll like an idiot!</span>", "<span class='userdanger'>You despereately try to decipher the soggy scroll and fail miserably!</span>")

// How to not suck at the aforementioned martial art.

/obj/item/paper/armstrong_tutorial
	name = "paper - 'HOW TO NOT SUCK'"
	info = "Activating throw mode gives you a 75% chance to block any melee attacks coming your way. Use it to not die to stunbatons.<br> \
	Don't spam one attack. Cycle rapidly through intents or try to use combos as much as possible to capitalize on both brute damage and stamina damage.<br> \
	To cycle intents, push F or G. To directly select an intent, press 1, 2, 3, or 4. <br>\
	You can't pull people. At all. Don't try to. Punch people as hard as you can, as fast as you can. Once you start to level up, you won't need to pull people any way.<br> \
	You can't use guns either. Guns are for pussies and fishpeople.<br> \
	<b>Go loud</b>. Don't sit on your hands waiting for the perfect target, just go punch people. Punch dead bodies if you have to. Get some experience, or else you're woefully underpowered.<br> \
	If you don't use hotkey mode, please use the rest of this paper to write your last will and testament:<br>"

//Level UP and EXP code.

/datum/martial_art/armstrong/proc/do_level_up(mob/living/carbon/human/owner)
	switch(current_level)
		if(2)
			to_chat(owner, "<span class = 'notice'>You have re-awakened the Buster Punches technique. To use: Help Help Grab</span>")
		if(3)
			to_chat(owner, "<span class = 'notice'>You remember the Surprise Attack. To use: Disarm Disarm Harm.</span>")
		if(5)
			to_chat(owner, "<span class = 'notice'>You remember how to utilize your emotion, and learned Fireball. To use: Help Grab Disarm</span>")
			to_chat(owner, "<span class = 'danger'>You also seem to be growing some facial hair...</span>")
			if(is_species(owner, /datum/species/human))
				owner.facial_hair_style = "Broken Man"
				owner.update_hair() //makes the hair/facial hair change actually happen
			else
				if(!istype(owner.wear_mask, /obj/item/clothing/mask/fakemoustache/italian/cursed))
					if(!owner.doUnEquip(owner.wear_mask))
						qdel(owner.wear_mask)
					owner.equip_to_slot_or_del(new /obj/item/clothing/mask/fakemoustache/italian/cursed(owner), slot_wear_mask) //your snowflake race won't save you from hair now
		if(6)
			to_chat(owner, "<span class = 'notice'>You remember how to Dropkick. To use: Disarm Help Help Disarm</span>")
		if(7)
			to_chat(owner, "<span class = 'notice'>You learn how to jab at rapid speeds, and unlocked Machine Gun Fist. To use: Help Harm Help Harm</span>")
		if(10)
			to_chat(owner, "<span class = 'notice'>You have mastered basic combos. Your attacks are more swift.</span>")
			to_chat(owner, "<span class = 'danger'><b>This great speed requires precision. Use your combos!</b></span>")
			owner.hair_style = "Bald"
			owner.facial_hair_style = "Broken Man" //ensures the proper look
			owner.update_hair() //makes the hair/facial hair change actually happen
		if(12)
			to_chat(owner, "<span class = 'notice'>You have unlocked an upgraded Fireball attack. To use: Help Disarm Disarm.</span>")
		if(13)
			to_chat(owner, "<span class = 'notice'>You have unlocked Head Slide. To use: Grab Disarm Disarm Grab.</span>")
		if(15)
			to_chat(owner, "<span class = 'notice'>You have unlocked Headbutt. To use: Help Harm Grab</span>")
		if(30)
			to_chat(owner, "<span class = 'danger'><b>You can now use Fireball without needing to combo.</b></span>")
			owner.AddSpell(new /obj/effect/proc_holder/spell/aimed/fireball(null))
	/*	if(20)
			to_chat(owner, "<span class = 'notice'><b>You can now Headslide without needing to combo.</b></span>")
			head_slide.Grant(owner) */ //todo: make this a spell - action code is garbage.

/datum/martial_art/armstrong/proc/add_exp(amt, mob/owner)
	if(current_level == level_cap)
		return
	current_exp += amt
	if(current_exp >= next_level_exp)
		current_level++
		var/next_level = current_level + 1
		next_level_exp = next_level*25
		do_level_up(mob/living/carbon/human/owner)
		to_chat(owner, "<span class = 'notice'><b>You feel more confident in your powers.</b></span>")

/obj/item/clothing/mask/fakemoustache/italian/cursed //for those cheeky aliens who think they can circumvent hair
	flags_1 = NODROP_1 | DROPDEL_1 | MASKINTERNALS_1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	desc = "It's made out of your own hair, now."

