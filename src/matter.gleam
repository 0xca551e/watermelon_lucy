import gleam/dynamic.{type Dynamic}
import glector.{type Vector2}

pub type Engine

pub type Body

pub type Bounds {
  Bounds(min: Vector2, max: Vector2)
}

@external(javascript, "./matter_ffi.mjs", "engine_create")
pub fn engine_create() -> Engine

@external(javascript, "./matter_ffi.mjs", "engine_set_position_iterations")
pub fn engine_set_position_iterations(engine: Engine, iterations: Int) -> Engine

@external(javascript, "./matter_ffi.mjs", "engine_set_velocity_iterations")
pub fn engine_set_velocity_iterations(engine: Engine, iterations: Int) -> Engine

@external(javascript, "./matter_ffi.mjs", "engine_tick")
pub fn engine_tick(engine: Engine, dt: Float) -> Nil

@external(javascript, "./matter_ffi.mjs", "engine_get_world")
pub fn engine_get_world(engine: Engine) -> Body

@external(javascript, "./matter_ffi.mjs", "world_add_body")
pub fn world_add_body(parent: Body, body: Body) -> Nil

@external(javascript, "./matter_ffi.mjs", "body_from_vertices")
pub fn body_from_vertices(x: Float, y: Float, vertices: List(Vector2)) -> Body

@external(javascript, "./matter_ffi.mjs", "body_set_center")
pub fn body_set_center(body: Body, center: Vector2) -> Body

@external(javascript, "./matter_ffi.mjs", "body_set_position")
pub fn body_set_position(body: Body, position: Vector2) -> Body

@external(javascript, "./matter_ffi.mjs", "body_set_angle")
pub fn body_set_angle(body: Body, angle: Float) -> Body

@external(javascript, "./matter_ffi.mjs", "body_get_position")
pub fn body_get_position(body: Body) -> Vector2

@external(javascript, "./matter_ffi.mjs", "body_get_angle")
pub fn body_get_angle(body: Body) -> Float

@external(javascript, "./matter_ffi.mjs", "body_get_bounds")
pub fn body_get_bounds(body: Body) -> Bounds

@external(javascript, "./matter_ffi.mjs", "body_create_from_parts")
pub fn body_create_from_parts(parts: List(Body)) -> Body

@external(javascript, "./matter_ffi.mjs", "body_set_user_data")
pub fn body_set_user_data(body: Body, data: Dynamic) -> Body

@external(javascript, "./matter_ffi.mjs", "body_create_static_rectangle")
pub fn body_create_static_rectangle(
  x: Float,
  y: Float,
  w: Float,
  h: Float,
) -> Body

@external(javascript, "./matter_ffi.mjs", "body_child_parts")
pub fn body_child_parts(body: Body) -> List(Body)

@external(javascript, "./matter_ffi.mjs", "body_get_vertices")
pub fn body_get_vertices(body: Body) -> List(Vector2)
