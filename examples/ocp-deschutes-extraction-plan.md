# Extraction Plan: OCP Project Deschutes CDU

**Source document:** OCP Project Deschutes: Data Center Facilities, v0.8.0,
Authors: Google, effective July 1, 2025.
**File:** `ocp-deschutes-cdu-spec-2025.pdf` (GCS: `visum-equipment-manuals-1767322178/equipment-manuals/cdu/`)

**Grounding rule:** Every asserted triple in the extraction TTL must be
explicitly traceable to a verbatim passage in the source document. No
inferred, synthesised, or placeholder facts.

---

## 1. Purpose

Produce a third worked example for the aif-ops ontology exercising 9 of the
11 operational entity classes against an OCP hyperscaler CDU design
specification. The two dropped classes are explained in §4.3 and §4.4.

The Deschutes example complements the two existing Vertiv extractions (CDU100,
XDU1350B) by introducing:

- A **design specification** source (not an O&M manual) — less alarm-table
  detail, richer hydraulic/thermal spec. Two entity classes that require
  O&M-level data (OperatingMode, MaintenanceTask) cannot be source-grounded
  from this document and are omitted.
- **Explicit primary/secondary loop naming** throughout (facility loop vs.
  technical/IT loop), surfacing fluid topology the Vertiv examples do not expose.
- **Three heat exchangers in parallel** (Alfa Laval CB210-276AH), a structural
  difference from the Vertiv single-HX designs.
- **N+1 pump redundancy with individual VFDs** (ABB ACH580-31-065A-4 per pump).
- **OCP hyperscaler context** — multi-vendor sourcing, PLC-based control with
  Modbus/TCP over IPv4+IPv6.
- First use of `aif-ops:AutomatedAction` in any worked example (PLC-triggered
  leak detection in the EOP).

---

## 2. Scope

**In scope:** Sections 3–13 of the spec (CDU physical, performance, functional,
electrical, safety, manufacturing, and maintenance).

**Partially in scope:**

| Section | Content | Reason |
|---------|---------|--------|
| §18.9, §18.13 | RDHx Details and CDU Placement | Needed solely to establish the `brick:feeds` RDHx stub required by `CDU_Shape`. Full HAC/RDHx modelling is deferred. |

**Out of scope:**

| Section | Content | Reason |
|---------|---------|--------|
| §17 | Barcode label specification | Asset tracking, not operational ontology |
| §18 (remainder) | Redmond Hot Aisle Containment (HAC) interface | Separate equipment type; warrants its own extraction |
| §19–20 | General and component validation suites | Commissioning test protocol; §20.5 used for CS class only |

---

## 3. Entity class mapping

### 3.1 Equipment instance (`aif-ops:Coolant_Distribution_Unit`)

Source: §3.1 Technical Specification table (p.12), §4.1 Overall Dimensions
(p.17)

Attributes recorded via `aif-ops:hasSource` annotations:
- 2 MW thermal load, 500 GPM IT/secondary flow
- Dimensions 65" × 93.1" × 47.2" (W × H × D)
- Wet weight 6910 lbs, dry weight 5310 lbs
- Coolants: DI water, PG25
- Heat exchanger: liquid-to-liquid, dual pass

**Note on `hasSource` annotations:** These attributes have no dedicated
ontology property in the current schema. They are recorded as annotation
literals only. This is a known limitation; see §4.5.

`brick:feeds` target: a stub `deschutes:RDHx_Rack a aif-ops:Rear_Door_Heat_Exchanger`
sourced from §18.9 (RDHx Details, p.63) and §18.13 (CDU Placement, p.67),
satisfying `CDU_Shape sh:qualifiedMinCount 1` for the `brick:feeds` constraint.

### 3.2 Sensors / Brick points (`brick:hasPoint`)

Source: §6.5 Sensors and Instrumentation table (p.25)

The sensor table distinguishes three loops (Technical, Primary, CDU-level)
across functions: Temperature, Pressure, Flow, Level, and Leak.

Selected points — one canonical label pair used throughout:
**Secondary/Technical loop** (labelled "Technical" in §6.5) and
**Primary/Facility loop** (labelled "Primary" in §6.5).

| IRI | Sensor function (§6.5) | Loop | Brick class |
|-----|------------------------|------|-------------|
| `deschutes:Sensor_Tech_CDUOutput_Temp` | CDU Output Temperature | Secondary/Technical | `brick:Temperature_Sensor` |
| `deschutes:Sensor_Tech_CDUInput_Temp` | CDU Input Temperature | Secondary/Technical | `brick:Temperature_Sensor` |
| `deschutes:Sensor_Tech_CDUOutput_Pressure` | CDU Output Pressure | Secondary/Technical | `brick:Pressure_Sensor` |
| `deschutes:Sensor_Tech_FlowMeter` | Flow Meter (vortex/ultrasonic) | Secondary/Technical | `brick:Flow_Sensor` |
| `deschutes:Sensor_Primary_CDUInput_Temp` | CDU Input Temperature | Primary/Facility | `brick:Temperature_Sensor` |
| `deschutes:Sensor_Primary_CCV_Pressure` | CCV Output Pressure | Primary/Facility | `brick:Pressure_Sensor` |
| `deschutes:Sensor_CDU_LeakRope` | Leak Detection (rope, 3 zones) | CDU | `brick:Leak_Detection_Sensor` |

The `brick:Leak_Detection_Sensor` on `deschutes:CDU_1` satisfies
`CDU_Shape sh:qualifiedMinCount 1` for the leak-sensor constraint.

**Brick stubs required in `aif_ops.ttl`:** `brick:Temperature_Sensor`,
`brick:Pressure_Sensor`, and `brick:Flow_Sensor` must be declared
`rdfs:subClassOf brick:Point`. These stubs are needed for
`FailureMode_Shape sh:path aif-ops:hasDetectionSignature sh:class brick:Point`
(not for `CDU_Shape hasPoint sh:minCount 1`, which only checks predicate
existence). See §4.1.

**Loop identity:** §6.5 uses the column label "Loop" with values "Technical"
and "Primary". Loop membership is recorded in `rdfs:label` (e.g.,
`"CDU Output Temperature (Secondary/Technical Loop)"`) pending a formal
`aif-ops:onFluidLoop` property. See §4.2.

### 3.3 Failure mode (`aif-ops:FailureMode`)

Source: §3.2 product requirement item 10 (p.13), §6.7 Control System (p.26)

Only one failure mode is modelled. Pump motor overtemperature is mentioned as
an alarm in §6.7 but no motor temperature sensor appears in the §6.5 sensor
table; there is no grounded `brick:Point` for its `hasDetectionSignature`
constraint, so it is omitted.

| IRI | Label | Detection signature | Mitigation |
|-----|-------|---------------------|------------|
| `deschutes:FM_CoolantLeak` | Coolant Leak Detected (3-zone rope sensor) | `deschutes:Sensor_CDU_LeakRope` | `deschutes:EOP_LeakResponse` |

### 3.4 Events (`aif-ops:Event`)

Source: §6.7 "Alarms for detected leaks" (p.26)

One event modelled. Motor overtemperature is mentioned in §6.7 but dropped
for the same reason as `FM_MotorOvertemp` (no grounded detection sensor).

| IRI | Label | Triggers |
|-----|-------|----------|
| `deschutes:Event_LeakDetected` | Leak Detected (PLC alarm, any of 3 zones) | `deschutes:EOP_LeakResponse` |

### 3.5 Interlocks (`aif-ops:Interlock`)

Source: §13.1 Power — maintenance and hotswap requirements (p.41), §13.4 (p.45)

The interlock gates the **replacement action** (the pump hotswap itself), not
the valve-closing prerequisite step. §13.1: "Components that are replaceable
during continuous normal operation must have appropriate interlocks to prevent:
Disruptive fluid pressure or flow conditions — manual stop valves, and/or check
valves and/or leak-free disconnects."

| IRI | Label | Gates |
|-----|-------|-------|
| `deschutes:Interlock_HotswapFluidIsolation` | Manual fluid isolation required before FRU replacement | `deschutes:Action_PumpRemove` (pump removal/hotswap action in MOP_PumpRemoval) |
| `deschutes:Interlock_FlowMeterShutdown` | CDU must be powered off before flow meter service | `deschutes:Action_FlowMeter_Unbolt` (flow meter removal action) |

Both gated actions are modelled as `aif-ops:ManualAction` within their
respective MOP sequences and carry `aif-ops:hasActor` and `aif-ops:stepOrder`,
satisfying `Action_Shape`.

### 3.6 Isolation points (`aif-ops:IsolationPoint`)

Source: §13.2 Pump Removal Step 1 (p.42), §13.3 Filter Removal Steps 1–2
(p.44), §13.5 VFD Removal Steps 1–2 (p.46)

| IRI | Label | Procedure |
|-----|-------|-----------|
| `deschutes:IP_PumpSupplyValve` | Pump supply shut-off valve | `MOP_PumpRemoval` |
| `deschutes:IP_FilterInletValve` | Filter inlet shut-off valve (Secondary/Technical loop) | `MOP_FilterService` |
| `deschutes:IP_FilterOutletValve` | Filter outlet shut-off valve (Secondary/Technical loop) | `MOP_FilterService` |
| `deschutes:IP_VFD_MainDisconnect` | VFD main disconnect (electrical) | `MOP_VFDRemoval` |

### 3.7 Lockout/tagout steps (`aif-ops:LockoutTagoutStep`)

Source: §13.5 VFD Removal Steps 1–2 (p.46), verbatim:

> "1. Turn off main disconnect for VFD to be serviced.
>  2. Open high voltage enclosure and ensure power to VFD is removed."

| IRI | Label |
|-----|-------|
| `deschutes:LOTO_VFD_Step1` | Turn off main disconnect for VFD to be serviced |
| `deschutes:LOTO_VFD_Step2` | Open high voltage enclosure and ensure power to VFD is removed |

Both carry `aif-ops:partOfProcedure deschutes:MOP_VFDRemoval`.

### 3.8 EOP: Coolant Leak Response (`aif-ops:EOP`)

Sources: §3.2 item 10 (p.13), §6.7 (p.26), §13.1 (p.41), §13.2 Steps 1–2
(p.42)

The leak response sequence is assembled from explicit statements in the spec:
- PLC detection: §3.2 item 10 "Leak rope detection (detected through PLC,
  3 zones)" and §6.7 "Alarms for detected leaks"
- Fluid isolation: §13.1 "manual stop valves … to prevent disruptive fluid
  pressure or flow conditions" and §13.2 Step 1 "Shut off supply valve"
- CDU shutdown: §7.2.2 "Pump enable/disable" (controllable parameter via PLC)
- Drain: §13.2 Step 2 "Connect drain hose to drain barb on bottom of pump
  and open drain valve"

Steps:

| Step | Action | Actor | Source |
|------|--------|-------|--------|
| 1 | PLC fires leak alarm (any of 3 rope zones) | Automated (PLC) | §3.2 item 10; §6.7 |
| 2 | Operator identifies affected zone | Manual | §3.2 item 10 (3-zone detection) |
| 3 | Shut off supply valve to affected component | Manual | §13.2 Step 1; §13.1 |
| 4 | Disable pump via PLC (pump enable/disable) | Manual | §7.2.2 |
| 5 | Connect drain hose and open drain valve | Manual | §13.2 Step 2 |
| 6 | Repair or replace leaking component | Manual | §13.1 "repair procedures" |

Step 1 → `aif-ops:AutomatedAction` (first use of this subclass in any worked
example). Steps 2–6 → `aif-ops:ManualAction`.

Note: the spec does not document an explicit "clear alarm" step (unlike the
XDU1350 which had an iCOM Clear Alarms button). Step 6 is grounded to §13.1's
"repair procedures" documentation requirement. No alarm-clear step is modelled.

### 3.9 MOPs: Filter Service, Pump Removal, VFD Removal

Three MOPs are modelled, each with a fully source-grounded action sequence.

**MOP_FilterService** (§13.3 Filter Removal Steps, p.44) — 6 steps, verbatim:

1. Shutoff filter inlet valve
2. Shutoff filter outlet valve
3. Connect drain hose to drain barb on bottom of filter and open drain valve
4. Loosen front clamp with rag around joint to allow air to enter if needed to complete drain
5. Remove clamp from front of filter
6. Slide filter out for cleaning or replacement

**MOP_PumpRemoval** (§13.2 Pump Removal Steps, p.42) — 10 steps, verbatim:

1. Shut off supply valve
2. Connect drain hose to drain barb on bottom of pump and open drain valve
3. Depress Schraeder valve as needed to drain line
4. Remove gussets
5. Remove 4x bolts from ANSI suction flange
6. Disconnect 4" triclamp
7. Unplug pressure sensor if required
8. Loosen Victaulic fittings in two locations to allow fittings to slide and section removal or remove 4x bolts from output flange and loosen Victaulic fitting to allow pipe section removal
9. Unbolt pump
10. With assistance device (in process) remove pump

**MOP_VFDRemoval** (§13.5 VFD Removal Steps, p.46) — 8 steps, verbatim:

1. Turn off main disconnect for VFD to be serviced
2. Open high voltage enclosure and ensure power to VFD is removed
3. Open cover of VFD and disconnect power and control cables
4. Remove conduit from bottom of VFD
5. Remove wire from inside VFD and bend conduit out of the way for VFD removal
6. Remove top two bolts in through holes on VFD
7. Loosen top key hole bolts and bottom slotted hole bolts
8. With assistance lift and remove VFD from frame

### 3.10 Commissioning step (`aif-ops:CommissioningStep`)

Source: §20.5 Primary and secondary filters — Hydraulic and Impulse subsections
(p.73–74)

Pass and fail criteria are taken verbatim from the §20.5 hydraulic and impulse
test requirements (exact text to be cited from the PDF in the sources MD when
extraction is written). No authored criteria.

| IRI | Label |
|-----|-------|
| `deschutes:CS_FilterHydraulicTest` | §20.5 Primary/Secondary Filter Hydraulic Validation |

---

## 4. Schema gap analysis

### 4.1 Missing Brick sensor subclass stubs

`aif_ops.ttl` line 22 declares one Brick point stub:
```turtle
brick:Leak_Detection_Sensor rdfs:subClassOf brick:Point .
```

The Deschutes extraction uses `brick:Temperature_Sensor`, `brick:Pressure_Sensor`,
and `brick:Flow_Sensor` as detection signatures on failure modes. Without stubs,
pyshacl cannot resolve these as `brick:Point` subclasses for:

```
aif_ops_shapes.ttl:126-130
  aif-ops-shapes:FailureMode_Shape sh:property [
      sh:path aif-ops:hasDetectionSignature ;
      sh:class brick:Point ;
  ]
```

(Not `CDU_Shape hasPoint sh:minCount 1`, which only checks predicate existence.)

**Resolution:** Add stubs to `aif_ops.ttl` (Option A — same pattern as line 22).
These stubs benefit all future extractions.

### 4.2 No fluid-loop property

The §6.5 sensor table organises sensors by loop (Technical/Primary/CDU). The
ontology has no `aif-ops:onFluidLoop` property.

**Resolution for this extraction:** Loop identity encoded in `rdfs:label` using
the canonical pair "Secondary/Technical Loop" and "Primary/Facility Loop" (per
§6.5 column values). Log as a future schema extension.

### 4.3 `aif-ops:OperatingMode` not extractable from this document

The spec does not define a named mode state machine. §5.4 says "N+1 pump
operation, providing redundancy" and §7.2.2 lists "Pump enable/disable" as a
controllable parameter, but neither defines discrete named operating states or
transitions. `aif-ops:OperatingMode` is **omitted** from this extraction.
No SHACL constraint requires operating mode instances.

### 4.4 `aif-ops:MaintenanceTask` not extractable — shape gap identified

`MaintenanceTask_Shape` (`aif_ops_shapes.ttl:137-144`) requires:
```
sh:path aif-ops:recursEvery ; sh:minCount 1 ; sh:datatype xsd:duration
```

The spec is a design specification and states no maintenance recurrence
intervals. The `aif-ops:MaintenanceTask` class definition (`aif_ops.ttl:142`)
explicitly requires "an explicit recurrence interval." No grounded value exists.

`MaintenanceTask` is **omitted** from this extraction. This causes a
`CDU_Shape` validation failure:
```
aif_ops_shapes.ttl:24-29
  sh:path aif-ops:hasMaintenanceTask ; sh:minCount 1
```

**Proposed schema fix:** Relax `CDU_Shape hasMaintenanceTask sh:minCount 1` to
`sh:minCount 0`, or introduce an `aif-ops:OnConditionMaintenanceTask` subclass
that does not require `recursEvery`. Spec-level CDU documents cannot provide
intervals; this constraint belongs at O&M-manual level. The maintenance
procedures themselves (§13.2–13.5) are fully grounded and modelled as MOPs.

### 4.5 Equipment attributes have no ontology properties

§3.1 records thermal load, flow rate, dimensions, weight, and coolant type via
`aif-ops:hasSource` annotations. `aif-ops:hasSource` is an
`owl:AnnotationProperty` (`aif_ops.ttl:280-282`); it does not represent those
facts structurally. This is a known limitation of the current schema: equipment
specification properties (capacity, dimensions, media compatibility) are out of
scope for the v1 ontology. They appear only as annotation text in this example.

### 4.6 `aif-ops:AutomatedAction` exercised for first time

Step 1 of `EOP_LeakResponse` (PLC leak alarm) is typed as
`aif-ops:AutomatedAction`. This class exists in `aif_ops.ttl:133-136` but has
no prior worked example. No schema change needed.

---

## 5. Output files

| File | Description |
|------|-------------|
| `examples/ocp-deschutes-extraction.ttl` | Instance TTL covering 9 entity classes + 3 MOPs |
| `examples/ocp-deschutes-extraction-sources.md` | Verbatim source citations for every modelled claim |

Namespace prefix: `deschutes: <https://visum.ai/instances/ocp-deschutes#>`

The `aif_ops.ttl` Brick sensor stub additions (§4.1) are included in the same
PR. The `CDU_Shape hasMaintenanceTask` relaxation (§4.4) is proposed as a
separate schema issue, not applied in this PR.

---

## 6. Open questions

1. **CDU_Shape `hasMaintenanceTask` validation failure**: This extraction will
   fail the `sh:minCount 1` constraint at `aif_ops_shapes.ttl:24-29`. Should the
   shape be relaxed to `sh:minCount 0` in this same PR, or tracked separately?

2. **`brick:feeds` source depth**: The RDHx stub is grounded to §18.9 and §18.13,
   which are read but not otherwise modelled. Is citing those two pages sufficient
   provenance for the stub, or should the scope table note them as explicitly
   partial rather than out-of-scope?

3. **§20.5 commissioning criteria verbatim text**: Pass/fail criteria for
   `CS_FilterHydraulicTest` must be pulled from §20.5 at extraction time.
   Those pages (p.73–74) have not been read yet — they should be read before
   the extraction TTL is written to ensure the criteria are grounded to actual
   spec language rather than paraphrased.
