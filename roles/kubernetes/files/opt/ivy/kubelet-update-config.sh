#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
# shellcheck disable=SC1091
. /opt/ivy/bash_functions.sh

THIS_SCRIPT=$(basename "${0}")
PADDING=$(printf %-${#THIS_SCRIPT}s " ")

function usage () {
  echo "Usage:"
  echo "${THIS_SCRIPT} -c,--config <kubelet config file to update, default: /etc/kubernetes/kubelet/config.yaml>"
  echo "${PADDING} --cluster-domain <clusterDomain is the DNS domain for this cluster. REQUIRED>"
  echo "${PADDING} --cluster-dns <clusterDNS IP addresses for the cluster DNS server, repeat this parameter per IP. REQUIRED>"
  echo "${PADDING} --provider-id <providerID, if set, sets the unique ID of the instance that an external provider (i.e. cloudprovider) can use to identify a specific node. REQUIRED>"
  echo
  echo "Update kubelet config file"
  exit
}

declare -a CLUSTER_DNS=()
KUBELET_KUBECONFIG='/etc/kubernetes/kubelet/config.yaml'
while [[ $# -gt 0 ]]; do
  case "${1}" in
      -c|--config)
        KUBELET_KUBECONFIG="${2}"
        shift # past argument
        shift # past value
        ;;
      --cluster-domain)
        CLUSTER_DOMAIN="${2}"
        shift # past argument
        shift # past value
        ;;
      --cluster-dns)
        CLUSTER_DNS+=("${2}")
        shift # past argument
        shift # past value
        ;;
      --provider-id)
        PROVIDER_ID="${2}"
        shift # past argument
        shift # past value
        ;;
      -*)
        echo "Unknown option ${1}"
        usage
        ;;
  esac
done

if [[ -z ${CLUSTER_DOMAIN:-""} ]] || [[ -z ${CLUSTER_DNS:-""} ]] || [[ -z ${PROVIDER_ID:-""} ]]; then
  usage
fi

yq e -i ".clusterDomain = \"${CLUSTER_DOMAIN}\"" "${KUBELET_KUBECONFIG}"

for i in "${!CLUSTER_DNS[@]}"; do
  yq e -i ".clusterDNS[${i}] = \"${CLUSTER_DNS[${i}]}\"" "${KUBELET_KUBECONFIG}"
done

yq e -i ".providerID = \"${PROVIDER_ID}\"" "${KUBELET_KUBECONFIG}"
