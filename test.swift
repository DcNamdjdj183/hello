import Foundation
if let dict = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any] {
    print(" OK\)
}
