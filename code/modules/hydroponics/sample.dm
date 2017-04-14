/obj/item/seeds/sample
	name = "plant sample"
	icon_state = "sample-empty"
	potency = -1
	yield = -1
	var/sample_color = "#FFFFFF"

/obj/item/seeds/sample/New()
	..()
	if(sample_color)
		var/image/I = image(icon, icon_state = "sample-filling")
		I.color = sample_color
		add_overlay(I)

/obj/item/seeds/sample/get_analyzer_text()
	return " The DNA of this sample is damaged beyond recovery, it can't support life on its own.\n*---------*"

/obj/item/seeds/sample/alienweed
	name = "alien weed sample"
	icon_state = "alienweed"
	sample_color = null