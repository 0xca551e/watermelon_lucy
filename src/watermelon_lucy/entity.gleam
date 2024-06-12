import gleam/dynamic
import gleam/int
import gleam/list
import gleam_community/maths/elementary
import glector.{type Vector2, Vector2}
import matter
import watermelon_lucy/constants
import watermelon_lucy/util

pub type Entity {
  Dropper(x: Float)
  Lucy(body: matter.Body)
  Wall(body: matter.Body)
}

type LucyBodyData {
  LucyBodyData(level: Int)
}

pub fn make_lucy(x: Float, level: Int) {
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
        util.glector_from_angle(tip_angle -. elementary.pi() /. 2.0)
        |> glector.scale(tip_radius)
      let right_pit_offset =
        util.glector_from_angle(tip_angle +. elementary.pi() /. 2.0)
        |> glector.scale(tip_radius)
      let tip_direction = util.glector_from_angle(tip_angle)
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
        util.glector_from_angle(left_arm_angle)
        |> glector.scale(inner_radius)
      let right_pit_point =
        util.glector_from_angle(right_arm_angle)
        |> glector.scale(inner_radius)
      let bezier_points =
        list.range(1, 4)
        |> list.map(fn(i) {
          util.get_quadratic_bezier_point(
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
      matter.body_set_position(
        body,
        Vector2(x: x, y: constants.lucy_level_1_size /. 2.0),
      )
      let angle = { 2.0 *. elementary.pi() *. int.to_float(i) } /. 5.0
      matter.body_set_angle(body, angle)
      body
    })
  let body =
    matter.body_create_from_parts(poly_parts)
    |> matter.body_set_user_data(dynamic.from(LucyBodyData(level: level)))
  Lucy(body: body)
}

pub fn make_wall(x: Float, y: Float, w: Float, h: Float) {
  Wall(body: matter.body_create_static_rectangle(x, y, w, h))
}

pub fn make_dropper(x: Float) {
  Dropper(x)
}
