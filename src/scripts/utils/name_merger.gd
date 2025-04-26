extends Node

func _ready():
	var json_files: Array[String] = [
		"res://src/scripts/data/names/south_america_batch1.json",
		"res://src/scripts/data/names/south_america_batch2.json",
		"res://src/scripts/data/names/south_america_batch3.json",
		"res://src/scripts/data/names/south_america_batch4.json"
		
	]

	var combined_data: Dictionary = {}

	for file_path in json_files:
		var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var content: String = file.get_as_text()
			var parsed: Variant = JSON.parse_string(content)
			if parsed is Dictionary:
				for country in parsed.keys():
					combined_data[country] = parsed[country]
			else:
				print("⚠️ Failed to parse JSON in:", file_path)
		else:
			print("❌ Could not open file:", file_path)

	# Save to Desktop
	var desktop_path := "/home/pi/Desktop/combined_names.json"
	var output_file: FileAccess = FileAccess.open(desktop_path, FileAccess.WRITE)
	if output_file:
		output_file.store_string(JSON.stringify(combined_data, "\t"))  # Pretty-print
		output_file.close()
		print("✅ Saved to Desktop at:", desktop_path)
	else:
		print("❌ Failed to open Desktop file for writing.")
