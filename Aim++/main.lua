
require 'gooi'

local gw
local gh
local points
local mx, my
local lives
local targets
local time
local misses
local misshits
local alive
local clicks
local playedYet
local elapsedTime
local elapsedTimer

function love.load()
  gw = love.graphics.getWidth()
  gh = love.graphics.getHeight()
  bigFont = love.graphics.newFont("roboto.ttf", 124)
  font = love.graphics.newFont("roboto.ttf", 52)
  littleFont = love.graphics.newFont("roboto.ttf", 18)
  arimoFont = love.graphics.newFont("Arimo-Bold.ttf", 13)
  hitSound = love.audio.newSource("Hit.wav", "static")
  missSound = love.audio.newSource("Miss.wav", "static")
  points = 0
  misses = 0
  misshits = 0
  clicks = 0
  lives = 3
  targets = 0
  time = 30
  elapsedTime = 0
  elapsedTimer = 0
  alive = false
  playedYet = false

  listOfCircles = { }
  listofCrosses = { }

  createUI()

end

function love.update(dt)
  gooi.update(dt)
  mx, my = love.mouse.getPosition()

  if alive == true then
  for i, v in ipairs(listOfCircles) do
    if v.radius < v.maxRadius and not v.reverse then
      v.radius = v.radius + v.speed * dt
    else if v.reverse and v.radius < 0 then
      table.remove(listOfCircles, i)
      misses = misses + 1
    else if v.reverse then
      v.radius = v.radius - v.speed * dt
    else
      v.reverse = true
        end
      end
    end
  end
end
  elapsedTime = elapsedTime + dt

  if(elapsedTime >= 2 / spinnerSpawnSpeed.value and alive) then
      createCircle()
      targets = targets + 1
      elapsedTime = 0
  end

  elapsedTimer = elapsedTimer + dt

    if(elapsedTimer >= 1.0) then
      elapsedTimer = 0
      time = time - 1
      if(time == 0) then
        die()
      end
    end
end

function love.draw()
  love.graphics.setBackgroundColor( 0.4, 0.4, 0.4, 1)
  if(alive) then
    createArea()
  else
    function love.mousereleased(x, y, button) gooi.released() end
    love.graphics.print("Made by Jeme", gw - 140, gh - 24)
    love.graphics.setFont(bigFont)
    love.graphics.print("Aim++", gw / 2 - 180, 140)
    love.graphics.setColor(0.3, 0.3, 0.3, 1)
    love.graphics.rectangle('fill', gw / 2 + 225, gh / 2 - 175, 250, 325)
    if (playedYet) then
      love.graphics.rectangle('fill', gw / 2 - 475, gh / 2 - 175, 250, 325)
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.setFont(arimoFont)
      love.graphics.printf("Stats", gw / 2 - 460, gh / 2 - 150, 222, 'center')
      love.graphics.printf(points .." Hits", gw / 2 - 460, gh / 2 - 100, 222, 'center')
      love.graphics.printf(clicks .." Clicks", gw / 2 - 460, gh / 2 - 60, 222, 'center')
      love.graphics.printf(misshits .." Missed Hits", gw / 2 - 460, gh / 2 - 20, 222, 'center')
      love.graphics.printf(misses .." Missed Targets", gw / 2 - 460, gh / 2 + 20, 222, 'center')
      love.graphics.printf(string.format("%0.2f", points / clicks) .."% Hit Accuracy", gw / 2 - 460, gh / 2 + 60, 222, 'center')
      love.graphics.printf(string.format("%0.2f", points / targets) .."% Target Efficiency", gw / 2 - 460, gh / 2 + 100, 222, 'center')
    end
    gooi.draw()
  end

  love.graphics.setColor(0.5, 0.5, 0.5, 1)
  love.graphics.setLineWidth(2)
  for i, v in ipairs(listofCrosses) do
    love.graphics.line(v.StartX1, v.StartY1, v.EndX1, v.EndY1)
    love.graphics.line(v.StartX2, v.StartY2, v.EndX2, v.EndY2)
  end

  love.graphics.setColor(1, 0, 0, 1)
  for i, v in ipairs(listOfCircles) do
    love.graphics.circle("fill", v.x, v.y, v.radius, 64)
  end

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setFont(littleFont)
  love.graphics.print("FPS: "..love.timer.getFPS())
end

function love.keypressed(key)
    if key == "escape" then
      if alive == true then
        die()
      else
        gooi.confirm({
          text = "Are you sure you want to exit?",
          ok = function()
            love.event.quit()
          end})
      end
    end
end


function love.mousepressed(x, y,button)
  if not alive then
    gooi.pressed()
  else
    playedYet = true
    clicks = clicks + 1
  end
  hit = false
  for i, v in ipairs(listOfCircles) do
   local isMouseOnCircle = mx > v.x - v.radius and mx < v.x + v.radius and
                            my > v.y - v.radius and my < v.y + v.radius
    if button == 1 and alive then
     if isMouseOnCircle then
           table.remove(listOfCircles, i)
           points = points + 1
           hit = true
           hitSound:play()
           break
       end
     end
   end
   if hit == false and alive then
    missSound:play()
    misshits = misshits + 1
    createCross()
    lives = lives - 1
    if lives == 0 then
          die()
        end
    end
  end

function die()
  alive = false
  listOfCircles = {}
  listofCrosses = {}
end

function createUI()
  style = {
    font = love.graphics.newFont("roboto.ttf", 13),
    showBorder = true,
    bgColor = {0.208, 0.220, 0.222}
  }

  gooi.setStyle(style)
  gooi.desktopMode()

    gooi.newLabel({x = gw / 2 + 320, y = gh / 2 - 160, text = "Settings"}):center()
    gooi.newButton({x = gw / 2 - 120, y = gh / 2 - 170, w = 240, h = 70, text = "Start"})
      :onRelease(function()
        startGame()
      end)
    gooi.newButton({x = gw / 2 - 120, y = gh / 2 - 60, w = 240, h = 70, text = "Highscores"})
    gooi.newButton({text = "Exit", x = gw / 2 - 120, y = gh / 2 + 50, w = 240, h = 70})
      :onRelease(function()
        gooi.confirm({
          text = "Are you sure you want to exit?",
          ok = function()
            love.event.quit()
          end
        })
      end)

      gooi.newLabel({x = gw / 2 + 250, y = gh / 2 - 100, text = "Difficulty"})
      spinnerDiff = gooi.newSpinner({x = gw / 2 + 325, y = gh / 2 - 100, min = 1, max = 10, value = 3})
      gooi.newLabel({x = gw / 2 + 250, y = gh / 2 - 50, text = "Time"})
      spinnerTime = gooi.newSpinner({x = gw / 2 + 325, y = gh / 2 - 50, min = 0, max = 240, value = 30})
      gooi.newLabel({x = gw / 2 + 250, y = gh / 2, text = "Target Size"})
      spinnerTargetSize = gooi.newSpinner({x = gw / 2 + 325, y = gh / 2, min = 1, max = 10, value = 3})
      gooi.newLabel({x = gw / 2 + 250, y = gh / 2 + 50, text = "Lives"})
      spinnerLifes = gooi.newSpinner({x = gw / 2 + 325, y = gh / 2 + 50, min = 0, max = 99, value = 5})
      gooi.newLabel({x = gw / 2 + 250, y = gh / 2 + 100, text = "Spawn Speed"})
      spinnerSpawnSpeed = gooi.newSpinner({x = gw / 2 + 325, y = gh / 2 + 100, min = 0, max = 99, value = 4})
end

function startGame()
 alive = true
 points = 0
 clicks = 0
 misses = 0
 misshits = 0
 targets = 0
 time = spinnerTime.value
 lives = spinnerLifes.value
end

function createArea()
  love.graphics.push()
  love.graphics.setColor(0.2, 0.2, 0.2, 1)
  love.graphics.setLineWidth(1)
  love.graphics.rectangle('fill', 80, 60, gw - 160, gh - 120)
  love.graphics.setColor(0.3, 0.3, 0.3, 1)
  for i=0, 11 do
    love.graphics.line(80 + 160 * i, 60, 80 + 160 * i, gh - 60)
    love.graphics.line(80, 60 + 160 * i, gw - 80, 60 + 160 * i)
  end
    love.graphics.setColor(1, 0.5, 0, 1)
    love.graphics.setFont(font)
    love.graphics.print('Time: '.. time, 600, 0)
    love.graphics.print('Hits: '.. points, 900, 0)
    love.graphics.print('Lifes: '.. lives, 1200, 0)
  love.graphics.pop()
end

function createCircle()
  circle = {}
  circle.x = love.math.random(90, gw - 90)
  circle.y = love.math.random(70, gh - 70)
  circle.radius = 1
  circle.maxRadius = 10 * spinnerTargetSize.value
  circle.speed = 5 * spinnerDiff.value
  circle.reverse = false

  table.insert(listOfCircles, circle)
end

function createCross()
  cross = {}
  cross.StartX1 = mx - 5
  cross.EndX1 = mx + 5
  cross.StartY1 = my - 5
  cross.EndY1 = my + 5
  cross.StartX2 = mx + 5
  cross.EndX2 = mx - 5
  cross.StartY2 = my - 5
  cross.EndY2 = my + 5

  table.insert(listofCrosses, cross)
end
