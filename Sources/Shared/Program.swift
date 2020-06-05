import AppKit

public class Program: NSObject {
    static let title: String = {
        switch Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
        case .none:
            return "Multi"
        case .some(let version):
            return "Multi — \(version)"
        }
    }()

    private static func addSubmenu(_ menu: NSMenu, _ submenu: [NSMenuItem]) {
        let item = NSMenuItem()
        item.submenu = menu
        submenu.forEach(menu.addItem)
        NSApp.mainMenu!.addItem(item)
    }

    public init(name: String) {
        NSApp.mainMenu = NSMenu()
        Program.addSubmenu(NSMenu(), [
            NSMenuItem(title: "Hide \(name)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "h"),
            NSMenuItem(title: "Quit \(name)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"),
        ])
        Program.addSubmenu(NSMenu(title: "Edit"), [
            NSMenuItem(title: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x"),
            NSMenuItem(title: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c"),
            NSMenuItem(title: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "p"),
            NSMenuItem(title: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"),
        ])
    }

    public func start(menu: KeyValuePairs<String, [NSMenuItem]>) {
        for (name, submenu) in menu {
            Program.addSubmenu(NSMenu(title: name), submenu)
        }

        if #available(macOS 10.12, *) {
            NSWindow.allowsAutomaticWindowTabbing = false
        }

        _ = NSApplication.shared
        NSApp.delegate = self
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        NSApp.run()
    }

    public func error(code: Int32, message: String) -> Never {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 80),
            styleMask: [.titled, .closable],
            backing: NSWindow.BackingStoreType.buffered,
            defer: false
        )
        window.title = Program.title
        window.titlebarAppearsTransparent = true
        window.makeKeyAndOrderFront(nil)
        window.center()

        let text = NSTextView(frame: window.contentView!.bounds)
        text.string = message
        text.backgroundColor = .clear
        text.isEditable = false
        text.font = .boldSystemFont(ofSize: NSFont.systemFontSize)
        text.textContainerInset = NSSize(width: 20, height: 20)
        window.contentView = text

        start(menu: [:])
        exit(code)
    }
}