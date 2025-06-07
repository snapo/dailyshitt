# **Decentralized Compute Marketplace Implementation Brief**  
*(Comprehensive Technical Specification for Developers)*  

---

## **1. Project Overview**  
**Goal:** Build a **100% decentralized, Bitcoin-only compute marketplace** where users can **rent out idle CPU resources** or **deploy WASM-based workloads** in a secure, sandboxed environment.  

### **Key Features:**  
✅ **P2P Network** (libp2p + Kademlia DHT)  
✅ **WASM Sandboxing** (WasmEdge with GPU blocking)  
✅ **Bitcoin Payments** (Lightning Network + Liquid)  
✅ **Decentralized Job Market** (GunDB for real-time job posting)  
✅ **Cross-Platform** (Tauri + React Native)  
✅ **Admin Controls** (Decentralized updates via signed IPFS packages)  

---

## **2. Core Architecture**  

### **2.1. Network Layer (libp2p + Kademlia DHT)**  
- **Peer Discovery**:  
  - Bootstrap via known peers or mDNS (local network).  
  - Kademlia DHT for decentralized job routing.  
- **Messaging**:  
  - Protobuf-encoded job requests/responses.  
  - End-to-end encryption using Noise protocol.  

**Key Code:**  
```rust
// P2P Setup with libp2p
let behaviour = MarketBehaviour {
    kademlia: Kademlia::new(local_peer_id, kademlia_config),
    mdns: Mdns::new(Default::default()).await?,
};
```

---

### **2.2. WASM Execution Environment (WasmEdge)**  
- **Sandboxing Rules**:  
  - No GPU access (block `wgpu`, `WebGPU`, CUDA, OpenCL).  
  - Memory limits (configurable, default **4GB**).  
  - CPU core restrictions (max `n-1` threads).  
- **Security Measures**:  
  - **Pre-execution WASM validation** (detect GPU-related imports).  
  - **cgroups/Job Objects** (system-level isolation).  

**Key Code:**  
```rust
// WASM Execution Config
let config = ConfigBuilder::new()
    .with_max_memory_pages(256) // 16MB
    .disable_reference_types(true)
    .build()?;
```

---

### **2.3. Decentralized Marketplace (GunDB + IPFS)**  
- **Job Posting**:  
  - Stored in GunDB with metadata (WASM hash, bid, resources).  
  - IPFS for WASM binary storage (content-addressed).  
- **Job Execution Flow**:  
  1. Provider selects job from GunDB stream.  
  2. WASM fetched from IPFS.  
  3. Executed in sandbox.  
  4. Results pushed back to IPFS.  
  5. Payment via Lightning invoice.  

**Key Code:**  
```javascript
// GunDB Job Posting
gun.get('marketplace').get(jobId).put({
  owner: pubkey,
  wasm_hash: IPFS_CID,
  bid: 0.0001, // BTC
  status: 'available'
});
```

---

### **2.4. Payment System (Lightning Network)**  
- **Microtransactions**:  
  - Zero-conf channels for fast settlements.  
  - Watchtower service for dispute resolution.  
- **Payment Flow**:  
  - Job creator → Invoice → Provider → Payment → Completion proof.  

**Key Code:**  
```typescript
// Lightning Payment
const { request } = await lnd.createInvoice({ 
  tokens: job.bid * 100_000_000, // satoshis
  description: `Job ${jobId}` 
});
```

---

### **2.5. Admin & Update System**  
- **Decentralized Updates**:  
  - Signed IPFS packages (`admin_sig` verified).  
  - Propagated via GunDB radix tree.  
- **Admin Controls**:  
  - Force-update nodes.  
  - Emergency kill-switch.  

**Key Code:**  
```json
// Update Package Format
{
  "update_id": "v1.2.3",
  "ipfs_cid": "Qm...",
  "signature": "admin_sig",
  "target_nodes": ["U_pubkey1", ...]
}
```

---

## **3. Security Model**  

### **3.1. WASM Sandboxing**  
| **Threat**          | **Mitigation**                          |
|----------------------|----------------------------------------|
| GPU Access           | Block `wgpu`, `WebGPU`, CUDA imports   |
| Memory Exhaustion    | Hard limits via WasmEdge               |
| Infinite Loops       | CPU time quotas (cgroups)              |
| Malicious WASM       | Pre-execution validation               |

### **3.2. Network Security**  
- **Encryption**: Noise protocol (libp2p).  
- **Auth**: Nkey-based (similar to NATS).  
- **Anti-Spam**: Proof-of-work for job submissions.  

---

## **4. UI/UX Components**  

### **Desktop (Tauri + React)**  
- **Dashboard**:  
  - Real-time CPU/memory allocation.  
  - Earnings graph (sats/hour).  
- **Marketplace**:  
  - Live job board + bidding.  
  - WASM job preview sandbox.  

### **Mobile (React Native)**  
- Same core logic, optimized for touch.  
- Push notifications for job completions.  

---

## **5. Deployment Strategy**  

### **5.1. Packaging**  
| **Platform** | **Format**       | **Notes**                     |
|-------------|------------------|-------------------------------|
| Windows     | MSIX (Signed)    | Auto-updates via IPFS         |
| macOS       | Notarized .app   | Sandboxed                     |
| Linux       | AppImage/Flatpak | cgroups integration           |
| Android     | APK (NDK)        | Restricted via SELinux        |

### **5.2. Bootstrap Process**  
1. **First Run**:  
   - Fetch initial peer list from signed IPFS config.  
   - Connect to DHT.  
2. **Updates**:  
   - Nodes verify admin-signed packages.  
   - Fetch WASM bundles from IPFS.  

---

## **6. Developer Roadmap**  

### **Phase 1: Core P2P + WASM (2 Weeks)**  
- Implement libp2p + Kademlia.  
- WASM executor with GPU blocking.  

### **Phase 2: Marketplace + Payments (2 Weeks)**  
- GunDB job posting.  
- Lightning Network integration.  

### **Phase 3: UI + Admin Controls (2 Weeks)**  
- Tauri desktop app.  
- Decentralized update system.  

### **Phase 4: Testing & Optimization (1 Week)**  
- Security audit (WASM escapes, payment flaws).  
- Performance benchmarking.  

---

## **7. Key Challenges & Solutions**  

| **Challenge**               | **Solution**                          |
|-----------------------------|---------------------------------------|
| GPU Access Prevention       | WASM validation + cgroups             |
| Payment Disputes            | Watchtower service + LN arbitration   |
| Cross-Platform WASM         | WasmEdge + strict config              |
| Decentralized Updates       | Signed IPFS packages + GunDB          |

---

## **8. Final Deliverables**  
📦 **Single binary per platform** (~25MB)  
🔒 **Secure, audited WASM sandbox**  
⚡ **Real-time P2P job market**  
💰 **Bitcoin-only payment flow**  

---

## **Next Steps for Developer**  
1. **Clone repo**: `git clone [marketplace-repo]`  
2. **Start with Phase 1** (P2P + WASM).  
3. **Refer to detailed RFCs** in `/docs/`.  

**Need more details?** Ask about:  
- Specific WASM security concerns.  
- Lightning Network channel management.  
- GunDB conflict resolution.  

---

### **Appendix: Key Dependencies**  
| **Component**      | **Tech**                |
|--------------------|-------------------------|
| P2P Networking     | libp2p (Rust)           |
| WASM Runtime       | WasmEdge                |
| Database           | GunDB + SEA             |
| Payments           | LND + Liquid            |
| UI Framework       | Tauri + React Native    |

🚀 **Let’s build this!** 🚀
