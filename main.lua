--[[pod_format="raw",created="2026-07-23 07:34:50",modified="2026-07-26 09:41:35",revision=522]]
SCREEN_WIDTH  = 480
SCREEN_HEIGHT = 270

GAME_WIDTH  = 256
GAME_HEIGHT = 256

MARGIN = 7

GAME_X = MARGIN
GAME_Y = (SCREEN_HEIGHT - GAME_HEIGHT) / 2

HUD_X = GAME_X + GAME_WIDTH + MARGIN
HUD_Y = 0 
HUD_WIDTH = SCREEN_WIDTH - HUD_X


starfield={}
for i=1,100 do
	local x=GAME_X + flr(rnd(GAME_WIDTH))
	local y=GAME_Y + flr(rnd(GAME_HEIGHT))
	local s=rnd(1.5) + 0.5
	add(starfield,{x=x,y=y,speed=s})
end

score = 0
max_lives = 4
lives = 1
wave = 0

SHIP_SIZE = 16
SHIP_LIFE_FULL  = 14
SHIP_LIFE_EMPTY = 15
SHIP_INVULNERABILITY = 90
SHIP_BULLET_FREQ=8
ship = {
	x = GAME_X + (GAME_WIDTH - SHIP_SIZE) / 2,
	y = 230,
	w = SHIP_SIZE,
	h = SHIP_SIZE,
	speed = 2,
	sprite = 2,
	flame = { 
		animation = {4,5,4,6,4},
		frame = 1,
		speed = 0.4
	},
	muzzle = 0,
	invulnerable = 0,
	bullet_timer = 0
}

BULLET_SPEED = 4
BULLET_SPRITE = 8
bullets = {}

ENEMY_SIZE = 16
ENEMY_FLASH = 5
enemies={}

EXPLOSION_DURATION = 30
explosions={}

EXPLOSION_PARTICLES = 50
PARTICLES_DURATION = 30
PARTICLE_PALETTE_1 = {7,10,9,8,2,5}
PARTICLE_PALETTE_2 = {7,28,12,16,13,1}
particles={}

SHOCKWAVE_DURATION=30
SHOCKWAVE_SIZE=10
shockwaves={}

enemy_types = {
    [1] = {
        w = 16,
        h = 16,
        animation = {16,17,18,19},
        hp = 1,
        speed = 0.5,
        score = 100
    },
    [2] = {
        w = 16,
        h = 16,
        animation = {24,25},
        hp = 3,
        speed = 1,
        score = 200
    },
    [3] = {
        w = 16,
        h = 16,
        animation = {32,33,34,35},
        hp = 3,
        speed = 1,
        score = 200
    },
    [4] = {
        w = 16,
        h = 16,
        animation = {40,41,42,43},
        hp = 3,
        speed = 1,
        score = 200
    },
    [5] = {
        w = 28,
        h = 26,
        animation = {48},
        hp = 10,
        speed = 1,
        score = 500
    }
    
}

waves = {
	[1]={
		{0,1,1,1,1,1,1,1,1,0},
		{0,1,1,1,1,1,1,1,1,0},
		{0,1,1,1,1,1,1,1,1,0},
		{0,1,1,1,1,1,1,1,1,0}},
	[2]={
   	{1,1,2,2,1,1,2,2,1,1},
   	{1,1,2,2,1,1,2,2,1,1},
   	{1,1,2,2,2,2,2,2,1,1},
   	{1,1,2,2,2,2,2,2,1,1}},
	[3]={
   	{3,3,0,2,2,2,2,0,3,3},
  		{3,3,0,2,2,2,2,0,3,3},
   	{3,3,0,1,1,1,1,0,3,3},
   	{3,3,0,1,0,0,1,0,3,3}},
	[4]={
   	{0,0,0,0,0,0,0,0,0,0},
   	{0,0,0,0,5,0,0,0,0,0},
   	{0,0,0,0,0,0,0,0,0,0},
   	{0,0,0,0,0,0,0,0,0,0}}
}


--------------------------
-- STATE MACHINE
--------------------------

state_manager = {
    current = nil
}

function change_state(new_state)

    if state_manager.current and state_manager.current.leave then
        state_manager.current.leave()
    end

    state_manager.current = new_state

    if state_manager.current.enter then
        state_manager.current.enter()
    end
end

function update_state()
    state_manager.current.update()
end

function draw_state()
    state_manager.current.draw()
end

function _update()
    update_state()
end

function _draw()
    draw_state()
end

--------------------------
-- GAMEPLAY STATE
--------------------------

function gameplay_enter()
	--place_enemies()
end

function gameplay_update()
	update_ship()
	update_bullets()
	update_enemies()
	check_bullets_collision()
	check_enemies_collision()
	
	update_starfield()
end

function gameplay_draw()
	cls(1)
	draw_playfield()
	draw_starfield()
	draw_ship()
	draw_enemies()
	draw_bullets()
	draw_particles()
	draw_shockwaves()
	draw_frame()
	draw_hud()
end

gameplay_state = {
    enter = gameplay_enter,
    update = gameplay_update,
    draw = gameplay_draw
}

--------------------------
-- WAVE STATE
--------------------------
local wave_timer = 0

function wave_enter()
	wave_timer = 120
end

function wave_draw()
	gameplay_draw()
	local text = "WAVE "..wave
	local x = GAME_X + (GAME_WIDTH - #text * 8) / 2
	local y = GAME_Y + GAME_HEIGHT / 2 + 20

	print(text, x+1, y+1, 1)
	print(text, x, y, next_text_color())
end

function wave_update()
	gameplay_update()
	
	wave_timer -= 1
	if wave_timer <= 0 then
		change_state(gameplay_state)
	end
end

wave_state = {
    enter = wave_enter,
    update = wave_update,
    draw = wave_draw
}


--------------------------
-- GAMEOVER STATE
--------------------------

function gameover_enter()
end

function gameover_draw()
	cls(24)
	local text = "GAME OVER"
	local x = (SCREEN_WIDTH - #text * 8) / 2
	local y = GAME_Y + GAME_HEIGHT / 2 + 20

	print(text, x+1, y+1, 1)
	print(text, x, y, next_text_color())
end

function gameover_update()
	if btnp(5) then
		change_state(gameplay_state)
	end
end

gameover_state = {
    enter = gameover_enter,
    update = gameover_update,
    draw = gameover_draw
}


function _init()
	cls(0)
	--change_state(gameplay_state)
	change_state(wave_state)
end


local text_anim = {5,5,5,5,5,5,5,5,5,5,5,6,6,7,7,6,6,5}

text_frame = 1

function next_text_color()
    local c = text_anim[text_frame]

    text_frame += 1
    if text_frame > #text_anim then
        text_frame = 1
    end

    return c
end

function old_draw()
	cls(1)
	draw_playfield()
	draw_starfield()
	draw_ship()
	draw_enemies()
	draw_bullets()
	--draw_explosions()
	draw_particles()
	draw_shockwaves()
	draw_frame()
	draw_hud()
end

function draw_starfield()	
	for star in all(starfield) do
		local x = star.x
		local y = star.y
		local speed = star.speed
		local col = 6
		
		if speed < 1.5 then
			col = 13
		end		
		if speed < 1 then
			col = 1
		end
			
		--pset(10,10,7)
		rectfill(x,y,x+1,y+1,col)
	end
end

function update_starfield()
	for star in all(starfield) do
		star.y += star.speed
		if (star.y > GAME_Y + GAME_HEIGHT - 2) then
			star.y = GAME_Y
			star.x = GAME_X + flr(rnd(GAME_WIDTH))
		end	
	end
end

function draw_playfield() 
	rectfill(GAME_X,GAME_Y,GAME_X + GAME_WIDTH - 1, GAME_Y + GAME_HEIGHT - 1,0)
end

function draw_hud() 
	rectfill(HUD_X,0,SCREEN_WIDTH - 1, SCREEN_HEIGHT,1)
	print("SCORE: "..score, HUD_X + MARGIN, 20, 7)
	print("WAVE: "..wave, HUD_X + MARGIN, 30, 7)
	--print(ship.y, HUD_X + MARGIN, 20, 7)
	--print("BULLETS: "..#bullets, HUD_X + MARGIN, 30, 7)
	for i = 1,max_lives do
		local sprite = SHIP_LIFE_FULL
		if (i > lives) then
			sprite = SHIP_LIFE_EMPTY
		end
		spr(sprite,(i*18)-6,12)
	end
end

function draw_frame()
    -- TOP
    rectfill(
        GAME_X - MARGIN,
        GAME_Y - MARGIN,
        GAME_X + GAME_WIDTH + MARGIN,
        GAME_Y - 1,
        1
    )

    -- BOTTOM
    rectfill(
        GAME_X - MARGIN,
        GAME_Y + GAME_HEIGHT,
        GAME_X + GAME_WIDTH + MARGIN,
        GAME_Y + GAME_HEIGHT + MARGIN - 1,
        1
    )

    -- LEFT
    rectfill(
        GAME_X - MARGIN,
        GAME_Y,
        GAME_X - 1,
        GAME_Y + GAME_HEIGHT - 1,
        1
    )

    -- RIGHT
    rectfill(
        GAME_X + GAME_WIDTH,
        GAME_Y,
        GAME_X + GAME_WIDTH + MARGIN - 1,
        GAME_Y + GAME_HEIGHT - 1,
        1
    )
end

function draw_ship()
	if ship.invulnerable > 0 and ship.invulnerable % 4 < 2 then 
		return
	end

	spr(ship.sprite,ship.x,ship.y)
	
	local frame = flr(ship.flame.frame)
	spr(ship.flame.animation[frame],ship.x,ship.y + SHIP_SIZE)
	
	if ship.muzzle > 0 then
		local col = 7
		if ship.muzzle < 5 then
			col = 10
		end
		if ship.muzzle < 3 then
			col = 9
		end
		circfill(ship.x+7,ship.y,flr(ship.muzzle),col)
	end
end

function draw_bullets()
	for bullet in all(bullets) do
		spr(bullet.sprite,bullet.x,bullet.y)
	end
end

function draw_explosions()
	for e in all(explosions) do
		local frame_time = EXPLOSION_DURATION / #e.animation 
		local frame = flr((EXPLOSION_DURATION - e.duration) / (frame_time)) + 1
		e.frame = frame
		local sprite=e.animation[flr(e.frame)]
		spr(sprite,e.x,e.y)
		e.duration -= 1
		if e.duration <= 0 then
			del(explosions,e)
		end
	end
end

function draw_particles()
	for p in all(particles) do
		local particle_palette = PARTICLE_PALETTE_1
		
		if p.type == 2 then
			particle_palette = PARTICLE_PALETTE_2
		end
		
		local progress = 1 - p.duration / PARTICLES_DURATION
		local index = flr(progress * (#particle_palette - 1)) + 1
		local col = particle_palette[index]
	
		if p.type == 3 then
			rectfill(p.x,p.y,p.x+1,p.y+1,7)
		else
			circfill(p.x,p.y,p.size,col)
		end
		p.x+=p.sx
		p.y+=p.sy
		
		p.sx *= 0.9
		p.sy *= 0.9
		
		p.duration-=1
		if p.duration <= 0 then
			p.size -= 0.5
			if p.size <= 0 then
			 del(particles,p)
			end
		end
	end
end

function draw_shockwaves()
	for s in all(shockwaves) do
		circ(s.x,s.y,s.r,s.col)
		s.r+=s.speed
		if s.r > s.size then
			del(shockwaves,s)
		end
	end
end

function draw_enemies()
	for enemy in all(enemies) do
		if enemy.flash > 0 then
			enemy.flash -= 1
			for i = 1,15 do
				pal(i,7)
			end
		end
		local sprite=enemy.animation[flr(enemy.frame)]
		spr(sprite,enemy.x,enemy.y)
		pal()
	end
end

function old_update()

	update_ship()
	update_bullets()
	update_enemies()
	check_bullets_collision()
	check_enemies_collision()
	
	update_starfield()
end

function update_ship()
	local dx = 0
	local dy = 0
	
	ship.sprite = 2
	if btn(0) then
		dx = -ship.speed
		ship.sprite = 1
	end
	if btn(1) then
		dx = ship.speed 
		ship.sprite = 3
	end
	if btn(2) then
		dy = -ship.speed
	end
	if btn(3) then
		dy = ship.speed
	end
	if btn(5) and ship.bullet_timer <= 0 then
	 	shoot_bullet()
	end
	ship.bullet_timer -= 1
	
	update_muzzle()
	
	ship.x += dx
	ship.y += dy
	
	ship.x = mid(GAME_X, ship.x, GAME_X + GAME_WIDTH - SHIP_SIZE)
	ship.y = mid(GAME_Y, ship.y, GAME_Y + GAME_HEIGHT - SHIP_SIZE)
		
	update_flame()
	
	if ship.invulnerable > 0 then
		ship.invulnerable -= 1	
	end
		
end

function shoot_bullet()
	local bullet = {}
	bullet.x = ship.x
	bullet.y = ship.y - 8
	bullet.w = 16
	bullet.h = 16
	bullet.speed = BULLET_SPEED
	bullet.sprite = BULLET_SPRITE		
	add(bullets, bullet)
	sfx(0)
	ship.muzzle=10
	ship.bullet_timer = SHIP_BULLET_FREQ
end

function ship_explosion(x,y)
	local e = {
		x = x,
		y = y,
		duration = EXPLOSION_DURATION,
		animation = {64,65,66,67,68},
		frame = 1
	}
	add(explosions, e)
end

function explosion(x,y,_type)
	if _type == nil then
		_type = 1
	end

	local p = {
		x = x,
		y = y,
		sx = 0,
		sy = 0,
		size = 16,
		type = _type,
		duration = PARTICLES_DURATION
	}
	add(particles, p)

	for i=1,EXPLOSION_PARTICLES do
		local p = {
			x = x,
			y = y,
			sx = (rnd() - 0.5) * 6,
			sy = (rnd() - 0.5) * 6,
			size = 1 + rnd (8),
			type = _type,
			duration = PARTICLES_DURATION - rnd(PARTICLES_DURATION)
		}
		add(particles, p)
	end
	
	for i=1,EXPLOSION_PARTICLES do
		local p = {
			x = x,
			y = y,
			sx = (rnd() - 0.5) * 6,
			sy = (rnd() - 0.5) * 6,
			size = 1,
			type = 3,
			duration = PARTICLES_DURATION - rnd(PARTICLES_DURATION)
		}
		add(particles, p)
	end
	
	create_shockwave(x,y,SHOCKWAVE_SIZE*5,2,7)
end

function create_sparks(x,y)
	for i=1,2 do
		local p = {
			x = x,
			y = y,
			sx = (rnd() - 0.5) * 6,
			sy = (rnd() - 1) * 6,
			size = 1,
			type = 3,
			duration = PARTICLES_DURATION - rnd(PARTICLES_DURATION)
		}
		add(particles, p)
	end
end

function create_shockwave(x,y,size,speed,col)
	if size == nil then
		size = SHOCKWAVE_SIZE
	end
	if speed == nil then
		speed = 1
	end
	if col == nil then
		col = 9
	end
		
	local s = {
		x = x,
		y = y,
		r = 1,
		size = size,
		col = col,
		speed = speed,
		duration = SHOCKWAVE_DURATION
	}
	add(shockwaves, s)
end

function check_enemies_collision()
	if ship.invulnerable > 0 then
		return
	end

	for enemy in all(enemies) do 
		if collision(enemy, ship) then
			lives -= 1
			sfx(1)
			explosion(ship.x + ship.w/2,ship.y + ship.h/2,2)
			ship.invulnerable = SHIP_INVULNERABILITY
			
			if lives <= 0 then
				change_state(gameover_state)
			end
		end
	end
end

function check_bullets_collision()
	for enemy in all(enemies) do 
		for bullet in all(bullets) do 
			if collision(enemy, bullet) then
				sfx(3)
				del(bullets,bullet)
				create_shockwave(bullet.x + bullet.w/2, bullet.y + bullet.h/2) 
				create_sparks(enemy.x + enemy.w/2, enemy.y + enemy.h/2)
				enemy.hp -= 1
				enemy.flash = ENEMY_FLASH
				if enemy.hp <= 0 then
					del(enemies,enemy)
					explosion(enemy.x + enemy.w/2,enemy.y + enemy.h/2)
					sfx(2)
					score += enemy.score
					--spawn_enemy()
				end
				break
			end
		end
	end
end

function update_muzzle()
	if ship.muzzle > 0 then
		ship.muzzle -= 0.75
	end
end

function update_flame()
	ship.flame.frame += ship.flame.speed
	
	if ship.flame.frame > #ship.flame.animation then
		ship.flame.frame = 1
	end
end

function update_bullets()
	for bullet in all(bullets) do
		bullet.y -= bullet.speed
		
		if bullet.y < GAME_Y - 16 then
			del(bullets,bullet)
		end
	end
end

function update_enemies()
	for enemy in all(enemies) do
		--enemy.y += 1
		enemy.frame += 0.2
		if enemy.frame >= #enemy.animation + 1 then
			enemy.frame = 1
		end
		if enemy.y > GAME_Y + GAME_HEIGHT then
			del(enemies,enemy)
			spawn_enemy()
		end
		--enemy.x += rnd(2)-1
	end
	
	if #enemies == 0 then
		next_wave()
	end
end

function next_wave()
	wave += 1
	spawn_wave()
end

function spawn_wave()
	place_enemies()
end

function place_enemies()
	local e=waves[wave]
	
	for y = 1, #e do
		for x = 1,#e[y] do
			if e[y][x] != 0 then
				spawn_enemy(x*24-6,y*24+20,e[y][x])
			end
		end	
	end
end

function spawn_enemy(x,y,_type)
	local def = enemy_types[_type]
	
	local e = {
        x=x,
        y=y,
        w=def.w,
        h=def.h,
        type=_type,
        animation=def.animation,
        hp=def.hp,
        speed=def.speed,
        score=def.score,
        frame=1,
        flash=0
    }
		
	add(enemies,e)
end

function collision(a,b)
    return (
        a.x < b.x + b.w and
        a.x + a.w > b.x and
        a.y < b.y + b.h and
        a.y + a.h > b.y
    )
end