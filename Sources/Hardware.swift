import Foundation
import IOKit

let german = Locale.preferredLanguages.first?.hasPrefix("de") ?? false
func L(_ de: String, _ en: String) -> String { german ? de : en }

struct Cable { var speed: String; var bps: Double; var watts: Int }
/// Ausgehandelter Ladevertrag (USB-PD) und was das Netzteil insgesamt anbietet.
struct Charger { var watts: Int; var volts: Double; var maxWatts: Int; var pd: Bool }
struct Device: Equatable { var name: String; var bps: Double; var volumes: [String]; var loc: UInt32 }
struct PortState {
    var number: Int
    var active = false
    var uuid = ""
    var location = ""   // z. B. left-back, left-front, right; leer = unbekannt
    var magsafe = false
    var place: String {
        if magsafe { return "MagSafe" }
        if location.isEmpty { return "Port \(number)" }
        let t = ["left": "links", "right": "rechts", "back": "hinten", "front": "vorne", "middle": "Mitte"]
        let s = location.split(separator: "-").map { german ? (t[String($0)] ?? String($0)) : String($0) }.joined(separator: " ")
        return s.prefix(1).uppercased() + s.dropFirst()
    }
    var transports: [String] = []
    var cable: Cable?
    var charger: Charger?
    var devices: [Device] = []
    var chargeText: String? {
        charger.map { c in
            let v = c.volts.rounded() == c.volts ? "\(Int(c.volts)) V" : String(format: "%.1f V", c.volts)
            return "\(c.watts) W · \(v)"
        }
    }

    var isThunderbolt: Bool { transports.contains("CIO") }
    /// Am Port selbst zählt das schnellste Gerät; hinter Hubs hängen oft langsame Beigeräte.
    var main: Device? {
        let storage = devices.filter { !$0.volumes.isEmpty }
        return (storage.isEmpty ? devices : storage).min { a, b in
            storage.isEmpty ? a.bps > b.bps : a.bps < b.bps
        }
    }
    var slowStorage: Bool { (main.map { !$0.volumes.isEmpty && $0.bps < 1e9 }) ?? false }
    var speedText: String? {
        if let m = main { return Self.fmt(m.bps) }
        if isThunderbolt { return "Thunderbolt" }
        if let c = charger { return "\(c.watts) W" }
        return nil
    }
    static func fmt(_ bps: Double) -> String {
        bps >= 1e9 ? "\(Int((bps / 1e9).rounded())) Gb/s" : "\(Int((bps / 1e6).rounded())) Mb/s"
    }
    /// Grobe Bestwerte in MB/s nach Protokoll-Overhead.
    static func realMBs(_ bps: Double) -> Double {
        switch bps { case 2e10...: return 2000; case 1e10...: return 1000; case 5e9...: return 430
        case 4e8...: return 40; default: return bps / 8e6 * 0.7 }
    }
    static func copyTime(_ bps: Double) -> String {
        let s = 100_000 / realMBs(bps)
        return s < 90 ? "\(Int(s)) s" : s < 5400 ? "\(Int((s / 60).rounded())) min" : String(format: "%.1f h", s / 3600)
    }
    var detail: String {
        if let m = main {
            let who = m.volumes.isEmpty ? m.name : m.volumes.joined(separator: ", ")
            let s = m.volumes.isEmpty ? who : L("\(who) · 100 GB ab \(Self.copyTime(m.bps))", "\(who) · 100 GB in about \(Self.copyTime(m.bps))")
            return charger.map { s + L(" · lädt mit \($0.watts) W", " · charging at \($0.watts) W") } ?? s
        }
        if isThunderbolt { return L("Thunderbolt / USB4 verbunden", "Thunderbolt / USB4 connected") + (charger.map { L(" · lädt mit \($0.watts) W", " · charging at \($0.watts) W") } ?? "") }
        // Wie bei Geräten nur der Name; Spannung und Netzteil-Maximum stehen im Menü.
        // MagSafe ist nur das Kabel; dahinter steckt ein normales USB-C-Netzteil, PD oder langsam.
        if let c = charger {
            let kind = c.pd ? L("PD-Netzteil", "PD charger") : L("Langsames Netzteil", "Slow charger")
            return magsafe ? "MagSafe · " + kind : kind
        }
        if let c = cable { return L("Nur Kabel oder Strom · Kabel bis \(c.speed)", "Cable or power only · cable up to \(c.speed)") }
        return L("Kein Datengerät erkannt", "No data device detected")
    }
    var verdict: String? {
        guard slowStorage, let m = main else { return nil }
        if let c = cable, c.bps <= m.bps { return L("Das Kabel kann nur USB 2", "This cable is USB 2 only") }
        if let c = cable, c.bps > 1e9 { return L("Kabel kann mehr. Stecker oder Gerät prüfen", "Cable can do more. Check plug or device") }
        return L("Bremse: Kabel, Stecker oder Gerät", "Bottleneck: cable, plug or device")
    }
}

enum Hardware {
    static let magsafeBase = 100
    static func prop(_ e: io_registry_entry_t, _ k: String) -> Any? {
        IORegistryEntryCreateCFProperty(e, k as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue()
    }
    static func each(_ cls: String, _ f: (io_registry_entry_t) -> Void) {
        var it: io_iterator_t = 0
        guard IOServiceGetMatchingServices(kIOMainPortDefault, IOServiceMatching(cls), &it) == KERN_SUCCESS else { return }
        defer { IOObjectRelease(it) }
        while case let e = IOIteratorNext(it), e != 0 { f(e); IOObjectRelease(e) }
    }
    static func decode(_ vdos: [Data], type: Int) -> Cable? {
        guard vdos.count > 3, type == 3 || type == 4, vdos[3].count >= 4 else { return nil }
        let v = vdos[3].prefix(4).enumerated().reduce(UInt32(0)) { $0 | UInt32($1.element) << (8 * UInt32($1.offset)) }
        let speeds: [(String, Double)] = [("480 Mb/s", 4.8e8), ("5 Gb/s", 5e9), ("10 Gb/s (USB4: 20)", 1e10), ("40 Gb/s", 4e10), ("80 Gb/s", 8e10)]
        let i = Int(v & 7); guard i < speeds.count else { return nil }
        let amps = (v >> 5) & 3 == 2 ? 5 : 3
        let maxV = (v >> 9) & 3
        return Cable(speed: speeds[i].0, bps: speeds[i].1, watts: amps == 5 && maxV == 3 ? 240 : amps * 20)
    }
    static func mounts() -> [String: String] {
        var p: UnsafeMutablePointer<statfs>?
        let n = getmntinfo(&p, MNT_NOWAIT)
        var r: [String: String] = [:]
        for i in 0..<Int(n) {
            var s = p![i]
            let from = withUnsafeBytes(of: &s.f_mntfromname) { String(cString: $0.bindMemory(to: CChar.self).baseAddress!) }
            let on = withUnsafeBytes(of: &s.f_mntonname) { String(cString: $0.bindMemory(to: CChar.self).baseAddress!) }
            if on.hasPrefix("/Volumes/") { r[(from as NSString).lastPathComponent] = (on as NSString).lastPathComponent }
        }
        return r
    }
    /// Nur Laufwerke unter diesem Gerät; tiefere USB-Geräte (Hub) zählen dort selbst.
    static func volumes(_ e: io_registry_entry_t, _ m: [String: String]) -> [String] {
        var out: [String] = []
        func walk(_ e: io_registry_entry_t) {
            var it: io_iterator_t = 0
            guard IORegistryEntryGetChildIterator(e, kIOServicePlane, &it) == KERN_SUCCESS else { return }
            defer { IOObjectRelease(it) }
            while case let c = IOIteratorNext(it), c != 0 {
                if IOObjectConformsTo(c, "IOUSBHostDevice") == 0 {
                    if IOObjectConformsTo(c, "IOMedia") != 0, let b = prop(c, "BSD Name") as? String, let v = m[b], !out.contains(v) { out.append(v) }
                    walk(c)
                }
                IOObjectRelease(c)
            }
        }
        walk(e); return out
    }
    /// Apple hinterlegt die Gehäuseposition im Elternknoten des Ports.
    static func location(_ e: io_registry_entry_t) -> String {
        let o = IOOptionBits(kIORegistryIterateRecursively | kIORegistryIterateParents)
        guard let d = IORegistryEntrySearchCFProperty(e, kIOServicePlane, "port-location" as CFString, kCFAllocatorDefault, o) as? Data else { return "" }
        return String(decoding: d.prefix { $0 != 0 }, as: UTF8.self).lowercased()
    }
    static func scan() -> [PortState] {
        var ports: [Int: PortState] = [:]
        each("IOPort") { e in
            guard let d = prop(e, "Description") as? String, d.hasPrefix("Port-USB-C@") || d.hasPrefix("Port-MagSafe"),
                  let n = (prop(e, "PortNumber") as? NSNumber)?.intValue else { return }
            // MagSafe zählt eigene Nummern ab 1; eigener Bereich, damit nichts mit USB-C kollidiert.
            let mag = d.hasPrefix("Port-MagSafe")
            var p = PortState(number: mag ? magsafeBase + n : n)
            p.magsafe = mag
            p.active = prop(e, "ConnectionActive") as? Bool ?? false
            p.uuid = prop(e, "ConnectionUUID") as? String ?? ""
            p.transports = prop(e, "TransportsActive") as? [String] ?? []
            // MagSafe hat keine port-location; es sitzt immer links ganz hinten.
            p.location = mag ? "magsafe" : location(e)
            ports[p.number] = p
        }
        each("IOPortTransportComponentCCUSBPDSOPp") { e in
            guard (prop(e, "ParentPortTypeDescription") as? String) == "USB-C",
                  let n = (prop(e, "ParentPortNumber") as? NSNumber)?.intValue,
                  let md = prop(e, "Metadata") as? [String: Any], let v = md["VDOs"] as? [Data] else { return }
            ports[n]?.cable = decode(v, type: (md["Product Type"] as? NSNumber)?.intValue ?? 0)
        }
        // Ladeleistung: nur Quellen mit ausgehandeltem Vertrag zählen; die stärkste gewinnt.
        each("IOPortFeaturePowerSource") { e in
            let type = prop(e, "ParentPortTypeDescription") as? String ?? ""
            guard type == "USB-C" || type.hasPrefix("MagSafe"),
                  let pn = (prop(e, "ParentPortNumber") as? NSNumber)?.intValue,
                  let win = prop(e, "WinningPowerSourceOption") as? [String: Any],
                  let mw = (win["Max Power (mW)"] as? NSNumber)?.intValue, mw > 0 else { return }
            let n = type.hasPrefix("MagSafe") ? magsafeBase + pn : pn
            let mv = (win["Voltage (mV)"] as? NSNumber)?.doubleValue ?? 0
            let opts = prop(e, "PowerSourceOptions") as? [[String: Any]] ?? []
            let best = opts.compactMap { ($0["Max Power (mW)"] as? NSNumber)?.intValue }.max() ?? mw
            let c = Charger(watts: Int((Double(mw) / 1000).rounded()), volts: (mv / 100).rounded() / 10, maxWatts: Int((Double(max(best, mw)) / 1000).rounded()),
                            pd: (prop(e, "PowerSourceName") as? String) == "USB-PD")
            if (ports[n]?.charger?.watts ?? 0) < c.watts { ports[n]?.charger = c }
        }
        var bus: [UInt32: Int] = [:]
        each("AppleUSBHostPort") { e in
            guard let l = (prop(e, "locationID") as? NSNumber)?.uint32Value,
                  let d = prop(e, "usb-c-port-number") as? Data, let n = d.first else { return }
            bus[l >> 24] = Int(n)
        }
        let m = mounts()
        each("IOUSBHostDevice") { e in
            guard let l = (prop(e, "locationID") as? NSNumber)?.uint32Value, let n = bus[l >> 24],
                  let s = (prop(e, "UsbLinkSpeed") as? NSNumber)?.doubleValue else { return }
            let name = prop(e, "USB Product Name") as? String ?? L("USB-Gerät", "USB device")
            ports[n]?.devices.append(Device(name: name, bps: s, volumes: volumes(e, m), loc: l))
        }
        // MagSafe zuerst: es sitzt links ganz hinten, vor den USB-C-Ports.
        return ports.values.sorted { ($0.magsafe ? 0 : 1, $0.number) < ($1.magsafe ? 0 : 1, $1.number) }
    }
}
