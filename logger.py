import os, sys
import coloredlogs, logging
import logging.config
from optparse import OptionParser

if __name__ == '__main__':

    parser = OptionParser()
    parser.add_option("-m",
                      "--mode",
                      dest="mode",
                      default=None,
                      help="Logging mode",
                      metavar="MODE")
    parser.add_option("-x",
                      "--exitcode",
                      dest="exitcode",
                      default=None,
                      help="Command exitcode",
                      metavar="EXITCODE")
    parser.add_option("-i",
                      "--input",
                      dest="input",
                      default='',
                      help="Logging input",
                      metavar="INPUT")
    (options, args) = parser.parse_args(sys.argv[1:])

    exitcode = options.exitcode
    mode = options.mode
    input = options.input

    if input is None or not input:
        raise ValueError("Input can not be None or empty.")

    logger = logging.getLogger()
    # create file handler which logs even debug messages
    logsDir = os.path.join(os.getenv("HOME"), 'var/log/bash_history')

    try:
        if not os.path.exists(logsDir):
            os.makedirs(logsDir)
    except Exception as err:
        print(err)
        exit(1)
        pass

    form = '%(asctime)s.%(msecs)04d %(hostname)s %(name)s[%(process)d] %(levelname)s %(message)s'

    logFile = os.path.join(logsDir, 'bash_history.log')

    loggingConfig = {
        'version': 1,
        'disable_existing_loggers':
        True,  # set True to suppress existing loggers from other modules
        'loggers': {
            '': {
                'level': 'DEBUG',
                'handlers': ['console', 'file'],
            },
        },
        'filters': {
            'hostname': {
                '()': 'coloredlogs.HostNameFilter'
            },
        },
        'formatters': {
            'colored_console': {
                '()': 'coloredlogs.ColoredFormatter',
                'format': form,
                'datefmt': '%H:%M:%S'
            },
            'format_for_file': {
                '()': 'coloredlogs.ColoredFormatter',
                'format': form,
                'datefmt': '%Y-%m-%d %H:%M:%S'
            },
        },
        'handlers': {
            'console': {
                'level': 'INFO',
                'class': 'logging.StreamHandler',
                'formatter': 'colored_console',
                'stream': sys.stdout,
            },
            'file': {
                'filters': ['hostname'],
                'level': 'DEBUG',
                'class': 'logging.handlers.RotatingFileHandler',
                'formatter': 'format_for_file',
                'filename': logFile,
                'maxBytes': 500000,
                'backupCount': 5
            }
        },
    }

    logging.config.dictConfig(loggingConfig)
    logger = logging.getLogger()

    coloredlogs.install(fmt=form, level='DEBUG', logger=logger)

    if mode is None:
        if exitcode is None:
            logging.info(input)
        elif exitcode == '0':
            logging.debug(input)
        else:
            logging.error(input)
    elif mode == 'info':
        logging.info(input)
    elif mode == 'debug':
        logging.debug(input)
    elif mode == 'error':
        logging.error(input)
    elif mode == 'warning':
        logging.warning(input)
    elif mode == 'critical':
        logging.critical(input)
    else:
        logging.info(input)
