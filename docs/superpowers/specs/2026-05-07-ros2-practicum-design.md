---
title: ROS2 Practicum Design (Q2) — instructions for Aron
date: 2026-05-07
audience: Aron (the student-builder)
status: draft, pending teacher review
---

# Smart Manufacturing & Robotics — ROS2 Practicum (Q2)

Build brief for Aron. Read end-to-end before starting.

- **Week 1 = now** — this spec is written this week and handed to Aron
- **Weeks 2-5** — Aron builds (4 weeks full-time)
- **End of week 5** — Aron delivers
- **Week 6** — practicum runs with the students (Aron delivers it; future cohorts may have a different teacher, so all materials must stand on their own)

---

## 1. The problem, the solution, what students will build

> ⚠️ **Critical for Aron:** students struggle to form a high-level mental model of what they're solving. **Lead every student-facing doc with the problem first, then the solution, then what they'll build.** Make it impossible for a student to be 5 minutes into the practicum without being able to explain — to a friend — _what the practicum is for_.

### 1.1 The problem (state this exactly, in plain language, on the very first page students read)

- Industrial robots traditionally execute fixed, pre-programmed paths. They always go to position X, always grip at position Y. This works only as long as nothing in the workspace moves
- In real factories — and in the company projects you do in this minor — objects don't sit still. Parts arrive at unpredictable positions on conveyors, in bins, in totes
- A robot that can only follow a hardcoded path is useless in those scenarios
- **The problem this practicum solves:** how do we make an industrial robot pick up an object whose position is _not known in advance_?

### 1.2 The solution (the pipeline students will build)

```
       ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
       │ 3D       │ -> │ Detector │ -> │ MoveIt2  │ -> │  Robot   │
       │ Camera   │    │ (ROS2)   │    │ planner  │    │ driver   │
       └──────────┘    └──────────┘    └──────────┘    └──────────┘
        sees where      publishes the   computes a      sends joint
        the object is   object's pose   safe motion     commands to the
                        as a tf frame   to that pose    physical robot
```

- Each component talks to the next via **ROS2** — the open-source middleware used in modern industrial robotics
- Each component is replaceable: swap the camera, swap the detector, swap the planner — the rest still works. **That is the lesson.**
- Same pipeline at home (laptop webcam + ArUco + sim robot) and in lab (RealSense + blue block + real robot)

### 1.3 What students will build, concretely

> **By the end of this practicum, every student pair will have made one of the lab's industrial robots — UR5 (CB3), UR10 (CB3), UR5e, UR10e, or Doosan M1013 — pick a 45 × 45 mm blue block off the workbench and place it at a tape-marked drop spot. The pickup location is detected at runtime by a 3D camera. Students wrote the high-level orchestration in Python; the driver, motion planner, and detector were pre-built.**

### 1.4 See it before you start — two videos

Aron records and ships **two videos**:

| Video              | Shows                                                                                                                                            | Length   | Where it's used                                                                                                                                                             |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------ | -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 📺 `lab_demo.mp4`  | A real robot in the lab moving to the blue block detected by the RealSense, executing the pick-and-place sequence at 3 different block positions | ~30-45 s | **Played to the whole class at the very kickoff of the practicum** — this is the "this is what you're going to build" moment. Also embedded at the top of `00_overview.md`. |
| 📺 `home_demo.mp4` | The sim robot in Gazebo moving to an ArUco marker (held on a phone), executing the pick-and-place sequence at 3 different marker positions       | ~30-45 s | Embedded in `00_overview.md` and again at the top of Chapter 5 (pick & place in sim) — students confirm "yes, this is what my sim should do" before they start.             |

These videos are not optional; they are the single most important pedagogical asset in the practicum. A student who watches both should immediately understand what they're aiming for.

Production constraints (so the videos work for kickoff projection in a classroom):

- Filmed landscape, ≥ 1080p
- No narration required — visuals must stand alone (no captions baked in either; the spoken explanation comes from whoever runs the kickoff)
- Stable camera (tripod), good lighting on the robot and the block
- Each of the 3 block positions clearly visible — short cut between them, not a single long take
- Title card at the start ("ROS2 Practicum — what you'll build") and end card ("Built by Aron Dingemanse, 2026, SMR Minor")

### 1.5 Where the problem + solution + videos must appear

- `practicum_docs/00_overview.md` — full problem / solution / videos / pipeline diagram, top of page
- `practicum_docs/01_ros2_mental_model.md` (Chapter 1) — the first paragraph re-states the problem in 1 sentence
- `install_guide.md` — opening 2 sentences re-state what they're going to build
- `lab_cheat_sheet.pdf` — top header re-states the goal in 1 line so students at the bench remember why they're there

If any of these locations doesn't surface the problem clearly, the deliverable isn't done.

---

## 2. Programme context

- Programme: [Smart Manufacturing & Robotics minor](https://www.robotminor.nl/), De Haagse Hogeschool, runs 20 weeks
- Industry projects students do in parallel: bin pick-and-place (OBS LinQ), flower handling (Van den Berg Roses), tiny parts assembly (Dynamic Ear), etc.
- Students arrive in Q2 with: vendor-software programming on UR e-series + UR CB3 + Doosan M (teach pendant), Python, OpenCV, one delivered company prototype
- This practicum adds: **controlling those same robots via ROS2 in Python**, replacing vendor software with the open ecosystem

---

## 3. Time budget (student-facing, hard cap)

| Phase               | Time      | Where                      |
| ------------------- | --------- | -------------------------- |
| 0. Setup            | ≤ 1 h     | Home — install VM          |
| 1. At-home tutorial | 4 h       | Home — VM, simulation only |
| 2. Lab session      | 2.5 h     | School — real robot        |
| **Total**           | **7.5 h** |                            |

Anything that pushes students past these caps is wrong. Cut.

---

## 4. Architectural pattern: sim-first, hardware-validates

- All ROS2 development happens at home in the VM, in simulation
- Lab session = take the same code, re-target to the real robot
- Same workspace at home and in lab; only network config + a CLI flag differs

Why this pattern:

- No permanent physical rigging needed in the lab
- Students still touch every relevant ROS2 element (nodes, topics, services, actions, params, launch, URDF, tf2, MoveIt2, sensor_msgs, image_transport)
- Vision pipeline is genuine even at home (real camera, real OpenCV, real ROS2 transport, real MoveIt plan)
- It is the **industrial pattern** students will reuse in their company projects
- Resilient against bad lab days — at-home work doesn't block

---

## 5. Robot-agnostic code

- Students don't know in advance which of the 5 robots they get
- Single robot-agnostic entry point: `ros2 launch practicum_bringup sim.launch.py robot:=ur5e` (or `ur10e`, `ur5_cb3`, `ur10_cb3`, `m1013`)
- All motion goes through MoveIt2's `move_group` action via `moveit_py` (Python)
- Per-robot params (joint home, safe-bench pose, drop pose) live in YAML files keyed by robot name, loaded by launch
- **CB2 robots out of scope** — `Universal_Robots_ROS2_Driver` doesn't support them. Document prominently. The teaching team assigns students only to CB3+ or e-series UR robots.

---

## 6. Phase 0 — Setup (≤ 1 h, home)

Two VM images you ship:

| Image                    | For                 | Tool                                    |
| ------------------------ | ------------------- | --------------------------------------- |
| `practicum-vm-amd64.ova` | Windows + Intel Mac | VirtualBox (free) or VMware Workstation |
| `practicum-vm-arm64.utm` | Apple Silicon Mac   | UTM (free)                              |

- Both built from the same recipe (Section 11)
- Each ~15-25 GB

Inside the VM (identical on both archs):

- Ubuntu 24.04 LTS
- ROS2 Jazzy Jalisco (desktop)
- MoveIt2 (Jazzy) + `moveit_py` Python bindings
- Gazebo Sim (Harmonic, the Jazzy-paired sim)
- `Universal_Robots_ROS2_Description` + `Universal_Robots_ROS2_Driver` (CB3 + e-series)
- `doosan-robot2` (M1013)
- `realsense-ros` (used in lab; pre-installed for parity)
- Calibration package (chosen with teachers — Section 13)
- VS Code + Microsoft ROS2 extension
- Pre-built workspace at `~/practicum_ws/`, sourced in `.bashrc`

Pre-built workspace layout (students never `colcon build` vendor packages):

```
~/practicum_ws/src/
  practicum_bringup/         # robot-agnostic launch files
  practicum_vision/          # ArUco + color-block detector nodes
  practicum_pick_place/      # student-facing template Python
  practicum_calibration/     # calibration scripts (TBD with teachers)
  practicum_docs/            # 6 markdown chapters
  vendor/
    Universal_Robots_ROS2_Description/
    Universal_Robots_ROS2_Driver/
    doosan-robot2/
    realsense-ros/
    moveit2_tutorials/
    [calibration package]/
```

Setup deliverable: 1-page install guide (PDF or markdown) — download links, import steps, verification command.

---

## 7. Phase 1 — At-home tutorial (4 h, 6 chapters)

- Format: markdown chapters in `~/practicum_ws/src/practicum_docs/`, opened in VS Code
- Each chapter: prose intro + runnable commands + 1-2 fill-in-the-TODO Python files
- Numbers below are **per-chapter caps** — overshooting is a bug

| #   | Time           | Chapter                           | Students do                                                                                                                                             | Aron pre-builds                                                                                                     |
| --- | -------------- | --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| 0   | (read + 2 min) | Overview                          | Read the problem statement, watch `lab_demo.mp4` and `home_demo.mp4`, internalize the pipeline diagram                                                  | Problem/solution framing (Section 1.1-1.3), both demo videos embedded, pipeline diagram, 30-second elevator summary |
| 1   | 0:30           | ROS2 mental model                 | Run `talker.py` / `listener.py`. Modify message string. Add a parameter.                                                                                | `talker.py`, `listener.py`, intro markdown                                                                          |
| 2   | 0:30           | Your assigned robot in RViz       | `ros2 launch practicum_bringup view_robot.launch.py robot:=ur5e`. Drive joints. Echo `/tf`, `/joint_states`. Inspect URDF. Switch robot arg.            | Robot-agnostic launch, URDF inspection exercises                                                                    |
| 3   | 0:45           | Programmatic motion via moveit_py | `ros2 launch practicum_bringup sim.launch.py robot:=ur5e`. Open `move_to_pose.py`, fill in 3-4 TODOs, watch sim robot execute.                          | Sim launch, MoveIt configs for all 5 robots, `move_to_pose.py` template (~20 lines for student)                     |
| 4   | 0:45           | Vision: webcam → ArUco → tf       | Open phone-displayed ArUco at `[course].github.io/aruco?id=42`, hold in front of laptop webcam. Run `webcam_aruco.launch.py`. Watch detections in RViz. | `aruco_detector_node.py` (~100 lines, readable), launch file, marker webpage                                        |
| 5   | 1:00           | Pick & place in simulation        | Combined launch. Open `pick_and_place.py` template — fill in 4-5 TODOs. Test with marker at 3 positions.                                                | `pick_and_place.py` template (~50 lines for student), drop-pose YAML, verification rubric                           |
| 6   | 0:30           | Lab dry-run                       | Walk full lab procedure in sim against a sim-driver mock. No surprises in the lab.                                                                      | Dry-run script + checklist mirroring the lab cheat sheet                                                            |

ArUco design choices and why:

- ArUco = stand-in for "the object to pick up" — cheapest way to give students a real 6DOF pose
- Phone display = no printer required
- Same pipeline (camera → tf frame → MoveIt goal) is unchanged in the lab — only the **detector implementation** swaps. Call this out in Chapter 4 + 5 docs.

Pre-lab verification:

- Each pair records a 30-second screen capture of sim pick & place succeeding at 3 different marker positions
- Submit before lab session
- Teacher (Thijs / future cohort's teacher) verifies before students walk into the lab
- Submission mechanism: open decision — confirm with Thijs (likely a folder on the course LMS)

---

## 8. Phase 2 — Lab session (2.5 h, school)

Pre-session prep, instructor side (minimal — keep it that way):

- Robots powered on at the wall switch
- Each workbench has: ethernet cable, RealSense (USB-C), blue block (already present), masking tape, marker for drop zone
- Wall-mounted "robot prep cheat sheet" per family (UR e-series, UR CB3, Doosan M1013)
- Note: prep doc + run-book must be usable by **any teacher**, not just Aron — future cohorts may have a different person delivering the practicum

Pre-session prep, student side (at home):

- VM ready, all 6 home chapters complete, screen capture submitted
- Lab cheat sheet PDF printed, brought to lab, 1 per pair

Session flow:

| Time        | Step                 | Students do                                                                                                                                                                             |
| ----------- | -------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 0:00 — 0:05 | Find robot           | Teacher points each pair at a robot. Pair sits, opens VM.                                                                                                                               |
| 0:05 — 0:25 | Robot prep           | Pair follows wall cheat sheet to put their robot in remote-control mode (UR ExternalControl URCap install, or Doosan auto/external mode). **Speed slider on robot at 33% max, strict.** |
| 0:25 — 0:40 | Network setup        | Set robot IP via teach pendant, set VM bridged-ethernet to matching subnet, plug cable, ping robot.                                                                                     |
| 0:40 — 0:55 | Driver + sanity move | `ros2 launch practicum_bringup driver.launch.py robot:=ur5e ip:=...`. Run home `move_to_pose.py`. Robot moves to safe pose.                                                             |
| 0:55 — 1:25 | Camera + calibration | Place RealSense per cheat sheet, plug USB. Run calibration command. _Procedure decided with teachers — Section 13._                                                                     |
| 1:25 — 2:20 | Vision pick & place  | Run home `pick_and_place.py --detector color_block`. Place blue block at 3 positions, watch robot execute.                                                                              |
| 2:20 — 2:30 | Show + power down    | Each pair demonstrates best run to a teacher; safe-power-down per cheat sheet.                                                                                                          |

Networking — Path A only:

- VM bridged ethernet → cable → robot
- Document clearly; do not leave students to figure out NAT vs bridged

Safety — non-negotiable:

- 🛑 **Speed slider on robot at 33% max, strict. Higher will NOT be tolerated.** Surface in every doc; in big text on the lab cheat sheet; verbally at session start.
- E-stop within reach of the pair at all times
- Workspace clear before any motion command
- Teacher / Aron circulates, may intervene at any time

Same code in lab as at home — only differences students apply:

- `--detector color_block` instead of `aruco`
- Robot IP via launch arg
- Bridged-ethernet in VM settings

`color_block_detector_node.py` publishes the **same tf frame name** as the ArUco node → `pick_and_place.py` is unchanged → that's the abstraction lesson, called out explicitly.

---

## 9. Vision detail

`aruco_detector_node.py` — at home:

- Reads laptop webcam (default `/dev/video0`)
- Detects ArUco markers via `cv2.aruco`
- Publishes marker pose as tf frame `detected_object` (parent: `camera_optical_frame`) and as a topic
- ~100 lines of Python, intentionally readable

`color_block_detector_node.py` — in lab:

- Reads RealSense color + aligned depth via `realsense-ros`
- HSV threshold for blue → largest contour → centroid (u, v)
- Looks up depth at (u, v) in aligned depth image
- Back-projects to 3D point in `camera_optical_frame`
- Publishes the **same tf frame name `detected_object`** so application code is unchanged
- ~100-150 lines of Python, readable

Both nodes:

- Publish a debug image with detection overlay (visible in `rqt_image_view`)
- Same topic + tf frame names — interchangeable

---

## 10. Aron's deliverables

| #   | Deliverable                    | Acceptance criterion                                                                                                                                                                                                   |
| --- | ------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| A   | Two VM images                  | `practicum-vm-amd64.ova` boots in VirtualBox on Windows; `practicum-vm-arm64.utm` boots in UTM on Apple Silicon. Hello-world Python node works on both.                                                                |
| B   | Reproducible build recipe      | `build-vm/` directory in repo with Ansible / Cubic / shell scripts (your choice — Section 11) and `README.md` step-by-step. New TA can rebuild from scratch.                                                           |
| C   | ROS2 workspace                 | `~/practicum_ws/` builds clean inside both VMs. All 5 robots launch via `robot:=...` arg.                                                                                                                              |
| D   | 6 markdown chapters + overview | All chapters readable end-to-end inside the VM, each within its time cap, ending with a self-checkable verification.                                                                                                   |
| E   | Lab cheat sheet PDF            | 1 page, printable, 1 per pair. Commands + IPs + 40 % speed warning + e-stop reminder + drop-zone diagram.                                                                                                              |
| F   | Calibration recommendation doc | Short markdown: chosen approach + alternatives + lab-time estimate + prep needed. **Approved by Mathijs & Thijs before you implement** (Section 13).                                                                   |
| G   | Lab session run-book           | Doc to run the lab — written for **any teacher** (not just yourself): pre-session checklist, common-issue playbook, debrief checklist. Future cohorts may have a different person delivering.                          |
| H   | Acceptance test report         | Short report after running the entire student experience yourself: clean install on Windows + Apple Silicon, all 6 chapters in ≤ 4 h, lab procedure on ≥ 2 robot types. Anything over budget gets fixed.               |
| I   | License + attribution files    | `LICENSE` (MIT, copyright Aron primary + Thijs secondary for docs), `NOTICE` spelling out the credit hierarchy, SPDX headers in every code file, attribution footer in every docs file. See Section 17.                |
| J   | Two demo videos                | `home_demo.mp4` (sim, ArUco) + `lab_demo.mp4` (real robot, blue block). 30-45 s each, ≥ 1080p, landscape, no narration required, 3 different positions visible. Played at kickoff + embedded in docs. See Section 1.4. |

All A–J lives in **one git repository** (e.g. `smr-ros2-practicum`).

---

## 11. VM build recipe — your tooling choice

Hard requirements:

- Reproducible from text / project file (not "I clicked around in a GUI")
- Produces both amd64 and arm64 deliverables
- Documented step-by-step in `build-vm/README.md`

Recommended options:

- **Ansible playbook + manual OS install per arch** — idempotent, code-as-truth, single tool both archs. Default if no strong preference.
- **Cubic (amd64) + Ansible / shell (arm64)** — GUI workflow if preferred. ⚠️ Verify Cubic supports Ubuntu 24.04 arm64 ISO before committing — Cubic's arm64 support is experimental.
- **Plain shell script** on a freshly-installed Ubuntu — simplest; loses Ansible's idempotency.
- **Packer + Ansible/shell** — gold standard, fully automated. Stretch goal only; learning Packer in 4 weeks is risky.

Whichever you pick:

- Commit the recipe
- Document in `build-vm/README.md`

Hosting the images:

- Each ~15-25 GB
- Confirm with Thijs which storage the school supports (university file server, NextCloud, OneDrive Education, hashed URL on a course page)
- Confirm before week 5 so links are stable when you write the install guide

---

## 12. Build sequence (milestones)

### Week 1 — NOW (kickoff, no build)

- This spec is written and handed to Aron
- Aron reads end-to-end, asks clarifying questions, sets up his dev environment
- First Monday tutor meeting with Thijs — discuss spec, surface any blockers

### Week 2 — Foundation (build starts)

- M1: VM tooling chosen, amd64 VM boots, ROS2 Jazzy installed, hello-world Python node runs
- M2 (start): arm64 VM produced from same recipe; smoke test on Apple Silicon

### Week 3 — Simulation pipeline

- M2 (done): both VM archs verified
- M3: All 5 robots load via `robot:=...` arg in sim launch (RViz + Gazebo)
- M4: `move_to_pose.py` template works in sim against any of the 5 robots
- M5: ArUco detector node reads webcam, publishes tf frame
- M6: `pick_and_place.py` template completes a full sim sequence with detected ArUco

### Week 4 — Real robot integration (in lab)

- M7: UR driver works against ≥ 1 CB3 and ≥ 1 e-series robot
- M8: Doosan driver works against the M1013
- M9: `color_block_detector_node.py` reads RealSense, publishes the same tf frame
- M10: ⚠️ **Calibration recommendation drafted, presented to Mathijs + Thijs (the calibration decision involves both).** Critical-path — must happen by mid-week 4 at latest.

### Week 5 — Calibration impl, docs, acceptance, videos, delivery

- M11: Approved calibration approach implemented, tested ≥ 2 robot types in lab
- M12: All 6 home chapters drafted and reviewed
- M13: Lab cheat sheet PDF + lab run-book drafted
- M14: Acceptance test passed
- M15: `home_demo.mp4` + `lab_demo.mp4` recorded during acceptance, edited, embedded in `00_overview.md`
- M16: Repository handed off **end of week 5**

### Week 6 — Practicum runs

- Aron delivers the practicum to the students this week
- He is present to support during the lab session
- Note for the future: someone other than Aron may deliver in subsequent cohorts — the run-book + cheat sheet must support that

---

## 13. Open decisions — escalate to Thijs, don't decide alone

### Calibration procedure

- You research, you recommend, you do **not** implement until approved
- Process:
  - Research options (`easy_handeye2`, manual ChArUco-on-wrist, ArUco-board-on-wrist with `aruco_ros`, fiducial-on-table with known robot poses, etc.)
  - Benchmark feasibility on at least one robot
  - Draft 1-2 page recommendation: chosen approach + alternatives considered + lab-time estimate + physical prep needed
  - Present at Monday tutor meeting with Thijs
  - Get sign-off
  - Then build
- Constraints any approach must satisfy:
  - Workable in the lab with **minimum prep / setup**
  - Fits inside ~30 min of lab time including any marker-attachment fiddling
  - No permanent rigging on the robot

### Hosting location for VM images

- TBD with Thijs
- Confirm before week 5

---

## 14. Working agreements

- **Weekly check-in with Thijs at the Monday tutor meeting** — progress, blockers, scope changes
- **No autonomous decisions on calibration** (Section 13)
- **Don't reinvent** — lean on community packages: `Universal_Robots_ROS2_Driver`, `doosan-robot2`, `moveit_py`, `realsense-ros`, `easy_handeye2` (if approved). Your value-add is integration + scaffolding + tutorial content.
- **Python only** for everything you write
- **Document as you go** — don't leave cheat sheet + run-book to the last day
- **No new features once you start week 5** — week 5 is calibration impl + docs + acceptance + handoff. If you find yourself adding scope in week 5, stop and ask Thijs.

---

## 15. Out of scope (push back if these come up)

- Obstacle avoidance / dynamic planning scene > Could be another, more advanced tutorial later, but not for now.
- Real gripper actuation (tool0 frame is the action point)
- C++ ROS2
- Multi-robot coordination
- Teach-pendant integration beyond enabling remote-control mode
- 3D point-cloud reconstruction / general object detection
- Deep-learning-based perception
- Robotic safety certification beyond pair-with-e-stop choreography
- CB2 robot support
- "Build the URDF from scratch" exercises

---

## 16. Acceptance test — your bar before handoff

Done = all of the following passed:

1. Wiped Windows machine, downloaded `practicum-vm-amd64.ova`, imported into VirtualBox, completed all 6 chapters in ≤ 4 h. **Recorded `home_demo.mp4` during this run.**
2. Same on a fresh Apple Silicon Mac with `practicum-vm-arm64.utm` and UTM
3. Walked the lab procedure on ≥ 2 different robot types (e.g. UR e-series + Doosan M1013) end-to-end, blue block picked + placed at 3 different positions. **Recorded `lab_demo.mp4` during this run.**
4. Both videos edited, title-carded, embedded in `00_overview.md`
5. Wrote up what tripped you up; fixed each item
6. Acceptance-test report reviewed by Thijs at Monday tutor meeting

If any step failed or exceeded the time budget — fix before declaring done.

---

## 17. Licensing & attribution

The repository ships under a permissive license so future cohorts, other universities, and industry partners can reuse it freely. Original credit for code stays with Aron; primary credit for Documentation with Aron, with secondary credit to Thijs.

License: **MIT** for everything in the repo (code + documentation). Simple, permissive, well-known, requires attribution.

Files Aron adds to the repo root:

- `LICENSE` — full MIT license text. Two copyright holders listed:
  - `Copyright (c) 2026 Aron Dingemanse` (covers code and is primary author for docs)
  - `Copyright (c) 2026 Thijs Brilleman` (secondary author for documentation contributions)
- `NOTICE` — short attribution text spelling out the credit hierarchy:
  - "**Code:** original author Aron Dingemanse, 2026."
  - "**Documentation:** primary author Aron Dingemanse, 2026, with secondary contributions and review by Thijs Brilleman."
  - "Built as part of the Smart Manufacturing & Robotics minor at De Haagse Hogeschool."
- `README.md` references both `LICENSE` and `NOTICE`

In every source file Aron writes, add a 1-line header:

```
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Aron Dingemanse
```

In every documentation file Aron writes, add a small footer (or front-matter line):

```
Licensed under MIT. © 2026 Aron Dingemanse (primary), Thijs Brilleman (secondary).
```

Vendor packages cloned into `vendor/` keep their original licenses untouched. Aron does not relicense other people's code.

---

## 18. Pointers / starting reads

- ROS2 Jazzy: https://docs.ros.org/en/jazzy/
- MoveIt2 tutorials: https://moveit.picknik.ai/main/index.html
- `moveit_py` (Python bindings): in MoveIt2 docs
- UR ROS2 driver: https://github.com/UniversalRobots/Universal_Robots_ROS2_Driver
- doosan-robot2: https://github.com/DoosanRobotics/doosan-robot2
- realsense-ros: https://github.com/IntelRealSense/realsense-ros
- `easy_handeye2`: https://github.com/marcoesposito1988/easy_handeye2 — verify Jazzy support
- Cubic: https://github.com/PJ-Singh-001/Cubic
- Programme: https://www.robotminor.nl/
- Project showcase forum: https://www.robotexchange.io/

Build for the student first; build for the next TA second.
