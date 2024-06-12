import gleam/list
import gleam_community/maths/elementary
import glector.{type Vector2, Vector2}

pub fn get_quadratic_bezier_point(a: Vector2, b: Vector2, c: Vector2, t: Float) {
  let d = glector.lerp(a, b, t)
  let e = glector.lerp(b, c, t)
  glector.lerp(d, e, t)
}

pub fn glector_from_angle(angle: Float) -> Vector2 {
  Vector2(x: elementary.cos(angle), y: elementary.sin(angle))
}

pub fn list_at(in list: List(a), get index: Int) -> Result(a, Nil) {
  case index >= 0 {
    True ->
      list
      |> list.drop(index)
      |> list.first()
    False -> Error(Nil)
  }
}
