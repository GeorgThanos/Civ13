//** Shield Helpers
//These are shared by various items that have shield-like behaviour

//bad_arc is the ABSOLUTE arc of directions from which we cannot block. If you want to fix it to e.g. the user's facing you will need to rotate the dirs yourself.
/proc/check_shield_arc(mob/user, var/bad_arc, atom/damage_source = null, mob/attacker = null)
	//check attack direction
	var/attack_dir = FALSE //direction from the user to the source of the attack
	if (istype(damage_source, /obj/item/projectile))
		var/obj/item/projectile/P = damage_source
		attack_dir = get_dir(get_turf(user), P.starting)
	else if (attacker)
		attack_dir = get_dir(get_turf(user), get_turf(attacker))
	else if (damage_source)
		attack_dir = get_dir(get_turf(user), get_turf(damage_source))

	if (!(attack_dir && (attack_dir & bad_arc)))
		return TRUE
	return FALSE

/proc/default_parry_check(mob/user, mob/attacker, atom/damage_source)
	//parry only melee attacks
	if (istype(damage_source, /obj/item/projectile) || (attacker && get_dist(user, attacker) > 1) || user.incapacitated())
		return FALSE

	if(user.defense_intent != I_PARRY)//If you're not on parry intent, you won't parry.
		return 0

	//block as long as they are not directly behind us
	var/bad_arc = reverse_direction(user.dir) //arc of directions from which we cannot block
	if (!check_shield_arc(user, bad_arc, damage_source, attacker))
		return FALSE

	return TRUE

/obj/item/weapon/shield
	name = "wood shield"
	icon_state = "buckler"
	item_state = "buckler"
	var/base_block_chance = 25
	w_class = 2.0
	slot_flags = SLOT_BACK|SLOT_DENYPOCKET
	var/material = "wood"
	health = 40 // hardness of wood
	var/cooldown = 0
/obj/item/weapon/shield/New()
	..()
	if (get_material_name() == "wood")
		flammable = TRUE
/obj/item/weapon/shield/steel
	name = "steel shield"
	icon_state = "steel_shield"
	item_state = "steel_shield"
	slot_flags = SLOT_BACK
	material = "steel"
	health = 60
	w_class = 3.0
	base_block_chance = 30

/obj/item/weapon/shield/iron
	name = "iron shield"
	icon_state = "iron_shield"
	item_state = "iron_shield"
	slot_flags = SLOT_BACK
	material = "iron"
	health = 50
	w_class = 3.0
	base_block_chance = 30

/obj/item/weapon/shield/bronze
	name = "bronze shield"
	icon_state = "bronze_shield"
	item_state = "bronze_shield"
	slot_flags = SLOT_BACK
	material = "bronze"
	health = 47
	w_class = 3.0
	base_block_chance = 30

/obj/item/weapon/shield/aspis
	name = "aspis"
	desc = "a round, slightly curved greek shield, with the colors and symbol of it's city-state."
	icon_state = "athenian_shield"
	item_state = "athenian_shield"
	slot_flags = SLOT_BACK
	material = "bronze"
	health = 47
	w_class = 3.0
	base_block_chance = 33

/obj/item/weapon/shield/aspis/New()
	..()
	icon_state = pick("athenian_shield", "spartan_shield", "pegasus_shield", "owl_shield")
	item_state = icon_state
	update_icon()

/obj/item/weapon/shield/roman
	name = "roman shield"
	desc = "a rectangular shield, with Roman motifs."
	icon_state = "roman_shield"
	item_state = "roman_shield"
	slot_flags = SLOT_BACK
	material = "bronze"
	health = 47
	w_class = 3.0
	base_block_chance = 35

/obj/item/weapon/shield/roman_buckler
	name = "roman parma shield"
	icon_state = "roman_buckler"
	item_state = "roman_buckler"
	base_block_chance = 27
	w_class = 2.0
	slot_flags = SLOT_BACK
	material = "wood"
	health = 40 // hardness of wood
/obj/item/weapon/shield/handle_shield(mob/user, var/damage, atom/damage_source = null, mob/attacker = null, var/def_zone = null, var/attack_text = "the attack")
	if (user.incapacitated())
		return FALSE

	//block as long as they are not directly behind us
	var/bad_arc = reverse_direction(user.dir) //arc of directions from which we cannot block
	if (check_shield_arc(user, bad_arc, damage_source, attacker))
		if (prob(get_block_chance(user, damage, damage_source, attacker)))
			user.visible_message("<font color='#E55300'><big>\The [user] blocks [attack_text] with \the [src]!</big></font>")
			if (istype(damage_source, /obj/item/weapon/melee))
				health -= 10
			else
				health--
			check_health()
			return TRUE
	return FALSE

/obj/item/weapon/shield/proc/get_block_chance(mob/user, var/damage, atom/damage_source = null, mob/attacker = null)
	return base_block_chance

/obj/item/weapon/shield/proc/check_health(var/consumed)
	if (health<=0)
		shatter(consumed)

/obj/item/weapon/shield/proc/shatter(var/consumed)
	var/turf/T = get_turf(src)
	T.visible_message("<span class='danger'>\The [src] is broken apart!</span>")
	if (istype(loc, /mob/living))
		var/mob/living/M = loc
		M.drop_from_inventory(src)
	playsound(src, "shatter", 70, TRUE)
	qdel(src)


/obj/item/weapon/shield/iron/semioval
	name = "semioval iron shield"
	icon_state = "semioval_shield"
	item_state = "semioval_shield"
	slot_flags = SLOT_BACK
	material = "iron"
	health = 50
	w_class = 3.0
	base_block_chance = 40


/obj/item/weapon/shield/iron/semioval/templar
	name = "semioval iron templar shield"
	icon_state = "semioval_shield_templar"
	item_state = "semioval_shield_templar"
	slot_flags = SLOT_BACK

/obj/item/weapon/shield/iron/semioval/templar2
	name = "semioval iron templar shield"
	icon_state = "semioval_shield_templar2"
	item_state = "semioval_shield_templar2"
	slot_flags = SLOT_BACK

obj/item/weapon/shield/red_buckler
	name = "red buckler shield"
	icon_state = "red_buckler"
	item_state = "red_buckler"
	base_block_chance = 25
	w_class = 2.0
	slot_flags = SLOT_BACK
	material = "wood"
	health = 40 // hardness of wood

obj/item/weapon/shield/blue_buckler
	name = "blue buckler shield"
	icon_state = "blue_buckler"
	item_state = "blue_buckler"
	base_block_chance = 25
	w_class = 2.0
	slot_flags = SLOT_BACK
	material = "wood"
	health = 40 // hardness of wood

obj/item/weapon/shield/attack_self(mob/user as mob)
	if (cooldown < world.time - 10)
		user.visible_message("<span class='warning'>[user] bashes the shield!</span>")
		playsound(user.loc, 'sound/effects/shieldbash2.ogg', 100, TRUE)
		cooldown = world.time

/obj/item/weapon/shield/arab_buckler
	name = "arabic round shield"
	icon_state = "arabic_shield"
	item_state = "arabic_shield"
	base_block_chance = 30
	w_class = 2.0
	slot_flags = SLOT_BACK
	material = "wood"
	health = 40 // hardness of wood