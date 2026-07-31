# Security Baseline & Privacy Design Principles

## Privacy & Security Policies

1. **Zero Secret Storage**:
   - The application does not store, request, or compile any API keys, backend secrets, passwords, or authentication tokens.

2. **Approximate Locality Enforcement**:
   - Nukkad enforces privacy by design: **exact street addresses, house numbers, or GPS coordinates are never collected**.
   - Users select approximate neighborhood areas (e.g. *Sector 15 Main Market*, *Green Park Blocks A-D*) preserving anonymity.

3. **Input Sanitization & Boundary Validation**:
   - Listing titles and descriptions are trimmed and validated before local storage to prevent malformed object states.

4. **Self-Service Data Reset**:
   - Users have complete control over local data. The **Reset Local Data** function in Settings enables clearing local Hive boxes instantly.

5. **Zero Telemetry / Cloud Sync**:
   - Zero analytics, tracking scripts, network calls, or telemetry run in the application.
