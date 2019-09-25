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
	var/default_price = 5  //I'm defaulting to a low price on this, but in the future I wouldn't have an issue making it more or less expensive.
	var/scan_active = null  //Shows if the machine is being used. resets upon new viewer.
	var/adv_scan_active = null  //Shows if the machine has upgraded functionality
	var/datum/bank_account/account  //payer's account.
	var/mob/living/carbon/human/H   //the person using the console in each instance.
	var/obj/item/card/id/C    //the account of the person using the console.

/obj/machinery/medical_kiosk/proc/inuse()  //Verifies that the user can use the interface, followed by showing medical information.
  if(C.registered_account)
    account = C.registered_account
  else
    say("No account detected.")  //No homeless crew.
    return
  if(!account.has_money(default_price))
    say("You do not possess the funds to purchase this.")  //No jobless crew, either.
    return
  else
    account.adjust_money(-default_price)
    var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_MED)
    if(D)
      D.adjust_money(default_price)
    use_power(20)
  scan_active = 0
  icon_state = "kiosk_active"
  say("Thank you for your patronage!")
  adv_scan_active = 1
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
  for(var/obj/item/stock_parts/scanning_module/S in component_parts)
    A += S.rating
  if(A >=3)
    adv_scan_active = 0
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
    ui = new(user, src, ui_key, "medical_kiosk", name, 550, 400, master_ui, state)
    ui.open()
    scan_active = 1
    icon_state = "kiosk_off"
  if(ishuman(user))
    H = user
    C = H.get_idcard(TRUE)

/obj/machinery/medical_kiosk/ui_data(mob/living/carbon/human/user)
  var/list/data = list()
  var/patient_name = user.name
  var/patient_status = "Alive."
  var/brute_loss = user.getBruteLoss()
  var/fire_loss = user.getFireLoss()
  var/tox_loss = user.getToxLoss()
  var/oxy_loss = user.getOxyLoss()
  var/clone_loss = user.getCloneLoss()
  var/brain_loss = user.getOrganLoss(ORGAN_SLOT_BRAIN)
  var/brain_status = "Brain patterns normal."
  var/sickness = "Patient does not show signs of disease."
  for(var/thing in user.diseases)
    var/datum/disease/D = thing
    if(!(D.visibility_flags & HIDDEN_SCANNER))
      sickness = "Warning: Patient is harboring some form of viral disease. Seek further medical attention."

  if(user.stat == DEAD || HAS_TRAIT(user, TRAIT_FAKEDEATH))
    patient_status = "Dead."
  if((brute_loss+fire_loss+tox_loss+oxy_loss) >= 80)
    patient_status = "Gravely Injured"
  else if((brute_loss+fire_loss+tox_loss+oxy_loss) >= 40)
    patient_status = "Injured"
  else if((brute_loss+fire_loss+tox_loss+oxy_loss) >= 20)
    patient_status = "Lightly Injured"

  if((brain_loss) >= 100)
    brain_status = "Grave brain damage detected."
  else if((brain_loss) >= 50)
    brain_status = "Severe brain damage detected."
  else if((brain_loss) >= 20)
    brain_status = "Brain damage detected."
  else if((brain_loss) >= 1)
    brain_status = "Mild brain damage detected."  //You may have a miiiild case of severe brain damage.

  data["patient_name"] = patient_name
  data["brute_health"] = brute_loss
  data["burn_health"] = fire_loss
  data["toxin_health"] = tox_loss
  data["suffocation_health"] = oxy_loss
  data["clone_health"] = clone_loss
  data["brain_health"] = brain_status
  data["patient_status"] = patient_status
  data["patient_illness"] = sickness
  data["active_status"] = scan_active ? 0 : 1
  data["adv_active_status"] = adv_scan_active ? 0 : 1

  return data

/obj/machinery/medical_kiosk/ui_act(action,active)
  if(..())
    return
  switch(action)
    if("beginScan")
      inuse()
      . = TRUE