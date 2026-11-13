#!/usr/bin/env python3
"""Writes legacy-aircraft.archive: an NSKeyedArchiver file shaped like the
`aircraft.archive` that versions 1.x-3.x of the Objective-C app saved in Documents.

The real app archived NSNumbers created from 32-bit floats, so values are rounded
through float32 here to reproduce artefacts such as 137.8 -> 137.8000030517578.

Run from this directory:  python3 make_legacy_aircraft_archive.py
"""
import plistlib
import struct


def f32(x):
    return struct.unpack("f", struct.pack("f", x))[0]


class Obj:
    def __init__(self, classname, fields, superclasses=("NSObject",)):
        self.classname = classname
        self.fields = fields
        self.superclasses = superclasses


class Archiver:
    def __init__(self):
        self.objects = ["$null"]
        self.class_uids = {}

    def class_uid(self, name, chain):
        if name not in self.class_uids:
            self.objects.append({"$classname": name, "$classes": [name, *chain]})
            self.class_uids[name] = plistlib.UID(len(self.objects) - 1)
        return self.class_uids[name]

    def encode(self, value):
        if value is None:
            return plistlib.UID(0)
        index = len(self.objects)
        self.objects.append(None)  # reserve
        if isinstance(value, (bool, int, float, str)):
            self.objects[index] = value
        elif isinstance(value, list):
            self.objects[index] = {
                "NS.objects": [self.encode(v) for v in value],
                "$class": self.class_uid("NSMutableArray", ["NSArray", "NSObject"]),
            }
        elif isinstance(value, dict):
            keys = list(value)
            self.objects[index] = {
                "NS.keys": [self.encode(k) for k in keys],
                "NS.objects": [self.encode(value[k]) for k in keys],
                "$class": self.class_uid("NSMutableDictionary", ["NSDictionary", "NSObject"]),
            }
        elif isinstance(value, Obj):
            entry = {k: self.encode(v) for k, v in value.fields.items()}
            entry["$class"] = self.class_uid(value.classname, list(value.superclasses))
            self.objects[index] = entry
        else:
            raise TypeError(value)
        return plistlib.UID(index)

    def archive(self, root):
        top = self.encode(root)
        return {
            "$archiver": "NSKeyedArchiver",
            "$version": 100000,
            "$top": {"root": top},
            "$objects": self.objects,
        }


def datum(name, quantity, wpq, arm):
    return Obj("Datum", {
        "DatumName": name,
        "DatumQuantity": quantity,
        "DatumWPQ": wpq,
        "DatumArm": f32(arm),
    })


def point(weight, arm):
    return Obj("EnvelopePoint", {"EWeight": f32(weight), "EArm": f32(arm)})


sr22t = Obj("Aircraft", {
    "tailNumber": "N123AB",
    "typeName": "SR22T/TN",
    "maxGross": f32(3400.0),
    "maxFuel": f32(92.0),
    "maxBaggage": f32(130.0),
    "frontArm": f32(143.5),
    "backArm": f32(180.0),
    "pilotWt": f32(190.0),
    "coPilotWt": f32(160.0),
    "secRowLeftWt": f32(45.0),
    "secRowRightWt": f32(0.0),
    "MaxTKS": f32(3.5),
    "MaxO2": f32(23.8),
    "envelope": [
        point(2100, 137.8), point(2700, 139.1), point(3400, 142.3),
        point(3400, 148.1), point(2100, 148.1),
    ],
    "datums": {
        "Basic Empty": datum("Basic Empty", f32(2489.0), 1, 139.5),
        "Fuel": datum("Fuel", f32(60.0), 6.0, 154.9),
        "TKS": datum("TKS", f32(3.5), 9.1, 148.0),
        "Oxygen": datum("Oxygen", 0, 1, 265.3),
        "Baggage": datum("Baggage", f32(40.0), 1, 208.0),
    },
})

# An aircraft created from a blank type and never filled in: nil numbers, one envelope point.
blank = Obj("Aircraft", {
    "tailNumber": "New",
    "typeName": None,
    "maxGross": None,
    "maxFuel": None,
    "maxBaggage": None,
    "frontArm": None,
    "backArm": None,
    "pilotWt": None,
    "coPilotWt": None,
    "secRowLeftWt": None,
    "secRowRightWt": None,
    "MaxTKS": None,
    "MaxO2": None,
    "envelope": [Obj("EnvelopePoint", {"EWeight": None, "EArm": None})],
    "datums": {
        "Basic Empty": datum("Basic Empty", 0.0, 1.0, 0.0),
        "Fuel": datum("Fuel", 0.0, 6.0, 0.0),
        "TKS": datum("TKS", 0.0, 9.1, 0.0),
        "Oxygen": datum("Oxygen", 0.0, 1.0, 0.0),
        "Baggage": datum("Baggage", 0.0, 1.0, 0.0),
    },
})

with open("legacy-aircraft.archive", "wb") as out:
    plistlib.dump(Archiver().archive([sr22t, blank]), out, fmt=plistlib.FMT_BINARY)
