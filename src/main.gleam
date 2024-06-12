import act
import p5js_gleam.{type P5}
import p5js_gleam/bindings as p5
import watermelon_lucy/entity
import watermelon_lucy/state.{type State}
import watermelon_lucy/system

fn setup(p: P5) -> State {
  p5.create_canvas(p, 400.0, 400.0)

  let result =
    state.initial(p)
    |> act.each([
      system.spawn(entity.make_dropper(0.0)),
      system.spawn(entity.make_wall(200.0, 390.0, 400.0, 100.0)),
    ])
  result.0
}

fn update(state: State) {
  act.exec(system.update_engine(), state)
}

fn draw(p: P5, state: State) {
  p5.clear(p)
  state
  |> act.each([system.draw_images(p), system.draw_hitboxes(p)])
}

fn on_mouse_moved(x: Float, _y: Float, state: State) {
  act.exec(system.move_dropper(x), state)
}

fn on_mouse_pressed(x: Float, _y: Float, state: State) {
  act.exec(system.spawn(entity.make_lucy(x, 1)), state)
}

fn on_key_pressed(key: String, _keycode: Int, state: State) {
  case key {
    "b" -> act.exec(system.toggle_hitboxes(), state)
    _ -> state
  }
}

pub fn main() {
  p5js_gleam.create_sketch(init: setup, draw: draw)
  |> p5js_gleam.set_on_tick(update)
  |> p5js_gleam.set_on_mouse_moved(on_mouse_moved)
  |> p5js_gleam.set_on_mouse_pressed(on_mouse_pressed)
  |> p5js_gleam.set_on_key_pressed(on_key_pressed)
  |> p5.start_sketch
}
