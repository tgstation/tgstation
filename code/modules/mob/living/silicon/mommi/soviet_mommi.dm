/* THIS FILE IS IN UTF-8. EDIT WITH NOTEPAD++ OR ATOM OR YOU WILL FUCK THE ENCODING. */
 /mob/living/silicon/robot/mommi/soviet
  prefix="Remont Robot" // Ремонт робот - Repair Robot
  damage_control_network="Usherp" // ущерб - Contextual translation of "Damage Control"
  desc = "This thing looks so Russian that you get the urge to wrestle bears and chug vodka."

// Fuck individualism
/mob/living/silicon/robot/mommi/soviet/updatename(var/oldprefix as text)
  var/changed_name = ""
  changed_name = "[prefix] [num2text(ident)]"
  real_name = changed_name
  name = real_name

// Ditto
/mob/living/silicon/robot/mommi/soviet/Namepick()
  return 0
