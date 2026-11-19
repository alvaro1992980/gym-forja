# CLAUDE.md
- Follow docs/PLAN.md strictly. Section 0 has the working rules.
- Current progress is in docs/PROGRESS.md; decisions in docs/DECISIONS.md.
- Backend: cd backend && npm run lint && npm run test && npm run test:e2e && npm run build
- Mobile: cd mobile && flutter analyze && flutter test && dart format --set-exit-if-changed .
- Never commit .env files or keystores.