# Open questions for the owner

Defaults from the plan are used until each question is answered. Write the answer below the question
and the date; Claude Code will apply it and move the item to DECISIONS.md.

1. **Prices:** real monthly prices for BASIC / PLUS / PREMIUM, and the currency.
   *Default: BASIC 150, PLUS 250, PREMIUM 400, BOB (placeholders).*
2. **Login:** is login by phone number OK, or do members have email?
   *Default: phone number, with email optional.*
3. **Upgrades and downgrades:** confirm the upgrade proration rule [R-13] and "no refund on downgrade" [R-14].
4. **Check-in and reminders:** confirm the check-in cooldown (3 h) and the expiry reminder days (7/3/1).
5. **Daily notification time:** confirm 08:00 gym time.
6. **Branding:** gym name, logo and brand colors for the app and the kiosk screen.
7. **App IDs (cannot change after publishing):** final Android `applicationId` and iOS bundle id, e.g. `com.<gymname>.app`.
   *The project is currently `com.example.gym_app` (from `flutter create`), and the stores reject `com.example`. This must be decided before D10 (Android release build).*
8. **Kiosk device:** which device will be the kiosk (Android tablet model)?
9. **Trainers:** are trainers employees with their own phones (needed for the trainer app)?
10. **Store accounts:** who owns the Apple Developer and Google Play accounts? They should belong to the business, not to a person.
