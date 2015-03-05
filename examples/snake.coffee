# Signalicious example game of Snake

s = require "signalicious"

# enable error logging to see errors thrown during piping
s.channels.enableErrorLogging()

WIDTH   = 10
HEIGHT  = 10

DIRECTIONS = [
  [0,   1],
  [-1,  0],
  [0,  -1],
  [1,   0]
]

# update game state every 50ms
frame = s.producer.every(50)

  # if the snake is dead, the game is no longer update
  .pipe s.helpers.filter ->
    dead.value() == false

eats = s.stream()
  .pipe s.helpers.filter (snek) ->
    # if the snake's head collides with the apple, the snake eats it
    equal(snek[0], apple.value())

# the snake turns randomly
turns = s.producer.every(80)
  .pipe s.helpers.sync -> 
    Math.round(Math.random() * 2) - 1


collisions = s.stream()
  .pipe s.helpers.filter (snek) ->
    # if the snake has two parts on the same cell, the snake has collided with itself
    snek
      .filter (a) -> equal(a, snek[0])
      .length > 1


wrapTo = (length) -> (n) -> (n + length) % length
wrapToWidth = wrapTo WIDTH
wrapToHeight = wrapTo HEIGHT

# apple is placed randomly anywhere in the game view
getApple = ->
  getRand = (n) -> Math.floor(Math.random() * n)
  [getRand(WIDTH), getRand(HEIGHT)]

length    = -> score.value() + 3
addStep   = (head) -> 
  add(head, DIRECTIONS[direction.value()])

add       = ([x0, y0], [x1, y1]) -> [wrapToWidth(x0 + x1), wrapToHeight(y0 + y1)]
equal     = ([x0, y0], [x1, y1]) -> x0 == x1 && y0 == y1

include   = (a, squares) ->
  for b in squares
    if equal(a, b)
      return true

  false

score = s.signal(0)
  # when the snake eats an apple, score is incremented
  .merge eats, (value) -> value + 1

snake = s.signal([[5, 5]])
  # move the snake on every frame
  .merge frame, (value) -> 
    [addStep(value[0])].concat(value).slice(0, length())

# when the snake moves, check for treats
snake.to eats

# when the snake moves, check for collisions
snake.to collisions

apple = s.signal(getApple())
  # when the apple is eaten, create a new one
  .merge eats, getApple 

direction = s.signal(0)
  # when the snake is turning, update direction
  .merge turns, (value, n) -> wrapTo(DIRECTIONS.length) value + n


dead = s.signal(false)
  # when the snake collides, it drops dead
  .merge collisions, -> true


frame
  .pipe s.helpers.sync ->
    s = ""

    for y in [0..HEIGHT - 1]
      for x in [0..WIDTH - 1]
        cell = [x, y]
        if include(cell, snake.value())
          s += "#"
        else if equal(cell, apple.value())
          s += "o"
        else
          s += "."

      if y == 0
        s += " Score: #{score.value()}"
      else if y == 2
        if dead.value()
          s += " DEAD :("

      s += "\n"

    s

  # clear the screen before every draw
  .pipe s.helpers.prepend `'\033[2J'`
  .to s.channels.stdout

