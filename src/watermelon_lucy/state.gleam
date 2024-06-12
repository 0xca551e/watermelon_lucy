import matter
import p5js_gleam.{type P5}
import p5js_gleam/bindings as p5
import watermelon_lucy/entity.{type Entity}

pub type State {
  State(
    entities: List(Entity),
    matter_engine: matter.Engine,
    show_hitboxes: Bool,
    lucy_image: p5js_gleam.P5Image,
  )
}

pub fn initial(p: P5) {
  let engine =
    matter.engine_create()
    |> matter.engine_set_position_iterations(12)
    |> matter.engine_set_velocity_iterations(8)

  let lucy_image = p5.load_image(p, "assets/lucy.png")

  State(
    entities: [],
    matter_engine: engine,
    show_hitboxes: False,
    lucy_image: lucy_image,
  )
}
