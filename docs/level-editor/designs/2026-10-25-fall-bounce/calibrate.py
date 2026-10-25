"""Geometric estimate for the submitted sketch; not a Godot play test.

120 Hz, current gravity/air drag/bounce formula, swept 22x30 AABB versus
20px straight wall strips. Sloped portals are a proposed geometric model:
the current game does not implement them yet. No player progress is read.
"""
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parent
DT, G, DRAG = 1 / 120, 900, 90
HALF = (11, 15)


def dot(a, b):
    return a[0] * b[0] + a[1] * b[1]


def sub(a, b):
    return (a[0] - b[0], a[1] - b[1])


def add(a, b):
    return (a[0] + b[0], a[1] + b[1])


def mul(a, k):
    return (a[0] * k, a[1] * k)


def vector(p):
    return (p['x'], p['y'])


def point(p):
    return {'x': p[0], 'y': p[1]}


def axes(item):
    a, b = vector(item['a']), vector(item['b'])
    delta = sub(b, a)
    size = math.hypot(*delta)
    t = mul(delta, 1 / size)
    return t, (t[1], -t[0])


def hull(pts):
    pts = sorted(set(pts))

    def cross(a, b, c):
        return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])

    lower, upper = [], []
    for p in pts:
        while len(lower) >= 2 and cross(lower[-2], lower[-1], p) <= 0:
            lower.pop()
        lower.append(p)
    for p in reversed(pts):
        while len(upper) >= 2 and cross(upper[-2], upper[-1], p) <= 0:
            upper.pop()
        upper.append(p)
    return lower[:-1] + upper[:-1]


def strip(a, b, thickness, half=HALF):
    delta = sub(b, a)
    size = math.hypot(*delta)
    n = (delta[1] / size, -delta[0] / size)
    corners = [add(p, mul(n, side * thickness / 2)) for p in (a, b) for side in (-1, 1)]
    return hull([(p[0] + sx * half[0], p[1] + sy * half[1]) for p in corners for sx in (-1, 1) for sy in (-1, 1)])


def sweep(start, end, poly):
    """Point against expanded convex polygon; returns first entering contact."""
    delta, lo, hi, normal = sub(end, start), 0.0, 1.0, None
    for a, b in zip(poly, poly[1:] + poly[:1]):
        edge = sub(b, a)
        n = (edge[1], -edge[0])
        size = math.hypot(*n)
        n = mul(n, 1 / size)
        distance, speed = dot(sub(start, a), n), dot(delta, n)
        if abs(speed) < 1e-10:
            if distance > 1e-8:
                return None
            continue
        at = -distance / speed
        if speed < 0:
            if at >= lo - 1e-9:
                lo, normal = max(lo, at), n
        else:
            hi = min(hi, at)
        if lo > hi + 1e-9:
            return None
    if normal is None or lo < -1e-8 or lo > 1 + 1e-8 or hi < 0:
        return None
    return lo, normal


def world(data, portal=None, half=HALF):
    result = []
    for item in data['items']:
        if not item['type'].startswith('wall-'):
            continue
        a, b = vector(item['a']), vector(item['b'])
        if portal and item['id'] in portal:
            center = portal[item['id']]
            t, _ = axes(item)
            spans = [(a, add(center, mul(t, -36))), (add(center, mul(t, 36)), b)]
        else:
            spans = [(a, b)]
        for left, right in spans:
            if math.dist(left, right) > .01:
                result.append((item['id'], strip(left, right, item['thickness'], half)))
    return result


def cast(a, b, solids):
    found = []
    for ident, polygon in solids:
        contact = sweep(a, b, polygon)
        if contact:
            found.append((contact[0], ident, contact[1]))
    return min(found, default=None, key=lambda hit: hit[0])


def simulate(data, entry_x=420, exit_along=0, bounce_enabled=True):
    items = {item['id']: item for item in data['items']}
    t_out, n_out = axes(items[8])
    exit_center = add((640, 302), mul(t_out, exit_along))
    entry = (entry_x, 500)
    solids = world(data, {5: (entry_x, 510), 8: exit_center})
    origin, velocity = (243.0, 185.0), (210.0, 0.0)
    paths, events = [], []

    def flight(origin, velocity, stage):
        trace = [origin]
        for frame in range(1200):
            vx, vy = velocity
            if stage != 'fall':
                vx = math.copysign(max(0, abs(vx) - DRAG * DT), vx)
            velocity = (vx, vy + G * DT)
            end = add(origin, mul(velocity, DT))
            crossing = None
            if stage == 'fall' and origin[1] <= entry[1] <= end[1]:
                frac = (entry[1] - origin[1]) / (end[1] - origin[1])
                p = add(origin, mul(sub(end, origin), frac))
                if abs(p[0] - entry_x) + 11 <= 36:
                    crossing = (frac, p)
            contact = cast(origin, end, solids)
            if crossing and (not contact or crossing[0] < contact[0]):
                trace.append(crossing[1])
                return {'kind': 'portal', 'p': crossing[1], 'v': velocity, 'seconds': (frame + crossing[0]) * DT, 'trace': trace}
            if contact:
                frac, ident, normal = contact
                p = add(origin, mul(sub(end, origin), frac))
                trace.append(p)
                return {'kind': 'wall', 'id': ident, 'n': normal, 'p': p, 'v': velocity, 'seconds': (frame + frac) * DT, 'trace': trace}
            if end[0] < 11 or end[0] > 949 or end[1] < 15 or end[1] > 555:
                return {'kind': 'boundary', 'p': end, 'v': velocity, 'trace': trace}
            origin = end
            trace.append(origin)
        return {'kind': 'timeout', 'trace': trace}

    first = flight(origin, velocity, 'fall')
    paths.append(first.pop('trace'))
    events.append(first)
    if first['kind'] != 'portal':
        return {'success': False, 'events': events, 'paths': paths}
    speed = math.hypot(*first['v'])
    # Tangential offset on the input is preserved, as in current transport.
    offset = first['p'][0] - entry_x
    face = add(exit_center, mul(n_out, 10))
    half_n = abs(n_out[0]) * 11 + abs(n_out[1]) * 15
    destination = add(add(face, mul((-n_out[1], n_out[0]), offset)), mul(n_out, half_n + 1))
    second = flight(destination, mul(n_out, speed), 'to_blue')
    paths.append(second.pop('trace'))
    events.append(second)
    if second['kind'] != 'wall' or second.get('id') != 3:
        return {'success': False, 'events': events, 'paths': paths}
    normal, incoming = second['n'], dot(second['v'], second['n'])
    minimum = 580 if normal[1] < -.5 else 420
    bounced = sub(second['v'], mul(normal, incoming))
    if bounce_enabled:
        bounced = add(bounced, mul(normal, min(900, max(minimum, -incoming))))
    third = flight(add(second['p'], mul(normal, .02)), bounced, 'to_goal')
    paths.append(third.pop('trace'))
    events.append(third)
    success = third['kind'] == 'wall' and third.get('id') == 10 and third['n'][1] < -.99
    return {'success': success, 'entry_speed': speed, 'exit_normal': n_out, 'bounce_velocity': bounced, 'events': events, 'paths': paths}


def revised():
    data = json.loads((ROOT / 'input.json').read_text(encoding='utf-8'))
    geometry = {1: ((70, 210), (230, 210)), 2: ((220, 210), (220, 295)), 3: ((220, 295), (300, 420)), 4: ((300, 420), (300, 510)), 5: ((360, 510), (480, 510)), 7: ((610, 510), (610, 410)), 8: ((610, 410), (660, 230)), 9: ((660, 230), (660, 210)), 10: ((650, 210), (900, 210))}
    for item in data['items']:
        if item['id'] in geometry:
            item['a'], item['b'] = map(point, geometry[item['id']])
        if item['type'] in ('start', 'goal'):
            item['y'] = 200
    data['title'] = '草图01 · 落差折返（比例修订）'
    data['notes'] = '路线：先走到起点右沿，看见两处白面后放门；后退至约x160，再向右助跑出平台，保持D直到落入底部门；出门后松开横向键，右侧陡白面向左上射出；碰蓝斜面折返到右侧平台，落地后走到终点。底部白带收短为120px，两侧补灰地，以免底部同时放两门绕过蓝面。保持原有物理。曲线是计算模型的示意，不是Godot实测；斜面门还需实现。'
    for ident, a, b in ((15, (300, 510), (360, 510)), (16, (480, 510), (610, 510))):
        data['items'].append({'id': ident, 'type': 'wall-gray', 'a': point(a), 'b': point(b), 'thickness': 20})
    data['nextId'] = 17
    return data


def probe_full_white_floor(data, entry_speed):
    """Counterexample to requiring the blue wall if the full floor is white."""
    candidate = json.loads(json.dumps(data))
    candidate['items'] = [i for i in candidate['items'] if i['id'] not in (15, 16)]
    floor = next(i for i in candidate['items'] if i['id'] == 5)
    floor['a'], floor['b'] = point((300, 510)), point((610, 510))
    solids, position, velocity = world(candidate), (560., 484.), (0., -entry_speed)
    for frame in range(600):
        vx, vy = velocity
        if vx < 210:
            vx += 380 * DT
        velocity = vx, vy + G * DT
        end = add(position, mul(velocity, DT))
        hit = cast(position, end, solids)
        if hit:
            frac, ident, n = hit
            return {'lands_goal_platform': ident == 10 and n[1] < -.99, 'first_wall': ident, 'p': add(position, mul(sub(end, position), frac)), 'note': 'two portals on a 310px white floor, upward exit at x560; not available after white band shrinks to120px'}
        position = end
    return {'lands_goal_platform': False}


def main():
    # Basic geometric sanity check: AABB center reaches x=89 at a wall x=100.
    test = cast((0, 50), (200, 50), [(1, strip((110, 0), (110, 100), 20))])
    assert test and abs(test[0] * 200 - 89) < 1e-6 and test[2][0] < -.99
    data = revised()
    result = simulate(data)
    if result['success']:
        # Least-squares control point for each computed trajectory, constrained
        # to the existing editor's paper, rather than claiming exact flight.
        for item, path in zip([i for i in data['items'] if i['type'] == 'path'], result['paths']):
            a, b = path[0], path[-1]
            sums = [0., 0.]
            denom = 0.
            for j, p in enumerate(path):
                t = j / (len(path) - 1)
                w = 2 * t * (1 - t)
                for axis in (0, 1):
                    sums[axis] += w * (p[axis] - (1 - t) ** 2 * a[axis] - t ** 2 * b[axis])
                denom += w * w
            control = (max(0, min(960, sums[0] / denom)), max(0, min(540, sums[1] / denom)))
            item['a'], item['b'], item['control'] = point(a), point(b), point(control)
    tolerance = []
    for dx in (-8, 0, 8):
        for ds in (-8, 0, 8):
            run = simulate(data, 420 + dx, ds)
            tolerance.append({'entry_delta_x': dx, 'exit_delta_along_face': ds, 'success': run['success'], 'last': run['events'][-1]})
    result['tolerance'] = tolerance
    result['without_blue_bounce_success'] = simulate(data, bounce_enabled=False)['success']
    result['minimum_center_y'] = min(p[1] for path in result['paths'] for p in path)
    result['full_white_floor_shortcut'] = probe_full_white_floor(data, result['entry_speed'])
    result['assumptions'] = {'dt': DT, 'gravity': G, 'air_release_drag': DRAG, 'player_size': [22, 30], 'wall_thickness': 20, 'model': 'swept AABB vs butt-ended wall strips; proposed diagonal aperture/clearance; no Godot run'}
    # Ray casts use the actual, unexpanded strips before apertures open.
    raw = world(data, half=(0, 0))
    _, n = axes({i['id']: i for i in data['items']}[8])
    target = add((640, 302), mul(n, 10))
    result['aim_checks'] = []
    for origin in ((131, 189), (235, 189)):
        for name, p in [('floor', (420, 500)), ('right_slope', target)]:
            contact = cast(origin, p, raw)
            result['aim_checks'].append({'origin': origin, 'target': name, 'first_wall': contact[1] if contact else None})
    assert result['success'] and all(v['success'] for v in tolerance)
    assert not result['without_blue_bounce_success']
    assert result['full_white_floor_shortcut']['lands_goal_platform']
    assert [v['first_wall'] for v in result['aim_checks']] == [1, 1, 5, 8]
    (ROOT / 'adjusted.json').write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')
    (ROOT / 'calculation.json').write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding='utf-8')
    summary = {k: v for k, v in result.items() if k not in ('paths', 'tolerance')}
    summary['tolerance_passed'] = sum(v['success'] for v in tolerance)
    print(json.dumps(summary, ensure_ascii=True, indent=2))


if __name__ == '__main__':
    main()
