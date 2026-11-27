----------------------------------------------------------------------------------------
-- Ranger GearSwap script: Hover Shot movement check, removal of the expensive ammo after use, and automatic DistancePlus mode switching
----------------------------------------------------------------------------------------

function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
    set_language('english')
end

local res = require('resources')

-- Variables that remember where you last shot (same criterion as the hovershot addon)
local last_shot_pos = nil       -- Where the last shot finished {x, y}. While nil, the next first shot is not checked
local last_shot_target = nil    -- ID of the enemy shot last (the stack resets when the enemy changes)

local function reset_hover_shot()
    last_shot_pos = nil
    last_shot_target = nil
end

-- Checked actions: ranged attacks and Archery (25) / Marksmanship (26) weapon skills (melee weapon skills are not checked)
local function is_hover_shot_action(spell)
    if spell.action_type == 'Ranged Attack' then return true end
    if spell.type == 'WeaponSkill' then
        local ws = res.weapon_skills[spell.id]
        return ws ~= nil and (ws.skill == 25 or ws.skill == 26)
    end
    return false
end

local function has_hover_shot_buff()
    return buffactive['Hover Shot'] or buffactive[628]
end

function job_setup()
    state.Buff['Double Shot'] = buffactive['Double Shot'] or false
    state.IdleMode:options('Normal')
    state.OffenseMode:options('Normal','SubtleBlow','ACC')
    state.WeaponskillMode:options('Normal', 'SubtleBlow')
    state.RangedMode:options('Normal','Double','ACC')
    
    -- States for weapon switching (`gs c cycle MainWeapons` etc.; the actual weapon swap is done by user-globals.lua)
    state.MainWeapons  = M{'Naegling','Perun','Malevolence','Kraken Club'}
    state.SubWeapons   = M{'Kraken Club','Nusku Shield','Kustawi +1'}
    state.RangeWeapons = M{'Annihilator','Fomalhaut','Gandiva','Armageddon','Sparrowhawk'}
end

-- Remember each lookup by name, so a ranged attack no longer scans every item (tens of thousands) each time.
-- Names that were not found are remembered too. A gear change just asks for another name, so a stored answer never goes stale.
local item_id_cache = {}
function get_item_id_by_name(name)
    if name == nil then return nil end
    local cached = item_id_cache[name]
    if cached ~= nil then return cached or nil end
    for id, item in pairs(res.items) do
        if item and (item.name == name or item.ja == name or item.en == name) then
            item_id_cache[name] = id
            return id
        end
    end
    item_id_cache[name] = false
    return nil
end

-- Helper functions for ranged weapon type and matching physical ammo
local function range_type_of(item_name)
    local item_id = get_item_id_by_name(item_name)
    local item = item_id and res.items[item_id]
    return item and item.range_type or nil
end

local PHYSICS_AMMO_KEY = {Gun = 'GunPhysics', Bow = 'BowPhysics', Crossbow = 'CrossbowPhysics'}
local AMMO_TYPE_FOR = {Gun = 'Bullet', Bow = 'Arrow', Crossbow = 'Bolt'}
local HAUKSBOK_AMMO = {['Hauksbok Arrow'] = true, ['Hauksbok Bullet'] = true}

local function ammo_fits(r_type, ammo_name)
    if not ammo_name or ammo_name == 'empty' or HAUKSBOK_AMMO[ammo_name] then return false end
    local item_id = get_item_id_by_name(ammo_name)
    local item = item_id and res.items[item_id]
    return item ~= nil and item.ammo_type ~= nil and item.ammo_type == AMMO_TYPE_FOR[r_type]
end

-------------------------------------------------------------------
-- Automatic ammo choice for ranged attacks (gun, bow, crossbow)
-------------------------------------------------------------------
function job_post_pretarget(spell, action, spellMap, eventArgs)
    if not spell then return end
    local ammo_chosen = false
    local equipped_ammo = player and player.equipment and player.equipment.ammo
    local equipped_range = player and player.equipment and player.equipment.range

    -- Ranged attacks and Archery/Marksmanship weapon skills: pick matching physical ammo before shooting
    if is_hover_shot_action(spell) then
        local r_type = gear and range_type_of(equipped_range)
        local key = r_type and PHYSICS_AMMO_KEY[r_type]
        local physics = key and gear[key]
        if physics and (spell.action_type == 'Ranged Attack' or not ammo_fits(r_type, equipped_ammo)) then
            equip({ammo = physics.name})
            ammo_chosen = true
        end
    elseif spell.name == 'Savage Blade' and gear and gear['Hauksbok Arrow'] then
        equip({ammo=gear['Hauksbok Arrow'].name})
        ammo_chosen = true
    elseif spell.name == 'Aeolian Edge' and gear and gear['Hauksbok Bullet'] then
        equip({ammo=gear['Hauksbok Bullet'].name})
        ammo_chosen = true
    end

    -- Remove the expensive Hauksbok arrow/bullet unless we just selected ammo above
    if not ammo_chosen and equipped_ammo and HAUKSBOK_AMMO[equipped_ammo] then
        send_command('input /equip ammo')
    end
end

-------------------------------------------------------------------
-- Hover Shot: just before shooting, check that you moved at least 1 Ym since the last shot
-------------------------------------------------------------------
function job_precast(spell, action, spellMap, eventArgs)
    if not spell then return end

    -- Check made right before a ranged attack or an Archery/Marksmanship weapon skill (melee weapon skills are not checked)
    if is_hover_shot_action(spell) then
        -- Safety stop if Hauksbok ammo is still equipped (no physical ammo found)
        if player and player.equipment and HAUKSBOK_AMMO[player.equipment.ammo] then
            eventArgs.cancel = true
            cancel_spell()
            add_to_chat(123, '[RNG.lua] Shot cancelled because Hauksbok ammo is equipped (no matching physical ammo found)')
            return
        end

        -- Get your current position
        local p_mob = windower.ffxi.get_mob_by_target('me')

        -- Only checked while the Hover Shot buff is active
        -- With no previous shot position (right after Hover Shot, or a new enemy) this is the first shot, so it is not checked
        local same_target = spell.target and spell.target.id == last_shot_target
        if p_mob and has_hover_shot_buff() and last_shot_pos and same_target then
            -- Straight-line distance (Ym) from the last shot position
            local dist = math.sqrt((p_mob.x - last_shot_pos.x)^2 + (p_mob.y - last_shot_pos.y)^2)

            if dist >= 1.0 then
                add_to_chat(6, '[Hover OK] Moved: ' .. string.format("%.2f", dist) .. ' Ym (stack kept)')
            else
                add_to_chat(123, '[Hover NG] Moved: ' .. string.format("%.2f", dist) .. ' Ym (under 1 Ym, ranged attack cancelled)')
                
                -- If you did not move 1 Ym, cancel the ranged attack to keep the stack
                eventArgs.cancel = true
                return
            end
        end
        -- The position is recorded when the shot has actually finished (job_post_aftercast)
    end
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    if spell.action_type == 'Ranged Attack' then
        -- While Double Shot is active, switch to its own set (sets.buff)
        if buffactive['Double Shot'] then
            if sets.buff and sets.buff['Double Shot'] then
                equip(sets.buff['Double Shot'])
            end
        end
    elseif spell.name == 'Trueflight' or spell.name == 'Aeolian Edge' then
        if get_hachirin then
            equip(get_hachirin(spell.element))
        end
    end
end

function job_post_aftercast(spell, action, spellMap, eventArgs)
    -- Hover Shot: record where and at whom you shot, for the next comparison (not recorded if the shot was interrupted or out of range)
    if spell.english == 'Hover Shot' then
        reset_hover_shot()                  -- Using Hover Shot again resets the stack
    elseif is_hover_shot_action(spell) and not spell.interrupted then
        local p_mob = windower.ffxi.get_mob_by_target('me')
        if p_mob then
            last_shot_pos = {x = p_mob.x, y = p_mob.y}
            last_shot_target = spell.target and spell.target.id
        end
    end

    -- After the melee weapon skill, or if Hauksbok ammo remains equipped, take it off right away
    local equipped_ammo = player and player.equipment and player.equipment.ammo
    if spell.name == 'Savage Blade' or spell.name == 'Aeolian Edge' or (equipped_ammo and HAUKSBOK_AMMO[equipped_ammo]) then
        send_command('input /equip ammo')
    end
end

-- Reset the stack when the Hover Shot buff is gained or lost (same as the hovershot addon)
function job_buff_change(buff, gain, eventArgs)
    if buff == 'Hover Shot' then
        reset_hover_shot()
    end
end

-- Reset the stack when you change zones (GearSwap removes this handler by itself when the job file is reloaded)
windower.register_event('zone change', function()
    reset_hover_shot()
end)

-------------------------------------------------------------------
-- Automatic DistancePlus mode switching that follows the equipped ranged weapon and the weapon cycle (requires DistancePlus)
-------------------------------------------------------------------
-- When `gs c cycle RangeWeapons` changes the ranged weapon,
-- send `//dp gun`, `//dp bow`, or `//dp xbow` to DistancePlus.
-- DistancePlus prints 5 chat lines every time it receives a mode command. Sending it on every equipment/status update would flood the chat, so
-- remember the mode sent last and send only when it changes (after a GearSwap reload it is sent once again)
local last_dp_mode = nil
local function set_distanceplus(mode)
    if mode == last_dp_mode then return end
    last_dp_mode = mode
    windower.send_command('dp ' .. mode)
end

local DP_MODE = {Gun = 'gun', Bow = 'bow', Crossbow = 'xbow'}

local function update_distanceplus(item_name)
    local mode = DP_MODE[range_type_of(item_name) or '']
    if mode then set_distanceplus(mode) end
end

function job_state_change(stateField, newValue, oldValue)
    -- When the RangeWeapons selection changes
    if stateField == 'Range Weapons' or stateField == 'RangeWeapons' then
        local entry = gear and gear[newValue]
        update_distanceplus(type(entry) == 'table' and entry.name or newValue)
    end

    -- Also call user_state_change from user-globals.lua, if it exists
    if user_state_change then
        user_state_change(stateField, newValue, oldValue)
    end
end

-- Also check the equipped ranged weapon whenever equipment or status is updated (Sparrowhawk is for Savage Blade, excluded)
function job_update(cmdParams, eventArgs)
    if not player or not player.equipment then return end
    local ranged_weapon = player.equipment.range
    if ranged_weapon and not ranged_weapon:find('Sparrowhawk', 1, true) then
        update_distanceplus(ranged_weapon)
    end
end
