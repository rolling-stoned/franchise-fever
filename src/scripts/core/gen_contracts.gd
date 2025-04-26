extends Node

func assign_contract(player_rating: int, position: String) -> Dictionary:
	var min_salary := 0.5  # in millions
	var max_salary := 20.0

	var normalized: float = clamp((player_rating - 40.0) / 60.0, 0.0, 1.0)
	var curved := pow(normalized, 1.5)

	# Positional wage weight (multipliers)
	var position_bias := {
		"gk": 0.85,
		"cb": 0.90,
		"rb": 0.75,
		"lb": 0.75,
		"dm": 0.85,
		"cm": 0.90,
		"am": 1.05,
		"lw": 1.1,
		"rw": 1.1,
		"cf": 1.1,
		"st": 1.15
	}

	var position_weight: float = position_bias.get(position, 1.0)

	var salary: float = lerp(min_salary, max_salary, curved) * position_weight
	salary = round(salary * 100) / 100.0  # round to nearest 10K

	# Contract length logic (high-rated players want shorter deals)
	var min_years := 1
	var max_years := 6
	var length_bias: float = 1.0 - normalized
	var contract_years := randi_range(min_years, max_years - int(length_bias * 3))

	return {
		"salary_million": salary,
		"contract_years": contract_years
	}
