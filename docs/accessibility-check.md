# Accessibility Checklist & Compliance Audit

Nukkad is designed with accessibility as a core architectural requirement, meeting WCAG 2.1 AA guidelines.

## Audit Summary

1. **Touch Target Dimensions**:
   - All buttons (`ElevatedButton`, `OutlinedButton`, `IconButton`, `FloatingActionButton`) enforce a minimum touch target size of **48x48dp** (via `ElevatedButton.styleFrom(minimumSize: Size(88, 48))` and explicit constraints).

2. **Screen Reader Semantics**:
   - `ListingCard` is wrapped in explicit `Semantics` tags reading:
     `"[Category] listing: [Title] in [Approximate Area]. Status: [Status]"`
   - Interactive icons include descriptive `tooltip` parameters (`"Save listing"`, `"Clear Form"`, `"Settings"`).

3. **Color Contrast & Dynamic Theming**:
   - Light and dark themes utilize high-contrast primary text (`#1C1B1F` on light, `#E6E1E5` on dark).
   - Category badges combine background tints with strong foreground text colors.

4. **Typography & Text Scaling**:
   - All text widgets use relative Material typography styles (`titleMedium`, `bodyLarge`, `bodySmall`) supporting system-level text scale adjustments without clipping.

5. **Form Validation Feedback**:
   - Dynamic error banners and inline field validations provide clear visual feedback for input omissions.
