import ch.qos.logback.core.util.FileSize
import org.springframework.boot.logging.logback.ColorConverter
import org.springframework.boot.logging.logback.WhitespaceThrowableProxyConverter

conversionRule 'clr', ColorConverter
conversionRule 'wex', WhitespaceThrowableProxyConverter

def loggingDir = '/var/log/atlas/profile-service'
def appName = 'profile-service'
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
        maxIndex=20
    }
    triggeringPolicy(SizeBasedTriggeringPolicy) {
        maxFileSize = FileSize.valueOf('10MB')
    }
}

root(INFO, [APPLICATION_LOG])
final error = [
        'au.org.ala.cas.client',
        "au.org.ala",
        'grails.spring.BeanBuilder',
        'grails.plugin.webxml',
        "grails.plugin.mail",
        'grails.plugin.cache.web.filter'
]

final warn = [
]

final info = [
]

final debug = [
        "grails.app",
        "grails.plugin.mail"
]

final trace = [
        "grails.plugin.mail"
]

for (def name : error) logger(name, ERROR)
for (def name : warn) logger(name, WARN)
for (def name: info) logger(name, INFO)
for (def name: debug) logger(name, DEBUG)
for (def name: trace) logger(name, TRACE)

