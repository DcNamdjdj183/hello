import re

with open('ThreeOneOSFive/ContentView.swift', 'r', encoding='utf-8') as f:
    content = f.read()

# We want to extract the categories into separate @ViewBuilder vars to help the compiler.
# Let's find the Picker and the if/else block.

# 1. Add computed property for disabled state to reduce expression complexity
prop_disabled = """
    private var isPatchDisabled: Bool {
        !appState.exploitStatus.isSuccess
    }
"""
if "private var isPatchDisabled" not in content:
    content = content.replace('    @State private var espFFMAXEnabled = false\n', '    @State private var espFFMAXEnabled = false\n' + prop_disabled)

# 2. Replace all instances of `!appState.exploitStatus.isSuccess` with `isPatchDisabled`
content = content.replace('!appState.exploitStatus.isSuccess', 'isPatchDisabled')

# 3. Extract the `if selectedScriptCategory == ...` block into a `@ViewBuilder private var scriptCategories: some View`
# Actually, replacing the long expression `isPatchDisabled` might be enough to fix the timeout!
# But let's also extract it just in case.

# Let's see if we can just do the `isPatchDisabled` replacement first, as that simplifies the type checking significantly.
# Many times, just reducing the property access depth `a.b.c` to `d` in 16 places is enough to fix the SwiftUI compiler timeout.

with open('ThreeOneOSFive/ContentView.swift', 'w', encoding='utf-8') as f:
    f.write(content)
print("Replaced long expressions in ContentView.swift")
