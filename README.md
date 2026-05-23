# QuanView ⚛️

**QuanView** is an augmented-reality educational iOS application that visualises quantum and physical concepts using SwiftUI, ARKit, and RealityKit. The project is organised as a Swift package and ships with several `.usdz` models to explore in AR.

---

## Key Features

- **Interactive AR Visualiser**: Place, scale, and interact with 3D models and simulations in your environment.
- **Model Library**: Includes multiple USDZ assets (e.g. `atom_3D.usdz`, `Atomic_Models.usdz`, `Atomic_Orbitals.usdz`, `Tesseract.usdz`, `YOUNGS_DOUBLE_SLIT_EXPERIMENT.usdz`) under `Reality/Resources/Models`.
- **Lab Notebook**: Capture snapshots from AR sessions and review them in the built-in notebook view.
- **Gesture Controls & Physics**: Pinch, pan, and tap to manipulate models; RealityKit drives simulations and physics-based interactions.

---

## Tech Stack

- Swift 6 / iOS 16+
- SwiftUI for UI
- RealityKit & ARKit for AR and rendering
- CoreImage for simple camera-based light estimation
- Concurrency (`async`/`await`, `@MainActor`) for camera and state handling

---

## Project Layout

- `QuanView.swiftpm/` — Swift package manifest and package layout
- `App/` — App entry (`PlanckApp.swift`), assets and app icons
- `Components/` — Reusable SwiftUI components
- `Models/` — Data models (e.g. `PlanckModel.swift`)
- `Reality/` — AR containers and model viewers (`ARViewContainer.swift`, `ModelViewerContainer.swift`)
- `Resources/Models/` — USDZ assets used by the app
- `Views/` — App views and subfolders (Welcome, Explore, Notebook, Profile, Visualiser)

---

## Getting Started

### Prerequisites

- Xcode 16 or later (or Swift Playgrounds on iPad/macOS)
- iPhone or iPad with ARKit support (A-series or M-series chip)

### Run

1. Clone this repository.
2. Open `QuanView.swiftpm` in Xcode.
3. Select a physical device (recommended) and run (`Cmd+R`).
4. Grant Camera and Photo Library permissions when requested.

---

## Notes

- Example AR models are stored in `Reality/Resources/Models` and can be replaced with your own USDZ files.
- The project is structured as a Swift package; you can open the `.swiftpm` manifest directly in Xcode.

---

## License

This repository does not include an open-source redistribution license. Contact the author for permission.

Made to make abstract science tangible. 🌌
