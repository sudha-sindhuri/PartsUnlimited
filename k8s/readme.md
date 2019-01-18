# PartsUnlimited k8s Edition

This demo is to show Container DevOps using Azure DevOps. It uses traefik to do canary testing.

## Prerequisites:
- helm
- traefik

## Building the PartsUnlimited Images
To build the images, invoke the Dockerfiles, passing in the image tag and version:

```sh
docker build . -t partsunlimitedapi:1.0.0.8 -f api.Dockerfile --build-arg version=1.0.0.8
docker build . -t partsunlimitedwebsite:1.0.0.8 -f api.Dockerfile --build-arg version=1.0.0.8
```

## Installing Traefik Ingress Controllers

You should install an internal and external controller to separate traffic on the cluster. For local testing, make the serviceType `NodePort` and make sure both instances are on different ports.

```sh
kubectl create ns pu

helm install stable/traefik --set dashboard.enabled=true,dashboard.domain=traefik-external.local,metrics.prometheus.enabled=true,service.nodePorts.http=30090,serviceType=NodePort,imageTag=1.7.6,kubernetes.ingressClass=traefik-external --name="traefik-external" --namespace pu

helm install stable/traefik --set dashboard.enabled=true,dashboard.domain=traefik-internal.local,metrics.prometheus.enabled=true,service.nodePorts.http=30080,serviceType=NodePort,imageTag=1.7.6,kubernetes.ingressClass=traefik-internal --name="traefik-internal" --namespace pu
```

## Helm install the Charts
Start the services by running the helm charts:

```sh
helm install --name pu-api --namespace pu partsunlimited-api/
helm install --name pu-web --namespace pu partsunlimited-website/
```

### Connecting from Docker-for-desktop
To access the site, use the hostname specified in the helm hosts value. Add a `hosts` entry and then tack on the nodeport for the traefik service. For example, the above traefik external port is `30090` and the hosts entry for the website ingress is `pu-web.local`. So to access the site, add
```
127.0.0.1   pu-web.local
```
to your hosts file and then browse to `http://pu-web.local:30090` and you should see the PartsUnlimited site!