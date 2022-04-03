/obj/machinery/rnd/production/techfab/department
	name = "department techfab"
	desc = "An advanced fabricator designed to print out the latest prototypes and circuits researched from Science. Contains hardware to sync to research networks. This one is department-locked and only possesses a limited set of decryption keys."
	icon_state = "protolathe"
	circuit = /obj/item/circuitboard/machine/techfab/department

/obj/machinery/rnd/production/techfab/department/engineering
	name = "department techfab (Engineering)"
	allowed_department_flags = DEPARTMENTAL_FLAG_ENGINEERING
	department_tag = "Engineering"
	circuit = /obj/item/circuitboard/machine/techfab/department/engineering
	stripe_color = "#EFB341"

/obj/machinery/rnd/production/techfab/department/service
	name = "department techfab (Service)"
	allowed_department_flags = DEPARTMENTAL_FLAG_SERVICE
	department_tag = "Service"
	circuit = /obj/item/circuitboard/machine/techfab/department/service
	stripe_color = "#83ca41"

/obj/machinery/rnd/production/techfab/department/medical
	name = "department techfab (Medical)"
	allowed_department_flags = DEPARTMENTAL_FLAG_MEDICAL
	department_tag = "Medical"
	circuit = /obj/item/circuitboard/machine/techfab/department/medical
	stripe_color = "#52B4E9"

/obj/machinery/rnd/production/techfab/department/cargo
	name = "department techfab (Cargo)"
	allowed_department_flags = DEPARTMENTAL_FLAG_CARGO
	department_tag = "Cargo"
	circuit = /obj/item/circuitboard/machine/techfab/department/cargo
	stripe_color = "#956929"

/obj/machinery/rnd/production/techfab/department/science
	name = "department techfab (Science)"
	allowed_department_flags = DEPARTMENTAL_FLAG_SCIENCE
	department_tag = "Science"
	circuit = /obj/item/circuitboard/machine/techfab/department/science
	stripe_color = "#D381C9"

/obj/machinery/rnd/production/techfab/department/security
	name = "department techfab (Security)"
	allowed_department_flags = DEPARTMENTAL_FLAG_SECURITY
	department_tag = "Security"
	circuit = /obj/item/circuitboard/machine/techfab/department/security
	stripe_color = "#DE3A3A"
