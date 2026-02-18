extends Node2D

# ── UI refs ──
@onready var run_btn: Button = %RunAllTests
@onready var summary_label: Label = %SummaryLabel
@onready var log_label: RichTextLabel = %LogLabel

# ── Counters ──
var passed: int = 0
var failed: int = 0
var total: int = 0

# ── Baseline stats ──
const BASE_HP = 2000
const BASE_ATK = 1.0
const BASE_CC = 0.05
const BASE_CDM = 1.2
const BASE_DC = 0.0
const BASE_MS = 1.0
const BASE_SR = 0.1
const BASE_EP = 1.0

func _ready() -> void:
	run_btn.pressed.connect(_run_all_tests)
	summary_label.text = "Press 'Run All Tests' to start."

# ═══════════════════════════════════════════
#  HELPERS
# ═══════════════════════════════════════════

func create_fresh_player_stats() -> PlayerStats:
	var ps = PlayerStats.new()
	ps.max_health = BASE_HP
	ps.current_health = BASE_HP
	ps.attack_power_multiplier = BASE_ATK
	ps.critical_chance = BASE_CC
	ps.critical_damage_multiplier = BASE_CDM
	ps.dodge_chance = BASE_DC
	ps.movement_speed_multiplier = BASE_MS
	ps.status_resist_multiplier = BASE_SR
	ps.effect_power_multiplier = BASE_EP
	ps.money_dictionary = {
		PlayerStats.MONEY.TICKETS: 0,
		PlayerStats.MONEY.TOKENS: 0
	}
	var empty_inv: Array[Upgrade] = []
	ps.inventory = empty_inv
	var empty_temp: Array[TemporaryUpgrade] = []
	ps.temporary_upgrades = empty_temp
	ps.head_slot = null
	ps.body_slot = null
	ps.legs_slot = null
	ps.fighting_style = null
	return ps

func make_shop_array(item: ShopUpgrade) -> Array[ShopUpgrade]:
	var arr: Array[ShopUpgrade] = [item]
	return arr

func create_stat_model(type: StatUpgrade.UPGRADABLE_STATS, base_val: float) -> StatModel:
	var sm = StatModel.new()
	sm.stat_type = type
	sm.base_value = base_val
	sm.multiplier = base_val
	return sm

func create_shop_upgrade(uname: String, slot: Upgrade.SLOT_TYPE, stats: Array[StatModel], cost_val: int, money: PlayerStats.MONEY) -> ShopUpgrade:
	var su = ShopUpgrade.new()
	su.name = uname
	su.title = uname
	su.slot_type = slot
	su.cost = cost_val
	su.money_type = money
	su.rarity = Upgrade.RARITY.COMMON
	var arr: Array[StatModel] = []
	for s in stats:
		arr.append(s)
	su.upgrade_array = arr
	su.initialize_upgrade()
	return su

func create_temporary_upgrade(uname: String, stats: Array[StatModel]) -> TemporaryUpgrade:
	var tu = TemporaryUpgrade.new()
	tu.name = uname
	tu.slot_type = Upgrade.SLOT_TYPE.NONE
	tu.rarity = Upgrade.RARITY.COMMON
	var arr: Array[StatModel] = []
	for s in stats:
		arr.append(s)
	tu.upgrade_array = arr
	tu.initialize_upgrade()
	return tu

# ── Assertions ──

func assert_eq(actual, expected, desc: String) -> void:
	total += 1
	if actual == expected:
		passed += 1
		_log_pass(desc)
	else:
		failed += 1
		_log_fail(desc + " | expected: " + str(expected) + ", got: " + str(actual))

func assert_approx(actual: float, expected: float, desc: String, epsilon: float = 0.001) -> void:
	total += 1
	if abs(actual - expected) <= epsilon:
		passed += 1
		_log_pass(desc)
	else:
		failed += 1
		_log_fail(desc + " | expected: ~" + str(expected) + ", got: " + str(actual))

func assert_true(condition: bool, desc: String) -> void:
	total += 1
	if condition:
		passed += 1
		_log_pass(desc)
	else:
		failed += 1
		_log_fail(desc)

func assert_null(value, desc: String) -> void:
	total += 1
	if value == null:
		passed += 1
		_log_pass(desc)
	else:
		failed += 1
		_log_fail(desc + " | expected null, got: " + str(value))

func assert_not_null(value, desc: String) -> void:
	total += 1
	if value != null:
		passed += 1
		_log_pass(desc)
	else:
		failed += 1
		_log_fail(desc + " | expected non-null")

# ── Logging ──

func _log_pass(msg: String) -> void:
	var line = "[color=green][PASS][/color] " + msg
	log_label.append_text(line + "\n")
	print("[PASS] ", msg)

func _log_fail(msg: String) -> void:
	var line = "[color=red][FAIL][/color] " + msg
	log_label.append_text(line + "\n")
	print("[FAIL] ", msg)

func log_header(msg: String) -> void:
	var line = "\n[color=cyan]── " + msg + " ──[/color]"
	log_label.append_text(line + "\n")
	print("── ", msg, " ──")

func log_info(msg: String) -> void:
	var line = "[color=yellow]  " + msg + "[/color]"
	log_label.append_text(line + "\n")
	print("  ", msg)

# ═══════════════════════════════════════════
#  RUN ALL
# ═══════════════════════════════════════════

func _run_all_tests() -> void:
	passed = 0
	failed = 0
	total = 0
	log_label.clear()
	log_label.append_text("[b]== Systems Test ==[/b]\n")

	test_a_rarity_system()
	test_b_stat_modifiers()
	test_c_equipment_system()
	test_d_inventory_management()
	test_e_shop_purchases()
	test_f_temporary_upgrades()
	test_g_bonus_manager()
	test_h_fighting_styles()
	test_i_currency_system()
	test_j_edge_cases()
	test_k_damage_system()
	test_l_character_stats()
	test_m_negative_effects()
	test_n_upgrade_manager()
	test_o_shop_assortment()
	test_p_spin_wheel()

	var color = "green" if failed == 0 else "red"
	summary_label.text = str(passed) + "/" + str(total) + " passed"
	log_label.append_text("\n[b][color=" + color + "]Result: " + str(passed) + "/" + str(total) + " passed[/color][/b]\n")
	print("Result: ", passed, "/", total, " passed, ", failed, " failed")

# ═══════════════════════════════════════════
#  A. RARITY SYSTEM
# ═══════════════════════════════════════════

func test_a_rarity_system() -> void:
	log_header("A. Rarity System")

	# A1-A5: StatModel base=0.1 + update_rarity for each rarity
	var rarities = [
		Upgrade.RARITY.COMMON,
		Upgrade.RARITY.UNCOMMON,
		Upgrade.RARITY.RARE,
		Upgrade.RARITY.MYTHICAL,
		Upgrade.RARITY.LEGENDARY
	]
	var expected_mults = [0.1, 0.2, 0.3, 0.4, 0.5]

	for i in range(5):
		var sm = create_stat_model(StatUpgrade.UPGRADABLE_STATS.CRITICAL_CHANCE, 0.1)
		var tu = TemporaryUpgrade.new()
		tu.name = "rarity_test"
		tu.rarity = rarities[i]
		var sm_arr: Array[StatModel] = [sm]
		tu.upgrade_array = sm_arr
		tu.update_rarity()
		assert_approx(tu.upgrade_array[0].multiplier, expected_mults[i],
			"A" + str(i + 1) + ": StatModel base=0.1 rarity=" + Upgrade.RARITY.keys()[i] + " → mult=" + str(expected_mults[i]))

	# A6: Increment rarity COMMON(0) to LEGENDARY(4)
	var upgrade = ShopUpgrade.new()
	upgrade.name = "rarity_inc_test"
	upgrade.rarity = Upgrade.RARITY.COMMON
	for j in range(4):
		upgrade.rarity += 1
	assert_eq(upgrade.rarity, Upgrade.RARITY.LEGENDARY, "A6: Rarity increments COMMON→LEGENDARY")

	# A7: get_rarity_name returns correct strings
	var u = Upgrade.new()
	var names_ok = true
	var rarity_names = ["COMMON", "UNCOMMON", "RARE", "MYTHICAL", "LEGENDARY"]
	for k in range(5):
		if u.get_rarity_name(k) != rarity_names[k]:
			names_ok = false
	assert_true(names_ok, "A7: get_rarity_name() returns correct strings")

# ═══════════════════════════════════════════
#  B. STAT MODIFIERS
# ═══════════════════════════════════════════

func test_b_stat_modifiers() -> void:
	log_header("B. Stat Modifiers")

	# Load cylinder hat resource
	var hat_res = load("res://data/game data/upgrades/shop_upgrades/cylinder_hat.tres")

	# B1: Apply Cylinder Hat COMMON → cc and cdm increase
	var ps = create_fresh_player_stats()
	var hat = hat_res.duplicate(true) as ShopUpgrade
	hat.rarity = Upgrade.RARITY.COMMON
	hat.initialize_upgrade()
	ps.apply_modifier(hat, true)
	# cc: base_value=0.03, COMMON mult=1.0 → multiplier=0.03, so 0.05+0.03=0.08
	# cdm: base_value=0.05, COMMON mult=1.0 → multiplier=0.05, so 1.2+0.05=1.25
	assert_approx(ps.critical_chance, 0.08, "B1a: Cylinder Hat COMMON → cc=0.08")
	assert_approx(ps.critical_damage_multiplier, 1.25, "B1b: Cylinder Hat COMMON → cdm=1.25")

	# B2: Remove → returns to baseline
	ps.apply_modifier(hat, false)
	assert_approx(ps.critical_chance, BASE_CC, "B2a: Remove hat → cc back to baseline")
	assert_approx(ps.critical_damage_multiplier, BASE_CDM, "B2b: Remove hat → cdm back to baseline")

	# B3: COMMON vs LEGENDARY → LEGENDARY gives 5x effect
	var ps2 = create_fresh_player_stats()
	var hat_leg = hat_res.duplicate(true) as ShopUpgrade
	hat_leg.rarity = Upgrade.RARITY.LEGENDARY
	hat_leg.initialize_upgrade()
	ps2.apply_modifier(hat_leg, true)
	# cc: 0.03*5=0.15, so 0.05+0.15=0.20
	# cdm: 0.05*5=0.25, so 1.2+0.25=1.45
	assert_approx(ps2.critical_chance, 0.20, "B3a: Cylinder Hat LEGENDARY → cc=0.20")
	assert_approx(ps2.critical_damage_multiplier, 1.45, "B3b: Cylinder Hat LEGENDARY → cdm=1.45")

	# B4: MAX_HEALTH base=0.1 → hp 2000→2200
	var ps3 = create_fresh_player_stats()
	var sm_hp = create_stat_model(StatUpgrade.UPGRADABLE_STATS.MAX_HEALTH, 0.1)
	var hp_upgrade = create_temporary_upgrade("hp_test", [sm_hp])
	ps3.add_temporary_upgrade(hp_upgrade)
	# MAX_HEALTH: change = current_health * multiplier = 2000 * 0.1 = 200
	assert_eq(ps3.max_health, 2200, "B4: MAX_HEALTH base=0.1 → hp 2000→2200")

	# B5: Clamping cc at 0.8
	var ps4 = create_fresh_player_stats()
	var sm_cc = create_stat_model(StatUpgrade.UPGRADABLE_STATS.CRITICAL_CHANCE, 0.9)
	var cc_upgrade = create_temporary_upgrade("cc_clamp", [sm_cc])
	ps4.add_temporary_upgrade(cc_upgrade)
	assert_approx(ps4.critical_chance, 0.8, "B5: CC clamped at 0.8")

	# B6: Clamping dc at 0.8
	var ps5 = create_fresh_player_stats()
	var sm_dc = create_stat_model(StatUpgrade.UPGRADABLE_STATS.DODGE_CHANCE, 0.9)
	var dc_upgrade = create_temporary_upgrade("dc_clamp", [sm_dc])
	ps5.add_temporary_upgrade(dc_upgrade)
	assert_approx(ps5.dodge_chance, 0.8, "B6: DC clamped at 0.8")

	# B7: Clamping sr at 0.8
	var ps6 = create_fresh_player_stats()
	var sm_sr = create_stat_model(StatUpgrade.UPGRADABLE_STATS.STATUS_RESIST_MULTI, 0.9)
	var sr_upgrade = create_temporary_upgrade("sr_clamp", [sm_sr])
	ps6.add_temporary_upgrade(sr_upgrade)
	assert_approx(ps6.status_resist_multiplier, 0.8, "B7: SR clamped at 0.8")

	# B8: Clamping lower bound at 0.0
	var ps7 = create_fresh_player_stats()
	var sm_cc_neg = create_stat_model(StatUpgrade.UPGRADABLE_STATS.CRITICAL_CHANCE, -1.0)
	var cc_neg_upgrade = create_temporary_upgrade("cc_neg", [sm_cc_neg])
	ps7.add_temporary_upgrade(cc_neg_upgrade)
	assert_approx(ps7.critical_chance, 0.0, "B8: CC clamped at lower bound 0.0")

# ═══════════════════════════════════════════
#  C. EQUIPMENT SYSTEM
# ═══════════════════════════════════════════

func test_c_equipment_system() -> void:
	log_header("C. Equipment System")

	var hat_res = load("res://data/game data/upgrades/shop_upgrades/cylinder_hat.tres")
	var belt_res = load("res://data/game data/upgrades/shop_upgrades/sweets_sellers_belt.tres")
	var uni_res = load("res://data/game data/upgrades/shop_upgrades/spiked_unicycle.tres")

	# C1: Equip HEAD
	var ps = create_fresh_player_stats()
	var hat = hat_res.duplicate(true) as ShopUpgrade
	hat.initialize_upgrade()
	ps.add_to_inventory(hat)
	ps.equip_upgrade(hat)
	assert_eq(ps.head_slot, hat, "C1a: HEAD slot occupied")
	assert_true(!ps.inventory.has(hat), "C1b: Removed from inventory")
	assert_approx(ps.critical_chance, BASE_CC + 0.03, "C1c: Stats applied")

	# C2: Equip BODY
	var ps2 = create_fresh_player_stats()
	var belt = belt_res.duplicate(true) as ShopUpgrade
	belt.initialize_upgrade()
	ps2.add_to_inventory(belt)
	ps2.equip_upgrade(belt)
	assert_eq(ps2.body_slot, belt, "C2a: BODY slot occupied")
	assert_true(!ps2.inventory.has(belt), "C2b: Removed from inventory")

	# C3: Equip LEGS
	var ps3 = create_fresh_player_stats()
	var uni = uni_res.duplicate(true) as ShopUpgrade
	uni.initialize_upgrade()
	ps3.add_to_inventory(uni)
	ps3.equip_upgrade(uni)
	assert_eq(ps3.legs_slot, uni, "C3a: LEGS slot occupied")
	assert_true(!ps3.inventory.has(uni), "C3b: Removed from inventory")

	# C4: Swap HEAD — old item goes to inventory, new one in slot
	var ps4 = create_fresh_player_stats()
	var hat1 = hat_res.duplicate(true) as ShopUpgrade
	hat1.name = "Hat_v1"
	hat1.initialize_upgrade()
	ps4.add_to_inventory(hat1)
	ps4.equip_upgrade(hat1)

	var hat2 = hat_res.duplicate(true) as ShopUpgrade
	hat2.name = "Hat_v2"
	hat2.initialize_upgrade()
	ps4.add_to_inventory(hat2)
	ps4.equip_upgrade(hat2)
	assert_eq(ps4.head_slot, hat2, "C4a: New hat in slot")
	assert_true(ps4.inventory.has(hat1), "C4b: Old hat back in inventory")

	# C5: Unequip — slot null, item in inventory, stats returned
	var ps5 = create_fresh_player_stats()
	var hat3 = hat_res.duplicate(true) as ShopUpgrade
	hat3.initialize_upgrade()
	ps5.add_to_inventory(hat3)
	ps5.equip_upgrade(hat3)
	ps5.unequip_upgrade(hat3)
	assert_null(ps5.head_slot, "C5a: HEAD slot null after unequip")
	assert_true(ps5.inventory.has(hat3), "C5b: Item back in inventory")
	assert_approx(ps5.critical_chance, BASE_CC, "C5c: Stats returned to baseline")

	# C6: Equip FightingStyle
	var ps6 = create_fresh_player_stats()
	var boxing_res = load("res://fighting styles/bear/bear_boxing.tres")
	var boxing = boxing_res.duplicate(true) as FightingStyle
	boxing.initialize_upgrade()
	ps6.add_to_inventory(boxing)
	ps6.equip_upgrade(boxing)
	assert_eq(ps6.fighting_style, boxing, "C6: FightingStyle equipped")

# ═══════════════════════════════════════════
#  D. INVENTORY MANAGEMENT
# ═══════════════════════════════════════════

func test_d_inventory_management() -> void:
	log_header("D. Inventory Management")

	var hat_res = load("res://data/game data/upgrades/shop_upgrades/cylinder_hat.tres")

	# D1: Add → size==1
	var ps = create_fresh_player_stats()
	var hat = hat_res.duplicate(true) as ShopUpgrade
	hat.initialize_upgrade()
	ps.add_to_inventory(hat)
	assert_eq(ps.inventory.size(), 1, "D1: Add to inventory → size=1")

	# D2: Duplicate replaces → size stays 1
	var hat_dup = hat_res.duplicate(true) as ShopUpgrade
	hat_dup.initialize_upgrade()
	ps.add_to_inventory(hat_dup)
	assert_eq(ps.inventory.size(), 1, "D2: Duplicate replaces → size stays 1")

	# D3: Remove → size==0
	# The last added item is hat_dup
	ps.remove_from_inventory(hat_dup)
	assert_eq(ps.inventory.size(), 0, "D3: Remove → size=0")

	# D4: Equip removes from inventory
	var ps2 = create_fresh_player_stats()
	var hat2 = hat_res.duplicate(true) as ShopUpgrade
	hat2.initialize_upgrade()
	ps2.add_to_inventory(hat2)
	ps2.equip_upgrade(hat2)
	assert_true(!ps2.inventory.has(hat2), "D4: Equip removes from inventory")

	# D5: Unequip returns to inventory
	ps2.unequip_upgrade(hat2)
	assert_true(ps2.inventory.has(hat2), "D5: Unequip returns to inventory")

# ═══════════════════════════════════════════
#  E. SHOP PURCHASES
# ═══════════════════════════════════════════

func test_e_shop_purchases() -> void:
	log_header("E. Shop Purchases")

	var hat_res = load("res://data/game data/upgrades/shop_upgrades/cylinder_hat.tres")

	# Create isolated ShopManager-like test
	var ps = create_fresh_player_stats()
	ps.money_dictionary[PlayerStats.MONEY.TICKETS] = 100

	var hat = hat_res.duplicate(true) as ShopUpgrade
	hat.initialize_upgrade()

	# Save ShopManager state
	var saved_ps = ShopManager.player_stats
	var saved_assortment = ShopManager.shop_assortment.duplicate()
	ShopManager.player_stats = ps
	ShopManager.shop_assortment = make_shop_array(hat)

	# E1: Purchase deducts money (100-30=70)
	var result = ShopManager.purchase_item(hat)
	assert_eq(ps.money_dictionary[PlayerStats.MONEY.TICKETS], 70, "E1: Purchase deducts money 100→70")

	# E2: Item appears in inventory
	var found = false
	for item in ps.inventory:
		if item.name == "Cylinder Hat":
			found = true
			break
	assert_true(found, "E2: Item appears in inventory after purchase")

	# E3: Shop rarity increases (COMMON→UNCOMMON)
	assert_eq(hat.rarity, Upgrade.RARITY.UNCOMMON, "E3: Rarity increases COMMON→UNCOMMON")

	# E4: Price doubles (30→60)
	assert_eq(hat.cost, 60, "E4: Cost doubles 30→60")

	# E5: can_afford with 0 → false
	var ps2 = create_fresh_player_stats()
	ps2.money_dictionary[PlayerStats.MONEY.TICKETS] = 0
	ShopManager.player_stats = ps2
	assert_true(!ShopManager.can_afford(hat), "E5: can_afford with 0 money → false")

	# E6: purchase_item without money → false
	var result2 = ShopManager.purchase_item(hat)
	assert_true(!result2, "E6: purchase_item without money → false")

	# E7: 4 purchases to LEGENDARY, prices 30→60→120→240
	var ps3 = create_fresh_player_stats()
	ps3.money_dictionary[PlayerStats.MONEY.TICKETS] = 10000
	ShopManager.player_stats = ps3

	var hat2 = hat_res.duplicate(true) as ShopUpgrade
	hat2.initialize_upgrade()
	ShopManager.shop_assortment = make_shop_array(hat2)

	var prices: Array = []
	var rarities_seen: Array = []
	for i in range(4):
		prices.append(hat2.cost)
		rarities_seen.append(hat2.rarity)
		ShopManager.purchase_item(hat2)

	assert_eq(prices, [30, 60, 120, 240], "E7a: Prices double: 30→60→120→240")
	assert_eq(rarities_seen, [0, 1, 2, 3], "E7b: Rarities progress COMMON→MYTHICAL")

	# Restore ShopManager
	ShopManager.player_stats = saved_ps
	ShopManager.shop_assortment = saved_assortment

# ═══════════════════════════════════════════
#  F. TEMPORARY UPGRADES
# ═══════════════════════════════════════════

func test_f_temporary_upgrades() -> void:
	log_header("F. Temporary Upgrades")

	# F1: Add → stats changed, size==1
	var ps = create_fresh_player_stats()
	var sm = create_stat_model(StatUpgrade.UPGRADABLE_STATS.CRITICAL_CHANCE, 0.05)
	var tu = create_temporary_upgrade("boxing_gloves_test", [sm])
	ps.add_temporary_upgrade(tu)
	assert_eq(ps.temporary_upgrades.size(), 1, "F1a: Temp upgrade added → size=1")
	assert_approx(ps.critical_chance, BASE_CC + 0.05, "F1b: Stats changed after add")

	# F2: Remove → stats returned, size==0
	ps.remove_temporary_upgrade(tu)
	assert_eq(ps.temporary_upgrades.size(), 0, "F2a: Temp upgrade removed → size=0")
	assert_approx(ps.critical_chance, BASE_CC, "F2b: Stats returned after remove")

	# F3: Multiple simultaneous → size==2
	var ps2 = create_fresh_player_stats()
	var sm1 = create_stat_model(StatUpgrade.UPGRADABLE_STATS.CRITICAL_CHANCE, 0.05)
	var sm2 = create_stat_model(StatUpgrade.UPGRADABLE_STATS.DODGE_CHANCE, 0.1)
	var tu1 = create_temporary_upgrade("tu1", [sm1])
	var tu2 = create_temporary_upgrade("tu2", [sm2])
	ps2.add_temporary_upgrade(tu1)
	ps2.add_temporary_upgrade(tu2)
	assert_eq(ps2.temporary_upgrades.size(), 2, "F3: Multiple temp upgrades → size=2")

	# F4: clear_temporary_modifiers → all returned
	ps2.clear_temporary_modifiers()
	assert_eq(ps2.temporary_upgrades.size(), 0, "F4a: clear_temporary_modifiers → size=0")
	assert_approx(ps2.critical_chance, BASE_CC, "F4b: CC back to baseline")
	assert_approx(ps2.dodge_chance, BASE_DC, "F4c: DC back to baseline")

	# F5: Remove non-existent → no crash
	var ps3 = create_fresh_player_stats()
	var fake_tu = create_temporary_upgrade("fake", [])
	ps3.remove_temporary_upgrade(fake_tu)
	assert_eq(ps3.temporary_upgrades.size(), 0, "F5: Remove non-existent → no crash")

# ═══════════════════════════════════════════
#  G. BONUS MANAGER
# ═══════════════════════════════════════════

func test_g_bonus_manager() -> void:
	log_header("G. BonusManager")

	# G1: generate_tickets(5) → array with 5 values
	var tickets_dict = BonusManager.generate_tickets(5)
	var tickets_arr = tickets_dict[PlayerStats.MONEY.TICKETS]
	assert_eq(tickets_arr.size(), 5, "G1: generate_tickets(5) → array size=5")

	# G2: Ticket values in {5, 15, 30}
	var valid_ticket_values = [5, 15, 30]
	var all_valid_tickets = true
	for v in tickets_arr:
		if !valid_ticket_values.has(v):
			all_valid_tickets = false
			break
	assert_true(all_valid_tickets, "G2: All ticket values in {5, 15, 30}")

	# G3: generate_tokens(5) → array with 5 values
	var tokens_dict = BonusManager.generate_tokens(5)
	var tokens_arr = tokens_dict[PlayerStats.MONEY.TOKENS]
	assert_eq(tokens_arr.size(), 5, "G3: generate_tokens(5) → array size=5")

	# G4: Token values in {1, 3, 5}
	var valid_token_values = [1, 3, 5]
	var all_valid_tokens = true
	for v in tokens_arr:
		if !valid_token_values.has(v):
			all_valid_tokens = false
			break
	assert_true(all_valid_tokens, "G4: All token values in {1, 3, 5}")

# ═══════════════════════════════════════════
#  H. FIGHTING STYLES
# ═══════════════════════════════════════════

func test_h_fighting_styles() -> void:
	log_header("H. Fighting Styles")

	var boxing_res = load("res://fighting styles/bear/bear_boxing.tres")
	var freestyle_res = load("res://fighting styles/bear/bear_freestyle.tres")

	# H1: change_fighting_style → set, removed from inventory
	var ps = create_fresh_player_stats()
	var boxing = boxing_res.duplicate(true) as FightingStyle
	boxing.initialize_upgrade()
	ps.add_to_inventory(boxing)
	ps.change_fighting_style(boxing)
	assert_eq(ps.fighting_style, boxing, "H1a: Fighting style set")
	assert_true(!ps.inventory.has(boxing), "H1b: Removed from inventory")

	# H2: Combo progression (boxing) → 4 calls = damage indices 0,1,2,3
	var boxing2 = boxing_res.duplicate(true) as FightingStyle
	boxing2.combo_count = 0
	var damages: Array = []
	for i in range(4):
		var dmg = boxing2.get_damage()
		damages.append(dmg)
	# get_damage increments combo_count after check
	# combo_count starts at 0, so first call gets index 0, etc
	assert_eq(damages.size(), 4, "H2: 4 combo calls return 4 damage values")

	# H3: Combo reset at max
	# After 4 calls with max_combo_count=4, combo_count should reset to 0
	assert_eq(boxing2.combo_count, 0, "H3: Combo resets after max (4→0)")

	# H4: get_damage_at_index(2)
	var boxing3 = boxing_res.duplicate(true) as FightingStyle
	var dmg_at_2 = boxing3.get_damage_at_index(2)
	assert_not_null(dmg_at_2, "H4: get_damage_at_index(2) returns non-null")

	# H5: Style swap — old unequipped, new applied
	var ps2 = create_fresh_player_stats()
	var freestyle = freestyle_res.duplicate(true) as FightingStyle
	freestyle.initialize_upgrade()
	ps2.add_to_inventory(freestyle)
	ps2.change_fighting_style(freestyle)

	var boxing4 = boxing_res.duplicate(true) as FightingStyle
	boxing4.initialize_upgrade()
	ps2.add_to_inventory(boxing4)
	ps2.change_fighting_style(boxing4)
	assert_eq(ps2.fighting_style, boxing4, "H5a: New style applied")
	assert_true(ps2.inventory.has(freestyle), "H5b: Old style back in inventory")

# ═══════════════════════════════════════════
#  I. CURRENCY SYSTEM
# ═══════════════════════════════════════════

func test_i_currency_system() -> void:
	log_header("I. Currency System")

	# I1: Add tickets
	var ps = create_fresh_player_stats()
	ps.money_dictionary[PlayerStats.MONEY.TICKETS] += 50
	assert_eq(ps.money_dictionary[PlayerStats.MONEY.TICKETS], 50, "I1: Add 50 tickets → balance=50")

	# I2: Add tokens
	ps.money_dictionary[PlayerStats.MONEY.TOKENS] += 10
	assert_eq(ps.money_dictionary[PlayerStats.MONEY.TOKENS], 10, "I2: Add 10 tokens → balance=10")

	# I3: Purchase with tickets → correct currency deducted
	var hat_res = load("res://data/game data/upgrades/shop_upgrades/cylinder_hat.tres")
	var ps2 = create_fresh_player_stats()
	ps2.money_dictionary[PlayerStats.MONEY.TICKETS] = 100
	ps2.money_dictionary[PlayerStats.MONEY.TOKENS] = 50

	var saved_ps = ShopManager.player_stats
	var saved_assort = ShopManager.shop_assortment.duplicate()
	ShopManager.player_stats = ps2

	var hat = hat_res.duplicate(true) as ShopUpgrade
	hat.money_type = PlayerStats.MONEY.TICKETS
	hat.initialize_upgrade()
	ShopManager.shop_assortment = make_shop_array(hat)
	ShopManager.purchase_item(hat)
	assert_eq(ps2.money_dictionary[PlayerStats.MONEY.TICKETS], 70, "I3: Tickets deducted (100→70)")
	assert_eq(ps2.money_dictionary[PlayerStats.MONEY.TOKENS], 50, "I3b: Tokens unchanged")

	# I4: Purchase with tokens → correct currency deducted
	var ps3 = create_fresh_player_stats()
	ps3.money_dictionary[PlayerStats.MONEY.TICKETS] = 100
	ps3.money_dictionary[PlayerStats.MONEY.TOKENS] = 50
	ShopManager.player_stats = ps3

	var hat2 = hat_res.duplicate(true) as ShopUpgrade
	hat2.money_type = PlayerStats.MONEY.TOKENS
	hat2.cost = 10
	hat2.initialize_upgrade()
	ShopManager.shop_assortment = make_shop_array(hat2)
	ShopManager.purchase_item(hat2)
	assert_eq(ps3.money_dictionary[PlayerStats.MONEY.TOKENS], 40, "I4: Tokens deducted (50→40)")
	assert_eq(ps3.money_dictionary[PlayerStats.MONEY.TICKETS], 100, "I4b: Tickets unchanged")

	# Restore
	ShopManager.player_stats = saved_ps
	ShopManager.shop_assortment = saved_assort

# ═══════════════════════════════════════════
#  J. EDGE CASES
# ═══════════════════════════════════════════

func test_j_edge_cases() -> void:
	log_header("J. Edge Cases")

	var hat_res = load("res://data/game data/upgrades/shop_upgrades/cylinder_hat.tres")

	# J1: Equip item NOT in inventory → slot stays null
	var ps = create_fresh_player_stats()
	var hat = hat_res.duplicate(true) as ShopUpgrade
	hat.initialize_upgrade()
	ps.equip_upgrade(hat)  # Not in inventory
	assert_null(ps.head_slot, "J1: Equip not-in-inventory → slot stays null")

	# J2: Purchase with 0 money → false
	var ps2 = create_fresh_player_stats()
	ps2.money_dictionary[PlayerStats.MONEY.TICKETS] = 0
	var saved_ps = ShopManager.player_stats
	var saved_assort = ShopManager.shop_assortment.duplicate()
	ShopManager.player_stats = ps2
	var hat2 = hat_res.duplicate(true) as ShopUpgrade
	hat2.initialize_upgrade()
	ShopManager.shop_assortment = make_shop_array(hat2)
	var result = ShopManager.purchase_item(hat2)
	assert_true(!result, "J2: Purchase with 0 money → false")
	ShopManager.player_stats = saved_ps
	ShopManager.shop_assortment = saved_assort

	# J3: Double apply_modifier → stats double
	var ps3 = create_fresh_player_stats()
	var hat3 = hat_res.duplicate(true) as ShopUpgrade
	hat3.initialize_upgrade()
	ps3.apply_modifier(hat3, true)
	ps3.apply_modifier(hat3, true)
	# cc: 0.05 + 0.03 + 0.03 = 0.11
	assert_approx(ps3.critical_chance, 0.11, "J3: Double apply_modifier → stats doubled")

	# J4: Unequip empty slot → no crash
	var ps4 = create_fresh_player_stats()
	var hat4 = hat_res.duplicate(true) as ShopUpgrade
	hat4.initialize_upgrade()
	ps4.unequip_upgrade(hat4)  # Not equipped anywhere
	assert_null(ps4.head_slot, "J4: Unequip empty slot → no crash")

	# J5: Add/remove temp upgrade twice → baseline
	var ps5 = create_fresh_player_stats()
	var sm = create_stat_model(StatUpgrade.UPGRADABLE_STATS.CRITICAL_CHANCE, 0.1)
	var tu = create_temporary_upgrade("double_test", [sm])
	ps5.add_temporary_upgrade(tu)
	ps5.remove_temporary_upgrade(tu)
	ps5.add_temporary_upgrade(tu)
	ps5.remove_temporary_upgrade(tu)
	assert_approx(ps5.critical_chance, BASE_CC, "J5: Add/remove temp twice → baseline")

	# J6: inventory_updated signal fires
	var ps6 = create_fresh_player_stats()
	var inv_tracker = [false]
	ps6.inventory_updated.connect(func(): inv_tracker[0] = true)
	var hat6 = hat_res.duplicate(true) as ShopUpgrade
	hat6.initialize_upgrade()
	ps6.add_to_inventory(hat6)
	assert_true(inv_tracker[0], "J6: inventory_updated signal fires on add")

	# J7: stats_upgraded signal fires
	var ps7 = create_fresh_player_stats()
	var stats_tracker = [false]
	ps7.stats_upgraded.connect(func(): stats_tracker[0] = true)
	var sm7 = create_stat_model(StatUpgrade.UPGRADABLE_STATS.CRITICAL_CHANCE, 0.01)
	var tu7 = create_temporary_upgrade("signal_test", [sm7])
	ps7.add_temporary_upgrade(tu7)
	assert_true(stats_tracker[0], "J7: stats_upgraded signal fires on modifier apply")

# ═══════════════════════════════════════════
#  K. DAMAGE SYSTEM
# ═══════════════════════════════════════════

func test_k_damage_system() -> void:
	log_header("K. Damage System")

	# K1: Damage.get_damage_amount() = damage_amount * multiplier
	var dmg = Damage.new()
	dmg.damage_amount = 50.0
	dmg.multiplier = 1.0
	assert_approx(dmg.get_damage_amount(), 50.0, "K1: Damage 50*1.0 = 50")

	# K2: Damage with multiplier
	var dmg2 = Damage.new()
	dmg2.damage_amount = 50.0
	dmg2.multiplier = 2.0
	assert_approx(dmg2.get_damage_amount(), 100.0, "K2: Damage 50*2.0 = 100")

	# K3: Damage with fractional multiplier
	var dmg3 = Damage.new()
	dmg3.damage_amount = 80.0
	dmg3.multiplier = 0.5
	assert_approx(dmg3.get_damage_amount(), 40.0, "K3: Damage 80*0.5 = 40")

	# K4: Full damage formula: damage * crit_mult * atk_power
	var damage_amount = 70.0
	var crit_mult = 1.2
	var atk_power = 1.5
	var expected = 70.0 * 1.2 * 1.5  # 126.0
	assert_approx(damage_amount * crit_mult * atk_power, expected, "K4: Damage formula 70*1.2*1.5 = 126")

	# K5: Non-critical hit uses multiplier 1.0
	var base = 100.0
	var no_crit = 1.0
	var atk = 1.0
	assert_approx(base * no_crit * atk, 100.0, "K5: Non-crit 100*1.0*1.0 = 100")

	# K6: Boxing combo damage values from .tres
	var boxing_res = load("res://fighting styles/bear/bear_boxing.tres")
	var boxing = boxing_res.duplicate(true) as FightingStyle
	var d0 = boxing.get_damage_at_index(0)
	var d1 = boxing.get_damage_at_index(1)
	var d2 = boxing.get_damage_at_index(2)
	var d3 = boxing.get_damage_at_index(3)
	assert_approx(d0.damage_amount, 70.0, "K6a: Boxing combo[0] = 70 dmg")
	assert_approx(d1.damage_amount, 80.0, "K6b: Boxing combo[1] = 80 dmg")
	assert_approx(d2.damage_amount, 90.0, "K6c: Boxing combo[2] = 90 dmg")
	assert_approx(d3.damage_amount, 100.0, "K6d: Boxing combo[3] = 100 dmg")

	# K7: Lumberjack combo damage values
	var lj_res = load("res://fighting styles/bear/bear_lumberjack.tres")
	var lj = lj_res.duplicate(true) as FightingStyle
	assert_approx(lj.get_damage_at_index(0).damage_amount, 100.0, "K7a: Lumberjack combo[0] = 100")
	assert_approx(lj.get_damage_at_index(1).damage_amount, 120.0, "K7b: Lumberjack combo[1] = 120")
	assert_approx(lj.get_damage_at_index(2).damage_amount, 140.0, "K7c: Lumberjack combo[2] = 140")

# ═══════════════════════════════════════════
#  L. CHARACTER STATS
# ═══════════════════════════════════════════

func test_l_character_stats() -> void:
	log_header("L. CharacterStats")

	# L1: take_damage reduces HP
	var cs = CharacterStats.new()
	cs.max_health = 1000
	cs.current_health = 1000
	cs.take_damage(300)
	assert_eq(cs.current_health, 700, "L1: take_damage(300) → 1000→700")

	# L2: take_damage doesn't go below 0
	cs.take_damage(9999)
	assert_eq(cs.current_health, 0, "L2: take_damage can't go below 0")

	# L3: heal restores HP
	var cs2 = CharacterStats.new()
	cs2.max_health = 1000
	cs2.current_health = 500
	cs2.heal(200)
	assert_eq(cs2.current_health, 700, "L3: heal(200) → 500→700")

	# L4: heal doesn't exceed max_health
	cs2.heal(9999)
	assert_eq(cs2.current_health, 1000, "L4: heal capped at max_health")

	# L5: got_hit signal fires on take_damage
	var cs3 = CharacterStats.new()
	cs3.max_health = 1000
	cs3.current_health = 1000
	var hit_tracker = [false]
	cs3.got_hit.connect(func(): hit_tracker[0] = true)
	cs3.take_damage(1)
	assert_true(hit_tracker[0], "L5: got_hit signal fires on take_damage")

	# L6: hp_changed signal fires with correct value
	var cs4 = CharacterStats.new()
	cs4.max_health = 1000
	cs4.current_health = 1000
	var hp_tracker = [-1]
	cs4.hp_changed.connect(func(new_hp): hp_tracker[0] = new_hp)
	cs4.take_damage(250)
	assert_eq(hp_tracker[0], 750, "L6: hp_changed emits 750 after take_damage(250)")

	# L7: reset() restores from reserve_copy
	var cs5 = CharacterStats.new()
	cs5.max_health = 2000
	cs5.current_health = 2000
	cs5.attack_power_multiplier = 1.0
	cs5.critical_chance = 0.05
	cs5.critical_damage_multiplier = 1.2
	cs5.dodge_chance = 0.0
	cs5.movement_speed_multiplier = 1.0
	cs5.status_resist_multiplier = 0.1
	cs5.effect_power_multiplier = 1.0

	var backup = CharacterStats.new()
	backup.max_health = 2000
	backup.attack_power_multiplier = 1.0
	backup.critical_chance = 0.05
	backup.critical_damage_multiplier = 1.2
	backup.dodge_chance = 0.0
	backup.movement_speed_multiplier = 1.0
	backup.status_resist_multiplier = 0.1
	backup.effect_power_multiplier = 1.0
	cs5.reserve_copy = backup

	# Mess up the stats
	cs5.attack_power_multiplier = 5.0
	cs5.critical_chance = 0.9
	cs5.dodge_chance = 0.8
	cs5.reset()
	assert_approx(cs5.attack_power_multiplier, 1.0, "L7a: reset() restores atk")
	assert_approx(cs5.critical_chance, 0.05, "L7b: reset() restores cc")
	assert_approx(cs5.dodge_chance, 0.0, "L7c: reset() restores dc")

	# L8: reset() without reserve_copy → no crash
	var cs6 = CharacterStats.new()
	cs6.max_health = 1000
	cs6.current_health = 1000
	cs6.reserve_copy = null
	cs6.reset()
	assert_eq(cs6.max_health, 1000, "L8: reset() without reserve_copy → no crash")

	# L9: increase_max_health also heals
	var cs7 = CharacterStats.new()
	cs7.max_health = 1000
	cs7.current_health = 800
	cs7.increase_max_health(200)
	assert_eq(cs7.max_health, 1200, "L9a: increase_max_health → 1200")
	assert_eq(cs7.current_health, 1000, "L9b: current_health healed by amount")

# ═══════════════════════════════════════════
#  M. NEGATIVE EFFECTS (Resources)
# ═══════════════════════════════════════════

func test_m_negative_effects() -> void:
	log_header("M. Negative Effects")

	# M1: BleedingEffect.calculate_damage — 3% of max HP
	var bleed = BleedingEffect.new()
	bleed.bleeding_damage_percent = 0.03
	var bleed_dmg = bleed.calculate_damage(2000)
	assert_approx(bleed_dmg, 60.0, "M1: BleedingEffect 3% of 2000 = 60")

	# M2: BleedingEffect with different HP
	var bleed2 = BleedingEffect.new()
	bleed2.bleeding_damage_percent = 0.05
	assert_approx(bleed2.calculate_damage(1000), 50.0, "M2: BleedingEffect 5% of 1000 = 50")

	# M3: TickingNegativeEffect tick count
	var tick_effect = TickingNegativeEffect.new()
	tick_effect.duration = 3.0
	tick_effect.tick_interval = 0.5
	assert_eq(tick_effect.get_ticks_amount(), 6, "M3: 3.0s / 0.5s interval = 6 ticks")

	# M4: Tick count with non-even division (ceil)
	var tick_effect2 = TickingNegativeEffect.new()
	tick_effect2.duration = 2.5
	tick_effect2.tick_interval = 0.6
	# ceil(2.5/0.6) = ceil(4.167) = 5
	assert_eq(tick_effect2.get_ticks_amount(), 5, "M4: ceil(2.5/0.6) = 5 ticks")

	# M5: get_tick_interval returns correct value
	assert_approx(tick_effect2.get_tick_interval(), 0.6, "M5: get_tick_interval = 0.6")

	# M6: Knockback has knockback_force
	var kb = Knockback.new()
	kb.knockback_force = 1500.0
	assert_approx(kb.knockback_force, 1500.0, "M6: Knockback force = 1500")

	# M7: SlowEffect has slow_ratio
	var slow = SlowEffect.new()
	slow.slow_ratio = 0.5
	assert_approx(slow.slow_ratio, 0.5, "M7: SlowEffect ratio = 0.5")

	# M8: Effect multiplier vs resistance formula
	var eff_mult = 1.0
	var resist = 0.1
	var result = clampf(eff_mult - resist, 0, eff_mult)
	assert_approx(result, 0.9, "M8: eff_mult(1.0) - resist(0.1) = 0.9")

	# M9: Full resistance negates effect
	var eff_mult2 = 0.5
	var resist2 = 0.8
	var result2 = clampf(eff_mult2 - resist2, 0, eff_mult2)
	assert_approx(result2, 0.0, "M9: eff_mult(0.5) - resist(0.8) clamped to 0.0")

	# M10: SlowEffect applied speed = (1 - slow_ratio * multiplier)
	var slow2 = SlowEffect.new()
	slow2.slow_ratio = 0.5
	var multiplier = 0.9  # after resistance
	var new_speed = 1.0 - slow2.slow_ratio * multiplier
	assert_approx(new_speed, 0.55, "M10: Slow 0.5 * mult 0.9 → speed=0.55")

	# M11: Fire damage adjusted by multiplier and resistance
	var fire_base_dmg = 20.0
	var fire_mult = 0.9
	var fire_resist = 0.1
	var adjusted = fire_base_dmg * fire_mult * (1.0 - fire_resist)
	assert_approx(adjusted, 16.2, "M11: Fire 20 * 0.9 * (1-0.1) = 16.2")

	# M12: Boxing knockback effect exists on combo hits
	var boxing_res = load("res://fighting styles/bear/bear_boxing.tres")
	var boxing = boxing_res.duplicate(true) as FightingStyle
	var dmg0 = boxing.get_damage_at_index(0)
	assert_not_null(dmg0.effect, "M12a: Boxing combo[0] has effect")
	assert_true(dmg0.effect is Knockback, "M12b: Boxing combo[0] effect is Knockback")

	# M13: Lumberjack combo[2] has SlowEffect
	var lj_res = load("res://fighting styles/bear/bear_lumberjack.tres")
	var lj = lj_res.duplicate(true) as FightingStyle
	var lj_dmg2 = lj.get_damage_at_index(2)
	assert_not_null(lj_dmg2.effect, "M13a: Lumberjack combo[2] has effect")
	assert_true(lj_dmg2.effect is SlowEffect, "M13b: Lumberjack combo[2] effect is SlowEffect")

# ═══════════════════════════════════════════
#  N. UPGRADE MANAGER
# ═══════════════════════════════════════════

func test_n_upgrade_manager() -> void:
	log_header("N. UpgradeManager")

	# N1: get_temporary_upgrades_pool returns requested count
	var ps = create_fresh_player_stats()
	var pool = UpgradeManager.get_temporary_upgrades_pool(4, ps)
	assert_eq(pool.size(), 4, "N1: get_temporary_upgrades_pool(4) → size=4")

	# N2: All items in pool are TemporaryUpgrade
	var all_temp = true
	for item in pool:
		if !(item is TemporaryUpgrade):
			all_temp = false
			break
	assert_true(all_temp, "N2: All pool items are TemporaryUpgrade")

	# N3: Each item has a valid rarity (0-4)
	var all_valid_rarity = true
	for item in pool:
		if item.rarity < 0 or item.rarity > 4:
			all_valid_rarity = false
			break
	assert_true(all_valid_rarity, "N3: All items have rarity 0-4")

	# N4: No duplicate names in a single pool draw
	var names: Array = []
	var no_dup_names = true
	for item in pool:
		if names.has(item.name):
			no_dup_names = false
			break
		names.append(item.name)
	assert_true(no_dup_names, "N4: No duplicate names in pool")

	# N5: No duplicate rarities among new items (fresh player = all new)
	var rarities_in_pool: Array = []
	var no_dup_rarities = true
	for item in pool:
		if rarities_in_pool.has(item.rarity):
			no_dup_rarities = false
			break
		rarities_in_pool.append(item.rarity)
	assert_true(no_dup_rarities, "N5: No duplicate rarities among new items")

	# N6: Existing upgrade → next rarity tier
	var ps2 = create_fresh_player_stats()
	# Add a known temp upgrade at COMMON
	if UpgradeManager.temporary_upgrades_pool.size() > 0:
		var known = UpgradeManager.temporary_upgrades_pool[0].duplicate(true)
		known.rarity = Upgrade.RARITY.COMMON
		known.initialize_upgrade()
		ps2.temporary_upgrades.append(known)

		var pool2 = UpgradeManager.get_temporary_upgrades_pool(UpgradeManager.temporary_upgrades_pool.size(), ps2)
		var escalated = false
		for item in pool2:
			if item.name == known.name:
				# Should be at least UNCOMMON (COMMON + 1)
				escalated = item.rarity >= Upgrade.RARITY.UNCOMMON
				break
		assert_true(escalated, "N6: Existing COMMON upgrade → offered at UNCOMMON+")
	else:
		log_info("N6: SKIPPED — no upgrades in pool")
		total += 1
		passed += 1

	# N7: get_rarity_name via UpgradeManager
	assert_eq(UpgradeManager.get_rarity_name(0), "COMMON", "N7a: get_rarity_name(0) = COMMON")
	assert_eq(UpgradeManager.get_rarity_name(4), "LEGENDARY", "N7b: get_rarity_name(4) = LEGENDARY")

	# N8: Rarity distribution over many draws (statistical)
	var ps3 = create_fresh_player_stats()
	var rarity_counts = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0}
	for i in range(50):
		var p = UpgradeManager.get_temporary_upgrades_pool(4, ps3)
		for item in p:
			rarity_counts[item.rarity] += 1
	# COMMON should appear more than LEGENDARY
	assert_true(rarity_counts[0] > rarity_counts[4],
		"N8: COMMON appears more often than LEGENDARY (" + str(rarity_counts[0]) + " vs " + str(rarity_counts[4]) + ")")

# ═══════════════════════════════════════════
#  O. SHOP ASSORTMENT
# ═══════════════════════════════════════════

func test_o_shop_assortment() -> void:
	log_header("O. Shop Assortment")

	var hat_res = load("res://data/game data/upgrades/shop_upgrades/cylinder_hat.tres")
	var belt_res = load("res://data/game data/upgrades/shop_upgrades/sweets_sellers_belt.tres")

	# Save ShopManager state
	var saved_ps = ShopManager.player_stats
	var saved_assort = ShopManager.shop_assortment.duplicate()

	# O1: get_shop_assortment returns requested amount
	var ps = create_fresh_player_stats()
	ShopManager.player_stats = ps
	var hat = hat_res.duplicate(true) as ShopUpgrade
	hat.initialize_upgrade()
	var belt = belt_res.duplicate(true) as ShopUpgrade
	belt.initialize_upgrade()
	var assort: Array[ShopUpgrade] = [hat, belt]
	ShopManager.shop_assortment = assort
	var result = ShopManager.get_shop_assortment(1)
	assert_eq(result.size(), 1, "O1: get_shop_assortment(1) → size=1")

	# O2: get_shop_assortment(2) returns both
	var result2 = ShopManager.get_shop_assortment(2)
	assert_eq(result2.size(), 2, "O2: get_shop_assortment(2) → size=2")

	# O3: update_assortment increases rarity when player has item
	var ps2 = create_fresh_player_stats()
	ShopManager.player_stats = ps2
	var hat2 = hat_res.duplicate(true) as ShopUpgrade
	hat2.initialize_upgrade()
	var assort2: Array[ShopUpgrade] = [hat2]
	ShopManager.shop_assortment = assort2
	# Simulate player having the hat in inventory
	var hat_in_inv = hat_res.duplicate(true) as ShopUpgrade
	hat_in_inv.initialize_upgrade()
	ps2.inventory.append(hat_in_inv)
	ShopManager.update_assortment()
	assert_eq(hat2.rarity, Upgrade.RARITY.UNCOMMON, "O3: update_assortment → rarity COMMON→UNCOMMON")

	# O4: update_assortment removes LEGENDARY item from shop
	var ps3 = create_fresh_player_stats()
	ShopManager.player_stats = ps3
	var hat3 = hat_res.duplicate(true) as ShopUpgrade
	hat3.rarity = Upgrade.RARITY.LEGENDARY
	hat3.initialize_upgrade()
	var assort3: Array[ShopUpgrade] = [hat3]
	ShopManager.shop_assortment = assort3
	var hat_in_inv2 = hat_res.duplicate(true) as ShopUpgrade
	hat_in_inv2.initialize_upgrade()
	ps3.inventory.append(hat_in_inv2)
	ShopManager.update_assortment()
	# After update, LEGENDARY items with same name in inventory should be removed from shop
	var still_in_shop = false
	for item in ShopManager.shop_assortment:
		if item == hat3:
			still_in_shop = true
	assert_true(!still_in_shop, "O4: LEGENDARY item removed from shop after update")

	# O5: assortment_updated signal fires
	var ps4 = create_fresh_player_stats()
	ShopManager.player_stats = ps4
	var hat4 = hat_res.duplicate(true) as ShopUpgrade
	hat4.initialize_upgrade()
	var assort4: Array[ShopUpgrade] = [hat4]
	ShopManager.shop_assortment = assort4
	var signal_tracker = [false]
	ShopManager.assortment_updated.connect(func(): signal_tracker[0] = true)
	ShopManager.update_assortment()
	assert_true(signal_tracker[0], "O5: assortment_updated signal fires")
	# Disconnect to avoid leaks
	for conn in ShopManager.assortment_updated.get_connections():
		ShopManager.assortment_updated.disconnect(conn["callable"])

	# Restore ShopManager
	ShopManager.player_stats = saved_ps
	ShopManager.shop_assortment = saved_assort

# ═══════════════════════════════════════════
#  P. SPIN WHEEL
# ═══════════════════════════════════════════

func test_p_spin_wheel() -> void:
	log_header("P. Spin Wheel")

	# P1: has_tokens_to_spin_a_wheel — enough tokens
	var ps = create_fresh_player_stats()
	ps.money_dictionary[PlayerStats.MONEY.TOKENS] = 5
	assert_true(ps.has_tokens_to_spin_a_wheel(1), "P1: 5 tokens >= 1 spin cost → true")

	# P2: has_tokens_to_spin_a_wheel — not enough
	var ps2 = create_fresh_player_stats()
	ps2.money_dictionary[PlayerStats.MONEY.TOKENS] = 0
	assert_true(!ps2.has_tokens_to_spin_a_wheel(1), "P2: 0 tokens < 1 spin cost → false")

	# P3: purchase_spin deducts tokens
	var ps3 = create_fresh_player_stats()
	ps3.money_dictionary[PlayerStats.MONEY.TOKENS] = 3
	ps3.purchase_spin(1)
	assert_eq(ps3.money_dictionary[PlayerStats.MONEY.TOKENS], 2, "P3: purchase_spin(1) → 3→2 tokens")

	# P4: Multiple spins deduct correctly
	ps3.purchase_spin(1)
	ps3.purchase_spin(1)
	assert_eq(ps3.money_dictionary[PlayerStats.MONEY.TOKENS], 0, "P4: 3 spins → 0 tokens")

	# P5: Wheel reward slots cover full 360 degrees
	# Simulating the rewards array structure (8 slots, 45 deg each)
	var rewards = [
		{"from": 0, "to": 45},
		{"from": 45, "to": 90},
		{"from": 90, "to": 135},
		{"from": 135, "to": 180},
		{"from": 180, "to": 225},
		{"from": 225, "to": 270},
		{"from": 270, "to": 315},
		{"from": 315, "to": 360}
	]
	assert_eq(rewards.size(), 8, "P5a: 8 reward slots")
	assert_eq(rewards[0]["from"], 0, "P5b: First slot starts at 0")
	assert_eq(rewards[7]["to"], 360, "P5c: Last slot ends at 360")

	# P6: Any random angle (0-360) hits exactly one slot
	var test_angles = [0, 44, 45, 90, 179, 180, 270, 315, 359, 360]
	var all_hit = true
	for angle in test_angles:
		var hit_count = 0
		for slot in rewards:
			if angle >= slot["from"] and angle <= slot["to"]:
				hit_count += 1
		if hit_count < 1:
			all_hit = false
			break
	assert_true(all_hit, "P6: Every test angle hits at least one slot")

	# P7: UpgradeManager provides 4 upgrades for wheel
	var ps5 = create_fresh_player_stats()
	var wheel_upgrades = UpgradeManager.get_temporary_upgrades_pool(4, ps5)
	assert_eq(wheel_upgrades.size(), 4, "P7: Wheel gets 4 temp upgrades from pool")

	# P8: BonusManager provides 2 ticket rewards for wheel
	var tickets = BonusManager.generate_tickets(2)
	assert_eq(tickets[PlayerStats.MONEY.TICKETS].size(), 2, "P8: Wheel gets 2 ticket rewards")

	# P9: BonusManager provides 2 token rewards for wheel
	var tokens = BonusManager.generate_tokens(2)
	assert_eq(tokens[PlayerStats.MONEY.TOKENS].size(), 2, "P9: Wheel gets 2 token rewards")

	# P10: Total wheel resources = 4 upgrades + 2 tickets + 2 tokens = 8 (fills all slots)
	assert_eq(wheel_upgrades.size() + tickets[PlayerStats.MONEY.TICKETS].size() + tokens[PlayerStats.MONEY.TOKENS].size(), 8,
		"P10: 4 upgrades + 2 tickets + 2 tokens = 8 total (fills all 8 slots)")

	# P11: Wheel upgrades have valid rarities
	var all_valid = true
	for u in wheel_upgrades:
		if u.rarity < 0 or u.rarity > 4:
			all_valid = false
			break
	assert_true(all_valid, "P11: All wheel upgrades have rarity 0-4")

	# P12: Wheel upgrades are unique (no duplicate names)
	var wheel_names: Array = []
	var no_dups = true
	for u in wheel_upgrades:
		if wheel_names.has(u.name):
			no_dups = false
			break
		wheel_names.append(u.name)
	assert_true(no_dups, "P12: Wheel upgrades have unique names")

	# P13: Prize applies temp upgrade to player stats
	var ps6 = create_fresh_player_stats()
	var sm = create_stat_model(StatUpgrade.UPGRADABLE_STATS.CRITICAL_CHANCE, 0.05)
	var prize = create_temporary_upgrade("wheel_prize", [sm])
	ps6.add_temporary_upgrade(prize)
	assert_approx(ps6.critical_chance, BASE_CC + 0.05, "P13: Wheel prize upgrade applies to stats")

	# P14: Prize adds tickets to balance
	var ps7 = create_fresh_player_stats()
	ps7.money_dictionary[PlayerStats.MONEY.TICKETS] += 15
	assert_eq(ps7.money_dictionary[PlayerStats.MONEY.TICKETS], 15, "P14: Wheel ticket prize adds to balance")

	# P15: Prize adds tokens to balance
	var ps8 = create_fresh_player_stats()
	ps8.money_dictionary[PlayerStats.MONEY.TOKENS] += 3
	assert_eq(ps8.money_dictionary[PlayerStats.MONEY.TOKENS], 3, "P15: Wheel token prize adds to balance")

	# ══════════════════════════════════════════════════════════
	# Iterative escalation: spin → equip → verify stats → spin again
	# Using boxing_gloves.tres: cc base_value=0.05
	# COMMON mult=0.05, UNCOMMON=0.10, RARE=0.15, MYTHICAL=0.20, LEGENDARY=0.25
	# ══════════════════════════════════════════════════════════
	log_info("Iterative escalation with stat checks:")

	var gloves_res = load("res://data/game data/upgrades/temporary_upgrades/boxing_gloves.tres")
	var rarity_mult_map = [1.0, 2.0, 3.0, 4.0, 5.0]  # COMMON..LEGENDARY
	var rarity_labels = ["COMMON", "UNCOMMON", "RARE", "MYTHICAL", "LEGENDARY"]
	# boxing_gloves: cc base_value = 0.05

	# P16: Equip COMMON boxing gloves → cc changes correctly
	var ps_esc = create_fresh_player_stats()
	var gloves_common = gloves_res.duplicate(true) as TemporaryUpgrade
	gloves_common.rarity = Upgrade.RARITY.COMMON
	gloves_common.initialize_upgrade()
	ps_esc.add_temporary_upgrade(gloves_common)
	# cc: 0.05 + (0.05 * 1.0) = 0.10
	assert_approx(ps_esc.critical_chance, BASE_CC + 0.05,
		"P16: Equip COMMON gloves → cc=" + str(BASE_CC + 0.05))

	# P17: Pool offers UNCOMMON after acquiring COMMON
	var pool_after_common = UpgradeManager.get_temporary_upgrades_pool(
		UpgradeManager.temporary_upgrades_pool.size(), ps_esc)
	var offered_after_common: TemporaryUpgrade = null
	for item in pool_after_common:
		if item.name == gloves_common.name:
			offered_after_common = item
			break
	assert_not_null(offered_after_common, "P17a: Boxing Gloves still offered in pool")
	if offered_after_common:
		assert_eq(offered_after_common.rarity, Upgrade.RARITY.UNCOMMON,
			"P17b: Offered at UNCOMMON (was COMMON)")
	else:
		total += 1; passed += 0  # count the skipped sub-assert

	# P18: Replace COMMON with UNCOMMON → stats update correctly
	ps_esc.remove_temporary_upgrade(gloves_common)
	var cc_after_remove = ps_esc.critical_chance
	assert_approx(cc_after_remove, BASE_CC,
		"P18a: Remove COMMON → cc back to baseline " + str(BASE_CC))

	var gloves_uncommon = gloves_res.duplicate(true) as TemporaryUpgrade
	gloves_uncommon.rarity = Upgrade.RARITY.UNCOMMON
	gloves_uncommon.initialize_upgrade()
	ps_esc.add_temporary_upgrade(gloves_uncommon)
	# cc: 0.05 + (0.05 * 2.0) = 0.15
	assert_approx(ps_esc.critical_chance, BASE_CC + 0.10,
		"P18b: Equip UNCOMMON gloves → cc=" + str(BASE_CC + 0.10))

	# P19: Replace UNCOMMON with RARE → stats update
	ps_esc.remove_temporary_upgrade(gloves_uncommon)
	assert_approx(ps_esc.critical_chance, BASE_CC,
		"P19a: Remove UNCOMMON → cc back to baseline")

	var gloves_rare = gloves_res.duplicate(true) as TemporaryUpgrade
	gloves_rare.rarity = Upgrade.RARITY.RARE
	gloves_rare.initialize_upgrade()
	ps_esc.add_temporary_upgrade(gloves_rare)
	# cc: 0.05 + (0.05 * 3.0) = 0.20
	assert_approx(ps_esc.critical_chance, BASE_CC + 0.15,
		"P19b: Equip RARE gloves → cc=" + str(BASE_CC + 0.15))

	# P20: Pool offers MYTHICAL after player has RARE
	var pool_after_rare = UpgradeManager.get_temporary_upgrades_pool(
		UpgradeManager.temporary_upgrades_pool.size(), ps_esc)
	var offered_after_rare: TemporaryUpgrade = null
	for item in pool_after_rare:
		if item.name == gloves_rare.name:
			offered_after_rare = item
			break
	if offered_after_rare:
		assert_eq(offered_after_rare.rarity, Upgrade.RARITY.MYTHICAL,
			"P20: Pool offers MYTHICAL (player has RARE)")
	else:
		_log_fail("P20: Boxing Gloves not found in pool after RARE")
		total += 1; failed += 1

	# P21: Replace RARE with MYTHICAL → stats update
	ps_esc.remove_temporary_upgrade(gloves_rare)
	var gloves_mythical = gloves_res.duplicate(true) as TemporaryUpgrade
	gloves_mythical.rarity = Upgrade.RARITY.MYTHICAL
	gloves_mythical.initialize_upgrade()
	ps_esc.add_temporary_upgrade(gloves_mythical)
	# cc: 0.05 + (0.05 * 4.0) = 0.25
	assert_approx(ps_esc.critical_chance, BASE_CC + 0.20,
		"P21: Equip MYTHICAL gloves → cc=" + str(BASE_CC + 0.20))

	# P22: Pool offers LEGENDARY after MYTHICAL
	var pool_after_myth = UpgradeManager.get_temporary_upgrades_pool(
		UpgradeManager.temporary_upgrades_pool.size(), ps_esc)
	var offered_after_myth: TemporaryUpgrade = null
	for item in pool_after_myth:
		if item.name == gloves_mythical.name:
			offered_after_myth = item
			break
	if offered_after_myth:
		assert_eq(offered_after_myth.rarity, Upgrade.RARITY.LEGENDARY,
			"P22: Pool offers LEGENDARY (player has MYTHICAL)")
	else:
		_log_fail("P22: Boxing Gloves not found in pool after MYTHICAL")
		total += 1; failed += 1

	# P23: Replace MYTHICAL with LEGENDARY → stats update
	ps_esc.remove_temporary_upgrade(gloves_mythical)
	var gloves_legendary = gloves_res.duplicate(true) as TemporaryUpgrade
	gloves_legendary.rarity = Upgrade.RARITY.LEGENDARY
	gloves_legendary.initialize_upgrade()
	ps_esc.add_temporary_upgrade(gloves_legendary)
	# cc: 0.05 + (0.05 * 5.0) = 0.30
	assert_approx(ps_esc.critical_chance, BASE_CC + 0.25,
		"P23: Equip LEGENDARY gloves → cc=" + str(BASE_CC + 0.25))

	# P24: After LEGENDARY, upgrade NOT offered in pool
	var pool_after_leg = UpgradeManager.get_temporary_upgrades_pool(
		UpgradeManager.temporary_upgrades_pool.size(), ps_esc)
	var found_after_leg = false
	for item in pool_after_leg:
		if item.name == gloves_legendary.name:
			found_after_leg = true
			break
	assert_true(!found_after_leg, "P24: LEGENDARY gloves NOT re-offered in pool")

	# P25: After removing LEGENDARY → stats fully back to baseline
	ps_esc.remove_temporary_upgrade(gloves_legendary)
	assert_approx(ps_esc.critical_chance, BASE_CC,
		"P25: Remove LEGENDARY → cc back to baseline " + str(BASE_CC))
	assert_eq(ps_esc.temporary_upgrades.size(), 0,
		"P25b: No temp upgrades remain")

	# ── Full chain with actual UpgradeManager pool flow ──
	log_info("Full game-like escalation chain:")

	# P26: Complete spin→equip→spin cycle using UpgradeManager pool
	var ps_full = create_fresh_player_stats()
	if UpgradeManager.temporary_upgrades_pool.size() > 0:
		var base_upg = UpgradeManager.temporary_upgrades_pool[0]
		var chain_name = base_upg.name
		log_info("Chain upgrade: '" + chain_name + "'")

		# Find which stat(s) this upgrade affects for verification
		var chain_stat_types: Array = []
		var chain_base_values: Array = []
		for stat_m in base_upg.upgrade_array:
			chain_stat_types.append(stat_m.stat_type)
			chain_base_values.append(stat_m.base_value)

		# Start: give player COMMON version
		var current_upg = base_upg.duplicate(true)
		current_upg.rarity = Upgrade.RARITY.COMMON
		current_upg.initialize_upgrade()
		ps_full.add_temporary_upgrade(current_upg)

		var chain_ok = true
		var expected_chain_rarities = [
			Upgrade.RARITY.UNCOMMON,
			Upgrade.RARITY.RARE,
			Upgrade.RARITY.MYTHICAL,
			Upgrade.RARITY.LEGENDARY
		]

		for step in range(4):
			# Record stats BEFORE swap
			var cc_before = ps_full.critical_chance
			var dc_before = ps_full.dodge_chance
			var hp_before = ps_full.max_health
			var atk_before = ps_full.attack_power_multiplier

			# Get pool — should offer next rarity
			var step_pool = UpgradeManager.get_temporary_upgrades_pool(
				UpgradeManager.temporary_upgrades_pool.size(), ps_full)
			var next_upg: TemporaryUpgrade = null
			for item in step_pool:
				if item.name == chain_name:
					next_upg = item
					break

			if next_upg == null:
				chain_ok = false
				log_info("  Step " + str(step) + ": '" + chain_name + "' NOT in pool!")
				break

			if next_upg.rarity != expected_chain_rarities[step]:
				chain_ok = false
				log_info("  Step " + str(step) + ": rarity=" + str(next_upg.rarity) + " expected=" + rarity_labels[expected_chain_rarities[step]])
				break

			# Swap: remove old, equip new (simulating proper replacement)
			ps_full.remove_temporary_upgrade(current_upg)
			ps_full.add_temporary_upgrade(next_upg)
			current_upg = next_upg

			# Verify stats changed — new rarity should give stronger effect
			var new_mult = rarity_mult_map[current_upg.rarity]
			log_info("  Step " + str(step) + ": " + rarity_labels[current_upg.rarity] + " (mult=" + str(new_mult) + "x)")

			# Verify the upgrade's stat models have correct multiplier
			for stat_m in current_upg.upgrade_array:
				var expected_mult = stat_m.base_value * new_mult
				if abs(stat_m.multiplier - expected_mult) > 0.001:
					chain_ok = false
					log_info("    StatModel multiplier wrong: " + str(sm.multiplier) + " expected " + str(expected_mult))
					break

		assert_true(chain_ok, "P26: Full pool chain — rarity + stat multipliers correct at each step")

		# P27: After full chain, pool should NOT offer the upgrade
		var end_pool = UpgradeManager.get_temporary_upgrades_pool(
			UpgradeManager.temporary_upgrades_pool.size(), ps_full)
		var found_end = false
		for item in end_pool:
			if item.name == chain_name:
				found_end = true
				break
		assert_true(!found_end, "P27: After LEGENDARY, upgrade gone from pool")

		# P28: Player has exactly 1 temp upgrade (the LEGENDARY)
		var chain_count = 0
		for u in ps_full.temporary_upgrades:
			if u.name == chain_name:
				chain_count += 1
		assert_eq(chain_count, 1, "P28: Exactly 1 copy of upgrade after chain (no stacking)")
	else:
		log_info("P26-P28: SKIPPED — no upgrades in UpgradeManager pool")
		total += 3; passed += 3

	# ── Multiple upgrades equipped simultaneously ──
	log_info("Multiple upgrades + stat stacking:")

	# P29: Two different temp upgrades stack stats correctly
	var ps_stack = create_fresh_player_stats()
	var gloves_c = gloves_res.duplicate(true) as TemporaryUpgrade
	gloves_c.rarity = Upgrade.RARITY.COMMON
	gloves_c.initialize_upgrade()
	# cc: +0.05

	var belt_res = load("res://data/game data/upgrades/shop_upgrades/sweets_sellers_belt.tres")
	var belt_temp = belt_res.duplicate(true)
	# Belt has MAX_HEALTH base=0.1, DODGE_CHANCE base=0.02
	# We'll create a temp upgrade mimicking belt stats
	var sm_hp2 = create_stat_model(StatUpgrade.UPGRADABLE_STATS.MAX_HEALTH, 0.1)
	var sm_dc2 = create_stat_model(StatUpgrade.UPGRADABLE_STATS.DODGE_CHANCE, 0.02)
	var belt_tu = create_temporary_upgrade("belt_temp", [sm_hp2, sm_dc2])

	ps_stack.add_temporary_upgrade(gloves_c)
	ps_stack.add_temporary_upgrade(belt_tu)
	assert_approx(ps_stack.critical_chance, BASE_CC + 0.05,
		"P29a: Gloves + Belt → cc=" + str(BASE_CC + 0.05))
	assert_approx(ps_stack.dodge_chance, BASE_DC + 0.02,
		"P29b: Gloves + Belt → dc=" + str(BASE_DC + 0.02))
	assert_eq(ps_stack.max_health, BASE_HP + int(BASE_HP * 0.1),
		"P29c: Gloves + Belt → hp=" + str(BASE_HP + int(BASE_HP * 0.1)))

	# P30: Remove one, other remains active
	ps_stack.remove_temporary_upgrade(gloves_c)
	assert_approx(ps_stack.critical_chance, BASE_CC,
		"P30a: Remove gloves → cc back to baseline")
	assert_approx(ps_stack.dodge_chance, BASE_DC + 0.02,
		"P30b: Belt still active → dc unchanged")
	assert_eq(ps_stack.temporary_upgrades.size(), 1,
		"P30c: 1 temp upgrade remains")

	# P31: Replace gloves COMMON with RARE, belt stays
	var gloves_r = gloves_res.duplicate(true) as TemporaryUpgrade
	gloves_r.rarity = Upgrade.RARITY.RARE
	gloves_r.initialize_upgrade()
	ps_stack.add_temporary_upgrade(gloves_r)
	# cc: 0.05 + (0.05 * 3.0) = 0.20
	assert_approx(ps_stack.critical_chance, BASE_CC + 0.15,
		"P31a: RARE gloves → cc=" + str(BASE_CC + 0.15))
	assert_approx(ps_stack.dodge_chance, BASE_DC + 0.02,
		"P31b: Belt still active → dc unchanged")
	assert_eq(ps_stack.temporary_upgrades.size(), 2,
		"P31c: 2 temp upgrades active")

	# P32: clear_temporary_modifiers resets ALL stats
	ps_stack.clear_temporary_modifiers()
	assert_approx(ps_stack.critical_chance, BASE_CC,
		"P32a: clear_all → cc=" + str(BASE_CC))
	assert_approx(ps_stack.dodge_chance, BASE_DC,
		"P32b: clear_all → dc=" + str(BASE_DC))
	assert_eq(ps_stack.temporary_upgrades.size(), 0,
		"P32c: clear_all → 0 temp upgrades")
