//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/operating
	name = "patient monitoring console"
	density = 1
	anchored = 1.0

	light_color = LIGHT_COLOR_CYAN
	icon_screen = "crew"
	circuit = /obj/item/circuitboard/operating
	var/mob/living/carbon/human/victim = null
	var/obj/machinery/optable/table = null

/obj/machinery/computer/operating/Initialize()
	. = ..()
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		table = locate(/obj/machinery/optable, get_step(src, dir))
		if (table)
			table.computer = src
			break

/obj/machinery/computer/operating/attack_ai(var/mob/user)
	return attack_hand(user)

/obj/machinery/computer/operating/attack_hand(var/mob/user)
	if(..())
		return
	ui_interact(user)


/obj/machinery/computer/operating/vueui_data_change(var/list/data, /mob/user, var/datum/vueui/ui)
	LAZYINITLIST(data)
	if(table && (table.check_victim()))
		victim = table.victim
		VUEUI_SET_CHECK(data["has_victim"], TRUE, ., data)
		VUEUI_SET_CHECK(data["brain_result"], victim.get_brain_result(), ., data)
		VUEUI_SET_CHECK(data["pulse"], victim.get_pulse(GETPULSE_TOOL), ., data)
		VUEUI_SET_CHECK(data["bp"], victim.get_blood_pressure(), ., data)
		VUEUI_SET_CHECK(data["bloodoxy"], victim.get_blood_oxygenation(), ., data)
	else
		VUEUI_SET_CHECK(data["has_victim"], FALSE, ., data)

/obj/machinery/computer/operating/ui_interact(mob/user, var/datum/topic_state/state = default_state)
	var/datum/vueui/ui = SSvueui.get_open_ui(user, src)
	if (!ui)
		ui = new(user, src, "medical-operatingtable", 400, 600, capitalize(name))
		ui.auto_update_content = TRUE
	ui.open()

/obj/machinery/computer/operating/Topic(href, href_list)
	..()
	return