import Foundation
import WidgetKit

/// Shares the item list with the widget through an App Group folder.
enum SharedStore {
    static var groupID: String {
        Bundle.main.object(forInfoDictionaryKey: "HNAppGroup") as? String ?? ""
    }

    static var fileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: groupID)?
            .appendingPathComponent("items.json")
    }

    /// `json` is the whole item list as JSON text, sent by the web app.
    static func save(_ json: String) {
        guard let url = fileURL, let data = json.data(using: .utf8) else { return }
        try? data.write(to: url, options: .atomic)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
