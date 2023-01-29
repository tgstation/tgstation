/// A font datum, it exists to define a custom font to use in a span style later.
/datum/font
	/// Font name, just so people know what to put in their span style.
	var/name
	/// The font file we link to.
	var/font_family

/datum/font/vcr_osd_mono
	name = "VCR OSD Mono"
	font_family = 'interface/VCR_OSD_Mono.ttf'
