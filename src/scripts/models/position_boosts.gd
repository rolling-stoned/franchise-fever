extends Node

var POSITION_BOOSTS := {
	"gk": {
		"default": {
			"reflexes": 1.3,
			"diving": 1.3,
			"handling": 1.2,
			"distribution": 1,
			"jumping": 1.1,
			"pace": 0.3,
			"control": 0.3,
			"vision": 0.3,
			"agility": 0.2
		},
		"archetypes": {
			"sweeper_keeper": {
				"chance": 0.2,
				"boosts": {
					"distribution": 1.3,
					"pace": 1.1,
					"control": 1,
					"composure": 1,
					"handling": 0.8, # Slight trade-off
					"agility": 0.8
				}
			}
		}
	},

	"cb": {
		"default": {
			"tackling": 1.3,
			"heading": 1.3,
			"strength": 1.2,
			"positioning": 1.2,
			"jumping": 1,
			"passing": 0.4,
			"finishing": 0.2,
			"vision": 0.4,
			"agility": 0.5,
			"control": 0.4
		},
		"archetypes": {
			"ball_playing_cb": {
				"chance": 0.25,
				"boosts": {
					"passing": 1.3,
					"vision": 1.0,
					"control": 0.9,
					"composure": 1,
					"heading": 1.0  # Slight trade-off
				}
			}
		}
	},

	"rb": {
		"default": {
			"pace": 1.2,
			"endurance": 1.2,
			"tackling": 1.0,
			"passing": 1.0,
			"control": 0.9,
			"finishing": 0.3,
			"heading": 0.8
		},
		"archetypes": {
			"wing_back": {
				"chance": 0.15,
				"boosts": {
					"pace": 1.4,
					"passing": 1.1,
					"control": 1.0,
					"finishing": 0.7,
					"tackling": 0.9  # Slight reduction
				}
			}
		}
	},

	"lb": { # same as RB
		"default": {},
		"archetypes": {
			"wing_back": {
				"chance": 0.15,
				"boosts": {
					"pace": 1.4,
					"passing": 1.1,
					"control": 1.0,
					"finishing": 0.7,
					"tackling": 0.9
				}
			}
		}
	},

	"dm": {
		"default": {
			"tackling": 1.3,
			"positioning": 1.2,
			"strength": 1.1,
			"passing": 1,
			"vision": 0.9,
			"finishing": 0.6,
			"pace": 0.7
		},
		"archetypes": {
			"ball_winner": {
				"chance": 0.35,
				"boosts": {
					"tackling": 1.4,
					"strength": 1.3,
					"endurance": 1.2,
					"pace": 1.0,
					"control": 0.8,  # trade-off
					"passing": 0.8
				}
			}
		}
	},

	"cm": {
		"default": {
			"endurance": 1.1,
			"vision": 1.0,
			"passing": 1.0,
			"control": 1.0
		},
		"archetypes": {
			"box_to_box": {
				"chance": 0.3,
				"boosts": {
					"endurance": 1.3,
					"strength": 1.2,
					"finishing": 1.1,
					"vision": 0.8,  # trade-off
					"composure": 0.9
				}
			}
		}
	},

	"am": {
		"default": {
			"vision": 1.2,
			"passing": 1.2,
			"control": 1.1,
			"finishing": 1.0,
			"tackling": 0.3,
			"strength": 0.5,
			"heading": 0.3
		},
		"archetypes": {
			"playmaker": {
				"chance": 0.3,
				"boosts": {
					"vision": 1.4,
					"passing": 1.3,
					"control": 1.2,
					"tackling": 0.2,
					"strength": 0.4
				}
			}
		}
	},

	"lw": {
		"default": {
			"pace": 1.4,
			"control": 1.2,
			"agility": 1.2,
			"passing": 1.0,
			"tackling": 0.4,
			"heading": 0.3,
			"strength": 0.5
		}
	},

	"rw": { "default": {} }, # same as LW

	"cf": {
		"default": {
			"finishing": 1.2,
			"positioning": 0.9,
			"control": 1.1,
			"heading": 1.0,
			"passing": 1.0,
			"tackling": 0.4
		},
		"archetypes": {
			"target_man": {
				"chance": 0.25,
				"boosts": {
					"heading": 1.4,
					"strength": 1.3,
					"jumping": 1.2,
					"finishing": 1.1,
					"passing": 0.8,
					"pace": 0.8
				}
			}
		}
	},

	"st": {
		"default": {
			"finishing": 1.4,
			"positioning": 1.1,
			"pace": 1,
			"control": 1.1,
			"vision": 0.8,
			"tackling": 0.3
		},
		"archetypes": {
			"poacher": {
				"chance": 0.35,
				"boosts": {
					"finishing": 1.1,
					"positioning": 1.3,
					"pace": 1.4,
					"control": 0.8,
					"vision": 1.1,
					"passing": 0.6,
					"strength": 0.8
				}
			}
		}
	}
}

func get_position_boosts(position: String) -> Dictionary:
	if not POSITION_BOOSTS.has(position):
		print("⚠️ No boost data for position:", position)
		return {}

	var base_boosts: Dictionary = POSITION_BOOSTS[position].get("default", {})
	var final_boosts: Dictionary = base_boosts.duplicate()

	# Archetype logic
	if POSITION_BOOSTS[position].has("archetypes"):
		for archetype_key: String in POSITION_BOOSTS[position]["archetypes"].keys():
			var archetype: Dictionary = POSITION_BOOSTS[position]["archetypes"][archetype_key]
			var chance: float = archetype.get("chance", 0.0)

			if randf() <= chance:
				print("🎯 Archetype applied:", archetype_key, "→", position)
				var boosts: Dictionary = archetype.get("boosts", {})
				for attr: String in boosts:
					final_boosts[attr] = boosts[attr]
				break

	return final_boosts
