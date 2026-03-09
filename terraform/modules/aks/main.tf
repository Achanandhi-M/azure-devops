###############################################################################
# modules/aks/main.tf
# Creates: AKS cluster with system-assigned managed identity, autoscaler,
#          Azure CNI networking, and RBAC enabled.
###############################################################################

resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.kubernetes_version

  # ── Identity ─────────────────────────────────────────────────────────────────
  # Use SystemAssigned managed identity — no need to manage service principal creds
  identity {
    type = "SystemAssigned"
  }

  # ── Default (System) Node Pool ────────────────────────────────────────────────
  default_node_pool {
    name            = "system"
    node_count      = var.node_count
    vm_size         = var.node_vm_size
    vnet_subnet_id  = var.subnet_id
    os_disk_size_gb = 50
    type            = "VirtualMachineScaleSets"

    # Cluster autoscaler
    enable_auto_scaling = true
    min_count           = var.min_node_count
    max_count           = var.max_node_count

    node_labels = {
      "nodepool-type" = "system"
      "environment"   = "production"
    }
  }

  # ── Networking ────────────────────────────────────────────────────────────────
  network_profile {
    network_plugin    = "azure" # Azure CNI — pods get VNet IPs
    network_policy    = "azure" # Azure Network Policy Manager
    load_balancer_sku = "standard"
    # Must NOT overlap with VNet (10.0.0.0/16) or AKS subnet (10.0.1.0/24)
    service_cidr      = "10.100.0.0/16"
    dns_service_ip    = "10.100.0.10"
  }

  # ── RBAC & AAD Integration ─────────────────────────────────────────────────
  role_based_access_control_enabled = true

  # ── OIDC Issuer ───────────────────────────────────────────────────────────────
  # Required for Workload Identity Federation (Azure DevOps service connection).
  # Once enabled, Azure WILL NOT allow this to be disabled — so we declare it
  # explicitly to prevent Terraform from trying to remove it on future applies.
  oidc_issuer_enabled = true

  # ── Monitoring ────────────────────────────────────────────────────────────────
  # Enable OMS Agent for Azure Monitor (optional but recommended)
  # oms_agent { log_analytics_workspace_id = "" }   # Uncomment if you want logs

  # ── Auto-upgrade ──────────────────────────────────────────────────────────────
  automatic_channel_upgrade = "patch" # Auto-patches within minor version

  tags = var.tags

  lifecycle {
    ignore_changes = [
      # Prevent Terraform from reverting node count set by autoscaler
      default_node_pool[0].node_count,
      kubernetes_version,
      # OIDC issuer cannot be disabled once enabled
      oidc_issuer_enabled,
    ]
  }
}
