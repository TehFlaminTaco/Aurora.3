/mob/living/carbon/human/holodummy

/mob/living/carbon/human/holodummy/Initialize()
    . = ..()
    // only holoorgans please boss
    for(var/obj/item/organ/O in organs)
        O.status |= ORGAN_HOLOGRAM
    for(var/obj/item/organ/O in internal_organs)
        O.status |= ORGAN_HOLOGRAM
        
    var/dummyName = "holo-dummy #[rand(0000,9999)]"
    fully_replace_character_name(dummyName, dummyName)
    alpha = 200
    color = "#88CCFF"
    set_light(1.4, 1, COLOR_CYAN)

/mob/living/carbon/human/holodummy/Move(var/atom/target_loc)
    if(!(/obj/machinery/optable in target_loc)) // Moving the body results in destruction...
        var/turf/current_turf = get_turf(src)
        // Dump our contents, to be safe.
        for(var/atom/movable/A in contents)
            A.Move(current_turf) // This will also destroy any holo-organs, but keep any real organs.
        spawn(0)
            qdel(src) // Destroy after move to prevent runtimes...
        return 0
    . = ..()