# ArogyaConnect

### Healthcare, connected around you.

[![Flutter](https://img.shields.io/badge/Flutter-App-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-%5E3.11.5-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![State management](https://img.shields.io/badge/State-Riverpod-6B4EFF)](https://riverpod.dev/)
[![Storage](https://img.shields.io/badge/Storage-Local%20SQLite-003B57?logo=sqlite&logoColor=white)](https://www.sqlite.org/)
[![Project status](https://img.shields.io/badge/Status-Prototype-orange)](#project-status)

**ArogyaConnect** is a healthcare companion app prototype for patients, families, and doctors. Patients can keep track of health information and appointments, while doctors can review patient records and save consultation notes. The app is built with Flutter and currently stores its working data on the device.

> This project is a prototype for learning and demonstration. It is not a replacement for professional medical advice, and it is not ready to store real patient information or run a real clinic.

## At a glance

- 👤 **For patients:** view a health dashboard, switch between family profiles, log vital readings, keep a list of medical documents, and book appointments.
- 🩺 **For doctors:** review a demo patient queue, open patient dossiers, update appointment statuses, record visit notes, and mark documents as doctor verified.
- 📍 **Doctor directory:** search a local directory of 201 seeded doctor listings by name, clinic, city, or speciality.
- 📱 **Built with Flutter:** a shared codebase with Android and iOS project folders.
- 💾 **Local-first prototype:** app data is stored in a SQLite database on the device; there is no connected online service.

## Who can use the app?

### Patient and family portal

After signing in as a patient, the bottom navigation has four sections:

1. **Dashboard** — a snapshot of the selected profile, recent health information, and shortcuts to common actions.
2. **Appointments** — upcoming and past visits, plus the option to book or cancel an appointment.
3. **Doctors** — browse the seeded directory, search, apply filters, and start booking with a selected doctor.
4. **Records** — review saved vital readings and medical document entries.

The profile switcher is designed for a patient managing their own and family members’ information. The seeded demo includes a patient and a spouse profile.

### Doctor portal

The doctor experience has three sections:

1. **Patient Queue** — view appointment entries and update their status.
2. **Patient Dossiers** — open demo patient records, including available demographics, conditions, vitals, documents, and visit history.
3. **Doctor Profile** — view the demo doctor profile, switch to the patient demo portal, or sign out.

From a dossier linked to an appointment, a doctor can enter a diagnosis, consultation notes, tests advised, and a follow-up interval. Saving the consultation adds a visit record and completes the appointment.

## What the prototype currently does

| Area | Included in this project |
| --- | --- |
| Sign-in | Role-based patient and doctor screens, demo sign-in, and local registration forms |
| Patient profiles | Seeded self and family profiles with a profile switcher |
| Doctor directory | Local search, city and speciality filters, video-consultation filter, and sorting |
| Appointments | Local booking, appointment list, status, and cancellation |
| Vital readings | Save and display blood pressure, glucose, heart rate, SpO₂, temperature, and weight readings |
| Health records | Save document details, display verification labels, and let a doctor mark a record verified |
| Doctor consultations | Save diagnosis, notes, tests advised, follow-up information, and completed appointment status |

## Demo sign-in

The login screen includes one-tap demo access. It also displays these sample credentials:

| Role | Email | Password shown in the app |
| --- | --- | --- |
| Patient | `patient@arogyanexus.com` | `patient123` |
| Doctor | `doctor@arogyanexus.com` | `doctor123` |

These accounts and the associated patient, doctor, appointment, vital, condition, and record data are seeded locally for demonstration.

## Project status and important limitations

ArogyaConnect demonstrates screens and local workflows. The following production services are **not** implemented:

- There is no web server, cloud database, account service, or sync between devices. Data remains in the local app database.
- Sign-in is demo-only: the current credential flow does not validate the entered password. Passwords entered during registration are stored locally without secure hashing. Do not use real passwords or personal health information with this prototype.
- Uploaded documents are represented by their details and filename. The selected PDF itself is not saved into the app’s records for later viewing.
- Appointment bookings are local demo entries. They do not check a real doctor’s availability, notify a clinic, process payment, or reserve an actual appointment.
- Choosing “Video” records the appointment mode only; there is no video-call feature.
- Doctor verification is a manual demo status change. There is no AI document analysis or automated verification service.
- Some doctor and patient screens use fixed demo data. For example, the doctor queue is tied to the seeded doctor, and the patient dossier search screen shows sample patients rather than searching all registered users.
- The app currently uses a seeded active profile ID. Newly registered patient profiles may not automatically become the selected profile.

**Use only fictional or test data.** This app does not provide medical diagnosis or treatment recommendations.

## Run the app

### Requirements

- Flutter SDK installed and available in your terminal.
- Android Studio with an Android emulator, or a connected Android device. An iOS build requires macOS and Xcode.
- This project’s Dart SDK constraint is `^3.11.5` (see `pubspec.yaml`).

### Start

From the project folder, run:

```bash
flutter pub get
flutter run
```

To run the existing automated tests:

```bash
flutter test
```

The local SQLite database is initialized when the app starts. The first launch seeds the demo data.

## How the app is organized

```text
lib/
├── main.dart                     # App startup, theme, and role-based home screen
├── core/
│   ├── constants/                # Shared colors
│   └── database/                 # SQLite schema and seeded demo data
├── models/                       # User, profile, doctor, appointment, and health data
├── providers/                    # Authentication and screen state (Riverpod)
├── repositories/                 # Local database read and write operations
└── screens/
    ├── auth/                     # Login, onboarding, and registration
    ├── appointments/             # Appointment list and booking form
    ├── dashboard/                # Patient dashboard and summary cards
    ├── doctor/                   # Doctor queue, profile, and patient dossiers
    ├── doctors/                  # Doctor directory
    └── records/                  # Patient vitals and document records
```

### Main data stored locally

The SQLite database contains tables for users, doctor profiles, patient/family profiles, the doctor directory, appointments, vital readings, patient conditions, health-record details, and consultation visit records. It is created and seeded by `lib/core/database/app_database.dart`; the expanded doctor directory data is in `lib/core/database/seed_doctors.dart`.

## Technology

- [Flutter](https://flutter.dev/) and Dart
- [Riverpod](https://riverpod.dev/) for app state
- [SQLite](https://www.sqlite.org/) through `sqflite` for on-device data
- SharedPreferences for remembering the local signed-in user ID
- `file_picker` for choosing a PDF file in the document form
- `intl` for formatting dates and times

## Related projects

This mobile app is named **ArogyaConnect**. Its doctor directory and demo data build on the healthcare web project below:

- 📱 **ArogyaConnect — mobile app:** [github.com/SachinMugade8797/ArogyaConnect](https://github.com/SachinMugade8797/ArogyaConnect)
- 🌐 **ArogyaNexus — related web project and reference:** [github.com/SachinMugade8797/ArogyaNexus](https://github.com/SachinMugade8797/ArogyaNexus)

## Contributing

Bug reports, thoughtful suggestions, and improvements are welcome. If you build on this prototype, please keep demo data fictional and describe clearly when a feature is simulated or stored only on the device.

## License

No license file is currently included. Contact the project owner before reusing or redistributing this code.
