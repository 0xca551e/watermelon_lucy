import matter from "matter-js";
import * as gleam from "../prelude.mjs";

export function engine_create() {
  return matter.Engine.create();
}
export function engine_set_position_iterations(engine, iterations) {
  engine.positionIterations = iterations;
  return engine;
}
export function engine_set_velocity_iterations(engine, iterations) {
  engine.velocityIterations = iterations;
  return engine;
}
export function engine_tick(engine, dt) {
  matter.Engine.update(engine, dt);
}
export function engine_get_world(engine) {
  return engine.world;
}
export function world_add_body(parent, body) {
  matter.World.addBody(parent, body);
}
export function body_from_vertices(x, y, verticies) {
  return matter.Bodies.fromVertices(x, y, verticies.toArray());
}
export function body_set_center(body, x, y) {
  matter.Body.setCentre(body, x, y);
  return body;
}
export function body_set_position(body, x, y) {
  matter.Body.setPosition(body, x, y);
  return body;
}
export function body_set_angle(body, angle) {
  matter.Body.setAngle(body, angle);
  return body;
}
export function body_get_position(body) {
  return body.position;
}
export function body_get_angle(body) {
  return body.angle;
}
export function body_get_bounds(body) {
  return body.bounds;
}
export function body_create_from_parts(parts) {
  return matter.Body.create({
    parts: parts.toArray(),
    slop: 0.1,
  });
}
export function body_set_user_data(body, userData) {
  body.userData = userData;
  return body;
}
export function body_create_static_rectangle(x, y, w, h) {
  return matter.Bodies.rectangle(x, y, w, h, { isStatic: true });
}
export function body_child_parts(body) {
  const parts = body.parts;
  if (parts.length === 1) {
    return gleam.List.fromArray(parts);
  } else {
    return gleam.List.fromArray(parts.slice(1));
  }
}
export function body_get_vertices(body) {
  return gleam.toList(body.vertices);
}
