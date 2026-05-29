extends Node

var previous_scene_path: String = ""
var current_scene_path: String = ""

# Central Data Storage
var game_state: Enums.GameState = Enums.GameState.MAIN_MENU

# Player Ship
var PlayerShip: CharacterBody3D
var player_is_dead: bool = false
var saved_player_transform: Transform3D = Transform3D.IDENTITY
const PLAYER_SHIP_NODE_NAME := "PlayerShipArchon"
const PLAYER_SHIP_SCENE := preload("res://scenes/Ships/PlayerShip_Archon.tscn")
const MAIN_MENU_SCENE := "res://scenes/Level/Main_Menu.tscn"

# Components
var cargo: CargoData = preload("res://src/data/cargo_res.tres") as CargoData
var station_resources: StationResourcesData = preload("res://src/data/station_resources_res.tres") as StationResourcesData
var weapon_system: WeaponData = preload("res://src/data/weapon_res.tres") as WeaponData

# Pause Menu
var _state_before_pause: Enums.GameState = Enums.GameState.MAIN_MENU
var _pause_menu_instance: Node

func _ready() -> void:
	# Unpauses the game
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Check if the game was just started or
	# if we are coming from a scene_transition

	# If the game just started from nowhere, don't do anything
	if game_state == Enums.GameState.MAIN_MENU and current_scene_path == "" and not PlayerShip:
		return
	if has_savegame():
		load_game()
	else:
		start_new_game()

#region Scene Transition
func start_new_game() -> void:
	print("Starting New Game")
	game_state = Enums.GameState.NEW_GAME

	# Initialize Cargo
	const CARGO_RESOURCE_FILE = preload("res://src/data/cargo_res.tres")
	cargo = CARGO_RESOURCE_FILE.duplicate(true)
	# Initialize Station Resource
	const STATION_RESOURCES_RESOURCE_FILE = preload("res://src/data/station_resources_res.tres")
	station_resources = STATION_RESOURCES_RESOURCE_FILE.duplicate(true)
	# Initialize Weapon System
	const WEAPON_SYSTEM_RESOURCE_FILE = preload("res://src/data/weapon_res.tres")
	weapon_system = WEAPON_SYSTEM_RESOURCE_FILE.duplicate(true)

	const PLAYER_SHIP_ARCHON = preload("res://scenes/Ships/PlayerShip_Archon.tscn")
	GameManager.PlayerShip = PLAYER_SHIP_ARCHON.instantiate() as CharacterBody3D
	PlayerShip.name = PLAYER_SHIP_NODE_NAME

	transition_to("res://scenes/Level/Space.tscn")

func return_to_main_menu() -> void:
	print("Returning to Main Menu")
	player_is_dead = false
	_close_pause_overlay()
	get_tree().paused = false
	InputManager.release_mouse()
	_destroy_player_ship()
	saved_player_transform = Transform3D.IDENTITY
	game_state = Enums.GameState.MAIN_MENU
	transition_to(MAIN_MENU_SCENE)


func halt_simulation_for_player_death() -> void:
	player_is_dead = true


func transition_to(target_path: String) -> void:
	# set global scene variables
	previous_scene_path = get_tree().current_scene.scene_file_path
	current_scene_path = target_path

	print("Changing scene from: " + previous_scene_path)
	print("Changing scene to: " + target_path)

	if game_state != Enums.GameState.NEW_GAME and game_state != Enums.GameState.LOADED:
		_detach_player_ship.call_deferred()
	# Do the scene change when the game feels like being ready
	get_tree().change_scene_to_file.call_deferred(target_path)

func _set_gamestate_enum(path: String) -> void:
	match path:
			"res://scenes/Level/Main_Menu.tscn":
					game_state = Enums.GameState.MAIN_MENU
			"res://scenes/Level/Space.tscn":
					game_state = Enums.GameState.SPACE
			"res://scenes/Level/Station.tscn":
					game_state = Enums.GameState.STATION
			# Else case
			_:
					pass

# Don't destroy the player ship because
# we keep a global reference to it
func _detach_player_ship() -> void:
	if not is_instance_valid(PlayerShip):
		return
	var parent := PlayerShip.get_parent()
	if parent:
		parent.remove_child(PlayerShip)


func _destroy_player_ship() -> void:
	if is_instance_valid(PlayerShip):
		PlayerShip.queue_free()
	PlayerShip = null
#endregion

#region Pause Menu
func open_pause_overlay() -> void:
	if game_state == Enums.GameState.PAUSED:
			return
	if game_state == Enums.GameState.MAIN_MENU:
			return
	_state_before_pause = game_state
	game_state = Enums.GameState.PAUSED
	const PAUSE_MENU_SCENE := preload("res://scenes/UI/Pause_Menu.tscn")
	_pause_menu_instance = PAUSE_MENU_SCENE.instantiate()
	get_tree().root.add_child(_pause_menu_instance)
	get_tree().paused = true
	InputManager.release_mouse()

func close_pause_overlay() -> void:
	if game_state != Enums.GameState.PAUSED:
			return
	game_state = _state_before_pause
	_close_pause_overlay()

func _close_pause_overlay() -> void:
	if is_instance_valid(_pause_menu_instance):
			_pause_menu_instance.queue_free()
			_pause_menu_instance = null
	get_tree().paused = false
	match game_state:
		Enums.GameState.SPACE:
				InputManager.capture_mouse()
		Enums.GameState.STATION:
				InputManager.release_mouse()
		_:
			pass
#endregion

#region Save System
# Savegames
const SAVE_FILE_PATH = "user://saves/savegame.tres"

func save_game() -> void:
	# declare the master holding savegame data
	var master_save = SaveGameData.new()

	# Prepare PlayerShip
	var ship_packed_scene = PackedScene.new()
	var pack_error = ship_packed_scene.pack(PlayerShip)

	if pack_error != OK:
		print("Failed to pack PlayerShip structure. Error: ", pack_error)
		return

	# Only save player position if there is a player (not in Station)
	if is_instance_valid(PlayerShip):
		saved_player_transform = PlayerShip.global_transform

	# assigns what actually is saved
	# see SaveGameData_res.gd for more information
	master_save.player_ship_scene = ship_packed_scene

	# Dynamically assign all other properties from GameManager to SaveGameData
	# I don't want to type every variable manually
	# So instead look at SaveGameData_res.gd for what is available
	# This and the restore function dynamically assign all properties
	var script_properties = master_save.get_script().get_script_property_list()
	for prop in script_properties:
		var prop_name = prop.name
		if prop_name == "player_ship_scene":
			continue

		if prop_name in self:
			master_save.set(prop_name, self.get(prop_name))

	# do the actual saving
	var error = ResourceSaver.save(master_save, SAVE_FILE_PATH)
	if error == OK:
			print("Game saved successfully to: ", SAVE_FILE_PATH)
	else:
			print("Failed to save game. Error code: ", error)

func has_savegame() -> bool:
	# Check if savegame exists
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("No save file discovered.")
		return false
	return true

func load_game() -> void:
	# read save_game() first for more explanation
	game_state = Enums.GameState.LOADED

	# declare the master holding savegame data
	var loaded_data: SaveGameData = ResourceLoader.load(SAVE_FILE_PATH, "", ResourceLoader.CACHE_MODE_REPLACE)
	# in case there loading had an issue, just start anew
	if !loaded_data:
		start_new_game()
		return

	# actual data retrieval, loads what is saved
	# see SaveGameData_res.gd for more information
	# if a ship exists, apply the saved location. Else assume it was already set or whatever
	if loaded_data.get("player_ship_scene") != null:
		GameManager.PlayerShip = loaded_data.player_ship_scene.instantiate() as CharacterBody3D
		PlayerShip.name = PLAYER_SHIP_NODE_NAME

	# Dynamically load all other properties from SaveGameData to GameManager
	var script_properties = loaded_data.get_script().get_script_property_list()
	for property in script_properties:
		var property_name = property.name
		if property_name == "player_ship_scene":
			continue

		if property_name in self:
			# set variables with the name property_name with their values
			self.set(property_name, loaded_data.get(property_name))

	_close_pause_overlay()

	# Because I had issues with this, in case it's missing from saved
	if not current_scene_path:
		transition_to("res://scenes/Level/Space.tscn")
	# default case
	else:
		transition_to(current_scene_path)

	# debugging
	print("Game loaded successfully. Cargo amount: ", cargo.cargo_amount)
	print("Game loaded successfully. Station resources: ", station_resources.resources_amount)

func delete_savegame() -> bool:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var error = DirAccess.remove_absolute(SAVE_FILE_PATH)
		if error == OK:
			return true
	return false

#endregion

const NAME_WORDS: Array = ["buddy", "yarn", "deuce", "tidy", "bleep", "press", "trump", "jot", "attic", "gulf", "april", "yeast", "turf", "henna", "bluff", "karma", "ace", "acid", "ally", "apex", "arch", "arid", "bark", "barn", "beam", "bear", "beta", "bird", "bite", "bolt", "bond", "bone", "book", "boss", "bowl", "brew", "burn", "cabin", "candy", "cargo", "chain", "charm", "chase", "chess", "chief", "chip", "clock", "cloud", "craft", "crane", "crisp", "cross", "crown", "creek", "delta", "dense", "diver", "drift", "drill", "drive", "dwarf", "eager", "eagle", "edge", "elf", "ember", "fable", "faint", "fancy", "feast", "ferry", "fetch", "fiber", "field", "finch", "flame", "flare", "flash", "fleet", "flint", "float", "flock", "flood", "flora", "focus", "forge", "forte", "fox", "frame", "fresh", "frost", "fruit", "ghost", "giant", "gild", "glade", "glass", "globe", "glow", "grace", "grape", "grasp", "grass", "gravy", "grill", "grind", "grove", "guard", "guest", "guild", "haste", "haven", "hazel", "heart", "heron", "honey", "horse", "house", "humor", "ivory", "jewel", "jolly", "judge", "juice", "knack", "knave", "kneel", "knife", "knock", "knoll", "lance", "larch", "laser", "latch", "leafy", "lemon", "level", "light", "lilac", "linen", "liver", "lodge", "logic", "lotus", "lunar", "lunch", "magic", "maple", "march", "match", "medal", "melon", "mercy", "metal", "minty", "misty", "model", "moist", "molar", "moral", "motor", "mount", "mouth", "music", "nexus", "noble", "noise", "north", "notch", "novel", "nurse", "ocean", "olive", "onion", "opera", "orbit", "otter", "ounce", "outer", "oxide", "ozone", "paint", "panel", "panic", "pasta", "patch", "pearl", "penny", "phase", "piano", "pilot", "pinch", "pitch", "pixel", "place", "plain", "plant", "plate", "plaza", "plead", "plume", "plump", "poise", "polar", "porch", "prawn", "pride", "prime", "print", "prize", "probe", "prone", "proof", "prose", "proud", "pulse", "punch", "pupil", "quack", "quail", "quake", "qualm", "quart", "queen", "quest", "quick", "quiet", "quill", "quota", "quote", "radar", "radio", "rainy", "ranch", "range", "rapid", "ratio", "raven", "rayon", "reach", "react", "realm", "rebel", "relic", "repay", "reply", "rhino", "ridge", "rifle", "right", "rigid", "risky", "rival", "river", "robin", "rocky", "roman", "roost", "rough", "round", "route", "rover", "royal", "rugby", "ruler", "rumor", "rusty", "sable", "saint", "salad", "salty", "sandy", "sauce", "scale", "scarf", "scene", "scent", "scope", "score", "scout", "scrap", "screw", "scrub", "seize", "sense", "serum", "serve", "shade", "shaft", "shake", "shale", "shame", "shape", "share", "shark", "sharp", "shear", "sheen", "sheep", "sheet", "shelf", "shell", "shift", "shine", "shire", "shock", "shore", "short", "shout", "shove", "showy", "shrub", "shrug", "siege", "sight", "sigma", "silky", "silly", "sinew", "siren", "sixth", "skate", "skier", "skill", "skirt", "skull", "slack", "slain", "slang", "slant", "slash", "slate", "slave", "sleek", "sleep", "sleet", "slice", "slick", "slide", "slime", "sling", "slope", "sloth", "slump", "smack", "small", "smart", "smash", "smell", "smile", "smoke", "snack", "snail", "snake", "snare", "sneak", "sniff", "snipe", "snore", "snort", "snowy", "snuff", "soapy", "sober", "solar", "solid", "solve", "sonic", "sorry", "sound", "south", "space", "spade", "spare", "spark", "spear", "speck", "speed", "spell", "spend", "spice", "spicy", "spike", "spill", "spine", "spire", "spite", "splat", "split", "spoil", "spoke", "spoon", "sport", "spray", "spree", "sprig", "spunk", "squid", "stack", "staff", "stage", "stain", "stake", "stale", "stall", "stamp", "stand", "stark", "start", "stash", "state", "stave", "stead", "steak", "steal", "steam", "steel", "steep", "steer", "stern", "stick", "stiff", "still", "sting", "stink", "stock", "stoic", "stoke", "stomp", "stone", "stony", "stood", "stool", "stoop", "store", "stork", "storm", "story", "stout", "stove", "strap", "straw", "strip", "strut", "stuck", "study", "stuff", "stump", "stung", "stunk", "stunt", "style", "suave", "sugar", "suite", "sunny", "super", "surge", "sushi", "swamp", "swarm", "swear", "sweat", "sweep", "sweet", "swell", "swift", "swine", "swing", "swirl", "sword", "swore", "sworn", "swung", "synod", "syrup", "tabby", "table", "tacit", "tacky", "taffy", "taint", "taken", "tally", "talon", "tango", "taper", "tapir", "tardy", "tarot", "taste", "taunt", "tawny", "teach", "tease", "teeth", "tempo", "tenor", "tense", "tepee", "terra", "terse", "testy", "thank", "theft", "theme", "thick", "thief", "thigh", "thing", "think", "third", "thorn", "those", "three", "threw", "throb", "throw", "thrum", "thumb", "thump", "tiara", "tiger", "tight", "tilde", "timer", "timid", "tipsy", "titan", "title", "toast", "today", "token", "tonal", "tonic", "tooth", "topaz", "topic", "torch", "torso", "total", "totem", "touch", "tough", "towel", "tower", "toxic", "trace", "track", "tract", "trade", "trail", "train", "trait", "tramp", "trash", "trawl", "tread", "treat", "trend", "triad", "trial", "tribe", "trick", "tried", "trier", "trike", "trill", "trio", "tripe", "trite", "troll", "troop", "trope", "trout", "truce", "truck", "truly", "trunk", "trust", "truth", "tryst", "tulip", "tumor", "tuner", "tunic", "turbo", "tutor", "twang", "tweak", "tweed", "tweet", "twice", "twine", "twirl", "twist", "twixt", "tying", "udder", "ulcer", "ultra", "umbra", "uncle", "under", "undid", "undue", "unfed", "unfit", "unify", "union", "unite", "unity", "unlit", "unmet", "unset", "untie", "until", "unwed", "unzip", "upper", "upset", "urban", "urged", "usage", "usher", "using", "usual", "usurp", "utile", "utter", "vague", "valet", "valid", "valor", "value", "valve", "vapid", "vault", "vaunt", "vegan", "venom", "venue", "verge", "verse", "verso", "verve", "vicar", "video", "vigil", "vigor", "villa", "vinyl", "viola", "viper", "viral", "virus", "visit", "vista", "vital", "vivid", "vixen", "vocal", "vodka", "vogue", "voice", "voila", "volta", "vomit", "voter", "vouch", "vowel", "vying", "wacky", "wafer", "wager", "wagon", "waist", "waive", "waken", "waltz", "warty", "waste", "watch", "water", "waver", "waxen", "weary", "weave", "wedge", "weedy", "weigh", "weird", "welch", "welsh", "whack", "whale", "wharf", "wheat", "wheel", "whelp", "where", "which", "whiff", "while", "whine", "whirl", "whisk", "white", "whole", "whoop", "whore", "whose", "widen", "wider", "widow", "width", "wield", "wight", "wince", "winch", "windy", "wiser", "witch", "witty", "woken", "woman", "women", "world", "worry", "worse", "worst", "worth", "would", "wound", "woven", "wrack", "wrath", "wreak", "wreck", "wrest", "wring", "wrist", "write", "wrong", "wrote", "wrung", "wryly", "xenon", "xerox", "yacht", "yearn", "yeast", "yield", "young", "youth", "yucca", "zappy", "zebra", "zesty", "zonal", "zoned", "zooms"]


func name_manager() -> String:
	var words := NAME_WORDS.duplicate()
	words.shuffle()
	return "%s-%s-%s" % [words[0], words[1], words[2]]


func quit_game() -> void:
	get_tree().quit()
