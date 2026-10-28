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
local hover_move_success = false

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
        if item and item.name == name then
            item_id_cache[name] = id
            return id
        end
    end
    item_id_cache[name] = false
    return nil
end

-------------------------------------------------------------------
-- Automatic ammo choice for ranged attacks (gun, bow, crossbow)
-------------------------------------------------------------------
function job_post_pretarget(spell, action, spellMap, eventArgs)
    -- Remove the expensive Hauksbok arrow/bullet if it is equipped, so it is not wasted on normal ranged attacks
    if (player.equipment.ammo == 'Hauksbok Arrow' or player.equipment.ammo == 'Hauksbok Bullet')
        and spell.name ~= 'Savage Blade' and spell.name ~= 'Aeolian Edge' then
        send_command('input /equip ammo')
    end

    if spell.action_type == 'Ranged Attack' then
        local range_item = player.equipment.range
        if range_item and gear then
            local item_id = get_item_id_by_name(range_item)
            if item_id and res.items[item_id] then
                local r_type = res.items[item_id].range_type
                if r_type == "Gun" and gear.GunPhysics then equip({ammo = gear.GunPhysics.name})
                elseif r_type == "Bow" and gear.BowPhysics then equip({ammo = gear.BowPhysics.name})
                elseif r_type == "Crossbow" and gear.CrossbowPhysics then equip({ammo = gear.CrossbowPhysics.name}) end
            end
        end
    elseif spell.name == 'Savage Blade' and gear['Hauksbok Arrow'] then
        equip({ammo=gear['Hauksbok Arrow'].name})
    elseif spell.name == 'Aeolian Edge' and gear['Hauksbok Bullet'] then
        equip({ammo=gear['Hauksbok Bullet'].name})
    end
end

-------------------------------------------------------------------
-- Hover Shot: just before shooting, check that you moved at least 1 Ym since the last shot
-------------------------------------------------------------------
function job_precast(spell, action, spellMap, eventArgs)
    if not spell then return end

    -- Check made right before a ranged attack or an Archery/Marksmanship weapon skill (melee weapon skills are not checked)
    if is_hover_shot_action(spell) then
        -- Get your current position
        local p_mob = windower.ffxi.get_mob_by_target('me')

        -- Only checked while the Hover Shot buff is active
        -- With no previous shot position (right after Hover Shot, or a new enemy) this is the first shot, so it is not checked
        local same_target = spell.target and spell.target.id == last_shot_target
        if p_mob and has_hover_shot_buff() and last_shot_pos and same_target then
            -- Straight-line distance (Ym) from the last shot position
            local dist = math.sqrt((p_mob.x - last_shot_pos.x)^2 + (p_mob.y - last_shot_pos.y)^2)

            if dist >= 1.0 then
                hover_move_success = true
                add_to_chat(6, '[Hover OK] Moved: ' .. string.format("%.2f", dist) .. ' Ym (stack kept)')
            else
                hover_move_success = false
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

    -- After the melee weapon skill, take the expensive ammo off right away
    if spell.name == 'Savage Blade' or spell.name == 'Aeolian Edge' then
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
-- send `//dp gun` or `//dp bow` to DistancePlus.
-- DistancePlus prints 5 chat lines every time it receives `//dp gun`. Sending it on every equipment/status update would flood the chat, so
-- remember the mode sent last and send only when it changes (after a GearSwap reload it is sent once again)
local last_dp_mode = nil
local function set_distanceplus(mode)
    if mode == last_dp_mode then return end
    last_dp_mode = mode
    windower.send_command('dp ' .. mode)
end

function job_state_change(stateField, newValue, oldValue)
    -- When the RangeWeapons selection changes
    if stateField == 'Range Weapons' or stateField == 'RangeWeapons' then
        if newValue == 'Annihilator' or newValue == 'Fomalhaut' or newValue == 'Armageddon' then
            -- Gun weapons switch to gun
            set_distanceplus('gun')
        elseif newValue == 'Gandiva' then
            -- Bow weapons switch to bow
            set_distanceplus('bow')
        end
    end

    -- Also call user_state_change from user-globals.lua, if it exists
    if user_state_change then
        user_state_change(stateField, newValue, oldValue)
    end
end

-- Also check the equipped ranged weapon whenever equipment or status is updated
function job_update(cmdParams, eventArgs)
    if not player or not player.equipment then return end
    local ranged_weapon = player.equipment.range
    
    if ranged_weapon then
        if ranged_weapon == 'Annihilator' or ranged_weapon == 'Fomalhaut' or ranged_weapon == 'Armageddon' then
            set_distanceplus('gun')
        elseif ranged_weapon == 'Gandiva' then
            set_distanceplus('bow')
        end
    end
end
