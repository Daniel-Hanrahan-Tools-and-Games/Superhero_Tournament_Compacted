-- title: Superhero_Tournament_Compacted
-- author: Daniel Hanrahan Tools and Games
-- license: GNU GPL-3.0
-- version: 1
-- script: lua

-- =====================
-- BUTTON CONSTANTS
-- =====================
BTN_A = 4 -- Z key
BTN_B = 5 -- X key

-- =====================
-- GAME STATES
-- =====================
STATE_NOTICE = 0
STATE_BATTLE = 1

--notice for what is happening
game_state = STATE_NOTICE
turn = "player"
message = ""

players = {}
enemy = {}

-- =====================
-- CHARACTER TYPES
-- =====================
TYPE_NAMES = {"Tool", "Super", "Wizard", "Gamer"} -- 1..4

-- =====================
-- ACTION QUEUE FOR ATTACK DESCRIPTIONS
-- =====================
actionQueue = {}
actionStep = 0
queueActive = false

-- =====================
-- INITIALIZATION
-- =====================
function initBattle()
    players = {}
    enemy = {}

    players.type = math.random(1,4)
    enemy.type = math.random(1,4)

    players.max_hp = 100
    enemy.max_hp = 100

    players.hp = players.max_hp
    enemy.hp = enemy.max_hp

    players.attack = 5
    enemy.attack = 5

    players.extra = 0
    enemy.extra = 0

    applyTypeMatchup()
    turn = "player"
    message = ""
    actionQueue = {}
    actionStep = 0
    queueActive = false
end

function applyTypeMatchup()
    local p = players.type
    local e = enemy.type

    -- Gamer type has no advantage/disadvantage
    if p==4 or e==4 then
        players.attack = 7
        enemy.attack = 7
        message = "Neutral matchup!"
        return
    end
    -- gives each sides modifier
    if p==1 and e==3 then
        players.attack = 10
        message = "Tool > Wizard!"
    elseif p==2 and e==1 then
        players.attack = 10
        message = "Super > Tool!"
    elseif p==3 and e==2 then
        players.attack = 10
        message = "Wizard > Super!"
    elseif p==2 and e==3 then
        enemy.attack = 10
        message = "Super < Wizard!"
    elseif p==1 and e==2 then
        enemy.attack = 10
        message = "Tool < Super!"
    elseif p==3 and e==1 then
        enemy.attack = 10
        message = "Wizard < Tool!"
    else
        players.attack = 7
        enemy.attack = 7
        message = "Neutral matchup!"
    end
end

function _init()
    math.randomseed(time())
end

-- =====================
-- PLAYER & ENEMY TURNS
-- =====================
function playerTurn(action)
    if action == 1 then -- Attack
        actionQueue = {
            "Player jumps in the air!",
            "Player approaches Enemy!",
            "Player attacks Enemy!"
        }
        queueActive = true
    elseif action == 2 then -- Power-up
        players.attack = players.attack + 5
        message = "Player powers up!"
        turn = "enemy"
    end
end

function enemyTurn()
    local choice = math.random(0,1)
    if choice == 0 then -- Attack
        actionQueue = {
            "Enemy jumps in the air!",
            "Enemy approaches Player!",
            "Enemy attacks Player!"
        }
        queueActive = true
    else -- Power-up
        enemy.attack = enemy.attack + 5
        message = "Enemy powers up!"
        turn = "player"
    end
end

-- =====================
-- PROCESS ACTION QUEUE
-- =====================
function processQueue()
    if queueActive then
        message = actionQueue[actionStep+1]
        actionStep = actionStep + 1

        if actionStep == #actionQueue then
            -- Apply damage after last message
            if turn == "player" then
                enemy.hp = enemy.hp - players.attack
                turn = "enemy"
            else
                players.hp = players.hp - enemy.attack
                turn = "player"
            end
            -- Reset queue
            actionQueue = {}
            actionStep = 0
            queueActive = false
        end
    end
end

-- =====================
-- CHECK FOR WINNER
-- =====================
function checkBattleEnd()
    if players.hp <= 0 then
        message = "Enemy wins!"
        return true
    elseif enemy.hp <= 0 then
        message = "Player wins!"
        return true
    end
    return false
end

-- =====================
-- NOTICE SCREEN
-- =====================
function draw_notice()
    cls(0)
    print("Copyright (C) 2025 Daniel",0,10,12,false,1,true)
    print("Hanrahan Tools and Games",0,20,12,false,1,true)
    print("SPDX-License-Identifier: GPL-3.0-or-later",0,30,12,false,1,true)
    print("A copy of the GNU General Public License is",0,40,12,false,1,true)
    print("included in the file COPYING; if not, see",0,50,12,false,1,true)
    print("<https://www.gnu.org/licenses/>.",0,60,12,false,1,true)
    print("Information just about the stuff in this",0,70,12,false,1,true)
    print("software not covered by the GNU General",0,80,12,false,1,true)
    print("Public License version 3: This work is",0,90,12,false,1,true)
    print("licensed under Attribution-ShareAlike",0,100,12,false,1,true)
    print("4.0 International",0,110,12,false,1,true)
    print("PRESS Z TO START",80,120,12,false,1,true)
end

-- =====================
-- MAIN TIC FUNCTION
-- =====================
function TIC()
    -- Notice screen
    if game_state == STATE_NOTICE then
        if btnp(BTN_A) or btnp(BTN_B) then
            initBattle()
            game_state = STATE_BATTLE
        end
        draw_notice()
        return
    end

    -- Process action queue for attacks
    if queueActive then
        processQueue()
    else
        -- Player input
        if turn == "player" then
            if btnp(BTN_A) then playerTurn(1)
            elseif btnp(BTN_B) then playerTurn(2) end
        else
            enemyTurn()
        end
    end

    -- Restart after win/loss
    if checkBattleEnd() then
        if btnp(BTN_A) or btnp(BTN_B) then
            initBattle()
        end
    end

    -- DRAW
    cls(0)
    print("PLAYER HP: "..players.hp,10,10,12)
    print("PLAYER TYPE: "..TYPE_NAMES[players.type],10,20,12)
    print("ENEMY HP: "..enemy.hp,140,10,12)
    print("ENEMY TYPE: "..TYPE_NAMES[enemy.type],140,20,12)
    print("PLAYER ATK: "..players.attack,10,35,11)
    print("ENEMY ATK: "..enemy.attack,140,35,11)
    print(message,10,65,14)

    if turn == "player" and not queueActive then
        print("Z: Attack",10,90,10)
        print("X: Power Up",10,100,10)
    elseif queueActive then
        print("...",10,90,8)  -- indicate description in progress
    else
        print("Enemy turn...",10,90,8)
    end
end

-- =====================
-- INITIALIZE GAME
-- =====================
_init()

-- <TILES>
-- 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

