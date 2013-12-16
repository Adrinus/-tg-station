/obj/item/device/remote_viewer
	name = "Remote Sensor Display"
	desc = "A Remote-Tech sensor control and display device."
	icon_state = "remotescan"
	item_state = "electronic"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	w_class = 1
	var/list/sensors = list()

/obj/item/device/remote_viewer/proc/refresh()
	if(sensors.len == 0)
		return
	for(var/i = 1; i <= sensors.len; i++)
		var/obj/item/device/remote/cursensor = sensors[i]
		cursensor.check()

/obj/item/device/remote_viewer/attack_self(mob/user)
	if(..())
		return
	user.set_machine(src)
	var/dat = "<P ALIGN=Right><a href='byond://?src=\ref[src];close=1'>Close</a></P><br>"
	if(sensors.len == 0)
		dat += "You have no sensors on your list."
	else
		for(var/i = 1; i <= sensors.len; i++)
			var/obj/item/device/remote/cursensor = sensors[i]
			dat += "<br>[cursensor.name]: [cursensor.info]"
	dat += "<br><a href='byond://?src=\ref[src];refresh=1'>Refresh</a>"
	var/datum/browser/popup = new(user, "sensors", "Remote Sensor Display")
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/item/device/remote_viewer/Topic(href, href_list)
	if(..())
		return
	if(href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=sensors")
	else if(href_list["refresh"])
		refresh()

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


/obj/item/device/remote
	name = "Remote Device"
	desc = "A device made to measure things remotely."
	icon_state = "remotesensor"
	item_state = "electronic"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	w_class = 1
	var/info = ""

/obj/item/device/remote/New()
	..()
	check()

/obj/item/device/remote/proc/check()
	..()

/obj/item/device/remote/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/device/remote_viewer))
		var/obj/item/device/remote_viewer/V = I
		if(!(src in V.sensors))
			V.sensors += src
			user.visible_message("<span class='notice'>You link the [src] to the [I].</span>")
		else
			V.sensors -= src
			user.visible_message("<span class='notice'>You un-link the [src] from the [I].</span>")

/obj/item/device/remote/thermometer
	name = "Remote Thermometer"
	desc = "A thermometer with a transmitter, made to measure temperature remotely."
	icon_state = "remotesensor_temp"
	item_state = "electronic"


/obj/item/device/remote/thermometer/check()
	var/turf/location = src.loc
	if (!( istype(location, /turf) ))
		return

	var/datum/gas_mixture/environment = location.return_air()
	info = "Temperature: [round(environment.temperature-T0C)]&deg;C"