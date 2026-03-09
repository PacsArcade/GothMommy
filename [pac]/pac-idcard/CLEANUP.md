# Asset Cleanup Log

The following files were removed from this branch (idcards) to reduce load size.
They remain in the upstream fork (PacsArcade/pac-idcard, v1-clean-rebuild) for reference.

## Removed
| File | Size | Reason |
|------|------|--------|
| `ui/assets/id-card.psd` | 4.0 MB | Source file, not loaded by game client |
| `ui/assets/previewphoto.png` | 452 KB | Not referenced in any HTML/CSS/JS |
| `ui/assets/cross2.png` | 50 KB | Not referenced in any HTML/CSS/JS |
| `ui/assets/frame2.png` | 21 KB | Not referenced in any HTML/CSS/JS |
| `ui/assets/fonts/SketchPencilDemoRegular.ttf` | 194 KB | Only Italic variant is used in style.css |
| `ui/assets/fonts/Arington_Demo.ttf` | 37 KB | Declared in @font-face but never applied to any element |

**Total saved: ~4.75 MB**

## Kept
All other assets confirmed referenced in style.css, index.html, or main.js.
