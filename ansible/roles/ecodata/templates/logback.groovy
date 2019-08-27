import ch.qos.logback.core.util.FileSize
import grails.util.Environment
import org.springframework.boot.logging.logback.ColorConverter
import org.springframework.boot.logging.logback.WhitespaceThrowableProxyConverter

conversionRule 'clr', ColorConverter
conversionRule 'wex', WhitespaceThrowableProxyConverter

def loggingDir = '/var/log/atlas/ecodata'
def appName = 'ecodata'
final APPLICATION_LOG = 'APPLICATION_LOG'
appender(APPLICATION_LOG, RollingFileAppender) {
    file = "${loggingDir}/${appName}.log"
    encoder(PatternLayoutEncoder) {
        pattern =
                '%d{yyyy-MM-dd HH:mm:ss.SSS} ' + // Date
                        '%5p ' + // Log level
                        '--- [%15.15t] ' + // Thread
                        '%-40.40logger{39} : ' + // Logger
                        '%m%n%wex' // Message
    }
    rollingPolicy(FixedWindowRollingPolicy) {
        fileNamePattern = "${loggingDir}/${appName}.%i.log.gz"
        minIndex=1
        maxIndex=4
    }
    triggeringPolicy(SizeBasedTriggeringPolicy) {
        maxFileSize = FileSize.valueOf('10MB')
    }
}

if (loggingDir != null) {
    appender("ES-INDEXING", FileAppender) {
        file = "${loggingDir}/elasticsearch-indexing.log"
        append = false
        encoder(PatternLayoutEncoder) {
            pattern = "%d{yyyy-MM-dd HH:mm:ss.SSS} - %msg%n"
        }
    }
    logger("EsIndexing", INFO, ['ES-INDEXING'], false)
}

root(WARN, [APPLICATION_LOG])
final error = [
]
final warn = [
        'au.org.ala.cas'
]
final info = [
        'asset.pipeline',
        'au.org.ala',
        'grails.app',
        'grails.plugins.mail',
        'com.mongo',
        'org.quartz',
        'org.springframework'
]

final debug = [
        'grails.mongodb',
        'grails.gorm',
        'au.org.ala.ecodata'
]

final trace = [
]

final esInfo  = [
        'au.org.ala.ecodata.ElasticSearchService'
]

for (def name : error) logger(name, ERROR)
for (def name : warn) logger(name, WARN)
for (def name: info) logger(name, INFO)
for (def name: debug) logger(name, DEBUG)
for (def name: trace) logger(name, TRACE)
for (def name: esInfo) logger(name, INFO, ["ES-INDEXING"])
