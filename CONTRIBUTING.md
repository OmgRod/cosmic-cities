# Contributing

Thank you for your interest in contributing! Your help makes open source exciting and collaborative.

## How to Contribute

1. **Fork the Repository**

Click the "Fork" button at the top right of this repository, then clone your fork:

```bash
git clone https://github.com/OmgRod/cosmic-cities.git
cd cosmic-cities
```

2. **Create a Feature Branch**

Create a new branch with a descriptive name:

```bash
git checkout -b feature/your-feature-name
```

3. **Make Your Changes**

- Ensure the game runs locally:
    - Run `love .`
    - Or drag the project folder onto the LÖVE app
- Keep your code clean, tested, and consistent with the existing codebase.

4. **Commit Your Changes**

Write clear, concise commit messages:

```bash
git commit -m "Add pause menu background blur"
```

5. **Push and Open a Pull Request**

Push your branch to your fork and open a Pull Request (PR) targeting the `main` branch:

```bash
git push origin feature/your-feature-name
```

## Contribution Guidelines

- Use LÖVE2D version 12.x (refer to the LÖVE2D repository or GitHub Actions for the current version).
- Follow the existing code style and structure.
- Test your changes before submitting a PR.
- Be respectful and constructive in code reviews and discussions.
- Keep physics code (Windfield) decoupled from drawing logic.
- Use the included `SpriteFont`, `hump`, and `sti` helpers.
- Place art/sprites in `assets/sprites`, and Lua modules in `include/` or `states/`
- Add features from [`ROADMAP.md`](ROADMAP.md) or [issues](https://github.com/OmgRod/cosmic-cities/issues)

---

We appreciate your contributions!
