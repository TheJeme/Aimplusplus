
require 'gooi'

local gw
local gh
local points
local mx, my
local lives
local difficult
local targetSize
local time
local misses
local alive
local angle

function love.load()
  gw = love.graphics.getWidth()
  gh = love.graphics.getHeight()
  bigFont = love.graphics.newFont("roboto.ttf", 124)
  font = love.graphics.newFont("roboto.ttf", 54)
  littleFont = love.graphics.newFont("roboto.ttf", 18)
  hitSound = love.audio.newSource("Hit.wav", "static")
  missSound = love.audio.newSource("Miss.wav", "static")
  points = 0
  misses = 0
  lives = 3
  difficult = 1
  targetSize = 3
  time = 30
  alive = false

  listOfCircles = { }
  listofCrosses = { }

  createUI()

end

local elapsedTime = 0
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
  elapsedTime = elapsedTime + dt

  if(elapsedTime > 0.4) then
      createCircle()
      elapsedTime = 0
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
    love.graphics.rectangle('fill', gw / 2 + 225, gh / 2 - 175, 250, 300)
    love.graphics.rectangle('fill', gw / 2 - 475, gh / 2 - 175, 250, 300)
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
        love.event.quit()
      end
    end
end


function love.mousepressed(x, y,button)
  gooi.pressed()
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
          text = "Are you sure?",
          ok = function()
            love.event.quit()
          end
        })
      end)

      gooi.newLabel({x = gw / 2 + 250, y = gh / 2 - 100, text = "Difficulty"})
      spinnerDiff = gooi.newSpinner({x = gw / 2 + 325, y = gh / 2 - 100, min = 1, max = 3, value = difficult})
      gooi.newLabel({x = gw / 2 + 250, y = gh / 2 - 50, text = "Time"})
      spinnerTime = gooi.newSpinner({x = gw / 2 + 325, y = gh / 2 - 50, min = 0, max = 120, value = time})
      gooi.newLabel({x = gw / 2 + 250, y = gh / 2, text = "Target Size"})
      spinnerLifes = gooi.newSpinner({x = gw / 2 + 325, y = gh / 2, min = 0, max = 10, value = targetSize})
      gooi.newLabel({x = gw / 2 + 250, y = gh / 2 + 50, text = "Lives"})
      spinnerLifes = gooi.newSpinner({x = gw / 2 + 325, y = gh / 2 + 50, min = 0, max = 99, value = lifes})


      gooi.newLabel({x = gw / 2 - 350, y = gh / 2 - 160, text = "Stats"})

      gooi.newLabel({x = gw / 2 - 370, y = gh / 2 - 120, text = "0 Points"})
      gooi.newLabel({x = gw / 2 - 370, y = gh / 2 - 80, text = "290 Hits"})
      gooi.newLabel({x = gw / 2 - 370, y = gh / 2 - 40, text = "0 Misses"})
      gooi.newLabel({x = gw / 2 - 370, y = gh / 2, text = "75% Click Accuracy"})
      gooi.newLabel({x = gw / 2 - 370, y = gh / 2 + 40, text = "0% Target Efficiency"})
      gooi.newLabel({x = gw / 2 - 370, y = gh / 2 + 80, text = "0% Target Per Second"})



end

function startGame()
 alive = true
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
    love.graphics.print('Points: '.. points, 900, 0)
    love.graphics.print('Lifes: '.. lives, 1200, 0)
  love.graphics.pop()
end

function createCircle()
  circle = {}
  circle.x = love.math.random(80, gw - 80)
  circle.y = love.math.random(60, gh - 60)
  circle.radius = 4
  circle.maxRadius = 30
  circle.speed = 17
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
