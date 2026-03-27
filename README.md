## Varsity

Varsity is a platform built to bring high school sports back to the center of student life.

It gives students a single place to follow their school teams, track games, stay updated on scores, and feel more connected to what’s happening around them.

---

### ✨ Features

🏫 School-Centered Experience
- Follow your school and its sports teams
- Dedicated team pages for each sport
- Built around real school communities

📅 Game Tracking
- View upcoming games and schedules
- Track past results and matchups
- Organized by team and school

📊 Live Updates (Planned)
- Real-time score updates
- Game progress tracking
- Instant access to what’s happening right now

📰 Team & Community Content
- Game recaps and updates
- School-based sports news
- Content powered by students and insiders

---

### 🚀 Vision

High school sports are one of the most exciting parts of student life — but there’s no central place to follow them.

Varsity changes that.

The goal is simple:
> Make it easy for students to stay connected, show school spirit, and never miss what’s happening with their teams.

---

### 🛠️ Tech Stack

- **Frontend:** Swift (iOS)
- **Backend:** Supabase (PostgreSQL + Auth + API)
- **Database Design:** Relational structure linking schools, teams, and games
- **Architecture:** Mobile client connected to a scalable backend

---

### 📦 Current Status

✅ Implemented
- Schools, teams, and games database schema
- Structured relationships between all core entities
- Backend powered by Supabase
- Basic app UI connected to backend

🚧 In Progress
- Game display UI and navigation
- Team and school profile views
- Live score updates
- Content and news integration

---

### 🧩 Core Data Model

- **Schools**
  - Represents each high school

- **Teams**
  - Linked to a school
  - Represents a specific sport (e.g., Varsity Football)

- **Games**
  - `home_team_id`
  - `away_team_id`
  - `location` (school ID or "neutral")
  - Stores matchups between teams

---

### 📸 Screenshots

> Add screenshots here once available  
> (Recommended: team pages, game feed, UI design)

---

### ⚙️ Installation

```bash
git clone https://github.com/yourusername/varsity.git
cd varsity
