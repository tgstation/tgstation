//The Medical Kiosk is designed to act as a low access alernative to  a medical analyzer, and doesn't require breaking into medical. Self Diagnose at your heart's content! ...For a fee.

/obj/machinery/medical_kiosk
	name = "medical kiosk"
	desc = "A freestanding medical kiosk, which can provide your basic medical status. Less effective than a medical analyzer."
	icon = 'icons/obj/machines/medical_kiosk.dmi'
	icon_state = "kiosk"
	layer = ABOVE_MOB_LAYER
	density = TRUE
	circuit = /obj/item/circuitboard/machine/medical_kiosk
	payment_department = ACCOUNT_MED
	var/default_price = 5           //I'm defaulting to a low price on this, but in the future I wouldn't have an issue making it more or less expensive.
	var/active_price = 5            //Change by using a multitool on the board.
	var/scan_active = FALSE         //Shows if the machine is being used. resets upon new viewer.
	var/upgrade_scan_active = FALSE //Shows if the machine has upgraded functionality. For T2.
	var/adv_scan_active = FALSE     //Ditto, for T3
	var/datum/bank_account/account  //payer's account.
	var/mob/living/carbon/human/H   //the person using the console in each instance.
	var/obj/item/card/id/C          //the account of the person using the console.

/obj/machinery/medical_kiosk/proc/inuse()  //Verifies that the user can use the interface, followed by showing medical information.
  if(C.registered_account)
    account = C.registered_account
  else
    say("No account detected.")  //No homeless crew.
    return
  if(!account.has_money(active_price))
    say("You do not possess the funds to purchase this.")  //No jobless crew, either.
    return
  else
    account.adjust_money(-active_price)
    var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_MED)
    if(D)
      D.adjust_money(active_price)
    use_power(20)
  scan_active = TRUE
  icon_state = "kiosk_active"
  say("Thank you for your patronage!")
  upgrade_scan_active = FALSE
  adv_scan_active = FALSE
  RefreshParts()
  return

/obj/machinery/medical_kiosk/update_icon()
	if(is_operational())
		icon_state = "kiosk_off"
	else
		icon_state = "kiosk"

/obj/machinery/medical_kiosk/wrench_act(mob/living/user, obj/item/I) //Allows for wrenching/unwrenching the machine.
	..()
	default_unfasten_wrench(user, I, time = 10)
	return TRUE

/obj/machinery/medical_kiosk/RefreshParts()
  var/A
  var/obj/item/circuitboard/machine/medical_kiosk/board = circuit
  if(board)
    active_price = board.custom_cost

  for(var/obj/item/stock_parts/scanning_module/S in component_parts)
    A += S.rating
  if(A >= 3)
    upgrade_scan_active = TRUE
    adv_scan_active = TRUE
    return
  else if(A >= 2)
    upgrade_scan_active = TRUE
    return
  return

/obj/machinery/medical_kiosk/attackby(obj/item/O, mob/user, params)
  if(default_deconstruction_screwdriver(user, "kiosk_open", "kiosk", O))
    return
  else if(default_deconstruction_crowbar(O))
    return

  return ..()

/obj/machinery/medical_kiosk/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
  ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
  if(!ui)
    ui = new(user, src, ui_key, "medical_kiosk", name, 600, 500, master_ui, state)
    ui.open()
    scan_active = FALSE
    icon_state = "kiosk_off"
  if(ishuman(user))
    RefreshParts()
    H = user
    C = H.get_idcard(TRUE)

/obj/machinery/medical_kiosk/ui_data(mob/living/carbon/human/user)
  var/list/data = list()
  var/patient_name = user.name   //T1 upgrade information
  var/patient_status = "Alive."
  var/brute_loss = user.getBruteLoss()
  var/fire_loss = user.getFireLoss()
  var/tox_loss = user.getToxLoss()
  var/oxy_loss = user.getOxyLoss()
  var/sickness = "Patient does not show signs of disease."
  for(var/thing in user.diseases)
    var/datum/disease/D = thing
    if(!(D.visibility_flags & HIDDEN_SCANNER))
      sickness = "Warning: Patient is harboring some form of viral disease. Seek further medical attention."

  var/rad_value = user.radiation  //T2 upgrade information
  var/rad_status = "Target within normal-low radiation levels."
  var/trauma_status = "Patient is free of unique brain trauma."

  var/clone_loss = user.getCloneLoss()  //T3 Upgrade information
  var/brain_loss = user.getOrganLoss(ORGAN_SLOT_BRAIN)
  var/brain_status = "Brain patterns normal."
  if(LAZYLEN(user.get_traumas()))
    var/list/trauma_text = list()
    for(var/datum/brain_trauma/B in user.get_traumas())
      var/trauma_desc = ""
      switch(B.resilience)
        if(TRAUMA_RESILIENCE_SURGERY)
          trauma_desc += "severe "
        if(TRAUMA_RESILIENCE_LOBOTOMY)
          trauma_desc += "deep-rooted "
        if(TRAUMA_RESILIENCE_MAGIC, TRAUMA_RESILIENCE_ABSOLUTE)
          trauma_desc += "permanent "
      trauma_desc += B.scan_desc
      trauma_text += trauma_desc
    trauma_status = "Cerebral traumas detected: patient appears to be suffering from [english_list(trauma_text)]."

  if(user.stat == DEAD || HAS_TRAIT(user, TRAIT_FAKEDEATH))  //Patient status checks.
    patient_status = "Dead."
  if((brute_loss+fire_loss+tox_loss+oxy_loss) >= 80)
    patient_status = "Gravely Injured"
  else if((brute_loss+fire_loss+tox_loss+oxy_loss) >= 40)
    patient_status = "Injured"
  else if((brute_loss+fire_loss+tox_loss+oxy_loss) >= 20)
    patient_status = "Lightly Injured"

  if((brain_loss) >= 100)   //Brain status checks.
    brain_status = "Grave brain damage detected."
  else if((brain_loss) >= 50)
    brain_status = "Severe brain damage detected."
  else if((brain_loss) >= 20)
    brain_status = "Brain damage detected."
  else if((brain_loss) >= 1)
    brain_status = "Mild brain damage detected."  //You may have a miiiild case of severe brain damage.

  if(user.radiation >=1000)  //
    rad_status = "Patient is suffering from extreme radiation poisoning. Suggested treatment: Isolation of patient, followed by repeated dosages of Pentetic Acid."
  else if(user.radiation >= 500)
    rad_status = "Patient is suffering from alarming radiation poisoning. Suggested treatment: Heavy use of showers and decontamination of clothing. Take Pentetic Acid or Potassium Iodine."
  else if(user.radiation >= 100)
    rad_status = "Patient has moderate radioactive signatures. Keep under showers until symptoms subside."

  data["kiosk_cost"] = active_price
  data["patient_name"] = patient_name
  data["brute_health"] = brute_loss
  data["burn_health"] = fire_loss
  data["toxin_health"] = tox_loss
  data["suffocation_health"] = oxy_loss
  data["clone_health"] = clone_loss
  data["brain_health"] = brain_status
  data["brain_damage"] = brain_loss
  data["patient_status"] = patient_status
  data["rad_value"] = rad_value
  data["rad_status"] = rad_status
  data["trauma_status"] = trauma_status
  data["patient_illness"] = sickness
  data["active_status"] = scan_active ? 0 : 1
  data["upgrade_active_status"] = upgrade_scan_active ? 0 : 1
  data["adv_active_status"] = adv_scan_active ? 0 : 1
  return data

/obj/machinery/medical_kiosk/ui_act(action,active)
  if(..())
    return
  switch(action)
    if("beginScan")
      inuse()
      . = TRUE