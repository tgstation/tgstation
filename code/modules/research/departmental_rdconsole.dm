/obj/machinery/computer/rdconsole/department
	name = "department research console"
	desc = "A special research console designed to permit each department to research technology without the assistance of the Science department."
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	allowed_department_flags = DEPARTMENTAL_FLAG_ALL
	var/department_tag = "Science"
	circuit = /obj/item/circuitboard/computer/rdconsole/department

/obj/machinery/computer/rdconsole/department/science
	name = "department R&D console (Science)"
	allowed_department_flags = DEPARTMENTAL_FLAG_ALL|DEPARTMENTAL_FLAG_SCIENCE
	department_tag = "Science"
	circuit = /obj/item/circuitboard/computer/rdconsole/department/science

/obj/machinery/computer/rdconsole/department/engineering
	name = "department R&D console (Engineering)"
	icon_screen = "rdcomp_eng"
	allowed_department_flags = DEPARTMENTAL_FLAG_ALL|DEPARTMENTAL_FLAG_ENGINEERING
	department_tag = "Engineering"
	circuit = /obj/item/circuitboard/computer/rdconsole/department/engineering

/obj/machinery/computer/rdconsole/department/service
	name = "department R&D console (Service)"
	allowed_department_flags = DEPARTMENTAL_FLAG_ALL|DEPARTMENTAL_FLAG_SERVICE
	department_tag = "Service"
	circuit = /obj/item/circuitboard/computer/rdconsole/department/service

/obj/machinery/computer/rdconsole/department/medical
	name = "department R&D console (Medical)"
	icon_screen = "rdcomp_med"
	allowed_department_flags = DEPARTMENTAL_FLAG_ALL|DEPARTMENTAL_FLAG_MEDICAL
	department_tag = "Medical"
	circuit = /obj/item/circuitboard/computer/rdconsole/department/medical

/obj/machinery/computer/rdconsole/department/cargo
	name = "department R&D console (Cargo)"
	allowed_department_flags = DEPARTMENTAL_FLAG_ALL|DEPARTMENTAL_FLAG_CARGO
	department_tag = "Cargo"
	req_access = "31"
	req_access_txt = "31"
	circuit = /obj/item/circuitboard/computer/rdconsole/department/cargo

/obj/machinery/computer/rdconsole/department/security
	name = "department R&D console (Security)"
	allowed_department_flags = DEPARTMENTAL_FLAG_ALL|DEPARTMENTAL_FLAG_SECURITY
	department_tag = "Security"
	circuit = /obj/item/circuitboard/computer/rdconsole/department/security
