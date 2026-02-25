# SnortML Multi-Protocol Extension Analysis

## 1) What the current implementation actually does

From the current Snort 3 source, SnortML is split into two pieces:

- `snort_ml_engine` (global): loads model file(s), optional pre-filters, and optional verdict cache.
- `snort_ml` (inspection policy): subscribes to events and decides whether to alert.

### 1.1 Scope is HTTP-parameter centric today

Current configuration and rule messaging explicitly target HTTP parameter detection:

- `snort_ml` options are `uri_depth`, `client_body_depth`, and `http_param_threshold`.
- `snort_ml_engine` option is `http_param_model`, plus `http_param_filter` / `http_param_ignore`.
- The rule text is “potential threat found in HTTP parameters...”.

### 1.2 Data path in current code

1. `snort_ml` subscribes to **HTTP** DataBus events only (`REQUEST_HEADER`, `REQUEST_BODY`, `MIME_FORM_DATA`).
2. It extracts URI query / urlencoded client body / form data.
3. It calls `SnortMLEngine::scan(buffer, len, output)`.
4. If output > `http_param_threshold`, it raises `gid:sid 411:1`.

### 1.3 Engine behavior is useful and reusable

The engine already supports practical IDS/IPS features:

- Loading a single model file or all models from a directory.
- Multi-model set via `BinaryClassifierSet`.
- Optional fast string pre-filtering before inference.
- Optional LRU cache (`cache_memcap`) keyed by hash of inspected bytes.

This is a good base to extend without replacing the engine architecture.

## 2) Why your research question is well formulated

Your question asks:

> How can SnortML be extended to support ML-based detection for non-HTTP traffic in a way that is practical for IDS/IPS use?

This is strong because it includes both:

- **Capability expansion** (non-HTTP protocol support).
- **Operational practicality** (latency, throughput, false-positive control, deployment constraints).

The existing code shows exactly this tension:

- Snort has rich protocol/event infrastructure.
- SnortML currently only attaches to HTTP event streams.

So the thesis gap is concrete and implementation-grounded.

## 3) What “extending to other protocols” should look like (concrete design)

## 3.1 Key design principle: protocol adapters feeding a shared ML engine

Keep one shared inference backend (`snort_ml_engine`) and add protocol-specific adapters in `snort_ml` (or sibling inspectors).

### Proposed architecture

- **Global ML engine**
  - Maintain current load/cache/filter mechanics.
  - Generalize naming from `http_param_*` to protocol-aware blocks.

- **Protocol adapters**
  - One adapter per protocol event source (DNS, SIP, SSH, etc.).
  - Adapter responsibilities:
    1. subscribe to protocol DataBus events,
    2. extract selected fields,
    3. canonicalize/serialize into model input bytes,
    4. invoke engine with protocol+feature-set model binding.

- **Model registry / routing**
  - Route by `(protocol, feature_profile, direction)` to one or more models.

## 3.2 Configuration model (example)

```lua
snort_ml_engine.protocol_models = {
  { protocol = 'http', feature_profile = 'params_v1', model = '/models/http_params_v1.model' },
  { protocol = 'dns',  feature_profile = 'qname_rr_v1', model = '/models/dns_qname_rr_v1.model' },
  { protocol = 'ssh',  feature_profile = 'kex_meta_v1', model = '/models/ssh_kex_meta_v1.model' }
}

snort_ml.protocols = {
  http = { enabled = true, uri_depth = 256, body_depth = 512, threshold = 0.95 },
  dns  = { enabled = true, payload_depth = 128, threshold = 0.90 },
  ssh  = { enabled = true, payload_depth = 128, threshold = 0.92 }
}
```

Important: avoid one universal threshold. Keep **per-protocol thresholds**, optionally per feature profile.

## 3.3 Protocol targets to start with (realistic order)

1. **DNS** (UDP/TCP): strong DGA/tunneling/amplification relevance; structured fields available via DNS events.
2. **SSH**: metadata-rich events (version, validation state, algorithms).
3. **SIP**: mature event model with user-agent/from/server/media metadata.
4. (Later) QUIC, DHCP, and selected industrial protocols where parser quality is high.

## 3.4 Feature extraction strategy (practical for IDS/IPS)

Use a two-layer representation:

- **Layer A (semantic features)**
  - e.g., DNS query type/class, RR counts, name length/entropy, label stats.
  - e.g., SSH algorithm-list tokens and protocol version metadata.

- **Layer B (bounded raw bytes)**
  - retain compact byte windows for patterns missed by handcrafted features.

Serialize to deterministic byte/f32 vectors with strict versioned schemas (`*_v1`, `*_v2`) so model compatibility is explicit.

## 3.5 Offline training + online deployment loop

1. Extract protocol events from public PCAPs (offline).
2. Build labeled datasets (normal + attack categories).
3. Train protocol-specific binary models first (normal vs suspicious).
4. Export TFLite, package metadata (input size, lowercase/normalization flags).
5. Deploy into Snort with per-protocol thresholds and monitor peg metrics.
6. Recalibrate thresholds against target FPR and CPU budget.

## 4) Feasibility and constraints from current codebase

## 4.1 Feasibility signals

- Engine already supports **multiple models** and picks model by input size.
- Engine already provides **cache + filters + reload handler**.
- Snort has broad **DataBus event ecosystem** for non-HTTP protocols.

So extension is additive, not a rewrite.

## 4.2 Constraints to explicitly manage

- Current `libml` runtime expects 1 input tensor / 1 scalar output and byte->float mapping semantics.
- Existing engine naming/config are HTTP-specific.
- Existing alert SID/message is HTTP-param-specific.
- Latency budget: inference per packet/transaction must be bounded (depth limits + pre-filters + cache).

## 5) Suggested thesis prototype plan

## 5.1 Prototype A: DNS model path

- Add `DnsHandler` in SnortML inspector (subscribe to DNS response/request events).
- Define `dns_feature_profile = qname_rr_v1`.
- Add `dns_threshold` and `dns_depth` style controls.
- Wire to shared engine with model routing.

Evaluation:

- Offline PCAP replay with public benign/malicious DNS corpora.
- Metrics: precision/recall/F1, ROC-AUC, alert rate per K events, CPU overhead, cache hit ratio.

## 5.2 Prototype B: SSH model path

- Subscribe to SSH state/algorithm events.
- Build metadata tokenization pipeline for version + KEX lists.
- Use separate model and threshold from DNS.

Evaluation:

- Add evasive and malformed handshake samples to test “unseen threat” sensitivity.

## 5.3 Comparative analysis (core thesis value)

Compare:

- Rule-only baseline
- Rule + SnortML HTTP-only
- Rule + SnortML HTTP + DNS
- Rule + SnortML HTTP + DNS + SSH

under same replay and throughput conditions.

## 6) Research question refinement (optional)

Your question is already good. A sharpened version could be:

> How can SnortML be architected and evaluated to support protocol-specific ML detectors beyond HTTP, while meeting operational IDS/IPS constraints on latency, throughput, and false-positive rate?

This keeps novelty and practicality explicit.

## 7) Bottom line

- Yes: extending SnortML beyond HTTP is technically viable with current Snort 3 internals.
- Best approach: protocol-adapter pipeline + shared engine + protocol-specific model routing and thresholds.
- Most defensible first targets for thesis prototypes: DNS then SSH.
- Your problem formulation is strong and directly supported by the present implementation gap.
