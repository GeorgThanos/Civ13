var/global/list/sparring_attack_cache = list()

//Species unarmed attacks
/datum/unarmed_attack
	var/attack_verb = list("attack")	// Empty hand hurt intent verb.
	var/attack_noun = list("fist")
	var/damage = FALSE						// Extra empty hand attack damage.
	var/attack_sound = "punch"
	var/miss_sound = 'sound/weapons/punchmiss.ogg'
	var/shredding = FALSE // Calls the old attack_alien() behavior on objects/mobs when on harm intent.
	var/sharp = FALSE
	var/edge = FALSE

	var/deal_halloss
	var/sparring_variant_type = /datum/unarmed_attack/light_strike

	var/eye_attack_text
	var/eye_attack_text_victim

/datum/unarmed_attack/proc/get_sparring_variant()
	if (sparring_variant_type)
		if (!sparring_attack_cache[sparring_variant_type])
			sparring_attack_cache[sparring_variant_type] = new sparring_variant_type()
		return sparring_attack_cache[sparring_variant_type]

/datum/unarmed_attack/proc/is_usable(var/mob/living/carbon/human/user, var/mob/living/carbon/human/target, var/zone)
	if (user.restrained())
		return FALSE

	// Check if they have a functioning hand.
	var/obj/item/organ/external/E = user.organs_by_name["l_hand"]
	if (E && !E.is_stump())
		return TRUE

	E = user.organs_by_name["r_hand"]
	if (E && !E.is_stump())
		return TRUE

	return FALSE

/datum/unarmed_attack/proc/get_unarmed_damage()
	return damage

/datum/unarmed_attack/proc/apply_effects(var/mob/living/carbon/human/user,var/mob/living/carbon/human/target,var/armor,var/attack_damage,var/zone)

	if (target.stat == DEAD)
		return

	var/stun_chance = rand(0, 100)

	if (attack_damage >= 5 && armor < 2 && !(target == user) && stun_chance <= attack_damage * 5) // 25% standard chance
		switch(zone) // strong punches can have effects depending on where they hit
			if ("head", "mouth", "eyes")
				// Induce blurriness
				target.visible_message("<span class='danger'>[target] looks momentarily disoriented.</span>", "<span class='danger'>You see stars.</span>")
				target.apply_effect(attack_damage*2, EYE_BLUR, armor)
			if ("l_arm", "l_hand")
				if (target.l_hand)
					// Disarm left hand
					//Urist McAssistant dropped the macguffin with a scream just sounds odd. Plus it doesn't work with NO_PAIN
					target.visible_message("<span class='danger'>\The [target.l_hand] was knocked right out of [target]'s grasp!</span>")
					target.drop_l_hand()
			if ("r_arm", "r_hand")
				if (target.r_hand)
					// Disarm right hand
					target.visible_message("<span class='danger'>\The [target.r_hand] was knocked right out of [target]'s grasp!</span>")
					target.drop_r_hand()
			if ("chest")
				if (!target.lying)
					var/turf/T = get_step(get_turf(target), get_dir(get_turf(user), get_turf(target)))
					if (!T.density)
						step(target, get_dir(get_turf(user), get_turf(target)))
						target.visible_message("<span class='danger'>[pick("[target] was sent flying backward!", "[target] staggers back from the impact!")]</span>")
					else
						target.visible_message("<span class='danger'>[target] slams into [T]!</span>")
						target.Weaken(rand(1,2))
						target.adjustBruteLoss(rand(10,15))
						playsound(get_turf(target), 'sound/effects/gore/fallsmash.ogg', 100)
						for (var/obj/structure/window/W in T)
							W.shatter()
					if (prob(50))
						target.set_dir(reverse_dir[target.dir])
					target.apply_effect(attack_damage * 0.4, WEAKEN, armor)
			if ("groin")
				target.visible_message("<span class='warning'>[target] looks like \he is in pain!</span>", "<span class='warning'>[(target.gender=="female") ? "Oh god that hurt!" : "Oh no, not your[pick("testicles", "crown jewels", "clockweights", "family jewels", "marbles", "bean bags", "teabags", "sweetmeats", "goolies")]!"]</span>")
				target.apply_effects(stutter = attack_damage * 2, agony = attack_damage* 3, blocked = armor)
			if ("l_leg", "l_foot", "r_leg", "r_foot")
				if (!target.lying)
					target.visible_message("<span class='warning'>[target] gives way slightly.</span>")
					target.apply_effect(attack_damage*3, AGONY, armor)
	else if (attack_damage >= 5 && !(target == user) && (stun_chance + attack_damage * 5 >= 100) && armor < 2) // Chance to get the usual throwdown as well (25% standard chance)
		if (!target.lying)
			target.visible_message("<span class='danger'>[target] [pick("slumps", "falls", "drops")] down to the ground!</span>")
		else
			target.visible_message("<span class='danger'>[target] has been weakened!</span>")
		target.apply_effect(3, WEAKEN, armor)

/datum/unarmed_attack/proc/show_attack(var/mob/living/carbon/human/user, var/mob/living/carbon/human/target, var/zone, var/attack_damage)
	var/obj/item/organ/external/affecting = target.get_organ(zone)
	user.visible_message("<span class='warning'>[user] [pick(attack_verb)] [target] in the [affecting.name]!</span>")
	playsound(user.loc, attack_sound, 25, TRUE, -1)

/datum/unarmed_attack/proc/handle_eye_attack(var/mob/living/carbon/human/user, var/mob/living/carbon/human/target)
	var/obj/item/organ/eyes/eyes = target.internal_organs_by_name["eyes"]
	eyes.take_damage(rand(3,4), TRUE)

	user.visible_message("<span class='danger'>[user] presses \his [eye_attack_text] into [target]'s [eyes.name]!</span>")
	target << "<span class='danger'>You experience[(target.species.flags & NO_PAIN)? "" : " immense pain as you feel" ] [eye_attack_text_victim] being pressed into your [eyes.name][(target.species.flags & NO_PAIN)? "." : "!"]</span>"

/datum/unarmed_attack/bite
	attack_verb = list("bit")
	attack_sound = 'sound/weapons/bite.ogg'
	shredding = FALSE
	damage = FALSE
	sharp = FALSE
	edge = FALSE

/datum/unarmed_attack/bite/is_usable(var/mob/living/carbon/human/user, var/mob/living/carbon/human/target, var/zone)

	if (user.wear_mask && (istype(user.wear_mask, /obj/item/clothing/mask/muzzle) || istype(user.wear_mask, /obj/item/weapon/grenade)))
		return FALSE
	if (user == target && (zone == "head" || zone == "eyes" || zone == "mouth"))
		return FALSE
	return TRUE

/datum/unarmed_attack/punch
	attack_verb = list("punched")
	attack_noun = list("fist")
	eye_attack_text = "fingers"
	eye_attack_text_victim = "digits"
	damage = FALSE

/datum/unarmed_attack/punch/show_attack(var/mob/living/carbon/human/user, var/mob/living/carbon/human/target, var/zone, var/attack_damage)
	var/obj/item/organ/external/affecting = target.get_organ(zone)
	if (!affecting)
		return
	var/organ = affecting.name

	attack_damage = Clamp(attack_damage, TRUE, 5) // We expect damage input of TRUE to 5 for this proc. But we leave this check juuust in case.

	if (target == user)
		user.visible_message("<span class='danger'>[user] [pick(attack_verb)] \himself in the [organ]!</span>")
		return FALSE

	if (!target.lying)
		switch(zone)
			if ("head", "mouth", "eyes")
				// ----- HEAD ----- //
				switch(attack_damage)
					if (1 to 2)
						user.visible_message("<span class='danger'>[user] slapped [target] across \his cheek!</span>")
					if (3 to 4)
						user.visible_message(pick(
							40; "<span class='danger'>[user] [pick(attack_verb)] [target] in the head!</span>",
							30; "<span class='danger'>[user] struck [target] in the head[pick("", " with a closed fist")]!</span>",
							30; "<span class='danger'>[user] threw a hook against [target]'s head!</span>"
							))
					if (5)
						user.visible_message(pick(
							30; "<span class='danger'>[user] gave [target] a resounding [pick("slap", "punch")] to the face!</span>",
							40; "<span class='danger'>[user] smashed \his [pick(attack_noun)] into [target]'s face!</span>",
							30; "<span class='danger'>[user] gave a strong blow against [target]'s jaw!</span>"
							))
			else
				// ----- BODY ----- //
				switch(attack_damage)
					if (1 to 2)	user.visible_message("<span class='danger'>[user] threw a glancing punch at [target]'s [organ]!</span>")
					if (1 to 4)	user.visible_message("<span class='danger'>[user] [pick(attack_verb)] [target] in \his [organ]!</span>")
					if (5)
						user.visible_message(pick(
							50; "<span class='danger'>[user] smashed \his [pick(attack_noun)] into [target]'s [organ]!</span>",
							50; "<span class='danger'>[user] landed a striking [pick(attack_noun)] on [target]'s [organ]!</span>"
							))
	else
		user.visible_message("<span class='danger'>[user] [pick("punched", "threw a punch against", "struck", "slammed their [pick(attack_noun)] into")] [target]'s [organ]!</span>") //why do we have a separate set of verbs for lying targets?

/datum/unarmed_attack/kick
	attack_verb = list("kicked", "kicked", "kicked", "kneed")
	attack_noun = list("kick", "kick", "kick", "knee strike")
	attack_sound = "swing_hit"
	damage = FALSE

/datum/unarmed_attack/kick/is_usable(var/mob/living/carbon/human/user, var/mob/living/carbon/human/target, var/zone)
	if (user.legcuffed)
		return FALSE

	if (!(zone in list("l_leg", "r_leg", "l_foot", "r_foot", "groin")))
		return FALSE

	var/obj/item/organ/external/E = user.organs_by_name["l_foot"]
	if (E && !E.is_stump())
		return TRUE

	E = user.organs_by_name["r_foot"]
	if (E && !E.is_stump())
		return TRUE

	return FALSE

/datum/unarmed_attack/kick/get_unarmed_damage(var/mob/living/carbon/human/user)
	var/obj/item/clothing/shoes = user.shoes
	if (!istype(shoes))
		return damage
	return damage + (shoes ? shoes.force : FALSE)

/datum/unarmed_attack/kick/show_attack(var/mob/living/carbon/human/user, var/mob/living/carbon/human/target, var/zone, var/attack_damage)
	var/obj/item/organ/external/affecting = target.get_organ(zone)
	var/organ = affecting.name

	attack_damage = Clamp(attack_damage, TRUE, 5)

	switch(attack_damage)
		if (1 to 2)	user.visible_message("<span class='danger'>[user] threw [target] a glancing [pick(attack_noun)] to the [organ]!</span>") //it's not that they're kicking lightly, it's that the kick didn't quite connect
		if (3 to 4)	user.visible_message("<span class='danger'>[user] [pick(attack_verb)] [target] in \his [organ]!</span>")
		if (5)		user.visible_message("<span class='danger'>[user] landed a strong [pick(attack_noun)] against [target]'s [organ]!</span>")

/datum/unarmed_attack/stomp
	attack_verb = null
	attack_noun = list("stomp")
	attack_sound = "swing_hit"
	damage = FALSE

/datum/unarmed_attack/stomp/is_usable(var/mob/living/carbon/human/user, var/mob/living/carbon/human/target, var/zone)

	if (user.legcuffed)
		return FALSE

	if (!istype(target))
		return FALSE

	if (!user.lying && (target.lying || (zone in list("l_foot", "r_foot"))))
		if (target.grabbed_by == user && target.lying)
			return FALSE
		var/obj/item/organ/external/E = user.organs_by_name["l_foot"]
		if (E && !E.is_stump())
			return TRUE

		E = user.organs_by_name["r_foot"]
		if (E && !E.is_stump())
			return TRUE

		return FALSE

/datum/unarmed_attack/stomp/get_unarmed_damage(var/mob/living/carbon/human/user)
	var/obj/item/clothing/shoes = user.shoes
	return damage + (shoes ? shoes.force : FALSE)

/datum/unarmed_attack/stomp/show_attack(var/mob/living/carbon/human/user, var/mob/living/carbon/human/target, var/zone, var/attack_damage)
	var/obj/item/organ/external/affecting = target.get_organ(zone)
	var/organ = affecting.name
	var/obj/item/clothing/shoes = user.shoes

	attack_damage = Clamp(attack_damage, TRUE, 5)

	switch(attack_damage)
		if (1 to 4)	user.visible_message("<span class='danger'>[pick("[user] stomped on", "[user] slammed \his [shoes ? copytext(shoes.name, TRUE, -1) : "foot"] down onto")] [target]'s [organ]!</span>")
		if (5)		user.visible_message("<span class='danger'>[pick("[user] landed a powerful stomp on", "[user] stomped down hard on", "[user] slammed \his [shoes ? copytext(shoes.name, TRUE, -1) : "foot"] down hard onto")] [target]'s [organ]!</span>") //Devastated lol. No. We want to say that the stomp was powerful or forceful, not that it /wrought devastation/

/datum/unarmed_attack/light_strike
	deal_halloss = 3
	attack_noun = list("tap","light strike")
	attack_verb = list("tapped", "lightly struck")
	damage = 2
	shredding = FALSE
	damage = FALSE
	sharp = FALSE
	edge = FALSE
