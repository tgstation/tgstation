/client/verb/fix_rightclick()
	set category = "OOC"
	set name = "Enable Rightclick Context Menu"
	set desc = "If combat mode stuck your context menu to off, press this!"
	show_popup_menus = TRUE
	to_chat(src, "<span class='boldnotice'>The right-click context menu has been forcefully enabled.</span>")
