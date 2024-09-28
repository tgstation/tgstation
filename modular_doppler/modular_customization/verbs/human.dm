/mob/living/carbon/human/verb/toggle_undies()
	set category = "IC"
	set name = "Toggle underwear visibility"
	set desc = "Allows you to toggle which underwear should show or be hidden. Underwear will obscure genitals."

	if(stat != CONSCIOUS)
		to_chat(usr, span_warning("You can't toggle underwear visibility right now..."))
		return

	var/underwear_button = underwear_visibility & UNDERWEAR_HIDE_UNDIES ? "Show underwear" : "Hide underwear"
	var/undershirt_button = underwear_visibility & UNDERWEAR_HIDE_SHIRT ? "Show shirt" : "Hide shirt"
	var/socks_button = underwear_visibility & UNDERWEAR_HIDE_SOCKS ? "Show socks" : "Hide socks"
	var/bra_button = underwear_visibility & UNDERWEAR_HIDE_BRA ? "Show bra" : "Hide bra"

	var/list/choice_list = list("[underwear_button]" = "underwear", "[bra_button]" = "bra", "[undershirt_button]" = "shirt", "[socks_button]" = "socks")

	if(underwear_visibility != NONE)
		choice_list += list("Show all" = "show")

	if(underwear_visibility != UNDERWEAR_HIDE_ALL)
		choice_list += list("Hide all" = "hide")

	var/picked_visibility = tgui_input_list(src, "Choose visibility setting", "Show/Hide underwear", choice_list)

	if(!picked_visibility)
		return

	var/picked_choice = choice_list[picked_visibility]

	switch(picked_choice)
		if("underwear")
			underwear_visibility ^= UNDERWEAR_HIDE_UNDIES
		if("bra")
			underwear_visibility ^= UNDERWEAR_HIDE_BRA
		if("shirt")
			underwear_visibility ^= UNDERWEAR_HIDE_SHIRT
		if("socks")
			underwear_visibility ^= UNDERWEAR_HIDE_SOCKS
		if("show")
			underwear_visibility = NONE
		if("hide")
			underwear_visibility = UNDERWEAR_HIDE_ALL

	update_body()
