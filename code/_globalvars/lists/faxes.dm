/**
 * This defines the list of faxes managed by the server administrators. They are not physically present in
 * the game, but are shown in the fax list as existing.
 * Lists:
 * * additional_faxes_list - A list of "legal" faxes available with authorization.
 * * syndicate_faxes_list - List of faxes available after hacking.
 *
 * The list consists of the following elements:
 * * fax_name - The name displayed in the fax list.
 * * button_color - The color of this fax button in the list of all faxes.
 */
GLOBAL_LIST_INIT(additional_faxes_list, list(
	list("fax_name" = "Central Command", "button_color" = "#34c924"),
	list("fax_name" = "Clown Planet", "button_color" = "#f4c800"),
))

GLOBAL_LIST_INIT(syndicate_faxes_list, list(
	list("fax_name" = "Syndicate Coordination Center", "button_color" = "#ff0000"),
	list("fax_name" = "Federation of Wizards", "button_color" = "#8b00ff"),
	list("fax_name" = "Nar-Sie Church", "button_color" = "#8b0000"),
))
