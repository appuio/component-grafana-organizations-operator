local kap = import 'lib/kapitan.libjsonnet';
local inv = kap.inventory();
local params = inv.parameters.grafana_organizations_operator;
local argocd = import 'lib/argocd.libjsonnet';

local app = argocd.App('grafana-organizations-operator', params.namespace);

{
  'grafana-organizations-operator': app,
}
