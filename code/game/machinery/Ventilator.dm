/obj/machinery/ventilator
	name = "ventilator"
	desc = "A machine that provides mechanical ventilation to a patient."
	icon = 'icons/obj/medical.dmi'
	icon_state = "fak-basic"
	machine_name = "ventilator"
	machine_desc = "A machine that provides mechanical ventilation to a patient. It is used to assist or replace spontaneous breathing."

	density = TRUE
	throwpass = TRUE
	layer = BELOW_OBJ_LAYER
	core_skill = SKILL_MEDICAL
	obj_flags = OBJ_FLAG_ANCHORABLE

	health_max = 150
	health_min_damage = 5
	idle_power_usage = 10
	active_power_usage = 300
	construct_state = /singleton/machine_construction/default/panel_closed
	uncreated_component_parts = null

	var/obj/machinery/optable/connected_optable = null
	var/mob/living/carbon/human/connected_victim = null
	var/obj/item/clothing/mask/breath/tube/connected_tube = null

/obj/machinery/ventilator/Initialize()
	. = ..()

/obj/machinery/ventilator/Destroy()
	. = ..()
	if (connected_optable)
		connected_optable.connected_vent = null
		connected_optable = null
	if (connected_tube)
		connected_tube.connected_vent = null
		connected_tube = null
	connected_victim = null

/obj/machinery/ventilator/examine(mob/user)
	. = ..()

/obj/machinery/ventilator/on_update_icon()
	. = ..()

/obj/machinery/ventilator/RefreshParts()
	. = ..()

/obj/machinery/ventilator/on_death()
	. = ..()

/obj/machinery/ventilator/on_revive()
	. = ..()

/obj/machinery/ventilator/Process()
	. = ..()

/obj/machinery/ventilator/attack_hand(mob/living/user)
	if ((. = ..()))
		return

/obj/machinery/ventilator/MouseDrop(over_object)
	if (!CanMouseDrop(over_object))
		return
	if (istype(over_object, /obj/machinery/optable))
		update_optable(over_object, usr)
	if (istype(over_object, /mob/living/carbon/human))
		update_victim(over_object, usr)

/obj/machinery/ventilator/Move()
	. = ..()
	if (connected_optable && get_dist(src, connected_optable) > 1)
		visible_message(SPAN_NOTICE("\The [src] is pulled away from \the [connected_optable]."))
		connected_optable.connected_vent = null
		connected_optable = null
	if (connected_victim && get_dist(src, connected_victim) > 1)
		if (istype(connected_tube, /obj/item/clothing/mask/breath/tube))
			visible_message(SPAN_WARNING("\The [src] is violently pulled away from \the [connected_victim], pulling \the [connected_tube] out of their mouth."))
			connected_victim.custom_pain("\The [connected_tube] is violently pulled out of your own throat!", 90, TRUE)
			connected_victim.apply_damage(rand(15, 30), DAMAGE_BRUTE, BP_HEAD, armor_pen = 100)
		else
			visible_message(SPAN_NOTICE("\The [connected_tube] is pulled off of \the [connected_victim]."))
		connected_victim = null
		connected_tube.connected_vent = null
		connected_tube = null

/obj/machinery/ventilator/proc/update_optable(obj/machinery/optable/new_table, user)
	if (!istype(new_table))
		return
	if (connected_optable && connected_optable != new_table)
		to_chat(user, SPAN_WARNING("\The [src] is already connected to a different [connected_optable]. Disconnect it first."))
		return
	if (new_table.connected_vent && new_table.connected_vent != src)
		to_chat(user, SPAN_WARNING("\The [new_table] is already connected to a different [new_table.connected_vent]. You cannot connect more than one."))
		return
	if (connected_optable == new_table)
		visible_message(SPAN_NOTICE("\The [src] is disconnected from \the [connected_optable]."))
		connected_optable.connected_vent = null
		connected_optable = null
		anchored = FALSE
		return
	if (!connected_optable)
		connected_optable = new_table
		connected_optable.connected_vent = src
		anchored = TRUE
		visible_message(SPAN_NOTICE("\The [src] is connected to \the [connected_optable]."))
		return

/obj/machinery/ventilator/proc/update_victim(mob/living/carbon/human/victim, user)
	if (!istype(victim))
		return
	if (connected_victim && connected_victim != victim)
		to_chat(user, SPAN_WARNING("\The [src] is already connected to [connected_victim]. Disconnect them first."))
		return
	if (!victim.wear_mask || !(victim.wear_mask.type in typesof(/obj/item/clothing/mask/breath)))
		to_chat(user, SPAN_WARNING("\The [victim] needs to be wearing a proper mask to be connected to \the [src]."))
		return
	var/obj/item/clothing/mask/breath/worn_mask = victim.wear_mask //Type check already done at this point.
	if (worn_mask.connected_vent && worn_mask.connected_vent != src)
		to_chat(user, SPAN_WARNING("\The [victim]'s \the [worn_mask] is already connected to another ventilator."))
		return
	if (connected_victim == victim)
		visible_message(SPAN_NOTICE("\The [victim]'s \the [worn_mask] is disconnected from \the [src]."))
		worn_mask.connected_vent = null
		connected_tube = null
		connected_victim = null
		return
	if (!connected_victim)
		worn_mask.connected_vent = src
		connected_tube = worn_mask
		connected_victim = victim
		visible_message(SPAN_NOTICE("\The [victim]'s \the [worn_mask] is connected to \the [src]."))

/*Immediate to-do list:
Breathing code; obviously.
add code to drop tube when pulled out violently.
Maybe switch move() to process()?
Add codex entry
Add wires
Way to repair it
Make it work with all ITEM_FLAG_AIRTIGHT as a BiPAP; with a tube perfectly.
Make sure you can't remove a connected mask; need to make sure not to lose track.
2-way click/drag to hook someone to a vent?

Reminder: Don't forget to use_sanity_check; maybe on update_Victim
Don't forget to move this somewhere else later.
*/
