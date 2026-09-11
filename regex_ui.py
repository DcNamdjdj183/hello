import sys, re
path = 'ThreeOneOSFive/ContentView.swift'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

pattern = re.compile(r'( {28}VStack\(spacing: 0\) \{\n.*?\.overlay\(RoundedRectangle\(cornerRadius: 16, style: \.continuous\)\.stroke\(Color\.white\.opacity\(0\.15\), lineWidth: 1\)\))', re.DOTALL)

match = pattern.search(text)
if match:
    old_vstack = match.group(1)
    
    new_vstack = """                            Text("AIMS")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 8)

""" + old_vstack + """

                            Text("SKIN")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 8)
                                .padding(.top, 10)

                            VStack(spacing: 0) {
                                PremiumToggleRow(name: "SKIN 1", pkg: "SKIN-1.3105", isOn: $skin1Enabled, isBusy: patchOperationBusy) { togglePatch(id: "47C88561-C524-4164-9ADA-D5F578F4FDC3", name: "SKIN 1", state: $skin1Enabled) }
                            }
                            .background(Color.black.opacity(0.3))
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))

                            Text("CHAMS")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 8)
                                .padding(.top, 10)

                            VStack(spacing: 0) {
                                PremiumToggleRow(name: "CHAMS BLUE", pkg: "CHAMS-BLUE.3105", isOn: $chamsBlueEnabled, isBusy: patchOperationBusy) { togglePatch(id: "A677DFE5-1355-4CC8-9137-C54A5E85B882", name: "CHAMS BLUE", state: $chamsBlueEnabled) }
                            }
                            .background(Color.black.opacity(0.3))
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1))"""
    
    # We want only the first match because it's the module toggles VStack, 
    # but wait, is it the first match?
    # Let's check all matches to be sure.
