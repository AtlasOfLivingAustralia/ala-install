
//
// CAS Config
//
casProperties="casServerLoginUrl,serverName,centralServer,casServerName,uriFilterPattern,uriExclusionFilter,authenticateOnlyIfLoggedInFilterPattern,casServerLoginUrlPrefix,gateway,casServerUrlPrefix,contextPath"
serverName="http://{{ bie_webapp_hostname }}"
contextPath="{{ bie_webapp_context_path }}"
grails.serverURL="http://{{ bie_webapp_hostname }}{{ bie_webapp_context_path }}"
uriFilterPattern="/admin/.*"
casServerName="{{ auth_base_url }}"
uriExclusionFilterPattern="/images.*,/css.*,/js.*,/less.*"
casServerLoginUrl="{{ auth_cas_url }}/login"
gateway=false
casServerUrlPrefix="{{ auth_cas_url }}"
security.cas.logoutUrl="{{ auth_cas_url }}/logout"
authenticateOnlyIfLoggedInFilterPattern="/species/.*"
auth.admin_role="ROLE_ADMIN"
uriFilterPattern="/admin, /admin/.*"

//
// Application dependencies
//
bie.baseURL = "{{ bie_webapp_base_url }}"
bie.searchPath = "/search"

biocache.baseURL = "{{ biocache_base_url }}"
biocacheService.baseURL = "{{ biocache_ws_url }}"

spatial.baseURL = "{{ spatial_base_url }}"

ala.baseURL = "{{ ala_base_url }}"

collectory.baseURL = "{{ collectory_base_url }}"
collectory.threatenedSpeciesCodesUrl = "{{ collectory_base_url }}/public/showDataResource"

bhl.baseURL = "{{ bhl_base_url }}"

speciesList.baseURL = "{{ species_list_base_url }}"

userDetails.url = "{{ userdetails_url }}"
userDetails.path = "{{ userdetails_path }}"

alerts.baseURL = "{{ alerts_base_url }}"

brds.guidUrl = "{{ sightings_base_url }}"

ranking.readonly = true

