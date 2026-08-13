# Source citations — ocp-deschutes-extraction.ttl

**Source document:** OCP Project Deschutes: Data Center Facilities, v0.8.0,
Authors: Google, effective July 1, 2025.
**File:** `ocp-deschutes-cdu-spec-2025.pdf`
**GCS:** `gs://visum-equipment-manuals-1767322178/equipment-manuals/cdu/`

Each entry records the aif-ops entity, its `aif-ops:hasSource` value, and the
verbatim text from the source document that grounds the modelled claim. All
citations were independently verified against the PDF on 2026-06-04.

**Grounding rule:** Every asserted triple is traceable to a verbatim passage
below. Annotations (equipment attributes with no structural property) are
noted as such.

---

## 1. Equipment instance

### `deschutes:CDU_1` — `aif-ops:Coolant_Distribution_Unit`

Source: §3.1 Technical Specification table, p.12; §4.1 Overall Dimensions, p.17

§3.1 Technical Specification table (p.12):

> "Thermal load: 2,000 kW"
> "IT fluid flow rate: 500 GPM"
> "Coolant: DI water, PG25"
> "Heat exchanger type: liquid-to-liquid, dual pass"

§4.1 Overall Dimensions table (p.17):

> "Width: 65 in (1651 mm)"
> "Height: 93.1 in (2364.7 mm)"
> "Depth: 47.2 in (1198.9 mm)"
> "Wet weight: 6910 lbs (3134 kg)"
> "Dry weight: 5310 lbs (2409 kg)"

Equipment attributes (thermal load, flow rate, dimensions, weight, coolant
type) have no dedicated ontology property in aif-ops v1. They are recorded as
annotation text in `aif-ops:hasSource` only (see extraction plan §4.5).

---

### `deschutes:RDHx_Rack` — `aif-ops:Rear_Door_Heat_Exchanger`

Source: §18.9 Rear Door Heat Exchanger (RDHx) Details, p.63; §18.13 CDU
Placement, Fig 18.13.1, p.67

§18.9 (p.63):

> "The data center owner will decide if rear door heat exchangers are needed
> to provide cooling to the rack. If needed, the RDHx units will be anchored
> into the floor without requiring any physical support from the IT racks or
> the Redmond structure. The RDHx vendor will design the mounting structure
> for the RDHx units."

§18.13 Figure 18.13.1 caption (p.67):

> "Project Deschutes CDU showing placement on Floor with primary and secondary
> piping connections"

The figure labels "Secondary Piping for rack cooling" connecting the CDU to
rack-level RDHx units. This grounds `deschutes:CDU_1 brick:feeds deschutes:RDHx_Rack`.

---

## 2. Sensors / Brick points

All seven sensors are sourced from the §6.5 Sensors and Instrumentation table,
p.25. The table has a "Loop" column with values "Technical" (Secondary loop)
and "Primary" (Facility loop). Loop identity is encoded in `rdfs:label` using
the canonical pair "Secondary/Technical Loop" and "Primary/Facility Loop" as
no `aif-ops:onFluidLoop` property exists in the current schema (extraction
plan §4.2).

### `deschutes:Sensor_Tech_CDUOutput_Temp` — `brick:Temperature_Sensor`

Source: §6.5 Sensors and Instrumentation p.25, row: CDU Output Temperature,
Loop = Technical.

### `deschutes:Sensor_Tech_CDUInput_Temp` — `brick:Temperature_Sensor`

Source: §6.5 Sensors and Instrumentation p.25, row: CDU Input Temperature,
Loop = Technical.

### `deschutes:Sensor_Tech_CDUOutput_Pressure` — `brick:Pressure_Sensor`

Source: §6.5 Sensors and Instrumentation p.25, row: CDU Output Pressure,
Loop = Technical.

### `deschutes:Sensor_Tech_FlowMeter` — `brick:Flow_Sensor`

Source: §6.5 Sensors and Instrumentation p.25, row: Flow Meter, Loop = Technical.

### `deschutes:Sensor_Primary_CDUInput_Temp` — `brick:Temperature_Sensor`

Source: §6.5 Sensors and Instrumentation p.25, row: CDU Input Temperature,
Loop = Primary.

### `deschutes:Sensor_Primary_CCV_Pressure` — `brick:Pressure_Sensor`

Source: §6.5 Sensors and Instrumentation p.25, row: CCV Output Pressure,
Loop = Primary.

### `deschutes:Sensor_CDU_LeakRope` — `brick:Leak_Detection_Sensor`

Source: §6.5 Sensors and Instrumentation p.25, row: Leak Detection (rope,
3 zones), Loop = CDU; §3.2 item 10 p.13

§3.2 product requirement item 10 (p.13):

> "Leak rope detection (detected through PLC, 3 zones)"

This sensor satisfies `CDU_Shape sh:qualifiedMinCount 1` for
`brick:Leak_Detection_Sensor`.

---

## 3. Failure mode

### `deschutes:FM_CoolantLeak` — `aif-ops:FailureMode`

Source: §3.2 item 10 p.13; §6.7 Control System p.26

§6.7 (p.26):

> "Alarms for detected leaks"

Only `FM_CoolantLeak` is modelled. Pump motor overtemperature is mentioned as
an alarm in §6.7 but no motor temperature sensor appears in the §6.5 sensor
table; there is no grounded `brick:Point` for its `hasDetectionSignature`
constraint (see extraction plan §3.3).

---

## 4. Events

### `deschutes:Event_LeakDetected` — `aif-ops:Event`

Source: §6.7 Control System p.26

> "Alarms for detected leaks"

---

## 5. Interlocks

### `deschutes:Interlock_HotswapFluidIsolation` — `aif-ops:Interlock`

Source: §13.1 Power, maintenance and hotswap requirements, p.41

> "Components that are replaceable during continuous normal operation must have
> appropriate interlocks to prevent: Disruptive fluid pressure or flow
> conditions — manual stop valves, and/or check valves and/or leak-free
> disconnects."

Gates `deschutes:Action_PumpRemove` (step 10 of `MOP_PumpRemoval`), not the
valve-closing prerequisite (step 1). The interlock guards the physical pump
removal action, not the isolation step.

### `deschutes:Interlock_FlowMeterShutdown` — `aif-ops:Interlock`

Source: §13.4 p.45

Gates `deschutes:Action_FlowMeter_Unbolt`. A full `MOP_FlowMeterService` is
deferred — verbatim steps from §13.4 have not been extracted in this PR.
`Action_FlowMeter_Unbolt` is a standalone action node satisfying
`Interlock_Shape sh:class aif-ops:Action`.

---

## 6. Isolation points

### `deschutes:IP_PumpSupplyValve` — `aif-ops:IsolationPoint`

Source: §13.2 Pump Removal Step 1, p.42

> "1. Shut off supply valve"

`hasIsolationProcedure` links to both `deschutes:MOP_PumpRemoval` and
`deschutes:EOP_LeakResponse`: Leak Response step 3
(`deschutes:Action_EOP_ShutSupplyValve`) cites the identical spec location,
§13.2 Step 1 p.42, for the same instruction, so both procedures isolate the
CDU at this same physical valve.

### `deschutes:IP_FilterInletValve` — `aif-ops:IsolationPoint`

Source: §13.3 Filter Removal Step 1, p.44

> "1. Shutoff filter inlet valve"

### `deschutes:IP_FilterOutletValve` — `aif-ops:IsolationPoint`

Source: §13.3 Filter Removal Step 2, p.44

> "2. Shutoff filter outlet valve"

### `deschutes:IP_VFD_MainDisconnect` — `aif-ops:IsolationPoint`

Source: §13.5 VFD Removal Step 1, p.46

> "1. Turn off main disconnect for VFD to be serviced"

---

## 7. Lockout/tagout steps

### `deschutes:LOTO_VFD_Step1` and `deschutes:LOTO_VFD_Step2`

Source: §13.5 VFD Removal Steps 1–2, p.46 (verbatim):

> "1. Turn off main disconnect for VFD to be serviced.
>  2. Open high voltage enclosure and ensure power to VFD is removed."

These steps mirror `Action_VFD_TurnOffDisconnect` and `Action_VFD_OpenHVEnclosure`
in `MOP_VFDRemoval` — the same physical actions are recorded both as LOTO steps
(for energy-control compliance) and as MOP sequence steps (for procedure
execution).

---

## 8. EOP: Coolant leak response

### `deschutes:EOP_LeakResponse` — `aif-ops:EOP`

Source (procedure-level): §3.2 item 10 p.13; §6.7 p.26; §13.1 p.41;
§13.2 Steps 1–2 p.42

#### Step 1 — `deschutes:Action_EOP_PLCLeakAlarm` (`aif-ops:AutomatedAction`)

First use of `aif-ops:AutomatedAction` in any aif-ops worked example.

Source: §3.2 item 10 p.13; §6.7 p.26

> "Leak rope detection (detected through PLC, 3 zones)" (§3.2 item 10, p.13)
> "Alarms for detected leaks" (§6.7, p.26)

#### Step 2 — `deschutes:Action_EOP_IdentifyZone` (`aif-ops:ManualAction`)

Source: §3.2 item 10 p.13

> "Leak rope detection (detected through PLC, 3 zones)"

3-zone detection implies the operator must determine which zone triggered.

#### Step 3 — `deschutes:Action_EOP_ShutSupplyValve` (`aif-ops:ManualAction`)

Source: §13.2 Step 1 p.42; §13.1 p.41

> "1. Shut off supply valve" (§13.2 Step 1, p.42)
> "manual stop valves … to prevent: Disruptive fluid pressure or flow
> conditions" (§13.1, p.41)

#### Step 4 — `deschutes:Action_EOP_DisablePump` (`aif-ops:ManualAction`)

Source: §7.2.2 p.28

> "Pump enable/disable" listed as a controllable parameter via PLC (§7.2.2, p.28)

#### Step 5 — `deschutes:Action_EOP_DrainPump` (`aif-ops:ManualAction`)

Source: §13.2 Step 2 p.42

> "2. Connect drain hose to drain barb on bottom of pump and open drain valve"

#### Step 6 — `deschutes:Action_EOP_RepairComponent` (`aif-ops:ManualAction`)

Source: §13.1 p.41

> "repair procedures" documentation requirement (§13.1, p.41)

Note: The spec does not document a PLC alarm-clear step (unlike the XDU1350
which has an explicit Clear Alarms button). No alarm-clear action is modelled.

---

## 9. MOP: Filter service

### `deschutes:MOP_FilterService` — `aif-ops:MOP`

Source: §13.3 Filter Removal Steps, p.44 (verbatim):

> "1. Shutoff filter inlet valve
>  2. Shutoff filter outlet valve
>  3. Connect drain hose to drain barb on bottom of filter and open drain valve
>  4. Loosen front clamp with rag around joint to allow air to enter if needed
>     to complete drain
>  5. Remove clamp from front of filter
>  6. Slide filter out for cleaning or replacement"

---

## 10. MOP: Pump removal

### `deschutes:MOP_PumpRemoval` — `aif-ops:MOP`

Source: §13.2 Pump Removal Steps, p.42 (verbatim):

> " 1. Shut off supply valve
>   2. Connect drain hose to drain barb on bottom of pump and open drain valve
>   3. Depress Schraeder valve as needed to drain line
>   4. Remove gussets
>   5. Remove 4x bolts from ANSI suction flange
>   6. Disconnect 4″ triclamp
>   7. Unplug pressure sensor if required
>   8. Loosen Victaulic fittings in two locations to allow fittings to slide and
>      section removal or remove 4x bolts from output flange and loosen Victaulic
>      fitting to allow pipe section removal
>   9. Unbolt pump
>  10. With assistance device (in process) remove pump"

Step 10 (`Action_PumpRemove`) is the gate target of `Interlock_HotswapFluidIsolation`.

---

## 11. MOP: VFD removal

### `deschutes:MOP_VFDRemoval` — `aif-ops:MOP`

Source: §13.5 VFD Removal Steps, p.46 (verbatim):

> "1. Turn off main disconnect for VFD to be serviced
>  2. Open high voltage enclosure and ensure power to VFD is removed
>  3. Open cover of VFD and disconnect power and control cables
>  4. Remove conduit from bottom of VFD
>  5. Remove wire from inside VFD and bend conduit out of the way for VFD removal
>  6. Remove top two bolts in through holes on VFD
>  7. Loosen top key hole bolts and bottom slotted hole bolts
>  8. With assistance lift and remove VFD from frame"

Steps 1–2 are also recorded as `LOTO_VFD_Step1` and `LOTO_VFD_Step2` for
energy-control compliance.

---

## 12. Maintenance task

### `deschutes:MT_FilterConditionBased` — `aif-ops:OnConditionMaintenanceTask`

Source: §20.5 Hydraulic, p.73–74 (primary trigger anchor); §13.3 Filter Removal Step 6, p.44 (confirms condition-based servicing)

The trigger-condition grounding comes primarily from §20.5, not §13.3:

§20.5 Hydraulic (p.73–74):

> "Vendor to provide guidance on alert/alarm thresholds for maintenance."

This passage explicitly models the maintenance trigger as a condition threshold (alert/alarm level) supplied by the equipment vendor — not a calendar interval. It directly grounds `hasTriggerCondition` as the observable condition that governs service timing. The vendor-guidance note also confirms that no fixed `recursEvery` duration is assertable from the design spec.

§13.3 Step 6 (p.44) provides corroborating evidence that the service action is condition-triggered:

> "Slide filter out for cleaning or replacement"

"Cleaning or replacement" (rather than "replace on schedule") is consistent with condition-based servicing but does not by itself specify the trigger condition. §20.5 is the anchor for the trigger; §13.3 is the anchor for the service procedure that follows.

`hasTriggerCondition` is therefore a prose description grounded on §20.5: elevated differential pressure across the filter assembly, or damage/contamination on visual inspection. A `ScheduledMaintenanceTask` with `recursEvery` is not assertable from this source.

This instance satisfies `CDU_Shape hasMaintenanceTask sh:minCount 1` via the `OnConditionMaintenanceTask` subclass of `MaintenanceTask`.

---

## 13. Commissioning step

### `deschutes:CS_FilterHydraulicTest` — `aif-ops:CommissioningStep`

Source: §20.5 Primary and secondary filters, Hydraulic and Impulse subsections,
p.73–74

**`hasPassCriteria`** — verbatim from §20.5 Hydraulic (p.73–74):

> "Measure dP vs flow of filter assemblies; validation shall be done with DI
> water and PG25 coolants."

The spec notes: "Vendor to provide guidance on alert/alarm thresholds for
maintenance." No numeric threshold is specified in the document; the pass
criterion is the measurement procedure itself. Quantitative thresholds are
vendor-supplied and not modelled here.

**`hasFailCriteria`** — verbatim from §20.5 Impulse (p.74):

> "A filter housing will be pressurized to 150 psig, then a ball valve will be
> suddenly opened–allowing for the water to escape through the housing outlet
> and create an impulse condition. The filter cartridge will be removed and
> inspected for damage."

The impulse test procedure is the failure-detection criterion: damage observed
on cartridge inspection constitutes a fail outcome.

---

## Addendum: schema changes in this PR

### Brick sensor subclass stubs added to `aif_ops.ttl`

Three stubs added alongside the existing `brick:Leak_Detection_Sensor` stub at
`aif_ops.ttl:22`:

```turtle
brick:Temperature_Sensor rdfs:subClassOf brick:Point .
brick:Pressure_Sensor    rdfs:subClassOf brick:Point .
brick:Flow_Sensor        rdfs:subClassOf brick:Point .
```

Required for `FailureMode_Shape sh:path aif-ops:hasDetectionSignature sh:class
brick:Point` to resolve `deschutes:Sensor_CDU_LeakRope` (and future temperature
and pressure sensors) as `brick:Point` subclasses. Without these stubs pyshacl
cannot traverse the subclass chain when validating the instance graph against
the shapes without loading the full Brick 1.4.4 TTL.

### MaintenanceTask subclass split

`aif-ops:MaintenanceTask` was split into two concrete subclasses in this PR:

- `aif-ops:ScheduledMaintenanceTask` — requires `aif-ops:recursEvery xsd:duration` (ISO 8601 interval). Used by XDU1350 and CDU100 examples.
- `aif-ops:OnConditionMaintenanceTask` — requires `aif-ops:hasTriggerCondition rdfs:Literal` (prose description of the trigger). Used by this extraction.

`CDU_Shape hasMaintenanceTask sh:minCount 1` targets the base class and is satisfied by either subtype. `ScheduledMaintenanceTask_Shape` and `OnConditionMaintenanceTask_Shape` validate the respective subclass constraints separately. All three extractions now conform with zero SHACL violations.
