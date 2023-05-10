// main template for grafana-organizations-operator
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
// The hiera parameters for the component
local params = inv.parameters.grafana_organizations_operator;

local namespace_meta = {
  metadata+: {
    namespace: params.namespace,
  },
};

local secret = kube.Secret('grafana-organizations-operator') + namespace_meta {
  stringData: {
    CONTROL_API_URL: params.control_api_url,
    CONTROL_API_TOKEN: params.control_api_token,
    GRAFANA_URL: params.grafana_url,
    GRAFANA_USERNAME: params.grafana_username,
    GRAFANA_PASSWORD: params.grafana_password,
  },
};

local statefulSet = kube.StatefulSet('grafana-organizations-operator') + namespace_meta {
  spec+: {
    template+: {
      spec+: {
        containers_+: {
          default: kube.Container('grafana-organizations-operator') {
            image: '%(registry)s/%(repository)s:%(tag)s' % params.image['grafana-organizations-operator'],
            resources: {
              limits: {
                cpu: params.limits.cpu,
                memory: params.limits.memory,
              },
              requests: {
                cpu: params.requests.cpu,
                memory: params.requests.memory,
              },
            },
            envFrom: [
                       {
                         secretRef: {
                           name: 'grafana-organizations-operator',
                         },
                       },
                     ] +
                     if params.grafana_secret != null then
                       [ { secretRef: { name: params.grafana_secret } } ]
                     else
                       [],
          },
        },
      },
    },
  },
};

[
  secret,
  statefulSet,
]
