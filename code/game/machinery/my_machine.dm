/obj/machinery/my_machine
	name = "medical kiosk"
	desc = "A freestanding medical kiosk, which can provide your basic medical status."
	icon = 'icons/obj/machines/medical_kiosk.dmi'
	icon_state = "kiosk_off"
	layer = ABOVE_ALL_MOB_LAYER // Overhead
	density = TRUE
	var/scan_active = null
	payment_department = ACCOUNT_MED

/obj/machinery/my_machine/proc/inUse()
  scan_active = 0
  icon_state = "kiosk_active"
  return

/obj/machinery/my_machine/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
  ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
  if(!ui)
    ui = new(user, src, ui_key, "my_machine", name, 500, 300, master_ui, state)
    ui.open()
    scan_active = 1
    icon_state = "kiosk_off"

/obj/machinery/my_machine/ui_data(mob/living/carbon/human/user)
  var/list/data = list()
  var/patient_name = user.name
  var/patient_status = "Alive."
  var/brute_loss = user.getBruteLoss()
  var/fire_loss = user.getFireLoss()
  var/tox_loss = user.getToxLoss()
  var/oxy_loss = user.getOxyLoss()
  var/sickness = "Patient does not show signs of disease."
  for(var/thing in user.diseases)
    var/datum/disease/D = thing
    if(!(D.visibility_flags & HIDDEN_SCANNER))
      sickness = "Warning: patient is harboring some form of viral disease. Seek further medical attention."
  data["patient_name"] = patient_name
  data["brute_health"] = brute_loss
  data["burn_health"] = fire_loss
  data["toxin_health"] = tox_loss
  data["suffocation_health"] = oxy_loss
  data["patient_status"] = patient_status
  data["patient_illness"] = sickness
  data["active_status"] = scan_active ? 0 : 1

  if(user.stat == DEAD || HAS_TRAIT(user, TRAIT_FAKEDEATH))
    patient_status = "Dead."
  return data

/obj/machinery/my_machine/ui_act(action,active)
  if(..())
    return
  switch(action)
    if("beginScan")
      inUse()
      . = TRUE