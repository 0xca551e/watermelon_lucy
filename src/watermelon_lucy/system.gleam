import gleam/bool
import gleam/list
import gleam/result
import glector.{type Vector2, Vector2}
import matter
import p5js_gleam.{type P5}
import p5js_gleam/bindings as p5
import watermelon_lucy/constants
import watermelon_lucy/entity.{type Entity, Dropper, Lucy, Wall}
import watermelon_lucy/state.{type State, State}
import watermelon_lucy/util

pub fn spawn(entity: Entity) {
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

pub fn move_dropper(target_x: Float) {
  fn(state: State) {
    let next_entities =
      list.map(state.entities, fn(entity) {
        case entity {
          Dropper(x: _x) -> Dropper(x: target_x)
          _ -> entity
        }
      })
    #(State(..state, entities: next_entities), Nil)
  }
}

pub fn toggle_hitboxes() {
  fn(state: State) {
    #(State(..state, show_hitboxes: !state.show_hitboxes), Nil)
  }
}

pub fn draw_images(p: P5) {
  fn(state: State) {
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
            constants.lucy_level_1_size /. -2.0,
            constants.lucy_level_1_size /. -2.0,
            constants.lucy_level_1_size,
            constants.lucy_level_1_size,
          )
          |> p5.pop()
          Nil
        }
        Dropper(x: x) -> {
          p
          |> p5.push()
          |> p5.translate(x, constants.lucy_level_1_size /. 2.0)
          |> p5.image(
            state.lucy_image,
            constants.lucy_level_1_size /. -2.0,
            constants.lucy_level_1_size /. -2.0,
            constants.lucy_level_1_size,
            constants.lucy_level_1_size,
          )
          |> p5.pop()
          Nil
        }
        _ -> Nil
      }
    })
    #(state, Nil)
  }
}

pub fn draw_hitboxes(p: P5) {
  fn(state: State) {
    list.each(state.entities, fn(entity) {
      case entity {
        Lucy(body: body) | Wall(body: body) -> {
          {
            use <- bool.guard(!state.show_hitboxes, Nil)
            use _acc, part, i <- list.index_fold(
              matter.body_child_parts(body),
              Nil,
            )
            p
            |> p5.fill(result.unwrap(
              util.list_at(constants.hitbox_colors, i),
              "#00000088",
            ))
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
        _ -> Nil
      }
    })
    #(state, Nil)
  }
}

pub fn update_engine() {
  fn(state: State) {
    matter.engine_tick(state.matter_engine, 16.666)
    #(state, Nil)
  }
}
