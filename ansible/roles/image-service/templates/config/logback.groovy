import grails.util.BuildSettings
import grails.util.Environment
import ch.qos.logback.classic.filter.ThresholdFilter
import ch.qos.logback.core.util.FileSize
import org.springframework.boot.logging.logback.ColorConverter
import org.springframework.boot.logging.logback.WhitespaceThrowableProxyConverter
import static ch.qos.logback.classic.Level.*

import java.nio.charset.Charset

conversionRule 'clr', ColorConverter
conversionRule 'wex', WhitespaceThrowableProxyConverter

def loggingDir = '//var/log/atlas/image-service/'
def appName = 'image-service'

// See http://logback.qos.ch/manual/groovy.html for details on configuration
appender('STDOUT', RollingFileAppender) {
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

appender('INDEXING_LOG', RollingFileAppender) {
    file = "${loggingDir}/${appName}-indexing.log"
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

    filter('au.org.ala.images.ScheduleReindexAllImagesTask', ThresholdFilter){
        level = INFO

    }

    triggeringPolicy(SizeBasedTriggeringPolicy) {
        maxFileSize = FileSize.valueOf('10MB')
    }
}

appender('BATCH_LOG', RollingFileAppender) {
    file = "${loggingDir}/${appName}-batch.log"
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

appender('TIMING_LOG', RollingFileAppender) {
    file = "${loggingDir}/${appName}-timings.log"
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

def targetDir = BuildSettings.TARGET_DIR
if (Environment.isDevelopmentMode() && targetDir != null) {
    appender("FULL_STACKTRACE", FileAppender) {
        file = "${targetDir}/stacktrace.log"
        append = true
        encoder(PatternLayoutEncoder) {
            pattern = "%level %logger - %msg%n"
        }
    }
    logger("StackTrace", ERROR, ['FULL_STACKTRACE'], false)
}

root(INFO, ['STDOUT'])

final error = []
final warn = [
        'au.org.ala',
        'au.org.ala.ws',
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

final debug = []
final trace = []

for (def name : error) logger(name, ERROR, ['STDOUT'])
for (def name : warn) logger(name, WARN, ['STDOUT'])
for (def name: info) logger(name, INFO, ['STDOUT'])
for (def name: debug) logger(name, DEBUG, ['STDOUT'])
for (def name: trace) logger(name, TRACE, ['STDOUT'])

logger('au.org.ala.images.CodeTimer', INFO, ['TIMING_LOG'], false)
logger('au.org.ala.images.ScheduleReindexAllImagesTask', INFO, ['INDEXING_LOG'], false)
logger('au.org.ala.images.BatchService', INFO, ['BATCH_LOG'], false)
logger('au.org.ala.images.BatchController', INFO, ['BATCH_LOG'], false)
