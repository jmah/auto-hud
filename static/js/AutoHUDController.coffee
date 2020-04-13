window.AutoHUDController = {
	useTestWeatherData: false
	watchers: {}

	init: ->
		for section in C.sections
			@makeWatcher(section)

	# start a timer for each section which has one. each section needs:
	# - a function called sectionGetter, where `section` is the section name
	# - an entry in constants.py called sectionPollTime, where `section` is the
	#   section name
	makeWatcher: (section) ->
		return if !section?

		getter = @["#{section}Getter"]
		return if !getter? || !_.isFunction(getter)

		pollTime = C["#{section}PollTime"]
		return if !pollTime

		# set the intial state
		getter.call(@)

		# set an interval
		@watchers[section] = setInterval(=>
			getter.call(@)
		, pollTime)


	# time and date
	#############################################################################

	timeGetter: ->
		d = new Date()
		month = C.months[d.getMonth()]

		@model.set({
			time: {
				hours: @padZeroes(d.getHours())
				minutes: @padZeroes(d.getMinutes())
				seconds: @padZeroes(d.getSeconds())
			}
			date: {
				month: month
				day: d.getDate()
				year: d.getFullYear()
			}
		})

	# 5 => "05"
	padZeroes: (number) ->
		if number < 10
			number = "0#{number}"

		return number


	# birthdays
	#############################################################################

	birthdaysGetter: ->
		$.ajax("/birthdays", {
			type: "GET"
			success: (data) =>
				@model.set(data)
		})


	# menu
	#############################################################################

	menuGetter: ->
		$.ajax("/menu", {
			type: "GET"
			success: (data) =>
				@model.set(data)
		})


	# chores
	#############################################################################

	choresGetter: ->
		$.ajax("/chores", {
			type: "GET"
			success: (data) =>
				@model.set(data)
		})


	# weather
	#############################################################################

	weatherGetter: ->
		if @useTestWeatherData
			@formatWeather(weatherData)
			return

		url = "#{C.weatherUrl}#{@model.get("forecastioApiKey")}/#{@model.get("forecastioLatLong")}"

		# to use test data, comment out the `getJSON` and add:
		# @formatWeather(weatherData)
		$.getJSON("#{url}?callback=?", (data) =>
			@formatWeather("weather", data, @model.get("forecastioTitle"))
		)

	weather2Getter: ->
		if @useTestWeatherData
			@formatWeather(weatherData)
			return

		url = "#{C.weatherUrl}#{@model.get("forecastioApiKey")}/#{@model.get("forecastioLatLong2")}"

		# to use test data, comment out the `getJSON` and add:
		# @formatWeather(weatherData)
		$.getJSON("#{url}?callback=?", (data) =>
			@formatWeather("weather2", data, @model.get("forecastioTitle2"))
		)

	###
	Format weather data from forecast.io into something a little more simple:
	current: 75º, rain
	today: 65º-77º, rain in the afternoon
	###
	formatWeather: (key, data, title) ->
		weather = {
			title: title
			current: {}
			preview: {}
		}

		weather.current.temperature = @formatTemperature(data.currently.apparentTemperature)
		weather.current.summary = data.currently.summary
		weather.current.icon = data.currently.icon

		# determine if we want to show a preview for today (if it's the morning)
		# or tomorrow (if it's the afternoon)
		if new Date().getHours() < 16
			dayIndex = 0
		else
			dayIndex = 1

		preview = data.daily.data[dayIndex]
		weather.preview = @formatDayWeather(preview, dayIndex)

		updates = {}
		updates[key] = weather
		@model.set(updates)

	formatTemperature: (temperature) ->
		displayF = Math.round(temperature)
		celcius = (temperature - 32) * 5 / 9
		displayC = Math.round(celcius)

		return """
			<span class="degree">#{displayF}</span>
			<span class="degree-symbol">ºF</span>
			/
			<span class="degree">#{displayC}</span>
			<span class="degree-symbol">ºC</span>
		"""

	formatDayWeather: (day, tomorrow = false)->
		return {
			low: @formatTemperature(day.temperatureMin)
			high: @formatTemperature(day.temperatureMax)
			summary: day.summary.replace(/\.$/, "")
			icon: day.icon
			tomorrow: tomorrow
			precip: Math.round(day.precipProbability * 100)
		}


	# subway
	#############################################################################

	subwayGetter: ->
		d = new Date()

		# if the constants have a subway day range, check that we qualify
		if C.subwayDayRange?
			day = C.daysJs[d.getDay()]

			if C.subwayDayRange.indexOf(day) < 0
				return

		# if the constants have a subway time range, check that we qualify
		if C.subwayTimeRange? && C.subwayTimeRange.length == 2
			hour = d.getHours()

			if hour < C.subwayTimeRange[0] || hour >= C.subwayTimeRange[1]
				@model.set({subway: null})
				return

		$.ajax(C.subwayUrl, {
			type: "GET"
			dataType: "xml"
			success: (data) =>
				@parseSubway(data)
		})

	parseSubway: (data) ->
		subwayStatus = {}

		return if !data || !$(data).length

		for line in $(data).find("service subway line")
			line = $(line)
			name = line.find("name")
			status = line.find("status")

			# bail if there's a missing element
			continue if !name.length || !status.length

			name = name.text()
			status = status.text()

			# bail if we don't care about this subway line
			continue if !C.subwayLinesToShow[name]

			subwayStatus[name] = {
				lines: @formatLines(name)
				status: status
			}

		@model.set({subway: subwayStatus})

	formatLines: (lines) ->
		res = []

		for line in lines.split("")
			res.push("""
				<span class="hud-section-subway-line">#{line}</span>
			""")

		return res.join("")
}
