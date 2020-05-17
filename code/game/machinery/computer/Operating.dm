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

	var/dummy_preferred_gender = NEUTER
	var/dummy_preferred_species = "H. Sapiens"
	var/dummy_preferred_subspecies = "Human"
	var/list/dummy_species_options = list( \
		"H. Sapiens" = list("Human", "Off-Worlder Human"), \
		"T. Sapiens" = list("Tajara", "M'sai Tajara", "Zhan-Khazan Tajara"), \
		"S. Sapiens" = list("Skrell"), \
		"V. Esseli" = list("Vaurca Warrior", "Vaurca Worker"), \
		"Sinta'Unathi" = list("Unathi", "Aut'akh Unathi"), \
		"IPC" 	 = list("Baseline Frame", "Hephaestus G1 Industrial Frame", "Hephaestus G2 Industrial Frame", "Xion Industrial Frame", "Zeng-Hu Mobility Frame", "Bishop Accessory Frame", "Shell Frame"))

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
	if(table && (istype(table.victim)))
		victim = table.victim
		VUEUI_SET_CHECK(data["has_victim"], TRUE, ., data)
		VUEUI_SET_CHECK(data["brain_result"], victim.get_brain_result(), ., data)
		VUEUI_SET_CHECK(data["pulse"], victim.get_pulse(GETPULSE_TOOL), ., data)
		VUEUI_SET_CHECK(data["bp"], victim.get_blood_pressure(), ., data)
		VUEUI_SET_CHECK(data["bloodoxy"], victim.get_blood_oxygenation(), ., data)
	else
		victim = null
		VUEUI_SET_CHECK(data["has_victim"], FALSE, ., data)

	LAZYINITLIST(data["editor"])
	if(istype(victim, /mob/living/carbon/human/holodummy)) // Dummy Editor
		VUEUI_SET_CHECK(data["editor"]["active"], TRUE, ., data)
		VUEUI_SET_CHECK(data["editor"]["species"], dummy_preferred_species, ., data)
		VUEUI_SET_CHECK(data["editor"]["subspecies"], dummy_preferred_subspecies, ., data)
		VUEUI_SET_CHECK(data["editor"]["gender"], victim.gender, ., data)

	else
		VUEUI_SET_CHECK(data["editor"]["active"], FALSE, ., data)

/obj/machinery/computer/operating/ui_interact(mob/user, var/datum/topic_state/state = default_state)
	var/datum/vueui/ui = SSvueui.get_open_ui(user, src)
	if (!ui)
		ui = new(user, src, "medical-operatingtable", 400, 600, capitalize(name))
		ui.auto_update_content = TRUE
	ui.open()

/obj/machinery/computer/operating/proc/spawn_dummy()
	var/mob/living/carbon/human/holodummy/dummy = new(get_turf(table))
	dummy.set_species(dummy_preferred_subspecies)
	if(dummy_preferred_gender in dummy.species.default_genders)
		dummy.change_gender(dummy_preferred_gender)
	else
		dummy_preferred_gender = pick(dummy.species.default_genders)
		dummy.change_gender(dummy_preferred_gender)
	dummy.randomize_appearance()
	// Both changing species and changing gender, for some ungodly reason, regenerate organs completely. 
	dummy.make_organs_holograms()
	table.take_victim(dummy, null)

/obj/machinery/computer/operating/proc/try_regenerate_dummy()
	var/mob/living/carbon/human/holodummy/dummy = locate() in table.loc
	if(!istype(dummy)) // Obviously don't regenerate a non-holo-dummy
		return
	dummy.Move(get_step(loc, NORTH)) // This'll destroy the old dummy pretty harmlessly.
	spawn_dummy()

/obj/machinery/computer/operating/Topic(href, href_list)
	..()
	if(href_list["startholo"])
		if(!table)
			return
		var/mob/living/carbon/human/H = locate() in table.loc
		if(istype(H))
			return // Don't do anything if a person is there.
		spawn_dummy()
	if(href_list["regenerate"])
		try_regenerate_dummy()
	
	if(href_list["setspecies"])
		dummy_preferred_species = input(usr, "Select Species", "Select Species", dummy_preferred_species) in dummy_species_options
		if(!(dummy_preferred_subspecies in dummy_species_options[dummy_preferred_species])) // If this sub-species isn't in this super-species, pick one at random.
			dummy_preferred_subspecies = pick(dummy_species_options[dummy_preferred_species])
		try_regenerate_dummy()
	if(href_list["setsubspecies"])
		dummy_preferred_subspecies = input(usr, "Select Sub-Species", "Select Sub-Species", dummy_preferred_subspecies) in dummy_species_options[dummy_preferred_species]
		try_regenerate_dummy()
	if(href_list["setgender"])
		if(!table)
			return
		var/mob/living/carbon/human/dummy/H = locate() in table.loc
		if(istype(H))
			return // Don't do anything if a person is there.
		dummy_preferred_gender = input(usr, "Select Gender", "Select Gender", dummy_preferred_gender) in victim.species.default_genders
		try_regenerate_dummy()

	return

/obj/machinery/computer/operating/robotics
	name = "Robotics Opearting Computer"
	dummy_species_options = list("IPC" = list("Baseline Frame", "Hephaestus G1 Industrial Frame", "Hephaestus G2 Industrial Frame", "Xion Industrial Frame", "Zeng-Hu Mobility Frame", "Bishop Accessory Frame", "Shell Frame"))
	dummy_preferred_species = "IPC"
	dummy_preferred_subspecies = "Baseline Frame"

/obj/item/disk/holodummy
	name = "Hologram Storage Disk"
	var/mob/living/carbon/human/holodummy/dummy
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk0"
	item_state = "card-id"

/obj/item/disk/holodummy/proc/load_dummy(var/mob/living/carbon/human/holodummy/D)
	// Nothing in us, and this is a real dummy.
	if(istype(dummy))
		return 0
	if(!istype(D))
		return 0
	if(D.Move(src))
		dummy = D
		name = "[initial(name)]: [dummy.name]"
		return 1
	return 0

/obj/item/disk/holodummy/proc/unload_dummy(var/atom/targetlocation)
	if(!istype(dummy))
		return 0
	if(istype(targetlocation, /obj/machinery/bodyscanner))
		var/obj/machinery/bodyscanner/bs = targetlocation
		if(bs.occupant)
			return 0
		dummy.Move(bs)
		bs.occupant = dummy
		bs.update_use_power(2)
		bs.update_icon()
		dummy = null
		name = initial(name)
		return 1
	else if(istype(targetlocation, /obj/machinery/optable) && !(locate(/mob/living/carbon/human/holodummy/) in targetlocation.loc))
		dummy.forceMove(targetlocation.loc)
		dummy = null
		name = initial(name)
		return 1
	else if(istype(targetlocation, /obj/item/disk/holodummy) && targetlocation != src)
		var/obj/item/disk/holodummy/otherdisk = targetlocation
		if(otherdisk.load_dummy(dummy))
			dummy = null
			name = initial(name)
			return 1

	return 0

/obj/item/disk/holodummy/attack(mob/living/M, mob/living/user, var/target_zone = BP_CHEST)
	load_dummy(M)

/obj/item/disk/holodummy/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(istype(dummy))
		unload_dummy(target)
	else if(istype(target,/obj/machinery/bodyscanner))
		var/obj/machinery/bodyscanner/bs = target
		if(istype(bs.occupant,/mob/living/carbon/human/holodummy))
			load_dummy(bs.occupant)
			bs.occupant = null
			bs.update_use_power(1)
			bs.update_icon()