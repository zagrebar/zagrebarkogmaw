local orb = module.internal("orb");
local ts = module.internal("TS");
local pred = module.internal("pred");
local damagelib = module.internal("damagelib");
local menu = module.load(header.id, 'menu');

function round(x)
  return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

local q_input = {
    delay = 0.25,
    speed = 1650,
    width = 70,
    range = 1100, -- +100
    manacost = 40,
    boundingRadiusMod = 1,
    collision = {
      minion = true,
      wall = false,
      hero = true,
    },
  }

  local w_input = {
    --damage = function(target)
      
    --end,
    boundingRadiusMod = 0,
    delay = 0.1,
    range = function()
 
      return 500 + (110 + (player:spellSlot(1).level * 20))
    end,
  }

  local e_input = {
    delay = 0.25,
    speed = 1400,
    width = 120,
    range = 1200, -- + 150
    manacost = function()
      if player:spellSlot(2).state==0 then
        return 25 + (15 * player:spellSlot(2).level)
      else
        return 0
      end 
    end,
    boundingRadiusMod = 1,
  }



  local r_input = {
    delay = 1.35,
    speed = math.huge,
    radius = 240,
    boundingRadiusMod = 1,
    range = function()
      if player:spellSlot(3).state==0 then
        return (1050 + (250 * player:spellSlot(3).level))
      end
      return 1300
    end,
    manacost = function()
      if player.buff["kogmawlivingartillerycost"] then
        return 40 + (player.buff["kogmawlivingartillerycost"].stacks * 40) 
      else
        return 40
      end 
    end,
    damage = function(target)
      local dmg = function()
        if player:spellSlot(3).level > 0 then
          local basedmg = 60 + (40 * player:spellSlot(3).level)
          if ((target.health / target.maxHealth) * 100) > 40 then
            return basedmg + ((player.totalAp * 35) / 100) + ((player.bonusAd * 65) / 100) -- + 0.83 % 1  
          else 
            return (basedmg + ((player.totalAp * 35) / 100) + ((player.bonusAd * 65) / 100)) * 2
          end
        else
          return 0
        end
      end
      local damagemult = 100.0 / (100.0 + target.spellBlock)
      local damageafter = dmg() * damagemult
      return damageafter 
    end,
    collision = {
        minion = false,
        wall = false,
        hero = false,
    },
  }

  
local function trace_filter_q(seg, obj)
    if seg.startPos:dist(seg.endPos) > q_input.range then return false end
    
    if pred.trace.linear.hardlock(q_input, seg, obj) then
      return true
    end
    if pred.trace.linear.hardlockmove(q_input, seg, obj) then
      return true
    end
    if pred.trace.newpath(obj, 0.033, 0.500) then
      return true
    end

end

local function trace_filter_e(seg, obj)
  if seg.startPos:dist(seg.endPos) > e_input.range then return false end
  
  if pred.trace.linear.hardlock(e_input, seg, obj) then
    return true
  end
  if pred.trace.linear.hardlockmove(e_input, seg, obj) then
    return true
  end
  if pred.trace.newpath(obj, 0.033, 1) then
    return true
  end

end

local function trace_filter_r(seg, obj)
  if seg.startPos:dist(seg.endPos) > r_input.range() then return false end
  
  if pred.trace.circular.hardlock(r_input, seg, obj) then
    return true
  end
  if pred.trace.circular.hardlockmove(r_input, seg, obj) then
    return true
  end
  if pred.trace.newpath(obj, 0.033, 0.500) then
    return true
  end
end


local function target_filter_q(res, obj, dist)
  if dist > q_input.range then return false end
  local seg = pred.linear.get_prediction(q_input, obj)
  if not seg then return false end
  if not trace_filter_q(seg, obj) then return false end
  if pred.collision.get_prediction(q_input, seg, obj) then
    return false 
  end

  res.pos = seg.endPos
  return true
end
local function target_filter_w(res, obj, dist)
  if dist>w_input.range() then return false end

  res.obj = obj
  return true
end
local function target_filter_e(res, obj, dist)
  if dist > e_input.range then return false end
  local seg = pred.linear.get_prediction(e_input, obj)
  if not seg then return false end
  if not trace_filter_e(seg, obj) then return false end
  
  res.pos = seg.endPos
  return true
end

local function target_filter_r(res, obj, dist)
  if dist > r_input.range() then return false end
  local seg = pred.circular.get_prediction(r_input, obj)
  if not seg then return false end
  if not trace_filter_r(seg, obj) then return false end
  if ((obj.health / obj.maxHealth) * 100) > (menu.Combo.R.rHealth:get()) then return false end
  if menu.Combo.R.OnlyRange:get() then
    if dist < player.attackRange + 100 then return false end
  end
  res.pos = seg.endPos
  return true
end


local function Combo()

  if menu.Combo.Q.useQ:get() and player:spellSlot(0).state==0 then
    if not menu.Combo.Q.qafteraa:get() then
      if(menu.Combo.Misc.saveWMana:get()) then
        if(player.mana >= 80) then
          local res = ts.get_result(target_filter_q)
          if res.pos then
            player:castSpell('pos', 0, vec3(res.pos.x, mousePos.y, res.pos.y))
          end
        end
      else
        local res = ts.get_result(target_filter_q)
        if res.pos then
          player:castSpell('pos', 0, vec3(res.pos.x, mousePos.y, res.pos.y))
        end
      end
    end
  end

  if menu.Combo.W.useW:get() and player:spellSlot(1).state==0 then
    
    local res = ts.get_result(target_filter_w)
    if res.obj then
      print("slm")
      player:castSpell('self', 1)
    end
  end

  if menu.Combo.E.useE:get() and player:spellSlot(2).state==0 then
    if(menu.Combo.Misc.saveWMana:get()) then
      if player.mana > (e_input.manacost() + 40) then
        local res = ts.get_result(target_filter_e)
        if res.pos then
          player:castSpell('pos', 2, vec3(res.pos.x, mousePos.y, res.pos.y))
        end
      end
    else
      local res = ts.get_result(target_filter_e)
      if res.pos then
        player:castSpell('pos', 2, vec3(res.pos.x, mousePos.y, res.pos.y))
      end
    end
  end

  if menu.Combo.R.useR:get() and player:spellSlot(3).state==0 then
    if menu.Combo.Misc.saveWMana:get() then
      if player.mana > r_input.manacost() + 40 then
      local res = ts.get_result(target_filter_r)
      if res.pos then
        if not player.buff["kogmawlivingartillerycost"] then
          player:castSpell('pos', 3, vec3(res.pos.x, mousePos.y, res.pos.y))
        end
        if player.buff["kogmawlivingartillerycost"] then
          if player.buff["kogmawlivingartillerycost"].stacks <= menu.Combo.R.rStacks:get() then
            player:castSpell('pos', 3, vec3(res.pos.x, mousePos.y, res.pos.y))
          end
        end
      end
    end
    else
      local res = ts.get_result(target_filter_r)
      if res.pos then
        if not player.buff["kogmawlivingartillerycost"] then
          player:castSpell('pos', 3, vec3(res.pos.x, mousePos.y, res.pos.y))
        end
        if player.buff["kogmawlivingartillerycost"] then
          if player.buff["kogmawlivingartillerycost"].stacks <= menu.Combo.R.rStacks:get() then
            player:castSpell('pos', 3, vec3(res.pos.x, mousePos.y, res.pos.y))
          end
        end
      end
    end
  end


end

orb.combat.register_f_pre_tick(function()
    if orb.combat.is_active() then
      for i=0, objManager.enemies_n-1 do
        local obj = objManager.enemies[i]
        local v = graphics.world_to_screen(obj.pos)
        local rlasthit = math.floor((obj.health / r_input.damage(obj)))
        if rlasthit <= 4 then
          print(rlasthit)
        end
      end
      Combo()
    end
end)
local function after_attack()
  if orb.combat.is_active() then
    if menu.Combo.Q.qafteraa:get() then
      if menu.Combo.Misc.saveWMana:get() then
        if player.mana > 80 then
          local res = ts.get_result(target_filter_q)
          if res.pos then
            player:castSpell('pos', 0, vec3(res.pos.x, mousePos.y, res.pos.y))
          end
        end
      else
        local res = ts.get_result(target_filter_q)
        if res.pos then
          player:castSpell('pos', 0, vec3(res.pos.x, mousePos.y, res.pos.y))
        end
      end
    end
  end
end
orb.combat.register_f_after_attack(after_attack)

local function on_draw()
    if menu.Drawings.qDraw:get() then
      graphics.draw_circle(player.pos, q_input.range, 2, COLOR_GREEN, 64)
    end
    if menu.Drawings.wDraw:get() then
      graphics.draw_circle(player.pos, w_input.range() + player.boundingRadius, 2, COLOR_GREEN, 64)
    end
    if menu.Drawings.eDraw:get() then
      graphics.draw_circle(player.pos, e_input.range, 2, COLOR_GREEN, 64)
    end
    if menu.Drawings.rDraw:get() then
      graphics.draw_circle(player.pos, r_input.range(), 2, COLOR_GREEN, 64)
    end
    if menu.Drawings.rDamage:get() then
      for i=0, objManager.enemies_n-1 do
        local obj = objManager.enemies[i]
        local v = graphics.world_to_screen(obj.pos)
        local rlasthit = round(obj.health / r_input.damage(obj))
        local str = tostring(rlasthit)
        local newstr = str .. " R"
        if ((obj.health / obj.maxHealth) * 100) <= 40 then
          graphics.draw_text_2D(newstr, 50, v.x + 50, v.y - 40, COLOR_RED)
        end
      end
    end
end


cb.add(cb.draw, on_draw)
local function on_buff_gain(obj, buff)
  print('on_buff_gain', obj.name, buff.name)
end

local function on_buff_lose(obj, buff)
  print('on_buff_lose', obj.name, buff.name)
end

cb.add(cb.buff_gain, on_buff_gain)
cb.add(cb.buff_lose, on_buff_lose)