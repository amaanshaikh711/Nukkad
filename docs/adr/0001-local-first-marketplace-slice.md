# ADR 0001: Local-First Neighborhood Marketplace Architecture

- **Status:** Accepted
- **Date:** 2026-07-31
- **Deciders:** Lead Flutter Software Architect & Senior Product Engineer

---

## Context & Problem Statement

The Nukkad application requires building a local-first neighborhood marketplace for residents of a single locality to buy, sell, lend, and help. The primary objective is to complete the first useful local loop while demonstrating clean architecture, accessibility, privacy preservation, offline-first execution, and isolated AI helpers without introducing unnecessary cloud backend dependencies.

---

## Decision Drivers

- **Offline-First Requirement**: Application must function seamlessly without internet, hosted APIs, or cloud infrastructure.
- **Strict Layer Separation**: UI must not depend on storage implementation details or AI model internals.
- **Accessibility & Quality**: Compliance with WCAG 2.1 AA (touch targets, semantics, color contrast).
- **Zero Secrets**: No API keys, passwords, or exact location tracking.

---

## Considered Options

1. **Option 1: Direct Hive Access in UI Widgets** (Rejected - tightly couples presentation to storage).
2. **Option 2: Cloud Database with Firebase/Supabase** (Rejected - violates offline-first constraint & introduces authentication complexity).
3. **Option 3: Clean Architecture with Hive Storage, Riverpod State, GoRouter Navigation & Isolated Local AI Abstraction** (**Selected**).

---

## Decision Outcome

**Selected Option 3**: Clean Architecture with local Hive storage and an isolated rule-based AI service.

### Consequences:
- **Positive**:
  - 100% offline capability with zero external API key requirements.
  - UI widgets strictly consume domain repositories and Riverpod state providers.
  - AI engine can be upgraded to on-device LLMs in the future by replacing a single provider binding.
  - Complete privacy preservation (approximate areas only).
- **Negative / Trade-offs**:
  - Requires maintaining local seed initialization for initial app launch experience.
