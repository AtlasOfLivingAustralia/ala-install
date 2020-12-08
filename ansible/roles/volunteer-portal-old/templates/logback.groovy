import ch.qos.logback.classic.boolex.JaninoEventEvaluator
import ch.qos.logback.core.filter.EvaluatorFilter
import ch.qos.logback.core.util.FileSize
import grails.util.Environment
import org.springframework.boot.logging.logback.ColorConverter
import org.springframework.boot.logging.logback.WhitespaceThrowableProxyConverter

import static ch.qos.logback.core.spi.FilterReply.DENY
import static ch.qos.logback.core.spi.FilterReply.NEUTRAL

conversionRule 'clr', ColorConverter
conversionRule 'wex', WhitespaceThrowableProxyConverter
def loggingDir = '/data/digivol/logs/'
def appName = 'digivol'
final TOMCAT_LOG = 'TOMCAT_LOG'
final ACCESS = 'ACCESS'
final CAS = 'CAS'
final DEBUG_LOG = 'DEBUG_LOG'
final APPENDERS = [[name: TOMCAT_LOG, suffix: ''],[name:ACCESS, suffix: '-session-access'],[name: CAS, suffix: '-cas'],[name: DEBUG_LOG, suffix: '-debug']]
for (def a : APPENDERS) {
    switch (Environment.current) {
        case Environment.PRODUCTION:
            appender(a.name, RollingFileAppender) {
                filter(EvaluatorFilter) {
                    evaluator(JaninoEventEvaluator) {
                        expression = 'return logger.equals("org.grails.plugins.rx.web.RxResultSubscriber") && message.contains("Async Dispatch Error: Broken pipe");'
                    }
                    onMismatch = NEUTRAL
                    onMatch = DENY
                }
                file = "$loggingDir/$appName${a.suffix}.log"
                encoder(PatternLayoutEncoder) {
                    pattern =
                            '%d{yyyy-MM-dd HH:mm:ss.SSS} ' + // Date
                                    '%5p ' + // Log level
                                    '--- [%15.15t] ' + // Thread
                                    '%-40.40logger{39} : ' + // Logger
                                    '%m%n%wex' // Message
                }
                rollingPolicy(FixedWindowRollingPolicy) {
                    fileNamePattern = "$loggingDir/$appName${a.suffix}.%i.log.gz"
                    minIndex=1
                    maxIndex=4
                }
                triggeringPolicy(SizeBasedTriggeringPolicy) {
                    maxFileSize = FileSize.valueOf('10MB')
                }
            }
            break
        case Environment.TEST:
            appender(a.name, RollingFileAppender) {
                file = "$loggingDir/$appName${a.suffix}.log"
                encoder(PatternLayoutEncoder) {
                    pattern =
                            '%d{yyyy-MM-dd HH:mm:ss.SSS} ' + // Date
                                    '%5p ' + // Log level
                                    '--- [%15.15t] ' + // Thread
                                    '%-40.40logger{39} : ' + // Logger
                                    '%m%n%wex' // Message
                }
                rollingPolicy(FixedWindowRollingPolicy) {
                    fileNamePattern = "$loggingDir/$appName${a.suffix}.%i.log.gz"
                    minIndex=1
                    maxIndex=4
                }
                triggeringPolicy(SizeBasedTriggeringPolicy) {
                    maxFileSize = FileSize.valueOf('1MB')
                }
            }
            break
        case Environment.DEVELOPMENT:
        default:
            appender(a.name, ConsoleAppender) {
                filter(EvaluatorFilter) {
                    evaluator(JaninoEventEvaluator) {
                        expression = 'return logger.equals("org.grails.plugins.rx.web.RxResultSubscriber") && message.startsWith("Async Dispatch Error: Broken pipe");'
                    }
                    onMismatch = NEUTRAL
                    onMatch = DENY
                }
                encoder(PatternLayoutEncoder) {
                    pattern = '%clr(%d{yyyy-MM-dd HH:mm:ss.SSS}){faint} ' + // Date
                            '%clr(%5p) ' + // Log level
                            '%clr(---){faint} %clr([%15.15t]){faint} ' + // Thread
                            '%clr(%-40.40logger{39}){cyan} %clr(:){faint} ' + // Logger
                            '%m%n%wex' // Message
                }
            }
            break


    }
}

root(WARN, [TOMCAT_LOG])
logger('au.org.ala.volunteer.BVPServletFilter', INFO, [ACCESS], false)
logger('au.org.ala.volunteer.BVPSessionListener', DEBUG, [ACCESS], false)

logger('au.org.ala.cas', DEBUG, [CAS], false)
logger('org.jasig.cas', DEBUG, [CAS], false)

logger('grails.app.services.au.org.ala.volunteer.TaskService', DEBUG, [DEBUG_LOG], false)

final error = [

]

final warn = [

        'au.org.ala.cas.client',
        'au.org.ala.cas.util',
        'org.apache.coyote.http11.Http11Processor'
]

final info  = [
        'asset.pipeline',
        'au.org.ala',
        'grails.app',
        'grails.plugins.mail',
        'grails.plugins.quartz',
        'org.hibernate',
        'org.quartz',
        'org.springframework',
        'org.flywaydb'
]

final debug = [
//        'grails.app.services.au.org.ala.volunteer.ExportService',
//        'grails.app.controllers.au.org.ala.volunteer.ProjectController',
        'grails.plugin.cache'
//        'org.apache.http.headers',
//        'org.apache.http.wire',
//        'org.hibernate.SQL',
//        'org.springframework.cache',
//        'net.sf.ehcache',
//        'org.jooq.tools.LoggerListener'
]

final trace = [
//        'org.hibernate.type'
]

for (def name : error) logger(name, ERROR)
for (def name : warn) logger(name, WARN)
for (def name: info) logger(name, INFO)
for (def name: debug) logger(name, DEBUG)
for (def name: trace) logger(name, TRACE)
