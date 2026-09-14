import re

with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

# Let's find PremiumToggleRow and add isDisabled
old_struct = """struct PremiumToggleRow: View {
    let name: String
    let pkg: String
    @Binding var isOn: Bool
    let isBusy: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(pkg)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { isOn },
                set: { _ in action() }
            ))
            .labelsHidden()
            .tint(.purple)
            .disabled(isBusy)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
    }
}"""

new_struct = """struct PremiumToggleRow: View {
    let name: String
    let pkg: String
    @Binding var isOn: Bool
    let isBusy: Bool
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(pkg)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { isOn },
                set: { _ in action() }
            ))
            .labelsHidden()
            .tint(.purple)
            .disabled(isBusy || isDisabled)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
    }
}"""

if old_struct in text:
    text = text.replace(old_struct, new_struct)
    with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
        f.write(text)
    print("Successfully added isDisabled to PremiumToggleRow!")
else:
    print("Could not find the exact struct block. Trying regex...")
    # fallback
    text = text.replace("    let isBusy: Bool\n    let action: () -> Void", "    let isBusy: Bool\n    var isDisabled: Bool = false\n    let action: () -> Void")
    text = text.replace(".disabled(isBusy)\n", ".disabled(isBusy || isDisabled)\n")
    with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
        f.write(text)
    print("Used fallback replacement.")
