# Gym App — Implementation Plan

> **Audience:** Claude Code (local), working inside this repository, and the project owner.
> **Stack:** Flutter (Android + iOS) · NestJS · PostgreSQL · Prisma · Firebase Cloud Messaging (push only).
> **Save this file as:** `docs/PLAN.md` in the repository root.

---

## 0. Instructions for Claude Code (read first, follow always)

1. **Work one deliverable at a time, in order** (Section 12). Do not start a deliverable until the previous one meets its acceptance criteria. Exception: a deliverable may list another as "can run in parallel".
2. **At the start of every session:** read `docs/PLAN.md`, `docs/PROGRESS.md` and `docs/DECISIONS.md`, then continue from the first unchecked item in `PROGRESS.md`.
3. **At the end of every deliverable:**
   - Run every command in its **Verification** list and make sure all pass.
   - Tick its checkboxes in `docs/PROGRESS.md` and write 1–3 lines on what was done.
   - Make one git commit per deliverable: `feat(D<n>): <short title>`.
4. **Do not invent requirements.** If something is unclear or missing, pick the simplest option consistent with this plan, record it in `docs/DECISIONS.md` (date, question, decision, reason), and continue. If the choice cannot be undone easily (data model of money, deleting data, store IDs), add it to `docs/OPEN_QUESTIONS.md` and ask the owner.
5. **Business rules in Section 3 are the source of truth.** Every rule marked `[R-xx]` must have at least one automated test that names it in the test title, e.g. `it('[R-07] renewal extends from current endDate when active')`.
6. **Never commit secrets.** Use `.env` files (git-ignored) and commit `.env.example` with every variable documented.
7. **Keep the app runnable.** After every deliverable, `docker compose up`, the backend and the Flutter app must start without errors.
8. **Code quality gates** (must pass before each commit):
   - Backend: `npm run lint`, `npm run test`, `npm run test:e2e`, `npm run build`
   - Mobile: `flutter analyze` (zero warnings), `flutter test`, `dart format --set-exit-if-changed .`
9. **Language:** code, comments, commits and docs in **English**. App UI text in **Spanish (default)** and **English**, always through localization files, never hard-coded strings.

---

## 1. Product summary

A mobile app for a single gym with three kinds of users:

| Role | Who | Main purpose |
|---|---|---|
| `ADMIN` | Gym owner / reception staff | Create and manage members, record payments, set membership tiers, see who enters, build training plans |
| `TRAINER` | Personal trainer (Premium tier) | Follow assigned Premium members, customize their plans, record measurements and notes |
| `MEMBER` | Gym customer | Check in by scanning a QR at the door, see days left, follow today's workout (Plus/Premium), track progress |
| `KIOSK` | A tablet at the entrance (technical account) | Show a rotating QR code that members scan to check in |

**There is no public sign-up.** Only an ADMIN creates accounts.

### Membership tiers

| Tier | Name in UI (es / en) | Includes |
|---|---|---|
| `BASIC` | Mensual / Monthly | QR check-in, days-left info, expiry notifications |
| `PLUS` | Mensual + / Monthly + | Everything in BASIC + an assigned training plan, "today's workout" after check-in, progress logging per day |
| `PREMIUM` | Mensual ++ / Monthly ++ | Everything in PLUS + an assigned personal trainer, a plan customized for the member, body measurements, trainer notes, advanced progress charts |

---

## 2. Glossary

| Term | Meaning |
|---|---|
| **Gym timezone** | `America/La_Paz` (configurable via `GYM_TIMEZONE`). All "today", "days left" and cron times use this timezone. |
| **Local date** | A calendar date in the gym timezone, stored as PostgreSQL `DATE` (no time). |
| **Membership** | The current subscription of a member: tier, start date, end date. One per member. |
| **endDate** | The **last valid day** (inclusive) of the membership. |
| **Payment** | A record that money was received for N months of a tier. Payments extend `endDate`. |
| **Check-in** | A successful entry to the gym, created by scanning the kiosk QR. |
| **Check-in attempt** | Any scan, successful or not, stored for audit. |
| **Plan** | A reusable training program: an ordered list of plan days. |
| **Plan day** | One workout (e.g. "Day 1 – Legs") with ordered exercises. |
| **Assignment** | Which plan a member is following and which plan day comes next. |
| **Session** | One workout performed by a member on a date, with logged sets. |

---

## 3. Business rules (source of truth)

### 3.1 Membership dates

- **[R-01]** `endDate` is inclusive. A membership is **active** when `today <= endDate` and the member account is active.
- **[R-02]** `daysLeft = (endDate − today) + 1` in calendar days when active. On the last day `daysLeft = 1`. When expired, `daysLeft = 0`.
- **[R-03]** A membership is **expired** when `today > endDate`.
- **[R-04]** Adding N months to a start date `S`: `endDate = addMonths(S, N) − 1 day`, using calendar months (use `date-fns`). Examples:
  - S = 2026-01-15, N = 1 → endDate = 2026-02-14
  - S = 2026-01-31, N = 1 → addMonths gives 2026-02-28 → endDate = 2026-02-27
  - S = 2026-03-01, N = 3 → endDate = 2026-05-31
- **[R-05]** New member: `startDate = today` unless the admin picks another start date (allowed range: today − 7 days to today + 30 days).

### 3.2 Payments and renewals

- **[R-06]** Every payment has: tier, months (1–12), amount, currency (default `BOB`), method (`CASH`, `TRANSFER`, `QR`, `CARD`, `OTHER`), optional note, recorded-by admin, timestamp.
- **[R-07]** Renewal while **active**: the new period starts on `endDate + 1`, so no paid days are lost.
- **[R-08]** Renewal while **expired**: the new period starts **today**.
- **[R-09]** A payment may change the tier. The new tier applies to the whole new period and **immediately** if the membership is expired, or from today if the admin selects "apply tier now".
- **[R-10]** The suggested amount is `tierPrice(tier) × months`. The admin can edit the amount (discount or surcharge). If the amount differs from the suggestion, a note is required.
- **[R-11]** Tier prices are stored in a `TierPrice` table and editable by ADMIN. Changing a price never changes past payments.
- **[R-12]** Payments cannot be deleted. A wrong payment is corrected by a **void** (sets `voidedAt`, `voidedById`, `voidReason`) which recalculates `endDate` from the remaining non-voided payments. Voiding requires a reason.

### 3.3 Tier changes without a new period

- **[R-13]** **Upgrade** (e.g. BASIC → PLUS) during an active period applies immediately. The system shows a **suggested prorated charge**: `round((newMonthlyPrice − oldMonthlyPrice) / 30 × daysLeft)`. The admin records it as a payment with `months = 0` and `kind = UPGRADE`, or sets it to 0 with a note.
- **[R-14]** **Downgrade** applies immediately, with no refund. The UI must warn the admin.
- **[R-15]** Downgrading from PLUS/PREMIUM keeps all workout history. Features are hidden, not deleted. Upgrading again shows the history again.
- **[R-16]** Downgrading from PREMIUM unassigns the trainer (`trainerId = null`) but keeps measurements and notes.

### 3.4 Check-in

- **[R-17]** A check-in requires: a valid kiosk QR token (signature OK, not expired), an authenticated MEMBER, an active member account, and an active membership.
- **[R-18]** QR tokens rotate every **30 seconds** and are valid for **45 seconds** (overlap so a scan during rotation still works).
- **[R-19]** **Duplicate protection:** if the member already has a successful check-in in the last **3 hours** (`CHECKIN_COOLDOWN_MINUTES = 180`), no new check-in is created and no admin notification is sent. The API returns `200` with `duplicate: true` and the same data (days left, today's workout).
- **[R-20]** Expired membership: no check-in is created. An attempt with result `DENIED_EXPIRED` is stored, and **both** admin and member are notified (see Section 7).
- **[R-21]** Deactivated member account: attempt stored with `DENIED_INACTIVE`. The member's tokens are already revoked, so this mainly protects against stale sessions.
- **[R-22]** Every scan creates a `CheckinAttempt` row with result `SUCCESS`, `DUPLICATE`, `DENIED_EXPIRED`, `DENIED_INACTIVE` or `INVALID_TOKEN`.
- **[R-23]** "Currently inside" = members with a successful check-in in the last **2 hours** (`INSIDE_WINDOW_MINUTES = 120`). There is no check-out in v1.

### 3.5 Expiry notifications

- **[R-24]** A daily job at **08:00 gym time** notifies:
  - members with `daysLeft` equal to **7, 3 or 1**: reminder;
  - members whose membership expired **yesterday** (today = endDate + 1): expired notice;
  - all admins: **one daily summary** ("3 vencen en 7 días, 1 venció ayer…"), only when there is something to report.
- **[R-25]** Each notification is sent **at most once** per membership period. Uniqueness key: `(membershipId, type, endDate)`. Running the job twice the same day must not send duplicates.
- **[R-26]** If a member renews, reminders for the old `endDate` no longer apply (the key includes `endDate`).

### 3.6 Training plans (PLUS and PREMIUM)

- **[R-27]** Only PLUS and PREMIUM members can have a plan assignment, see "today's workout" and log sessions. The backend enforces this, not only the UI.
- **[R-28]** **Today's workout** = the plan day at `assignment.nextDayIndex`. It is **not** tied to the weekday. Members who skip days continue where they left off.
- **[R-29]** When a member **finishes** a session with at least one logged set, `nextDayIndex = (nextDayIndex + 1) % numberOfPlanDays`. Finishing with zero sets is not allowed. The member can "discard" the session instead.
- **[R-30]** One open (unfinished) session per member at a time. An open session not finished by **23:59 gym time** is auto-finished by the nightly job if it has ≥ 1 set (and advances the day). If it has 0 sets, it is deleted.
- **[R-31]** If the member already finished a session today, the post-check-in screen shows today's summary and a button "Hacer otro entrenamiento" (start the next day anyway).
- **[R-32]** Editing a plan template does **not** change sessions already logged. Sets reference the plan exercise and also store a snapshot of the exercise name.
- **[R-33]** If a plan's number of days shrinks below a member's `nextDayIndex`, reset that member's `nextDayIndex` to 0.
- **[R-34]** Assigning a new plan resets `nextDayIndex` to 0. Old sessions are kept.

### 3.7 Premium

- **[R-35]** A PREMIUM member can have one assigned trainer. A trainer sees **only** their assigned members.
- **[R-36]** A trainer can create a **member-specific plan** by copying a template (`Plan.ownerMemberId` set). Changes to it affect only that member.
- **[R-37]** Measurements are recorded by a trainer or admin, with a date (default today). Fields are optional except date and at least one value.
- **[R-38]** Trainer notes have `visibleToMember` (default `true`). Private notes are seen only by trainers and admins.
- **[R-39]** Members can see their own measurements, visible notes and charts. They cannot edit measurements.

### 3.8 Accounts

- **[R-40]** Login identifier is the **phone number** (unique, normalized to digits with country code, default `+591`). Email is optional and unique when present.
- **[R-41]** Admin creates the account with a **temporary password** (generated, 8 characters, shown once to the admin, shareable via a "copy/share" button). `mustChangePassword = true` forces a password change at first login.
- **[R-42]** Passwords: minimum 8 characters, hashed with **argon2**.
- **[R-43]** Deactivating a member sets `isActive = false`, revokes all refresh tokens and hides them from default lists. No hard delete in v1.
- **[R-44]** Admin can reset a member's password (generates a new temporary password and revokes sessions).
- **[R-45]** At least one active ADMIN must always exist. Deactivating the last admin is rejected.

---

## 4. Roles and permissions matrix

| Capability | ADMIN | TRAINER | MEMBER | KIOSK |
|---|:-:|:-:|:-:|:-:|
| Create/edit/deactivate members | ✅ | ❌ | ❌ | ❌ |
| Create trainers, admins, kiosk accounts | ✅ | ❌ | ❌ | ❌ |
| Record/void payments, change tier | ✅ | ❌ | ❌ | ❌ |
| Edit tier prices & gym settings | ✅ | ❌ | ❌ | ❌ |
| See all members & check-ins | ✅ | ❌ | ❌ | ❌ |
| See assigned members | ✅ | ✅ (own) | ❌ | ❌ |
| Create/edit plan templates & exercises | ✅ | ✅ | ❌ | ❌ |
| Assign plan to PLUS member | ✅ | ❌ | ❌ | ❌ |
| Assign/customize plan for PREMIUM member | ✅ | ✅ (own) | ❌ | ❌ |
| Record measurements & notes | ✅ | ✅ (own) | ❌ | ❌ |
| Get rotating QR token | ❌ | ❌ | ❌ | ✅ |
| Check in | ❌ | ❌ | ✅ | ❌ |
| See own membership, days left, payments history | — | — | ✅ | — |
| Today's workout, log sets | — | — | ✅ (PLUS+) | — |
| See own progress charts, measurements, notes | — | — | ✅ (PREMIUM for measurements/notes; PLUS+ for basic progress) | — |
| Receive check-in notifications | ✅ | ❌ | ✅ (own) | ❌ |

Enforcement: NestJS `@Roles()` guard + `@RequireTier()` guard + ownership checks in services. Every forbidden case must have an e2e test returning `403`.

---

## 5. Architecture

```
┌─────────────────────────── Flutter app (one codebase) ───────────────────────────┐
│  Role-based UI: Admin · Trainer · Member · Kiosk mode                            │
│  dio (REST) · socket_io_client (live feed) · firebase_messaging (push)           │
└───────────────┬───────────────────────────────┬──────────────────────────────────┘
                │ HTTPS REST /api/v1            │ WSS /realtime
                ▼                               ▼
┌──────────────────────────────── NestJS API ──────────────────────────────────────┐
│ auth · users · memberships · payments · pricing · kiosk · checkins · realtime    │
│ notifications · scheduler · exercises · plans · workouts · premium · reports     │
└───────┬──────────────────────────────────────────────┬───────────────────────────┘
        ▼                                              ▼
   PostgreSQL (Prisma)                       firebase-admin → FCM → phones
```

### 5.1 Repository layout (monorepo)

```
gym-app/
├── backend/                 # NestJS
│   ├── prisma/
│   │   ├── schema.prisma
│   │   ├── migrations/
│   │   └── seed.ts
│   ├── src/
│   │   ├── main.ts
│   │   ├── app.module.ts
│   │   ├── config/          # typed config + validation (zod or class-validator)
│   │   ├── common/          # guards, decorators, filters, interceptors, date utils, pagination
│   │   ├── prisma/          # PrismaService
│   │   └── modules/
│   │       ├── auth/
│   │       ├── users/
│   │       ├── memberships/
│   │       ├── payments/
│   │       ├── pricing/
│   │       ├── settings/
│   │       ├── kiosk/
│   │       ├── checkins/
│   │       ├── realtime/
│   │       ├── notifications/
│   │       ├── scheduler/
│   │       ├── exercises/
│   │       ├── plans/
│   │       ├── workouts/
│   │       ├── premium/
│   │       └── reports/
│   ├── test/                # e2e tests (supertest)
│   ├── .env.example
│   └── Dockerfile
├── mobile/                  # Flutter app (move the existing gym_app project here)
├── docs/
│   ├── PLAN.md              # this file
│   ├── PROGRESS.md
│   ├── DECISIONS.md
│   ├── OPEN_QUESTIONS.md
│   └── API.md               # generated summary / link to Swagger
├── docker-compose.yml       # postgres (+ optional pgadmin)
└── README.md                # how to run everything locally
```

### 5.2 Backend libraries

`@nestjs/config`, `@nestjs/jwt`, `@nestjs/passport` + `passport-jwt`, `@nestjs/swagger`, `@nestjs/schedule`, `@nestjs/websockets` + `@nestjs/platform-socket.io`, `@nestjs/throttler`, `prisma` + `@prisma/client`, `argon2`, `class-validator` + `class-transformer`, `date-fns` + `date-fns-tz`, `firebase-admin`, `nestjs-pino` (logging), `helmet`. Tests: `jest`, `supertest`.

### 5.3 Mobile libraries

`flutter_riverpod` + `riverpod_annotation` + `riverpod_generator`, `go_router`, `dio`, `flutter_secure_storage`, `freezed` + `freezed_annotation` + `json_serializable` + `build_runner`, `qr_flutter`, `mobile_scanner`, `permission_handler`, `socket_io_client`, `firebase_core` + `firebase_messaging` + `flutter_local_notifications`, `fl_chart`, `intl` + `flutter_localizations`, `wakelock_plus`, `share_plus`, `cached_network_image` (optional). Tests: `flutter_test`, `mocktail`.

### 5.4 Mobile folder structure (feature-first)

```
mobile/lib/
├── main.dart
├── app.dart                       # MaterialApp.router, theme, l10n
├── core/
│   ├── config/                    # env (API_BASE_URL via --dart-define)
│   ├── network/                   # dio client, auth interceptor, refresh logic, error mapping
│   ├── auth/                      # session state, secure storage
│   ├── router/                    # go_router + role redirects
│   ├── realtime/                  # socket client
│   ├── push/                      # FCM setup, token registration, local notifications
│   ├── theme/
│   ├── widgets/                   # shared widgets (loading, error, empty states, tier badge)
│   └── utils/                     # date formatting in gym timezone, validators
├── l10n/                          # app_es.arb, app_en.arb
└── features/
    ├── auth/                      # login, change password
    ├── admin/
    │   ├── dashboard/
    │   ├── members/               # list, detail, create, edit, payments, tier change
    │   ├── checkins/              # live feed, history
    │   ├── pricing/
    │   ├── staff/                 # trainers, admins, kiosks
    │   └── reports/
    ├── kiosk/                     # rotating QR screen
    ├── member/
    │   ├── home/                  # membership card, days left, scan button
    │   ├── checkin/               # scanner + result screen
    │   ├── workout/               # today's workout, session logging
    │   ├── progress/              # history, charts
    │   └── premium/               # measurements, notes, trainer info
    ├── trainer/                   # my members, member detail, plan customization
    ├── plans/                     # shared plan builder + exercise library (admin/trainer)
    └── notifications/             # in-app inbox
```

Each feature: `data/` (API + DTOs), `domain/` (models), `presentation/` (screens, widgets, providers).

---

## 6. Data model (Prisma)

Claude Code: implement exactly this schema in D1–D3 (core) and D11/D13 (training/premium), adjusting only for Prisma syntax errors. Record any change in `DECISIONS.md`.

```prisma
generator client { provider = "prisma-client-js" }
datasource db { provider = "postgresql"; url = env("DATABASE_URL") }

enum Role            { ADMIN TRAINER MEMBER KIOSK }
enum Tier            { BASIC PLUS PREMIUM }
enum PaymentMethod   { CASH TRANSFER QR CARD OTHER }
enum PaymentKind     { NEW RENEWAL UPGRADE ADJUSTMENT }
enum CheckinResult   { SUCCESS DUPLICATE DENIED_EXPIRED DENIED_INACTIVE INVALID_TOKEN }
enum NotificationType {
  CHECKIN_ADMIN CHECKIN_MEMBER CHECKIN_DENIED_ADMIN CHECKIN_DENIED_MEMBER
  EXPIRING_7 EXPIRING_3 EXPIRING_1 EXPIRED_MEMBER ADMIN_DAILY_SUMMARY
  PAYMENT_RECORDED TIER_CHANGED PLAN_ASSIGNED TRAINER_ASSIGNED TRAINER_NOTE
}
enum MuscleGroup { CHEST BACK SHOULDERS BICEPS TRICEPS LEGS GLUTES CORE CARDIO FULL_BODY OTHER }

model User {
  id                 String   @id @default(uuid())
  role               Role
  firstName          String
  lastName           String
  phone              String   @unique          // normalized, e.g. +59171234567
  email              String?  @unique
  passwordHash       String
  mustChangePassword Boolean  @default(true)
  isActive           Boolean  @default(true)
  birthDate          DateTime? @db.Date
  gender             String?
  emergencyContact   String?
  medicalNotes       String?                   // visible to admin/trainer only
  createdAt          DateTime @default(now())
  updatedAt          DateTime @updatedAt

  membership         Membership?   @relation("MemberMembership")
  trainedMemberships Membership[]  @relation("TrainerMemberships")
  refreshTokens      RefreshToken[]
  devices            Device[]
  checkins           Checkin[]
  checkinAttempts    CheckinAttempt[]
  notifications      Notification[]
  assignment         PlanAssignment?
  sessions           WorkoutSession[]
  measurements       Measurement[] @relation("MemberMeasurements")
  notesReceived      TrainerNote[] @relation("NoteMember")
  notesWritten       TrainerNote[] @relation("NoteAuthor")
  paymentsRecorded   Payment[]     @relation("PaymentRecordedBy")
  ownedPlans         Plan[]        @relation("MemberOwnedPlans")
}

model RefreshToken {
  id         String   @id @default(uuid())
  userId     String
  user       User     @relation(fields: [userId], references: [id])
  tokenHash  String   @unique
  expiresAt  DateTime
  revokedAt  DateTime?
  createdAt  DateTime @default(now())
  @@index([userId])
}

model Membership {
  id         String   @id @default(uuid())
  memberId   String   @unique
  member     User     @relation("MemberMembership", fields: [memberId], references: [id])
  tier       Tier
  startDate  DateTime @db.Date      // start of current continuous period
  endDate    DateTime @db.Date      // inclusive last valid day
  trainerId  String?
  trainer    User?    @relation("TrainerMemberships", fields: [trainerId], references: [id])
  payments   Payment[]
  tierChanges TierChange[]
  createdAt  DateTime @default(now())
  updatedAt  DateTime @updatedAt
  @@index([endDate])
}

model Payment {
  id            String        @id @default(uuid())
  membershipId  String
  membership    Membership    @relation(fields: [membershipId], references: [id])
  kind          PaymentKind
  tier          Tier
  months        Int           // 0 for UPGRADE/ADJUSTMENT
  periodStart   DateTime?     @db.Date
  periodEnd     DateTime?     @db.Date
  amount        Decimal       @db.Decimal(10, 2)
  suggestedAmount Decimal     @db.Decimal(10, 2)
  currency      String        @default("BOB")
  method        PaymentMethod
  note          String?
  recordedById  String
  recordedBy    User          @relation("PaymentRecordedBy", fields: [recordedById], references: [id])
  paidAt        DateTime      @default(now())
  voidedAt      DateTime?
  voidedById    String?
  voidReason    String?
  @@index([membershipId])
  @@index([paidAt])
}

model TierChange {
  id           String     @id @default(uuid())
  membershipId String
  membership   Membership @relation(fields: [membershipId], references: [id])
  fromTier     Tier
  toTier       Tier
  changedById  String
  createdAt    DateTime   @default(now())
}

model TierPrice {
  tier         Tier     @id
  monthlyPrice Decimal  @db.Decimal(10, 2)
  currency     String   @default("BOB")
  updatedAt    DateTime @updatedAt
}

model GymSettings {
  id                     Int     @id @default(1)
  gymName                String  @default("Mi Gimnasio")
  timezone               String  @default("America/La_Paz")
  checkinCooldownMinutes Int     @default(180)
  insideWindowMinutes    Int     @default(120)
  defaultCountryCode     String  @default("+591")
}

model Checkin {
  id        String   @id @default(uuid())
  memberId  String
  member    User     @relation(fields: [memberId], references: [id])
  tier      Tier                       // snapshot
  daysLeft  Int                        // snapshot
  kioskId   String
  createdAt DateTime @default(now())
  @@index([memberId, createdAt])
  @@index([createdAt])
}

model CheckinAttempt {
  id        String        @id @default(uuid())
  memberId  String?
  member    User?         @relation(fields: [memberId], references: [id])
  result    CheckinResult
  kioskId   String?
  detail    String?
  createdAt DateTime      @default(now())
  @@index([createdAt])
}

model Device {
  id         String   @id @default(uuid())
  userId     String
  user       User     @relation(fields: [userId], references: [id])
  fcmToken   String   @unique
  platform   String                     // android | ios
  lastSeenAt DateTime @default(now())
}

model Notification {
  id        String           @id @default(uuid())
  userId    String
  user      User             @relation(fields: [userId], references: [id])
  type      NotificationType
  title     String
  body      String
  data      Json?
  readAt    DateTime?
  createdAt DateTime         @default(now())
  @@index([userId, createdAt])
}

model NotificationLog {          // idempotency for scheduled notifications [R-25]
  id           String           @id @default(uuid())
  membershipId String
  type         NotificationType
  endDate      DateTime         @db.Date
  sentAt       DateTime         @default(now())
  @@unique([membershipId, type, endDate])
}

// ---------- Training (D11+) ----------

model Exercise {
  id          String      @id @default(uuid())
  name        String      @unique
  muscleGroup MuscleGroup
  description String?
  videoUrl    String?
  isActive    Boolean     @default(true)
  createdAt   DateTime    @default(now())
}

model Plan {
  id            String    @id @default(uuid())
  name          String
  description   String?
  level         String?            // beginner | intermediate | advanced
  isTemplate    Boolean   @default(true)
  ownerMemberId String?            // set for PREMIUM member-specific plans [R-36]
  ownerMember   User?     @relation("MemberOwnedPlans", fields: [ownerMemberId], references: [id])
  createdById   String
  isArchived    Boolean   @default(false)
  days          PlanDay[]
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt
}

model PlanDay {
  id        String         @id @default(uuid())
  planId    String
  plan      Plan           @relation(fields: [planId], references: [id], onDelete: Cascade)
  index     Int                       // 0-based order
  title     String                    // "Día 1 – Piernas"
  notes     String?
  exercises PlanExercise[]
  @@unique([planId, index])
}

model PlanExercise {
  id          String   @id @default(uuid())
  planDayId   String
  planDay     PlanDay  @relation(fields: [planDayId], references: [id], onDelete: Cascade)
  exerciseId  String
  order       Int
  sets        Int
  reps        String                 // "10" or "8-12" or "30s"
  restSeconds Int?
  targetWeightKg Decimal? @db.Decimal(6, 2)
  notes       String?
}

model PlanAssignment {
  memberId     String   @id
  member       User     @relation(fields: [memberId], references: [id])
  planId       String
  nextDayIndex Int      @default(0)
  assignedById String
  assignedAt   DateTime @default(now())
}

model WorkoutSession {
  id          String    @id @default(uuid())
  memberId    String
  member      User      @relation(fields: [memberId], references: [id])
  planId      String
  planDayId   String
  dayIndex    Int
  dayTitle    String                 // snapshot
  localDate   DateTime  @db.Date
  startedAt   DateTime  @default(now())
  finishedAt  DateTime?
  rpe         Int?                   // 1-10 perceived effort (optional)
  comment     String?
  sets        SetLog[]
  @@index([memberId, localDate])
}

model SetLog {
  id             String         @id @default(uuid())
  sessionId      String
  session        WorkoutSession @relation(fields: [sessionId], references: [id], onDelete: Cascade)
  planExerciseId String?
  exerciseId     String
  exerciseName   String                 // snapshot [R-32]
  setNumber      Int
  reps           Int?
  weightKg       Decimal?        @db.Decimal(6, 2)
  durationSec    Int?
  completed      Boolean         @default(true)
  createdAt      DateTime        @default(now())
}

// ---------- Premium (D13) ----------

model Measurement {
  id            String   @id @default(uuid())
  memberId      String
  member        User     @relation("MemberMeasurements", fields: [memberId], references: [id])
  localDate     DateTime @db.Date
  weightKg      Decimal? @db.Decimal(5, 2)
  bodyFatPct    Decimal? @db.Decimal(4, 1)
  muscleMassKg  Decimal? @db.Decimal(5, 2)
  chestCm       Decimal? @db.Decimal(5, 1)
  waistCm       Decimal? @db.Decimal(5, 1)
  hipsCm        Decimal? @db.Decimal(5, 1)
  armCm         Decimal? @db.Decimal(5, 1)
  thighCm       Decimal? @db.Decimal(5, 1)
  recordedById  String
  createdAt     DateTime @default(now())
  @@index([memberId, localDate])
}

model TrainerNote {
  id              String   @id @default(uuid())
  memberId        String
  member          User     @relation("NoteMember", fields: [memberId], references: [id])
  authorId        String
  author          User     @relation("NoteAuthor", fields: [authorId], references: [id])
  body            String
  visibleToMember Boolean  @default(true)
  createdAt       DateTime @default(now())
}

model MemberGoal {
  id          String   @id @default(uuid())
  memberId    String
  description String               // "Bajar a 75 kg"
  targetValue Decimal? @db.Decimal(6, 2)
  metric      String?              // weightKg | bodyFatPct | custom
  targetDate  DateTime? @db.Date
  achievedAt  DateTime?
  createdById String
  createdAt   DateTime @default(now())
}
```

**Date handling rule:** every `@db.Date` value is computed in the gym timezone with a single helper, `common/date/gym-date.ts` (`todayLocal()`, `addMonthsInclusive()`, `daysLeft()`, `toLocalDate(instant)`). Never use `new Date()` for "today" anywhere else. This helper needs the most unit tests in the project.

---

## 7. Notifications catalog

All notifications are (a) stored in `Notification` for the in-app inbox and (b) sent as push via FCM to all of the user's `Device`s. Invalid FCM tokens returned by Firebase are deleted. Texts are in Spanish by default (backend templates in `notifications/templates.ts`, with English variants keyed by the user's preferred language later; Spanish only in v1 is acceptable).

| Type | Trigger | Recipients | Title | Body (example) | `data` payload |
|---|---|---|---|---|---|
| `CHECKIN_ADMIN` | Successful check-in (not duplicate) | All active admins | Ingreso | Juan Pérez · Mensual ++ · 12 días restantes | `{memberId, checkinId}` → opens member detail |
| `CHECKIN_MEMBER` | Successful check-in (not duplicate) | Member | ¡Bienvenido, Juan! | Te quedan 12 días de membresía. | `{screen: "checkin_result"}` |
| `CHECKIN_DENIED_ADMIN` | Scan with expired membership | All active admins | Ingreso rechazado | Juan Pérez intentó ingresar: membresía vencida el 10/11/2026 | `{memberId}` |
| `CHECKIN_DENIED_MEMBER` | Same | Member | Membresía vencida | Tu membresía venció el 10/11/2026. Acércate a recepción para renovar. | `{screen: "home"}` |
| `EXPIRING_7` / `_3` / `_1` | Daily job [R-24] | Member | Tu membresía vence pronto | Te quedan 7 días (vence el 21/11/2026). | `{screen: "home"}` |
| `EXPIRED_MEMBER` | Daily job, day after endDate | Member | Tu membresía venció | Venció ayer. Renueva en recepción para seguir entrenando. | `{screen: "home"}` |
| `ADMIN_DAILY_SUMMARY` | Daily job, only if non-empty | All active admins | Resumen de membresías | 3 vencen en 7 días · 2 en 3 días · 1 mañana · 1 venció ayer | `{screen: "admin_expiring"}` |
| `PAYMENT_RECORDED` | Payment created | Member | Pago registrado | Renovaste Mensual + hasta el 14/12/2026. ¡Gracias! | `{screen: "home"}` |
| `TIER_CHANGED` | Tier change | Member | Tu plan cambió | Ahora tienes Mensual ++. | `{screen: "home"}` |
| `PLAN_ASSIGNED` | Plan assigned | Member | Nuevo plan de entrenamiento | Te asignaron "Fuerza Principiante – 3 días". | `{screen: "workout"}` |
| `TRAINER_ASSIGNED` | Trainer assigned | Member + trainer | Entrenador asignado | Tu entrenador es Carlos Rojas. / Nuevo alumno: Juan Pérez. | `{screen: ...}` |
| `TRAINER_NOTE` | Visible note created | Member | Nota de tu entrenador | (first 100 chars) | `{screen: "premium_notes"}` |

Push failures must never make the API request fail: send asynchronously after the database transaction commits, and log errors.

---

## 8. API specification (`/api/v1`)

Conventions:
- JSON, camelCase. Dates as `YYYY-MM-DD`, instants as ISO-8601 UTC.
- Pagination: `?page=1&pageSize=20` → `{ items, page, pageSize, total }`.
- Errors: `{ "statusCode": 409, "code": "MEMBERSHIP_EXPIRED", "message": "Human readable (es)", "details": {...} }`. Use a global exception filter. Define all codes in `common/errors/error-codes.ts`.
- Swagger at `/api/docs` (disabled in production unless `SWAGGER_ENABLED=true`).
- Rate limiting: login 5/min per IP+phone, check-in 10/min per user.

### 8.1 Auth
| Method | Path | Role | Body / Notes | Response |
|---|---|---|---|---|
| POST | `/auth/login` | public | `{phone, password}` | `{accessToken, refreshToken, user: {id, role, firstName, lastName, mustChangePassword}}` |
| POST | `/auth/refresh` | public | `{refreshToken}`; rotates the token (old one revoked) | same as login |
| POST | `/auth/logout` | any | `{refreshToken}`; also deletes the device FCM token if `fcmToken` is sent | `204` |
| POST | `/auth/change-password` | any | `{currentPassword, newPassword}`; sets `mustChangePassword=false` | `204` |
| GET | `/me` | any | — | user profile + membership summary (members) |

Access token TTL 15 min, refresh token TTL 30 days (hashed in DB). When `mustChangePassword` is true, every endpoint except `change-password`, `logout` and `me` returns `403 PASSWORD_CHANGE_REQUIRED`.

### 8.2 Users (admin)
| Method | Path | Notes |
|---|---|---|
| POST | `/admin/members` | Body: `{firstName, lastName, phone, email?, birthDate?, gender?, emergencyContact?, medicalNotes?, tier, months, startDate?, amount, method, note?}` → creates user + membership + first payment (`kind=NEW`) in **one transaction**. Returns member + `temporaryPassword` (only time it's returned). Errors: `PHONE_ALREADY_EXISTS`, `EMAIL_ALREADY_EXISTS`, `AMOUNT_NOTE_REQUIRED` |
| GET | `/admin/members` | Filters: `q` (name/phone), `tier`, `status=active|expiring|expired|inactive`, `expiringWithinDays`, `trainerId`; sort by `name|endDate|createdAt` |
| GET | `/admin/members/:id` | Profile, membership, daysLeft, last 10 check-ins, payments, assignment, trainer |
| PATCH | `/admin/members/:id` | Edit profile fields (not tier/dates) |
| POST | `/admin/members/:id/deactivate` / `reactivate` | [R-43] |
| POST | `/admin/members/:id/reset-password` | Returns new `temporaryPassword` [R-44] |
| POST | `/admin/staff` | Create TRAINER, ADMIN or KIOSK: `{role, firstName, lastName, phone, email?}` → `temporaryPassword` |
| GET | `/admin/staff` | List staff |

### 8.3 Memberships, payments, pricing
| Method | Path | Notes |
|---|---|---|
| GET | `/admin/members/:id/payments/preview?tier=PLUS&months=3` | Returns `{periodStart, periodEnd, suggestedAmount, currency}` using [R-07]/[R-08]/[R-10]. The UI calls this before confirming. |
| POST | `/admin/members/:id/payments` | `{tier, months (1-12), amount, method, note?, applyTierNow?}` → `kind=RENEWAL`. Updates membership, creates `TierChange` if needed, sends `PAYMENT_RECORDED`. |
| POST | `/admin/members/:id/tier-change/preview` | `{toTier}` → `{suggestedAmount, isUpgrade, warning?}` [R-13]/[R-14] |
| POST | `/admin/members/:id/tier-change` | `{toTier, amount, method?, note?}` → applies immediately, payment `kind=UPGRADE` if amount > 0 |
| POST | `/admin/payments/:id/void` | `{reason}` [R-12]; recalculates membership dates |
| GET | `/admin/payments` | Filters: `from`, `to`, `method`, `memberId`; includes totals |
| GET/PUT | `/admin/pricing` | Get/update `TierPrice` for the 3 tiers |
| GET/PUT | `/admin/settings` | `GymSettings` |
| GET | `/me/membership` | `{tier, startDate, endDate, daysLeft, status, trainer?}` |
| GET | `/me/payments` | Member's own payment history (no notes, no voided) |

**Recalculation algorithm** (used by void and as a consistency check): sort non-voided payments with `months > 0` by `paidAt`; replay [R-07]/[R-08] using each payment's `paidAt` local date as "today". Store `periodStart`/`periodEnd` on each payment. Unit test with at least 6 scenarios (on-time renewal, late renewal, early renewal, void of last payment, void of middle payment, month-end dates).

### 8.4 Kiosk and check-in
| Method | Path | Role | Notes |
|---|---|---|---|
| GET | `/kiosk/qr-token` | KIOSK | `{token, expiresAt, refreshInSeconds: 30}`. Token = JWT signed with `QR_TOKEN_SECRET`, claims `{typ:"checkin", kid:<kioskUserId>, jti, exp}` |
| POST | `/checkins` | MEMBER | `{qrToken}` → see below |
| GET | `/admin/checkins` | ADMIN | Filters `from`, `to`, `memberId`, paginated |
| GET | `/admin/checkins/inside` | ADMIN | Members inside now [R-23] |
| GET | `/admin/checkins/attempts` | ADMIN | Denied/invalid attempts |
| GET | `/me/checkins` | MEMBER | Own history (for attendance calendar) |

`POST /checkins` success response:
```json
{
  "result": "SUCCESS",            // or "DUPLICATE"
  "duplicate": false,
  "member": { "firstName": "Juan" },
  "membership": { "tier": "PLUS", "endDate": "2026-12-14", "daysLeft": 12 },
  "todayWorkout": {                // null for BASIC or no assignment
    "sessionStatus": "NOT_STARTED", // NOT_STARTED | IN_PROGRESS | FINISHED_TODAY
    "planName": "Fuerza 3 días",
    "dayIndex": 1, "dayTitle": "Día 2 – Espalda y bíceps",
    "exercises": [ { "planExerciseId": "...", "name": "Remo con barra", "sets": 4, "reps": "8-10", "restSeconds": 90, "targetWeightKg": 40, "lastPerformance": { "weightKg": 37.5, "reps": 10, "date": "2026-11-10" } } ]
  }
}
```
Errors: `400 QR_TOKEN_INVALID`, `400 QR_TOKEN_EXPIRED` (the UI says "Código vencido, escanea de nuevo"), `403 MEMBERSHIP_EXPIRED` (with `endDate`), `403 ACCOUNT_INACTIVE`.

### 8.5 Realtime (Socket.IO namespace `/realtime`)
- Auth: access token in the handshake `auth.token`. Only ADMIN joins the room `admins`.
- Events to `admins`: `checkin.created` `{checkinId, member: {id, firstName, lastName, photoUrl?}, tier, daysLeft, createdAt}`, `checkin.denied` `{member, reason, endDate}`.
- The client reconnects automatically and, on reconnect, reloads `/admin/checkins/inside` to fill any gap.

### 8.6 Notifications
| Method | Path | Notes |
|---|---|---|
| POST | `/me/devices` | `{fcmToken, platform}` upsert |
| DELETE | `/me/devices/:fcmToken` | On logout |
| GET | `/me/notifications` | Paginated inbox, `unreadCount` |
| POST | `/me/notifications/:id/read` / `/me/notifications/read-all` | |

### 8.7 Exercises and plans (ADMIN, TRAINER)
| Method | Path | Notes |
|---|---|---|
| CRUD | `/exercises` | `GET` is also allowed for MEMBER (names only). Soft delete via `isActive=false` |
| GET | `/plans?template=true` | Templates list |
| POST | `/plans` | Full nested body: `{name, description, level, days: [{title, notes, exercises: [{exerciseId, sets, reps, restSeconds, targetWeightKg, notes}]}]}` |
| GET | `/plans/:id` | Nested |
| PUT | `/plans/:id` | Replaces days/exercises in one transaction; applies [R-33] |
| POST | `/plans/:id/duplicate` | `{name?, ownerMemberId?}` → copy (used for [R-36]) |
| POST | `/plans/:id/archive` | Hidden from lists; existing assignments keep working |
| PUT | `/members/:id/assignment` | `{planId}` [R-27][R-34]; TRAINER only for own PREMIUM members |
| DELETE | `/members/:id/assignment` | |

### 8.8 Workouts (MEMBER, PLUS+)
| Method | Path | Notes |
|---|---|---|
| GET | `/me/workout/today` | Same shape as `todayWorkout` above, plus `openSession` if any |
| POST | `/me/workout/sessions` | Start session for the current `nextDayIndex` (or `{advance: true}` for [R-31]). Error `SESSION_ALREADY_OPEN` returns the open session id |
| PUT | `/me/workout/sessions/:id/sets` | Upsert a set: `{planExerciseId, setNumber, reps, weightKg, durationSec, completed}` |
| DELETE | `/me/workout/sessions/:id/sets/:setId` | |
| POST | `/me/workout/sessions/:id/finish` | `{rpe?, comment?}` [R-29] |
| DELETE | `/me/workout/sessions/:id` | Discard an open session |
| GET | `/me/workout/sessions` | History, paginated |
| GET | `/me/workout/sessions/:id` | Detail |
| GET | `/me/progress/summary` | `{totalSessions, sessionsThisMonth, checkinsThisMonth, currentStreakWeeks, lastSessionDate}` |
| GET | `/me/progress/exercises/:exerciseId` | Per-session best set, estimated 1RM (Epley: `w × (1 + reps/30)`), volume (`Σ reps×weight`) |

### 8.9 Premium
| Method | Path | Role | Notes |
|---|---|---|---|
| PUT | `/admin/members/:id/trainer` | ADMIN | `{trainerId|null}`; member must be PREMIUM |
| GET | `/trainer/members` | TRAINER | Own members with daysLeft, last check-in, last session, sessions this week |
| GET | `/trainer/members/:id` | TRAINER (own) / ADMIN | Profile (incl. medicalNotes), assignment, recent sessions, measurements, notes, goals |
| GET | `/trainer/members/:id/sessions` | TRAINER / ADMIN | Full session history with sets |
| CRUD | `/members/:id/measurements` | TRAINER (own) / ADMIN | [R-37] |
| CRUD | `/members/:id/notes` | TRAINER (own) / ADMIN | [R-38]; author can edit/delete own notes |
| CRUD | `/members/:id/goals` | TRAINER (own) / ADMIN | |
| GET | `/me/measurements`, `/me/notes`, `/me/goals` | MEMBER (PREMIUM) | Notes filtered by `visibleToMember` |
| GET | `/me/progress/body` | MEMBER (PREMIUM) | Time series for weight, body fat, waist, etc. |

### 8.10 Reports (ADMIN)
| Method | Path | Returns |
|---|---|---|
| GET | `/admin/reports/dashboard` | `{checkinsToday, insideNow, activeMembers: {BASIC, PLUS, PREMIUM, total}, expiringIn7Days, expiredLast30Days, revenueThisMonth, revenueLastMonth}` |
| GET | `/admin/reports/revenue?from&to&groupBy=day|month` | Totals by period, by tier, by method (non-voided) |
| GET | `/admin/reports/attendance?from&to` | Check-ins per day + per hour of day (busy hours heatmap data) |
| GET | `/admin/reports/expiring?days=7` | List for follow-up calls |

---

## 9. Mobile app: screens and behavior

General UX rules:
- Material 3, a single brand color set in `core/theme`, light + dark mode.
- Every screen that loads data has **loading**, **error (with Retry)** and **empty** states.
- Every form validates on the client (same rules as the backend) and shows backend error messages mapped from `code`.
- Money formatted as `Bs 150,00` (locale `es_BO`), dates `dd/MM/yyyy`.
- Tier badge colors: BASIC grey, PLUS blue, PREMIUM gold. Same widget everywhere.
- Pull-to-refresh on all lists.

### 9.1 Auth
1. **Splash:** reads stored tokens → calls `/me` → routes by role. Without tokens → Login.
2. **Login:** phone field with `+591` prefix selector and password field with a show/hide toggle. Error messages: wrong credentials, inactive account, no connection.
3. **Change password** (forced when `mustChangePassword`): new password + confirm, strength hint. After success → role home.
4. **Logout** in the profile/settings of every role: revokes the refresh token, deletes the FCM token, clears storage.
5. **Token refresh:** a dio interceptor refreshes on `401` once, queues concurrent requests, and logs out if the refresh fails.

### 9.2 Routing by role (go_router redirects)
- `ADMIN` → `/admin` (bottom nav: Dashboard · Socios · Ingresos · Planes · Más)
- `TRAINER` → `/trainer` (bottom nav: Mis alumnos · Planes · Perfil)
- `MEMBER` → `/member` (bottom nav: Inicio · Entrenamiento* · Progreso* · Perfil). *Tabs hidden for BASIC. PREMIUM adds "Mi entrenador".
- `KIOSK` → `/kiosk` (full screen, no navigation)
- A user who opens a route for another role is redirected to their home.

### 9.3 Admin screens
1. **Dashboard:** cards for check-ins today, inside now, active members by tier, expiring in 7 days (tap → filtered list), revenue this month vs last month. Below: the last 10 check-ins (live).
2. **Members list:** search box (name/phone), filter chips (Activos, Por vencer, Vencidos, Inactivos, tier), each row: name, tier badge, "12 días" / "Vencido hace 3 días" in red, last check-in. FAB "Nuevo socio".
3. **New member** (stepper):
   1. Personal data: first name, last name, phone, email (optional), birth date, gender, emergency contact, medical notes.
   2. Membership: tier selector (shows monthly price), months (1, 2, 3, 6, 12 or custom 1-12), start date (default today).
   3. Payment: suggested amount (from preview), editable amount, method, note (required if the amount changed).
   4. Summary → Confirm.
   5. Result screen shows the **temporary password** with "Copiar" and "Compartir por WhatsApp" (share_plus) and a warning that it is shown only once.
4. **Member detail:** header (name, phone with call/WhatsApp buttons, tier badge, status, days left as a progress ring), tabs:
   - *Membresía:* start/end dates, buttons **Renovar**, **Cambiar plan (tier)**.
   - *Pagos:* list with void option (asks for the reason).
   - *Ingresos:* check-in history + denied attempts.
   - *Entrenamiento* (PLUS+): assigned plan, next day, last sessions; button "Asignar plan".
   - *Entrenador* (PREMIUM): assign/change trainer.
   - *Datos:* edit profile, reset password, deactivate/reactivate.
5. **Renew dialog/screen:** tier, months → calls preview → shows "Nuevo periodo: 15/12/2026 – 14/01/2027" + suggested amount → amount, method, note → confirm.
6. **Tier change screen:** select target tier → preview shows upgrade charge or downgrade warning [R-13]/[R-14] → confirm.
7. **Check-ins (live):** two tabs, **Adentro ahora** and **Hoy**. New check-ins appear at the top with an animation and a short sound/vibration (can be turned off in settings). Denied attempts show in red.
8. **Plans:** exercise library + plan builder (Section 9.6).
9. **More:** Precios, Personal (trainers/admins/kiosks), Reportes, Configuración del gimnasio, Mi perfil, Cerrar sesión.
10. **Reports:** revenue chart by month (bar), attendance by day (line), busy-hours heatmap (7×24 grid), expiring list with call/WhatsApp buttons.

### 9.4 Kiosk mode
- Logged in once with a KIOSK account; stays logged in (refresh token renewed automatically).
- Full-screen screen: gym name/logo, a big QR (≥ 60% of the shorter side), a countdown bar to the next rotation, the text "Escanea con la app para ingresar", and a clock.
- Fetches a new token every 30 s. When offline, shows "Sin conexión" instead of a stale QR (never show an expired QR).
- Keeps the screen on (`wakelock_plus`), hides system bars (immersive mode), locks orientation to portrait.
- Optional: listens to `checkin.created` and shows a 3-second "¡Bienvenido, Juan!" overlay. Kiosk accounts need a `kiosk` socket room that receives only first names.
- Hidden exit: long-press the logo for 5 s → asks for an admin password → logs out.

### 9.5 Member screens
1. **Home:**
   - Membership card: name, tier badge, "Te quedan **12** días" with a progress ring, end date. Colors: green > 7 days, orange 1–7, red expired.
   - Big button **"Escanear para ingresar"**.
   - Expired: the card turns red with "Membresía vencida — acércate a recepción". The scan button stays enabled, because the backend handles the denial and notifies the admin.
   - Attendance this month (count) and a mini calendar with check-in days marked.
   - Notification bell with unread count.
2. **Scanner:** camera permission flow (explain → request → if denied, a button to open settings), scan frame overlay, torch toggle. On detect: vibrate, stop the camera, call `POST /checkins`, show a loading state.
3. **Check-in result:**
   - SUCCESS: big check animation, "¡Bienvenido, Juan!", days left, then:
     - BASIC: "Listo, ¡buen entrenamiento!" + button to Home.
     - PLUS/PREMIUM: **today's workout** preview (day title + exercise list) with button **"Empezar entrenamiento"**.
   - DUPLICATE: "Ya registraste tu ingreso hoy a las 18:05" + same content as success.
   - EXPIRED: red screen with end date and instructions.
   - QR expired/invalid: "Código no válido, vuelve a escanear" + retry.
4. **Today's workout / session (PLUS+):**
   - Header: plan name, "Día 2 de 3 – Espalda y bíceps".
   - One card per exercise: name, target `4 × 8-10`, rest, notes, **last performance** ("La última vez: 37,5 kg × 10").
   - Each set is a row: reps and weight inputs prefilled from the target/last performance, plus a checkbox to mark it done. "+ Serie" adds an extra set.
   - Rest timer: after marking a set done, start a countdown of `restSeconds` (local notification when it ends if the app is in the background).
   - Data saves to the backend on each set check (optimistic UI, retried when back online).
   - **Finish** button → dialog: RPE 1–10 slider + optional comment → summary (duration, sets, total volume, PRs achieved).
   - If the member leaves, the open session continues from the "Entrenamiento" tab.
5. **Training tab (PLUS+):** today's/next workout, the full plan overview (all days, next one highlighted), session history list.
6. **Progress tab (PLUS+):** totals (sessions, check-ins this month, weekly streak), an exercise picker → line chart of best weight / estimated 1RM over time, and a list of personal records.
7. **Premium extras:**
   - **Mi entrenador:** trainer name + WhatsApp button, visible notes (newest first), goals with progress.
   - **Mi cuerpo:** measurement history table + line charts (weight, body fat %, waist), with the first measurement vs the latest and the difference.
8. **Profile:** personal data (read-only, except a later password change), payment history, language, notification settings, logout.
9. **Notifications inbox:** list, tap → navigate by `data.screen`, mark all as read.

### 9.6 Plan builder (ADMIN, TRAINER)
- **Exercise library:** list with search and muscle-group filter; create/edit (name, group, description, optional video URL).
- **Plan editor:** name, description, level; a list of days (add, rename, reorder by drag, delete with confirmation); inside each day, exercises (pick from the library with search, sets, reps text, rest seconds, target weight, notes; reorder by drag).
- Validation: at least 1 day, each day at least 1 exercise, sets 1–10, rest 0–600 s.
- Actions: Save, Duplicate, Archive, **Assign to member** (opens a member picker filtered to PLUS/PREMIUM).

### 9.7 Trainer screens
1. **My members:** list with daysLeft, last check-in, "sessions this week", and an alert icon when there are no sessions in 7 days.
2. **Member detail:** tabs Resumen (profile + medical notes + goals) · Plan (current plan; **Personalizar** creates a member-specific copy [R-36] and opens the editor) · Sesiones (history with sets) · Medidas (list + add form + charts) · Notas (list + add, visibility toggle).

### 9.8 Push notifications on the device
- Request permission after login (iOS + Android 13+), with a short explanation screen first.
- Register/refresh the FCM token on login and when `onTokenRefresh` fires.
- Foreground: show an in-app banner (flutter_local_notifications) and refresh the related providers (e.g. the admin live feed).
- Tap (background/terminated): route using `data.screen` / `memberId`.

---

## 10. Non-functional requirements

- **Security:** HTTPS only in production; helmet; CORS restricted; argon2 hashing; refresh token rotation with reuse detection (a revoked token used again → revoke all of that user's tokens); role + tier + ownership guards; input validation on every DTO (`whitelist: true, forbidNonWhitelisted: true`); no medical notes in member-facing responses; logs never include passwords, tokens or medical notes.
- **Data integrity:** creating a member, payments, voids and tier changes run inside Prisma `$transaction`. Money uses `Decimal`, never float.
- **Time:** all "today" logic goes through `gym-date.ts`. The server runs in UTC.
- **Performance:** check-in endpoint p95 < 300 ms (excluding push). Index the queries used by lists.
- **Offline (mobile):** show a clear "Sin conexión" banner; workout set logging queues locally and syncs; check-in requires a connection (message if offline).
- **Accessibility:** text scales up to 1.3× without overflow; tap targets ≥ 48 dp; never rely on color alone (also show text like "Vencido").
- **Logging/monitoring:** structured JSON logs (pino) with a request id; Sentry on backend and mobile (D10).
- **Backups:** daily managed PostgreSQL backups (production, D14).
- **Configuration (`backend/.env.example`):** `DATABASE_URL`, `PORT`, `JWT_ACCESS_SECRET`, `JWT_ACCESS_TTL=15m`, `JWT_REFRESH_TTL_DAYS=30`, `QR_TOKEN_SECRET`, `QR_TOKEN_TTL_SECONDS=45`, `GYM_TIMEZONE=America/La_Paz`, `FIREBASE_SERVICE_ACCOUNT_JSON` (base64), `PUSH_ENABLED=true`, `SWAGGER_ENABLED=true`, `CORS_ORIGINS`, `SEED_ADMIN_PHONE`, `SEED_ADMIN_PASSWORD`.
- **Mobile config:** `--dart-define=API_BASE_URL=...` with three flavors/environments: `dev` (emulator `http://10.0.2.2:3000`), `staging`, `prod`.

---

## 11. Testing strategy

| Layer | What | Minimum |
|---|---|---|
| Backend unit | `gym-date.ts`, renewal/void recalculation, prorating, daysLeft, nextDayIndex logic, notification scheduling selection | Every `[R-xx]` rule that is pure logic |
| Backend e2e | Each endpoint: happy path, validation error, 401, 403 by role/tier/ownership | Uses a separate test database (`DATABASE_URL_TEST`), reset per suite |
| Mobile unit | Repositories (mocked dio), providers, date/money formatters | Key flows |
| Mobile widget | Login, member home states (active/expiring/expired), check-in result variants, set logging row | Key screens |
| Manual QA | Checklist at the end of each deliverable in `PROGRESS.md` | Tested on a **real Android phone** |

Time-dependent tests must inject a clock (`ClockService` in backend, `clockProvider` in mobile). Never depend on the real current date.

---

## 12. Deliverables (do them in order)

Each deliverable lists **Goal → Tasks → Acceptance criteria → Verification**.

### D0 — Repository and tooling
**Goal:** a clean monorepo where everything starts with documented commands.
**Tasks**
- Create the structure from 5.1. Move the existing Flutter project into `mobile/` (keep `applicationId`/bundle id as configured by the owner; if it is still `com.example`, add an entry to `OPEN_QUESTIONS.md`).
- `docker-compose.yml` with `postgres:16` (volume, healthcheck) and the optional `pgadmin` service.
- Root `README.md`: prerequisites, how to start the DB, backend and mobile, how to run tests.
- `docs/PROGRESS.md` with one checkbox section per deliverable D0–D14, plus `docs/DECISIONS.md` and `docs/OPEN_QUESTIONS.md`.
- `.gitignore` for Node, Flutter, env files, IDE folders.
- `.editorconfig`; Prettier + ESLint in backend; `analysis_options.yaml` with `flutter_lints` (strict) in mobile.

**Acceptance criteria**
- `docker compose up -d` starts Postgres and the healthcheck passes.
- `README.md` steps work on a fresh clone.

**Verification:** `docker compose ps` shows healthy; `cd mobile && flutter analyze` passes.

---

### D1 — Backend foundation
**Goal:** a NestJS API skeleton with config, database, errors, logs, docs and health.
**Tasks**
- `nest new backend` (strict TypeScript). Global prefix `/api/v1`.
- Typed config with validation; fail fast if a variable is missing.
- PrismaService; first migration with the **core** models (User, RefreshToken, Membership, Payment, TierChange, TierPrice, GymSettings, Checkin, CheckinAttempt, Device, Notification, NotificationLog).
- Global `ValidationPipe`, global exception filter with the error format from Section 8, `error-codes.ts`.
- pino logger with a request id; helmet; CORS; throttler.
- Swagger at `/api/docs`.
- `GET /api/v1/health` (checks the DB).
- `common/date/gym-date.ts` + `ClockService` with full unit tests for [R-01]–[R-05].
- Seed script: GymSettings, TierPrices (BASIC 150, PLUS 250, PREMIUM 400 BOB, placeholders the owner will change), the first ADMIN from `SEED_ADMIN_*`.

**Acceptance criteria**
- `npm run start:dev` serves `/api/v1/health` → `{status: "ok", db: "ok"}`.
- Swagger loads.
- Date helper tests cover the month-end examples in [R-04].

**Verification:** `npm run lint && npm run test && npm run build && npx prisma migrate dev && npx prisma db seed`

---

### D2 — Authentication and users
**Goal:** secure login with roles; admin can create staff.
**Tasks**
- `auth` module: login, refresh (rotation + reuse detection), logout, change-password, `/me`.
- JWT strategy, `@Roles()` decorator + `RolesGuard`, `@CurrentUser()` decorator.
- `MustChangePasswordGuard` (global, with an allow-list).
- Phone normalization utility ([R-40]) with tests (`71234567` → `+59171234567`, with spaces/dashes, already prefixed).
- Temporary password generator ([R-41]), using no ambiguous characters (0/O, 1/l/I).
- `POST/GET /admin/staff`. Rule [R-45].
- Login rate limiting.

**Acceptance criteria**
- Seeded admin can log in; must change password on first login if seeded with `mustChangePassword=true`.
- A refresh token works once; reuse revokes all of that user's tokens (e2e test).
- Non-admins get `403` on `/admin/*` (e2e).

**Verification:** backend gates (Section 0.8).

---

### D3 — Memberships, payments, pricing, settings
**Goal:** the full membership lifecycle on the backend.
**Tasks**
- `POST /admin/members` (transaction: user + membership + payment NEW).
- Members list/detail/edit/deactivate/reactivate/reset-password with filters and pagination.
- Payment preview + create (RENEWAL), tier change preview + apply (UPGRADE/downgrade), void with recalculation.
- Pricing and settings endpoints.
- `/me/membership`, `/me/payments`.
- Unit tests for [R-06]–[R-16], [R-41]–[R-45]; the recalculation scenarios from 8.3.

**Acceptance criteria**
- Every rule [R-01]–[R-16] has a passing test.
- Creating a member returns a temporary password that works for login.
- Voiding the last renewal restores the previous `endDate`.

**Verification:** backend gates.

---

### D4 — Mobile foundation
**Goal:** the app shell with login and role-based navigation, talking to the real backend.
**Tasks**
- Add dependencies (5.3); set up `build_runner`, freezed and json_serializable.
- `core/config` with `API_BASE_URL` via `--dart-define`, plus three run configurations (dev/staging/prod) documented in the README.
- dio client + auth interceptor (attach token, refresh on 401 once, queue requests, log out on failure); error mapping from backend `code` to localized messages.
- Secure token storage; session provider; splash → `/me` → route by role.
- Login, change password, logout.
- go_router with role redirects and placeholder home screens per role.
- Theme (Material 3, light/dark), tier badge widget, loading/error/empty widgets.
- Localization: `app_es.arb` (default) and `app_en.arb`; no hard-coded UI strings.

**Acceptance criteria**
- On a real Android phone (or emulator), the seeded admin logs in → forced password change → admin home.
- Closing and reopening the app keeps the session.
- Expired access token is refreshed transparently (test by setting the TTL to 1 minute in dev).

**Verification:** mobile gates; widget tests for the login form validation and the splash routing.

---

### D5 — Admin: member management UI
**Goal:** the admin can run the gym's memberships from the phone.
**Tasks:** screens 9.3 #2–#6 and the More → Precios / Personal / Configuración screens.
**Acceptance criteria**
- Create a member with the stepper; temporary password shown once with copy/share.
- List filters (active/expiring/expired/inactive/tier) and search work against the backend.
- Renew shows the correct new period from preview before confirming.
- Upgrade shows the prorated suggestion; downgrade shows the warning.
- Void payment asks for a reason and refreshes the member's dates.
- Create a TRAINER and a KIOSK account.

**Verification:** mobile gates; manual QA checklist in PROGRESS.md (create, renew early, renew late, upgrade, downgrade, void, deactivate, reset password).

---

### D6 — Check-in backend + realtime
**Goal:** the secure check-in flow on the server.
**Tasks**
- `kiosk` module: `GET /kiosk/qr-token` (KIOSK role only), signed with `QR_TOKEN_SECRET`.
- `checkins` module: `POST /checkins` implementing [R-17]–[R-23], attempts logging, response shape from 8.4 (for now `todayWorkout: null`).
- Admin check-in endpoints (list, inside, attempts) and `/me/checkins`.
- Socket.IO gateway `/realtime` with JWT handshake, `admins` room, events `checkin.created` / `checkin.denied`.
- e2e tests: valid scan; expired token; tampered token; another role's token used as the QR; duplicate within the cooldown; expired membership; inactive account; non-member calling `/checkins`.

**Acceptance criteria:** all [R-17]–[R-23] tests pass; a socket test client receives `checkin.created`.
**Verification:** backend gates.

---

### D7 — Check-in mobile (kiosk, scanner, live feed)
**Goal:** check-in works end to end on real devices.
**Tasks**
- Kiosk screen (9.4) including wakelock, immersive mode, rotation, offline state and the hidden exit.
- Member home (9.5 #1) with the membership card states.
- Scanner (9.5 #2) with the permission flow; Android `CAMERA` permission in `AndroidManifest.xml`; iOS `NSCameraUsageDescription` in `Info.plist` (Spanish text).
- Check-in result screen (9.5 #3), every variant.
- Admin live check-ins screen (9.3 #7) with socket + reconnect reload; the dashboard "last check-ins" widget becomes live.

**Acceptance criteria**
- Tablet/emulator shows the rotating QR; a real phone with a member account scans it → success screen with days left; the admin phone sees the entry within 2 seconds.
- Second scan within 3 h → "Ya registraste tu ingreso…", and the admin feed doesn't duplicate.
- Expired member → red screen; the admin sees a denied entry.
- A screenshot of the QR used after 45 s is rejected.

**Verification:** mobile gates; widget tests for every result variant; manual QA with two physical devices.

---

### D8 — Push notifications, scheduler, inbox
**Goal:** everyone is notified as in Section 7.
**Tasks**
- Firebase project setup instructions in `docs/FIREBASE_SETUP.md` (Android `google-services.json`, iOS APNs key + `GoogleService-Info.plist`, service account for the backend). **The owner does the console steps; Claude Code writes the instructions and the code.**
- Backend `notifications` module: templates, store + send, invalid token cleanup, `PUSH_ENABLED` switch (when false, only store and log).
- Hook notifications into check-in, payments, tier change.
- `scheduler` module: daily job 08:00 gym time [R-24]–[R-26] with `NotificationLog` idempotency; nightly job 23:59 for [R-30] (no-op until D12); both also callable via an admin-only `POST /admin/jobs/:name/run` in non-production for testing.
- Mobile: permission flow, token registration/refresh, foreground banners, tap routing, inbox screen with unread badge.

**Acceptance criteria**
- Check-in triggers pushes to the admin and the member phone (real devices).
- Running the daily job twice the same day sends each reminder once (e2e with an injected clock).
- Tapping a notification opens the right screen from background and terminated states.

**Verification:** backend + mobile gates; manual push test on Android (iOS in D14).

---

### D9 — Admin dashboard and reports
**Goal:** the owner sees how the business is doing.
**Tasks:** `reports` module (8.10); dashboard screen (9.3 #1); reports screen (9.3 #10) with `fl_chart`; payments list with date range filter and totals.
**Acceptance criteria:** the numbers match a SQL check on seeded data (add a `prisma/seed-demo.ts` with 40 members, 3 months of payments and check-ins for demos and tests).
**Verification:** backend + mobile gates; e2e tests for report totals against seeded data.

---

### D10 — v1 hardening and Android release build (**v1 = BASIC tier complete**)
**Goal:** a stable v1 usable in the gym.
**Tasks**
- Sentry (backend + mobile) with DSNs in env/dart-define.
- Review every screen for loading/error/empty states, text scaling and dark mode.
- Offline banner; no-connection handling for check-in.
- Backend `Dockerfile` (multi-stage) + `docs/DEPLOY.md` for a staging deployment (Railway/Render/VPS + managed Postgres + HTTPS).
- Android app icon, splash, app name "<Gym name>", release signing config (keystore path via `key.properties`, git-ignored), `flutter build appbundle --dart-define=...`.
- Security review checklist (Section 10) ticked in PROGRESS.md.

**Acceptance criteria:** a release APK/AAB connected to staging works for the full BASIC flow on 2+ real Android phones; no crashes in a 30-minute manual session.
**Verification:** all gates + manual QA checklist v1.

> 🚩 **Milestone v1:** the gym can start using the app with real members on Android.

---

### D11 — PLUS backend + plan builder UI
**Goal:** admins/trainers can build plans and assign them.
**Tasks**
- Migration for Exercise, Plan, PlanDay, PlanExercise, PlanAssignment, WorkoutSession, SetLog.
- Seed ~40 common exercises in Spanish with muscle groups (e.g. Sentadilla, Press banca, Peso muerto, Remo con barra, Jalón al pecho, Press militar, Curl de bíceps, Extensión de tríceps, Prensa, Zancadas, Plancha…), plus 2 template plans ("Principiante Full Body – 3 días", "Torso/Pierna – 4 días").
- Endpoints 8.7 with [R-27], [R-32]–[R-34], `PLAN_ASSIGNED` notification.
- Mobile: exercise library, plan editor with drag & drop, assign to member, the "Entrenamiento" tab in admin member detail.

**Acceptance criteria:** create a 3-day plan with 5 exercises per day, reorder, save, reopen and see the same order; assigning to a BASIC member is rejected (`403 TIER_REQUIRED`).
**Verification:** gates; tests for the [R-33] and [R-34] rules.

---

### D12 — PLUS member workout flow and progress
**Goal:** members train with the app after check-in.
**Tasks**
- Endpoints 8.8 with [R-28]–[R-31]; `todayWorkout` included in the check-in response; the nightly auto-finish job from D8 becomes active.
- Mobile 9.5 #3 (PLUS variant), #4, #5, #6: session logging with optimistic saves + offline queue, rest timer, finish dialog with summary and PR detection, history, progress charts.
- Downgrade/upgrade behavior [R-15] verified in the UI (tabs hide and reappear).

**Acceptance criteria**
- A PLUS member checks in → sees Day 1 → logs sets → finishes → the next check-in (after the cooldown, or the next day) shows Day 2; after the last day it returns to Day 1.
- Logging a set in airplane mode syncs when back online.
- The progress chart shows the estimated 1RM trend for an exercise with ≥ 3 sessions.

**Verification:** gates; unit tests for nextDayIndex, Epley, PR detection; widget test for the set row.

---

### D13 — PREMIUM: trainers, customization, measurements, notes, goals
**Goal:** a personal-trainer experience.
**Tasks**
- Migration for Measurement, TrainerNote, MemberGoal.
- Endpoints 8.9 with [R-35]–[R-39]; `TRAINER_ASSIGNED`, `TRAINER_NOTE` notifications.
- Admin: assign a trainer in member detail.
- Trainer app (9.7), including "Personalizar plan" (duplicate + edit).
- Member premium screens (9.5 #7): Mi entrenador, Mi cuerpo with charts, goals.
- e2e ownership tests: trainer A cannot read trainer B's members; members cannot see private notes or other members' data.

**Acceptance criteria:** the full premium story works on devices: admin assigns trainer → trainer customizes the plan and records measurements + a note → the member sees the note, the updated plan at the next check-in and the measurement chart.
**Verification:** gates.

---

### D14 — iOS, production and store release
**Goal:** both apps are published.
**Tasks**
- iOS: bundle id, signing (owner's Apple Developer account), APNs key in Firebase, icons, launch screen, camera and notification permission texts, test on a real iPhone via TestFlight. Requires a Mac or a CI service such as Codemagic; document the chosen path in `docs/IOS_RELEASE.md`.
- Production backend: environment, managed Postgres with daily backups, HTTPS domain, Swagger disabled, secrets rotated, seed admin password changed.
- Store assets: screenshots (admin, member, kiosk), descriptions in Spanish, privacy policy page (data collected: name, phone, email, attendance, workout and body data; purpose; contact), and data safety / App Privacy forms.
- Play Store: internal testing → production. App Store: TestFlight → review. Provide a demo account for reviewers (Apple requires login credentials, since there is no sign-up).

**Acceptance criteria:** the app is installable from both stores (or at least approved in internal testing/TestFlight), pointing to production.

---

## 13. Out of scope for v1 (do not build unless the owner asks)

- Online payments inside the app (payments are recorded manually by the admin).
- Member self sign-up, social login.
- Chat between trainer and member (use WhatsApp buttons).
- Membership freeze/pause.
- Multiple gym branches.
- Check-out / occupancy tracking beyond the "inside" time window.
- Class scheduling/booking.
- Progress photos (candidate for after v1: needs storage and privacy review).
- Web admin panel (candidate for after v1; the API already supports it).

---

## 14. Open questions for the owner (Claude Code: copy these into `docs/OPEN_QUESTIONS.md` in D0)

1. Real monthly prices for BASIC / PLUS / PREMIUM, and the currency (assumed BOB).
2. Is login by phone number OK, or do members have email?
3. Upgrade proration rule [R-13] and "no refund on downgrade" [R-14]: confirm.
4. Check-in cooldown (3 h) and the expiry reminder days (7/3/1): confirm.
5. Daily notification time (08:00): confirm.
6. Gym name, logo and brand colors for the app and kiosk screen.
7. Final Android `applicationId` / iOS bundle id (e.g. `com.<gymname>.app`), which can't change after publishing.
8. Which device will be the kiosk (Android tablet model)?
9. Are trainers employees with their own phones (needed for the trainer app)?
10. Who owns the Apple Developer and Google Play accounts (should be the business, not a personal account)?

---

## 15. `docs/PROGRESS.md` template (create in D0)

```markdown
# Progress

| Deliverable | Status | Date | Notes |
|---|---|---|---|
| D0 Repo & tooling | ⬜ | | |
| D1 Backend foundation | ⬜ | | |
| D2 Auth & users | ⬜ | | |
| D3 Memberships & payments | ⬜ | | |
| D4 Mobile foundation | ⬜ | | |
| D5 Admin member UI | ⬜ | | |
| D6 Check-in backend | ⬜ | | |
| D7 Check-in mobile | ⬜ | | |
| D8 Notifications & scheduler | ⬜ | | |
| D9 Dashboard & reports | ⬜ | | |
| D10 v1 hardening & Android release | ⬜ | | |
| D11 Plans (PLUS) backend + builder | ⬜ | | |
| D12 Member workouts & progress | ⬜ | | |
| D13 Premium | ⬜ | | |
| D14 iOS & store release | ⬜ | | |

Status: ⬜ not started · 🟡 in progress · ✅ done (all acceptance criteria met)

## Manual QA checklists
(Add one checklist per deliverable here as it is completed.)
```

---

## 16. How the owner should drive Claude Code

1. Put this file at `docs/PLAN.md` and create a short `CLAUDE.md` in the repo root:
   ```markdown
   # CLAUDE.md
   - Follow docs/PLAN.md strictly. Section 0 has the working rules.
   - Current progress is in docs/PROGRESS.md; decisions in docs/DECISIONS.md.
   - Backend: cd backend && npm run lint && npm run test && npm run test:e2e && npm run build
   - Mobile: cd mobile && flutter analyze && flutter test && dart format --set-exit-if-changed .
   - Never commit .env files or keystores.
   ```
2. Ask for **one deliverable per session**, e.g. *"Implement D3 from docs/PLAN.md. Stop when its acceptance criteria pass and update PROGRESS.md."*
3. After each deliverable, **review the code yourself and test on your phone** before asking for the next. This is how you learn Flutter while the project advances.
4. Answer the questions in `OPEN_QUESTIONS.md` as soon as they appear. Defaults are used until then.
5. Rough effort with Claude Code doing most of the typing (part-time owner, ~15 h/week, including review and device testing): D0–D10 (v1) ≈ **6–9 weeks**, D11–D12 ≈ **3–4 weeks**, D13 ≈ **2–3 weeks**, D14 ≈ **2–3 weeks** (store reviews are outside your control). Total ≈ **3–4.5 months**.
