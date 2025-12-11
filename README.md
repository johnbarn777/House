# 🏡 **House**

**The ultimate shared living companion.**

Welcome to **House**, a modern, cross-platform Flutter application designed to harmonize your shared living experience. From managing chores to tracking groceries and gamifying household contributions, House leverages real-time synchronization to ensure everyone stays on the same page.

---

## 📱 **Features Overview**

### 🧹 **Smart Chore Management**
*Take the friction out of dividing household labor.*

A robust system designed to handle the complexities of chore distribution fairly and transparently.

- **Assignment Logic**:
    - **Direct Assignment**: Assign specific tasks to individual roommates.
    - **Round-Robin Rotation**: Automatically rotate recurring chores (e.g., "Take out trash") between selected members to ensure fairness.
    - **Open-for-Grabs**: Post unassigned chores that any member can claim for extra points.
- **Lifecycle Management**:
    - **Mark Complete**: Simple swipe-to-complete actions with optional **photo verification** and **completion notes** (e.g., upload a picture of the clean sink!).
    - **Undo Completion**: Accidentally marked a task as done? Easily un-complete it to restore it to the active list.
    - **Delay/Snooze**: Life happens. Request a delay on a chore with a required "Reason" note (e.g., "Working late"). Housemates are notified and can approve/acknowledge.
    - **Edit & Delete**: Admins or task creators can modify details, due dates, or remove chores entirely.
- **Notifications**:
    - Reminders for due tasks, overdue alerts, and notifications when a assigned chore is completed by someone else.

### 🥦 **Digital Fridge & Pantry**
*Never run out of the essentials again.*

A collaborative inventory system to track shared groceries and supplies.

- **Inventory Dashboard**:
    - Visual grid/list of tracked items (Milk, Eggs, Toilet Paper, Detergent).
    - **Status Indicators**:
        - 🟢 **Available**: Item is in stock.
        - 🟡 **Low**: Item is running low (notify user next time they are at the shop).
        - 🔴 **Out of Stock**: Item is gone. Automatically prompts to add to the Shopping List.
- **Smart Shopping List**:
    - A centralized list synced in real-time.
    - One-tap "I bought it" action that moves items from the shopping list back to "In Stock".
    - Categorization (Produce, Dairy, Household) for efficient shopping trips.

###  **House Notes & Notices**
*Effective communication without the group chat clutter.*

A dedicated space for house announcements, reminders, and rules.

- **Pinned Notices**: High-priority alerts that stay at the top (e.g., "Landlord inspection on Friday", "Quiet hours after 10 PM").
- **General Notes**: A digital whiteboard for non-urgent messages (e.g., "Leftovers in the fridge are for everyone").
- **Urgency Levels**:
    - ℹ️ **Info**: General FYIs.
    - ⚠️ **Important**: Please read (e.g., "Bill due").
    - 🚨 **Urgent**: Immediate attention required (e.g., "Leak in bathroom").

### 🎮 **Gamification**
*Make contribution fun and rewarding.*

Incentivize participation and create a positive feedback loop for household maintenance.

- **Points System**:
    - Earn points for completing chores (weighted by difficulty/effort).
    - Bonus points for maintaining a streak or picking up "Open-for-Grabs" tasks.
    - Deductions (optional) for significantly overdue items.
- **Leaderboards**:
    - **Weekly/Monthly Standings**: See who is carrying the team!
    - **All-Time Stats**: Track total tasks completed.
- **Streaks**: Visual indicators (🔥) for housemates who have completed their daily/weekly tasks on time consecutively.
- **Rewards**:
    - Customizable house perks for winners (e.g., "Winner doesn't have to clean the bathroom next week", "Loser buys pizza").

---

## 🛠 **Tech Stack**

- **Framework**: [Flutter](https://flutter.dev) (v3.10+)
- **Language**: Dart
- **State Management**: [Riverpod](https://riverpod.dev)
- **Backend**: [Firebase](https://firebase.google.com)
    - **Authentication**: Secure sign-in (Email/Password, Google).
    - **Firestore**: Real-time NoSQL database for syncing chores, lists, and profiles.
    - **Cloud Functions**: Serverless logic for chore rotation, gamification scoring, and notifications.
    - **Storage**: Image hosting for profile pictures and chore verification.
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router)

---

##  **Getting Started**

### Prerequisites

- **Flutter SDK**: [Install Flutter](https://docs.flutter.dev/get-started/install) (v3.10.1 or higher)
- **Dart SDK**: Included with Flutter.
- **Firebase Project**: You need a Firebase project configured for Android/iOS.

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/house.git
   cd house/flutter_app
   ```

2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   - Install the FlutterFire CLI:
     ```bash
     dart pub global activate flutterfire_cli
     ```
   - Configure your app:
     ```bash
     flutterfire configure
     ```
   - This will generate/update `lib/firebase_options.dart`.

4. **Run the App:**
   - For iOS (Simulator):
     ```bash
     flutter run -d iphonesimulator
     ```
   - For Android (Emulator):
     ```bash
     flutter run -d android
     ```

---

## 🤝 **Contributing**

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

**Designed with ❤️ for better shared living.**

---

## 🏴‍☠️ **Pirate Theme Implementation**

The application has been overhauled with a playful **Cartoon Pirate Theme** to make household management a fun, engaging adventure.

### **The Concept**
Your house is a **Ship**, and your housemates are the **Crew**. The goal is simple: **Keep the Ship Afloat.**
- **Ship Health**: Every overdue chore damages the ship's integrity (-5%). Completing duties repairs it (+2%).
- **Status**: Visual indicators range from "Smooth Sailing" (Health > 90) to "Abandon Ship!" (Health < 30).

### **Feature Mapping**
| Feature | Pirate Equivalent | Description |
| :--- | :--- | :--- |
| **House Code** | **Ship's Charter** | Sign the charter to join the crew. |
| **Chores** | **Duty Roster** | "Swab the decks", "Secure the galley", "Hoist the mainsail". |
| **Fridge** | **The Galley** | Manage your rations (Cargo) and provisions (Provisions). |
| **Members** | **The Crew** | Collaborators on the high seas. |
| **Settings** | **Quartermaster** | Configuration and Captain's logs. |

### **Design System ("Cartoon Pirate")**
A vibrant, high-contrast aesthetic designed for readability and fun.

- **Aesthetic**:
    - **Cel-Shaded Styling**: Thick iron borders, hard shadows, and 3D "gem" buttons.
    - **Fonts**: `Carter One` (Playful Headers) and `Nunito` (Friendly, readable body).
- **Color Palette**:
    - 🌊 **Ocean Blue** (`#0099CC`): Primary branding.
    - 💰 **Cartoon Gold** (`#FFCC00`): Accents and interactive elements.
    - 🪵 **Milk Chocolate** (`#A0522D`): Wood paneling surfaces.
    - 📜 **Creamy Parchment** (`#FFF8E1`): High-contrast background for text.
    - 🍬 **Candy Red** (`#FF5555`): Alerts and danger zones.

### **Gamification Mechanics**
- **Decay**: Uncompleted chores past their due date damage the ship's health daily.
- **Repair**: Completing chores restores health.
- **Visuals**: The "Ship Status" wheel on the deck gives immediate feedback on how well the house is managed.

