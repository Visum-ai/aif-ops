# Source citations — vertiv-xdu1350-extraction.ttl

**Source document:** Vertiv XDU1350 Coolant Distribution Unit Operation and
Maintenance Manual, XDU1350B, SL-71310, Vertiv Group Corp., 2025.

Each entry records the aif-ops entity, its `aif-ops:hasSource` value, and the
verbatim text from the source document that grounds the modeled claim. All
citations were independently verified against the PDF on 2026-06-04.

---

## 1. Equipment instance

### `xdu:CDU_1` — `aif-ops:Coolant_Distribution_Unit`

Source: §3 Product Description, p.11

> "The XDU1350 contains a secondary closed loop circuit that provides a supply
> of cooling fluid to equipment based on constant differential pressure either
> through indirect cooling (rack mounted rear door heat exchangers), or direct
> cooling (cold plates at chip level)."

---

## 2. Operating modes

### `xdu:Mode_Online` — `aif-ops:OperatingMode`

Source: §4.5 Alarm Management, Fig 4.18, p.49

Fig 4.18 (Control Screen Alarm Indication) shows the Home screen display with
the Unit Mode field reading **"Online (Running)"**.

### `xdu:Mode_Shutdown_Fault` — `aif-ops:OperatingMode`

Source: §4.6 Table 4.39, A37 Shutdown column p.56; A43 Shutdown column p.57

Table 4.39:
- A37 row: Shutdown = ✓ (or not) — configurable alarm-only or shutdown
- A43 row: Shutdown = ✓ — always shuts down on insufficient fluid

---

## 3. Sensor / Brick point

### `xdu:LeakSwitch_DripTray` — `brick:Leak_Detection_Sensor`

Source: §4.6 Table 4.39, A37 Detail, p.56

> "Detail: Level switch in cabinet drip tray has detected a substantial water
> leak."

---

## 4. Failure mode

### `xdu:FM_CoolantLeak` — `aif-ops:FailureMode`

Source: §4.6 Table 4.39, A37 row, p.56

| Code | Description | Type | Self-clear | Latching | Shutdown | Delay |
|------|-------------|------|------------|----------|----------|-------|
| A37  | Leak - Unit | 1    | —          | ✓        | ✓ (or not) | — |

---

## 5. Events

### `xdu:Event_A37` — `aif-ops:Event`

Source: §4.6 Table 4.39, A37, p.56

> "Detail: Level switch in cabinet drip tray has detected a substantial water
> leak. Event may be set for Alarm Only (default), or Alarm + Unit Shutdown."

### `xdu:Event_A44` — `aif-ops:Event`

Source: §4.6 Table 4.39, A44, p.57

| Code | Description                    | Type | Self-clear | Latching | Shutdown |
|------|-------------------------------|------|------------|----------|----------|
| A44  | Level Sensor — No Fluid Detected | 2  | ✓          | —        | —        |

> "Detail: While Unit is Running only: If both Level sensors are open circuit
> for more than 1 second then this alarm will be raised, providing flow or DP
> (depending on control function set) is >50% of flow/DP setpoint."

Modeled as a log-only event with no `aif-ops:triggers` triple, exercising the
`sh:minCount 0` constraint on `Event_Shape`.

---

## 6. Interlocks

### `xdu:Action_StartUnit` — `aif-ops:ManualAction` (interlock gate target)

Source: §4.3 Automatic Operation, p.39

> "After commissioning, the unit will be ready to run in automatic mode. Press
> the Start/Stop icon button on the display Home screen (see Figure 4.1 on
> page 17), then select the ON button as shown in Figure 4.11 below."

### `xdu:Interlock_A27_PumpLowFlow` — `aif-ops:Interlock`

Source: §4.6 Table 4.39, A27, p.55

| Code | Description    | Type | Latching |
|------|---------------|------|----------|
| A27  | Pump Low Flow | 1    | ✓        |

> "Detail: Pumps have not reached the flow rate (or differential pressure)
> setpoint in the specified time limit (default 100 secs)."
>
> "Action: Check that unit has been set for the correct system flow rate (or DP),
> check for system blockages, check inverter drive for faults, check non-return
> valves on Pumps are not sticking open (pump rotating slowly backwards).
> Reduce flow setting (or DP)."

### `xdu:Interlock_A43_InsufficientFluid` — `aif-ops:Interlock`

Source: §4.6 Table 4.39, A43, p.57

| Code | Description        | Type | Latching | Shutdown |
|------|--------------------|------|----------|----------|
| A43  | Insufficient Fluid | 1    | ✓        | ✓        |

> "Detail: On Initial Startup: level sensors are not made, fill pressure has not
> been achieved and fill pump has been running for more than 1 minute, then unit
> will not start or shutdown immediately."
>
> "While Unit is Running: This will be in conjunction with a A44 — Level Sensor
> — No Fluid Detected alarm. If level sensors are not made and flow or DP is
> < 50% of flow/DP setpoint, then unit will shutdown after a 1 second delay."

---

## 7. Isolation points

### `xdu:IP_ElectricalDisconnect` — `aif-ops:IsolationPoint`

Source: §1.5 Electrical Connection, p.6

> "The only way to ensure that there is NO voltage inside the unit is to install
> and open a remote disconnect switch. Refer to unit electrical schematic."

### `xdu:IP_FluidIsolationValve_Supply` and `xdu:IP_FluidIsolationValve_Return`

Source: §5.5 Unit Draining, p.75

> "Field supplied external isolation valves should be fitted by the installer to
> both supply and return pipes, as close as possible to the XDU1350 for
> maintenance purposes."

### `xdu:IP_FilterIsolationValve_4` and `xdu:IP_FilterIsolationValve_5`

Source: §5.4 Secondary Filter Service, Fig 5.2, p.74

Fig 5.2 (Servicing Secondary Filter) item legend:
- Item 4: "Filter isolation valve"
- Item 5: "Filter isolation valve"

Procedure step 2:

> "Close filter isolation valves 4 and 5 to positions shown by red handle
> outlines, as shown in Figure 5.2 above (i.e. handles are
> vertical/horizontal)."

---

## 8. Lockout/tagout steps

### `xdu:LOTO_Step1`, `xdu:LOTO_Step2`, `xdu:LOTO_Step3`

Source: §1.1 General, p.4

> "Before any maintenance work being carried out, ensure:
> 1. Equipment is switched OFF.
> 2. Equipment and controls are disconnected from the electrical supply.
> 3. All rotating parts such as pumps and 3-way valve have come to rest."

`LOTO_Step2` additionally cites §1.5 Electrical Connection, p.6:

> "The only way to ensure that there is NO voltage inside the unit is to install
> and open a remote disconnect switch."

---

## 9. EOP: Coolant leak response

### `xdu:EOP_CoolantLeak` — `aif-ops:EOP`

Source: §4.6 Table 4.39, A37 Action, p.56; §1.1 General pre-maintenance steps, p.4

### `xdu:Action_IdentifyLeak` and `xdu:Action_RepairLeak`

Source: §4.6 Table 4.39, A37, p.56

> "Action: Identify and repair the leak."

### `xdu:Action_SwitchOff`

Source: §1.1 General, p.4 item 1; §4.3 Automatic Operation, Fig 4.11, p.39

> "1. Equipment is switched OFF."

Fig 4.11 shows the "Switch CDU" dialog with Cancel / Off / ON buttons.

### `xdu:Action_DisconnectElectrical`

Source: §1.1 General, p.4 item 2; §1.5 Electrical Connection, p.6

> "2. Equipment and controls are disconnected from the electrical supply."
> "The only way to ensure that there is NO voltage inside the unit is to install
> and open a remote disconnect switch."

### `xdu:Action_VerifyRotatingPartsStopped`

Source: §1.1 General, p.4 item 3

> "3. All rotating parts such as pumps and 3-way valve have come to rest."

### `xdu:Action_ClearA37Alarm`

Source: §4.5 Alarm Management, p.50

> "Latching alarms need to be manually cleared when logged on at the service
> level or higher by pressing the Clear Alarms button on either of the screens
> above."

---

## 10. Maintenance task

### `xdu:MT_FilterInspection_3month` — `aif-ops:MaintenanceTask`

Source: §5.3 Planned Preventative Maintenance, p.71

> "Planned maintenance services should be carried out in 3 months, 6 months,
> and 12 months in the first year after the commissioning. After then, the
> planned maintenance service will be twice every year, with interval of
> 6 months."

3-month interval items include secondary filter differential pressure check and
filter service if required.

---

## 11. Commissioning step

### `xdu:CS_PumpChangeover` — `aif-ops:CommissioningStep`

Source: §5.3 Planned Preventative Maintenance, p.72 (6-month interval);
§4.6 Table 4.39, A27, p.55; §4.3.2, p.47

§5.3, p.72:

> "Simulate the pump change over."

§4.3.2, p.47 (run/standby pump changeover timing):

> "the complete changeover sequence takes approximately 0.25 seconds (default)."

A27 (p.55) defines the failure criterion: pumps fail to reach flow/DP setpoint
within 100 seconds.

---

## 12. MOP: Secondary filter service

### `xdu:MOP_FilterService` — `aif-ops:MOP`

Source: §5.4 Secondary Filter Service, p.73–74

> "NOTE: Each filter can be cleaned while the unit is running provided the
> operation is switched to the pumps/filters not to be cleaned. Place the pump
> for the filter to be cleaned into out-of-service state via the service
> secondary pumps menu."

### Filter service steps (§5.4, p.74)

> "The secondary filter may be removed and cleaned following the procedure
> below:
>
> 1. Open the cabinet front doors, and swing the electrical panel up and out of
>    the way as shown in Figure 5.1 on the previous page.
> 2. Close filter isolation valves 4 and 5 to positions shown by red handle
>    outlines, as shown in Figure 5.2 above (i.e. handles are
>    vertical/horizontal).
> 3. Connect hose to drain valve 3.
> 4. Once drained, undo the clamp ring then withdraw the cap and filter screen
>    using the Tee handle provided. Lift filter screen up and out of the filter
>    housing, then out through the front of the unit.
> 5. To clean the filter, rinse with DI water or PG solution and then let drip
>    dry."
