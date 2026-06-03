# aif-ops

OWL ontology and SHACL shapes extending [Brick Schema](https://brickschema.org) with operational metadata for AI factory infrastructure.

Developed for the broader community working on operational semantics for AI factory infrastructure.

## What this covers

**Equipment classes:** Coolant Distribution Units, cold plates, rear-door heat exchangers, liquid cooling manifolds, immersion cooling tanks, GPU racks, rack PDUs, and busways, positioned within the Brick class hierarchy.

**Operational entity classes:** Procedures (MOPs, SOPs, EOPs), failure modes, isolation points, interlocks, lockout/tagout steps, operating modes, events, sequences, actions, maintenance tasks, and commissioning steps.

**Properties:** 21 object properties and 4 datatype properties connecting equipment instances to their operational metadata.

## Files

| File | Description |
|------|-------------|
| `aif_ops.ttl` | OWL ontology: class declarations, property definitions, and Brick hierarchy stubs |
| `aif_ops_shapes.ttl` | SHACL shapes: 12 node shapes (1 CDU equipment shape + 11 operational entity class shapes) |

## Namespace

```
https://visum.ai/ns/aif-ops#
```

Recommended prefix: `aif-ops:`

## Validation

Install [pyshacl](https://github.com/RDFLib/pySHACL):

```
pip install pyshacl
```

Validate an instance graph against the shapes:

```
pyshacl -s aif_ops_shapes.ttl -e aif_ops.ttl -df turtle -f table your-instance.ttl
```

A conforming graph produces:

```
Validation Report
Conforms: True
```

**The `-e` flag is mandatory.** It loads the ontology as extra graph data so pyshacl can resolve subclass chains when evaluating `sh:class` constraints. Without it, shapes whose `sh:targetClass` resolves only through subclass inference will silently fire on zero nodes and report `Conforms: True` without validating anything. Always pass `-e aif_ops.ttl`.

## Brick alignment

The ontology extends Brick Schema 1.4.4. The `owl:imports` IRI points to the Brick 1.4.4 TTL. `aif_ops.ttl` also includes the minimal Brick hierarchy stubs required for pyshacl subclass resolution without fetching the full Brick graph at validation time.

## License

Apache 2.0
