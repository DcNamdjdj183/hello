import re

with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    text = f.read()

# Let's extract the block manually using string matching.
start_str = '                            if selectedScriptCategory == 0 {'
end_str = '                            } else if selectedScriptCategory == 3 {\n                                VStack(spacing: 0) {\n                                    PremiumToggleRow(name: "ESP FREE FIRE TH", pkg: "com.dts.freefireth", isOn: $espFFTHEnabled, isBusy: patchOperationBusy, isDisabled: !appState.exploitStatus.isSuccess) { togglePatch(id: "DE5A2E93-C78A-4A24-B401-9D25F4443505", name: "ESP FREE FIRE TH", state: $espFFTHEnabled) }\n                                    Divider().background(Color.white.opacity(0.1)).padding(.leading, 64)\n                                    PremiumToggleRow(name: "ESP FREE FIRE MAX", pkg: "com.dts.freefiremax", isOn: $espFFMAXEnabled, isBusy: patchOperationBusy, isDisabled: !appState.exploitStatus.isSuccess) { togglePatch(id: "C1B4ACD2-2320-45E3-80B4-936B46076140", name: "ESP FREE FIRE MAX", state: $espFFMAXEnabled) }\n                                }\n                                .background(Color.black.opacity(0.3))\n                                .background(.ultraThinMaterial)\n                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))\n                                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))\n                                .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)\n                            }'

start_idx = text.find(start_str)
end_idx = text.find(end_str) + len(end_str)

if start_idx != -1 and end_idx != -1:
    block = text[start_idx:end_idx]
    
    # Replace in text
    text = text[:start_idx] + '                            scriptCategoryViews' + text[end_idx:]
    
    # Create view builder
    lines = block.split('\n')
    view_builder_func = "\n    @ViewBuilder\n    private var scriptCategoryViews: some View {\n"
    for line in lines:
        if line.startswith('                        '):
            view_builder_func += line[8:] + '\n'
        else:
            view_builder_func += line + '\n'
    view_builder_func += "    }\n"
    
    # Also add isPatchDisabled property
    prop_disabled = """
    private var isPatchDisabled: Bool {
        !appState.exploitStatus.isSuccess
    }
"""
    if "private var isPatchDisabled" not in text:
        text = text.replace('    @State private var espFFMAXEnabled = false\n', '    @State private var espFFMAXEnabled = false\n' + prop_disabled)

    # Replace all instances of `!appState.exploitStatus.isSuccess` in view_builder_func with `isPatchDisabled`
    view_builder_func = view_builder_func.replace('!appState.exploitStatus.isSuccess', 'isPatchDisabled')

    text = text.replace('    private func syncPatchStates() {', view_builder_func + '\n    private func syncPatchStates() {')
    
    with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
        f.write(text)
    print("Successfully extracted scriptCategoryViews")
else:
    print("Could not find the block")
