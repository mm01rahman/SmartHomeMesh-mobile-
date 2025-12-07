# SmartHomeMesh-mobile-

Architecture overview and code for SmartHomeMesh – esp v2.0 using NestJS backend with MQTT + PostgreSQL and Flutter client with Riverpod/go_router.

## Tech choices
- **Backend:** NestJS (TypeScript), Prisma ORM, PostgreSQL, JWT auth, HiveMQ Cloud MQTT via `mqtt` library. Deploy via Render web service.
- **Flutter:** Riverpod + go_router, dio HTTP client, secure storage for JWT.
- **MQTT topics:** base `smarthome`; JOIN/STATUS/LWT subscriptions and CMD publishing follow esp v2.0 protocol.

See `backend/` and `app/` for code.
