import sdl2

const DISPLAY_W: int = 64
const DISPLAY_H: int = 32

type
  Input {.pure.} = enum none, test, quit

  Emu = ref object
    inputs: array[Input, bool]
    renderer: RendererPtr
    # general purpose registers
    v: array[16, int]
    # special purpose/pseudo registers
    i, dt, st, pc, sp: int
    memory: array[4096, int]
    stack: array[16, int]
    display: array[DISPLAY_W * DISPLAY_H, int]

proc newEmu(renderer: RendererPtr): Emu =
  new result
  result.renderer = renderer

proc toInput(key: Scancode): Input =
  case key:
    of SDL_SCANCODE_Q: Input.quit
    of SDL_SCANCODE_SPACE: Input.test
    else: Input.none

proc handleInput(emu: Emu) =
  var event = defaultEvent

  while pollEvent(event):
    case event.kind:
      of QuitEvent:
        emu.inputs[Input.quit] = true
      of KeyDown:
        echo "Key pressed"
        emu.inputs[event.key.keysym.scancode.toInput] = true
      of KeyUp:
        echo "Key released"
        emu.inputs[event.key.keysym.scancode.toInput] = false
      else:
        discard

proc render(emu: Emu) =
  emu.renderer.clear()

  var rect: Rect
  rect.w = 10.cint
  rect.h = 10.cint

  for i, pixel in emu.display:
    if pixel == 1:
      echo i, "hello"
      setDrawColor(emu.renderer, 255, 255, 255, 0)
    else:
      setDrawColor(emu.renderer, 0, 0, 0, 0)

    rect.x = cint(10 * (i mod DISPLAY_W))
    rect.y = cint(10 * (i div DISPLAY_W))
    fillRect(emu.renderer, rect)

  emu.renderer.present()

when isMainModule:
  var
    win: WindowPtr
    ren: RendererPtr
  
  discard init(INIT_EVERYTHING)
  
  win = createWindow("Chip-8", 100, 100, 640, 320, SDL_WINDOW_SHOWN)
  
  if win == nil:
    echo "createWindow error: ", getError()
    quit(1)
  
  ren = createRenderer(win, -1, Renderer_Accelerated or Renderer_PresentVsync)
  
  if ren == nil:
    echo "createRenderer error: ", getError()
    quit(1)
  
  var emu = newEmu(ren)
  
  while not emu.inputs[Input.quit]:
    emu.handleInput()
    emu.render()
  
  destroy ren
  destroy win
  
  sdl2.quit()

