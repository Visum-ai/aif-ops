# Known Limitations and Ambiguities

This document records open design questions and expressibility gaps in the current release of the aif-ops ontology and SHACL shapes. It is intended as a working reference for implementers evaluating the schema for adoption.

Entries are grouped into two categories:

- **Ambiguities:** concepts whose semantics are under-specified and could be interpreted in more than one way
- **Limitations:** constraints that are intentionally desired but cannot be expressed in SHACL Core

---

## Ambiguities

### A1: `Event`: trigger type or trigger instance?

`aif-ops:Event` is defined as "a detected condition that may trigger a Procedure." The ontology does not distinguish between the *type* of event (e.g. the class of condition "CDU supply temperature exceeds 45°C") and a *specific occurrence* of that event at a point in time. Systems that need both (for example, a CMMS that logs each alarm firing and links it to the procedure it triggered) will need to introduce a subclass or a separate occurrence class.

**Consequence:** Instance graphs that record individual alarm events cannot distinguish a recurring event type from a single firing without extending the model.

**Resolution path:** Introduce `aif-ops:EventType` and `aif-ops:EventOccurrence` as a type/occurrence split, following the pattern used by PROV-O (`prov:Activity` vs. `prov:ActivityType`) or FMEA ontologies.

---

### A2: `Action` vs. step granularity

`aif-ops:Action` is defined as "an atomic operator or automated step within a Sequence." Three subclasses are declared (`ManualAction`, `AutomatedAction`, `VerificationAction`) but the boundary between an action and a step is not formally defined. Some procedure formats distinguish high-level steps (numbered sections) from atomic actions (individual physical moves). The current model collapses both into `Action`.

**Consequence:** Two implementers encoding the same procedure may produce structurally incompatible instance graphs depending on how finely they decompose actions.

**Resolution path:** Define a `Step` class as a container of one or more `Action` instances, or add a `sh:property` constraint that restricts `stepOrder` to a specific granularity level within a `Sequence`.

---

### A3: `hasActor` open range

`aif-ops:hasActor` has no `rdfs:range` declaration. The intended object is whichever IRI identifies the actor responsible for an `Action`: a person, a role, an automated system, or an external agent. Leaving the range open allows maximum flexibility but gives no guidance to implementers about what vocabulary to use for actor identity.

**Consequence:** Instance graphs from different sources will use incompatible actor vocabularies, making cross-graph queries unreliable.

**Resolution path:** Recommend a specific actor vocabulary (e.g. ORG ontology roles, PROV-O `prov:Agent`) in a usage note, or introduce an `aif-ops:Actor` superclass that implementers can subclass.

---

### A4: `IsolationPoint` vs. `Interlock`: semantic boundary

Both `IsolationPoint` and `Interlock` gate equipment actions. `IsolationPoint` is defined as a physical point (valve, breaker, disconnect) at which equipment can be removed from service. `Interlock` is defined as a trip or permissive condition that gates an operator or automated action. The boundary between a physical permissive (e.g. a pressure switch that must read zero before a valve can open) and an isolation point is not formally stated.

**Consequence:** Implementers may classify the same physical device differently depending on context, producing inconsistent graphs.

**Resolution path:** Add an `rdfs:comment` to each class that explicitly states what the other class is *not*, and add a worked example to the documentation.

---

### A5: `GPU_Rack` placement in the Brick hierarchy

`aif-ops:GPU_Rack` is placed under `aif-ops:Compute_Equipment`, which is declared as a direct subclass of `brick:Equipment`. An alternative placement would be under `brick:ICT_Equipment` (a Brick 1.4.4 class), which would make GPU racks visible to queries over the existing Brick equipment hierarchy without requiring knowledge of the aif-ops namespace.

**Consequence:** SPARQL queries written against the standard Brick hierarchy will not return `GPU_Rack` instances unless they also import aif-ops class declarations.

**Resolution path:** Deferred pending review of Brick's `ICT_Equipment` subtree.

---

## Limitations (SHACL Core)

### L1: `stepOrder` uniqueness and contiguity

`Action_Shape` enforces that every `Action` has exactly one `stepOrder` value that is a positive integer (`sh:datatype xsd:integer`, `sh:minInclusive 1`). It does not enforce that `stepOrder` values are unique across all actions in a given `Sequence`, or that they form a contiguous sequence (1, 2, 3, …, n) with no gaps.

**Consequence:** A `Sequence` with two `Action` nodes both declaring `stepOrder 1`, or a `Sequence` with steps 1, 2, and 4 (skipping 3), will pass validation without error.

**Resolution path:** SHACL-SPARQL (`sh:sparql` constraint) can express both uniqueness and contiguity. Deferred to a future release.

---

### L2: Subclass shapes inherit silently

Shapes target parent classes directly (`aif-ops:Procedure`, `aif-ops:Action`, `aif-ops:Event`, etc.). Instances of subclasses (`aif-ops:MOP`, `aif-ops:ManualAction`, `aif-ops:EOP`, etc.) are validated through subclass inference when the ontology is loaded via `-e`, but no dedicated shape exists for any subclass. Subclass-specific constraints (for example, that an `EOP` must reference an emergency contact) cannot be expressed without additional shapes.

**Consequence:** Subclass instances satisfy only the parent shape. Any constraint that is meaningful only for a specific subclass is not validated.

**Resolution path:** Add per-subclass shapes as subclass-specific requirements are identified.

---

### L3: `CommissioningStep` criteria datatype

`CommissioningStep_Shape` constrains `hasPassCriteria` and `hasFailCriteria` to `sh:nodeKind sh:Literal`, which allows any RDF literal including language-tagged strings, numeric values, and untyped literals. The intent is a human-readable text criterion, which would normally be `xsd:string`.

**Consequence:** An instance graph that stores a numeric pass threshold as a bare number (e.g. `"45"^^xsd:decimal`) will pass validation even though the consuming system expects a text description.

**Resolution path:** Change `sh:nodeKind sh:Literal` to `sh:datatype xsd:string` if strict string typing is required. Left open intentionally to avoid over-constraining multilingual deployments.

---

### L4: `requires` and `prohibits` on `Interlock` have no range

`aif-ops:requires` and `aif-ops:prohibits` are declared as object properties on `aif-ops:Interlock` with no `rdfs:range`. The intended semantics (the condition or state that an interlock requires to be true or prohibits from being true) could be modeled as a sensor point, an operating mode, or a boolean expression, depending on the system.

**Consequence:** No shape validates the object of these properties, so any IRI will pass.

**Resolution path:** Once the target vocabulary for conditions and states is agreed (e.g. Brick `Point`, `aif-ops:OperatingMode`, or a dedicated `aif-ops:Condition` class), add `rdfs:range` declarations and corresponding shape constraints.
