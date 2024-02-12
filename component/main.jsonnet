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
    GRAFANA_URL: params.grafana_url,
    GRAFANA_USERNAME: params.grafana_username,
    GRAFANA_PASSWORD: params.grafana_password,
    GRAFANA_DATASOURCE_URL: params.grafana_datasource_url,
    GRAFANA_DATASOURCE_USERNAME: params.grafana_datasource_username,
    GRAFANA_DATASOURCE_PASSWORD: params.grafana_datasource_password,
    GRAFANA_CLEAR_AUTO_ASSIGN_ORG: params.grafana_clear_auto_assign_org,
    KEYCLOAK_USERNAME: params.keycloak_username,
    KEYCLOAK_PASSWORD: params.keycloak_password,
    KEYCLOAK_CLIENT_ID: params.keycloak_client_id,
    KEYCLOAK_URL: params.keycloak_url,
    KEYCLOAK_REALM: params.keycloak_realm,
    KEYCLOAK_ADMIN_GROUP_PATH: params.keycloak_admin_group_path,
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
