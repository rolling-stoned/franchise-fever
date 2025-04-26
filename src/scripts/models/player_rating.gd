extends Node

# OVR weightings by position
var POSITION_OVR_WEIGHTS := {
	"gk": {
		"reflexes": 0.2,
		"diving": 0.2,
		"handling": 0.2,
		"distribution": 0.1,
		"jumping": 0.1,
		"decision_making": 0.2
	},
	"cb": {
		"tackling": 0.2,
		"heading": 0.15,
		"positioning": 0.3,
		"strength": 0.15,
		"jumping": 0.1,
		"decision_making": 0.1
	},
	"rb": {
		"pace": 0.15,
		"endurance": 0.2,
		"tackling": 0.25,
		"passing": 0.1,
		"control": 0.1,
		"positioning": 0.2
	},
	"lb": {},  # same as rb
	"dm": {
		"tackling": 0.25,
		"positioning": 0.2,
		"strength": 0.15,
		"passing": 0.15,
		"vision": 0.15,
		"control": 0.1
	},
	"cm": {
		"passing": 0.2,
		"vision": 0.2,
		"endurance": 0.2,
		"control": 0.2,
		"positioning": 0.2
	},
	"am": {
		"vision": 0.25,
		"passing": 0.25,
		"control": 0.3,
		"finishing": 0.1,
		"composure": 0.1,
	},
	"lw": {
		"pace": 0.25,
		"control": 0.25,
		"passing": 0.15,
		"finishing": 0.1,
		"agility": 0.25
	},
	"rw": {},  # same as lw
	"cf": {
		"finishing": 0.25,
		"positioning": 0.1,
		"control": 0.15,
		"heading": 0.15,
		"passing": 0.15,
		"strength": 0.2
	},
	"st": {
		"finishing": 0.35,
		"positioning": 0.1,
		"pace": 0.2,
		"control": 0.1,
		"composure": 0.25
	}
}

func calculate_ovr_and_pot(position: String, ratings: Dictionary, age: int) -> Dictionary:
	# Handle LB/RB etc. fallback
	if not POSITION_OVR_WEIGHTS.has(position) or POSITION_OVR_WEIGHTS[position].is_empty():
		if position == "lb" or position == "rb":
			position = "rb"
		elif position == "rw" or position == "lw":
			position = "lw"

	var weights: Dictionary = POSITION_OVR_WEIGHTS.get(position, {})
	var total_weight: float = 0.0
	var weighted_sum: float = 0.0

	for attr: String in weights.keys():
		var weight: float = weights[attr]
		var value: int = ratings.get(attr, 50)
		weighted_sum += float(value) * weight
		total_weight += weight

	var ovr: int = int(clamp(weighted_sum / max(total_weight, 1.0), 40, 100))

	# Generate POT based on age
	var pot: int = ovr
	if age <= 21:
		pot += randi_range(5, 20)
	elif age <= 25:
		pot += randi_range(2, 15)
	elif age <= 30:
		pot += randi_range(0, 10)
	elif age <= 34:
		pot += randi_range(-2, 5)
	else:
		pot += randi_range(-5, 3)

	pot = int(clamp(pot, ovr, 100))

	return {
		"ovr": ovr,
		"pot": pot
	}
	
