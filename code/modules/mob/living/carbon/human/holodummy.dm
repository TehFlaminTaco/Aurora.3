/mob/living/carbon/human/holodummy

/mob/living/carbon/human/holodummy/Initialize()
    . = ..()
    // Spawn them laying down, and intentionally SSD
    teleop = TRUE
    lying = 1
    make_organs_holograms() // Incase an admin spawns this, or something...
    mutations |= NOCLONE // This conveniently prevents blood being taken in all forms.

    // Give them an auto-generated name.
    var/dummyName = "holo-dummy #[rand(0000,9999)]"
    fully_replace_character_name(dummyName, dummyName)

    // Make it all holo-grammy and pretty
    set_light(1.4, 1, COLOR_CYAN)
    color = "#88CCFF"
    alpha = 0
    spawn()
        animate(src, alpha=200, time = 5, easing = QUAD_EASING | EASE_IN)

// The only proc that does this also regenerates _everything_ for the mob.
// There is no easy way to randomize an appearance.
/mob/living/carbon/human/holodummy/proc/randomize_appearance()
    var/datum/preferences/P = new()
    if(species.appearance_flags & HAS_SKIN_TONE)
        s_tone = random_skin_tone()
    if(species.appearance_flags & HAS_EYE_COLOR)
        P.randomize_eyes_color()
    if(species.appearance_flags & HAS_SKIN_COLOR)
        P.randomize_skin_color(species)
    P.randomize_hair_color("hair")
    P.randomize_hair_color("facial")
    h_style = random_hair_style(gender, species.name)
    f_style = random_facial_hair_style(gender, species.name)
    r_eyes = P.r_eyes
    g_eyes = P.g_eyes
    b_eyes = P.b_eyes
    r_skin = P.r_skin
    g_skin = P.g_skin
    b_skin = P.b_skin
    r_hair = P.r_hair
    g_hair = P.g_hair
    b_hair = P.b_hair
    r_facial = P.r_facial
    g_facial = P.g_facial
    b_facial = P.b_facial

    force_update_limbs()
    update_mutations(0)
    update_body(0)
    update_hair(0)
    update_underwear(0)
    update_icons()

/mob/living/carbon/human/holodummy/proc/make_organs_holograms()
    // Ensure we have holographic organs
    for(var/obj/item/organ/O in organs)
        O.status |= ORGAN_HOLOGRAM
    for(var/obj/item/organ/O in internal_organs)
        O.status |= ORGAN_HOLOGRAM

/mob/living/carbon/human/holodummy/proc/valid_location(var/atom/loc)
    if(istype(loc, /obj/machinery/bodyscanner) || istype(loc, /obj/item/disk/holodummy))
        return 1
    if(locate(/obj/machinery/optable) in loc)
        return 1
    return 0

/mob/living/carbon/human/holodummy/proc/check_or_destroy(var/atom/target_loc)
    if(!valid_location(target_loc)) // Moving the body results in destruction...
        var/turf/current_turf = get_turf(src)
        // Eject all non-holo limbs, so they're not destroyed/emptied
        for(var/obj/item/organ/external/E in organs)
            if(!(E.status & ORGAN_HOLOGRAM))
                E.droplimb(TRUE, DROPLIMB_EDGE)
        for(var/obj/item/organ/internal/E in internal_organs)
            if(!(E.status & ORGAN_HOLOGRAM))
                E.removed()
        // Dump our contents, to be safe.
        for(var/atom/movable/A in contents)
            A.Move(current_turf) // This will also destroy any holo-organs, but keep any real organs.
        spawn()
            qdel(src) // Destroy after move to prevent runtimes...
        return 1
    return 0
/mob/living/carbon/human/holodummy/Life()
    ..()
    check_or_destroy(loc) // Just incase...


/mob/living/carbon/human/holodummy/Move(var/atom/target_loc)
    if(check_or_destroy(target_loc))
        return 0
    . = ..()