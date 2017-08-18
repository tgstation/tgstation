/datum/intercept_text/build(mode_type)
  . = ..()
  if(mode_type == "shadowling")
    text += "<br><br>Sightings of strange alien creatures have been observed in your area. These aliens supposedly possess the ability to enslave unwitting personnel and leech from their power. \
	Be wary of dark areas and ensure all lights are kept well-maintained. Closely monitor all crew for suspicious behavior and perform dethralling surgery if they have obvious tells. Investigate all \
	reports of odd or suspicious sightings in maintenance."
