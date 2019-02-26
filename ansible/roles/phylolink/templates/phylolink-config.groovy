debug = true

//address that resolves doi value
doiAddress = "http://dx.doi.org/"

//variables used for facetting
alaWebServiceMeta = [
        "speciesfacet":'taxon_name'
]

//external webservice
doiSearchUrl = "http://search.crossref.org/dois?q=SEARCH&header=true"
citationParser = "http://freecite.library.brown.edu/citations/create"

//ala webservices
occurrences = "BIOCACHE_SERVICE/occurrences/search?q=SEARCH&facets=LAYER&fq=REGION&flimit=1000000"
layers = "${spatialPortalRoot}/ws/layers"
fields = "${spatialPortalRoot}/ws/fields"
layerMetadata = "${spatialPortalRoot}/layers-service/layers/view/more/"

regionsUrl = [
        "state": "${regionsRoot}/regions/regionList?type=states",
        "ibra": "${regionsRoot}/regions/regionList?type=ibras"
];
speciesListUrl = "BIOCACHE_SERVICE/occurrences/facets/download?facets=${alaWebServiceMeta['speciesfacet']}&flimit=1000000&fq=REGION&fq=rank:species"
drUrl = "BIOCACHE_SERVICE/occurrences/search?q=data_resource_uid:DATA_RESOURCE&facets=${alaWebServiceMeta['speciesfacet']}&fq=REGION"
occurrencesSearch = "BIOCACHE_SERVICE/occurrences/search"
autocompleteUrl = "${bieRoot}/ws/search.json?q=QUERY&fq=idxtype:TAXON"
bieInfo = "${bieRoot}/ws/species/info/QUERY.json"
qidUrl = 'BIOCACHE_SERVICE/webportal/params'
listUrl = "${listToolBaseURL}/ws/speciesListItems/DRID?includeKVP=true"
listPost = "${listToolBaseURL}/ws/speciesList"
listCSV = "${listToolBaseURL}/speciesListItem/downloadList/DRID?id=DRID&action=list&controller=speciesListItem&max=10&sort=itemOrder&fetch=%7BkvpValues%3Dselect%7D&file=test"
listCsvForKeys = "${listToolBaseURL}/ws/speciesListItems/byKeys?druid=DRID&keys=KEYS&format=csv"
listKeys = "${listToolBaseURL}/ws/speciesListItems/keys?druid=DRID"
listsPermUrl = "${listToolBaseURL}/speciesListItem/list/DRID"
legendAla = 'BIOCACHE_HUB/legend'
lsidBulkLookup = "${bieRoot}/ws/species/lookup/bulk.json"

//opentree configs
find_all_studies= "${oti_address}/db/data/ext/QueryServices/graphdb/findAllStudies"
ot_api = "${ot_address}/api/v1"
tree_api = "${ot_api}/study/STUDYID/tree/TREEID"
newick_tree = "${tree_api}.tre"
studyMeta = "${ot_api}/study/STUDYID.json?output_nexml2json=1.2.1"
studyUrl = "${ot_api}/study/STUDYID.json?output_nexml2json=FORMAT"
treesearch_url = "${oti_address}/db/data/ext/QueryServices/graphdb/singlePropertySearchForTrees"
curator = "${ot_address}/curator"
to_nexson = "${curator}/default/to_nexson"

find_all_studies_postdata = [ "includeTreeMetadata":true, "verbose":true ]
search_postdata = ["property":"ot:originalLabel", "value":'', "verbose":true]
//opentree configs end

alaDataresourceInfo = [
        'id': -1,
        'drid': null,
        'scientificName': 'taxon_name',
        'biocacheServiceUrl':biocacheServiceUrl,
        'biocacheHubUrl':biocacheHubUrl,
        'title':'Atlas of Living Australia (All data)',
        'layerUrl': "/mapping/wms/reflect",
        'type':'ala'
]

// ala web service meta
layersMeta = [
        env:"Environmental",
        cl:'Contextual'
]

//variable config

// nexml2json 0.0 is best since other versions are giving errors.
nexml2json = "1.2.1"

// supported tree formats
treeFormats = [ 'nexml', 'nexus', 'newick' ]

jsonkey = [
        stList:"studies"
]

opentree_jsonvars=[
        searchTree :'matched_studies'
]

treeMeta = [
        numLeaves:'numberOfLeaves',
        numIntNodes:'numberOfInternalNodes',
        hasBL:'hasBranchLength',
        treeText:'tree',
        treeUrl:'treeViewUrl'
]
studyMetaMap = [
        name :'studyName',
        year :'year',
        authors:'authors'
]
expertTreesMeta=[
        et:'expertTrees'
]

nexmlMetaMapping = [
        "${studyMetaMap.name}":'data/nexml/^ot:studyPublicationReference',
        'focalClade': 'data/nexml/^ot:focalCladeOTTTaxonName',
        'doi': 'data/nexml/^ot:studyPublication/@href',
        'year':'data/nexml/^ot:studyYear'
]


studyListMapping=[
        'ot:studyPublicationReference': studyMetaMap.name,
        'is_deprecated': 'deprecated',
        'ot:focalCladeOTTTaxonName': 'focalCladeName',
        'ot:studyYear': studyMetaMap.year,
        'matched_trees':'trees',
        'is_deprecated': 'deprecated',
        'oti_tree_id': "treeId",
        'ot:tag': 'tag',
        'ot:curatorName': 'curator',
        'ot:studyPublication': 'doi',
        'ot:focalClade': 'focalCladeId',
        'ot:studyId': 'studyId',
        'ot:dataDeposit': 'source'
]

intersectionMeta =[
        name:'name',
        var:'variable',
        count:'count'
]

widgetMeta =[
        data:'data',
        chartOptions:'options'
]


//variable config end

/**** Phylo Link config end ****/

/**
 * Expert Tree config
 */

expert_trees = [
        [
                "group":"Amphibia",
                "studyId":"423",
                "treeId":"tree2857"
        ],
        [
                "group":"Birds",
                "studyId":"2015",
                "treeId":"tree4152"
        ]
        ,[
                "group":"Acacia",
                "studyId":"ot_29",
                "treeId":"tree5"
        ]
]

/** Tree config **/

/**
 * elastic search configs
 */
if( !app.elasticsearch.location ){
    app.elasticsearch.location = "/data/phylolink/elasticsearch/"
}
elasticBaseUrl = 'http://localhost:9200'
eIndex = 'phylolink'
eType = 'nexson'
elasticSchema = 'artifacts/schema.json'
facets ='''
        {
    "aggs" : {
        "Publisher" : {
            "terms" : {
                "field" : "^dc:publisher"
            }
        },
        "Expert Trees":{
            "terms":{
                "field" : "expertTree"
            }
        }
    }
}
'''