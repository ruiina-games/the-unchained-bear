# Shop UI/UX Fixes — Handoff

## What was done

### 1. Equipment slot icon fix (`Shop/slot_container.tscn`)
- **Icon size**: set `custom_minimum_size = Vector2(300, 300)` to keep consistent dimensions
- **Icon expand_mode**: changed from `3` (FIT_HEIGHT) to `1` (IGNORE_SIZE) — icon no longer resizes when equipping items with different texture sizes
- **Stats text color**: changed StatsName modulate from red `(0.999, 0.26, 0.20)` to soft yellow `(1, 0.95, 0.7)` for readability

### 2. Click-to-unequip (`Shop/slot_container.gd`, `Shop/shop.gd`)
- Added `signal slot_clicked(upgrade: Upgrade, slot_type: int)` to SlotContainer
- Added `_gui_input()` handler: left-click on equipped slot (except FIGHTING_STYLE) emits `slot_clicked`
- In `shop.gd`: connected `slot_clicked` to `_on_slot_clicked()` which calls `player_stats.unequip_upgrade(item)`
- Connection uses `is_connected()` guard to prevent duplicate connections on UI refresh

### 3. Stats display as custom tooltip (`Shop/slot_container.gd`)
- Item stats moved from inline Label to `tooltip_text` — prevents layout shifting when equipping items
- Added `_make_custom_tooltip()` override: dark panel with yellow border, font_size 32, yellow text on dark bg
- Empty slots show no tooltip

### 4. Stat-aware formatting (all three files)
- **Chances** (critical_chance, dodge_chance): `"5%"` format — `str(int(value * 100)) + "%"`
- **Multipliers** (attack_power, critical_damage, movement_speed, status_resist, effect_power): `"x1.2"` format
- **HP** (max_health): absolute integer `"2000"`
- `SlotContainer.format_stat_value()` is `static` — reused by `item_details.gd` via `SlotContainer.format_stat_value()`
- `stats_container.gd`: separate `format_multiplier()` and `format_chance()` methods (doesn't use enum, formats directly per-stat)

### 5. Inventory alignment (`Shop/shop.tscn`)
- `InventoryUpperContainer` alignment changed from `1` (CENTER) to `0` (BEGIN) — items start top-left

### 6. Tooltips on stat labels (`Shop/shop.tscn`)
- All 8 stat name Labels in the Stats panel now have English `tooltip_text`:
  - Damage Multiplier, Critical Chance, Critical Damage, Max Health, Status Resist, Movement Speed, Dodge Chance, Effect Power

### 7. Removed CurrentHealth from Stats (`Shop/shop.tscn`, `stats_container.gd`)
- Deleted `CurrentHeatlthContainer` node and children from shop.tscn
- Removed `current_health` @onready var and all references from stats_container.gd

## Files modified
| File | Summary |
|------|---------|
| `Shop/slot_container.tscn` | Icon 300x300, expand_mode=1, yellow stats color |
| `Shop/slot_container.gd` | signal + gui_input for unequip, stats as custom tooltip, static format_stat_value() |
| `Shop/shop.gd` | connect slot_clicked → unequip_upgrade |
| `Shop/shop.tscn` | alignment=0, stat tooltips, removed CurrentHealth node |
| `controllers/player controller/stats_container.gd` | format_multiplier/format_chance, removed current_health |
| `Shop/item_details.gd` | uses SlotContainer.format_stat_value(), removed old format_multiplier_text() |

## Known considerations
- The custom tooltip in `_make_custom_tooltip()` uses hardcoded style (font_size=32, colors). If game's UI scale changes, may need adjustment.
- `StatsName` Label still exists in slot_container.tscn but is always set to `""` — could be removed from .tscn if desired, but kept for backwards compatibility.
- Fighting style slot is intentionally non-unequippable (guarded in `_gui_input`).

## What to test
1. Open inventory → equip item → icon stays same size, no layout shift
2. Hover equipped slot → custom tooltip shows stats (large, yellow on dark)
3. Click equipped slot → item returns to inventory (except fighting style)
4. Stats tab → multipliers as `x1.2`, chances as `5%`, HP as number
5. Hover stat names in Stats tab → English tooltips appear
6. Current Health no longer in Stats panel
7. Inventory items start from top-left, not centered
