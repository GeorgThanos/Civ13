// ported from /tg/station - Kachnov
/process/ping_track
	var/avg = 0
	var/client_ckey_check[1000]
	var/pingtime = 0
/process/ping_track/setup()
	name = "Ping Tracking"
	schedule_interval = 0.5 SECONDS
	fires_at_gamestates = list(GAME_STATE_PREGAME, GAME_STATE_SETTING_UP, GAME_STATE_PLAYING, GAME_STATE_FINISHED)
	priority = PROCESS_PRIORITY_LOW
	processes.ping_track = src

/process/ping_track/fire()
	if (pingtime >= 99999)
		pingtime = 0
	pingtime += 50
	if (!current_list.len)
		return

	avg = 0
	var/clients_checked = 0

	while (current_list.len)

		var/client/C = current_list[current_list.len]
		--current_list.len

		if (!C)
			continue

		// this nasty code if else block fixes the "Unrecognized or inaccessible verb: .update_ping" error - Kachnov
		if (!hascall(C, ".update_ping")) // BYOND treats "update_ping" and ".update_ping" the same here, for reference
			continue
		if (!client_ckey_check[C.ckey])
			client_ckey_check[C.ckey] = pingtime+50
			continue
		if (pingtime < client_ckey_check[C.ckey])
			continue

		winset(C, null, "command=.update_ping+[pingtime+world.tick_lag*world.tick_usage/100]")
		avg += C.last_ping
		++clients_checked

		PROCESS_TICK_CHECK

	if (clients_checked)
		avg /= clients_checked

/process/ping_track/reset_current_list()
	PROCESS_USE_FASTEST_LIST(clients)