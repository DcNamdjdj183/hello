import re

with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

patchFunc = """
func applyPatchFile(filename: String) {
    guard let resourcePath = Bundle.main.resourcePath else { return }
    let patchesPath = resourcePath + "/Patches"
    let fm = FileManager.default
    if let enumerator = fm.enumerator(atPath: patchesPath) {
        for case let file as String in enumerator {
            if file.hasSuffix(filename) {
                let fullPath = patchesPath + "/" + file
                if let data = try? Data(contentsOf: URL(fileURLWithPath: fullPath)) {
                    let passes = ["3105", "Tele@YaPaor", ""]
                    for pass in passes {
                        if let decoded = try? PatchPackageCodec.decode(data, password: pass.isEmpty ? nil : pass) {
                            _ = try? DevicePatchService.apply(project: decoded.project)
                            return
                        }
                    }
                }
                break
            }
        }
    }
}
"""

text = text.replace('struct InteractiveRow: View {', patchFunc + '\nstruct InteractiveRow: View {')

oldRow = """        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            isEnabled.toggle()
        }) {"""

newRow = """        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            isEnabled.toggle()
            if isEnabled {
                DispatchQueue.global(qos: .userInitiated).async {
                    applyPatchFile(filename: item)
                }
            }
        }) {"""

text = text.replace(oldRow, newRow)

with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
    f.write(text)

print("Patch auto-apply added.")
