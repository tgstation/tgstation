/datum/asset/spritesheet/plumbing
	name = "plumbing-tgui"

/datum/asset/spritesheet/plumbing/create_spritesheets()
	//load only what we need from the icon files,format is icon_file_name = list of icon_states we need from this file
	var/list/essentials = list(
		'icons/obj/medical/iv_drip.dmi' = list("plumb"),
		'icons/obj/plumbing/fluid_ducts.dmi' = list("nduct"),
		'icons/hud/radial.dmi' = list(
			"plumbing_layer1",
			"plumbing_layer2",
			"plumbing_layer4",
			"plumbing_layer8",
			"plumbing_layer16",
		),
		'icons/obj/plumbing/plumbers.dmi' = list(
			"synthesizer",
			"reaction_chamber",
			"grinder_chemical",
			"growing_vat",
			"fermenter",
			"pump",
			"disposal",
			"buffer",
			"manifold",
			"pipe_input",
			"filter",
			"splitter",
			"beacon",
			"pipe_output",
			"tank",
			"acclimator",
			"bottler",
			"pill_press",
			"synthesizer_soda",
			"synthesizer_booze",
			"tap_output",
		),
	)

	for(var/icon_file as anything in essentials)
		for(var/icon_state as anything in essentials[icon_file])
			Insert(sprite_name = icon_state, I = icon_file, icon_state = icon_state)

