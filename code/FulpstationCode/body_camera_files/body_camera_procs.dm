#define SEC_BODY_CAM_SOUND list('sound/machines/beep.ogg')
#define SEC_BODY_CAM_SOUND_DENY list('sound/machines/buzz-two.ogg')
#define SEC_BODY_CAM_REG_DELAY 1 SECONDS
#define SEC_BODY_CAM_COOLDOWN 2 SECONDS

/obj/item/clothing/under/rank/security/Initialize()
	. = ..()
	builtInCamera = new (src)
	builtInCamera.internal_light = FALSE

	RegisterSignal(src, COMSIG_ITEM_EQUIPPED, .proc/auto_register_bodycam)

	addtimer(CALLBACK(src, /obj/item/clothing/under/rank/security.proc/auto_register_bodycam, null, ITEM_SLOT_ICLOTHING), SEC_BODY_CAM_REG_DELAY)

/obj/item/clothing/under/rank/security/proc/auto_register_bodycam(mob/user, slot)
	if(!builtInCamera)
		return
	if(slot != ITEM_SLOT_ICLOTHING)
		return
	if(!user)
		if(ismob(loc))
			user = loc
		else
			return

	if(!user.mind) //Vibe check for mindless mobs.
		return

	var/obj/item/card/id/I = user.get_idcard(TRUE)
	if(!istype(I))
		return
	if(check_access(I))
		register_body_camera(I, user)

/obj/item/clothing/under/rank/security/attackby(obj/item/W, mob/user, params)
	. = ..()
	var/obj/item/card/id/I
	if (istype(W, /obj/item/card/id))
		I = W
	else if (istype(W, /obj/item/pda))
		var/obj/item/pda/P = W
		I = P.id

	if(!I)
		to_chat(user, "<span class='warning'>No ID detected for body camera registration.</span>")
		return

	if(!builtInCamera)
		to_chat(user, "<span class='warning'>No body camera detected for registration.</span>")
		return

	if(check_access(I))
		register_body_camera(I, user)
	else
		to_chat(user, "<span class='warning'>ID is not authorized for registration with this uniform's body camera.</span>")
		camera_sound(FALSE)

/obj/item/clothing/under/rank/security/proc/register_body_camera(obj/item/card/id/I, mob/user)
	if(!I) //Sanity check
		return
	var/id_name = I.registered_name
	if(id_name == registrant) //If already registered to the same person swiping the ID, we will 'toggle off' registration and unregister the body camera.
		unregister_body_camera(I, user)
		return

	registrant = id_name
	builtInCamera.network = list("sec_bodycameras")
	var/cam_name = "-Body Camera: [id_name] ([I.assignment])"
	for(var/obj/machinery/camera/matching_camera in GLOB.cameranet.cameras)
		if(cam_name == matching_camera.c_tag)
			to_chat(user, "<span class='notice'>Matching registration found. Unregistering previously registered body camera.</span>")
			var/obj/item/clothing/under/rank/security/S = matching_camera.loc
			if(S)
				S.unregister_body_camera(I, user, FALSE)
			break

	builtInCamera.c_tag = "[cam_name]"

	camera_sound()
	if(user)
		to_chat(user, "<span class='notice'>Security uniform body camera successfully registered to [id_name]</span>")

/obj/item/clothing/under/rank/security/proc/unregister_body_camera(obj/item/card/id/I, mob/user, message=TRUE)
	builtInCamera.network = list()
	builtInCamera.c_tag = null
	registrant = null
	if(user && message)
		camera_sound()
		to_chat(user, "<span class='notice'>Security uniform body camera successfully unregistered from [I.registered_name]</span>")



/obj/item/clothing/under/rank/security/verb/toggle_camera()
	set name = "Toggle Body Camera"
	set category = "Object"
	set src in usr
	var/mob/M = usr
	if (istype(M, /mob/dead/))
		return
	if (!can_use(M))
		return
	camera_toggle(usr)


/obj/item/clothing/under/rank/security/proc/camera_toggle()
	var/message = "<span class='notice'>There's no camera!</span>"

	if(builtInCamera)
		if(camera_on)
			camera_on = FALSE
			builtInCamera.status = 0
			message = "<span class='notice'>You toggle the body camera off.</span>"
		else
			camera_on = TRUE
			builtInCamera.status = 1
			message = "<span class='notice'>You toggle the body camera on.</span>"
		camera_sound()

	if(ismob(loc))
		var/mob/user = loc
		if(user)
			to_chat(user, "[message]")

/obj/item/clothing/under/rank/security/proc/camera_sound(accepted = TRUE)
	if(world.time - sound_time_stamp > SEC_BODY_CAM_COOLDOWN)
		if(accepted)
			playsound(loc, SEC_BODY_CAM_SOUND, get_clamped_volume(), TRUE, -1)
		else
			playsound(loc, SEC_BODY_CAM_SOUND_DENY, get_clamped_volume(), TRUE, -1)
		sound_time_stamp = world.time

/obj/item/clothing/under/rank/security/emp_act()
	. = ..()
	camera_toggle()


/obj/item/clothing/under/rank/security/examine(mob/user)
	. = ..()
	if(builtInCamera)
		if(camera_on)
			. += "Its body camera appears to be <b>active</b>."
		else
			. += "Its body camera appears to be <b>inactive</b>."
		if(registrant)
			. += "The body camera is registered to <b>[registrant]</b>."

/obj/machinery/computer/security/proc/check_bodycamera_unlock(user)
	if(allowed(user))
		network += "sec_bodycameras" //We can tap into the body camera network with appropriate access
	else
		network -= "sec_bodycameras"

/mob/living/simple_animal/bot/secbot/proc/secbot_register_body_camera()
	if(!src) //Sanity
		return

	builtInCamera = new (src)
	builtInCamera.internal_light = FALSE

	builtInCamera.network = list("sec_bodycameras")
	var/cam_name = "-Robot Camera: [name] ([model])"
	var/count
	for(var/obj/machinery/camera/matching_camera in GLOB.cameranet.cameras)
		if(cam_name == matching_camera.c_tag)
			count++
			cam_name = "-Robot Camera: [name] ([count]) ([model])" //Add and increment a number to the camera name; eventually there will be no matches.

	builtInCamera.c_tag = "[cam_name]"

/mob/living/simple_animal/bot/secbot/proc/secbot_declare_arrest_completion(mob/living/carbon/C, threat)
	if(!C) //sanity
		return

	var/location = get_area(src)
	var/assignment = "NO ASSIGNMENT"
	var/mob/living/carbon/human/H = C

	if(ishuman(H))
		assignment = H.get_assignment()

	speak("[arrest_type ? "Detaining" : "Arresting"] level [threat] scumbag <b>[C], [assignment]</b> in <b>[location]</b>.", radio_channel)
	if(weapons_violation || id_violation || record_violation || harm_violation) //Report arrest criteria if we have any violations.
		speak("Reasons for arrest:[weapons_violation][harm_violation][id_violation][record_violation]", radio_channel)
	arrest_security_record(C, arrest_type, threat, location, assignment) //FULPSTATION IMPROVED RECORD SECURITY PR -Surrealistik Oct 2019; this makes a record of the arrest, including timestamp and location.


/mob/living/simple_animal/bot/secbot/proc/secbot_declare_arrest_attempt(mob/living/carbon/C, threatlevel)
	if(!C) //sanity
		return

	var/location = get_area(src)
	var/assignment = "NO ASSIGNMENT"
	var/mob/living/carbon/human/H = C

	if(ishuman(H))
		assignment = H.get_assignment()

	speak("Level [threatlevel] scumbag <b>[C], [assignment]</b> detected at <b>[get_area(C)]</b>. Attempting to [arrest_type ? "detain" : "arrest"]. Current location is <b>[location]</b>", radio_channel)
	if(weapons_violation || id_violation || record_violation || harm_violation) //Report arrest criteria if we have any violations.
		speak("Reasons for arrest:[weapons_violation][harm_violation][id_violation][record_violation]", radio_channel)

/mob/living/simple_animal/bot/proc/bot_responding(mob/user)
	if(!user) //Sanity
		return

	var/assignment = "NO ASSIGNMENT"
	var/mob/living/carbon/human/H = user

	if(ishuman(H))
		assignment = H.get_assignment()

	speak("Responding to <b>[user.name], [assignment]</b> summon at <b>[get_area(user)]</b>. Currently at <b>[get_area(src)]</b>. En route.", radio_channel)


/mob/living/carbon/human/proc/assess_threat_fulp(judgement_criteria, mob/living/simple_animal/bot/secbot/S, harm_bot = FALSE, lasercolor = "", datum/callback/weaponcheck=null)
	if(judgement_criteria & JUDGE_EMAGGED)
		return 10 //Everyone is a criminal!

	var/threatcount = 0

	//Lasertag bullshit
	if(lasercolor)
		if(lasercolor == "b")//Lasertag turrets target the opposing team, how great is that? -Sieve
			if(istype(wear_suit, /obj/item/clothing/suit/redtag))
				threatcount += 4
			if(is_holding_item_of_type(/obj/item/gun/energy/laser/redtag))
				threatcount += 4
			if(istype(belt, /obj/item/gun/energy/laser/redtag))
				threatcount += 2

		if(lasercolor == "r")
			if(istype(wear_suit, /obj/item/clothing/suit/bluetag))
				threatcount += 4
			if(is_holding_item_of_type(/obj/item/gun/energy/laser/bluetag))
				threatcount += 4
			if(istype(belt, /obj/item/gun/energy/laser/bluetag))
				threatcount += 2

		return threatcount

	//Check for ID
	var/obj/item/card/id/idcard = get_idcard(FALSE)
	if( (judgement_criteria & JUDGE_IDCHECK) && !idcard && name=="Unknown")
		threatcount += 4
		S.id_violation = " Lack of identification."

	if(harm_bot)
		S.harm_violation = " <b>[S.name]</b> retaliated against suspect."

	//Check for weapons
	if( (judgement_criteria & JUDGE_WEAPONCHECK) && weaponcheck)
		if(!idcard || !(ACCESS_WEAPONS in idcard.access))
			for(var/obj/item/I in held_items) //if they're holding a gun
				if(weaponcheck.Invoke(I))
					threatcount += 4
					S.weapons_violation = " Suspect in possession of <b>[I.name]</b>."
			if(weaponcheck.Invoke(belt) || weaponcheck.Invoke(back)) //if a weapon is present in the belt or back slot
				threatcount += 2 //not enough to trigger look_for_perp() on it's own unless they also have criminal status.

	//Check for arrest warrant
	if(judgement_criteria & JUDGE_RECORDCHECK)
		var/perpname = get_face_name(get_id_name())
		var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.security)
		if(R && R.fields["criminal"] && (R.fields["criminal"] != "None") )
			var/record_status = R.fields["criminal"]
			S.record_violation = " Status: <b>[record_status]</b>."
			switch(R.fields["criminal"])
				if("*Arrest*")
					threatcount += 5
				if("Incarcerated")
					threatcount += 2
				if("Paroled")
					threatcount += 2

	//Check for dresscode violations
	if(istype(head, /obj/item/clothing/head/wizard) || istype(head, /obj/item/clothing/head/helmet/space/hardsuit/wizard))
		threatcount += 2

	//Check for nonhuman scum
	if(dna && dna.species.id && dna.species.id != "human")
		threatcount += 1

	//mindshield implants imply trustworthyness
	if(HAS_TRAIT(src, TRAIT_MINDSHIELD))
		threatcount -= 1

	//Agent cards lower threatlevel.
	if(istype(idcard, /obj/item/card/id/syndicate))
		threatcount -= 5

	return threatcount
