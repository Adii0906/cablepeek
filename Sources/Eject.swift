import AppKit
import DiskArbitration

enum Eject {
    /// Normales Auswerfen ganzer Datenträger, nie erzwungen: erst alle Volumes sauber aushängen, dann auswerfen.
    /// Ist etwas in Gebrauch, lehnt macOS ab und das Laufwerk bleibt verbunden.
    static func run(_ names: [String], done: @escaping (Bool) -> Void) {
        guard let session = DASessionCreate(kCFAllocatorDefault) else { return done(false) }
        DASessionSetDispatchQueue(session, .main)
        var disks: [String: DADisk] = [:]
        for n in names {
            let url = URL(fileURLWithPath: "/Volumes/\(n)") as CFURL
            guard let v = DADiskCreateFromVolumePath(kCFAllocatorDefault, session, url), let whole = DADiskCopyWholeDisk(v),
                  let id = DADiskGetBSDName(whole) else { return done(false) }
            // Nie das Systemlaufwerk.
            if let d = DADiskCopyDescription(whole) as? [String: Any], d[kDADiskDescriptionDeviceInternalKey as String] as? Bool == true { return done(false) }
            disks[String(cString: id)] = whole
        }
        guard !disks.isEmpty else { return done(false) }
        var left = disks.count, ok = true
        for d in disks.values {
            let box = Box { good in
                ok = ok && good; left -= 1
                if left == 0 { DASessionSetDispatchQueue(session, nil); done(ok) }
            }
            DADiskUnmount(d, DADiskUnmountOptions(kDADiskUnmountOptionWhole), { disk, err, ctx in
                let b = Unmanaged<Box>.fromOpaque(ctx!).takeRetainedValue()
                if err != nil { b.f(false); return }
                DADiskEject(disk, DADiskEjectOptions(kDADiskEjectOptionDefault), { _, e, c in
                    Unmanaged<Box>.fromOpaque(c!).takeRetainedValue().f(e == nil)
                }, Unmanaged.passRetained(b).toOpaque())
            }, Unmanaged.passRetained(box).toOpaque())
        }
    }
    final class Box { let f: (Bool) -> Void; init(_ f: @escaping (Bool) -> Void) { self.f = f } }
}
