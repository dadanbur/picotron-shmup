--[[pod_format="raw",created="2026-07-23 07:34:50",modified="2026-07-23 14:19:02",revision=190]]
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

SHIP_SIZE = 16

SHIP_LIFE_FULL  = 7
SHIP_LIFE_EMPTY = 15

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

ship = {
	x = GAME_X + (GAME_WIDTH - SHIP_SIZE) / 2,
	y = 230,
	speed = 2,
	sprite = 2,
	flame = { 
		animation = {4,5,4,6,4},
		frame = 1,
		speed = 0.4
	},
	muzzle = 0
}

BULLET_SPEED = 4
BULLET_SPRITE = 8
bullets = {}

function _init()
	cls(0)

end

function _draw()
	cls(1)
	draw_playfield()
	draw_starfield()
	draw_ship()
	draw_bullets()
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
	--print(ship.flame.sprite, HUD_X + MARGIN, 30, 7)
	for i = 1,max_lives do
		local sprite = SHIP_LIFE_FULL
		if (i > lives) then
			sprite = SHIP_LIFE_EMPTY
		end
		spr(sprite,(i*18)-6,12)
	end
end

function draw_ship()
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

function _update()
	update_ship()
	update_bullets()
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
	if btnp(5) then
		local bullet = {}
		bullet.x = ship.x
		bullet.y = ship.y - 8
		bullet.speed = BULLET_SPEED
		bullet.sprite = BULLET_SPRITE		
		add(bullets, bullet)
		sfx(0)
		ship.muzzle=10
		score+=10
	end
	
	update_muzzle()
	
	ship.x += dx
	ship.y += dy
	
	ship.x = mid(GAME_X, ship.x, GAME_X + GAME_WIDTH - SHIP_SIZE)
	ship.y = mid(GAME_Y, ship.y, GAME_Y + GAME_HEIGHT - SHIP_SIZE)
	
	update_flame()
		
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
		bullet.y += -4
	end
end