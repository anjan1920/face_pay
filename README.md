# 🚇 FACE_PAY – Face Recognition Based Ticketing System

**FacePay** is a smart facial recognition ticketing system for public transport. Built using Flutter and Python (Flask), this solution allows users to register their face and use it as a digital ticket — eliminating the need for physical cards or QR codes. Admins can monitor real-time station crowd flow via a web-based dashboard.

---

## 🔑 Key Features

- 🎭 **Face as a Ticket** – No need for cards or tokens.
- 📲 **Flutter App** – User registration, login, wallet balance, face upload.
- 🧠 **Flask Server** – Handles face recognition, wallet deduction, and DB ops.
- 🧬 **InsightFace + Faiss** – High-accuracy face embedding and matching.
- 📊 **Admin Panel** – HTML/CSS/JS dashboard with live crowd data (via user logs).
- 🗃️ **MySQL DB** – Stores user info, wallet, and station logs.

---

## 🧰 Tech Stack

| Module         | Technology                         |
|----------------|-------------------------------------|
| Mobile App     | Flutter (Dart)                      |
| Backend        | Flask (Python) + CORS               |
| Face Recognition | InsightFace for embeddings        |
| Similarity Search | Faiss (Facebook AI Similarity Search) |
| Database       | MySQL                               |
| Admin Panel    | HTML, CSS, JavaScript (fetch/JS)    |
| Image Processing | OpenCV                            |

---

## ⚙️ How It Works

1. **User registers** via the Flutter app and uploads a face image.
2. Flask backend:
   - Extracts face embeddings using **InsightFace**
   - Stores user and embedding data in **MySQL**
3. At station entry/exit:
   - Face is scanned by a webcam-connected device running Flask
   - **Faiss** searches for the closest face match
   - If matched → fare is deducted and logged in the `user_log` table
4. The **Admin Panel** fetches real-time `user_log` data using JavaScript and displays live station-wise activity.

---

## 📁 Project Structure
face_pay/
├── admin_panel/ # Web dashboard for station admins
│ ├── index.html # Landing page
│ ├── station_control.html # Live station-wise control panel
│ ├── script.js # General fetch logic
│ ├── station_control_script.js
│ ├── style.css # General styles
│ ├── station_control_style.css
│ └── index01.html # (Optional or backup HTML file)

├── dataset/ # Folder to store face images (if needed)
├── embeddings.npz # Numpy array file storing face embeddings
├── face_new.py # Face detection & embedding using InsightFace
├── server.py # Main Flask app (CORS-enabled)
└── pycache/ # Python bytecode cache
