# 🎨 Design System Migration Guide

## Quick Reference: Old → New

### Colors
| Old | New |
|-----|-----|
| `Color(hex: "#6B4EAA")` | `Gentle.Primary.purple` |
| `Color(hex: "#A78BFA")` | `Gentle.Primary.lavender` |
| `Color(hex: "#F472B6")` | `Gentle.Primary.pink` |
| `Color(hex: "#FCD34D")` | `Gentle.Primary.yellow` |
| `Color(hex: "#F59E0B")` | `Gentle.Primary.orange` |
| `Color(hex: "#8B5CF6")` | `Gentle.Primary.indigo` |
| `Color(hex: "#1F1035")` | `Gentle.Text.primary` |
| `Color(hex: "#6B7280")` | `Gentle.Text.secondary` |
| `Color(hex: "#9CA3AF")` | `Gentle.Text.tertiary` |
| `Color.white` | `Gentle.Background.secondary` |
| `Color(hex: "#F5F0FF")` | `Gentle.Background.primary` |
| `Color(hex: "#EDE9FE")` | `Gentle.Background.tertiary` |
| `Color.blue` | `Gentle.Text.link` or `Gentle.Primary.indigo` |
| `Color.red` | `Gentle.State.error` |
| `Color.gray` | `Gentle.Text.secondary` |
| `.gray.opacity(0.1)` | `Gentle.Border.light` |
| `.gray.opacity(0.2)` | `Gentle.Border.medium` |
| `Color(hex: "#E0D2FE")` | `Gentle.Text.darkSecondary` (≈ lavender tint) |

### Typography
| Old | New |
|-----|-----|
| `.font(.system(size: N, weight: .ultraLight))` | `GentleFont.display(N)` |
| `.font(.system(size: N, weight: .semibold))` | `GentleFont.title(N)` or `.headline(N)` |
| `.font(.headline)` | `GentleFont.headline(17)` |
| `.font(.subheadline)` | `GentleFont.body(15)` |
| `.font(.body)` | `GentleFont.body(15)` |
| `.font(.caption)` | `GentleFont.caption(12)` |
| `.font(.system(size: N, design: .monospaced))` | `GentleFont.mono(N)` |
| `.fontWeight(.semibold)` (inlined) | Use `GentleFont.title()` / `.headline()` |

### Spacing
| Old | New |
|-----|-----|
| `.padding(4)` | `GentleSpacing.xxs` |
| `.padding(8)` | `GentleSpacing.xs` |
| `.padding(12)` | `GentleSpacing.sm` |
| `.padding(16)` | `GentleSpacing.md` |
| `.padding(20)` | `GentleSpacing.lg` |
| `.padding(24)` | `GentleSpacing.xl` |
| `.padding(30)` | `GentleSpacing.xxl` |
| `.padding(40)` | `GentleSpacing.xxxl` |
| `.padding(.horizontal, N)` + `.padding(.vertical, N)` | `.padding(GentleSpacing.md)` or `.padding(.horizontal, GentleSpacing.md)` |

### Corner Radii
| Old | New |
|-----|-----|
| `.cornerRadius(8)` | `GentleRadius.sm` |
| `.cornerRadius(10)` | `GentleRadius.sm` |
| `.cornerRadius(12)` | `GentleRadius.md` |
| `.cornerRadius(14)` | `GentleRadius.lg` |
| `.cornerRadius(16)` | `GentleRadius.lg` |
| `.cornerRadius(20)` | `GentleRadius.xl` |
| `.cornerRadius(24)` | `GentleRadius.xxl` |

### Shadows
| Old | New |
|-----|-----|
| `.shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)` | `GentleShadow.sm` |
| `.shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)` | `GentleShadow.sm` |
| `.shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)` | `GentleShadow.md` |
| `.shadow(color: .black.opacity(0.14), radius: 12, x: 0, y: 6)` | `GentleShadow.lg` |
| `.shadow(color: Color(hex:"#8B5CF6").opacity(0.4), radius: 12, x: 0, y: 6)` | `GentleShadow.glow` |
| inline `.shadow` | Use `GentleShadow.apply(shadow) { ... }` |

### Gradients
| Old | New |
|-----|-----|
| `LinearGradient(colors:[purple, lavender])` | `Gentle.Gradient.primaryButton` |
| `LinearGradient(colors:[lavender, pink])` | `Gentle.Gradient.secondaryButton` |
| `LinearGradient(colors:[yellow, orange])` | `Gentle.Gradient.warmButton` |
| `LinearGradient(colors:[indigo, lavender])` | `Gentle.Gradient.breathing` |
| `LinearGradient(colors:[white.opacity(0.9), white.opacity(0.6)])` | `Gentle.Gradient.card` |

### Button Styles
| Old | New |
|-----|-----|
| `Button(...).buttonStyle(PlainButtonStyle())` + custom | `.buttonStyle(GentlePrimaryButtonStyle())` |
| Gray ghost button | `.buttonStyle(GentleSecondaryButtonStyle())` |
| Inline `.foregroundColor(.blue)` + opacity | `.buttonStyle(GentleGhostButtonStyle())` |
| Red destructive | `.buttonStyle(GentleDestructiveButtonStyle())` |
| Icon circle button | `.buttonStyle(GentleIconButtonStyle())` |

### TextField Styles
| Old | New |
|-----|-----|
| Inline text field styling (padding+border+cornerRadius) | `.textFieldStyle(GentleTextFieldStyle())` |

### View Modifiers
| Old | New |
|-----|-----|
| Card with shadow | `.gentleCard()` |
| Divider | `.gentleDivider()` |
| Tag/pill | `.gentleTag(color: Gentle.Primary.lavender)` |

### Component Replacements
| Old | New |
|-----|-----|
| Inline card (RoundedRectangle+fill+shadow) | Use `GentleCard` modifier |
| Inline avatar (ZStack+Circle+Text) | `GentleAvatar(initials: "XY")` |
| Inline loading spinner | `GentleLoadingIndicator()` |
| Inline empty state | `GentleEmptyState(icon: "tray", title: "...", message: "...")` |
| Inline section header | `GentleSectionHeader(title: "...")` |
| Inline star rating | `GentleStarRating(rating: $binding)` |

## File Status
- [x] `Design.swift` — created (centralized design system)
- [ ] `MainView.swift` — needs migration
- [ ] `PomodoroView.swift` — needs migration (large, ~1000+ lines)
- [ ] `GentleWallView.swift` — needs migration
- [ ] `SocialFeedView.swift` — needs migration
- [ ] `SettingsView.swift` — needs migration
- [ ] `FriendsView.swift` — needs migration
- [ ] `MessagesView.swift` — needs migration
- [ ] `AuthView.swift` — needs migration
- [ ] `AccountManagerView.swift` — needs migration
- [ ] `OnboardingView.swift` — needs migration
- [ ] `ActivationFlowView.swift` — needs migration
- [ ] `TimeModeView.swift` — needs migration
- [ ] `GentleSleepView.swift` — needs migration
- [ ] `CustomMessageView.swift` — needs migration
- [ ] `ContentView.swift` — needs migration
- [ ] `PomodoroSubviews.swift` — needs migration
- [x] `Extensions.swift` — keep as-is (Color(hex:))
- [x] `GentleCompanionApp.swift` — mostly fine
- [x] Models/ — no UI code, keep as-is

## How to Migrate a File
1. Add `import SwiftUI` if not present
2. Replace all hard-coded colors using the table above
3. Replace `.font(.system(...))` with `GentleFont.*`
4. Replace magic numbers in `.padding()` with `GentleSpacing.*`
5. Replace magic numbers in `.cornerRadius()` with `GentleRadius.*`
6. Replace inline shadows with `GentleShadow.sm/md/lg/glow`
7. Replace inline gradients with `Gentle.Gradient.*`
8. Replace custom button styles with built-in button styles
9. Replace inline cards with `.gentleCard()` modifier
10. Replace reusable components with Design.swift counterparts
