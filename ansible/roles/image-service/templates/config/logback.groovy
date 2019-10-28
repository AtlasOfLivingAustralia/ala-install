import ch.qos.logback.core.util.FileSize
import grails.util.Environment
import org.springframework.boot.logging.logback.ColorConverter
import org.springframework.boot.logging.logback.WhitespaceThrowableProxyConverter

conversionRule 'clr', ColorConverter
conversionRule 'wex', WhitespaceThrowableProxyConverter
def loggingDir = '//var/log/atlas/image-service/'
def appName = 'image-service'
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

root(ERROR, [APPLICATION_LOG])
final error = [
]
final warn = [
        'au.org.ala',
        'au.org.ala.ws',
        'au.org.ala.images',
        'au.org.ala.web.config',
        'au.org.ala.cas',
        'org.springframework',
        'grails.app',
        'grails.plugins.mail',
        'org.hibernate',
        'org.quartz',
        'org.flywaydb',
        'asset.pipeline'
]
final info = [
]

final debug = [

]

final trace = [
]

for (def name : error) logger(name, ERROR)
for (def name : warn) logger(name, WARN)
for (def name: info) logger(name, INFO)
for (def name: debug) logger(name, DEBUG)
for (def name: trace) logger(name, TRACE)