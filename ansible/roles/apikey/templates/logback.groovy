import ch.qos.logback.core.util.FileSize
import grails.util.BuildSettings
import grails.util.Environment
import org.springframework.boot.logging.logback.ColorConverter
import org.springframework.boot.logging.logback.WhitespaceThrowableProxyConverter

import java.nio.charset.Charset

conversionRule 'clr', ColorConverter
conversionRule 'wex', WhitespaceThrowableProxyConverter

// See http://logback.qos.ch/manual/groovy.html for details on configuration
def loggingDir = System.getenv('LOG_DIR') ?: System.getProperty('logDir', './logs')
def appName = 'apikey'
def TOMCAT_LOG = 'TOMCAT_LOG'
switch (Environment.current) {
    case Environment.PRODUCTION:
        appender(TOMCAT_LOG, RollingFileAppender) {
            file = "$loggingDir/${appName}.log"
            encoder(PatternLayoutEncoder) {
                pattern =
                        '%d{yyyy-MM-dd HH:mm:ss.SSS} ' + // Date
                                '%5p ' + // Log level
                                '--- [%15.15t] ' + // Thread
                                '%-40.40logger{39} : ' + // Logger
                                '%m%n%wex' // Message
            }
            rollingPolicy(FixedWindowRollingPolicy) {
                fileNamePattern = "$loggingDir/$appName.%i.log.gz"
                minIndex=1
                maxIndex=4
            }
            triggeringPolicy(SizeBasedTriggeringPolicy) {
                maxFileSize = FileSize.valueOf('10MB')
            }
        }
        break
    default:
        appender(TOMCAT_LOG, ConsoleAppender) {
            encoder(PatternLayoutEncoder) {
                charset = Charset.forName('UTF-8')

                pattern =
                        '%clr(%d{yyyy-MM-dd HH:mm:ss.SSS}){faint} ' + // Date
                                '%clr(%5p) ' + // Log level
                                '%clr(---){faint} %clr([%15.15t]){faint} ' + // Thread
                                '%clr(%-40.40logger{39}){cyan} %clr(:){faint} ' + // Logger
                                '%m%n%wex' // Message
            }
        }
        break
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
jmxConfigurator()

root(WARN, [TOMCAT_LOG])
[
        (OFF): [],
        (ERROR): [
        ],
        (WARN): [
        ],
        (INFO): [
                'de.codecentric.boot.admin',
                'grails.plugin.externalconfig.ExternalConfig',
                'grails.app'
        ],
        (DEBUG): [
                'au.org.ala',
                'apikey'
        ],
        (TRACE): [
        ]
].each { level, names -> names.each { name -> logger(name, level) } }
