terraform {
  required_version = ">= 1.5"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

data "http" "operator_ip" {
  count = var.operator_public_ip_cidr == "" ? 1 : 0
  url   = "https://ifconfig.me/ip"
}

locals {
  operator_cidr = var.operator_public_ip_cidr != "" ? var.operator_public_ip_cidr : "${chomp(data.http.operator_ip[0].response_body)}/32"
  sip_cidr      = var.sip_allowed_cidr != "" ? var.sip_allowed_cidr : local.operator_cidr
  web_cidr      = var.web_allowed_cidr != "" ? var.web_allowed_cidr : local.operator_cidr
}

resource "oci_core_vcn" "lab" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.project_name}-vcn"
  cidr_block     = var.vcn_cidr
  dns_label      = "issabellab"
}

resource "oci_core_internet_gateway" "lab" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.lab.id
  display_name   = "${var.project_name}-igw"
  enabled        = true
}

resource "oci_core_route_table" "lab" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.lab.id
  display_name   = "${var.project_name}-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.lab.id
  }
}

resource "oci_core_security_list" "lab" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.lab.id
  display_name   = "${var.project_name}-security-list"

  ingress_security_rules {
    protocol    = "6"
    source      = local.operator_cidr
    description = "SSH from operator IP only"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = local.web_cidr
    description = "HTTP for Issabel and Let's Encrypt"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = local.web_cidr
    description = "HTTPS for Issabel"
    tcp_options {
      min = 443
      max = 443
    }
  }

  ingress_security_rules {
    protocol    = "17"
    source      = local.sip_cidr
    description = "SIP UDP from trusted client network"
    udp_options {
      min = 5060
      max = 5060
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = local.sip_cidr
    description = "SIP TCP from trusted client network"
    tcp_options {
      min = 5060
      max = 5060
    }
  }

  ingress_security_rules {
    protocol    = "17"
    source      = local.sip_cidr
    description = "RTP media from trusted client network"
    udp_options {
      min = var.rtp_start_port
      max = var.rtp_end_port
    }
  }

  ingress_security_rules {
    protocol    = "17"
    source      = local.operator_cidr
    description = "WireGuard VPN from operator IP"
    udp_options {
      min = var.wireguard_port
      max = var.wireguard_port
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = local.operator_cidr
    description = "Grafana from operator IP"
    tcp_options {
      min = 3000
      max = 3000
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = local.operator_cidr
    description = "Prometheus from operator IP"
    tcp_options {
      min = 9090
      max = 9090
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow outbound package, DNS, NTP, ACME, and API traffic"
  }
}

resource "oci_core_subnet" "lab" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.lab.id
  display_name               = "${var.project_name}-public-subnet"
  cidr_block                 = var.subnet_cidr
  dns_label                  = "pbx"
  prohibit_public_ip_on_vnic = false
  route_table_id             = oci_core_route_table.lab.id
  security_list_ids          = [oci_core_security_list.lab.id]
}

resource "oci_core_instance" "issabel" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain_index].name
  compartment_id      = var.compartment_ocid
  display_name        = "${var.project_name}-vm"
  shape               = var.instance_shape

  dynamic "shape_config" {
    for_each = var.instance_shape == "VM.Standard.A1.Flex" ? [1] : []
    content {
      ocpus         = var.a1_ocpus
      memory_in_gbs = var.a1_memory_gbs
    }
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.lab.id
    assign_public_ip = true
    display_name     = "${var.project_name}-vnic"
    hostname_label   = "issabel"
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data           = base64encode(templatefile("${path.module}/cloud-init.yaml", { swap_size_gb = var.swap_size_gb }))
  }

  source_details {
    source_type = "image"
    source_id   = var.image_id
  }

  preserve_boot_volume = false
}
