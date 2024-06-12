import act
import gleam/bool
import gleam/dynamic
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam_community/maths/elementary
import glector.{type Vector2, Vector2}
import matter
import p5js_gleam.{type P5}
import p5js_gleam/bindings as p5

pub fn list_at(in list: List(a), get index: Int) -> Result(a, Nil) {
  case index >= 0 {
    True ->
      list
      |> list.drop(index)
      |> list.first()
    False -> Error(Nil)
  }
}

const colors = [
  "#ff595e88", "#ffca3a88", "#8ac92688", "#1982c488", "#6a4c9388", "#db5c9f88",
]

const lucy_level_1_size = 100.0

const lucy_level_scale_factor = 1.5

type LucyBodyData {
  LucyBodyData(level: Int)
}

type Entity {
  Dropper(x: Float)
  Lucy(body: matter.Body)
  Wall(body: matter.Body)
}

type State {
  State(
    entities: List(Entity),
    matter_engine: matter.Engine,
    show_hitboxes: Bool,
    lucy_image: p5js_gleam.P5Image,
  )
}

fn get_quadratic_bezier_point(a: Vector2, b: Vector2, c: Vector2, t: Float) {
  let d = glector.lerp(a, b, t)
  let e = glector.lerp(b, c, t)
  glector.lerp(d, e, t)
}

fn glector_from_angle(angle: Float) -> Vector2 {
  Vector2(x: elementary.cos(angle), y: elementary.sin(angle))
}

fn make_lucy(x: Float, level: Int) {
  let tip_radius = 6.0
  let outer_radius = 46.0
  let inner_radius = 31.0

  let poly_parts =
    list.range(0, 4)
    |> list.map(fn(i) {
      let tip_angle = elementary.pi() /. -2.0
      let left_arm_angle = tip_angle -. elementary.pi() /. 5.0
      let right_arm_angle = tip_angle +. elementary.pi() /. 5.0

      let left_pit_offset =
        glector_from_angle(tip_angle -. elementary.pi() /. 2.0)
        |> glector.scale(tip_radius)
      let right_pit_offset =
        glector_from_angle(tip_angle +. elementary.pi() /. 2.0)
        |> glector.scale(tip_radius)
      let tip_direction = glector_from_angle(tip_angle)
      let tip_point =
        tip_direction
        |> glector.scale(outer_radius)
      let tip_control_point =
        tip_direction
        |> glector.scale(outer_radius +. tip_radius *. 1.3)
      let left_tip_point =
        tip_point
        |> glector.add(left_pit_offset)
      let right_tip_point =
        tip_point
        |> glector.add(right_pit_offset)
      let left_pit_point =
        glector_from_angle(left_arm_angle)
        |> glector.scale(inner_radius)
      let right_pit_point =
        glector_from_angle(right_arm_angle)
        |> glector.scale(inner_radius)
      let bezier_points =
        list.range(1, 4)
        |> list.map(fn(i) {
          get_quadratic_bezier_point(
            left_tip_point,
            tip_control_point,
            right_tip_point,
            int.to_float(i) /. 5.0,
          )
        })
      let body =
        matter.body_from_vertices(
          0.0,
          0.0,
          list.concat([
            [glector.zero, left_pit_point, left_tip_point, right_tip_point],
            bezier_points,
            [right_pit_point],
          ]),
        )
      matter.body_set_center(
        body,
        Vector2(x: 0.0, y: matter.body_get_bounds(body).max.y),
      )
      matter.body_set_position(body, Vector2(x: x, y: lucy_level_1_size /. 2.0))
      let angle = { 2.0 *. elementary.pi() *. int.to_float(i) } /. 5.0
      matter.body_set_angle(body, angle)
      body
    })
  let body =
    matter.body_create_from_parts(poly_parts)
    |> matter.body_set_user_data(dynamic.from(LucyBodyData(level: level)))
  Lucy(body: body)
}

fn make_wall(x: Float, y: Float, w: Float, h: Float) {
  Wall(body: matter.body_create_static_rectangle(x, y, w, h))
}

fn initial_state(p: P5) {
  let engine =
    matter.engine_create()
    |> matter.engine_set_position_iterations(12)
    |> matter.engine_set_velocity_iterations(8)

  let lucy_image = p5.load_image(p, "assets/lucy.png")

  p5.create_canvas(p, 400.0, 400.0)
  State(
    entities: [],
    matter_engine: engine,
    show_hitboxes: False,
    lucy_image: lucy_image,
  )
}

fn spawn(entity: Entity) {
  fn(state: State) {
    let next_entities = [entity, ..state.entities]
    case entity {
      Lucy(body) | Wall(body) -> {
        matter.world_add_body(
          matter.engine_get_world(state.matter_engine),
          body,
        )
      }
      _ -> Nil
    }
    #(State(..state, entities: next_entities), Nil)
  }
}

fn move_dropper(target_x: Float) {
  fn(state: State) {
    let next_entities =
      list.map(state.entities, fn(entity) {
        case entity {
          Dropper(x: x) -> Dropper(x: target_x)
          _ -> entity
        }
      })
    #(State(..state, entities: next_entities), Nil)
  }
}

fn toggle_hitboxes() {
  fn(state: State) {
    #(State(..state, show_hitboxes: !state.show_hitboxes), Nil)
  }
}

fn setup(p: P5) -> State {
  let result =
    initial_state(p)
    |> act.each([
      spawn(Dropper(0.0)),
      spawn(make_wall(200.0, 390.0, 400.0, 100.0)),
    ])
  result.0
}

fn update(state: State) {
  matter.engine_tick(state.matter_engine, 16.666)
  state
}

fn draw(p: P5, state: State) {
  p5.clear(p)
  list.each(state.entities, fn(entity) {
    case entity {
      Lucy(body: body) -> {
        let Vector2(x, y) = matter.body_get_position(body)
        let r = matter.body_get_angle(body)
        p
        |> p5.push()
        |> p5.translate(x, y)
        |> p5.rotate(r)
        |> p5.image(
          state.lucy_image,
          lucy_level_1_size /. -2.0,
          lucy_level_1_size /. -2.0,
          lucy_level_1_size,
          lucy_level_1_size,
        )
        |> p5.pop()
        Nil
      }
      _ -> Nil
    }
    case entity {
      Dropper(x: x) -> {
        p
        |> p5.push()
        |> p5.translate(x, lucy_level_1_size /. 2.0)
        |> p5.image(
          state.lucy_image,
          lucy_level_1_size /. -2.0,
          lucy_level_1_size /. -2.0,
          lucy_level_1_size,
          lucy_level_1_size,
        )
        |> p5.pop()
        Nil
      }
      Lucy(body: body) | Wall(body: body) -> {
        {
          use <- bool.guard(!state.show_hitboxes, Nil)
          use _acc, part, i <- list.index_fold(
            matter.body_child_parts(body),
            Nil,
          )
          p
          |> p5.fill(result.unwrap(list_at(colors, i), "#00000088"))
          |> p5.begin_shape()
          list.each(matter.body_get_vertices(part), fn(vertex) {
            p
            |> p5.vertex(vertex.x, vertex.y)
          })
          p
          |> p5.end_shape("close")
          Nil
        }
      }
    }
  })
}

fn on_mouse_moved(x: Float, _y: Float, state: State) {
  act.exec(move_dropper(x), state)
}

fn on_mouse_pressed(x: Float, _y: Float, state: State) {
  act.exec(spawn(make_lucy(x, 1)), state)
}

fn on_key_pressed(key: String, _keycode: Int, state: State) {
  case key {
    "b" -> act.exec(toggle_hitboxes(), state)
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
