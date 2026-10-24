-- Called from user-globals.lua when it exists (sets the default weapons)
function init_weaponns()
    -- Set the default weapons
    send_command('gs c set MainWeapons Perun')
    if player.sub_job == 'NIN' or player.sub_job == 'DNC' then
        send_command('wait 1; gs c set SubWeapons Kraken Club')
    else
        send_command('wait 1; gs c set SubWeapons Nusku Shield')
    end

end


-- For setups without user-globals.lua: a minimal table of which gear set each ranged weapon skill uses.
-- (If user-globals.lua has init_weapon_skill, that one is used instead.)
function init_ranger_weapon_skills()
    local ranged = {
        'Flaming Arrow', 'Piercing Arrow', 'Dulling Arrow', 'Sidewinder', 'Blast Arrow', 'Arching Arrow',
        'Empyreal Arrow', 'Namas Arrow', 'Refulgent Arrow', 'Apex Arrow', 'Sarv',
        'Hot Shot', 'Split Shot', 'Sniper Shot', 'Slug Shot', 'Blast Shot', 'Heavy Shot',
        'Detonator', 'Numbing Shot', 'Last Stand', 'Terminus',
    }
    local magic = {'Trueflight', 'Wildfire', 'Leaden Salute', 'Aeolian Edge'}
    for _, name in ipairs(ranged) do sets.precast.WS[name] = sets.precast.WS.Range end
    for _, name in ipairs(magic) do sets.precast.WS[name] = sets.precast.WS.Magic end
end


function init_gear_sets()
    -- Lockstyle number
    lockstyleset = 107

    -- Weapons
    gear['Naegling']        = {name="Naegling"}
    gear['Kustawi +1']        = {name="Kustawi +1"}
    gear['Kraken Club']    = {name="Kraken Club"}
    gear['Malevolence']      = {name="Malevolence"}
    gear['Perun']            = {name="Perun +1"}
    gear['Nusku Shield']      = {name="Nusku Shield"}
    gear['Armageddon']        = {name="Armageddon"}
    gear['Fomalhaut']    = {name="Fomalhaut"}
    gear['Sparrowhawk']      = {name="Sparrowhawk +2"}
    gear['Annihilator']    = {name="Annihilator"}
    gear['Gandiva']      = {name="Gandiva"}
    gear['Prime Gun']        = {name="Prime Gun"}
    gear['Hauksbok Arrow']    = {name="Hauksbok Arrow"}
    gear['Hauksbok Bullet']  = {name="Hauksbok Bullet"}
    gear.GunPhysics             = {name="Chrono Bullet"}
    gear.GunMagical             = {name="Chrono Bullet"}
    gear.BowPhysics             = {name="Artemis's Arrow"}
    gear.BowMagical             = {name="Artemis's Arrow"}
    gear.CrossbowPhysics        = {name="Bronze Bolt"}
    gear.CrossbowMagical        = {name="Bronze Bolt"}

    -- Idle (normal)
    sets.idle = {
    head="Nyame Helm",
    body="Nyame Mail",
    hands="Nyame Gauntlets",
    legs="Nyame Flanchard",
    feet="Nyame Sollerets",
        neck="Null Loop",
        waist="Null Belt",
    left_ear="Eabani Earring",
    right_ear="Etiolation Earring",
    left_ring="Defending Ring",
    right_ring="Shneddick Ring",
        back="Null Shawl",
    }

    -- Idle (refresh)
    sets.idle.Refresh = set_combine(sets.idle,{
        neck="Sibyl Scarf",
    })

    -- Engaged
    sets.engaged = {
        head="Malignance Chapeau",
        body="Malignance Tabard",
        hands="Amini Glove. +2",
        legs="Amini Bragues +3",
        feet="Malignance Boots",
        neck="Null Loop",
        waist={ name="Sailfi Belt +1", augments={'Path: A',}},
        left_ear="Crep. Earring",
        right_ear="Alabaster Earring",
        left_ring="Chirich Ring +1",
        right_ring="Chirich Ring +1",
        back="Null Shawl",
    }

    -- Subtle Blow 50
    sets.engaged.SubtleBlow = set_combine(sets.engaged,{
        head="Dampening Tam",
        hands={ name="Adhemar Wrist. +1", augments={'Accuracy+20','Attack+20','"Subtle Blow"+8',}},
        feet="Mummu Gamash. +2",
        waist={ name="Sailfi Belt +1", augments={'Path: A',}},
        right_ear="Digni. Earring",
        left_ring="Chirich Ring +1",
        right_ring="Chirich Ring +1",
    })

    -- Dual Wield 11 (sub NIN)
    sets.engaged.dual11= {waist="Reiki Yotai",left_ear="Eabani Earring",}
    
    -- Dual Wield 21 (sub DNC)
    sets.engaged.dual21= set_combine(sets.engaged.dual11,{back={ name="Camulus's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','"Dual Wield"+10','Phys. dmg. taken-10%',}},})

    -- Sets used while a buff is active
    sets.buff['Double Shot']       = set_combine(sets.midcast.RA,{
    head="Amini Gapette +2",
    body="Arc. Jerkin +4",
    hands="Oshosi Gloves +1",
    legs="Osh. Trousers +1",
    feet="Osh. Leggings +1",
    neck={ name="Scout's Gorget +2", augments={'Path: A',}},
    waist="Yemaya Belt",
    left_ear="Dedition Earring",
    right_ear="Telos Earring",
    left_ring="Cacoethic Ring +1",
    right_ring="Crepuscular Ring",
    back={ name="Belenus's Cape", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','"Store TP"+10',}},
        })

    --FC
    sets.precast.FC = {
        hands="Leyline Gloves",
        feet="Carmine Greaves",
        neck="Orunmila's Torque",
        waist="Cornelia's Belt",
        left_ear="Etiolation Earring",
        right_ear="Enchntr. Earring +1",
        left_ring="Murky Ring",
        right_ring="Rahab Ring",
    }
    sets.precast.FC.value = 35

    -- Snapshot
    sets.precast.RA = {
    head={ name="Taeon Chapeau", augments={'Accuracy+21','"Snapshot"+5','"Snapshot"+5',}},
    body="Amini Caban +3",
    hands="Oshosi Gloves +1",
    legs="Orion Braccae +3",
    feet="Meg. Jam. +2",
    waist="Yemaya Belt",
    left_ring="Crepuscular Ring",
    right_ring="Defending Ring",
    back={ name="Belenus's Cape", augments={'"Snapshot"+10',}},
    }

    -- Weapon skill: melee damage
    sets.precast.WS.Damage = {
    ammo="Hauksbok Arrow",
    head="Nyame Helm",
    body="Nyame Mail",
    hands="Nyame Gauntlets",
    legs="Nyame Flanchard",
    feet="Nyame Sollerets",
    neck="Rep. Plat. Medal",
    waist="Sailfi Belt +1",
    left_ear="Moonshade Earring",
    right_ear="Amini Earring +1",
    left_ring="Regal Ring",
    right_ring="Chirich Ring +1",
    back={ name="Belenus's Cape", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','Weapon skill damage +10%',}},
    }
    
    -- Weapon skill: ranged damage
    sets.precast.WS.Range = {
    head="Orion Beret +4",
    body="Amini Caban +3",
    hands="Malignance Gloves",
    legs="Arc. Braccae +4",
    feet="Amini Bottillons +3",
    neck={ name="Scout's Gorget +2", augments={'Path: A',}},
    waist="Fotia Belt",
    left_ear="Ishvara Earring",
    right_ear={ name="Amini Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+12','Mag. Acc.+12','Crit.hit rate+4',}},
    left_ring="Regal Ring",
    right_ring="Cornelia's Ring",
    back={ name="Belenus's Cape", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','Weapon skill damage +10%',}},
    }
    
    -- Weapon skill: ranged magic attack
    sets.precast.WS.Magic = {
        head="Nyame Helm",
        body="Nyame Mail",
        hands="Nyame Gauntlets",
        legs="Nyame Flanchard",
        feet="Nyame Sollerets",
        neck={ name="Comm. Charm +2", augments={'Path: A',}},
        waist="Orpheus's Sash",
        left_ear={ name="Moonshade Earring", augments={'Accuracy+4','TP Bonus +250',}},
        right_ear="Friomisi Earring",
        left_ring="Dingir Ring",
        right_ring="Epaminondas's Ring",
        back={ name="Belenus's Cape", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','Weapon skill damage +10%',}},
    }

    -- Weapon skill: Subtle Blow
    sets.precast.WS.SubtleBlow = sets.engaged.SubtleBlow
    
    -- Shared weapon skill definitions (use init_weapon_skill from user-globals.lua if it exists, otherwise the minimal table above)
    if init_weapon_skill then
        init_weapon_skill()
    else
        init_ranger_weapon_skills()
    end

    -- Per-weapon-skill sets
    sets.precast.WS["Coronach"] = set_combine(sets.precast.WS.Range,{
    head="Orion Beret +4",
    body="Amini Caban +3",
    hands="Amini Glove. +2",
    legs="Arc. Braccae +4",
    feet="Amini Bottillons +3",
    neck={ name="Scout's Gorget +2", augments={'Path: A',}},
    waist="Fotia Belt",
    left_ear="Domin. Earring +1",
    right_ear={ name="Amini Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+12','Mag. Acc.+12','Crit.hit rate+4',}},
    left_ring="Regal Ring",
    right_ring="Cacoethic Ring +1",
    back={ name="Belenus's Cape", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','Weapon skill damage +10%',}},
    })

    sets.precast.WS["Jishnu's Radiance"] = set_combine(sets.precast.WS.Range,{
    ammo="Artemis's Arrow",
    head="Blistering Sallet +1",
    body="Ikenga's Vest",
    hands="Nzame Bracers",
    legs="Amini Bragues +3",
    feet="Ikenga's Clogs",
    neck="Fotia Gorget",
    waist="Fotia Belt",
    left_ear="Odr Earring",
    right_ear={ name="Amini Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+12','Mag. Acc.+12','Crit.hit rate+4',}},
    left_ring="Regal Ring",
    right_ring="Ilabrat Ring",
    back={ name="Belenus's Cape", augments={'DEX+20','Rng.Acc.+20 Rng.Atk.+20','DEX+10','Crit.hit rate+10','Damage taken-5%',}},
    })

    sets.precast.WS["Savage Blade"] = set_combine(sets.precast.WS.Damage,
   {
    range="Sparrowhawk +2",
    ammo="Hauksbok Arrow",
    head="Nyame Helm",
    body="Nyame Mail",
    hands="Nyame Gauntlets",
    legs="Nyame Flanchard",
    feet="Nyame Sollerets",
    neck="Rep. Plat. Medal",
    waist="Sailfi Belt +1",
    left_ear="Moonshade Earring",
    right_ear={ name="Amini Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+12','Mag. Acc.+12','Crit.hit rate+4',}},
    left_ring="Regal Ring",
    right_ring="Cornelia's Ring",
    back="Null Shawl",
   })

    -- Ranged attack
    sets.midcast.RA = {
    head="Arcadian Beret +4",
    body="Ikenga's Vest",
    hands="Ikenga's Gloves",
    legs="Amini Bragues +3",
    feet="Ikenga's Clogs",
    neck={ name="Scout's Gorget +2", augments={'Path: A',}},
    waist="Yemaya Belt",
    left_ear="Dedition Earring",
    right_ear="Telos Earring",
    left_ring="Crepuscular Ring",
    right_ring="Chirich Ring +1",
    back={ name="Belenus's Cape", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','"Store TP"+10',}},
    }

    -- Ranged attack
    sets.midcast.RA.Double = {
    head="Amini Gapette +2",
    body="Arc. Jerkin +4",
    hands="Oshosi Gloves +1",
    legs="Osh. Trousers +1",
    feet="Osh. Leggings +1",
    neck={ name="Scout's Gorget +2", augments={'Path: A',}},
    waist="Yemaya Belt",
    left_ear="Dedition Earring",
    right_ear="Telos Earring",
    left_ring="Cacoethic Ring +1",
    right_ring="Crepuscular Ring",
    back={ name="Belenus's Cape", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','"Store TP"+10',}},
    }

    -- Ranged attack
    sets.midcast.RA.ACC = {
    head="Malignance Chapeau",
    body="Amini Caban +3",
    hands="Amini Glove. +2",
    legs="Amini Bragues +3",
    feet="Amini Bottillons +3",
    neck="Null Loop",
    waist="Yemaya Belt",
    left_ear="Telos Earring",
    right_ear={ name="Amini Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+12','Mag. Acc.+12','Crit.hit rate+4',}},
    left_ring="Cacoethic Ring +1",
    right_ring="Crepuscular Ring",
    back={ name="Belenus's Cape", augments={'AGI+20','Rng.Acc.+20 Rng.Atk.+20','AGI+10','"Store TP"+10',}},
    }
end
