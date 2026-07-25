--[[pod_format="raw",created="2026-07-23 07:34:50",modified="2026-07-25 17:12:23",revision=368]]
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
lives = 4

SHIP_SIZE = 16
SHIP_LIFE_FULL  = 7
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

PARTICLES_DURATION = 30
particles={}

function _init()
	cls(0)
	spawn_enemy()
end

function _draw()
	cls(1)
	draw_playfield()
	draw_starfield()
	draw_ship()
	draw_enemies()
	draw_bullets()
	--draw_explosions()
	draw_particles()
	draw_frame()
	draw_hud()
end

function draw_starfield()
	--pset(10,10,7)
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
		local col = 7
		local particle_palette = {7, 10, 9, 8, 2, 5}
		local progress = 1 - p.duration / PARTICLES_DURATION
		local index = flr(progress * (#particle_palette - 1)) + 1
		local col = particle_palette[index]
	
		--rectfill(p.x,p.y,p.x+1,p.y+1,7)
		circfill(p.x,p.y,p.size,col)
		p.x+=p.sx
		p.y+=p.sy
		
		p.sx *= 0.9
		p.sy *= 0.9
		
		p.duration-=1
		if p.duration < 0 then
			p.size -= 0.5
			if p.size <= 0 then
			 del(particles,p)
			end
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

function _update()

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

function explosion_old(x,y)
	local e = {
		x = x,
		y = y,
		duration = EXPLOSION_DURATION,
		animation = {64,65,66,67,68},
		frame = 1
	}
	add(explosions, e)
end

function explosion(x,y)

	local p = {
		x = x,
		y = y,
		sx = 0,
		sy = 0,
		size = 16,
		duration = PARTICLES_DURATION
	}
	add(particles, p)

	for i=1,50 do
		local p = {
			x = x,
			y = y,
			sx = (rnd() - 0.5) * 6,
			sy = (rnd() - 0.5) * 6,
			size = 1 + rnd (8),
			duration = PARTICLES_DURATION - rnd(PARTICLES_DURATION)
		}
		add(particles, p)
	end
end

function check_enemies_collision()
	if ship.invulnerable > 0 then
		return
	end

	for enemy in all(enemies) do 
		if collision(enemy, ship) then
			lives -= 1
			sfx(1)
			ship.invulnerable = SHIP_INVULNERABILITY
		end
	end
end

function check_bullets_collision()
	for enemy in all(enemies) do 
		for bullet in all(bullets) do 
			if collision(enemy, bullet) then
				sfx(3)
				del(bullets,bullet)
				enemy.hp -= 1
				enemy.flash = ENEMY_FLASH
				if enemy.hp <= 0 then
					del(enemies,enemy)
					explosion(enemy.x + enemy.w/2,enemy.y + enemy.h/2)
					sfx(2)
					score += 1
					spawn_enemy()
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
		enemy.y += 1
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
end

function spawn_enemy()
	local e = {
		x = GAME_X + rnd(GAME_WIDTH - ENEMY_SIZE),
		y = -ENEMY_SIZE,
		w = 16,
		h = 16,
		animation = {16,17,18,19},
		frame=1,
		hp=5,
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