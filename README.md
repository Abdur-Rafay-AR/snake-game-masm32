# 🐍 Snake Game - MASM32 Assembly

A classic Snake game implemented in x86 Assembly language using MASM32 and the Irvine32 library. This project demonstrates low-level programming concepts including memory management, keyboard input handling, and console graphics manipulation.

## 📋 Table of Contents

- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Building and Running](#-building-and-running)
- [How to Play](#-how-to-play)
- [Game Mechanics](#-game-mechanics)
- [Project Structure](#-project-structure)
- [Technical Details](#-technical-details)
- [License](#-license)

## ✨ Features

- **Three Difficulty Levels**:
  - **Easy**: Slower speed, no obstacles
  - **Medium**: Normal speed, 5 obstacles
  - **Hard**: Fast speed, 15 obstacles

- **Classic Snake Gameplay**:
  - Smooth snake movement with arrow keys or WASD
  - Food generation and collision detection
  - Score tracking
  - Self-collision detection
  - Wall collision detection
  - Obstacle collision (in Medium/Hard modes)

- **Visual Elements**:
  - Color-coded game elements (snake, food, walls, obstacles)
  - Dynamic game board with borders
  - Real-time score display
  - Game over screen with replay option

- **Menu System**:
  - Main menu for starting or exiting
  - Difficulty selection menu
  - Play again option after game over

## 🔧 Prerequisites

Before building and running this project, ensure you have the following installed:

1. **Microsoft Macro Assembler (MASM32)**
   - Download from [masm32.com](http://www.masm32.com/)
   - Or use the Visual Studio MASM tools

2. **Irvine32 Library**
   - Download from [Kip Irvine's website](http://asmirvine.com/)
   - Install to `C:\Irvine` or update the environment paths in your build configuration

3. **Windows Operating System**
   - Required for MASM32 and Irvine32 library

4. **VS Code** (recommended)
   - With assembly language syntax highlighting extensions

## 📦 Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/snake-game-masm32.git
   cd snake-game-masm32
   ```

2. **Verify Irvine32 Installation**:
   - Ensure `Irvine32.lib` and `Irvine32.inc` are in `C:\Irvine`
   - Or update the `INCLUDE` and `LIB` environment variables in [.vscode/tasks.json](.vscode/tasks.json)

## 🔨 Building and Running

### Using VS Code Tasks

The project includes pre-configured VS Code tasks for easy building:

1. **Build the project**:
   - Press `Ctrl+Shift+B` (default build task)
   - Or select "Build & Link" from the task list

2. **Run the game**:
   ```bash
   .\snake.exe
   ```

### Manual Build

If you prefer to build manually from the command line:

```bash
# Assemble
ml /c /coff snake.asm

# Link
link snake.obj Irvine32.lib kernel32.lib user32.lib /SUBSYSTEM:CONSOLE

# Run
snake.exe
```

**Note**: Ensure the MASM32 tools are in your PATH or run these commands from the appropriate developer command prompt.

## 🎮 How to Play

1. **Launch the game**: Run `snake.exe`

2. **Main Menu**:
   - Press `1` to start the game
   - Press `2` to exit

3. **Select Difficulty**:
   - Press `1` for Easy (slow, no obstacles)
   - Press `2` for Medium (normal speed, 5 obstacles)
   - Press `3` for Hard (fast, 15 obstacles)

4. **Controls**:
   - **Arrow Keys** or **WASD** to move the snake
   - `↑` / `W` - Move up
   - `↓` / `S` - Move down
   - `←` / `A` - Move left
   - `→` / `D` - Move right

5. **Objective**:
   - Guide the snake to eat food (`A`)
   - Each food eaten increases your score and snake length
   - Avoid hitting walls (`#`), obstacles (`X`), or yourself

6. **Game Over**:
   - Press `Y` to play again
   - Press `N` to return to the main menu

## 🎯 Game Mechanics

### Snake Movement
- The snake starts with a length of 3 segments
- Moves continuously in the current direction
- Cannot reverse directly (e.g., can't go left if moving right)
- Speed depends on selected difficulty

### Food System
- Food (`A`) appears randomly on the game board
- Eating food increases score by 1
- Each food eaten makes the snake grow by 1 segment
- Food never spawns on the snake or obstacles

### Collision Detection
- **Walls**: Hitting the border (`#`) ends the game
- **Self-Collision**: Running into your own body ends the game
- **Obstacles**: Only in Medium/Hard modes; touching `X` ends the game

### Game Board
- Map size: 30×20 cells
- Maximum snake length: 100 segments
- Obstacles: 0 (Easy), 5 (Medium), or 15 (Hard)

## 📁 Project Structure

```
snake-game-masm32/
│
├── snake.asm          # Main game source code
├── README.md          # This file
├── LICENSE            # License information
└── .vscode/
    └── tasks.json     # VS Code build tasks
```

## 🔍 Technical Details

### Assembly Directives
- **INCLUDE**: Irvine32.inc for library procedures
- **EQU**: Constants for map dimensions, snake length, and key codes

### Key Procedures

| Procedure | Description |
|-----------|-------------|
| `main` | Entry point; handles menu loop and game loop |
| `InitGame` | Initializes snake position, direction, and game state |
| `DrawWalls` | Renders game borders and obstacles |
| `DrawGame` | Updates only changed elements (snake head/tail, food) |
| `DrawFullSnake` | Renders the entire snake (used at game start) |
| `Input` | Handles keyboard input for directional changes |
| `Logic` | Updates game state (movement, collision, food) |
| `GenerateFood` | Places food at random valid positions |
| `GenerateObstacles` | Creates obstacles based on difficulty |
| `ShowGameOver` | Displays game over screen and final score |
| `MainMenu` | Shows main menu and handles selection |
| `DifficultyMenu` | Shows difficulty selection and configures game |

### Data Structures

- **Snake Representation**: Arrays `snakeX[]` and `snakeY[]` store coordinates
- **Direction Vectors**: `dirX` and `dirY` (values: -1, 0, 1)
- **Obstacles**: Arrays `obstaclesX[]` and `obstaclesY[]` with `obstacleCount`
- **Game State**: `gameOver`, `score`, `snakeLen`, `gameSpeed`

### Irvine32 Library Functions Used

- `Randomize` / `RandomRange`: Random number generation
- `ClrScr`: Clear screen
- `Gotoxy`: Position cursor
- `SetTextColor`: Change text color
- `WriteChar` / `WriteString` / `WriteDec`: Output
- `ReadKey` / `ReadChar`: Input
- `Delay`: Pause execution

### Memory Management

- Stack-based local variables
- Fixed-size arrays for snake and obstacles
- No dynamic memory allocation

### Color Scheme

- **Snake Head**: Light Blue (`@`)
- **Snake Body**: Light Blue (`o`)
- **Food**: Green (`A`)
- **Walls**: Brown (`#`)
- **Obstacles**: Light Red (`X`)
- **Score**: Yellow
- **Game Over**: Light Red

## 📝 License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.

## 🎓 Educational Purpose

This project was developed as part of a Computer Organization and Assembly Language (COAL) course. It demonstrates:

- Low-level programming in x86 assembly
- Direct hardware/console manipulation
- Memory addressing and data structures in assembly
- Game loop implementation
- Real-time input handling
- Procedural programming in assembly

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the issues page.

## 👨‍💻 Author

Developed for the COAL course at Semester 3.

---

**Enjoy the game! 🐍🎮**