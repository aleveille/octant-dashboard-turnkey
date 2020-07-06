# Octant Dashboard turnkey Docker image and Helm deployment files

This repository provides ready-to-use Helm deployment files and a Docker image
to deploy the [Octant](https://octant.dev/) tool in your Kubernetes cluster in
a read-only manner.

## What is Octant

From the [Octant GitHub repository](https://github.com/vmware-tanzu/octant):

> A highly extensible platform for developers to better understand the complexity of Kubernetes clusters.

Octant is a tool for developers to understand how applications run on a Kubernetes cluster. It aims to be part of the developer's toolkit for gaining insight and approaching complexity found in Kubernetes. Octant offers a combination of introspective tooling, cluster navigation, and object management along with a plugin system to further extend its capabilities.

## The purpose of this repo

I like Octant, but sometimes giving Kubectl config to your developers isn't
feasible or practical (for various reasons, which is another discussion
altogether!).

So I figured I could deploy octant in as a read-only dashboard alternative to
the official Kubernetes dashboard. This repository is me open-sourcing and
sharing my deployment configuration. I often use Keycloak Gatekeeper as an SSO
proxy to various application and this Helm deployment chart supports enabling
Gatekeeper as an SSO proxy to Octant.

Effectively, using this repo you can:
* Install Octant as read-only in your Kubernetes cluster(s)
* Protect that dashboard with SSO

## Installing with Helm

Bundled in this repository is a Helm chart to deploy Octant to Kubernetes.
Here's a sample deployment command:

```
helm upgrade octant-dashboard helm --namespace octant  --install --values myValues.yaml
```

Here's a sample `myValues.yaml` file compatible with [External DNS](https://github.com/kubernetes-sigs/external-dns), [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
and that assumes you are terminating SSL somewhere upstream. By default, this chart will have Octant listens on port `8000` (service & pod).

```
keycloakGatekeeper:
  enabled: true
  url: https://keycloak.yourdns.zone.com/auth/realms/master
  clientId: octantClientId
  clientSecret: 123e4567-e89b-12d3-a456-426655440000
  proxyPort: 4999

#imagePullSecrets:
#- name: someSecret

ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
    external-dns.alpha.kubernetes.io/target: yourdns.zone.com.
  hosts:
    - host: octant.yourdns.zone.com
      paths:
      - /
  tls: []
```


## Contributing or asking for features

While this repo is heavily inspired by my deployments of Octant and how I deploy
it, I'm happy to improve it if you have different needs (eg: other SSO proxies
or non-read-only deployments). Just open a GitHub issue and I'll see if I can
support your use-case.
