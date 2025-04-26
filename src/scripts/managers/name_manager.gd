extends Node

var name_data: Dictionary = {}



func _ready():
	randomize()
	load_name_data()
	print("✅ NameManager ready. Loaded", name_data.size(), "countries.")

	# Auto-generate and save players across 20 teams
	var teams: Dictionary = generate_all_teams()
	save_teams_to_file(teams, "/home/pi/Desktop/generated_teams.json")



func load_name_data():
	var path := "/home/pi/Desktop/combined_names.json"
	var file := FileAccess.open(path, FileAccess.READ)
	if file:
		var content: String = file.get_as_text()
		var parsed: Variant = JSON.parse_string(content)
		if parsed is Dictionary:
			name_data = parsed
		else:
			print("❌ Failed to parse name data.")
	else:
		print("❌ Could not open:", path)



func generate_realistic_age() -> int:
	var r := randf()
	if r < 0.15:
		return randi_range(21, 24)  # Young
	elif r < 0.85:
		return randi_range(25, 33)  # Prime
	else:
		return randi_range(34, 39)  # Older



func generate_random_player() -> Dictionary:
	if name_data.is_empty():
		return {}

	# Country and name
	var countries: PackedStringArray = name_data.keys()
	var country: String = countries[randi() % countries.size()]
	var first_names: Array = name_data[country]["first_names"]
	var last_names: Array = name_data[country]["last_names"]
	var first_name: String = first_names[randi() % first_names.size()]
	var last_name: String = last_names[randi() % last_names.size()]

	# Age
	var age: int = generate_realistic_age()

	# Position
	var positions: Array = ["gk", "cb", "rb", "lb", "dm", "cm", "am", "lw", "rw", "cf", "st"]
	var position: String = positions[randi() % positions.size()]

	# Strong foot
	var foot_roll := randf()
	var strong_foot: String = "right"
	if foot_roll < 0.05:
		strong_foot = "both"
	elif foot_roll < 0.30:
		strong_foot = "left"
	if position == "rb" and strong_foot == "left":
		strong_foot = "right"  # No left-footed RBs

	# Height and weight (bias for gk/cb)
	var height: int
	match position:
		"gk": height = randi_range(188, 200)
		"cb": height = randi_range(183, 195)
		"cf", "st": height = randi_range(175, 190)
		"rb", "lb", "dm": height = randi_range(170, 185)
		_: height = randi_range(165, 185)
	var weight: int = int(height * randf_range(0.40, 0.48))

	# Get multipliers
	var multipliers: Dictionary = PositionBoosts.get_position_boosts(position)

	# Define global attributes (for all players)
	var global_attributes: Array = [
		"pace", "strength", "agility", "jumping", "endurance",
		"vision", "positioning", "composure", "decision_making", "durability"
	]

	# Define technical attributes based on position
	var technical_attributes: Array
	if position == "gk":
		technical_attributes = [
			"reflexes", "diving", "handling", "distribution", "control"
	]
	else:
		technical_attributes = [
			"passing", "tackling", "heading", "finishing", "control"
	]

	# Combine global and technical attributes
	var all_attributes: Array = global_attributes + technical_attributes
	
	# Generate ratings
	var ratings: Dictionary = {}
	for attr: String in all_attributes:
		var base := int(clamp(randfn(60, 15), 0, 100))
		var factor: float = multipliers.get(attr, 1.0)
		var final: int = int(clamp(base * factor, 0, 100))
		ratings[attr] = final

	# OVR + POT
	var rating_summary: Dictionary = PlayerRating.calculate_ovr_and_pot(position, ratings, age)
	var ovr: int = rating_summary["ovr"]
	var pot: int = rating_summary["pot"]
	
	# Contract
	var contract: Dictionary = GenContracts.assign_contract(ovr, position)
	
	# Ensure potential doesn't exceed overall for players age 27 or older
	if age >= 27:
		pot = min(pot, ovr) # Capped potential to overall

	# Final player object
	return {
		"name": first_name + " " + last_name,
		"country": country,
		"age": age,
		"position": position,
		"height": height,
		"weight": weight,
		"strong_foot": strong_foot,
		"ovr": ovr,
		"pot": pot,
		"ratings": ratings,
		"contract": contract
	}



func generate_balanced_team() -> Array:
	var squad: Array = []

	# Define position groups and rules
	var position_requirements := {
		"gk": {
			"min": 2,
			"max": 4,
			"positions": ["gk"]
		},
		"def": {
			"min": 5,
			"max": 9,
			"positions": ["cb", "rb", "lb"]
		},
		"mid": {
			"min": 5,
			"max": 9,
			"positions": ["dm", "cm", "am"]
		},
		"wing": {
			"min": 3,
			"max": 7,
			"positions": ["lw", "rw"]
		},
		"fwd": {
			"min": 3,
			"max": 5,
			"positions": ["cf", "st"]
		}
	}

	# Count how many we’ve added per group
	var current_counts := {
		"gk": 0,
		"def": 0,
		"mid": 0,
		"wing": 0,
		"fwd": 0
	}

	# Fill minimum required players per group
	for group in position_requirements.keys():
		var group_data = position_requirements[group]
		while current_counts[group] < group_data["min"]:
			var player = generate_random_player() 
			while not group_data["positions"].has(player["position"]):
				player = generate_random_player()
			squad.append(player)
			current_counts[group] += 1

	# Fill remaining players (to 25), while respecting max limits
	while squad.size() < 25:
		var player = generate_random_player()

		# Determine which group they belong to
		var group := ""
		for g in position_requirements.keys():
			if position_requirements[g]["positions"].has(player["position"]):
				group = g
				break

		# If they belong to a group and haven’t exceeded that group’s max, add them
		if group != "" and current_counts[group] < position_requirements[group]["max"]:
			squad.append(player)
			current_counts[group] += 1
		else:
			# If group is full or unknown, just keep trying until valid
			continue

	return squad



func generate_all_teams() -> Dictionary:
	var team_names: Array[String] = [
		"Asuncion Gazelles",
		"Bogota Conflict",
		"Buenos Aires Stallions",
		"Brasilia Redeemers",
		"Caracas Essentials",
		"Guatemala City Gunners",
		"Havana Howlers",
		"Kingston Collective",
		"Sucre Flamingos",
		"Lima Anacondas",
		"Managua Outlanders",
		"Mexico City Vaqueros",
		"Montevideo Enforcers",
		"Panama City Prodigals",
		"Santiago Statesmen",
		"Santo Domingo Shakedown",
		"San Jose Silverbacks",
		"San Salvador Vanquish",
		"Tegucigalpa Drift",
		"Quito Connoisseurs"
	]

	var all_teams: Dictionary = {}

	for team_name in team_names:
		all_teams[team_name] = generate_balanced_team()

	return all_teams




func save_teams_to_file(teams: Dictionary, path: String):
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(teams, "\t"))  # Pretty-printed JSON
		file.close()
		print("✅ Teams saved to:", path)
	else:
		print("❌ Failed to save teams to file.")
