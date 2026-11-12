
# 🏥 ArogyaConnect — Healthcare Management Platform

### Healthcare, connected around you.

![Flutter](https://img.shields.io/badge/Flutter-Mobile%20App-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.11.5-0175C2?logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/State%20Management-Riverpod-6B4EFF)
![SQLite](https://img.shields.io/badge/Database-SQLite-003B57?logo=sqlite&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green)
![Status](https://img.shields.io/badge/Status-Active%20Development-orange)

**ArogyaConnect** is a Flutter-based healthcare management application designed to bring patients, families, and doctors together through a unified digital healthcare experience.

The application provides dedicated patient and doctor portals, allowing patients to manage their health information, monitor vital readings, maintain medical records, discover doctors, and manage appointments. Doctors can access patient information, review medical histories, manage appointments, and document consultations.

With a local SQLite database, Riverpod state management, and an intuitive Flutter interface, ArogyaConnect provides an integrated healthcare management experience.

---

## ✨ Key Features

### 👤 1. Patient & Family Management

Manage personal and family healthcare information from a single application.

- Personalized patient dashboard.
- Family profile management with profile switching.
- Access individual family member health information.
- View recent health activities and medical information.
- Manage personal healthcare records.

### 🩺 2. Doctor Directory

Discover doctors through an integrated doctor directory.

- Browse a directory of 200+ doctor listings.
- Search doctors by name, clinic, city, or speciality.
- Filter doctors based on medical speciality and location.
- Filter doctors offering video consultation.
- Sort and explore available doctor profiles.
- Initiate appointment booking directly from a selected doctor.

### 📅 3. Appointment Management

A complete appointment management workflow for patients and doctors.

**Patient features:**
- Book appointments with selected doctors.
- Select appointment dates and available appointment modes.
- View upcoming and previous appointments.
- Cancel existing appointments.
- Track appointment status.

**Doctor features:**
- View scheduled appointments.
- Access appointment-related patient information.
- Update appointment statuses.
- Complete appointments after recording consultations.

### ❤️ 4. Health Monitoring & Vital Tracking

Keep important health measurements organized in one place.

Patients can record and review:

- Blood Pressure
- Blood Glucose
- Heart Rate
- Blood Oxygen (SpO₂)
- Body Temperature
- Body Weight

The application maintains individual vital-reading records, making it easier to review previously entered health information.

### 📁 5. Digital Health Records

Organize medical document information through a centralized health records section.

- Maintain medical document details.
- Associate health records with patient profiles.
- Select PDF documents through the document picker.
- View saved document information.
- Track doctor verification status.
- Allow doctors to verify medical record entries.

### 👨‍⚕️ 6. Doctor Portal

A dedicated workspace for doctors to manage patient interactions.

**Patient Queue**
- View appointment entries.
- Review scheduled patient visits.
- Update appointment statuses.

**Patient Dossiers**
- Access patient demographic information.
- Review existing medical conditions.
- Examine recorded vital readings.
- View available medical documents.
- Review previous consultation history.

**Consultation Management**

Doctors can document consultations by entering:

- Diagnosis
- Consultation notes
- Tests advised
- Follow-up interval

Saving a consultation creates a visit record and updates the associated appointment status.

### 🔐 7. Authentication & Role-Based Navigation

ArogyaConnect provides separate application experiences for patients and doctors.

- Patient and doctor login interfaces.
- Role-based navigation.
- Patient registration interface.
- Doctor demo login.
- Patient demo login.
- Dedicated patient and doctor dashboards.

### 💾 8. Local Database Management

The application uses SQLite to manage and persist healthcare information on the device.

The database maintains structured information for:

- Users and authentication details
- Patient and family profiles
- Doctor profiles
- Doctor directory
- Appointments
- Vital readings
- Medical conditions
- Health records
- Consultation history

---

## 📱 Application Screens & Navigation

### Patient Application

The patient portal provides four main navigation sections:

| Section | Functionality |
|---|---|
| Dashboard | Health overview, profile information, and quick actions |
| Appointments | Book, view, and manage appointments |
| Doctors | Search, filter, and explore doctors |
| Records | View health readings and medical documents |

### Doctor Application

The doctor portal provides three main sections:

| Section | Functionality |
|---|---|
| Patient Queue | Manage and review appointment entries |
| Patient Dossiers | Access patient health information and consultation history |
| Doctor Profile | View doctor information and manage portal access |

---

## 🔑 Demo Access

The application includes preconfigured demo accounts so users can explore both application roles.

| Role | Email | Password |
|---|---|---|
| Patient | `patient@arogyanexus.com` | `patient123` |
| Doctor | `doctor@arogyanexus.com` | `doctor123` |

The application also provides quick demo access from the login screen.

---

## 🛠️ Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform mobile application development |
| Dart | Application programming language |
| Riverpod | State management |
| SQLite | Local database management |
| sqflite | SQLite database integration |
| SharedPreferences | Local session persistence |
| file_picker | PDF document selection |
| intl | Date and time formatting |

---

## 🏗️ Project Architecture

The project follows a modular architecture that separates application screens, data models, state management, and database operations.

```text
lib/
│
├── main.dart
│
├── core/
│   ├── constants/
│   └── database/
│       ├── app_database.dart
│       └── seed_doctors.dart
│
├── models/
│
├── providers/
│
├── repositories/
│
└── screens/
    ├── auth/
    ├── appointments/
    ├── dashboard/
    ├── doctor/
    ├── doctors/
    └── records/
```

**Architecture responsibilities:**

- **Core:** Shared application configuration and database initialization.
- **Models:** Structured healthcare data and application entities.
- **Providers:** Application state and authentication state management.
- **Repositories:** Database queries and data operations.
- **Screens:** Patient, doctor, authentication, appointment, and medical record interfaces.

---

## 🚀 Getting Started

### Prerequisites

Before running the project, ensure you have:

- Flutter SDK installed.
- Dart SDK compatible with the project.
- Android Studio or Visual Studio Code.
- Android emulator or physical Android device.
- Xcode for iOS development on macOS.

### Installation

**1. Clone the repository**

```bash
git clone https://github.com/SachinMugade8797/ArogyaConnect.git
```

**2. Navigate to the project directory**

```bash
cd ArogyaConnect
```

**3. Install dependencies**

```bash
flutter pub get
```

**4. Run the application**

```bash
flutter run
```

**5. Execute automated tests**

```bash
flutter test
```

The local SQLite database is initialized when the application starts, and demo data is seeded on the first launch.

---

## 🔮 Future Enhancements

The project is designed with opportunities for further healthcare technology integration.

Potential future improvements include:

- Cloud-based database and real-time synchronization.
- Secure authentication and user authorization.
- AI-powered healthcare assistance.
- Medical document processing and automated information extraction.
- Real-time doctor-patient video consultations.
- Push notifications and appointment reminders.
- Online appointment scheduling with doctor availability.
- Secure medical document storage.
- Healthcare analytics and patient health insights.

---

## 🔗 Related Projects

ArogyaConnect is part of a broader healthcare application ecosystem.

📱 **ArogyaConnect — Flutter Mobile Application**

[GitHub Repository](https://github.com/SachinMugade8797/ArogyaConnect)

🌐 **ArogyaNexus — Healthcare Web Application**

[GitHub Repository](https://github.com/SachinMugade8797/ArogyaNexus)

---

## 👨‍💻 Developer

**Sachin Mugade**

Software Developer | Flutter & Web Developer

- GitHub: [SachinMugade8797](https://github.com/SachinMugade8797)
- LinkedIn: [Connect with me](https://www.linkedin.com/in/sachin-mugade-7a3545306/)

---

## 📌 Project Information

ArogyaConnect is an actively developed healthcare management application built for learning, experimentation, and demonstration of modern mobile application development.

The current implementation uses local demo data and on-device SQLite storage. Authentication, document handling, and appointment workflows are intended for demonstration rather than real-world clinical deployment.

**Important:** Use fictional or test information only. ArogyaConnect is not a medical device and does not provide professional medical diagnosis or treatment recommendations.

---

### Healthcare, made more accessible. 🏥
